public Action:Listener_Suicide(client, const String:command[], int argc)
{
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