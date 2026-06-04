@echo off
color 0E
title Windows Autopilot Setup Tool
cls

echo.
echo  +==============================================================+
echo  ^|                    AUTOPILOT SETUP TOOL                     ^|
echo  ^|                      Version 1.0                            ^|
echo  +==============================================================+
echo.

ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No internet connection detected!
    echo [ERROR] Please connect to network and try again.
    pause
    exit /b 1
)
echo [STEP 1/5] Setting PowerShell execution policy...
powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Force" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to set execution policy!
    pause
    exit /b 1
)
echo [SUCCESS] Execution policy set to Bypass.
echo.

echo [STEP 2/5] Installing NuGet provider...
powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "try { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop | Out-Null } catch { exit 1 }" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to install NuGet provider!
    echo [INFO] Retrying with TLS 1.2...
    powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] NuGet installation failed after retry!
        pause
        exit /b 1
    )
)
echo [SUCCESS] NuGet provider installed.
echo.

echo [STEP 3/5] Configuring PowerShell Gallery...
powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to configure PowerShell Gallery!
    pause
    exit /b 1
)
echo [SUCCESS] PowerShell Gallery configured as trusted.
echo.

echo [STEP 4/5] Installing Autopilot Import GUI...
echo [INFO] This may take a few moments...
powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "try { Install-Script Get-WindowsAutopilotImportGUI -Force -ErrorAction Stop | Out-Null } catch { exit 1 }" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to install Autopilot script!
    echo [INFO] Trying alternative method...
    powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Install-Script Get-WindowsAutopilotImportGUI -Force" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Autopilot script installation failed!
        echo [INFO] Please check internet connection and try again.
        pause
        exit /b 1
    )
)

powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "if (Get-Command Get-WindowsAutopilotImportGUI -ErrorAction SilentlyContinue) { Write-Host 'VERIFIED' } else { Write-Host 'NOT_FOUND' }" 2>nul > temp_result.txt
set /p VERIFY_RESULT=<temp_result.txt
del temp_result.txt >nul 2>&1

if "%VERIFY_RESULT%"=="NOT_FOUND" (
    powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "if (Test-Path 'C:\Program Files\WindowsPowerShell\Scripts\Get-WindowsAutopilotImportGUI.ps1') { Write-Host 'FOUND_SCRIPT' } else { Write-Host 'MISSING' }" > temp_result.txt
    set /p SCRIPT_CHECK=<temp_result.txt
    del temp_result.txt >nul 2>&1
    
    if "%SCRIPT_CHECK%"=="MISSING" (
        echo [ERROR] Autopilot script not installed properly!
        pause
        exit /b 1
    )
)
echo [SUCCESS] Autopilot Import GUI installed.
echo.

echo [STEP 5/5] Launching Autopilot Import GUI...
echo [INFO] Starting the GUI application...
echo.

if "%VERIFY_RESULT%"=="NOT_FOUND" (
    powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -File "C:\Program Files\WindowsPowerShell\Scripts\Get-WindowsAutopilotImportGUI.ps1" 2>nul
) else (
    powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "Get-WindowsAutopilotImportGUI" 2>nul
)

echo.
echo  +==============================================================+
echo  ^|                    SETUP COMPLETED!                         ^|
echo  ^|          Use the GUI to import device to Autopilot          ^|
echo  +==============================================================+
echo.
echo Press any key to exit...
pause >nul
