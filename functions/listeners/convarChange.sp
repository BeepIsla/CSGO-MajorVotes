public void OnConVarChange(ConVar convar, char[] oldValue, char[] newValue)
{
	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 0) return;

	new String:eventName[512];
	GetConVarString(g_hEventName, eventName, sizeof(eventName));

	new String:eventStage[512];
	GetConVarString(g_hEventStage, eventStage, sizeof(eventStage));

	GameRules_SetProp("m_bIsQueuedMatchmaking", GetConVarInt(g_hEnabled));
	GameRules_SetPropString("m_szTournamentEventName", eventName);
	GameRules_SetPropString("m_szTournamentEventStage", eventStage);
}

public void OnConVarChange_checkSurrender(ConVar convar, char[] oldValue, char[] newValue)
{
	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 0) return;

	if (RealPlayerCount(0, false, false, false) <= 0) return;

	int CTScore = CS_GetTeamScore(CS_TEAM_CT);
	int TScore = CS_GetTeamScore(CS_TEAM_T);
	int totalScore = CTScore + TScore;
	int maxRounds = GetConVarInt(FindConVar("mp_maxrounds"));

	if (totalScore >= maxRounds)
	{
		totalScore = totalScore - maxRounds;
		maxRounds = GetConVarInt(FindConVar("mp_overtime_maxrounds"));

		while (totalScore >= maxRounds)
		{
			totalScore = totalScore - maxRounds;
		}
	}

	int res = RoundToNearest(float(maxRounds / 2)) - totalScore;

	if (res == 1) // Match is now 1 round before halftime
	{
		canSurrender = false;
	}
	else if (res == ((RoundToNearest(float(maxRounds / 2)) - maxRounds) + 1)) // Match is now 1 round before end
	{
		canSurrender = false;
	}
	else
	{
		canSurrender = true;
	}
	return;
}

public void OnConVarChange_voteDuration(ConVar convar, char[] oldValue, char[] newValue)
{
	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 0) return;

	if (GetConVarFloat(g_hVoteDuration) < 1.0)
	{
		SetConVarFloat(g_hVoteDuration, 1.0);
	}
}
