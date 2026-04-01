#!/bin/bash
# BattleScribe Installer: Warhammer Fantasy Battle 6th edition with Reinforcements

DEST="$HOME/BattleScribe/data/Warhammer Fantasy Battle 6th edition with Reinforcements"

mkdir -p "$DEST"
echo "Installiere nach: $DEST"

gh release download latest \
  --repo Kerrrunchhh/warhammer-fantasy-6th-reinforcements \
  --dir "$DEST" \
  --clobber

echo ""
echo "Fertig! Bitte BattleScribe neu starten."
