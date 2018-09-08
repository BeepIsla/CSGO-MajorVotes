public Action CS_OnTerminateRound(float& delay, CSRoundEndReason& reason)
{
	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 0) return Plugin_Continue;

	canSurrender = false;

	if (reason != CSRoundEnd_TerroristsSurrender && reason != CSRoundEnd_CTSurrender)
	{
		if (isVoteActive == true)
		{
			new entity = FindEntityByClassname(-1, "vote_controller");

			if (entity < 0) return Plugin_Continue;

			int activeIssue = GetEntProp(entity, Prop_Send, "m_iActiveIssueIndex", -1);

			if (activeIssue == 0) // Surrender
			{
				CreateTimer(1.0, Timer_VoteFail, 33);
			}
		}
	}

	return Plugin_Continue;
}
