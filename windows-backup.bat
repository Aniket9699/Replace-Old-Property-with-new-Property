@echo off
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

set source=${p:UploadFolder}\${p:Appname}.${p:Extension}
set destination=${p:BackUpDirectory}\${p:Appname}_"%timestamp%".${p:Extension}

IF EXIST "%source%" (
    copy "%source%" "%destination%"
    echo BackUp taken successfully
) ELSE (
    echo " ${p:Appname}.${p:Extension} folder is not for Deployment"
)
