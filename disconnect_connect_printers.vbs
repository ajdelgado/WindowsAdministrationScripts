Set WshShell = WScript.CreateObject("WScript.Shell")

strPrintServer = "master.privalia.global"

Function Connect()
	WshShell.Run("rundll32 printui.dll,PrintUIEntry /in /q /n " & Chr(34) & "\\" & strPrintServer & "\printbcn01" & Chr(34))
	WshShell.Run("rundll32 printui.dll,PrintUIEntry /in /q /n " & Chr(34) & "\\" & strPrintServer & "\printbcn03" & Chr(34))
End Function

Function Disconnect()
	WshShell.Run("rundll32 printui.dll,PrintUIEntry /dn /q /n " & Chr(34) & "\\" & strPrintServer & "\printbcn01" & Chr(34))
	WshShell.Run("rundll32 printui.dll,PrintUIEntry /dn /q /n " & Chr(34) & "\\" & strPrintServer & "\printbcn03" & Chr(34))
End Function

Disconnect()

Connect()
