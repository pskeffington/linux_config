# Arch / Garuda RF field communications workstation

## Scope
Reproducible, modular deployment for lawful amateur-radio, SDR, packet, field communications, and digital-signal research on a fresh Arch-derived workstation. All configuration is RX-first. No service starts, keying, PTT, or TX is enabled by default.

## Workstreams
| ID | Sector | Stack | Acceptance gate |
|---|---|---|---|
| RF-00 | OS inventory | pacman, lsusb, lspci, udevadm, rfkill | OS/kernel and connected hardware recorded |
| RF-01 | DSP and SDR | rtl-sdr, SoapySDR, GNU Radio, GQRX | packages available; synthetic IQ processing |
| RF-02 | Radio and rig control | hamlib, fldigi, flrig | local GUI/CAT discovery only; no PTT |
| RF-03 | Packet | Dire Wolf, AX.25, APRS | synthetic/offline frame decode; TX held |
| RF-04 | Digital weak-signal | WSJT-X, JS8Call, WSPR | decode-only audio fixtures |
| RF-05 | Digital voice | codec2, FreeDV, DMR research | offline codec testing; legal mode checks |
| RF-06 | Field mesh | Meshtastic, LoRa, routing | USB/network inventory; local RX integration |
| RF-07 | Spectrum operations | waterfall, filters, logging, SigMF | offline recordings with metadata and hashes |
| RF-08 | Incident/workflow | logs, interoperability, battery/antenna plans | documented operator checklist |
| RF-09 | Validation | per-device adapter and test fixtures | evidence ledger distinguishes observed vs planned |

## Repository conventions
- `packages/*.txt`: candidate native package identifiers, checked with `pacman -Si` before install.
- `packages/aur-review.tsv`: optional upstream/AUR work requiring manual review.
- `scripts/`: idempotent read-only inventory and explicit-install entrypoints.
- `config/examples/`: templates only; no credentials, callsigns, private keys, or frequencies hardcoded.
- `literature/`: attributable source matrix; label standards, maintainers, practitioner guides and field reports separately.
- `evidence/`: locally generated, gitignored host/device inventories, benchmark outputs, and recordings.
- `docs/`: handoff and acceptance gates.

## Build sequence
1. RF-00 baseline and host inventory without root.
2. Run `scripts/check-packages.sh` to classify native package availability.
3. Install minimal profile with `scripts/install-profile.sh core` after operator approval.
4. Confirm device IDs and dedicated official-driver package support before extra firmware or kernel changes.
5. Verify IQ and audio processing offline; store test fixtures and SHA-256 evidence.
6. For any actual amateur TX: verify operator privileges, local band rules, equipment configuration, antenna and power limits, and receive-safe test plans separately.

## Safety and compliance
No scanning of private or encrypted transmissions for unauthorized access; no transmission without authorization. Amateur radio band plans are voluntary coordination guidance and do not substitute for FCC Part 97 or applicable national rules. Do not expose RTL-TCP/Soapy network receivers publicly by default. Do not assume a field/tactical product implies military use or permits jamming. Every hardware TX path is an explicitly gated future workstream.

## Key sources
- ArchWiki amateur radio: https://wiki.archlinux.org/title/Amateur_radio
- ArchWiki RTL-SDR: https://wiki.archlinux.org/title/RTL-SDR
- GNU Radio tutorials: https://wiki.gnuradio.org/index.php/Tutorials
- ARRL band plan: https://www.arrl.org/band-plan
- FCC Part 97: https://www.ecfr.gov/current/title-47/chapter-I/subchapter-D/part-97
