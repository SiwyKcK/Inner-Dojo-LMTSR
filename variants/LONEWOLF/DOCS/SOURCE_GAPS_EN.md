# Source gaps and verification boundary

The inspected conditional Paramdex reference graph contains15missing reference edges. None of their target records exists in the supplied LoneWolf author PARAM either, so the merge does not invent replacements or silently change attack effects.

Unique positive missing SpEffect targets: 3980062, 3980060, 104019, 1065353216.

The large counterSpEffectId1065353216 is recorded as interpreted by the current supplied Paramdef. Its operational meaning is not confirmed; it must not be treated as a proven runtime bug. Other absent targets are recorded with their exact AtkParam_Pc source rows in EVIDENCE/PARAM_REFERENCE_AUDIT.json. An entry can be unreachable, intentionally unused or require a different interpretation; file absence alone does not resolve that.

The traversal checks recognized simple conditions from Paramdex Meta Refs and positive IDs. It is not an exhaustive HKS/TAE/engine activation proof. The copied source HKS contains no direct literal references to the listed old private patch's support-record IDs in the targeted search, but that does not prove absence of computed or indirect dependencies.

No gameplay testing was requested or performed. Runtime status: NOT_TESTED_IN_GAME.
