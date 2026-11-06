# Clean NOOB + LoneWolf + Inner Dojo compatibility overlay

## Exact input set

Original LMTSR NOOB20.43 plus Lone Wolf Master LMTSR Hardcore1.0, including Hot fix Execution Lady Butterfly1.0 (2025-11-03) and Fix Hitbox1 (2026-09-02). SOURCE_PROVENANCE.json and FIXES_ALREADY_APPLIED.json identify the actual bytes. Both supplied fix files are identical to the corresponding files in the local LoneWolf source folder. The public version labels alone are not considered proof of their presence.

The old working NOOB_PATCH_01_60S_PLUS_LONE_WOLF_MASTER_NOOB_V.1 was only a comparison input. It contains the user's private patch and is not the output base. The old ZIP's three game files match that old NOOB60S base exactly. The user's report that this older combination worked is evidence for that older combination only.

## Build method

1. Start with the clean original NOOB integration of Inner DojoR4. Its map, world event, navigation, combat controller, other-language text and Hirata Lua resources remain byte-identical in this variant.
2. Compare current author LoneWolf PARAM with original Hardcore20.43 to isolate authored values. Compare PARAM rows by ID plus occurrence, not by ID alone: legacy helper tables contain repeated IDs. Preserve the relative order of duplicate rows with stable sorting.
3. Apply only the actual author delta to clean NOOB+Dojo.623new rows and49modified cells in45existing rows across12tables are copied. No row deletion or cell conflict was found. Other cells and binder members remain unchanged. A whole copied author PARAM would instead import Hardcore statistics.
4. Merge32 authored English FMG entry changes into Dojo text by member name and entry ID. Preserve the unrelated source text and Dojo entries. Original author English menu text has no substantive delta against the base, but the shipped Dojo menu file stays present.
5. Merge common SFX resources by filename, not BinderFile.ID; local IDs differ between source binders. Original NOOB contains174duplicate filenames with identical payloads. When a name is overridden by the author, every corresponding duplicate occurrence receives the same author payload; otherwise preserve every original occurrence and its bytes. Add170new names and override484existing names (515physical entries). Do not collapse or inconsistently overwrite duplicates.
6. Leave the14unchanged author HKS/CHR files in the required author download; REQUIRED_LONEWOLF_FILES_SHA256.json records them. The overlay contains18game files and must be installed last after the author files and both fixes. Do not launch between installing a Hardcore author PARAM and applying this NOOB compatibility overlay.

## Excluded private patch

The old patch changes Butterfly effects51413/51414 from24to60seconds and adds a private well ninja: entity1000999, NPC14709999, name c1470_Codex_HirataWellWall_0003, activation event11009991. These are excluded by construction and checked after reading the output. Both effect durations remain24seconds; all three private identifiers are absent where applicable.

The old patch additionally adds Hardcore item/skill/support records and modifies weapon5200/7000 behavior/resource fields. These are not wholesale imported. The clean output includes only the independent current author delta and Dojo additions. Needed author parameter references are checked separately; the old patch is not used as an implicit dependency bundle.

## File checks and limits

FINAL_READBACK.json records19628original PARAM rows checked,8022cells checked within edited rows, author row equivalence, untouched Dojo files, FMG and SFX preservation,24second durations and absence of private content. These are saved-file comparisons only. No game was launched, save edited, active installation written, RAM reader run or custom Tracer used. The user explicitly requested no gameplay testing due to lack of time.

PARAM_REFERENCE_AUDIT.json traverses simple conditional Paramdex references from changed/new authored rows.933rows/1147edges were visited. Every missing target also lacks a record in the supplied author PARAM; no target present in that author file was lost solely due to the NOOB rebase in this inspected scope. This does not prove all HKS/TAE branches, item unlock conditions or runtime paths. See SOURCE_GAPS_EN.md.

## Public packaging

This is an optional compatibility variant for the same future Inner Dojo page. Require original LMTSR NOOB and original LoneWolf downloads, specify both fix versions and install this overlay last. Do not claim compatibility with arbitrary future LoneWolf PARAM revisions. Credits and required modification/asset permissions must be settled before publishing; no upload was performed.
