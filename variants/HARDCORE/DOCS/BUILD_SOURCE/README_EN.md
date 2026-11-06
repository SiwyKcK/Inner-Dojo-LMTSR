# Build sources for clean LMTSR Hardcore20.43

## Integration sequence

All scripts operate on isolated working copies; do not set their output paths to an active installation. The workspace-specific scripts contain absolute paths and must be reconfigured for another environment. Required inputs are identified by SOURCE_PROVENANCE.json and the evidence reports; they are not all redistributed in this private candidate.

1. Common.ps1 loads the approved SoulsFormats parser and schema; Raw.ps1 handles the examined original archive's DFLT variant.
2. AuditHardcore.ps1 compares original Hardcore and NOOB sources. The historical NOOB comparison input is used for analysis, not as the output game base.
3. BuildCore.ps1 opens the original Hardcore binder, adds the44 Dojo records, merges only the Dojo text delta, adds the world startup hook and copies separate Dojo/nav/Lua/UI resources. It starts from R4 combat events.
4. BuildMap.ps1 appends the628 typed Dojo entries to original Hardcore. It preserves named references and original entries, including the four additional Hardcore enemies.
5. PatchHardcorePhases.ps1 adapts the two Arashi source health-bar operands. It requires the unmodified R4 instructions and records exactly two changes.
6. Readback.ps1 validates existing PARAM rows, unrelated text and world event scope, final Hardcore Dojo hash and17-file count.

The report path READBACK_CLEAN.json is retained from the original integration script; its current contents identify Hardcore. The first whole-PARAM input is always original Hardcore, never the personalized NOOB/Enma/LoneWolf binder.

## Portable Dojo event writer

WriteDojoEvent.ps1 accepts -SoulsFormatsAssembly and -OutputFile, optionally -OodleLibrary, -IRFile and -TemplateFile. Use PowerShell7 and a trusted compatible SoulsFormats assembly. The shipped BUILD_EVENT_IR.json is the final Hardcore event representation; the supplied template preserves container metadata. The writer rebuilds instructions, layers, event restart behavior and parameter mappings into a new output file.

Relative skip counts and parameter instruction indices must be updated if instructions are inserted or removed. Editing an integer in a raw hex blob without checking EMEDF argument names/types can change the wrong field.

Raw.ps1's ZLib offset76 applies only to the examined DFLT variant. It is not a universal DCX offset. Other formats delegate to SoulsFormats.

The portable writer is checked through a file round-trip into Working. Game runtime is a separate unperformed stage.
