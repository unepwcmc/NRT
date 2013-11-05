@echo off

set NODE_ENV=production
set AUTH_TOKEN=changeme
set PORT=80

if %AUTH_TOKEN%==changeme (
  echo *****************************************************
  echo Please change the AUTH_TOKEN in server/bin/server.bat
  echo *****************************************************
  pause > nul
  EXIT
)

coffee ./bin/server.coffee
