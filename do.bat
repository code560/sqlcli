@echo off
setlocal
pushd "%~dp0"

set BIN=%CD%\bin\trdsql
set INPUT=%CD%\data\sample-d1.csv
set SQL=%CD%\hoge.sql

@echo on
cat %INPUT%|%BIN% -ih -icsv -oh -q %SQL%
@echo off

:END
popd
endlocal
exit /b