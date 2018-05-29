public Action:Event_AnnouncePhaseEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	canSurrender = false;

	if (isVoteActive == true)
	{
		new entity = FindEntityByClassname(-1, "vote_controller");

		if (entity < 0) return;

		int activeIssue = GetEntProp(entity, Prop_Send, "m_iActiveIssueIndex", -1);

		if (activeIssue == 0 || activeIssue == 6)
		{
			VoteFail(0);
		}
	}

	new Float:HalftimeDuration = GetConVarFloat(FindConVar("mp_halftime_duration"));
	CreateTimer(HalftimeDuration, Timer_HalftimeDuration);
}

public Action Timer_HalftimeDuration(Handle timer)
{
	canSurrender = true;
	return Plugin_Continue;
}