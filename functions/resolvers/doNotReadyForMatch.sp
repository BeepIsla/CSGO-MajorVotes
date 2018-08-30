public Action:Timer_DoNotReadyForMatch(Handle:timer)
{
	ServerCommand("mp_warmup_pausetimer 1");
	ServerCommand("mp_warmuptime 60");

	new client = GetClientOfUserId(voteCaller);
	if (client <= 0 && client > MaxClients)
	{
		CreateTimer(0.5, Timer_ResetData);
		return;
	}
	new String:ClientName[512];
	GetClientName(client, ClientName, sizeof(ClientName));
	PrintValveTranslationToAll(3, "#SFUI_vote_passed_not_ready_for_match_chat", ClientName);
}