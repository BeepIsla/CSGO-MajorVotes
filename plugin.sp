#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <valve>

public Plugin myinfo = {
	name        = "Ingame Tournament Votes",
	author      = "github.com/BeepFelix",
	description = "Allows users to use the ingame votes seen in Major Tournaments such as \"Load Backup\", \"Pause during freezetime\", \"Begin warmup countdown to match start\", etc",
	version     = "2.0"
};

int teamVoteID = -1;
int voteType = -1;
int voteCaller = -1;
new String:displayString[512];
new String:detailsString[512];
new String:otherTeamString[512];
new String:passString[512];
new String:passDetailsString[512];
new bool:isTeamOnly = false;
new bool:soloOnly = false;
new bool:isVoteActive = false;
new bool:alreadyVoted[MAXPLAYERS + 1];
new bool:canSurrender = true;
new Handle:voteTimeout = null;

public OnPluginStart()
{
	for (int i = 0; i < MAXPLAYERS + 1; i++) alreadyVoted[i] = false;
	
	AddCommandListener(Listener_Vote, "vote");
	AddCommandListener(Listener_Callvote, "callvote");
	AddCommandListener(Listener_Listissues, "listissues");

	HookEvent("announce_phase_end", Event_AnnouncePhaseEnd) // Halftime/Win panel display event - Executes when the scoreboard automatically shows up
}

public void OnClientConnected(client)
{
	alreadyVoted[client] = false;
}

public void OnClientDisconnect(client)
{
	alreadyVoted[client] = false;
}

public void OnMapStart()
{
	canSurrender = true;
	
	for (int i = 0; i < MAXPLAYERS + 1; i++) alreadyVoted[i] = false;
	
	GameRules_SetProp("m_bIsQueuedMatchmaking", 1); // Change this in combination of "m_szTournamentEventName" to achieve different plugin-results
	GameRules_SetPropString("m_szTournamentEventName", ""); // Change this in combination of "m_bIsQueuedMatchmaking" to achieve different plugin-results

	/*
	How the aboves work:
		- Set "m_bIsQueuedMatchmaking" to 0 to disable the plugin
		- Set "m_szTournamentEventName" to "" to disable tournament votes
			- It only enabled "StartTimeout" and "surrender"
			- Everything else is disabled
			- It technically also enabled "kick" but I did not implement it in the plugin - It is handled by the game
		- Set "m_szTournamentEventName" to any string (it is shown in the top right on your scoreboard) to enable tournament votes
			- It enables "ReadyForMatch" & "NotReadyForMatch" & "PauseMatch" & "UnpauseMatch" & "LoadBackup" & "StartTimeout"
			- It disables "surrender"
	*/

	ServerCommand("mp_win_panel_display_time 0"); // This is required to make the scoreboard show up instantly as soon as the match is over or halftime happened
}

#include "./functions/listeners/listissues.sp"
#include "./functions/listeners/callvote.sp"
#include "./functions/listeners/vote.sp"

#include "./functions/handlers/voteYes.sp"
#include "./functions/handlers/voteNo.sp"
#include "./functions/handlers/getResults.sp"
#include "./functions/handlers/votePass.sp"
#include "./functions/handlers/voteFail.sp"
#include "./functions/handlers/voteTimeout.sp"
#include "./functions/handlers/event_announcePhaseEnd.sp"

#include "./functions/resolvers/doSurrender.sp"
#include "./functions/resolvers/doReadyForMatch.sp"
#include "./functions/resolvers/doNotReadyForMatch.sp"
#include "./functions/resolvers/doPauseMatch.sp"
#include "./functions/resolvers/doUnpauseMatch.sp"
#include "./functions/resolvers/doLoadBackup.sp"
#include "./functions/resolvers/doStartTimeout.sp"

#include "./functions/functions.sp"