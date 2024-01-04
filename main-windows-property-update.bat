@echo off
setlocal enabledelayedexpansion

for /f "tokens=*" %%a in ('hostname') do set "myVariable=%%a"
echo Hostname: !myVariable!

for /f "tokens=*" %%a in ('%SystemRoot%\System32\PING.exe !myVariable! -4 ^| %SystemRoot%\System32\findstr.exe /c:"Ping statistics for "') do (
    for %%i in (%%a) do set "IpAddress=%%i"
    set "IpAddress=!IpAddress::=!"
    echo Ip Address : !IpAddress!
)

set "found=false"
set "IpAddress=10.250.130.24"

for /f "tokens=*" %%a in ('type Windows-Agent-Details.txt ^| %SystemRoot%\System32\findstr.exe /R /C:"\<!IpAddress!\>"
') do (
    set "found=true"
)

if !found! equ true (
    echo IP address found in file
) else (
    echo IP address not found in file
    exit /b 0
)

for /f "tokens=1,2,3 delims==" %%a in ('%SystemRoot%\System32\findstr.exe /R /C:"\<!IpAddress!\>" Windows-Agent-Details.txt') do (
    set "firstValue=%%a"
    set "secondValue=%%b"
    set "thirdValue=%%c"
    set "thirdValue=!thirdValue:/=\!"

    for /f "tokens=2 delims==" %%a in ('%SystemRoot%\System32\findstr.exe "JAVA_HOME" "!thirdValue!\bin\configure-agent.cmd"') do (
        set "configure_agent_java_home=%%a"
    )

    for /f "tokens=2 delims==" %%a in ('%SystemRoot%\System32\findstr.exe "agentcomm.proxy.uri" "!thirdValue!\conf\agent\installed.properties"') do (
        set "agentcommproxyuri=%%a"
    )

    for /f "tokens=2 delims==" %%a in ('%SystemRoot%\System32\findstr.exe "agentcomm.server.uri" "!thirdValue!\conf\agent\installed.properties"') do (
        set "agentcommserveruri=%%a"
    )
)

REM old java path
set "inputPath=!configure_agent_java_home!"

REM Replace backslashes with double backslashes and add a single backslash after the drive letter
set "outputPath=!inputPath:\=\\!"
set "outputPath=!outputPath:~0,1!\:\!outputPath:~3!"

REM new java path
set "oldJava=!thirdValue!\opt\Agent_Java\jre"

REM Replace backslashes with double backslashes and add a single backslash after the drive letter
set "newJava=!oldJava:\=\\!"
set "newJava=!oldJava:~0,1!\:\!newJava:~3!"

echo ====================================================================================
echo System IP: !firstValue!
echo Groovy Home: !secondValue!
echo Agent Home: !thirdValue!
echo configure-agent.cmd java path: !configure_agent_java_home!
echo installed.properties java path: %outputPath%
echo New Java Path for files are :- "%newJava%" "!thirdValue!\opt\Agent_Java\jre"
echo Agent comm proxy uri:- !agentcommproxyuri!
echo Agent comm server uri:- !agentcommserveruri!
echo ====================================================================================

endlocal
