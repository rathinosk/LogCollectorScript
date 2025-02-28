@echo off
setlocal enabledelayedexpansion
 
REM ========================================================
REM  Path Configuration
REM ========================================================
set "LogSourceBase=K$\Impact360\Data\Logs"

set "LogSource=MAS"
set "LogDest=MAS"
REM set "LogSource=DataAccessServices"
REM set "LogDest=DataAccessServices"

REM --> TrsTomcat64 Logs
REM set "LogSourceBase=E$\Impact360\Software\TrsTomcat64"
REM set "LogSource=logs"
REM set "LogDest=TrsTomcat64"

set "LogAge=1"                               
set "DestinationRoot=C:\Temp\CollectedLogs"
set "ZIP_7z_exe=C:\Program Files\7-Zip\7z.exe"
 
REM ========================================================
REM  Server List
REM ========================================================
REM set "Servers[0]=TDCWPH7WVA171.verizon.com"
REM set "Servers[1]=TDCWPH7WVA172.verizon.com"
REM set "Servers[2]=TDCWPH7WVA173.verizon.com"
REM set "Servers[3]=TDCWPH7WVA174.verizon.com"
REM set "Servers[4]=TDCWPH7WVA175.verizon.com"
REM set "Servers[5]=TDCWPH7WVA176.verizon.com"
REM set "Servers[6]=TDCWPH7WVA177.verizon.com"
REM set "Servers[7]=TDCWPH7WVA178.verizon.com"
REM set "Servers[8]=TDCWPH7WVA179.verizon.com"
REM set "Servers[9]=TDCWPH7WVA180.verizon.com"
REM set "Servers[10]=TDCWPH7WVA182.verizon.com"
REM set "Servers[11]=TDCWPH7WVA181.verizon.com"
REM set "Servers[12]=TDCWPH7WVA183.verizon.com"
set "Servers[0]=TDCWPH7WVA184.verizon.com"
set "Servers[1]=TDCWPH7WVA185.verizon.com"
REM -------------------------------------------------
REM set "Servers[15]=tpawph7wva186.verizon.com"
REM set "Servers[16]=tpawph7wva187.verizon.com"
REM set "Servers[17]=tpawph7wva188.verizon.com"
REM set "Servers[18]=tpawph7wva189.verizon.com"
REM set "Servers[19]=tpawph7wva190.verizon.com"
REM set "Servers[20]=tpawph7wva191.verizon.com"
REM set "Servers[21]=tpawph7wva192.verizon.com"
REM set "Servers[22]=tpawph7wva193.verizon.com"
REM set "Servers[23]=tpawph7wva194.verizon.com"
REM set "Servers[24]=tpawph7wva195.verizon.com"
REM set "Servers[25]=tpawph7wva196.verizon.com"
REM set "Servers[26]=tpawph7wva197.verizon.com"
REM set "Servers[27]=tpawph7wva198.verizon.com"
REM set "Servers[28]=tpawph7wva199.verizon.com"
REM set "Servers[29]=tpawph7wva200.verizon.com"
 
REM ========================================================
REM  Print a list of defined Servers
REM ========================================================
set "ServerCount=0"
:ServerCountLoop
if defined Servers[%ServerCount%] (
  set /a ServerCount+=1
  goto ServerCountLoop
)

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
echo  Source !LogSourceBase!\!LogSource!
echo ========================================================

for /l %%i in (0,1,!UpperBound!) do (

  set "Server=!Servers[%%i]!"
  echo --------------------------------------------------------
  echo  Processing server: !Server!
  echo --------------------------------------------------------
  
  REM Create destination folder for the server
  set "DestinationServerPath=%DestinationRoot%\!Server!"
  if not exist "!DestinationServerPath!" mkdir "!DestinationServerPath!"
  if not exist "!DestinationServerPath!\!LogDest!" mkdir "!DestinationServerPath!\!LogDest!"
 
  REM Copy files using robocopy (preserves folder structure)
  set "SourcePath=\\!Server!\!LogSourceBase!\!LogSource!"
  echo.
  echo  Source: !SourcePath!
  echo  Destination: !DestinationServerPath!\!LogDest!
 
  robocopy "!SourcePath!" "!DestinationServerPath!\!LogDest!" /S /E /COPY:DAT /DCOPY:T /MAXAGE:!LogAge! /R:0 /W:0 /NFL /NDL /NP /LOG+:"!DestinationServerPath!\robocopy.log"
  
  if %Errorlevel% gtr 0 (
        echo Error during copy from !Server!. Check robocopy.log for details.
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
	
for /d %%a in ("%DestinationRoot%\*") do (
  "%ZIP_7z_Exe%" a "%%a.zip" "%%a"
)

:EndScript
endlocal
echo.
echo ========================================================
echo  Script finished.
echo ========================================================
pause