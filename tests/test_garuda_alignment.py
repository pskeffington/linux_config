"""Static regression guard: Garuda update and privacy-preserving defaults."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

class GarudaAlignmentTests(unittest.TestCase):
    def test_deploy_uses_native_update(self):
        script = (ROOT / "deploy.sh").read_text()
        self.assertIn("garuda-update", script)
        self.assertIn('[[ "${ID:-}" == "garuda" ]]', script)
        self.assertNotIn("sudo pacman -Syu", script)
        self.assertNotIn("garuda-update --aur", script)
    def test_theme_default_preserved(self):
        script = (ROOT / "deploy.sh").read_text()
        self.assertIn("THEME=keep", script)
        self.assertIn("AUTOMATION=off", script)
        self.assertIn("MODE=plan", script)
    def test_preflight_has_no_mutation(self):
        script = (ROOT / "scripts/garuda-preflight.sh").read_text()
        self.assertIn("garuda-update", script)
        self.assertNotIn("garuda-health --fix", script)
        self.assertNotIn("pacman -S ", script)

if __name__ == "__main__":
    unittest.main()
