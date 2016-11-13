#!/bin/bash
gcc -I /usr/include/lua5.1 -o ./tools/srlua-lnx86 ./tools/src/srlua.c -l lua5.1 -lm
gcc -I /usr/include/lua5.1 -o ./tools/glue-lnx86 ./tools/src/glue.c   -l lua5.1 -lm

./tools/glue-lnx86 ./tools/srlua-lnx86 lidec.lua ./lidec

echo "> Lide compiler builded successfuly."