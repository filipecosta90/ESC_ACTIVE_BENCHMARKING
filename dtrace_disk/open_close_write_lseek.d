#!/usr/sbin/dtrace -s

#pragma D option quiet

syscall::open*:entry{
  self->pathname = copyinstr(arg1);
}

syscall::open*:return
/strstr(self->pathname,"iozone.DUMMY.0") != NULL /
{
  self->start = timestamp; 
  total_size = 0;
  total_time = 0;
  fd = 1;
}

syscall::write*:entry
/fd == 1/
{
 self->time_in = timestamp;
}

syscall::write*:return
/fd == 1/
{
 self->time_out = timestamp;
 total_time = self->time_out - self->time_in;
}

syscall::close*:return
/total_time > 0 && self->start /
{
  self->stop_t = timestamp; 
  printf("\n\n###############################################\n");
  printf("total time: %d\n", self->stop_t - self->start );
  printf("total write time: %d", total_time);
  printf("###############################################\n\n");
  fd = 0;
  total_time = 0;
}
