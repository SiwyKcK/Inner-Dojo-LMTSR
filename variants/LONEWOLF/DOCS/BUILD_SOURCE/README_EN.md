# Source workflow

All scripts contain workspace-specific trusted parser/tool paths. Adapt them to isolated copies before use. They must not target the active game directory.

InspectAuthorDelta.ps1 compares current author PARAM to original Hardcore and records actual field changes against a clean NOOB+Dojo target. It handles repeated PARAM IDs by occurrence. The previous patched merge is read only as historical comparison. InspectExcludedPatch.ps1 identifies the private patch changes. BuildCleanVariantV2.ps1 is the final integrated builder with stable row ordering and consistent duplicate SFX overrides. ReadbackCleanVariantV2.ps1 checks the saved file scope. AuditReferences.ps1 records recognized conditional parameter references and source gaps.

Common.ps1 uses SoulsFormats and Paramdex. Raw.ps1's examined DFLT payload handling is specific to those input archives. Copy the exact inputs identified by SOURCE_PROVENANCE before adapting the scripts. Never run the earlier unsuccessful draft builders as substitutes for this final source.

The shipped portable WriteDojoEvent.ps1 can rebuild the existing R4 Dojo container from BUILD_EVENT_IR.json. No additional combat event change is made by this LoneWolf integration.
