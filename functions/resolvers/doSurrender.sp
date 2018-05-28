public Action:Timer_DoSurrender(Handle:timer, any:team)
{
	if (team == CS_TEAM_CT)
	{
		CS_TerminateRound(1.0, CSRoundEnd_CTSurrender, false);
	}
	else if (team == CS_TEAM_T)
	{
		CS_TerminateRound(1.0, CSRoundEnd_TerroristsSurrender, false);
	}
}