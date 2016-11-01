﻿AllBuiltInVars:="-A_Space-A_Tab-A_YYYY-A_Year-A_MM-A_Mon-A_DD-A_MDay-A_MMMM-A_MMM-A_DDDD-A_DDD-A_WDay-A_YDay-A_Hour-A_Min-A_Sec-A_MSec-A_TickCount-A_TimeIdle-A_TimeIdlePhysical-A_Temp-A_OSVersion-A_Is64bitOS-A_PtrSize-A_Language-A_ComputerName-A_UserName-A_ScriptDir-A_WinDir-A_ProgramFiles-A_AppData-A_AppDataCommon-A_Desktop-A_DesktopCommon-A_StartMenu-A_StartMenuCommon-A_Programs-A_ProgramsCommon-A_Startup-A_StartupCommon-A_MyDocuments-A_IsAdmin-A_ScreenWidth-A_ScreenHeight-A_ScreenDPI-A_IPAddress1-A_IPAddress2-A_IPAddress3-A_IPAddress4-A_Cursor-A_CaretX-A_CaretY-----" ;a_now and a_nowutc not included, they will be treated specially

ThreadVariable_Set(Environment,p_Name,p_Value,p_ContentType="Normal")
{
	Environment.threadvars[p_Name]:={name:p_Name,value:p_Value,type:p_ContentType}
	
}
LoopVariable_Set(Environment,p_Name,p_Value,p_ContentType="Normal")
{
	Environment.loopvars[p_Name]:={name:p_Name,value:p_Value,type:p_ContentType}
}
InstanceVariable_Set(Environment,p_Name,p_Value,p_ContentType="Normal")
{
	global _execution
	;~ d(p_Value,"set variable " p_Name)
	;~ d(environment,"set variable environment")
	_execution.instances[Environment.InstanceID].InstanceVars[p_Name]:={name:p_Name,value:p_Value,type:p_ContentType}
	;~ d(_execution.instances[Environment.InstanceID].InstanceVars,"set variable " p_Name ". instance " Environment.InstanceID)
	
}

StaticVariable_Set(Environment,p_Name,p_Value,p_ContentType="Normal")
{
	;~ Lock(global_CriticalSectionGlobalVars)
	;~ allThreads[p_thread].loopvars[p_Name]:=CriticalObject({name=p_Name,value=p_Value,type=p_ContentType})
	
	;~ UnLock(global_CriticalSectionGlobalVars)
}
GlobalVariable_Set(Environment,p_Name,p_Value,p_ContentType="Normal")
{
	;~ Lock(global_CriticalSectionGlobalVars)
	;~ allThreads[p_thread].loopvars[p_Name]:=CriticalObject({name=p_Name,value=p_Value,type=p_ContentType})
	;~ UnLock(global_CriticalSectionGlobalVars)
}


Var_RetrieveDestination(p_Name,p_Location,p_log=true)
{
	if (substr(p_Name,1,2)="A_") ;If variable name begins with A_
	{
		if (p_Location!="Thread" and p_Location!="loop")
		{
			if (p_log=true or p_log="LOG")
				logger("f0","Setting built in variable '" p_Name "' failed. No permission given.")
			return ;No result
		}
		else ;The variable is either a thread variable or a loop variable
			return p_Location
	}
	else if (p_Location="Thread" or p_Location="loop")
	{
		if (p_log=true or p_log="LOG")
			logger("f0","Setting built in variable '" p_Name "' failed. It does not start with 'A_'.")
		return ;No result
		
	}
	else if (substr(p_Name,1,7)="global_")  ;If variable is global
	{
		return "global"
	}
	else if (substr(p_Name,1,7)="static_") ;If variable is static
	{
		return "static"
	}
	else
	{
		return "instance"
	}
	
	
}

Var_Set(environment, p_Name, p_Value, p_Type, p_Destination="")
{
	global _execution
	res:=Var_CheckName(p_Name,true)
	if (res="empty")
	{
		if (p_log=true or p_log="LOG")
			logger("f0","Setting a variable failed. Its name is empty.")
		return ;No result
	}
	else if (res="ForbiddenCharacter")
	{
		if (p_log=true or p_log="LOG")
			logger("f0","Setting variable '" p_Name "' failed. It contains forbidden characters.")
		return ;No result
	}
	
	if (p_Destination="")
		destination:=Var_RetrieveDestination(p_Name,p_Destination,"LOG")
	else
		destination:=p_Destination
	if (destination!="")
	{
		%destination%Variable_Set(environment,p_Name,p_Value,p_Type)
	}
	else
	{
		logger("f0","Setting variable '" p_Name "' failed. Cannot retrieve destination.")
	}
	;~ d(_execution.instances[Environment.InstanceID].InstanceVars,"instance vars set " p_Name)
}

Var_Get(environment, p_Name, p_Type)
{
	global _execution
	tempvalue=
	if (p_Name="")
	{
		logger("f0","Retrieving variable failed. The name is empty")
	}
	else if (substr(p_Name,1,2)="A_") ; if variable is a built in variable or a thread variable
	{
		;~ MsgBox asfh  %name%
		if (Environment.threadvars.HasKey(p_Name)) ;Try to find a thread variable
		{
			logger("f3","Retrieving thread variable '" p_Name "'")
			tempvalue:=Environment.threadvars[p_Name].value
			;~ MsgBox ag e %tempvalue%
			return tempvalue
		}
		else if (Environment.loopvars.HasKey(p_Name)) ;Try to find a loop variable
		{
			logger("f3","Retrieving loop variable '" p_Name "'")
			tempvalue:=Environment.loopvars[p_Name].value
			return tempvalue
		}
		;If no thread and loop variable found, try to find a built in variable
		else if (p_Name="a_now" || p_Name="A_NowUTC")
		{
			if (p_Type!="Date")
			{
				tempvalue:=Var_ConvertType(p_Name,"date",p_Type)
				
				return tempvalue
			}
			else
			{
				tempvalue:=%p_Name%
				;~ MsgBox %tempvalue%
				return tempvalue
			}
		}
		else if (p_Name="A_YWeek") ;Separate the week.
		{
			StringRight,tempvalue,A_YWeek,2
			return tempvalue
		}
		else if (p_Name="A_LanguageName") 
		{
			tempvalue:= ;GetLanguageNameFromCode(A_Language) ;;TODO: Uncomment
			
			return tempvalue
		}
		else if (p_Name="a_workingdir")
		{
			;~ tempvalue:=flowSettings.WorkingDir
			return tempvalue
		}
		;~ else if (name="a_triggertime")
		;~ {
			;~ tempvalue:=Instance_%InstanceID%_Thread_%ThreadID%_Variables[name] 
			;~ if p_Type=Normal
				;~ return this.convertVariable(tempvalue,"date","`n") 
			;~ else
			;~ {
				;~ return tempvalue
			;~ }
		;~ }
		else if (p_Name="a_linefeed" or p_Name="a_lf")
		{
			return "`n"
		}
		;~ else if (p_Name="a_CPULoad")
		;~ {
			;~ return CPULoad()
		;~ }
		;~ else if (p_Name="a_MemoryUsage")
		;~ {
			;~ return MemoryLoad()
		;~ }
		;~ else if (p_Name="a_OSInstallDate")
		;~ {
			;~ if p_Type=Normal
				;~ return convertVariable(OSInstallDate(),"date","`n") 
			;~ else
			;~ {
				;~ return OSInstallDate()
			;~ }
		;~ }
		else If InStr(this.AllBuiltInVars,"-" p_Name "-")
		{
			tempvalue:=%p_Name%
			return tempvalue
		}
		else
		{
			logger("f0","Retrieving variable '" p_Name "' failed. It does not exist")
		}
			
			
	}
	else if (substr(p_Name,1,7)="global_") ; if variable is a global variable
	{
		return tempvalue
	}
	else if (substr(p_Name,1,7)="static_") ; if variable is a static variable
	{
		return tempvalue
	}
	else ;If this is a instance variable
	{
		;~ d(_execution.instances[Environment.InstanceID].InstanceVars,"instance vars" p_Name)
		if (_execution.instances[Environment.InstanceID].InstanceVars.HasKey(p_Name)) ;Try to find a instance variable
		{
			logger("f3","Retrieving instance variable '" p_Name "'")
			tempvalue:=_execution.instances[Environment.InstanceID].InstanceVars[p_Name].value
			;TODO, convert type if necessary
			;~ MsgBox ag e %tempvalue% - %name%
			return tempvalue
		}
		else
		{
			logger("f0","Retrieving instance variable '" p_Name "' failed. It does not exist")
		}
	}
}


Var_ConvertType(p_Value,p_Contenttype,p_TargetType)
{
	if (p_TargetType="normal")
	{
		if (p_Contenttype="date")
		{
			FormatTime,result,% p_Value
		}
		else if (p_Contenttype="list")
		{
			if IsObject(p_Value)
				result:=strobj(p_Value)
			else
				result:= p_Value
			
		}
	}
	
	return result
}

Var_CheckName(p_Name, tellWhy=false) ;Return 1 if valid. 0 if not
{
	;Check whether the variable name is not empty
	if p_Name=
	{
		;~ logger("f0","Setting a variable failed. Its name is empty.")
		if tellWhy
			return "Empty"
		else
			return 0
	}
	;Check whether the variable name is valid and has no prohibited characters
	try
		asdf%p_Name%:=1 
	catch
	{
		;~ logger("f0","Setting variable '" p_Name "' failed. Name is invalid.")
		if tellWhy
			return "ForbiddenCharacter"
		else
			return 0
	}
	if tellWhy
		return "OK"
	else
		return 1
}



Var_replaceVariables(environment, p_String, p_ContentType = "AsIs")
{
	tempstring:=p_String
	;~ d(environment, "replace variables: " p_String )
	Loop
	{
		tempFoundPos:=RegExMatch(tempstring, "SU).*%(.+)%.*", tempFoundVarName)
		if tempFoundPos=0
			break
		StringReplace,tempstring,tempstring,`%%tempFoundVarName1%`%,% Var_Get(environment,tempFoundVarName1,p_ContentType)
		;~ MsgBox % "reerhes#-" tempstring "-#-" tempFoundVarName1 "-#-" Variable_Get(p_thread,tempFoundVarName1,p_ContentType)
		;~ MsgBox %tempVariablesToReplace1%
	}
	;~ d(environment, "replace variables result: " tempstring )
	return tempstring 
	
}
