param(
 [Parameter(Mandatory)][ValidateSet('NOOB','HARDCORE','LONEWOLF')][string]$Variant,
 [Parameter(Mandatory)][string]$BaseMods,
 [Parameter(Mandatory)][string]$OutputRoot,
 [Parameter(Mandatory)][string]$SoulsFormatsAssembly,
 [Parameter(Mandatory)][string]$ParamDefs,
 [string]$HardcoreMods,
 [string]$LoneWolfMods,
 [string]$OodleLibrary
)
$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
$assets=Join-Path $repo 'source_assets'
$OutputRoot=[IO.Path]::GetFullPath($OutputRoot)
if(Test-Path -LiteralPath $OutputRoot){throw 'OutputRoot must be a new folder. No overwrite is performed.'}
foreach($inputPath in @($BaseMods,$HardcoreMods,$LoneWolfMods,$SoulsFormatsAssembly,$ParamDefs,$OodleLibrary)){
 if(-not $inputPath){continue}
 $absolute=[IO.Path]::GetFullPath($inputPath)
 if($OutputRoot -eq $absolute -or $OutputRoot.StartsWith(($absolute.TrimEnd('\')+'\'),[StringComparison]::OrdinalIgnoreCase)){throw 'OutputRoot must be separate from every input.'}
}
$cursor=$OutputRoot
while($cursor){
 if(Test-Path -LiteralPath (Join-Path $cursor 'sekiro.exe')){throw 'Do not build inside a Sekiro installation.'}
 if((Test-Path -LiteralPath $cursor) -and ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){throw 'Output ancestor is a reparse point.'}
 $cursor=[IO.Path]::GetDirectoryName($cursor)
}
Add-Type -Path $SoulsFormatsAssembly
if($OodleLibrary){
 [Runtime.InteropServices.NativeLibrary]::Load($OodleLibrary)|Out-Null
 $field=[SoulsFormats.Oodle].GetField('Oodle6Exists',[Reflection.BindingFlags]'NonPublic,Static')
 if($field){$field.SetValue($null,$true)}
}
. (Join-Path $PSScriptRoot 'Helpers.ps1')
$defs=$ParamDefs
$required=Get-Content -LiteralPath (Join-Path $repo 'REQUIRED_INPUT_FILES.json') -Raw|ConvertFrom-Json
$baseProfile=if($Variant -eq 'HARDCORE'){'HARDCORE'}else{'NOOB'}
$profiles=@{ $baseProfile=$BaseMods }
if($Variant -eq 'LONEWOLF'){
 Need ($HardcoreMods -and $LoneWolfMods) 'LONEWOLF requires HardcoreMods and LoneWolfMods'
 $profiles.HARDCORE=$HardcoreMods;$profiles.LONEWOLF=$LoneWolfMods
}
foreach($entry in $required){
 if(-not $profiles.ContainsKey($entry.profile)){continue}
 $file=Join-Path $profiles[$entry.profile] $entry.path
 Need ((Sha $file) -eq $entry.sha256) "Input hash differs: $($entry.profile)/$($entry.path)"
}
$baseDocs=Join-Path $repo ("variants\$baseProfile\DOCS")
$mods=Join-Path $OutputRoot 'mods'
$taskRoot=$OutputRoot
[IO.Directory]::CreateDirectory($mods)|Out-Null
[IO.Directory]::CreateDirectory((Join-Path $OutputRoot 'reports'))|Out-Null
# Inherited, unchanged game assets are copied; authored event instructions are rebuilt below.
foreach($rel in @('map\m10_00_00_00\m10_00_00_00.nva.dcx','map\m10_00_00_00\m10_00_00_00.nvmhktbnd.dcx','menu\02_205_bossselect.gfx','menu\hi\menu_boss_11490.tpf.dcx','script\m10_00_00_00.luabnd.dcx')){
 Copy-File (Join-Path $assets $rel) (Join-Path $mods $rel)
}
$evOut=Join-Path $mods 'event\m10_00_50_91.emevd.dcx'
$writerArgs=@{SoulsFormatsAssembly=$SoulsFormatsAssembly;OutputFile=$evOut;IRFile=(Join-Path $baseDocs 'BUILD_EVENT_IR.json');TemplateFile=(Join-Path $assets 'event\m10_00_50_91.emevd.dcx')}
if($OodleLibrary){$writerArgs.OodleLibrary=$OodleLibrary}
& (Join-Path $PSScriptRoot 'WriteDojoEvent.ps1') @writerArgs | Out-Null
# Recreate the 44 Dojo rows on the exact original target binder.
$rel='param\gameparam\gameparam.parambnd.dcx'
$target=[SoulsFormats.BND4]::Read((Raw (Join-Path $BaseMods $rel)))
$source=[SoulsFormats.BND4]::Read((Raw (Join-Path $assets $rel)))
$delta=Get-Content -LiteralPath (Join-Path $baseDocs 'EVIDENCE\PARAM_DOJO_DELTA.json') -Raw|ConvertFrom-Json
foreach($group in $delta|Group-Object table){
 $t=Table $target $group.Name $group.Name;$s=Table $source $group.Name $group.Name
 foreach($entry in $group.Group){
  Need $entry.new 'Only new Dojo rows are expected'
  Need (@($t.Rows|Where-Object ID -eq $entry.id).Count -eq 0) 'PARAM row collision'
  $t.Rows.Add([SoulsFormats.PARAM+Row]::new((Row $s $entry.id)))
 }
 $t.Rows.Sort([Comparison[SoulsFormats.PARAM+Row]]{param($a,$b)$a.ID.CompareTo($b.ID)})
 (Member $target ($group.Name+'.param')).Bytes=$t.Write()
}
$out=Join-Path $mods $rel
[IO.Directory]::CreateDirectory((Split-Path $out -Parent))|Out-Null
$target.Write($out,[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)
# World changes are limited to the two identified Dojo events.
$rel='event\m10_00_00_00.emevd.dcx'
$world=[SoulsFormats.EMEVD]::Read((Raw (Join-Path $BaseMods $rel)))
$worldSource=Read-E (Join-Path $assets $rel)
foreach($id in @(50,11011983)){
 $existing=@($world.Events|Where-Object ID -eq $id)
 if($existing.Count){$world.Events.Remove($existing[0])|Out-Null}
 $world.Events.Add((Clone-Event (Event $worldSource $id) $id))
}
$world.Write((Join-Path $mods $rel),[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)
# Apply the serialized text delta rather than copying complete target text binders.
$textDelta=Get-Content -LiteralPath (Join-Path $baseDocs 'EVIDENCE\MSG_DOJO_DELTA.json') -Raw|ConvertFrom-Json
foreach($fileGroup in $textDelta|Group-Object file){
 $binder=[SoulsFormats.BND4]::Read((Raw (Join-Path $BaseMods $fileGroup.Name)))
 foreach($memberGroup in $fileGroup.Group|Group-Object member){
  $member=Member $binder $memberGroup.Name;$fmg=[SoulsFormats.FMG]::Read($member.Bytes)
  foreach($entry in $memberGroup.Group){
   $existing=@($fmg.Entries|Where-Object ID -eq $entry.id)
   if($existing.Count){Need ($existing.Count -eq 1) 'Duplicate FMG entry';$existing[0].Text=$entry.text}
   else{$fmg.Entries.Add([SoulsFormats.FMG+Entry]::new($fmg,$entry.id,$entry.text))}
  }
  $fmg.Entries.Sort([Comparison[SoulsFormats.FMG+Entry]]{param($a,$b)$a.ID.CompareTo($b.ID)})
  $member.Bytes=$fmg.Write()
 }
 $out=Join-Path $mods $fileGroup.Name
 [IO.Directory]::CreateDirectory((Split-Path $out -Parent))|Out-Null
 $binder.Write($out,[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)
}
# Replay recorded typed map additions from their R2 asset donor. Name references
# are resolved by SoulsFormats; saved binary reference indices are not copied manually.
$rel='map\mapstudio\m10_00_00_00.msb.dcx'
$map=[SoulsFormats.MSBS]::Read((Raw (Join-Path $BaseMods $rel)))
$sourceMap=[SoulsFormats.MSBS]::Read((Raw (Join-Path $assets $rel)))
$mapDelta=Get-Content -LiteralPath (Join-Path $baseDocs 'EVIDENCE\MAP_SEMANTIC_DELTA.json') -Raw|ConvertFrom-Json
foreach($entry in $mapDelta.changes){
 $sec=$entry.section;$list=$entry.list;$index=[int]$entry.index
 Need ($sourceMap.$sec.$list[$index].Name -ceq $entry.name) 'Unexpected map source entry'
 if($entry.new){$map.$sec.$list.Add($sourceMap.$sec.$list[$index].DeepCopy())}
 else{Need $entry.cleanMatchesDonor 'Unresolved map conflict';$map.$sec.$list[[int]$entry.cleanIndex]=$sourceMap.$sec.$list[$index].DeepCopy()}
}
$out=Join-Path $mods $rel
[IO.Directory]::CreateDirectory((Split-Path $out -Parent))|Out-Null
$map.Write($out,[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)
if($Variant -eq 'LONEWOLF'){
 $noob=$BaseMods;$hc=$HardcoreMods;$lw=$LoneWolfMods
 $lwDocs=Join-Path $repo 'variants\LONEWOLF\DOCS'
 Copy-File (Join-Path $lwDocs 'EVIDENCE\AUTHOR_LONEWOLF_DELTA.json') (Join-Path $taskRoot 'reports\AUTHOR_LONEWOLF_DELTA.json')
 # Execute the reviewed original merge body with explicit inputs. All helper
 # loading, absolute workspace assignments and original output setup are excluded.
 $original=Get-Content -LiteralPath (Join-Path $lwDocs 'BUILD_SOURCE\BuildCleanVariantV2.ps1') -Raw
 $start=$original.IndexOf('$plan=Get-Content')
 Need ($start -gt 0) 'Original merge source marker missing'
 . ([scriptblock]::Create($original.Substring($start)))
}
$expected=Get-Content -LiteralPath (Join-Path $repo ("variants\$Variant\EXPECTED_MOD_FILES.json")) -Raw|ConvertFrom-Json
$checks=@()
foreach($entry in $expected){
 $file=Join-Path $mods $entry.path
 $actual=Sha $file
 $checks+=@{path=$entry.path;expected=$entry.sha256;actual=$actual;pass=($actual -eq $entry.sha256)}
}
$files=@(Get-ChildItem -LiteralPath $mods -File -Recurse)
$mismatches=@($checks|Where-Object {-not $_.pass})
$status=if($mismatches.Count -eq 0 -and $files.Count -eq $expected.Count){'PASS'}else{'MISMATCH'}
Json-Write @{variant=$Variant;status=$status;files=$checks;actualFileCount=$files.Count;expectedFileCount=$expected.Count;gameWritten=$false;runtimeTested=$false} (Join-Path $OutputRoot 'reports\REBUILD_RESULT.json')
if($status -ne 'PASS'){throw "Rebuild differs from original release: see $OutputRoot/reports/REBUILD_RESULT.json"}
"$Variant : $status; $($files.Count) game files match the original release."
