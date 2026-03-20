# BattleScribe Installer: Warhammer Fantasy Battle 6th edition with Reinforcements
$repo = "Kerrrunchhh/warhammer-fantasy-6th-reinforcements"
$base = "https://github.com/$repo/releases/latest/download"
$dest = "$env:APPDATA\BattleScribe\data\Warhammer Fantasy Battle 6th edition with Reinforcements"

$files = @(
    "Warhammer.Fantasy.Battle.6th.edition.with.Reinforcements.gstz",
    "Bretonnia.catz",
    "Chaos.catz",
    "Dark.Elves.catz",
    "Dark.Elves.Raiders.of.Naggaroth.catz",
    "Dogs.of.War.catz",
    "Dwarfs.catz",
    "Dwarfs.Guild.Expedition.catz",
    "Dwarfs.Overground.Defence.catz",
    "Dwarfs.Royal.Clan.catz",
    "Dwarfs.Throng.of.Karak.Kadrin.catz",
    "Dwarfs.Undgrin.Ankor.Force.catz",
    "Dwarfs.War.of.Vengeance.catz",
    "Empire.catz",
    "Empire.Crusader.Army.catz",
    "Empire.Cult.of.Ulric.catz",
    "Empire.Marienburg.Mercenary.Army.catz",
    "Empire.Sigmarite.Army.catz",
    "Empire.The.Artillery.Train.of.Nuln.catz",
    "Empire.The.Emperors.Guard.catz",
    "High.Elf.catz",
    "Lizardmen.catz",
    "Lizardmen.of.the.Southlands.catz",
    "Ogre.Kingdoms.catz",
    "Orcs.and.Goblins.catz",
    "Orcs.and.Goblins.Common.Goblin.Horde.catz",
    "Orcs.and.Goblins.Mountain.or.Troll.Country.Waaagh.catz",
    "Orcs.and.Goblins.Night.Goblin.Horde.catz",
    "Orcs.and.Goblins.Savage.Orc.Horde.catz",
    "Orcs.and.Goblins.Snotling.Horde.catz",
    "Skaven.catz",
    "Skaven.Clan.Eshin.catz",
    "Skaven.Clan.Moulder.catz",
    "Skaven.Clan.Pestilens.catz",
    "Skaven.Clan.Skryre.catz",
    "Tomb.Kings.catz",
    "Vampire.Counts.catz",
    "Vampire.Counts.von.Carstein.catz",
    "Wood.Elf.catz"
)

New-Item -ItemType Directory -Force -Path $dest | Out-Null
Write-Host "Installiere nach: $dest"

foreach ($file in $files) {
    $url = "$base/$file"
    $out = Join-Path $dest $file
    Write-Host "Lade herunter: $file"
    Invoke-WebRequest -Uri $url -OutFile $out
}

Write-Host ""
Write-Host "Fertig! Bitte BattleScribe neu starten."
