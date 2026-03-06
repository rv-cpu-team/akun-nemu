#include <defs.h>
#include <types.h>
reg_t paddr_read (reg_t addr, int len);
void  paddr_write(reg_t addr, int len, reg_t data);


reg_t csr_read(reg_t csr_id);
#define SATP  0x180

// #define SATP_PPN             GET_BITFIELD(cpu.csr[SATP], 0, IS_RV64(44, 22))
// #define SATP_ASID            GET_BITFIELD(cpu.csr[SATP], IS_RV64(44, 22), IS_RV64(16, 9))
// #define SATP_MODE            GET_BITFIELD(cpu.csr[SATP], IS_RV64(60, 31), IS_RV64(4, 1))
// #define SATP_SET_MODE(value) SET_BITFIELD(cpu.csr[SATP], IS_RV64(60, 31), IS_RV64(4, 1), value)

static inline void mmu_translate_sv39(reg_t va, reg_t *pa) {
    reg_t satp = csr_read(SATP);    
    reg_t mode = (satp >> 60) & 0xF;
    if(mode == 0){  *pa = va; return ;  }   
    assert(mode == 8);                   
    reg_t ppn = satp & 0xFFFFFFFFFFFULL;
    reg_t pg_table_pa = ppn << 12;  

    for (int level = 2; level >= 0; level--) {
        reg_t vpn = 0;
        if(level == 2)          vpn =  (va >> (12 + level * 9)) & 0x1FF;
        else if(level == 1)     vpn =  (va >> (12 + level * 9)) & 0x1FF;
        else if(level == 0)     vpn =  (va >> (12 + level * 9)) & 0x1FF;
        else if(level <  0) assert(0);
        reg_t pte_pa = pg_table_pa + (vpn * 8); // Sv39 每个 PTE 是 8 字节
        reg_t pte = paddr_read(pte_pa, 8); 

        if (!(pte & 0x1)) {
            printf("Page Fault: Invalid PTE at Level %d\n", level);
            return;
        }
        if (pte & 0xE) {
            reg_t page_offset_mask = (1ULL << (12 + level * 9)) - 1;
            reg_t page_base_pa = (pte >> 10) << 12;
            *pa = page_base_pa | (va & page_offset_mask);
            return;
        }
        pg_table_pa = (pte >> 10) << 12;
    }
}

u32 mmu_fetch(reg_t va) {
    reg_t pa;
    mmu_translate_sv39(va, &pa);
    return paddr_read(pa, 4);
}

reg_t mmu_read(reg_t va, int len) {
    reg_t pa;
    mmu_translate_sv39(va, &pa);
    if(va==0x8000b9a8){
        printf("pa=%lx", pa);        
    }
    return paddr_read(pa, len);
}
void mmu_write(reg_t va, int len, reg_t data) {
    reg_t pa;
    mmu_translate_sv39(va, &pa);
    paddr_write(pa, len, data);
}