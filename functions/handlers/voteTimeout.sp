public Action Timer_VoteTimeout(Handle timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client <= 0 && client > MaxClients)
	{
		return;
	}

	CreateTimer(1.0, Timer_VoteFail, 4);
	voteTimeout = null;
}