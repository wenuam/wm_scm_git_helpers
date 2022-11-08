@echo off && setlocal enabledelayedexpansion

rem Apply git command on subfolder tree, by wenuam 2022
rem 'git_xxx_all' -> 'git xxx' on all '*(\.git\config)' found

rem Set code page to utf-8 (/!\ this file MUST be in utf-8, BOM or not)
for /f "tokens=2 delims=:." %%x in ('chcp') do set cp=%%x
chcp 65001>nul

rem Set look-up parameters
set "cdir=/B /A:D /ON /S"
set "cfil=.cdir.txt"

rem Set "quiet" suffixes
set "quiet=1>nul 2>nul"
set "fquiet=/f /q 1>nul 2>nul"

rem Get git folders
del "%cfil%" %fquiet%
dir %cdir% ".git">"%cfil%"

rem If git command found
if exist "%cfil%" (
	rem Get git command from batch file name ('git_xxx_all')
	for /f "delims=_ tokens=1,2*" %%i in ("%~n0") do (
		if "%%i"=="git" if "%%k"=="all" (
			set "todo=%%j"
		)
	)

	if not "!todo!"=="" (
		set "disp=!todo!"
		rem Set display in UPPERCASE
		for %%b in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set "disp=!disp:%%b=%%b!"
		rem Set command in lowercase (because git is case sensitive)
		for %%b in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "todo=!todo:%%b=%%b!"
		rem echo TODO : !todo!

		rem For all paths found (yet not checked as valid)
		for /f "delims=" %%i in (.cdir.txt) do (
			rem echo %%i
			set "cnf=%%i"
			rem Check if "valid"
			if exist "!cnf!\config" (
				rem Change path and apply git command
				cd /d "!cnf!\.."
				echo === GIT !disp! : !cnf:~0,-5! =========
				git !todo! -v
				echo;
			)
		)

		rem Restore path
		cd /d "%~dp0"
		rem Delete git folders list
		del "%cfil%" %fquiet%
	)
)

rem Restore code page
chcp %cp%>nul
