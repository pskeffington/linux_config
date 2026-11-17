# Master package library (phase 1)

The canonical package specification is `packages/master-catalog.json`. Existing `packages/core.txt`, `sdr.txt`, `ham.txt`, and `desktop.txt` are **generated deployment views**, used by `deploy.sh`.

## Design contract
- Native pacman candidate entries have one package ID, owner, source, profile, hardware adapters, review flag, and evidence status.
- Package status `CANDIDATE_UNVERIFIED` means *neither package availability nor installation success is established*.
- AUR and upstream-source candidates are represented by `manual-review` records with `package_name: null`, never included in install manifests.
- `linux_config` is the installer manifest owner. `agent_skills` is the reusable operator and task-routing owner. No automatic cross-repository synchronization yet.
- `deploy.sh` remains the only host install entrypoint; package-library tooling never installs software.
- No implicit kernel-module blacklisting, flashing, privileged services, radio TX or PTT.

## Developer workflow
```bash
python scripts/package-library.py summary
python scripts/package-library.py validate --check
python scripts/package-library.py render
python -m unittest discover -s tests -v
bash tests/static.sh
bash scripts/resolve-package-library.sh
```

`render` is an explicit checked-in source transformation, not a network operation. Resolve script requires a **real Arch/Garuda host** and reads pacman metadata without installing software. Record the exact host OS, architecture, repository revision and timestamp with resolution evidence. Repo commit alone does not constitute package verification.

## Next phases
- Resolve actual sync-repository names and package versions on Garuda; review `soapyrtlsdr`, `rtl_433`, and separate GNU Radio components particularly carefully.
- Add model-specific Airspy, USRP, HackRF, SDRplay, USB audio, serial adapters and firmware compatibility without modifying attached hardware.
- Capture package dependencies, license, source provenance, risk, and version pins from observed authoritative metadata. Don't invent versions in the master catalog.
- Expand separately approved profiles for `mesh`, `digital-voice`, `field-digital` and offline maps/security once compatible deployment code and tests exist.
- Gate every selected bundle with independent build, offline fixtures, host packages and physical hardware acceptance.
