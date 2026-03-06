#ifndef __CPU_CPU_H__
#define __CPU_CPU_H__

#include <common.h>
#include <debug.h>
#include <types.h>

typedef struct {
  reg_t gpr[GPR_NUM];
  reg_t pc;
  reg_t csr[CSR_NUM];
  reg_t  mode;
} CPU_state;





#endif
