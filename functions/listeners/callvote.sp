public Action:Command_Callvote(client, const String:command[], argc)
{
	if (client <= 0) return Plugin_Handled;
	
	decl String:arg[32];
	GetCmdArg(1, arg, sizeof(arg));
	
	decl String:argument[32];
	StrToLowerRemoveBlanks(arg, argument, sizeof(argument));
	
	// Vote to start warmup countdown
	if (strcmp(argument, "readyformatch") == 0)
	{
		ServerCommand("sv_vote_quorum_ratio 1.0");

		new Handle:vote = NativeVotes_Create(VOTE_ReadyForMatchHandler, NativeVotesType_Custom_YesNo);
		
		if (GetConVarInt(FindConVar("mp_warmup_pausetimer")) == 0 || GameRules_GetProp("m_bWarmupPeriod") == 0 || !NativeVotes_IsNewVoteAllowed())
		{
			NativeVotes_DisplayFail(vote, NativeVotesFail_Generic);
			NativeVotes_Close(vote);
			return Plugin_Handled;
		}

		NativeVotes_SetInitiator(vote, client);
		NativeVotes_SetDetails(vote, "#SFUI_Vote_ready_for_match");
		NativeVotes_DisplayToAll(vote, GetConVarInt(FindConVar("sv_vote_timer_duration")));
	}
	
	// Vote to stop warmup countdown
	else if (strcmp(argument, "notreadyformatch") == 0)
	{
		ServerCommand("sv_vote_quorum_ratio 0.01");

		new Handle:vote = NativeVotes_Create(VOTE_NotReadyForMatchHandler, NativeVotesType_Custom_YesNo);
		
		if (GetConVarInt(FindConVar("mp_warmup_pausetimer")) == 1 || GameRules_GetProp("m_bWarmupPeriod") == 0 || !NativeVotes_IsNewVoteAllowed())
		{
			NativeVotes_DisplayFail(vote, NativeVotesFail_Generic);
			NativeVotes_Close(vote);
			return Plugin_Handled;
		}
		
		NativeVotes_SetInitiator(vote, client);
		NativeVotes_SetDetails(vote, "#SFUI_Vote_not_ready_for_match");
		NativeVotes_DisplayToAll(vote, GetConVarInt(FindConVar("sv_vote_timer_duration")));
	}

	// Vote to pause match at next freezetime
	else if (strcmp(argument, "pausematch") == 0)
	{
		ServerCommand("sv_vote_quorum_ratio 0.01");

		new Handle:vote = NativeVotes_Create(VOTE_PauseMatchHandler, NativeVotesType_Custom_YesNo);
		
		if (GameRules_GetProp("m_bMatchWaitingForResume") == 1 || GameRules_GetProp("m_bWarmupPeriod") == 1 || !NativeVotes_IsNewVoteAllowed())
		{
			NativeVotes_DisplayFail(vote, NativeVotesFail_Generic);
			NativeVotes_Close(vote);
			return Plugin_Handled;
		}
		
		NativeVotes_SetInitiator(vote, client);
		NativeVotes_SetDetails(vote, "#SFUI_Vote_pause_match");
		NativeVotes_DisplayToAll(vote, GetConVarInt(FindConVar("sv_vote_timer_duration")));
	}

	// Vote to unpause match
	else if (strcmp(argument, "unpausematch") == 0)
	{
		ServerCommand("sv_vote_quorum_ratio 1.0");
		
		new Handle:vote = NativeVotes_Create(VOTE_UnpauseMatchHandler, NativeVotesType_Custom_YesNo);
		
		if (GameRules_GetProp("m_bMatchWaitingForResume") == 0 || GameRules_GetProp("m_bWarmupPeriod") == 1 || !NativeVotes_IsNewVoteAllowed())
		{
			NativeVotes_DisplayFail(vote, NativeVotesFail_Generic);
			NativeVotes_Close(vote);
			return Plugin_Handled;
		}
		
		NativeVotes_SetInitiator(vote, client);
		NativeVotes_SetDetails(vote, "#SFUI_Vote_unpause_match");
		NativeVotes_DisplayToAll(vote, GetConVarInt(FindConVar("sv_vote_timer_duration")));
	}

	// Vote to timeout at next freezetime
	else if (strcmp(argument, "starttimeout") == 0)
	{
		ServerCommand("sv_vote_quorum_ratio 0.501");
		return Plugin_Continue;
		
		// We do not need this code as timeouts still get handled by the game itself for some reason (plus the below code doesnt even work cuz im stupid)
		
		/*new Handle:vote = NativeVotes_Create(VOTE_StartTimeoutHandler, NativeVotesType_Custom_YesNo);
		
		if (GameRules_GetProp("m_bMatchWaitingForResume") == 1 || GameRules_GetProp("m_bTerroristTimeOutActive") == 1 ||
			GameRules_GetProp("m_bCTTimeOutActive") == 1 || GameRules_GetProp("m_flTerroristTimeOutRemaining") <= 0 || 
			GameRules_GetProp("m_flCTTimeOutRemaining") <= 0|| !NativeVotes_IsNewVoteAllowed() || GameRules_GetProp("m_bWarmupPeriod") == 1)
		{
			NativeVotes_DisplayFail(vote, NativeVotesFail_Generic);
			NativeVotes_Close(vote);
			return Plugin_Handled;
		}
		
		NativeVotes_SetInitiator(vote, client);
		NativeVotes_SetTeam(vote, GetClientTeam(client));
		NativeVotes_SetDetails(vote, "#SFUI_Vote_pause_match");
		NativeVotes_DisplayToAll(vote, GetConVarInt(FindConVar("sv_vote_timer_duration")));*/
	}

	// Vote to load a backup file
	else if (strcmp(argument, "loadbackup") == 0)
	{
		ServerCommand("sv_vote_quorum_ratio 1.0");

		new Handle:vote = NativeVotes_Create(VOTE_LoadBackupHandler, NativeVotesType_Custom_YesNo);
		
		if (argc < 2 || GameRules_GetProp("m_gamePhase") == 5 || GameRules_GetProp("m_bWarmupPeriod") == 1 || !NativeVotes_IsNewVoteAllowed())
		{
			NativeVotes_DisplayFail(vote, NativeVotesFail_Generic);
			NativeVotes_Close(vote);
			return Plugin_Handled;
		}
		
		GetCmdArg(2, backupToLoad, sizeof(backupToLoad));

		if (!FileExists(backupToLoad))
		{
			NativeVotes_DisplayFail(vote, NativeVotesFail_Generic);
			NativeVotes_Close(vote);
			return Plugin_Handled;
		}
		
		NativeVotes_SetInitiator(vote, client);
		NativeVotes_SetDetails(vote, "#SFUI_Vote_loadbackup");
		NativeVotes_DisplayToAll(vote, GetConVarInt(FindConVar("sv_vote_timer_duration")));
	}
	return Plugin_Handled;
}
