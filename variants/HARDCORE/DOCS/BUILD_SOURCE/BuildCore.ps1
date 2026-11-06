. (Join-Path $PSScriptRoot 'Common.ps1')
. (Join-Path $PSScriptRoot 'Raw.ps1')
$taskRoot='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\HARDCORE_MAIN_PACKAGE'
$clean=Join-Path $taskRoot 'input\mods'
$baseRoot='E:\PRACA AI CAŁY FOLDER\INNER DOJO\CREATE NEW FILES\INNER_DOJO_SALA_A_B_43_BOSSOW_V20_R2_FLAGI_SERII_2026-10-22'
$mods=Join-Path $taskRoot 'build\mods'
Need (-not(Test-Path -LiteralPath $mods)) 'Build already exists'
[IO.Directory]::CreateDirectory($mods)|Out-Null
# Only Dojo-specific standalone resources. All NOOB character/SFX dependencies are already in the required original mod.
foreach($rel in @('event\m10_00_50_91.emevd.dcx','map\m10_00_00_00\m10_00_00_00.nva.dcx','map\m10_00_00_00\m10_00_00_00.nvmhktbnd.dcx','menu\02_205_bossselect.gfx','menu\hi\menu_boss_11490.tpf.dcx','script\m10_00_00_00.luabnd.dcx')){Copy-File (Join-Path $baseRoot "mods\$rel") (Join-Path $mods $rel)}
Copy-File 'E:\PRACA AI CAŁY FOLDER\INNER DOJO\CREATE NEW FILES\INNER_DOJO_V20_R4_PATCH_ONGYOKI_START_2026-10-24\mods\event\m10_00_50_91.emevd.dcx' (Join-Path $mods 'event\m10_00_50_91.emevd.dcx')
# PARAM: all original binder members retained; only 44 new Dojo rows, no item patch changes.
$rel='param\gameparam\gameparam.parambnd.dcx';$pc=[SoulsFormats.BND4]::Read((Raw (Join-Path $clean $rel)));$pb=[SoulsFormats.BND4]::Read((Raw (Join-Path $baseRoot "mods\$rel")))
$delta=Get-Content -LiteralPath (Join-Path $taskRoot 'reports\PARAM_DOJO_DELTA.json') -Raw|ConvertFrom-Json
foreach($g in $delta|Group-Object table){$t=Table $pc $g.Name $g.Name;$b=Table $pb $g.Name $g.Name;foreach($d in $g.Group){Need $d.new 'Unexpected existing-row PARAM modification';Need (@($t.Rows|Where-Object ID -eq $d.id).Count -eq 0) 'PARAM row collision';$t.Rows.Add([SoulsFormats.PARAM+Row]::new((Row $b $d.id)))};$t.Rows.Sort([Comparison[SoulsFormats.PARAM+Row]]{param($a,$b)$a.ID.CompareTo($b.ID)});(Member $pc ($g.Name+'.param')).Bytes=$t.Write()}
$out=Join-Path $mods $rel;[IO.Directory]::CreateDirectory((Split-Path $out -Parent))|Out-Null;$pc.Write($out,[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)
# World events: only the Dojo startup hook and region world guard; preserve original NOOB everything else.
$rel='event\m10_00_00_00.emevd.dcx';$ec=Read-Source (Join-Path $clean $rel);$eb=Read-E (Join-Path $baseRoot "mods\$rel")
foreach($id in @(50,11011983)){$hits=@($ec.Events|Where-Object ID -eq $id);if($hits.Count){$ec.Events.Remove($hits[0])|Out-Null};$ec.Events.Add((Clone-Event (Event $eb $id) $id))}
$ec.Write((Join-Path $mods $rel),[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)
# English/Japanese/Chinese text: apply only the Dojo FMG delta relative to the previous donor. Do not copy bomb descriptions.
$msgChanges=@()
foreach($lang in @('engus','jpnjp','zhocn','zhotw')){foreach($kind in @('item','menu')){$rel="msg\$lang\$kind.msgbnd.dcx";$cc=[SoulsFormats.BND4]::Read((Raw (Join-Path $clean $rel)));$bb=[SoulsFormats.BND4]::Read((Raw (Join-Path $baseRoot "mods\$rel")));$dd=[SoulsFormats.BND4]::Read((Raw (Join-Path $donorRoot $rel)));$count=0;foreach($file in $bb.Files){$name=[IO.Path]::GetFileName($file.Name);$df=Member $dd $name;$cf=Member $cc $name;if($name -notmatch '\.fmg$'){continue};$bf=[SoulsFormats.FMG]::Read($file.Bytes);$don=[SoulsFormats.FMG]::Read($df.Bytes);$dst=[SoulsFormats.FMG]::Read($cf.Bytes);$dm=@{};foreach($e in $don.Entries){$dm[$e.ID]=$e.Text};$changed=$false;foreach($e in $bf.Entries){if(-not $dm.ContainsKey($e.ID) -or $dm[$e.ID] -cne $e.Text){$existing=@($dst.Entries|Where-Object ID -eq $e.ID);if($existing.Count){Need ($existing.Count -eq 1) 'Duplicate FMG';$existing[0].Text=$e.Text}else{$dst.Entries.Add([SoulsFormats.FMG+Entry]::new($dst,$e.ID,$e.Text))};$msgChanges+=@{file=$rel;member=$name;id=$e.ID;text=$e.Text};$count++;$changed=$true}};if($changed){$dst.Entries.Sort([Comparison[SoulsFormats.FMG+Entry]]{param($a,$b)$a.ID.CompareTo($b.ID)});$cf.Bytes=$dst.Write()}};if($count){$out=Join-Path $mods $rel;[IO.Directory]::CreateDirectory((Split-Path $out -Parent))|Out-Null;$cc.Write($out,[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)}}}
Json-Write $msgChanges (Join-Path $taskRoot 'reports\MSG_DOJO_DELTA.json')
'CORE_BUILD_DONE'
