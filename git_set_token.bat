@echo off && setlocal enableextensions enabledelayedexpansion
if "%~dp0" neq "%tmp%\" (set "cd=%~dp0" & (if not exist "%tmp%\%~nx0" (find "" /v<"%~f0" >"%tmp%\%~nx0")) & call "%tmp%\%~nx0" %* & del "%tmp%\%~nx0" 2>nul & exit /b) else (if "%cd:~-1%"=="\" set "cd=%cd:~0,-1%")

rem Change git access token on subfolder tree, by wenuam 2022

rem Set code page to utf-8 (/!\ this file MUST be in utf-8, BOM or not)
for /f "tokens=2 delims=:." %%x in ('chcp') do set cp=%%x
chcp 65001>nul

rem Set look-up parameters
set "carg=/B /A:D /ON /S"
set "clst=.clst.txt"

set "crel=%cd%"
set "curl=https://"
set "caut=oauth2:"
set "ctok=ghp_"

rem Set "quiet" suffixes
set "quiet=1>nul 2>nul"
set "fquiet=/f /q 1>nul 2>nul"

echo; Current folder: %crel%
echo; Scanning git folders...
dir %carg% ".git">"!clst!"
echo;

rem If git command found
if exist "!clst!" (
	rem Get token if not provided as argument
	set "vtok=%~1"
	if "!vtok!"=="" (
		set /p vtok=Enter valid git access token:
		echo;
	)

	if not "!vtok!"=="" (
		if "!vtok:~0,4!"=="!ctok!" (
			rem For all paths found (yet not checked as valid)
			for /f "delims=" %%i in (!clst!) do (
REM				echo %%i
				set "vdir=%%i"
				rem Check if "valid"
				if exist "!vdir!\config" (
					rem Change path and apply git command
					cd /d "!vdir!\.."
					rem Replace starting path with '.\'
					call set "vdir=!vdir:%crel%=.\!"
					rem Display the folder without '\.git' (5 chars)
					echo === GIT SET TOKEN : !vdir:~0,-5! =========
					rem Get remote 'origin' url
					for /f %%u in ('git config --get remote.origin.url') do set "vurl=%%u"
REM					echo vurl=!vurl!
					rem Strip protocol/auth/token
					if "!vurl:~0,8!"=="!curl!" set "vurl=!vurl:~8!"
					if "!vurl:~0,7!"=="!caut!" set "vurl=!vurl:~7!"
					if "!vurl:~0,4!"=="!ctok!" set "vurl=!vurl:~40!"
					if "!vurl:~0,1!"=="@" set "vurl=!vurl:~1!"
					if not "!vurl!"=="" (
						echo Remote "origin" = !curl!!vurl!
						git remote set-url origin !curl!!vtok!@!vurl!
						echo;
					)
				)
			)

			echo Done...
		) else (
			echo Invalid token...
		)

		rem Restore path
		cd /d "%crel%"
	) else (
		echo No token provided...
	)

	rem Delete git folders list
	del "%clst%" %fquiet%
)

rem Restore code page
chcp %cp%>nul
