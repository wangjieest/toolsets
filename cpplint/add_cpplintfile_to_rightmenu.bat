@echo off
Pushd %~dp0
bcdedit>nul
if errorlevel 1 (echo "请右键以管理员权限运行" && Pause>nul && exit /b 1)

set tools_dir=%~dp0
cd %~dp0
if not exist "%tools_dir%\cpplint_file.py" (
echo 请将此文件放到cpplint_file.py相同目录下.
exit /b 1
)

rem pyhon路径
set /p python_dir=请输入python_dir路径(留空则使从path中查找):
if "%python_dir%" neq "" (
 set python_dir=%python_dir%\
 set result_path=%python_dir%
 ) 
if not exist %python_dir%\python.exe (
call :find_in_path python.exe
if "%result_path%" neq "" set python_dir=%result_path%
)
set python_dir=%result_path%
echo python.exe 路径为 : "%python_dir%python.exe"
if not exist "%python_dir%\python.exe" (
echo 没有找到 python.exe 请检查
goto fail
)

>cpplint_rightmenu.bat echo @echo off
>>cpplint_rightmenu.bat echo if "%%1" equ "" goto:eof
>>cpplint_rightmenu.bat echo cd /d %%~dp0
>>cpplint_rightmenu.bat echo "%python_dir%python.exe" "%tools_dir%\cpplint_file.py" %%*
>>cpplint_rightmenu.bat echo echo "扫描完成. 按任意键退出" ^&^& Pause^>nul exit /b 0 

rem .cpp
call :addrightmenu .cpp
call :addrightmenu .cc
call :addrightmenu .cxx
call :addrightmenu .c
call :addrightmenu .h
call :addrightmenu .hpp
call :addrightmenu .hxx
echo "添加右键 cpplint 完成. 按任意键退出" && Pause>nul exit /b 0 
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
reg add hkcr\%param%\shell\cpplint  /d "代码检查CppLin(&t)" /f >nul 
reg add hkcr\%param%\shell\cpplint\command /f /d %param2% >nul 
endlocal
goto:eof

rem 在环境变量中查找文件
:find_in_path
set result_path=%~dp$PATH:1
goto:eof