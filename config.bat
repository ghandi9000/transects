rem Data configuration/package setup
@echo off
for /f "tokens=*" %%G IN ('dir /B /A:D "C:\Program Files\R"') DO (
    set rdir="C:\Program Files\R\%%G\bin"
)

ECHO adding %rdir% temporarily to PATH
@if exist %rdir% set PATH=%rdir%;%PATH%

cd ./explore
Rscript config.R

pause
