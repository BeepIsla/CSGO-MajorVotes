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

RealPlayerCount(client, bool:InGameOnly, bool:teamOnly, bool:noSpectators)
{
	new clientTeam = CS_TEAM_NONE;

	if (client > 0) {
		clientTeam = GetClientTeam(client);
	}

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
					if (noSpectators == true)
					{
						if (GetClientTeam(i) == CS_TEAM_CT || GetClientTeam(i) == CS_TEAM_T)
						{
							players++
						}
					}
					else
					{
						players++;
					}
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

/*
	Credit: https://github.com/powerlord/sourcemod-tf2-scramble/blob/master/addons/sourcemod/scripting/include/valve.inc#L18
*/
stock PrintValveTranslation(clients[], numClients, msg_dest, const String:msg_name[], const String:param1[]="", const String:param2[]="", const String:param3[]="", const String:param4[]="")
{
	new Handle:bf = StartMessage("TextMsg", clients, numClients, USERMSG_RELIABLE);
	
	if (GetUserMessageType() == UM_Protobuf)
	{
		PbSetInt(bf, "msg_dst", msg_dest);
		PbAddString(bf, "params", msg_name);
		
		PbAddString(bf, "params", param1);
		PbAddString(bf, "params", param2);
		PbAddString(bf, "params", param3);
		PbAddString(bf, "params", param4);
	}
	else
	{
		BfWriteByte(bf, msg_dest);
		BfWriteString(bf, msg_name);
		
		BfWriteString(bf, param1);
		BfWriteString(bf, param2);
		BfWriteString(bf, param3);
		BfWriteString(bf, param4);
	}
	
	EndMessage();
}

stock PrintValveTranslationToAll(msg_dest, const String:msg_name[], const String:param1[]="", const String:param2[]="", const String:param3[]="", const String:param4[]="")
{
	new total = 0;
	new clients[MaxClients];
	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientConnected(i))
		{
			clients[total++] = i;
		}
	}
	PrintValveTranslation(clients, total, msg_dest, msg_name, param1, param2, param3, param4);
}
