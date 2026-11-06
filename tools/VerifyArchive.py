"""Read-only ZIP/member audit. Standard Python 3 only; no game access."""
import argparse, hashlib, json, zipfile
from pathlib import Path, PurePosixPath

parser=argparse.ArgumentParser()
parser.add_argument('archive',type=Path)
parser.add_argument('--variant',required=True,choices=('NOOB','HARDCORE','LONEWOLF'))
args=parser.parse_args()
repo=Path(__file__).resolve().parent.parent
expected=json.loads((repo/'RELEASE_ARCHIVE_AUDIT.json').read_text(encoding='utf-8'))
names={'NOOB':'Inner_Dojo_for_LMTSR_NOOB_20.43.zip','HARDCORE':'Inner_Dojo_for_LMTSR_Hardcore_20.43.zip','LONEWOLF':'Inner_Dojo_for_LMTSR_NOOB_20.43_Lone_Wolf_Compatibility.zip'}
row=next(a for a in expected['archives'] if a['archive']==names[args.variant])
actual=hashlib.sha256(args.archive.read_bytes()).hexdigest().upper()
if actual!=row['sha256']:raise SystemExit('Archive SHA-256 differs from the reviewed release')
index={f['path']:f for f in row['files']}
count=0
with zipfile.ZipFile(args.archive) as z:
 if z.testzip() is not None:raise SystemExit('ZIP CRC failure')
 for info in z.infolist():
  if info.is_dir():continue
  path=PurePosixPath(info.filename)
  if path.is_absolute() or '..' in path.parts:raise SystemExit('Unsafe archive path')
  entry=index.get(info.filename)
  if entry is None:raise SystemExit('Unexpected member: '+info.filename)
  if hashlib.sha256(z.read(info)).hexdigest().upper()!=entry['sha256']:raise SystemExit('Member mismatch: '+info.filename)
  count+=1
if count!=len(index):raise SystemExit('Member count mismatch')
print(json.dumps({'status':'PASS','sha256':actual,'members':count,'scope':'ZIP and member identity; not malware clearance'},indent=2))
