@echo off
gcc -I ./include -l lib\win\lua5.1 -o ./srlua/srlua ./srlua/srlua.c -lm
gcc -I ./include -l lib\win\lua5.1 -o ./srlua/glue ./srlua/glue.c  -lm

./srlua/glue ./lib/precolide_win32 lidec.lua ./lidec.exe

echo "> Lide compiler builded successfuly."