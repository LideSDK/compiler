@echo off
cd example_app
rmdir /S/Q release
mkdir release
lidec APP -o application.exe -i main.lua -pWIN32 -d .\release --noclean
lidec lib -o modulo -i "modulo.boton modulo.label" -pWIN32  -d .\release
cd ..