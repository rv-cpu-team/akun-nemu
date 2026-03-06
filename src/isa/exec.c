#include <riscv.h>
#include <common.h> //types.h
#include <defs.h>
#include <types.h>
u64 sim_clk_count   = 0;
u64 sim_instr_count = 0;
u64 sim_time        = 0;

u64  get_sim_clk_count()      {  return sim_clk_count;    }


reg_t csr_read(reg_t csr_id);
void execute(uint64_t n){
  for (   ;n > 0; n --) {
    decode_t s;
    s.pc = cpu.pc;
    fetch_decode_exec(&s);
    //update pc
    cpu.pc = s.dnpc;
    sim_instr_count++;    
    if(sim_instr_count % 100000000 == 0 && sim_instr_count > 0) {
        printf("[cpu]已经执行了%ld条指令\n", sim_instr_count);
    }
    IFDEF(CONFIG_TRACE,     instr_trace_dispatch(s.pc, s.instr, sim_instr_count));
    IFDEF(CONFIG_DIFFTEST,  difftest_step(s.pc, s.dnpc, s.instr));        
  }
}



u64 timer_start = 0;
u64 timer_end   = 0;
void cpu_exec(uint64_t n) {
  timer_start = get_time();
  execute(n); 
}


