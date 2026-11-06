function Need([bool]$ok,[string]$why){if(-not $ok){throw $why}}
function Sha([string]$path){(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash}
function Copy-File([string]$from,[string]$to){[IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($to))|Out-Null;Copy-Item -LiteralPath $from -Destination $to}
function Member($b,[string]$suffix){$a=@($b.Files|Where-Object {[IO.Path]::GetFileName($_.Name) -eq $suffix});Need ($a.Count -eq 1) "Member $suffix count=$($a.Count)";$a[0]}
function Table($b,[string]$name,[string]$def){$p=[SoulsFormats.PARAM]::Read((Member $b "$name.param").Bytes);$p.ApplyParamdef([SoulsFormats.PARAMDEF]::XmlDeserialize((Join-Path $defs "$def.xml"),$false));$p}
function Row($p,[int]$id){$a=@($p.Rows|Where-Object ID -EQ $id);Need ($a.Count -eq 1) "Row $id count=$($a.Count)";$a[0]}
function Cell($r,[string]$field){$a=@($r.Cells|Where-Object {$_.Def.InternalName -eq $field});Need ($a.Count -eq 1) "Cell $field count=$($a.Count)";$a[0]}
function Sig($r){($r.Cells|ForEach-Object {if($_.Value -is [byte[]]){[Convert]::ToHexString($_.Value)}else{[string]$_.Value}}) -join '|'}
function Read-E([string]$path){[byte[]]$b=[IO.File]::ReadAllBytes($path);if([SoulsFormats.DCX]::Is($b)){$b=[SoulsFormats.DCX]::Decompress($b).ToArray()};[SoulsFormats.EMEVD]::Read($b)}
function Read-SourceE([string]$path){$b=[IO.File]::ReadAllBytes($path);$s=[IO.MemoryStream]::new($b,76,$b.Length-76);$z=[IO.Compression.ZLibStream]::new($s,[IO.Compression.CompressionMode]::Decompress);$m=[IO.MemoryStream]::new();try{$z.CopyTo($m);[SoulsFormats.EMEVD]::Read($m.ToArray())}finally{$z.Dispose();$s.Dispose();$m.Dispose()}}
function Event($ev,[long]$id){$a=@($ev.Events|Where-Object ID -EQ $id);Need ($a.Count -eq 1) "Event $id count=$($a.Count)";$a[0]}
function Arg($i,[int]$n){[BitConverter]::ToInt32($i.ArgData,$n*4)}
function Inst([int]$bank,[int]$opcode,[object[]]$values){$normalized=[object[]]::new($values.Count);for($j=0;$j -lt $values.Count;$j++){$v=$values[$j].PSObject.BaseObject;if($v -is [long]){if($v -lt [int]::MinValue -or $v -gt [int]::MaxValue){throw 'Instruction Int64 outside Int32'};$normalized[$j]=[int]$v}else{$normalized[$j]=$v}};[SoulsFormats.EMEVD+Instruction]::new($bank,$opcode,$normalized)}
function Clone-Event($src,[long]$id){Need ($src.Parameters.Count -eq 0) "Parameterized event $($src.ID)";$e=[SoulsFormats.EMEVD+Event]::new($id,$src.RestBehavior);$e.Name=$src.Name;foreach($i in $src.Instructions){$c=[SoulsFormats.EMEVD+Instruction]::new($i.Bank,$i.ID,[byte[]]$i.ArgData.Clone());$c.Layer=$i.Layer;$e.Instructions.Add($c)};$e}
function Json-Write($value,[string]$path){[IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($path))|Out-Null;$value|ConvertTo-Json -Depth 40|Set-Content -LiteralPath $path -Encoding UTF8}

function Raw([string]$path){$b=[IO.File]::ReadAllBytes($path);if([Text.Encoding]::ASCII.GetString($b,0,4) -ne 'DCX'+[char]0){return ,$b};if([Text.Encoding]::ASCII.GetString($b,40,4) -eq 'DFLT'){$st=[IO.MemoryStream]::new($b,76,$b.Length-76);$z=[IO.Compression.ZLibStream]::new($st,[IO.Compression.CompressionMode]::Decompress);$m=[IO.MemoryStream]::new();$z.CopyTo($m);$z.Dispose();$st.Dispose();return ,$m.ToArray()};return ,[SoulsFormats.DCX]::Decompress($b).ToArray()}

function Read-Source([string]$path){Read-E $path}
