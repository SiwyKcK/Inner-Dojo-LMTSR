. (Join-Path $PSScriptRoot 'Common.ps1')
. (Join-Path $PSScriptRoot 'Raw.ps1')
$taskRoot='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\NOOB_LONEWOLF_DOJO_PACKAGE';$sources='E:\PRACA AI CAŁY FOLDER\SEKIRO\VANILLA_WORKFILES_BASE'
$hc='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\HARDCORE_MAIN_PACKAGE\input\mods';$lw=Join-Path $sources 'LMTSR_Lone_Wolf_Master_Hardcore_V1.0';$noob='E:\PRACA AI CAŁY FOLDER\INNER DOJO\CREATE NEW FILES\INNER DOJO\mods';$merged=Join-Path $sources 'LMTSR_NOOB_PATCH_01_60S_PLUS_LONE_WOLF_MASTER_NOOB_V.1'
$rel='param\gameparam\gameparam.parambnd.dcx';$h=[SoulsFormats.BND4]::Read((Raw (Join-Path $hc $rel)));$l=[SoulsFormats.BND4]::Read((Raw (Join-Path $lw $rel)));$n=[SoulsFormats.BND4]::Read((Raw (Join-Path $noob $rel)));$m=[SoulsFormats.BND4]::Read((Raw (Join-Path $merged $rel)))
function BH($f){[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($f.Bytes.ToArray()))}
$defByType=@{};foreach($defFile in Get-ChildItem -LiteralPath $defs -Filter '*.xml'){$xml=[xml](Get-Content -LiteralPath $defFile.FullName -Raw);$defByType[[string]$xml.PARAMDEF.ParamType]=$defFile.BaseName}
function Def($name){$temp=[SoulsFormats.PARAM]::Read((Member $h ($name+'.param')).Bytes);$type=[string]$temp.ParamType;Need ($defByType.ContainsKey($type)) "Missing schema for $name type=$type";$defByType[$type]}

$tables=@();foreach($f in $l.Files){$name=[IO.Path]::GetFileName($f.Name);if((BH $f) -cne (BH (Member $h $name))){$tables+=($name -replace '\.param$','')}}
Json-Write @{tables=$tables} (Join-Path $taskRoot 'reports\AUTHOR_CHANGED_TABLES.json')
function RowMap($table){$seen=@{};$map=@{};$keys=@();foreach($r in $table.Rows){$id=[string]$r.ID;$count=$seen[$id];if($null -eq $count){$count=0};$seen[$id]=$count+1;$key=$id+'#'+$count;$map[$key]=$r;$keys+=$key};@{map=$map;keys=$keys}}
$changes=@();$conflicts=@();$deletions=@()
foreach($table in $tables){
 $def=Def $table;$ht=Table $h $table $def;$lt=Table $l $table $def;$nt=Table $n $table $def;$mt=Table $m $table $def
 $hm=RowMap $ht;$nm=RowMap $nt;$mm=RowMap $mt;$lm=RowMap $lt
 foreach($key in $lm.keys){
  $r=$lm.map[$key];$hr=$hm.map[$key];$occurrence=[int]($key.Split('#')[1])
  if($null -eq $hr){$collision=$nm.map.ContainsKey($key);$equal=($collision -and (Sig $nm.map[$key]) -ceq (Sig $r));$change=@{table=$table;id=$r.ID;occurrence=$occurrence;key=$key;new=$true;cleanCollision=$collision;equalExisting=$equal};$changes+=$change;if($collision -and -not $equal){$conflicts+=$change};continue}
  if((Sig $hr) -ceq (Sig $r)){continue}
  $nr=$nm.map[$key];Need ($null -ne $nr) "Source row absent in NOOB $table/$key";$mr=$mm.map[$key];$cells=@()
  foreach($cell in $r.Cells){$field=$cell.Def.InternalName;$hcVal=(Cell $hr $field).Value;$lwVal=$cell.Value;if([string]$hcVal -ceq [string]$lwVal){continue};$noobVal=(Cell $nr $field).Value;$oldVal=if($null -ne $mr){(Cell $mr $field).Value}else{$null};$conflict=([string]$noobVal -cne [string]$hcVal -and [string]$noobVal -cne [string]$lwVal);$c=@{field=$field;hardcore=$hcVal;loneWolf=$lwVal;noob=$noobVal;previousMerge=$oldVal;conflict=$conflict};$cells+=$c;if($conflict){$conflicts+=@{table=$table;id=$r.ID;key=$key;cell=$c}}}
  $changes+=@{table=$table;id=$r.ID;occurrence=$occurrence;key=$key;new=$false;cells=$cells}
 }
 foreach($key in $hm.keys){if(-not $lm.map.ContainsKey($key)){$deletions+=@{table=$table;key=$key;id=$hm.map[$key].ID}}}
}

Json-Write @{tables=$tables;changes=$changes;deletions=$deletions} (Join-Path $taskRoot 'reports\AUTHOR_LONEWOLF_DELTA.json')
Json-Write @{conflicts=$conflicts} (Join-Path $taskRoot 'reports\AUTHOR_NOOB_CONFLICTS.json')
'AUTHOR_DELTA_ANALYZED'
