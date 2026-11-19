# Social and practitioner identity research for Linux RF field communications

## Definition and ranking
These are public project organizations, public self-selected handles, and attributable professional operator identities—not private personal profiles, verified follower-count rankings, or alleged intelligence/military affiliations. `P1` means direct utility to the Arch/Garuda deployment and evidence-backed upstream authorship; `P2` means useful practitioner coverage or community review. No unverified social account is assigned to a named person.

## Technical extraction queue
| Source lane | Extract into deployment | Required validation |
|---|---|---|
| GNU Radio core/architects | DSP pipelines, build compatibility, Python/C++ ABI and test fixtures | Official release notes and Arch dependency checks |
| Meshtastic project | CLI/serial drivers, network integration and observability | Official firmware/CLI docs; read-only hardware enumeration |
| WB2OSZ Dire Wolf | AX.25/APRS soundcard decode, offline audio fixtures | Version-pinned sample audio and upstream test guidance |
| David Rowe / FreeDV | Codec2 ABI, offline speech and modem encode/decode test | Project release/specification and objective signal metrics |
| KM4ACK Build-a-Pi | User-facing installer selection menus and repair workflow | Reimplement native Arch design; do not execute third-party bootstrap scripts |
| OH8STN | Portable digital modes, field power/antenna, Linux operating checklist | Separate field anecdotes from measured reproducible benchmarks |
| Ham Radio DX | SDR front end, receiver integration, LNA/switching | Technical hardware safety and manufacturer documentation |
| argilo | GQRX/NRSC5 and upstream bug triage | Cross-check author-controlled repositories |
| Ham Radio Workbench | Field station assembly, audio, power, operator ergonomics | Episode-specific notes and hardware tests |

## Evidence policy
Use official project websites, maintained repositories, operator-published channels or credited publications. Distinguish measured technical contributions from subscriber reach. An account's existence is not evidence for a particular package, driver, equipment recommendation, military background, or authority. Do not scrape private group identities or attempt to link pseudonymous users to real names. Archive source URL, access date, deployment hypothesis and acceptance outcome; avoid storing personal emails or contact details.

## Next passes
1. Add a machine-readable `source_to_package.tsv` linking each public technical source to proposed native package and driver tests.
2. Add release freshness and last-verified dates; verify every nominated handle independently before claiming cross-platform identity.
3. Add a weighted scoring rubric: upstream maintainership 35%, reproduced engineering evidence 30%, Arch compatibility 20%, community operator clarity 15%. No social popularity substituted for technical expertise.
4. Expand public field user cohorts: ARES/RACES, portable HF, mesh, satellite, digital voice, SDR learning and interoperability. Avoid unverifiable tactical affiliations.
5. Add test-based acceptance statuses, never mark tested solely from a video or README.
