public Action:Timer_DoNotReadyForMatch(Handle:timer)
{
	ServerCommand("mp_warmup_pausetimer 1");
	ServerCommand("mp_warmuptime 60");
}