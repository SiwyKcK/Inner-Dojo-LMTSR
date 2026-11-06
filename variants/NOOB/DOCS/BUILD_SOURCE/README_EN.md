# Build sources

WriteDojoEvent.ps1 is the portable event writer. Run with PowerShell7 and a trusted compatible SoulsFormats assembly, using a new output path. It consumes the shipped BUILD_EVENT_IR.json and final EMEVD template. Parameters: -SoulsFormatsAssembly, -OutputFile and optionally -OodleLibrary, -IRFile, -TemplateFile.

The other scripts are actual clean-base workspace integration sources. Reconfigure taskRoot, donorRoot, baseRoot, defs and assembly/tool paths to your own copies before running. BuildCore expects PARAM_DOJO_DELTA.json and the historical donor; BuildMap derives additions from the clean input and cumulative donor. Historical inputs are identified in SOURCE_PROVENANCE and EVIDENCE and are not all redistributed here. Never run historical scripts blindly against a game installation.

Raw.ps1 handles this examined original archive's DCX DFLT payload with ZLibStream at offset76; other variants delegate to SoulsFormats. That offset is not a general DCX rule.

The integration adds44 PARAM rows and628 MSB entries, using typed list/name/occurrence identity. Do not compare raw MSB reference indices; the writer regenerates them. World event50 matched between clean and donor;11011983 is new. FMG uses the donor-to-Dojo delta applied to original text. Readback.ps1 checks the saved output scope. These checks were run, but no clean-base game trial was run. The portable writer reproduced the shipped R4 EMEVD byte for byte. This is a file round-trip, not a game trial.

Portable event writer: executed on a working copy; output SHA256 identical to the shipped R4 EMEVD. See EVIDENCE/PORTABLE_WRITER_READBACK.json.
