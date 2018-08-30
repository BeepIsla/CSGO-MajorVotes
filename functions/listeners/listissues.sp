public Action:Listener_Listissues(client, const String:command[], int argc)
{
	new String:eventName[512];
	GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));

	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) > 0)
	{
		if (GetClientTeam(client) == CS_TEAM_SPECTATOR) {
			PrintToConsole(client, "---Vote commands---");
			PrintToConsole(client, "callvote ReadyForMatch");
			PrintToConsole(client, "callvote NotReadyForMatch");
			PrintToConsole(client, "callvote PauseMatch");
			PrintToConsole(client, "callvote UnpauseMatch");
			PrintToConsole(client, "callvote LoadBackup <backup>");
			PrintToConsole(client, "--- End Vote commands---");
			return Plugin_Handled;
		} else {
			PrintToConsole(client, "---Vote commands---");
			PrintToConsole(client, "callvote PauseMatch");
			PrintToConsole(client, "callvote StartTimeout");
			PrintToConsole(client, "--- End Vote commands---");
			return Plugin_Handled;
		}
	}
	else if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1)
	{
		PrintToConsole(client, "---Vote commands---");
		if (GetConVarBool(FindConVar("sv_vote_issue_kick_allowed")) == true) PrintToConsole(client, "callvote Kick <userID>");
		PrintToConsole(client, "callvote Surrender");
		PrintToConsole(client, "callvote StartTimeout");
		PrintToConsole(client, "--- End Vote commands---");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}