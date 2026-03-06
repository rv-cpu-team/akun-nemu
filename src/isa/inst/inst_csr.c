
#include <types.h>
#include <defs.h>

//无论是csrrw还是csrrs都需要用到csr_write和csr_read这个函数
#define IP_WMASK 0x26
#define MSTATUS_WMASK       0x80000000ffffffffLL  //copy from cremu
#define SSTATUS_RMASK       0x80000003000de762LL  //copy from cremu
#define SSTATUS_WMASK       0x80000000000de762LL  //copy from cremu
#define MEDELEG_WMASK       0xfb3ff               //copy from cremu
#define MIDELEG_WMASK       0x222                 //get from spike 
#define MENVCFG_RMASK       0x0                   //get from spike
#define MENVCFG_WMASK       0x0                   //get from spike
#define MCOUNTEREN_WMASK    0x0                   //get from spike 
#define MCOUNTEREN_RMASK    0x0                   //get from spike
void csr_write(reg_t csr_id, reg_t data){
    switch(csr_id){
        case mstatus:{
            cpu.csr[mstatus] = (cpu.csr[mstatus] & ~MSTATUS_WMASK) | (data & MSTATUS_WMASK);
            break;
        }
        case sstatus: {
            cpu.csr[mstatus] = (cpu.csr[mstatus] & ~SSTATUS_WMASK) | (data & SSTATUS_WMASK);
            break;
        } 
        case medeleg: cpu.csr[csr_id] = data & 0x00000000000fb3ff; break;
        case mideleg: cpu.csr[csr_id] = data & 0x0000000000000222; break;
        case sip    : {
            reg_t mask = cpu.csr[mideleg] & IP_WMASK;
            cpu.csr[mip] = (cpu.csr[mip] & ~mask) | (data & mask);
            break;
        }
        case mip   :{
            cpu.csr[mip]  = (cpu.csr[mip] & ~IP_WMASK) | (data & IP_WMASK);
            break;
        }
        case sie: {
            reg_t mask      = cpu.csr[mideleg];
            cpu.csr[mie]    = (cpu.csr[mie] & ~mask) | (data & mask);
            break;
        }
        case menvcfg:{
            cpu.csr[menvcfg]  = data & MENVCFG_WMASK;
            break;
        }
        case mcounteren:{
            cpu.csr[mcounteren] = data & MCOUNTEREN_WMASK;
            break;
        }
        case stvec     :{
            cpu.csr[csr_id] = data;
            break;
        }
        default     : cpu.csr[csr_id] = data;
    }
}
reg_t csr_read(reg_t csr_id){
    switch(csr_id){
        case sstatus    :   return cpu.csr[mstatus] & SSTATUS_RMASK;
        case sie        :   return cpu.csr[mie] & cpu.csr[mideleg];
        case sip        :   return cpu.csr[mip] & cpu.csr[mideleg];
        case menvcfg    :   return cpu.csr[menvcfg]  & MENVCFG_RMASK;
        case mcounteren :   return cpu.csr[mcounteren] & MCOUNTEREN_RMASK;
        default         :   return cpu.csr[csr_id];
    }
}


//csrrw       zero, sie, a5
reg_t inst_csrrw(reg_t csr_id, reg_t src1){
    reg_t data = csr_read(csr_id);
    csr_write(csr_id, src1);
    return data;        //for rd
}

//csrrs       a5, mie, zero读csr的值到通用寄存器 
reg_t inst_csrrs(reg_t csr_id, reg_t src1){
    reg_t data    = csr_read(csr_id);
    csr_write(csr_id, data| src1);
    return data;        //for rd
}