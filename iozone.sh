#!/bin/bash 
SIZE = 180

/opt/csw/bin/iozone -R -i 0  -g 180G -s $SIZEg -r 16384 -b teste$SIZE.xls -l 1 -u 1 

