public Action:Listener_Vote(client, const String:command[], int argc)
{
	if (!isVoteActive || argc < 1)
	{
		return Plugin_Continue;
	}
	
	if (alreadyVoted[client] == true || soloOnly == true) return Plugin_Stop;

	new entity = FindEntityByClassname(-1, "vote_controller");
	
	if (entity < 0) return Plugin_Stop;
	
	if (GetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1) != -1 && GetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1) != GetClientTeam(client)) return Plugin_Stop;
	
	new String:option[512];
	GetCmdArg(1, option, sizeof(option));
	
	if (strcmp(option, "option1", false) == 0)
	{
		voteYes(client);
	}
	else if (strcmp(option, "option2", false) == 0)
	{
		voteNo(client);
	}
	
	return Plugin_Handled;
}