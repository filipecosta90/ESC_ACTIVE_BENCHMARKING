#!/usr/sbin/dtrace -s

#pragma D option quiet

dtrace:::BEGIN{
  opp_num = 1;

}

syscall::open*:entry{
  self->pathname = copyinstr(arg1);
}

syscall::open*:return
/strstr(self->pathname,"iozone.DUMMY.0") != NULL /
{
  flag = 1;
}

syscall::read*:entry
/flag == 1/
{
  self->time_in = timestamp;
  @total_r_size[opp_num] =  sum (arg2/1024);
}

syscall::read*:return
/flag == 1/
{
  self->time_out = timestamp;
  self->total_time = self->time_out - self->time_in;
  @total_time[opp_num] = sum  (self->total_time);
}

syscall::fdsync:entry
/flag == 1/
{
  self->time_in = timestamp;
  @total_fdsync[opp_num] =  count();
}

syscall::fdsync:return
/flag == 1/
{
  self->time_out = timestamp;
  self->total_time = self->time_out - self->time_in;
  @total_time[opp_num] = sum  (self->total_time);
}


syscall::write*:entry
/flag == 1/
{
  self->time_in = timestamp;
  @total_w_size[opp_num] =  sum  (arg2/1024);
}

syscall::write*:return
/flag == 1/
{
  self->time_out = timestamp;
  self->total_time = self->time_out - self->time_in;
  @total_time[opp_num] =  sum (self->total_time);
}

syscall::lseek:entry
/flag == 1/
{
  self->time_in = timestamp;
  @lseek_offset[opp_num] = quantize (arg1);
  @lseek_count[opp_num] = count();
}

syscall::lseek:return
/flag == 1/
{
  self->time_out = timestamp;
  self->total_time = self->time_out - self->time_in;
  @total_time[opp_num] =  sum (self->total_time);
}


syscall::close*:entry
/flag == 1/
{
  flag = 0;
  opp_num = opp_num + 1;
}

dtrace:::END{
  printf("%-10s %10s %10s %10s %10s %10s\n","#opp", "Time elapsed", "T. Wr. KB", "T. Rd. KB", "#fdsync", "#lseek");
  printa("%-10d %10@d %10@d %10@d %10@d\n", @total_time , @total_w_size, @total_r_size, @total_fdsync, @lseek_offset );
  printf("\n\n Lseek offset analysis:\n");
  printa(@lseek_offset);
}

