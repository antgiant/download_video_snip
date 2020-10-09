@ECHO OFF

@REM Set active path to this folder
cd /D "%~dp0"

SET audio=
CHOICE /M "Do you want Audio only (MP3)?" 
IF "%ERRORLEVEL%" == "1" GOTO Audio_Only
GOTO Audio_Done
:Audio_Only
SET audio=-f bestaudio --extract-audio --audio-format mp3
:Audio_Done

SET /p start_time=Please enter the Start Time in 00:00:00.000 format: 
SET /p end_time=Please enter the End Time in 00:00:00.000 format (Blank for Entire Video): 
SET /p filename=Please enter the output filename (Blank for default): 
SET /p url=Please enter the video URL: 

IF "%start_time%" == "" GOTO Blank_Start
GOTO End_Start
:Blank_Start
SET start_time=0
:End_Start
SET start_time=-ss %start_time%

IF "%end_time%" == "" GOTO Blank_End
SET end_time=-t %end_time%
GOTO End_End
:Blank_End
SET start_time=
SET end_time=
:End_End

IF NOT "%filename%" == "" GOTO Not_Blank
GOTO filename_done
:Not_Blank
SET filename=-o "%filename%.%%(ext)s"
:filename_done

@ECHO ON
youtube-dl %audio% %filename%  --embed-thumbnail --add-metadata --postprocessor-args "%start_time% %end_time%" "%url%" 
@pause