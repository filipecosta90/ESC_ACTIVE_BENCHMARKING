#!/usr/sbin/dtrace -s

#pragma D option quiet

syscall::open*:return
/arg1 == 5/
{
 start = timestamp; 
  total_size = 0;
}

io:::start
{
      this->size = args[0]->b_bcount;

        /* store details */
        total_size  = total_size + this->size;
}

syscall::close*:return
/arg0 == 5/
{
 stop_t = timestamp; 
 printf("total time: %d\n", stop_t - start );
 printf("total bytes: %d\n", total_size );
 total_size = 0;
}
