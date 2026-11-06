# Uninstall / restore original NOOB 20.43

Close the game. Restore the 12 overwritten files from DOCS/ROLLBACK/mods into the installed mods directory. Then remove only these five added overrides, provided they did not exist before this package:

- mods/event/m10_00_50_91.emevd.dcx
- mods/map/m10_00_00_00/m10_00_00_00.nva.dcx
- mods/map/m10_00_00_00/m10_00_00_00.nvmhktbnd.dcx
- mods/menu/02_205_bossselect.gfx
- mods/menu/hi/menu_boss_11490.tpf.dcx

Do not delete the whole mods directory, character assets, saves, or other installed mods. INSTALL_MANIFEST.json lists exact paths and original/output hashes. The included rollback restores the supplied original NOOB archive, not a personalized installation. Use your personal backup when reverting a customized base.
