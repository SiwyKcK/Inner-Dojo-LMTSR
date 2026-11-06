# Security-review notes

The supplied VirusTotal screenshot identifies ZIP
`5AB39FCFC344E6552EDF665AEEBD6E5AC18947BB26C5071BE85C53C5B9B6F4FF`,
the original NOOB/Lone Wolf compatibility release. It shows 5/62 detections.
Neither that count nor a heuristic label determines the exact cause or proves
that a specific contained file is clean/infected.

`RELEASE_ARCHIVE_AUDIT.json` lists every original ZIP member and SHA-256.
The three archives passed ZIP CRC and matched the retained original manifests.
No member was a named Windows EXE/DLL/COM/SCR/MSI or began with an MZ header.
No nested ZIP/7z/RAR archive was found by the reported filename/header checks.
There are PowerShell scripts under DOCS/BUILD_SOURCE: 6 in NOOB, 9 in Hardcore
and 8 in Lone Wolf. These were included to document build/analysis work.
They are not automatically executed by the game.

Game files are 17/17/18 data overrides: `.dcx` containers and one `.gfx` asset.
The review does not claim a full antivirus/static-code audit, signature scan of
every decompressed object, or approval by Nexus Mods.

For the support team: if a particular member triggered a scanner, please identify
its archive-relative path and SHA-256 so that it can be investigated directly.
The unmodified submitted ZIPs have been preserved. No byte changes were made
merely to evade a detection.

The new portable builder performs local file I/O, uses a separately provided
parsing library and optionally Oodle, and writes only a new build directory.
It has no downloader, network client, process injector or save-writing step.
Historical scripts retain absolute development paths: inspect them as historical
source and use the portable adapter rather than running them blindly.
