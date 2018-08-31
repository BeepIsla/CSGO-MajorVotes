public Action CS_OnTerminateRound(float& delay, CSRoundEndReason& reason)
{
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
				VoteFail(33);
			}
		}
	}

	return Plugin_Continue;
}
