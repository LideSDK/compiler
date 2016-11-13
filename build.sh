#!/bin/bash
gcc -I/usr/include/lua5.1 -o srlua/srlua srlua/srlua.c -llua5.1 -lm
gcc -I/usr/include/lua5.1 -o srlua/glue srlua/glue.c -llua5.1 -lm

./srlua/glue lib/precolide_lnx86 lidec.lua ./lidec

echo "> Lide compiler builded successfuly."
