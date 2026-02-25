#ifndef __COMMON_H__
#define __COMMON_H__

#include <autoconf.h>
#include <debug.h>
#include <macro.h>
#include <types.h>
#include <utils.h>


#include <sim_state.h>
#include <autoconf.h>

#define __GUEST_ISA__ riscv64

#define GPR_NUM 32
#define CSR_NUM 4096

#define FMT_WORD  "0x%16" PRIx64
#define FMT_PADDR "0x%16" PRIx64
#define PMEM_LEFT  ((reg_t)CONFIG_MBASE)
#define PMEM_RIGHT ((reg_t)CONFIG_MBASE + CONFIG_MSIZE - 1)
#define RESET_VECTOR (PMEM_LEFT + CONFIG_PC_RESET_OFFSET)

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
enum { SIM_RUNNING, SIM_STOP, SIM_END, SIM_ABORT, SIM_QUIT };

#endif
