@echo off
REM Define the target output file name
set PDF_FILE_NAME=install_instructions.pdf

REM Define the pandoc variables
set PANDOC_VARS=-V geometry:margin=1in ^
  -V linkcolor:blue ^
  -V urlcolor:blue

REM Define the list of input files for pandoc
set INPUT_FILES=README.md ^
  Install.md ^
  helm\openshift-gitops\README.md ^
  helm\openshift-gitops-day2\README.md ^
  docs\vm-migration-notes.md

REM Check if required tools are installed
call :check_if_installed pandoc "Pandoc"
if errorlevel 1 goto :eof  REM Exit if pandoc is not installed

call :check_if_installed pdflatex "LaTeX (MiKTeX, TeX Live LaTeX, etc.)"
if errorlevel 1 goto :eof  REM Exit if pdflatex is not installed

REM Generate PDF with pandoc
call :generate_pdf
goto :eof


REM 
REM Methods defined below; main script flow ends above this
REM 

REM 
REM Method to verify that a particular tool exists on the Windows PATH
REM 
:check_if_installed
where %1 > nul 2> nul
if errorlevel 1 (
    echo %2 is not installed.
    echo Please install %2 manually before continuing.
    exit /b 1  REM This exits the method with an error level 1, indicating failure
) else (
    echo %2 is already installed.
)
goto :eof

REM 
REM Method to generate the PDF with Pandoc
REM 
:generate_pdf
echo Generating PDF using Pandoc...
pandoc ^
  -f markdown ^
  --metadata=title:"Disconnected OpenShift and VM Migration" ^
  %PANDOC_VARS% ^
  -o %PDF_FILE_NAME% ^
  %INPUT_FILES%
if errorlevel 1 (
    echo Pandoc failed to generate the PDF.
    exit /b 1
)
echo PDF generated: %PDF_FILE_NAME%
goto :eof
