Set sh = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")
base = fs.GetParentFolderName(WScript.ScriptFullName)
' Panel T5475 local: sin ventana negra, pide admin 1 vez, todo queda en esta carpeta.
sh.Run "powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & base & "\SC-T5475_VidaUtil_Reset.ps1""", 0, False
