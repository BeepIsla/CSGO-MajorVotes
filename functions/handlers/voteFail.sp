VoteFail(int reason)
{
	new entity = FindEntityByClassname(-1, "vote_controller");
	
	if (entity < 0) return;
	
	new Handle:voteFailed;

	if (GetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1) != -1)
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
	
	CreateTimer(0.5, Timer_ResetData);
}