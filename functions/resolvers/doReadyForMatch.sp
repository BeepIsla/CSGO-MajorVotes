public Action:Timer_DoReadyForMatch(Handle:timer)
{
	ServerCommand("mp_warmup_pausetimer 0");
	ServerCommand("mp_warmuptime 60");
}