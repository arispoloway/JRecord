#include <sourcemod>
#include <sdktools>


new clientRecording;
new Handle:outputFile;


public Plugin:myinfo = {
	name = "JRecord",
	author = "talkingmelon",
	description = "Records to csv",
	version = ".1",
	url = "http://www.tf2rj.com"
};



public OnPluginStart(){

	RegConsoleCmd("sm_rec", Command_Record, "Records");
	RegConsoleCmd("sm_st", Command_StopRecord, "Stops");
	RegConsoleCmd("sm_tog", Command_ToggleRecord, "Stops");

}

public Action:Command_Record(client, args){
	clientRecording = client;

	decl String:path[PLATFORM_MAX_PATH];
	decl String:dateTime[1024];
	new time = GetTime();
	FormatTime(dateTime, sizeof(dateTime), "%y%m%d_%H%M%S", time);
	BuildPath(Path_SM,path,PLATFORM_MAX_PATH,"REC %s.csv", dateTime);
	PrintToChat(client,path);
	outputFile = OpenFile(path, "w+");

	if(outputFile == INVALID_HANDLE){
		PrintToChat(client, "An error occured while creating the file");
		clientRecording = 0;
	}else{
		WriteFileString(outputFile, "xloc,yloc,zloc,xvel,yvel,zvel,pitch,yaw,roll,attack,jump,duck\n", false);
	}
}


public Action:Command_StopRecord(client, args){
	clientRecording = 0;
	if(outputFile !=  INVALID_HANDLE){
		CloseHandle(outputFile);
	}
	PrintToChat(client, "Stopped Recording");
}

public Action:Command_ToggleRecord(client, args){
	if(clientRecording){
		Command_StopRecord(client, 0);
	}else{
		Command_Record(client, 0);
	}
}


public OnGameFrame(){
	if(clientRecording){
		decl Float:a[3];
		decl Float:v[3];
		decl Float:l[3];

		decl b;
		new bool:at, bool:j, bool:d;

		GetEntPropVector(clientRecording, Prop_Data, "m_vecOrigin", l);
		GetClientEyeAngles(clientRecording, a);
		GetEntPropVector(clientRecording, Prop_Data, "m_vecVelocity", v);

		b = GetClientButtons(clientRecording);
		if(b & IN_ATTACK){
			at=true;
		}
		if(b & IN_JUMP){
			j=true;
		}
		if(b & IN_DUCK){
			d=true;
		}

		new String:buttonBuffer[16];
		if(at){
			Format(buttonBuffer, sizeof(buttonBuffer), "1,", buttonBuffer);
		}else{
			Format(buttonBuffer, sizeof(buttonBuffer), "0,", buttonBuffer);
		}
		if(j){
			Format(buttonBuffer, sizeof(buttonBuffer), "%s1,", buttonBuffer);
		}else{
			Format(buttonBuffer, sizeof(buttonBuffer), "%s0,", buttonBuffer);
		}
		if(d){
			Format(buttonBuffer, sizeof(buttonBuffer), "%s1", buttonBuffer);
		}else{
			Format(buttonBuffer, sizeof(buttonBuffer), "%s0", buttonBuffer);
		}


		new String:buffer[512];
		Format(buffer, sizeof(buffer), "%f,%f,%f,%f,%f,%f,%f,%f,%f,%s\n", l[0],l[1],l[2],v[0],v[1],v[2],a[0],a[1],a[2], buttonBuffer);

		WriteFileString(outputFile, buffer, false);


	}
}
