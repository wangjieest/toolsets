@echo off
Pushd %~dp0
bcdedit>nul
if errorlevel 1 (echo "请右键以管理员权限运行" && Pause>nul && exit /b 1)

set tools_dir=%~dp0
cd %~dp0
if not exist "%tools_dir%\clang-format.exe" (
echo 请将此文件放到clang-format.exe相同目录下.
exit /b 1
)
rem @echo off
rem if "%1" equ "" goto:eof
rem %~dp0clang-format.exe --style="{BasedOnStyle: Google, AccessModifierOffset: 0, BinPackArguments: false, BinPackParameters: false, ColumnLimit: 100, DerivePointerAlignment: false, IndentWidth: 4, SortIncludes: false, SpaceAfterTemplateKeyword: false, TabWidth: 4, AllowShortCaseLabelsOnASingleLine: true, AllowShortIfStatementsOnASingleLine: false, AllowShortLoopsOnASingleLine: false, AllowShortFunctionsOnASingleLine: Empty}" -i %*
rem if errorlevel 1 (
rem echo "格式化出错. 按任意键退出" && Pause>nul exit /b 1
rem )

>clang-format_rightmenu.bat echo @echo off
>>clang-format_rightmenu.bat echo if "%%1" equ "" goto:eof
>>clang-format_rightmenu.bat echo if not exist "%tools_dir%\clang-format.exe" (
>>clang-format_rightmenu.bat echo echo 请将此文件放到clang-format.exe相同目录下.
>>clang-format_rightmenu.bat echo exit /b 1
>>clang-format_rightmenu.bat echo )
>>clang-format_rightmenu.bat echo %%~dp0clang-format.exe --style="{BasedOnStyle: Google, AccessModifierOffset: 0, BinPackArguments: false, BinPackParameters: false, ColumnLimit: 100, DerivePointerAlignment: false, IndentWidth: 4, SortIncludes: false, SpaceAfterTemplateKeyword: false, TabWidth: 4, AllowShortCaseLabelsOnASingleLine: true, AllowShortIfStatementsOnASingleLine: false, AllowShortLoopsOnASingleLine: false, AllowShortFunctionsOnASingleLine: Empty}" -i %%*
>>clang-format_rightmenu.bat echo if errorlevel 1 (
>>clang-format_rightmenu.bat echo echo "格式化出错. 按任意键退出" ^&^& Pause^>nul exit /b 1
>>clang-format_rightmenu.bat echo )

rem .cpp
call :addrightmenu .cpp
call :addrightmenu .cc
call :addrightmenu .cxx
call :addrightmenu .c
call :addrightmenu .h
call :addrightmenu .hpp
call :addrightmenu .hxx
echo "添加右键 clang-format 完成. 按任意键退出" && Pause>nul exit /b 0 
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

set param2=""""%~dp0clang-format_rightmenu.bat""" """%%1"""" 
reg add hkcr\%param%\shell\clangformat  /d "代码格式化(&F)" /f >nul 
reg add hkcr\%param%\shell\clangformat\command /f /d %param2% >nul 
goto:eof
