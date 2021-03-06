﻿iniAllActions.="Add_to_list|" ;Add this action to list of all actions on initialisation

runActionAdd_to_list(InstanceID,ThreadID,ElementID,ElementIDInInstance)
{
	global
	local temp
	local varvalue
	local varvalues
	local Varname:=v_replaceVariables(InstanceID,ThreadID,%ElementID%Varname)
	local Position:=v_replaceVariables(InstanceID,ThreadID,%ElementID%Position)
	
	if not v_CheckVariableName(varname)
	{
		logger("f0","Instance " InstanceID " - " %ElementID%type " '" %ElementID%name "': Error! List name '" varname "' is not valid")
		MarkThatElementHasFinishedRunning(InstanceID,ThreadID,ElementID,ElementIDInInstance,"exception",lang("%1% is not valid",lang("List name '%1%'",varname)) )
		return
	}
	
	
	
	local tempObject:=v_getVariable(InstanceID,ThreadID,Varname,"list")
	
	
	if (!(IsObject(tempObject)))
	{
		if tempObject=
		{
			logger("f0","Instance " InstanceID " - " %ElementID%type " '" %ElementID%name "': Waring! Variable '" Varname "' is empty. A new list will be created.")
			tempObject:=Object()
		}
		else
		{
			logger("f0","Instance " InstanceID " - " %ElementID%type " '" %ElementID%name "': Error! Variable '" Varname "' is not empty and does not contain a list.")
			MarkThatElementHasFinishedRunning(InstanceID,ThreadID,ElementID,ElementIDInInstance,"exception",lang("Variable '%1%' is not empty and does not contain a list.",Varname))
			return
		}
	}
	
	if (%ElementID%NumberOfElements=1) ;Add one element
	{
		varvalue:=v_replaceVariables(InstanceID,ThreadID,%ElementID%varvalue)
		
		if %ElementID%isExpression=1
			temp:=v_replaceVariables(InstanceID,ThreadID,%ElementID%VarValue)
		else
			temp:=v_EvaluateExpression(InstanceID,ThreadID,%ElementID%VarValue)
		
		if %ElementID%WhitchPosition=1 ;Stupid misspelling :-(
		{
			tempObject.insert(1,temp)
		}
		else if %ElementID%WhitchPosition=2
		{
			tempObject.insert(temp)
		}
		else
		{
			if Position=
			{
				logger("f0","Instance " InstanceID " - " %ElementID%type " '" %ElementID%name "': Error! Position is not specified.")
				MarkThatElementHasFinishedRunning(InstanceID,ThreadID,ElementID,ElementIDInInstance,"exception",lang("%1% is empty.",lang("Position")))
				return
			}
			tempObject.insert(Position,temp)
		}
	}
	else ;Add multiple elements
	{
		varvalues:=v_replaceVariables(InstanceID,ThreadID,%ElementID%varvalues)
		
		if %ElementID%DelimiterLinefeed
			StringReplace,varvalues,varvalues,`n,▬,all
		if %ElementID%DelimiterComma
			StringReplace,varvalues,varvalues,`,,▬,all
		if %ElementID%DelimiterSemicolon
			StringReplace,varvalues,varvalues,;,▬,all
		if %ElementID%DelimiterSpace
			StringReplace,varvalues,varvalues,%A_Space%,▬,all
		
		if %ElementID%WhitchPosition=1
		{
			loop,parse,varvalues,▬
			{
				tempObject.Insert(A_Index,A_LoopField)
			}
		}
		else if %ElementID%WhitchPosition=2
		{
			loop,parse,varvalues,▬
			{
				tempObject.Insert(A_LoopField)
			}
		}
		else if %ElementID%WhitchPosition=3
		{
			if Position=
			{
				logger("f0","Instance " InstanceID " - " %ElementID%type " '" %ElementID%name "': Error! Position is not specified.")
				MarkThatElementHasFinishedRunning(InstanceID,ThreadID,ElementID,ElementIDInInstance,"exception",lang("%1% is not specified.",lang("Position")))
				return
			}
			Position--
			loop,parse,varvalues,▬
			{
				tempObject.Insert(Position+A_Index,A_LoopField)
			}
		}
	}
	v_SetVariable(InstanceID,ThreadID,Varname,tempObject,"list")
	
	MarkThatElementHasFinishedRunning(InstanceID,ThreadID,ElementID,ElementIDInInstance,"normal")
	

	

	return
}
getNameActionAdd_to_list()
{
	return lang("Add_to_list")
}
getCategoryActionAdd_to_list()
{
	return lang("Variable")
}

getParametersActionAdd_to_list()
{
	global
	parametersToEdit:=Object()
	parametersToEdit.push({type: "Label", label: lang("List variable name")})
	parametersToEdit.push({type: "Edit", id: "Varname", default: "List", content: "VariableName", WarnIfEmpty: true})
	parametersToEdit.push({type: "Label", label: lang("Number of elements")})
	parametersToEdit.push({type: "Radio", id: "NumberOfElements", default: 1, choices: [lang("Add one element"), lang("Add multiple elements")]})
	parametersToEdit.push({type: "Label", label: lang("Content to add")})
	parametersToEdit.push({type: "Radio", id: "isExpression", default: 1, choices: [lang("This is a value"), lang("This is a variable name or expression")]})
	parametersToEdit.push({type: "Edit", id: "VarValue", default: "New element", content: "StringOrExpression", contentParID: "isExpression", WarnIfEmpty: true})
	parametersToEdit.push({type: "Edit", id: "VarValues", default: "Added Element 1`nAdded Element 2", multiline: true, content: "String", WarnIfEmpty: true})
	parametersToEdit.push({type: "Checkbox", id: "DelimiterLinefeed", default: 1, label: lang("Use linefeed as delimiter")})
	parametersToEdit.push({type: "Checkbox", id: "DelimiterComma", default: 0, label: lang("Use comma as delimiter")})
	parametersToEdit.push({type: "Checkbox", id: "DelimiterSemicolon", default: 0, label: lang("Use semicolon as delimiter")})
	parametersToEdit.push({type: "Checkbox", id: "DelimiterSpace", default: 0, label: lang("Use space as delimiter")})
	parametersToEdit.push({type: "Label", label: lang("Where to insert")})
	parametersToEdit.push({type: "Radio", id: "WhitchPosition", default: 2, choices: [lang("First position"), lang("Last position"), lang("Following position or key")]})
	parametersToEdit.push({type: "edit", id: "Position", default: 2, content: "Expression", WarnIfEmpty: true})

	
	return parametersToEdit
}

GenerateNameActionAdd_to_list(ID)
{
	global
	local text
	
	if GUISettingsOfElement%ID%NumberOfElements1=1
	{
		Text.= lang("Add to list") " " GUISettingsOfElement%ID%Varname ": " GUISettingsOfElement%ID%VarValue
	}
	else if GUISettingsOfElement%ID%NumberOfElements2=1
	{
		Text.= lang("Add to list") " " GUISettingsOfElement%ID%Varname ": " GUISettingsOfElement%ID%VarValues
		
	}
	
	
	return Text
	
}

CheckSettingsActionAdd_to_list(ID)
{
	global
	
	if (GUISettingsOfElement%ID%NumberOfElements1 = 1) ;one element
	{
		GuiControl,Enable,GUISettingsOfElement%ID%isExpression1
		GuiControl,Enable,GUISettingsOfElement%ID%isExpression2
		GuiControl,Enable,GUISettingsOfElement%ID%VarValue
		GuiControl,Disable,GUISettingsOfElement%ID%VarValues
		GuiControl,Disable,GUISettingsOfElement%ID%DelimiterLinefeed
		GuiControl,Disable,GUISettingsOfElement%ID%DelimiterComma
		GuiControl,Disable,GUISettingsOfElement%ID%DelimiterSemicolon
		GuiControl,Disable,GUISettingsOfElement%ID%DelimiterSpace
		GuiControl,,GUISettingsOfElement%ID%WhitchPosition3,% lang("Following position or key")
	}
	else ;Multiple elements
	{
		GuiControl,Disable,GUISettingsOfElement%ID%isExpression1
		GuiControl,Disable,GUISettingsOfElement%ID%isExpression2
		GuiControl,Disable,GUISettingsOfElement%ID%VarValue
		GuiControl,Enable,GUISettingsOfElement%ID%VarValues
		GuiControl,Enable,GUISettingsOfElement%ID%DelimiterLinefeed
		GuiControl,Enable,GUISettingsOfElement%ID%DelimiterComma
		GuiControl,Enable,GUISettingsOfElement%ID%DelimiterSemicolon
		GuiControl,Enable,GUISettingsOfElement%ID%DelimiterSpace
		GuiControl,,GUISettingsOfElement%ID%WhitchPosition3,% lang("Following position")
	}
	
	
	if (GUISettingsOfElement%ID%WhitchPosition3 = 1)
	{
		GuiControl,Enable,GUISettingsOfElement%ID%Position
	}
	else
	{
		GuiControl,Disable,GUISettingsOfElement%ID%Position
	}
	
	
}