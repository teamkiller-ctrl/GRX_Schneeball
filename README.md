# GRX_Schneeball

# Vorschau: Soon

Deutsch
------

Kurz: Dieses kleine Script fügt Schneeeffekte und Schneebälle hinzu und verbessert optional die Fahrzeug-Traktion bei Schneewetter (`XMAS`).

Installation
- Resource in den `resources`-Ordner legen.
- `server.cfg` oder `fxmanifest.lua` prüfen und Resource starten:  
```bash
ensure schneeball
```

Konfiguration
- Einstellungen sind in `config.lua` (z. B. `Config.SnowHandling.TractionMultiplier`).
- Beispielwerte:
	- `TractionMultiplier = 1.25` (erhöht Traktion)
	- `LowSpeedTractionLossMultiplier = 0.85` (reduziert Verlust bei niedriger Geschwindigkeit)

Testen
- Auf dem Server `refresh` und `restart schneeball` ausführen oder `ensure schneeball`.
- Im Spiel Schneewetter abwarten (Weather `XMAS`) oder Wetter manuell setzen und ein Fahrzeug besteigen — das Fahrverhalten sollte weniger rutschen.

Hinweise
- Änderungen sind clientseitig in `client.lua` implementiert; die Original-Handling-Werte werden beim Ende des Schnees wiederhergestellt.

English
-------

# preview: soon

Short: This small script adds snow effects and snowballs and optionally improves vehicle traction during snow weather (`XMAS`).

Installation
- Place the resource into your `resources` folder.
- Start the resource in `server.cfg` or via console:  
```bash
ensure schneeball
```

Configuration
- Settings are in `config.lua` (e.g. `Config.SnowHandling.TractionMultiplier`).
- Example values:
	- `TractionMultiplier = 1.25` (increases traction)
	- `LowSpeedTractionLossMultiplier = 0.85` (reduces low-speed traction loss)

Testing
- Run `refresh` and `restart schneeball` on the server, or `ensure schneeball`.
- While `XMAS` weather is active, enter a vehicle — handling should feel less slippery.

Notes
- Changes are implemented client-side in `client.lua`; original handling values are restored when snow ends.

If you want, I can:
- Feinabstimmung der Multiplikatoren pro Fahrzeugklasse hinzufügen.
- Die Änderungen serverseitig auf alle Spieler/Fahrzeuge ausweiten.
