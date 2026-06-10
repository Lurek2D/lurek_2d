@echo off
setlocal
call "%~dp0tools\python.cmd" %*
exit /b %ERRORLEVEL%
