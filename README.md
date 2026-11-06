# Inner Dojo for LMTSR — source and security review

Prepared for Nexus Mods support, concerning:
https://www.nexusmods.com/sekiro/mods/2904

This source review corresponds to the three original releases uploaded on
25 October 2026, not to the later personalized development package.

| Release | Game files | Archive SHA-256 |
| --- | ---: | --- |
| NOOB 20.43 | 17 | `428DE63A1F5A5F11350BB6409B60BDFEC64F573B3DFFF1F3151AB7B4E885AC83` |
| Hardcore 20.43 | 17 | `2D75E1944FCDABE55484F378FE3DC6F875777E1BFADD730DDE3394B009BE7095` |
| NOOB 20.43 + Lone Wolf | 18 | `5AB39FCFC344E6552EDF665AEEBD6E5AC18947BB26C5071BE85C53C5B9B6F4FF` |

The last hash is the same file shown in the supplied VirusTotal screenshot.
The original ZIPs contain no `.exe`, `.dll`, or nested ZIP/7z/RAR archives.
They do contain the PowerShell build/documentation sources listed in the audit.
This inventory is not a malware clearance or an explanation of any vendor flag.

## Where to start

1. Read [BUILD.md](BUILD.md) for prerequisites and exact build commands.
2. Inspect `tools/Rebuild.ps1`: it reconstructs the mod overlay on verified
   original game/mod inputs, in a new output folder, and checks every output hash.
3. Inspect `variants/NOOB/DOCS/BUILD_EVENT_IR.json` and the corresponding
   Hardcore representation. These describe the actual event instructions,
   restart behavior, instruction layers and argument bindings.
4. `variants/*/DOCS/BUILD_SOURCE` preserves every original published integration
   and analysis script, including its historical workspace paths. The portable
   review adapter replaces the need to recreate that workspace.
5. `variants/*/DOCS/EVIDENCE` records map/PARAM/text/author deltas and prior checks.
   Current reproduction results are under `verification/`.

## Source and assets

This is a data/asset modification, not a native Windows executable or injected DLL.
The game interprets its EMEVD events, map, parameters, Lua binder and UI assets.
It is not a standalone game: original LMTSR and the separately obtained Lone Wolf
inputs are required as appropriate.

`source_assets` contains the inherited binary asset inputs used by the build
(navigation, UI, Lua binder, row donor, world-event donor and R2 map donor).
These are explicitly identified as binary assets, not C#/Lua/Flash project source.
No original Flash authoring project or upstream LMTSR source repository is claimed.
Our event representation, integration algorithms and exact input/output records
are supplied, and all 52 game-file outputs were reproduced byte for byte locally.

No loader, HKS, ChainRec, save file, credentials, or original LMTSR full download
is bundled. External parsing libraries and proprietary Oodle are not redistributed.
`TOOLCHAIN.json` identifies the exact external assembly and definitions used.

## Verified scope

All three reconstructions passed on 6 November 2026: 17 + 17 + 18 exact output
hash matches. These are offline file builds; no game was launched, save changed,
or runtime behavior asserted during the review. ZIP byte-level recompression
is not the target; member game-file hashes must match the uploaded archives.

This repository folder was prepared locally. Preparing it does not mean it has
already been published on GitHub or reviewed/approved by Nexus Mods.

See [SECURITY_REVIEW.md](SECURITY_REVIEW.md) and [CREDITS_AND_ASSETS.md](CREDITS_AND_ASSETS.md).
