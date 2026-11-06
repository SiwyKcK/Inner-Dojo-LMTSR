. (Join-Path $PSScriptRoot 'Common.ps1')
. (Join-Path $PSScriptRoot 'Raw.ps1')
$taskRoot='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\HARDCORE_MAIN_PACKAGE';$clean=Join-Path $taskRoot 'input\mods';$rel='map\mapstudio\m10_00_00_00.msb.dcx'
$c=[SoulsFormats.MSBS]::Read((Raw (Join-Path $clean $rel)));$b=[SoulsFormats.MSBS]::Read((Join-Path $taskRoot ('build\mods\'+$rel)))
$changes=Get-Content -LiteralPath (Join-Path $taskRoot 'reports\MAP_SEMANTIC_DELTA.json') -Raw|ConvertFrom-Json
$oldIds=@{};foreach($sec in @('Parts','Regions','Events')){foreach($e in $c.$sec.GetEntries()){if($e.PSObject.Properties['EntityID'] -and $e.EntityID -notin @(-1,0,4294967295)){$oldIds[[long]$e.EntityID]=@{section=$sec;name=$e.Name}}}}
$hits=@();$newIds=@{};$ord=@{};foreach($entry in $changes.changes){Need $entry.new 'Expected additions only';$sec=$entry.section;$list=$entry.list;$listKey=$sec+'/'+$list;$offset=$ord[$listKey];if($null -eq $offset){$offset=0};$ord[$listKey]=$offset+1;$lr=@($changes.lists|Where-Object {$_.section -eq $sec -and $_.list -eq $list})[0];$idx=$lr.clean+$offset;$e=$b.$sec.$list[$idx];Need ($e.Name -ceq $entry.name) 'Added entry order mismatch';if($e.PSObject.Properties['EntityID'] -and $e.EntityID -notin @(-1,0,4294967295)){$id=[long]$e.EntityID;if($oldIds.ContainsKey($id)){$hits+=@{id=$id;newName=$e.Name;existing=$oldIds[$id]}};if($newIds.ContainsKey($id)){$hits+=@{id=$id;newName=$e.Name;otherNew=$newIds[$id]}};$newIds[$id]=$e.Name}}
Json-Write $hits (Join-Path $taskRoot 'reports\ENTITY_COLLISIONS.json');Need ($hits.Count -eq 0) 'Introduced map EntityID collision'
$opts=[System.Text.Json.JsonSerializerOptions]::new();$opts.IncludeFields=$true
function Canon($v){$text=[System.Text.Json.JsonSerializer]::Serialize($v,$v.GetType(),$opts);[regex]::Replace($text,'("[^"\\]*(?:Index|Indices)[0-9]*":)(?:-?\d+|\[[^\]]*\])','$1"<recomputed-index>"')}
$preserved=0
foreach($sec in @('Models','Events','Regions','Parts','Routes')){
 foreach($prop in $c.$sec.PSObject.Properties){
  if($prop.Value -isnot [Collections.IList]){continue};$sub=$prop.Name;$cl=$c.$sec.$sub;$bl=$b.$sec.$sub
  for($n=0;$n -lt $cl.Count;$n++){Need ((Canon $cl[$n]) -ceq (Canon $bl[$n])) "Original Hardcore MSB entry changed $sec/$sub/$n";$preserved++}
 }
}

$cp=[SoulsFormats.BND4]::Read((Raw (Join-Path $clean 'param\gameparam\gameparam.parambnd.dcx')));$np=Table $cp 'NpcParam' 'NpcParam';$think=Table $cp 'NpcThinkParam' 'NpcThinkParam'
$roster=Get-Content -LiteralPath 'E:\PRACA AI CAŁY FOLDER\INNER DOJO\CREATE NEW FILES\INNER DOJO\DOCS\COMBATANT_ROSTER.json' -Raw|ConvertFrom-Json
$actorRows=@();foreach($r in $roster){$e=@($b.Parts.Enemies|Where-Object EntityID -eq $r.real);Need ($e.Count -eq 1) "Combat actor identity collision $($r.real)";$n=Row $np $e[0].NPCParamID;Row $think $e[0].ThinkParamID|Out-Null;$actorRows+=@{key=$r.key;actor=$r.real;npc=$e[0].NPCParamID;think=$e[0].ThinkParamID;healthBars=(Cell $n 'ninsatuNum').Value}}
Json-Write @{status='PASS';originalMapEntriesPreserved=$preserved;introducedEntityCollisions=$hits;newExplicitEntityIDs=$newIds.Count;combatants=$actorRows;scope='MSB explicit EntityIDs against original Hardcore and within additions; all roster NPC/Think references exist'} (Join-Path $taskRoot 'reports\ENTITY_AND_PARAM_REFERENCES.json')
'ENTITY_REFERENCES_PASS'
