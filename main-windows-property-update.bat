@echo off
setlocal enabledelayedexpansion


set drives=D P E
set driveFound=

for %%d in (%drives%) do (
    if exist %%d:\ (
        set driveFound=%%d:
        goto :break
    ) else (
        echo %%d: drive is not present.
    )
)

:break
echo Drive %driveFound% is present.

for /f "tokens=*" %%a in ('hostname') do set "myVariable=%%a"
echo Hostname: !myVariable!

for /f "tokens=*" %%a in ('%SystemRoot%\System32\PING.exe !myVariable! -4 ^| %SystemRoot%\System32\findstr.exe /c:"Ping statistics for "') do (
    for %%i in (%%a) do set "IpAddress=%%i"
    set "IpAddress=!IpAddress::=!"
    echo Ip Address : !IpAddress!
)

set "found=false"

for /f "tokens=*" %%a in ('type "Windows-Agent-Details.txt" ^| %SystemRoot%\System32\findstr.exe /i /c:"%IpAddress%"') do (
    set "found=true"
)

if !found! equ true (
    echo IP address found in file
) else (
    echo IP address not found in file
    exit /b 0
)

for /f "tokens=1,2,3 delims==" %%a in ('%SystemRoot%\System32\findstr.exe /b "!IpAddress!" Windows-Agent-Details.txt') do (
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

:: stop agent
call !thirdValue!\bin\stop_agent.cmd
if %ERRORLEVEL% equ 0 (
    echo Agent Stopped successfully.
) else (
    echo Failed to stop agent exit code %ERRORLEVEL%
)
:: Get the current date and time
for /f "delims=" %%a in ('wmic os get localdatetime ^| find "."') do set datetime=%%a

:: Extract the date and time components
set year=%datetime:~0,4%
set month=%datetime:~4,2%
set day=%datetime:~6,2%
set hour=%datetime:~8,2%
set minute=%datetime:~10,2%
set second=%datetime:~12,2%

:: Create a timestamp
set timestamp=%year%-%month%-%day%_%hour%-%minute%-%second%

echo Timestamp: %timestamp%

set source=!thirdValue!
set destination=%source%_BKP_%timestamp%

REM Check if the string contains "ibm-java-win"
echo !inputPath! | %SystemRoot%\System32\findstr.exe /c:"ibm-java-win-x86_64-71" >nul
if not errorlevel 1 (
    echo Agent is using "ibm-java-win-x86_64-71"
    echo Copying from "%source%" to "%destination%"
    xcopy "%source%" "%destination%" /E /I
    if exist "%destination%" (
        echo Backup taken successfully.
    ) else (
        echo Failed to take backup.
        exit /b 1
    )
    
    mkdir "!thirdValue!\opt\Agent_Java"
    if exist "!thirdValue!\opt\Agent_Java" (
        echo Agent_Java folder created
    ) else (
        echo Failed to create Agent_Java folder.
        exit /b 1
    )
    rem unzip Agent_Java.zip into destination
    echo "Unzipping java into Agent_Java folder"
    call "!secondValue!\bin\groovy.bat" unzip.groovy Agent_Java.zip "!thirdValue!\opt\Agent_Java"

    if exist "!thirdValue!\opt\Agent_Java\jre" (
        echo New Java is present.
    ) else (
        echo New Java is absent.
        exit /b 1
    )

    rem copy installed.properties, agent.cmd, configure-agent.cmd and _agent.cmd file into other logicaldrive and make the changes
    xcopy /Y "!thirdValue!\bin\configure-agent.cmd" %driveFound%
    xcopy /Y "!thirdValue!\conf\agent\installed.properties" %driveFound%
    xcopy /Y "!thirdValue!\bin\agent.cmd" %driveFound%
    xcopy /Y "!thirdValue!\bin\service\_agent.cmd" %driveFound%

    set "filesToCheck= %driveFound%\configure-agent.cmd %driveFound%\installed.properties %driveFound%\agent.cmd %driveFound%\_agent.cmd"

    for %%f in (%filesToCheck%) do (
        if exist "%%f" (
            echo File "%%f" is present.
        ) else (
            echo File "%%f" is not present.
            exit /b 1
        )
    )

    rem groovy script use 1st parameter is filename, 2nd parameter is old string, and 3rd parameter is new string

    call "!secondValue!\bin\groovy.bat" updateAgentJavaProperty.groovy "%driveFound%\configure-agent.cmd" "!configure_agent_java_home!" "!thirdValue!\opt\Agent_Java\jre"

    call "!secondValue!\bin\groovy.bat" updateAgentJavaProperty.groovy "%driveFound%\installed.properties" "%outputPath%" "%newJava%"

    call "!secondValue!\bin\groovy.bat" updateAgentJavaProperty.groovy "%driveFound%\agent.cmd" "!configure_agent_java_home!" "!thirdValue!\opt\Agent_Java\jre"

    call "!secondValue!\bin\groovy.bat" updateAgentJavaProperty.groovy "%driveFound%\_agent.cmd" "!configure_agent_java_home!" "!thirdValue!\opt\Agent_Java\jre"

    call "!secondValue!\bin\groovy.bat" updateAgentJavaProperty.groovy "%driveFound%\installed.properties" "!agentcommproxyuri!" "random\:(http\://10.246.64.207\:20080,http\://10.246.64.208\:20080,http://10.177.48.207:20080,http://10.177.48.208:20080)"

    call "!secondValue!\bin\groovy.bat" updateAgentJavaProperty.groovy "%driveFound%\installed.properties" "!agentcommserveruri!" "random\:(wss\://10.246.64.201\:7919,wss\://10.246.64.202\:7919,wss\://10.177.48.201\:7919,wss\://10.177.48.202\:7919)"


    rem copy installed.properties, agent.cmd, configure-agent.cmd and _agent.cmd file into agent home
    xcopy /Y  "%driveFound%\configure-agent.cmd" "!thirdValue!\bin\"
    xcopy /Y "%driveFound%\installed.properties" "!thirdValue!\conf\agent\"
    xcopy /Y "%driveFound%\agent.cmd" "!thirdValue!\bin\"
    xcopy /Y "%driveFound%\_agent.cmd" "!thirdValue!\bin\service\"

    set "filesToCheck= !thirdValue!\bin\configure-agent.cmd !thirdValue!\conf\agent\installed.properties !thirdValue!\bin\agent.cmd !thirdValue!\bin\service\_agent.cmd"

    for %%f in (%filesToCheck%) do (
        if exist "%%f" (
            echo File "%%f" is present.
        ) else (
            echo File "%%f" is not present.
            exit /b 1
        )
    )

    call !thirdValue!\bin\service\_agent.cmd install ibm-ucd-agent-7-1
    
    if %ERRORLEVEL% equ 0 (
        echo Service Created successfully.
    ) else (
        echo Failed to create service exit code:- %ERRORLEVEL%
        exit /b 1
    )
    %SystemRoot%\System32\sc.exe query ibm-ucd-agent-7-1

    %SystemRoot%\System32\sc.exe start ibm-ucd-agent-7-1

    %SystemRoot%\System32\sc.exe query ibm-ucd-agent-7-1

) else (
    echo Agent is using java other than ibm-java-win-x86_64-71"
    echo Agent Java !inputPath!
)

endlocal
