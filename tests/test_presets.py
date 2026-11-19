"""Static deployment-preset contract tests (no Garuda runtime required)."""
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
EXPECTED = {
    "base": "core",
    "rf-receiver": "core,sdr",
    "field-comms": "core,sdr,ham,desktop",
}

class PresetTests(unittest.TestCase):
    def test_presets_are_strict_and_nontransmitting(self):
        for name, profiles in EXPECTED.items():
            with self.subTest(preset=name):
                path = ROOT / "presets" / (name + ".conf")
                values = {}
                for line in path.read_text().splitlines():
                    if not line or line.startswith("#"):
                        continue
                    key, value = line.split("=", 1)
                    self.assertIn(key, {"PROFILES", "THEME", "AUTOMATION", "WORKSPACE"})
                    self.assertNotIn(key, values)
                    values[key] = value
                self.assertEqual(values["WORKSPACE"], name)
                self.assertEqual(values["PROFILES"], profiles)
                self.assertEqual(values["THEME"], "keep")
                self.assertEqual(values["AUTOMATION"], "off")

    def test_preset_staging_is_explicit(self):
        source = (ROOT / "deploy.sh").read_text()
        self.assertIn("--preset)", source)
        self.assertIn('[[ -z "$PRESET" ]] || bash "$ROOT/scripts/stage-preset.sh" "$PRESET"', source)
        self.assertIn("MODE=plan", source)
        self.assertIn("garuda-update", source)

    def test_no_radio_configuration_writes(self):
        source = (ROOT / "scripts/stage-preset.sh").read_text()
        self.assertNotIn("rigctl", source)
        self.assertNotIn("meshtastic --set", source)
        self.assertNotIn("systemctl --user enable", source)

if __name__ == "__main__":
    unittest.main()
