#!/bin/bash
# Builds all .catz files and publishes a new GitHub release.
# Run this after committing changes to .cat files.

set -e

SRC="/home/markus/Downloads/Spiele/Warhammer/WHFB/6te/Verstärkung für die 6te Edition/Warhammer Fantasy Battle 6th edition with Reinforcements"
NAME="Warhammer Fantasy Battle 6th edition with Reinforcements"
OUTDIR="/tmp/bs-release"
BSI_NAME="warhammer-fantasy-6th-reinforcements.latest"
BASE_URL="https://github.com/Kerrrunchhh/warhammer-fantasy-6th-reinforcements/releases/latest/download/"

rm -rf "$OUTDIR" && mkdir -p "$OUTDIR"

echo "Building GST..."
zip -j "$OUTDIR/$NAME.gstz" "$SRC/$NAME.gst" -q

cp "$SRC/index.xml" "$OUTDIR/"

echo "Building catalogues..."
declare -A MAP=(
    ["Bretonnia"]="Bretonnia"
    ["Chaos"]="Chaos"
    ["Dark Elves"]="Dark.Elves"
    ["Dark Elves Raiders of Naggaroth"]="Dark.Elves.Raiders.of.Naggaroth"
    ["Dogs of War"]="Dogs.of.War"
    ["Dwarfs"]="Dwarfs"
    ["Dwarfs Guild Expedition"]="Dwarfs.Guild.Expedition"
    ["Dwarfs Overground Defence"]="Dwarfs.Overground.Defence"
    ["Dwarfs Royal Clan"]="Dwarfs.Royal.Clan"
    ["Dwarfs Throng of Karak Kadrin"]="Dwarfs.Throng.of.Karak.Kadrin"
    ["Dwarfs Undgrin Ankor Force"]="Dwarfs.Undgrin.Ankor.Force"
    ["Dwarfs War of Vengeance"]="Dwarfs.War.of.Vengeance"
    ["Empire"]="Empire"
    ["Empire Crusader Army"]="Empire.Crusader.Army"
    ["Empire Cult of Ulric"]="Empire.Cult.of.Ulric"
    ["Empire Marienburg Mercenary Army"]="Empire.Marienburg.Mercenary.Army"
    ["Empire Sigmarite Army"]="Empire.Sigmarite.Army"
    ["Empire The Artillery Train of Nuln"]="Empire.The.Artillery.Train.of.Nuln"
    ["Empire The Emperor's Guard"]="Empire.The.Emperors.Guard"
    ["High Elf"]="High.Elf"
    ["Lizardmen"]="Lizardmen"
    ["Lizardmen of the Southlands"]="Lizardmen.of.the.Southlands"
    ["Ogre Kingdoms"]="Ogre.Kingdoms"
    ["Orcs and Goblins"]="Orcs.and.Goblins"
    ["Orcs and Goblins Common Goblin Horde"]="Orcs.and.Goblins.Common.Goblin.Horde"
    ["Orcs and Goblins Mountain or Troll Country Waaagh!"]="Orcs.and.Goblins.Mountain.or.Troll.Country.Waaagh"
    ["Orcs and Goblins Night Goblin Horde"]="Orcs.and.Goblins.Night.Goblin.Horde"
    ["Orcs and Goblins Savage Orc Horde"]="Orcs.and.Goblins.Savage.Orc.Horde"
    ["Orcs and Goblins Snotling Horde"]="Orcs.and.Goblins.Snotling.Horde"
    ["Skaven"]="Skaven"
    ["Skaven Clan Eshin"]="Skaven.Clan.Eshin"
    ["Skaven Clan Moulder"]="Skaven.Clan.Moulder"
    ["Skaven Clan Pestilens"]="Skaven.Clan.Pestilens"
    ["Skaven Clan Skryre"]="Skaven.Clan.Skryre"
    ["Tomb Kings"]="Tomb.Kings"
    ["Vampire Counts"]="Vampire.Counts"
    ["Vampire Counts von Carstein"]="Vampire.Counts.von.Carstein"
    ["Vampire Counts Necrarchs"]="Vampire.Counts.Necrarchs"
    ["Vampire Counts Necromancer's Army"]="Vampire.Counts.Necromancers.Army"
    ["Vampire Counts Lahmians"]="Vampire.Counts.Lahmians"
    ["Vampire Counts Blood Dragons"]="Vampire.Counts.Blood.Dragons"
    ["Vampire Counts Strigoi"]="Vampire.Counts.Strigoi"
    ["Wood Elf"]="Wood.Elf"
)

for catname in "${!MAP[@]}"; do
    dotname="${MAP[$catname]}"
    zip -j "$OUTDIR/$dotname.catz" "$SRC/$catname.cat" -q || echo "WARNING: missing $catname.cat"
done

echo "Building .bsi index..."
python3 - << PYEOF
import xml.etree.ElementTree as ET, zipfile, io
NS = "http://www.battlescribe.net/schema/dataIndexSchema"
ET.register_namespace('', NS)
SRC = "/home/markus/Downloads/Spiele/Warhammer/WHFB/6te/Verstärkung für die 6te Edition/Warhammer Fantasy Battle 6th edition with Reinforcements"
BASE_URL = "$BASE_URL"
BSI_NAME = "$BSI_NAME"
tree = ET.parse(f"{SRC}/index.xml")
root = tree.getroot()
def tag(t): return f"{{{NS}}}{t}"
for entry in root.iter(tag("dataIndexEntry")):
    fp = entry.get("filePath", "")
    entry.set("filePath", BASE_URL + fp)
ET.indent(tree, space="  ")
buf = io.BytesIO()
tree.write(buf, encoding="utf-8", xml_declaration=True)
with zipfile.ZipFile(f"/tmp/bs-release/{BSI_NAME}.bsi", "w", zipfile.ZIP_DEFLATED) as zf:
    zf.writestr(f"{BSI_NAME}.xml", buf.getvalue())
print(f"  Written {BSI_NAME}.bsi")
PYEOF

cp "$SRC/install.sh"  "$OUTDIR/"
cp "$SRC/install.ps1" "$OUTDIR/"

echo "Publishing GitHub release..."
cd "$SRC"
gh release delete latest --yes 2>/dev/null || true
gh release create latest /tmp/bs-release/* --title "Latest" --notes "Auto-built release"

echo ""
echo "Release published."
