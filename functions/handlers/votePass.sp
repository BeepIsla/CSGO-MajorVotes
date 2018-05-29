VotePass()
{
	new entity = FindEntityByClassname(-1, "vote_controller");
	
	if (entity < 0) return;

	new Handle:votePass;
	if (soloOnly == true)
	{
		new client = GetClientOfUserId(voteCaller);
		if (client <= 0 && client > MaxClients)
		{
			CreateTimer(0.5, Timer_ResetData);
			return;
		}

		new onlyUs[1];
		onlyUs[0] = client;
		
		votePass = StartMessage("VotePass", onlyUs, 1, USERMSG_RELIABLE);
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
		votePass = StartMessage("VotePass", sendto, index, USERMSG_RELIABLE);
	}
	else
	{
		votePass = StartMessageAll("VotePass", USERMSG_RELIABLE);
	}

	PbSetInt(votePass, "team", GetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1));
	PbSetInt(votePass, "vote_type", GetEntProp(entity, Prop_Send, "m_iActiveIssueIndex", -1));
	PbSetString(votePass, "disp_str", passString);
	PbSetString(votePass, "details_str", passDetailsString);
	EndMessage();
	
	if (voteTimeout != null)
	{
		KillTimer(voteTimeout);
		voteTimeout = null;
	}
	
	CreateTimer(1.0, Timer_ResetData);
}