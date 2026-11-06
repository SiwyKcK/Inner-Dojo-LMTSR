. (Join-Path $PSScriptRoot 'Common.ps1')
$taskRoot='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\HARDCORE_MAIN_PACKAGE'
$path=Join-Path $taskRoot 'build\mods\event\m10_00_50_91.emevd.dcx'
$old=Read-E $path;$ev=Read-E $path
$patch=Get-Content -LiteralPath (Join-Path $taskRoot 'reports\HARDCORE_ARASHI_PHASE_PATCH.json') -Raw|ConvertFrom-Json
foreach($p in $patch){$e=Event $ev $p.event;$i=$e.Instructions[$p.instruction];Need ([Convert]::ToHexString($i.ArgData) -ceq $p.oldHex) 'Unexpected source instruction';$i.ArgData=[Convert]::FromHexString($p.newHex)}
$ev.Write($path,[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)
$actual=Read-E $path;$changes=@()
foreach($e in $old.Events){$a=Event $actual $e.ID;Need ($a.Instructions.Count -eq $e.Instructions.Count -and $a.RestBehavior -eq $e.RestBehavior -and $a.Parameters.Count -eq $e.Parameters.Count) 'EMEVD structure drift';for($n=0;$n -lt $e.Instructions.Count;$n++){$x=$e.Instructions[$n];$y=$a.Instructions[$n];if($x.Bank -ne $y.Bank -or $x.ID -ne $y.ID -or $x.Layer -ne $y.Layer -or [Convert]::ToHexString($x.ArgData) -cne [Convert]::ToHexString($y.ArgData)){$changes+=@{event=$e.ID;index=$n;before=[Convert]::ToHexString($x.ArgData);after=[Convert]::ToHexString($y.ArgData)}}}}
Need ($changes.Count -eq 2) 'Expected two phase changes'
foreach($c in $changes){Need ($c.event -in @(11012202,11012203) -and $c.index -eq 4) 'Unexpected changed instruction'}
Json-Write @{status='SAVED_AND_READ_BACK';runtime='NOT_TESTED_ON_CLEAN_HARDCORE';changedInstructions=$changes;unchangedEvents=1570;outputSHA256=Sha $path} (Join-Path $taskRoot 'reports\HARDCORE_DOJO_READBACK.json')
'DOJO_HARDCORE_PHASES_SAVED'
