public Action:Listener_Callvote(client, const String:command[], int argc)
{
	/*
	0 = Vote Failed.
	1 = You cannot call a new vote while other players are still loading.
	2 = You called a vote recently and can not call another for %d seconds.
	3 = Vote Failed.
	4 = Vote Failed.
	5 = Server has disabled that issue.
	6 = That map does not exist.
	7 = You must specify a map name.
	8 = This vote recently failed. It can't be called again for &d secs.
	9 = Voting to kick this player failed recently. It can't be called for %d secs.
	10 = Voting to this map failed recently. It can't be called again for %d secs.
	11 = Voting to swap teams failed recently. It can't be called again for &d secs.
	12 = Voting to scramble failed recently. It can't be called again for %d secs.
	13 = Voting to restart failed recently. It can't be called again for %d secs.
	14 = Your team cannot call this vote.
	15 = Voting not allowed during warmup.
	16 = Vote failed.
	17 = You may not vote to kick the server admin.
	18 = A Team Scramble is in progress.
	19 = A Team Swap is in progress.
	20 = This server has disabled voting for Spectators.
	21 = This server has disabled voting.
	22 = The next level has already been set.
	23 = Vote Failed.
	24 = You cannot surrender until a teammate abandons the match.
	25 = Vote Failed.
	26 = The match is already paused!
	27 = The match is not paused!
	28 = The match is not in warmup!
	29 = This vote requires 10 players.
	30 = A timeout is already in progress.
	31 = Vote Failed.
	32 = Your team has no timeouts left.
	33 = Vote can't succeed after round has ended. Call vote again.
	*/

	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 0) return Plugin_Continue;

	if (argc < 1 || IsFakeClient(client)) // FakeClients (eg Bots) cause errors and we dont want that
	{
		return Plugin_Continue;
	}
	
	new onlyUs[1];
	onlyUs[0] = client;
		
	if (isVoteActive == true)
	{
		new entity = FindEntityByClassname(-1, "vote_controller");
		
		if (entity < 0) return Plugin_Stop;
		
		if (GetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1) == GetClientTeam(client))
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 0);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
		}
		else
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 0);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
		}
		
		return Plugin_Handled;
	}

	new bool:issueFound = false;

	new String:option[512];
	GetCmdArg(1, option, sizeof(option));
	
	if (strcmp(option, "Surrender", false) == 0 && (GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T))
	{
		// This vote ONLY works if we are not in an event
		new String:eventName[512];
		GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));
		if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) > 0) return Plugin_Handled;

		// Do fail checks
		if (GameRules_GetProp("m_bWarmupPeriod") == 1)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 15);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		if (canSurrender == false)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 5);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		// Continue with the normal stuff
		voteType = 0;
		displayString = "#SFUI_vote_surrender";
		detailsString = "";
		otherTeamString = "#SFUI_otherteam_vote_unimplemented";
		passString = "#SFUI_vote_passed_surrender";
		passDetailsString = "";
		isTeamOnly = true;
		soloOnly = false;

		issueFound = true;
	}
	else if (strcmp(option, "ReadyForMatch", false) == 0 && GetClientTeam(client) == CS_TEAM_SPECTATOR && GetEntProp(client, Prop_Send, "m_iCoachingTeam") == 0)
	{
		// This vote ONLY works if we are in an event
		new String:eventName[512];
		GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));
		if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) < 1) return Plugin_Handled;
		
		// Do fail checks
		if (GameRules_GetProp("m_bWarmupPeriod") == 0)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 28);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		if (GetConVarBool(FindConVar("mp_warmup_pausetimer")) == false)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 5);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		new requiredPlayers = 10;
		if (GetConVarInt(g_hPlayersNeeded) > 0) requiredPlayers = GetConVarInt(g_hPlayersNeeded);

		if (RealPlayerCount(client, true, false, true) < requiredPlayers)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 29);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		// Continue with the normal stuff
		voteType = 1;
		displayString = "#SFUI_Vote_ready_for_match";
		detailsString = "";
		otherTeamString = "#SFUI_otherteam_vote_unimplemented";
		passString = "#SFUI_vote_passed_ready_for_match";
		passDetailsString = "";
		isTeamOnly = false;
		soloOnly = false;
		
		issueFound = true;
	}
	else if (strcmp(option, "NotReadyForMatch", false) == 0 && GetClientTeam(client) == CS_TEAM_SPECTATOR && GetEntProp(client, Prop_Send, "m_iCoachingTeam") == 0)
	{
		// This vote ONLY works if we are in an event
		new String:eventName[512];
		GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));
		if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) < 1) return Plugin_Handled;
		
		// Do fail checks
		if (GameRules_GetProp("m_bWarmupPeriod") == 0)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 28);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		if (GetConVarBool(FindConVar("mp_warmup_pausetimer")) == true)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 5);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		// Continue with the normal stuff
		voteType = 2;
		displayString = "#SFUI_Vote_not_ready_for_match";
		detailsString = "";
		otherTeamString = "#SFUI_otherteam_vote_unimplemented";
		passString = "#SFUI_vote_passed_not_ready_for_match";
		passDetailsString = "";
		isTeamOnly = false;
		soloOnly = true;
		
		issueFound = true;
	}
	else if (strcmp(option, "PauseMatch", false) == 0 && (GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_SPECTATOR || GetEntProp(client, Prop_Send, "m_iCoachingTeam") != 0))
	{
		// This vote ONLY works if we are in an event
		new String:eventName[512];
		GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));
		if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) < 1) return Plugin_Handled;
		
		// Do fail checks
		if (GameRules_GetProp("m_bMatchWaitingForResume") == 1)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 26);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		// Continue with the normal stuff
		voteType = 3;
		displayString = "#SFUI_Vote_pause_match";
		detailsString = "";
		otherTeamString = "#SFUI_otherteam_vote_unimplemented";
		passString = "#SFUI_vote_passed_pause_match";
		passDetailsString = "";
		isTeamOnly = false;
		soloOnly = true;
		
		issueFound = true;
	}
	else if (strcmp(option, "UnpauseMatch", false) == 0 && GetClientTeam(client) == CS_TEAM_SPECTATOR && GetEntProp(client, Prop_Send, "m_iCoachingTeam") == 0)
	{
		// This vote ONLY works if we are in an event
		new String:eventName[512];
		GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));
		if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) < 1) return Plugin_Handled;
		
		// Do fail checks
		if (GameRules_GetProp("m_bMatchWaitingForResume") == 0)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 27);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		// Continue with the normal stuff
		voteType = 4;
		displayString = "#SFUI_Vote_unpause_match";
		detailsString = "";
		otherTeamString = "#SFUI_otherteam_vote_unimplemented";
		passString = "#SFUI_vote_passed_unpause_match";
		passDetailsString = "";
		isTeamOnly = false;
		soloOnly = false;
		
		issueFound = true;
	}
	else if (strcmp(option, "LoadBackup", false) == 0 && GetClientTeam(client) == CS_TEAM_SPECTATOR && GetEntProp(client, Prop_Send, "m_iCoachingTeam") == 0)
	{
		// This vote ONLY works if we are in an event
		new String:eventName[512];
		GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));
		if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) < 1) return Plugin_Handled;
		
		// Do fail checks
		if (GameRules_GetProp("m_bMatchWaitingForResume") == 0)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 27);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		// Get argument 2
		new String:option2[512];
		GetCmdArg(2, option2, sizeof(option2));

		// Extract team scores out of backup file if it exists
		if (FileExists(option2) == false)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 0);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		int firstHalfScoreTeam1 = 0;
		int firstHalfScoreTeam2 = 0;
		int secondHalfScoreTeam1 = 0;
		int secondHalfScoreTeam2 = 0;
		int OvertimeScoreTeam1 = 0;
		int OvertimeScoreTeam2 = 0;

		int currentlyLogging = -1;
		// -1 = Undefined
		// 0  = FirstHalfScore
		// 1  = SecondHalfScore
		// 2  = OvertimeScore

		new String:line[1024];
		new Handle:fileHandle = OpenFile(option2, "r");
		while (!IsEndOfFile(fileHandle) && ReadFileLine(fileHandle, line, sizeof(line)))
		{
			TrimString(line);

			if (strcmp(line, "\"FirstHalfScore\"", true) == 0)
			{
				currentlyLogging = 0;
				continue;
			}
			else if (strcmp(line, "\"SecondHalfScore\"", true) == 0)
			{
				currentlyLogging = 1;
				continue;
			}
			else if (strcmp(line, "\"OvertimeScore\"", true) == 0)
			{
				currentlyLogging = 2;
				continue;
			}

			if (strncmp(line, "\"team1\"", 7, true) == 0)
			{
				ReplaceString(line, sizeof(line), "\"team1\"", "", true);
				ReplaceString(line, sizeof(line), "\"", "", true);
				TrimString(line);

				if (currentlyLogging == 0)
				{
					firstHalfScoreTeam1 = StringToInt(line);
				}
				else if (currentlyLogging == 1)
				{
					secondHalfScoreTeam1 = StringToInt(line);
				}
				else if (currentlyLogging == 2)
				{
					OvertimeScoreTeam1 = StringToInt(line);
				}
			}
			else if (strncmp(line, "\"team2\"", 7, true) == 0)
			{
				ReplaceString(line, sizeof(line), "\"team2\"", "", true);
				ReplaceString(line, sizeof(line), "\"", "", true);
				TrimString(line);

				if (currentlyLogging == 0)
				{
					firstHalfScoreTeam2 = StringToInt(line);
				}
				else if (currentlyLogging == 1)
				{
					secondHalfScoreTeam2 = StringToInt(line);
				}
				else if (currentlyLogging == 2)
				{
					OvertimeScoreTeam2 = StringToInt(line);
				}
			}
		}
		CloseHandle(fileHandle);

		int totalScoreTeam1 = (firstHalfScoreTeam1 + secondHalfScoreTeam1 + OvertimeScoreTeam1);
		int totalScoreTeam2 = (firstHalfScoreTeam2 + secondHalfScoreTeam2 + OvertimeScoreTeam2);
		new String:stringDetailsBackup[512];
		Format(stringDetailsBackup, sizeof(stringDetailsBackup), "%d:%d", totalScoreTeam1, totalScoreTeam2);

		// Continue with the normal stuff
		voteType = 5;
		displayString = "#SFUI_Vote_loadbackup";
		detailsString = stringDetailsBackup;
		otherTeamString = "#SFUI_otherteam_vote_unimplemented";
		passString = "#SFUI_vote_passed_loadbackup";
		passDetailsString = stringDetailsBackup;
		isTeamOnly = false;
		soloOnly = false;
		Format(backupToLoad, sizeof(backupToLoad), "%s", option2);

		issueFound = true;
	}
	else if (strcmp(option, "StartTimeout", false) == 0 && (GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T || GetEntProp(client, Prop_Send, "m_iCoachingTeam") != 0))
	{
		// Let the game handle the votes if we are NOT in an event
		new String:eventName[512];
		GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));
		if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) <= 0) return Plugin_Continue;
		// Else let the plugin handle the votes

		// Do fail checks
		if (GameRules_GetProp("m_bTerroristTimeOutActive") == 1 || GameRules_GetProp("m_bCTTimeOutActive") == 1)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 30);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		if (GameRules_GetProp("m_bMatchWaitingForResume") == 1)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 26);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		int tTimeoutsLeft = GameRules_GetProp("m_nTerroristTimeOuts", 1);
		int ctTimeoutsLeft = GameRules_GetProp("m_nCTTimeOuts", 1);

		if ((GetClientTeam(client) == CS_TEAM_CT || GetEntProp(client, Prop_Send, "m_iCoachingTeam") == 3) && ctTimeoutsLeft <= 0 || (GetClientTeam(client) == CS_TEAM_T || GetEntProp(client, Prop_Send, "m_iCoachingTeam") == 2) && tTimeoutsLeft <= 0)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 32);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		// Continue with the normal stuff
		voteType = 6;
		displayString = "#SFUI_vote_start_timeout";
		detailsString = "";
		otherTeamString = "#SFUI_otherteam_vote_unimplemented";
		passString = "#SFUI_vote_passed_timeout";
		passDetailsString = "";
		isTeamOnly = true;
		soloOnly = false;
		
		issueFound = true;
	}
	else if (strcmp(option, "Kick", false) == 0) // (GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T) (Game handles kicking - Checks not required)
	{
		// This vote ONLY works if we are not in an event
		new String:eventName[512];
		GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));
		if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) > 0) return Plugin_Handled;

		return Plugin_Continue; // Let the game handle kicking
	}
	
	if (issueFound == true)
	{
		CreateTimer(0.0, Timer_StartVote, GetClientUserId(client));
		voteTimeout = CreateTimer(GetConVarFloat(FindConVar("sv_vote_timer_duration")), Timer_VoteTimeout, GetClientUserId(client));
	} else {
		new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
		PbSetInt(voteStart, "reason", 14);
		PbSetInt(voteStart, "time", -1);
		EndMessage();
	}

	return Plugin_Handled;
}

public Action:Timer_StartVote(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0 && client > MaxClients)
	{
		return;
	}

	new entity = FindEntityByClassname(-1, "vote_controller");
	
	if (entity < 0) return;
	
	SetEntProp(entity, Prop_Send, "m_iActiveIssueIndex", voteType);
	
	if (soloOnly == true) SetEntProp(entity, Prop_Send, "m_nPotentialVotes", 1);
	else if (isTeamOnly == true) SetEntProp(entity, Prop_Send, "m_nPotentialVotes", RealPlayerCount(client, true, true, false));
	else SetEntProp(entity, Prop_Send, "m_nPotentialVotes", RealPlayerCount(client, true, false, true));

	if (isTeamOnly == true || soloOnly == true) SetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", GetClientTeam(client));
	else SetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1);

	SetEntProp(entity, Prop_Send, "m_bIsYesNoVote", true);
	
	for (new i = 0; i < 5; i++) SetEntProp(entity, Prop_Send, "m_nVoteOptionCount", 0, _, i);
	
	CreateTimer(0.0, Timer_voteStart, GetClientUserId(client));
}

public Action:Timer_voteStart(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0 && client > MaxClients)
	{
		return;
	}

	teamVoteID = GetClientTeam(client);

	new Handle:voteStart;
	if (isTeamOnly == true)
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
		voteStart = StartMessage("VoteStart", sendto, index, USERMSG_RELIABLE);
	}
	else if (soloOnly == true)
	{
		new onlyUs[1];
		onlyUs[0] = client;

		voteStart = StartMessage("VoteStart", onlyUs, 1, USERMSG_RELIABLE);
	}
	else
	{
		voteStart = StartMessageAll("VoteStart", USERMSG_RELIABLE);
	}
	
	if (isTeamOnly == true || soloOnly == true) PbSetInt(voteStart, "team", GetClientTeam(client)); // -1 = All, 0 = Unassigned, 1 = Spectators, 2 = Terrorists, 3 = Counter-Terrorists
	else PbSetInt(voteStart, "team", -1); // -1 = All, 0 = Unassigned, 1 = Spectators, 2 = Terrorists, 3 = Counter-Terrorists
	
	PbSetInt(voteStart, "ent_idx", client); // Vote caller
	PbSetString(voteStart, "disp_str", displayString); // String to display (Example: "Change map to:") - Customs dont work?
	PbSetString(voteStart, "details_str", detailsString); // Details to display (Example: "de_dust2") - Customs dont work?
	PbSetBool(voteStart, "is_yes_no_vote", true); // CSGO only supports Yes/No
	PbSetString(voteStart, "other_team_str", otherTeamString); // What to display if we call the vote while being on the wrong team
	PbSetInt(voteStart, "vote_type", voteType);
	EndMessage();
	
	CreateTimer(0.0, Timer_VoteCast, GetClientUserId(client));
	voteCaller = GetClientUserId(client);
	return;
}

public Action:Timer_VoteCast(Handle:timer, any:userid)
{
	// Cast vote from caller - ALWAYS YES
	new client = GetClientOfUserId(userid);
	if (client <= 0 && client > MaxClients)
	{
		return Plugin_Continue;
	}

	// Spectators cannot vote on issues (Excluding coaches if its a timeout or match pause)
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) == true && GetClientTeam(i) == CS_TEAM_SPECTATOR)
		{
			if (voteType == 3 || voteType == 6)
			{
				if (GetEntProp(client, Prop_Send, "m_iCoachingTeam") == 3 || GetEntProp(client, Prop_Send, "m_iCoachingTeam") == 2) continue;
			}

			alreadyVoted[i] = true;
		}
	}

	if (voteType == 1 || voteType == 4 || voteType == 5)
	{
		if (IsClientInGame(client) == true && GetClientTeam(client) == CS_TEAM_SPECTATOR)
		{
			// Do not vote yes if we are a spectator. Spectators cannot vote on issues. (Including coaches)
			// This only applies to "ReadyForMatch" (1), "UnpauseMatch" (4) and "LoadBackup" (5) votes
			isVoteActive = true;
			return Plugin_Handled;
		}
	}
	else
	{
		voteYes(client);
		isVoteActive = true;
		alreadyVoted[client] = true;
	}

	return Plugin_Handled;
}