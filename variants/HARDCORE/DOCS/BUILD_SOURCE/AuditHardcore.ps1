. (Join-Path $PSScriptRoot 'Common.ps1')
. (Join-Path $PSScriptRoot 'Raw.ps1')
$taskRoot='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\HARDCORE_MAIN_PACKAGE'
$hc=Join-Path $taskRoot 'input\mods'
$noob='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\CLEAN_NOOB_MAIN_PACKAGE\input\mods'
function EventSig($e){[ordered]@{rest=[string]$e.RestBehavior;instructions=@($e.Instructions|ForEach-Object {@{b=$_.Bank;o=$_.ID;l=$_.Layer;h=[Convert]::ToHexString($_.ArgData)}});parameters=@($e.Parameters|ForEach-Object {@{i=$_.InstructionIndex;t=$_.TargetStartByte;s=$_.SourceStartByte;n=$_.ByteCount;u=$_.UnkID}})}|ConvertTo-Json -Depth 15 -Compress}
$evdiff=@()
foreach($f in Get-ChildItem -LiteralPath (Join-Path $hc 'event') -File){$old=Join-Path $noob ('event\'+$f.Name);if((Sha $old) -eq (Sha $f.FullName)){continue};$a=Read-Source $old;$b=Read-Source $f.FullName;$am=@{};foreach($e in $a.Events){$am[$e.ID]=$e};$changes=@();foreach($e in $b.Events){$n=$am[$e.ID];if($null -eq $n -or (EventSig $n) -cne (EventSig $e)){$changes+=@{id=$e.ID;added=($null -eq $n)}}};$evdiff+=@{file=$f.Name;changed=$changes;noobEvents=$a.Events.Count;hardcoreEvents=$b.Events.Count}}
Json-Write $evdiff (Join-Path $taskRoot 'reports\HARDCORE_VS_NOOB_EVENTS.json')
$pa=[SoulsFormats.BND4]::Read((Raw (Join-Path $noob 'param\gameparam\gameparam.parambnd.dcx')));$pb=[SoulsFormats.BND4]::Read((Raw (Join-Path $hc 'param\gameparam\gameparam.parambnd.dcx')))
$tables=@();foreach($f in $pb.Files){$a=Member $pa ([IO.Path]::GetFileName($f.Name));if([Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($f.Bytes.ToArray())) -cne [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($a.Bytes.ToArray()))){$tables+=[IO.Path]::GetFileName($f.Name)}}
Json-Write $tables (Join-Path $taskRoot 'reports\HARDCORE_VS_NOOB_PARAM_TABLES.json')
# Original clean maps: determine semantic differences by list ordinal and named references, excluding serialized indices.
$opts=[System.Text.Json.JsonSerializerOptions]::new();$opts.IncludeFields=$true
function Canon($v){$s=[System.Text.Json.JsonSerializer]::Serialize($v,$v.GetType(),$opts);[regex]::Replace($s,'("[^"\\]*(?:Index|Indices)[0-9]*":)(?:-?\d+|\[[^\]]*\])','$1"<recomputed-index>"')}
$rel='map\mapstudio\m10_00_00_00.msb.dcx';$a=[SoulsFormats.MSBS]::Read((Raw (Join-Path $noob $rel)));$b=[SoulsFormats.MSBS]::Read((Raw (Join-Path $hc $rel)))
$mapdiff=@();foreach($sec in @('Models','Events','Regions','Parts','Routes')){
 foreach($prop in $b.$sec.PSObject.Properties){
  if($prop.Value -isnot [Collections.IList]){continue};$sub=$prop.Name;$al=$a.$sec.$sub;$bl=$b.$sec.$sub
  if($al.Count -ne $bl.Count){$mapdiff+=@{section=$sec;list=$sub;noobCount=$al.Count;hardcoreCount=$bl.Count};continue}
  for($n=0;$n -lt $bl.Count;$n++){if((Canon $al[$n]) -cne (Canon $bl[$n])){$mapdiff+=@{section=$sec;list=$sub;index=$n;noobName=$al[$n].Name;hardcoreName=$bl[$n].Name}}}
 }
}
Json-Write $mapdiff (Join-Path $taskRoot 'reports\HARDCORE_VS_NOOB_MAP.json')
'AUDIT_HARDCORE_DONE'
