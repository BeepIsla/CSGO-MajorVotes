public Action:Timer_DoLoadBackup(Handle:timer)
{
	ServerCommand("mp_backup_restore_load_file %s", passDetailsString);
}