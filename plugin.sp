#include <sourcemod>
#include <sdktools>
#include <cstrike>

public Plugin myinfo = {
	name        = "Major Votes",
	author      = "github.com/BeepFelix",
	description = "Allows users to use the ingame votes seen in Major Tournaments such as \"Load Backup\", \"Pause during freezetime\", \"Begin warmup countdown to match start\", etc.",
	version     = "2.3"
};

int teamVoteID = -1;
int voteType = -1;
int voteCaller = -1;
new String:displayString[512];
new String:detailsString[512];
new String:otherTeamString[512];
new String:passString[512];
new String:passDetailsString[512];
new String:backupToLoad[512];
new bool:isTeamOnly = false;
new bool:soloOnly = false;
new bool:isVoteActive = false;
new bool:alreadyVoted[MAXPLAYERS + 1];
new bool:canSurrender = true;
new Handle:voteTimeout = null;
new ConVar:g_hEnabled = null;
new ConVar:g_hEventName = null;
new ConVar:g_hEventStage = null;
new ConVar:g_hPlayersNeeded = null;
new ConVar:g_hDisallowSuicide = null;
new ConVar:g_hDeleteBackupFiles = null;
new ConVar:g_hVoteDuration = null;
new ConVar:g_hMaxrounds = null;
new ConVar:g_hMaxroundsOT = null;

public OnPluginStart()
{
	for (int i = 0; i < MAXPLAYERS + 1; i++) alreadyVoted[i] = false;
	
	AddCommandListener(Listener_Vote, "vote");
	AddCommandListener(Listener_Callvote, "callvote");
	AddCommandListener(Listener_Listissues, "listissues");
	AddCommandListener(Listener_Suicide, "kill");
	AddCommandListener(Listener_Suicide, "explode");

	g_hEnabled = CreateConVar("sm_tournament_enabled", "1", "1 to enable the plugin. 0 to disable the plugin", _, true, 0.0, true, 1.0);
	g_hEventName = CreateConVar("sm_tournament_name", "CSGO_Tournament_Event_Name_14", "The localization of your tournament name. Set to \"\" to enable matchmaking mode");
	g_hEventStage = CreateConVar("sm_tournament_stage", "CSGO_Tournament_Event_Stage_Display_11", "Optional localization of the stage name. Set to \"\" for no stage");
	g_hPlayersNeeded = CreateConVar("sm_tournament_players_to_start", "10", "The needed player count in order to start a match. The warmup vote will always show \"This vote requires 10 players\" if the required player count is not met.", _, true, 1.0);
	g_hDisallowSuicide = CreateConVar("sm_tournament_disallow_suicide", "1", "Should we disable suiciding during the match?", _, true, 0.0, true, 1.0);
	g_hDeleteBackupFiles = CreateConVar("sm_tournament_delete_round_backups", "0", "Should we delete all backup files when the match ends? (\"cs_intermission\" gets triggered)", _, true, 0.0, true, 1.0);
	g_hVoteDuration = FindConVar("sv_vote_timer_duration");
	g_hMaxrounds = FindConVar("mp_maxrounds");
	g_hMaxroundsOT = FindConVar("mp_overtime_maxrounds");

	g_hEnabled.AddChangeHook(OnConVarChange);
	g_hEventName.AddChangeHook(OnConVarChange);
	g_hEventStage.AddChangeHook(OnConVarChange);
	g_hVoteDuration.AddChangeHook(OnConVarChange_voteDuration);
	g_hMaxrounds.AddChangeHook(OnConVarChange_checkSurrender);
	g_hMaxroundsOT.AddChangeHook(OnConVarChange_checkSurrender);

	HookEvent("round_start", Event_RoundStart);
	HookEvent("cs_intermission", Event_Intermission);

	AutoExecConfig(true, "tournament");
}

public void OnClientConnected(client)
{
	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 0) return;

	// To make 100% sure the convars are set properly
	if (GetConVarFloat(g_hVoteDuration) < 1.0)
	{
		SetConVarFloat(g_hVoteDuration, 1.0);
	}

	alreadyVoted[client] = false;
}

public void OnClientDisconnect(client)
{
	alreadyVoted[client] = false;
}

public void OnMapStart()
{
	if (GetConVarInt(g_hEnabled) <= 0) return;

	new String:eventName[512];
	GetConVarString(g_hEventName, eventName, sizeof(eventName));

	new String:eventStage[512];
	GetConVarString(g_hEventStage, eventStage, sizeof(eventStage));

	GameRules_SetProp("m_bIsQueuedMatchmaking", GetConVarInt(g_hEnabled));
	GameRules_SetPropString("m_szTournamentEventName", eventName);
	GameRules_SetPropString("m_szTournamentEventStage", eventStage);

	canSurrender = true;
	
	for (int i = 0; i < MAXPLAYERS + 1; i++) alreadyVoted[i] = false;
}

#include "./functions/listeners/listissues.sp"
#include "./functions/listeners/callvote.sp"
#include "./functions/listeners/vote.sp"
#include "./functions/listeners/suicide.sp"
#include "./functions/listeners/convarChange.sp"
#include "./functions/listeners/roundStart.sp"
#include "./functions/listeners/terminateRound.sp"
#include "./functions/listeners/intermission.sp"

#include "./functions/handlers/voteYes.sp"
#include "./functions/handlers/voteNo.sp"
#include "./functions/handlers/getResults.sp"
#include "./functions/handlers/votePass.sp"
#include "./functions/handlers/voteFail.sp"
#include "./functions/handlers/voteTimeout.sp"

#include "./functions/resolvers/doSurrender.sp"
#include "./functions/resolvers/doReadyForMatch.sp"
#include "./functions/resolvers/doNotReadyForMatch.sp"
#include "./functions/resolvers/doPauseMatch.sp"
#include "./functions/resolvers/doUnpauseMatch.sp"
#include "./functions/resolvers/doLoadBackup.sp"
#include "./functions/resolvers/doStartTimeout.sp"

#include "./functions/functions.sp"
