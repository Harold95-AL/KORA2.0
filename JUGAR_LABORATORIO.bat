@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\open_godot.ps1" -Play
if errorlevel 1 pause
