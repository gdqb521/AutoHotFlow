﻿
;Here at the top there will be something like this line:
; share:=Criticalobject(1234)
;The object share contains values which are shared among this and other threads
;~ #NoTrayIcon

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%\..  ; Ensures a consistent starting directory.

SetBatchLines -1
#SingleInstance off
CoordMode,mouse,client
;FileEncoding,UTF-8
OnExit,Exit


#Persistent
#include language\language.ahk ;Must be very first
#include Lib\gdi+\gdip.ahk
#include Lib\Object to file\String-object-file.ahk
#include Lib\ObjFullyClone\ObjFullyClone.ahk

#include Source_Draw\GDIp\gdip.ahk
#include Source_Draw\API\API receiver draw.ahk

#include Source_Common\Debug\Debug.ahk
#include source_Common\Debug\Logger.ahk
#include Source_Common\Defaults\Default values.ahk

parentThread := AhkExported()

;initialize languages
lang_Init()
gdip_Init()
menu,tray, tip, Draw

SetTimer,drawTask,100

return
;Called by the main thread
;it prepares some values and starts a timer which calls UI_drawEverything()
Draw()
{
	global
	SetTimer,drawTask,10
	
}

drawTask()
{
	local temp
	local somethingdrawn
	
	
	Loop
	{
		somethingdrawn:= false
		for flowID, flowParams in _flows
		{
			if (flowParams.draw.mustDraw = true)
			{
				flowParams.draw.mustDraw := false
				gdip_DrawEverything(flowParams)
				somethingdrawn:=true
			}
			
		}
		if (somethingdrawn = false)
		{
			;~ ToolTip notdrawn
			break
		}
	}
	
}


exit_all()
{
	global
	parentThread.ahkFunction("Thread_Stopped", Global_ThisThreadID)
}


exit:
if (exiting != true)
exit_all()
exiting := true
exitapp
return