@echo off
setlocal enabledelayedexpansion

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| find "IPv4"') do set IP=%%a

echo Server IP: %IP%

findstr "%IP:~1%" Ip-Details | for /f "tokens=2 delims==" %%b in ('more') do (
    echo Groovy Home Path: %%b
    cd /d %%b\bin\
    dir
    groovy.bat "D:\Agent-Upgrade\ucd-agent-7.0.3\agent\os.groovy"
)

endlocal
