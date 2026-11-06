# Build status — clean Hardcore20.43

Date:2026-10-24. Private review candidate.17 mod files:12 replacements and5 additions. Requires the complete original Hardcore20.43 installation and its working loader. No LoneWolf, Enma, HKS DLL, custom bomb, no-grass patch or loader settings are shipped.

## Confirmed file checks

- All existing Hardcore PARAM rows retained;44 new owned records in ActionButtonParam/EquipParamGoods/RematchWarpParam. Other binder members unchanged.
-628 map entries appended, preserving original Hardcore entries and original enemy count243 before additions.
- All original Hardcore world events retained; event50 modified for the startup hook and new11011983 added.
- Dojo contains exactly two changed instruction operands relative to R4, adapting Arashi thresholds to Hardcore;1570 other events unchanged. SHA256:22904BAEA6BCDEE86F4AC11274132892CB9343D0E7E4EDF9EC5247928A944F4C.
- English/Japanese/SimplifiedChinese/TraditionalChinese text retains unrelated source entries. The inherited Dojo text delta contains193 entries across these binders.
- Required shared CHR/SFX assets come from the original mod. No player c0000 override.

## Runtime boundary

NOT_TESTED_ON_CLEAN_HARDCORE. No game/save writes or game/RAM reader launch by the agent. The user's one previous successful test belongs to an earlier build on another base. This package does not claim all encounters, item refunds, flag banks or exit paths were tested.

LoneWolf work was explicitly deferred by the user. The overlap analysis in Working identified full PARAM and two English MSG binders, so no arbitrary installation-order compatibility claim is made.

Portable event writer reproduced the shipped Hardcore Dojo file byte for byte. See EVIDENCE/PORTABLE_WRITER_READBACK.json.

Additional saved-file checks: 9946 original MSB entries preserved semantically;284 new explicit map EntityIDs checked against original Hardcore and each other, no collisions; all43 combatants reference existing NPC/Think records. Nominal source NPC health-bar counts:4 actors with2,38 with3,1 with4. These are PARAM values, not runtime measurements.
