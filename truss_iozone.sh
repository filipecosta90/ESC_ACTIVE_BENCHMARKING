#!/bin/bash 

truss -o truss_small_report_write.txt -df /opt/csw/bin/iozone -R -i 0 -S 20480 -s 500m -b /export/home/a57816/ESC_ACTIVE_BENCHMARKING_HOME/teste_write.xls -l 1 -u 1 

