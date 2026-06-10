@echo off
setlocal

if defined LUREK_PYTHON if exist "%LUREK_PYTHON%" (
  "%LUREK_PYTHON%" %*
  exit /b %ERRORLEVEL%
)

set "PROGRAMFILES_PY314=C:\Program Files\Python314\python.exe"
if exist "%PROGRAMFILES_PY314%" (
  "%PROGRAMFILES_PY314%" %*
  exit /b %ERRORLEVEL%
)

set "CODEX_PY=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if exist "%CODEX_PY%" (
  "%CODEX_PY%" %*
  exit /b %ERRORLEVEL%
)

set "USER_PY314=%LOCALAPPDATA%\Programs\Python\Python314\python.exe"
if exist "%USER_PY314%" (
  "%USER_PY314%" %*
  exit /b %ERRORLEVEL%
)

set "PORTABLE_PY=C:\venv_portable\Scripts\python.exe"
if exist "%PORTABLE_PY%" (
  "%PORTABLE_PY%" %*
  exit /b %ERRORLEVEL%
)

set "USER_PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
if exist "%USER_PY%" (
  "%USER_PY%" %*
  exit /b %ERRORLEVEL%
)

set "PY_LAUNCHER=%LOCALAPPDATA%\Programs\Python\Launcher\py.exe"
if exist "%PY_LAUNCHER%" (
  "%PY_LAUNCHER%" -3 %*
  exit /b %ERRORLEVEL%
)

echo No working Python interpreter found.>&2
exit /b 9009
