@echo off
setlocal
pushd "%~dp0"

set BIN=%CD%\bin\trdsql
set INPUT=%CD%\data\sample-d1.csv
set OUTPUT=%CD%\output\result.csv
set SQL=%CD%\hoge.sql

call :MD "%OUTPUT%"


@echo on
type %INPUT%|%BIN% -ih -icsv -oh -out "%OUTPUT%" -q %SQL%
@echo off

:END
popd
endlocal
exit /b

:MD
echo %~dp1
md "%~dp1" >nul 2>&1
exit /b
