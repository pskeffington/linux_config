"""No-install tests for the master package registry and rendered manifests."""
import importlib.util
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("pkg_library", ROOT / "scripts/package-library.py")
PKG = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PKG)

class MasterPackageTests(unittest.TestCase):
    def test_catalog_integrity(self):
        self.assertEqual(PKG.validate(PKG.load()), [])
    def test_manifest_equivalence(self):
        self.assertEqual(PKG.compare_manifests(PKG.load()), [])
    def test_manual_packages_never_autoinstall(self):
        for pkg in PKG.load()["packages"]:
            if pkg["kind"] == "manual-review":
                self.assertIsNone(pkg["package_name"])
                self.assertFalse(pkg["install_default"])
                self.assertTrue(pkg["review_required"])
    def test_profile_counts(self):
        packages=PKG.load()["packages"]
        self.assertEqual(sum(x["kind"]=="native" for x in packages),33)
        self.assertEqual(sum(x["kind"]=="manual-review" for x in packages),6)

if __name__ == "__main__":
    unittest.main()
