#include <common.h>
#include <defs.h>

#define ITRACE_POOL_SIZE 30
#define INST_STR_MAX 128
typedef struct {
    u64 pc;
    u32 instr; 
} TraceEntry;

static TraceEntry itrace_pool[ITRACE_POOL_SIZE];
static int itrace_ptr = 0;      // 下一个写入位置
static bool pool_full = false;  // 标记是否已写满过一轮



void instr_trace(u64 pc, u32 instr, u64 instr_count) {
    char inst_str[INST_STR_MAX];
    disassemble(inst_str, INST_STR_MAX, pc, (u8 *)&instr, 8);
    printf("[%ld] pc=[0x%016lx] instr=[0x%08x], disassemble=[%s]\n", instr_count, pc, instr, inst_str);
}

void instr_itrace(u64 pc, u32 instr) {
    itrace_pool[itrace_ptr].pc = pc;
    itrace_pool[itrace_ptr].instr = instr;
    itrace_ptr = (itrace_ptr + 1) % ITRACE_POOL_SIZE;
    if (itrace_ptr == 0) pool_full = true;
}



void instr_itrace_display() {    
    int total = pool_full ? ITRACE_POOL_SIZE : itrace_ptr;
    printf("\n%s ● " ANSI_BOLD "最近 %d 条指令 " ANSI_FG_RESET "(总计已执行: %" PRIu64 " 条, 不含 nop)\n",  ANSI_FG_CYAN, total, sim_instr_count);    
    int i = pool_full ? itrace_ptr : 0;
    //执行count循环
    for (int count = 0; count < total; count++) {
        char inst_str[INST_STR_MAX];
        TraceEntry *e = &itrace_pool[i];
        disassemble(inst_str, INST_STR_MAX, e->pc, (uint8_t *)&e->instr, 4);
        int last_idx = (itrace_ptr + ITRACE_POOL_SIZE - 1) % ITRACE_POOL_SIZE;
        char current_flag = (i == last_idx) ? '>' : ' ';
        printf("%c [0x%016lx]: 0x%08x  %s\n", current_flag, e->pc, e->instr, inst_str);

        i = (i + 1) % ITRACE_POOL_SIZE;
    }
    if (total == 0) {
        printf(" (No instructions executed yet.)\n");
    }    
    printf("--- [ End of Trace ] ---\n");
}





// --- 模式解析 (支持 ?, 0, 1) ---
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

// --- 统一的 Trace 处理 ---
static inline void __do_execute_special_trace(u64 pc, u32 instr, u64 instr_count) {
    char inst_str[INST_STR_MAX];
    disassemble(inst_str, INST_STR_MAX, pc, (uint8_t *)&instr, 4);
    log_write("[%ld] pc=[0x%016lx] instr=[0x%08x], disassemble=[%s]\n", instr_count, pc, instr, inst_str);
    //printf("[%ld] pc=[0x%016lx] instr=[0x%08x], disassemble=[%s]\n", instr_count, pc, instr, inst_str);
}



// --- 业务逻辑 ---
void instr_special_trace(u64 pc, u32 instr, u64 instr_count) {
    #define INSTPAT(pattern, label) do { \
        static u32 __key = 0, __mask = 0; \
        static int __inited = 0; \
        if (!__inited) { \
            parse_pattern(pattern, &__key, &__mask); __inited = 1; \
        } \
        if ((instr & __mask) == __key) { \
            __do_execute_special_trace(pc, instr, instr_count); \
            return; \
        } \
    } while (0)
    INSTPAT("0001100 00000 ????? 001 ????? 11100 11", csrrw);
    // INSTPAT("??????? ????? ????? 010 ????? 11100 11", csrrs);
    // INSTPAT("??????? ????? ????? 011 ????? 11100 11", csrrc);
    // INSTPAT("??????? ????? ????? 101 ????? 11100 11", csrrwi);
    // INSTPAT("??????? ????? ????? 110 ????? 11100 11", csrrsi);
    // INSTPAT("??????? ????? ????? 111 ????? 11100 11", csrrci);
}
//----------------------------------------instr_special_trace---end--------------------------------------------------

void instr_trace_dispatch(u64 pc, u32 instr, u64 instr_count){
    IFDEF(CONFIG_TRACE_LOG,         instr_trace(pc, instr, instr_count));
    IFDEF(CONFIG_TRACE_SPECIAL,     instr_special_trace(pc, instr, instr_count));
    IFDEF(CONFIG_ITRACE,            instr_itrace(pc , instr));
}