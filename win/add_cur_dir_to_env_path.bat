set "targetpath=%1"
if "%targetpath%"== "%1" set "targetpath=%~dp0"

::���path����û��%targetpath%(�о��˳���û�оͽ���ִ��)
echo %path%|findstr /i "%targetpath%" && (goto end)

::����ӣ���ֹû��ʱ�޸ĳ���
wmic ENVIRONMENT create name="path",VariableValue="%path%"
::���޸�
wmic ENVIRONMENT where "name='path' and username='<system>'" set VariableValue="%targetpath%;%path%"
::�ټ�ʱӦ��
set "path=%targetpath%;%path%"

:end
echo %path%
PAUSE