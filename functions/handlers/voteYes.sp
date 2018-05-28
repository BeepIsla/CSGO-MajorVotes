voteYes(client)
{
	new Handle:castVote = CreateEvent("vote_cast");
	SetEventInt(castVote, "vote_option", 0);
	
	if (isTeamOnly == true) SetEventInt(castVote, "team", GetClientTeam(client));
	else SetEventInt(castVote, "team", -1);
	
	SetEventInt(castVote, "entityid", client);
	FireEvent(castVote);
	
	new entity = FindEntityByClassname(-1, "vote_controller");
	
	if (entity < 0) return;
	
	int curVotes = GetEntProp(entity, Prop_Send, "m_nVoteOptionCount", -1, 0); // Get yes votes
	curVotes++; // Increase yes votes
	SetEntProp(entity, Prop_Send, "m_nVoteOptionCount", curVotes, _, 0); // Set yes votes
	
	CreateTimer(0.5, Timer_GetResults);
}