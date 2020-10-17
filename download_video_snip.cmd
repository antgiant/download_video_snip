: # This is a special script which intermixes both sh
: # and cmd code. It is written this way because it is
: # used in system() shell-outs directly in otherwise
: # portable code. See https://stackoverflow.com/questions/17510688
: # for details.
:<<"::CMDLITERAL"
@ECHO OFF
GOTO :CMDSCRIPT
: # -----------------------------------------------------
: # Bash Script Starts Here
: # -----------------------------------------------------
::CMDLITERAL
## Who am i? ##
## Get real path ##
_script="$(readlink -f ${BASH_SOURCE[0]})"
 
## Delete last component from $_script ##
_mydir="$(dirname $_script)"

## Set active path to this folder
cd "$_mydir"

while true; do
    read -n 1 -p "Do you want Audio only (MP3)? " yn
    case $yn in
        [Yy]* ) audio="-f bestaudio --extract-audio --audio-format mp3"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo ""

read -p "Please enter the Start Time in 00:00:00.000 format: " start_time
read -p "Please enter the End Time in 00:00:00.000 format (Blank for Entire Video): " end_time
read -p "Please enter the output filename (Blank for default): " filename
read -p "Please enter the video URL: " url

if [ -z "$start_time" ]
then
      start_time="-ss 0"
else
      start_time="-ss $start_time"
fi

if [ -z "$end_time" ]
then
      start_time=""
      end_time=""
else
      end_time="-t $end_time"
fi

if [ -z "$filename" ]
then
      filename=""
else
      filename="$filename.%(ext)s"
fi

./youtube-dl $audio "$filename" --embed-thumbnail --add-metadata --postprocessor-args "$start_time $end_time" "$url" 
echo ""
read -n 1 -p "Press Any Key to Continue"

exit $?
: # -----------------------------------------------------
: # Windows Part Starts Here
: # -----------------------------------------------------
:CMDSCRIPT
@REM Set active path to this folder
cd /D "%~dp0"

SET audio=
CHOICE /M "Do you want Audio only (MP3)? "
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
SET end_time=-to %end_time%
GOTO End_End
:Blank_End
SET end_time=
:End_End

IF NOT "%filename%" == "" GOTO Not_Blank
GOTO filename_done
:Not_Blank
SET filename=-o "%filename%.%%(ext)s"
:filename_done

@ECHO ON
@REM Download the entire Video
youtube-dl %audio% %filename% --embed-thumbnail --add-metadata --no-playlist "%url%" -v

@ECHO OFF
@REM Wait for youtube-dl to finish
timeout 3
@REM Get the filename youtube-dl just created
dir /O-d /TC /b >%TEMP%\temp_file_list.txt
set /p first_file=<%TEMP%\temp_file_list.txt
del %TEMP%\temp_file_list.txt

@ECHO ON
@REM Trim File
ffmpeg -i "%first_file%" %start_time% %end_time% "trimmed_%first_file%"
@REM Add back cover art
ffmpeg -y -i "%first_file%" -i "trimmed_%first_file%" -map 1 -codec copy -map 0:1 -map_metadata 0  -id3v2_version 3 "trimmed2_%first_file%"

@ECHO OFF
@REM Remove temp files.
timeout 3
move /Y "trimmed2_%first_file%" "%first_file%"
del "trimmed_%first_file%"

pause