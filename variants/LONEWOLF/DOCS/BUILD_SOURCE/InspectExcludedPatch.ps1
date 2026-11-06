. (Join-Path $PSScriptRoot 'Common.ps1')
. (Join-Path $PSScriptRoot 'Raw.ps1')
$taskRoot='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\NOOB_LONEWOLF_DOJO_PACKAGE';$clean='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\CLEAN_NOOB_MAIN_PACKAGE\input\mods';$old=Join-Path $taskRoot 'input\old-patch\mods'
$rel='param\gameparam\gameparam.parambnd.dcx';$n=[SoulsFormats.BND4]::Read((Raw (Join-Path $clean $rel)));$o=[SoulsFormats.BND4]::Read((Raw (Join-Path $old $rel)))
$byType=@{};foreach($df in Get-ChildItem -LiteralPath $defs -Filter '*.xml'){$xml=[xml](Get-Content -LiteralPath $df.FullName -Raw);$byType[[string]$xml.PARAMDEF.ParamType]=$df.BaseName}
$tables=@();$edits=@()
function FH($f){[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($f.Bytes.ToArray()))}
foreach($f in $o.Files){$file=[IO.Path]::GetFileName($f.Name);if((FH $f) -ceq (FH (Member $n $file))){continue};$table=$file -replace '\.param$','';$ot=[SoulsFormats.PARAM]::Read($f.Bytes);$def=$byType[[string]$ot.ParamType];$ot.ApplyParamdef([SoulsFormats.PARAMDEF]::XmlDeserialize((Join-Path $defs ($def+'.xml')),$false));$nt=Table $n $table $def;$nm=@{};foreach($r in $nt.Rows){$nm[$r.ID]=$r};foreach($r in $ot.Rows){$nr=$nm[$r.ID];if($null -eq $nr){$edits+=@{table=$table;id=$r.ID;new=$true};continue};if((Sig $nr) -ceq (Sig $r)){continue};$cells=@();foreach($c in $r.Cells){$oldVal=(Cell $nr $c.Def.InternalName).Value;if([string]$oldVal -cne [string]$c.Value){$cells+=@{field=$c.Def.InternalName;clean=$oldVal;patch=$c.Value}}};$edits+=@{table=$table;id=$r.ID;new=$false;cells=$cells}};$tables+=$table}
Json-Write @{tables=$tables;edits=$edits} (Join-Path $taskRoot 'reports\EXCLUDED_OLD_PATCH_DELTA.json')
'OLD_PATCH_IDENTIFIED'
