set "targetpath=%1"
if "%targetpath%"== "%1" set "targetpath=%~dp0"

::检查path中有没有%targetpath%(有就退出，没有就接着执行)
echo %path%|findstr /i "%targetpath%" && (goto end)

::先添加，防止没有时修改出错
wmic ENVIRONMENT create name="path",VariableValue="%path%"
::再修改
wmic ENVIRONMENT where "name='path' and username='<system>'" set VariableValue="%targetpath%;%path%"
::再即时应用
set "path=%targetpath%;%path%"

:end
echo %path%
PAUSE