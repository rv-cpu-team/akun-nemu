
#include <dlfcn.h>
#include <common.h>
#include <defs.h>
#include <riscv.h>



void (*ref_difftest_memcpy)(reg_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;
uint64_t (*ref_difftest_get_csr)(uint64_t csr_id) = NULL;
const char* (*ref_difftest_get_csr_name)(int which) = NULL;

//我有一个这样的csr

void isa_reg_display(CPU_state *state, const char *msg);
#ifdef CONFIG_DIFFTEST

void init_difftest(char *ref_so_file, long img_size, int port) {
  assert(ref_so_file != NULL);
  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);
  ref_difftest_memcpy =  (void (*)(reg_t, void *, size_t, bool))dlsym(handle, "difftest_memcpy");
  assert(ref_difftest_memcpy);

  ref_difftest_regcpy = (void (*)(void *, bool))dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);


  ref_difftest_get_csr = (uint64_t (*)(uint64_t))dlsym(handle, "difftest_get_csr");
  assert(ref_difftest_get_csr);

  ref_difftest_get_csr_name = (const char* (*)(int))dlsym(handle, "difftest_get_csr_name");
  assert(ref_difftest_get_csr_name);


  ref_difftest_exec =  (void (*)(uint64_t))dlsym(handle, "difftest_exec");
  assert(ref_difftest_exec);

  ref_difftest_raise_intr = (void (*)(uint64_t))dlsym(handle, "difftest_raise_intr");
  assert(ref_difftest_raise_intr);

  void (*ref_difftest_init)(int) = (void (*)(int))dlsym(handle, "difftest_init");
  assert(ref_difftest_init);

  ref_difftest_init(port); //do nothing
  printf("RESET_VECTOR=%lx\n", RESET_VECTOR);


  //执行spike的difftest_memcpy函数，将处理器的内存写入到spike里面
  ref_difftest_memcpy(RESET_VECTOR, guest_to_host(RESET_VECTOR), img_size, DIFFTEST_TO_REF); 
  //执行spike的difftest_regcpy函数，将处理器的寄存器写入到spike里面
  ref_difftest_regcpy(&cpu, DIFFTEST_TO_REF);  
  Log("Difftest已打开");
}


bool csr_ignore(int id){
    return id == timer || id == instret;
}


static void display_regs_error(CPU_state *ref, u64 pc, u64 next_pc, const char *msg) {
    printf("\n%-9s\n", ANSI_FMT("DIFFTEST ERROR", ANSI_FG_YELLOW ANSI_BG_RED));         
    instr_itrace_display();
    printf("[NPC] 执行完 pc=[0x%016lx] 处的指令后出错。错误原因: %s%s%s\n", pc, ANSI_FG_RED, msg, ANSI_NONE);
    if (next_pc != ref->pc) {
        printf("\n%s* [PC] 执行完 pc=[0x%016lx] 处的指令后，PC 出现不一致! \t[REF]=0x%016lx, [DUT]=0x%016lx%s\n", ANSI_FG_RED, pc, ref->pc, next_pc, ANSI_NONE);
    } 
    printf("\n----------- 寄存器状态对比 (REF vs DUT) -----------\n");
    for (int i = 0; i < 32; i++) {
        bool mismatch = (ref->gpr[i] != cpu.gpr[i]);
        const char* color = mismatch ? ANSI_FG_RED : "";
        printf("%s%c [REF.%-3s]=0x%016lx | [DUT.%-3s]=0x%016lx%s\n", color, mismatch ? '*' : ' ', reg_name(i), ref->gpr[i], reg_name(i), cpu.gpr[i], ANSI_NONE);
    }
    sim_exit("[NPC] Difftest 终止，请检查上述差异。");
}

static void checkregs(CPU_state *ref, u64 pc, u64 next_pc) {
    if (next_pc != ref->pc) {
        display_regs_error(ref, pc, next_pc, "PC 出现不一致");
    }
    for (int i = 0; i < 32; i++) {
        if (ref->gpr[i] != cpu.gpr[i]) {
            char buf[64];
            snprintf(buf, sizeof(buf), "寄存器 [%s] 数值不一致", reg_name(i));
            display_regs_error(ref, pc, next_pc, buf);
        }
    }
}

static inline void parse_pattern(const char *p, u32 *key, u32 *mask) {
    *key = 0; *mask = 0;
    while (*p) {
        if (*p == ' ' || *p == '_') { p++; continue; }
        *key <<= 1; *mask <<= 1;
        if (*p == '1') { *key |= 1; *mask |= 1; }
        else if (*p == '0') { *mask |= 1; }
        p++;
    }
}
static bool is_csr_instr(u32 instr) {
    #define INSTPAT(pattern, label) do { \
        static u32 __key = 0, __mask = 0; \
        static int __inited = 0; \
        if (!__inited) { parse_pattern(pattern, &__key, &__mask); __inited = 1; } \
        if ((instr & __mask) == __key) { \
            return true; \
        } \
    } while (0)
    INSTPAT("??????? ????? ????? 001 ????? 11100 11", csrrw);
    INSTPAT("??????? ????? ????? 010 ????? 11100 11", csrrs);
    INSTPAT("??????? ????? ????? 011 ????? 11100 11", csrrc);
    INSTPAT("??????? ????? ????? 101 ????? 11100 11", csrrwi);
    INSTPAT("??????? ????? ????? 110 ????? 11100 11", csrrsi);
    INSTPAT("??????? ????? ????? 111 ????? 11100 11", csrrci);
    return false; 
}


bool is_skip_ref = false;
reg_t csr_read(reg_t csr_id);
void difftest_step(reg_t pc, reg_t next_pc, u32 instr) {
    CPU_state ref_r;
    if(is_skip_ref){
        ref_difftest_regcpy(&cpu, DIFFTEST_TO_REF);
        is_skip_ref = false;
        return;
    }
    ref_difftest_exec(1);    
    ref_difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);
    checkregs(&ref_r, pc, next_pc);
    if(is_csr_instr(instr)){
        u32 csr_id          = (u32)(instr >> 20);
        u64 ref_csr_value   = ref_difftest_get_csr(csr_id);
        u64 dut_csr_value   = csr_read(csr_id);
        if (ref_csr_value != dut_csr_value) {
            instr_itrace_display();
            for (int i = 0; i < 32; i++) {
                bool mismatch = (ref_r.gpr[i] != cpu.gpr[i]);
                const char* color = mismatch ? ANSI_FG_RED : "";
                printf("%s%c [REF.%-3s]=0x%016lx | [DUT.%-3s]=0x%016lx%s\n", color, mismatch ? '*' : ' ', reg_name(i), ref_r.gpr[i], reg_name(i), cpu.gpr[i], ANSI_NONE);
            }
            const char *csr_name = ref_difftest_get_csr_name(csr_id);
            printf("\033[1;31m[REF.%-8s]=0x%016lx | [DUT.%-8s]=0x%016lx\033[0m\n", csr_name, ref_csr_value, csr_name, dut_csr_value);
            sim_exit("CSR_CHECK_FAILED");
        }
    }
}

#else
void init_difftest(char *ref_so_file, long img_size, int port) { }
#endif