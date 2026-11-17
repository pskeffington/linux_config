# Codex RF field communications handoff

Operate only in `linux_config`. Do not modify FIDES, TRANS, SDR Studio, or other repositories without explicit separate authorization. `linux_config` owns host configuration, install manifests, driver suitability checks, and acceptance evidence schema; other repos own their own DSP/service implementations.

## Each pass
1. Read `docs/ARCHITECTURE.md`, package manifests, and `literature/RF_FIELD_COMMS_MATRIX.tsv`.
2. Verify candidate packages using Arch Linux package metadata, not guesses. Record missing packages and vetted AUR alternatives.
3. Keep install script interactive; never silently run AUR helpers, alter boot modules, blacklist drivers, flash firmware, expose services, or enable TX.
4. Record each device with USB VID:PID, driver, permissions, RX status, data path, source and evidence hash. Do not commit host identifiers.
5. Build tests for synthetic IQ/digital audio decoding before bench hardware acceptance.
6. New citations require author, source, URL, source type, claim, date checked, and confidence.
7. Separate statutory/regulatory, primary engineering, practitioner and anecdotal claims.
8. For TX-related work, require operator licensing, band/mode jurisdiction check, RF safety and explicit human approval.
9. Maintain staged gates: source-verified / native-package-confirmed / simulated / read-only-hardware-verified / transmit-authorized. Never collapse stages.
10. Keep PR small and CI portable; shell syntax checks may run offline with `bash -n scripts/*.sh`.

## Next focus
Verify `pacman -Si` mappings for every candidate; add USRP, Airspy, HackRF, SDRplay and USB-serial hardware adapter matrices without treating physical presence as confirmed. Then prepare vendor-specific receive-only acceptance scripts and a structured operator literature expansion.

## Clone-and-deploy contract
- `deploy.sh` is the canonical entrypoint. Every new package group must be in `packages/<profile>.txt` and accepted explicitly by its profile switch.
- Keep `--plan` read-only, `--download` cache-only, and `--apply` install-plus-opt-in-configuration.
- On a fresh Arch/Garuda target, the user should need only git, clone, and one `bash deploy.sh --apply --profiles ...` command.
- KDE theme must default to `keep`; never silently replace Garuda's selected theme. Always check for installed assets and write user-level backups.
- Automations must be user-scoped, opt-in, and documented with disable instructions. No RF transmit or privileged background daemon.
- Run `bash tests/static.sh` before packaging; record the result from a real machine rather than claiming GitHub file creation is test execution.
- GitHub is the authoritative source for all source modifications. Keep acceptance evidence private on each target machine.

## Master package library contract
Treat `packages/master-catalog.json` as the canonical candidate package catalog; `packages/*.txt` are generated deployment views. Before editing the manifests:
1. Update the master catalog and its source, owner, hardware and review metadata.
2. Run `python scripts/package-library.py render` and verify the diff.
3. Run `python scripts/package-library.py validate --check` and `python -m unittest discover -s tests -v`.
4. Verify candidate names on actual Arch/Garuda host with `bash scripts/resolve-package-library.sh`. Record status per architecture, release and timestamp; do not claim host verification from CI alone.
5. Never promote manual/AUR candidates into pacman install lists automatically or claim TX acceptance.

The master operator skill in `agent_skills` proposes capability groupings; only the reviewed `linux_config` source can change host package operations.
