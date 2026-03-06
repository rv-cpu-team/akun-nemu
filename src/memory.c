#include "cpu.h"
#include <common.h>
#include <debug.h>
#include <defs.h>



uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {}; 

void init_mem() {
#if defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem, 0, CONFIG_MSIZE));
  Log("物理内存区域为 [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}


uint8_t* guest_to_host(reg_t paddr) { 
  return pmem + paddr - CONFIG_MBASE; 
}

static inline reg_t host_read(void *addr, int len) {
  switch (len) {
    case 1: return *(uint8_t  *)addr;
    case 2: return *(uint16_t *)addr;
    case 4: return *(uint32_t *)addr;
    case 8: return *(uint64_t *)addr;
    default: assert(0);
  }
}
static inline void host_write(void *addr, int len, reg_t data) {
  switch (len) {
    case 1: *(uint8_t  *)addr = data; return;
    case 2: *(uint16_t *)addr = data; return;
    case 4: *(uint32_t *)addr = data; return;
    case 8: *(uint64_t *)addr = data; return;
    default: assert(0);
  }
}
static inline bool in_pmem(reg_t addr) {
  return addr >= CONFIG_MBASE && addr <= CONFIG_MBASE + CONFIG_MSIZE;
}


reg_t pmem_read(reg_t addr, int len){
  return host_read(guest_to_host(addr), len);
}
void pmem_write(reg_t addr, int len, reg_t data) {
  host_write(guest_to_host(addr), len, data);
}
static void out_of_bound(reg_t addr) {
  instr_itrace_display();
  panic("in[npc] address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD, addr, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
}

extern bool is_skip_ref;
reg_t mmio_read(reg_t addr, reg_t len){
  if(addr == 0x0000000010000005){
    is_skip_ref = true;
    return (uint64_t)0x20U;
  }
  return 0;
}
void mmio_write(reg_t addr, reg_t len, reg_t data){
  if (addr == 0x10000000) {
    char c = (char)(data & 0xFF);
    putchar(c); 
    fflush(stdout); 
  }
  // if (addr == 0x10000001) {
  //     char c = (char)(data & 0xFF);
  //     putchar(c); 
  //     fflush(stdout); 
  // }
  is_skip_ref = true;
}

reg_t paddr_read(reg_t addr, int len){
  if(likely(in_pmem(addr))) {
    return pmem_read(addr, len);
  }
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  out_of_bound(addr);
  return 0;
}

void paddr_write(reg_t addr, int len, reg_t data) {
  if (likely(in_pmem(addr))) { 
    pmem_write(addr, len, data); 
    return; 
  }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  
  out_of_bound(addr);
}


