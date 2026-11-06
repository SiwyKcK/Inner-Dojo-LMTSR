param([Parameter(Mandatory=$true)][string]$SoulsFormatsAssembly,[Parameter(Mandatory=$true)][string]$OutputFile,[string]$OodleLibrary,[string]$IRFile=(Join-Path $PSScriptRoot '..\BUILD_EVENT_IR.json'),[string]$TemplateFile=(Join-Path $PSScriptRoot '..\..\mods\event\m10_00_50_91.emevd.dcx'))
$ErrorActionPreference='Stop'
if(Test-Path -LiteralPath $OutputFile){throw 'Choose a new output path; do not overwrite an installation.'}
Add-Type -Path $SoulsFormatsAssembly
if($OodleLibrary){[Runtime.InteropServices.NativeLibrary]::Load($OodleLibrary)|Out-Null;$field=[SoulsFormats.Oodle].GetField('Oodle6Exists',[Reflection.BindingFlags]'NonPublic,Static');if($field){$field.SetValue($null,$true)}}
$ir=Get-Content -LiteralPath $IRFile -Raw|ConvertFrom-Json
$ev=[SoulsFormats.EMEVD]::Read($TemplateFile);$restType=$ev.Events[0].RestBehavior.GetType();$ev.Events.Clear()
foreach($item in $ir.dojo){$e=[SoulsFormats.EMEVD+Event]::new([long]$item.id);$e.RestBehavior=[Enum]::Parse($restType,[string]$item.rest);foreach($i in $item.instructions){$inst=[SoulsFormats.EMEVD+Instruction]::new([int]$i.b,[int]$i.o,[Convert]::FromHexString($i.h));if($null -ne $i.l){$inst.Layer=[uint32]$i.l};$e.Instructions.Add($inst)};foreach($p in $item.parameters){$param=[SoulsFormats.EMEVD+Parameter]::new();$param.InstructionIndex=$p.i;$param.TargetStartByte=$p.t;$param.SourceStartByte=$p.s;$param.ByteCount=$p.n;$param.UnkID=$p.u;$e.Parameters.Add($param)};$ev.Events.Add($e)}
$parent=[IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($OutputFile));[IO.Directory]::CreateDirectory($parent)|Out-Null
$ev.Write($OutputFile,[SoulsFormats.DCX+Type]::DCX_DFLT_10000_44_9)
$check=[SoulsFormats.EMEVD]::Read($OutputFile);if($check.Events.Count -ne $ir.dojo.Count){throw 'Event count mismatch'}
Get-FileHash -LiteralPath $OutputFile -Algorithm SHA256
