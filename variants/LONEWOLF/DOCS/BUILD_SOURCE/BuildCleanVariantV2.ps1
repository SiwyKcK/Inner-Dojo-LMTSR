. (Join-Path $PSScriptRoot 'Common.ps1')
. (Join-Path $PSScriptRoot 'Raw.ps1')
$taskRoot='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\NOOB_LONEWOLF_DOJO_PACKAGE'
$noob='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\CLEAN_NOOB_MAIN_PACKAGE\input\mods'
$hc='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\HARDCORE_MAIN_PACKAGE\input\mods'
$lw='E:\PRACA AI CAŁY FOLDER\SEKIRO\VANILLA_WORKFILES_BASE\LMTSR_Lone_Wolf_Master_Hardcore_V1.0'
$dojo='E:\PRACA AI CAŁY FOLDER\INNER DOJO\CREATE NEW FILES\INNER DOJO'
$mods=Join-Path $taskRoot 'build_v2\mods';Need (-not(Test-Path -LiteralPath $mods)) 'Build already exists'
[IO.Directory]::CreateDirectory((Split-Path $mods -Parent))|Out-Null;Copy-Item -LiteralPath (Join-Path $dojo 'mods') -Destination $mods -Recurse
$plan=Get-Content -LiteralPath (Join-Path $taskRoot 'reports\AUTHOR_LONEWOLF_DELTA.json') -Raw|ConvertFrom-Json
Need ($plan.deletions.Count -eq 0) 'Source row deletions need review'
$rel='param\gameparam\gameparam.parambnd.dcx';$n=[SoulsFormats.BND4]::Read((Raw (Join-Path $mods $rel)));$l=[SoulsFormats.BND4]::Read((Raw (Join-Path $lw $rel)))
$defByType=@{};foreach($df in Get-ChildItem -LiteralPath $defs -Filter '*.xml'){$xml=[xml](Get-Content -LiteralPath $df.FullName -Raw);$defByType[[string]$xml.PARAMDEF.ParamType]=$df.BaseName}
function RowMap($table){$seen=@{};$map=@{};foreach($r in $table.Rows){$id=[string]$r.ID;$count=$seen[$id];if($null -eq $count){$count=0};$seen[$id]=$count+1;$map[$id+'#'+$count]=$r};return $map}
$cellCount=0;$newCount=0
foreach($g in $plan.changes|Group-Object table){
 $table=$g.Name;$temp=[SoulsFormats.PARAM]::Read((Member $l ($table+'.param')).Bytes);$def=$defByType[[string]$temp.ParamType];$nt=Table $n $table $def;$lt=Table $l $table $def;$nm=RowMap $nt;$lm=RowMap $lt
 foreach($entry in $g.Group){$key=$entry.key;if($entry.new){if($nm.ContainsKey($key)){Need ((Sig $nm[$key]) -ceq (Sig $lm[$key])) 'New row collision'}else{$nt.Rows.Add([SoulsFormats.PARAM+Row]::new($lm[$key]));$newCount++}}else{$row=$nm[$key];foreach($c in $entry.cells){Need (-not $c.conflict) 'Unresolved field conflict';$target=Cell $row $c.field;$source=Cell $lm[$key] $c.field;$target.Value=$source.Value;$cellCount++}}}
 # Sort stably: legacy duplicate-ID rows keep their relative order.
 $sorted=@($nt.Rows|Sort-Object -Property ID -Stable);$nt.Rows.Clear();foreach($row in $sorted){$nt.Rows.Add($row)};(Member $n ($table+'.param')).Bytes=$nt.Write()
}

$n.Write((Join-Path $mods $rel),[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)
# Merge author's English FMG row delta into NOOB+Dojo. Text IDs are scoped to their FMG member, not globally.
$msgChanges=@()
foreach($rel in @('msg\engus\item.msgbnd.dcx','msg\engus\menu.msgbnd.dcx')){
 $h=[SoulsFormats.BND4]::Read((Raw (Join-Path $hc $rel)));$l=[SoulsFormats.BND4]::Read((Raw (Join-Path $lw $rel)));$n=[SoulsFormats.BND4]::Read((Raw (Join-Path $mods $rel)))
 foreach($f in $l.Files){$name=[IO.Path]::GetFileName($f.Name);if($name -notmatch '\.fmg$'){continue};$hf=Member $h $name;$nf=Member $n $name;$hs=[SoulsFormats.FMG]::Read($hf.Bytes);$ls=[SoulsFormats.FMG]::Read($f.Bytes);$ns=[SoulsFormats.FMG]::Read($nf.Bytes);$hm=@{};foreach($e in $hs.Entries){$hm[$e.ID]=$e.Text};$nm=@{};foreach($e in $ns.Entries){$nm[$e.ID]=$e};$changed=$false
 foreach($e in $ls.Entries){if($hm.ContainsKey($e.ID) -and [string]$hm[$e.ID] -ceq [string]$e.Text){continue};if($nm.ContainsKey($e.ID)){Need ([string]$nm[$e.ID].Text -ceq [string]$hm[$e.ID] -or [string]$nm[$e.ID].Text -ceq [string]$e.Text) "FMG conflict $name/$($e.ID)";$nm[$e.ID].Text=$e.Text}else{$ns.Entries.Add([SoulsFormats.FMG+Entry]::new($ns,$e.ID,$e.Text))};$msgChanges+=@{file=$rel;member=$name;id=$e.ID;text=$e.Text};$changed=$true}
 if($changed){$ns.Entries.Sort([Comparison[SoulsFormats.FMG+Entry]]{param($a,$b)$a.ID.CompareTo($b.ID)});$nf.Bytes=$ns.Write()}
 };$n.Write((Join-Path $mods $rel),[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)
}
# SFX: preserve original duplicate occurrences; replace every occurrence of an authored override name consistently.
$rel='sfx\sfxbnd_commoneffects.ffxbnd.dcx';$n=[SoulsFormats.BND4]::Read((Raw (Join-Path $noob $rel)));$l=[SoulsFormats.BND4]::Read((Raw (Join-Path $lw $rel)));$h=[SoulsFormats.BND4]::Read((Raw (Join-Path $hc $rel)))
function Groups($binder){$map=@{};foreach($f in $binder.Files){$key=[IO.Path]::GetFileName($f.Name);if(-not $map.ContainsKey($key)){$map[$key]=[Collections.Generic.List[object]]::new()};$map[$key].Add($f)};return $map}
function FH($f){[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($f.Bytes.ToArray()))}
$hm=Groups $h;$nm=Groups $n;$nextID=($n.Files|Measure-Object ID -Maximum).Maximum+1;$sfxChanges=@();$physicalReplacements=0
foreach($f in $l.Files){$key=[IO.Path]::GetFileName($f.Name);$hs=$hm[$key];$ns=$nm[$key];$want=FH $f
 if($null -ne $hs){$old=FH $hs[0];foreach($item in $hs){Need ((FH $item) -ceq $old) "Ambiguous original duplicate SFX $key"};if($old -ceq $want){continue}}
 if($null -ne $ns){Need ($null -ne $hs) 'Unexpected NOOB-only SFX conflict';foreach($item in $ns){Need ((FH $item) -ceq $old -or (FH $item) -ceq $want) "SFX conflict $key";$item.Bytes=$f.Bytes;$physicalReplacements++};$sfxChanges+=@{name=$key;new=$false;occurrences=$ns.Count;sha256=$want}}
 else{$f.ID=[int]$nextID;$nextID++;$n.Files.Add($f);$sfxChanges+=@{name=$key;new=$true;occurrences=1;sha256=$want}}
}
$out=Join-Path $mods $rel;[IO.Directory]::CreateDirectory((Split-Path $out -Parent))|Out-Null;$n.Write($out,[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)

# Leave unmodified author HKS/CHR in the required LoneWolf download; deliver only compatibility changes + complete Dojo overlay.
Json-Write @{status='BUILD_SAVED';paramNewRows=$newCount;paramEditedCells=$cellCount;paramChangedRows=$plan.changes.Count;msgChanges=$msgChanges;sfxChanges=$sfxChanges;sfxPhysicalReplacements=$physicalReplacements;requiredAuthorFiles='Original LoneWolf Hardcore1.0 + Lady Butterfly1.0 + FixHitbox1 already installed before this overlay';gameWritten=$false;runtime='NOT_TESTED_IN_GAME'} (Join-Path $taskRoot 'reports\BUILD_REPORT.json')
'CLEAN_LONEWOLF_DOJO_BUILT'
