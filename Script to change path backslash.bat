@echo off
setlocal enabledelayedexpansion

set "inputPath=/path/to/some/folder/"

REM Replace forward slashes with backslashes
set "outputPath=!inputPath:/=\!"

echo Input Path: %inputPath%
echo Output Path: %outputPath%

endlocal
