#include <defs.h>
#include <types.h>

reg_t inst_mret() {
    reg_t npc = cpu.csr[mepc];
    reg_t s = cpu.csr[mstatus];
    reg_t mpie = (s >> 7) & 1;     // MSTATUS_MPIE 偏移通常为 7
    reg_t mpp  = (s >> 11) & 3;    // MSTATUS_MPP 偏移通常为 11
    s = (s & ~(1 << 3)) | (mpie << 3);    
    s |= (1 << 7);
    s &= ~(3 << 11);
    cpu.csr[mstatus] = s;
    cpu.mode = mpp; // 这一步至关重要，决定了后续指令的权限

    return npc;
}