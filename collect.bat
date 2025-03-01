@echo off
setlocal enabledelayedexpansion

REM ========================================================
REM  Log Collector Script - Version 3.0.5
REM  Author: Ted Crow
REM  Date: 2025-02-28
REM ========================================================

REM ========================================================
REM  Validate Required Files
REM ========================================================
if not exist "servers.txt" (
    echo Error: servers.txt not found.
    goto EndScript
)

if not exist "filepaths.txt" (
    echo Error: filepaths.txt not found.
    goto EndScript
)

REM ========================================================
REM  Path Configuration
REM ========================================================
set "LogAge=1"                               
set "DestinationRoot=C:\Temp\CollectedLogs"
set "ZIP_7z_exe=%ProgramFiles%\7-Zip\7z.exe"
set "ZIP_Path=C:\Temp\ZippedLogs"

REM ========================================================
REM  Load Server List from servers.txt
REM ========================================================
set "ServerCount=0"
for /f "usebackq tokens=*" %%A in ("servers.txt") do (
    set "line=%%A"
    set "firstChar=!line:~0,1!"
    if not "!line!" == "" if "!firstChar!" neq "#" (
        set "Servers[!ServerCount!]=!line!"
        set /a ServerCount+=1
    )
)

REM ========================================================
REM  Load File Paths from filepaths.txt
REM ========================================================
set "FilePathCount=0"
for /f "usebackq tokens=1,2" %%B in ("filepaths.txt") do (
    set "line=%%B"
    set "firstChar=!line:~0,1!"
    if not "!line!" == "" if "!firstChar!" neq "#" (
        set "SourcePaths[!FilePathCount!]=%%B"
        set "DestPaths[!FilePathCount!]=%%C"
        set /a FilePathCount+=1
    )
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

REM ========================================================
REM  Print a list of defined File Paths
REM ========================================================
echo ========================================================
echo  File Paths:
echo ========================================================
for /l %%j in (0,1,!FilePathCount!) do (
    echo !SourcePaths[%%j]! --^> !DestPaths[%%j]!
)
echo.

choice /M "Are you ready to COPY the logs? (Y/N)"
if %ERRORLEVEL% == 2 goto EndScript

REM ========================================================
REM  Ensure DestinationRoot exists and set compressed flag
REM ========================================================
if not exist "%DestinationRoot%" mkdir "%DestinationRoot%"
compact /C /I /Q "%DestinationRoot%"

REM ========================================================
REM   Main Loop
REM ========================================================

REM Define RoboCopy error messages in an array
set "ErrorMessage[1]=One or more files were copied successfully. "
set "ErrorMessage[2]=Extra files or directories were detected, none of files were copied. "
set "ErrorMessage[4]=Mismatched files or directories were detected. "
set "ErrorMessage[8]=Some files or directories could not be copied. "
set "ErrorMessage[16]=Serious error occurred. Robocopy did not copy any files. "


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
    
        REM Calculate the robocopy exit code
        set "RoboCopyExitCode=!ERRORLEVEL!"
        set "RoboCopyMessage="

		set "RoboCopyMessage="

		REM Decode the exit code and build combined message
		if !RoboCopyExitCode! EQU 0 (
			set "RoboCopyMessage=No errors occurred, and no copying was done."
		) else (
			for %%e in (1 2 4 8 16) do (
				set /a "BitwiseResult=!RoboCopyExitCode! & %%e"
				if !BitwiseResult! NEQ 0 (
					set "RoboCopyMessage=!RoboCopyMessage!!ErrorMessage[%%e]!"
				)
			)
		)
		
		if !RoboCopyExitCode! LEQ 7 (
			echo SUCCESS: !RoboCopyMessage!
		) else if !RoboCopyExitCode! LEQ 15 (
			echo ERROR: !RoboCopyMessage!
		) else (
			echo FATAL: !RoboCopyMessage!
		)
		
		if !RoboCopyExitCode! GEQ 8 (
			echo Check robocopy.log for details.
		)
    )
)

REM ========================================================
REM  ZIP File Creation
REM ========================================================

choice /M "Are you ready to ZIP the logs? (Y/N)"
if %ERRORLEVEL% == 2 goto EndScript

if not exist "%ZIP_7z_exe%" (
    echo 7z.exe not found. Please install 7-Zip or check the path.
    goto EndScript
)

REM Ensure ZIP_Path exists
if not exist "%ZIP_Path%" mkdir "%ZIP_Path%"

REM Get today's date and time in YYYY-MM-DD_HH-MM format
set "DateStamp=%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%-%TIME:~3,2%"
set "DateStamp=%DateStamp: =0%"

REM Build all the archive files
for /d %%a in ("%DestinationRoot%\*") do (
    "%ZIP_7z_exe%" a "%ZIP_Path%\%DateStamp%-%%~nxa.zip" "%%a"
)

:EndScript
endlocal
echo.
echo ========================================================
echo  Script finished.
echo ========================================================
pause