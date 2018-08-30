public Action:Timer_DoPauseMatch(Handle:timer)
{
	ServerCommand("mp_pause_match");

	new client = GetClientOfUserId(voteCaller);
	if (client <= 0 && client > MaxClients)
	{
		CreateTimer(0.5, Timer_ResetData);
		return;
	}
	new String:ClientName[512];
	GetClientName(client, ClientName, sizeof(ClientName));
	PrintValveTranslationToAll(3, "#SFUI_vote_passed_pause_match_chat", ClientName);
}