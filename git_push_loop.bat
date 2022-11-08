@echo off && setlocal enabledelayedexpansion

rem Retry 'git push' until it works, by wenuam 2022
rem Used when many/large files are pushed (random timeout might occurs)

rem Reset counter
set /a tries=0

:repeat
rem Display current time
echo %time% ====================================================================
set /a tries+=1
rem Loop if it fails
(git push) || goto :repeat

rem Print number of times it tried
echo; %time% : Success! (tried %tries% times)
echo;

rem You may want to request user input before exiting
REM pause
