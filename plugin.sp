#include <sourcemod>
#include <sdktools>
#include <extendedcommandline>

#pragma semicolon 1
#pragma newdecls required

public void OnPluginStart() {
	RegAdminCmd("sm_match_reload", Command_MatchReload, ADMFLAG_CHANGEMAP);
}

public void OnMapStart() {
	char filePath[512];
	BuildPath(Path_SM, filePath, sizeof(filePath), "configs/match.vdf");

	KeyValues kv = new KeyValues("Match");
	if (!kv.ImportFromFile(filePath)) {
		LogError("Failed to find \"match.vdf\"");

		delete kv;
		return;
	}

	// Do we have a "Tournament" key in our match?
	bool isTournament = kv.JumpToKey("Tournament");
	if (isTournament) {
		int nameID = kv.GetNum("NameID", 2);
		int stageID = kv.GetNum("StageID", 4);

		char tournamentEventName[64];
		char tournamentEventStage[64];

		// Sadly only names found in the translation files will work here
		Format(tournamentEventName, sizeof(tournamentEventName), "CSGO_Tournament_Event_Name_%d", nameID);
		Format(tournamentEventStage, sizeof(tournamentEventStage), "CSGO_Tournament_Event_Stage_Display_%d", stageID);

		GameRules_SetPropString("m_szTournamentEventName", tournamentEventName);
		GameRules_SetPropString("m_szTournamentEventStage", tournamentEventStage);

		kv.GoBack();
	}

	// We don't care about the players here - Only name, flag, logo are important to us
	if (!kv.JumpToKey("Teams")) {
		LogError("Failed to find \"Teams\" data");

		delete kv;
		return;
	}

	if (!kv.GotoFirstSubKey()) {
		LogError("Failed to find first team data");

		delete kv;
		return;
	}

	// Teams
	char components[][] = {
		"Name",
		"Flag",
		"Logo"
	};

	int i = 0;
	do {
		for (int j = 0; j < sizeof(components); j++) {
			char value[64];
			if (!kv.GetString(components[j], value, sizeof(value))) {
				continue;
			}

			char convarString[64];
			Format(convarString, sizeof(convarString), "mp_team%s_%d", components[j], i + 1);

			ConVar cvar = FindConVar(convarString);
			if (cvar == null) {
				LogError("Failed to find \"%s\" convar", convarString);
				continue;
			}

			cvar.SetString(value);
		}

		i++;
	} while (kv.GotoNextKey());
}

public Action Command_MatchReload(int client, int args) {
	ConVar mmqueueCvar = FindConVar("sv_mmqueue_reservation");
	if (mmqueueCvar == null) {
		ReplyToCommand(client, "Failed to find \"sv_mmqueue_reservation\" convar");
		return Plugin_Handled;
	}
	mmqueueCvar.SetString("");

	char filePath[512];
	BuildPath(Path_SM, filePath, sizeof(filePath), "configs/match.vdf");

	KeyValues kv = new KeyValues("Match");
	if (!kv.ImportFromFile(filePath)) {
		ReplyToCommand(client, "Failed to find \"match.vdf\"");

		delete kv;
		return Plugin_Handled;
	}

	bool isTournament = kv.JumpToKey("Tournament");
	if (isTournament) {
		ExtendedCommandLine_Remove("-tournament");
		ExtendedCommandLine_Append("-tournament", "1"); // Value doesn't matter

		kv.GoBack();
	} else {
		ExtendedCommandLine_Remove("-tournament");
	}

	// We don't care about the logo, logo and flag here - Only players are important to us
	if (!kv.JumpToKey("Teams")) {
		ReplyToCommand(client, "Failed to find \"Teams\" data");

		delete kv;
		return Plugin_Handled;
	}

	// This entire thing will probably break in Danger Zone
	int players[2][5]; // 5 players per side maximum
	int playerCount[2]; // 2 teams

	if (!kv.GotoFirstSubKey()) {
		ReplyToCommand(client, "Failed to find first team data");

		delete kv;
		return Plugin_Handled;
	}

	// Teams
	int i = 0;
	do {
		if (i >= sizeof(players)) {
			ReplyToCommand(client, "Too many teams - Maximum: %d", sizeof(players));

			delete kv;
			return Plugin_Handled;
		}

		char playerString[512];
		kv.GetString("Players", playerString, sizeof(playerString), "");

		char parts[32][64];
		playerCount[i] = ExplodeString(playerString, ";", parts, sizeof(parts), sizeof(parts[]));

		for (int j = 0; j < playerCount[i]; j++) {
			players[i][j] = StringToInt(parts[j]);
		}

		char infoText[64];
		if (!kv.GetSectionName(infoText, sizeof(infoText))) {
			IntToString(i, infoText, sizeof(infoText));
		}

		ReplyToCommand(client, "Found %d players in team \"%s\"", playerCount[i], infoText);

		i++;
	} while (kv.GotoNextKey());
	kv.GoBack(); // Out of sub
	kv.GoBack(); // Out of teams

	// Spectators
	char spectatorString[512];
	kv.GetString("Spectators", spectatorString, sizeof(spectatorString), "");

	char parts[32][64];
	int partsCount = ExplodeString(spectatorString, ";", parts, sizeof(parts), sizeof(parts[]));

	// sv_mmqueue_reservation
	// -> Q // Prefix
	// -> [HEX] // AccountID hex is player
	// -> {HEX} // AccountID hex is spectator
	char mmqueueValue[512];
	Format(mmqueueValue, sizeof(mmqueueValue), "Q");

	for (int a = 0; a < sizeof(playerCount); a++) {
		for (int b = 0; b < playerCount[a]; b++) {
			Format(mmqueueValue, sizeof(mmqueueValue), "%s[%x]", mmqueueValue, players[a][b]);
		}

		// Fill empty team slots with nothingness
		for (int b = playerCount[a]; b < 5; b++) {
			Format(mmqueueValue, sizeof(mmqueueValue), "%s[%x]", mmqueueValue, 0);
		}
	}

	for (int a = 0; a < partsCount; a++) {
		Format(mmqueueValue, sizeof(mmqueueValue), "%s{%x}", mmqueueValue, StringToInt(parts[a]));
	}

	ReplyToCommand(client, "Setting \"sv_mmqueue_reservation\" to \"%s\"", mmqueueValue);
	mmqueueCvar.SetString(mmqueueValue);

	char currentMap[64];
	GetCurrentMap(currentMap, sizeof(currentMap));

	ReplyToCommand(client, "Reloading map to apply changes... Changing to \"%s\"", currentMap);
	ServerCommand("changelevel %s", currentMap);

	delete kv;
	return Plugin_Handled;
}