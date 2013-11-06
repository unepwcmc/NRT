@echo off


@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin


@powershell -Command cinst python
@powershell -Command cinst git
@powershell -Command cinst nodejs.install
@powershell -Command cinst mongodb


echo **************************************************************
echo The following `node-gyp` dependencies must first be installed:
echo Install "Microsoft Visual Studio 2010 Express":
echo http://go.microsoft.com/?linkid=9709949
echo Install "Microsoft Windows 7 64-bit SDK":
echo http://www.microsoft.com/en-us/download/details.aspx?id=8279
echo Once successfully installed, press ENTER
pause > nul
