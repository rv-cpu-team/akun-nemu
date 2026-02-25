#include <riscv.h>
#include <common.h>
#include <defs.h>

extern u64 timer_start;
extern u64 timer_end;

void sim_exit(const char *msg){

    timer_end   = get_time();
    u64 timer_use = timer_end - timer_start;
    u64 total_sec = timer_use / 1000000;
    u64 minutes = total_sec / 60;
    u64 seconds = total_sec % 60;
    printf("\n[Timer] 程序运行耗时: %lu min %lu s (%lu us)\n",  minutes, seconds, timer_use);
    Log("%s\n", msg);
    exit(1);
}



