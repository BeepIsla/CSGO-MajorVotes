public Action:Event_Intermission(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GameRules_GetProp("m_bIsQueuedMatchmaking", 1) == 0) return Plugin_Continue;
	if (GetConVarBool(g_hDeleteBackupFiles) == false) return Plugin_Continue;

	new Handle:dirh = OpenDirectory("/");
	new String:buffer[256];
	new String:backupPrefix[64];
	GetConVarString(FindConVar("mp_backup_round_file"), backupPrefix, sizeof(backupPrefix));

	if (strlen(backupPrefix) <= 0) return Plugin_Continue; // Do not delete files if the prefix is set to nothing. We WILL delete important game files if we do this.

	while (ReadDirEntry(dirh, buffer, sizeof(buffer)))
	{
		TrimString(buffer);

		if (strncmp(buffer, backupPrefix, strlen(backupPrefix), true) == 0)
		{
			if (DirExists(buffer) == true)
			{
				continue;
			}

			DeleteFile(buffer);
		}
	}

	return Plugin_Continue;
}