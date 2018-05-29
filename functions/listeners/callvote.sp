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
	
	if (GetClientTeam(client) != CS_TEAM_CT && GetClientTeam(client) != CS_TEAM_T)
	{
		new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
		PbSetInt(voteStart, "reason", 14);
		PbSetInt(voteStart, "time", -1);
		EndMessage();
		
		return Plugin_Continue;
	}
	
	new bool:issueFound = false;
	
	new String:option[512];
	GetCmdArg(1, option, sizeof(option));
	
	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 0) return Plugin_Continue;
	
	if (strcmp(option, "Surrender", false) == 0)
	{
		// This vote ONLY works if we are not in an event
		new String:eventName[512];
		GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));
		if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) > 0) return Plugin_Handled;
		
		// Do fail checks
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
	else if (strcmp(option, "ReadyForMatch", false) == 0)
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

		if (RealPlayerCount(client, true, false) < 10)
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
	else if (strcmp(option, "NotReadyForMatch", false) == 0)
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
	else if (strcmp(option, "PauseMatch", false) == 0)
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
	else if (strcmp(option, "UnpauseMatch", false) == 0)
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
	else if (strcmp(option, "LoadBackup", false) == 0)
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

		// Continue with the normal stuff
		voteType = 5;
		displayString = "#SFUI_Vote_loadbackup";
		detailsString = option2;
		otherTeamString = "#SFUI_otherteam_vote_unimplemented";
		passString = "#SFUI_vote_passed_loadbackup";
		passDetailsString = option2;
		isTeamOnly = false;
		soloOnly = false;
		
		issueFound = true;
	}
	else if (strcmp(option, "StartTimeout", false) == 0)
	{
		// This vote works if we are in an event AND if we are not

		// return Plugin_Continue;
		// Uncomment this if you want (Explanation at the bottom of the if statement)
		
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
		
		if (canSurrender == false)
		{
			new Handle:voteStart = StartMessage("CallVoteFailed", onlyUs, 1, USERMSG_RELIABLE);
			PbSetInt(voteStart, "reason", 5);
			PbSetInt(voteStart, "time", -1);
			EndMessage();
			return Plugin_Handled;
		}

		float tTimeoutsRemaining = GameRules_GetPropFloat("m_flTerroristTimeOutRemaining");
		float ctTimeoutsRemaining = GameRules_GetPropFloat("m_flCTTimeOutRemaining");
		int tTimeoutsLeft = RoundToNearest(tTimeoutsRemaining);
		int ctTimeoutsLeft = RoundToNearest(ctTimeoutsRemaining);
		if (GetClientTeam(client) == CS_TEAM_CT && ctTimeoutsLeft <= 0 || GetClientTeam(client) == CS_TEAM_T && tTimeoutsLeft <= 0)
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

		// This is technically irrelevant. The game can handle timeout votes by itself. I still included it just so this plugin is complete
		// If you want the game to handle it (it will need 51% of the votes to pass - The plugin only requires 1 single vote)
		// Then uncomment the "return Plugin_Continue" at the top of this if statement
	}
	else if (strcmp(option, "Kick", false) == 0)
	{
		// This vote ONLY works if we are not in an event
		new String:eventName[512];
		GameRules_GetPropString("m_szTournamentEventName", eventName, sizeof(eventName));
		if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 1 && strlen(eventName) > 0) return Plugin_Handled;

		return Plugin_Continue; // Make the game handle kicking
	}
	
	if (issueFound)
	{
		CreateTimer(0.0, Timer_StartVote, GetClientUserId(client));
		voteTimeout = CreateTimer(60.0, Timer_VoteTimeout, GetClientUserId(client));
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
	
	SetEntProp(entity, Prop_Send, "m_iActiveIssueIndex", voteType); // 1 = Idk Restarting Round or smth?
	
	if (soloOnly == true) SetEntProp(entity, Prop_Send, "m_nPotentialVotes", 1);
	else if (isTeamOnly == true) SetEntProp(entity, Prop_Send, "m_nPotentialVotes", RealPlayerCount(client, true, true));
	else SetEntProp(entity, Prop_Send, "m_nPotentialVotes", RealPlayerCount(client, true, false));
	
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
	
	voteYes(client);
	teamVoteID = GetClientTeam(client);
	isVoteActive = true;
	alreadyVoted[client] = true;

	return Plugin_Handled;
}