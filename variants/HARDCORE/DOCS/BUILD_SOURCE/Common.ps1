$ErrorActionPreference='Stop'
$project='E:\PRACA AI CAŁY FOLDER\INNER DOJO'
$defs='E:\PRACA AI CAŁY FOLDER\TOOLS\SEKIRO PROGRAMS\WitchyBND\Assets\Paramdex\SDT\Defs'
Add-Type -Path 'E:\PRACA AI CAŁY FOLDER\SEKIRO\Working\2026-09-22\INNER_DOJO_RESURRECTION_TO_LMTSR_NOOB\tools\bin\Release\net10.0\Andre.SoulsFormats.dll'
[Runtime.InteropServices.NativeLibrary]::Load('E:\PRACA AI CAŁY FOLDER\TOOLS\SEKIRO PROGRAMS\WitchyBND\oo2core_6_win64.dll')|Out-Null
[SoulsFormats.Oodle].GetField('Oodle6Exists',[Reflection.BindingFlags]'NonPublic,Static').SetValue($null,$true)
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
$schema=Get-Content -LiteralPath 'E:\PRACA AI CAŁY FOLDER\TOOLS\SEKIRO PROGRAMS\DarkScript3\app\Resources\sekiro-common.emedf.json' -Raw|ConvertFrom-Json
$ops=@{};foreach($cls in @($schema.main_classes)+@($schema.extra_classes)){foreach($op in $cls.instrs){$ops["$($cls.index):$($op.index)"]=$op}}
function Decode($i){
    $op=$ops["$($i.Bank):$($i.ID)"];Need ($null -ne $op) "Unknown opcode $($i.Bank)/$($i.ID)"
    $off=0;$args=@();foreach($a in $op.args){
        $size=switch([int]$a.type){0{1}1{2}2{4}3{1}4{2}5{4}6{4}8{4}default{throw "Unknown arg type $($a.type)"}}
        if($off % $size){$off += $size-($off % $size)}
        if($off+$size -gt $i.ArgData.Length){break}
        $v=switch([int]$a.type){0{[int]$i.ArgData[$off]}1{[BitConverter]::ToUInt16($i.ArgData,$off)}2{[BitConverter]::ToUInt32($i.ArgData,$off)}3{if($i.ArgData[$off] -gt 127){[int]$i.ArgData[$off]-256}else{[int]$i.ArgData[$off]}}4{[BitConverter]::ToInt16($i.ArgData,$off)}5{[BitConverter]::ToInt32($i.ArgData,$off)}6{[BitConverter]::ToSingle($i.ArgData,$off)}8{[BitConverter]::ToInt32($i.ArgData,$off)}}
        $args += [pscustomobject]@{name=$a.name;type=$a.type;offset=$off;value=$v};$off+=$size
    }
    [pscustomobject]@{bank=$i.Bank;opcode=$i.ID;name=$op.name;args=$args;hex=[Convert]::ToHexString($i.ArgData)}
}
function Dump-Events($ev,[long[]]$ids,[string]$path){
    $lines=[Collections.Generic.List[string]]::new()
    foreach($id in $ids){$e=Event $ev $id;$lines.Add("EVENT $id rest=$($e.RestBehavior) instructions=$($e.Instructions.Count) parameters=$($e.Parameters.Count)");for($j=0;$j -lt $e.Instructions.Count;$j++){$i=$e.Instructions[$j];$d=Decode $i;$lines.Add(('{0:000} {1}[{2}] {3}: {4} HEX={5}' -f $j,$i.Bank,$i.ID,$d.name,(($d.args|ForEach-Object {"$($_.name)=$($_.value)"}) -join '; '),$d.hex))};$lines.Add('')}
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($path))|Out-Null;$lines|Set-Content -LiteralPath $path -Encoding UTF8
}























$taskRoot='E:\PRACA AI CAŁY FOLDER\INNER DOJO\Working\2026-10-24\V20_R4_ONGYOKI_BACKREAD'
$donorRoot='E:\PRACA AI CAŁY FOLDER\INNER DOJO\MATERIALS\LMTSR_NOOB_PATCH_01_60S_PLUS_LONE_WOLF_MASTER_NOOB_V.1_NIGHTJAR_BOMB_NOGRASS_FINAL_BATTLE'
$baseRoot='E:\PRACA AI CAŁY FOLDER\INNER DOJO\CREATE NEW FILES\INNER_DOJO_V20_R3_PATCH_KROPKI_KOLEJNOSC_2026-10-23'
function Read-Source([string]$path){try{Read-E $path}catch{if([Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes($path),40,4) -ne 'DFLT'){throw};Read-SourceE $path}}
function Cells($r){$v=[ordered]@{};foreach($c in $r.Cells){$v[$c.Def.InternalName]=$c.Value};$v}
function Vec($v){@([double]$v.X,[double]$v.Y,[double]$v.Z)}


