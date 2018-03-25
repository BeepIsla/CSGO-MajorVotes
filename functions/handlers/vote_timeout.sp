public VOTE_StartTimeoutHandler(Handle:vote, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			NativeVotes_Close(vote);
		}
		
		case MenuAction_VoteCancel:
		{
			if (param1 == VoteCancel_NoVotes)
			{
				NativeVotes_DisplayFail(vote, NativeVotesFail_NotEnoughVotes);
			}
			else
			{
				NativeVotes_DisplayFail(vote, NativeVotesFail_Generic);
			}
		}
		
		case MenuAction_VoteEnd:
		{
			if (param1 == NATIVEVOTES_VOTE_NO)
			{
				NativeVotes_DisplayFail(vote, NativeVotesFail_Loses);
			}
			else
			{
				NativeVotes_DisplayPass(vote, "#SFUI_vote_passed_timeout");
				
				if (GetClientTeam(NativeVotes_GetInitiator(vote)) == CS_TEAM_CT)
				{
					ServerCommand("timeout_ct_start");
				}
				else if (GetClientTeam(NativeVotes_GetInitiator(vote)) == CS_TEAM_T)
				{
					ServerCommand("timeout_terrorist_start");
				}
			}
		}
	}
}