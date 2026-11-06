# Inner Dojo for original LMTSR Hardcore20.43

## Scope and evidence

This is the clean Hardcore integration candidate dated2026-10-24. See HARDCORE_ADAPTATION_EN.md for source-specific differences and the two Arashi phase thresholds. It requires the complete original Hardcore20.43 release (Nexus mod603). It is not compatible with unmodified base-game Sekiro by itself. Forty selectable encounters contain 43 individual enemies, split across two rooms. The user reported one successful trial of the prior R4 build; this newly rebased package has not been run in the game. File readback and manifests are bounded static evidence, not runtime proof. Do not claim exhaustive coverage.

## Read this package in order

1. SOURCE_PROVENANCE.json and INSTALL_MANIFEST.json establish exact input/output provenance.
2. ROSTER_EN.md / ROSTER.json list selection actor and controller IDs. COMBATANT_ROSTER.json is the historical individual roster; prefer the corrected sequence in ROSTER.json for order.
3. BUILD_EVENT_IR.json contains the final R4-based Hardcore Dojo plus the two modified world events; it is not a replacement for the complete original Hardcore world container. EMEDF.json defines instruction fields and types.
4. EVIDENCE/PARAM_DOJO_DELTA.json, MAP_SEMANTIC_DELTA.json, WORLD_DOJO_DELTA.json and MSG_DOJO_DELTA.json describe the clean rebase.
5. BUILD_SOURCE contains the actual workspace integration scripts and a portable event writer. Workspace scripts contain local source/tool paths: reconfigure and review them before use. Do not blindly run historical scripts against an installation.

## File architecture

- event/m10_00_50_91.emevd.dcx: independent Dojo event container; V20 R4 plus two Hardcore Arashi threshold changes,1572events.
- event/m10_00_00_00.emevd.dcx: original Hardcore Hirata events plus Dojo startup integration in event50 and owned-actor world guard11011983.
- map/mapstudio/m10_00_00_00.msb.dcx: original Hirata map plus 628 additional entries in typed MSB lists. Existing original entries are preserved semantically. Index fields are regenerated from named references when writing; raw Index/Indices values are not semantic differences. Duplicate names must be matched by type and occurrence, not a name-only dictionary.
- map/m10_00_00_00/*.nva.dcx and *.nvmhktbnd.dcx: separate navigation instances for the translated room.
- script/m10_00_00_00.luabnd.dcx: cumulative Dojo AI/script dependencies while retaining original map scripts.
- param/gameparam/gameparam.parambnd.dcx: original Hardcore binder with 42 new ActionButton rows9947..9988, Goods11490 and RematchWarp20. All existing rows and all other binder members are preserved.
- msg/{engus,jpnjp,zhocn,zhotw}/{item,menu}.msgbnd.dcx: original Hardcore text with only the inherited Dojo delta. Null/empty FMG entries may normalize on serialization. No unrelated item description edits are imported.
- menu/02_205_bossselect.gfx and menu/hi/menu_boss_11490.tpf.dcx: Dojo menu icon registration and preview. Goods11490 uses icon756. Original Hardcore supplies the common atlas; the old bomb atlas patch is not included.

All required CHR/SFX dependencies that were in the cumulative build match the original archive byte for byte, so they are not duplicated. Do not strip them from the required original Hardcore installation. No HKS DLL, Enma patch, Nightjar bomb patch, no-grass patch or personalized loader configuration is shipped.

## Entry, isolation and selection

RematchWarp20 provides the entry destination. Goods11490 supplies the Inner Dojo label/icon; the preconstructor/UI events11011981/11011982 and entry event11011980 integrate it. The arena lives in map m10_00_00_00 but is translated by X+2000 relative to the original room. Its collision is h016100_InnerDojo_V6 and its cloned navigation uses Model916100. Main region1012990 is the isolation boundary.

Selection uses two actors per ordinary encounter: a visible selector and a hidden combat actor. Do not turn every selector into a combatant. Room A/B switching uses existing door1001400, point170 and group flag11009071. Global fight flag11009050 and lock11009074 coordinate selection and cleanup. World event11011983 uses Restart behavior and suppresses the owned Dojo actors outside the arena. It is essential to prevent invisible battles, HP bars and XP gains in story Hirata. Maintain this guard and every start/finish matrix when adding encounters.

## Combat lifecycle

A start controller prepares the selected combat actor: disable AI, unhide backread, wait for loaded/backread/alive, enable appropriate animation state, clear that character's transient source markers, apply reset8010 and wait for full HP plus health bars. Other selectors/combatants are hidden according to ownership. The selected actor is warped to point1012816; Wolf uses1012815. The controller then sets team, gravity, HUD, force-target, active flag and AI/replan.

Do not globally disable Immortality to fix finish detection. Native Dojo reset relies on an alive actor and8010. The reset effect restores vitality/remaining deathblows; making the actor physically dead can break the next start. Finish waits for the remaining-health-bar criterion while preserving that reset contract. Cleanup disables combat, hides HUD, parks the actor at1012818, applies reset/hidden effects, performs the native recovery and restores selectors. Failure/exit must also terminate source combat ports and clear encounter state.

The implementation inherits native training recovery rather than manually rewriting inventory slots. Earlier user evidence includes emblems8→40 with storage994 unchanged and Pellet5+284 unchanged across images; actual Pellet consumption was not proven in that observation. Do not claim every consumable is refunded in every exit path without runtime evidence, and do not add arbitrary item grants as a workaround.

## Four-stage forest series: exact IDs

Root start11012350; root finish11012351; selector1010950; root-active11009908.

| Order | Character / model | Combat actor | Stage flag | HUD name |
|---:|---|---:|---:|---:|
| 1 | Ongyoki / c1450 Nightjar | 1010948 | 11009912 | 903403 |
| 2 | Kinki / c1180 Taro | 1010942 | 11009909 | 903400 |
| 3 | Fuki / c1070 Juzou | 1010944 | 11009910 | 903401 |
| 4 | Suiki / c7000 O'Rin | 1010946 | 11009911 | 903402 |

Transitions11012480,11012481,11012482 respectively implement1→2,2→3,3→4. Each waits for the current stage and HealthBars==0 with root/Wolf/region guards, stops that actor's combat ports, performs the inherited pause/reset/recovery and activates the next. Health-bar counts come from the Hardcore NPC records. Do not assume that every combatant has two bars. The old HP<=1 fallback from R1/R2 is removed; it could end an encounter too early during a finisher. Final success requires Suiki's active stage plus the final health-bar condition. This series is a custom sequential adaptation, not the original shared coordinator's HP system.

Combat port ranges: Kinki11012562..11012566; Fuki11012567..11012579; Suiki11012580..11012618; Ongyoki11012619..11012621. These ports preserve source-specific reactions, with root/stage/loaded/region gating.

R2 corrected invalid map flag-bank references: old11012352..11012356 were replaced by11009908..11009912. Passive historical evidence showed no registered10_01 flag category while native10_00 flags worked. Event IDs are not interchangeable with flag IDs. Audit bank registration and collisions before allocating any future flag; other historical custom flags have not all received the same runtime audit.

R3 changed the order but left Ongyoki in the inactive-actor hide list. Instructions980,983,986,989 in root start disabled his AI/enable/backread/animation after preparation; launch showed his HUD without restoring backread. R4 changes only those four instruction EntityID fields to the waiting Kinki. When reordering, update prep ownership, hideOthers exclusions, launch actor, stage flags, transitions, final actor and cleanup together. Do not globally remap every occurrence of an actor: their effect resets belong to their own source profile.

## Source mechanics that can look like bugs

Original forest NOOB uses an HP coordinator1500808 with NPC12602000; four actual deaths apply3126018, subtracting26% each. It is a separate shared HUD proxy. This package does not copy that shared-HP/quest/reward system into Dojo.

Ongyoki ports apply3145012 and invincibility when Wolf lacks2801 and3451; the reversal requires either effect and distance<=5. Suiki uses source state14023, with additional invulnerability logic around14022/8880/300614. These mechanics remain. Do not automatically remove them when investigating a missing actor. First distinguish backread/loaded/enable/position from an active source effect. Exact behavior with modified items needs a separate observation.

O'Rin's model is c7000. c1260 is Folding Screen Monkeys; the coordinator's NPC ID12602000 does not identify the visible woman's model. Source common20307788 concerns Puppeteer effects220030/220090/220091, not a generic deathblow signal. Do not use it as the normal finisher detector.

## Adding a combatant

1. Identify the exact NOOB map/actor variant, NPCParam, ThinkParam, model, animation variant and event phase. Record direct source IDs; do not infer event flags from a location name or story phase.
2. Trace NpcThink logic/battle IDs into the required Lua members; preserve existing Hirata binder entries. Trace animation imports, TAE markers, Behavior→Atk/Bullet/SpEffect dependencies. Keep altered source appearances and source scale unless the change is explicitly intended.
3. Allocate noncolliding combat/selector actors, prompt/ActionButton, start/finish IDs and valid active flags. Update both roster counts: a series selection can contain several combatants.
4. Materialize needed parameterized common events using typed argument offsets from EMEDF. Handle short fields and floats correctly; never replace every matching Int32 in a binary blob.
5. Replace source quest/arena activation with explicit Dojo start guards. Keep actual attacks, phase reactions, armor and transient markers. Do not copy story rewards, world defeat flags, fogwalls or source quest completion.
6. Add selector/map/region dependencies, per-round resets and cleanup. Extend all start/finish hide/restore lists, room switches and world isolation ownership. Preserve the translated room's navigation and collision.
7. Rebuild on copies, read the saved files back and record exact deltas. Then distinguish any later user/runtime result from static checks. This candidate does not require the user to exhaustively test every addition. No runtime trial of this Hardcore rebase has been performed.

## Debugging checklist for maintainers

HUD but no enemy: inspect backreadRemoved, loaded/enable, animation, warp destination/floor, hideOthers and source effects before changing HP or AI. Enemy attacks but never walks: inspect translated navigation instance/floor alignment; V12's isolated clone fixed a reported pursuit issue. Deathblows reach0 but no transition: inspect stage/root flag-bank validity and active guards before weakening the finish criterion. First hit skips both bars: ensure the old HP fallback was not reintroduced. Invisible story battles/XP: inspect region1012990 guards and world11011983 owned actors. Item conflicts: merge specific PARAM rows/cells and FMG IDs; do not copy the personalized full PARAM/common into this clean package.

Keep experiments separate and change one substantive cause at a time. Preserve prior releases, input archives and saves. Do not use the prohibited custom Sekiro/HKS Chain Tracer or its modules. Approved parsers such as SoulsFormats and documented editors are sufficient for file analysis. Never describe an unrun game test as passed.

## Rebuilding and distribution

The portable WriteDojoEvent.ps1 reads the shipped final IR, uses the shipped EMEVD as its template and writes a new output copy. Supply your own trusted SoulsFormats assembly and Oodle library where required. It preserves event parameters and instruction layers. Edit a copy of IR; avoid shifting instruction indexes without updating parameter mappings and relative skips.

Workspace BuildCore.ps1/BuildMap.ps1 document the exact clean integration process; their source paths must be adapted. EVIDENCE files retain the semantic delta and raw provenance. Do not run scripts against the active game folder.

Credits: LMTSR NOOB by assassin0800 supplies the original enemies/data; Resurrection1.16.x supplies the training-system lineage. This private candidate does not grant redistribution rights to either author's assets. Review the upstream permissions/credits before public release. No Nexus upload or public release was performed here.

## Current scope decision

The user explicitly postponed LoneWolf and other variants. This package is clean Hardcore plus Dojo. LoneWolf HardcoreV1.0 overlaps the complete PARAM and two English text binders; arbitrary overwrite order is not a compatibility merge. Do not add it to this product or claim compatibility without a later explicit variant.
