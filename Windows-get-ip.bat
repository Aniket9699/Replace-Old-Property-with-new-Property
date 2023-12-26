@echo off
setlocal enabledelayedexpansion

for /f "tokens=*" %%a in ('hostname') do set myVariable=%%a
echo Hostname: !myVariable!

for /f "tokens=*" %%a in ('%SystemRoot%\System32\PING.exe !myVariable! -4 ^| %SystemRoot%\System32\findstr.exe /c:"Ping statistics for "') do (
    echo %%a
    set "lastValue="
	for %%i in (%%a) do (
    	set "lastValue=%%i"
	)
	set "IpAddress=!lastValue::=!"
	echo Ip Address : !IpAddress!
)

%SystemRoot%\System32\findstr.exe "!IpAddress!" Windows-Agent-Details.txt | for /f "tokens=2 delims==" %%b in ('more') do (
    echo Groovy Home Path: %%b
    copy Update.groovy %%b\bin
    cd /d %%b\bin\
    dir
    groovy.bat "Update.groovy"
)

endlocal
