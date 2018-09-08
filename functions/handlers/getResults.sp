public Action:Timer_GetResults(Handle:timer, any:userid)
{
	// Get stuff and check if we pass or fail or wait for more votes
	new entity = FindEntityByClassname(-1, "vote_controller");
	
	if (entity < 0) return Plugin_Stop;
	
	int client = GetClientOfUserId(userid); // Only used for coaching votes else it is highly inaccurate
	int activeIssue = GetEntProp(entity, Prop_Send, "m_iActiveIssueIndex", -1); // Special index for each and every custom type - Compare it to a list to figure out what we voted
	int potentialVotes = GetEntProp(entity, Prop_Send, "m_nPotentialVotes", -1); // Max amount of votes
	int teamOnly = GetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1); // -1 = All, 0 = Unassigned, 1 = Spectators, 2 = Terrorists, 3 = Counter-Terrorists
	int option1 = GetEntProp(entity, Prop_Send, "m_nVoteOptionCount", -1, 0); // Yes votes count
	int option2 = GetEntProp(entity, Prop_Send, "m_nVoteOptionCount", -1, 1); // No votes count
	
	if (activeIssue == 0) // Surrender
	{
		if ((option1 + option2) >= potentialVotes)
		{
			if (DidWePassQuorumRatio(option1, option2, 100))
			{
				CreateTimer(0.5, Timer_VotePass);
				CreateTimer(0.5, Timer_DoSurrender, teamOnly);
				canSurrender = false;
			}
			else
			{
				CreateTimer(0.5, Timer_VoteFail, 3);
			}
		}
	}
	else if (activeIssue == 1) // ReadyForMatch
	{
		if ((option1 + option2) >= potentialVotes)
		{
			if (DidWePassQuorumRatio(option1, option2, 100))
			{
				CreateTimer(0.5, Timer_VotePass);
				CreateTimer(0.5, Timer_DoReadyForMatch);
			}
			else
			{
				CreateTimer(0.5, Timer_VoteFail, 3);
			}
		}
	}
	else if (activeIssue == 2) // NotReadyForMatch
	{
		if (option1 >= 1)
		{
			CreateTimer(0.5, Timer_VotePass);
			CreateTimer(0.5, Timer_DoNotReadyForMatch);
		}
	}
	else if (activeIssue == 3) // PauseMatch
	{
		if (option1 >= 1)
		{
			CreateTimer(0.5, Timer_VotePass);
			CreateTimer(0.5, Timer_DoPauseMatch);
		}
	}
	else if (activeIssue == 4) // UnpauseMatch
	{
		if ((option1 + option2) >= potentialVotes)
		{
			if (DidWePassQuorumRatio(option1, option2, 100))
			{
				CreateTimer(0.5, Timer_VotePass);
				CreateTimer(0.5, Timer_DoUnpauseMatch);
			}
			else
			{
				CreateTimer(0.5, Timer_VoteFail, 3);
			}
		}
	}
	else if (activeIssue == 5) // LoadBackup
	{
		if ((option1 + option2) >= potentialVotes)
		{
			if (DidWePassQuorumRatio(option1, option2, 100))
			{
				CreateTimer(0.5, Timer_VotePass);
				CreateTimer(0.5, Timer_DoLoadBackup);
			}
			else
			{
				CreateTimer(0.5, Timer_VoteFail, 3);
			}
		}
	}
	else if (activeIssue == 6) // StartTimeout
	{
		if (option1 >= 1)
		{
			CreateTimer(0.5, Timer_VotePass);

			if (teamOnly == CS_TEAM_SPECTATOR)
			{
				if (GetEntProp(client, Prop_Send, "m_iCoachingTeam") == 3) // CT
				{
					CreateTimer(0.5, Timer_DoStartTimeout, CS_TEAM_CT);
				}
				else if (GetEntProp(client, Prop_Send, "m_iCoachingTeam") == 2) // T
				{
					CreateTimer(0.5, Timer_DoStartTimeout, CS_TEAM_T);
				}
			} else {
				CreateTimer(0.5, Timer_DoStartTimeout, teamOnly);
			}
		}
	}
	
	return Plugin_Handled;
}