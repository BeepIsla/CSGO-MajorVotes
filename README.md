# CSGO-IngameVotes v2.0

This plugin no longer requires NativeVotes!

**WARNING: I did not properly test it because I don't own a server nor have enough friends to test it with. Please try it out and report back to me. Preferrably on Discord (Felix#2343)**

Info: "m_bIsQueuedMatchmaking" forcefully disables the teammenu so you might have to create your own work around or teammanager

Using the settings "m_szTournamentEventName" and "m_bIsQueuedMatchmaking" you can create major-similar matches that use the ingame voting system. You still have to handle the votes yourself, using NativeVotes for example, like I do in this example plugin.

[Example how the vote menu looks like 1](https://cdn.discordapp.com/attachments/426980696809144321/427424569087885332/Unbenannt.PNG)

[Example how the vote menu looks like 2](https://cdn.discordapp.com/attachments/426980696809144321/427424570518142976/Unbenannt2.PNG)

#Changelog:

- Removed the requirement for NativeVotes
- Votes are now fully handled by the plugin itself