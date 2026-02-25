#include <common.h>
#include <riscv.h>

CPU_state cpu; 
u64 *reg_ptr = NULL;
u64 *csr_ptr = NULL;



const char *regs[] = {
  "$0", "ra", "sp",  "gp",  "tp", "t0", "t1", "t2",
  "s0", "s1", "a0",  "a1",  "a2", "a3", "a4", "a5",
  "a6", "a7", "s2",  "s3",  "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

int check_reg_idx(int idx) {
  assert(idx >= 0 && idx < GPR_NUM);
  return idx;
}
int check_csr_idx(int idx){
  assert(idx >= 0 && idx < CSR_NUM);
  return idx;
}
const char* reg_name(int idx) {
  extern const char* regs[];
  return regs[check_reg_idx(idx)];
}


void init_cpu(){
  cpu.pc = 0x80000000;
  for(int i = 0; i < 32; ++i){
    cpu.gpr[i] = 0;
  }
  for(int i = 0; i < 4096; ++i){
    cpu.csr[i] = 0;
  }
}




void isa_reg_display(CPU_state *state, const char *msg) {
    const char *prefix = (msg != NULL) ? msg : "CPU";

    printf("\n--- Reg [%s] ---\n", prefix);
    for (int i = 0; i < GPR_NUM; i++) {
        printf("%-4s: 0x%016lx\n", reg_name(i), state->gpr[i]);
    }
    printf("pc  : 0x%016lx\n", state->pc);
    printf("--------------------------------------\n");
}


