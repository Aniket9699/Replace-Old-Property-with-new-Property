@echo off
setlocal EnableDelayedExpansion

REM Run ipconfig and filter the output for the specified Ethernet adapter
for /f "tokens=*" %%a in ('ipconfig ^| findstr /C:"Ethernet adapter Lan" /C:"IPv4 Address"') do (
    set "outputLine=%%a"
    REM Extract and display only the IPv4 Address line
    if "!outputLine:IPv4 Address=!" neq "!outputLine!" (
        REM Extract the IPv4 address using string manipulation
        set "ipv4Address=!outputLine:*: =!"
        echo !ipv4Address!
    )
)

endlocal
