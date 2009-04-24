#include <sourcemod>
#include <sdktools>

#define MAX_PLAYERS 256

new Handle:DisplayTimers[MAX_PLAYERS+1]
new Handle:cvar_DispHPInterval;
new Float:DispHPInterval;

public Plugin:myinfo = 
{
	name = "Display team HP list",
	author = "withgod",
	description = "add display team HP list command",
	version = "1.0.0",
	url = "http://fps.withgod.jp/"
}

public OnPluginStart()
{
	RegAdminCmd("sm_dispHP", Command_DispHP, ADMFLAG_SLAY);
	cvar_DispHPInterval = CreateConVar("sm_dispHP_interval", "3.0", "display interval", _, true, 1.0, true, 10.0);
}

public OnMapEnd()
{
	new i = 1;
	for (i = 1; i < MAX_PLAYERS; i++)
	{
		if (DisplayTimers[i] != INVALID_HANDLE)
		{
			KillTimer(DisplayTimers[i]);
			DisplayTimers[i] = INVALID_HANDLE;
		}
	}
}

public OnClientDisconnect(client)
{
	if (DisplayTimers[client] != INVALID_HANDLE)
	{
		KillTimer(DisplayTimers[client]);
		DisplayTimers[client] = INVALID_HANDLE;
	}
}

public Action:Command_DispHP(client, args)
{
	if (GetClientTeam(client) == 1)
	{
		DispHPInterval = GetConVarFloat(cvar_DispHPInterval);
		DispMenu(client);
		DisplayTimers[client] = CreateTimer(DispHPInterval, DispMenuTimer, client, TIMER_REPEAT);
	}
	else
	{
		PrintToChat(client, "this command spectator only");
	}
	return Plugin_Handled;
}


public MenuHandler(Handle:menu, MenuAction:action, client, item)
{
	if (item == 10)
	{
		if (DisplayTimers[client] != INVALID_HANDLE)
		{
			KillTimer(DisplayTimers[client]);
			DisplayTimers[client] = INVALID_HANDLE;
		}
	}
}

public Action:DispMenuTimer(Handle:timer, any:client)
{
	
	if (GetClientTeam(client) == 1) 
	{
		DispMenu(client);
	} 
	else
	{
		KillTimer(DisplayTimers[client]);
	}
	return Plugin_Continue;
}

//team id
//spec = 1
//red  = 2
//blue = 3
public DispPanel(Handle:panel, team)
{
	new i = 1;
	new max = GetClientCount();
	//PrintToChatAll("%d", max);
	new String:msg[256];
	for (i = 1; i <= max; i++)
	{
		//PrintToChatAll("xxxxxx[[[%d]]]]", GetClientTeam(i));
		if (GetClientTeam(i) == team)
		{
			new hp, maxHp;
			new String:uname[128];
			hp = GetClientHealth(i);
			maxHp = GetEntProp(i, Prop_Data,"m_iMaxHealth");
			GetClientName(i, uname, 128);
			//Format(msg, sizeof(msg), "%d/%d    %s", hp, maxHp, uname);
			//PrintToChatAll("%d/%d    %s", hp, maxHp, uname);
			//PrintToChatAll(msg);

			if (!IsPlayerAlive(i))
			{ //dead player life 1 fix
				hp = 0;
			}

			Format(msg, sizeof(msg), "%03d/%03d %s", hp, maxHp, uname);

			DrawPanelText(panel, msg);
		}
	}
}

public DispMenu(client)
{
	new Handle:cvar_TeamName[2];
	new String:TeamName[2][128];
	new ScoreRed;
	new ScoreBlue;
	decl String:ctime[64];
	new String:TeamNameDsp[256];
	FormatTime(ctime, 64, "%Y/%m/%d %H:%M:%S");
	
	cvar_TeamName[0] = FindConVar("mp_tournament_redteamname");
	GetConVarString(cvar_TeamName[0], TeamName[0], 128);
	cvar_TeamName[1] = FindConVar("mp_tournament_blueteamname");
	GetConVarString(cvar_TeamName[1], TeamName[1], 128);
	
	new Handle:cpanel = CreatePanel();
	SetPanelTitle(cpanel, "Red/Blue HP Display");
	DrawPanelText(cpanel, ctime);
	
	ScoreRed = GetTeamScore(2);
	Format(TeamNameDsp, sizeof(TeamNameDsp), "Red[%d][%s]", ScoreRed, TeamName[0]);
	DrawPanelText(cpanel, TeamNameDsp);
	DispPanel(cpanel, 2);
	ScoreBlue = GetTeamScore(3);
	Format(TeamNameDsp, sizeof(TeamNameDsp), "Blu[%d][%s]", ScoreBlue, TeamName[1]);
	DrawPanelText(cpanel, TeamNameDsp);
	DispPanel(cpanel, 3);
	
	
	DrawPanelText(cpanel, " ");
	DrawPanelItem(cpanel, " ", ITEMDRAW_NOTEXT);// skip 1-9 items
	DrawPanelItem(cpanel, " ", ITEMDRAW_NOTEXT);
	DrawPanelItem(cpanel, " ", ITEMDRAW_NOTEXT);
	DrawPanelItem(cpanel, " ", ITEMDRAW_NOTEXT);
	DrawPanelItem(cpanel, " ", ITEMDRAW_NOTEXT);
	DrawPanelItem(cpanel, " ", ITEMDRAW_NOTEXT);
	DrawPanelItem(cpanel, " ", ITEMDRAW_NOTEXT);
	DrawPanelItem(cpanel, " ", ITEMDRAW_NOTEXT);
	DrawPanelItem(cpanel, " ", ITEMDRAW_NOTEXT);
	DrawPanelItem(cpanel, "exit", ITEMDRAW_CONTROL);
	SendPanelToClient(cpanel, client, MenuHandler, 30);
	CloseHandle(cpanel);
}