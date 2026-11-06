# Restore original LMTSR Hardcore20.43

Close the game. Restore the12 original files from DOCS/ROLLBACK/mods into the installed mods directory. Then remove only the following5 added overrides if they did not exist before installation:

- mods/event/m10_00_50_91.emevd.dcx
- mods/map/m10_00_00_00/m10_00_00_00.nva.dcx
- mods/map/m10_00_00_00/m10_00_00_00.nvmhktbnd.dcx
- mods/menu/02_205_bossselect.gfx
- mods/menu/hi/menu_boss_11490.tpf.dcx

INSTALL_MANIFEST.json lists the exact original and output hashes. Do not remove the whole mods directory, original character assets or saves. The bundled rollback restores the supplied original Hardcore archive, not an installation customized with other mods. Use your personal backup for that case.
