# CSGO MajorVotes

Enable Valve Matchmaking & Valve Major functionality in your games.

For Tournaments/Majors at least one spectator is ALWAYS needed. Only they can load backups, unpause the match, or start the warmup countdown.

You may have to add `-maxplayers_override` to your command line if you require more slots on your server than the default.

You may need to adjust your server config as some convars are required to allow spectators to start a vote and to have infinite warmup at the beginning of the match.

# Requirements

- [ExtendedCommandLine](https://github.com/BeepIsla/extended-command-line/)

# Preview

![Matchmaking](https://i.imgur.com/pmnBzLQ.png "Matchmaking")
![Tournament](https://i.imgur.com/4EMm68F.png "Tournament")

# Config

Place your config in `addons/sourcemod/configs/match.vdf`. A full example config can be found [here](configs/match.vdf). If a client joins the server and they are not in this list the server will automatically refuse connection. Run `sm_match_reload` to setup the match, you will likely need to execute this from the server console directly.

**Warning**: The command will reload the current map and every client not in the `match.vdf` will be kicked out.

- `Match`
  - `Tournament`: **OPTIONAL** - Enables Tournament/Major mode
    - `NameID`: Event ID to display the name of - **Only** IDs from the [translation files](https://github.com/SteamDatabase/GameTracking-CSGO/blob/master/csgo/resource/csgo_english.txt?raw=true) work (Prefixed with `CSGO_Tournament_Event_Name_`).
    - `StageID`: Stage ID to display the name of - **Only** IDs from the [translation files](https://github.com/SteamDatabase/GameTracking-CSGO/blob/master/csgo/resource/csgo_english.txt?raw=true) work (Prefixed with `CSGO_Tournament_Event_Stage_Display_`).
  - `Teams`
    - `0`: First team, starts the match as CT
      - `Name`: **OPTIONAL** - Team name
      - `Flag`: **OPTIONAL** - Team flag
      - `Logo`: **OPTIONAL** - Team logo - Custom logos will require you to use a download manager
      - `Players`: A list of [account ID](#account-id)s which are assigned to this team - Use `0` as filler if needed
    - `1`: Second team, starts the match as T
      - `Name`: **OPTIONAL** - Team name
      - `Flag`: **OPTIONAL** - Team flag
      - `Logo`: **OPTIONAL** - Team logo - Custom logos will require you to use a download manager
      - `Players`: A list of [account ID](#account-id)s which are assigned to this team - Use `0` as filler if needed
  - `Spectators`: **OPTIONAL** - A list of [account ID](#account-id)s which can spectate this match

# Account ID

Use a website like [SteamID.io](https://steamid.io/) and convert your Steam Profile link to their SteamID. Go to the `steamID3` and copy out the last number.

Example: `[U:1:25341944]` is the SteamID3, `25341944` is the account ID.

# Credits

Thanks to the CSGO Source Code leak for letting me figure this out
