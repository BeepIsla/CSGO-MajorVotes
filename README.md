# CSGO-MajorVotes v2

This plugin is for 10man's, Tournaments, or whatever you want to use it for. I will never add thing like "Mapvote" or similar to it.

I recommend using the `example_server_settings_matchmaking.cfg` config as a base for your server config if you use the matchmaking mode. Same the other way around for the `example_server_settings_tournament.cfg` config for tournament mode.

I recommend against loading backup files from other matches. They completely fuck up the game. I played 33 rounds in my test match which ended 21:12 before CSGO realised "oh wait the match is over".

[Showcase Album (Tournament Mode)](https://imgur.com/a/sZoTdYM)

[Showcase Album (Matchmaking Mode)](https://imgur.com/a/MPkMFGn)

**For issues add me on Discord: Felix#2343**

[Small plugin explanation to understand a little how this all works.](pluginExplanation.md)

# Credit:
- **Thanks to [Powerlord](https://forums.alliedmods.net/member.php?u=38996)** for making the original [NativeVotes](https://forums.alliedmods.net/showthread.php?t=208008), [csgo_votestart_test](https://github.com/powerlord/sourcemod-nativevotes/blob/master/addons/sourcemod/scripting/csgo_votestart_test.sp), [votediagnostics](https://github.com/powerlord/sourcemod-nativevotes/blob/master/addons/sourcemod/scripting/votediagnostics.sp) plugins and for the "[valve.inc](https://github.com/powerlord/sourcemod-tf2-scramble/blob/master/addons/sourcemod/scripting/include/valve.inc)". Without these and I would have never been able to understand how votes in CSGO works. Big big thanks to [Powerlord](https://forums.alliedmods.net/member.php?u=38996)!

# Convars
### Custom
- `sm_tournament_enabled`
- - Default: `1`
- - Description: `1 to enable the plugin. 0 to disable the plugin`
- `sm_tournament_name`
- - Default: `Tournament Test Event`
- - Description: `The name of your tournament. Set to "" to enable matchmaking mode`
- `sm_tournament_stage`
- - Default: `Grand Final`
- - Description: `Optional name of the stage. Set to "" for no stage`
- `sm_tournament_players_to_start`
- - Default `10`
- - Description: `The needed player count in order to start a match. The warmup vote will always show "This vote requires 10 players" if the required player count is not met.`
- `sm_tournament_disallow_suicide`
- - Default: `1`
- - Description: `Should we disable suiciding during the match?`

### Default
- `sv_vote_timer_duration`
- - Controls the length of the votes before they timeout
- - Minimum 1.0

# Changelog:

**2.2.1:**
- **General**
- - Added convars:
- - - `sm_tournament_disallow_suicide`
- - - - Default: `1`
- - - - Description: `Should we disable suiciding during the match?`
- - Fixed team-only votes not displaying properly

- **Matchmaking Mode**
- - Fixed not being able to call a surrender vote during freezetime pause
- - Surrender votes are now disabled 1 round before and during halftime/matchend

- **Tournament Mode**
- - Fixed backup votes not working (Thanks Valve for breaking things)

**2.2:**
- **General**
- - Added convars:
- - - `sm_tournament_enabled`
- - - - Default: `1`
- - - - Description: `1 to enable the plugin. 0 to disable the plugin`
- - - `sm_tournament_name`
- - - - Default: `Tournament Test Event`
- - - - Description: `The name of your tournament. Set to "" to enable matchmaking mode`
- - - `sm_tournament_stage`
- - - - Default: `Grand Final`
- - - - Description: `Optional name of the stage. Set to "" for no stage`
- - - `sm_tournament_players_to_start`
- - - - Default `10`
- - - - Description: `The needed player count in order to start a match. The warmup vote will always show "This vote requires 10 players" if the required player count is not met.`
- - Votes now follow the ingame vote duration. (Eg: Change `sv_vote_timer_duration` to adjust voting duration)
- - `sv_vote_timer_duration` is now being forced to a minimum of `1.0`

- **Tournament Mode**
- - **Ingame players can now only start a vote for a "Tactical Timeout" and a "Technical Pause".**
- - - Spectators can call a vote to unpause the match, load backup, etc.
- - - This is a Valve restriction due to the new voting UI
- - - I highly recommend always having at least 1 spectator when using tournament mode.
- - Fixed timeouts not working properly when using a value above `1` for  `mp_team_timeout_max`

- **Matchmaking Mode**
- - Matchmaking mode now uses the ingame way of handling timeouts
- - Fixed being able to call a surrender vote during warmup

**2.1:**
- Added proper chat messages when someone pauses the match or stops the warmup countdown
- Fixed the error "Trying to resolve a vote that is not a YES/NO vote, YES/NO votes aren't currently supported!" appearing in server console when calling a vote to stop the warmup countdown
- Fixed some votes showing for everyone even tho only the caller should see them
- Fixed votes never ending on their own
- Kinda fixed surrendering and timeouts triggering for the wrong team when calling them during halftime (It is not 100% fixed - I will do that later)
- Plugin now supports kicking:
	- It only works if "m_szTournamentEventName" is set to ""
	- It requires 2 or more players
	- It is controlled by "sv_vote_issue_kick_allowed" set it to "1" to enable kicking, "0" to disable
	- Use "sv_vote_kick_ban_duration" to set the length of the ban after being kicked

**2.0:**
- Removed the requirement for NativeVotes
- Votes are now fully handled by the plugin itself
