#!bin/bash
      dtrace -s dtrace_disk/open_close_read_lseek.d -c "/opt/csw/bin/iozone -+u -i 0 -S 20480 -s 1g -l 1 -u 1 -F /diskHitachi/a57816/iozone.DUMMY.0" >> dtrace_output_write_new_26_april_1gb_WRITE_UFS.txt
      

