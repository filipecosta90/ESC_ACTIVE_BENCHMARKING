#!bin/bash
      dtrace -s dtrace_disk/iofile.d -c "/opt/csw/bin/iozone -+u -R -i 0 -S 20480 -s 39g -b /export/home/a57816/ESC_ACTIVE_BENCHMARKING_HOME/teste_write.xls -l 1 -u 1" >> dtrace_iofile.txt
      dtrace -s dtrace_disk/iofileb.d -c "/opt/csw/bin/iozone -+u -R -i 0 -S 20480 -s 39g -b /export/home/a57816/ESC_ACTIVE_BENCHMARKING_HOME/teste_write.xls -l 1 -u 1" >> dtrace_iofileb.txt
      dtrace -s dtrace_disk/bitesize.d -c "/opt/csw/bin/iozone -+u -R -i 0 -S 20480 -s 39g -b /export/home/a57816/ESC_ACTIVE_BENCHMARKING_HOME/teste_write.xls -l 1 -u 1" >> dtrace_bitesize.txt

