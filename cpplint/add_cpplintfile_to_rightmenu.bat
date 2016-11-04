@echo off
Pushd %~dp0
bcdedit>nul
if errorlevel 1 (echo "���Ҽ��Թ���ԱȨ������" && Pause>nul && exit /b 1)

set tools_dir=%~dp0
cd %~dp0
if not exist "%tools_dir%\cpplint_file.py" (
echo �뽫���ļ��ŵ�cpplint_file.py��ͬĿ¼��.
exit /b 1
)

rem pyhon·��
set /p python_dir=������python_dir·��(������ʹ��path�в���):
if "%python_dir%" neq "" (
 set python_dir=%python_dir%\
 set result_path=%python_dir%
 ) 
if not exist %python_dir%\python.exe (
call :find_in_path python.exe
if "%result_path%" neq "" set python_dir=%result_path%
)
set python_dir=%result_path%
echo python.exe ·��Ϊ : "%python_dir%python.exe"
if not exist "%python_dir%\python.exe" (
echo û���ҵ� python.exe ����
goto fail
)

>cpplint_rightmenu.bat echo @echo off
>>cpplint_rightmenu.bat echo if "%%1" equ "" goto:eof
>>cpplint_rightmenu.bat echo cd /d %%~dp0
>>cpplint_rightmenu.bat echo "%python_dir%python.exe" "%tools_dir%\cpplint_file.py" %%*
>>cpplint_rightmenu.bat echo echo "ɨ�����. ��������˳�" ^&^& Pause^>nul exit /b 0 

rem .cpp
call :addrightmenu .cpp
call :addrightmenu .cc
call :addrightmenu .cxx
call :addrightmenu .c
call :addrightmenu .h
call :addrightmenu .hpp
call :addrightmenu .hxx
echo "����Ҽ� cpplint ���. ��������˳�" && Pause>nul exit /b 0 
goto:eof

:addrightmenu
setlocal
set "ext=%1"
echo ext=%ext%
reg query hkcu\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%ext%\UserChoice /s >temp.txt
FOR /F "tokens=3 delims= " %%i in (temp.txt) do (
set param=%%i)
del temp.txt 1>nul 2>nul
if %param% == "" (
reg query hkcr\%ext% /ve >temp.txt
FOR /F "tokens=3 delims= " %%i in (temp.txt) do (
set param=%%i)
del temp.txt 1>nul 2>nul
)

set param2=""""%~dp0cpplint_rightmenu.bat""" """%%1"""" 
reg add hkcr\%param%\shell\cpplint  /d "������CppLin(&t)" /f >nul 
reg add hkcr\%param%\shell\cpplint\command /f /d %param2% >nul 
endlocal
goto:eof

rem �ڻ��������в����ļ�
:find_in_path
set result_path=%~dp$PATH:1
goto:eof