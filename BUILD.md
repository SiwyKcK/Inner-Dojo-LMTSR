# Build and verify the three Inner Dojo overlays

## Environment

Use Windows x64 and PowerShell 7.6 or a compatible PowerShell 7 host on a recent
.NET runtime. The test host was PowerShell 7.6.9. This workflow builds game data;
there is no native mod DLL to compile with Visual Studio.

External prerequisites, not bundled here:

- A compatible `Andre.SoulsFormats.dll` from Smithbox. Tested assembly version
  `1.0.0.0`, SHA-256
  `306D6021B9BB8EC7F169951077AD6DFBBDA2FCE1CB35EB20C583F783F4DD9912`.
  Upstream source: https://github.com/vawser/Smithbox
  (the generic SoulsFormats API source is https://github.com/soulsmods/SoulsFormatsNEXT).
  Do not assume an arbitrarily newer assembly will serialize byte-identically.
- Sekiro Paramdex XML definitions. The tested XML snapshots are provided in
  `schemas/SDT/Defs` with hashes and upstream attribution. A compatible external
  copy can also be used: https://github.com/soulsmods/Paramdex
- If compressed source assets require it, provide your legally obtained
  `oo2core_6_win64.dll` via `-OodleLibrary`. It is not part of this repository.

The scripts have no auto-download or game-installation step. Obtain trusted
dependencies separately. Do not target an active game directory.

## Exact source inputs

Acquire the original mod downloads, extract them, and identify their **mods
root**, i.e. the folder containing `param`, `map`, `event`, `msg`, etc.

- NOOB: original LMTSR NOOB 20.43, not the author's personalized 60-second patch.
- Hardcore: original LMTSR Hardcore 20.43.
  Source page: https://www.nexusmods.com/sekiro/mods/603?tab=files
- Lone Wolf compatibility additionally requires Lone Wolf Master LMTSR Hardcore
  1.0 with Hot fix Execution Lady Butterfly 1.0 and Fix Hitbox 1 already applied
  to its extracted source folder. Source:
  https://www.nexusmods.com/sekiro/mods/2400

`REQUIRED_INPUT_FILES.json` pins the files actually consumed by the build.
The build checks these hashes before generating output. The original archive
names, hashes, dates and fix hashes are also in each variant's
`DOCS/SOURCE_PROVENANCE.json`. Do not substitute the private Inner Dojo package.

## Commands

In PowerShell 7, set paths to your extracted inputs and trusted library:

```powershell
$library = 'C:\review-tools\Smithbox\Andre.SoulsFormats.dll'
$defs = Join-Path $PWD 'schemas\SDT\Defs'
$noob = 'C:\review-inputs\LMTSR-NOOB-20.43\mods'
$hardcore = 'C:\review-inputs\LMTSR-Hardcore-20.43\mods'
$lonewolf = 'C:\review-inputs\Lone-Wolf-1.0-with-both-fixes\mods'
$oodle = 'C:\review-tools\oo2core_6_win64.dll'

.\tools\Rebuild.ps1 -Variant NOOB -BaseMods $noob `
  -OutputRoot 'C:\review-output\noob' `
  -SoulsFormatsAssembly $library -ParamDefs $defs -OodleLibrary $oodle

.\tools\Rebuild.ps1 -Variant HARDCORE -BaseMods $hardcore `
  -OutputRoot 'C:\review-output\hardcore' `
  -SoulsFormatsAssembly $library -ParamDefs $defs -OodleLibrary $oodle

.\tools\Rebuild.ps1 -Variant LONEWOLF -BaseMods $noob `
  -HardcoreMods $hardcore -LoneWolfMods $lonewolf `
  -OutputRoot 'C:\review-output\lonewolf' `
  -SoulsFormatsAssembly $library -ParamDefs $defs -OodleLibrary $oodle
```

Each `OutputRoot` must be a new, separate folder. The build refuses existing
output and paths inside a Sekiro installation. Do not disable these checks.
If a previous attempt created output, select a new output path for the next run.

Expected terminal results: `NOOB : PASS` (17), `HARDCORE : PASS` (17),
`LONEWOLF : PASS` (18). Inspect `reports/REBUILD_RESULT.json` in each output.
All expected relative paths, sizes and SHA-256 values are supplied in
`variants/<VARIANT>/EXPECTED_MOD_FILES.json`.

## What is rebuilt

1. The 44 additional Dojo PARAM rows are inserted into the original base binder.
2. World events 50 and 11011983 are integrated into the original world event file.
3. Text deltas are applied to the original language binders.
4. Typed map additions are replayed from the identified R2 map asset donor.
5. The combat event file is rebuilt from `BUILD_EVENT_IR.json` through the
   portable `WriteDojoEvent.ps1` writer; its template supplies container metadata.
6. Inherited navigation/UI/Lua assets are copied unchanged, like other build assets.
7. The optional Lone Wolf stage executes the original published parameter/text/SFX
   merge body with explicit input paths, preserving repeated row/resource IDs.
8. Every output file is compared with the exact original release member hash.

This is a reconstruction from code, editable event/delta data and inherited
binary asset inputs, not a claim to recreate every upstream game's binary asset
from an unavailable original art or Flash project.

## Verify an original ZIP without executing its scripts

Python 3.10+ with its standard library is sufficient:

```powershell
python .\tools\VerifyArchive.py 'C:\downloads\Inner_Dojo_for_LMTSR_NOOB_20.43.zip' --variant NOOB
python .\tools\VerifyArchive.py 'C:\downloads\Inner_Dojo_for_LMTSR_Hardcore_20.43.zip' --variant HARDCORE
python .\tools\VerifyArchive.py 'C:\downloads\Inner_Dojo_for_LMTSR_NOOB_20.43_Lone_Wolf_Compatibility.zip' --variant LONEWOLF
```

This reads ZIPs in memory and verifies identity/CRC; it neither extracts nor
runs scripts. No Internet access, running game or save is required.
