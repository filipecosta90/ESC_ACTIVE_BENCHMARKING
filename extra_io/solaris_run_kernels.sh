#!bin/bash

rm -r __csv

echo "running tests for NFS"
for seq in 1 2 3 4 5 6 7 8 9 10
do
  echo "test number $seq" 
  dtrace -s threaded.d -c "./io -c  -b 4096 -t 104857600 100MB.out" > "DTRACE_IO_CREATE_NFS_JADE_"$seq".csv"
  mv IO_OUT.txt  "nfs_$seq.time"
done

echo "running tests for UFS"
for seq in 1 2 3 4 5 6 7 8 9 10
do
  echo "test number $seq" 
  dtrace -s threaded.d -c "./io -c -b 4096 -t 104857600 /diskHitachi/a57816/100MB.out" > "DTRACE_IO_CREATE_UFS_HITACHI_"$seq".csv"
  mv IO_OUT.txt  "ufs_$seq.time"
done

echo "running tests for ZFS"
for seq in 1 2 3 4 5 6 7 8 9 10
do
  echo "test number $seq" 
  dtrace -s threaded.d -c "./io -c -b 4096 -t 104857600 /export/home/a57816/100MB.out" > "DTRACE_IO_CREATE_ZFS_HOME_"$seq".csv"
  mv IO_OUT.txt  "zfs_$seq.time"
done

mkdir __csv
mv DTRACE*.csv __csv
