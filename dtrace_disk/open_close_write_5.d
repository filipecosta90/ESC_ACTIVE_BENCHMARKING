#!/usr/sbin/dtrace -s

#pragma D option quiet

syscall::open*:entry
{
  self->pathname = copyinstr(arg1); 
}

syscall::open*:return
/strstr(self->pathname,"iozone.DUMMY.0") != NULL /
{
  self->start = timestamp; 
  total_size = 0;
}

fsinfo:::write 
/strstr(args[0]->fi_pathname,"iozone.DUMMY.0") != NULL /
{
  kb = arg1 / 1024;
  total_size = total_size + kb ; 
}

syscall::close*:return
/total_size > 0 && self->start /
{
  self->stop_t = timestamp; 
  printf("\n\n###############################################\n");
  printf("total time: %d\n", self->stop_t - self->start );
  printf("total size: %d\n", total_size);
  printf("###############################################\n\n");
  total_size = 0;
}
