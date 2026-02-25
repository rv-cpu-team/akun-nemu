#ifndef  DEFS_H_
#define  DEFS_H_
#include <riscv/riscv.h>
#include <common.h>




//sdb.c
void 		sdb_set_batch_mode();

//cpu.c
void 		cpu_exec(uint64_t n);
const char* reg_name(int idx);
int 	    check_reg_idx(int idx);
int 	    check_csr_idx(int idx);
void        isa_csr_display(CPU_state *, const char *);
void        isa_reg_display(CPU_state *, const char *);
#define pc_self  (cpu.pc)
#define gpr(idx) (cpu.gpr[check_reg_idx(idx)])
#define csr(idx) (cpu.csr[check_csr_idx(idx)])
void 		get_cpu_state_from_npc();
void 		init_regex();



//init_monitor.c
void 		init_monitor(int , char **);
void 		init_log(const char *log_file);
void 		init_difftest(char *ref_so_file, long img_size, int port);
void 		init_trace();
void        init_cpu();

void init_disasm(const char *triple);
void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);


//timer.c
void		init_rand();

void fetch_decode_exec(decode_t* s);
void init_cpu();


//disasm.cc
void        difftest_step(reg_t pc, reg_t next_pc, u32 instr);
bool        isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc);


uint64_t get_time();


//memory.c
void 	    init_mem();
uint8_t*    guest_to_host(paddr_t paddr);
reg_t	    pmem_read(paddr_t addr, int len);
void	    pmem_write(paddr_t addr, int len, reg_t data);
void paddr_write(paddr_t addr, int len, reg_t data);
reg_t paddr_read(paddr_t addr, int len);

void        instr_trace_dispatch(u64 pc, u32 instr, u64 instr_count);
void        instr_itrace_display();
//sim
void        sim_exit(const char *msg);
//
bool        log_enable();


//全局变量
extern u64 sim_instr_count;
extern CPU_state cpu;
extern uint8_t pmem[CONFIG_MSIZE];
extern SIMState   sim_state;
extern FILE *log_fp;
extern u64 sim_time;
extern u64 clk_count;
void        update_sim_clk_count();
void        update_instr_count();
bool        instr_exec_one_million();

#endif
