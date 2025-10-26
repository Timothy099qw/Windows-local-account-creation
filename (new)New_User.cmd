@echo off
:: ==============================================================
::  Auth Tim – Create Admin User and Configure System
::  Run this file as Administrator.
:: ==============================================================

:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as Administrator.
    pause
    exit /b
)

:: Who r we setting up for
set /p username=Enter the new username you want to create: 

echo.
echo Creating user account "%username%"...
net user "%username%" * /add
net localgroup administrators "%username%" /add
net user "%username%" /active:yes
net user "%username%" /expires:never

echo.
echo Disabling built-in Administrator account...
net user "Administrator" /active:no

echo.
echo Removing defaultUser0 if it exists...
net user "defaultUser0" /delete >nul 2>&1

echo.
echo Updating registry (OOBE keys)...

:: Delete unwanted registry keys
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v DefaultAccountAction /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v DefaultAccountSAMName /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v DefaultAccountSID /f >nul 2>&1

:: Rename LaunchUserOOBE to SkipMachineOOBE and set its value to 1
for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v LaunchUserOOBE 2^>nul') do (
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v LaunchUserOOBE /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v SkipMachineOOBE /t REG_DWORD /d 1 /f
)

:: If LaunchUserOOBE not found, ensure SkipMachineOOBE=1 anyway
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v SkipMachineOOBE /t REG_DWORD /d 1 /f >nul 2>&1

echo.
echo All operations completed successfully.
echo The system will restart now...
shutdown /r /t 0
