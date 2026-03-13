#!/bin/bash
# BattleScribe Installer: Warhammer Fantasy Battle 6th edition with Reinforcements

BASE="https://github.com/Kerrrunchhh/warhammer-fantasy-6th-reinforcements/releases/latest/download"
DEST="$HOME/BattleScribe/data/Warhammer Fantasy Battle 6th edition with Reinforcements"

FILES=(
    "Warhammer.Fantasy.Battle.6th.edition.with.Reinforcements.gstz"
    "Bretonnia.catz" "Chaos.catz" "Dark.Elves.catz" "Dogs.of.War.catz"
    "Dwarfs.catz" "Empire.catz" "High.Elf.catz" "Lizardmen.catz"
    "Ogre.Kingdoms.catz" "Orcs.and.Goblins.catz" "RH.Chaos.Dwarfs.catz"
    "RH.Orcs.and.Goblins.catz" "Skaven.catz" "Tomb.Kings.catz"
    "Vampire.Counts.catz" "Wood.Elf.catz"
)

mkdir -p "$DEST"
echo "Installiere nach: $DEST"

for FILE in "${FILES[@]}"; do
    echo "Lade herunter: $FILE"
    curl -L -o "$DEST/$FILE" "$BASE/$FILE"
done

echo ""
echo "Fertig! Bitte BattleScribe neu starten."
