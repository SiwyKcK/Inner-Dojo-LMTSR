# Hardcore adaptation — 2026-10-24

## Exact scope

This is a separate17-file Inner Dojo overlay for the supplied original LMTSR Hardcore20.43 archive. The previous NOOB overlay is preserved separately. Runtime status: NOT_TESTED_ON_CLEAN_HARDCORE. No LoneWolf or personalized patches are included. Installation and saves were not modified by the agent.

## Why a NOOB PARAM cannot simply be reused

The original archives each have98 game files. Nine differ: seven EMEVD containers, the Hirata MSB and PARAM. Changed PARAM tables include EquipParamGoods, EquipParamWeapon, ItemLotParam, NpcParam, SkillParam and SpEffectParam. Replacing the complete Hardcore PARAM with the NOOB Dojo PARAM would erase those differences.

The builder instead opens the supplied Hardcore binder and adds only the44 owned Dojo rows: ActionButton9947..9988, EquipParamGoods11490 and RematchWarp20. Readback verifies all original rows and other binder members are unchanged, retaining Hardcore health bars, stats, items and skills. No enemy balancing row was edited.

## World map and events

Hardcore has243 original Hirata enemy entries; NOOB has239. The builder preserves all original Hardcore entries and appends628 typed Dojo MSB entries. Duplicate names are matched by type/name/occurrence; serialization index fields are ignored during semantic comparison and rebuilt by the parser. A named enemy from a previously personalized donor is intentionally not imported.

The Hardcore Hirata event container has533 original events versus510 in the original NOOB. All original Hardcore events are retained; only event50 gains the existing Dojo startup hook, and11011983 is added as the owned-actor isolation guard. The remaining23 original Hardcore additions are not replaced with NOOB events. Hardcore common and other world event containers stay in the required base mod, not in this overlay.

## Ported combat difference: Arashi

The collected source-event metadata of the cumulative Dojo releases was checked against source events that differ between Hardcore and NOOB. Two mapped source events differ: m25/11504504→Dojo11012202 and11504505→11012203, both for Okami Leader Arashi.

In the original Hardcore source,11504504 tests remaining bars==2 (NOOB==1), and11504505 tests bars==3 (NOOB==2). The two Dojo instruction4 operands are changed to2 and3 accordingly. Entity/active/loaded/arena guards and all other instructions remain as in R4. This preserves the original Hardcore phase timing rather than merely changing statistics.

The saved Dojo event differs from R4 in exactly these two instructions;1570other events are identical. The forest-series flag-bank correction, strict final health-bar finish condition, new order and R4 hideOthers/backread correction are retained. R4 was originally developed against the NOOB lineage; source comparison and file checks do not imply a complete runtime validation of every Hardcore encounter.

## Preserved resources and known limits

Original CHR, AI script archives and SFX dependencies checked in the original archives are identical between Hardcore and NOOB. The overlay relies on the installed original Hardcore for these shared assets and provides the cumulative Dojo Hirata Lua binder. No c0000 player moveset override is included.

English/Japanese/SimplifiedChinese/TraditionalChinese text binders preserve original source text outside the inherited Dojo delta. The menu label for the forest series retains source-name order; actual controller order is Ongyoki→Kinki→Fuki→Suiki. Hardcore health-bar counts are not forced to match NOOB.

All shipped results are static saved-file evidence. No game trial was run; one reported prior successful trial belongs to a different build/base. Source boss special effects/invulnerability remain. Custom active flag banks beyond the historically corrected forest bank have not all been confirmed in runtime.

## Evidence

EVIDENCE/HARDCORE_VS_NOOB_FILES.json, HARDCORE_VS_NOOB_EVENTS.json, HARDCORE_VS_NOOB_PARAM_TABLES.json, MAP_SEMANTIC_DELTA.json, HARDCORE_ARASHI_PHASE_PATCH.json, HARDCORE_DOJO_READBACK.json and READBACK_CLEAN.json contain the concrete inputs and checks. READBACK_CLEAN is a historical script filename; its runtime field explicitly states clean Hardcore.
