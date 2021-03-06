﻿;#include v_variables.ahk ;only include for testing
if (!NoTests) ;Test mode when executing this script directly
{
	InstanceID=5
	TrheadID=1
	Instance_%InstanceID%_LocalVariables:=Object()
	v_setVariable(InstanceID,TrheadID,"kontostand",5000)
	v_setVariable(InstanceID,TrheadID,"schulden",4000)
	;MsgBox % "Gesetzte Variablen:`nkonstostand: " v_getVariable(InstanceID,"kontostand") "`nschulden: " v_getVariable(InstanceID,"schulden")
	
	;teststring=((4+5)*2)*(3+1-(2+1))
	;teststring=% "2<=1"
	;teststring=% "!(var1 < 10) and !0"
	;teststring=% "kontostand - schulden"
	teststring=% "2+ 3/4 + 5"
	
	MsgBox I am starting
	res:=v_EvaluateExpression(InstanceID,TrheadID,teststring)
	MsgBox % "Result of " teststring " is " res 
}

/* Evaluation of an Expression
*/
v_EvaluateExpression(InstanceID,ThreadID,ExpressionString)
{
	logger("f3","Evaluating expression " ExpressionString)
	v_replaceVariables(InstanceID,ThreadID,ExpressionString)
	ExpressionString:=A_Space ExpressionString A_Space
	StringReplace,ExpressionString,ExpressionString,>=,≥,all
	StringReplace,ExpressionString,ExpressionString,<=,≤,all
	StringReplace,ExpressionString,ExpressionString,!=,≠,all
	StringReplace,ExpressionString,ExpressionString,<>,≠,all
	StringReplace,ExpressionString,ExpressionString,==,≡,all
	StringReplace,ExpressionString,ExpressionString,% " or ",∨,all
	StringReplace,ExpressionString,ExpressionString,||,∨,all
	StringReplace,ExpressionString,ExpressionString,% " and ", ∧,all
	StringReplace,ExpressionString,ExpressionString,&&,∧,all
	StringReplace,ExpressionString,ExpressionString,% " not ",% " ¬",all
	StringReplace,ExpressionString,ExpressionString,% "!",% "¬",all
	return v_EvaluateExpressionRecurse(InstanceID,ThreadID,ExpressionString)
}

/* Evaluation of an Expression
Thanks to Sunshine for the easy to understand instruction. See http://www.sunshine2k.de/coding/java/SimpleParser/SimpleParser.html
If anybody knows hot to implement more operants and make this more flexible, or even support scripts, please come in touch with me!
*/
v_EvaluateExpressionRecurse(InstanceID,ThreadID,ExpressionString)
{
	;MsgBox %ExpressionString%
	
	 
	
	ExpressionString:=trim(ExpressionString)
	
	if (substr(ExpressionString,1,1)="-" or substr(ExpressionString,1,1)="+")
		ExpressionString:="0" ExpressionString
	
	
	
	if (v_SearchForFirstOperand(ExpressionString,FoundOpreand,leftSubstring,rightSubstring))
	{
		;MsgBox %  leftSubstring FoundOpreand rightSubstring 
		if ( FoundOpreand != "¬")
			resleft:= v_EvaluateExpression(InstanceID,ThreadID,leftSubstring)
		resright:=v_EvaluateExpression(InstanceID,ThreadID,rightSubstring)
		;MsgBox %FoundOpreand% %resleft% %resright%
		if FoundOpreand = +
			return resleft + resright
		else if FoundOpreand = -
			return resleft - resright
		else if FoundOpreand = *
			return resleft * resright
		else if FoundOpreand = /
			return resleft / resright
		else if FoundOpreand = ≠
			return resleft != resright
		else if FoundOpreand = ≡
			return resleft == resright
		else if FoundOpreand = =
			return resleft = resright
		else if FoundOpreand = ≤
			return resleft <= resright
		else if FoundOpreand = ≥
			return resleft >= resright
		else if FoundOpreand = <
			return resleft < resright
		else if FoundOpreand = >
			return resleft > resright
		else if FoundOpreand = ∨
			return resleft || resright
		else if FoundOpreand = ∧
			return resleft && resright
		else if FoundOpreand = ¬
		{
			return not resright
		}
		else
			return
	}
	
	if (substr(ExpressionString,1,1) = "(")
	{
		StringRight,tempchar,ExpressionString,1
		if (tempchar = ")")
		{
			StringTrimLeft,ExpressionString,ExpressionString,1
			StringTrimRight,ExpressionString,ExpressionString,1
			return (v_EvaluateExpression(InstanceID,ThreadID,ExpressionString))
		}
		   
		else
		{
			MsgBox Bracket Error
			return
		}
	}
	
	if ExpressionString is number
		return ExpressionString
	
	;MsgBox % v_GetVariable(InstanceID,ExpressionString,"asIs")
	return v_GetVariable(InstanceID,ThreadID,ExpressionString,"asIs")
	
	
	
	
}

v_SearchForFirstOperand(String,ByRef ResFoundoperand,Byref ResLeftString, Byref ResRightString)
{
	BracketCount=0
	firstplus=
	firstminus=
	;MsgBox %String%
	loop, parse, String
	{
		
		if (a_Loopfield="(")
		{
			BracketCount++
		}
		else if (a_Loopfield=")")
		{
			BracketCount--
		}
		else if (BracketCount=0)
		{
			if (a_Loopfield="∨")
			{
				firstor:=A_Index
			}
			if (a_Loopfield="∧")
			{
				firstand:=A_Index
			}
			if (a_Loopfield="¬")
			{
				
				firstnot:=A_Index
			}
			if (a_Loopfield="=")
			{
				firstequal:=A_Index
				firstequaletc:=A_Index
			}
			if (a_Loopfield="≡")
			{
				firstequalequal:=A_Index
				firstequaletc:=A_Index
			}
			if (a_Loopfield="≠")
			{
				firstenotequal:=A_Index
				firstequaletc:=A_Index
			}
			if (a_Loopfield=">" )
			{
				firstgreater:=A_Index
				firstgreatersmaller:=A_Index
			}
			if (a_Loopfield="<" )
			{
				firstsmaller:=A_Index
				firstgreatersmaller:=A_Index
			}
			if (a_Loopfield="≥" )
			{
				firstgreaterequal:=A_Index
				firstgreatersmaller:=A_Index
			}
			if (a_Loopfield="≤" )
			{
				firstsmallerequal:=A_Index
				firstgreatersmaller:=A_Index
			}
			if (a_Loopfield="+")
			{
				firstplus:=A_Index
				firstplusminus:=A_Index
			}
			if (a_Loopfield="+" )
			{
				firstplus:=A_Index
				firstplusminus:=A_Index
			}
			if (a_Loopfield="-" )
			{
				firstminus:=A_Index
				firstplusminus:=A_Index
			}
			if (a_Loopfield="*" )
			{
				firstMult:=A_Index
				firstplusMultDiv:=A_Index
			}
			if (a_Loopfield="/")
			{
				firstDiv:=A_Index
				firstplusMultDiv:=A_Index
			}
		}
		
		
	}
	
	if (firstor!="" )
	{
		
		ResFoundoperand:="∨"
		StringLeft,ResLeftString,String,% firstor -1
		StringTrimLeft,ResRightString,String,% firstor
		
		return true
	}
	if (firstand!="")
	{
		
		ResFoundoperand:="∧"
		StringLeft,ResLeftString,String,% firstand -1
		StringTrimLeft,ResRightString,String,% firstand
		
		return true
	}
	if (firstnot!="")
	{
		
		ResFoundoperand:="¬"
		StringLeft,ResLeftString,String,% firstnot -1
		StringTrimLeft,ResRightString,String,% firstnot
		
		return true
	}
	if (firstgreater!="" and (firstgreater =firstgreatersmaller))
	{
		
		ResFoundoperand:=">"
		StringLeft,ResLeftString,String,% firstgreater -1
		StringTrimLeft,ResRightString,String,% firstgreater
		
		return true
	}
	if (firstsmaller!="" and (firstsmaller =firstgreatersmaller))
	{
		
		ResFoundoperand:="<"
		StringLeft,ResLeftString,String,% firstsmaller -1
		StringTrimLeft,ResRightString,String,% firstsmaller
		
		return true
	}
	if (firstgreaterequal!="" and (firstgreaterequal =firstgreatersmaller))
	{
		
		ResFoundoperand:="≥"
		StringLeft,ResLeftString,String,% firstgreaterequal -1
		StringTrimLeft,ResRightString,String,% firstgreaterequal
		
		return true
	}
	if (firstsmallerequal!="" and (firstsmallerequal =firstgreatersmaller))
	{
		
		ResFoundoperand:="≤"
		StringLeft,ResLeftString,String,% firstsmallerequal -1
		StringTrimLeft,ResRightString,String,% firstsmallerequal
		
		return true
	}
	if (firstequal!="" and (firstequal =firstequaletc))
	{
		
		ResFoundoperand:="="
		StringLeft,ResLeftString,String,% firstequal -1
		StringTrimLeft,ResRightString,String,% firstequal
		
		return true
	}
	if (firstequalequal!="" and (firstequalequal =firstequaletc))
	{
		
		ResFoundoperand:="≡"
		StringLeft,ResLeftString,String,% firstequalequal -1
		StringTrimLeft,ResRightString,String,% firstequalequal
		
		return true
	}
	if (firstenotequal!="" and (firstenotequal =firstequaletc))
	{
		
		ResFoundoperand:="≠"
		StringLeft,ResLeftString,String,% firstenotequal -1
		StringTrimLeft,ResRightString,String,% firstenotequal
		
		return true
	}
	if (firstplus!="" and (firstplus =firstplusminus))
	{
		
		ResFoundoperand=+
		StringLeft,ResLeftString,String,% firstplus -1
		StringTrimLeft,ResRightString,String,% firstplus
		
		return true
	}
	if (firstminus!=""  and (firstminus =firstplusminus))
	{
		ResFoundoperand=-
		StringLeft,ResLeftString,String,% firstminus -1
		StringTrimLeft,ResRightString,String,% firstminus
		return true
	}
	if (firstMult!="" and (firstMult = firstplusMultDiv))
	{
		
		ResFoundoperand=*
		StringLeft,ResLeftString,String,% firstMult -1
		StringTrimLeft,ResRightString,String,% firstMult
		
		return true
	}
	if (firstDiv!="" and (firstDiv = firstplusMultDiv))
	{
		ResFoundoperand=/
		StringLeft,ResLeftString,String,% firstDiv -1
		StringTrimLeft,ResRightString,String,% firstDiv
		return true
	}
	
	;MsgBox No operand found in "%String%" firstplus %firstplus% firstminus %firstminus% firstplusminus %firstplusminus%
	return false
	
}

getvariabletest(name)
{
	var1=11
	var2=hi
	var22=hi
	var23=hie
	
 retval:=%name%
	return retval

}