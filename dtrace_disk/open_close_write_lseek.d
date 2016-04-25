#!/usr/sbin/dtrace -s

#pragma D option quiet

syscall::open*:entry{
  self->pathname = copyinstr(arg1);
}

syscall::open*:return
/strstr(self->pathname,"iozone.DUMMY.0") != NULL /
{
  self->start_total = timestamp; 
  total_size = 0;
  total_time = 0;
  flag = 1;
}

syscall::write*:entry
/flag == 1/
{
  self->time_in = timestamp;
}

syscall::write*:return
/flag == 1/
{
  self->time_out = timestamp;
  self->total_time = self->time_out - self->time_in;
  total_time = total_time + self->total_time;
}

syscall::close*:entry
/total_time > 0 && self->start_total /
{
  self->stop_total = timestamp; 
  printf("\n\n###############################################\n");
  printf("t time: %d\n", self->stop_total - self->start_total );
  printf("w time: %d", total_time);
  printf("###############################################\n\n");
  flag = 0;
  total_time = 0;
}

