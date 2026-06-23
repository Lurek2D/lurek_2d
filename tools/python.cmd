@echo off
setlocal

if defined LUREK_PYTHON if exist "%LUREK_PYTHON%" (
  set "PYTHON_EXE=%LUREK_PYTHON%"
  goto run
)

set "PROGRAMFILES_PY314=C:\Program Files\Python314\python.exe"
if exist "%PROGRAMFILES_PY314%" (
  set "PYTHON_EXE=%PROGRAMFILES_PY314%"
  goto run
)

set "CODEX_PY=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if exist "%CODEX_PY%" (
  set "PYTHON_EXE=%CODEX_PY%"
  goto run
)

set "USER_PY314=%LOCALAPPDATA%\Programs\Python\Python314\python.exe"
if exist "%USER_PY314%" (
  set "PYTHON_EXE=%USER_PY314%"
  goto run
)

set "PORTABLE_PY=C:\venv_portable\Scripts\python.exe"
if exist "%PORTABLE_PY%" (
  set "PYTHON_EXE=%PORTABLE_PY%"
  goto run
)

set "USER_PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
if exist "%USER_PY%" (
  set "PYTHON_EXE=%USER_PY%"
  goto run
)

set "PY_LAUNCHER=%LOCALAPPDATA%\Programs\Python\Launcher\py.exe"
if exist "%PY_LAUNCHER%" (
  set "PYTHON_EXE=%PY_LAUNCHER%"
  set "PYTHON_ARGS=-3"
  goto run
)

echo No working Python interpreter found.>&2
exit /b 9009

:run
"%PYTHON_EXE%" %PYTHON_ARGS% %*
exit /b %ERRORLEVEL%
