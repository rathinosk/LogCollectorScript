@echo off
setlocal EnableDelayedExpansion

REM Test cases for error levels 0 to 16
for /L %%i in (0,1,16) do (
    call :test_robocopy_exit_code %%i
)

goto :eof


REM Function to test the robocopy exit code
:test_robocopy_exit_code
    set "RoboCopyExitCode=%~1"

    echo Exit Code: !RoboCopyExitCode!

    REM Define error messages in an array
    set "ErrorMessage[1]=One or more files were copied successfully. "
    set "ErrorMessage[2]=Extra files or directories were detected, none of the files were copied. "
    set "ErrorMessage[4]=Mismatched files or directories were detected. "
    set "ErrorMessage[8]=Some files or directories could not be copied. "
    set "ErrorMessage[16]=Serious error occurred. Robocopy did not copy any files. "

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

    REM echo Message: !RoboCopyMessage!
    if !RoboCopyExitCode! GEQ 8 (
        echo Check robocopy.log for details.
    )
    echo.
    echo ----------------------------
    exit /b 0

:eof

endlocal