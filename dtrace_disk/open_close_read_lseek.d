#!/usr/sbin/dtrace -s

#pragma D option quiet

dtrace:::BEGIN{
  opp_num = 1;

}

syscall::openat*:entry{
  self->time_in = timestamp;
  self->file = arg1;
}

syscall::openat*:return
/self->file /
{
  self->pathname = copyinstr(self->file);
  flag = (strstr(self->pathname,"iozone.DUMMY.0") != NULL ) ?  1 : 0; 
  self->time_out = timestamp;
  self->total_t = (strstr(self->pathname,"iozone.DUMMY.0") != NULL ) ? ( self->time_out - self->time_in ) / 1000 : 0 ;
  @total_time[opp_num] = sum  (self->total_t);
  @nofdsync_time[opp_num] = sum (self->total_t);
}

syscall::read*:entry
/flag == 1/
{
  self->time_in = timestamp;
  self->r_size = arg2/1024;
  @total_r_size[opp_num] =  sum (self->r_size);
}

syscall::read*:return
/flag == 1 &&  self->r_size/
{ 
  self->time_out = timestamp;
  self->total_t = ( self->time_out - self->time_in ) / 1000;
  @total_time[opp_num] = sum  (self->total_t);
  @nofdsync_time[opp_num] = sum (self->total_t);
  self->r_size = 0;
}

syscall::fdsync*:entry
/flag == 1/
{
  self->time_in = timestamp;
  @total_fdsync[opp_num] =  count();
}

syscall::fdsync*:return
/flag == 1 /
{
  self->time_out = timestamp;
  self->total_t = ( self->time_out - self->time_in )/ 1000;
  @total_time[opp_num] = sum  (self->total_t);

}


syscall::write*:entry
/flag == 1/
{
  self->time_in = timestamp;
  self->w_size = arg2 / 1024;
  @total_w_size[opp_num] =  sum (self->w_size);
}

syscall::write*:return
/flag == 1 && self->w_size/
{
  self->time_out = timestamp;
  self->total_t = ( self->time_out - self->time_in )/ 1000;
  @total_time[opp_num] = sum  (self->total_t);
  @nofdsync_time[opp_num] = sum (self->total_t);
  self->w_size = 0;
}

syscall::lseek*:entry
/flag == 1 /
{
  self->time_in = timestamp;
  @lseek_offset[opp_num] = quantize (arg1);
  @lseek_count[opp_num] = count();
}

syscall::lseek*:return
/flag == 1 /
{
  self->time_out = timestamp;
  self->total_t = ( self->time_out - self->time_in ) / 1000;
  @total_time[opp_num] = sum  (self->total_t);
  @nofdsync_time[opp_num] = sum (self->total_t);
}

syscall::close*:entry
/flag == 1 /
{
  self->time_in = timestamp;
}


syscall::close*:return
/flag == 1 /
{
  self->time_out = timestamp;
  self->total_t = ( self->time_out - self->time_in ) / 1000;
  @total_time[opp_num] = sum  (self->total_t);
  @nofdsync_time[opp_num] = sum (self->total_t);
  opp_num = opp_num + 1;
  flag = 0;
}

dtrace:::END{
  printf("%-5s\t%20s\t%20s\t%15s\t%15s\t%10s\t%10s\n","#opp", "Total T. elapsed", "No fdsynk T. elapsed", "T. Wr. KB", "T. Rd. KB", "#fdsync", "#lseek");
  printa("%-5d\t%@20d\t%@20d\t%@15d\t%@15d\t%@10d\t%@10d\n"       , @total_time       , @nofdsync_time      , @total_w_size, @total_r_size, @total_fdsync, @lseek_count );
  printf("\n\n Lseek offset analysis:\n\n\n\n\n\n");
  printa( @lseek_offset );

  clear ( @lseek_offset );
  clear ( @total_time );
  clear ( @nofdsync_time );
  clear ( @total_w_size );
  clear ( @total_r_size );
  clear ( @total_fdsync );
  clear ( @lseek_offset );

}

