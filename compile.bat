@echo off
:: コンパイル

echo src build
coffee -o "src/compiled/" -cb "src/script/"

pause
exit /b
