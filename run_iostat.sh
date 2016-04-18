#!bin/bash

iostat 1  >iostat_iozone_write.out &
/opt/csw/bin/iozone -+u -R -i 0 -S 20480 -s 39g -b /export/home/a57816/ESC_ACTIVE_BENCHMARKING_HOME/teste_write.xls -l 1 -u 1

sleep 5
kill $!
echo "$! killed"
