@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\open_godot.ps1" -Scene "res://scenes/lab/Level_1_1_CrystalSpiresTest.tscn"
if errorlevel 1 pause
