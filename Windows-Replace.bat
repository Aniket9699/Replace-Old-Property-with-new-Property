@echo off
setlocal enabledelayedexpansion

set "file_path=D:\Agent-Upgrade\ucd-agent-7.0.3\Property_Change\conf\agent\installed.properties"
set "new_line=agentcomm.server.uri=random\:(wss\://localhost\:7919,wss\://192.168.30.43\:7919)"

if not exist "%file_path%" (
    echo File not found: %file_path%
    exit /b 1
)

echo Reading file: %file_path%

:: Create a temporary file to store the modified content
set "temp_file=%temp%\tempfile.txt"

:: Read the file line by line and replace the line containing "agentcomm.server.uri"
(for /f "tokens=* delims=" %%a in (%file_path%) do (
    set "line=%%a"
    echo !line! | findstr /i "agentcomm.server.uri" >nul
    if !errorlevel! equ 0 (
        echo Replacing line: !line!
        echo !new_line!>>"%temp_file%"
    ) else (
        echo !line!>>"%temp_file%"
    )
))

:: Replace the original file with the modified content
move /y "%temp_file%" "%file_path%" >nul

echo File modification complete.
