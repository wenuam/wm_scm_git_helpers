@echo off && setlocal enabledelayedexpansion
if "%~dp0" neq "%tmp%\%guid%\" (set "guid=%~nx0.%~z0" & set "cd=%~dp0" & (if not exist "%tmp%\%~nx0.%~z0\%~nx0" (mkdir "%tmp%\%~nx0.%~z0" 2>nul & find "" /v<"%~f0" >"%tmp%\%~nx0.%~z0\%~nx0")) & call "%tmp%\%~nx0.%~z0\%~nx0" %* & rmdir /s /q "%tmp%\%~nx0.%~z0" 2>nul & exit /b) else (if "%cd:~-1%"=="\" set "cd=%cd:~0,-1%")

rem Apply git command on subfolder tree, by wenuam 2022
rem 'git_xxx_all' -> 'git xxx' on all '*(\.git\config)' found

rem Set code page to utf-8 (/!\ this file MUST be in utf-8, BOM or not)
for /f "tokens=2 delims=:." %%x in ('chcp') do set cp=%%x
chcp 65001>nul

rem Set look-up parameters
set "carg=/B /A:D /ON /S"
set "clst=.clst.txt"

set "crel=%cd%"

rem Set "quiet" suffixes
set "quiet=1>nul 2>nul"
set "fquiet=/f /q 1>nul 2>nul"

echo; Current folder : %crel%
echo; Scanning git folders...
dir %carg% ".git">"!clst!"
echo;

rem If git folders found
if exist "!clst!" (
	rem Get git 'xxx' command from batch file name ('git_xxx_all')
	for /f "delims=_ tokens=1,2*" %%i in ("%~n0") do (
		if "%%i"=="git" if "%%k"=="all" (
			set "vcmd=%%j"
		)
	)

	if not "!vcmd!"=="" (
		set "vout=!vcmd!"
		rem Set display in UPPERCASE
		for %%b in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set "vout=!vout:%%b=%%b!"
		rem Set command in lowercase (because git is case sensitive)
		for %%b in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "vcmd=!vcmd:%%b=%%b!"
REM		echo TODO : !vcmd!

		rem For all paths found (yet not checked as valid)
		for /f "delims=" %%i in (!clst!) do (
REM			echo %%i
			set "vdir=%%i"
			rem Check if "valid"
			if exist "!vdir!\config" (
				rem Change path and apply git command
				cd /d "!vdir!\.."
				rem Replace starting path with '.\'
				call set "vdir=!vdir:%crel%=.\!"
				rem Display the folder without '\.git' (5 chars)
				echo === GIT !vout! : !vdir:~0,-5! =========
				git !vcmd! -v
				echo;
			)
		)

		echo Done...

		rem Restore path
		cd /d "%~dp0"
	) else (
		echo No git command found...
	)

	rem Delete git folders list
	del "%clst%" %fquiet%
)

rem Restore code page
chcp %cp%>nul
