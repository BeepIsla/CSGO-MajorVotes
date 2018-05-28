VotePass()
{
	new entity = FindEntityByClassname(-1, "vote_controller");
	
	if (entity < 0) return;

	new Handle:votePass;
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
	
	CreateTimer(0.5, Timer_ResetData);
}