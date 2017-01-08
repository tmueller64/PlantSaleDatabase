for /f "usebackq tokens=* delims=\" %%a in ('C:\Program Files\Sun\Creator2ea2\rave2.0') do (
  set dbdir=%%~fsa
)


setlocal
set PATH=.;%SystemRoot%\system32;c:\windows\system32;c:\WINNT\system32
set configFile=%dbdir%\config\com-sun-rave-install.properties

cmd /c "%dbdir%\startup\bin\run-sql-bundled" pbsysadmin pbsysadmin "create-schema-Plantsale.sql" "%configFile%"
cmd /c "%dbdir%\startup\bin\run-sql-bundled" plantsale plantsale "create-Plantsale.sql" "%configFile%"
