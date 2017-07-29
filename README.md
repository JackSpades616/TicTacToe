With this AddOn you can play the world famous game Tic Tac Toe in World of Warcraft. You can play it in single player mode or against another player.
 
----------------------------
Commands
----------------------------

> Start the game: /ttt

> Shows help info: /ttt help

> Reset the AddOn configuration: /ttt reset

> Shows the player statistics: /ttt stats

----------------------------
GUI
----------------------------

Repeat Button:
The Repeat Button repeats in a multiplayer game the last chat message that was send. 
This will be needed if you are playing over the emote channel and your opponent has moved out of range and missed the message.

Reset Button:
The Reset Button resets only the game and the game related variables. Unlike the command "/ttt reset" this button does not reset 
the whole AddOn configuration like positioning, sizing, stats etc.

Clear Button:
In the statistic frame exists for each player a clear button. Those buttons allows you to reset the statistics for the respective player.

TextBox and Invite Button:
The TextBox in the configuration frame is used as the whisper target and also for the invite button. When you click the invite button it will send an invitation
message and the recipients name will be set to whatever is written in the text box.

Target Button:
With the Target Button you can put the name of your target into the text box. It is much more easier than tipping in the name.
 
----------------------------
Multiplayer
----------------------------

While playing multiplayer your moves will be send to the selected chat channel. Your opponent and also everybody else who can read them 
will be able to see your move in their own Tic Tac Toe interface. 
The emote channel is selected by default. You can invite other players to make setting up the game a bit more easy. 
 
----------------------------
Whisper channel
----------------------------

If you want to play with someone in whisper Mode, you only have to take the player to the target and click the target button to get the 
name of the target into the TextBox in the Config Menu and than click the invite button to start the game.
You can also enter the name of the opponent in the TextBox and invite it.
 
----------------------------
Party, Raid and Guild channels
----------------------------

You can play with someone in your party, raid or guild. So you can play Tic Tac Toe over distances. The handling is the same as in the other modes.
 
----------------------------
Singleplayer Mode
----------------------------

You can choose the single player mode by activating the single player checkbox in the configuration. If it is activated the dropdown menu below will be enabled. 
There you can choose if you want to play against yourself or against simple or medium AI. On launch it is set to medium.
We are planning to integrate a hard mode but first things first. ;)

----------------------------
Updates
----------------------------

Version 3.1.1 Beta
----------------------------
Bugfixes
>Dropdown ChatType
>>Fixed the disappearing of the Dropdown for the chat type after hard reset via command.

Changes
>Default Singleplayer
>> Set singleplayer against medium AI as default.

>Repeat Button
>> Disabled the repeat button when singleplayer mode is activated.

Version 3.1.0 Beta
----------------------------
New Features
> AI player
>> Added an AI to singleplayer.
Singleplayer has now three modes:
self (play against yourself like before)
easy (easy difficulty for AI)
medium (medium difficulty)

> Automatic reset
>> Implemented an automatic reset after a game has finished. That way you don't have to reset the game manually.
The game of the player (or AI) who made the first move will be disabled, letting the other player start the new game.

> Raid channel
>> The game can now also be played over the raid channel.

Changes
> Invitation time-out
>> Added a time-out for sent invitations. After 30 seconds the invitation will be canceled.


----------------------------
Other
----------------------------
We would like to thank Mayron, who has helped us with his tutorial videos on AddOn programming. 
If you're new to AddOn development we recommend you to watch his videos. https://www.youtube.com/channel/UCCu-NuBYVi7yokZmKBCBvHw
