#include <a_samp>
#include <zcmd>

#define MAX_DAMAGE_LOGS 50

enum e_damage_log {
	Float:damage,
	weaponid,
	bodypart,
	issuerid,
	logtime
};

new PlayerDamageLogs[MAX_PLAYERS][MAX_DAMAGE_LOGS][e_damage_log];
new PlayerDamageCount[MAX_PLAYERS];

forward SaveDamageLog(playerid, Float:amount, weapon, bodypart, issuer);
public SaveDamageLog(playerid, Float:amount, weapon, bodypart, issuer)
{
	new idx = PlayerDamageCount[playerid];
	
	if(idx >= MAX_DAMAGE_LOGS)
	{
		for(new i = 0; i < MAX_DAMAGE_LOGS - 1; i++)
		{
			PlayerDamageLogs[playerid][i][damage]   = PlayerDamageLogs[playerid][i+1][damage];
			PlayerDamageLogs[playerid][i][weaponid] = PlayerDamageLogs[playerid][i+1][weaponid];
			PlayerDamageLogs[playerid][i][bodypart] = PlayerDamageLogs[playerid][i+1][bodypart];
			PlayerDamageLogs[playerid][i][issuerid] = PlayerDamageLogs[playerid][i+1][issuerid];
			PlayerDamageLogs[playerid][i][logtime]  = PlayerDamageLogs[playerid][i+1][logtime];
		}
		idx = MAX_DAMAGE_LOGS - 1;
	}
	else PlayerDamageCount[playerid]++;

	PlayerDamageLogs[playerid][idx][damage]   = amount;
	PlayerDamageLogs[playerid][idx][weaponid] = weapon;
	PlayerDamageLogs[playerid][idx][bodypart] = bodypart;
	PlayerDamageLogs[playerid][idx][issuerid] = issuer;
	PlayerDamageLogs[playerid][idx][logtime]  = gettime();
	
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	SetTimerEx("SaveDamageLog", 100, 0, "dffdd", playerid, amount, weaponid, bodypart, issuerid);
	return 1;
}

new const g_szWeapons[47][] = 
{
	"Fist", "Brass Knuckles", "Golf Club", "Nightstick", "Knife", "Baseball Bat", "Shovel", "Pool Cue", "Katana", "Chainsaw",
	"Dildo", "Dildo", "Vibrator", "Vibrator", "Flowers", "Cane", "Grenade", "Teargas", "Molotov", "Vehicle",
	"Vehicle", "Vehicle", "Colt 45", "Silenced Pistol", "Deagle", "Shotgun", "Sawnoff", "SPAS12", "Micro UZI",
	"MP5", "AK47", "M4", "TEC9", "Rifle", "Sniper", "RPG", "Heat Seeker", "Flamethrower",
	"Minigun", "Satchel", "Detonator", "Spraycan", "Extinguisher", "Camera", "NV Goggles", "IR Goggles", "Parachute"
};

new const g_szBodyparts[10][] = 
{
	"Unknown", "Unknown", "Unknown", 
	"Torso", "Groin", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Head"
};

CMD:dlog(playerid, params[])
{
	new str[1024], tmp[128], timebuf[32], attacker[24];
	
	format(str, sizeof(str), "attacker\tweapon\tbody\ttime");
	
	if(PlayerDamageCount[playerid] == 0)
	{
		strcat(str, "\n-\t-\t-\t-");
	}
	else
	{
		for(new i = PlayerDamageCount[playerid] - 1; i >= 0; i--)
		{
			new issuer = PlayerDamageLogs[playerid][i][issuerid];
			
			if(issuer == INVALID_PLAYER_ID) format(attacker, sizeof(attacker), "World");
			else if(issuer == playerid) format(attacker, sizeof(attacker), "Self");
			else if(!IsPlayerConnected(issuer)) format(attacker, sizeof(attacker), "Offline");
			else GetPlayerName(issuer, attacker, sizeof(attacker));
			
			new t = PlayerDamageLogs[playerid][i][logtime];
			format(timebuf, sizeof(timebuf), "%02d:%02d:%02d", (t / 3600) % 24, (t / 60) % 60, t % 60);
			
			format(tmp, sizeof(tmp), "\n%s\t%s\t%s\t%s",
				attacker,
				g_szWeapons[PlayerDamageLogs[playerid][i][weaponid]],
				g_szBodyparts[PlayerDamageLogs[playerid][i][bodypart]],
				timebuf
			);
			
			strcat(str, tmp);
		}
	}
	
	ShowPlayerDialog(playerid, 1337, DIALOG_STYLE_TABLIST_HEADERS, "Damage Logs", str, "Close", "");
	return 1;
}
