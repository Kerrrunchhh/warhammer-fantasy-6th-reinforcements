# BattleScribe Installer: Warhammer Fantasy Battle 6th edition with Reinforcements
$repo = "Kerrrunchhh/warhammer-fantasy-6th-reinforcements"
$base = "https://github.com/$repo/releases/latest/download"
$dest = "$env:APPDATA\BattleScribe\data\Warhammer Fantasy Battle 6th edition with Reinforcements"

$files = @(
    "Warhammer.Fantasy.Battle.6th.edition.with.Reinforcements.gstz",
    "Bretonnia.catz", "Chaos.catz", "Dark.Elves.catz", "Dogs.of.War.catz",
    "Dwarfs.catz", "Empire.catz", "High.Elf.catz", "Lizardmen.catz",
    "Ogre.Kingdoms.catz", "Orcs.and.Goblins.catz", "RH.Chaos.Dwarfs.catz",
    "RH.Orcs.and.Goblins.catz", "Skaven.catz", "Tomb.Kings.catz",
    "Vampire.Counts.catz", "Wood.Elf.catz"
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
