public Action:Listener_Listissues(client, const String:command[], int argc)
{
	new String:eventName[512];
	GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));
	
	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) > 0)
	{
		PrintToConsole(client, "---Vote commands---");
		PrintToConsole(client, "callvote ReadyForMatch");
		PrintToConsole(client, "callvote NotReadyForMatch");
		PrintToConsole(client, "callvote PauseMatch");
		PrintToConsole(client, "callvote UnpauseMatch");
		PrintToConsole(client, "callvote LoadBackup <backup name>");
		PrintToConsole(client, "callvote StartTimeout");
		PrintToConsole(client, "--- End Vote commands---");
		return Plugin_Handled;
	}
	else if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1)
	{
		PrintToConsole(client, "---Vote commands---");
		PrintToConsole(client, "callvote surrender");
		PrintToConsole(client, "callvote StartTimeout");
		PrintToConsole(client, "--- End Vote commands---");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}