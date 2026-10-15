#!/bin/bash
# Builds all .catz/.gstz files and updates the "latest" GitHub release in place.
# Run this after committing and pushing changes to .cat/.gst files.
#
# Needs a GitHub token with write access to the repo, taken from $GITHUB_TOKEN
# or, failing that, from the credentials embedded in the origin remote URL.
# Only needs bash, curl, python3 and git (no gh CLI).

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="Kerrrunchhh/warhammer-fantasy-6th-reinforcements"
TAG="latest"
API="https://api.github.com/repos/$REPO"
UPLOAD="https://uploads.github.com/repos/$REPO"
OUTDIR="$(mktemp -d)"
trap 'rm -rf "$OUTDIR"' EXIT

TOKEN="${GITHUB_TOKEN:-}"
if [ -z "$TOKEN" ]; then
    TOKEN="$(git -C "$SRC" remote get-url origin | sed -nE 's|https://[^:/]+:([^@]+)@.*|\1|p')"
fi
[ -n "$TOKEN" ] || { echo "No token: set GITHUB_TOKEN" >&2; exit 1; }
AUTH=(-H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json")

if [ -n "$(git -C "$SRC" status --porcelain -- '*.cat' '*.gst' index.xml)" ]; then
    echo "WARNING: uncommitted changes to data files - they will be released anyway."
fi

echo "Building release files..."
python3 -I - "$SRC" "$OUTDIR" << 'PYEOF'
import sys, os, re, glob, zipfile, io
import xml.etree.ElementTree as ET
src, out = sys.argv[1], sys.argv[2]
NS = "http://www.battlescribe.net/schema/dataIndexSchema"
ET.register_namespace('', NS)
BASE = "https://github.com/Kerrrunchhh/warhammer-fantasy-6th-reinforcements/releases/latest/download/"
BSI_NAME = "warhammer-fantasy-6th-reinforcements.latest"

tree = ET.parse(os.path.join(src, "index.xml"))
entries = {e.get("dataId"): e for e in tree.getroot().iter(f"{{{NS}}}dataIndexEntry")}
files = sorted(glob.glob(os.path.join(src, "*.cat")) + glob.glob(os.path.join(src, "*.gst")))

# Each .cat/.gst is matched to its index entry by ID, so new catalogues only
# need an index.xml entry - no name mapping to maintain here.
errors, seen = [], set()
for f in files:
    head = open(f, encoding="utf-8").read(3000)
    fid = re.search(r'<(?:catalogue|gameSystem)\b[^>]*?\bid="([^"]+)"', head).group(1)
    rev = re.search(r'<(?:catalogue|gameSystem)\b[^>]*?\brevision="(\d+)"', head).group(1)
    e = entries.get(fid)
    if e is None:
        errors.append(f"{os.path.basename(f)}: id {fid} missing from index.xml")
        continue
    if e.get("dataRevision") != rev:
        errors.append(f"{os.path.basename(f)}: revision {rev}, index.xml says {e.get('dataRevision')}")
    seen.add(fid)
    with zipfile.ZipFile(os.path.join(out, e.get("filePath")), "w", zipfile.ZIP_DEFLATED) as z:
        z.write(f, os.path.basename(f))
for fid in set(entries) - seen:
    errors.append(f"index.xml entry {entries[fid].get('dataName')} has no data file")
if errors:
    sys.exit("Aborting:\n  " + "\n  ".join(errors))

with open(os.path.join(src, "index.xml"), "rb") as fi, open(os.path.join(out, "index.xml"), "wb") as fo:
    fo.write(fi.read())

for e in entries.values():
    e.set("filePath", BASE + e.get("filePath"))
ET.indent(tree, space="  ")
buf = io.BytesIO()
tree.write(buf, encoding="utf-8", xml_declaration=True)
with zipfile.ZipFile(os.path.join(out, f"{BSI_NAME}.bsi"), "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr(f"{BSI_NAME}.xml", buf.getvalue())

with zipfile.ZipFile(os.path.join(out, "warhammer-fantasy-6th-reinforcements.bsr"), "w", zipfile.ZIP_DEFLATED) as z:
    for f in files + [os.path.join(src, "index.xml")]:
        z.write(f, os.path.basename(f))
print(f"  Built {len(files)} data files")
PYEOF

REL_ID="$(curl -sf "${AUTH[@]}" "$API/releases/tags/$TAG" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["id"])')"
curl -sf "${AUTH[@]}" "$API/releases/$REL_ID/assets?per_page=100" \
    | python3 -I -c 'import json,sys; [print(a["id"], a["name"]) for a in json.load(sys.stdin)]' > "$OUTDIR/.assets"

# Data files first, index files last, so the index never announces revisions
# whose files are not uploaded yet.
echo "Uploading to release $TAG..."
cd "$OUTDIR"
for f in *.catz *.gstz index.xml warhammer-fantasy-6th-reinforcements.bsr warhammer-fantasy-6th-reinforcements.latest.bsi; do
    old_id="$(awk -v n="$f" '$2==n {print $1}' .assets)"
    if [ -n "$old_id" ]; then
        curl -sf -o /dev/null -X DELETE "${AUTH[@]}" "$API/releases/assets/$old_id"
    fi
    curl -sf -o /dev/null --retry 3 -X POST "${AUTH[@]}" -H "Content-Type: application/octet-stream" \
        --data-binary @"$f" "$UPLOAD/releases/$REL_ID/assets?name=$f" \
        || { echo "FAILED to upload $f" >&2; exit 1; }
done

# Point the tag at the released commit (must already be pushed).
HEAD_SHA="$(git -C "$SRC" rev-parse HEAD)"
if curl -sf -o /dev/null -X PATCH "${AUTH[@]}" "$API/git/refs/tags/$TAG" \
        -d "{\"sha\":\"$HEAD_SHA\",\"force\":true}"; then
    echo "  Tag $TAG -> ${HEAD_SHA:0:7}"
else
    echo "WARNING: could not move tag $TAG (is HEAD pushed?)"
fi

echo ""
echo "Release updated: https://github.com/$REPO/releases/tag/$TAG"
