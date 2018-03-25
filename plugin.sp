#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <nativevotes>

new String:backupToLoad[1024];

public Plugin myinfo = {
	name        = "Ingame Tournament Votes",
	author      = "github.com/BeepFelix",
	description = "Allows users to use the ingame votes seen in Major Tournaments such as \"Load Backup\", \"Pause during freezetime\", \"Begin warmup countdown to match start\", etc",
	version     = "0.0.1"
};

#include "./functions/functions.sp"

public void OnConfigsExecuted()
{
	GameRules_SetPropString("m_szTournamentEventName", "Custom Test Tournament"); // This is required to enable the Major-Like behaviour
	GameRules_SetPropString("m_szTournamentEventStage", "");
	GameRules_SetProp("m_bIsQueuedMatchmaking", 1); // This is required to enable the Major-Like behaviour
	// "m_bIsQueuedMatchmaking" forces the teammenu to be disabled (similar to "mp_force_assign_teams" & "sv_disable_show_team_select_menu")
	// So I recommend you write your own team-manager or team-balancer or whatever to go around this
	
	ServerCommand("nativevotes_vote_delay 5");
	ServerCommand("nativevotes_progress_chat 0");
	ServerCommand("nativevotes_progress_console 1");
	ServerCommand("nativevotes_progress_client_console 0");
	ServerCommand("nativevotes_progress_hintbox 0");
	ServerCommand("sv_vote_command_delay 0");
}

public void OnPluginStart()
{
	AddCommandListener(Command_Callvote, "callvote");
}

#include "./functions/listeners/callvote.sp"

#include "./functions/handlers/vote_readyformatch.sp"
#include "./functions/handlers/vote_notreadyformatch.sp"
#include "./functions/handlers/vote_pausematch.sp"
#include "./functions/handlers/vote_unpausematch.sp"
#include "./functions/handlers/vote_timeout.sp"
#include "./functions/handlers/vote_loadbackup.sp"
