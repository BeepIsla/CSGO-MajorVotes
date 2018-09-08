public Action:Timer_VoteFail(Handle:timer, int reason)
{
	new entity = FindEntityByClassname(-1, "vote_controller");
	
	if (entity < 0) return Plugin_Continue;
	
	new Handle:voteFailed;

	if (soloOnly == true)
	{
		new client = GetClientOfUserId(voteCaller);
		if (client <= 0 && client > MaxClients)
		{
			CreateTimer(5.0, Timer_ResetData);
			return Plugin_Continue;
		}

		new onlyUs[1];
		onlyUs[0] = client;
		
		voteFailed = StartMessage("VoteFailed", onlyUs, 1, USERMSG_RELIABLE);
	}
	else if (GetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1) != -1)
	{
		new sendto[MaxClients];
		new index = 0;
		for (new i = 1; i < MaxClients; i++)
		{
			if (IsClientInGame(i) && teamVoteID == GetClientTeam(i))
			{
				sendto[index] = i;
				index++;
			}
		}
		voteFailed = StartMessage("VoteFailed", sendto, index, USERMSG_RELIABLE);
	}
	else
	{
		voteFailed = StartMessageAll("VoteFailed", USERMSG_RELIABLE);
	}
	
	PbSetInt(voteFailed, "team", GetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1));
	PbSetInt(voteFailed, "reason", reason);
	/*
	0 = Vote Failed.
	1 = *Empty*
	2 = *Empty*
	3 = Yes votes must exceed No votes.
	4 = Not enough players voted.
	*/
	EndMessage();
	
	if (voteTimeout != null)
	{
		KillTimer(voteTimeout);
		voteTimeout = null;
	}

	CreateTimer(5.0, Timer_ResetData);
	return Plugin_Continue;
}