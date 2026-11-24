@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\open_godot.ps1" -Scene "res://levels/Level_1_1.tscn"
if errorlevel 1 pause
