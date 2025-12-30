# GRX_Schneeball

Deutsch
-------

Kurzbeschreibung
---------------

`GRX_Schneeball` fügt Schneeeffekte und Schneebälle ins Spiel ein und kann optional das Fahrverhalten bei Schneewetter (`XMAS`) verbessern. Das Script besteht aus client- und serverseitigen Komponenten und lässt sich leicht in ESX(Legacy)-Server integrieren.

Features
- Schneeeffekte und Schnee-Visuals
- Schneeball-Waffe (werfbar)
- Optionale Anpassung der Fahrzeug-Traktion während Schnee
- Beispiel-Integration für `ox_inventory`

Anforderungen
- FiveM Server
- `es_extended` (ESX Legacy)
- `ox_lib`
- `ox_inventory` (für Inventar-/Item-Integration)

Installation
1. Die Resource-Ordner `schneeball` in deinen Server-`resources`-Ordner kopieren.
2. In `server.cfg` oder per Konsole die Resource aktivieren:

```bash
ensure schneeball
```

3. Stelle sicher, dass `ox_lib` und `ox_inventory` installiert sind. Füge das Snowball-Item wie im Abschnitt "ox_inventory Integration" hinzu.

Konfiguration
- Öffne `config.lua` und passe die Werte an. Relevante Einstellungen:
  - `Config.SnowHandling.TractionMultiplier` — multipliziert die Traktion bei Schnee (z. B. `1.25`).
  - `Config.SnowHandling.LowSpeedTractionLossMultiplier` — zusätzlicher Multiplikator bei niedrigen Geschwindigkeiten (z. B. `0.85`).

Beispiel (aus `config.lua`)
```lua
Config = {}
Config.SnowHandling = {
  TractionMultiplier = 1.25,
  LowSpeedTractionLossMultiplier = 0.85,
}
```

Benutzung & Test
- Auf dem Server `refresh` ausführen und `restart schneeball` oder `ensure schneeball`.
- Aktiviere Schneewetter (`XMAS`) im Spiel oder per Weather-Trigger und teste Fahrverhalten und Schneebälle.

Debug / Hinweise
- Handling-Änderungen werden clientseitig in `client.lua` angewendet und beim Ende des Schnees wiederhergestellt.
- Falls Effekte nicht auftauchen: überprüfe die Konsole auf Fehler und bestätige, dass die Resource gestartet ist.

ox_inventory Integration (Beispiel)
---------------------------------

Wenn du `ox_inventory` verwendest, kannst du das Item für Schneebälle in `ox_inventory/data/weapons.lua` hinzufügen. Beispiel:

```lua
['WEAPON_SNOWBALL'] = {
  label = 'Schneeball',
  weight = 5,
  throwable = true,
  anim = { 'anim@mp_snowball', 'unholster', 200, 'anim@mp_snowball', 'holster', 600 },
  buttons = {
    {
      label = 'Schneemann Herstellen',
      close = true,
      action = function(slot)
        TriggerEvent('schneeball:attempt_build')
      end
    }
  },
},
```

Tipps & Erweiterungen
- Feinabstimmung: Passe die Multiplikatoren pro Fahrzeugklasse an, wenn nötig.
- Serverweite Wirkung: Wenn du die Handling-Änderung serverseitig für alle Spieler erzwingen willst, kann das Script erweitert werden, um Werte an alle Clients zu senden.

Lizenz & Credits
- Ursprünglicher Autor / Anpassungen: siehe `fxmanifest.lua` / Header im Code.
- Verwende die Resource gemäß den Lizenzbedingungen im Repository oder frage den Autor bei Unklarheiten.

Support
- Melde Fehler oder Wünsche als Issue im Repository oder kontaktiere den Autor/Server-Administrator.

---

English
-------

Short description
-----------------

`GRX_Schneeball` adds snow effects and throwable snowballs to the game and can optionally improve vehicle handling during snow weather (`XMAS`). The resource contains client and server components and integrates easily with ESX (Legacy) servers.

Features
- Snow visual effects
- Throwable snowball weapon
- Optional vehicle traction adjustments during snow
- Example integration for `ox_inventory`

Requirements
- FiveM server
- `es_extended` (ESX Legacy)
- `ox_lib`
- `ox_inventory` (for inventory/item integration)

Installation
1. Copy the `schneeball` resource folder into your server `resources` directory.
2. Enable the resource in `server.cfg` or via console:

```bash
ensure schneeball
```

3. Make sure `ox_lib` and `ox_inventory` are installed. Add the snowball item as shown in the "ox_inventory Integration" section.

Configuration
- Open `config.lua` and adjust values. Relevant settings:
  - `Config.SnowHandling.TractionMultiplier` — multiplies traction during snow (e.g. `1.25`).
  - `Config.SnowHandling.LowSpeedTractionLossMultiplier` — additional multiplier for low-speed handling (e.g. `0.85`).

Example (from `config.lua`)
```lua
Config = {}
Config.SnowHandling = {
  TractionMultiplier = 1.25,
  LowSpeedTractionLossMultiplier = 0.85,
}
```

Usage & Testing
- Run `refresh` and `restart schneeball` on the server, or `ensure schneeball`.
- Activate `XMAS` weather in-game or via a weather trigger and test handling and snowballs.

Debug / Notes
- Handling changes are applied client-side in `client.lua` and restored when snow ends.
- If effects do not appear: check the console for errors and confirm the resource is started.

ox_inventory Integration (example)
---------------------------------

If you use `ox_inventory`, add the snowball item to `ox_inventory/data/weapons.lua`. Example:

```lua
['WEAPON_SNOWBALL'] = {
  label = 'Snowball',
  weight = 5,
  throwable = true,
  anim = { 'anim@mp_snowball', 'unholster', 200, 'anim@mp_snowball', 'holster', 600 },
  buttons = {
    {
      label = 'Build Snowman',
      close = true,
      action = function(slot)
        TriggerEvent('schneeball:attempt_build')
      end
    }
  },
},
```

Tips & Extensions
- Tweak multipliers per vehicle class if needed.
- To enforce handling changes server-side for all players, extend the resource to broadcast values to clients.

License & Credits
- Original author / modifications: see `fxmanifest.lua` headers.
- Use the resource according to the repository license or contact the author if unsure.

Support
- Report bugs or feature requests as an issue in the repository or contact the server administrator.

If you want, I can:
- patch your `ox_inventory` file automatically to add the snowball item,
- add more comments to `config.lua`,
- or produce a compact English-only README instead.
