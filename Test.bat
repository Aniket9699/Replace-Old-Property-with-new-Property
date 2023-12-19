@echo off
setlocal enabledelayedexpansion

for /f "tokens=*" %%a in ('hostname') do set myVariable=%%a
echo Hostname: !myVariable!

for /f "tokens=*" %%a in ('ping !myVariable! -4 ^| findstr /c:"Ping statistics for "') do (
    echo %%a
    set "lastValue="
	for %%i in (%%a) do (
    	set "lastValue=%%i"
	)
	set "IpAddress=!lastValue::=!"
	echo Ip Address : !IpAddress!
)

endlocal
