voteNo(client)
{
	new Handle:castVote = CreateEvent("vote_cast");
	SetEventInt(castVote, "vote_option", 1);
	
	if (isTeamOnly == true) SetEventInt(castVote, "team", GetClientTeam(client));
	else if (soloOnly == true) SetEventInt(castVote, "team", 0); // Technically that can NEVER happen - The creator cant vote no
	else SetEventInt(castVote, "team", -1);
	
	SetEventInt(castVote, "entityid", client);
	FireEvent(castVote);
	
	new entity = FindEntityByClassname(-1, "vote_controller");
	
	if (entity < 0) return;
	
	int curVotes = GetEntProp(entity, Prop_Send, "m_nVoteOptionCount", -1, 1); // Get no votes
	curVotes++; // Increase no votes
	SetEntProp(entity, Prop_Send, "m_nVoteOptionCount", curVotes, _, 1); // Set no votes
	
	CreateTimer(0.5, Timer_GetResults, GetClientUserId(client));
}