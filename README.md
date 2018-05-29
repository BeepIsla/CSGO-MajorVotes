# CSGO-IngameVotes v2.0

**WARNING: I did not properly test it because I don't own a server nor have enough friends to test it with. Please try it out and report back to me. Preferrably on Discord (Felix#2343)**

Info: "m_bIsQueuedMatchmaking" forcefully disables the teammenu so you might have to create your own work around or teammanager

Using the settings "m_szTournamentEventName" and "m_bIsQueuedMatchmaking" you can create major-similar matches that use the ingame voting system. You still have to handle the votes yourself, using NativeVotes for example, like I do in this example plugin.

[Example how the vote menu looks like 1](https://cdn.discordapp.com/attachments/426980696809144321/427424569087885332/Unbenannt.PNG)

[Example how the vote menu looks like 2](https://cdn.discordapp.com/attachments/426980696809144321/427424570518142976/Unbenannt2.PNG)

# Full explanation to what this plugin all does:
This plugin listens to the "callvote" command which is automatically executed when you press a option on the vote menu. It then fiddles around with the vote_controller and [UserMessages](https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_UserMessages) to create a vote on the left side of your screen. The plugin also listens to the "vote" command. It is execute when you press F1 or F2 to vote, the command is ONLY executed if a vote actually exists. After every successful vote the plugin checks if there are enough Yes/No votes and if a quorum ratio is fulfilled. Some of the votes only require 1 vote to succeed. Some require all 10 players. That was not possible with [NativeVotes](https://forums.alliedmods.net/showthread.php?t=208008) so I had to figure out how votes in CSGO work to try and re-create it.

If a vote passes or fails the plugin again fiddles around with the vote_controller and [UserMessages](https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_UserMessages) to make the "Vote Passed" or "Vote Failed" screen appear. If a vote passes it checks the type of the vote we called and then does what the vote wants it to do. Eg: We vote to pause the match and if it succeeds the plugin executes "mp_pause_match" to pause the match. If a vote fails it just displays it and does nothing.

The plugin also listens to "listissues". It is a command for clients only which lists all the possible votes. Due to CSGO being kinda weird the original list of issues (votes) is wrong, it lists for example "callvote changelevel <mapname>" even if the issue is disabled via the available ingame commands. It also doesn't list the custom ones I added (They are not really custom but the game kinda gets tricked. Its a bit awkward) so basically the plugin overrides the original list of issues with a custom list I made with the plugin.

# Changelog:

**Known bugs:**
- If a team surrenders at the right time during the halftime screen will cause a surrender for the enemy team
- Some votes show for everyone even tho only the caller should see them
- Making a timeout at the right time during the halftime screen will cause a timeout for the enemy team
- Votes never time out and last for a infinite amount of time
- Stopping the warmup countdown causes a "Trying to resolve a vote that is not a YES/NO vote, YES/NO votes aren't currently supported!" error in the server console

**2.0:**
- Removed the requirement for NativeVotes
- Votes are now fully handled by the plugin itself
