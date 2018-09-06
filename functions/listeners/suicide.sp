public Action:Listener_Suicide(client, const String:command[], int argc)
{
	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 0) return Plugin_Continue;

	if (GetConVarBool(g_hDisallowSuicide) == true)
	{
		if (GameRules_GetProp("m_bWarmupPeriod") == 1)
		{
			return Plugin_Continue;
		}
		else
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}