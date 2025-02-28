@echo off
setlocal enabledelayedexpansion

REM ========================================================
REM  Path Configuration
REM ========================================================
set "LogAge=1"                               
set "DestinationRoot=C:\Temp\CollectedLogs"
set "ZIP_7z_exe=C:\Program Files\7-Zip\7z.exe"

REM ========================================================
REM  Ensure DestinationRoot exists and set compressed flag
REM ========================================================
if not exist "%DestinationRoot%" mkdir "%DestinationRoot%"
compact /C /I /Q "%DestinationRoot%"

REM ========================================================
REM  Load Server List from servers.txt
REM ========================================================
set "ServerCount=0"
for /f "tokens=*" %%A in (servers.txt) do (
    set "Servers[!ServerCount!]=%%A"
    set /a ServerCount+=1
)

REM ========================================================
REM  Load File Paths from filepaths.txt
REM ========================================================
set "FilePathCount=0"
for /f "tokens=1,2" %%B in (filepaths.txt) do (
    set "SourcePaths[!FilePathCount!]=%%B"
    set "DestPaths[!FilePathCount!]=%%C"
    set /a FilePathCount+=1
)
set /a FilePathCount-=1

REM ========================================================
REM  Print a list of defined Servers
REM ========================================================
set /a UpperBound=(!ServerCount! - 1)

echo ========================================================
echo  Number of Servers: %ServerCount% ([0]-[%UpperBound%])
echo ========================================================
for /l %%i in (0,1,!UpperBound!) do (
    echo Servers[%%i]: !Servers[%%i]!
)
echo.

choice /M "Are you ready to COPY the logs? (Y/N)"
if %ERRORLEVEL% == 2 goto EndScript

REM ========================================================
REM   Main Loop
REM ========================================================

echo ========================================================
echo  Starting processing of %ServerCount% servers. ([0]-[%UpperBound%])
echo ========================================================

for /l %%i in (0,1,!UpperBound!) do (
    set "Server=!Servers[%%i]!"
    echo --------------------------------------------------------
    echo  Processing server: !Server!
    echo --------------------------------------------------------
    
    REM Create destination folder for the server
    set "DestinationServerPath=%DestinationRoot%\!Server!"
    if not exist "!DestinationServerPath!" mkdir "!DestinationServerPath!"
  
    REM Copy files using robocopy (preserves folder structure)
    for /l %%j in (0,1,!FilePathCount!) do (
        set "SourceFile=!SourcePaths[%%j]!"
        set "DestFile=!DestPaths[%%j]!"
        set "SourcePath=\\!Server!\!SourceFile!"
        set "DestinationPath=!DestinationServerPath!\!DestFile!"
        
        echo.
        echo  Source: !SourcePath!
        echo  Destination: !DestinationPath!
        
        robocopy "!SourcePath!" "!DestinationPath!" /S /E /COPY:DAT /DCOPY:T /MAXAGE:!LogAge! /R:0 /W:0 /NFL /NDL /NP /LOG+:"!DestinationServerPath!\robocopy.log"
    
        if %Errorlevel% gtr 0 (
            echo Error during copy from !Server!. Check robocopy.log for details.
        )
    )
)

REM ========================================================
REM  ZIP File Creation
REM ========================================================

choice /M "Are you ready to ZIP the logs? (Y/N)"
if %ERRORLEVEL% == 2 goto EndScript

if not exist "%ZIP_7z_Exe%" (
    echo 7z.exe not found. Please install 7-Zip or check the path.
    goto EndScript
)

REM Get today's date in YYYY-MM-DD format
set "DateStamp=%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%"

for /d %%a in ("%DestinationRoot%\*") do (
    "%ZIP_7z_Exe%" a "%DateStamp%-%%~nxa.zip" "%%a"
)

:EndScript
endlocal
echo.
echo ========================================================
echo  Script finished.
echo ========================================================
pause