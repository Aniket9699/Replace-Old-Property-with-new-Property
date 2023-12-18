@echo off
setlocal EnableDelayedExpansion

REM Run ipconfig and filter the output for the specified Ethernet adapter
for /f "tokens=*" %%a in ('%SystemRoot%\System32\ipconfig.exe ^| %SystemRoot%\System32\findstr.exe /C:"Ethernet adapter Lan" /C:"IPv4 Address"') do (
    set "outputLine=%%a"
    REM Extract and display only the IPv4 Address line
    if "!outputLine:IPv4 Address=!" neq "!outputLine!" (
        REM Extract the IPv4 address using string manipulation
        set "ipv4Address=!outputLine:*: =!"
        echo IPv4 Address: !ipv4Address!
        
        REM Your additional commands using the IPv4 address go here
        set "IP=!ipv4Address!"
        %SystemRoot%\System32\findstr.exe "!IP:~1!" Windows-Agent-Details.txt | for /f "tokens=2 delims==" %%b in ('more') do (
            echo Groovy Home Path: %%b
            copy Update.groovy %%b\bin
            cd /d %%b\bin\
            dir
            groovy.bat "Update.groovy"
        )
    )
)

endlocal
