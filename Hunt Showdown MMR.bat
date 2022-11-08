::============Default Settings============::
set Utf=Off
set Active=Team
cls
@Echo off

::============Git-Pull============::

::============Cache Variables============::
if not exist MMRCache.txt (
color 2
Set "Colour=2"
goto PreNameChanger
) else (
for /f "tokens=1,2 delims==" %%a in (MMRCache.txt) do (
    if %%a==GameLoc set %%a=%%b
    if %%a==HunterName set %%a=%%b
    if %%a==Colour set %%a=%%b
    if %%a==Active set %%a=%%b
    if %%a==Utf set %%a=%%b
)
goto MMRCheck
)

::============Home Screen============::
:Home
cls
echo Welcome, %USERNAME%
echo.
echo Your Game ID is: %HunterName%
echo Your Current Location is: %GameLoc%
echo.
if %MMR% LEQ 2000 goto a1
if %MMR% GEQ 2000 if %MMR% LSS 2300 goto a2
if %MMR% GEQ 2300 if %MMR% LSS 2600 goto a3
if %MMR% GEQ 2600 if %MMR% LSS 2750 goto a4
if %MMR% GEQ 2750 if %MMR% LSS 3000 goto a5
if %MMR% GEQ 3000 goto a6
if %MMR% EQU -1 goto a7

:a1
Set Star=1
goto mmrEnd

:a2
Set Star=2
goto mmrEnd

:a3
Set Star=3
goto mmrEnd

:a4
Set Star=4
goto mmrEnd

:a5
Set Star=5
goto mmrEnd

:a6
Set Star=6
goto mmrEnd

:a7
Echo Your Current MMR is Unknown 
goto mmrSkip

:mmrEnd
goto MMRTargets
:ReturnFromMMRTargets
set NextStar=%Star%
set /a NextStar+=1
set /a TargetMMR-=%MMR%
set PMMR=%MMR%
set /a PMMR-=%PreviousMMR%
if %TargetMMR% LSS %PMMR% (set DMMR=%TargetMMR% points to %NextStar% star)
if %TargetMMR% GTR %PMMR% (set DMMR=%PMMR% points to %Star% star)

Echo Your Current Estimated MMR is: %Star% star at %MMR% [-%PMMR%^|+%TargetMMR%]

echo Current MMR Search Mode: %Active%

echo _________________________________
:mmrSkip

echo What would you like to do?
echo.
echo 1. Update MMR
echo 2. Check MMR Ratings
echo 3. Change Game Location
echo 4. Change Name
echo 5. Get Player List
echo 6. Settings
echo 0. Quit
echo.

set /p choice="Enter your choice: "

if "%choice%"=="1" cls
if "%choice%"=="1" goto MMRCheck
if "%choice%"=="2" cls
if "%choice%"=="2" goto MMRRating
if "%choice%"=="3" cls
if "%choice%"=="3" goto FileLocation
if "%choice%"=="4" cls
if "%choice%"=="4" goto PostNameChanger
if "%choice%"=="5" goto GetPlayerList
if "%choice%"=="6" goto Settings
if "%choice%"=="7" goto Home
if "%choice%"=="8" goto Home
if "%choice%"=="9" goto Home
if "%choice%"=="0" exit
FOR /F "tokens=* delims=-0123456789" %%G IN ("%choice%") DO goto Home
echo Lunching.: %choice%
echo.


::============Pre-Name Changer============::

:PreNameChanger:
cls
echo Please Input Your Username
set /p HunterName=Enter Name: 

echo.%HunterName%| findstr /R >nul 2>&1
if ErrorLevel 1 (
 if "%HunterName:~3%"=="" (
cls
  echo %HunterName% - 4 CHARACTERS OR MORE
pause
 goto PostNameChanger
 )
goto FileLocation
)

::============Post-Name Changer============::

:PostNameChanger
cls
echo Please Input Your Username
set /p HunterName=Enter Name: 

echo.%HunterName%| findstr /R >nul 2>&1
if ErrorLevel 1 (
 if "%HunterName:~3%"=="" (
cls
  echo %HunterName% - 4 CHARACTERS OR MORE
pause
 goto PostNameChanger
 )
For /F "Tokens=2 Delims=:" %%A In ('"Find "" ":%HunterName:~,1%" 2>&1"') Do set HunterName=%%A%HunterName:~1%
goto CacheSave
)

::============Check MMR============::

:MMRCheck
cls
color %Colour%

>nul findstr /i /C:"name\" value=\"%HunterName%" "%GameLoc%" && (
  Echo Refreshing....
) || (
  cls
echo No Name Detected in Recent Matches. Please Use Another.
Set MMR=-1
@Pause
goto Home
)

for /f "usebackq tokens=2 delims=, " %%i  in (`findstr /l "%HunterName%" "%GameLoc%"`) do (
set "PlayerIndex=%%i"
if %Active%==Team goto foundtarget
)
:foundtarget 
set PlayerIndex=%PlayerIndex:~22,5%
:: Position, Length
if Not [%PlayerIndex:~-1%]==[_] set PlayerIndex=%PlayerIndex%_
set PlayerIndex=%PlayerIndex%mmr
for /f tokens^=4^ delims^=^" %%a in ('findstr /I %PlayerIndex% "%GameLoc%"') do (set "MMR=%%a")
::set MMR=%MMR:~-11%

GoTo Home

::============File Location============::

:FileLocation
@echo off
cls

Title Folder Selection
echo( Select Hunt Showdown Installation folder . . .
call:FolderSelection "%SourcePath%", SourcePath, "Select Folder"

if Not "%SourcePath%"=="%SourcePath:Hunt=%" (
if "%SourcePath%"=="%SourcePath:user=%" (
set "GameLoc=%SourcePath%\user\profiles\default\attributes.xml"
) else (
set "GameLoc=%SourcePath%"
)
set "HasLocation=true"
goto CacheSave
) else (
cls	
echo Incorrect File Location, Please Select the "Hunt Showdown" Folder, where the game is installed
echo -------------------
@pause
goto FileLocation
)



Rem ---------------------------------------------------------------------------------------------------------
:FolderSelection <SelectedPath> <folder> <Description>
SetLocal & set "folder=%~1"
set "dialog=powershell -sta "Add-Type -AssemblyName System.windows.forms^
|Out-Null;$f=New-Object System.Windows.Forms.FolderBrowserDialog;$f.SelectedPath='%~1';$f.Description='%~3';^
$f.ShowNewFolderButton=$false;$f.ShowDialog();$f.SelectedPath""
for /F "delims=" %%I in ('%dialog%') do set "res=%%I"
EndLocal & (if "%res%" EQU "" (set "%2=%folder%") else (set "%2=%res%"))
exit/B 0
Rem ---------------------------------------------------------------------------------------------------------

::============Save Cache============::

:CacheSave
(
  echo GameLoc=%GameLoc%
  echo HunterName=%HunterName%
  echo Colour=%Colour%
  echo Active=%Active%
  echo Utf=%Utf%
) > MMRCache.txt

goto MMRCheck

::============Settings Select============::
:Settings
cls
echo 1.  MMR Solo/Team[Will scan for a: %Active% Profile] 
echo 2.  Toggle UTF-8 [Currently %Utf%]
echo 3.  Change Text Colour
echo 4.  Return
echo 0.  Quit

set /p choice="Enter your choice: "
if "%choice%"=="1" goto ChangeActive 
if "%choice%"=="1" goto Settings
if "%choice%"=="2" goto ChangeActive2
if "%choice%"=="3" goto ColourSelect
if "%choice%"=="4" goto MMRCheck
if "%choice%"=="5" goto Settings
if "%choice%"=="6" goto Settings
if "%choice%"=="7" goto Settings
if "%choice%"=="8" goto Settings
if "%choice%"=="9" goto Settings
if "%choice%"=="0" exit
FOR /F "tokens=* delims=-0123456789" %%G IN ("%choice%") DO goto Settings

:ChangeActive

if %Active%==Team (set Active=Solo
goto CacheSave)
if Not %Active%==Team (set Active=Team
goto CacheSave)

:ChangeActive2

if %Utf%==Off (set chcp=65001)
if %Utf%==Off (set Utf=On
goto CacheSave)


if %Utf%==On (set chcp=437)
if %Utf%==On (set Utf=Off
goto CacheSave)
::============Colour Select============::

:ColourSelect
cls
echo Welcome, %USERNAME%
echo What colour would you like to have?
echo.
echo 1.  Dark Blue
echo 2.  Green
echo 3.  Blue V2
echo 4.  Red
echo 5.  Purple
echo 6.  Yellow
echo 7.  White
echo 8.  Gray
echo 9.  Bright Blue
echo +.  Back to startup screen
echo 0.  Quit

set /p choice="Enter your choice: "
if "%choice%"=="1" color 1
if "%choice%"=="1" set "Colour=1"
if "%choice%"=="1" cls
if "%choice%"=="1" goto CacheSave
if "%choice%"=="2" color 2
if "%choice%"=="2" set "Colour=2"  
if "%choice%"=="2" cls
if "%choice%"=="2" goto CacheSave
if "%choice%"=="3" color 3
if "%choice%"=="3" set "Colour=3" 
if "%choice%"=="3" cls
if "%choice%"=="3" goto CacheSave
if "%choice%"=="4" color 4
if "%choice%"=="4" set "Colour=4" 
if "%choice%"=="4" cls
if "%choice%"=="4" goto CacheSave
if "%choice%"=="5" color 5
if "%choice%"=="5" set "Colour=5"
if "%choice%"=="5" cls
if "%choice%"=="5" goto CacheSave
if "%choice%"=="6" color 6
if "%choice%"=="6" set "Colour=6"
if "%choice%"=="6" cls
if "%choice%"=="6" goto CacheSave
if "%choice%"=="7" color 7
if "%choice%"=="7" set "Colour=7"
if "%choice%"=="7" cls
if "%choice%"=="7" goto CacheSave
if "%choice%"=="8" color 8
if "%choice%"=="8" set "Colour=8"
if "%choice%"=="8" cls
if "%choice%"=="8" goto CacheSave
if "%choice%"=="9" color 9
if "%choice%"=="9" set "Colour=9"
if "%choice%"=="9" cls
if "%choice%"=="9" goto CacheSave
if "%choice%"=="+" cls
if "%choice%"=="+" goto Home
if "%choice%"=="-" cls
if "%choice%"=="0" exit
FOR /F "tokens=* delims=-0123456789" %%G IN ("%choice%") DO goto ColourSelect

::============MMR Ratings============::

:MMRRating

echo ________________________________________
echo.      
echo                  General
echo ________________________________________
echo.
if Not %MMR% EQU -1 (echo Your Estimated MMR is: %MMR%)
if %MMR% EQU -1 (echo Your Current Estimated MMR is Unknown 
goto MMRRatingSkip)
if %Star% EQU 6 (Echo You Reached the Max Star-Rating!)
if Not %Star% EQU 6 (echo You Are %TargetMMR% points away from gaining your %NextStar% Star)
if %Star% EQU 1 (Echo You Are at the Lowest Star-Rating Possible!)
if Not %Star% EQU 1 (echo You Are %PMMR% points away from losing your %Star% Star)

:MMRRatingSkip
echo ________________________________________
echo.
echo                  MMR Ranges
echo ________________________________________
echo.
echo.          
echo.
echo.    
echo      1 Star                             3 Star           5 Star   
echo     [0==========1000==========2000------2300------2600---2750-----3000====================5000]
echo.                              2 Star              4 Star          6 Star
echo.
echo.
echo                "=" is increments of 100 MMR ^| "-" is increments of 50 MMR
echo.
echo.
echo.
@pause

goto Home

:MMRTargets

if %Star% EQU 1 goto b1
if %Star% EQU 2 goto b2
if %Star% EQU 3 goto b3
if %Star% EQU 4 goto b4
if %Star% EQU 5 goto b5


:b1
Set TargetMMR=2000
goto MMRDownTargets

:b2
Set TargetMMR=2300
goto MMRDownTargets

:b3
Set TargetMMR=2600
goto MMRDownTargets

:b4
Set TargetMMR=2750
goto MMRDownTargets

:b5
Set TargetMMR=3000
goto MMRDownTargets


:MMRDownTargets
if %Star% EQU 1 goto c0
if %Star% EQU 2 goto c1
if %Star% EQU 3 goto c2
if %Star% EQU 4 goto c3
if %Star% EQU 5 goto c4
if %Star% EQU 6 goto c5

:c0
Set PreviousMMR=-1
goto ReturnFromMMRTargets

:c1
Set PreviousMMR=1999
goto ReturnFromMMRTargets

:c2
Set PreviousMMR=2299
goto ReturnFromMMRTargets

:c3
Set PreviousMMR=2599
goto ReturnFromMMRTargets

:c4
Set PreviousMMR=2749
goto ReturnFromMMRTargets

:c5
Set PreviousMMR=2999
goto ReturnFromMMRTargets


::============Get List of Players============::
:GetPlayerList
cls
echo =============Player List=============
for /f tokens^=4^ delims^=^" %%a in ('findstr /I "blood_line_name" "%GameLoc%"') do (
if Not "%%a"=="/>" echo %%a
)
echo =====================================
echo.
pause
goto Home



::============Kill Death Calc============::
::>1 findstr /i /C:"_downedbyme\" value=\"0" "%GameLoc%" && (
:KD
goto  Home
Set PreMMR=%MMR%
Set "Calc=5"

>TempCache.txt findstr /i /C:"_downedbyme\" value=\"" "%GameLoc%" && (
echo Getting Values...
)

>ValuesCache.txt findstr /V /i /C:"_downedbyme\" value=\"0" "TempCache.txt" && (
echo ValuesCached
Del TempCache.txt
)
for /f "usebackq tokens=2 delims=, " %%i  in (`findstr /i /C:"_downedbyme" "ValuesCache.txt"`) do (
echo %%i
set "PlayerIndex=%%i"
)

set PlayerIndex=%PlayerIndex:~22,5%
:: Position, Length
if Not [%PlayerIndex:~-1%]==[_] set PlayerIndex=%PlayerIndex%_
set PlayerIndex=%PlayerIndex%downedbyme
for /f tokens^=4^ delims^=^" %%a in ('findstr /I %PlayerIndex% "%GameLoc%"') do (
set "Num=%%a"
)

for /f "usebackq tokens=2 delims=, " %%i  in (`findstr /i /C:"_downedbyme" "ValuesCache.txt"`) do (
echo %%i
set "PlayerIndex=%%i"
)

set PlayerIndex=%PlayerIndex:~22,5%
:: Position, Length
if Not [%PlayerIndex:~-1%]==[_] set PlayerIndex=%PlayerIndex%_
set PlayerIndex=%PlayerIndex%MMR
for /f tokens^=4^ delims^=^" %%a in ('findstr /I %PlayerIndex% "%GameLoc%"') do (set "EnemyMMR=%%a")
::echo %EnemyMMR%

if %MMR% GEQ %EnemyMMR% (
set Diff=%MMR%
set Dom=%EnemyMMR%
set "Multiplier=1"
)
if %MMR% LSS %EnemyMMR% (
set Diff=%EnemyMMR%
set Dom=%MMR%
set "Multiplier=2"
)

set /a Diff-=Dom
set BaseMMR=%Diff%
set /a BaseMMR/=10*%Multiplier%

echo 1 %Diff%
echo 2 %BaseMMR%

set /a MMR-=BaseMMR
echo 3 %MMR%
@pause


::set /a Calc+=Num
echo %Calc%
)
echo %Calc%
@pause
::for /f "usebackq tokens=2 delims=, " %%i  in (`findstr /i /C:"_downedbyme" "%GameLoc%"`) do (
for /f tokens=^=4^ delims^=^" %%i  in (`findstr /i /C:"_downedbyme" "%GameLoc%"`) do (
echo %%i
set "PlayerIndex=%%i"
)
set PlayerIndex=%PlayerIndex:~22,5%
:: Position, Length
if Not [%PlayerIndex:~-1%]==[_] set PlayerIndex=%PlayerIndex%_
set PlayerIndex=%PlayerIndex%mmr
for /f tokens^=4^ delims^=^" %%a in ('findstr /I %PlayerIndex% "%GameLoc%"') do (set "Calc=%%a")
echo %PlayerIndex%
echo %Calc%
)
@pause
set /a MMR+=Calc
goto Home
