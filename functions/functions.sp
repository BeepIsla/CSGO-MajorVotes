DidWePassQuorumRatio(yesVotes, noVotes, quorum)
{
	int resultQuorum = yesVotes / (yesVotes + noVotes) * 100;
	
	if (resultQuorum >= quorum)
	{
		return true;
	}
	else
	{
		return false;
	}
}

RealPlayerCount(client, bool:InGameOnly, bool:teamOnly)
{
	new clientTeam = GetClientTeam(client);
	new players = 0;

	for(new i = 1; i <= MaxClients; i++)
	{
		if (InGameOnly == true)
		{
			if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
			{
				if (teamOnly == true)
				{
					if (clientTeam == GetClientTeam(i))
					{
						players++;
					}
				}
				else
				{
					players++;
				}
			}
		}
		else
		{
			if (IsClientConnected(i) && !IsFakeClient(i))
			{
				if (teamOnly == true)
				{
					if (clientTeam == GetClientTeam(i))
					{
						players++;
					}
				}
				else
				{
					players++;
				}
			}
		}
	}

	return players;
}

public Action:Timer_ResetData(Handle:timer)
{
	isVoteActive = false;
	for (int i = 0; i < MAXPLAYERS + 1; i++) alreadyVoted[i] = false;
	
	new entity = FindEntityByClassname(-1, "vote_controller");
	if (entity > -1)
	{
		//SetEntProp(entity, Prop_Send, "m_iActiveIssueIndex", -1);
		for (new i = 0; i < 5; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nVoteOptionCount", 0, _, i);
		}
		SetEntProp(entity, Prop_Send, "m_nPotentialVotes", 0);
		SetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1);
		SetEntProp(entity, Prop_Send, "m_bIsYesNoVote", true);
	}	
}