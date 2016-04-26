#!/usr/sbin/dtrace -s

#pragma D option quiet

dtrace:::BEGIN{
  opp_num = 1;

}

syscall::openat:entry{
  wall_time_in = timestamp;
  self->time_in = timestamp;
  self->pathname = copyinstr(arg1);
}

syscall::openat:return
/strstr(self->pathname,"iozone.DUMMY.0") != NULL /
{
  @total_time[opp_num] = sum  (timestamp - self->time_in );
  self->time_in = 0;
  flag = 1;
}

syscall::read:entry
/flag == 1/
{
  self->time_in = timestamp;
  @total_r_size[opp_num] =  sum (arg2/1024);
}

syscall::read:return
/flag == 1 && self->time_in /
{
  @total_time[opp_num] = sum  (timestamp - self->time_in );
  self->time_in = 0;
}

syscall::fdsync:entry
/flag == 1/
{
  self->time_in = timestamp;
  @total_fdsync[opp_num] =  count();
}

syscall::fdsync:return
/flag == 1 && self->time_in /
{
  @total_time[opp_num] = sum  (timestamp - self->time_in );
  self->time_in = 0;
}


syscall::write:entry
/flag == 1/
{
  self->time_in = timestamp;
  @total_w_size[opp_num] =  sum (arg2/1024);
  self->time_in = 0;
}

syscall::write:return
/flag == 1 && self->time_in /
{
  @total_time[opp_num] = sum  (timestamp - self->time_in );
  self->time_in = 0;
}

syscall::lseek:entry
/flag == 1 /
{
  self->time_in = timestamp;
  @lseek_offset[opp_num] = quantize (arg1);
  @lseek_count[opp_num] = count();
}

syscall::lseek:return
/flag == 1 && self->time_in /
{
  @total_time[opp_num] = sum  (timestamp - self->time_in );
  self->time_in = 0;
}

syscall::close:entry
/flag == 1 /
{
  self->time_in = timestamp;
}


syscall::close:return
/flag == 1 && self->time_in /
{
  @total_time[opp_num] = sum  (timestamp - self->time_in );
  @wall_time[opp_num] = sum(timestamp - wall_time_in);
  self->time_in = 0;
  wall_time_in = 0;
  opp_num = opp_num + 1;
  flag = 0;
}

dtrace:::END{
  printf("%-10s %20s %20s %20s %20s %20s %20s\n","#opp", "W.T. elapsed", "Syscall T. elapsed", "T. Wr. KB", "T. Rd. KB", "#fdsync", "#lseek");
  printa("%-10d %20@d %20@d %20@d %20@d %20@d\n", @wall_time, @total_time , @total_w_size, @total_r_size, @total_fdsync, @lseek_offset );
  printf("\n\n Lseek offset analysis:\n");
  printa(@lseek_offset);
}

