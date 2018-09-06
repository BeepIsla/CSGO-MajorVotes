public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 0) return Plugin_Continue;

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

	return Plugin_Continue;
}