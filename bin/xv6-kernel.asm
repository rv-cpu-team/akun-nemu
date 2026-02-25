
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	9c010113          	addi	sp,sp,-1600 # 8000a9c0 <stack0>
        li a0, 1024*4
    80000008:	00001537          	lui	a0,0x1
        csrr a1, mhartid
    8000000c:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    80000010:	00158593          	addi	a1,a1,1
        mul a0, a0, a1
    80000014:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000018:	00a10133          	add	sp,sp,a0
        # jump to start() in start.c
        call start
    8000001c:	04c000ef          	jal	ra,80000068 <start>

0000000080000020 <spin>:
spin:
        j spin
    80000020:	0000006f          	j	80000020 <spin>

0000000080000024 <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80000024:	ff010113          	addi	sp,sp,-16
    80000028:	00813423          	sd	s0,8(sp)
    8000002c:	01010413          	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000030:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000034:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    80000038:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000003c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000040:	fff00713          	li	a4,-1
    80000044:	03f71713          	slli	a4,a4,0x3f
    80000048:	00e7e7b3          	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000004c:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80000050:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000054:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000058:	30679073          	csrw	mcounteren,a5
  
  // ask for the very first timer interrupt.
//  w_stimecmp(r_time() + 1000000);
}
    8000005c:	00813403          	ld	s0,8(sp)
    80000060:	01010113          	addi	sp,sp,16
    80000064:	00008067          	ret

0000000080000068 <start>:
{
    80000068:	ff010113          	addi	sp,sp,-16
    8000006c:	00113423          	sd	ra,8(sp)
    80000070:	00813023          	sd	s0,0(sp)
    80000074:	01010413          	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000078:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000007c:	ffffe737          	lui	a4,0xffffe
    80000080:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdab37>
    80000084:	00e7f7b3          	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000088:	00001737          	lui	a4,0x1
    8000008c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000090:	00e7e7b3          	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000094:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000098:	00001797          	auipc	a5,0x1
    8000009c:	3ec78793          	addi	a5,a5,1004 # 80001484 <main>
    800000a0:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000a4:	00000793          	li	a5,0
    800000a8:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000ac:	000107b7          	lui	a5,0x10
    800000b0:	fff78793          	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000b4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000b8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000bc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000c0:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000c4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000c8:	fff00793          	li	a5,-1
    800000cc:	00a7d793          	srli	a5,a5,0xa
    800000d0:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000d4:	00f00793          	li	a5,15
    800000d8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000dc:	00000097          	auipc	ra,0x0
    800000e0:	f48080e7          	jalr	-184(ra) # 80000024 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e4:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e8:	0007879b          	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000ec:	00078213          	mv	tp,a5
  asm volatile("mret");
    800000f0:	30200073          	mret
}
    800000f4:	00813083          	ld	ra,8(sp)
    800000f8:	00013403          	ld	s0,0(sp)
    800000fc:	01010113          	addi	sp,sp,16
    80000100:	00008067          	ret

0000000080000104 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000104:	f9010113          	addi	sp,sp,-112
    80000108:	06113423          	sd	ra,104(sp)
    8000010c:	06813023          	sd	s0,96(sp)
    80000110:	04913c23          	sd	s1,88(sp)
    80000114:	05213823          	sd	s2,80(sp)
    80000118:	05313423          	sd	s3,72(sp)
    8000011c:	05413023          	sd	s4,64(sp)
    80000120:	03513c23          	sd	s5,56(sp)
    80000124:	03613823          	sd	s6,48(sp)
    80000128:	03713423          	sd	s7,40(sp)
    8000012c:	03813023          	sd	s8,32(sp)
    80000130:	07010413          	addi	s0,sp,112
  char buf[32];
  int i = 0;

  while(i < n){
    80000134:	06c05463          	blez	a2,8000019c <consolewrite+0x98>
    80000138:	00050a13          	mv	s4,a0
    8000013c:	00058a93          	mv	s5,a1
    80000140:	00060993          	mv	s3,a2
  int i = 0;
    80000144:	00000913          	li	s2,0
    int nn = sizeof(buf);
    if(nn > n - i)
    80000148:	01f00b93          	li	s7,31
    int nn = sizeof(buf);
    8000014c:	02000c13          	li	s8,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000150:	fff00b13          	li	s6,-1
    80000154:	0380006f          	j	8000018c <consolewrite+0x88>
    80000158:	00048693          	mv	a3,s1
    8000015c:	01590633          	add	a2,s2,s5
    80000160:	000a0593          	mv	a1,s4
    80000164:	f9040513          	addi	a0,s0,-112
    80000168:	00003097          	auipc	ra,0x3
    8000016c:	570080e7          	jalr	1392(ra) # 800036d8 <either_copyin>
    80000170:	03650863          	beq	a0,s6,800001a0 <consolewrite+0x9c>
      break;
    uartwrite(buf, nn);
    80000174:	00048593          	mv	a1,s1
    80000178:	f9040513          	addi	a0,s0,-112
    8000017c:	00001097          	auipc	ra,0x1
    80000180:	9f8080e7          	jalr	-1544(ra) # 80000b74 <uartwrite>
    i += nn;
    80000184:	0124893b          	addw	s2,s1,s2
  while(i < n){
    80000188:	01395c63          	bge	s2,s3,800001a0 <consolewrite+0x9c>
    if(nn > n - i)
    8000018c:	412984bb          	subw	s1,s3,s2
    80000190:	fc9bd4e3          	bge	s7,s1,80000158 <consolewrite+0x54>
    int nn = sizeof(buf);
    80000194:	000c0493          	mv	s1,s8
    80000198:	fc1ff06f          	j	80000158 <consolewrite+0x54>
  int i = 0;
    8000019c:	00000913          	li	s2,0
  }

  return i;
}
    800001a0:	00090513          	mv	a0,s2
    800001a4:	06813083          	ld	ra,104(sp)
    800001a8:	06013403          	ld	s0,96(sp)
    800001ac:	05813483          	ld	s1,88(sp)
    800001b0:	05013903          	ld	s2,80(sp)
    800001b4:	04813983          	ld	s3,72(sp)
    800001b8:	04013a03          	ld	s4,64(sp)
    800001bc:	03813a83          	ld	s5,56(sp)
    800001c0:	03013b03          	ld	s6,48(sp)
    800001c4:	02813b83          	ld	s7,40(sp)
    800001c8:	02013c03          	ld	s8,32(sp)
    800001cc:	07010113          	addi	sp,sp,112
    800001d0:	00008067          	ret

00000000800001d4 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    800001d4:	f9010113          	addi	sp,sp,-112
    800001d8:	06113423          	sd	ra,104(sp)
    800001dc:	06813023          	sd	s0,96(sp)
    800001e0:	04913c23          	sd	s1,88(sp)
    800001e4:	05213823          	sd	s2,80(sp)
    800001e8:	05313423          	sd	s3,72(sp)
    800001ec:	05413023          	sd	s4,64(sp)
    800001f0:	03513c23          	sd	s5,56(sp)
    800001f4:	03613823          	sd	s6,48(sp)
    800001f8:	03713423          	sd	s7,40(sp)
    800001fc:	03813023          	sd	s8,32(sp)
    80000200:	01913c23          	sd	s9,24(sp)
    80000204:	01a13823          	sd	s10,16(sp)
    80000208:	07010413          	addi	s0,sp,112
    8000020c:	00050a93          	mv	s5,a0
    80000210:	00058a13          	mv	s4,a1
    80000214:	00060993          	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000218:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000021c:	00012517          	auipc	a0,0x12
    80000220:	7a450513          	addi	a0,a0,1956 # 800129c0 <cons>
    80000224:	00001097          	auipc	ra,0x1
    80000228:	e74080e7          	jalr	-396(ra) # 80001098 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000022c:	00012497          	auipc	s1,0x12
    80000230:	79448493          	addi	s1,s1,1940 # 800129c0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000234:	00013917          	auipc	s2,0x13
    80000238:	82490913          	addi	s2,s2,-2012 # 80012a58 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000023c:	00400b93          	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000240:	fff00c13          	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000244:	00a00c93          	li	s9,10
  while(n > 0){
    80000248:	09305463          	blez	s3,800002d0 <consoleread+0xfc>
    while(cons.r == cons.w){
    8000024c:	0984a783          	lw	a5,152(s1)
    80000250:	09c4a703          	lw	a4,156(s1)
    80000254:	02f71a63          	bne	a4,a5,80000288 <consoleread+0xb4>
      if(killed(myproc())){
    80000258:	00002097          	auipc	ra,0x2
    8000025c:	4a0080e7          	jalr	1184(ra) # 800026f8 <myproc>
    80000260:	00003097          	auipc	ra,0x3
    80000264:	200080e7          	jalr	512(ra) # 80003460 <killed>
    80000268:	08051063          	bnez	a0,800002e8 <consoleread+0x114>
      sleep(&cons.r, &cons.lock);
    8000026c:	00048593          	mv	a1,s1
    80000270:	00090513          	mv	a0,s2
    80000274:	00003097          	auipc	ra,0x3
    80000278:	e3c080e7          	jalr	-452(ra) # 800030b0 <sleep>
    while(cons.r == cons.w){
    8000027c:	0984a783          	lw	a5,152(s1)
    80000280:	09c4a703          	lw	a4,156(s1)
    80000284:	fcf70ae3          	beq	a4,a5,80000258 <consoleread+0x84>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80000288:	0017871b          	addiw	a4,a5,1
    8000028c:	08e4ac23          	sw	a4,152(s1)
    80000290:	07f7f713          	andi	a4,a5,127
    80000294:	00e48733          	add	a4,s1,a4
    80000298:	01874703          	lbu	a4,24(a4)
    8000029c:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800002a0:	097d0a63          	beq	s10,s7,80000334 <consoleread+0x160>
    cbuf = c;
    800002a4:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800002a8:	00100693          	li	a3,1
    800002ac:	f9f40613          	addi	a2,s0,-97
    800002b0:	000a0593          	mv	a1,s4
    800002b4:	000a8513          	mv	a0,s5
    800002b8:	00003097          	auipc	ra,0x3
    800002bc:	390080e7          	jalr	912(ra) # 80003648 <either_copyout>
    800002c0:	01850863          	beq	a0,s8,800002d0 <consoleread+0xfc>
    dst++;
    800002c4:	001a0a13          	addi	s4,s4,1
    --n;
    800002c8:	fff9899b          	addiw	s3,s3,-1
    if(c == '\n'){
    800002cc:	f79d1ee3          	bne	s10,s9,80000248 <consoleread+0x74>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800002d0:	00012517          	auipc	a0,0x12
    800002d4:	6f050513          	addi	a0,a0,1776 # 800129c0 <cons>
    800002d8:	00001097          	auipc	ra,0x1
    800002dc:	eb8080e7          	jalr	-328(ra) # 80001190 <release>

  return target - n;
    800002e0:	413b053b          	subw	a0,s6,s3
    800002e4:	0180006f          	j	800002fc <consoleread+0x128>
        release(&cons.lock);
    800002e8:	00012517          	auipc	a0,0x12
    800002ec:	6d850513          	addi	a0,a0,1752 # 800129c0 <cons>
    800002f0:	00001097          	auipc	ra,0x1
    800002f4:	ea0080e7          	jalr	-352(ra) # 80001190 <release>
        return -1;
    800002f8:	fff00513          	li	a0,-1
}
    800002fc:	06813083          	ld	ra,104(sp)
    80000300:	06013403          	ld	s0,96(sp)
    80000304:	05813483          	ld	s1,88(sp)
    80000308:	05013903          	ld	s2,80(sp)
    8000030c:	04813983          	ld	s3,72(sp)
    80000310:	04013a03          	ld	s4,64(sp)
    80000314:	03813a83          	ld	s5,56(sp)
    80000318:	03013b03          	ld	s6,48(sp)
    8000031c:	02813b83          	ld	s7,40(sp)
    80000320:	02013c03          	ld	s8,32(sp)
    80000324:	01813c83          	ld	s9,24(sp)
    80000328:	01013d03          	ld	s10,16(sp)
    8000032c:	07010113          	addi	sp,sp,112
    80000330:	00008067          	ret
      if(n < target){
    80000334:	0009871b          	sext.w	a4,s3
    80000338:	f9677ce3          	bgeu	a4,s6,800002d0 <consoleread+0xfc>
        cons.r--;
    8000033c:	00012717          	auipc	a4,0x12
    80000340:	70f72e23          	sw	a5,1820(a4) # 80012a58 <cons+0x98>
    80000344:	f8dff06f          	j	800002d0 <consoleread+0xfc>

0000000080000348 <consputc>:
{
    80000348:	ff010113          	addi	sp,sp,-16
    8000034c:	00113423          	sd	ra,8(sp)
    80000350:	00813023          	sd	s0,0(sp)
    80000354:	01010413          	addi	s0,sp,16
  if(c == BACKSPACE){
    80000358:	10000793          	li	a5,256
    8000035c:	00f50e63          	beq	a0,a5,80000378 <consputc+0x30>
    uartputc_sync(c);
    80000360:	00001097          	auipc	ra,0x1
    80000364:	90c080e7          	jalr	-1780(ra) # 80000c6c <uartputc_sync>
}
    80000368:	00813083          	ld	ra,8(sp)
    8000036c:	00013403          	ld	s0,0(sp)
    80000370:	01010113          	addi	sp,sp,16
    80000374:	00008067          	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000378:	00800513          	li	a0,8
    8000037c:	00001097          	auipc	ra,0x1
    80000380:	8f0080e7          	jalr	-1808(ra) # 80000c6c <uartputc_sync>
    80000384:	02000513          	li	a0,32
    80000388:	00001097          	auipc	ra,0x1
    8000038c:	8e4080e7          	jalr	-1820(ra) # 80000c6c <uartputc_sync>
    80000390:	00800513          	li	a0,8
    80000394:	00001097          	auipc	ra,0x1
    80000398:	8d8080e7          	jalr	-1832(ra) # 80000c6c <uartputc_sync>
    8000039c:	fcdff06f          	j	80000368 <consputc+0x20>

00000000800003a0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800003a0:	fe010113          	addi	sp,sp,-32
    800003a4:	00113c23          	sd	ra,24(sp)
    800003a8:	00813823          	sd	s0,16(sp)
    800003ac:	00913423          	sd	s1,8(sp)
    800003b0:	01213023          	sd	s2,0(sp)
    800003b4:	02010413          	addi	s0,sp,32
    800003b8:	00050493          	mv	s1,a0
  acquire(&cons.lock);
    800003bc:	00012517          	auipc	a0,0x12
    800003c0:	60450513          	addi	a0,a0,1540 # 800129c0 <cons>
    800003c4:	00001097          	auipc	ra,0x1
    800003c8:	cd4080e7          	jalr	-812(ra) # 80001098 <acquire>

  switch(c){
    800003cc:	01500793          	li	a5,21
    800003d0:	0cf48663          	beq	s1,a5,8000049c <consoleintr+0xfc>
    800003d4:	0497c263          	blt	a5,s1,80000418 <consoleintr+0x78>
    800003d8:	00800793          	li	a5,8
    800003dc:	10f48a63          	beq	s1,a5,800004f0 <consoleintr+0x150>
    800003e0:	01000793          	li	a5,16
    800003e4:	12f49e63          	bne	s1,a5,80000520 <consoleintr+0x180>
  case C('P'):  // Print process list.
    procdump();
    800003e8:	00003097          	auipc	ra,0x3
    800003ec:	380080e7          	jalr	896(ra) # 80003768 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800003f0:	00012517          	auipc	a0,0x12
    800003f4:	5d050513          	addi	a0,a0,1488 # 800129c0 <cons>
    800003f8:	00001097          	auipc	ra,0x1
    800003fc:	d98080e7          	jalr	-616(ra) # 80001190 <release>
}
    80000400:	01813083          	ld	ra,24(sp)
    80000404:	01013403          	ld	s0,16(sp)
    80000408:	00813483          	ld	s1,8(sp)
    8000040c:	00013903          	ld	s2,0(sp)
    80000410:	02010113          	addi	sp,sp,32
    80000414:	00008067          	ret
  switch(c){
    80000418:	07f00793          	li	a5,127
    8000041c:	0cf48a63          	beq	s1,a5,800004f0 <consoleintr+0x150>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000420:	00012717          	auipc	a4,0x12
    80000424:	5a070713          	addi	a4,a4,1440 # 800129c0 <cons>
    80000428:	0a072783          	lw	a5,160(a4)
    8000042c:	09872703          	lw	a4,152(a4)
    80000430:	40e787bb          	subw	a5,a5,a4
    80000434:	07f00713          	li	a4,127
    80000438:	faf76ce3          	bltu	a4,a5,800003f0 <consoleintr+0x50>
      c = (c == '\r') ? '\n' : c;
    8000043c:	00d00793          	li	a5,13
    80000440:	0ef48463          	beq	s1,a5,80000528 <consoleintr+0x188>
      consputc(c);
    80000444:	00048513          	mv	a0,s1
    80000448:	00000097          	auipc	ra,0x0
    8000044c:	f00080e7          	jalr	-256(ra) # 80000348 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000450:	00012797          	auipc	a5,0x12
    80000454:	57078793          	addi	a5,a5,1392 # 800129c0 <cons>
    80000458:	0a07a683          	lw	a3,160(a5)
    8000045c:	0016871b          	addiw	a4,a3,1
    80000460:	0007061b          	sext.w	a2,a4
    80000464:	0ae7a023          	sw	a4,160(a5)
    80000468:	07f6f693          	andi	a3,a3,127
    8000046c:	00d787b3          	add	a5,a5,a3
    80000470:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000474:	00a00793          	li	a5,10
    80000478:	0ef48263          	beq	s1,a5,8000055c <consoleintr+0x1bc>
    8000047c:	00400793          	li	a5,4
    80000480:	0cf48e63          	beq	s1,a5,8000055c <consoleintr+0x1bc>
    80000484:	00012797          	auipc	a5,0x12
    80000488:	5d47a783          	lw	a5,1492(a5) # 80012a58 <cons+0x98>
    8000048c:	40f7073b          	subw	a4,a4,a5
    80000490:	08000793          	li	a5,128
    80000494:	f4f71ee3          	bne	a4,a5,800003f0 <consoleintr+0x50>
    80000498:	0c40006f          	j	8000055c <consoleintr+0x1bc>
    while(cons.e != cons.w &&
    8000049c:	00012717          	auipc	a4,0x12
    800004a0:	52470713          	addi	a4,a4,1316 # 800129c0 <cons>
    800004a4:	0a072783          	lw	a5,160(a4)
    800004a8:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800004ac:	00012497          	auipc	s1,0x12
    800004b0:	51448493          	addi	s1,s1,1300 # 800129c0 <cons>
    while(cons.e != cons.w &&
    800004b4:	00a00913          	li	s2,10
    800004b8:	f2f70ce3          	beq	a4,a5,800003f0 <consoleintr+0x50>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800004bc:	fff7879b          	addiw	a5,a5,-1
    800004c0:	07f7f713          	andi	a4,a5,127
    800004c4:	00e48733          	add	a4,s1,a4
    while(cons.e != cons.w &&
    800004c8:	01874703          	lbu	a4,24(a4)
    800004cc:	f32702e3          	beq	a4,s2,800003f0 <consoleintr+0x50>
      cons.e--;
    800004d0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800004d4:	10000513          	li	a0,256
    800004d8:	00000097          	auipc	ra,0x0
    800004dc:	e70080e7          	jalr	-400(ra) # 80000348 <consputc>
    while(cons.e != cons.w &&
    800004e0:	0a04a783          	lw	a5,160(s1)
    800004e4:	09c4a703          	lw	a4,156(s1)
    800004e8:	fcf71ae3          	bne	a4,a5,800004bc <consoleintr+0x11c>
    800004ec:	f05ff06f          	j	800003f0 <consoleintr+0x50>
    if(cons.e != cons.w){
    800004f0:	00012717          	auipc	a4,0x12
    800004f4:	4d070713          	addi	a4,a4,1232 # 800129c0 <cons>
    800004f8:	0a072783          	lw	a5,160(a4)
    800004fc:	09c72703          	lw	a4,156(a4)
    80000500:	eef708e3          	beq	a4,a5,800003f0 <consoleintr+0x50>
      cons.e--;
    80000504:	fff7879b          	addiw	a5,a5,-1
    80000508:	00012717          	auipc	a4,0x12
    8000050c:	54f72c23          	sw	a5,1368(a4) # 80012a60 <cons+0xa0>
      consputc(BACKSPACE);
    80000510:	10000513          	li	a0,256
    80000514:	00000097          	auipc	ra,0x0
    80000518:	e34080e7          	jalr	-460(ra) # 80000348 <consputc>
    8000051c:	ed5ff06f          	j	800003f0 <consoleintr+0x50>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000520:	ec0488e3          	beqz	s1,800003f0 <consoleintr+0x50>
    80000524:	efdff06f          	j	80000420 <consoleintr+0x80>
      consputc(c);
    80000528:	00a00513          	li	a0,10
    8000052c:	00000097          	auipc	ra,0x0
    80000530:	e1c080e7          	jalr	-484(ra) # 80000348 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000534:	00012797          	auipc	a5,0x12
    80000538:	48c78793          	addi	a5,a5,1164 # 800129c0 <cons>
    8000053c:	0a07a703          	lw	a4,160(a5)
    80000540:	0017069b          	addiw	a3,a4,1
    80000544:	0006861b          	sext.w	a2,a3
    80000548:	0ad7a023          	sw	a3,160(a5)
    8000054c:	07f77713          	andi	a4,a4,127
    80000550:	00e787b3          	add	a5,a5,a4
    80000554:	00a00713          	li	a4,10
    80000558:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000055c:	00012797          	auipc	a5,0x12
    80000560:	50c7a023          	sw	a2,1280(a5) # 80012a5c <cons+0x9c>
        wakeup(&cons.r);
    80000564:	00012517          	auipc	a0,0x12
    80000568:	4f450513          	addi	a0,a0,1268 # 80012a58 <cons+0x98>
    8000056c:	00003097          	auipc	ra,0x3
    80000570:	bd4080e7          	jalr	-1068(ra) # 80003140 <wakeup>
    80000574:	e7dff06f          	j	800003f0 <consoleintr+0x50>

0000000080000578 <consoleinit>:

void
consoleinit(void)
{
    80000578:	ff010113          	addi	sp,sp,-16
    8000057c:	00113423          	sd	ra,8(sp)
    80000580:	00813023          	sd	s0,0(sp)
    80000584:	01010413          	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000588:	0000a597          	auipc	a1,0xa
    8000058c:	a8858593          	addi	a1,a1,-1400 # 8000a010 <etext+0x10>
    80000590:	00012517          	auipc	a0,0x12
    80000594:	43050513          	addi	a0,a0,1072 # 800129c0 <cons>
    80000598:	00001097          	auipc	ra,0x1
    8000059c:	a1c080e7          	jalr	-1508(ra) # 80000fb4 <initlock>

  uartinit();
    800005a0:	00000097          	auipc	ra,0x0
    800005a4:	570080e7          	jalr	1392(ra) # 80000b10 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800005a8:	00022797          	auipc	a5,0x22
    800005ac:	58878793          	addi	a5,a5,1416 # 80022b30 <devsw>
    800005b0:	00000717          	auipc	a4,0x0
    800005b4:	c2470713          	addi	a4,a4,-988 # 800001d4 <consoleread>
    800005b8:	00e7b823          	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800005bc:	00000717          	auipc	a4,0x0
    800005c0:	b4870713          	addi	a4,a4,-1208 # 80000104 <consolewrite>
    800005c4:	00e7bc23          	sd	a4,24(a5)
}
    800005c8:	00813083          	ld	ra,8(sp)
    800005cc:	00013403          	ld	s0,0(sp)
    800005d0:	01010113          	addi	sp,sp,16
    800005d4:	00008067          	ret

00000000800005d8 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    800005d8:	fc010113          	addi	sp,sp,-64
    800005dc:	02113c23          	sd	ra,56(sp)
    800005e0:	02813823          	sd	s0,48(sp)
    800005e4:	02913423          	sd	s1,40(sp)
    800005e8:	03213023          	sd	s2,32(sp)
    800005ec:	04010413          	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    800005f0:	00060463          	beqz	a2,800005f8 <printint+0x20>
    800005f4:	0a054463          	bltz	a0,8000069c <printint+0xc4>
    x = -xx;
  else
    x = xx;
    800005f8:	00000893          	li	a7,0
    800005fc:	fc840693          	addi	a3,s0,-56

  i = 0;
    80000600:	00000793          	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000604:	0000a617          	auipc	a2,0xa
    80000608:	a3460613          	addi	a2,a2,-1484 # 8000a038 <digits>
    8000060c:	00078813          	mv	a6,a5
    80000610:	0017879b          	addiw	a5,a5,1
    80000614:	02b57733          	remu	a4,a0,a1
    80000618:	00e60733          	add	a4,a2,a4
    8000061c:	00074703          	lbu	a4,0(a4)
    80000620:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000624:	00050713          	mv	a4,a0
    80000628:	02b55533          	divu	a0,a0,a1
    8000062c:	00168693          	addi	a3,a3,1
    80000630:	fcb77ee3          	bgeu	a4,a1,8000060c <printint+0x34>

  if(sign)
    80000634:	00088c63          	beqz	a7,8000064c <printint+0x74>
    buf[i++] = '-';
    80000638:	fe078793          	addi	a5,a5,-32
    8000063c:	008787b3          	add	a5,a5,s0
    80000640:	02d00713          	li	a4,45
    80000644:	fee78423          	sb	a4,-24(a5)
    80000648:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    8000064c:	02f05c63          	blez	a5,80000684 <printint+0xac>
    80000650:	fc840713          	addi	a4,s0,-56
    80000654:	00f704b3          	add	s1,a4,a5
    80000658:	fff70913          	addi	s2,a4,-1
    8000065c:	00f90933          	add	s2,s2,a5
    80000660:	fff7879b          	addiw	a5,a5,-1
    80000664:	02079793          	slli	a5,a5,0x20
    80000668:	0207d793          	srli	a5,a5,0x20
    8000066c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    80000670:	fff4c503          	lbu	a0,-1(s1)
    80000674:	00000097          	auipc	ra,0x0
    80000678:	cd4080e7          	jalr	-812(ra) # 80000348 <consputc>
  while(--i >= 0)
    8000067c:	fff48493          	addi	s1,s1,-1
    80000680:	ff2498e3          	bne	s1,s2,80000670 <printint+0x98>
}
    80000684:	03813083          	ld	ra,56(sp)
    80000688:	03013403          	ld	s0,48(sp)
    8000068c:	02813483          	ld	s1,40(sp)
    80000690:	02013903          	ld	s2,32(sp)
    80000694:	04010113          	addi	sp,sp,64
    80000698:	00008067          	ret
    x = -xx;
    8000069c:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800006a0:	00100893          	li	a7,1
    x = -xx;
    800006a4:	f59ff06f          	j	800005fc <printint+0x24>

00000000800006a8 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800006a8:	f4010113          	addi	sp,sp,-192
    800006ac:	06113c23          	sd	ra,120(sp)
    800006b0:	06813823          	sd	s0,112(sp)
    800006b4:	06913423          	sd	s1,104(sp)
    800006b8:	07213023          	sd	s2,96(sp)
    800006bc:	05313c23          	sd	s3,88(sp)
    800006c0:	05413823          	sd	s4,80(sp)
    800006c4:	05513423          	sd	s5,72(sp)
    800006c8:	05613023          	sd	s6,64(sp)
    800006cc:	03713c23          	sd	s7,56(sp)
    800006d0:	03813823          	sd	s8,48(sp)
    800006d4:	03913423          	sd	s9,40(sp)
    800006d8:	03a13023          	sd	s10,32(sp)
    800006dc:	01b13c23          	sd	s11,24(sp)
    800006e0:	08010413          	addi	s0,sp,128
    800006e4:	00050a13          	mv	s4,a0
    800006e8:	00b43423          	sd	a1,8(s0)
    800006ec:	00c43823          	sd	a2,16(s0)
    800006f0:	00d43c23          	sd	a3,24(s0)
    800006f4:	02e43023          	sd	a4,32(s0)
    800006f8:	02f43423          	sd	a5,40(s0)
    800006fc:	03043823          	sd	a6,48(s0)
    80000700:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000704:	0000a797          	auipc	a5,0xa
    80000708:	2907a783          	lw	a5,656(a5) # 8000a994 <panicking>
    8000070c:	02078e63          	beqz	a5,80000748 <printf+0xa0>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000710:	00840793          	addi	a5,s0,8
    80000714:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000718:	000a4503          	lbu	a0,0(s4)
    8000071c:	30050263          	beqz	a0,80000a20 <printf+0x378>
    80000720:	00000993          	li	s3,0
    if(cx != '%'){
    80000724:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000728:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000072c:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000730:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000734:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000738:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000073c:	0000ab97          	auipc	s7,0xa
    80000740:	8fcb8b93          	addi	s7,s7,-1796 # 8000a038 <digits>
    80000744:	0340006f          	j	80000778 <printf+0xd0>
    acquire(&pr.lock);
    80000748:	00012517          	auipc	a0,0x12
    8000074c:	32050513          	addi	a0,a0,800 # 80012a68 <pr>
    80000750:	00001097          	auipc	ra,0x1
    80000754:	948080e7          	jalr	-1720(ra) # 80001098 <acquire>
    80000758:	fb9ff06f          	j	80000710 <printf+0x68>
      consputc(cx);
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	bec080e7          	jalr	-1044(ra) # 80000348 <consputc>
      continue;
    80000764:	00098493          	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000768:	0014899b          	addiw	s3,s1,1
    8000076c:	013a07b3          	add	a5,s4,s3
    80000770:	0007c503          	lbu	a0,0(a5)
    80000774:	2a050663          	beqz	a0,80000a20 <printf+0x378>
    if(cx != '%'){
    80000778:	ff5512e3          	bne	a0,s5,8000075c <printf+0xb4>
    i++;
    8000077c:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000780:	009a07b3          	add	a5,s4,s1
    80000784:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000788:	28090c63          	beqz	s2,80000a20 <printf+0x378>
    8000078c:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000790:	00078693          	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000794:	00078663          	beqz	a5,800007a0 <printf+0xf8>
    80000798:	009a0733          	add	a4,s4,s1
    8000079c:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800007a0:	03690c63          	beq	s2,s6,800007d8 <printf+0x130>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	05890c63          	beq	s2,s8,800007fc <printf+0x154>
    } else if(c0 == 'u'){
    800007a8:	11990463          	beq	s2,s9,800008b0 <printf+0x208>
    } else if(c0 == 'x'){
    800007ac:	17a90c63          	beq	s2,s10,80000924 <printf+0x27c>
    } else if(c0 == 'p'){
    800007b0:	1db90063          	beq	s2,s11,80000970 <printf+0x2c8>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800007b4:	06300793          	li	a5,99
    800007b8:	20f90463          	beq	s2,a5,800009c0 <printf+0x318>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800007bc:	07300793          	li	a5,115
    800007c0:	20f90e63          	beq	s2,a5,800009dc <printf+0x334>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800007c4:	05591663          	bne	s2,s5,80000810 <printf+0x168>
      consputc('%');
    800007c8:	000a8513          	mv	a0,s5
    800007cc:	00000097          	auipc	ra,0x0
    800007d0:	b7c080e7          	jalr	-1156(ra) # 80000348 <consputc>
    800007d4:	f95ff06f          	j	80000768 <printf+0xc0>
      printint(va_arg(ap, int), 10, 1);
    800007d8:	f8843783          	ld	a5,-120(s0)
    800007dc:	00878713          	addi	a4,a5,8
    800007e0:	f8e43423          	sd	a4,-120(s0)
    800007e4:	00100613          	li	a2,1
    800007e8:	00a00593          	li	a1,10
    800007ec:	0007a503          	lw	a0,0(a5)
    800007f0:	00000097          	auipc	ra,0x0
    800007f4:	de8080e7          	jalr	-536(ra) # 800005d8 <printint>
    800007f8:	f71ff06f          	j	80000768 <printf+0xc0>
    } else if(c0 == 'l' && c1 == 'd'){
    800007fc:	03678863          	beq	a5,s6,8000082c <printf+0x184>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000800:	05878a63          	beq	a5,s8,80000854 <printf+0x1ac>
    } else if(c0 == 'l' && c1 == 'u'){
    80000804:	0d978863          	beq	a5,s9,800008d4 <printf+0x22c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000808:	05878863          	beq	a5,s8,80000858 <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'x'){
    8000080c:	13a78e63          	beq	a5,s10,80000948 <printf+0x2a0>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000810:	000a8513          	mv	a0,s5
    80000814:	00000097          	auipc	ra,0x0
    80000818:	b34080e7          	jalr	-1228(ra) # 80000348 <consputc>
      consputc(c0);
    8000081c:	00090513          	mv	a0,s2
    80000820:	00000097          	auipc	ra,0x0
    80000824:	b28080e7          	jalr	-1240(ra) # 80000348 <consputc>
    80000828:	f41ff06f          	j	80000768 <printf+0xc0>
      printint(va_arg(ap, uint64), 10, 1);
    8000082c:	f8843783          	ld	a5,-120(s0)
    80000830:	00878713          	addi	a4,a5,8
    80000834:	f8e43423          	sd	a4,-120(s0)
    80000838:	00100613          	li	a2,1
    8000083c:	00a00593          	li	a1,10
    80000840:	0007b503          	ld	a0,0(a5)
    80000844:	00000097          	auipc	ra,0x0
    80000848:	d94080e7          	jalr	-620(ra) # 800005d8 <printint>
      i += 1;
    8000084c:	0029849b          	addiw	s1,s3,2
    80000850:	f19ff06f          	j	80000768 <printf+0xc0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000854:	03668a63          	beq	a3,s6,80000888 <printf+0x1e0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000858:	0b968263          	beq	a3,s9,800008fc <printf+0x254>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000085c:	fba69ae3          	bne	a3,s10,80000810 <printf+0x168>
      printint(va_arg(ap, uint64), 16, 0);
    80000860:	f8843783          	ld	a5,-120(s0)
    80000864:	00878713          	addi	a4,a5,8
    80000868:	f8e43423          	sd	a4,-120(s0)
    8000086c:	00000613          	li	a2,0
    80000870:	01000593          	li	a1,16
    80000874:	0007b503          	ld	a0,0(a5)
    80000878:	00000097          	auipc	ra,0x0
    8000087c:	d60080e7          	jalr	-672(ra) # 800005d8 <printint>
      i += 2;
    80000880:	0039849b          	addiw	s1,s3,3
    80000884:	ee5ff06f          	j	80000768 <printf+0xc0>
      printint(va_arg(ap, uint64), 10, 1);
    80000888:	f8843783          	ld	a5,-120(s0)
    8000088c:	00878713          	addi	a4,a5,8
    80000890:	f8e43423          	sd	a4,-120(s0)
    80000894:	00100613          	li	a2,1
    80000898:	00a00593          	li	a1,10
    8000089c:	0007b503          	ld	a0,0(a5)
    800008a0:	00000097          	auipc	ra,0x0
    800008a4:	d38080e7          	jalr	-712(ra) # 800005d8 <printint>
      i += 2;
    800008a8:	0039849b          	addiw	s1,s3,3
    800008ac:	ebdff06f          	j	80000768 <printf+0xc0>
      printint(va_arg(ap, uint32), 10, 0);
    800008b0:	f8843783          	ld	a5,-120(s0)
    800008b4:	00878713          	addi	a4,a5,8
    800008b8:	f8e43423          	sd	a4,-120(s0)
    800008bc:	00000613          	li	a2,0
    800008c0:	00a00593          	li	a1,10
    800008c4:	0007e503          	lwu	a0,0(a5)
    800008c8:	00000097          	auipc	ra,0x0
    800008cc:	d10080e7          	jalr	-752(ra) # 800005d8 <printint>
    800008d0:	e99ff06f          	j	80000768 <printf+0xc0>
      printint(va_arg(ap, uint64), 10, 0);
    800008d4:	f8843783          	ld	a5,-120(s0)
    800008d8:	00878713          	addi	a4,a5,8
    800008dc:	f8e43423          	sd	a4,-120(s0)
    800008e0:	00000613          	li	a2,0
    800008e4:	00a00593          	li	a1,10
    800008e8:	0007b503          	ld	a0,0(a5)
    800008ec:	00000097          	auipc	ra,0x0
    800008f0:	cec080e7          	jalr	-788(ra) # 800005d8 <printint>
      i += 1;
    800008f4:	0029849b          	addiw	s1,s3,2
    800008f8:	e71ff06f          	j	80000768 <printf+0xc0>
      printint(va_arg(ap, uint64), 10, 0);
    800008fc:	f8843783          	ld	a5,-120(s0)
    80000900:	00878713          	addi	a4,a5,8
    80000904:	f8e43423          	sd	a4,-120(s0)
    80000908:	00000613          	li	a2,0
    8000090c:	00a00593          	li	a1,10
    80000910:	0007b503          	ld	a0,0(a5)
    80000914:	00000097          	auipc	ra,0x0
    80000918:	cc4080e7          	jalr	-828(ra) # 800005d8 <printint>
      i += 2;
    8000091c:	0039849b          	addiw	s1,s3,3
    80000920:	e49ff06f          	j	80000768 <printf+0xc0>
      printint(va_arg(ap, uint32), 16, 0);
    80000924:	f8843783          	ld	a5,-120(s0)
    80000928:	00878713          	addi	a4,a5,8
    8000092c:	f8e43423          	sd	a4,-120(s0)
    80000930:	00000613          	li	a2,0
    80000934:	01000593          	li	a1,16
    80000938:	0007e503          	lwu	a0,0(a5)
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	c9c080e7          	jalr	-868(ra) # 800005d8 <printint>
    80000944:	e25ff06f          	j	80000768 <printf+0xc0>
      printint(va_arg(ap, uint64), 16, 0);
    80000948:	f8843783          	ld	a5,-120(s0)
    8000094c:	00878713          	addi	a4,a5,8
    80000950:	f8e43423          	sd	a4,-120(s0)
    80000954:	00000613          	li	a2,0
    80000958:	01000593          	li	a1,16
    8000095c:	0007b503          	ld	a0,0(a5)
    80000960:	00000097          	auipc	ra,0x0
    80000964:	c78080e7          	jalr	-904(ra) # 800005d8 <printint>
      i += 1;
    80000968:	0029849b          	addiw	s1,s3,2
    8000096c:	dfdff06f          	j	80000768 <printf+0xc0>
      printptr(va_arg(ap, uint64));
    80000970:	f8843783          	ld	a5,-120(s0)
    80000974:	00878713          	addi	a4,a5,8
    80000978:	f8e43423          	sd	a4,-120(s0)
    8000097c:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000980:	03000513          	li	a0,48
    80000984:	00000097          	auipc	ra,0x0
    80000988:	9c4080e7          	jalr	-1596(ra) # 80000348 <consputc>
  consputc('x');
    8000098c:	000d0513          	mv	a0,s10
    80000990:	00000097          	auipc	ra,0x0
    80000994:	9b8080e7          	jalr	-1608(ra) # 80000348 <consputc>
    80000998:	01000913          	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000099c:	03c9d793          	srli	a5,s3,0x3c
    800009a0:	00fb87b3          	add	a5,s7,a5
    800009a4:	0007c503          	lbu	a0,0(a5)
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	9a0080e7          	jalr	-1632(ra) # 80000348 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800009b0:	00499993          	slli	s3,s3,0x4
    800009b4:	fff9091b          	addiw	s2,s2,-1
    800009b8:	fe0912e3          	bnez	s2,8000099c <printf+0x2f4>
    800009bc:	dadff06f          	j	80000768 <printf+0xc0>
      consputc(va_arg(ap, uint));
    800009c0:	f8843783          	ld	a5,-120(s0)
    800009c4:	00878713          	addi	a4,a5,8
    800009c8:	f8e43423          	sd	a4,-120(s0)
    800009cc:	0007a503          	lw	a0,0(a5)
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	978080e7          	jalr	-1672(ra) # 80000348 <consputc>
    800009d8:	d91ff06f          	j	80000768 <printf+0xc0>
      if((s = va_arg(ap, char*)) == 0)
    800009dc:	f8843783          	ld	a5,-120(s0)
    800009e0:	00878713          	addi	a4,a5,8
    800009e4:	f8e43423          	sd	a4,-120(s0)
    800009e8:	0007b903          	ld	s2,0(a5)
    800009ec:	02090263          	beqz	s2,80000a10 <printf+0x368>
      for(; *s; s++)
    800009f0:	00094503          	lbu	a0,0(s2)
    800009f4:	d6050ae3          	beqz	a0,80000768 <printf+0xc0>
        consputc(*s);
    800009f8:	00000097          	auipc	ra,0x0
    800009fc:	950080e7          	jalr	-1712(ra) # 80000348 <consputc>
      for(; *s; s++)
    80000a00:	00190913          	addi	s2,s2,1
    80000a04:	00094503          	lbu	a0,0(s2)
    80000a08:	fe0518e3          	bnez	a0,800009f8 <printf+0x350>
    80000a0c:	d5dff06f          	j	80000768 <printf+0xc0>
        s = "(null)";
    80000a10:	00009917          	auipc	s2,0x9
    80000a14:	60890913          	addi	s2,s2,1544 # 8000a018 <etext+0x18>
      for(; *s; s++)
    80000a18:	02800513          	li	a0,40
    80000a1c:	fddff06f          	j	800009f8 <printf+0x350>
    }

  }
  va_end(ap);

  if(panicking == 0)
    80000a20:	0000a797          	auipc	a5,0xa
    80000a24:	f747a783          	lw	a5,-140(a5) # 8000a994 <panicking>
    80000a28:	04078263          	beqz	a5,80000a6c <printf+0x3c4>
    release(&pr.lock);

  return 0;
}
    80000a2c:	00000513          	li	a0,0
    80000a30:	07813083          	ld	ra,120(sp)
    80000a34:	07013403          	ld	s0,112(sp)
    80000a38:	06813483          	ld	s1,104(sp)
    80000a3c:	06013903          	ld	s2,96(sp)
    80000a40:	05813983          	ld	s3,88(sp)
    80000a44:	05013a03          	ld	s4,80(sp)
    80000a48:	04813a83          	ld	s5,72(sp)
    80000a4c:	04013b03          	ld	s6,64(sp)
    80000a50:	03813b83          	ld	s7,56(sp)
    80000a54:	03013c03          	ld	s8,48(sp)
    80000a58:	02813c83          	ld	s9,40(sp)
    80000a5c:	02013d03          	ld	s10,32(sp)
    80000a60:	01813d83          	ld	s11,24(sp)
    80000a64:	0c010113          	addi	sp,sp,192
    80000a68:	00008067          	ret
    release(&pr.lock);
    80000a6c:	00012517          	auipc	a0,0x12
    80000a70:	ffc50513          	addi	a0,a0,-4 # 80012a68 <pr>
    80000a74:	00000097          	auipc	ra,0x0
    80000a78:	71c080e7          	jalr	1820(ra) # 80001190 <release>
  return 0;
    80000a7c:	fb1ff06f          	j	80000a2c <printf+0x384>

0000000080000a80 <panic>:

void
panic(char *s)
{
    80000a80:	fe010113          	addi	sp,sp,-32
    80000a84:	00113c23          	sd	ra,24(sp)
    80000a88:	00813823          	sd	s0,16(sp)
    80000a8c:	00913423          	sd	s1,8(sp)
    80000a90:	01213023          	sd	s2,0(sp)
    80000a94:	02010413          	addi	s0,sp,32
    80000a98:	00050493          	mv	s1,a0
  panicking = 1;
    80000a9c:	00100913          	li	s2,1
    80000aa0:	0000a797          	auipc	a5,0xa
    80000aa4:	ef27aa23          	sw	s2,-268(a5) # 8000a994 <panicking>
  printf("panic: ");
    80000aa8:	00009517          	auipc	a0,0x9
    80000aac:	57850513          	addi	a0,a0,1400 # 8000a020 <etext+0x20>
    80000ab0:	00000097          	auipc	ra,0x0
    80000ab4:	bf8080e7          	jalr	-1032(ra) # 800006a8 <printf>
  printf("%s\n", s);
    80000ab8:	00048593          	mv	a1,s1
    80000abc:	00009517          	auipc	a0,0x9
    80000ac0:	56c50513          	addi	a0,a0,1388 # 8000a028 <etext+0x28>
    80000ac4:	00000097          	auipc	ra,0x0
    80000ac8:	be4080e7          	jalr	-1052(ra) # 800006a8 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000acc:	0000a797          	auipc	a5,0xa
    80000ad0:	ed27a223          	sw	s2,-316(a5) # 8000a990 <panicked>
  for(;;)
    80000ad4:	0000006f          	j	80000ad4 <panic+0x54>

0000000080000ad8 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000ad8:	ff010113          	addi	sp,sp,-16
    80000adc:	00113423          	sd	ra,8(sp)
    80000ae0:	00813023          	sd	s0,0(sp)
    80000ae4:	01010413          	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000ae8:	00009597          	auipc	a1,0x9
    80000aec:	54858593          	addi	a1,a1,1352 # 8000a030 <etext+0x30>
    80000af0:	00012517          	auipc	a0,0x12
    80000af4:	f7850513          	addi	a0,a0,-136 # 80012a68 <pr>
    80000af8:	00000097          	auipc	ra,0x0
    80000afc:	4bc080e7          	jalr	1212(ra) # 80000fb4 <initlock>
}
    80000b00:	00813083          	ld	ra,8(sp)
    80000b04:	00013403          	ld	s0,0(sp)
    80000b08:	01010113          	addi	sp,sp,16
    80000b0c:	00008067          	ret

0000000080000b10 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000b10:	ff010113          	addi	sp,sp,-16
    80000b14:	00113423          	sd	ra,8(sp)
    80000b18:	00813023          	sd	s0,0(sp)
    80000b1c:	01010413          	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000b20:	100007b7          	lui	a5,0x10000
    80000b24:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000b28:	f8000713          	li	a4,-128
    80000b2c:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000b30:	00300713          	li	a4,3
    80000b34:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000b38:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000b3c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000b40:	00700693          	li	a3,7
    80000b44:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000b48:	00e780a3          	sb	a4,1(a5)

  initlock(&tx_lock, "uart");
    80000b4c:	00009597          	auipc	a1,0x9
    80000b50:	50458593          	addi	a1,a1,1284 # 8000a050 <digits+0x18>
    80000b54:	00012517          	auipc	a0,0x12
    80000b58:	f2c50513          	addi	a0,a0,-212 # 80012a80 <tx_lock>
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	458080e7          	jalr	1112(ra) # 80000fb4 <initlock>
}
    80000b64:	00813083          	ld	ra,8(sp)
    80000b68:	00013403          	ld	s0,0(sp)
    80000b6c:	01010113          	addi	sp,sp,16
    80000b70:	00008067          	ret

0000000080000b74 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000b74:	fb010113          	addi	sp,sp,-80
    80000b78:	04113423          	sd	ra,72(sp)
    80000b7c:	04813023          	sd	s0,64(sp)
    80000b80:	02913c23          	sd	s1,56(sp)
    80000b84:	03213823          	sd	s2,48(sp)
    80000b88:	03313423          	sd	s3,40(sp)
    80000b8c:	03413023          	sd	s4,32(sp)
    80000b90:	01513c23          	sd	s5,24(sp)
    80000b94:	01613823          	sd	s6,16(sp)
    80000b98:	01713423          	sd	s7,8(sp)
    80000b9c:	05010413          	addi	s0,sp,80
    80000ba0:	00050493          	mv	s1,a0
    80000ba4:	00058913          	mv	s2,a1
  acquire(&tx_lock);
    80000ba8:	00012517          	auipc	a0,0x12
    80000bac:	ed850513          	addi	a0,a0,-296 # 80012a80 <tx_lock>
    80000bb0:	00000097          	auipc	ra,0x0
    80000bb4:	4e8080e7          	jalr	1256(ra) # 80001098 <acquire>

  int i = 0;
  while(i < n){ 
    80000bb8:	07205c63          	blez	s2,80000c30 <uartwrite+0xbc>
    80000bbc:	00048a13          	mv	s4,s1
    80000bc0:	00148493          	addi	s1,s1,1
    80000bc4:	fff9079b          	addiw	a5,s2,-1
    80000bc8:	02079793          	slli	a5,a5,0x20
    80000bcc:	0207d793          	srli	a5,a5,0x20
    80000bd0:	00f48ab3          	add	s5,s1,a5
    while(tx_busy != 0){
    80000bd4:	0000a497          	auipc	s1,0xa
    80000bd8:	dc848493          	addi	s1,s1,-568 # 8000a99c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000bdc:	00012997          	auipc	s3,0x12
    80000be0:	ea498993          	addi	s3,s3,-348 # 80012a80 <tx_lock>
    80000be4:	0000a917          	auipc	s2,0xa
    80000be8:	db490913          	addi	s2,s2,-588 # 8000a998 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000bec:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000bf0:	00100b13          	li	s6,1
    80000bf4:	0300006f          	j	80000c24 <uartwrite+0xb0>
      sleep(&tx_chan, &tx_lock);
    80000bf8:	00098593          	mv	a1,s3
    80000bfc:	00090513          	mv	a0,s2
    80000c00:	00002097          	auipc	ra,0x2
    80000c04:	4b0080e7          	jalr	1200(ra) # 800030b0 <sleep>
    while(tx_busy != 0){
    80000c08:	0004a783          	lw	a5,0(s1)
    80000c0c:	fe0796e3          	bnez	a5,80000bf8 <uartwrite+0x84>
    WriteReg(THR, buf[i]);
    80000c10:	000a4783          	lbu	a5,0(s4)
    80000c14:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    80000c18:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000c1c:	001a0a13          	addi	s4,s4,1
    80000c20:	015a0863          	beq	s4,s5,80000c30 <uartwrite+0xbc>
    while(tx_busy != 0){
    80000c24:	0004a783          	lw	a5,0(s1)
    80000c28:	fc0798e3          	bnez	a5,80000bf8 <uartwrite+0x84>
    80000c2c:	fe5ff06f          	j	80000c10 <uartwrite+0x9c>
  }

  release(&tx_lock);
    80000c30:	00012517          	auipc	a0,0x12
    80000c34:	e5050513          	addi	a0,a0,-432 # 80012a80 <tx_lock>
    80000c38:	00000097          	auipc	ra,0x0
    80000c3c:	558080e7          	jalr	1368(ra) # 80001190 <release>
}
    80000c40:	04813083          	ld	ra,72(sp)
    80000c44:	04013403          	ld	s0,64(sp)
    80000c48:	03813483          	ld	s1,56(sp)
    80000c4c:	03013903          	ld	s2,48(sp)
    80000c50:	02813983          	ld	s3,40(sp)
    80000c54:	02013a03          	ld	s4,32(sp)
    80000c58:	01813a83          	ld	s5,24(sp)
    80000c5c:	01013b03          	ld	s6,16(sp)
    80000c60:	00813b83          	ld	s7,8(sp)
    80000c64:	05010113          	addi	sp,sp,80
    80000c68:	00008067          	ret

0000000080000c6c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000c6c:	fe010113          	addi	sp,sp,-32
    80000c70:	00113c23          	sd	ra,24(sp)
    80000c74:	00813823          	sd	s0,16(sp)
    80000c78:	00913423          	sd	s1,8(sp)
    80000c7c:	02010413          	addi	s0,sp,32
    80000c80:	00050493          	mv	s1,a0
  if(panicking == 0)
    80000c84:	0000a797          	auipc	a5,0xa
    80000c88:	d107a783          	lw	a5,-752(a5) # 8000a994 <panicking>
    80000c8c:	00078c63          	beqz	a5,80000ca4 <uartputc_sync+0x38>
    push_off();

  if(panicked){
    80000c90:	0000a797          	auipc	a5,0xa
    80000c94:	d007a783          	lw	a5,-768(a5) # 8000a990 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000c98:	10000737          	lui	a4,0x10000
  if(panicked){
    80000c9c:	00078a63          	beqz	a5,80000cb0 <uartputc_sync+0x44>
    for(;;)
    80000ca0:	0000006f          	j	80000ca0 <uartputc_sync+0x34>
    push_off();
    80000ca4:	00000097          	auipc	ra,0x0
    80000ca8:	380080e7          	jalr	896(ra) # 80001024 <push_off>
    80000cac:	fe5ff06f          	j	80000c90 <uartputc_sync+0x24>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000cb0:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000cb4:	0207f793          	andi	a5,a5,32
    80000cb8:	fe078ce3          	beqz	a5,80000cb0 <uartputc_sync+0x44>
    ;
  WriteReg(THR, c);
    80000cbc:	0ff4f513          	zext.b	a0,s1
    80000cc0:	100007b7          	lui	a5,0x10000
    80000cc4:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000cc8:	0000a797          	auipc	a5,0xa
    80000ccc:	ccc7a783          	lw	a5,-820(a5) # 8000a994 <panicking>
    80000cd0:	00078c63          	beqz	a5,80000ce8 <uartputc_sync+0x7c>
    pop_off();
}
    80000cd4:	01813083          	ld	ra,24(sp)
    80000cd8:	01013403          	ld	s0,16(sp)
    80000cdc:	00813483          	ld	s1,8(sp)
    80000ce0:	02010113          	addi	sp,sp,32
    80000ce4:	00008067          	ret
    pop_off();
    80000ce8:	00000097          	auipc	ra,0x0
    80000cec:	428080e7          	jalr	1064(ra) # 80001110 <pop_off>
}
    80000cf0:	fe5ff06f          	j	80000cd4 <uartputc_sync+0x68>

0000000080000cf4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000cf4:	ff010113          	addi	sp,sp,-16
    80000cf8:	00813423          	sd	s0,8(sp)
    80000cfc:	01010413          	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000d00:	100007b7          	lui	a5,0x10000
    80000d04:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000d08:	0017f793          	andi	a5,a5,1
    80000d0c:	00078c63          	beqz	a5,80000d24 <uartgetc+0x30>
    // input data is ready.
    return ReadReg(RHR);
    80000d10:	100007b7          	lui	a5,0x10000
    80000d14:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000d18:	00813403          	ld	s0,8(sp)
    80000d1c:	01010113          	addi	sp,sp,16
    80000d20:	00008067          	ret
    return -1;
    80000d24:	fff00513          	li	a0,-1
    80000d28:	ff1ff06f          	j	80000d18 <uartgetc+0x24>

0000000080000d2c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000d2c:	fe010113          	addi	sp,sp,-32
    80000d30:	00113c23          	sd	ra,24(sp)
    80000d34:	00813823          	sd	s0,16(sp)
    80000d38:	00913423          	sd	s1,8(sp)
    80000d3c:	02010413          	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000d40:	100004b7          	lui	s1,0x10000
    80000d44:	0024c783          	lbu	a5,2(s1) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000d48:	00012517          	auipc	a0,0x12
    80000d4c:	d3850513          	addi	a0,a0,-712 # 80012a80 <tx_lock>
    80000d50:	00000097          	auipc	ra,0x0
    80000d54:	348080e7          	jalr	840(ra) # 80001098 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000d58:	0054c783          	lbu	a5,5(s1)
    80000d5c:	0207f793          	andi	a5,a5,32
    80000d60:	00079e63          	bnez	a5,80000d7c <uartintr+0x50>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000d64:	00012517          	auipc	a0,0x12
    80000d68:	d1c50513          	addi	a0,a0,-740 # 80012a80 <tx_lock>
    80000d6c:	00000097          	auipc	ra,0x0
    80000d70:	424080e7          	jalr	1060(ra) # 80001190 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000d74:	fff00493          	li	s1,-1
    80000d78:	0280006f          	j	80000da0 <uartintr+0x74>
    tx_busy = 0;
    80000d7c:	0000a797          	auipc	a5,0xa
    80000d80:	c207a023          	sw	zero,-992(a5) # 8000a99c <tx_busy>
    wakeup(&tx_chan);
    80000d84:	0000a517          	auipc	a0,0xa
    80000d88:	c1450513          	addi	a0,a0,-1004 # 8000a998 <tx_chan>
    80000d8c:	00002097          	auipc	ra,0x2
    80000d90:	3b4080e7          	jalr	948(ra) # 80003140 <wakeup>
    80000d94:	fd1ff06f          	j	80000d64 <uartintr+0x38>
      break;
    consoleintr(c);
    80000d98:	fffff097          	auipc	ra,0xfffff
    80000d9c:	608080e7          	jalr	1544(ra) # 800003a0 <consoleintr>
    int c = uartgetc();
    80000da0:	00000097          	auipc	ra,0x0
    80000da4:	f54080e7          	jalr	-172(ra) # 80000cf4 <uartgetc>
    if(c == -1)
    80000da8:	fe9518e3          	bne	a0,s1,80000d98 <uartintr+0x6c>
  }
}
    80000dac:	01813083          	ld	ra,24(sp)
    80000db0:	01013403          	ld	s0,16(sp)
    80000db4:	00813483          	ld	s1,8(sp)
    80000db8:	02010113          	addi	sp,sp,32
    80000dbc:	00008067          	ret

0000000080000dc0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000dc0:	fe010113          	addi	sp,sp,-32
    80000dc4:	00113c23          	sd	ra,24(sp)
    80000dc8:	00813823          	sd	s0,16(sp)
    80000dcc:	00913423          	sd	s1,8(sp)
    80000dd0:	01213023          	sd	s2,0(sp)
    80000dd4:	02010413          	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000dd8:	03451793          	slli	a5,a0,0x34
    80000ddc:	06079a63          	bnez	a5,80000e50 <kfree+0x90>
    80000de0:	00050493          	mv	s1,a0
    80000de4:	00023797          	auipc	a5,0x23
    80000de8:	ee478793          	addi	a5,a5,-284 # 80023cc8 <end>
    80000dec:	06f56263          	bltu	a0,a5,80000e50 <kfree+0x90>
    80000df0:	01100793          	li	a5,17
    80000df4:	01b79793          	slli	a5,a5,0x1b
    80000df8:	04f57c63          	bgeu	a0,a5,80000e50 <kfree+0x90>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);  //1个4KB，
    80000dfc:	00001637          	lui	a2,0x1
    80000e00:	00100593          	li	a1,1
    80000e04:	00000097          	auipc	ra,0x0
    80000e08:	3ec080e7          	jalr	1004(ra) # 800011f0 <memset>

  r = (struct run*)pa;
  acquire(&kmem.lock);
    80000e0c:	00012917          	auipc	s2,0x12
    80000e10:	c8c90913          	addi	s2,s2,-884 # 80012a98 <kmem>
    80000e14:	00090513          	mv	a0,s2
    80000e18:	00000097          	auipc	ra,0x0
    80000e1c:	280080e7          	jalr	640(ra) # 80001098 <acquire>
  r->next = kmem.freelist;
    80000e20:	01893783          	ld	a5,24(s2)
    80000e24:	00f4b023          	sd	a5,0(s1)
  kmem.freelist = r;
    80000e28:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000e2c:	00090513          	mv	a0,s2
    80000e30:	00000097          	auipc	ra,0x0
    80000e34:	360080e7          	jalr	864(ra) # 80001190 <release>
}
    80000e38:	01813083          	ld	ra,24(sp)
    80000e3c:	01013403          	ld	s0,16(sp)
    80000e40:	00813483          	ld	s1,8(sp)
    80000e44:	00013903          	ld	s2,0(sp)
    80000e48:	02010113          	addi	sp,sp,32
    80000e4c:	00008067          	ret
    panic("kfree");
    80000e50:	00009517          	auipc	a0,0x9
    80000e54:	20850513          	addi	a0,a0,520 # 8000a058 <digits+0x20>
    80000e58:	00000097          	auipc	ra,0x0
    80000e5c:	c28080e7          	jalr	-984(ra) # 80000a80 <panic>

0000000080000e60 <freerange>:
{
    80000e60:	fd010113          	addi	sp,sp,-48
    80000e64:	02113423          	sd	ra,40(sp)
    80000e68:	02813023          	sd	s0,32(sp)
    80000e6c:	00913c23          	sd	s1,24(sp)
    80000e70:	01213823          	sd	s2,16(sp)
    80000e74:	01313423          	sd	s3,8(sp)
    80000e78:	01413023          	sd	s4,0(sp)
    80000e7c:	03010413          	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000e80:	000017b7          	lui	a5,0x1
    80000e84:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000e88:	00e504b3          	add	s1,a0,a4
    80000e8c:	fffff737          	lui	a4,0xfffff
    80000e90:	00e4f4b3          	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000e94:	00f484b3          	add	s1,s1,a5
    80000e98:	0295e263          	bltu	a1,s1,80000ebc <freerange+0x5c>
    80000e9c:	00058913          	mv	s2,a1
    kfree(p);
    80000ea0:	fffffa37          	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ea4:	000019b7          	lui	s3,0x1
    kfree(p);
    80000ea8:	01448533          	add	a0,s1,s4
    80000eac:	00000097          	auipc	ra,0x0
    80000eb0:	f14080e7          	jalr	-236(ra) # 80000dc0 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000eb4:	013484b3          	add	s1,s1,s3
    80000eb8:	fe9978e3          	bgeu	s2,s1,80000ea8 <freerange+0x48>
}
    80000ebc:	02813083          	ld	ra,40(sp)
    80000ec0:	02013403          	ld	s0,32(sp)
    80000ec4:	01813483          	ld	s1,24(sp)
    80000ec8:	01013903          	ld	s2,16(sp)
    80000ecc:	00813983          	ld	s3,8(sp)
    80000ed0:	00013a03          	ld	s4,0(sp)
    80000ed4:	03010113          	addi	sp,sp,48
    80000ed8:	00008067          	ret

0000000080000edc <kinit>:
{
    80000edc:	ff010113          	addi	sp,sp,-16
    80000ee0:	00113423          	sd	ra,8(sp)
    80000ee4:	00813023          	sd	s0,0(sp)
    80000ee8:	01010413          	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000eec:	00009597          	auipc	a1,0x9
    80000ef0:	17458593          	addi	a1,a1,372 # 8000a060 <digits+0x28>
    80000ef4:	00012517          	auipc	a0,0x12
    80000ef8:	ba450513          	addi	a0,a0,-1116 # 80012a98 <kmem>
    80000efc:	00000097          	auipc	ra,0x0
    80000f00:	0b8080e7          	jalr	184(ra) # 80000fb4 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000f04:	01100593          	li	a1,17
    80000f08:	01b59593          	slli	a1,a1,0x1b
    80000f0c:	00023517          	auipc	a0,0x23
    80000f10:	dbc50513          	addi	a0,a0,-580 # 80023cc8 <end>
    80000f14:	00000097          	auipc	ra,0x0
    80000f18:	f4c080e7          	jalr	-180(ra) # 80000e60 <freerange>
}
    80000f1c:	00813083          	ld	ra,8(sp)
    80000f20:	00013403          	ld	s0,0(sp)
    80000f24:	01010113          	addi	sp,sp,16
    80000f28:	00008067          	ret

0000000080000f2c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000f2c:	fe010113          	addi	sp,sp,-32
    80000f30:	00113c23          	sd	ra,24(sp)
    80000f34:	00813823          	sd	s0,16(sp)
    80000f38:	00913423          	sd	s1,8(sp)
    80000f3c:	02010413          	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);            //fence
    80000f40:	00012497          	auipc	s1,0x12
    80000f44:	b5848493          	addi	s1,s1,-1192 # 80012a98 <kmem>
    80000f48:	00048513          	mv	a0,s1
    80000f4c:	00000097          	auipc	ra,0x0
    80000f50:	14c080e7          	jalr	332(ra) # 80001098 <acquire>
  r = kmem.freelist;
    80000f54:	0184b483          	ld	s1,24(s1)
  if(r)
    80000f58:	04048463          	beqz	s1,80000fa0 <kalloc+0x74>
    kmem.freelist = r->next;
    80000f5c:	0004b783          	ld	a5,0(s1)
    80000f60:	00012517          	auipc	a0,0x12
    80000f64:	b3850513          	addi	a0,a0,-1224 # 80012a98 <kmem>
    80000f68:	00f53c23          	sd	a5,24(a0)
  release(&kmem.lock);
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	224080e7          	jalr	548(ra) # 80001190 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000f74:	00001637          	lui	a2,0x1
    80000f78:	00500593          	li	a1,5
    80000f7c:	00048513          	mv	a0,s1
    80000f80:	00000097          	auipc	ra,0x0
    80000f84:	270080e7          	jalr	624(ra) # 800011f0 <memset>
  return (void*)r;
}
    80000f88:	00048513          	mv	a0,s1
    80000f8c:	01813083          	ld	ra,24(sp)
    80000f90:	01013403          	ld	s0,16(sp)
    80000f94:	00813483          	ld	s1,8(sp)
    80000f98:	02010113          	addi	sp,sp,32
    80000f9c:	00008067          	ret
  release(&kmem.lock);
    80000fa0:	00012517          	auipc	a0,0x12
    80000fa4:	af850513          	addi	a0,a0,-1288 # 80012a98 <kmem>
    80000fa8:	00000097          	auipc	ra,0x0
    80000fac:	1e8080e7          	jalr	488(ra) # 80001190 <release>
  if(r)
    80000fb0:	fd9ff06f          	j	80000f88 <kalloc+0x5c>

0000000080000fb4 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000fb4:	ff010113          	addi	sp,sp,-16
    80000fb8:	00813423          	sd	s0,8(sp)
    80000fbc:	01010413          	addi	s0,sp,16
  lk->name = name;
    80000fc0:	00b53423          	sd	a1,8(a0)
  lk->locked = 0;
    80000fc4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000fc8:	00053823          	sd	zero,16(a0)
}
    80000fcc:	00813403          	ld	s0,8(sp)
    80000fd0:	01010113          	addi	sp,sp,16
    80000fd4:	00008067          	ret

0000000080000fd8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000fd8:	00052783          	lw	a5,0(a0)
    80000fdc:	00079663          	bnez	a5,80000fe8 <holding+0x10>
    80000fe0:	00000513          	li	a0,0
  return r;
}
    80000fe4:	00008067          	ret
{
    80000fe8:	fe010113          	addi	sp,sp,-32
    80000fec:	00113c23          	sd	ra,24(sp)
    80000ff0:	00813823          	sd	s0,16(sp)
    80000ff4:	00913423          	sd	s1,8(sp)
    80000ff8:	02010413          	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ffc:	01053483          	ld	s1,16(a0)
    80001000:	00001097          	auipc	ra,0x1
    80001004:	6c8080e7          	jalr	1736(ra) # 800026c8 <mycpu>
    80001008:	40a48533          	sub	a0,s1,a0
    8000100c:	00153513          	seqz	a0,a0
}
    80001010:	01813083          	ld	ra,24(sp)
    80001014:	01013403          	ld	s0,16(sp)
    80001018:	00813483          	ld	s1,8(sp)
    8000101c:	02010113          	addi	sp,sp,32
    80001020:	00008067          	ret

0000000080001024 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80001024:	fe010113          	addi	sp,sp,-32
    80001028:	00113c23          	sd	ra,24(sp)
    8000102c:	00813823          	sd	s0,16(sp)
    80001030:	00913423          	sd	s1,8(sp)
    80001034:	02010413          	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001038:	100024f3          	csrr	s1,sstatus
    8000103c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001040:	ffd7f793          	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001044:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80001048:	00001097          	auipc	ra,0x1
    8000104c:	680080e7          	jalr	1664(ra) # 800026c8 <mycpu>
    80001050:	07852783          	lw	a5,120(a0)
    80001054:	02078663          	beqz	a5,80001080 <push_off+0x5c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80001058:	00001097          	auipc	ra,0x1
    8000105c:	670080e7          	jalr	1648(ra) # 800026c8 <mycpu>
    80001060:	07852783          	lw	a5,120(a0)
    80001064:	0017879b          	addiw	a5,a5,1
    80001068:	06f52c23          	sw	a5,120(a0)
}
    8000106c:	01813083          	ld	ra,24(sp)
    80001070:	01013403          	ld	s0,16(sp)
    80001074:	00813483          	ld	s1,8(sp)
    80001078:	02010113          	addi	sp,sp,32
    8000107c:	00008067          	ret
    mycpu()->intena = old;
    80001080:	00001097          	auipc	ra,0x1
    80001084:	648080e7          	jalr	1608(ra) # 800026c8 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80001088:	0014d493          	srli	s1,s1,0x1
    8000108c:	0014f493          	andi	s1,s1,1
    80001090:	06952e23          	sw	s1,124(a0)
    80001094:	fc5ff06f          	j	80001058 <push_off+0x34>

0000000080001098 <acquire>:
{
    80001098:	fe010113          	addi	sp,sp,-32
    8000109c:	00113c23          	sd	ra,24(sp)
    800010a0:	00813823          	sd	s0,16(sp)
    800010a4:	00913423          	sd	s1,8(sp)
    800010a8:	02010413          	addi	s0,sp,32
    800010ac:	00050493          	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800010b0:	00000097          	auipc	ra,0x0
    800010b4:	f74080e7          	jalr	-140(ra) # 80001024 <push_off>
  if(holding(lk))
    800010b8:	00048513          	mv	a0,s1
    800010bc:	00000097          	auipc	ra,0x0
    800010c0:	f1c080e7          	jalr	-228(ra) # 80000fd8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800010c4:	00100713          	li	a4,1
  if(holding(lk))
    800010c8:	02051c63          	bnez	a0,80001100 <acquire+0x68>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800010cc:	00070793          	mv	a5,a4
    800010d0:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800010d4:	0007879b          	sext.w	a5,a5
    800010d8:	fe079ae3          	bnez	a5,800010cc <acquire+0x34>
  __sync_synchronize();
    800010dc:	0ff0000f          	fence
  lk->cpu = mycpu();
    800010e0:	00001097          	auipc	ra,0x1
    800010e4:	5e8080e7          	jalr	1512(ra) # 800026c8 <mycpu>
    800010e8:	00a4b823          	sd	a0,16(s1)
}
    800010ec:	01813083          	ld	ra,24(sp)
    800010f0:	01013403          	ld	s0,16(sp)
    800010f4:	00813483          	ld	s1,8(sp)
    800010f8:	02010113          	addi	sp,sp,32
    800010fc:	00008067          	ret
    panic("acquire");
    80001100:	00009517          	auipc	a0,0x9
    80001104:	f6850513          	addi	a0,a0,-152 # 8000a068 <digits+0x30>
    80001108:	00000097          	auipc	ra,0x0
    8000110c:	978080e7          	jalr	-1672(ra) # 80000a80 <panic>

0000000080001110 <pop_off>:

void
pop_off(void)
{
    80001110:	ff010113          	addi	sp,sp,-16
    80001114:	00113423          	sd	ra,8(sp)
    80001118:	00813023          	sd	s0,0(sp)
    8000111c:	01010413          	addi	s0,sp,16
  struct cpu *c = mycpu();
    80001120:	00001097          	auipc	ra,0x1
    80001124:	5a8080e7          	jalr	1448(ra) # 800026c8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001128:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000112c:	0027f793          	andi	a5,a5,2
  if(intr_get())
    80001130:	04079063          	bnez	a5,80001170 <pop_off+0x60>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80001134:	07852783          	lw	a5,120(a0)
    80001138:	04f05463          	blez	a5,80001180 <pop_off+0x70>
    panic("pop_off");
  c->noff -= 1;
    8000113c:	fff7879b          	addiw	a5,a5,-1
    80001140:	0007871b          	sext.w	a4,a5
    80001144:	06f52c23          	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80001148:	00071c63          	bnez	a4,80001160 <pop_off+0x50>
    8000114c:	07c52783          	lw	a5,124(a0)
    80001150:	00078863          	beqz	a5,80001160 <pop_off+0x50>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001154:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001158:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000115c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80001160:	00813083          	ld	ra,8(sp)
    80001164:	00013403          	ld	s0,0(sp)
    80001168:	01010113          	addi	sp,sp,16
    8000116c:	00008067          	ret
    panic("pop_off - interruptible");
    80001170:	00009517          	auipc	a0,0x9
    80001174:	f0050513          	addi	a0,a0,-256 # 8000a070 <digits+0x38>
    80001178:	00000097          	auipc	ra,0x0
    8000117c:	908080e7          	jalr	-1784(ra) # 80000a80 <panic>
    panic("pop_off");
    80001180:	00009517          	auipc	a0,0x9
    80001184:	f0850513          	addi	a0,a0,-248 # 8000a088 <digits+0x50>
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	8f8080e7          	jalr	-1800(ra) # 80000a80 <panic>

0000000080001190 <release>:
{
    80001190:	fe010113          	addi	sp,sp,-32
    80001194:	00113c23          	sd	ra,24(sp)
    80001198:	00813823          	sd	s0,16(sp)
    8000119c:	00913423          	sd	s1,8(sp)
    800011a0:	02010413          	addi	s0,sp,32
    800011a4:	00050493          	mv	s1,a0
  if(!holding(lk))
    800011a8:	00000097          	auipc	ra,0x0
    800011ac:	e30080e7          	jalr	-464(ra) # 80000fd8 <holding>
    800011b0:	02050863          	beqz	a0,800011e0 <release+0x50>
  lk->cpu = 0;
    800011b4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    800011b8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    800011bc:	0f50000f          	fence	iorw,ow
    800011c0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	f4c080e7          	jalr	-180(ra) # 80001110 <pop_off>
}
    800011cc:	01813083          	ld	ra,24(sp)
    800011d0:	01013403          	ld	s0,16(sp)
    800011d4:	00813483          	ld	s1,8(sp)
    800011d8:	02010113          	addi	sp,sp,32
    800011dc:	00008067          	ret
    panic("release");
    800011e0:	00009517          	auipc	a0,0x9
    800011e4:	eb050513          	addi	a0,a0,-336 # 8000a090 <digits+0x58>
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	898080e7          	jalr	-1896(ra) # 80000a80 <panic>

00000000800011f0 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800011f0:	ff010113          	addi	sp,sp,-16
    800011f4:	00813423          	sd	s0,8(sp)
    800011f8:	01010413          	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800011fc:	02060063          	beqz	a2,8000121c <memset+0x2c>
    80001200:	00050793          	mv	a5,a0
    80001204:	02061613          	slli	a2,a2,0x20
    80001208:	02065613          	srli	a2,a2,0x20
    8000120c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80001210:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80001214:	00178793          	addi	a5,a5,1
    80001218:	fee79ce3          	bne	a5,a4,80001210 <memset+0x20>
  }
  return dst;
}
    8000121c:	00813403          	ld	s0,8(sp)
    80001220:	01010113          	addi	sp,sp,16
    80001224:	00008067          	ret

0000000080001228 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80001228:	ff010113          	addi	sp,sp,-16
    8000122c:	00813423          	sd	s0,8(sp)
    80001230:	01010413          	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80001234:	04060463          	beqz	a2,8000127c <memcmp+0x54>
    80001238:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    8000123c:	02069693          	slli	a3,a3,0x20
    80001240:	0206d693          	srli	a3,a3,0x20
    80001244:	00168693          	addi	a3,a3,1
    80001248:	00d506b3          	add	a3,a0,a3
    if(*s1 != *s2)
    8000124c:	00054783          	lbu	a5,0(a0)
    80001250:	0005c703          	lbu	a4,0(a1)
    80001254:	00e79c63          	bne	a5,a4,8000126c <memcmp+0x44>
      return *s1 - *s2;
    s1++, s2++;
    80001258:	00150513          	addi	a0,a0,1
    8000125c:	00158593          	addi	a1,a1,1
  while(n-- > 0){
    80001260:	fed516e3          	bne	a0,a3,8000124c <memcmp+0x24>
  }

  return 0;
    80001264:	00000513          	li	a0,0
    80001268:	0080006f          	j	80001270 <memcmp+0x48>
      return *s1 - *s2;
    8000126c:	40e7853b          	subw	a0,a5,a4
}
    80001270:	00813403          	ld	s0,8(sp)
    80001274:	01010113          	addi	sp,sp,16
    80001278:	00008067          	ret
  return 0;
    8000127c:	00000513          	li	a0,0
    80001280:	ff1ff06f          	j	80001270 <memcmp+0x48>

0000000080001284 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80001284:	ff010113          	addi	sp,sp,-16
    80001288:	00813423          	sd	s0,8(sp)
    8000128c:	01010413          	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80001290:	02060663          	beqz	a2,800012bc <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80001294:	02a5ea63          	bltu	a1,a0,800012c8 <memmove+0x44>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80001298:	02061613          	slli	a2,a2,0x20
    8000129c:	02065613          	srli	a2,a2,0x20
    800012a0:	00c587b3          	add	a5,a1,a2
{
    800012a4:	00050713          	mv	a4,a0
      *d++ = *s++;
    800012a8:	00158593          	addi	a1,a1,1
    800012ac:	00170713          	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb339>
    800012b0:	fff5c683          	lbu	a3,-1(a1)
    800012b4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800012b8:	fef598e3          	bne	a1,a5,800012a8 <memmove+0x24>

  return dst;
}
    800012bc:	00813403          	ld	s0,8(sp)
    800012c0:	01010113          	addi	sp,sp,16
    800012c4:	00008067          	ret
  if(s < d && s + n > d){
    800012c8:	02061693          	slli	a3,a2,0x20
    800012cc:	0206d693          	srli	a3,a3,0x20
    800012d0:	00d58733          	add	a4,a1,a3
    800012d4:	fce572e3          	bgeu	a0,a4,80001298 <memmove+0x14>
    d += n;
    800012d8:	00d506b3          	add	a3,a0,a3
    while(n-- > 0)
    800012dc:	fff6079b          	addiw	a5,a2,-1
    800012e0:	02079793          	slli	a5,a5,0x20
    800012e4:	0207d793          	srli	a5,a5,0x20
    800012e8:	fff7c793          	not	a5,a5
    800012ec:	00f707b3          	add	a5,a4,a5
      *--d = *--s;
    800012f0:	fff70713          	addi	a4,a4,-1
    800012f4:	fff68693          	addi	a3,a3,-1
    800012f8:	00074603          	lbu	a2,0(a4)
    800012fc:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80001300:	fee798e3          	bne	a5,a4,800012f0 <memmove+0x6c>
    80001304:	fb9ff06f          	j	800012bc <memmove+0x38>

0000000080001308 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80001308:	ff010113          	addi	sp,sp,-16
    8000130c:	00113423          	sd	ra,8(sp)
    80001310:	00813023          	sd	s0,0(sp)
    80001314:	01010413          	addi	s0,sp,16
  return memmove(dst, src, n);
    80001318:	00000097          	auipc	ra,0x0
    8000131c:	f6c080e7          	jalr	-148(ra) # 80001284 <memmove>
}
    80001320:	00813083          	ld	ra,8(sp)
    80001324:	00013403          	ld	s0,0(sp)
    80001328:	01010113          	addi	sp,sp,16
    8000132c:	00008067          	ret

0000000080001330 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80001330:	ff010113          	addi	sp,sp,-16
    80001334:	00813423          	sd	s0,8(sp)
    80001338:	01010413          	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    8000133c:	02060663          	beqz	a2,80001368 <strncmp+0x38>
    80001340:	00054783          	lbu	a5,0(a0)
    80001344:	02078663          	beqz	a5,80001370 <strncmp+0x40>
    80001348:	0005c703          	lbu	a4,0(a1)
    8000134c:	02f71263          	bne	a4,a5,80001370 <strncmp+0x40>
    n--, p++, q++;
    80001350:	fff6061b          	addiw	a2,a2,-1
    80001354:	00150513          	addi	a0,a0,1
    80001358:	00158593          	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000135c:	fe0612e3          	bnez	a2,80001340 <strncmp+0x10>
  if(n == 0)
    return 0;
    80001360:	00000513          	li	a0,0
    80001364:	01c0006f          	j	80001380 <strncmp+0x50>
    80001368:	00000513          	li	a0,0
    8000136c:	0140006f          	j	80001380 <strncmp+0x50>
  if(n == 0)
    80001370:	00060e63          	beqz	a2,8000138c <strncmp+0x5c>
  return (uchar)*p - (uchar)*q;
    80001374:	00054503          	lbu	a0,0(a0)
    80001378:	0005c783          	lbu	a5,0(a1)
    8000137c:	40f5053b          	subw	a0,a0,a5
}
    80001380:	00813403          	ld	s0,8(sp)
    80001384:	01010113          	addi	sp,sp,16
    80001388:	00008067          	ret
    return 0;
    8000138c:	00000513          	li	a0,0
    80001390:	ff1ff06f          	j	80001380 <strncmp+0x50>

0000000080001394 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80001394:	ff010113          	addi	sp,sp,-16
    80001398:	00813423          	sd	s0,8(sp)
    8000139c:	01010413          	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800013a0:	00050713          	mv	a4,a0
    800013a4:	00060813          	mv	a6,a2
    800013a8:	fff6061b          	addiw	a2,a2,-1
    800013ac:	01005c63          	blez	a6,800013c4 <strncpy+0x30>
    800013b0:	00170713          	addi	a4,a4,1
    800013b4:	0005c783          	lbu	a5,0(a1)
    800013b8:	fef70fa3          	sb	a5,-1(a4)
    800013bc:	00158593          	addi	a1,a1,1
    800013c0:	fe0792e3          	bnez	a5,800013a4 <strncpy+0x10>
    ;
  while(n-- > 0)
    800013c4:	00070693          	mv	a3,a4
    800013c8:	00c05e63          	blez	a2,800013e4 <strncpy+0x50>
    *s++ = 0;
    800013cc:	00168693          	addi	a3,a3,1
    800013d0:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800013d4:	40d707bb          	subw	a5,a4,a3
    800013d8:	fff7879b          	addiw	a5,a5,-1
    800013dc:	010787bb          	addw	a5,a5,a6
    800013e0:	fef046e3          	bgtz	a5,800013cc <strncpy+0x38>
  return os;
}
    800013e4:	00813403          	ld	s0,8(sp)
    800013e8:	01010113          	addi	sp,sp,16
    800013ec:	00008067          	ret

00000000800013f0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800013f0:	ff010113          	addi	sp,sp,-16
    800013f4:	00813423          	sd	s0,8(sp)
    800013f8:	01010413          	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800013fc:	02c05a63          	blez	a2,80001430 <safestrcpy+0x40>
    80001400:	fff6069b          	addiw	a3,a2,-1
    80001404:	02069693          	slli	a3,a3,0x20
    80001408:	0206d693          	srli	a3,a3,0x20
    8000140c:	00d586b3          	add	a3,a1,a3
    80001410:	00050793          	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001414:	00d58c63          	beq	a1,a3,8000142c <safestrcpy+0x3c>
    80001418:	00158593          	addi	a1,a1,1
    8000141c:	00178793          	addi	a5,a5,1
    80001420:	fff5c703          	lbu	a4,-1(a1)
    80001424:	fee78fa3          	sb	a4,-1(a5)
    80001428:	fe0716e3          	bnez	a4,80001414 <safestrcpy+0x24>
    ;
  *s = 0;
    8000142c:	00078023          	sb	zero,0(a5)
  return os;
}
    80001430:	00813403          	ld	s0,8(sp)
    80001434:	01010113          	addi	sp,sp,16
    80001438:	00008067          	ret

000000008000143c <strlen>:

int
strlen(const char *s)
{
    8000143c:	ff010113          	addi	sp,sp,-16
    80001440:	00813423          	sd	s0,8(sp)
    80001444:	01010413          	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001448:	00054783          	lbu	a5,0(a0)
    8000144c:	02078863          	beqz	a5,8000147c <strlen+0x40>
    80001450:	00150513          	addi	a0,a0,1
    80001454:	00050793          	mv	a5,a0
    80001458:	00100693          	li	a3,1
    8000145c:	40a686bb          	subw	a3,a3,a0
    80001460:	00f6853b          	addw	a0,a3,a5
    80001464:	00178793          	addi	a5,a5,1
    80001468:	fff7c703          	lbu	a4,-1(a5)
    8000146c:	fe071ae3          	bnez	a4,80001460 <strlen+0x24>
    ;
  return n;
}
    80001470:	00813403          	ld	s0,8(sp)
    80001474:	01010113          	addi	sp,sp,16
    80001478:	00008067          	ret
  for(n = 0; s[n]; n++)
    8000147c:	00000513          	li	a0,0
    80001480:	ff1ff06f          	j	80001470 <strlen+0x34>

0000000080001484 <main>:
// start() jumps here in supervisor mode on all CPUs.


void
main()
{
    80001484:	ff010113          	addi	sp,sp,-16
    80001488:	00113423          	sd	ra,8(sp)
    8000148c:	00813023          	sd	s0,0(sp)
    80001490:	01010413          	addi	s0,sp,16
  if(cpuid() == 0){
    80001494:	00001097          	auipc	ra,0x1
    80001498:	214080e7          	jalr	532(ra) # 800026a8 <cpuid>

    printf("__sync_synchronize start \n");
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000149c:	00009717          	auipc	a4,0x9
    800014a0:	50470713          	addi	a4,a4,1284 # 8000a9a0 <started>
  if(cpuid() == 0){
    800014a4:	04050863          	beqz	a0,800014f4 <main+0x70>
    while(started == 0)
    800014a8:	00072783          	lw	a5,0(a4)
    800014ac:	0007879b          	sext.w	a5,a5
    800014b0:	fe078ce3          	beqz	a5,800014a8 <main+0x24>
      ;
    __sync_synchronize();
    800014b4:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800014b8:	00001097          	auipc	ra,0x1
    800014bc:	1f0080e7          	jalr	496(ra) # 800026a8 <cpuid>
    800014c0:	00050593          	mv	a1,a0
    800014c4:	00009517          	auipc	a0,0x9
    800014c8:	d3c50513          	addi	a0,a0,-708 # 8000a200 <digits+0x1c8>
    800014cc:	fffff097          	auipc	ra,0xfffff
    800014d0:	1dc080e7          	jalr	476(ra) # 800006a8 <printf>
    kvminithart();    // turn on paging
    800014d4:	00000097          	auipc	ra,0x0
    800014d8:	1dc080e7          	jalr	476(ra) # 800016b0 <kvminithart>
    trapinithart();   // install kernel trap vector
    800014dc:	00002097          	auipc	ra,0x2
    800014e0:	42c080e7          	jalr	1068(ra) # 80003908 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800014e4:	00007097          	auipc	ra,0x7
    800014e8:	eb4080e7          	jalr	-332(ra) # 80008398 <plicinithart>
  }

  scheduler();        
    800014ec:	00002097          	auipc	ra,0x2
    800014f0:	950080e7          	jalr	-1712(ra) # 80002e3c <scheduler>
    consoleinit();          
    800014f4:	fffff097          	auipc	ra,0xfffff
    800014f8:	084080e7          	jalr	132(ra) # 80000578 <consoleinit>
    printfinit();           
    800014fc:	fffff097          	auipc	ra,0xfffff
    80001500:	5dc080e7          	jalr	1500(ra) # 80000ad8 <printfinit>
    printf("\n");             
    80001504:	00009517          	auipc	a0,0x9
    80001508:	d0c50513          	addi	a0,a0,-756 # 8000a210 <digits+0x1d8>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	19c080e7          	jalr	412(ra) # 800006a8 <printf>
    printf("xv6 kernel is booting\n");     
    80001514:	00009517          	auipc	a0,0x9
    80001518:	b8450513          	addi	a0,a0,-1148 # 8000a098 <digits+0x60>
    8000151c:	fffff097          	auipc	ra,0xfffff
    80001520:	18c080e7          	jalr	396(ra) # 800006a8 <printf>
    printf("\n");  
    80001524:	00009517          	auipc	a0,0x9
    80001528:	cec50513          	addi	a0,a0,-788 # 8000a210 <digits+0x1d8>
    8000152c:	fffff097          	auipc	ra,0xfffff
    80001530:	17c080e7          	jalr	380(ra) # 800006a8 <printf>
    printf("kinit start \n");
    80001534:	00009517          	auipc	a0,0x9
    80001538:	b7c50513          	addi	a0,a0,-1156 # 8000a0b0 <digits+0x78>
    8000153c:	fffff097          	auipc	ra,0xfffff
    80001540:	16c080e7          	jalr	364(ra) # 800006a8 <printf>
    kinit();         // physical page allocator，   
    80001544:	00000097          	auipc	ra,0x0
    80001548:	998080e7          	jalr	-1640(ra) # 80000edc <kinit>
    printf("kinit finish\n");
    8000154c:	00009517          	auipc	a0,0x9
    80001550:	b7450513          	addi	a0,a0,-1164 # 8000a0c0 <digits+0x88>
    80001554:	fffff097          	auipc	ra,0xfffff
    80001558:	154080e7          	jalr	340(ra) # 800006a8 <printf>
    printf("kvminit start \n");
    8000155c:	00009517          	auipc	a0,0x9
    80001560:	b7450513          	addi	a0,a0,-1164 # 8000a0d0 <digits+0x98>
    80001564:	fffff097          	auipc	ra,0xfffff
    80001568:	144080e7          	jalr	324(ra) # 800006a8 <printf>
    kvminit();       // create kernel page table
    8000156c:	00000097          	auipc	ra,0x0
    80001570:	578080e7          	jalr	1400(ra) # 80001ae4 <kvminit>
    printf("kvminit start \n");
    80001574:	00009517          	auipc	a0,0x9
    80001578:	b5c50513          	addi	a0,a0,-1188 # 8000a0d0 <digits+0x98>
    8000157c:	fffff097          	auipc	ra,0xfffff
    80001580:	12c080e7          	jalr	300(ra) # 800006a8 <printf>
    printf("kvminithart start \n");
    80001584:	00009517          	auipc	a0,0x9
    80001588:	b5c50513          	addi	a0,a0,-1188 # 8000a0e0 <digits+0xa8>
    8000158c:	fffff097          	auipc	ra,0xfffff
    80001590:	11c080e7          	jalr	284(ra) # 800006a8 <printf>
    kvminithart();   // turn on paging             //------->
    80001594:	00000097          	auipc	ra,0x0
    80001598:	11c080e7          	jalr	284(ra) # 800016b0 <kvminithart>
    printf("procinit start \n");
    8000159c:	00009517          	auipc	a0,0x9
    800015a0:	b5c50513          	addi	a0,a0,-1188 # 8000a0f8 <digits+0xc0>
    800015a4:	fffff097          	auipc	ra,0xfffff
    800015a8:	104080e7          	jalr	260(ra) # 800006a8 <printf>
    procinit();      // process table
    800015ac:	00001097          	auipc	ra,0x1
    800015b0:	010080e7          	jalr	16(ra) # 800025bc <procinit>
    printf("trapinit start \n");
    800015b4:	00009517          	auipc	a0,0x9
    800015b8:	b5c50513          	addi	a0,a0,-1188 # 8000a110 <digits+0xd8>
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	0ec080e7          	jalr	236(ra) # 800006a8 <printf>
    trapinit();      // trap vectors
    800015c4:	00002097          	auipc	ra,0x2
    800015c8:	30c080e7          	jalr	780(ra) # 800038d0 <trapinit>
    printf("trapinithart start \n");
    800015cc:	00009517          	auipc	a0,0x9
    800015d0:	b5c50513          	addi	a0,a0,-1188 # 8000a128 <digits+0xf0>
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	0d4080e7          	jalr	212(ra) # 800006a8 <printf>
    trapinithart();  // install kernel trap vector
    800015dc:	00002097          	auipc	ra,0x2
    800015e0:	32c080e7          	jalr	812(ra) # 80003908 <trapinithart>
    printf("plicinit start \n");
    800015e4:	00009517          	auipc	a0,0x9
    800015e8:	b5c50513          	addi	a0,a0,-1188 # 8000a140 <digits+0x108>
    800015ec:	fffff097          	auipc	ra,0xfffff
    800015f0:	0bc080e7          	jalr	188(ra) # 800006a8 <printf>
    plicinit();      // set up interrupt controller
    800015f4:	00007097          	auipc	ra,0x7
    800015f8:	d7c080e7          	jalr	-644(ra) # 80008370 <plicinit>
    printf("plicinithart start \n");
    800015fc:	00009517          	auipc	a0,0x9
    80001600:	b5c50513          	addi	a0,a0,-1188 # 8000a158 <digits+0x120>
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	0a4080e7          	jalr	164(ra) # 800006a8 <printf>
    plicinithart();  // ask PLIC for device interrupts
    8000160c:	00007097          	auipc	ra,0x7
    80001610:	d8c080e7          	jalr	-628(ra) # 80008398 <plicinithart>
    printf("binit start \n");
    80001614:	00009517          	auipc	a0,0x9
    80001618:	b5c50513          	addi	a0,a0,-1188 # 8000a170 <digits+0x138>
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	08c080e7          	jalr	140(ra) # 800006a8 <printf>
    binit();         // buffer cache
    80001624:	00003097          	auipc	ra,0x3
    80001628:	d80080e7          	jalr	-640(ra) # 800043a4 <binit>
    printf("iinit start \n");
    8000162c:	00009517          	auipc	a0,0x9
    80001630:	b5450513          	addi	a0,a0,-1196 # 8000a180 <digits+0x148>
    80001634:	fffff097          	auipc	ra,0xfffff
    80001638:	074080e7          	jalr	116(ra) # 800006a8 <printf>
    iinit();         // inode table
    8000163c:	00003097          	auipc	ra,0x3
    80001640:	5ac080e7          	jalr	1452(ra) # 80004be8 <iinit>
    printf("fileinit start \n");
    80001644:	00009517          	auipc	a0,0x9
    80001648:	b4c50513          	addi	a0,a0,-1204 # 8000a190 <digits+0x158>
    8000164c:	fffff097          	auipc	ra,0xfffff
    80001650:	05c080e7          	jalr	92(ra) # 800006a8 <printf>
    fileinit();      // file table
    80001654:	00005097          	auipc	ra,0x5
    80001658:	d9c080e7          	jalr	-612(ra) # 800063f0 <fileinit>
    printf("virtio_disk_init start \n");
    8000165c:	00009517          	auipc	a0,0x9
    80001660:	b4c50513          	addi	a0,a0,-1204 # 8000a1a8 <digits+0x170>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	044080e7          	jalr	68(ra) # 800006a8 <printf>
    virtio_disk_init(); // emulated hard disk
    8000166c:	00007097          	auipc	ra,0x7
    80001670:	e98080e7          	jalr	-360(ra) # 80008504 <virtio_disk_init>
    printf("userinit start \n");
    80001674:	00009517          	auipc	a0,0x9
    80001678:	b5450513          	addi	a0,a0,-1196 # 8000a1c8 <digits+0x190>
    8000167c:	fffff097          	auipc	ra,0xfffff
    80001680:	02c080e7          	jalr	44(ra) # 800006a8 <printf>
    userinit();      // first user process
    80001684:	00001097          	auipc	ra,0x1
    80001688:	524080e7          	jalr	1316(ra) # 80002ba8 <userinit>
    printf("__sync_synchronize start \n");
    8000168c:	00009517          	auipc	a0,0x9
    80001690:	b5450513          	addi	a0,a0,-1196 # 8000a1e0 <digits+0x1a8>
    80001694:	fffff097          	auipc	ra,0xfffff
    80001698:	014080e7          	jalr	20(ra) # 800006a8 <printf>
    __sync_synchronize();
    8000169c:	0ff0000f          	fence
    started = 1;
    800016a0:	00100793          	li	a5,1
    800016a4:	00009717          	auipc	a4,0x9
    800016a8:	2ef72e23          	sw	a5,764(a4) # 8000a9a0 <started>
    800016ac:	e41ff06f          	j	800014ec <main+0x68>

00000000800016b0 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    800016b0:	ff010113          	addi	sp,sp,-16
    800016b4:	00813423          	sd	s0,8(sp)
    800016b8:	01010413          	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800016bc:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();
  w_satp(MAKE_SATP(kernel_pagetable));
    800016c0:	00009797          	auipc	a5,0x9
    800016c4:	2e87b783          	ld	a5,744(a5) # 8000a9a8 <kernel_pagetable>
    800016c8:	00c7d793          	srli	a5,a5,0xc
    800016cc:	fff00713          	li	a4,-1
    800016d0:	03f71713          	slli	a4,a4,0x3f
    800016d4:	00e7e7b3          	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800016d8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800016dc:	12000073          	sfence.vma
  sfence_vma(); //xv6启动时，这个出错，但是我硬件根本没有tlb。
}
    800016e0:	00813403          	ld	s0,8(sp)
    800016e4:	01010113          	addi	sp,sp,16
    800016e8:	00008067          	ret

00000000800016ec <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800016ec:	fc010113          	addi	sp,sp,-64
    800016f0:	02113c23          	sd	ra,56(sp)
    800016f4:	02813823          	sd	s0,48(sp)
    800016f8:	02913423          	sd	s1,40(sp)
    800016fc:	03213023          	sd	s2,32(sp)
    80001700:	01313c23          	sd	s3,24(sp)
    80001704:	01413823          	sd	s4,16(sp)
    80001708:	01513423          	sd	s5,8(sp)
    8000170c:	01613023          	sd	s6,0(sp)
    80001710:	04010413          	addi	s0,sp,64
    80001714:	00050493          	mv	s1,a0
    80001718:	00058993          	mv	s3,a1
    8000171c:	00060a93          	mv	s5,a2
  if(va >= MAXVA)
    80001720:	fff00793          	li	a5,-1
    80001724:	01a7d793          	srli	a5,a5,0x1a
    80001728:	01e00a13          	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000172c:	00c00b13          	li	s6,12
  if(va >= MAXVA)
    80001730:	04b7f863          	bgeu	a5,a1,80001780 <walk+0x94>
    panic("walk");
    80001734:	00009517          	auipc	a0,0x9
    80001738:	ae450513          	addi	a0,a0,-1308 # 8000a218 <digits+0x1e0>
    8000173c:	fffff097          	auipc	ra,0xfffff
    80001740:	344080e7          	jalr	836(ra) # 80000a80 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001744:	080a8e63          	beqz	s5,800017e0 <walk+0xf4>
    80001748:	fffff097          	auipc	ra,0xfffff
    8000174c:	7e4080e7          	jalr	2020(ra) # 80000f2c <kalloc>
    80001750:	00050493          	mv	s1,a0
    80001754:	06050263          	beqz	a0,800017b8 <walk+0xcc>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001758:	00001637          	lui	a2,0x1
    8000175c:	00000593          	li	a1,0
    80001760:	00000097          	auipc	ra,0x0
    80001764:	a90080e7          	jalr	-1392(ra) # 800011f0 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001768:	00c4d793          	srli	a5,s1,0xc
    8000176c:	00a79793          	slli	a5,a5,0xa
    80001770:	0017e793          	ori	a5,a5,1
    80001774:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001778:	ff7a0a1b          	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb32f>
    8000177c:	036a0663          	beq	s4,s6,800017a8 <walk+0xbc>
    pte_t *pte = &pagetable[PX(level, va)];
    80001780:	0149d933          	srl	s2,s3,s4
    80001784:	1ff97913          	andi	s2,s2,511
    80001788:	00391913          	slli	s2,s2,0x3
    8000178c:	01248933          	add	s2,s1,s2
    if(*pte & PTE_V) {
    80001790:	00093483          	ld	s1,0(s2)
    80001794:	0014f793          	andi	a5,s1,1
    80001798:	fa0786e3          	beqz	a5,80001744 <walk+0x58>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000179c:	00a4d493          	srli	s1,s1,0xa
    800017a0:	00c49493          	slli	s1,s1,0xc
    800017a4:	fd5ff06f          	j	80001778 <walk+0x8c>
    }
  }
  return &pagetable[PX(0, va)];
    800017a8:	00c9d513          	srli	a0,s3,0xc
    800017ac:	1ff57513          	andi	a0,a0,511
    800017b0:	00351513          	slli	a0,a0,0x3
    800017b4:	00a48533          	add	a0,s1,a0
}
    800017b8:	03813083          	ld	ra,56(sp)
    800017bc:	03013403          	ld	s0,48(sp)
    800017c0:	02813483          	ld	s1,40(sp)
    800017c4:	02013903          	ld	s2,32(sp)
    800017c8:	01813983          	ld	s3,24(sp)
    800017cc:	01013a03          	ld	s4,16(sp)
    800017d0:	00813a83          	ld	s5,8(sp)
    800017d4:	00013b03          	ld	s6,0(sp)
    800017d8:	04010113          	addi	sp,sp,64
    800017dc:	00008067          	ret
        return 0;
    800017e0:	00000513          	li	a0,0
    800017e4:	fd5ff06f          	j	800017b8 <walk+0xcc>

00000000800017e8 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800017e8:	fff00793          	li	a5,-1
    800017ec:	01a7d793          	srli	a5,a5,0x1a
    800017f0:	00b7f663          	bgeu	a5,a1,800017fc <walkaddr+0x14>
    return 0;
    800017f4:	00000513          	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800017f8:	00008067          	ret
{
    800017fc:	ff010113          	addi	sp,sp,-16
    80001800:	00113423          	sd	ra,8(sp)
    80001804:	00813023          	sd	s0,0(sp)
    80001808:	01010413          	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000180c:	00000613          	li	a2,0
    80001810:	00000097          	auipc	ra,0x0
    80001814:	edc080e7          	jalr	-292(ra) # 800016ec <walk>
  if(pte == 0)
    80001818:	02050a63          	beqz	a0,8000184c <walkaddr+0x64>
  if((*pte & PTE_V) == 0)
    8000181c:	00053783          	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001820:	0117f693          	andi	a3,a5,17
    80001824:	01100713          	li	a4,17
    return 0;
    80001828:	00000513          	li	a0,0
  if((*pte & PTE_U) == 0)
    8000182c:	00e68a63          	beq	a3,a4,80001840 <walkaddr+0x58>
}
    80001830:	00813083          	ld	ra,8(sp)
    80001834:	00013403          	ld	s0,0(sp)
    80001838:	01010113          	addi	sp,sp,16
    8000183c:	00008067          	ret
  pa = PTE2PA(*pte);
    80001840:	00a7d793          	srli	a5,a5,0xa
    80001844:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001848:	fe9ff06f          	j	80001830 <walkaddr+0x48>
    return 0;
    8000184c:	00000513          	li	a0,0
    80001850:	fe1ff06f          	j	80001830 <walkaddr+0x48>

0000000080001854 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001854:	fb010113          	addi	sp,sp,-80
    80001858:	04113423          	sd	ra,72(sp)
    8000185c:	04813023          	sd	s0,64(sp)
    80001860:	02913c23          	sd	s1,56(sp)
    80001864:	03213823          	sd	s2,48(sp)
    80001868:	03313423          	sd	s3,40(sp)
    8000186c:	03413023          	sd	s4,32(sp)
    80001870:	01513c23          	sd	s5,24(sp)
    80001874:	01613823          	sd	s6,16(sp)
    80001878:	01713423          	sd	s7,8(sp)
    8000187c:	05010413          	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001880:	03459793          	slli	a5,a1,0x34
    80001884:	06079c63          	bnez	a5,800018fc <mappages+0xa8>
    80001888:	00050a93          	mv	s5,a0
    8000188c:	00070b13          	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001890:	03461793          	slli	a5,a2,0x34
    80001894:	06079c63          	bnez	a5,8000190c <mappages+0xb8>
    panic("mappages: size not aligned");

  if(size == 0)
    80001898:	08060263          	beqz	a2,8000191c <mappages+0xc8>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000189c:	fffff7b7          	lui	a5,0xfffff
    800018a0:	00f60633          	add	a2,a2,a5
    800018a4:	00b609b3          	add	s3,a2,a1
  a = va;
    800018a8:	00058913          	mv	s2,a1
    800018ac:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800018b0:	00001bb7          	lui	s7,0x1
    800018b4:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800018b8:	00100613          	li	a2,1
    800018bc:	00090593          	mv	a1,s2
    800018c0:	000a8513          	mv	a0,s5
    800018c4:	00000097          	auipc	ra,0x0
    800018c8:	e28080e7          	jalr	-472(ra) # 800016ec <walk>
    800018cc:	06050863          	beqz	a0,8000193c <mappages+0xe8>
    if(*pte & PTE_V)
    800018d0:	00053783          	ld	a5,0(a0)
    800018d4:	0017f793          	andi	a5,a5,1
    800018d8:	04079a63          	bnez	a5,8000192c <mappages+0xd8>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800018dc:	00c4d493          	srli	s1,s1,0xc
    800018e0:	00a49493          	slli	s1,s1,0xa
    800018e4:	0164e4b3          	or	s1,s1,s6
    800018e8:	0014e493          	ori	s1,s1,1
    800018ec:	00953023          	sd	s1,0(a0)
    if(a == last)
    800018f0:	07390e63          	beq	s2,s3,8000196c <mappages+0x118>
    a += PGSIZE;
    800018f4:	01790933          	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800018f8:	fbdff06f          	j	800018b4 <mappages+0x60>
    panic("mappages: va not aligned");
    800018fc:	00009517          	auipc	a0,0x9
    80001900:	92450513          	addi	a0,a0,-1756 # 8000a220 <digits+0x1e8>
    80001904:	fffff097          	auipc	ra,0xfffff
    80001908:	17c080e7          	jalr	380(ra) # 80000a80 <panic>
    panic("mappages: size not aligned");
    8000190c:	00009517          	auipc	a0,0x9
    80001910:	93450513          	addi	a0,a0,-1740 # 8000a240 <digits+0x208>
    80001914:	fffff097          	auipc	ra,0xfffff
    80001918:	16c080e7          	jalr	364(ra) # 80000a80 <panic>
    panic("mappages: size");
    8000191c:	00009517          	auipc	a0,0x9
    80001920:	94450513          	addi	a0,a0,-1724 # 8000a260 <digits+0x228>
    80001924:	fffff097          	auipc	ra,0xfffff
    80001928:	15c080e7          	jalr	348(ra) # 80000a80 <panic>
      panic("mappages: remap");
    8000192c:	00009517          	auipc	a0,0x9
    80001930:	94450513          	addi	a0,a0,-1724 # 8000a270 <digits+0x238>
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	14c080e7          	jalr	332(ra) # 80000a80 <panic>
      return -1;
    8000193c:	fff00513          	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001940:	04813083          	ld	ra,72(sp)
    80001944:	04013403          	ld	s0,64(sp)
    80001948:	03813483          	ld	s1,56(sp)
    8000194c:	03013903          	ld	s2,48(sp)
    80001950:	02813983          	ld	s3,40(sp)
    80001954:	02013a03          	ld	s4,32(sp)
    80001958:	01813a83          	ld	s5,24(sp)
    8000195c:	01013b03          	ld	s6,16(sp)
    80001960:	00813b83          	ld	s7,8(sp)
    80001964:	05010113          	addi	sp,sp,80
    80001968:	00008067          	ret
  return 0;
    8000196c:	00000513          	li	a0,0
    80001970:	fd1ff06f          	j	80001940 <mappages+0xec>

0000000080001974 <kvmmap>:
{
    80001974:	ff010113          	addi	sp,sp,-16
    80001978:	00113423          	sd	ra,8(sp)
    8000197c:	00813023          	sd	s0,0(sp)
    80001980:	01010413          	addi	s0,sp,16
    80001984:	00068793          	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001988:	00060693          	mv	a3,a2
    8000198c:	00078613          	mv	a2,a5
    80001990:	00000097          	auipc	ra,0x0
    80001994:	ec4080e7          	jalr	-316(ra) # 80001854 <mappages>
    80001998:	00051a63          	bnez	a0,800019ac <kvmmap+0x38>
}
    8000199c:	00813083          	ld	ra,8(sp)
    800019a0:	00013403          	ld	s0,0(sp)
    800019a4:	01010113          	addi	sp,sp,16
    800019a8:	00008067          	ret
    panic("kvmmap");
    800019ac:	00009517          	auipc	a0,0x9
    800019b0:	8d450513          	addi	a0,a0,-1836 # 8000a280 <digits+0x248>
    800019b4:	fffff097          	auipc	ra,0xfffff
    800019b8:	0cc080e7          	jalr	204(ra) # 80000a80 <panic>

00000000800019bc <kvmmake>:
{
    800019bc:	fe010113          	addi	sp,sp,-32
    800019c0:	00113c23          	sd	ra,24(sp)
    800019c4:	00813823          	sd	s0,16(sp)
    800019c8:	00913423          	sd	s1,8(sp)
    800019cc:	01213023          	sd	s2,0(sp)
    800019d0:	02010413          	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	558080e7          	jalr	1368(ra) # 80000f2c <kalloc>
    800019dc:	00050493          	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800019e0:	00001637          	lui	a2,0x1
    800019e4:	00000593          	li	a1,0
    800019e8:	00000097          	auipc	ra,0x0
    800019ec:	808080e7          	jalr	-2040(ra) # 800011f0 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800019f0:	00600713          	li	a4,6
    800019f4:	000016b7          	lui	a3,0x1
    800019f8:	10000637          	lui	a2,0x10000
    800019fc:	100005b7          	lui	a1,0x10000
    80001a00:	00048513          	mv	a0,s1
    80001a04:	00000097          	auipc	ra,0x0
    80001a08:	f70080e7          	jalr	-144(ra) # 80001974 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001a0c:	00600713          	li	a4,6
    80001a10:	000016b7          	lui	a3,0x1
    80001a14:	10001637          	lui	a2,0x10001
    80001a18:	100015b7          	lui	a1,0x10001
    80001a1c:	00048513          	mv	a0,s1
    80001a20:	00000097          	auipc	ra,0x0
    80001a24:	f54080e7          	jalr	-172(ra) # 80001974 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001a28:	00600713          	li	a4,6
    80001a2c:	040006b7          	lui	a3,0x4000
    80001a30:	0c000637          	lui	a2,0xc000
    80001a34:	0c0005b7          	lui	a1,0xc000
    80001a38:	00048513          	mv	a0,s1
    80001a3c:	00000097          	auipc	ra,0x0
    80001a40:	f38080e7          	jalr	-200(ra) # 80001974 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001a44:	00008917          	auipc	s2,0x8
    80001a48:	5bc90913          	addi	s2,s2,1468 # 8000a000 <etext>
    80001a4c:	00a00713          	li	a4,10
    80001a50:	80008697          	auipc	a3,0x80008
    80001a54:	5b068693          	addi	a3,a3,1456 # a000 <_entry-0x7fff6000>
    80001a58:	00100613          	li	a2,1
    80001a5c:	01f61613          	slli	a2,a2,0x1f
    80001a60:	00060593          	mv	a1,a2
    80001a64:	00048513          	mv	a0,s1
    80001a68:	00000097          	auipc	ra,0x0
    80001a6c:	f0c080e7          	jalr	-244(ra) # 80001974 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001a70:	00600713          	li	a4,6
    80001a74:	01100693          	li	a3,17
    80001a78:	01b69693          	slli	a3,a3,0x1b
    80001a7c:	412686b3          	sub	a3,a3,s2
    80001a80:	00090613          	mv	a2,s2
    80001a84:	00090593          	mv	a1,s2
    80001a88:	00048513          	mv	a0,s1
    80001a8c:	00000097          	auipc	ra,0x0
    80001a90:	ee8080e7          	jalr	-280(ra) # 80001974 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001a94:	00a00713          	li	a4,10
    80001a98:	000016b7          	lui	a3,0x1
    80001a9c:	00007617          	auipc	a2,0x7
    80001aa0:	56460613          	addi	a2,a2,1380 # 80009000 <_trampoline>
    80001aa4:	040005b7          	lui	a1,0x4000
    80001aa8:	fff58593          	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aac:	00c59593          	slli	a1,a1,0xc
    80001ab0:	00048513          	mv	a0,s1
    80001ab4:	00000097          	auipc	ra,0x0
    80001ab8:	ec0080e7          	jalr	-320(ra) # 80001974 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001abc:	00048513          	mv	a0,s1
    80001ac0:	00001097          	auipc	ra,0x1
    80001ac4:	a28080e7          	jalr	-1496(ra) # 800024e8 <proc_mapstacks>
}
    80001ac8:	00048513          	mv	a0,s1
    80001acc:	01813083          	ld	ra,24(sp)
    80001ad0:	01013403          	ld	s0,16(sp)
    80001ad4:	00813483          	ld	s1,8(sp)
    80001ad8:	00013903          	ld	s2,0(sp)
    80001adc:	02010113          	addi	sp,sp,32
    80001ae0:	00008067          	ret

0000000080001ae4 <kvminit>:
{
    80001ae4:	ff010113          	addi	sp,sp,-16
    80001ae8:	00113423          	sd	ra,8(sp)
    80001aec:	00813023          	sd	s0,0(sp)
    80001af0:	01010413          	addi	s0,sp,16
  printf("kvminit right\n");
    80001af4:	00008517          	auipc	a0,0x8
    80001af8:	79450513          	addi	a0,a0,1940 # 8000a288 <digits+0x250>
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	bac080e7          	jalr	-1108(ra) # 800006a8 <printf>
  kernel_pagetable = kvmmake();
    80001b04:	00000097          	auipc	ra,0x0
    80001b08:	eb8080e7          	jalr	-328(ra) # 800019bc <kvmmake>
    80001b0c:	00009797          	auipc	a5,0x9
    80001b10:	e8a7be23          	sd	a0,-356(a5) # 8000a9a8 <kernel_pagetable>
}
    80001b14:	00813083          	ld	ra,8(sp)
    80001b18:	00013403          	ld	s0,0(sp)
    80001b1c:	01010113          	addi	sp,sp,16
    80001b20:	00008067          	ret

0000000080001b24 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001b24:	fe010113          	addi	sp,sp,-32
    80001b28:	00113c23          	sd	ra,24(sp)
    80001b2c:	00813823          	sd	s0,16(sp)
    80001b30:	00913423          	sd	s1,8(sp)
    80001b34:	02010413          	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	3f4080e7          	jalr	1012(ra) # 80000f2c <kalloc>
    80001b40:	00050493          	mv	s1,a0
  if(pagetable == 0)
    80001b44:	00050a63          	beqz	a0,80001b58 <uvmcreate+0x34>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001b48:	00001637          	lui	a2,0x1
    80001b4c:	00000593          	li	a1,0
    80001b50:	fffff097          	auipc	ra,0xfffff
    80001b54:	6a0080e7          	jalr	1696(ra) # 800011f0 <memset>
  return pagetable;
}
    80001b58:	00048513          	mv	a0,s1
    80001b5c:	01813083          	ld	ra,24(sp)
    80001b60:	01013403          	ld	s0,16(sp)
    80001b64:	00813483          	ld	s1,8(sp)
    80001b68:	02010113          	addi	sp,sp,32
    80001b6c:	00008067          	ret

0000000080001b70 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001b70:	fc010113          	addi	sp,sp,-64
    80001b74:	02113c23          	sd	ra,56(sp)
    80001b78:	02813823          	sd	s0,48(sp)
    80001b7c:	02913423          	sd	s1,40(sp)
    80001b80:	03213023          	sd	s2,32(sp)
    80001b84:	01313c23          	sd	s3,24(sp)
    80001b88:	01413823          	sd	s4,16(sp)
    80001b8c:	01513423          	sd	s5,8(sp)
    80001b90:	01613023          	sd	s6,0(sp)
    80001b94:	04010413          	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001b98:	03459793          	slli	a5,a1,0x34
    80001b9c:	04079463          	bnez	a5,80001be4 <uvmunmap+0x74>
    80001ba0:	00050a13          	mv	s4,a0
    80001ba4:	00058913          	mv	s2,a1
    80001ba8:	00068a93          	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001bac:	00c61613          	slli	a2,a2,0xc
    80001bb0:	00b609b3          	add	s3,a2,a1
    80001bb4:	00001b37          	lui	s6,0x1
    80001bb8:	0535e463          	bltu	a1,s3,80001c00 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001bbc:	03813083          	ld	ra,56(sp)
    80001bc0:	03013403          	ld	s0,48(sp)
    80001bc4:	02813483          	ld	s1,40(sp)
    80001bc8:	02013903          	ld	s2,32(sp)
    80001bcc:	01813983          	ld	s3,24(sp)
    80001bd0:	01013a03          	ld	s4,16(sp)
    80001bd4:	00813a83          	ld	s5,8(sp)
    80001bd8:	00013b03          	ld	s6,0(sp)
    80001bdc:	04010113          	addi	sp,sp,64
    80001be0:	00008067          	ret
    panic("uvmunmap: not aligned");
    80001be4:	00008517          	auipc	a0,0x8
    80001be8:	6b450513          	addi	a0,a0,1716 # 8000a298 <digits+0x260>
    80001bec:	fffff097          	auipc	ra,0xfffff
    80001bf0:	e94080e7          	jalr	-364(ra) # 80000a80 <panic>
    *pte = 0;
    80001bf4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001bf8:	01690933          	add	s2,s2,s6
    80001bfc:	fd3970e3          	bgeu	s2,s3,80001bbc <uvmunmap+0x4c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001c00:	00000613          	li	a2,0
    80001c04:	00090593          	mv	a1,s2
    80001c08:	000a0513          	mv	a0,s4
    80001c0c:	00000097          	auipc	ra,0x0
    80001c10:	ae0080e7          	jalr	-1312(ra) # 800016ec <walk>
    80001c14:	00050493          	mv	s1,a0
    80001c18:	fe0500e3          	beqz	a0,80001bf8 <uvmunmap+0x88>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001c1c:	00053783          	ld	a5,0(a0)
    80001c20:	0017f713          	andi	a4,a5,1
    80001c24:	fc070ae3          	beqz	a4,80001bf8 <uvmunmap+0x88>
    if(do_free){
    80001c28:	fc0a86e3          	beqz	s5,80001bf4 <uvmunmap+0x84>
      uint64 pa = PTE2PA(*pte);
    80001c2c:	00a7d793          	srli	a5,a5,0xa
      kfree((void*)pa);
    80001c30:	00c79513          	slli	a0,a5,0xc
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	18c080e7          	jalr	396(ra) # 80000dc0 <kfree>
    80001c3c:	fb9ff06f          	j	80001bf4 <uvmunmap+0x84>

0000000080001c40 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001c40:	fe010113          	addi	sp,sp,-32
    80001c44:	00113c23          	sd	ra,24(sp)
    80001c48:	00813823          	sd	s0,16(sp)
    80001c4c:	00913423          	sd	s1,8(sp)
    80001c50:	02010413          	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001c54:	00058493          	mv	s1,a1
  if(newsz >= oldsz)
    80001c58:	02b67463          	bgeu	a2,a1,80001c80 <uvmdealloc+0x40>
    80001c5c:	00060493          	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001c60:	000017b7          	lui	a5,0x1
    80001c64:	fff78793          	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001c68:	00f60733          	add	a4,a2,a5
    80001c6c:	fffff6b7          	lui	a3,0xfffff
    80001c70:	00d77733          	and	a4,a4,a3
    80001c74:	00f587b3          	add	a5,a1,a5
    80001c78:	00d7f7b3          	and	a5,a5,a3
    80001c7c:	00f76e63          	bltu	a4,a5,80001c98 <uvmdealloc+0x58>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001c80:	00048513          	mv	a0,s1
    80001c84:	01813083          	ld	ra,24(sp)
    80001c88:	01013403          	ld	s0,16(sp)
    80001c8c:	00813483          	ld	s1,8(sp)
    80001c90:	02010113          	addi	sp,sp,32
    80001c94:	00008067          	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001c98:	40e787b3          	sub	a5,a5,a4
    80001c9c:	00c7d793          	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001ca0:	00100693          	li	a3,1
    80001ca4:	0007861b          	sext.w	a2,a5
    80001ca8:	00070593          	mv	a1,a4
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	ec4080e7          	jalr	-316(ra) # 80001b70 <uvmunmap>
    80001cb4:	fcdff06f          	j	80001c80 <uvmdealloc+0x40>

0000000080001cb8 <uvmalloc>:
  if(newsz < oldsz)
    80001cb8:	10b66863          	bltu	a2,a1,80001dc8 <uvmalloc+0x110>
{
    80001cbc:	fc010113          	addi	sp,sp,-64
    80001cc0:	02113c23          	sd	ra,56(sp)
    80001cc4:	02813823          	sd	s0,48(sp)
    80001cc8:	02913423          	sd	s1,40(sp)
    80001ccc:	03213023          	sd	s2,32(sp)
    80001cd0:	01313c23          	sd	s3,24(sp)
    80001cd4:	01413823          	sd	s4,16(sp)
    80001cd8:	01513423          	sd	s5,8(sp)
    80001cdc:	01613023          	sd	s6,0(sp)
    80001ce0:	04010413          	addi	s0,sp,64
    80001ce4:	00050a93          	mv	s5,a0
    80001ce8:	00060a13          	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001cec:	000017b7          	lui	a5,0x1
    80001cf0:	fff78793          	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001cf4:	00f585b3          	add	a1,a1,a5
    80001cf8:	fffff7b7          	lui	a5,0xfffff
    80001cfc:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001d00:	0cc9f863          	bgeu	s3,a2,80001dd0 <uvmalloc+0x118>
    80001d04:	00098913          	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001d08:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001d0c:	fffff097          	auipc	ra,0xfffff
    80001d10:	220080e7          	jalr	544(ra) # 80000f2c <kalloc>
    80001d14:	00050493          	mv	s1,a0
    if(mem == 0){
    80001d18:	04050463          	beqz	a0,80001d60 <uvmalloc+0xa8>
    memset(mem, 0, PGSIZE);
    80001d1c:	00001637          	lui	a2,0x1
    80001d20:	00000593          	li	a1,0
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	4cc080e7          	jalr	1228(ra) # 800011f0 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001d2c:	000b0713          	mv	a4,s6
    80001d30:	00048693          	mv	a3,s1
    80001d34:	00001637          	lui	a2,0x1
    80001d38:	00090593          	mv	a1,s2
    80001d3c:	000a8513          	mv	a0,s5
    80001d40:	00000097          	auipc	ra,0x0
    80001d44:	b14080e7          	jalr	-1260(ra) # 80001854 <mappages>
    80001d48:	04051c63          	bnez	a0,80001da0 <uvmalloc+0xe8>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001d4c:	000017b7          	lui	a5,0x1
    80001d50:	00f90933          	add	s2,s2,a5
    80001d54:	fb496ce3          	bltu	s2,s4,80001d0c <uvmalloc+0x54>
  return newsz;
    80001d58:	000a0513          	mv	a0,s4
    80001d5c:	01c0006f          	j	80001d78 <uvmalloc+0xc0>
      uvmdealloc(pagetable, a, oldsz);
    80001d60:	00098613          	mv	a2,s3
    80001d64:	00090593          	mv	a1,s2
    80001d68:	000a8513          	mv	a0,s5
    80001d6c:	00000097          	auipc	ra,0x0
    80001d70:	ed4080e7          	jalr	-300(ra) # 80001c40 <uvmdealloc>
      return 0;
    80001d74:	00000513          	li	a0,0
}
    80001d78:	03813083          	ld	ra,56(sp)
    80001d7c:	03013403          	ld	s0,48(sp)
    80001d80:	02813483          	ld	s1,40(sp)
    80001d84:	02013903          	ld	s2,32(sp)
    80001d88:	01813983          	ld	s3,24(sp)
    80001d8c:	01013a03          	ld	s4,16(sp)
    80001d90:	00813a83          	ld	s5,8(sp)
    80001d94:	00013b03          	ld	s6,0(sp)
    80001d98:	04010113          	addi	sp,sp,64
    80001d9c:	00008067          	ret
      kfree(mem);
    80001da0:	00048513          	mv	a0,s1
    80001da4:	fffff097          	auipc	ra,0xfffff
    80001da8:	01c080e7          	jalr	28(ra) # 80000dc0 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001dac:	00098613          	mv	a2,s3
    80001db0:	00090593          	mv	a1,s2
    80001db4:	000a8513          	mv	a0,s5
    80001db8:	00000097          	auipc	ra,0x0
    80001dbc:	e88080e7          	jalr	-376(ra) # 80001c40 <uvmdealloc>
      return 0;
    80001dc0:	00000513          	li	a0,0
    80001dc4:	fb5ff06f          	j	80001d78 <uvmalloc+0xc0>
    return oldsz;
    80001dc8:	00058513          	mv	a0,a1
}
    80001dcc:	00008067          	ret
  return newsz;
    80001dd0:	00060513          	mv	a0,a2
    80001dd4:	fa5ff06f          	j	80001d78 <uvmalloc+0xc0>

0000000080001dd8 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001dd8:	fd010113          	addi	sp,sp,-48
    80001ddc:	02113423          	sd	ra,40(sp)
    80001de0:	02813023          	sd	s0,32(sp)
    80001de4:	00913c23          	sd	s1,24(sp)
    80001de8:	01213823          	sd	s2,16(sp)
    80001dec:	01313423          	sd	s3,8(sp)
    80001df0:	01413023          	sd	s4,0(sp)
    80001df4:	03010413          	addi	s0,sp,48
    80001df8:	00050a13          	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001dfc:	00050493          	mv	s1,a0
    80001e00:	00001937          	lui	s2,0x1
    80001e04:	01250933          	add	s2,a0,s2
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001e08:	00100993          	li	s3,1
    80001e0c:	0200006f          	j	80001e2c <freewalk+0x54>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001e10:	00a7d793          	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001e14:	00c79513          	slli	a0,a5,0xc
    80001e18:	00000097          	auipc	ra,0x0
    80001e1c:	fc0080e7          	jalr	-64(ra) # 80001dd8 <freewalk>
      pagetable[i] = 0;
    80001e20:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001e24:	00848493          	addi	s1,s1,8
    80001e28:	03248463          	beq	s1,s2,80001e50 <freewalk+0x78>
    pte_t pte = pagetable[i];
    80001e2c:	0004b783          	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001e30:	00f7f713          	andi	a4,a5,15
    80001e34:	fd370ee3          	beq	a4,s3,80001e10 <freewalk+0x38>
    } else if(pte & PTE_V){
    80001e38:	0017f793          	andi	a5,a5,1
    80001e3c:	fe0784e3          	beqz	a5,80001e24 <freewalk+0x4c>
      panic("freewalk: leaf");
    80001e40:	00008517          	auipc	a0,0x8
    80001e44:	47050513          	addi	a0,a0,1136 # 8000a2b0 <digits+0x278>
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	c38080e7          	jalr	-968(ra) # 80000a80 <panic>
    }
  }
  kfree((void*)pagetable);
    80001e50:	000a0513          	mv	a0,s4
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	f6c080e7          	jalr	-148(ra) # 80000dc0 <kfree>
}
    80001e5c:	02813083          	ld	ra,40(sp)
    80001e60:	02013403          	ld	s0,32(sp)
    80001e64:	01813483          	ld	s1,24(sp)
    80001e68:	01013903          	ld	s2,16(sp)
    80001e6c:	00813983          	ld	s3,8(sp)
    80001e70:	00013a03          	ld	s4,0(sp)
    80001e74:	03010113          	addi	sp,sp,48
    80001e78:	00008067          	ret

0000000080001e7c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001e7c:	fe010113          	addi	sp,sp,-32
    80001e80:	00113c23          	sd	ra,24(sp)
    80001e84:	00813823          	sd	s0,16(sp)
    80001e88:	00913423          	sd	s1,8(sp)
    80001e8c:	02010413          	addi	s0,sp,32
    80001e90:	00050493          	mv	s1,a0
  if(sz > 0)
    80001e94:	02059263          	bnez	a1,80001eb8 <uvmfree+0x3c>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001e98:	00048513          	mv	a0,s1
    80001e9c:	00000097          	auipc	ra,0x0
    80001ea0:	f3c080e7          	jalr	-196(ra) # 80001dd8 <freewalk>
}
    80001ea4:	01813083          	ld	ra,24(sp)
    80001ea8:	01013403          	ld	s0,16(sp)
    80001eac:	00813483          	ld	s1,8(sp)
    80001eb0:	02010113          	addi	sp,sp,32
    80001eb4:	00008067          	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001eb8:	000017b7          	lui	a5,0x1
    80001ebc:	fff78793          	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001ec0:	00f585b3          	add	a1,a1,a5
    80001ec4:	00100693          	li	a3,1
    80001ec8:	00c5d613          	srli	a2,a1,0xc
    80001ecc:	00000593          	li	a1,0
    80001ed0:	00000097          	auipc	ra,0x0
    80001ed4:	ca0080e7          	jalr	-864(ra) # 80001b70 <uvmunmap>
    80001ed8:	fc1ff06f          	j	80001e98 <uvmfree+0x1c>

0000000080001edc <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001edc:	10060e63          	beqz	a2,80001ff8 <uvmcopy+0x11c>
{
    80001ee0:	fb010113          	addi	sp,sp,-80
    80001ee4:	04113423          	sd	ra,72(sp)
    80001ee8:	04813023          	sd	s0,64(sp)
    80001eec:	02913c23          	sd	s1,56(sp)
    80001ef0:	03213823          	sd	s2,48(sp)
    80001ef4:	03313423          	sd	s3,40(sp)
    80001ef8:	03413023          	sd	s4,32(sp)
    80001efc:	01513c23          	sd	s5,24(sp)
    80001f00:	01613823          	sd	s6,16(sp)
    80001f04:	01713423          	sd	s7,8(sp)
    80001f08:	05010413          	addi	s0,sp,80
    80001f0c:	00050a93          	mv	s5,a0
    80001f10:	00058b13          	mv	s6,a1
    80001f14:	00060a13          	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001f18:	00000493          	li	s1,0
    80001f1c:	0100006f          	j	80001f2c <uvmcopy+0x50>
    80001f20:	000017b7          	lui	a5,0x1
    80001f24:	00f484b3          	add	s1,s1,a5
    80001f28:	0b44f063          	bgeu	s1,s4,80001fc8 <uvmcopy+0xec>
    if((pte = walk(old, i, 0)) == 0)
    80001f2c:	00000613          	li	a2,0
    80001f30:	00048593          	mv	a1,s1
    80001f34:	000a8513          	mv	a0,s5
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	7b4080e7          	jalr	1972(ra) # 800016ec <walk>
    80001f40:	fe0500e3          	beqz	a0,80001f20 <uvmcopy+0x44>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    80001f44:	00053703          	ld	a4,0(a0)
    80001f48:	00177793          	andi	a5,a4,1
    80001f4c:	fc078ae3          	beqz	a5,80001f20 <uvmcopy+0x44>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    80001f50:	00a75593          	srli	a1,a4,0xa
    80001f54:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001f58:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	fd0080e7          	jalr	-48(ra) # 80000f2c <kalloc>
    80001f64:	00050993          	mv	s3,a0
    80001f68:	04050063          	beqz	a0,80001fa8 <uvmcopy+0xcc>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001f6c:	00001637          	lui	a2,0x1
    80001f70:	000b8593          	mv	a1,s7
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	310080e7          	jalr	784(ra) # 80001284 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001f7c:	00090713          	mv	a4,s2
    80001f80:	00098693          	mv	a3,s3
    80001f84:	00001637          	lui	a2,0x1
    80001f88:	00048593          	mv	a1,s1
    80001f8c:	000b0513          	mv	a0,s6
    80001f90:	00000097          	auipc	ra,0x0
    80001f94:	8c4080e7          	jalr	-1852(ra) # 80001854 <mappages>
    80001f98:	f80504e3          	beqz	a0,80001f20 <uvmcopy+0x44>
      kfree(mem);
    80001f9c:	00098513          	mv	a0,s3
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	e20080e7          	jalr	-480(ra) # 80000dc0 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001fa8:	00100693          	li	a3,1
    80001fac:	00c4d613          	srli	a2,s1,0xc
    80001fb0:	00000593          	li	a1,0
    80001fb4:	000b0513          	mv	a0,s6
    80001fb8:	00000097          	auipc	ra,0x0
    80001fbc:	bb8080e7          	jalr	-1096(ra) # 80001b70 <uvmunmap>
  return -1;
    80001fc0:	fff00513          	li	a0,-1
    80001fc4:	0080006f          	j	80001fcc <uvmcopy+0xf0>
  return 0;
    80001fc8:	00000513          	li	a0,0
}
    80001fcc:	04813083          	ld	ra,72(sp)
    80001fd0:	04013403          	ld	s0,64(sp)
    80001fd4:	03813483          	ld	s1,56(sp)
    80001fd8:	03013903          	ld	s2,48(sp)
    80001fdc:	02813983          	ld	s3,40(sp)
    80001fe0:	02013a03          	ld	s4,32(sp)
    80001fe4:	01813a83          	ld	s5,24(sp)
    80001fe8:	01013b03          	ld	s6,16(sp)
    80001fec:	00813b83          	ld	s7,8(sp)
    80001ff0:	05010113          	addi	sp,sp,80
    80001ff4:	00008067          	ret
  return 0;
    80001ff8:	00000513          	li	a0,0
}
    80001ffc:	00008067          	ret

0000000080002000 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80002000:	ff010113          	addi	sp,sp,-16
    80002004:	00113423          	sd	ra,8(sp)
    80002008:	00813023          	sd	s0,0(sp)
    8000200c:	01010413          	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80002010:	00000613          	li	a2,0
    80002014:	fffff097          	auipc	ra,0xfffff
    80002018:	6d8080e7          	jalr	1752(ra) # 800016ec <walk>
  if(pte == 0)
    8000201c:	02050063          	beqz	a0,8000203c <uvmclear+0x3c>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80002020:	00053783          	ld	a5,0(a0)
    80002024:	fef7f793          	andi	a5,a5,-17
    80002028:	00f53023          	sd	a5,0(a0)
}
    8000202c:	00813083          	ld	ra,8(sp)
    80002030:	00013403          	ld	s0,0(sp)
    80002034:	01010113          	addi	sp,sp,16
    80002038:	00008067          	ret
    panic("uvmclear");
    8000203c:	00008517          	auipc	a0,0x8
    80002040:	28450513          	addi	a0,a0,644 # 8000a2c0 <digits+0x288>
    80002044:	fffff097          	auipc	ra,0xfffff
    80002048:	a3c080e7          	jalr	-1476(ra) # 80000a80 <panic>

000000008000204c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000204c:	10068663          	beqz	a3,80002158 <copyinstr+0x10c>
{
    80002050:	fb010113          	addi	sp,sp,-80
    80002054:	04113423          	sd	ra,72(sp)
    80002058:	04813023          	sd	s0,64(sp)
    8000205c:	02913c23          	sd	s1,56(sp)
    80002060:	03213823          	sd	s2,48(sp)
    80002064:	03313423          	sd	s3,40(sp)
    80002068:	03413023          	sd	s4,32(sp)
    8000206c:	01513c23          	sd	s5,24(sp)
    80002070:	01613823          	sd	s6,16(sp)
    80002074:	01713423          	sd	s7,8(sp)
    80002078:	05010413          	addi	s0,sp,80
    8000207c:	00050a13          	mv	s4,a0
    80002080:	00058b13          	mv	s6,a1
    80002084:	00060b93          	mv	s7,a2
    80002088:	00068493          	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000208c:	fffffab7          	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80002090:	000019b7          	lui	s3,0x1
    80002094:	0480006f          	j	800020dc <copyinstr+0x90>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80002098:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000209c:	00100793          	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800020a0:	fff7879b          	addiw	a5,a5,-1
    800020a4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800020a8:	04813083          	ld	ra,72(sp)
    800020ac:	04013403          	ld	s0,64(sp)
    800020b0:	03813483          	ld	s1,56(sp)
    800020b4:	03013903          	ld	s2,48(sp)
    800020b8:	02813983          	ld	s3,40(sp)
    800020bc:	02013a03          	ld	s4,32(sp)
    800020c0:	01813a83          	ld	s5,24(sp)
    800020c4:	01013b03          	ld	s6,16(sp)
    800020c8:	00813b83          	ld	s7,8(sp)
    800020cc:	05010113          	addi	sp,sp,80
    800020d0:	00008067          	ret
    srcva = va0 + PGSIZE;
    800020d4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800020d8:	06048863          	beqz	s1,80002148 <copyinstr+0xfc>
    va0 = PGROUNDDOWN(srcva);
    800020dc:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800020e0:	00090593          	mv	a1,s2
    800020e4:	000a0513          	mv	a0,s4
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	700080e7          	jalr	1792(ra) # 800017e8 <walkaddr>
    if(pa0 == 0)
    800020f0:	06050063          	beqz	a0,80002150 <copyinstr+0x104>
    n = PGSIZE - (srcva - va0);
    800020f4:	417906b3          	sub	a3,s2,s7
    800020f8:	013686b3          	add	a3,a3,s3
    800020fc:	00d4f463          	bgeu	s1,a3,80002104 <copyinstr+0xb8>
    80002100:	00048693          	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80002104:	01750533          	add	a0,a0,s7
    80002108:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000210c:	fc0684e3          	beqz	a3,800020d4 <copyinstr+0x88>
    80002110:	000b0793          	mv	a5,s6
      if(*p == '\0'){
    80002114:	41650633          	sub	a2,a0,s6
    80002118:	fff48593          	addi	a1,s1,-1
    8000211c:	00bb05b3          	add	a1,s6,a1
    while(n > 0){
    80002120:	00db06b3          	add	a3,s6,a3
      if(*p == '\0'){
    80002124:	00f60733          	add	a4,a2,a5
    80002128:	00074703          	lbu	a4,0(a4)
    8000212c:	f60706e3          	beqz	a4,80002098 <copyinstr+0x4c>
        *dst = *p;
    80002130:	00e78023          	sb	a4,0(a5)
      --max;
    80002134:	40f584b3          	sub	s1,a1,a5
      dst++;
    80002138:	00178793          	addi	a5,a5,1
    while(n > 0){
    8000213c:	fed794e3          	bne	a5,a3,80002124 <copyinstr+0xd8>
      dst++;
    80002140:	00078b13          	mv	s6,a5
    80002144:	f91ff06f          	j	800020d4 <copyinstr+0x88>
    80002148:	00000793          	li	a5,0
    8000214c:	f55ff06f          	j	800020a0 <copyinstr+0x54>
      return -1;
    80002150:	fff00513          	li	a0,-1
    80002154:	f55ff06f          	j	800020a8 <copyinstr+0x5c>
  int got_null = 0;
    80002158:	00000793          	li	a5,0
  if(got_null){
    8000215c:	fff7879b          	addiw	a5,a5,-1
    80002160:	0007851b          	sext.w	a0,a5
}
    80002164:	00008067          	ret

0000000080002168 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80002168:	ff010113          	addi	sp,sp,-16
    8000216c:	00113423          	sd	ra,8(sp)
    80002170:	00813023          	sd	s0,0(sp)
    80002174:	01010413          	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80002178:	00000613          	li	a2,0
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	570080e7          	jalr	1392(ra) # 800016ec <walk>
  if (pte == 0) {
    80002184:	00050e63          	beqz	a0,800021a0 <ismapped+0x38>
    return 0;
  }
  if (*pte & PTE_V){
    80002188:	00053503          	ld	a0,0(a0)
    return 0;
    8000218c:	00157513          	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80002190:	00813083          	ld	ra,8(sp)
    80002194:	00013403          	ld	s0,0(sp)
    80002198:	01010113          	addi	sp,sp,16
    8000219c:	00008067          	ret
    return 0;
    800021a0:	00000513          	li	a0,0
    800021a4:	fedff06f          	j	80002190 <ismapped+0x28>

00000000800021a8 <vmfault>:
{
    800021a8:	fd010113          	addi	sp,sp,-48
    800021ac:	02113423          	sd	ra,40(sp)
    800021b0:	02813023          	sd	s0,32(sp)
    800021b4:	00913c23          	sd	s1,24(sp)
    800021b8:	01213823          	sd	s2,16(sp)
    800021bc:	01313423          	sd	s3,8(sp)
    800021c0:	01413023          	sd	s4,0(sp)
    800021c4:	03010413          	addi	s0,sp,48
    800021c8:	00050993          	mv	s3,a0
    800021cc:	00058493          	mv	s1,a1
  struct proc *p = myproc();
    800021d0:	00000097          	auipc	ra,0x0
    800021d4:	528080e7          	jalr	1320(ra) # 800026f8 <myproc>
  if (va >= p->sz)
    800021d8:	04853783          	ld	a5,72(a0)
    800021dc:	02f4e663          	bltu	s1,a5,80002208 <vmfault+0x60>
    return 0;
    800021e0:	00000993          	li	s3,0
}
    800021e4:	00098513          	mv	a0,s3
    800021e8:	02813083          	ld	ra,40(sp)
    800021ec:	02013403          	ld	s0,32(sp)
    800021f0:	01813483          	ld	s1,24(sp)
    800021f4:	01013903          	ld	s2,16(sp)
    800021f8:	00813983          	ld	s3,8(sp)
    800021fc:	00013a03          	ld	s4,0(sp)
    80002200:	03010113          	addi	sp,sp,48
    80002204:	00008067          	ret
    80002208:	00050913          	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000220c:	fffff7b7          	lui	a5,0xfffff
    80002210:	00f4f4b3          	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80002214:	00048593          	mv	a1,s1
    80002218:	00098513          	mv	a0,s3
    8000221c:	00000097          	auipc	ra,0x0
    80002220:	f4c080e7          	jalr	-180(ra) # 80002168 <ismapped>
    return 0;
    80002224:	00000993          	li	s3,0
  if(ismapped(pagetable, va)) {
    80002228:	fa051ee3          	bnez	a0,800021e4 <vmfault+0x3c>
  mem = (uint64) kalloc();
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	d00080e7          	jalr	-768(ra) # 80000f2c <kalloc>
    80002234:	00050a13          	mv	s4,a0
  if(mem == 0)
    80002238:	fa0506e3          	beqz	a0,800021e4 <vmfault+0x3c>
  mem = (uint64) kalloc();
    8000223c:	00050993          	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80002240:	00001637          	lui	a2,0x1
    80002244:	00000593          	li	a1,0
    80002248:	fffff097          	auipc	ra,0xfffff
    8000224c:	fa8080e7          	jalr	-88(ra) # 800011f0 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80002250:	01600713          	li	a4,22
    80002254:	000a0693          	mv	a3,s4
    80002258:	00001637          	lui	a2,0x1
    8000225c:	00048593          	mv	a1,s1
    80002260:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80002264:	fffff097          	auipc	ra,0xfffff
    80002268:	5f0080e7          	jalr	1520(ra) # 80001854 <mappages>
    8000226c:	f6050ce3          	beqz	a0,800021e4 <vmfault+0x3c>
    kfree((void *)mem);
    80002270:	000a0513          	mv	a0,s4
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	b4c080e7          	jalr	-1204(ra) # 80000dc0 <kfree>
    return 0;
    8000227c:	00000993          	li	s3,0
    80002280:	f65ff06f          	j	800021e4 <vmfault+0x3c>

0000000080002284 <copyout>:
  while(len > 0){
    80002284:	10068663          	beqz	a3,80002390 <copyout+0x10c>
{
    80002288:	fa010113          	addi	sp,sp,-96
    8000228c:	04113c23          	sd	ra,88(sp)
    80002290:	04813823          	sd	s0,80(sp)
    80002294:	04913423          	sd	s1,72(sp)
    80002298:	05213023          	sd	s2,64(sp)
    8000229c:	03313c23          	sd	s3,56(sp)
    800022a0:	03413823          	sd	s4,48(sp)
    800022a4:	03513423          	sd	s5,40(sp)
    800022a8:	03613023          	sd	s6,32(sp)
    800022ac:	01713c23          	sd	s7,24(sp)
    800022b0:	01813823          	sd	s8,16(sp)
    800022b4:	01913423          	sd	s9,8(sp)
    800022b8:	01a13023          	sd	s10,0(sp)
    800022bc:	06010413          	addi	s0,sp,96
    800022c0:	00050c13          	mv	s8,a0
    800022c4:	00058b13          	mv	s6,a1
    800022c8:	00060b93          	mv	s7,a2
    800022cc:	00068a13          	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800022d0:	fffff4b7          	lui	s1,0xfffff
    800022d4:	0095f4b3          	and	s1,a1,s1
    if(va0 >= MAXVA)
    800022d8:	fff00793          	li	a5,-1
    800022dc:	01a7d793          	srli	a5,a5,0x1a
    800022e0:	0a97ec63          	bltu	a5,s1,80002398 <copyout+0x114>
    800022e4:	00001d37          	lui	s10,0x1
    800022e8:	00078c93          	mv	s9,a5
    800022ec:	0340006f          	j	80002320 <copyout+0x9c>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800022f0:	409b0533          	sub	a0,s6,s1
    800022f4:	0009861b          	sext.w	a2,s3
    800022f8:	000b8593          	mv	a1,s7
    800022fc:	01250533          	add	a0,a0,s2
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	f84080e7          	jalr	-124(ra) # 80001284 <memmove>
    len -= n;
    80002308:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000230c:	013b8bb3          	add	s7,s7,s3
  while(len > 0){
    80002310:	060a0c63          	beqz	s4,80002388 <copyout+0x104>
    if(va0 >= MAXVA)
    80002314:	095ce663          	bltu	s9,s5,800023a0 <copyout+0x11c>
    va0 = PGROUNDDOWN(dstva);
    80002318:	000a8493          	mv	s1,s5
    dstva = va0 + PGSIZE;
    8000231c:	000a8b13          	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80002320:	00048593          	mv	a1,s1
    80002324:	000c0513          	mv	a0,s8
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	4c0080e7          	jalr	1216(ra) # 800017e8 <walkaddr>
    80002330:	00050913          	mv	s2,a0
    if(pa0 == 0) {
    80002334:	02051063          	bnez	a0,80002354 <copyout+0xd0>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80002338:	00000613          	li	a2,0
    8000233c:	00048593          	mv	a1,s1
    80002340:	000c0513          	mv	a0,s8
    80002344:	00000097          	auipc	ra,0x0
    80002348:	e64080e7          	jalr	-412(ra) # 800021a8 <vmfault>
    8000234c:	00050913          	mv	s2,a0
    80002350:	04050c63          	beqz	a0,800023a8 <copyout+0x124>
    pte = walk(pagetable, va0, 0);
    80002354:	00000613          	li	a2,0
    80002358:	00048593          	mv	a1,s1
    8000235c:	000c0513          	mv	a0,s8
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	38c080e7          	jalr	908(ra) # 800016ec <walk>
    if((*pte & PTE_W) == 0)
    80002368:	00053783          	ld	a5,0(a0)
    8000236c:	0047f793          	andi	a5,a5,4
    80002370:	04078063          	beqz	a5,800023b0 <copyout+0x12c>
    n = PGSIZE - (dstva - va0);
    80002374:	01a48ab3          	add	s5,s1,s10
    80002378:	416a89b3          	sub	s3,s5,s6
    8000237c:	f73a7ae3          	bgeu	s4,s3,800022f0 <copyout+0x6c>
    80002380:	000a0993          	mv	s3,s4
    80002384:	f6dff06f          	j	800022f0 <copyout+0x6c>
  return 0;
    80002388:	00000513          	li	a0,0
    8000238c:	0280006f          	j	800023b4 <copyout+0x130>
    80002390:	00000513          	li	a0,0
}
    80002394:	00008067          	ret
      return -1;
    80002398:	fff00513          	li	a0,-1
    8000239c:	0180006f          	j	800023b4 <copyout+0x130>
    800023a0:	fff00513          	li	a0,-1
    800023a4:	0100006f          	j	800023b4 <copyout+0x130>
        return -1;
    800023a8:	fff00513          	li	a0,-1
    800023ac:	0080006f          	j	800023b4 <copyout+0x130>
      return -1;
    800023b0:	fff00513          	li	a0,-1
}
    800023b4:	05813083          	ld	ra,88(sp)
    800023b8:	05013403          	ld	s0,80(sp)
    800023bc:	04813483          	ld	s1,72(sp)
    800023c0:	04013903          	ld	s2,64(sp)
    800023c4:	03813983          	ld	s3,56(sp)
    800023c8:	03013a03          	ld	s4,48(sp)
    800023cc:	02813a83          	ld	s5,40(sp)
    800023d0:	02013b03          	ld	s6,32(sp)
    800023d4:	01813b83          	ld	s7,24(sp)
    800023d8:	01013c03          	ld	s8,16(sp)
    800023dc:	00813c83          	ld	s9,8(sp)
    800023e0:	00013d03          	ld	s10,0(sp)
    800023e4:	06010113          	addi	sp,sp,96
    800023e8:	00008067          	ret

00000000800023ec <copyin>:
  while(len > 0){
    800023ec:	0e068a63          	beqz	a3,800024e0 <copyin+0xf4>
{
    800023f0:	fb010113          	addi	sp,sp,-80
    800023f4:	04113423          	sd	ra,72(sp)
    800023f8:	04813023          	sd	s0,64(sp)
    800023fc:	02913c23          	sd	s1,56(sp)
    80002400:	03213823          	sd	s2,48(sp)
    80002404:	03313423          	sd	s3,40(sp)
    80002408:	03413023          	sd	s4,32(sp)
    8000240c:	01513c23          	sd	s5,24(sp)
    80002410:	01613823          	sd	s6,16(sp)
    80002414:	01713423          	sd	s7,8(sp)
    80002418:	01813023          	sd	s8,0(sp)
    8000241c:	05010413          	addi	s0,sp,80
    80002420:	00050b93          	mv	s7,a0
    80002424:	00058a93          	mv	s5,a1
    80002428:	00060913          	mv	s2,a2
    8000242c:	00068a13          	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80002430:	fffffc37          	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80002434:	00001b37          	lui	s6,0x1
    80002438:	03c0006f          	j	80002474 <copyin+0x88>
    8000243c:	412984b3          	sub	s1,s3,s2
    80002440:	016484b3          	add	s1,s1,s6
    80002444:	009a7463          	bgeu	s4,s1,8000244c <copyin+0x60>
    80002448:	000a0493          	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000244c:	413905b3          	sub	a1,s2,s3
    80002450:	0004861b          	sext.w	a2,s1
    80002454:	00a585b3          	add	a1,a1,a0
    80002458:	000a8513          	mv	a0,s5
    8000245c:	fffff097          	auipc	ra,0xfffff
    80002460:	e28080e7          	jalr	-472(ra) # 80001284 <memmove>
    len -= n;
    80002464:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80002468:	009a8ab3          	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000246c:	01698933          	add	s2,s3,s6
  while(len > 0){
    80002470:	020a0e63          	beqz	s4,800024ac <copyin+0xc0>
    va0 = PGROUNDDOWN(srcva);
    80002474:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80002478:	00098593          	mv	a1,s3
    8000247c:	000b8513          	mv	a0,s7
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	368080e7          	jalr	872(ra) # 800017e8 <walkaddr>
    if(pa0 == 0) {
    80002488:	fa051ae3          	bnez	a0,8000243c <copyin+0x50>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000248c:	00000613          	li	a2,0
    80002490:	00098593          	mv	a1,s3
    80002494:	000b8513          	mv	a0,s7
    80002498:	00000097          	auipc	ra,0x0
    8000249c:	d10080e7          	jalr	-752(ra) # 800021a8 <vmfault>
    800024a0:	f8051ee3          	bnez	a0,8000243c <copyin+0x50>
        return -1;
    800024a4:	fff00513          	li	a0,-1
    800024a8:	0080006f          	j	800024b0 <copyin+0xc4>
  return 0;
    800024ac:	00000513          	li	a0,0
}
    800024b0:	04813083          	ld	ra,72(sp)
    800024b4:	04013403          	ld	s0,64(sp)
    800024b8:	03813483          	ld	s1,56(sp)
    800024bc:	03013903          	ld	s2,48(sp)
    800024c0:	02813983          	ld	s3,40(sp)
    800024c4:	02013a03          	ld	s4,32(sp)
    800024c8:	01813a83          	ld	s5,24(sp)
    800024cc:	01013b03          	ld	s6,16(sp)
    800024d0:	00813b83          	ld	s7,8(sp)
    800024d4:	00013c03          	ld	s8,0(sp)
    800024d8:	05010113          	addi	sp,sp,80
    800024dc:	00008067          	ret
  return 0;
    800024e0:	00000513          	li	a0,0
}
    800024e4:	00008067          	ret

00000000800024e8 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800024e8:	fc010113          	addi	sp,sp,-64
    800024ec:	02113c23          	sd	ra,56(sp)
    800024f0:	02813823          	sd	s0,48(sp)
    800024f4:	02913423          	sd	s1,40(sp)
    800024f8:	03213023          	sd	s2,32(sp)
    800024fc:	01313c23          	sd	s3,24(sp)
    80002500:	01413823          	sd	s4,16(sp)
    80002504:	01513423          	sd	s5,8(sp)
    80002508:	01613023          	sd	s6,0(sp)
    8000250c:	04010413          	addi	s0,sp,64
    80002510:	00050993          	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80002514:	00011497          	auipc	s1,0x11
    80002518:	9d448493          	addi	s1,s1,-1580 # 80012ee8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000251c:	00048b13          	mv	s6,s1
    80002520:	00008a97          	auipc	s5,0x8
    80002524:	ae0a8a93          	addi	s5,s5,-1312 # 8000a000 <etext>
    80002528:	04000937          	lui	s2,0x4000
    8000252c:	fff90913          	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80002530:	00c91913          	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80002534:	00016a17          	auipc	s4,0x16
    80002538:	3b4a0a13          	addi	s4,s4,948 # 800188e8 <tickslock>
    char *pa = kalloc();
    8000253c:	fffff097          	auipc	ra,0xfffff
    80002540:	9f0080e7          	jalr	-1552(ra) # 80000f2c <kalloc>
    80002544:	00050613          	mv	a2,a0
    if(pa == 0)
    80002548:	06050263          	beqz	a0,800025ac <proc_mapstacks+0xc4>
    uint64 va = KSTACK((int) (p - proc));
    8000254c:	416485b3          	sub	a1,s1,s6
    80002550:	4035d593          	srai	a1,a1,0x3
    80002554:	000ab783          	ld	a5,0(s5)
    80002558:	02f585b3          	mul	a1,a1,a5
    8000255c:	0015859b          	addiw	a1,a1,1
    80002560:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80002564:	00600713          	li	a4,6
    80002568:	000016b7          	lui	a3,0x1
    8000256c:	40b905b3          	sub	a1,s2,a1
    80002570:	00098513          	mv	a0,s3
    80002574:	fffff097          	auipc	ra,0xfffff
    80002578:	400080e7          	jalr	1024(ra) # 80001974 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000257c:	16848493          	addi	s1,s1,360
    80002580:	fb449ee3          	bne	s1,s4,8000253c <proc_mapstacks+0x54>
  }
}
    80002584:	03813083          	ld	ra,56(sp)
    80002588:	03013403          	ld	s0,48(sp)
    8000258c:	02813483          	ld	s1,40(sp)
    80002590:	02013903          	ld	s2,32(sp)
    80002594:	01813983          	ld	s3,24(sp)
    80002598:	01013a03          	ld	s4,16(sp)
    8000259c:	00813a83          	ld	s5,8(sp)
    800025a0:	00013b03          	ld	s6,0(sp)
    800025a4:	04010113          	addi	sp,sp,64
    800025a8:	00008067          	ret
      panic("kalloc");
    800025ac:	00008517          	auipc	a0,0x8
    800025b0:	d2450513          	addi	a0,a0,-732 # 8000a2d0 <digits+0x298>
    800025b4:	ffffe097          	auipc	ra,0xffffe
    800025b8:	4cc080e7          	jalr	1228(ra) # 80000a80 <panic>

00000000800025bc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800025bc:	fc010113          	addi	sp,sp,-64
    800025c0:	02113c23          	sd	ra,56(sp)
    800025c4:	02813823          	sd	s0,48(sp)
    800025c8:	02913423          	sd	s1,40(sp)
    800025cc:	03213023          	sd	s2,32(sp)
    800025d0:	01313c23          	sd	s3,24(sp)
    800025d4:	01413823          	sd	s4,16(sp)
    800025d8:	01513423          	sd	s5,8(sp)
    800025dc:	01613023          	sd	s6,0(sp)
    800025e0:	04010413          	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800025e4:	00008597          	auipc	a1,0x8
    800025e8:	cf458593          	addi	a1,a1,-780 # 8000a2d8 <digits+0x2a0>
    800025ec:	00010517          	auipc	a0,0x10
    800025f0:	4cc50513          	addi	a0,a0,1228 # 80012ab8 <pid_lock>
    800025f4:	fffff097          	auipc	ra,0xfffff
    800025f8:	9c0080e7          	jalr	-1600(ra) # 80000fb4 <initlock>
  initlock(&wait_lock, "wait_lock");
    800025fc:	00008597          	auipc	a1,0x8
    80002600:	ce458593          	addi	a1,a1,-796 # 8000a2e0 <digits+0x2a8>
    80002604:	00010517          	auipc	a0,0x10
    80002608:	4cc50513          	addi	a0,a0,1228 # 80012ad0 <wait_lock>
    8000260c:	fffff097          	auipc	ra,0xfffff
    80002610:	9a8080e7          	jalr	-1624(ra) # 80000fb4 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002614:	00011497          	auipc	s1,0x11
    80002618:	8d448493          	addi	s1,s1,-1836 # 80012ee8 <proc>
      initlock(&p->lock, "proc");
    8000261c:	00008b17          	auipc	s6,0x8
    80002620:	cd4b0b13          	addi	s6,s6,-812 # 8000a2f0 <digits+0x2b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80002624:	00048a93          	mv	s5,s1
    80002628:	00008a17          	auipc	s4,0x8
    8000262c:	9d8a0a13          	addi	s4,s4,-1576 # 8000a000 <etext>
    80002630:	04000937          	lui	s2,0x4000
    80002634:	fff90913          	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80002638:	00c91913          	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000263c:	00016997          	auipc	s3,0x16
    80002640:	2ac98993          	addi	s3,s3,684 # 800188e8 <tickslock>
      initlock(&p->lock, "proc");
    80002644:	000b0593          	mv	a1,s6
    80002648:	00048513          	mv	a0,s1
    8000264c:	fffff097          	auipc	ra,0xfffff
    80002650:	968080e7          	jalr	-1688(ra) # 80000fb4 <initlock>
      p->state = UNUSED;
    80002654:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80002658:	415487b3          	sub	a5,s1,s5
    8000265c:	4037d793          	srai	a5,a5,0x3
    80002660:	000a3703          	ld	a4,0(s4)
    80002664:	02e787b3          	mul	a5,a5,a4
    80002668:	0017879b          	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffdb339>
    8000266c:	00d7979b          	slliw	a5,a5,0xd
    80002670:	40f907b3          	sub	a5,s2,a5
    80002674:	04f4b023          	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80002678:	16848493          	addi	s1,s1,360
    8000267c:	fd3494e3          	bne	s1,s3,80002644 <procinit+0x88>
  }
}
    80002680:	03813083          	ld	ra,56(sp)
    80002684:	03013403          	ld	s0,48(sp)
    80002688:	02813483          	ld	s1,40(sp)
    8000268c:	02013903          	ld	s2,32(sp)
    80002690:	01813983          	ld	s3,24(sp)
    80002694:	01013a03          	ld	s4,16(sp)
    80002698:	00813a83          	ld	s5,8(sp)
    8000269c:	00013b03          	ld	s6,0(sp)
    800026a0:	04010113          	addi	sp,sp,64
    800026a4:	00008067          	ret

00000000800026a8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800026a8:	ff010113          	addi	sp,sp,-16
    800026ac:	00813423          	sd	s0,8(sp)
    800026b0:	01010413          	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800026b4:	00020513          	mv	a0,tp
  int id = r_tp();
  return id;
}
    800026b8:	0005051b          	sext.w	a0,a0
    800026bc:	00813403          	ld	s0,8(sp)
    800026c0:	01010113          	addi	sp,sp,16
    800026c4:	00008067          	ret

00000000800026c8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800026c8:	ff010113          	addi	sp,sp,-16
    800026cc:	00813423          	sd	s0,8(sp)
    800026d0:	01010413          	addi	s0,sp,16
    800026d4:	00020793          	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800026d8:	0007879b          	sext.w	a5,a5
    800026dc:	00779793          	slli	a5,a5,0x7
  return c;
}
    800026e0:	00010517          	auipc	a0,0x10
    800026e4:	40850513          	addi	a0,a0,1032 # 80012ae8 <cpus>
    800026e8:	00f50533          	add	a0,a0,a5
    800026ec:	00813403          	ld	s0,8(sp)
    800026f0:	01010113          	addi	sp,sp,16
    800026f4:	00008067          	ret

00000000800026f8 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800026f8:	fe010113          	addi	sp,sp,-32
    800026fc:	00113c23          	sd	ra,24(sp)
    80002700:	00813823          	sd	s0,16(sp)
    80002704:	00913423          	sd	s1,8(sp)
    80002708:	02010413          	addi	s0,sp,32
  push_off();
    8000270c:	fffff097          	auipc	ra,0xfffff
    80002710:	918080e7          	jalr	-1768(ra) # 80001024 <push_off>
    80002714:	00020793          	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80002718:	0007879b          	sext.w	a5,a5
    8000271c:	00779793          	slli	a5,a5,0x7
    80002720:	00010717          	auipc	a4,0x10
    80002724:	39870713          	addi	a4,a4,920 # 80012ab8 <pid_lock>
    80002728:	00f707b3          	add	a5,a4,a5
    8000272c:	0307b483          	ld	s1,48(a5)
  pop_off();
    80002730:	fffff097          	auipc	ra,0xfffff
    80002734:	9e0080e7          	jalr	-1568(ra) # 80001110 <pop_off>
  return p;
}
    80002738:	00048513          	mv	a0,s1
    8000273c:	01813083          	ld	ra,24(sp)
    80002740:	01013403          	ld	s0,16(sp)
    80002744:	00813483          	ld	s1,8(sp)
    80002748:	02010113          	addi	sp,sp,32
    8000274c:	00008067          	ret

0000000080002750 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80002750:	fd010113          	addi	sp,sp,-48
    80002754:	02113423          	sd	ra,40(sp)
    80002758:	02813023          	sd	s0,32(sp)
    8000275c:	00913c23          	sd	s1,24(sp)
    80002760:	03010413          	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80002764:	00000097          	auipc	ra,0x0
    80002768:	f94080e7          	jalr	-108(ra) # 800026f8 <myproc>
    8000276c:	00050493          	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80002770:	fffff097          	auipc	ra,0xfffff
    80002774:	a20080e7          	jalr	-1504(ra) # 80001190 <release>

  if (first) {
    80002778:	00008797          	auipc	a5,0x8
    8000277c:	2087a783          	lw	a5,520(a5) # 8000a980 <first.1>
    80002780:	04078863          	beqz	a5,800027d0 <forkret+0x80>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80002784:	00100513          	li	a0,1
    80002788:	00003097          	auipc	ra,0x3
    8000278c:	be4080e7          	jalr	-1052(ra) # 8000536c <fsinit>

    first = 0;
    80002790:	00008797          	auipc	a5,0x8
    80002794:	1e07a823          	sw	zero,496(a5) # 8000a980 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80002798:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    8000279c:	00008517          	auipc	a0,0x8
    800027a0:	b5c50513          	addi	a0,a0,-1188 # 8000a2f8 <digits+0x2c0>
    800027a4:	fca43823          	sd	a0,-48(s0)
    800027a8:	fc043c23          	sd	zero,-40(s0)
    800027ac:	fd040593          	addi	a1,s0,-48
    800027b0:	00004097          	auipc	ra,0x4
    800027b4:	690080e7          	jalr	1680(ra) # 80006e40 <kexec>
    800027b8:	0584b783          	ld	a5,88(s1)
    800027bc:	06a7b823          	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800027c0:	0584b783          	ld	a5,88(s1)
    800027c4:	0707b703          	ld	a4,112(a5)
    800027c8:	fff00793          	li	a5,-1
    800027cc:	04f70e63          	beq	a4,a5,80002828 <forkret+0xd8>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800027d0:	00001097          	auipc	ra,0x1
    800027d4:	15c080e7          	jalr	348(ra) # 8000392c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800027d8:	0504b503          	ld	a0,80(s1)
    800027dc:	00c55513          	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800027e0:	04000737          	lui	a4,0x4000
    800027e4:	00007797          	auipc	a5,0x7
    800027e8:	8cc78793          	addi	a5,a5,-1844 # 800090b0 <userret>
    800027ec:	00007697          	auipc	a3,0x7
    800027f0:	81468693          	addi	a3,a3,-2028 # 80009000 <_trampoline>
    800027f4:	40d787b3          	sub	a5,a5,a3
    800027f8:	fff70713          	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800027fc:	00c71713          	slli	a4,a4,0xc
    80002800:	00e787b3          	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002804:	fff00713          	li	a4,-1
    80002808:	03f71713          	slli	a4,a4,0x3f
    8000280c:	00e56533          	or	a0,a0,a4
    80002810:	000780e7          	jalr	a5
}
    80002814:	02813083          	ld	ra,40(sp)
    80002818:	02013403          	ld	s0,32(sp)
    8000281c:	01813483          	ld	s1,24(sp)
    80002820:	03010113          	addi	sp,sp,48
    80002824:	00008067          	ret
      panic("exec");
    80002828:	00008517          	auipc	a0,0x8
    8000282c:	ad850513          	addi	a0,a0,-1320 # 8000a300 <digits+0x2c8>
    80002830:	ffffe097          	auipc	ra,0xffffe
    80002834:	250080e7          	jalr	592(ra) # 80000a80 <panic>

0000000080002838 <allocpid>:
{
    80002838:	fe010113          	addi	sp,sp,-32
    8000283c:	00113c23          	sd	ra,24(sp)
    80002840:	00813823          	sd	s0,16(sp)
    80002844:	00913423          	sd	s1,8(sp)
    80002848:	01213023          	sd	s2,0(sp)
    8000284c:	02010413          	addi	s0,sp,32
  acquire(&pid_lock);
    80002850:	00010917          	auipc	s2,0x10
    80002854:	26890913          	addi	s2,s2,616 # 80012ab8 <pid_lock>
    80002858:	00090513          	mv	a0,s2
    8000285c:	fffff097          	auipc	ra,0xfffff
    80002860:	83c080e7          	jalr	-1988(ra) # 80001098 <acquire>
  pid = nextpid;
    80002864:	00008797          	auipc	a5,0x8
    80002868:	12078793          	addi	a5,a5,288 # 8000a984 <nextpid>
    8000286c:	0007a483          	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80002870:	0014871b          	addiw	a4,s1,1
    80002874:	00e7a023          	sw	a4,0(a5)
  release(&pid_lock);
    80002878:	00090513          	mv	a0,s2
    8000287c:	fffff097          	auipc	ra,0xfffff
    80002880:	914080e7          	jalr	-1772(ra) # 80001190 <release>
}
    80002884:	00048513          	mv	a0,s1
    80002888:	01813083          	ld	ra,24(sp)
    8000288c:	01013403          	ld	s0,16(sp)
    80002890:	00813483          	ld	s1,8(sp)
    80002894:	00013903          	ld	s2,0(sp)
    80002898:	02010113          	addi	sp,sp,32
    8000289c:	00008067          	ret

00000000800028a0 <proc_pagetable>:
{
    800028a0:	fe010113          	addi	sp,sp,-32
    800028a4:	00113c23          	sd	ra,24(sp)
    800028a8:	00813823          	sd	s0,16(sp)
    800028ac:	00913423          	sd	s1,8(sp)
    800028b0:	01213023          	sd	s2,0(sp)
    800028b4:	02010413          	addi	s0,sp,32
    800028b8:	00050913          	mv	s2,a0
  pagetable = uvmcreate();
    800028bc:	fffff097          	auipc	ra,0xfffff
    800028c0:	268080e7          	jalr	616(ra) # 80001b24 <uvmcreate>
    800028c4:	00050493          	mv	s1,a0
  if(pagetable == 0)
    800028c8:	04050a63          	beqz	a0,8000291c <proc_pagetable+0x7c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800028cc:	00a00713          	li	a4,10
    800028d0:	00006697          	auipc	a3,0x6
    800028d4:	73068693          	addi	a3,a3,1840 # 80009000 <_trampoline>
    800028d8:	00001637          	lui	a2,0x1
    800028dc:	040005b7          	lui	a1,0x4000
    800028e0:	fff58593          	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800028e4:	00c59593          	slli	a1,a1,0xc
    800028e8:	fffff097          	auipc	ra,0xfffff
    800028ec:	f6c080e7          	jalr	-148(ra) # 80001854 <mappages>
    800028f0:	04054463          	bltz	a0,80002938 <proc_pagetable+0x98>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800028f4:	00600713          	li	a4,6
    800028f8:	05893683          	ld	a3,88(s2)
    800028fc:	00001637          	lui	a2,0x1
    80002900:	020005b7          	lui	a1,0x2000
    80002904:	fff58593          	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80002908:	00d59593          	slli	a1,a1,0xd
    8000290c:	00048513          	mv	a0,s1
    80002910:	fffff097          	auipc	ra,0xfffff
    80002914:	f44080e7          	jalr	-188(ra) # 80001854 <mappages>
    80002918:	02054c63          	bltz	a0,80002950 <proc_pagetable+0xb0>
}
    8000291c:	00048513          	mv	a0,s1
    80002920:	01813083          	ld	ra,24(sp)
    80002924:	01013403          	ld	s0,16(sp)
    80002928:	00813483          	ld	s1,8(sp)
    8000292c:	00013903          	ld	s2,0(sp)
    80002930:	02010113          	addi	sp,sp,32
    80002934:	00008067          	ret
    uvmfree(pagetable, 0);
    80002938:	00000593          	li	a1,0
    8000293c:	00048513          	mv	a0,s1
    80002940:	fffff097          	auipc	ra,0xfffff
    80002944:	53c080e7          	jalr	1340(ra) # 80001e7c <uvmfree>
    return 0;
    80002948:	00000493          	li	s1,0
    8000294c:	fd1ff06f          	j	8000291c <proc_pagetable+0x7c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002950:	00000693          	li	a3,0
    80002954:	00100613          	li	a2,1
    80002958:	040005b7          	lui	a1,0x4000
    8000295c:	fff58593          	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002960:	00c59593          	slli	a1,a1,0xc
    80002964:	00048513          	mv	a0,s1
    80002968:	fffff097          	auipc	ra,0xfffff
    8000296c:	208080e7          	jalr	520(ra) # 80001b70 <uvmunmap>
    uvmfree(pagetable, 0);
    80002970:	00000593          	li	a1,0
    80002974:	00048513          	mv	a0,s1
    80002978:	fffff097          	auipc	ra,0xfffff
    8000297c:	504080e7          	jalr	1284(ra) # 80001e7c <uvmfree>
    return 0;
    80002980:	00000493          	li	s1,0
    80002984:	f99ff06f          	j	8000291c <proc_pagetable+0x7c>

0000000080002988 <proc_freepagetable>:
{
    80002988:	fe010113          	addi	sp,sp,-32
    8000298c:	00113c23          	sd	ra,24(sp)
    80002990:	00813823          	sd	s0,16(sp)
    80002994:	00913423          	sd	s1,8(sp)
    80002998:	01213023          	sd	s2,0(sp)
    8000299c:	02010413          	addi	s0,sp,32
    800029a0:	00050493          	mv	s1,a0
    800029a4:	00058913          	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800029a8:	00000693          	li	a3,0
    800029ac:	00100613          	li	a2,1
    800029b0:	040005b7          	lui	a1,0x4000
    800029b4:	fff58593          	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800029b8:	00c59593          	slli	a1,a1,0xc
    800029bc:	fffff097          	auipc	ra,0xfffff
    800029c0:	1b4080e7          	jalr	436(ra) # 80001b70 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800029c4:	00000693          	li	a3,0
    800029c8:	00100613          	li	a2,1
    800029cc:	020005b7          	lui	a1,0x2000
    800029d0:	fff58593          	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800029d4:	00d59593          	slli	a1,a1,0xd
    800029d8:	00048513          	mv	a0,s1
    800029dc:	fffff097          	auipc	ra,0xfffff
    800029e0:	194080e7          	jalr	404(ra) # 80001b70 <uvmunmap>
  uvmfree(pagetable, sz);
    800029e4:	00090593          	mv	a1,s2
    800029e8:	00048513          	mv	a0,s1
    800029ec:	fffff097          	auipc	ra,0xfffff
    800029f0:	490080e7          	jalr	1168(ra) # 80001e7c <uvmfree>
}
    800029f4:	01813083          	ld	ra,24(sp)
    800029f8:	01013403          	ld	s0,16(sp)
    800029fc:	00813483          	ld	s1,8(sp)
    80002a00:	00013903          	ld	s2,0(sp)
    80002a04:	02010113          	addi	sp,sp,32
    80002a08:	00008067          	ret

0000000080002a0c <freeproc>:
{
    80002a0c:	fe010113          	addi	sp,sp,-32
    80002a10:	00113c23          	sd	ra,24(sp)
    80002a14:	00813823          	sd	s0,16(sp)
    80002a18:	00913423          	sd	s1,8(sp)
    80002a1c:	02010413          	addi	s0,sp,32
    80002a20:	00050493          	mv	s1,a0
  if(p->trapframe)
    80002a24:	05853503          	ld	a0,88(a0)
    80002a28:	00050663          	beqz	a0,80002a34 <freeproc+0x28>
    kfree((void*)p->trapframe);
    80002a2c:	ffffe097          	auipc	ra,0xffffe
    80002a30:	394080e7          	jalr	916(ra) # 80000dc0 <kfree>
  p->trapframe = 0;
    80002a34:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80002a38:	0504b503          	ld	a0,80(s1)
    80002a3c:	00050863          	beqz	a0,80002a4c <freeproc+0x40>
    proc_freepagetable(p->pagetable, p->sz);
    80002a40:	0484b583          	ld	a1,72(s1)
    80002a44:	00000097          	auipc	ra,0x0
    80002a48:	f44080e7          	jalr	-188(ra) # 80002988 <proc_freepagetable>
  p->pagetable = 0;
    80002a4c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80002a50:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80002a54:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80002a58:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80002a5c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80002a60:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80002a64:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80002a68:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80002a6c:	0004ac23          	sw	zero,24(s1)
}
    80002a70:	01813083          	ld	ra,24(sp)
    80002a74:	01013403          	ld	s0,16(sp)
    80002a78:	00813483          	ld	s1,8(sp)
    80002a7c:	02010113          	addi	sp,sp,32
    80002a80:	00008067          	ret

0000000080002a84 <allocproc>:
{
    80002a84:	fe010113          	addi	sp,sp,-32
    80002a88:	00113c23          	sd	ra,24(sp)
    80002a8c:	00813823          	sd	s0,16(sp)
    80002a90:	00913423          	sd	s1,8(sp)
    80002a94:	01213023          	sd	s2,0(sp)
    80002a98:	02010413          	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80002a9c:	00010497          	auipc	s1,0x10
    80002aa0:	44c48493          	addi	s1,s1,1100 # 80012ee8 <proc>
    80002aa4:	00016917          	auipc	s2,0x16
    80002aa8:	e4490913          	addi	s2,s2,-444 # 800188e8 <tickslock>
    acquire(&p->lock);
    80002aac:	00048513          	mv	a0,s1
    80002ab0:	ffffe097          	auipc	ra,0xffffe
    80002ab4:	5e8080e7          	jalr	1512(ra) # 80001098 <acquire>
    if(p->state == UNUSED) {
    80002ab8:	0184a783          	lw	a5,24(s1)
    80002abc:	02078063          	beqz	a5,80002adc <allocproc+0x58>
      release(&p->lock);
    80002ac0:	00048513          	mv	a0,s1
    80002ac4:	ffffe097          	auipc	ra,0xffffe
    80002ac8:	6cc080e7          	jalr	1740(ra) # 80001190 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002acc:	16848493          	addi	s1,s1,360
    80002ad0:	fd249ee3          	bne	s1,s2,80002aac <allocproc+0x28>
  return 0;
    80002ad4:	00000493          	li	s1,0
    80002ad8:	0740006f          	j	80002b4c <allocproc+0xc8>
  p->pid = allocpid();
    80002adc:	00000097          	auipc	ra,0x0
    80002ae0:	d5c080e7          	jalr	-676(ra) # 80002838 <allocpid>
    80002ae4:	02a4a823          	sw	a0,48(s1)
  p->state = USED;
    80002ae8:	00100793          	li	a5,1
    80002aec:	00f4ac23          	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	43c080e7          	jalr	1084(ra) # 80000f2c <kalloc>
    80002af8:	00050913          	mv	s2,a0
    80002afc:	04a4bc23          	sd	a0,88(s1)
    80002b00:	06050463          	beqz	a0,80002b68 <allocproc+0xe4>
  p->pagetable = proc_pagetable(p);
    80002b04:	00048513          	mv	a0,s1
    80002b08:	00000097          	auipc	ra,0x0
    80002b0c:	d98080e7          	jalr	-616(ra) # 800028a0 <proc_pagetable>
    80002b10:	00050913          	mv	s2,a0
    80002b14:	04a4b823          	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002b18:	06050863          	beqz	a0,80002b88 <allocproc+0x104>
  memset(&p->context, 0, sizeof(p->context));
    80002b1c:	07000613          	li	a2,112
    80002b20:	00000593          	li	a1,0
    80002b24:	06048513          	addi	a0,s1,96
    80002b28:	ffffe097          	auipc	ra,0xffffe
    80002b2c:	6c8080e7          	jalr	1736(ra) # 800011f0 <memset>
  p->context.ra = (uint64)forkret;
    80002b30:	00000797          	auipc	a5,0x0
    80002b34:	c2078793          	addi	a5,a5,-992 # 80002750 <forkret>
    80002b38:	06f4b023          	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002b3c:	0404b783          	ld	a5,64(s1)
    80002b40:	00001737          	lui	a4,0x1
    80002b44:	00e787b3          	add	a5,a5,a4
    80002b48:	06f4b423          	sd	a5,104(s1)
}
    80002b4c:	00048513          	mv	a0,s1
    80002b50:	01813083          	ld	ra,24(sp)
    80002b54:	01013403          	ld	s0,16(sp)
    80002b58:	00813483          	ld	s1,8(sp)
    80002b5c:	00013903          	ld	s2,0(sp)
    80002b60:	02010113          	addi	sp,sp,32
    80002b64:	00008067          	ret
    freeproc(p);
    80002b68:	00048513          	mv	a0,s1
    80002b6c:	00000097          	auipc	ra,0x0
    80002b70:	ea0080e7          	jalr	-352(ra) # 80002a0c <freeproc>
    release(&p->lock);
    80002b74:	00048513          	mv	a0,s1
    80002b78:	ffffe097          	auipc	ra,0xffffe
    80002b7c:	618080e7          	jalr	1560(ra) # 80001190 <release>
    return 0;
    80002b80:	00090493          	mv	s1,s2
    80002b84:	fc9ff06f          	j	80002b4c <allocproc+0xc8>
    freeproc(p);
    80002b88:	00048513          	mv	a0,s1
    80002b8c:	00000097          	auipc	ra,0x0
    80002b90:	e80080e7          	jalr	-384(ra) # 80002a0c <freeproc>
    release(&p->lock);
    80002b94:	00048513          	mv	a0,s1
    80002b98:	ffffe097          	auipc	ra,0xffffe
    80002b9c:	5f8080e7          	jalr	1528(ra) # 80001190 <release>
    return 0;
    80002ba0:	00090493          	mv	s1,s2
    80002ba4:	fa9ff06f          	j	80002b4c <allocproc+0xc8>

0000000080002ba8 <userinit>:
{
    80002ba8:	fe010113          	addi	sp,sp,-32
    80002bac:	00113c23          	sd	ra,24(sp)
    80002bb0:	00813823          	sd	s0,16(sp)
    80002bb4:	00913423          	sd	s1,8(sp)
    80002bb8:	02010413          	addi	s0,sp,32
  p = allocproc();
    80002bbc:	00000097          	auipc	ra,0x0
    80002bc0:	ec8080e7          	jalr	-312(ra) # 80002a84 <allocproc>
    80002bc4:	00050493          	mv	s1,a0
  initproc = p;
    80002bc8:	00008797          	auipc	a5,0x8
    80002bcc:	dea7b423          	sd	a0,-536(a5) # 8000a9b0 <initproc>
  p->cwd = namei("/");
    80002bd0:	00007517          	auipc	a0,0x7
    80002bd4:	73850513          	addi	a0,a0,1848 # 8000a308 <digits+0x2d0>
    80002bd8:	00003097          	auipc	ra,0x3
    80002bdc:	fbc080e7          	jalr	-68(ra) # 80005b94 <namei>
    80002be0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80002be4:	00300793          	li	a5,3
    80002be8:	00f4ac23          	sw	a5,24(s1)
  release(&p->lock);
    80002bec:	00048513          	mv	a0,s1
    80002bf0:	ffffe097          	auipc	ra,0xffffe
    80002bf4:	5a0080e7          	jalr	1440(ra) # 80001190 <release>
}
    80002bf8:	01813083          	ld	ra,24(sp)
    80002bfc:	01013403          	ld	s0,16(sp)
    80002c00:	00813483          	ld	s1,8(sp)
    80002c04:	02010113          	addi	sp,sp,32
    80002c08:	00008067          	ret

0000000080002c0c <growproc>:
{
    80002c0c:	fe010113          	addi	sp,sp,-32
    80002c10:	00113c23          	sd	ra,24(sp)
    80002c14:	00813823          	sd	s0,16(sp)
    80002c18:	00913423          	sd	s1,8(sp)
    80002c1c:	01213023          	sd	s2,0(sp)
    80002c20:	02010413          	addi	s0,sp,32
    80002c24:	00050913          	mv	s2,a0
  struct proc *p = myproc();
    80002c28:	00000097          	auipc	ra,0x0
    80002c2c:	ad0080e7          	jalr	-1328(ra) # 800026f8 <myproc>
    80002c30:	00050493          	mv	s1,a0
  sz = p->sz;
    80002c34:	04853583          	ld	a1,72(a0)
  if(n > 0){
    80002c38:	03204463          	bgtz	s2,80002c60 <growproc+0x54>
  } else if(n < 0){
    80002c3c:	04094463          	bltz	s2,80002c84 <growproc+0x78>
  p->sz = sz;
    80002c40:	04b4b423          	sd	a1,72(s1)
  return 0;
    80002c44:	00000513          	li	a0,0
}
    80002c48:	01813083          	ld	ra,24(sp)
    80002c4c:	01013403          	ld	s0,16(sp)
    80002c50:	00813483          	ld	s1,8(sp)
    80002c54:	00013903          	ld	s2,0(sp)
    80002c58:	02010113          	addi	sp,sp,32
    80002c5c:	00008067          	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80002c60:	00400693          	li	a3,4
    80002c64:	00b90633          	add	a2,s2,a1
    80002c68:	05053503          	ld	a0,80(a0)
    80002c6c:	fffff097          	auipc	ra,0xfffff
    80002c70:	04c080e7          	jalr	76(ra) # 80001cb8 <uvmalloc>
    80002c74:	00050593          	mv	a1,a0
    80002c78:	fc0514e3          	bnez	a0,80002c40 <growproc+0x34>
      return -1;
    80002c7c:	fff00513          	li	a0,-1
    80002c80:	fc9ff06f          	j	80002c48 <growproc+0x3c>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002c84:	00b90633          	add	a2,s2,a1
    80002c88:	05053503          	ld	a0,80(a0)
    80002c8c:	fffff097          	auipc	ra,0xfffff
    80002c90:	fb4080e7          	jalr	-76(ra) # 80001c40 <uvmdealloc>
    80002c94:	00050593          	mv	a1,a0
    80002c98:	fa9ff06f          	j	80002c40 <growproc+0x34>

0000000080002c9c <kfork>:
{
    80002c9c:	fc010113          	addi	sp,sp,-64
    80002ca0:	02113c23          	sd	ra,56(sp)
    80002ca4:	02813823          	sd	s0,48(sp)
    80002ca8:	02913423          	sd	s1,40(sp)
    80002cac:	03213023          	sd	s2,32(sp)
    80002cb0:	01313c23          	sd	s3,24(sp)
    80002cb4:	01413823          	sd	s4,16(sp)
    80002cb8:	01513423          	sd	s5,8(sp)
    80002cbc:	04010413          	addi	s0,sp,64
  struct proc *p = myproc();
    80002cc0:	00000097          	auipc	ra,0x0
    80002cc4:	a38080e7          	jalr	-1480(ra) # 800026f8 <myproc>
    80002cc8:	00050a93          	mv	s5,a0
  if((np = allocproc()) == 0){
    80002ccc:	00000097          	auipc	ra,0x0
    80002cd0:	db8080e7          	jalr	-584(ra) # 80002a84 <allocproc>
    80002cd4:	16050063          	beqz	a0,80002e34 <kfork+0x198>
    80002cd8:	00050a13          	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002cdc:	048ab603          	ld	a2,72(s5)
    80002ce0:	05053583          	ld	a1,80(a0)
    80002ce4:	050ab503          	ld	a0,80(s5)
    80002ce8:	fffff097          	auipc	ra,0xfffff
    80002cec:	1f4080e7          	jalr	500(ra) # 80001edc <uvmcopy>
    80002cf0:	06054063          	bltz	a0,80002d50 <kfork+0xb4>
  np->sz = p->sz;
    80002cf4:	048ab783          	ld	a5,72(s5)
    80002cf8:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80002cfc:	058ab683          	ld	a3,88(s5)
    80002d00:	00068793          	mv	a5,a3
    80002d04:	058a3703          	ld	a4,88(s4)
    80002d08:	12068693          	addi	a3,a3,288
    80002d0c:	0007b803          	ld	a6,0(a5)
    80002d10:	0087b503          	ld	a0,8(a5)
    80002d14:	0107b583          	ld	a1,16(a5)
    80002d18:	0187b603          	ld	a2,24(a5)
    80002d1c:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80002d20:	00a73423          	sd	a0,8(a4)
    80002d24:	00b73823          	sd	a1,16(a4)
    80002d28:	00c73c23          	sd	a2,24(a4)
    80002d2c:	02078793          	addi	a5,a5,32
    80002d30:	02070713          	addi	a4,a4,32
    80002d34:	fcd79ce3          	bne	a5,a3,80002d0c <kfork+0x70>
  np->trapframe->a0 = 0;
    80002d38:	058a3783          	ld	a5,88(s4)
    80002d3c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002d40:	0d0a8493          	addi	s1,s5,208
    80002d44:	0d0a0913          	addi	s2,s4,208
    80002d48:	150a8993          	addi	s3,s5,336
    80002d4c:	0300006f          	j	80002d7c <kfork+0xe0>
    freeproc(np);
    80002d50:	000a0513          	mv	a0,s4
    80002d54:	00000097          	auipc	ra,0x0
    80002d58:	cb8080e7          	jalr	-840(ra) # 80002a0c <freeproc>
    release(&np->lock);
    80002d5c:	000a0513          	mv	a0,s4
    80002d60:	ffffe097          	auipc	ra,0xffffe
    80002d64:	430080e7          	jalr	1072(ra) # 80001190 <release>
    return -1;
    80002d68:	fff00913          	li	s2,-1
    80002d6c:	0a00006f          	j	80002e0c <kfork+0x170>
  for(i = 0; i < NOFILE; i++)
    80002d70:	00848493          	addi	s1,s1,8
    80002d74:	00890913          	addi	s2,s2,8
    80002d78:	01348e63          	beq	s1,s3,80002d94 <kfork+0xf8>
    if(p->ofile[i])
    80002d7c:	0004b503          	ld	a0,0(s1)
    80002d80:	fe0508e3          	beqz	a0,80002d70 <kfork+0xd4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002d84:	00003097          	auipc	ra,0x3
    80002d88:	730080e7          	jalr	1840(ra) # 800064b4 <filedup>
    80002d8c:	00a93023          	sd	a0,0(s2)
    80002d90:	fe1ff06f          	j	80002d70 <kfork+0xd4>
  np->cwd = idup(p->cwd);
    80002d94:	150ab503          	ld	a0,336(s5)
    80002d98:	00002097          	auipc	ra,0x2
    80002d9c:	0b4080e7          	jalr	180(ra) # 80004e4c <idup>
    80002da0:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002da4:	01000613          	li	a2,16
    80002da8:	158a8593          	addi	a1,s5,344
    80002dac:	158a0513          	addi	a0,s4,344
    80002db0:	ffffe097          	auipc	ra,0xffffe
    80002db4:	640080e7          	jalr	1600(ra) # 800013f0 <safestrcpy>
  pid = np->pid;
    80002db8:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80002dbc:	000a0513          	mv	a0,s4
    80002dc0:	ffffe097          	auipc	ra,0xffffe
    80002dc4:	3d0080e7          	jalr	976(ra) # 80001190 <release>
  acquire(&wait_lock);
    80002dc8:	00010497          	auipc	s1,0x10
    80002dcc:	d0848493          	addi	s1,s1,-760 # 80012ad0 <wait_lock>
    80002dd0:	00048513          	mv	a0,s1
    80002dd4:	ffffe097          	auipc	ra,0xffffe
    80002dd8:	2c4080e7          	jalr	708(ra) # 80001098 <acquire>
  np->parent = p;
    80002ddc:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80002de0:	00048513          	mv	a0,s1
    80002de4:	ffffe097          	auipc	ra,0xffffe
    80002de8:	3ac080e7          	jalr	940(ra) # 80001190 <release>
  acquire(&np->lock);
    80002dec:	000a0513          	mv	a0,s4
    80002df0:	ffffe097          	auipc	ra,0xffffe
    80002df4:	2a8080e7          	jalr	680(ra) # 80001098 <acquire>
  np->state = RUNNABLE;
    80002df8:	00300793          	li	a5,3
    80002dfc:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80002e00:	000a0513          	mv	a0,s4
    80002e04:	ffffe097          	auipc	ra,0xffffe
    80002e08:	38c080e7          	jalr	908(ra) # 80001190 <release>
}
    80002e0c:	00090513          	mv	a0,s2
    80002e10:	03813083          	ld	ra,56(sp)
    80002e14:	03013403          	ld	s0,48(sp)
    80002e18:	02813483          	ld	s1,40(sp)
    80002e1c:	02013903          	ld	s2,32(sp)
    80002e20:	01813983          	ld	s3,24(sp)
    80002e24:	01013a03          	ld	s4,16(sp)
    80002e28:	00813a83          	ld	s5,8(sp)
    80002e2c:	04010113          	addi	sp,sp,64
    80002e30:	00008067          	ret
    return -1;
    80002e34:	fff00913          	li	s2,-1
    80002e38:	fd5ff06f          	j	80002e0c <kfork+0x170>

0000000080002e3c <scheduler>:
{
    80002e3c:	fb010113          	addi	sp,sp,-80
    80002e40:	04113423          	sd	ra,72(sp)
    80002e44:	04813023          	sd	s0,64(sp)
    80002e48:	02913c23          	sd	s1,56(sp)
    80002e4c:	03213823          	sd	s2,48(sp)
    80002e50:	03313423          	sd	s3,40(sp)
    80002e54:	03413023          	sd	s4,32(sp)
    80002e58:	01513c23          	sd	s5,24(sp)
    80002e5c:	01613823          	sd	s6,16(sp)
    80002e60:	01713423          	sd	s7,8(sp)
    80002e64:	01813023          	sd	s8,0(sp)
    80002e68:	05010413          	addi	s0,sp,80
    80002e6c:	00020793          	mv	a5,tp
  int id = r_tp();
    80002e70:	0007879b          	sext.w	a5,a5
  c->proc = 0;
    80002e74:	00779b13          	slli	s6,a5,0x7
    80002e78:	00010717          	auipc	a4,0x10
    80002e7c:	c4070713          	addi	a4,a4,-960 # 80012ab8 <pid_lock>
    80002e80:	01670733          	add	a4,a4,s6
    80002e84:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002e88:	00010717          	auipc	a4,0x10
    80002e8c:	c6870713          	addi	a4,a4,-920 # 80012af0 <cpus+0x8>
    80002e90:	00eb0b33          	add	s6,s6,a4
        p->state = RUNNING;
    80002e94:	00400c13          	li	s8,4
        c->proc = p;
    80002e98:	00779793          	slli	a5,a5,0x7
    80002e9c:	00010a17          	auipc	s4,0x10
    80002ea0:	c1ca0a13          	addi	s4,s4,-996 # 80012ab8 <pid_lock>
    80002ea4:	00fa0a33          	add	s4,s4,a5
        found = 1;
    80002ea8:	00100b93          	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80002eac:	00016997          	auipc	s3,0x16
    80002eb0:	a3c98993          	addi	s3,s3,-1476 # 800188e8 <tickslock>
    80002eb4:	0580006f          	j	80002f0c <scheduler+0xd0>
      release(&p->lock);
    80002eb8:	00048513          	mv	a0,s1
    80002ebc:	ffffe097          	auipc	ra,0xffffe
    80002ec0:	2d4080e7          	jalr	724(ra) # 80001190 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002ec4:	16848493          	addi	s1,s1,360
    80002ec8:	03348e63          	beq	s1,s3,80002f04 <scheduler+0xc8>
      acquire(&p->lock);
    80002ecc:	00048513          	mv	a0,s1
    80002ed0:	ffffe097          	auipc	ra,0xffffe
    80002ed4:	1c8080e7          	jalr	456(ra) # 80001098 <acquire>
      if(p->state == RUNNABLE) {
    80002ed8:	0184a783          	lw	a5,24(s1)
    80002edc:	fd279ee3          	bne	a5,s2,80002eb8 <scheduler+0x7c>
        p->state = RUNNING;
    80002ee0:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80002ee4:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002ee8:	06048593          	addi	a1,s1,96
    80002eec:	000b0513          	mv	a0,s6
    80002ef0:	00001097          	auipc	ra,0x1
    80002ef4:	96c080e7          	jalr	-1684(ra) # 8000385c <swtch>
        c->proc = 0;
    80002ef8:	020a3823          	sd	zero,48(s4)
        found = 1;
    80002efc:	000b8a93          	mv	s5,s7
    80002f00:	fb9ff06f          	j	80002eb8 <scheduler+0x7c>
    if(found == 0) {
    80002f04:	000a9463          	bnez	s5,80002f0c <scheduler+0xd0>
      asm volatile("wfi");
    80002f08:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f0c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002f10:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f14:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f18:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002f1c:	ffd7f793          	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f20:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002f24:	00000a93          	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002f28:	00010497          	auipc	s1,0x10
    80002f2c:	fc048493          	addi	s1,s1,-64 # 80012ee8 <proc>
      if(p->state == RUNNABLE) {
    80002f30:	00300913          	li	s2,3
    80002f34:	f99ff06f          	j	80002ecc <scheduler+0x90>

0000000080002f38 <sched>:
{
    80002f38:	fd010113          	addi	sp,sp,-48
    80002f3c:	02113423          	sd	ra,40(sp)
    80002f40:	02813023          	sd	s0,32(sp)
    80002f44:	00913c23          	sd	s1,24(sp)
    80002f48:	01213823          	sd	s2,16(sp)
    80002f4c:	01313423          	sd	s3,8(sp)
    80002f50:	03010413          	addi	s0,sp,48
  struct proc *p = myproc();
    80002f54:	fffff097          	auipc	ra,0xfffff
    80002f58:	7a4080e7          	jalr	1956(ra) # 800026f8 <myproc>
    80002f5c:	00050493          	mv	s1,a0
  if(!holding(&p->lock))
    80002f60:	ffffe097          	auipc	ra,0xffffe
    80002f64:	078080e7          	jalr	120(ra) # 80000fd8 <holding>
    80002f68:	0a050863          	beqz	a0,80003018 <sched+0xe0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002f6c:	00020793          	mv	a5,tp
  if(mycpu()->noff != 1)
    80002f70:	0007879b          	sext.w	a5,a5
    80002f74:	00779793          	slli	a5,a5,0x7
    80002f78:	00010717          	auipc	a4,0x10
    80002f7c:	b4070713          	addi	a4,a4,-1216 # 80012ab8 <pid_lock>
    80002f80:	00f707b3          	add	a5,a4,a5
    80002f84:	0a87a703          	lw	a4,168(a5)
    80002f88:	00100793          	li	a5,1
    80002f8c:	08f71e63          	bne	a4,a5,80003028 <sched+0xf0>
  if(p->state == RUNNING)
    80002f90:	0184a703          	lw	a4,24(s1)
    80002f94:	00400793          	li	a5,4
    80002f98:	0af70063          	beq	a4,a5,80003038 <sched+0x100>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002fa0:	0027f793          	andi	a5,a5,2
  if(intr_get())
    80002fa4:	0a079263          	bnez	a5,80003048 <sched+0x110>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002fa8:	00020793          	mv	a5,tp
  intena = mycpu()->intena;
    80002fac:	00010917          	auipc	s2,0x10
    80002fb0:	b0c90913          	addi	s2,s2,-1268 # 80012ab8 <pid_lock>
    80002fb4:	0007879b          	sext.w	a5,a5
    80002fb8:	00779793          	slli	a5,a5,0x7
    80002fbc:	00f907b3          	add	a5,s2,a5
    80002fc0:	0ac7a983          	lw	s3,172(a5)
    80002fc4:	00020793          	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002fc8:	0007879b          	sext.w	a5,a5
    80002fcc:	00779793          	slli	a5,a5,0x7
    80002fd0:	00010597          	auipc	a1,0x10
    80002fd4:	b2058593          	addi	a1,a1,-1248 # 80012af0 <cpus+0x8>
    80002fd8:	00b785b3          	add	a1,a5,a1
    80002fdc:	06048513          	addi	a0,s1,96
    80002fe0:	00001097          	auipc	ra,0x1
    80002fe4:	87c080e7          	jalr	-1924(ra) # 8000385c <swtch>
    80002fe8:	00020793          	mv	a5,tp
  mycpu()->intena = intena;
    80002fec:	0007879b          	sext.w	a5,a5
    80002ff0:	00779793          	slli	a5,a5,0x7
    80002ff4:	00f90933          	add	s2,s2,a5
    80002ff8:	0b392623          	sw	s3,172(s2)
}
    80002ffc:	02813083          	ld	ra,40(sp)
    80003000:	02013403          	ld	s0,32(sp)
    80003004:	01813483          	ld	s1,24(sp)
    80003008:	01013903          	ld	s2,16(sp)
    8000300c:	00813983          	ld	s3,8(sp)
    80003010:	03010113          	addi	sp,sp,48
    80003014:	00008067          	ret
    panic("sched p->lock");
    80003018:	00007517          	auipc	a0,0x7
    8000301c:	2f850513          	addi	a0,a0,760 # 8000a310 <digits+0x2d8>
    80003020:	ffffe097          	auipc	ra,0xffffe
    80003024:	a60080e7          	jalr	-1440(ra) # 80000a80 <panic>
    panic("sched locks");
    80003028:	00007517          	auipc	a0,0x7
    8000302c:	2f850513          	addi	a0,a0,760 # 8000a320 <digits+0x2e8>
    80003030:	ffffe097          	auipc	ra,0xffffe
    80003034:	a50080e7          	jalr	-1456(ra) # 80000a80 <panic>
    panic("sched RUNNING");
    80003038:	00007517          	auipc	a0,0x7
    8000303c:	2f850513          	addi	a0,a0,760 # 8000a330 <digits+0x2f8>
    80003040:	ffffe097          	auipc	ra,0xffffe
    80003044:	a40080e7          	jalr	-1472(ra) # 80000a80 <panic>
    panic("sched interruptible");
    80003048:	00007517          	auipc	a0,0x7
    8000304c:	2f850513          	addi	a0,a0,760 # 8000a340 <digits+0x308>
    80003050:	ffffe097          	auipc	ra,0xffffe
    80003054:	a30080e7          	jalr	-1488(ra) # 80000a80 <panic>

0000000080003058 <yield>:
{
    80003058:	fe010113          	addi	sp,sp,-32
    8000305c:	00113c23          	sd	ra,24(sp)
    80003060:	00813823          	sd	s0,16(sp)
    80003064:	00913423          	sd	s1,8(sp)
    80003068:	02010413          	addi	s0,sp,32
  struct proc *p = myproc();
    8000306c:	fffff097          	auipc	ra,0xfffff
    80003070:	68c080e7          	jalr	1676(ra) # 800026f8 <myproc>
    80003074:	00050493          	mv	s1,a0
  acquire(&p->lock);
    80003078:	ffffe097          	auipc	ra,0xffffe
    8000307c:	020080e7          	jalr	32(ra) # 80001098 <acquire>
  p->state = RUNNABLE;
    80003080:	00300793          	li	a5,3
    80003084:	00f4ac23          	sw	a5,24(s1)
  sched();
    80003088:	00000097          	auipc	ra,0x0
    8000308c:	eb0080e7          	jalr	-336(ra) # 80002f38 <sched>
  release(&p->lock);
    80003090:	00048513          	mv	a0,s1
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	0fc080e7          	jalr	252(ra) # 80001190 <release>
}
    8000309c:	01813083          	ld	ra,24(sp)
    800030a0:	01013403          	ld	s0,16(sp)
    800030a4:	00813483          	ld	s1,8(sp)
    800030a8:	02010113          	addi	sp,sp,32
    800030ac:	00008067          	ret

00000000800030b0 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800030b0:	fd010113          	addi	sp,sp,-48
    800030b4:	02113423          	sd	ra,40(sp)
    800030b8:	02813023          	sd	s0,32(sp)
    800030bc:	00913c23          	sd	s1,24(sp)
    800030c0:	01213823          	sd	s2,16(sp)
    800030c4:	01313423          	sd	s3,8(sp)
    800030c8:	03010413          	addi	s0,sp,48
    800030cc:	00050993          	mv	s3,a0
    800030d0:	00058913          	mv	s2,a1
  struct proc *p = myproc();
    800030d4:	fffff097          	auipc	ra,0xfffff
    800030d8:	624080e7          	jalr	1572(ra) # 800026f8 <myproc>
    800030dc:	00050493          	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800030e0:	ffffe097          	auipc	ra,0xffffe
    800030e4:	fb8080e7          	jalr	-72(ra) # 80001098 <acquire>
  release(lk);
    800030e8:	00090513          	mv	a0,s2
    800030ec:	ffffe097          	auipc	ra,0xffffe
    800030f0:	0a4080e7          	jalr	164(ra) # 80001190 <release>

  // Go to sleep.
  p->chan = chan;
    800030f4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800030f8:	00200793          	li	a5,2
    800030fc:	00f4ac23          	sw	a5,24(s1)

  sched();
    80003100:	00000097          	auipc	ra,0x0
    80003104:	e38080e7          	jalr	-456(ra) # 80002f38 <sched>

  // Tidy up.
  p->chan = 0;
    80003108:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000310c:	00048513          	mv	a0,s1
    80003110:	ffffe097          	auipc	ra,0xffffe
    80003114:	080080e7          	jalr	128(ra) # 80001190 <release>
  acquire(lk);
    80003118:	00090513          	mv	a0,s2
    8000311c:	ffffe097          	auipc	ra,0xffffe
    80003120:	f7c080e7          	jalr	-132(ra) # 80001098 <acquire>
}
    80003124:	02813083          	ld	ra,40(sp)
    80003128:	02013403          	ld	s0,32(sp)
    8000312c:	01813483          	ld	s1,24(sp)
    80003130:	01013903          	ld	s2,16(sp)
    80003134:	00813983          	ld	s3,8(sp)
    80003138:	03010113          	addi	sp,sp,48
    8000313c:	00008067          	ret

0000000080003140 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80003140:	fc010113          	addi	sp,sp,-64
    80003144:	02113c23          	sd	ra,56(sp)
    80003148:	02813823          	sd	s0,48(sp)
    8000314c:	02913423          	sd	s1,40(sp)
    80003150:	03213023          	sd	s2,32(sp)
    80003154:	01313c23          	sd	s3,24(sp)
    80003158:	01413823          	sd	s4,16(sp)
    8000315c:	01513423          	sd	s5,8(sp)
    80003160:	04010413          	addi	s0,sp,64
    80003164:	00050a13          	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80003168:	00010497          	auipc	s1,0x10
    8000316c:	d8048493          	addi	s1,s1,-640 # 80012ee8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80003170:	00200993          	li	s3,2
        p->state = RUNNABLE;
    80003174:	00300a93          	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80003178:	00015917          	auipc	s2,0x15
    8000317c:	77090913          	addi	s2,s2,1904 # 800188e8 <tickslock>
    80003180:	0180006f          	j	80003198 <wakeup+0x58>
      }
      release(&p->lock);
    80003184:	00048513          	mv	a0,s1
    80003188:	ffffe097          	auipc	ra,0xffffe
    8000318c:	008080e7          	jalr	8(ra) # 80001190 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80003190:	16848493          	addi	s1,s1,360
    80003194:	03248a63          	beq	s1,s2,800031c8 <wakeup+0x88>
    if(p != myproc()){
    80003198:	fffff097          	auipc	ra,0xfffff
    8000319c:	560080e7          	jalr	1376(ra) # 800026f8 <myproc>
    800031a0:	fea488e3          	beq	s1,a0,80003190 <wakeup+0x50>
      acquire(&p->lock);
    800031a4:	00048513          	mv	a0,s1
    800031a8:	ffffe097          	auipc	ra,0xffffe
    800031ac:	ef0080e7          	jalr	-272(ra) # 80001098 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800031b0:	0184a783          	lw	a5,24(s1)
    800031b4:	fd3798e3          	bne	a5,s3,80003184 <wakeup+0x44>
    800031b8:	0204b783          	ld	a5,32(s1)
    800031bc:	fd4794e3          	bne	a5,s4,80003184 <wakeup+0x44>
        p->state = RUNNABLE;
    800031c0:	0154ac23          	sw	s5,24(s1)
    800031c4:	fc1ff06f          	j	80003184 <wakeup+0x44>
    }
  }
}
    800031c8:	03813083          	ld	ra,56(sp)
    800031cc:	03013403          	ld	s0,48(sp)
    800031d0:	02813483          	ld	s1,40(sp)
    800031d4:	02013903          	ld	s2,32(sp)
    800031d8:	01813983          	ld	s3,24(sp)
    800031dc:	01013a03          	ld	s4,16(sp)
    800031e0:	00813a83          	ld	s5,8(sp)
    800031e4:	04010113          	addi	sp,sp,64
    800031e8:	00008067          	ret

00000000800031ec <reparent>:
{
    800031ec:	fd010113          	addi	sp,sp,-48
    800031f0:	02113423          	sd	ra,40(sp)
    800031f4:	02813023          	sd	s0,32(sp)
    800031f8:	00913c23          	sd	s1,24(sp)
    800031fc:	01213823          	sd	s2,16(sp)
    80003200:	01313423          	sd	s3,8(sp)
    80003204:	01413023          	sd	s4,0(sp)
    80003208:	03010413          	addi	s0,sp,48
    8000320c:	00050913          	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80003210:	00010497          	auipc	s1,0x10
    80003214:	cd848493          	addi	s1,s1,-808 # 80012ee8 <proc>
      pp->parent = initproc;
    80003218:	00007a17          	auipc	s4,0x7
    8000321c:	798a0a13          	addi	s4,s4,1944 # 8000a9b0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80003220:	00015997          	auipc	s3,0x15
    80003224:	6c898993          	addi	s3,s3,1736 # 800188e8 <tickslock>
    80003228:	00c0006f          	j	80003234 <reparent+0x48>
    8000322c:	16848493          	addi	s1,s1,360
    80003230:	03348063          	beq	s1,s3,80003250 <reparent+0x64>
    if(pp->parent == p){
    80003234:	0384b783          	ld	a5,56(s1)
    80003238:	ff279ae3          	bne	a5,s2,8000322c <reparent+0x40>
      pp->parent = initproc;
    8000323c:	000a3503          	ld	a0,0(s4)
    80003240:	02a4bc23          	sd	a0,56(s1)
      wakeup(initproc);
    80003244:	00000097          	auipc	ra,0x0
    80003248:	efc080e7          	jalr	-260(ra) # 80003140 <wakeup>
    8000324c:	fe1ff06f          	j	8000322c <reparent+0x40>
}
    80003250:	02813083          	ld	ra,40(sp)
    80003254:	02013403          	ld	s0,32(sp)
    80003258:	01813483          	ld	s1,24(sp)
    8000325c:	01013903          	ld	s2,16(sp)
    80003260:	00813983          	ld	s3,8(sp)
    80003264:	00013a03          	ld	s4,0(sp)
    80003268:	03010113          	addi	sp,sp,48
    8000326c:	00008067          	ret

0000000080003270 <kexit>:
{
    80003270:	fd010113          	addi	sp,sp,-48
    80003274:	02113423          	sd	ra,40(sp)
    80003278:	02813023          	sd	s0,32(sp)
    8000327c:	00913c23          	sd	s1,24(sp)
    80003280:	01213823          	sd	s2,16(sp)
    80003284:	01313423          	sd	s3,8(sp)
    80003288:	01413023          	sd	s4,0(sp)
    8000328c:	03010413          	addi	s0,sp,48
    80003290:	00050a13          	mv	s4,a0
  struct proc *p = myproc();
    80003294:	fffff097          	auipc	ra,0xfffff
    80003298:	464080e7          	jalr	1124(ra) # 800026f8 <myproc>
    8000329c:	00050993          	mv	s3,a0
  if(p == initproc)
    800032a0:	00007797          	auipc	a5,0x7
    800032a4:	7107b783          	ld	a5,1808(a5) # 8000a9b0 <initproc>
    800032a8:	0d050493          	addi	s1,a0,208
    800032ac:	15050913          	addi	s2,a0,336
    800032b0:	02a79463          	bne	a5,a0,800032d8 <kexit+0x68>
    panic("init exiting");
    800032b4:	00007517          	auipc	a0,0x7
    800032b8:	0a450513          	addi	a0,a0,164 # 8000a358 <digits+0x320>
    800032bc:	ffffd097          	auipc	ra,0xffffd
    800032c0:	7c4080e7          	jalr	1988(ra) # 80000a80 <panic>
      fileclose(f);
    800032c4:	00003097          	auipc	ra,0x3
    800032c8:	260080e7          	jalr	608(ra) # 80006524 <fileclose>
      p->ofile[fd] = 0;
    800032cc:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800032d0:	00848493          	addi	s1,s1,8
    800032d4:	01248863          	beq	s1,s2,800032e4 <kexit+0x74>
    if(p->ofile[fd]){
    800032d8:	0004b503          	ld	a0,0(s1)
    800032dc:	fe0514e3          	bnez	a0,800032c4 <kexit+0x54>
    800032e0:	ff1ff06f          	j	800032d0 <kexit+0x60>
  begin_op();
    800032e4:	00003097          	auipc	ra,0x3
    800032e8:	bc4080e7          	jalr	-1084(ra) # 80005ea8 <begin_op>
  iput(p->cwd);
    800032ec:	1509b503          	ld	a0,336(s3)
    800032f0:	00002097          	auipc	ra,0x2
    800032f4:	e18080e7          	jalr	-488(ra) # 80005108 <iput>
  end_op();
    800032f8:	00003097          	auipc	ra,0x3
    800032fc:	c64080e7          	jalr	-924(ra) # 80005f5c <end_op>
  p->cwd = 0;
    80003300:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80003304:	0000f497          	auipc	s1,0xf
    80003308:	7cc48493          	addi	s1,s1,1996 # 80012ad0 <wait_lock>
    8000330c:	00048513          	mv	a0,s1
    80003310:	ffffe097          	auipc	ra,0xffffe
    80003314:	d88080e7          	jalr	-632(ra) # 80001098 <acquire>
  reparent(p);
    80003318:	00098513          	mv	a0,s3
    8000331c:	00000097          	auipc	ra,0x0
    80003320:	ed0080e7          	jalr	-304(ra) # 800031ec <reparent>
  wakeup(p->parent);
    80003324:	0389b503          	ld	a0,56(s3)
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	e18080e7          	jalr	-488(ra) # 80003140 <wakeup>
  acquire(&p->lock);
    80003330:	00098513          	mv	a0,s3
    80003334:	ffffe097          	auipc	ra,0xffffe
    80003338:	d64080e7          	jalr	-668(ra) # 80001098 <acquire>
  p->xstate = status;
    8000333c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80003340:	00500793          	li	a5,5
    80003344:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80003348:	00048513          	mv	a0,s1
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	e44080e7          	jalr	-444(ra) # 80001190 <release>
  sched();
    80003354:	00000097          	auipc	ra,0x0
    80003358:	be4080e7          	jalr	-1052(ra) # 80002f38 <sched>
  panic("zombie exit");
    8000335c:	00007517          	auipc	a0,0x7
    80003360:	00c50513          	addi	a0,a0,12 # 8000a368 <digits+0x330>
    80003364:	ffffd097          	auipc	ra,0xffffd
    80003368:	71c080e7          	jalr	1820(ra) # 80000a80 <panic>

000000008000336c <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    8000336c:	fd010113          	addi	sp,sp,-48
    80003370:	02113423          	sd	ra,40(sp)
    80003374:	02813023          	sd	s0,32(sp)
    80003378:	00913c23          	sd	s1,24(sp)
    8000337c:	01213823          	sd	s2,16(sp)
    80003380:	01313423          	sd	s3,8(sp)
    80003384:	03010413          	addi	s0,sp,48
    80003388:	00050913          	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000338c:	00010497          	auipc	s1,0x10
    80003390:	b5c48493          	addi	s1,s1,-1188 # 80012ee8 <proc>
    80003394:	00015997          	auipc	s3,0x15
    80003398:	55498993          	addi	s3,s3,1364 # 800188e8 <tickslock>
    acquire(&p->lock);
    8000339c:	00048513          	mv	a0,s1
    800033a0:	ffffe097          	auipc	ra,0xffffe
    800033a4:	cf8080e7          	jalr	-776(ra) # 80001098 <acquire>
    if(p->pid == pid){
    800033a8:	0304a783          	lw	a5,48(s1)
    800033ac:	03278063          	beq	a5,s2,800033cc <kkill+0x60>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800033b0:	00048513          	mv	a0,s1
    800033b4:	ffffe097          	auipc	ra,0xffffe
    800033b8:	ddc080e7          	jalr	-548(ra) # 80001190 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800033bc:	16848493          	addi	s1,s1,360
    800033c0:	fd349ee3          	bne	s1,s3,8000339c <kkill+0x30>
  }
  return -1;
    800033c4:	fff00513          	li	a0,-1
    800033c8:	0280006f          	j	800033f0 <kkill+0x84>
      p->killed = 1;
    800033cc:	00100793          	li	a5,1
    800033d0:	02f4a423          	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800033d4:	0184a703          	lw	a4,24(s1)
    800033d8:	00200793          	li	a5,2
    800033dc:	02f70863          	beq	a4,a5,8000340c <kkill+0xa0>
      release(&p->lock);
    800033e0:	00048513          	mv	a0,s1
    800033e4:	ffffe097          	auipc	ra,0xffffe
    800033e8:	dac080e7          	jalr	-596(ra) # 80001190 <release>
      return 0;
    800033ec:	00000513          	li	a0,0
}
    800033f0:	02813083          	ld	ra,40(sp)
    800033f4:	02013403          	ld	s0,32(sp)
    800033f8:	01813483          	ld	s1,24(sp)
    800033fc:	01013903          	ld	s2,16(sp)
    80003400:	00813983          	ld	s3,8(sp)
    80003404:	03010113          	addi	sp,sp,48
    80003408:	00008067          	ret
        p->state = RUNNABLE;
    8000340c:	00300793          	li	a5,3
    80003410:	00f4ac23          	sw	a5,24(s1)
    80003414:	fcdff06f          	j	800033e0 <kkill+0x74>

0000000080003418 <setkilled>:

void
setkilled(struct proc *p)
{
    80003418:	fe010113          	addi	sp,sp,-32
    8000341c:	00113c23          	sd	ra,24(sp)
    80003420:	00813823          	sd	s0,16(sp)
    80003424:	00913423          	sd	s1,8(sp)
    80003428:	02010413          	addi	s0,sp,32
    8000342c:	00050493          	mv	s1,a0
  acquire(&p->lock);
    80003430:	ffffe097          	auipc	ra,0xffffe
    80003434:	c68080e7          	jalr	-920(ra) # 80001098 <acquire>
  p->killed = 1;
    80003438:	00100793          	li	a5,1
    8000343c:	02f4a423          	sw	a5,40(s1)
  release(&p->lock);
    80003440:	00048513          	mv	a0,s1
    80003444:	ffffe097          	auipc	ra,0xffffe
    80003448:	d4c080e7          	jalr	-692(ra) # 80001190 <release>
}
    8000344c:	01813083          	ld	ra,24(sp)
    80003450:	01013403          	ld	s0,16(sp)
    80003454:	00813483          	ld	s1,8(sp)
    80003458:	02010113          	addi	sp,sp,32
    8000345c:	00008067          	ret

0000000080003460 <killed>:

int
killed(struct proc *p)
{
    80003460:	fe010113          	addi	sp,sp,-32
    80003464:	00113c23          	sd	ra,24(sp)
    80003468:	00813823          	sd	s0,16(sp)
    8000346c:	00913423          	sd	s1,8(sp)
    80003470:	01213023          	sd	s2,0(sp)
    80003474:	02010413          	addi	s0,sp,32
    80003478:	00050493          	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000347c:	ffffe097          	auipc	ra,0xffffe
    80003480:	c1c080e7          	jalr	-996(ra) # 80001098 <acquire>
  k = p->killed;
    80003484:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80003488:	00048513          	mv	a0,s1
    8000348c:	ffffe097          	auipc	ra,0xffffe
    80003490:	d04080e7          	jalr	-764(ra) # 80001190 <release>
  return k;
}
    80003494:	00090513          	mv	a0,s2
    80003498:	01813083          	ld	ra,24(sp)
    8000349c:	01013403          	ld	s0,16(sp)
    800034a0:	00813483          	ld	s1,8(sp)
    800034a4:	00013903          	ld	s2,0(sp)
    800034a8:	02010113          	addi	sp,sp,32
    800034ac:	00008067          	ret

00000000800034b0 <kwait>:
{
    800034b0:	fb010113          	addi	sp,sp,-80
    800034b4:	04113423          	sd	ra,72(sp)
    800034b8:	04813023          	sd	s0,64(sp)
    800034bc:	02913c23          	sd	s1,56(sp)
    800034c0:	03213823          	sd	s2,48(sp)
    800034c4:	03313423          	sd	s3,40(sp)
    800034c8:	03413023          	sd	s4,32(sp)
    800034cc:	01513c23          	sd	s5,24(sp)
    800034d0:	01613823          	sd	s6,16(sp)
    800034d4:	01713423          	sd	s7,8(sp)
    800034d8:	01813023          	sd	s8,0(sp)
    800034dc:	05010413          	addi	s0,sp,80
    800034e0:	00050b13          	mv	s6,a0
  struct proc *p = myproc();
    800034e4:	fffff097          	auipc	ra,0xfffff
    800034e8:	214080e7          	jalr	532(ra) # 800026f8 <myproc>
    800034ec:	00050913          	mv	s2,a0
  acquire(&wait_lock);
    800034f0:	0000f517          	auipc	a0,0xf
    800034f4:	5e050513          	addi	a0,a0,1504 # 80012ad0 <wait_lock>
    800034f8:	ffffe097          	auipc	ra,0xffffe
    800034fc:	ba0080e7          	jalr	-1120(ra) # 80001098 <acquire>
    havekids = 0;
    80003500:	00000b93          	li	s7,0
        if(pp->state == ZOMBIE){
    80003504:	00500a13          	li	s4,5
        havekids = 1;
    80003508:	00100a93          	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000350c:	00015997          	auipc	s3,0x15
    80003510:	3dc98993          	addi	s3,s3,988 # 800188e8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80003514:	0000fc17          	auipc	s8,0xf
    80003518:	5bcc0c13          	addi	s8,s8,1468 # 80012ad0 <wait_lock>
    havekids = 0;
    8000351c:	000b8713          	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80003520:	00010497          	auipc	s1,0x10
    80003524:	9c848493          	addi	s1,s1,-1592 # 80012ee8 <proc>
    80003528:	0800006f          	j	800035a8 <kwait+0xf8>
          pid = pp->pid;
    8000352c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80003530:	020b0063          	beqz	s6,80003550 <kwait+0xa0>
    80003534:	00400693          	li	a3,4
    80003538:	02c48613          	addi	a2,s1,44
    8000353c:	000b0593          	mv	a1,s6
    80003540:	05093503          	ld	a0,80(s2)
    80003544:	fffff097          	auipc	ra,0xfffff
    80003548:	d40080e7          	jalr	-704(ra) # 80002284 <copyout>
    8000354c:	02054863          	bltz	a0,8000357c <kwait+0xcc>
          freeproc(pp);
    80003550:	00048513          	mv	a0,s1
    80003554:	fffff097          	auipc	ra,0xfffff
    80003558:	4b8080e7          	jalr	1208(ra) # 80002a0c <freeproc>
          release(&pp->lock);
    8000355c:	00048513          	mv	a0,s1
    80003560:	ffffe097          	auipc	ra,0xffffe
    80003564:	c30080e7          	jalr	-976(ra) # 80001190 <release>
          release(&wait_lock);
    80003568:	0000f517          	auipc	a0,0xf
    8000356c:	56850513          	addi	a0,a0,1384 # 80012ad0 <wait_lock>
    80003570:	ffffe097          	auipc	ra,0xffffe
    80003574:	c20080e7          	jalr	-992(ra) # 80001190 <release>
          return pid;
    80003578:	0880006f          	j	80003600 <kwait+0x150>
            release(&pp->lock);
    8000357c:	00048513          	mv	a0,s1
    80003580:	ffffe097          	auipc	ra,0xffffe
    80003584:	c10080e7          	jalr	-1008(ra) # 80001190 <release>
            release(&wait_lock);
    80003588:	0000f517          	auipc	a0,0xf
    8000358c:	54850513          	addi	a0,a0,1352 # 80012ad0 <wait_lock>
    80003590:	ffffe097          	auipc	ra,0xffffe
    80003594:	c00080e7          	jalr	-1024(ra) # 80001190 <release>
            return -1;
    80003598:	fff00993          	li	s3,-1
    8000359c:	0640006f          	j	80003600 <kwait+0x150>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800035a0:	16848493          	addi	s1,s1,360
    800035a4:	03348a63          	beq	s1,s3,800035d8 <kwait+0x128>
      if(pp->parent == p){
    800035a8:	0384b783          	ld	a5,56(s1)
    800035ac:	ff279ae3          	bne	a5,s2,800035a0 <kwait+0xf0>
        acquire(&pp->lock);
    800035b0:	00048513          	mv	a0,s1
    800035b4:	ffffe097          	auipc	ra,0xffffe
    800035b8:	ae4080e7          	jalr	-1308(ra) # 80001098 <acquire>
        if(pp->state == ZOMBIE){
    800035bc:	0184a783          	lw	a5,24(s1)
    800035c0:	f74786e3          	beq	a5,s4,8000352c <kwait+0x7c>
        release(&pp->lock);
    800035c4:	00048513          	mv	a0,s1
    800035c8:	ffffe097          	auipc	ra,0xffffe
    800035cc:	bc8080e7          	jalr	-1080(ra) # 80001190 <release>
        havekids = 1;
    800035d0:	000a8713          	mv	a4,s5
    800035d4:	fcdff06f          	j	800035a0 <kwait+0xf0>
    if(!havekids || killed(p)){
    800035d8:	00070a63          	beqz	a4,800035ec <kwait+0x13c>
    800035dc:	00090513          	mv	a0,s2
    800035e0:	00000097          	auipc	ra,0x0
    800035e4:	e80080e7          	jalr	-384(ra) # 80003460 <killed>
    800035e8:	04050663          	beqz	a0,80003634 <kwait+0x184>
      release(&wait_lock);
    800035ec:	0000f517          	auipc	a0,0xf
    800035f0:	4e450513          	addi	a0,a0,1252 # 80012ad0 <wait_lock>
    800035f4:	ffffe097          	auipc	ra,0xffffe
    800035f8:	b9c080e7          	jalr	-1124(ra) # 80001190 <release>
      return -1;
    800035fc:	fff00993          	li	s3,-1
}
    80003600:	00098513          	mv	a0,s3
    80003604:	04813083          	ld	ra,72(sp)
    80003608:	04013403          	ld	s0,64(sp)
    8000360c:	03813483          	ld	s1,56(sp)
    80003610:	03013903          	ld	s2,48(sp)
    80003614:	02813983          	ld	s3,40(sp)
    80003618:	02013a03          	ld	s4,32(sp)
    8000361c:	01813a83          	ld	s5,24(sp)
    80003620:	01013b03          	ld	s6,16(sp)
    80003624:	00813b83          	ld	s7,8(sp)
    80003628:	00013c03          	ld	s8,0(sp)
    8000362c:	05010113          	addi	sp,sp,80
    80003630:	00008067          	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80003634:	000c0593          	mv	a1,s8
    80003638:	00090513          	mv	a0,s2
    8000363c:	00000097          	auipc	ra,0x0
    80003640:	a74080e7          	jalr	-1420(ra) # 800030b0 <sleep>
    havekids = 0;
    80003644:	ed9ff06f          	j	8000351c <kwait+0x6c>

0000000080003648 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80003648:	fd010113          	addi	sp,sp,-48
    8000364c:	02113423          	sd	ra,40(sp)
    80003650:	02813023          	sd	s0,32(sp)
    80003654:	00913c23          	sd	s1,24(sp)
    80003658:	01213823          	sd	s2,16(sp)
    8000365c:	01313423          	sd	s3,8(sp)
    80003660:	01413023          	sd	s4,0(sp)
    80003664:	03010413          	addi	s0,sp,48
    80003668:	00050493          	mv	s1,a0
    8000366c:	00058913          	mv	s2,a1
    80003670:	00060993          	mv	s3,a2
    80003674:	00068a13          	mv	s4,a3
  struct proc *p = myproc();
    80003678:	fffff097          	auipc	ra,0xfffff
    8000367c:	080080e7          	jalr	128(ra) # 800026f8 <myproc>
  if(user_dst){
    80003680:	02048e63          	beqz	s1,800036bc <either_copyout+0x74>
    return copyout(p->pagetable, dst, src, len);
    80003684:	000a0693          	mv	a3,s4
    80003688:	00098613          	mv	a2,s3
    8000368c:	00090593          	mv	a1,s2
    80003690:	05053503          	ld	a0,80(a0)
    80003694:	fffff097          	auipc	ra,0xfffff
    80003698:	bf0080e7          	jalr	-1040(ra) # 80002284 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000369c:	02813083          	ld	ra,40(sp)
    800036a0:	02013403          	ld	s0,32(sp)
    800036a4:	01813483          	ld	s1,24(sp)
    800036a8:	01013903          	ld	s2,16(sp)
    800036ac:	00813983          	ld	s3,8(sp)
    800036b0:	00013a03          	ld	s4,0(sp)
    800036b4:	03010113          	addi	sp,sp,48
    800036b8:	00008067          	ret
    memmove((char *)dst, src, len);
    800036bc:	000a061b          	sext.w	a2,s4
    800036c0:	00098593          	mv	a1,s3
    800036c4:	00090513          	mv	a0,s2
    800036c8:	ffffe097          	auipc	ra,0xffffe
    800036cc:	bbc080e7          	jalr	-1092(ra) # 80001284 <memmove>
    return 0;
    800036d0:	00048513          	mv	a0,s1
    800036d4:	fc9ff06f          	j	8000369c <either_copyout+0x54>

00000000800036d8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800036d8:	fd010113          	addi	sp,sp,-48
    800036dc:	02113423          	sd	ra,40(sp)
    800036e0:	02813023          	sd	s0,32(sp)
    800036e4:	00913c23          	sd	s1,24(sp)
    800036e8:	01213823          	sd	s2,16(sp)
    800036ec:	01313423          	sd	s3,8(sp)
    800036f0:	01413023          	sd	s4,0(sp)
    800036f4:	03010413          	addi	s0,sp,48
    800036f8:	00050913          	mv	s2,a0
    800036fc:	00058493          	mv	s1,a1
    80003700:	00060993          	mv	s3,a2
    80003704:	00068a13          	mv	s4,a3
  struct proc *p = myproc();
    80003708:	fffff097          	auipc	ra,0xfffff
    8000370c:	ff0080e7          	jalr	-16(ra) # 800026f8 <myproc>
  if(user_src){
    80003710:	02048e63          	beqz	s1,8000374c <either_copyin+0x74>
    return copyin(p->pagetable, dst, src, len);
    80003714:	000a0693          	mv	a3,s4
    80003718:	00098613          	mv	a2,s3
    8000371c:	00090593          	mv	a1,s2
    80003720:	05053503          	ld	a0,80(a0)
    80003724:	fffff097          	auipc	ra,0xfffff
    80003728:	cc8080e7          	jalr	-824(ra) # 800023ec <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000372c:	02813083          	ld	ra,40(sp)
    80003730:	02013403          	ld	s0,32(sp)
    80003734:	01813483          	ld	s1,24(sp)
    80003738:	01013903          	ld	s2,16(sp)
    8000373c:	00813983          	ld	s3,8(sp)
    80003740:	00013a03          	ld	s4,0(sp)
    80003744:	03010113          	addi	sp,sp,48
    80003748:	00008067          	ret
    memmove(dst, (char*)src, len);
    8000374c:	000a061b          	sext.w	a2,s4
    80003750:	00098593          	mv	a1,s3
    80003754:	00090513          	mv	a0,s2
    80003758:	ffffe097          	auipc	ra,0xffffe
    8000375c:	b2c080e7          	jalr	-1236(ra) # 80001284 <memmove>
    return 0;
    80003760:	00048513          	mv	a0,s1
    80003764:	fc9ff06f          	j	8000372c <either_copyin+0x54>

0000000080003768 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80003768:	fb010113          	addi	sp,sp,-80
    8000376c:	04113423          	sd	ra,72(sp)
    80003770:	04813023          	sd	s0,64(sp)
    80003774:	02913c23          	sd	s1,56(sp)
    80003778:	03213823          	sd	s2,48(sp)
    8000377c:	03313423          	sd	s3,40(sp)
    80003780:	03413023          	sd	s4,32(sp)
    80003784:	01513c23          	sd	s5,24(sp)
    80003788:	01613823          	sd	s6,16(sp)
    8000378c:	01713423          	sd	s7,8(sp)
    80003790:	05010413          	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80003794:	00007517          	auipc	a0,0x7
    80003798:	a7c50513          	addi	a0,a0,-1412 # 8000a210 <digits+0x1d8>
    8000379c:	ffffd097          	auipc	ra,0xffffd
    800037a0:	f0c080e7          	jalr	-244(ra) # 800006a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800037a4:	00010497          	auipc	s1,0x10
    800037a8:	89c48493          	addi	s1,s1,-1892 # 80013040 <proc+0x158>
    800037ac:	00015917          	auipc	s2,0x15
    800037b0:	29490913          	addi	s2,s2,660 # 80018a40 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800037b4:	00500b13          	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800037b8:	00007997          	auipc	s3,0x7
    800037bc:	bc098993          	addi	s3,s3,-1088 # 8000a378 <digits+0x340>
    printf("%d %s %s", p->pid, state, p->name);
    800037c0:	00007a97          	auipc	s5,0x7
    800037c4:	bc0a8a93          	addi	s5,s5,-1088 # 8000a380 <digits+0x348>
    printf("\n");
    800037c8:	00007a17          	auipc	s4,0x7
    800037cc:	a48a0a13          	addi	s4,s4,-1464 # 8000a210 <digits+0x1d8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800037d0:	00007b97          	auipc	s7,0x7
    800037d4:	bf0b8b93          	addi	s7,s7,-1040 # 8000a3c0 <states.0>
    800037d8:	0280006f          	j	80003800 <procdump+0x98>
    printf("%d %s %s", p->pid, state, p->name);
    800037dc:	ed86a583          	lw	a1,-296(a3)
    800037e0:	000a8513          	mv	a0,s5
    800037e4:	ffffd097          	auipc	ra,0xffffd
    800037e8:	ec4080e7          	jalr	-316(ra) # 800006a8 <printf>
    printf("\n");
    800037ec:	000a0513          	mv	a0,s4
    800037f0:	ffffd097          	auipc	ra,0xffffd
    800037f4:	eb8080e7          	jalr	-328(ra) # 800006a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800037f8:	16848493          	addi	s1,s1,360
    800037fc:	03248a63          	beq	s1,s2,80003830 <procdump+0xc8>
    if(p->state == UNUSED)
    80003800:	00048693          	mv	a3,s1
    80003804:	ec04a783          	lw	a5,-320(s1)
    80003808:	fe0788e3          	beqz	a5,800037f8 <procdump+0x90>
      state = "???";
    8000380c:	00098613          	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003810:	fcfb66e3          	bltu	s6,a5,800037dc <procdump+0x74>
    80003814:	02079713          	slli	a4,a5,0x20
    80003818:	01d75793          	srli	a5,a4,0x1d
    8000381c:	00fb87b3          	add	a5,s7,a5
    80003820:	0007b603          	ld	a2,0(a5)
    80003824:	fa061ce3          	bnez	a2,800037dc <procdump+0x74>
      state = "???";
    80003828:	00098613          	mv	a2,s3
    8000382c:	fb1ff06f          	j	800037dc <procdump+0x74>
  }
}
    80003830:	04813083          	ld	ra,72(sp)
    80003834:	04013403          	ld	s0,64(sp)
    80003838:	03813483          	ld	s1,56(sp)
    8000383c:	03013903          	ld	s2,48(sp)
    80003840:	02813983          	ld	s3,40(sp)
    80003844:	02013a03          	ld	s4,32(sp)
    80003848:	01813a83          	ld	s5,24(sp)
    8000384c:	01013b03          	ld	s6,16(sp)
    80003850:	00813b83          	ld	s7,8(sp)
    80003854:	05010113          	addi	sp,sp,80
    80003858:	00008067          	ret

000000008000385c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000385c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80003860:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80003864:	00853823          	sd	s0,16(a0)
        sd s1, 24(a0)
    80003868:	00953c23          	sd	s1,24(a0)
        sd s2, 32(a0)
    8000386c:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80003870:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80003874:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80003878:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000387c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80003880:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80003884:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80003888:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000388c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80003890:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80003894:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80003898:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000389c:	0105b403          	ld	s0,16(a1)
        ld s1, 24(a1)
    800038a0:	0185b483          	ld	s1,24(a1)
        ld s2, 32(a1)
    800038a4:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800038a8:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800038ac:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800038b0:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800038b4:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800038b8:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800038bc:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800038c0:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800038c4:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800038c8:	0685bd83          	ld	s11,104(a1)
        
        ret
    800038cc:	00008067          	ret

00000000800038d0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800038d0:	ff010113          	addi	sp,sp,-16
    800038d4:	00113423          	sd	ra,8(sp)
    800038d8:	00813023          	sd	s0,0(sp)
    800038dc:	01010413          	addi	s0,sp,16
  initlock(&tickslock, "time");
    800038e0:	00007597          	auipc	a1,0x7
    800038e4:	b1058593          	addi	a1,a1,-1264 # 8000a3f0 <states.0+0x30>
    800038e8:	00015517          	auipc	a0,0x15
    800038ec:	00050513          	mv	a0,a0
    800038f0:	ffffd097          	auipc	ra,0xffffd
    800038f4:	6c4080e7          	jalr	1732(ra) # 80000fb4 <initlock>
}
    800038f8:	00813083          	ld	ra,8(sp)
    800038fc:	00013403          	ld	s0,0(sp)
    80003900:	01010113          	addi	sp,sp,16
    80003904:	00008067          	ret

0000000080003908 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80003908:	ff010113          	addi	sp,sp,-16
    8000390c:	00813423          	sd	s0,8(sp)
    80003910:	01010413          	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003914:	00005797          	auipc	a5,0x5
    80003918:	9bc78793          	addi	a5,a5,-1604 # 800082d0 <kernelvec>
    8000391c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003920:	00813403          	ld	s0,8(sp)
    80003924:	01010113          	addi	sp,sp,16
    80003928:	00008067          	ret

000000008000392c <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000392c:	ff010113          	addi	sp,sp,-16
    80003930:	00113423          	sd	ra,8(sp)
    80003934:	00813023          	sd	s0,0(sp)
    80003938:	01010413          	addi	s0,sp,16
  struct proc *p = myproc();
    8000393c:	fffff097          	auipc	ra,0xfffff
    80003940:	dbc080e7          	jalr	-580(ra) # 800026f8 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003944:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003948:	ffd7f793          	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000394c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80003950:	04000737          	lui	a4,0x4000
    80003954:	00005797          	auipc	a5,0x5
    80003958:	6ac78793          	addi	a5,a5,1708 # 80009000 <_trampoline>
    8000395c:	00005697          	auipc	a3,0x5
    80003960:	6a468693          	addi	a3,a3,1700 # 80009000 <_trampoline>
    80003964:	40d787b3          	sub	a5,a5,a3
    80003968:	fff70713          	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000396c:	00c71713          	slli	a4,a4,0xc
    80003970:	00e787b3          	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003974:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80003978:	05853783          	ld	a5,88(a0) # 80018940 <bcache+0x40>
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000397c:	18002773          	csrr	a4,satp
    80003980:	00e7b023          	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80003984:	05853703          	ld	a4,88(a0)
    80003988:	04053783          	ld	a5,64(a0)
    8000398c:	000016b7          	lui	a3,0x1
    80003990:	00d787b3          	add	a5,a5,a3
    80003994:	00f73423          	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80003998:	05853783          	ld	a5,88(a0)
    8000399c:	00000717          	auipc	a4,0x0
    800039a0:	17c70713          	addi	a4,a4,380 # 80003b18 <usertrap>
    800039a4:	00e7b823          	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800039a8:	05853783          	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800039ac:	00020713          	mv	a4,tp
    800039b0:	02e7b023          	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800039b4:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800039b8:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800039bc:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800039c0:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800039c4:	05853783          	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800039c8:	0187b783          	ld	a5,24(a5)
    800039cc:	14179073          	csrw	sepc,a5
}
    800039d0:	00813083          	ld	ra,8(sp)
    800039d4:	00013403          	ld	s0,0(sp)
    800039d8:	01010113          	addi	sp,sp,16
    800039dc:	00008067          	ret

00000000800039e0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800039e0:	fe010113          	addi	sp,sp,-32
    800039e4:	00113c23          	sd	ra,24(sp)
    800039e8:	00813823          	sd	s0,16(sp)
    800039ec:	00913423          	sd	s1,8(sp)
    800039f0:	02010413          	addi	s0,sp,32
  if(cpuid() == 0){
    800039f4:	fffff097          	auipc	ra,0xfffff
    800039f8:	cb4080e7          	jalr	-844(ra) # 800026a8 <cpuid>
    800039fc:	00050c63          	beqz	a0,80003a14 <clockintr+0x34>

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
//  w_stimecmp(r_time() + 1000000);
} 
    80003a00:	01813083          	ld	ra,24(sp)
    80003a04:	01013403          	ld	s0,16(sp)
    80003a08:	00813483          	ld	s1,8(sp)
    80003a0c:	02010113          	addi	sp,sp,32
    80003a10:	00008067          	ret
    acquire(&tickslock);
    80003a14:	00015497          	auipc	s1,0x15
    80003a18:	ed448493          	addi	s1,s1,-300 # 800188e8 <tickslock>
    80003a1c:	00048513          	mv	a0,s1
    80003a20:	ffffd097          	auipc	ra,0xffffd
    80003a24:	678080e7          	jalr	1656(ra) # 80001098 <acquire>
    ticks++;
    80003a28:	00007517          	auipc	a0,0x7
    80003a2c:	f9050513          	addi	a0,a0,-112 # 8000a9b8 <ticks>
    80003a30:	00052783          	lw	a5,0(a0)
    80003a34:	0017879b          	addiw	a5,a5,1
    80003a38:	00f52023          	sw	a5,0(a0)
    wakeup(&ticks);
    80003a3c:	fffff097          	auipc	ra,0xfffff
    80003a40:	704080e7          	jalr	1796(ra) # 80003140 <wakeup>
    release(&tickslock);
    80003a44:	00048513          	mv	a0,s1
    80003a48:	ffffd097          	auipc	ra,0xffffd
    80003a4c:	748080e7          	jalr	1864(ra) # 80001190 <release>
} 
    80003a50:	fb1ff06f          	j	80003a00 <clockintr+0x20>

0000000080003a54 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80003a54:	fe010113          	addi	sp,sp,-32
    80003a58:	00113c23          	sd	ra,24(sp)
    80003a5c:	00813823          	sd	s0,16(sp)
    80003a60:	00913423          	sd	s1,8(sp)
    80003a64:	02010413          	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003a68:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80003a6c:	fff00793          	li	a5,-1
    80003a70:	03f79793          	slli	a5,a5,0x3f
    80003a74:	00978793          	addi	a5,a5,9
    80003a78:	02f70663          	beq	a4,a5,80003aa4 <devintr+0x50>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80003a7c:	fff00793          	li	a5,-1
    80003a80:	03f79793          	slli	a5,a5,0x3f
    80003a84:	00578793          	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80003a88:	00000513          	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80003a8c:	06f70e63          	beq	a4,a5,80003b08 <devintr+0xb4>
  }
}
    80003a90:	01813083          	ld	ra,24(sp)
    80003a94:	01013403          	ld	s0,16(sp)
    80003a98:	00813483          	ld	s1,8(sp)
    80003a9c:	02010113          	addi	sp,sp,32
    80003aa0:	00008067          	ret
    int irq = plic_claim();
    80003aa4:	00005097          	auipc	ra,0x5
    80003aa8:	940080e7          	jalr	-1728(ra) # 800083e4 <plic_claim>
    80003aac:	00050493          	mv	s1,a0
    if(irq == UART0_IRQ){
    80003ab0:	00a00793          	li	a5,10
    80003ab4:	02f50e63          	beq	a0,a5,80003af0 <devintr+0x9c>
    } else if(irq == VIRTIO0_IRQ){
    80003ab8:	00100793          	li	a5,1
    80003abc:	04f50063          	beq	a0,a5,80003afc <devintr+0xa8>
    return 1;
    80003ac0:	00100513          	li	a0,1
    } else if(irq){
    80003ac4:	fc0486e3          	beqz	s1,80003a90 <devintr+0x3c>
      printf("unexpected interrupt irq=%d\n", irq);
    80003ac8:	00048593          	mv	a1,s1
    80003acc:	00007517          	auipc	a0,0x7
    80003ad0:	92c50513          	addi	a0,a0,-1748 # 8000a3f8 <states.0+0x38>
    80003ad4:	ffffd097          	auipc	ra,0xffffd
    80003ad8:	bd4080e7          	jalr	-1068(ra) # 800006a8 <printf>
      plic_complete(irq);
    80003adc:	00048513          	mv	a0,s1
    80003ae0:	00005097          	auipc	ra,0x5
    80003ae4:	93c080e7          	jalr	-1732(ra) # 8000841c <plic_complete>
    return 1;
    80003ae8:	00100513          	li	a0,1
    80003aec:	fa5ff06f          	j	80003a90 <devintr+0x3c>
      uartintr();
    80003af0:	ffffd097          	auipc	ra,0xffffd
    80003af4:	23c080e7          	jalr	572(ra) # 80000d2c <uartintr>
    80003af8:	fe5ff06f          	j	80003adc <devintr+0x88>
      virtio_disk_intr();
    80003afc:	00005097          	auipc	ra,0x5
    80003b00:	f5c080e7          	jalr	-164(ra) # 80008a58 <virtio_disk_intr>
    80003b04:	fd9ff06f          	j	80003adc <devintr+0x88>
    clockintr();
    80003b08:	00000097          	auipc	ra,0x0
    80003b0c:	ed8080e7          	jalr	-296(ra) # 800039e0 <clockintr>
    return 2;
    80003b10:	00200513          	li	a0,2
    80003b14:	f7dff06f          	j	80003a90 <devintr+0x3c>

0000000080003b18 <usertrap>:
{
    80003b18:	fe010113          	addi	sp,sp,-32
    80003b1c:	00113c23          	sd	ra,24(sp)
    80003b20:	00813823          	sd	s0,16(sp)
    80003b24:	00913423          	sd	s1,8(sp)
    80003b28:	01213023          	sd	s2,0(sp)
    80003b2c:	02010413          	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003b30:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003b34:	1007f793          	andi	a5,a5,256
    80003b38:	08079e63          	bnez	a5,80003bd4 <usertrap+0xbc>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003b3c:	00004797          	auipc	a5,0x4
    80003b40:	79478793          	addi	a5,a5,1940 # 800082d0 <kernelvec>
    80003b44:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003b48:	fffff097          	auipc	ra,0xfffff
    80003b4c:	bb0080e7          	jalr	-1104(ra) # 800026f8 <myproc>
    80003b50:	00050493          	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003b54:	05853783          	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003b58:	14102773          	csrr	a4,sepc
    80003b5c:	00e7bc23          	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003b60:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003b64:	00800793          	li	a5,8
    80003b68:	06f70e63          	beq	a4,a5,80003be4 <usertrap+0xcc>
  } else if((which_dev = devintr()) != 0){
    80003b6c:	00000097          	auipc	ra,0x0
    80003b70:	ee8080e7          	jalr	-280(ra) # 80003a54 <devintr>
    80003b74:	00050913          	mv	s2,a0
    80003b78:	10051a63          	bnez	a0,80003c8c <usertrap+0x174>
    80003b7c:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80003b80:	00f00793          	li	a5,15
    80003b84:	0ef70263          	beq	a4,a5,80003c68 <usertrap+0x150>
    80003b88:	14202773          	csrr	a4,scause
    80003b8c:	00d00793          	li	a5,13
    80003b90:	0cf70c63          	beq	a4,a5,80003c68 <usertrap+0x150>
    80003b94:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80003b98:	0304a603          	lw	a2,48(s1)
    80003b9c:	00007517          	auipc	a0,0x7
    80003ba0:	89c50513          	addi	a0,a0,-1892 # 8000a438 <states.0+0x78>
    80003ba4:	ffffd097          	auipc	ra,0xffffd
    80003ba8:	b04080e7          	jalr	-1276(ra) # 800006a8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003bac:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003bb0:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80003bb4:	00007517          	auipc	a0,0x7
    80003bb8:	8b450513          	addi	a0,a0,-1868 # 8000a468 <states.0+0xa8>
    80003bbc:	ffffd097          	auipc	ra,0xffffd
    80003bc0:	aec080e7          	jalr	-1300(ra) # 800006a8 <printf>
    setkilled(p);
    80003bc4:	00048513          	mv	a0,s1
    80003bc8:	00000097          	auipc	ra,0x0
    80003bcc:	850080e7          	jalr	-1968(ra) # 80003418 <setkilled>
    80003bd0:	0440006f          	j	80003c14 <usertrap+0xfc>
    panic("usertrap: not from user mode");
    80003bd4:	00007517          	auipc	a0,0x7
    80003bd8:	84450513          	addi	a0,a0,-1980 # 8000a418 <states.0+0x58>
    80003bdc:	ffffd097          	auipc	ra,0xffffd
    80003be0:	ea4080e7          	jalr	-348(ra) # 80000a80 <panic>
    if(killed(p))
    80003be4:	00000097          	auipc	ra,0x0
    80003be8:	87c080e7          	jalr	-1924(ra) # 80003460 <killed>
    80003bec:	06051663          	bnez	a0,80003c58 <usertrap+0x140>
    p->trapframe->epc += 4;
    80003bf0:	0584b703          	ld	a4,88(s1)
    80003bf4:	01873783          	ld	a5,24(a4)
    80003bf8:	00478793          	addi	a5,a5,4
    80003bfc:	00f73c23          	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003c00:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003c04:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003c08:	10079073          	csrw	sstatus,a5
    syscall();
    80003c0c:	00000097          	auipc	ra,0x0
    80003c10:	400080e7          	jalr	1024(ra) # 8000400c <syscall>
  if(killed(p))
    80003c14:	00048513          	mv	a0,s1
    80003c18:	00000097          	auipc	ra,0x0
    80003c1c:	848080e7          	jalr	-1976(ra) # 80003460 <killed>
    80003c20:	08051063          	bnez	a0,80003ca0 <usertrap+0x188>
  prepare_return();
    80003c24:	00000097          	auipc	ra,0x0
    80003c28:	d08080e7          	jalr	-760(ra) # 8000392c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80003c2c:	0504b503          	ld	a0,80(s1)
    80003c30:	00c55513          	srli	a0,a0,0xc
    80003c34:	fff00793          	li	a5,-1
    80003c38:	03f79793          	slli	a5,a5,0x3f
    80003c3c:	00f56533          	or	a0,a0,a5
}
    80003c40:	01813083          	ld	ra,24(sp)
    80003c44:	01013403          	ld	s0,16(sp)
    80003c48:	00813483          	ld	s1,8(sp)
    80003c4c:	00013903          	ld	s2,0(sp)
    80003c50:	02010113          	addi	sp,sp,32
    80003c54:	00008067          	ret
      kexit(-1);
    80003c58:	fff00513          	li	a0,-1
    80003c5c:	fffff097          	auipc	ra,0xfffff
    80003c60:	614080e7          	jalr	1556(ra) # 80003270 <kexit>
    80003c64:	f8dff06f          	j	80003bf0 <usertrap+0xd8>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003c68:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003c6c:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80003c70:	ff360613          	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80003c74:	00163613          	seqz	a2,a2
    80003c78:	0504b503          	ld	a0,80(s1)
    80003c7c:	ffffe097          	auipc	ra,0xffffe
    80003c80:	52c080e7          	jalr	1324(ra) # 800021a8 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80003c84:	f80518e3          	bnez	a0,80003c14 <usertrap+0xfc>
    80003c88:	f0dff06f          	j	80003b94 <usertrap+0x7c>
  if(killed(p))
    80003c8c:	00048513          	mv	a0,s1
    80003c90:	fffff097          	auipc	ra,0xfffff
    80003c94:	7d0080e7          	jalr	2000(ra) # 80003460 <killed>
    80003c98:	00050c63          	beqz	a0,80003cb0 <usertrap+0x198>
    80003c9c:	0080006f          	j	80003ca4 <usertrap+0x18c>
    80003ca0:	00000913          	li	s2,0
    kexit(-1);
    80003ca4:	fff00513          	li	a0,-1
    80003ca8:	fffff097          	auipc	ra,0xfffff
    80003cac:	5c8080e7          	jalr	1480(ra) # 80003270 <kexit>
  if(which_dev == 2)
    80003cb0:	00200793          	li	a5,2
    80003cb4:	f6f918e3          	bne	s2,a5,80003c24 <usertrap+0x10c>
    yield();
    80003cb8:	fffff097          	auipc	ra,0xfffff
    80003cbc:	3a0080e7          	jalr	928(ra) # 80003058 <yield>
    80003cc0:	f65ff06f          	j	80003c24 <usertrap+0x10c>

0000000080003cc4 <kerneltrap>:
{
    80003cc4:	fd010113          	addi	sp,sp,-48
    80003cc8:	02113423          	sd	ra,40(sp)
    80003ccc:	02813023          	sd	s0,32(sp)
    80003cd0:	00913c23          	sd	s1,24(sp)
    80003cd4:	01213823          	sd	s2,16(sp)
    80003cd8:	01313423          	sd	s3,8(sp)
    80003cdc:	03010413          	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003ce0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003ce4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003ce8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003cec:	1004f793          	andi	a5,s1,256
    80003cf0:	04078463          	beqz	a5,80003d38 <kerneltrap+0x74>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003cf4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003cf8:	0027f793          	andi	a5,a5,2
  if(intr_get() != 0)
    80003cfc:	04079663          	bnez	a5,80003d48 <kerneltrap+0x84>
  if((which_dev = devintr()) == 0){
    80003d00:	00000097          	auipc	ra,0x0
    80003d04:	d54080e7          	jalr	-684(ra) # 80003a54 <devintr>
    80003d08:	04050863          	beqz	a0,80003d58 <kerneltrap+0x94>
  if(which_dev == 2 && myproc() != 0)
    80003d0c:	00200793          	li	a5,2
    80003d10:	06f50a63          	beq	a0,a5,80003d84 <kerneltrap+0xc0>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003d14:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003d18:	10049073          	csrw	sstatus,s1
}
    80003d1c:	02813083          	ld	ra,40(sp)
    80003d20:	02013403          	ld	s0,32(sp)
    80003d24:	01813483          	ld	s1,24(sp)
    80003d28:	01013903          	ld	s2,16(sp)
    80003d2c:	00813983          	ld	s3,8(sp)
    80003d30:	03010113          	addi	sp,sp,48
    80003d34:	00008067          	ret
    panic("kerneltrap: not from supervisor mode");
    80003d38:	00006517          	auipc	a0,0x6
    80003d3c:	75850513          	addi	a0,a0,1880 # 8000a490 <states.0+0xd0>
    80003d40:	ffffd097          	auipc	ra,0xffffd
    80003d44:	d40080e7          	jalr	-704(ra) # 80000a80 <panic>
    panic("kerneltrap: interrupts enabled");
    80003d48:	00006517          	auipc	a0,0x6
    80003d4c:	77050513          	addi	a0,a0,1904 # 8000a4b8 <states.0+0xf8>
    80003d50:	ffffd097          	auipc	ra,0xffffd
    80003d54:	d30080e7          	jalr	-720(ra) # 80000a80 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003d58:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003d5c:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80003d60:	00098593          	mv	a1,s3
    80003d64:	00006517          	auipc	a0,0x6
    80003d68:	77450513          	addi	a0,a0,1908 # 8000a4d8 <states.0+0x118>
    80003d6c:	ffffd097          	auipc	ra,0xffffd
    80003d70:	93c080e7          	jalr	-1732(ra) # 800006a8 <printf>
    panic("kerneltrap");
    80003d74:	00006517          	auipc	a0,0x6
    80003d78:	78c50513          	addi	a0,a0,1932 # 8000a500 <states.0+0x140>
    80003d7c:	ffffd097          	auipc	ra,0xffffd
    80003d80:	d04080e7          	jalr	-764(ra) # 80000a80 <panic>
  if(which_dev == 2 && myproc() != 0)
    80003d84:	fffff097          	auipc	ra,0xfffff
    80003d88:	974080e7          	jalr	-1676(ra) # 800026f8 <myproc>
    80003d8c:	f80504e3          	beqz	a0,80003d14 <kerneltrap+0x50>
    yield();
    80003d90:	fffff097          	auipc	ra,0xfffff
    80003d94:	2c8080e7          	jalr	712(ra) # 80003058 <yield>
    80003d98:	f7dff06f          	j	80003d14 <kerneltrap+0x50>

0000000080003d9c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003d9c:	fe010113          	addi	sp,sp,-32
    80003da0:	00113c23          	sd	ra,24(sp)
    80003da4:	00813823          	sd	s0,16(sp)
    80003da8:	00913423          	sd	s1,8(sp)
    80003dac:	02010413          	addi	s0,sp,32
    80003db0:	00050493          	mv	s1,a0
  struct proc *p = myproc();
    80003db4:	fffff097          	auipc	ra,0xfffff
    80003db8:	944080e7          	jalr	-1724(ra) # 800026f8 <myproc>
  switch (n) {
    80003dbc:	00500793          	li	a5,5
    80003dc0:	0697ec63          	bltu	a5,s1,80003e38 <argraw+0x9c>
    80003dc4:	00249493          	slli	s1,s1,0x2
    80003dc8:	00006717          	auipc	a4,0x6
    80003dcc:	77070713          	addi	a4,a4,1904 # 8000a538 <states.0+0x178>
    80003dd0:	00e484b3          	add	s1,s1,a4
    80003dd4:	0004a783          	lw	a5,0(s1)
    80003dd8:	00e787b3          	add	a5,a5,a4
    80003ddc:	00078067          	jr	a5
  case 0:
    return p->trapframe->a0;
    80003de0:	05853783          	ld	a5,88(a0)
    80003de4:	0707b503          	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003de8:	01813083          	ld	ra,24(sp)
    80003dec:	01013403          	ld	s0,16(sp)
    80003df0:	00813483          	ld	s1,8(sp)
    80003df4:	02010113          	addi	sp,sp,32
    80003df8:	00008067          	ret
    return p->trapframe->a1;
    80003dfc:	05853783          	ld	a5,88(a0)
    80003e00:	0787b503          	ld	a0,120(a5)
    80003e04:	fe5ff06f          	j	80003de8 <argraw+0x4c>
    return p->trapframe->a2;
    80003e08:	05853783          	ld	a5,88(a0)
    80003e0c:	0807b503          	ld	a0,128(a5)
    80003e10:	fd9ff06f          	j	80003de8 <argraw+0x4c>
    return p->trapframe->a3;
    80003e14:	05853783          	ld	a5,88(a0)
    80003e18:	0887b503          	ld	a0,136(a5)
    80003e1c:	fcdff06f          	j	80003de8 <argraw+0x4c>
    return p->trapframe->a4;
    80003e20:	05853783          	ld	a5,88(a0)
    80003e24:	0907b503          	ld	a0,144(a5)
    80003e28:	fc1ff06f          	j	80003de8 <argraw+0x4c>
    return p->trapframe->a5;
    80003e2c:	05853783          	ld	a5,88(a0)
    80003e30:	0987b503          	ld	a0,152(a5)
    80003e34:	fb5ff06f          	j	80003de8 <argraw+0x4c>
  panic("argraw");
    80003e38:	00006517          	auipc	a0,0x6
    80003e3c:	6d850513          	addi	a0,a0,1752 # 8000a510 <states.0+0x150>
    80003e40:	ffffd097          	auipc	ra,0xffffd
    80003e44:	c40080e7          	jalr	-960(ra) # 80000a80 <panic>

0000000080003e48 <fetchaddr>:
{
    80003e48:	fe010113          	addi	sp,sp,-32
    80003e4c:	00113c23          	sd	ra,24(sp)
    80003e50:	00813823          	sd	s0,16(sp)
    80003e54:	00913423          	sd	s1,8(sp)
    80003e58:	01213023          	sd	s2,0(sp)
    80003e5c:	02010413          	addi	s0,sp,32
    80003e60:	00050493          	mv	s1,a0
    80003e64:	00058913          	mv	s2,a1
  struct proc *p = myproc();
    80003e68:	fffff097          	auipc	ra,0xfffff
    80003e6c:	890080e7          	jalr	-1904(ra) # 800026f8 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003e70:	04853783          	ld	a5,72(a0)
    80003e74:	04f4f263          	bgeu	s1,a5,80003eb8 <fetchaddr+0x70>
    80003e78:	00848713          	addi	a4,s1,8
    80003e7c:	04e7e263          	bltu	a5,a4,80003ec0 <fetchaddr+0x78>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003e80:	00800693          	li	a3,8
    80003e84:	00048613          	mv	a2,s1
    80003e88:	00090593          	mv	a1,s2
    80003e8c:	05053503          	ld	a0,80(a0)
    80003e90:	ffffe097          	auipc	ra,0xffffe
    80003e94:	55c080e7          	jalr	1372(ra) # 800023ec <copyin>
    80003e98:	00a03533          	snez	a0,a0
    80003e9c:	40a00533          	neg	a0,a0
}
    80003ea0:	01813083          	ld	ra,24(sp)
    80003ea4:	01013403          	ld	s0,16(sp)
    80003ea8:	00813483          	ld	s1,8(sp)
    80003eac:	00013903          	ld	s2,0(sp)
    80003eb0:	02010113          	addi	sp,sp,32
    80003eb4:	00008067          	ret
    return -1;
    80003eb8:	fff00513          	li	a0,-1
    80003ebc:	fe5ff06f          	j	80003ea0 <fetchaddr+0x58>
    80003ec0:	fff00513          	li	a0,-1
    80003ec4:	fddff06f          	j	80003ea0 <fetchaddr+0x58>

0000000080003ec8 <fetchstr>:
{
    80003ec8:	fd010113          	addi	sp,sp,-48
    80003ecc:	02113423          	sd	ra,40(sp)
    80003ed0:	02813023          	sd	s0,32(sp)
    80003ed4:	00913c23          	sd	s1,24(sp)
    80003ed8:	01213823          	sd	s2,16(sp)
    80003edc:	01313423          	sd	s3,8(sp)
    80003ee0:	03010413          	addi	s0,sp,48
    80003ee4:	00050913          	mv	s2,a0
    80003ee8:	00058493          	mv	s1,a1
    80003eec:	00060993          	mv	s3,a2
  struct proc *p = myproc();
    80003ef0:	fffff097          	auipc	ra,0xfffff
    80003ef4:	808080e7          	jalr	-2040(ra) # 800026f8 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003ef8:	00098693          	mv	a3,s3
    80003efc:	00090613          	mv	a2,s2
    80003f00:	00048593          	mv	a1,s1
    80003f04:	05053503          	ld	a0,80(a0)
    80003f08:	ffffe097          	auipc	ra,0xffffe
    80003f0c:	144080e7          	jalr	324(ra) # 8000204c <copyinstr>
    80003f10:	02054663          	bltz	a0,80003f3c <fetchstr+0x74>
  return strlen(buf);
    80003f14:	00048513          	mv	a0,s1
    80003f18:	ffffd097          	auipc	ra,0xffffd
    80003f1c:	524080e7          	jalr	1316(ra) # 8000143c <strlen>
}
    80003f20:	02813083          	ld	ra,40(sp)
    80003f24:	02013403          	ld	s0,32(sp)
    80003f28:	01813483          	ld	s1,24(sp)
    80003f2c:	01013903          	ld	s2,16(sp)
    80003f30:	00813983          	ld	s3,8(sp)
    80003f34:	03010113          	addi	sp,sp,48
    80003f38:	00008067          	ret
    return -1;
    80003f3c:	fff00513          	li	a0,-1
    80003f40:	fe1ff06f          	j	80003f20 <fetchstr+0x58>

0000000080003f44 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80003f44:	fe010113          	addi	sp,sp,-32
    80003f48:	00113c23          	sd	ra,24(sp)
    80003f4c:	00813823          	sd	s0,16(sp)
    80003f50:	00913423          	sd	s1,8(sp)
    80003f54:	02010413          	addi	s0,sp,32
    80003f58:	00058493          	mv	s1,a1
  *ip = argraw(n);
    80003f5c:	00000097          	auipc	ra,0x0
    80003f60:	e40080e7          	jalr	-448(ra) # 80003d9c <argraw>
    80003f64:	00a4a023          	sw	a0,0(s1)
}
    80003f68:	01813083          	ld	ra,24(sp)
    80003f6c:	01013403          	ld	s0,16(sp)
    80003f70:	00813483          	ld	s1,8(sp)
    80003f74:	02010113          	addi	sp,sp,32
    80003f78:	00008067          	ret

0000000080003f7c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80003f7c:	fe010113          	addi	sp,sp,-32
    80003f80:	00113c23          	sd	ra,24(sp)
    80003f84:	00813823          	sd	s0,16(sp)
    80003f88:	00913423          	sd	s1,8(sp)
    80003f8c:	02010413          	addi	s0,sp,32
    80003f90:	00058493          	mv	s1,a1
  *ip = argraw(n);
    80003f94:	00000097          	auipc	ra,0x0
    80003f98:	e08080e7          	jalr	-504(ra) # 80003d9c <argraw>
    80003f9c:	00a4b023          	sd	a0,0(s1)
}
    80003fa0:	01813083          	ld	ra,24(sp)
    80003fa4:	01013403          	ld	s0,16(sp)
    80003fa8:	00813483          	ld	s1,8(sp)
    80003fac:	02010113          	addi	sp,sp,32
    80003fb0:	00008067          	ret

0000000080003fb4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003fb4:	fd010113          	addi	sp,sp,-48
    80003fb8:	02113423          	sd	ra,40(sp)
    80003fbc:	02813023          	sd	s0,32(sp)
    80003fc0:	00913c23          	sd	s1,24(sp)
    80003fc4:	01213823          	sd	s2,16(sp)
    80003fc8:	03010413          	addi	s0,sp,48
    80003fcc:	00058493          	mv	s1,a1
    80003fd0:	00060913          	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80003fd4:	fd840593          	addi	a1,s0,-40
    80003fd8:	00000097          	auipc	ra,0x0
    80003fdc:	fa4080e7          	jalr	-92(ra) # 80003f7c <argaddr>
  return fetchstr(addr, buf, max);
    80003fe0:	00090613          	mv	a2,s2
    80003fe4:	00048593          	mv	a1,s1
    80003fe8:	fd843503          	ld	a0,-40(s0)
    80003fec:	00000097          	auipc	ra,0x0
    80003ff0:	edc080e7          	jalr	-292(ra) # 80003ec8 <fetchstr>
}
    80003ff4:	02813083          	ld	ra,40(sp)
    80003ff8:	02013403          	ld	s0,32(sp)
    80003ffc:	01813483          	ld	s1,24(sp)
    80004000:	01013903          	ld	s2,16(sp)
    80004004:	03010113          	addi	sp,sp,48
    80004008:	00008067          	ret

000000008000400c <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    8000400c:	fe010113          	addi	sp,sp,-32
    80004010:	00113c23          	sd	ra,24(sp)
    80004014:	00813823          	sd	s0,16(sp)
    80004018:	00913423          	sd	s1,8(sp)
    8000401c:	01213023          	sd	s2,0(sp)
    80004020:	02010413          	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80004024:	ffffe097          	auipc	ra,0xffffe
    80004028:	6d4080e7          	jalr	1748(ra) # 800026f8 <myproc>
    8000402c:	00050493          	mv	s1,a0

  num = p->trapframe->a7;
    80004030:	05853903          	ld	s2,88(a0)
    80004034:	0a893783          	ld	a5,168(s2)
    80004038:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000403c:	fff7879b          	addiw	a5,a5,-1
    80004040:	01400713          	li	a4,20
    80004044:	02f76463          	bltu	a4,a5,8000406c <syscall+0x60>
    80004048:	00369713          	slli	a4,a3,0x3
    8000404c:	00006797          	auipc	a5,0x6
    80004050:	50478793          	addi	a5,a5,1284 # 8000a550 <syscalls>
    80004054:	00e787b3          	add	a5,a5,a4
    80004058:	0007b783          	ld	a5,0(a5)
    8000405c:	00078863          	beqz	a5,8000406c <syscall+0x60>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80004060:	000780e7          	jalr	a5
    80004064:	06a93823          	sd	a0,112(s2)
    80004068:	0280006f          	j	80004090 <syscall+0x84>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000406c:	15848613          	addi	a2,s1,344
    80004070:	0304a583          	lw	a1,48(s1)
    80004074:	00006517          	auipc	a0,0x6
    80004078:	4a450513          	addi	a0,a0,1188 # 8000a518 <states.0+0x158>
    8000407c:	ffffc097          	auipc	ra,0xffffc
    80004080:	62c080e7          	jalr	1580(ra) # 800006a8 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80004084:	0584b783          	ld	a5,88(s1)
    80004088:	fff00713          	li	a4,-1
    8000408c:	06e7b823          	sd	a4,112(a5)
  }
}
    80004090:	01813083          	ld	ra,24(sp)
    80004094:	01013403          	ld	s0,16(sp)
    80004098:	00813483          	ld	s1,8(sp)
    8000409c:	00013903          	ld	s2,0(sp)
    800040a0:	02010113          	addi	sp,sp,32
    800040a4:	00008067          	ret

00000000800040a8 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800040a8:	fe010113          	addi	sp,sp,-32
    800040ac:	00113c23          	sd	ra,24(sp)
    800040b0:	00813823          	sd	s0,16(sp)
    800040b4:	02010413          	addi	s0,sp,32
  int n;
  argint(0, &n);
    800040b8:	fec40593          	addi	a1,s0,-20
    800040bc:	00000513          	li	a0,0
    800040c0:	00000097          	auipc	ra,0x0
    800040c4:	e84080e7          	jalr	-380(ra) # 80003f44 <argint>
  kexit(n);
    800040c8:	fec42503          	lw	a0,-20(s0)
    800040cc:	fffff097          	auipc	ra,0xfffff
    800040d0:	1a4080e7          	jalr	420(ra) # 80003270 <kexit>
  return 0;  // not reached
}
    800040d4:	00000513          	li	a0,0
    800040d8:	01813083          	ld	ra,24(sp)
    800040dc:	01013403          	ld	s0,16(sp)
    800040e0:	02010113          	addi	sp,sp,32
    800040e4:	00008067          	ret

00000000800040e8 <sys_getpid>:

uint64
sys_getpid(void)
{
    800040e8:	ff010113          	addi	sp,sp,-16
    800040ec:	00113423          	sd	ra,8(sp)
    800040f0:	00813023          	sd	s0,0(sp)
    800040f4:	01010413          	addi	s0,sp,16
  return myproc()->pid;
    800040f8:	ffffe097          	auipc	ra,0xffffe
    800040fc:	600080e7          	jalr	1536(ra) # 800026f8 <myproc>
}
    80004100:	03052503          	lw	a0,48(a0)
    80004104:	00813083          	ld	ra,8(sp)
    80004108:	00013403          	ld	s0,0(sp)
    8000410c:	01010113          	addi	sp,sp,16
    80004110:	00008067          	ret

0000000080004114 <sys_fork>:

uint64
sys_fork(void)
{
    80004114:	ff010113          	addi	sp,sp,-16
    80004118:	00113423          	sd	ra,8(sp)
    8000411c:	00813023          	sd	s0,0(sp)
    80004120:	01010413          	addi	s0,sp,16
  return kfork();
    80004124:	fffff097          	auipc	ra,0xfffff
    80004128:	b78080e7          	jalr	-1160(ra) # 80002c9c <kfork>
}
    8000412c:	00813083          	ld	ra,8(sp)
    80004130:	00013403          	ld	s0,0(sp)
    80004134:	01010113          	addi	sp,sp,16
    80004138:	00008067          	ret

000000008000413c <sys_wait>:

uint64
sys_wait(void)
{
    8000413c:	fe010113          	addi	sp,sp,-32
    80004140:	00113c23          	sd	ra,24(sp)
    80004144:	00813823          	sd	s0,16(sp)
    80004148:	02010413          	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000414c:	fe840593          	addi	a1,s0,-24
    80004150:	00000513          	li	a0,0
    80004154:	00000097          	auipc	ra,0x0
    80004158:	e28080e7          	jalr	-472(ra) # 80003f7c <argaddr>
  return kwait(p);
    8000415c:	fe843503          	ld	a0,-24(s0)
    80004160:	fffff097          	auipc	ra,0xfffff
    80004164:	350080e7          	jalr	848(ra) # 800034b0 <kwait>
}
    80004168:	01813083          	ld	ra,24(sp)
    8000416c:	01013403          	ld	s0,16(sp)
    80004170:	02010113          	addi	sp,sp,32
    80004174:	00008067          	ret

0000000080004178 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80004178:	fd010113          	addi	sp,sp,-48
    8000417c:	02113423          	sd	ra,40(sp)
    80004180:	02813023          	sd	s0,32(sp)
    80004184:	00913c23          	sd	s1,24(sp)
    80004188:	03010413          	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    8000418c:	fd840593          	addi	a1,s0,-40
    80004190:	00000513          	li	a0,0
    80004194:	00000097          	auipc	ra,0x0
    80004198:	db0080e7          	jalr	-592(ra) # 80003f44 <argint>
  argint(1, &t);
    8000419c:	fdc40593          	addi	a1,s0,-36
    800041a0:	00100513          	li	a0,1
    800041a4:	00000097          	auipc	ra,0x0
    800041a8:	da0080e7          	jalr	-608(ra) # 80003f44 <argint>
  addr = myproc()->sz;
    800041ac:	ffffe097          	auipc	ra,0xffffe
    800041b0:	54c080e7          	jalr	1356(ra) # 800026f8 <myproc>
    800041b4:	04853483          	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800041b8:	fdc42703          	lw	a4,-36(s0)
    800041bc:	00100793          	li	a5,1
    800041c0:	02f70863          	beq	a4,a5,800041f0 <sys_sbrk+0x78>
    800041c4:	fd842783          	lw	a5,-40(s0)
    800041c8:	0207c463          	bltz	a5,800041f0 <sys_sbrk+0x78>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800041cc:	009787b3          	add	a5,a5,s1
    800041d0:	0497e863          	bltu	a5,s1,80004220 <sys_sbrk+0xa8>
      return -1;
    myproc()->sz += n;
    800041d4:	ffffe097          	auipc	ra,0xffffe
    800041d8:	524080e7          	jalr	1316(ra) # 800026f8 <myproc>
    800041dc:	fd842703          	lw	a4,-40(s0)
    800041e0:	04853783          	ld	a5,72(a0)
    800041e4:	00e787b3          	add	a5,a5,a4
    800041e8:	04f53423          	sd	a5,72(a0)
    800041ec:	0140006f          	j	80004200 <sys_sbrk+0x88>
    if(growproc(n) < 0) {
    800041f0:	fd842503          	lw	a0,-40(s0)
    800041f4:	fffff097          	auipc	ra,0xfffff
    800041f8:	a18080e7          	jalr	-1512(ra) # 80002c0c <growproc>
    800041fc:	00054e63          	bltz	a0,80004218 <sys_sbrk+0xa0>
  }
  return addr;
}
    80004200:	00048513          	mv	a0,s1
    80004204:	02813083          	ld	ra,40(sp)
    80004208:	02013403          	ld	s0,32(sp)
    8000420c:	01813483          	ld	s1,24(sp)
    80004210:	03010113          	addi	sp,sp,48
    80004214:	00008067          	ret
      return -1;
    80004218:	fff00493          	li	s1,-1
    8000421c:	fe5ff06f          	j	80004200 <sys_sbrk+0x88>
      return -1;
    80004220:	fff00493          	li	s1,-1
    80004224:	fddff06f          	j	80004200 <sys_sbrk+0x88>

0000000080004228 <sys_pause>:

uint64
sys_pause(void)
{
    80004228:	fc010113          	addi	sp,sp,-64
    8000422c:	02113c23          	sd	ra,56(sp)
    80004230:	02813823          	sd	s0,48(sp)
    80004234:	02913423          	sd	s1,40(sp)
    80004238:	03213023          	sd	s2,32(sp)
    8000423c:	01313c23          	sd	s3,24(sp)
    80004240:	04010413          	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80004244:	fcc40593          	addi	a1,s0,-52
    80004248:	00000513          	li	a0,0
    8000424c:	00000097          	auipc	ra,0x0
    80004250:	cf8080e7          	jalr	-776(ra) # 80003f44 <argint>
  if(n < 0)
    80004254:	fcc42783          	lw	a5,-52(s0)
    80004258:	0807cc63          	bltz	a5,800042f0 <sys_pause+0xc8>
    n = 0;
  acquire(&tickslock);
    8000425c:	00014517          	auipc	a0,0x14
    80004260:	68c50513          	addi	a0,a0,1676 # 800188e8 <tickslock>
    80004264:	ffffd097          	auipc	ra,0xffffd
    80004268:	e34080e7          	jalr	-460(ra) # 80001098 <acquire>
  ticks0 = ticks;
    8000426c:	00006917          	auipc	s2,0x6
    80004270:	74c92903          	lw	s2,1868(s2) # 8000a9b8 <ticks>
  while(ticks - ticks0 < n){
    80004274:	fcc42783          	lw	a5,-52(s0)
    80004278:	04078463          	beqz	a5,800042c0 <sys_pause+0x98>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000427c:	00014997          	auipc	s3,0x14
    80004280:	66c98993          	addi	s3,s3,1644 # 800188e8 <tickslock>
    80004284:	00006497          	auipc	s1,0x6
    80004288:	73448493          	addi	s1,s1,1844 # 8000a9b8 <ticks>
    if(killed(myproc())){
    8000428c:	ffffe097          	auipc	ra,0xffffe
    80004290:	46c080e7          	jalr	1132(ra) # 800026f8 <myproc>
    80004294:	fffff097          	auipc	ra,0xfffff
    80004298:	1cc080e7          	jalr	460(ra) # 80003460 <killed>
    8000429c:	04051e63          	bnez	a0,800042f8 <sys_pause+0xd0>
    sleep(&ticks, &tickslock);
    800042a0:	00098593          	mv	a1,s3
    800042a4:	00048513          	mv	a0,s1
    800042a8:	fffff097          	auipc	ra,0xfffff
    800042ac:	e08080e7          	jalr	-504(ra) # 800030b0 <sleep>
  while(ticks - ticks0 < n){
    800042b0:	0004a783          	lw	a5,0(s1)
    800042b4:	412787bb          	subw	a5,a5,s2
    800042b8:	fcc42703          	lw	a4,-52(s0)
    800042bc:	fce7e8e3          	bltu	a5,a4,8000428c <sys_pause+0x64>
  }
  release(&tickslock);
    800042c0:	00014517          	auipc	a0,0x14
    800042c4:	62850513          	addi	a0,a0,1576 # 800188e8 <tickslock>
    800042c8:	ffffd097          	auipc	ra,0xffffd
    800042cc:	ec8080e7          	jalr	-312(ra) # 80001190 <release>
  return 0;
    800042d0:	00000513          	li	a0,0
}
    800042d4:	03813083          	ld	ra,56(sp)
    800042d8:	03013403          	ld	s0,48(sp)
    800042dc:	02813483          	ld	s1,40(sp)
    800042e0:	02013903          	ld	s2,32(sp)
    800042e4:	01813983          	ld	s3,24(sp)
    800042e8:	04010113          	addi	sp,sp,64
    800042ec:	00008067          	ret
    n = 0;
    800042f0:	fc042623          	sw	zero,-52(s0)
    800042f4:	f69ff06f          	j	8000425c <sys_pause+0x34>
      release(&tickslock);
    800042f8:	00014517          	auipc	a0,0x14
    800042fc:	5f050513          	addi	a0,a0,1520 # 800188e8 <tickslock>
    80004300:	ffffd097          	auipc	ra,0xffffd
    80004304:	e90080e7          	jalr	-368(ra) # 80001190 <release>
      return -1;
    80004308:	fff00513          	li	a0,-1
    8000430c:	fc9ff06f          	j	800042d4 <sys_pause+0xac>

0000000080004310 <sys_kill>:

uint64
sys_kill(void)
{
    80004310:	fe010113          	addi	sp,sp,-32
    80004314:	00113c23          	sd	ra,24(sp)
    80004318:	00813823          	sd	s0,16(sp)
    8000431c:	02010413          	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80004320:	fec40593          	addi	a1,s0,-20
    80004324:	00000513          	li	a0,0
    80004328:	00000097          	auipc	ra,0x0
    8000432c:	c1c080e7          	jalr	-996(ra) # 80003f44 <argint>
  return kkill(pid);
    80004330:	fec42503          	lw	a0,-20(s0)
    80004334:	fffff097          	auipc	ra,0xfffff
    80004338:	038080e7          	jalr	56(ra) # 8000336c <kkill>
}
    8000433c:	01813083          	ld	ra,24(sp)
    80004340:	01013403          	ld	s0,16(sp)
    80004344:	02010113          	addi	sp,sp,32
    80004348:	00008067          	ret

000000008000434c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000434c:	fe010113          	addi	sp,sp,-32
    80004350:	00113c23          	sd	ra,24(sp)
    80004354:	00813823          	sd	s0,16(sp)
    80004358:	00913423          	sd	s1,8(sp)
    8000435c:	02010413          	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80004360:	00014517          	auipc	a0,0x14
    80004364:	58850513          	addi	a0,a0,1416 # 800188e8 <tickslock>
    80004368:	ffffd097          	auipc	ra,0xffffd
    8000436c:	d30080e7          	jalr	-720(ra) # 80001098 <acquire>
  xticks = ticks;
    80004370:	00006497          	auipc	s1,0x6
    80004374:	6484a483          	lw	s1,1608(s1) # 8000a9b8 <ticks>
  release(&tickslock);
    80004378:	00014517          	auipc	a0,0x14
    8000437c:	57050513          	addi	a0,a0,1392 # 800188e8 <tickslock>
    80004380:	ffffd097          	auipc	ra,0xffffd
    80004384:	e10080e7          	jalr	-496(ra) # 80001190 <release>
  return xticks;
}
    80004388:	02049513          	slli	a0,s1,0x20
    8000438c:	02055513          	srli	a0,a0,0x20
    80004390:	01813083          	ld	ra,24(sp)
    80004394:	01013403          	ld	s0,16(sp)
    80004398:	00813483          	ld	s1,8(sp)
    8000439c:	02010113          	addi	sp,sp,32
    800043a0:	00008067          	ret

00000000800043a4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800043a4:	fd010113          	addi	sp,sp,-48
    800043a8:	02113423          	sd	ra,40(sp)
    800043ac:	02813023          	sd	s0,32(sp)
    800043b0:	00913c23          	sd	s1,24(sp)
    800043b4:	01213823          	sd	s2,16(sp)
    800043b8:	01313423          	sd	s3,8(sp)
    800043bc:	01413023          	sd	s4,0(sp)
    800043c0:	03010413          	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800043c4:	00006597          	auipc	a1,0x6
    800043c8:	23c58593          	addi	a1,a1,572 # 8000a600 <syscalls+0xb0>
    800043cc:	00014517          	auipc	a0,0x14
    800043d0:	53450513          	addi	a0,a0,1332 # 80018900 <bcache>
    800043d4:	ffffd097          	auipc	ra,0xffffd
    800043d8:	be0080e7          	jalr	-1056(ra) # 80000fb4 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800043dc:	0001c797          	auipc	a5,0x1c
    800043e0:	52478793          	addi	a5,a5,1316 # 80020900 <bcache+0x8000>
    800043e4:	0001c717          	auipc	a4,0x1c
    800043e8:	78470713          	addi	a4,a4,1924 # 80020b68 <bcache+0x8268>
    800043ec:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800043f0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800043f4:	00014497          	auipc	s1,0x14
    800043f8:	52448493          	addi	s1,s1,1316 # 80018918 <bcache+0x18>
    b->next = bcache.head.next;
    800043fc:	00078913          	mv	s2,a5
    b->prev = &bcache.head;
    80004400:	00070993          	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80004404:	00006a17          	auipc	s4,0x6
    80004408:	204a0a13          	addi	s4,s4,516 # 8000a608 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000440c:	2b893783          	ld	a5,696(s2)
    80004410:	04f4b823          	sd	a5,80(s1)
    b->prev = &bcache.head;
    80004414:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80004418:	000a0593          	mv	a1,s4
    8000441c:	01048513          	addi	a0,s1,16
    80004420:	00002097          	auipc	ra,0x2
    80004424:	e08080e7          	jalr	-504(ra) # 80006228 <initsleeplock>
    bcache.head.next->prev = b;
    80004428:	2b893783          	ld	a5,696(s2)
    8000442c:	0497b423          	sd	s1,72(a5)
    bcache.head.next = b;
    80004430:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004434:	45848493          	addi	s1,s1,1112
    80004438:	fd349ae3          	bne	s1,s3,8000440c <binit+0x68>
  }
}
    8000443c:	02813083          	ld	ra,40(sp)
    80004440:	02013403          	ld	s0,32(sp)
    80004444:	01813483          	ld	s1,24(sp)
    80004448:	01013903          	ld	s2,16(sp)
    8000444c:	00813983          	ld	s3,8(sp)
    80004450:	00013a03          	ld	s4,0(sp)
    80004454:	03010113          	addi	sp,sp,48
    80004458:	00008067          	ret

000000008000445c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000445c:	fd010113          	addi	sp,sp,-48
    80004460:	02113423          	sd	ra,40(sp)
    80004464:	02813023          	sd	s0,32(sp)
    80004468:	00913c23          	sd	s1,24(sp)
    8000446c:	01213823          	sd	s2,16(sp)
    80004470:	01313423          	sd	s3,8(sp)
    80004474:	03010413          	addi	s0,sp,48
    80004478:	00050913          	mv	s2,a0
    8000447c:	00058993          	mv	s3,a1
  acquire(&bcache.lock);
    80004480:	00014517          	auipc	a0,0x14
    80004484:	48050513          	addi	a0,a0,1152 # 80018900 <bcache>
    80004488:	ffffd097          	auipc	ra,0xffffd
    8000448c:	c10080e7          	jalr	-1008(ra) # 80001098 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80004490:	0001c497          	auipc	s1,0x1c
    80004494:	7284b483          	ld	s1,1832(s1) # 80020bb8 <bcache+0x82b8>
    80004498:	0001c797          	auipc	a5,0x1c
    8000449c:	6d078793          	addi	a5,a5,1744 # 80020b68 <bcache+0x8268>
    800044a0:	04f48863          	beq	s1,a5,800044f0 <bread+0x94>
    800044a4:	00078713          	mv	a4,a5
    800044a8:	00c0006f          	j	800044b4 <bread+0x58>
    800044ac:	0504b483          	ld	s1,80(s1)
    800044b0:	04e48063          	beq	s1,a4,800044f0 <bread+0x94>
    if(b->dev == dev && b->blockno == blockno){
    800044b4:	0084a783          	lw	a5,8(s1)
    800044b8:	ff279ae3          	bne	a5,s2,800044ac <bread+0x50>
    800044bc:	00c4a783          	lw	a5,12(s1)
    800044c0:	ff3796e3          	bne	a5,s3,800044ac <bread+0x50>
      b->refcnt++;
    800044c4:	0404a783          	lw	a5,64(s1)
    800044c8:	0017879b          	addiw	a5,a5,1
    800044cc:	04f4a023          	sw	a5,64(s1)
      release(&bcache.lock);
    800044d0:	00014517          	auipc	a0,0x14
    800044d4:	43050513          	addi	a0,a0,1072 # 80018900 <bcache>
    800044d8:	ffffd097          	auipc	ra,0xffffd
    800044dc:	cb8080e7          	jalr	-840(ra) # 80001190 <release>
      acquiresleep(&b->lock);
    800044e0:	01048513          	addi	a0,s1,16
    800044e4:	00002097          	auipc	ra,0x2
    800044e8:	d9c080e7          	jalr	-612(ra) # 80006280 <acquiresleep>
      return b;
    800044ec:	06c0006f          	j	80004558 <bread+0xfc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800044f0:	0001c497          	auipc	s1,0x1c
    800044f4:	6c04b483          	ld	s1,1728(s1) # 80020bb0 <bcache+0x82b0>
    800044f8:	0001c797          	auipc	a5,0x1c
    800044fc:	67078793          	addi	a5,a5,1648 # 80020b68 <bcache+0x8268>
    80004500:	00f48c63          	beq	s1,a5,80004518 <bread+0xbc>
    80004504:	00078713          	mv	a4,a5
    if(b->refcnt == 0) {
    80004508:	0404a783          	lw	a5,64(s1)
    8000450c:	00078e63          	beqz	a5,80004528 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004510:	0484b483          	ld	s1,72(s1)
    80004514:	fee49ae3          	bne	s1,a4,80004508 <bread+0xac>
  panic("bget: no buffers");
    80004518:	00006517          	auipc	a0,0x6
    8000451c:	0f850513          	addi	a0,a0,248 # 8000a610 <syscalls+0xc0>
    80004520:	ffffc097          	auipc	ra,0xffffc
    80004524:	560080e7          	jalr	1376(ra) # 80000a80 <panic>
      b->dev = dev;
    80004528:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000452c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80004530:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80004534:	00100793          	li	a5,1
    80004538:	04f4a023          	sw	a5,64(s1)
      release(&bcache.lock);
    8000453c:	00014517          	auipc	a0,0x14
    80004540:	3c450513          	addi	a0,a0,964 # 80018900 <bcache>
    80004544:	ffffd097          	auipc	ra,0xffffd
    80004548:	c4c080e7          	jalr	-948(ra) # 80001190 <release>
      acquiresleep(&b->lock);
    8000454c:	01048513          	addi	a0,s1,16
    80004550:	00002097          	auipc	ra,0x2
    80004554:	d30080e7          	jalr	-720(ra) # 80006280 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80004558:	0004a783          	lw	a5,0(s1)
    8000455c:	02078263          	beqz	a5,80004580 <bread+0x124>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80004560:	00048513          	mv	a0,s1
    80004564:	02813083          	ld	ra,40(sp)
    80004568:	02013403          	ld	s0,32(sp)
    8000456c:	01813483          	ld	s1,24(sp)
    80004570:	01013903          	ld	s2,16(sp)
    80004574:	00813983          	ld	s3,8(sp)
    80004578:	03010113          	addi	sp,sp,48
    8000457c:	00008067          	ret
    virtio_disk_rw(b, 0);
    80004580:	00000593          	li	a1,0
    80004584:	00048513          	mv	a0,s1
    80004588:	00004097          	auipc	ra,0x4
    8000458c:	1e4080e7          	jalr	484(ra) # 8000876c <virtio_disk_rw>
    b->valid = 1;
    80004590:	00100793          	li	a5,1
    80004594:	00f4a023          	sw	a5,0(s1)
  return b;
    80004598:	fc9ff06f          	j	80004560 <bread+0x104>

000000008000459c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000459c:	fe010113          	addi	sp,sp,-32
    800045a0:	00113c23          	sd	ra,24(sp)
    800045a4:	00813823          	sd	s0,16(sp)
    800045a8:	00913423          	sd	s1,8(sp)
    800045ac:	02010413          	addi	s0,sp,32
    800045b0:	00050493          	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800045b4:	01050513          	addi	a0,a0,16
    800045b8:	00002097          	auipc	ra,0x2
    800045bc:	db4080e7          	jalr	-588(ra) # 8000636c <holdingsleep>
    800045c0:	02050463          	beqz	a0,800045e8 <bwrite+0x4c>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800045c4:	00100593          	li	a1,1
    800045c8:	00048513          	mv	a0,s1
    800045cc:	00004097          	auipc	ra,0x4
    800045d0:	1a0080e7          	jalr	416(ra) # 8000876c <virtio_disk_rw>
}
    800045d4:	01813083          	ld	ra,24(sp)
    800045d8:	01013403          	ld	s0,16(sp)
    800045dc:	00813483          	ld	s1,8(sp)
    800045e0:	02010113          	addi	sp,sp,32
    800045e4:	00008067          	ret
    panic("bwrite");
    800045e8:	00006517          	auipc	a0,0x6
    800045ec:	04050513          	addi	a0,a0,64 # 8000a628 <syscalls+0xd8>
    800045f0:	ffffc097          	auipc	ra,0xffffc
    800045f4:	490080e7          	jalr	1168(ra) # 80000a80 <panic>

00000000800045f8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800045f8:	fe010113          	addi	sp,sp,-32
    800045fc:	00113c23          	sd	ra,24(sp)
    80004600:	00813823          	sd	s0,16(sp)
    80004604:	00913423          	sd	s1,8(sp)
    80004608:	01213023          	sd	s2,0(sp)
    8000460c:	02010413          	addi	s0,sp,32
    80004610:	00050493          	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004614:	01050913          	addi	s2,a0,16
    80004618:	00090513          	mv	a0,s2
    8000461c:	00002097          	auipc	ra,0x2
    80004620:	d50080e7          	jalr	-688(ra) # 8000636c <holdingsleep>
    80004624:	08050e63          	beqz	a0,800046c0 <brelse+0xc8>
    panic("brelse");

  releasesleep(&b->lock);
    80004628:	00090513          	mv	a0,s2
    8000462c:	00002097          	auipc	ra,0x2
    80004630:	cdc080e7          	jalr	-804(ra) # 80006308 <releasesleep>

  acquire(&bcache.lock);
    80004634:	00014517          	auipc	a0,0x14
    80004638:	2cc50513          	addi	a0,a0,716 # 80018900 <bcache>
    8000463c:	ffffd097          	auipc	ra,0xffffd
    80004640:	a5c080e7          	jalr	-1444(ra) # 80001098 <acquire>
  b->refcnt--;
    80004644:	0404a783          	lw	a5,64(s1)
    80004648:	fff7879b          	addiw	a5,a5,-1
    8000464c:	0007871b          	sext.w	a4,a5
    80004650:	04f4a023          	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80004654:	04071263          	bnez	a4,80004698 <brelse+0xa0>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80004658:	0504b783          	ld	a5,80(s1)
    8000465c:	0484b703          	ld	a4,72(s1)
    80004660:	04e7b423          	sd	a4,72(a5)
    b->prev->next = b->next;
    80004664:	0484b783          	ld	a5,72(s1)
    80004668:	0504b703          	ld	a4,80(s1)
    8000466c:	04e7b823          	sd	a4,80(a5)
    b->next = bcache.head.next;
    80004670:	0001c797          	auipc	a5,0x1c
    80004674:	29078793          	addi	a5,a5,656 # 80020900 <bcache+0x8000>
    80004678:	2b87b703          	ld	a4,696(a5)
    8000467c:	04e4b823          	sd	a4,80(s1)
    b->prev = &bcache.head;
    80004680:	0001c717          	auipc	a4,0x1c
    80004684:	4e870713          	addi	a4,a4,1256 # 80020b68 <bcache+0x8268>
    80004688:	04e4b423          	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000468c:	2b87b703          	ld	a4,696(a5)
    80004690:	04973423          	sd	s1,72(a4)
    bcache.head.next = b;
    80004694:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80004698:	00014517          	auipc	a0,0x14
    8000469c:	26850513          	addi	a0,a0,616 # 80018900 <bcache>
    800046a0:	ffffd097          	auipc	ra,0xffffd
    800046a4:	af0080e7          	jalr	-1296(ra) # 80001190 <release>
}
    800046a8:	01813083          	ld	ra,24(sp)
    800046ac:	01013403          	ld	s0,16(sp)
    800046b0:	00813483          	ld	s1,8(sp)
    800046b4:	00013903          	ld	s2,0(sp)
    800046b8:	02010113          	addi	sp,sp,32
    800046bc:	00008067          	ret
    panic("brelse");
    800046c0:	00006517          	auipc	a0,0x6
    800046c4:	f7050513          	addi	a0,a0,-144 # 8000a630 <syscalls+0xe0>
    800046c8:	ffffc097          	auipc	ra,0xffffc
    800046cc:	3b8080e7          	jalr	952(ra) # 80000a80 <panic>

00000000800046d0 <bpin>:

void
bpin(struct buf *b) {
    800046d0:	fe010113          	addi	sp,sp,-32
    800046d4:	00113c23          	sd	ra,24(sp)
    800046d8:	00813823          	sd	s0,16(sp)
    800046dc:	00913423          	sd	s1,8(sp)
    800046e0:	02010413          	addi	s0,sp,32
    800046e4:	00050493          	mv	s1,a0
  acquire(&bcache.lock);
    800046e8:	00014517          	auipc	a0,0x14
    800046ec:	21850513          	addi	a0,a0,536 # 80018900 <bcache>
    800046f0:	ffffd097          	auipc	ra,0xffffd
    800046f4:	9a8080e7          	jalr	-1624(ra) # 80001098 <acquire>
  b->refcnt++;
    800046f8:	0404a783          	lw	a5,64(s1)
    800046fc:	0017879b          	addiw	a5,a5,1
    80004700:	04f4a023          	sw	a5,64(s1)
  release(&bcache.lock);
    80004704:	00014517          	auipc	a0,0x14
    80004708:	1fc50513          	addi	a0,a0,508 # 80018900 <bcache>
    8000470c:	ffffd097          	auipc	ra,0xffffd
    80004710:	a84080e7          	jalr	-1404(ra) # 80001190 <release>
}
    80004714:	01813083          	ld	ra,24(sp)
    80004718:	01013403          	ld	s0,16(sp)
    8000471c:	00813483          	ld	s1,8(sp)
    80004720:	02010113          	addi	sp,sp,32
    80004724:	00008067          	ret

0000000080004728 <bunpin>:

void
bunpin(struct buf *b) {
    80004728:	fe010113          	addi	sp,sp,-32
    8000472c:	00113c23          	sd	ra,24(sp)
    80004730:	00813823          	sd	s0,16(sp)
    80004734:	00913423          	sd	s1,8(sp)
    80004738:	02010413          	addi	s0,sp,32
    8000473c:	00050493          	mv	s1,a0
  acquire(&bcache.lock);
    80004740:	00014517          	auipc	a0,0x14
    80004744:	1c050513          	addi	a0,a0,448 # 80018900 <bcache>
    80004748:	ffffd097          	auipc	ra,0xffffd
    8000474c:	950080e7          	jalr	-1712(ra) # 80001098 <acquire>
  b->refcnt--;
    80004750:	0404a783          	lw	a5,64(s1)
    80004754:	fff7879b          	addiw	a5,a5,-1
    80004758:	04f4a023          	sw	a5,64(s1)
  release(&bcache.lock);
    8000475c:	00014517          	auipc	a0,0x14
    80004760:	1a450513          	addi	a0,a0,420 # 80018900 <bcache>
    80004764:	ffffd097          	auipc	ra,0xffffd
    80004768:	a2c080e7          	jalr	-1492(ra) # 80001190 <release>
}
    8000476c:	01813083          	ld	ra,24(sp)
    80004770:	01013403          	ld	s0,16(sp)
    80004774:	00813483          	ld	s1,8(sp)
    80004778:	02010113          	addi	sp,sp,32
    8000477c:	00008067          	ret

0000000080004780 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004780:	fe010113          	addi	sp,sp,-32
    80004784:	00113c23          	sd	ra,24(sp)
    80004788:	00813823          	sd	s0,16(sp)
    8000478c:	00913423          	sd	s1,8(sp)
    80004790:	01213023          	sd	s2,0(sp)
    80004794:	02010413          	addi	s0,sp,32
    80004798:	00058493          	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000479c:	00d5d59b          	srliw	a1,a1,0xd
    800047a0:	0001d797          	auipc	a5,0x1d
    800047a4:	83c7a783          	lw	a5,-1988(a5) # 80020fdc <sb+0x1c>
    800047a8:	00f585bb          	addw	a1,a1,a5
    800047ac:	00000097          	auipc	ra,0x0
    800047b0:	cb0080e7          	jalr	-848(ra) # 8000445c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800047b4:	0074f713          	andi	a4,s1,7
    800047b8:	00100793          	li	a5,1
    800047bc:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800047c0:	03349493          	slli	s1,s1,0x33
    800047c4:	0364d493          	srli	s1,s1,0x36
    800047c8:	00950733          	add	a4,a0,s1
    800047cc:	05874703          	lbu	a4,88(a4)
    800047d0:	00e7f6b3          	and	a3,a5,a4
    800047d4:	04068263          	beqz	a3,80004818 <bfree+0x98>
    800047d8:	00050913          	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800047dc:	009504b3          	add	s1,a0,s1
    800047e0:	fff7c793          	not	a5,a5
    800047e4:	00f77733          	and	a4,a4,a5
    800047e8:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800047ec:	00002097          	auipc	ra,0x2
    800047f0:	920080e7          	jalr	-1760(ra) # 8000610c <log_write>
  brelse(bp);
    800047f4:	00090513          	mv	a0,s2
    800047f8:	00000097          	auipc	ra,0x0
    800047fc:	e00080e7          	jalr	-512(ra) # 800045f8 <brelse>
}
    80004800:	01813083          	ld	ra,24(sp)
    80004804:	01013403          	ld	s0,16(sp)
    80004808:	00813483          	ld	s1,8(sp)
    8000480c:	00013903          	ld	s2,0(sp)
    80004810:	02010113          	addi	sp,sp,32
    80004814:	00008067          	ret
    panic("freeing free block");
    80004818:	00006517          	auipc	a0,0x6
    8000481c:	e2050513          	addi	a0,a0,-480 # 8000a638 <syscalls+0xe8>
    80004820:	ffffc097          	auipc	ra,0xffffc
    80004824:	260080e7          	jalr	608(ra) # 80000a80 <panic>

0000000080004828 <balloc>:
{
    80004828:	fa010113          	addi	sp,sp,-96
    8000482c:	04113c23          	sd	ra,88(sp)
    80004830:	04813823          	sd	s0,80(sp)
    80004834:	04913423          	sd	s1,72(sp)
    80004838:	05213023          	sd	s2,64(sp)
    8000483c:	03313c23          	sd	s3,56(sp)
    80004840:	03413823          	sd	s4,48(sp)
    80004844:	03513423          	sd	s5,40(sp)
    80004848:	03613023          	sd	s6,32(sp)
    8000484c:	01713c23          	sd	s7,24(sp)
    80004850:	01813823          	sd	s8,16(sp)
    80004854:	01913423          	sd	s9,8(sp)
    80004858:	06010413          	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000485c:	0001c797          	auipc	a5,0x1c
    80004860:	7687a783          	lw	a5,1896(a5) # 80020fc4 <sb+0x4>
    80004864:	14078863          	beqz	a5,800049b4 <balloc+0x18c>
    80004868:	00050b93          	mv	s7,a0
    8000486c:	00000a93          	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004870:	0001cb17          	auipc	s6,0x1c
    80004874:	750b0b13          	addi	s6,s6,1872 # 80020fc0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004878:	00000c13          	li	s8,0
      m = 1 << (bi % 8);
    8000487c:	00100993          	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004880:	00002a37          	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004884:	00002cb7          	lui	s9,0x2
    80004888:	0bc0006f          	j	80004944 <balloc+0x11c>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000488c:	00f907b3          	add	a5,s2,a5
    80004890:	00d66633          	or	a2,a2,a3
    80004894:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80004898:	00090513          	mv	a0,s2
    8000489c:	00002097          	auipc	ra,0x2
    800048a0:	870080e7          	jalr	-1936(ra) # 8000610c <log_write>
        brelse(bp);
    800048a4:	00090513          	mv	a0,s2
    800048a8:	00000097          	auipc	ra,0x0
    800048ac:	d50080e7          	jalr	-688(ra) # 800045f8 <brelse>
  bp = bread(dev, bno);
    800048b0:	00048593          	mv	a1,s1
    800048b4:	000b8513          	mv	a0,s7
    800048b8:	00000097          	auipc	ra,0x0
    800048bc:	ba4080e7          	jalr	-1116(ra) # 8000445c <bread>
    800048c0:	00050913          	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800048c4:	40000613          	li	a2,1024
    800048c8:	00000593          	li	a1,0
    800048cc:	05850513          	addi	a0,a0,88
    800048d0:	ffffd097          	auipc	ra,0xffffd
    800048d4:	920080e7          	jalr	-1760(ra) # 800011f0 <memset>
  log_write(bp);
    800048d8:	00090513          	mv	a0,s2
    800048dc:	00002097          	auipc	ra,0x2
    800048e0:	830080e7          	jalr	-2000(ra) # 8000610c <log_write>
  brelse(bp);
    800048e4:	00090513          	mv	a0,s2
    800048e8:	00000097          	auipc	ra,0x0
    800048ec:	d10080e7          	jalr	-752(ra) # 800045f8 <brelse>
}
    800048f0:	00048513          	mv	a0,s1
    800048f4:	05813083          	ld	ra,88(sp)
    800048f8:	05013403          	ld	s0,80(sp)
    800048fc:	04813483          	ld	s1,72(sp)
    80004900:	04013903          	ld	s2,64(sp)
    80004904:	03813983          	ld	s3,56(sp)
    80004908:	03013a03          	ld	s4,48(sp)
    8000490c:	02813a83          	ld	s5,40(sp)
    80004910:	02013b03          	ld	s6,32(sp)
    80004914:	01813b83          	ld	s7,24(sp)
    80004918:	01013c03          	ld	s8,16(sp)
    8000491c:	00813c83          	ld	s9,8(sp)
    80004920:	06010113          	addi	sp,sp,96
    80004924:	00008067          	ret
    brelse(bp);
    80004928:	00090513          	mv	a0,s2
    8000492c:	00000097          	auipc	ra,0x0
    80004930:	ccc080e7          	jalr	-820(ra) # 800045f8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004934:	015c87bb          	addw	a5,s9,s5
    80004938:	00078a9b          	sext.w	s5,a5
    8000493c:	004b2703          	lw	a4,4(s6)
    80004940:	06eafa63          	bgeu	s5,a4,800049b4 <balloc+0x18c>
    bp = bread(dev, BBLOCK(b, sb));
    80004944:	41fad79b          	sraiw	a5,s5,0x1f
    80004948:	0137d79b          	srliw	a5,a5,0x13
    8000494c:	015787bb          	addw	a5,a5,s5
    80004950:	40d7d79b          	sraiw	a5,a5,0xd
    80004954:	01cb2583          	lw	a1,28(s6)
    80004958:	00b785bb          	addw	a1,a5,a1
    8000495c:	000b8513          	mv	a0,s7
    80004960:	00000097          	auipc	ra,0x0
    80004964:	afc080e7          	jalr	-1284(ra) # 8000445c <bread>
    80004968:	00050913          	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000496c:	004b2503          	lw	a0,4(s6)
    80004970:	000a849b          	sext.w	s1,s5
    80004974:	000c0713          	mv	a4,s8
    80004978:	faa4f8e3          	bgeu	s1,a0,80004928 <balloc+0x100>
      m = 1 << (bi % 8);
    8000497c:	00777693          	andi	a3,a4,7
    80004980:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004984:	41f7579b          	sraiw	a5,a4,0x1f
    80004988:	01d7d79b          	srliw	a5,a5,0x1d
    8000498c:	00e787bb          	addw	a5,a5,a4
    80004990:	4037d79b          	sraiw	a5,a5,0x3
    80004994:	00f90633          	add	a2,s2,a5
    80004998:	05864603          	lbu	a2,88(a2)
    8000499c:	00c6f5b3          	and	a1,a3,a2
    800049a0:	ee0586e3          	beqz	a1,8000488c <balloc+0x64>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800049a4:	0017071b          	addiw	a4,a4,1
    800049a8:	0014849b          	addiw	s1,s1,1
    800049ac:	fd4716e3          	bne	a4,s4,80004978 <balloc+0x150>
    800049b0:	f79ff06f          	j	80004928 <balloc+0x100>
  printf("balloc: out of blocks\n");
    800049b4:	00006517          	auipc	a0,0x6
    800049b8:	c9c50513          	addi	a0,a0,-868 # 8000a650 <syscalls+0x100>
    800049bc:	ffffc097          	auipc	ra,0xffffc
    800049c0:	cec080e7          	jalr	-788(ra) # 800006a8 <printf>
  return 0;
    800049c4:	00000493          	li	s1,0
    800049c8:	f29ff06f          	j	800048f0 <balloc+0xc8>

00000000800049cc <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800049cc:	fd010113          	addi	sp,sp,-48
    800049d0:	02113423          	sd	ra,40(sp)
    800049d4:	02813023          	sd	s0,32(sp)
    800049d8:	00913c23          	sd	s1,24(sp)
    800049dc:	01213823          	sd	s2,16(sp)
    800049e0:	01313423          	sd	s3,8(sp)
    800049e4:	01413023          	sd	s4,0(sp)
    800049e8:	03010413          	addi	s0,sp,48
    800049ec:	00050993          	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800049f0:	00b00793          	li	a5,11
    800049f4:	02b7ea63          	bltu	a5,a1,80004a28 <bmap+0x5c>
    if((addr = ip->addrs[bn]) == 0){
    800049f8:	02059793          	slli	a5,a1,0x20
    800049fc:	01e7d593          	srli	a1,a5,0x1e
    80004a00:	00b504b3          	add	s1,a0,a1
    80004a04:	0504a903          	lw	s2,80(s1)
    80004a08:	08091463          	bnez	s2,80004a90 <bmap+0xc4>
      addr = balloc(ip->dev);
    80004a0c:	00052503          	lw	a0,0(a0)
    80004a10:	00000097          	auipc	ra,0x0
    80004a14:	e18080e7          	jalr	-488(ra) # 80004828 <balloc>
    80004a18:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80004a1c:	06090a63          	beqz	s2,80004a90 <bmap+0xc4>
        return 0;
      ip->addrs[bn] = addr;
    80004a20:	0524a823          	sw	s2,80(s1)
    80004a24:	06c0006f          	j	80004a90 <bmap+0xc4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80004a28:	ff45849b          	addiw	s1,a1,-12
    80004a2c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004a30:	0ff00793          	li	a5,255
    80004a34:	0ae7e463          	bltu	a5,a4,80004adc <bmap+0x110>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80004a38:	08052903          	lw	s2,128(a0)
    80004a3c:	00091e63          	bnez	s2,80004a58 <bmap+0x8c>
      addr = balloc(ip->dev);
    80004a40:	00052503          	lw	a0,0(a0)
    80004a44:	00000097          	auipc	ra,0x0
    80004a48:	de4080e7          	jalr	-540(ra) # 80004828 <balloc>
    80004a4c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80004a50:	04090063          	beqz	s2,80004a90 <bmap+0xc4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80004a54:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80004a58:	00090593          	mv	a1,s2
    80004a5c:	0009a503          	lw	a0,0(s3)
    80004a60:	00000097          	auipc	ra,0x0
    80004a64:	9fc080e7          	jalr	-1540(ra) # 8000445c <bread>
    80004a68:	00050a13          	mv	s4,a0
    a = (uint*)bp->data;
    80004a6c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004a70:	02049713          	slli	a4,s1,0x20
    80004a74:	01e75593          	srli	a1,a4,0x1e
    80004a78:	00b784b3          	add	s1,a5,a1
    80004a7c:	0004a903          	lw	s2,0(s1)
    80004a80:	02090a63          	beqz	s2,80004ab4 <bmap+0xe8>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80004a84:	000a0513          	mv	a0,s4
    80004a88:	00000097          	auipc	ra,0x0
    80004a8c:	b70080e7          	jalr	-1168(ra) # 800045f8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004a90:	00090513          	mv	a0,s2
    80004a94:	02813083          	ld	ra,40(sp)
    80004a98:	02013403          	ld	s0,32(sp)
    80004a9c:	01813483          	ld	s1,24(sp)
    80004aa0:	01013903          	ld	s2,16(sp)
    80004aa4:	00813983          	ld	s3,8(sp)
    80004aa8:	00013a03          	ld	s4,0(sp)
    80004aac:	03010113          	addi	sp,sp,48
    80004ab0:	00008067          	ret
      addr = balloc(ip->dev);
    80004ab4:	0009a503          	lw	a0,0(s3)
    80004ab8:	00000097          	auipc	ra,0x0
    80004abc:	d70080e7          	jalr	-656(ra) # 80004828 <balloc>
    80004ac0:	0005091b          	sext.w	s2,a0
      if(addr){
    80004ac4:	fc0900e3          	beqz	s2,80004a84 <bmap+0xb8>
        a[bn] = addr;
    80004ac8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80004acc:	000a0513          	mv	a0,s4
    80004ad0:	00001097          	auipc	ra,0x1
    80004ad4:	63c080e7          	jalr	1596(ra) # 8000610c <log_write>
    80004ad8:	fadff06f          	j	80004a84 <bmap+0xb8>
  panic("bmap: out of range");
    80004adc:	00006517          	auipc	a0,0x6
    80004ae0:	b8c50513          	addi	a0,a0,-1140 # 8000a668 <syscalls+0x118>
    80004ae4:	ffffc097          	auipc	ra,0xffffc
    80004ae8:	f9c080e7          	jalr	-100(ra) # 80000a80 <panic>

0000000080004aec <iget>:
{
    80004aec:	fd010113          	addi	sp,sp,-48
    80004af0:	02113423          	sd	ra,40(sp)
    80004af4:	02813023          	sd	s0,32(sp)
    80004af8:	00913c23          	sd	s1,24(sp)
    80004afc:	01213823          	sd	s2,16(sp)
    80004b00:	01313423          	sd	s3,8(sp)
    80004b04:	01413023          	sd	s4,0(sp)
    80004b08:	03010413          	addi	s0,sp,48
    80004b0c:	00050993          	mv	s3,a0
    80004b10:	00058a13          	mv	s4,a1
  acquire(&itable.lock);
    80004b14:	0001c517          	auipc	a0,0x1c
    80004b18:	4cc50513          	addi	a0,a0,1228 # 80020fe0 <itable>
    80004b1c:	ffffc097          	auipc	ra,0xffffc
    80004b20:	57c080e7          	jalr	1404(ra) # 80001098 <acquire>
  empty = 0;
    80004b24:	00000913          	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004b28:	0001c497          	auipc	s1,0x1c
    80004b2c:	4d048493          	addi	s1,s1,1232 # 80020ff8 <itable+0x18>
    80004b30:	0001e697          	auipc	a3,0x1e
    80004b34:	f5868693          	addi	a3,a3,-168 # 80022a88 <log>
    80004b38:	0100006f          	j	80004b48 <iget+0x5c>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004b3c:	04090263          	beqz	s2,80004b80 <iget+0x94>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004b40:	08848493          	addi	s1,s1,136
    80004b44:	04d48463          	beq	s1,a3,80004b8c <iget+0xa0>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004b48:	0084a783          	lw	a5,8(s1)
    80004b4c:	fef058e3          	blez	a5,80004b3c <iget+0x50>
    80004b50:	0004a703          	lw	a4,0(s1)
    80004b54:	ff3714e3          	bne	a4,s3,80004b3c <iget+0x50>
    80004b58:	0044a703          	lw	a4,4(s1)
    80004b5c:	ff4710e3          	bne	a4,s4,80004b3c <iget+0x50>
      ip->ref++;
    80004b60:	0017879b          	addiw	a5,a5,1
    80004b64:	00f4a423          	sw	a5,8(s1)
      release(&itable.lock);
    80004b68:	0001c517          	auipc	a0,0x1c
    80004b6c:	47850513          	addi	a0,a0,1144 # 80020fe0 <itable>
    80004b70:	ffffc097          	auipc	ra,0xffffc
    80004b74:	620080e7          	jalr	1568(ra) # 80001190 <release>
      return ip;
    80004b78:	00048913          	mv	s2,s1
    80004b7c:	0380006f          	j	80004bb4 <iget+0xc8>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004b80:	fc0790e3          	bnez	a5,80004b40 <iget+0x54>
    80004b84:	00048913          	mv	s2,s1
    80004b88:	fb9ff06f          	j	80004b40 <iget+0x54>
  if(empty == 0)
    80004b8c:	04090663          	beqz	s2,80004bd8 <iget+0xec>
  ip->dev = dev;
    80004b90:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004b94:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004b98:	00100793          	li	a5,1
    80004b9c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004ba0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004ba4:	0001c517          	auipc	a0,0x1c
    80004ba8:	43c50513          	addi	a0,a0,1084 # 80020fe0 <itable>
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	5e4080e7          	jalr	1508(ra) # 80001190 <release>
}
    80004bb4:	00090513          	mv	a0,s2
    80004bb8:	02813083          	ld	ra,40(sp)
    80004bbc:	02013403          	ld	s0,32(sp)
    80004bc0:	01813483          	ld	s1,24(sp)
    80004bc4:	01013903          	ld	s2,16(sp)
    80004bc8:	00813983          	ld	s3,8(sp)
    80004bcc:	00013a03          	ld	s4,0(sp)
    80004bd0:	03010113          	addi	sp,sp,48
    80004bd4:	00008067          	ret
    panic("iget: no inodes");
    80004bd8:	00006517          	auipc	a0,0x6
    80004bdc:	aa850513          	addi	a0,a0,-1368 # 8000a680 <syscalls+0x130>
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	ea0080e7          	jalr	-352(ra) # 80000a80 <panic>

0000000080004be8 <iinit>:
{
    80004be8:	fd010113          	addi	sp,sp,-48
    80004bec:	02113423          	sd	ra,40(sp)
    80004bf0:	02813023          	sd	s0,32(sp)
    80004bf4:	00913c23          	sd	s1,24(sp)
    80004bf8:	01213823          	sd	s2,16(sp)
    80004bfc:	01313423          	sd	s3,8(sp)
    80004c00:	03010413          	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004c04:	00006597          	auipc	a1,0x6
    80004c08:	a8c58593          	addi	a1,a1,-1396 # 8000a690 <syscalls+0x140>
    80004c0c:	0001c517          	auipc	a0,0x1c
    80004c10:	3d450513          	addi	a0,a0,980 # 80020fe0 <itable>
    80004c14:	ffffc097          	auipc	ra,0xffffc
    80004c18:	3a0080e7          	jalr	928(ra) # 80000fb4 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004c1c:	0001c497          	auipc	s1,0x1c
    80004c20:	3ec48493          	addi	s1,s1,1004 # 80021008 <itable+0x28>
    80004c24:	0001e997          	auipc	s3,0x1e
    80004c28:	e7498993          	addi	s3,s3,-396 # 80022a98 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004c2c:	00006917          	auipc	s2,0x6
    80004c30:	a6c90913          	addi	s2,s2,-1428 # 8000a698 <syscalls+0x148>
    80004c34:	00090593          	mv	a1,s2
    80004c38:	00048513          	mv	a0,s1
    80004c3c:	00001097          	auipc	ra,0x1
    80004c40:	5ec080e7          	jalr	1516(ra) # 80006228 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004c44:	08848493          	addi	s1,s1,136
    80004c48:	ff3496e3          	bne	s1,s3,80004c34 <iinit+0x4c>
}
    80004c4c:	02813083          	ld	ra,40(sp)
    80004c50:	02013403          	ld	s0,32(sp)
    80004c54:	01813483          	ld	s1,24(sp)
    80004c58:	01013903          	ld	s2,16(sp)
    80004c5c:	00813983          	ld	s3,8(sp)
    80004c60:	03010113          	addi	sp,sp,48
    80004c64:	00008067          	ret

0000000080004c68 <ialloc>:
{
    80004c68:	fb010113          	addi	sp,sp,-80
    80004c6c:	04113423          	sd	ra,72(sp)
    80004c70:	04813023          	sd	s0,64(sp)
    80004c74:	02913c23          	sd	s1,56(sp)
    80004c78:	03213823          	sd	s2,48(sp)
    80004c7c:	03313423          	sd	s3,40(sp)
    80004c80:	03413023          	sd	s4,32(sp)
    80004c84:	01513c23          	sd	s5,24(sp)
    80004c88:	01613823          	sd	s6,16(sp)
    80004c8c:	01713423          	sd	s7,8(sp)
    80004c90:	05010413          	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80004c94:	0001c717          	auipc	a4,0x1c
    80004c98:	33872703          	lw	a4,824(a4) # 80020fcc <sb+0xc>
    80004c9c:	00100793          	li	a5,1
    80004ca0:	06e7f463          	bgeu	a5,a4,80004d08 <ialloc+0xa0>
    80004ca4:	00050a93          	mv	s5,a0
    80004ca8:	00058b93          	mv	s7,a1
    80004cac:	00100493          	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004cb0:	0001ca17          	auipc	s4,0x1c
    80004cb4:	310a0a13          	addi	s4,s4,784 # 80020fc0 <sb>
    80004cb8:	00048b1b          	sext.w	s6,s1
    80004cbc:	0044d593          	srli	a1,s1,0x4
    80004cc0:	018a2783          	lw	a5,24(s4)
    80004cc4:	00b785bb          	addw	a1,a5,a1
    80004cc8:	000a8513          	mv	a0,s5
    80004ccc:	fffff097          	auipc	ra,0xfffff
    80004cd0:	790080e7          	jalr	1936(ra) # 8000445c <bread>
    80004cd4:	00050913          	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80004cd8:	05850993          	addi	s3,a0,88
    80004cdc:	00f4f793          	andi	a5,s1,15
    80004ce0:	00679793          	slli	a5,a5,0x6
    80004ce4:	00f989b3          	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004ce8:	00099783          	lh	a5,0(s3)
    80004cec:	04078e63          	beqz	a5,80004d48 <ialloc+0xe0>
    brelse(bp);
    80004cf0:	00000097          	auipc	ra,0x0
    80004cf4:	908080e7          	jalr	-1784(ra) # 800045f8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80004cf8:	00148493          	addi	s1,s1,1
    80004cfc:	00ca2703          	lw	a4,12(s4)
    80004d00:	0004879b          	sext.w	a5,s1
    80004d04:	fae7eae3          	bltu	a5,a4,80004cb8 <ialloc+0x50>
  printf("ialloc: no inodes\n");
    80004d08:	00006517          	auipc	a0,0x6
    80004d0c:	99850513          	addi	a0,a0,-1640 # 8000a6a0 <syscalls+0x150>
    80004d10:	ffffc097          	auipc	ra,0xffffc
    80004d14:	998080e7          	jalr	-1640(ra) # 800006a8 <printf>
  return 0;
    80004d18:	00000513          	li	a0,0
}
    80004d1c:	04813083          	ld	ra,72(sp)
    80004d20:	04013403          	ld	s0,64(sp)
    80004d24:	03813483          	ld	s1,56(sp)
    80004d28:	03013903          	ld	s2,48(sp)
    80004d2c:	02813983          	ld	s3,40(sp)
    80004d30:	02013a03          	ld	s4,32(sp)
    80004d34:	01813a83          	ld	s5,24(sp)
    80004d38:	01013b03          	ld	s6,16(sp)
    80004d3c:	00813b83          	ld	s7,8(sp)
    80004d40:	05010113          	addi	sp,sp,80
    80004d44:	00008067          	ret
      memset(dip, 0, sizeof(*dip));
    80004d48:	04000613          	li	a2,64
    80004d4c:	00000593          	li	a1,0
    80004d50:	00098513          	mv	a0,s3
    80004d54:	ffffc097          	auipc	ra,0xffffc
    80004d58:	49c080e7          	jalr	1180(ra) # 800011f0 <memset>
      dip->type = type;
    80004d5c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004d60:	00090513          	mv	a0,s2
    80004d64:	00001097          	auipc	ra,0x1
    80004d68:	3a8080e7          	jalr	936(ra) # 8000610c <log_write>
      brelse(bp);
    80004d6c:	00090513          	mv	a0,s2
    80004d70:	00000097          	auipc	ra,0x0
    80004d74:	888080e7          	jalr	-1912(ra) # 800045f8 <brelse>
      return iget(dev, inum);
    80004d78:	000b0593          	mv	a1,s6
    80004d7c:	000a8513          	mv	a0,s5
    80004d80:	00000097          	auipc	ra,0x0
    80004d84:	d6c080e7          	jalr	-660(ra) # 80004aec <iget>
    80004d88:	f95ff06f          	j	80004d1c <ialloc+0xb4>

0000000080004d8c <iupdate>:
{
    80004d8c:	fe010113          	addi	sp,sp,-32
    80004d90:	00113c23          	sd	ra,24(sp)
    80004d94:	00813823          	sd	s0,16(sp)
    80004d98:	00913423          	sd	s1,8(sp)
    80004d9c:	01213023          	sd	s2,0(sp)
    80004da0:	02010413          	addi	s0,sp,32
    80004da4:	00050493          	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004da8:	00452783          	lw	a5,4(a0)
    80004dac:	0047d79b          	srliw	a5,a5,0x4
    80004db0:	0001c597          	auipc	a1,0x1c
    80004db4:	2285a583          	lw	a1,552(a1) # 80020fd8 <sb+0x18>
    80004db8:	00b785bb          	addw	a1,a5,a1
    80004dbc:	00052503          	lw	a0,0(a0)
    80004dc0:	fffff097          	auipc	ra,0xfffff
    80004dc4:	69c080e7          	jalr	1692(ra) # 8000445c <bread>
    80004dc8:	00050913          	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004dcc:	05850793          	addi	a5,a0,88
    80004dd0:	0044a703          	lw	a4,4(s1)
    80004dd4:	00f77713          	andi	a4,a4,15
    80004dd8:	00671713          	slli	a4,a4,0x6
    80004ddc:	00e787b3          	add	a5,a5,a4
  dip->type = ip->type;
    80004de0:	04449703          	lh	a4,68(s1)
    80004de4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80004de8:	04649703          	lh	a4,70(s1)
    80004dec:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80004df0:	04849703          	lh	a4,72(s1)
    80004df4:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80004df8:	04a49703          	lh	a4,74(s1)
    80004dfc:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80004e00:	04c4a703          	lw	a4,76(s1)
    80004e04:	00e7a423          	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004e08:	03400613          	li	a2,52
    80004e0c:	05048593          	addi	a1,s1,80
    80004e10:	00c78513          	addi	a0,a5,12
    80004e14:	ffffc097          	auipc	ra,0xffffc
    80004e18:	470080e7          	jalr	1136(ra) # 80001284 <memmove>
  log_write(bp);
    80004e1c:	00090513          	mv	a0,s2
    80004e20:	00001097          	auipc	ra,0x1
    80004e24:	2ec080e7          	jalr	748(ra) # 8000610c <log_write>
  brelse(bp);
    80004e28:	00090513          	mv	a0,s2
    80004e2c:	fffff097          	auipc	ra,0xfffff
    80004e30:	7cc080e7          	jalr	1996(ra) # 800045f8 <brelse>
}
    80004e34:	01813083          	ld	ra,24(sp)
    80004e38:	01013403          	ld	s0,16(sp)
    80004e3c:	00813483          	ld	s1,8(sp)
    80004e40:	00013903          	ld	s2,0(sp)
    80004e44:	02010113          	addi	sp,sp,32
    80004e48:	00008067          	ret

0000000080004e4c <idup>:
{
    80004e4c:	fe010113          	addi	sp,sp,-32
    80004e50:	00113c23          	sd	ra,24(sp)
    80004e54:	00813823          	sd	s0,16(sp)
    80004e58:	00913423          	sd	s1,8(sp)
    80004e5c:	02010413          	addi	s0,sp,32
    80004e60:	00050493          	mv	s1,a0
  acquire(&itable.lock);
    80004e64:	0001c517          	auipc	a0,0x1c
    80004e68:	17c50513          	addi	a0,a0,380 # 80020fe0 <itable>
    80004e6c:	ffffc097          	auipc	ra,0xffffc
    80004e70:	22c080e7          	jalr	556(ra) # 80001098 <acquire>
  ip->ref++;
    80004e74:	0084a783          	lw	a5,8(s1)
    80004e78:	0017879b          	addiw	a5,a5,1
    80004e7c:	00f4a423          	sw	a5,8(s1)
  release(&itable.lock);
    80004e80:	0001c517          	auipc	a0,0x1c
    80004e84:	16050513          	addi	a0,a0,352 # 80020fe0 <itable>
    80004e88:	ffffc097          	auipc	ra,0xffffc
    80004e8c:	308080e7          	jalr	776(ra) # 80001190 <release>
}
    80004e90:	00048513          	mv	a0,s1
    80004e94:	01813083          	ld	ra,24(sp)
    80004e98:	01013403          	ld	s0,16(sp)
    80004e9c:	00813483          	ld	s1,8(sp)
    80004ea0:	02010113          	addi	sp,sp,32
    80004ea4:	00008067          	ret

0000000080004ea8 <ilock>:
{
    80004ea8:	fe010113          	addi	sp,sp,-32
    80004eac:	00113c23          	sd	ra,24(sp)
    80004eb0:	00813823          	sd	s0,16(sp)
    80004eb4:	00913423          	sd	s1,8(sp)
    80004eb8:	01213023          	sd	s2,0(sp)
    80004ebc:	02010413          	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004ec0:	02050e63          	beqz	a0,80004efc <ilock+0x54>
    80004ec4:	00050493          	mv	s1,a0
    80004ec8:	00852783          	lw	a5,8(a0)
    80004ecc:	02f05863          	blez	a5,80004efc <ilock+0x54>
  acquiresleep(&ip->lock);
    80004ed0:	01050513          	addi	a0,a0,16
    80004ed4:	00001097          	auipc	ra,0x1
    80004ed8:	3ac080e7          	jalr	940(ra) # 80006280 <acquiresleep>
  if(ip->valid == 0){
    80004edc:	0404a783          	lw	a5,64(s1)
    80004ee0:	02078663          	beqz	a5,80004f0c <ilock+0x64>
}
    80004ee4:	01813083          	ld	ra,24(sp)
    80004ee8:	01013403          	ld	s0,16(sp)
    80004eec:	00813483          	ld	s1,8(sp)
    80004ef0:	00013903          	ld	s2,0(sp)
    80004ef4:	02010113          	addi	sp,sp,32
    80004ef8:	00008067          	ret
    panic("ilock");
    80004efc:	00005517          	auipc	a0,0x5
    80004f00:	7bc50513          	addi	a0,a0,1980 # 8000a6b8 <syscalls+0x168>
    80004f04:	ffffc097          	auipc	ra,0xffffc
    80004f08:	b7c080e7          	jalr	-1156(ra) # 80000a80 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004f0c:	0044a783          	lw	a5,4(s1)
    80004f10:	0047d79b          	srliw	a5,a5,0x4
    80004f14:	0001c597          	auipc	a1,0x1c
    80004f18:	0c45a583          	lw	a1,196(a1) # 80020fd8 <sb+0x18>
    80004f1c:	00b785bb          	addw	a1,a5,a1
    80004f20:	0004a503          	lw	a0,0(s1)
    80004f24:	fffff097          	auipc	ra,0xfffff
    80004f28:	538080e7          	jalr	1336(ra) # 8000445c <bread>
    80004f2c:	00050913          	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004f30:	05850593          	addi	a1,a0,88
    80004f34:	0044a783          	lw	a5,4(s1)
    80004f38:	00f7f793          	andi	a5,a5,15
    80004f3c:	00679793          	slli	a5,a5,0x6
    80004f40:	00f585b3          	add	a1,a1,a5
    ip->type = dip->type;
    80004f44:	00059783          	lh	a5,0(a1)
    80004f48:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004f4c:	00259783          	lh	a5,2(a1)
    80004f50:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004f54:	00459783          	lh	a5,4(a1)
    80004f58:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004f5c:	00659783          	lh	a5,6(a1)
    80004f60:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004f64:	0085a783          	lw	a5,8(a1)
    80004f68:	04f4a623          	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004f6c:	03400613          	li	a2,52
    80004f70:	00c58593          	addi	a1,a1,12
    80004f74:	05048513          	addi	a0,s1,80
    80004f78:	ffffc097          	auipc	ra,0xffffc
    80004f7c:	30c080e7          	jalr	780(ra) # 80001284 <memmove>
    brelse(bp);
    80004f80:	00090513          	mv	a0,s2
    80004f84:	fffff097          	auipc	ra,0xfffff
    80004f88:	674080e7          	jalr	1652(ra) # 800045f8 <brelse>
    ip->valid = 1;
    80004f8c:	00100793          	li	a5,1
    80004f90:	04f4a023          	sw	a5,64(s1)
    if(ip->type == 0)
    80004f94:	04449783          	lh	a5,68(s1)
    80004f98:	f40796e3          	bnez	a5,80004ee4 <ilock+0x3c>
      panic("ilock: no type");
    80004f9c:	00005517          	auipc	a0,0x5
    80004fa0:	72450513          	addi	a0,a0,1828 # 8000a6c0 <syscalls+0x170>
    80004fa4:	ffffc097          	auipc	ra,0xffffc
    80004fa8:	adc080e7          	jalr	-1316(ra) # 80000a80 <panic>

0000000080004fac <iunlock>:
{
    80004fac:	fe010113          	addi	sp,sp,-32
    80004fb0:	00113c23          	sd	ra,24(sp)
    80004fb4:	00813823          	sd	s0,16(sp)
    80004fb8:	00913423          	sd	s1,8(sp)
    80004fbc:	01213023          	sd	s2,0(sp)
    80004fc0:	02010413          	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004fc4:	04050463          	beqz	a0,8000500c <iunlock+0x60>
    80004fc8:	00050493          	mv	s1,a0
    80004fcc:	01050913          	addi	s2,a0,16
    80004fd0:	00090513          	mv	a0,s2
    80004fd4:	00001097          	auipc	ra,0x1
    80004fd8:	398080e7          	jalr	920(ra) # 8000636c <holdingsleep>
    80004fdc:	02050863          	beqz	a0,8000500c <iunlock+0x60>
    80004fe0:	0084a783          	lw	a5,8(s1)
    80004fe4:	02f05463          	blez	a5,8000500c <iunlock+0x60>
  releasesleep(&ip->lock);
    80004fe8:	00090513          	mv	a0,s2
    80004fec:	00001097          	auipc	ra,0x1
    80004ff0:	31c080e7          	jalr	796(ra) # 80006308 <releasesleep>
}
    80004ff4:	01813083          	ld	ra,24(sp)
    80004ff8:	01013403          	ld	s0,16(sp)
    80004ffc:	00813483          	ld	s1,8(sp)
    80005000:	00013903          	ld	s2,0(sp)
    80005004:	02010113          	addi	sp,sp,32
    80005008:	00008067          	ret
    panic("iunlock");
    8000500c:	00005517          	auipc	a0,0x5
    80005010:	6c450513          	addi	a0,a0,1732 # 8000a6d0 <syscalls+0x180>
    80005014:	ffffc097          	auipc	ra,0xffffc
    80005018:	a6c080e7          	jalr	-1428(ra) # 80000a80 <panic>

000000008000501c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000501c:	fd010113          	addi	sp,sp,-48
    80005020:	02113423          	sd	ra,40(sp)
    80005024:	02813023          	sd	s0,32(sp)
    80005028:	00913c23          	sd	s1,24(sp)
    8000502c:	01213823          	sd	s2,16(sp)
    80005030:	01313423          	sd	s3,8(sp)
    80005034:	01413023          	sd	s4,0(sp)
    80005038:	03010413          	addi	s0,sp,48
    8000503c:	00050993          	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80005040:	05050493          	addi	s1,a0,80
    80005044:	08050913          	addi	s2,a0,128
    80005048:	00c0006f          	j	80005054 <itrunc+0x38>
    8000504c:	00448493          	addi	s1,s1,4
    80005050:	03248063          	beq	s1,s2,80005070 <itrunc+0x54>
    if(ip->addrs[i]){
    80005054:	0004a583          	lw	a1,0(s1)
    80005058:	fe058ae3          	beqz	a1,8000504c <itrunc+0x30>
      bfree(ip->dev, ip->addrs[i]);
    8000505c:	0009a503          	lw	a0,0(s3)
    80005060:	fffff097          	auipc	ra,0xfffff
    80005064:	720080e7          	jalr	1824(ra) # 80004780 <bfree>
      ip->addrs[i] = 0;
    80005068:	0004a023          	sw	zero,0(s1)
    8000506c:	fe1ff06f          	j	8000504c <itrunc+0x30>
    }
  }

  if(ip->addrs[NDIRECT]){
    80005070:	0809a583          	lw	a1,128(s3)
    80005074:	02059a63          	bnez	a1,800050a8 <itrunc+0x8c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80005078:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000507c:	00098513          	mv	a0,s3
    80005080:	00000097          	auipc	ra,0x0
    80005084:	d0c080e7          	jalr	-756(ra) # 80004d8c <iupdate>
}
    80005088:	02813083          	ld	ra,40(sp)
    8000508c:	02013403          	ld	s0,32(sp)
    80005090:	01813483          	ld	s1,24(sp)
    80005094:	01013903          	ld	s2,16(sp)
    80005098:	00813983          	ld	s3,8(sp)
    8000509c:	00013a03          	ld	s4,0(sp)
    800050a0:	03010113          	addi	sp,sp,48
    800050a4:	00008067          	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800050a8:	0009a503          	lw	a0,0(s3)
    800050ac:	fffff097          	auipc	ra,0xfffff
    800050b0:	3b0080e7          	jalr	944(ra) # 8000445c <bread>
    800050b4:	00050a13          	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800050b8:	05850493          	addi	s1,a0,88
    800050bc:	45850913          	addi	s2,a0,1112
    800050c0:	00c0006f          	j	800050cc <itrunc+0xb0>
    800050c4:	00448493          	addi	s1,s1,4
    800050c8:	01248e63          	beq	s1,s2,800050e4 <itrunc+0xc8>
      if(a[j])
    800050cc:	0004a583          	lw	a1,0(s1)
    800050d0:	fe058ae3          	beqz	a1,800050c4 <itrunc+0xa8>
        bfree(ip->dev, a[j]);
    800050d4:	0009a503          	lw	a0,0(s3)
    800050d8:	fffff097          	auipc	ra,0xfffff
    800050dc:	6a8080e7          	jalr	1704(ra) # 80004780 <bfree>
    800050e0:	fe5ff06f          	j	800050c4 <itrunc+0xa8>
    brelse(bp);
    800050e4:	000a0513          	mv	a0,s4
    800050e8:	fffff097          	auipc	ra,0xfffff
    800050ec:	510080e7          	jalr	1296(ra) # 800045f8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800050f0:	0809a583          	lw	a1,128(s3)
    800050f4:	0009a503          	lw	a0,0(s3)
    800050f8:	fffff097          	auipc	ra,0xfffff
    800050fc:	688080e7          	jalr	1672(ra) # 80004780 <bfree>
    ip->addrs[NDIRECT] = 0;
    80005100:	0809a023          	sw	zero,128(s3)
    80005104:	f75ff06f          	j	80005078 <itrunc+0x5c>

0000000080005108 <iput>:
{
    80005108:	fe010113          	addi	sp,sp,-32
    8000510c:	00113c23          	sd	ra,24(sp)
    80005110:	00813823          	sd	s0,16(sp)
    80005114:	00913423          	sd	s1,8(sp)
    80005118:	01213023          	sd	s2,0(sp)
    8000511c:	02010413          	addi	s0,sp,32
    80005120:	00050493          	mv	s1,a0
  acquire(&itable.lock);
    80005124:	0001c517          	auipc	a0,0x1c
    80005128:	ebc50513          	addi	a0,a0,-324 # 80020fe0 <itable>
    8000512c:	ffffc097          	auipc	ra,0xffffc
    80005130:	f6c080e7          	jalr	-148(ra) # 80001098 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80005134:	0084a703          	lw	a4,8(s1)
    80005138:	00100793          	li	a5,1
    8000513c:	02f70c63          	beq	a4,a5,80005174 <iput+0x6c>
  ip->ref--;
    80005140:	0084a783          	lw	a5,8(s1)
    80005144:	fff7879b          	addiw	a5,a5,-1
    80005148:	00f4a423          	sw	a5,8(s1)
  release(&itable.lock);
    8000514c:	0001c517          	auipc	a0,0x1c
    80005150:	e9450513          	addi	a0,a0,-364 # 80020fe0 <itable>
    80005154:	ffffc097          	auipc	ra,0xffffc
    80005158:	03c080e7          	jalr	60(ra) # 80001190 <release>
}
    8000515c:	01813083          	ld	ra,24(sp)
    80005160:	01013403          	ld	s0,16(sp)
    80005164:	00813483          	ld	s1,8(sp)
    80005168:	00013903          	ld	s2,0(sp)
    8000516c:	02010113          	addi	sp,sp,32
    80005170:	00008067          	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80005174:	0404a783          	lw	a5,64(s1)
    80005178:	fc0784e3          	beqz	a5,80005140 <iput+0x38>
    8000517c:	04a49783          	lh	a5,74(s1)
    80005180:	fc0790e3          	bnez	a5,80005140 <iput+0x38>
    acquiresleep(&ip->lock);
    80005184:	01048913          	addi	s2,s1,16
    80005188:	00090513          	mv	a0,s2
    8000518c:	00001097          	auipc	ra,0x1
    80005190:	0f4080e7          	jalr	244(ra) # 80006280 <acquiresleep>
    release(&itable.lock);
    80005194:	0001c517          	auipc	a0,0x1c
    80005198:	e4c50513          	addi	a0,a0,-436 # 80020fe0 <itable>
    8000519c:	ffffc097          	auipc	ra,0xffffc
    800051a0:	ff4080e7          	jalr	-12(ra) # 80001190 <release>
    itrunc(ip);
    800051a4:	00048513          	mv	a0,s1
    800051a8:	00000097          	auipc	ra,0x0
    800051ac:	e74080e7          	jalr	-396(ra) # 8000501c <itrunc>
    ip->type = 0;
    800051b0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800051b4:	00048513          	mv	a0,s1
    800051b8:	00000097          	auipc	ra,0x0
    800051bc:	bd4080e7          	jalr	-1068(ra) # 80004d8c <iupdate>
    ip->valid = 0;
    800051c0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800051c4:	00090513          	mv	a0,s2
    800051c8:	00001097          	auipc	ra,0x1
    800051cc:	140080e7          	jalr	320(ra) # 80006308 <releasesleep>
    acquire(&itable.lock);
    800051d0:	0001c517          	auipc	a0,0x1c
    800051d4:	e1050513          	addi	a0,a0,-496 # 80020fe0 <itable>
    800051d8:	ffffc097          	auipc	ra,0xffffc
    800051dc:	ec0080e7          	jalr	-320(ra) # 80001098 <acquire>
    800051e0:	f61ff06f          	j	80005140 <iput+0x38>

00000000800051e4 <iunlockput>:
{
    800051e4:	fe010113          	addi	sp,sp,-32
    800051e8:	00113c23          	sd	ra,24(sp)
    800051ec:	00813823          	sd	s0,16(sp)
    800051f0:	00913423          	sd	s1,8(sp)
    800051f4:	02010413          	addi	s0,sp,32
    800051f8:	00050493          	mv	s1,a0
  iunlock(ip);
    800051fc:	00000097          	auipc	ra,0x0
    80005200:	db0080e7          	jalr	-592(ra) # 80004fac <iunlock>
  iput(ip);
    80005204:	00048513          	mv	a0,s1
    80005208:	00000097          	auipc	ra,0x0
    8000520c:	f00080e7          	jalr	-256(ra) # 80005108 <iput>
}
    80005210:	01813083          	ld	ra,24(sp)
    80005214:	01013403          	ld	s0,16(sp)
    80005218:	00813483          	ld	s1,8(sp)
    8000521c:	02010113          	addi	sp,sp,32
    80005220:	00008067          	ret

0000000080005224 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80005224:	0001c717          	auipc	a4,0x1c
    80005228:	da872703          	lw	a4,-600(a4) # 80020fcc <sb+0xc>
    8000522c:	00100793          	li	a5,1
    80005230:	12e7fc63          	bgeu	a5,a4,80005368 <ireclaim+0x144>
{
    80005234:	fc010113          	addi	sp,sp,-64
    80005238:	02113c23          	sd	ra,56(sp)
    8000523c:	02813823          	sd	s0,48(sp)
    80005240:	02913423          	sd	s1,40(sp)
    80005244:	03213023          	sd	s2,32(sp)
    80005248:	01313c23          	sd	s3,24(sp)
    8000524c:	01413823          	sd	s4,16(sp)
    80005250:	01513423          	sd	s5,8(sp)
    80005254:	01613023          	sd	s6,0(sp)
    80005258:	04010413          	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000525c:	00100493          	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80005260:	00050a1b          	sext.w	s4,a0
    80005264:	0001ca97          	auipc	s5,0x1c
    80005268:	d5ca8a93          	addi	s5,s5,-676 # 80020fc0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000526c:	00005b17          	auipc	s6,0x5
    80005270:	46cb0b13          	addi	s6,s6,1132 # 8000a6d8 <syscalls+0x188>
    80005274:	07c0006f          	j	800052f0 <ireclaim+0xcc>
    80005278:	00098593          	mv	a1,s3
    8000527c:	000b0513          	mv	a0,s6
    80005280:	ffffb097          	auipc	ra,0xffffb
    80005284:	428080e7          	jalr	1064(ra) # 800006a8 <printf>
      ip = iget(dev, inum);
    80005288:	00098593          	mv	a1,s3
    8000528c:	000a0513          	mv	a0,s4
    80005290:	00000097          	auipc	ra,0x0
    80005294:	85c080e7          	jalr	-1956(ra) # 80004aec <iget>
    80005298:	00050993          	mv	s3,a0
    brelse(bp);
    8000529c:	00090513          	mv	a0,s2
    800052a0:	fffff097          	auipc	ra,0xfffff
    800052a4:	358080e7          	jalr	856(ra) # 800045f8 <brelse>
    if (ip) {
    800052a8:	02098c63          	beqz	s3,800052e0 <ireclaim+0xbc>
      begin_op();
    800052ac:	00001097          	auipc	ra,0x1
    800052b0:	bfc080e7          	jalr	-1028(ra) # 80005ea8 <begin_op>
      ilock(ip);
    800052b4:	00098513          	mv	a0,s3
    800052b8:	00000097          	auipc	ra,0x0
    800052bc:	bf0080e7          	jalr	-1040(ra) # 80004ea8 <ilock>
      iunlock(ip);
    800052c0:	00098513          	mv	a0,s3
    800052c4:	00000097          	auipc	ra,0x0
    800052c8:	ce8080e7          	jalr	-792(ra) # 80004fac <iunlock>
      iput(ip);
    800052cc:	00098513          	mv	a0,s3
    800052d0:	00000097          	auipc	ra,0x0
    800052d4:	e38080e7          	jalr	-456(ra) # 80005108 <iput>
      end_op();
    800052d8:	00001097          	auipc	ra,0x1
    800052dc:	c84080e7          	jalr	-892(ra) # 80005f5c <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800052e0:	00148493          	addi	s1,s1,1
    800052e4:	00caa703          	lw	a4,12(s5)
    800052e8:	0004879b          	sext.w	a5,s1
    800052ec:	04e7fa63          	bgeu	a5,a4,80005340 <ireclaim+0x11c>
    800052f0:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800052f4:	0044d593          	srli	a1,s1,0x4
    800052f8:	018aa783          	lw	a5,24(s5)
    800052fc:	00b785bb          	addw	a1,a5,a1
    80005300:	000a0513          	mv	a0,s4
    80005304:	fffff097          	auipc	ra,0xfffff
    80005308:	158080e7          	jalr	344(ra) # 8000445c <bread>
    8000530c:	00050913          	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80005310:	05850793          	addi	a5,a0,88
    80005314:	00f9f713          	andi	a4,s3,15
    80005318:	00671713          	slli	a4,a4,0x6
    8000531c:	00e787b3          	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80005320:	00079703          	lh	a4,0(a5)
    80005324:	00070663          	beqz	a4,80005330 <ireclaim+0x10c>
    80005328:	00679783          	lh	a5,6(a5)
    8000532c:	f40786e3          	beqz	a5,80005278 <ireclaim+0x54>
    brelse(bp);
    80005330:	00090513          	mv	a0,s2
    80005334:	fffff097          	auipc	ra,0xfffff
    80005338:	2c4080e7          	jalr	708(ra) # 800045f8 <brelse>
    if (ip) {
    8000533c:	fa5ff06f          	j	800052e0 <ireclaim+0xbc>
}
    80005340:	03813083          	ld	ra,56(sp)
    80005344:	03013403          	ld	s0,48(sp)
    80005348:	02813483          	ld	s1,40(sp)
    8000534c:	02013903          	ld	s2,32(sp)
    80005350:	01813983          	ld	s3,24(sp)
    80005354:	01013a03          	ld	s4,16(sp)
    80005358:	00813a83          	ld	s5,8(sp)
    8000535c:	00013b03          	ld	s6,0(sp)
    80005360:	04010113          	addi	sp,sp,64
    80005364:	00008067          	ret
    80005368:	00008067          	ret

000000008000536c <fsinit>:
fsinit(int dev) {
    8000536c:	fd010113          	addi	sp,sp,-48
    80005370:	02113423          	sd	ra,40(sp)
    80005374:	02813023          	sd	s0,32(sp)
    80005378:	00913c23          	sd	s1,24(sp)
    8000537c:	01213823          	sd	s2,16(sp)
    80005380:	01313423          	sd	s3,8(sp)
    80005384:	03010413          	addi	s0,sp,48
    80005388:	00050493          	mv	s1,a0
  bp = bread(dev, 1);
    8000538c:	00100593          	li	a1,1
    80005390:	fffff097          	auipc	ra,0xfffff
    80005394:	0cc080e7          	jalr	204(ra) # 8000445c <bread>
    80005398:	00050913          	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000539c:	0001c997          	auipc	s3,0x1c
    800053a0:	c2498993          	addi	s3,s3,-988 # 80020fc0 <sb>
    800053a4:	02000613          	li	a2,32
    800053a8:	05850593          	addi	a1,a0,88
    800053ac:	00098513          	mv	a0,s3
    800053b0:	ffffc097          	auipc	ra,0xffffc
    800053b4:	ed4080e7          	jalr	-300(ra) # 80001284 <memmove>
  brelse(bp);
    800053b8:	00090513          	mv	a0,s2
    800053bc:	fffff097          	auipc	ra,0xfffff
    800053c0:	23c080e7          	jalr	572(ra) # 800045f8 <brelse>
  if(sb.magic != FSMAGIC)
    800053c4:	0009a703          	lw	a4,0(s3)
    800053c8:	102037b7          	lui	a5,0x10203
    800053cc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800053d0:	04f71063          	bne	a4,a5,80005410 <fsinit+0xa4>
  initlog(dev, &sb);
    800053d4:	0001c597          	auipc	a1,0x1c
    800053d8:	bec58593          	addi	a1,a1,-1044 # 80020fc0 <sb>
    800053dc:	00048513          	mv	a0,s1
    800053e0:	00001097          	auipc	ra,0x1
    800053e4:	9f0080e7          	jalr	-1552(ra) # 80005dd0 <initlog>
  ireclaim(dev);
    800053e8:	00048513          	mv	a0,s1
    800053ec:	00000097          	auipc	ra,0x0
    800053f0:	e38080e7          	jalr	-456(ra) # 80005224 <ireclaim>
}
    800053f4:	02813083          	ld	ra,40(sp)
    800053f8:	02013403          	ld	s0,32(sp)
    800053fc:	01813483          	ld	s1,24(sp)
    80005400:	01013903          	ld	s2,16(sp)
    80005404:	00813983          	ld	s3,8(sp)
    80005408:	03010113          	addi	sp,sp,48
    8000540c:	00008067          	ret
    panic("invalid file system");
    80005410:	00005517          	auipc	a0,0x5
    80005414:	2e850513          	addi	a0,a0,744 # 8000a6f8 <syscalls+0x1a8>
    80005418:	ffffb097          	auipc	ra,0xffffb
    8000541c:	668080e7          	jalr	1640(ra) # 80000a80 <panic>

0000000080005420 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80005420:	ff010113          	addi	sp,sp,-16
    80005424:	00813423          	sd	s0,8(sp)
    80005428:	01010413          	addi	s0,sp,16
  st->dev = ip->dev;
    8000542c:	00052783          	lw	a5,0(a0)
    80005430:	00f5a023          	sw	a5,0(a1)
  st->ino = ip->inum;
    80005434:	00452783          	lw	a5,4(a0)
    80005438:	00f5a223          	sw	a5,4(a1)
  st->type = ip->type;
    8000543c:	04451783          	lh	a5,68(a0)
    80005440:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80005444:	04a51783          	lh	a5,74(a0)
    80005448:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000544c:	04c56783          	lwu	a5,76(a0)
    80005450:	00f5b823          	sd	a5,16(a1)
}
    80005454:	00813403          	ld	s0,8(sp)
    80005458:	01010113          	addi	sp,sp,16
    8000545c:	00008067          	ret

0000000080005460 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80005460:	04c52783          	lw	a5,76(a0)
    80005464:	16d7e263          	bltu	a5,a3,800055c8 <readi+0x168>
{
    80005468:	f9010113          	addi	sp,sp,-112
    8000546c:	06113423          	sd	ra,104(sp)
    80005470:	06813023          	sd	s0,96(sp)
    80005474:	04913c23          	sd	s1,88(sp)
    80005478:	05213823          	sd	s2,80(sp)
    8000547c:	05313423          	sd	s3,72(sp)
    80005480:	05413023          	sd	s4,64(sp)
    80005484:	03513c23          	sd	s5,56(sp)
    80005488:	03613823          	sd	s6,48(sp)
    8000548c:	03713423          	sd	s7,40(sp)
    80005490:	03813023          	sd	s8,32(sp)
    80005494:	01913c23          	sd	s9,24(sp)
    80005498:	01a13823          	sd	s10,16(sp)
    8000549c:	01b13423          	sd	s11,8(sp)
    800054a0:	07010413          	addi	s0,sp,112
    800054a4:	00050b13          	mv	s6,a0
    800054a8:	00058b93          	mv	s7,a1
    800054ac:	00060a13          	mv	s4,a2
    800054b0:	00068493          	mv	s1,a3
    800054b4:	00070a93          	mv	s5,a4
  if(off > ip->size || off + n < off)
    800054b8:	00e6873b          	addw	a4,a3,a4
    return 0;
    800054bc:	00000513          	li	a0,0
  if(off > ip->size || off + n < off)
    800054c0:	0cd76263          	bltu	a4,a3,80005584 <readi+0x124>
  if(off + n > ip->size)
    800054c4:	00e7f463          	bgeu	a5,a4,800054cc <readi+0x6c>
    n = ip->size - off;
    800054c8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800054cc:	0e0a8a63          	beqz	s5,800055c0 <readi+0x160>
    800054d0:	00000993          	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800054d4:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800054d8:	fff00c13          	li	s8,-1
    800054dc:	0480006f          	j	80005524 <readi+0xc4>
    800054e0:	020d1d93          	slli	s11,s10,0x20
    800054e4:	020ddd93          	srli	s11,s11,0x20
    800054e8:	05890613          	addi	a2,s2,88
    800054ec:	000d8693          	mv	a3,s11
    800054f0:	00e60633          	add	a2,a2,a4
    800054f4:	000a0593          	mv	a1,s4
    800054f8:	000b8513          	mv	a0,s7
    800054fc:	ffffe097          	auipc	ra,0xffffe
    80005500:	14c080e7          	jalr	332(ra) # 80003648 <either_copyout>
    80005504:	07850663          	beq	a0,s8,80005570 <readi+0x110>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80005508:	00090513          	mv	a0,s2
    8000550c:	fffff097          	auipc	ra,0xfffff
    80005510:	0ec080e7          	jalr	236(ra) # 800045f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80005514:	013d09bb          	addw	s3,s10,s3
    80005518:	009d04bb          	addw	s1,s10,s1
    8000551c:	01ba0a33          	add	s4,s4,s11
    80005520:	0759f063          	bgeu	s3,s5,80005580 <readi+0x120>
    uint addr = bmap(ip, off/BSIZE);
    80005524:	00a4d59b          	srliw	a1,s1,0xa
    80005528:	000b0513          	mv	a0,s6
    8000552c:	fffff097          	auipc	ra,0xfffff
    80005530:	4a0080e7          	jalr	1184(ra) # 800049cc <bmap>
    80005534:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80005538:	04058463          	beqz	a1,80005580 <readi+0x120>
    bp = bread(ip->dev, addr);
    8000553c:	000b2503          	lw	a0,0(s6)
    80005540:	fffff097          	auipc	ra,0xfffff
    80005544:	f1c080e7          	jalr	-228(ra) # 8000445c <bread>
    80005548:	00050913          	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000554c:	3ff4f713          	andi	a4,s1,1023
    80005550:	40ec87bb          	subw	a5,s9,a4
    80005554:	413a86bb          	subw	a3,s5,s3
    80005558:	00078d13          	mv	s10,a5
    8000555c:	0007879b          	sext.w	a5,a5
    80005560:	0006861b          	sext.w	a2,a3
    80005564:	f6f67ee3          	bgeu	a2,a5,800054e0 <readi+0x80>
    80005568:	00068d13          	mv	s10,a3
    8000556c:	f75ff06f          	j	800054e0 <readi+0x80>
      brelse(bp);
    80005570:	00090513          	mv	a0,s2
    80005574:	fffff097          	auipc	ra,0xfffff
    80005578:	084080e7          	jalr	132(ra) # 800045f8 <brelse>
      tot = -1;
    8000557c:	fff00993          	li	s3,-1
  }
  return tot;
    80005580:	0009851b          	sext.w	a0,s3
}
    80005584:	06813083          	ld	ra,104(sp)
    80005588:	06013403          	ld	s0,96(sp)
    8000558c:	05813483          	ld	s1,88(sp)
    80005590:	05013903          	ld	s2,80(sp)
    80005594:	04813983          	ld	s3,72(sp)
    80005598:	04013a03          	ld	s4,64(sp)
    8000559c:	03813a83          	ld	s5,56(sp)
    800055a0:	03013b03          	ld	s6,48(sp)
    800055a4:	02813b83          	ld	s7,40(sp)
    800055a8:	02013c03          	ld	s8,32(sp)
    800055ac:	01813c83          	ld	s9,24(sp)
    800055b0:	01013d03          	ld	s10,16(sp)
    800055b4:	00813d83          	ld	s11,8(sp)
    800055b8:	07010113          	addi	sp,sp,112
    800055bc:	00008067          	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800055c0:	000a8993          	mv	s3,s5
    800055c4:	fbdff06f          	j	80005580 <readi+0x120>
    return 0;
    800055c8:	00000513          	li	a0,0
}
    800055cc:	00008067          	ret

00000000800055d0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800055d0:	04c52783          	lw	a5,76(a0)
    800055d4:	18d7e063          	bltu	a5,a3,80005754 <writei+0x184>
{
    800055d8:	f9010113          	addi	sp,sp,-112
    800055dc:	06113423          	sd	ra,104(sp)
    800055e0:	06813023          	sd	s0,96(sp)
    800055e4:	04913c23          	sd	s1,88(sp)
    800055e8:	05213823          	sd	s2,80(sp)
    800055ec:	05313423          	sd	s3,72(sp)
    800055f0:	05413023          	sd	s4,64(sp)
    800055f4:	03513c23          	sd	s5,56(sp)
    800055f8:	03613823          	sd	s6,48(sp)
    800055fc:	03713423          	sd	s7,40(sp)
    80005600:	03813023          	sd	s8,32(sp)
    80005604:	01913c23          	sd	s9,24(sp)
    80005608:	01a13823          	sd	s10,16(sp)
    8000560c:	01b13423          	sd	s11,8(sp)
    80005610:	07010413          	addi	s0,sp,112
    80005614:	00050a93          	mv	s5,a0
    80005618:	00058b93          	mv	s7,a1
    8000561c:	00060a13          	mv	s4,a2
    80005620:	00068913          	mv	s2,a3
    80005624:	00070b13          	mv	s6,a4
  if(off > ip->size || off + n < off)
    80005628:	00e687bb          	addw	a5,a3,a4
    8000562c:	12d7e863          	bltu	a5,a3,8000575c <writei+0x18c>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80005630:	00043737          	lui	a4,0x43
    80005634:	12f76863          	bltu	a4,a5,80005764 <writei+0x194>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80005638:	100b0a63          	beqz	s6,8000574c <writei+0x17c>
    8000563c:	00000993          	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80005640:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80005644:	fff00c13          	li	s8,-1
    80005648:	0540006f          	j	8000569c <writei+0xcc>
    8000564c:	020d1d93          	slli	s11,s10,0x20
    80005650:	020ddd93          	srli	s11,s11,0x20
    80005654:	05848513          	addi	a0,s1,88
    80005658:	000d8693          	mv	a3,s11
    8000565c:	000a0613          	mv	a2,s4
    80005660:	000b8593          	mv	a1,s7
    80005664:	00e50533          	add	a0,a0,a4
    80005668:	ffffe097          	auipc	ra,0xffffe
    8000566c:	070080e7          	jalr	112(ra) # 800036d8 <either_copyin>
    80005670:	07850c63          	beq	a0,s8,800056e8 <writei+0x118>
      brelse(bp);
      break;
    }
    log_write(bp);
    80005674:	00048513          	mv	a0,s1
    80005678:	00001097          	auipc	ra,0x1
    8000567c:	a94080e7          	jalr	-1388(ra) # 8000610c <log_write>
    brelse(bp);
    80005680:	00048513          	mv	a0,s1
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	f74080e7          	jalr	-140(ra) # 800045f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000568c:	013d09bb          	addw	s3,s10,s3
    80005690:	012d093b          	addw	s2,s10,s2
    80005694:	01ba0a33          	add	s4,s4,s11
    80005698:	0569fe63          	bgeu	s3,s6,800056f4 <writei+0x124>
    uint addr = bmap(ip, off/BSIZE);
    8000569c:	00a9559b          	srliw	a1,s2,0xa
    800056a0:	000a8513          	mv	a0,s5
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	328080e7          	jalr	808(ra) # 800049cc <bmap>
    800056ac:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800056b0:	04058263          	beqz	a1,800056f4 <writei+0x124>
    bp = bread(ip->dev, addr);
    800056b4:	000aa503          	lw	a0,0(s5)
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	da4080e7          	jalr	-604(ra) # 8000445c <bread>
    800056c0:	00050493          	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800056c4:	3ff97713          	andi	a4,s2,1023
    800056c8:	40ec87bb          	subw	a5,s9,a4
    800056cc:	413b06bb          	subw	a3,s6,s3
    800056d0:	00078d13          	mv	s10,a5
    800056d4:	0007879b          	sext.w	a5,a5
    800056d8:	0006861b          	sext.w	a2,a3
    800056dc:	f6f678e3          	bgeu	a2,a5,8000564c <writei+0x7c>
    800056e0:	00068d13          	mv	s10,a3
    800056e4:	f69ff06f          	j	8000564c <writei+0x7c>
      brelse(bp);
    800056e8:	00048513          	mv	a0,s1
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	f0c080e7          	jalr	-244(ra) # 800045f8 <brelse>
  }

  if(off > ip->size)
    800056f4:	04caa783          	lw	a5,76(s5)
    800056f8:	0127f463          	bgeu	a5,s2,80005700 <writei+0x130>
    ip->size = off;
    800056fc:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80005700:	000a8513          	mv	a0,s5
    80005704:	fffff097          	auipc	ra,0xfffff
    80005708:	688080e7          	jalr	1672(ra) # 80004d8c <iupdate>

  return tot;
    8000570c:	0009851b          	sext.w	a0,s3
}
    80005710:	06813083          	ld	ra,104(sp)
    80005714:	06013403          	ld	s0,96(sp)
    80005718:	05813483          	ld	s1,88(sp)
    8000571c:	05013903          	ld	s2,80(sp)
    80005720:	04813983          	ld	s3,72(sp)
    80005724:	04013a03          	ld	s4,64(sp)
    80005728:	03813a83          	ld	s5,56(sp)
    8000572c:	03013b03          	ld	s6,48(sp)
    80005730:	02813b83          	ld	s7,40(sp)
    80005734:	02013c03          	ld	s8,32(sp)
    80005738:	01813c83          	ld	s9,24(sp)
    8000573c:	01013d03          	ld	s10,16(sp)
    80005740:	00813d83          	ld	s11,8(sp)
    80005744:	07010113          	addi	sp,sp,112
    80005748:	00008067          	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000574c:	000b0993          	mv	s3,s6
    80005750:	fb1ff06f          	j	80005700 <writei+0x130>
    return -1;
    80005754:	fff00513          	li	a0,-1
}
    80005758:	00008067          	ret
    return -1;
    8000575c:	fff00513          	li	a0,-1
    80005760:	fb1ff06f          	j	80005710 <writei+0x140>
    return -1;
    80005764:	fff00513          	li	a0,-1
    80005768:	fa9ff06f          	j	80005710 <writei+0x140>

000000008000576c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000576c:	ff010113          	addi	sp,sp,-16
    80005770:	00113423          	sd	ra,8(sp)
    80005774:	00813023          	sd	s0,0(sp)
    80005778:	01010413          	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000577c:	00e00613          	li	a2,14
    80005780:	ffffc097          	auipc	ra,0xffffc
    80005784:	bb0080e7          	jalr	-1104(ra) # 80001330 <strncmp>
}
    80005788:	00813083          	ld	ra,8(sp)
    8000578c:	00013403          	ld	s0,0(sp)
    80005790:	01010113          	addi	sp,sp,16
    80005794:	00008067          	ret

0000000080005798 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80005798:	fc010113          	addi	sp,sp,-64
    8000579c:	02113c23          	sd	ra,56(sp)
    800057a0:	02813823          	sd	s0,48(sp)
    800057a4:	02913423          	sd	s1,40(sp)
    800057a8:	03213023          	sd	s2,32(sp)
    800057ac:	01313c23          	sd	s3,24(sp)
    800057b0:	01413823          	sd	s4,16(sp)
    800057b4:	04010413          	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800057b8:	04451703          	lh	a4,68(a0)
    800057bc:	00100793          	li	a5,1
    800057c0:	02f71263          	bne	a4,a5,800057e4 <dirlookup+0x4c>
    800057c4:	00050913          	mv	s2,a0
    800057c8:	00058993          	mv	s3,a1
    800057cc:	00060a13          	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800057d0:	04c52783          	lw	a5,76(a0)
    800057d4:	00000493          	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800057d8:	00000513          	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800057dc:	02079a63          	bnez	a5,80005810 <dirlookup+0x78>
    800057e0:	0900006f          	j	80005870 <dirlookup+0xd8>
    panic("dirlookup not DIR");
    800057e4:	00005517          	auipc	a0,0x5
    800057e8:	f2c50513          	addi	a0,a0,-212 # 8000a710 <syscalls+0x1c0>
    800057ec:	ffffb097          	auipc	ra,0xffffb
    800057f0:	294080e7          	jalr	660(ra) # 80000a80 <panic>
      panic("dirlookup read");
    800057f4:	00005517          	auipc	a0,0x5
    800057f8:	f3450513          	addi	a0,a0,-204 # 8000a728 <syscalls+0x1d8>
    800057fc:	ffffb097          	auipc	ra,0xffffb
    80005800:	284080e7          	jalr	644(ra) # 80000a80 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005804:	0104849b          	addiw	s1,s1,16
    80005808:	04c92783          	lw	a5,76(s2)
    8000580c:	06f4f063          	bgeu	s1,a5,8000586c <dirlookup+0xd4>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005810:	01000713          	li	a4,16
    80005814:	00048693          	mv	a3,s1
    80005818:	fc040613          	addi	a2,s0,-64
    8000581c:	00000593          	li	a1,0
    80005820:	00090513          	mv	a0,s2
    80005824:	00000097          	auipc	ra,0x0
    80005828:	c3c080e7          	jalr	-964(ra) # 80005460 <readi>
    8000582c:	01000793          	li	a5,16
    80005830:	fcf512e3          	bne	a0,a5,800057f4 <dirlookup+0x5c>
    if(de.inum == 0)
    80005834:	fc045783          	lhu	a5,-64(s0)
    80005838:	fc0786e3          	beqz	a5,80005804 <dirlookup+0x6c>
    if(namecmp(name, de.name) == 0){
    8000583c:	fc240593          	addi	a1,s0,-62
    80005840:	00098513          	mv	a0,s3
    80005844:	00000097          	auipc	ra,0x0
    80005848:	f28080e7          	jalr	-216(ra) # 8000576c <namecmp>
    8000584c:	fa051ce3          	bnez	a0,80005804 <dirlookup+0x6c>
      if(poff)
    80005850:	000a0463          	beqz	s4,80005858 <dirlookup+0xc0>
        *poff = off;
    80005854:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80005858:	fc045583          	lhu	a1,-64(s0)
    8000585c:	00092503          	lw	a0,0(s2)
    80005860:	fffff097          	auipc	ra,0xfffff
    80005864:	28c080e7          	jalr	652(ra) # 80004aec <iget>
    80005868:	0080006f          	j	80005870 <dirlookup+0xd8>
  return 0;
    8000586c:	00000513          	li	a0,0
}
    80005870:	03813083          	ld	ra,56(sp)
    80005874:	03013403          	ld	s0,48(sp)
    80005878:	02813483          	ld	s1,40(sp)
    8000587c:	02013903          	ld	s2,32(sp)
    80005880:	01813983          	ld	s3,24(sp)
    80005884:	01013a03          	ld	s4,16(sp)
    80005888:	04010113          	addi	sp,sp,64
    8000588c:	00008067          	ret

0000000080005890 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80005890:	fa010113          	addi	sp,sp,-96
    80005894:	04113c23          	sd	ra,88(sp)
    80005898:	04813823          	sd	s0,80(sp)
    8000589c:	04913423          	sd	s1,72(sp)
    800058a0:	05213023          	sd	s2,64(sp)
    800058a4:	03313c23          	sd	s3,56(sp)
    800058a8:	03413823          	sd	s4,48(sp)
    800058ac:	03513423          	sd	s5,40(sp)
    800058b0:	03613023          	sd	s6,32(sp)
    800058b4:	01713c23          	sd	s7,24(sp)
    800058b8:	01813823          	sd	s8,16(sp)
    800058bc:	01913423          	sd	s9,8(sp)
    800058c0:	01a13023          	sd	s10,0(sp)
    800058c4:	06010413          	addi	s0,sp,96
    800058c8:	00050493          	mv	s1,a0
    800058cc:	00058b13          	mv	s6,a1
    800058d0:	00060a93          	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800058d4:	00054703          	lbu	a4,0(a0)
    800058d8:	02f00793          	li	a5,47
    800058dc:	02f70863          	beq	a4,a5,8000590c <namex+0x7c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800058e0:	ffffd097          	auipc	ra,0xffffd
    800058e4:	e18080e7          	jalr	-488(ra) # 800026f8 <myproc>
    800058e8:	15053503          	ld	a0,336(a0)
    800058ec:	fffff097          	auipc	ra,0xfffff
    800058f0:	560080e7          	jalr	1376(ra) # 80004e4c <idup>
    800058f4:	00050a13          	mv	s4,a0
  while(*path == '/')
    800058f8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800058fc:	00d00c93          	li	s9,13
  len = path - s;
    80005900:	00000b93          	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80005904:	00100c13          	li	s8,1
    80005908:	1100006f          	j	80005a18 <namex+0x188>
    ip = iget(ROOTDEV, ROOTINO);
    8000590c:	00100593          	li	a1,1
    80005910:	00100513          	li	a0,1
    80005914:	fffff097          	auipc	ra,0xfffff
    80005918:	1d8080e7          	jalr	472(ra) # 80004aec <iget>
    8000591c:	00050a13          	mv	s4,a0
    80005920:	fd9ff06f          	j	800058f8 <namex+0x68>
      iunlockput(ip);
    80005924:	000a0513          	mv	a0,s4
    80005928:	00000097          	auipc	ra,0x0
    8000592c:	8bc080e7          	jalr	-1860(ra) # 800051e4 <iunlockput>
      return 0;
    80005930:	00000a13          	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80005934:	000a0513          	mv	a0,s4
    80005938:	05813083          	ld	ra,88(sp)
    8000593c:	05013403          	ld	s0,80(sp)
    80005940:	04813483          	ld	s1,72(sp)
    80005944:	04013903          	ld	s2,64(sp)
    80005948:	03813983          	ld	s3,56(sp)
    8000594c:	03013a03          	ld	s4,48(sp)
    80005950:	02813a83          	ld	s5,40(sp)
    80005954:	02013b03          	ld	s6,32(sp)
    80005958:	01813b83          	ld	s7,24(sp)
    8000595c:	01013c03          	ld	s8,16(sp)
    80005960:	00813c83          	ld	s9,8(sp)
    80005964:	00013d03          	ld	s10,0(sp)
    80005968:	06010113          	addi	sp,sp,96
    8000596c:	00008067          	ret
      iunlock(ip);
    80005970:	000a0513          	mv	a0,s4
    80005974:	fffff097          	auipc	ra,0xfffff
    80005978:	638080e7          	jalr	1592(ra) # 80004fac <iunlock>
      return ip;
    8000597c:	fb9ff06f          	j	80005934 <namex+0xa4>
      iunlockput(ip);
    80005980:	000a0513          	mv	a0,s4
    80005984:	00000097          	auipc	ra,0x0
    80005988:	860080e7          	jalr	-1952(ra) # 800051e4 <iunlockput>
      return 0;
    8000598c:	00098a13          	mv	s4,s3
    80005990:	fa5ff06f          	j	80005934 <namex+0xa4>
  len = path - s;
    80005994:	40998633          	sub	a2,s3,s1
    80005998:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    8000599c:	0bacde63          	bge	s9,s10,80005a58 <namex+0x1c8>
    memmove(name, s, DIRSIZ);
    800059a0:	00e00613          	li	a2,14
    800059a4:	00048593          	mv	a1,s1
    800059a8:	000a8513          	mv	a0,s5
    800059ac:	ffffc097          	auipc	ra,0xffffc
    800059b0:	8d8080e7          	jalr	-1832(ra) # 80001284 <memmove>
    800059b4:	00098493          	mv	s1,s3
  while(*path == '/')
    800059b8:	0004c783          	lbu	a5,0(s1)
    800059bc:	01279863          	bne	a5,s2,800059cc <namex+0x13c>
    path++;
    800059c0:	00148493          	addi	s1,s1,1
  while(*path == '/')
    800059c4:	0004c783          	lbu	a5,0(s1)
    800059c8:	ff278ce3          	beq	a5,s2,800059c0 <namex+0x130>
    ilock(ip);
    800059cc:	000a0513          	mv	a0,s4
    800059d0:	fffff097          	auipc	ra,0xfffff
    800059d4:	4d8080e7          	jalr	1240(ra) # 80004ea8 <ilock>
    if(ip->type != T_DIR){
    800059d8:	044a1783          	lh	a5,68(s4)
    800059dc:	f58794e3          	bne	a5,s8,80005924 <namex+0x94>
    if(nameiparent && *path == '\0'){
    800059e0:	000b0663          	beqz	s6,800059ec <namex+0x15c>
    800059e4:	0004c783          	lbu	a5,0(s1)
    800059e8:	f80784e3          	beqz	a5,80005970 <namex+0xe0>
    if((next = dirlookup(ip, name, 0)) == 0){
    800059ec:	000b8613          	mv	a2,s7
    800059f0:	000a8593          	mv	a1,s5
    800059f4:	000a0513          	mv	a0,s4
    800059f8:	00000097          	auipc	ra,0x0
    800059fc:	da0080e7          	jalr	-608(ra) # 80005798 <dirlookup>
    80005a00:	00050993          	mv	s3,a0
    80005a04:	f6050ee3          	beqz	a0,80005980 <namex+0xf0>
    iunlockput(ip);
    80005a08:	000a0513          	mv	a0,s4
    80005a0c:	fffff097          	auipc	ra,0xfffff
    80005a10:	7d8080e7          	jalr	2008(ra) # 800051e4 <iunlockput>
    ip = next;
    80005a14:	00098a13          	mv	s4,s3
  while(*path == '/')
    80005a18:	0004c783          	lbu	a5,0(s1)
    80005a1c:	01279863          	bne	a5,s2,80005a2c <namex+0x19c>
    path++;
    80005a20:	00148493          	addi	s1,s1,1
  while(*path == '/')
    80005a24:	0004c783          	lbu	a5,0(s1)
    80005a28:	ff278ce3          	beq	a5,s2,80005a20 <namex+0x190>
  if(*path == 0)
    80005a2c:	04078863          	beqz	a5,80005a7c <namex+0x1ec>
  while(*path != '/' && *path != 0)
    80005a30:	0004c783          	lbu	a5,0(s1)
    80005a34:	00048993          	mv	s3,s1
  len = path - s;
    80005a38:	000b8d13          	mv	s10,s7
    80005a3c:	000b8613          	mv	a2,s7
  while(*path != '/' && *path != 0)
    80005a40:	01278c63          	beq	a5,s2,80005a58 <namex+0x1c8>
    80005a44:	f40788e3          	beqz	a5,80005994 <namex+0x104>
    path++;
    80005a48:	00198993          	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80005a4c:	0009c783          	lbu	a5,0(s3)
    80005a50:	ff279ae3          	bne	a5,s2,80005a44 <namex+0x1b4>
    80005a54:	f41ff06f          	j	80005994 <namex+0x104>
    memmove(name, s, len);
    80005a58:	0006061b          	sext.w	a2,a2
    80005a5c:	00048593          	mv	a1,s1
    80005a60:	000a8513          	mv	a0,s5
    80005a64:	ffffc097          	auipc	ra,0xffffc
    80005a68:	820080e7          	jalr	-2016(ra) # 80001284 <memmove>
    name[len] = 0;
    80005a6c:	01aa8d33          	add	s10,s5,s10
    80005a70:	000d0023          	sb	zero,0(s10) # 1000 <_entry-0x7ffff000>
    80005a74:	00098493          	mv	s1,s3
    80005a78:	f41ff06f          	j	800059b8 <namex+0x128>
  if(nameiparent){
    80005a7c:	ea0b0ce3          	beqz	s6,80005934 <namex+0xa4>
    iput(ip);
    80005a80:	000a0513          	mv	a0,s4
    80005a84:	fffff097          	auipc	ra,0xfffff
    80005a88:	684080e7          	jalr	1668(ra) # 80005108 <iput>
    return 0;
    80005a8c:	00000a13          	li	s4,0
    80005a90:	ea5ff06f          	j	80005934 <namex+0xa4>

0000000080005a94 <dirlink>:
{
    80005a94:	fc010113          	addi	sp,sp,-64
    80005a98:	02113c23          	sd	ra,56(sp)
    80005a9c:	02813823          	sd	s0,48(sp)
    80005aa0:	02913423          	sd	s1,40(sp)
    80005aa4:	03213023          	sd	s2,32(sp)
    80005aa8:	01313c23          	sd	s3,24(sp)
    80005aac:	01413823          	sd	s4,16(sp)
    80005ab0:	04010413          	addi	s0,sp,64
    80005ab4:	00050913          	mv	s2,a0
    80005ab8:	00058a13          	mv	s4,a1
    80005abc:	00060993          	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80005ac0:	00000613          	li	a2,0
    80005ac4:	00000097          	auipc	ra,0x0
    80005ac8:	cd4080e7          	jalr	-812(ra) # 80005798 <dirlookup>
    80005acc:	0a051463          	bnez	a0,80005b74 <dirlink+0xe0>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005ad0:	04c92483          	lw	s1,76(s2)
    80005ad4:	04048063          	beqz	s1,80005b14 <dirlink+0x80>
    80005ad8:	00000493          	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005adc:	01000713          	li	a4,16
    80005ae0:	00048693          	mv	a3,s1
    80005ae4:	fc040613          	addi	a2,s0,-64
    80005ae8:	00000593          	li	a1,0
    80005aec:	00090513          	mv	a0,s2
    80005af0:	00000097          	auipc	ra,0x0
    80005af4:	970080e7          	jalr	-1680(ra) # 80005460 <readi>
    80005af8:	01000793          	li	a5,16
    80005afc:	08f51463          	bne	a0,a5,80005b84 <dirlink+0xf0>
    if(de.inum == 0)
    80005b00:	fc045783          	lhu	a5,-64(s0)
    80005b04:	00078863          	beqz	a5,80005b14 <dirlink+0x80>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005b08:	0104849b          	addiw	s1,s1,16
    80005b0c:	04c92783          	lw	a5,76(s2)
    80005b10:	fcf4e6e3          	bltu	s1,a5,80005adc <dirlink+0x48>
  strncpy(de.name, name, DIRSIZ);
    80005b14:	00e00613          	li	a2,14
    80005b18:	000a0593          	mv	a1,s4
    80005b1c:	fc240513          	addi	a0,s0,-62
    80005b20:	ffffc097          	auipc	ra,0xffffc
    80005b24:	874080e7          	jalr	-1932(ra) # 80001394 <strncpy>
  de.inum = inum;
    80005b28:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b2c:	01000713          	li	a4,16
    80005b30:	00048693          	mv	a3,s1
    80005b34:	fc040613          	addi	a2,s0,-64
    80005b38:	00000593          	li	a1,0
    80005b3c:	00090513          	mv	a0,s2
    80005b40:	00000097          	auipc	ra,0x0
    80005b44:	a90080e7          	jalr	-1392(ra) # 800055d0 <writei>
    80005b48:	ff050513          	addi	a0,a0,-16
    80005b4c:	00a03533          	snez	a0,a0
    80005b50:	40a00533          	neg	a0,a0
}
    80005b54:	03813083          	ld	ra,56(sp)
    80005b58:	03013403          	ld	s0,48(sp)
    80005b5c:	02813483          	ld	s1,40(sp)
    80005b60:	02013903          	ld	s2,32(sp)
    80005b64:	01813983          	ld	s3,24(sp)
    80005b68:	01013a03          	ld	s4,16(sp)
    80005b6c:	04010113          	addi	sp,sp,64
    80005b70:	00008067          	ret
    iput(ip);
    80005b74:	fffff097          	auipc	ra,0xfffff
    80005b78:	594080e7          	jalr	1428(ra) # 80005108 <iput>
    return -1;
    80005b7c:	fff00513          	li	a0,-1
    80005b80:	fd5ff06f          	j	80005b54 <dirlink+0xc0>
      panic("dirlink read");
    80005b84:	00005517          	auipc	a0,0x5
    80005b88:	bb450513          	addi	a0,a0,-1100 # 8000a738 <syscalls+0x1e8>
    80005b8c:	ffffb097          	auipc	ra,0xffffb
    80005b90:	ef4080e7          	jalr	-268(ra) # 80000a80 <panic>

0000000080005b94 <namei>:

struct inode*
namei(char *path)
{
    80005b94:	fe010113          	addi	sp,sp,-32
    80005b98:	00113c23          	sd	ra,24(sp)
    80005b9c:	00813823          	sd	s0,16(sp)
    80005ba0:	02010413          	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80005ba4:	fe040613          	addi	a2,s0,-32
    80005ba8:	00000593          	li	a1,0
    80005bac:	00000097          	auipc	ra,0x0
    80005bb0:	ce4080e7          	jalr	-796(ra) # 80005890 <namex>
}
    80005bb4:	01813083          	ld	ra,24(sp)
    80005bb8:	01013403          	ld	s0,16(sp)
    80005bbc:	02010113          	addi	sp,sp,32
    80005bc0:	00008067          	ret

0000000080005bc4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80005bc4:	ff010113          	addi	sp,sp,-16
    80005bc8:	00113423          	sd	ra,8(sp)
    80005bcc:	00813023          	sd	s0,0(sp)
    80005bd0:	01010413          	addi	s0,sp,16
    80005bd4:	00058613          	mv	a2,a1
  return namex(path, 1, name);
    80005bd8:	00100593          	li	a1,1
    80005bdc:	00000097          	auipc	ra,0x0
    80005be0:	cb4080e7          	jalr	-844(ra) # 80005890 <namex>
}
    80005be4:	00813083          	ld	ra,8(sp)
    80005be8:	00013403          	ld	s0,0(sp)
    80005bec:	01010113          	addi	sp,sp,16
    80005bf0:	00008067          	ret

0000000080005bf4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80005bf4:	fe010113          	addi	sp,sp,-32
    80005bf8:	00113c23          	sd	ra,24(sp)
    80005bfc:	00813823          	sd	s0,16(sp)
    80005c00:	00913423          	sd	s1,8(sp)
    80005c04:	01213023          	sd	s2,0(sp)
    80005c08:	02010413          	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80005c0c:	0001d917          	auipc	s2,0x1d
    80005c10:	e7c90913          	addi	s2,s2,-388 # 80022a88 <log>
    80005c14:	01892583          	lw	a1,24(s2)
    80005c18:	02492503          	lw	a0,36(s2)
    80005c1c:	fffff097          	auipc	ra,0xfffff
    80005c20:	840080e7          	jalr	-1984(ra) # 8000445c <bread>
    80005c24:	00050493          	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80005c28:	02892683          	lw	a3,40(s2)
    80005c2c:	04d52c23          	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80005c30:	02d05e63          	blez	a3,80005c6c <write_head+0x78>
    80005c34:	0001d797          	auipc	a5,0x1d
    80005c38:	e8078793          	addi	a5,a5,-384 # 80022ab4 <log+0x2c>
    80005c3c:	05c50713          	addi	a4,a0,92
    80005c40:	fff6869b          	addiw	a3,a3,-1
    80005c44:	02069613          	slli	a2,a3,0x20
    80005c48:	01e65693          	srli	a3,a2,0x1e
    80005c4c:	0001d617          	auipc	a2,0x1d
    80005c50:	e6c60613          	addi	a2,a2,-404 # 80022ab8 <log+0x30>
    80005c54:	00c686b3          	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80005c58:	0007a603          	lw	a2,0(a5)
    80005c5c:	00c72023          	sw	a2,0(a4) # 43000 <_entry-0x7ffbd000>
  for (i = 0; i < log.lh.n; i++) {
    80005c60:	00478793          	addi	a5,a5,4
    80005c64:	00470713          	addi	a4,a4,4
    80005c68:	fed798e3          	bne	a5,a3,80005c58 <write_head+0x64>
  }
  bwrite(buf);
    80005c6c:	00048513          	mv	a0,s1
    80005c70:	fffff097          	auipc	ra,0xfffff
    80005c74:	92c080e7          	jalr	-1748(ra) # 8000459c <bwrite>
  brelse(buf);
    80005c78:	00048513          	mv	a0,s1
    80005c7c:	fffff097          	auipc	ra,0xfffff
    80005c80:	97c080e7          	jalr	-1668(ra) # 800045f8 <brelse>
}
    80005c84:	01813083          	ld	ra,24(sp)
    80005c88:	01013403          	ld	s0,16(sp)
    80005c8c:	00813483          	ld	s1,8(sp)
    80005c90:	00013903          	ld	s2,0(sp)
    80005c94:	02010113          	addi	sp,sp,32
    80005c98:	00008067          	ret

0000000080005c9c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80005c9c:	0001d797          	auipc	a5,0x1d
    80005ca0:	e147a783          	lw	a5,-492(a5) # 80022ab0 <log+0x28>
    80005ca4:	12f05463          	blez	a5,80005dcc <install_trans+0x130>
{
    80005ca8:	fb010113          	addi	sp,sp,-80
    80005cac:	04113423          	sd	ra,72(sp)
    80005cb0:	04813023          	sd	s0,64(sp)
    80005cb4:	02913c23          	sd	s1,56(sp)
    80005cb8:	03213823          	sd	s2,48(sp)
    80005cbc:	03313423          	sd	s3,40(sp)
    80005cc0:	03413023          	sd	s4,32(sp)
    80005cc4:	01513c23          	sd	s5,24(sp)
    80005cc8:	01613823          	sd	s6,16(sp)
    80005ccc:	01713423          	sd	s7,8(sp)
    80005cd0:	05010413          	addi	s0,sp,80
    80005cd4:	00050b13          	mv	s6,a0
    80005cd8:	0001da97          	auipc	s5,0x1d
    80005cdc:	ddca8a93          	addi	s5,s5,-548 # 80022ab4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005ce0:	00000993          	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80005ce4:	00005b97          	auipc	s7,0x5
    80005ce8:	a64b8b93          	addi	s7,s7,-1436 # 8000a748 <syscalls+0x1f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005cec:	0001da17          	auipc	s4,0x1d
    80005cf0:	d9ca0a13          	addi	s4,s4,-612 # 80022a88 <log>
    80005cf4:	0440006f          	j	80005d38 <install_trans+0x9c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80005cf8:	000aa603          	lw	a2,0(s5)
    80005cfc:	00098593          	mv	a1,s3
    80005d00:	000b8513          	mv	a0,s7
    80005d04:	ffffb097          	auipc	ra,0xffffb
    80005d08:	9a4080e7          	jalr	-1628(ra) # 800006a8 <printf>
    80005d0c:	0300006f          	j	80005d3c <install_trans+0xa0>
    brelse(lbuf);
    80005d10:	00090513          	mv	a0,s2
    80005d14:	fffff097          	auipc	ra,0xfffff
    80005d18:	8e4080e7          	jalr	-1820(ra) # 800045f8 <brelse>
    brelse(dbuf);
    80005d1c:	00048513          	mv	a0,s1
    80005d20:	fffff097          	auipc	ra,0xfffff
    80005d24:	8d8080e7          	jalr	-1832(ra) # 800045f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005d28:	0019899b          	addiw	s3,s3,1
    80005d2c:	004a8a93          	addi	s5,s5,4
    80005d30:	028a2783          	lw	a5,40(s4)
    80005d34:	06f9d663          	bge	s3,a5,80005da0 <install_trans+0x104>
    if(recovering) {
    80005d38:	fc0b10e3          	bnez	s6,80005cf8 <install_trans+0x5c>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005d3c:	018a2583          	lw	a1,24(s4)
    80005d40:	013585bb          	addw	a1,a1,s3
    80005d44:	0015859b          	addiw	a1,a1,1
    80005d48:	024a2503          	lw	a0,36(s4)
    80005d4c:	ffffe097          	auipc	ra,0xffffe
    80005d50:	710080e7          	jalr	1808(ra) # 8000445c <bread>
    80005d54:	00050913          	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80005d58:	000aa583          	lw	a1,0(s5)
    80005d5c:	024a2503          	lw	a0,36(s4)
    80005d60:	ffffe097          	auipc	ra,0xffffe
    80005d64:	6fc080e7          	jalr	1788(ra) # 8000445c <bread>
    80005d68:	00050493          	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005d6c:	40000613          	li	a2,1024
    80005d70:	05890593          	addi	a1,s2,88
    80005d74:	05850513          	addi	a0,a0,88
    80005d78:	ffffb097          	auipc	ra,0xffffb
    80005d7c:	50c080e7          	jalr	1292(ra) # 80001284 <memmove>
    bwrite(dbuf);  // write dst to disk
    80005d80:	00048513          	mv	a0,s1
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	818080e7          	jalr	-2024(ra) # 8000459c <bwrite>
    if(recovering == 0)
    80005d8c:	f80b12e3          	bnez	s6,80005d10 <install_trans+0x74>
      bunpin(dbuf);
    80005d90:	00048513          	mv	a0,s1
    80005d94:	fffff097          	auipc	ra,0xfffff
    80005d98:	994080e7          	jalr	-1644(ra) # 80004728 <bunpin>
    80005d9c:	f75ff06f          	j	80005d10 <install_trans+0x74>
}
    80005da0:	04813083          	ld	ra,72(sp)
    80005da4:	04013403          	ld	s0,64(sp)
    80005da8:	03813483          	ld	s1,56(sp)
    80005dac:	03013903          	ld	s2,48(sp)
    80005db0:	02813983          	ld	s3,40(sp)
    80005db4:	02013a03          	ld	s4,32(sp)
    80005db8:	01813a83          	ld	s5,24(sp)
    80005dbc:	01013b03          	ld	s6,16(sp)
    80005dc0:	00813b83          	ld	s7,8(sp)
    80005dc4:	05010113          	addi	sp,sp,80
    80005dc8:	00008067          	ret
    80005dcc:	00008067          	ret

0000000080005dd0 <initlog>:
{
    80005dd0:	fd010113          	addi	sp,sp,-48
    80005dd4:	02113423          	sd	ra,40(sp)
    80005dd8:	02813023          	sd	s0,32(sp)
    80005ddc:	00913c23          	sd	s1,24(sp)
    80005de0:	01213823          	sd	s2,16(sp)
    80005de4:	01313423          	sd	s3,8(sp)
    80005de8:	03010413          	addi	s0,sp,48
    80005dec:	00050913          	mv	s2,a0
    80005df0:	00058993          	mv	s3,a1
  initlock(&log.lock, "log");
    80005df4:	0001d497          	auipc	s1,0x1d
    80005df8:	c9448493          	addi	s1,s1,-876 # 80022a88 <log>
    80005dfc:	00005597          	auipc	a1,0x5
    80005e00:	96c58593          	addi	a1,a1,-1684 # 8000a768 <syscalls+0x218>
    80005e04:	00048513          	mv	a0,s1
    80005e08:	ffffb097          	auipc	ra,0xffffb
    80005e0c:	1ac080e7          	jalr	428(ra) # 80000fb4 <initlock>
  log.start = sb->logstart;
    80005e10:	0149a583          	lw	a1,20(s3)
    80005e14:	00b4ac23          	sw	a1,24(s1)
  log.dev = dev;
    80005e18:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80005e1c:	00090513          	mv	a0,s2
    80005e20:	ffffe097          	auipc	ra,0xffffe
    80005e24:	63c080e7          	jalr	1596(ra) # 8000445c <bread>
  log.lh.n = lh->n;
    80005e28:	05852683          	lw	a3,88(a0)
    80005e2c:	02d4a423          	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80005e30:	02d05c63          	blez	a3,80005e68 <initlog+0x98>
    80005e34:	05c50793          	addi	a5,a0,92
    80005e38:	0001d717          	auipc	a4,0x1d
    80005e3c:	c7c70713          	addi	a4,a4,-900 # 80022ab4 <log+0x2c>
    80005e40:	fff6869b          	addiw	a3,a3,-1
    80005e44:	02069613          	slli	a2,a3,0x20
    80005e48:	01e65693          	srli	a3,a2,0x1e
    80005e4c:	06050613          	addi	a2,a0,96
    80005e50:	00c686b3          	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80005e54:	0007a603          	lw	a2,0(a5)
    80005e58:	00c72023          	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005e5c:	00478793          	addi	a5,a5,4
    80005e60:	00470713          	addi	a4,a4,4
    80005e64:	fed798e3          	bne	a5,a3,80005e54 <initlog+0x84>
  brelse(buf);
    80005e68:	ffffe097          	auipc	ra,0xffffe
    80005e6c:	790080e7          	jalr	1936(ra) # 800045f8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80005e70:	00100513          	li	a0,1
    80005e74:	00000097          	auipc	ra,0x0
    80005e78:	e28080e7          	jalr	-472(ra) # 80005c9c <install_trans>
  log.lh.n = 0;
    80005e7c:	0001d797          	auipc	a5,0x1d
    80005e80:	c207aa23          	sw	zero,-972(a5) # 80022ab0 <log+0x28>
  write_head(); // clear the log
    80005e84:	00000097          	auipc	ra,0x0
    80005e88:	d70080e7          	jalr	-656(ra) # 80005bf4 <write_head>
}
    80005e8c:	02813083          	ld	ra,40(sp)
    80005e90:	02013403          	ld	s0,32(sp)
    80005e94:	01813483          	ld	s1,24(sp)
    80005e98:	01013903          	ld	s2,16(sp)
    80005e9c:	00813983          	ld	s3,8(sp)
    80005ea0:	03010113          	addi	sp,sp,48
    80005ea4:	00008067          	ret

0000000080005ea8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80005ea8:	fe010113          	addi	sp,sp,-32
    80005eac:	00113c23          	sd	ra,24(sp)
    80005eb0:	00813823          	sd	s0,16(sp)
    80005eb4:	00913423          	sd	s1,8(sp)
    80005eb8:	01213023          	sd	s2,0(sp)
    80005ebc:	02010413          	addi	s0,sp,32
  acquire(&log.lock);
    80005ec0:	0001d517          	auipc	a0,0x1d
    80005ec4:	bc850513          	addi	a0,a0,-1080 # 80022a88 <log>
    80005ec8:	ffffb097          	auipc	ra,0xffffb
    80005ecc:	1d0080e7          	jalr	464(ra) # 80001098 <acquire>
  while(1){
    if(log.committing){
    80005ed0:	0001d497          	auipc	s1,0x1d
    80005ed4:	bb848493          	addi	s1,s1,-1096 # 80022a88 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80005ed8:	01e00913          	li	s2,30
    80005edc:	0140006f          	j	80005ef0 <begin_op+0x48>
      sleep(&log, &log.lock);
    80005ee0:	00048593          	mv	a1,s1
    80005ee4:	00048513          	mv	a0,s1
    80005ee8:	ffffd097          	auipc	ra,0xffffd
    80005eec:	1c8080e7          	jalr	456(ra) # 800030b0 <sleep>
    if(log.committing){
    80005ef0:	0204a783          	lw	a5,32(s1)
    80005ef4:	fe0796e3          	bnez	a5,80005ee0 <begin_op+0x38>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80005ef8:	01c4a703          	lw	a4,28(s1)
    80005efc:	0017071b          	addiw	a4,a4,1
    80005f00:	0007069b          	sext.w	a3,a4
    80005f04:	0027179b          	slliw	a5,a4,0x2
    80005f08:	00e787bb          	addw	a5,a5,a4
    80005f0c:	0017979b          	slliw	a5,a5,0x1
    80005f10:	0284a703          	lw	a4,40(s1)
    80005f14:	00e787bb          	addw	a5,a5,a4
    80005f18:	00f95c63          	bge	s2,a5,80005f30 <begin_op+0x88>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80005f1c:	00048593          	mv	a1,s1
    80005f20:	00048513          	mv	a0,s1
    80005f24:	ffffd097          	auipc	ra,0xffffd
    80005f28:	18c080e7          	jalr	396(ra) # 800030b0 <sleep>
    80005f2c:	fc5ff06f          	j	80005ef0 <begin_op+0x48>
    } else {
      log.outstanding += 1;
    80005f30:	0001d517          	auipc	a0,0x1d
    80005f34:	b5850513          	addi	a0,a0,-1192 # 80022a88 <log>
    80005f38:	00d52e23          	sw	a3,28(a0)
      release(&log.lock);
    80005f3c:	ffffb097          	auipc	ra,0xffffb
    80005f40:	254080e7          	jalr	596(ra) # 80001190 <release>
      break;
    }
  }
}
    80005f44:	01813083          	ld	ra,24(sp)
    80005f48:	01013403          	ld	s0,16(sp)
    80005f4c:	00813483          	ld	s1,8(sp)
    80005f50:	00013903          	ld	s2,0(sp)
    80005f54:	02010113          	addi	sp,sp,32
    80005f58:	00008067          	ret

0000000080005f5c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80005f5c:	fc010113          	addi	sp,sp,-64
    80005f60:	02113c23          	sd	ra,56(sp)
    80005f64:	02813823          	sd	s0,48(sp)
    80005f68:	02913423          	sd	s1,40(sp)
    80005f6c:	03213023          	sd	s2,32(sp)
    80005f70:	01313c23          	sd	s3,24(sp)
    80005f74:	01413823          	sd	s4,16(sp)
    80005f78:	01513423          	sd	s5,8(sp)
    80005f7c:	04010413          	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80005f80:	0001d497          	auipc	s1,0x1d
    80005f84:	b0848493          	addi	s1,s1,-1272 # 80022a88 <log>
    80005f88:	00048513          	mv	a0,s1
    80005f8c:	ffffb097          	auipc	ra,0xffffb
    80005f90:	10c080e7          	jalr	268(ra) # 80001098 <acquire>
  log.outstanding -= 1;
    80005f94:	01c4a783          	lw	a5,28(s1)
    80005f98:	fff7879b          	addiw	a5,a5,-1
    80005f9c:	0007891b          	sext.w	s2,a5
    80005fa0:	00f4ae23          	sw	a5,28(s1)
  if(log.committing)
    80005fa4:	0204a783          	lw	a5,32(s1)
    80005fa8:	06079063          	bnez	a5,80006008 <end_op+0xac>
    panic("log.committing");
  if(log.outstanding == 0){
    80005fac:	06091663          	bnez	s2,80006018 <end_op+0xbc>
    do_commit = 1;
    log.committing = 1;
    80005fb0:	0001d497          	auipc	s1,0x1d
    80005fb4:	ad848493          	addi	s1,s1,-1320 # 80022a88 <log>
    80005fb8:	00100793          	li	a5,1
    80005fbc:	02f4a023          	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80005fc0:	00048513          	mv	a0,s1
    80005fc4:	ffffb097          	auipc	ra,0xffffb
    80005fc8:	1cc080e7          	jalr	460(ra) # 80001190 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80005fcc:	0284a783          	lw	a5,40(s1)
    80005fd0:	08f04663          	bgtz	a5,8000605c <end_op+0x100>
    acquire(&log.lock);
    80005fd4:	0001d497          	auipc	s1,0x1d
    80005fd8:	ab448493          	addi	s1,s1,-1356 # 80022a88 <log>
    80005fdc:	00048513          	mv	a0,s1
    80005fe0:	ffffb097          	auipc	ra,0xffffb
    80005fe4:	0b8080e7          	jalr	184(ra) # 80001098 <acquire>
    log.committing = 0;
    80005fe8:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80005fec:	00048513          	mv	a0,s1
    80005ff0:	ffffd097          	auipc	ra,0xffffd
    80005ff4:	150080e7          	jalr	336(ra) # 80003140 <wakeup>
    release(&log.lock);
    80005ff8:	00048513          	mv	a0,s1
    80005ffc:	ffffb097          	auipc	ra,0xffffb
    80006000:	194080e7          	jalr	404(ra) # 80001190 <release>
}
    80006004:	0340006f          	j	80006038 <end_op+0xdc>
    panic("log.committing");
    80006008:	00004517          	auipc	a0,0x4
    8000600c:	76850513          	addi	a0,a0,1896 # 8000a770 <syscalls+0x220>
    80006010:	ffffb097          	auipc	ra,0xffffb
    80006014:	a70080e7          	jalr	-1424(ra) # 80000a80 <panic>
    wakeup(&log);
    80006018:	0001d497          	auipc	s1,0x1d
    8000601c:	a7048493          	addi	s1,s1,-1424 # 80022a88 <log>
    80006020:	00048513          	mv	a0,s1
    80006024:	ffffd097          	auipc	ra,0xffffd
    80006028:	11c080e7          	jalr	284(ra) # 80003140 <wakeup>
  release(&log.lock);
    8000602c:	00048513          	mv	a0,s1
    80006030:	ffffb097          	auipc	ra,0xffffb
    80006034:	160080e7          	jalr	352(ra) # 80001190 <release>
}
    80006038:	03813083          	ld	ra,56(sp)
    8000603c:	03013403          	ld	s0,48(sp)
    80006040:	02813483          	ld	s1,40(sp)
    80006044:	02013903          	ld	s2,32(sp)
    80006048:	01813983          	ld	s3,24(sp)
    8000604c:	01013a03          	ld	s4,16(sp)
    80006050:	00813a83          	ld	s5,8(sp)
    80006054:	04010113          	addi	sp,sp,64
    80006058:	00008067          	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000605c:	0001da97          	auipc	s5,0x1d
    80006060:	a58a8a93          	addi	s5,s5,-1448 # 80022ab4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80006064:	0001da17          	auipc	s4,0x1d
    80006068:	a24a0a13          	addi	s4,s4,-1500 # 80022a88 <log>
    8000606c:	018a2583          	lw	a1,24(s4)
    80006070:	012585bb          	addw	a1,a1,s2
    80006074:	0015859b          	addiw	a1,a1,1
    80006078:	024a2503          	lw	a0,36(s4)
    8000607c:	ffffe097          	auipc	ra,0xffffe
    80006080:	3e0080e7          	jalr	992(ra) # 8000445c <bread>
    80006084:	00050493          	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80006088:	000aa583          	lw	a1,0(s5)
    8000608c:	024a2503          	lw	a0,36(s4)
    80006090:	ffffe097          	auipc	ra,0xffffe
    80006094:	3cc080e7          	jalr	972(ra) # 8000445c <bread>
    80006098:	00050993          	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000609c:	40000613          	li	a2,1024
    800060a0:	05850593          	addi	a1,a0,88
    800060a4:	05848513          	addi	a0,s1,88
    800060a8:	ffffb097          	auipc	ra,0xffffb
    800060ac:	1dc080e7          	jalr	476(ra) # 80001284 <memmove>
    bwrite(to);  // write the log
    800060b0:	00048513          	mv	a0,s1
    800060b4:	ffffe097          	auipc	ra,0xffffe
    800060b8:	4e8080e7          	jalr	1256(ra) # 8000459c <bwrite>
    brelse(from);
    800060bc:	00098513          	mv	a0,s3
    800060c0:	ffffe097          	auipc	ra,0xffffe
    800060c4:	538080e7          	jalr	1336(ra) # 800045f8 <brelse>
    brelse(to);
    800060c8:	00048513          	mv	a0,s1
    800060cc:	ffffe097          	auipc	ra,0xffffe
    800060d0:	52c080e7          	jalr	1324(ra) # 800045f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800060d4:	0019091b          	addiw	s2,s2,1
    800060d8:	004a8a93          	addi	s5,s5,4
    800060dc:	028a2783          	lw	a5,40(s4)
    800060e0:	f8f946e3          	blt	s2,a5,8000606c <end_op+0x110>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800060e4:	00000097          	auipc	ra,0x0
    800060e8:	b10080e7          	jalr	-1264(ra) # 80005bf4 <write_head>
    install_trans(0); // Now install writes to home locations
    800060ec:	00000513          	li	a0,0
    800060f0:	00000097          	auipc	ra,0x0
    800060f4:	bac080e7          	jalr	-1108(ra) # 80005c9c <install_trans>
    log.lh.n = 0;
    800060f8:	0001d797          	auipc	a5,0x1d
    800060fc:	9a07ac23          	sw	zero,-1608(a5) # 80022ab0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80006100:	00000097          	auipc	ra,0x0
    80006104:	af4080e7          	jalr	-1292(ra) # 80005bf4 <write_head>
    80006108:	ecdff06f          	j	80005fd4 <end_op+0x78>

000000008000610c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000610c:	fe010113          	addi	sp,sp,-32
    80006110:	00113c23          	sd	ra,24(sp)
    80006114:	00813823          	sd	s0,16(sp)
    80006118:	00913423          	sd	s1,8(sp)
    8000611c:	01213023          	sd	s2,0(sp)
    80006120:	02010413          	addi	s0,sp,32
    80006124:	00050493          	mv	s1,a0
  int i;

  acquire(&log.lock);
    80006128:	0001d917          	auipc	s2,0x1d
    8000612c:	96090913          	addi	s2,s2,-1696 # 80022a88 <log>
    80006130:	00090513          	mv	a0,s2
    80006134:	ffffb097          	auipc	ra,0xffffb
    80006138:	f64080e7          	jalr	-156(ra) # 80001098 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000613c:	02892603          	lw	a2,40(s2)
    80006140:	01d00793          	li	a5,29
    80006144:	06c7ce63          	blt	a5,a2,800061c0 <log_write+0xb4>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80006148:	0001d797          	auipc	a5,0x1d
    8000614c:	95c7a783          	lw	a5,-1700(a5) # 80022aa4 <log+0x1c>
    80006150:	08f05063          	blez	a5,800061d0 <log_write+0xc4>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80006154:	00000793          	li	a5,0
    80006158:	08c05463          	blez	a2,800061e0 <log_write+0xd4>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000615c:	00c4a583          	lw	a1,12(s1)
    80006160:	0001d717          	auipc	a4,0x1d
    80006164:	95470713          	addi	a4,a4,-1708 # 80022ab4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80006168:	00000793          	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000616c:	00072683          	lw	a3,0(a4)
    80006170:	06b68863          	beq	a3,a1,800061e0 <log_write+0xd4>
  for (i = 0; i < log.lh.n; i++) {
    80006174:	0017879b          	addiw	a5,a5,1
    80006178:	00470713          	addi	a4,a4,4
    8000617c:	fef618e3          	bne	a2,a5,8000616c <log_write+0x60>
      break;
  }
  log.lh.block[i] = b->blockno;
    80006180:	00860613          	addi	a2,a2,8
    80006184:	00261613          	slli	a2,a2,0x2
    80006188:	0001d797          	auipc	a5,0x1d
    8000618c:	90078793          	addi	a5,a5,-1792 # 80022a88 <log>
    80006190:	00c787b3          	add	a5,a5,a2
    80006194:	00c4a703          	lw	a4,12(s1)
    80006198:	00e7a623          	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000619c:	00048513          	mv	a0,s1
    800061a0:	ffffe097          	auipc	ra,0xffffe
    800061a4:	530080e7          	jalr	1328(ra) # 800046d0 <bpin>
    log.lh.n++;
    800061a8:	0001d717          	auipc	a4,0x1d
    800061ac:	8e070713          	addi	a4,a4,-1824 # 80022a88 <log>
    800061b0:	02872783          	lw	a5,40(a4)
    800061b4:	0017879b          	addiw	a5,a5,1
    800061b8:	02f72423          	sw	a5,40(a4)
    800061bc:	0440006f          	j	80006200 <log_write+0xf4>
    panic("too big a transaction");
    800061c0:	00004517          	auipc	a0,0x4
    800061c4:	5c050513          	addi	a0,a0,1472 # 8000a780 <syscalls+0x230>
    800061c8:	ffffb097          	auipc	ra,0xffffb
    800061cc:	8b8080e7          	jalr	-1864(ra) # 80000a80 <panic>
    panic("log_write outside of trans");
    800061d0:	00004517          	auipc	a0,0x4
    800061d4:	5c850513          	addi	a0,a0,1480 # 8000a798 <syscalls+0x248>
    800061d8:	ffffb097          	auipc	ra,0xffffb
    800061dc:	8a8080e7          	jalr	-1880(ra) # 80000a80 <panic>
  log.lh.block[i] = b->blockno;
    800061e0:	00878693          	addi	a3,a5,8
    800061e4:	00269693          	slli	a3,a3,0x2
    800061e8:	0001d717          	auipc	a4,0x1d
    800061ec:	8a070713          	addi	a4,a4,-1888 # 80022a88 <log>
    800061f0:	00d70733          	add	a4,a4,a3
    800061f4:	00c4a683          	lw	a3,12(s1)
    800061f8:	00d72623          	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800061fc:	faf600e3          	beq	a2,a5,8000619c <log_write+0x90>
  }
  release(&log.lock);
    80006200:	0001d517          	auipc	a0,0x1d
    80006204:	88850513          	addi	a0,a0,-1912 # 80022a88 <log>
    80006208:	ffffb097          	auipc	ra,0xffffb
    8000620c:	f88080e7          	jalr	-120(ra) # 80001190 <release>
}
    80006210:	01813083          	ld	ra,24(sp)
    80006214:	01013403          	ld	s0,16(sp)
    80006218:	00813483          	ld	s1,8(sp)
    8000621c:	00013903          	ld	s2,0(sp)
    80006220:	02010113          	addi	sp,sp,32
    80006224:	00008067          	ret

0000000080006228 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80006228:	fe010113          	addi	sp,sp,-32
    8000622c:	00113c23          	sd	ra,24(sp)
    80006230:	00813823          	sd	s0,16(sp)
    80006234:	00913423          	sd	s1,8(sp)
    80006238:	01213023          	sd	s2,0(sp)
    8000623c:	02010413          	addi	s0,sp,32
    80006240:	00050493          	mv	s1,a0
    80006244:	00058913          	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80006248:	00004597          	auipc	a1,0x4
    8000624c:	57058593          	addi	a1,a1,1392 # 8000a7b8 <syscalls+0x268>
    80006250:	00850513          	addi	a0,a0,8
    80006254:	ffffb097          	auipc	ra,0xffffb
    80006258:	d60080e7          	jalr	-672(ra) # 80000fb4 <initlock>
  lk->name = name;
    8000625c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80006260:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80006264:	0204a423          	sw	zero,40(s1)
}
    80006268:	01813083          	ld	ra,24(sp)
    8000626c:	01013403          	ld	s0,16(sp)
    80006270:	00813483          	ld	s1,8(sp)
    80006274:	00013903          	ld	s2,0(sp)
    80006278:	02010113          	addi	sp,sp,32
    8000627c:	00008067          	ret

0000000080006280 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80006280:	fe010113          	addi	sp,sp,-32
    80006284:	00113c23          	sd	ra,24(sp)
    80006288:	00813823          	sd	s0,16(sp)
    8000628c:	00913423          	sd	s1,8(sp)
    80006290:	01213023          	sd	s2,0(sp)
    80006294:	02010413          	addi	s0,sp,32
    80006298:	00050493          	mv	s1,a0
  acquire(&lk->lk);
    8000629c:	00850913          	addi	s2,a0,8
    800062a0:	00090513          	mv	a0,s2
    800062a4:	ffffb097          	auipc	ra,0xffffb
    800062a8:	df4080e7          	jalr	-524(ra) # 80001098 <acquire>
  while (lk->locked) {
    800062ac:	0004a783          	lw	a5,0(s1)
    800062b0:	00078e63          	beqz	a5,800062cc <acquiresleep+0x4c>
    sleep(lk, &lk->lk);
    800062b4:	00090593          	mv	a1,s2
    800062b8:	00048513          	mv	a0,s1
    800062bc:	ffffd097          	auipc	ra,0xffffd
    800062c0:	df4080e7          	jalr	-524(ra) # 800030b0 <sleep>
  while (lk->locked) {
    800062c4:	0004a783          	lw	a5,0(s1)
    800062c8:	fe0796e3          	bnez	a5,800062b4 <acquiresleep+0x34>
  }
  lk->locked = 1;
    800062cc:	00100793          	li	a5,1
    800062d0:	00f4a023          	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800062d4:	ffffc097          	auipc	ra,0xffffc
    800062d8:	424080e7          	jalr	1060(ra) # 800026f8 <myproc>
    800062dc:	03052783          	lw	a5,48(a0)
    800062e0:	02f4a423          	sw	a5,40(s1)
  release(&lk->lk);
    800062e4:	00090513          	mv	a0,s2
    800062e8:	ffffb097          	auipc	ra,0xffffb
    800062ec:	ea8080e7          	jalr	-344(ra) # 80001190 <release>
}
    800062f0:	01813083          	ld	ra,24(sp)
    800062f4:	01013403          	ld	s0,16(sp)
    800062f8:	00813483          	ld	s1,8(sp)
    800062fc:	00013903          	ld	s2,0(sp)
    80006300:	02010113          	addi	sp,sp,32
    80006304:	00008067          	ret

0000000080006308 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80006308:	fe010113          	addi	sp,sp,-32
    8000630c:	00113c23          	sd	ra,24(sp)
    80006310:	00813823          	sd	s0,16(sp)
    80006314:	00913423          	sd	s1,8(sp)
    80006318:	01213023          	sd	s2,0(sp)
    8000631c:	02010413          	addi	s0,sp,32
    80006320:	00050493          	mv	s1,a0
  acquire(&lk->lk);
    80006324:	00850913          	addi	s2,a0,8
    80006328:	00090513          	mv	a0,s2
    8000632c:	ffffb097          	auipc	ra,0xffffb
    80006330:	d6c080e7          	jalr	-660(ra) # 80001098 <acquire>
  lk->locked = 0;
    80006334:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80006338:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000633c:	00048513          	mv	a0,s1
    80006340:	ffffd097          	auipc	ra,0xffffd
    80006344:	e00080e7          	jalr	-512(ra) # 80003140 <wakeup>
  release(&lk->lk);
    80006348:	00090513          	mv	a0,s2
    8000634c:	ffffb097          	auipc	ra,0xffffb
    80006350:	e44080e7          	jalr	-444(ra) # 80001190 <release>
}
    80006354:	01813083          	ld	ra,24(sp)
    80006358:	01013403          	ld	s0,16(sp)
    8000635c:	00813483          	ld	s1,8(sp)
    80006360:	00013903          	ld	s2,0(sp)
    80006364:	02010113          	addi	sp,sp,32
    80006368:	00008067          	ret

000000008000636c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000636c:	fd010113          	addi	sp,sp,-48
    80006370:	02113423          	sd	ra,40(sp)
    80006374:	02813023          	sd	s0,32(sp)
    80006378:	00913c23          	sd	s1,24(sp)
    8000637c:	01213823          	sd	s2,16(sp)
    80006380:	01313423          	sd	s3,8(sp)
    80006384:	03010413          	addi	s0,sp,48
    80006388:	00050493          	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000638c:	00850913          	addi	s2,a0,8
    80006390:	00090513          	mv	a0,s2
    80006394:	ffffb097          	auipc	ra,0xffffb
    80006398:	d04080e7          	jalr	-764(ra) # 80001098 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000639c:	0004a783          	lw	a5,0(s1)
    800063a0:	02079a63          	bnez	a5,800063d4 <holdingsleep+0x68>
    800063a4:	00000493          	li	s1,0
  release(&lk->lk);
    800063a8:	00090513          	mv	a0,s2
    800063ac:	ffffb097          	auipc	ra,0xffffb
    800063b0:	de4080e7          	jalr	-540(ra) # 80001190 <release>
  return r;
}
    800063b4:	00048513          	mv	a0,s1
    800063b8:	02813083          	ld	ra,40(sp)
    800063bc:	02013403          	ld	s0,32(sp)
    800063c0:	01813483          	ld	s1,24(sp)
    800063c4:	01013903          	ld	s2,16(sp)
    800063c8:	00813983          	ld	s3,8(sp)
    800063cc:	03010113          	addi	sp,sp,48
    800063d0:	00008067          	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800063d4:	0284a983          	lw	s3,40(s1)
    800063d8:	ffffc097          	auipc	ra,0xffffc
    800063dc:	320080e7          	jalr	800(ra) # 800026f8 <myproc>
    800063e0:	03052483          	lw	s1,48(a0)
    800063e4:	413484b3          	sub	s1,s1,s3
    800063e8:	0014b493          	seqz	s1,s1
    800063ec:	fbdff06f          	j	800063a8 <holdingsleep+0x3c>

00000000800063f0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800063f0:	ff010113          	addi	sp,sp,-16
    800063f4:	00113423          	sd	ra,8(sp)
    800063f8:	00813023          	sd	s0,0(sp)
    800063fc:	01010413          	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80006400:	00004597          	auipc	a1,0x4
    80006404:	3c858593          	addi	a1,a1,968 # 8000a7c8 <syscalls+0x278>
    80006408:	0001c517          	auipc	a0,0x1c
    8000640c:	7c850513          	addi	a0,a0,1992 # 80022bd0 <ftable>
    80006410:	ffffb097          	auipc	ra,0xffffb
    80006414:	ba4080e7          	jalr	-1116(ra) # 80000fb4 <initlock>
}
    80006418:	00813083          	ld	ra,8(sp)
    8000641c:	00013403          	ld	s0,0(sp)
    80006420:	01010113          	addi	sp,sp,16
    80006424:	00008067          	ret

0000000080006428 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80006428:	fe010113          	addi	sp,sp,-32
    8000642c:	00113c23          	sd	ra,24(sp)
    80006430:	00813823          	sd	s0,16(sp)
    80006434:	00913423          	sd	s1,8(sp)
    80006438:	02010413          	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000643c:	0001c517          	auipc	a0,0x1c
    80006440:	79450513          	addi	a0,a0,1940 # 80022bd0 <ftable>
    80006444:	ffffb097          	auipc	ra,0xffffb
    80006448:	c54080e7          	jalr	-940(ra) # 80001098 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000644c:	0001c497          	auipc	s1,0x1c
    80006450:	79c48493          	addi	s1,s1,1948 # 80022be8 <ftable+0x18>
    80006454:	0001d717          	auipc	a4,0x1d
    80006458:	73470713          	addi	a4,a4,1844 # 80023b88 <disk>
    if(f->ref == 0){
    8000645c:	0044a783          	lw	a5,4(s1)
    80006460:	02078263          	beqz	a5,80006484 <filealloc+0x5c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80006464:	02848493          	addi	s1,s1,40
    80006468:	fee49ae3          	bne	s1,a4,8000645c <filealloc+0x34>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000646c:	0001c517          	auipc	a0,0x1c
    80006470:	76450513          	addi	a0,a0,1892 # 80022bd0 <ftable>
    80006474:	ffffb097          	auipc	ra,0xffffb
    80006478:	d1c080e7          	jalr	-740(ra) # 80001190 <release>
  return 0;
    8000647c:	00000493          	li	s1,0
    80006480:	01c0006f          	j	8000649c <filealloc+0x74>
      f->ref = 1;
    80006484:	00100793          	li	a5,1
    80006488:	00f4a223          	sw	a5,4(s1)
      release(&ftable.lock);
    8000648c:	0001c517          	auipc	a0,0x1c
    80006490:	74450513          	addi	a0,a0,1860 # 80022bd0 <ftable>
    80006494:	ffffb097          	auipc	ra,0xffffb
    80006498:	cfc080e7          	jalr	-772(ra) # 80001190 <release>
}
    8000649c:	00048513          	mv	a0,s1
    800064a0:	01813083          	ld	ra,24(sp)
    800064a4:	01013403          	ld	s0,16(sp)
    800064a8:	00813483          	ld	s1,8(sp)
    800064ac:	02010113          	addi	sp,sp,32
    800064b0:	00008067          	ret

00000000800064b4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800064b4:	fe010113          	addi	sp,sp,-32
    800064b8:	00113c23          	sd	ra,24(sp)
    800064bc:	00813823          	sd	s0,16(sp)
    800064c0:	00913423          	sd	s1,8(sp)
    800064c4:	02010413          	addi	s0,sp,32
    800064c8:	00050493          	mv	s1,a0
  acquire(&ftable.lock);
    800064cc:	0001c517          	auipc	a0,0x1c
    800064d0:	70450513          	addi	a0,a0,1796 # 80022bd0 <ftable>
    800064d4:	ffffb097          	auipc	ra,0xffffb
    800064d8:	bc4080e7          	jalr	-1084(ra) # 80001098 <acquire>
  if(f->ref < 1)
    800064dc:	0044a783          	lw	a5,4(s1)
    800064e0:	02f05a63          	blez	a5,80006514 <filedup+0x60>
    panic("filedup");
  f->ref++;
    800064e4:	0017879b          	addiw	a5,a5,1
    800064e8:	00f4a223          	sw	a5,4(s1)
  release(&ftable.lock);
    800064ec:	0001c517          	auipc	a0,0x1c
    800064f0:	6e450513          	addi	a0,a0,1764 # 80022bd0 <ftable>
    800064f4:	ffffb097          	auipc	ra,0xffffb
    800064f8:	c9c080e7          	jalr	-868(ra) # 80001190 <release>
  return f;
}
    800064fc:	00048513          	mv	a0,s1
    80006500:	01813083          	ld	ra,24(sp)
    80006504:	01013403          	ld	s0,16(sp)
    80006508:	00813483          	ld	s1,8(sp)
    8000650c:	02010113          	addi	sp,sp,32
    80006510:	00008067          	ret
    panic("filedup");
    80006514:	00004517          	auipc	a0,0x4
    80006518:	2bc50513          	addi	a0,a0,700 # 8000a7d0 <syscalls+0x280>
    8000651c:	ffffa097          	auipc	ra,0xffffa
    80006520:	564080e7          	jalr	1380(ra) # 80000a80 <panic>

0000000080006524 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80006524:	fc010113          	addi	sp,sp,-64
    80006528:	02113c23          	sd	ra,56(sp)
    8000652c:	02813823          	sd	s0,48(sp)
    80006530:	02913423          	sd	s1,40(sp)
    80006534:	03213023          	sd	s2,32(sp)
    80006538:	01313c23          	sd	s3,24(sp)
    8000653c:	01413823          	sd	s4,16(sp)
    80006540:	01513423          	sd	s5,8(sp)
    80006544:	04010413          	addi	s0,sp,64
    80006548:	00050493          	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000654c:	0001c517          	auipc	a0,0x1c
    80006550:	68450513          	addi	a0,a0,1668 # 80022bd0 <ftable>
    80006554:	ffffb097          	auipc	ra,0xffffb
    80006558:	b44080e7          	jalr	-1212(ra) # 80001098 <acquire>
  if(f->ref < 1)
    8000655c:	0044a783          	lw	a5,4(s1)
    80006560:	06f05863          	blez	a5,800065d0 <fileclose+0xac>
    panic("fileclose");
  if(--f->ref > 0){
    80006564:	fff7879b          	addiw	a5,a5,-1
    80006568:	0007871b          	sext.w	a4,a5
    8000656c:	00f4a223          	sw	a5,4(s1)
    80006570:	06e04863          	bgtz	a4,800065e0 <fileclose+0xbc>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80006574:	0004a903          	lw	s2,0(s1)
    80006578:	0094ca83          	lbu	s5,9(s1)
    8000657c:	0104ba03          	ld	s4,16(s1)
    80006580:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80006584:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80006588:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000658c:	0001c517          	auipc	a0,0x1c
    80006590:	64450513          	addi	a0,a0,1604 # 80022bd0 <ftable>
    80006594:	ffffb097          	auipc	ra,0xffffb
    80006598:	bfc080e7          	jalr	-1028(ra) # 80001190 <release>

  if(ff.type == FD_PIPE){
    8000659c:	00100793          	li	a5,1
    800065a0:	06f90a63          	beq	s2,a5,80006614 <fileclose+0xf0>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800065a4:	ffe9091b          	addiw	s2,s2,-2
    800065a8:	00100793          	li	a5,1
    800065ac:	0527e263          	bltu	a5,s2,800065f0 <fileclose+0xcc>
    begin_op();
    800065b0:	00000097          	auipc	ra,0x0
    800065b4:	8f8080e7          	jalr	-1800(ra) # 80005ea8 <begin_op>
    iput(ff.ip);
    800065b8:	00098513          	mv	a0,s3
    800065bc:	fffff097          	auipc	ra,0xfffff
    800065c0:	b4c080e7          	jalr	-1204(ra) # 80005108 <iput>
    end_op();
    800065c4:	00000097          	auipc	ra,0x0
    800065c8:	998080e7          	jalr	-1640(ra) # 80005f5c <end_op>
    800065cc:	0240006f          	j	800065f0 <fileclose+0xcc>
    panic("fileclose");
    800065d0:	00004517          	auipc	a0,0x4
    800065d4:	20850513          	addi	a0,a0,520 # 8000a7d8 <syscalls+0x288>
    800065d8:	ffffa097          	auipc	ra,0xffffa
    800065dc:	4a8080e7          	jalr	1192(ra) # 80000a80 <panic>
    release(&ftable.lock);
    800065e0:	0001c517          	auipc	a0,0x1c
    800065e4:	5f050513          	addi	a0,a0,1520 # 80022bd0 <ftable>
    800065e8:	ffffb097          	auipc	ra,0xffffb
    800065ec:	ba8080e7          	jalr	-1112(ra) # 80001190 <release>
  }
}
    800065f0:	03813083          	ld	ra,56(sp)
    800065f4:	03013403          	ld	s0,48(sp)
    800065f8:	02813483          	ld	s1,40(sp)
    800065fc:	02013903          	ld	s2,32(sp)
    80006600:	01813983          	ld	s3,24(sp)
    80006604:	01013a03          	ld	s4,16(sp)
    80006608:	00813a83          	ld	s5,8(sp)
    8000660c:	04010113          	addi	sp,sp,64
    80006610:	00008067          	ret
    pipeclose(ff.pipe, ff.writable);
    80006614:	000a8593          	mv	a1,s5
    80006618:	000a0513          	mv	a0,s4
    8000661c:	00000097          	auipc	ra,0x0
    80006620:	4c0080e7          	jalr	1216(ra) # 80006adc <pipeclose>
    80006624:	fcdff06f          	j	800065f0 <fileclose+0xcc>

0000000080006628 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80006628:	fb010113          	addi	sp,sp,-80
    8000662c:	04113423          	sd	ra,72(sp)
    80006630:	04813023          	sd	s0,64(sp)
    80006634:	02913c23          	sd	s1,56(sp)
    80006638:	03213823          	sd	s2,48(sp)
    8000663c:	03313423          	sd	s3,40(sp)
    80006640:	05010413          	addi	s0,sp,80
    80006644:	00050493          	mv	s1,a0
    80006648:	00058993          	mv	s3,a1
  struct proc *p = myproc();
    8000664c:	ffffc097          	auipc	ra,0xffffc
    80006650:	0ac080e7          	jalr	172(ra) # 800026f8 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80006654:	0004a783          	lw	a5,0(s1)
    80006658:	ffe7879b          	addiw	a5,a5,-2
    8000665c:	00100713          	li	a4,1
    80006660:	06f76463          	bltu	a4,a5,800066c8 <filestat+0xa0>
    80006664:	00050913          	mv	s2,a0
    ilock(f->ip);
    80006668:	0184b503          	ld	a0,24(s1)
    8000666c:	fffff097          	auipc	ra,0xfffff
    80006670:	83c080e7          	jalr	-1988(ra) # 80004ea8 <ilock>
    stati(f->ip, &st);
    80006674:	fb840593          	addi	a1,s0,-72
    80006678:	0184b503          	ld	a0,24(s1)
    8000667c:	fffff097          	auipc	ra,0xfffff
    80006680:	da4080e7          	jalr	-604(ra) # 80005420 <stati>
    iunlock(f->ip);
    80006684:	0184b503          	ld	a0,24(s1)
    80006688:	fffff097          	auipc	ra,0xfffff
    8000668c:	924080e7          	jalr	-1756(ra) # 80004fac <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80006690:	01800693          	li	a3,24
    80006694:	fb840613          	addi	a2,s0,-72
    80006698:	00098593          	mv	a1,s3
    8000669c:	05093503          	ld	a0,80(s2)
    800066a0:	ffffc097          	auipc	ra,0xffffc
    800066a4:	be4080e7          	jalr	-1052(ra) # 80002284 <copyout>
    800066a8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800066ac:	04813083          	ld	ra,72(sp)
    800066b0:	04013403          	ld	s0,64(sp)
    800066b4:	03813483          	ld	s1,56(sp)
    800066b8:	03013903          	ld	s2,48(sp)
    800066bc:	02813983          	ld	s3,40(sp)
    800066c0:	05010113          	addi	sp,sp,80
    800066c4:	00008067          	ret
  return -1;
    800066c8:	fff00513          	li	a0,-1
    800066cc:	fe1ff06f          	j	800066ac <filestat+0x84>

00000000800066d0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800066d0:	fd010113          	addi	sp,sp,-48
    800066d4:	02113423          	sd	ra,40(sp)
    800066d8:	02813023          	sd	s0,32(sp)
    800066dc:	00913c23          	sd	s1,24(sp)
    800066e0:	01213823          	sd	s2,16(sp)
    800066e4:	01313423          	sd	s3,8(sp)
    800066e8:	03010413          	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800066ec:	00854783          	lbu	a5,8(a0)
    800066f0:	0e078a63          	beqz	a5,800067e4 <fileread+0x114>
    800066f4:	00050493          	mv	s1,a0
    800066f8:	00058993          	mv	s3,a1
    800066fc:	00060913          	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80006700:	00052783          	lw	a5,0(a0)
    80006704:	00100713          	li	a4,1
    80006708:	06e78e63          	beq	a5,a4,80006784 <fileread+0xb4>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000670c:	00300713          	li	a4,3
    80006710:	08e78463          	beq	a5,a4,80006798 <fileread+0xc8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80006714:	00200713          	li	a4,2
    80006718:	0ae79e63          	bne	a5,a4,800067d4 <fileread+0x104>
    ilock(f->ip);
    8000671c:	01853503          	ld	a0,24(a0)
    80006720:	ffffe097          	auipc	ra,0xffffe
    80006724:	788080e7          	jalr	1928(ra) # 80004ea8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80006728:	00090713          	mv	a4,s2
    8000672c:	0204a683          	lw	a3,32(s1)
    80006730:	00098613          	mv	a2,s3
    80006734:	00100593          	li	a1,1
    80006738:	0184b503          	ld	a0,24(s1)
    8000673c:	fffff097          	auipc	ra,0xfffff
    80006740:	d24080e7          	jalr	-732(ra) # 80005460 <readi>
    80006744:	00050913          	mv	s2,a0
    80006748:	00a05863          	blez	a0,80006758 <fileread+0x88>
      f->off += r;
    8000674c:	0204a783          	lw	a5,32(s1)
    80006750:	00a787bb          	addw	a5,a5,a0
    80006754:	02f4a023          	sw	a5,32(s1)
    iunlock(f->ip);
    80006758:	0184b503          	ld	a0,24(s1)
    8000675c:	fffff097          	auipc	ra,0xfffff
    80006760:	850080e7          	jalr	-1968(ra) # 80004fac <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80006764:	00090513          	mv	a0,s2
    80006768:	02813083          	ld	ra,40(sp)
    8000676c:	02013403          	ld	s0,32(sp)
    80006770:	01813483          	ld	s1,24(sp)
    80006774:	01013903          	ld	s2,16(sp)
    80006778:	00813983          	ld	s3,8(sp)
    8000677c:	03010113          	addi	sp,sp,48
    80006780:	00008067          	ret
    r = piperead(f->pipe, addr, n);
    80006784:	01053503          	ld	a0,16(a0)
    80006788:	00000097          	auipc	ra,0x0
    8000678c:	544080e7          	jalr	1348(ra) # 80006ccc <piperead>
    80006790:	00050913          	mv	s2,a0
    80006794:	fd1ff06f          	j	80006764 <fileread+0x94>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80006798:	02451783          	lh	a5,36(a0)
    8000679c:	03079693          	slli	a3,a5,0x30
    800067a0:	0306d693          	srli	a3,a3,0x30
    800067a4:	00900713          	li	a4,9
    800067a8:	04d76263          	bltu	a4,a3,800067ec <fileread+0x11c>
    800067ac:	00479793          	slli	a5,a5,0x4
    800067b0:	0001c717          	auipc	a4,0x1c
    800067b4:	38070713          	addi	a4,a4,896 # 80022b30 <devsw>
    800067b8:	00f707b3          	add	a5,a4,a5
    800067bc:	0007b783          	ld	a5,0(a5)
    800067c0:	02078a63          	beqz	a5,800067f4 <fileread+0x124>
    r = devsw[f->major].read(1, addr, n);
    800067c4:	00100513          	li	a0,1
    800067c8:	000780e7          	jalr	a5
    800067cc:	00050913          	mv	s2,a0
    800067d0:	f95ff06f          	j	80006764 <fileread+0x94>
    panic("fileread");
    800067d4:	00004517          	auipc	a0,0x4
    800067d8:	01450513          	addi	a0,a0,20 # 8000a7e8 <syscalls+0x298>
    800067dc:	ffffa097          	auipc	ra,0xffffa
    800067e0:	2a4080e7          	jalr	676(ra) # 80000a80 <panic>
    return -1;
    800067e4:	fff00913          	li	s2,-1
    800067e8:	f7dff06f          	j	80006764 <fileread+0x94>
      return -1;
    800067ec:	fff00913          	li	s2,-1
    800067f0:	f75ff06f          	j	80006764 <fileread+0x94>
    800067f4:	fff00913          	li	s2,-1
    800067f8:	f6dff06f          	j	80006764 <fileread+0x94>

00000000800067fc <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800067fc:	fb010113          	addi	sp,sp,-80
    80006800:	04113423          	sd	ra,72(sp)
    80006804:	04813023          	sd	s0,64(sp)
    80006808:	02913c23          	sd	s1,56(sp)
    8000680c:	03213823          	sd	s2,48(sp)
    80006810:	03313423          	sd	s3,40(sp)
    80006814:	03413023          	sd	s4,32(sp)
    80006818:	01513c23          	sd	s5,24(sp)
    8000681c:	01613823          	sd	s6,16(sp)
    80006820:	01713423          	sd	s7,8(sp)
    80006824:	01813023          	sd	s8,0(sp)
    80006828:	05010413          	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000682c:	00954783          	lbu	a5,9(a0)
    80006830:	16078463          	beqz	a5,80006998 <filewrite+0x19c>
    80006834:	00050913          	mv	s2,a0
    80006838:	00058b13          	mv	s6,a1
    8000683c:	00060a13          	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80006840:	00052783          	lw	a5,0(a0)
    80006844:	00100713          	li	a4,1
    80006848:	02e78863          	beq	a5,a4,80006878 <filewrite+0x7c>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000684c:	00300713          	li	a4,3
    80006850:	02e78e63          	beq	a5,a4,8000688c <filewrite+0x90>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80006854:	00200713          	li	a4,2
    80006858:	12e79863          	bne	a5,a4,80006988 <filewrite+0x18c>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000685c:	0ec05463          	blez	a2,80006944 <filewrite+0x148>
    int i = 0;
    80006860:	00000993          	li	s3,0
    80006864:	00001bb7          	lui	s7,0x1
    80006868:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000686c:	00001c37          	lui	s8,0x1
    80006870:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80006874:	0bc0006f          	j	80006930 <filewrite+0x134>
    ret = pipewrite(f->pipe, addr, n);
    80006878:	01053503          	ld	a0,16(a0)
    8000687c:	00000097          	auipc	ra,0x0
    80006880:	2f8080e7          	jalr	760(ra) # 80006b74 <pipewrite>
    80006884:	00050a13          	mv	s4,a0
    80006888:	0c40006f          	j	8000694c <filewrite+0x150>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000688c:	02451783          	lh	a5,36(a0)
    80006890:	03079693          	slli	a3,a5,0x30
    80006894:	0306d693          	srli	a3,a3,0x30
    80006898:	00900713          	li	a4,9
    8000689c:	10d76263          	bltu	a4,a3,800069a0 <filewrite+0x1a4>
    800068a0:	00479793          	slli	a5,a5,0x4
    800068a4:	0001c717          	auipc	a4,0x1c
    800068a8:	28c70713          	addi	a4,a4,652 # 80022b30 <devsw>
    800068ac:	00f707b3          	add	a5,a4,a5
    800068b0:	0087b783          	ld	a5,8(a5)
    800068b4:	0e078a63          	beqz	a5,800069a8 <filewrite+0x1ac>
    ret = devsw[f->major].write(1, addr, n);
    800068b8:	00100513          	li	a0,1
    800068bc:	000780e7          	jalr	a5
    800068c0:	00050a13          	mv	s4,a0
    800068c4:	0880006f          	j	8000694c <filewrite+0x150>
    800068c8:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800068cc:	fffff097          	auipc	ra,0xfffff
    800068d0:	5dc080e7          	jalr	1500(ra) # 80005ea8 <begin_op>
      ilock(f->ip);
    800068d4:	01893503          	ld	a0,24(s2)
    800068d8:	ffffe097          	auipc	ra,0xffffe
    800068dc:	5d0080e7          	jalr	1488(ra) # 80004ea8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800068e0:	000a8713          	mv	a4,s5
    800068e4:	02092683          	lw	a3,32(s2)
    800068e8:	01698633          	add	a2,s3,s6
    800068ec:	00100593          	li	a1,1
    800068f0:	01893503          	ld	a0,24(s2)
    800068f4:	fffff097          	auipc	ra,0xfffff
    800068f8:	cdc080e7          	jalr	-804(ra) # 800055d0 <writei>
    800068fc:	00050493          	mv	s1,a0
    80006900:	00a05863          	blez	a0,80006910 <filewrite+0x114>
        f->off += r;
    80006904:	02092783          	lw	a5,32(s2)
    80006908:	00a787bb          	addw	a5,a5,a0
    8000690c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80006910:	01893503          	ld	a0,24(s2)
    80006914:	ffffe097          	auipc	ra,0xffffe
    80006918:	698080e7          	jalr	1688(ra) # 80004fac <iunlock>
      end_op();
    8000691c:	fffff097          	auipc	ra,0xfffff
    80006920:	640080e7          	jalr	1600(ra) # 80005f5c <end_op>

      if(r != n1){
    80006924:	029a9263          	bne	s5,s1,80006948 <filewrite+0x14c>
        // error from writei
        break;
      }
      i += r;
    80006928:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000692c:	0149de63          	bge	s3,s4,80006948 <filewrite+0x14c>
      int n1 = n - i;
    80006930:	413a04bb          	subw	s1,s4,s3
    80006934:	0004879b          	sext.w	a5,s1
    80006938:	f8fbd8e3          	bge	s7,a5,800068c8 <filewrite+0xcc>
    8000693c:	000c0493          	mv	s1,s8
    80006940:	f89ff06f          	j	800068c8 <filewrite+0xcc>
    int i = 0;
    80006944:	00000993          	li	s3,0
    }
    ret = (i == n ? n : -1);
    80006948:	033a1c63          	bne	s4,s3,80006980 <filewrite+0x184>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000694c:	000a0513          	mv	a0,s4
    80006950:	04813083          	ld	ra,72(sp)
    80006954:	04013403          	ld	s0,64(sp)
    80006958:	03813483          	ld	s1,56(sp)
    8000695c:	03013903          	ld	s2,48(sp)
    80006960:	02813983          	ld	s3,40(sp)
    80006964:	02013a03          	ld	s4,32(sp)
    80006968:	01813a83          	ld	s5,24(sp)
    8000696c:	01013b03          	ld	s6,16(sp)
    80006970:	00813b83          	ld	s7,8(sp)
    80006974:	00013c03          	ld	s8,0(sp)
    80006978:	05010113          	addi	sp,sp,80
    8000697c:	00008067          	ret
    ret = (i == n ? n : -1);
    80006980:	fff00a13          	li	s4,-1
    80006984:	fc9ff06f          	j	8000694c <filewrite+0x150>
    panic("filewrite");
    80006988:	00004517          	auipc	a0,0x4
    8000698c:	e7050513          	addi	a0,a0,-400 # 8000a7f8 <syscalls+0x2a8>
    80006990:	ffffa097          	auipc	ra,0xffffa
    80006994:	0f0080e7          	jalr	240(ra) # 80000a80 <panic>
    return -1;
    80006998:	fff00a13          	li	s4,-1
    8000699c:	fb1ff06f          	j	8000694c <filewrite+0x150>
      return -1;
    800069a0:	fff00a13          	li	s4,-1
    800069a4:	fa9ff06f          	j	8000694c <filewrite+0x150>
    800069a8:	fff00a13          	li	s4,-1
    800069ac:	fa1ff06f          	j	8000694c <filewrite+0x150>

00000000800069b0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800069b0:	fd010113          	addi	sp,sp,-48
    800069b4:	02113423          	sd	ra,40(sp)
    800069b8:	02813023          	sd	s0,32(sp)
    800069bc:	00913c23          	sd	s1,24(sp)
    800069c0:	01213823          	sd	s2,16(sp)
    800069c4:	01313423          	sd	s3,8(sp)
    800069c8:	01413023          	sd	s4,0(sp)
    800069cc:	03010413          	addi	s0,sp,48
    800069d0:	00050493          	mv	s1,a0
    800069d4:	00058a13          	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800069d8:	0005b023          	sd	zero,0(a1)
    800069dc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800069e0:	00000097          	auipc	ra,0x0
    800069e4:	a48080e7          	jalr	-1464(ra) # 80006428 <filealloc>
    800069e8:	00a4b023          	sd	a0,0(s1)
    800069ec:	0a050663          	beqz	a0,80006a98 <pipealloc+0xe8>
    800069f0:	00000097          	auipc	ra,0x0
    800069f4:	a38080e7          	jalr	-1480(ra) # 80006428 <filealloc>
    800069f8:	00aa3023          	sd	a0,0(s4)
    800069fc:	08050663          	beqz	a0,80006a88 <pipealloc+0xd8>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80006a00:	ffffa097          	auipc	ra,0xffffa
    80006a04:	52c080e7          	jalr	1324(ra) # 80000f2c <kalloc>
    80006a08:	00050913          	mv	s2,a0
    80006a0c:	06050863          	beqz	a0,80006a7c <pipealloc+0xcc>
    goto bad;
  pi->readopen = 1;
    80006a10:	00100993          	li	s3,1
    80006a14:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80006a18:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80006a1c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80006a20:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80006a24:	00004597          	auipc	a1,0x4
    80006a28:	de458593          	addi	a1,a1,-540 # 8000a808 <syscalls+0x2b8>
    80006a2c:	ffffa097          	auipc	ra,0xffffa
    80006a30:	588080e7          	jalr	1416(ra) # 80000fb4 <initlock>
  (*f0)->type = FD_PIPE;
    80006a34:	0004b783          	ld	a5,0(s1)
    80006a38:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80006a3c:	0004b783          	ld	a5,0(s1)
    80006a40:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80006a44:	0004b783          	ld	a5,0(s1)
    80006a48:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80006a4c:	0004b783          	ld	a5,0(s1)
    80006a50:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80006a54:	000a3783          	ld	a5,0(s4)
    80006a58:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80006a5c:	000a3783          	ld	a5,0(s4)
    80006a60:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80006a64:	000a3783          	ld	a5,0(s4)
    80006a68:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80006a6c:	000a3783          	ld	a5,0(s4)
    80006a70:	0127b823          	sd	s2,16(a5)
  return 0;
    80006a74:	00000513          	li	a0,0
    80006a78:	03c0006f          	j	80006ab4 <pipealloc+0x104>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80006a7c:	0004b503          	ld	a0,0(s1)
    80006a80:	00051863          	bnez	a0,80006a90 <pipealloc+0xe0>
    80006a84:	0140006f          	j	80006a98 <pipealloc+0xe8>
    80006a88:	0004b503          	ld	a0,0(s1)
    80006a8c:	04050463          	beqz	a0,80006ad4 <pipealloc+0x124>
    fileclose(*f0);
    80006a90:	00000097          	auipc	ra,0x0
    80006a94:	a94080e7          	jalr	-1388(ra) # 80006524 <fileclose>
  if(*f1)
    80006a98:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80006a9c:	fff00513          	li	a0,-1
  if(*f1)
    80006aa0:	00078a63          	beqz	a5,80006ab4 <pipealloc+0x104>
    fileclose(*f1);
    80006aa4:	00078513          	mv	a0,a5
    80006aa8:	00000097          	auipc	ra,0x0
    80006aac:	a7c080e7          	jalr	-1412(ra) # 80006524 <fileclose>
  return -1;
    80006ab0:	fff00513          	li	a0,-1
}
    80006ab4:	02813083          	ld	ra,40(sp)
    80006ab8:	02013403          	ld	s0,32(sp)
    80006abc:	01813483          	ld	s1,24(sp)
    80006ac0:	01013903          	ld	s2,16(sp)
    80006ac4:	00813983          	ld	s3,8(sp)
    80006ac8:	00013a03          	ld	s4,0(sp)
    80006acc:	03010113          	addi	sp,sp,48
    80006ad0:	00008067          	ret
  return -1;
    80006ad4:	fff00513          	li	a0,-1
    80006ad8:	fddff06f          	j	80006ab4 <pipealloc+0x104>

0000000080006adc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80006adc:	fe010113          	addi	sp,sp,-32
    80006ae0:	00113c23          	sd	ra,24(sp)
    80006ae4:	00813823          	sd	s0,16(sp)
    80006ae8:	00913423          	sd	s1,8(sp)
    80006aec:	01213023          	sd	s2,0(sp)
    80006af0:	02010413          	addi	s0,sp,32
    80006af4:	00050493          	mv	s1,a0
    80006af8:	00058913          	mv	s2,a1
  acquire(&pi->lock);
    80006afc:	ffffa097          	auipc	ra,0xffffa
    80006b00:	59c080e7          	jalr	1436(ra) # 80001098 <acquire>
  if(writable){
    80006b04:	04090663          	beqz	s2,80006b50 <pipeclose+0x74>
    pi->writeopen = 0;
    80006b08:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80006b0c:	21848513          	addi	a0,s1,536
    80006b10:	ffffc097          	auipc	ra,0xffffc
    80006b14:	630080e7          	jalr	1584(ra) # 80003140 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80006b18:	2204b783          	ld	a5,544(s1)
    80006b1c:	04079463          	bnez	a5,80006b64 <pipeclose+0x88>
    release(&pi->lock);
    80006b20:	00048513          	mv	a0,s1
    80006b24:	ffffa097          	auipc	ra,0xffffa
    80006b28:	66c080e7          	jalr	1644(ra) # 80001190 <release>
    kfree((char*)pi);
    80006b2c:	00048513          	mv	a0,s1
    80006b30:	ffffa097          	auipc	ra,0xffffa
    80006b34:	290080e7          	jalr	656(ra) # 80000dc0 <kfree>
  } else
    release(&pi->lock);
}
    80006b38:	01813083          	ld	ra,24(sp)
    80006b3c:	01013403          	ld	s0,16(sp)
    80006b40:	00813483          	ld	s1,8(sp)
    80006b44:	00013903          	ld	s2,0(sp)
    80006b48:	02010113          	addi	sp,sp,32
    80006b4c:	00008067          	ret
    pi->readopen = 0;
    80006b50:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80006b54:	21c48513          	addi	a0,s1,540
    80006b58:	ffffc097          	auipc	ra,0xffffc
    80006b5c:	5e8080e7          	jalr	1512(ra) # 80003140 <wakeup>
    80006b60:	fb9ff06f          	j	80006b18 <pipeclose+0x3c>
    release(&pi->lock);
    80006b64:	00048513          	mv	a0,s1
    80006b68:	ffffa097          	auipc	ra,0xffffa
    80006b6c:	628080e7          	jalr	1576(ra) # 80001190 <release>
}
    80006b70:	fc9ff06f          	j	80006b38 <pipeclose+0x5c>

0000000080006b74 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80006b74:	fa010113          	addi	sp,sp,-96
    80006b78:	04113c23          	sd	ra,88(sp)
    80006b7c:	04813823          	sd	s0,80(sp)
    80006b80:	04913423          	sd	s1,72(sp)
    80006b84:	05213023          	sd	s2,64(sp)
    80006b88:	03313c23          	sd	s3,56(sp)
    80006b8c:	03413823          	sd	s4,48(sp)
    80006b90:	03513423          	sd	s5,40(sp)
    80006b94:	03613023          	sd	s6,32(sp)
    80006b98:	01713c23          	sd	s7,24(sp)
    80006b9c:	01813823          	sd	s8,16(sp)
    80006ba0:	06010413          	addi	s0,sp,96
    80006ba4:	00050493          	mv	s1,a0
    80006ba8:	00058a93          	mv	s5,a1
    80006bac:	00060a13          	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80006bb0:	ffffc097          	auipc	ra,0xffffc
    80006bb4:	b48080e7          	jalr	-1208(ra) # 800026f8 <myproc>
    80006bb8:	00050993          	mv	s3,a0

  acquire(&pi->lock);
    80006bbc:	00048513          	mv	a0,s1
    80006bc0:	ffffa097          	auipc	ra,0xffffa
    80006bc4:	4d8080e7          	jalr	1240(ra) # 80001098 <acquire>
  while(i < n){
    80006bc8:	0f405263          	blez	s4,80006cac <pipewrite+0x138>
  int i = 0;
    80006bcc:	00000913          	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80006bd0:	fff00b13          	li	s6,-1
      wakeup(&pi->nread);
    80006bd4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80006bd8:	21c48b93          	addi	s7,s1,540
    80006bdc:	0680006f          	j	80006c44 <pipewrite+0xd0>
      release(&pi->lock);
    80006be0:	00048513          	mv	a0,s1
    80006be4:	ffffa097          	auipc	ra,0xffffa
    80006be8:	5ac080e7          	jalr	1452(ra) # 80001190 <release>
      return -1;
    80006bec:	fff00913          	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80006bf0:	00090513          	mv	a0,s2
    80006bf4:	05813083          	ld	ra,88(sp)
    80006bf8:	05013403          	ld	s0,80(sp)
    80006bfc:	04813483          	ld	s1,72(sp)
    80006c00:	04013903          	ld	s2,64(sp)
    80006c04:	03813983          	ld	s3,56(sp)
    80006c08:	03013a03          	ld	s4,48(sp)
    80006c0c:	02813a83          	ld	s5,40(sp)
    80006c10:	02013b03          	ld	s6,32(sp)
    80006c14:	01813b83          	ld	s7,24(sp)
    80006c18:	01013c03          	ld	s8,16(sp)
    80006c1c:	06010113          	addi	sp,sp,96
    80006c20:	00008067          	ret
      wakeup(&pi->nread);
    80006c24:	000c0513          	mv	a0,s8
    80006c28:	ffffc097          	auipc	ra,0xffffc
    80006c2c:	518080e7          	jalr	1304(ra) # 80003140 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80006c30:	00048593          	mv	a1,s1
    80006c34:	000b8513          	mv	a0,s7
    80006c38:	ffffc097          	auipc	ra,0xffffc
    80006c3c:	478080e7          	jalr	1144(ra) # 800030b0 <sleep>
  while(i < n){
    80006c40:	07495863          	bge	s2,s4,80006cb0 <pipewrite+0x13c>
    if(pi->readopen == 0 || killed(pr)){
    80006c44:	2204a783          	lw	a5,544(s1)
    80006c48:	f8078ce3          	beqz	a5,80006be0 <pipewrite+0x6c>
    80006c4c:	00098513          	mv	a0,s3
    80006c50:	ffffd097          	auipc	ra,0xffffd
    80006c54:	810080e7          	jalr	-2032(ra) # 80003460 <killed>
    80006c58:	f80514e3          	bnez	a0,80006be0 <pipewrite+0x6c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80006c5c:	2184a783          	lw	a5,536(s1)
    80006c60:	21c4a703          	lw	a4,540(s1)
    80006c64:	2007879b          	addiw	a5,a5,512
    80006c68:	faf70ee3          	beq	a4,a5,80006c24 <pipewrite+0xb0>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80006c6c:	00100693          	li	a3,1
    80006c70:	01590633          	add	a2,s2,s5
    80006c74:	faf40593          	addi	a1,s0,-81
    80006c78:	0509b503          	ld	a0,80(s3)
    80006c7c:	ffffb097          	auipc	ra,0xffffb
    80006c80:	770080e7          	jalr	1904(ra) # 800023ec <copyin>
    80006c84:	03650663          	beq	a0,s6,80006cb0 <pipewrite+0x13c>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80006c88:	21c4a783          	lw	a5,540(s1)
    80006c8c:	0017871b          	addiw	a4,a5,1
    80006c90:	20e4ae23          	sw	a4,540(s1)
    80006c94:	1ff7f793          	andi	a5,a5,511
    80006c98:	00f487b3          	add	a5,s1,a5
    80006c9c:	faf44703          	lbu	a4,-81(s0)
    80006ca0:	00e78c23          	sb	a4,24(a5)
      i++;
    80006ca4:	0019091b          	addiw	s2,s2,1
    80006ca8:	f99ff06f          	j	80006c40 <pipewrite+0xcc>
  int i = 0;
    80006cac:	00000913          	li	s2,0
  wakeup(&pi->nread);
    80006cb0:	21848513          	addi	a0,s1,536
    80006cb4:	ffffc097          	auipc	ra,0xffffc
    80006cb8:	48c080e7          	jalr	1164(ra) # 80003140 <wakeup>
  release(&pi->lock);
    80006cbc:	00048513          	mv	a0,s1
    80006cc0:	ffffa097          	auipc	ra,0xffffa
    80006cc4:	4d0080e7          	jalr	1232(ra) # 80001190 <release>
  return i;
    80006cc8:	f29ff06f          	j	80006bf0 <pipewrite+0x7c>

0000000080006ccc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80006ccc:	fb010113          	addi	sp,sp,-80
    80006cd0:	04113423          	sd	ra,72(sp)
    80006cd4:	04813023          	sd	s0,64(sp)
    80006cd8:	02913c23          	sd	s1,56(sp)
    80006cdc:	03213823          	sd	s2,48(sp)
    80006ce0:	03313423          	sd	s3,40(sp)
    80006ce4:	03413023          	sd	s4,32(sp)
    80006ce8:	01513c23          	sd	s5,24(sp)
    80006cec:	01613823          	sd	s6,16(sp)
    80006cf0:	05010413          	addi	s0,sp,80
    80006cf4:	00050493          	mv	s1,a0
    80006cf8:	00058913          	mv	s2,a1
    80006cfc:	00060a93          	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80006d00:	ffffc097          	auipc	ra,0xffffc
    80006d04:	9f8080e7          	jalr	-1544(ra) # 800026f8 <myproc>
    80006d08:	00050a13          	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80006d0c:	00048513          	mv	a0,s1
    80006d10:	ffffa097          	auipc	ra,0xffffa
    80006d14:	388080e7          	jalr	904(ra) # 80001098 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80006d18:	2184a703          	lw	a4,536(s1)
    80006d1c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80006d20:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80006d24:	02f71c63          	bne	a4,a5,80006d5c <piperead+0x90>
    80006d28:	2244a783          	lw	a5,548(s1)
    80006d2c:	02078863          	beqz	a5,80006d5c <piperead+0x90>
    if(killed(pr)){
    80006d30:	000a0513          	mv	a0,s4
    80006d34:	ffffc097          	auipc	ra,0xffffc
    80006d38:	72c080e7          	jalr	1836(ra) # 80003460 <killed>
    80006d3c:	0c051063          	bnez	a0,80006dfc <piperead+0x130>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80006d40:	00048593          	mv	a1,s1
    80006d44:	00098513          	mv	a0,s3
    80006d48:	ffffc097          	auipc	ra,0xffffc
    80006d4c:	368080e7          	jalr	872(ra) # 800030b0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80006d50:	2184a703          	lw	a4,536(s1)
    80006d54:	21c4a783          	lw	a5,540(s1)
    80006d58:	fcf708e3          	beq	a4,a5,80006d28 <piperead+0x5c>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006d5c:	00000993          	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80006d60:	fff00b13          	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006d64:	05505a63          	blez	s5,80006db8 <piperead+0xec>
    if(pi->nread == pi->nwrite)
    80006d68:	2184a783          	lw	a5,536(s1)
    80006d6c:	21c4a703          	lw	a4,540(s1)
    80006d70:	04f70463          	beq	a4,a5,80006db8 <piperead+0xec>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80006d74:	0017871b          	addiw	a4,a5,1
    80006d78:	20e4ac23          	sw	a4,536(s1)
    80006d7c:	1ff7f793          	andi	a5,a5,511
    80006d80:	00f487b3          	add	a5,s1,a5
    80006d84:	0187c783          	lbu	a5,24(a5)
    80006d88:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80006d8c:	00100693          	li	a3,1
    80006d90:	fbf40613          	addi	a2,s0,-65
    80006d94:	00090593          	mv	a1,s2
    80006d98:	050a3503          	ld	a0,80(s4)
    80006d9c:	ffffb097          	auipc	ra,0xffffb
    80006da0:	4e8080e7          	jalr	1256(ra) # 80002284 <copyout>
    80006da4:	01650a63          	beq	a0,s6,80006db8 <piperead+0xec>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006da8:	0019899b          	addiw	s3,s3,1
    80006dac:	00190913          	addi	s2,s2,1
    80006db0:	fb3a9ce3          	bne	s5,s3,80006d68 <piperead+0x9c>
    80006db4:	000a8993          	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80006db8:	21c48513          	addi	a0,s1,540
    80006dbc:	ffffc097          	auipc	ra,0xffffc
    80006dc0:	384080e7          	jalr	900(ra) # 80003140 <wakeup>
  release(&pi->lock);
    80006dc4:	00048513          	mv	a0,s1
    80006dc8:	ffffa097          	auipc	ra,0xffffa
    80006dcc:	3c8080e7          	jalr	968(ra) # 80001190 <release>
  return i;
}
    80006dd0:	00098513          	mv	a0,s3
    80006dd4:	04813083          	ld	ra,72(sp)
    80006dd8:	04013403          	ld	s0,64(sp)
    80006ddc:	03813483          	ld	s1,56(sp)
    80006de0:	03013903          	ld	s2,48(sp)
    80006de4:	02813983          	ld	s3,40(sp)
    80006de8:	02013a03          	ld	s4,32(sp)
    80006dec:	01813a83          	ld	s5,24(sp)
    80006df0:	01013b03          	ld	s6,16(sp)
    80006df4:	05010113          	addi	sp,sp,80
    80006df8:	00008067          	ret
      release(&pi->lock);
    80006dfc:	00048513          	mv	a0,s1
    80006e00:	ffffa097          	auipc	ra,0xffffa
    80006e04:	390080e7          	jalr	912(ra) # 80001190 <release>
      return -1;
    80006e08:	fff00993          	li	s3,-1
    80006e0c:	fc5ff06f          	j	80006dd0 <piperead+0x104>

0000000080006e10 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80006e10:	ff010113          	addi	sp,sp,-16
    80006e14:	00813423          	sd	s0,8(sp)
    80006e18:	01010413          	addi	s0,sp,16
    80006e1c:	00050793          	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80006e20:	00157513          	andi	a0,a0,1
    80006e24:	00351513          	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80006e28:	0027f793          	andi	a5,a5,2
    80006e2c:	00078463          	beqz	a5,80006e34 <flags2perm+0x24>
      perm |= PTE_W;
    80006e30:	00456513          	ori	a0,a0,4
    return perm;
}
    80006e34:	00813403          	ld	s0,8(sp)
    80006e38:	01010113          	addi	sp,sp,16
    80006e3c:	00008067          	ret

0000000080006e40 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80006e40:	de010113          	addi	sp,sp,-544
    80006e44:	20113c23          	sd	ra,536(sp)
    80006e48:	20813823          	sd	s0,528(sp)
    80006e4c:	20913423          	sd	s1,520(sp)
    80006e50:	21213023          	sd	s2,512(sp)
    80006e54:	1f313c23          	sd	s3,504(sp)
    80006e58:	1f413823          	sd	s4,496(sp)
    80006e5c:	1f513423          	sd	s5,488(sp)
    80006e60:	1f613023          	sd	s6,480(sp)
    80006e64:	1d713c23          	sd	s7,472(sp)
    80006e68:	1d813823          	sd	s8,464(sp)
    80006e6c:	1d913423          	sd	s9,456(sp)
    80006e70:	1da13023          	sd	s10,448(sp)
    80006e74:	1bb13c23          	sd	s11,440(sp)
    80006e78:	22010413          	addi	s0,sp,544
    80006e7c:	00050913          	mv	s2,a0
    80006e80:	dea43423          	sd	a0,-536(s0)
    80006e84:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80006e88:	ffffc097          	auipc	ra,0xffffc
    80006e8c:	870080e7          	jalr	-1936(ra) # 800026f8 <myproc>
    80006e90:	00050493          	mv	s1,a0

  begin_op();
    80006e94:	fffff097          	auipc	ra,0xfffff
    80006e98:	014080e7          	jalr	20(ra) # 80005ea8 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80006e9c:	00090513          	mv	a0,s2
    80006ea0:	fffff097          	auipc	ra,0xfffff
    80006ea4:	cf4080e7          	jalr	-780(ra) # 80005b94 <namei>
    80006ea8:	08050c63          	beqz	a0,80006f40 <kexec+0x100>
    80006eac:	00050a93          	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80006eb0:	ffffe097          	auipc	ra,0xffffe
    80006eb4:	ff8080e7          	jalr	-8(ra) # 80004ea8 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80006eb8:	04000713          	li	a4,64
    80006ebc:	00000693          	li	a3,0
    80006ec0:	e5040613          	addi	a2,s0,-432
    80006ec4:	00000593          	li	a1,0
    80006ec8:	000a8513          	mv	a0,s5
    80006ecc:	ffffe097          	auipc	ra,0xffffe
    80006ed0:	594080e7          	jalr	1428(ra) # 80005460 <readi>
    80006ed4:	04000793          	li	a5,64
    80006ed8:	00f51a63          	bne	a0,a5,80006eec <kexec+0xac>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80006edc:	e5042703          	lw	a4,-432(s0)
    80006ee0:	464c47b7          	lui	a5,0x464c4
    80006ee4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80006ee8:	06f70463          	beq	a4,a5,80006f50 <kexec+0x110>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80006eec:	000a8513          	mv	a0,s5
    80006ef0:	ffffe097          	auipc	ra,0xffffe
    80006ef4:	2f4080e7          	jalr	756(ra) # 800051e4 <iunlockput>
    end_op();
    80006ef8:	fffff097          	auipc	ra,0xfffff
    80006efc:	064080e7          	jalr	100(ra) # 80005f5c <end_op>
  }
  return -1;
    80006f00:	fff00513          	li	a0,-1
}
    80006f04:	21813083          	ld	ra,536(sp)
    80006f08:	21013403          	ld	s0,528(sp)
    80006f0c:	20813483          	ld	s1,520(sp)
    80006f10:	20013903          	ld	s2,512(sp)
    80006f14:	1f813983          	ld	s3,504(sp)
    80006f18:	1f013a03          	ld	s4,496(sp)
    80006f1c:	1e813a83          	ld	s5,488(sp)
    80006f20:	1e013b03          	ld	s6,480(sp)
    80006f24:	1d813b83          	ld	s7,472(sp)
    80006f28:	1d013c03          	ld	s8,464(sp)
    80006f2c:	1c813c83          	ld	s9,456(sp)
    80006f30:	1c013d03          	ld	s10,448(sp)
    80006f34:	1b813d83          	ld	s11,440(sp)
    80006f38:	22010113          	addi	sp,sp,544
    80006f3c:	00008067          	ret
    end_op();
    80006f40:	fffff097          	auipc	ra,0xfffff
    80006f44:	01c080e7          	jalr	28(ra) # 80005f5c <end_op>
    return -1;
    80006f48:	fff00513          	li	a0,-1
    80006f4c:	fb9ff06f          	j	80006f04 <kexec+0xc4>
  if((pagetable = proc_pagetable(p)) == 0)
    80006f50:	00048513          	mv	a0,s1
    80006f54:	ffffc097          	auipc	ra,0xffffc
    80006f58:	94c080e7          	jalr	-1716(ra) # 800028a0 <proc_pagetable>
    80006f5c:	00050b13          	mv	s6,a0
    80006f60:	f80506e3          	beqz	a0,80006eec <kexec+0xac>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006f64:	e7042783          	lw	a5,-400(s0)
    80006f68:	e8845703          	lhu	a4,-376(s0)
    80006f6c:	08070863          	beqz	a4,80006ffc <kexec+0x1bc>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80006f70:	00000913          	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006f74:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80006f78:	00001a37          	lui	s4,0x1
    80006f7c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80006f80:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80006f84:	00001db7          	lui	s11,0x1
    80006f88:	fffffd37          	lui	s10,0xfffff
    80006f8c:	2d80006f          	j	80007264 <kexec+0x424>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80006f90:	00004517          	auipc	a0,0x4
    80006f94:	88050513          	addi	a0,a0,-1920 # 8000a810 <syscalls+0x2c0>
    80006f98:	ffffa097          	auipc	ra,0xffffa
    80006f9c:	ae8080e7          	jalr	-1304(ra) # 80000a80 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80006fa0:	00090713          	mv	a4,s2
    80006fa4:	009c86bb          	addw	a3,s9,s1
    80006fa8:	00000593          	li	a1,0
    80006fac:	000a8513          	mv	a0,s5
    80006fb0:	ffffe097          	auipc	ra,0xffffe
    80006fb4:	4b0080e7          	jalr	1200(ra) # 80005460 <readi>
    80006fb8:	0005051b          	sext.w	a0,a0
    80006fbc:	22a91463          	bne	s2,a0,800071e4 <kexec+0x3a4>
  for(i = 0; i < sz; i += PGSIZE){
    80006fc0:	009d84bb          	addw	s1,s11,s1
    80006fc4:	013d09bb          	addw	s3,s10,s3
    80006fc8:	2774fe63          	bgeu	s1,s7,80007244 <kexec+0x404>
    pa = walkaddr(pagetable, va + i);
    80006fcc:	02049593          	slli	a1,s1,0x20
    80006fd0:	0205d593          	srli	a1,a1,0x20
    80006fd4:	018585b3          	add	a1,a1,s8
    80006fd8:	000b0513          	mv	a0,s6
    80006fdc:	ffffb097          	auipc	ra,0xffffb
    80006fe0:	80c080e7          	jalr	-2036(ra) # 800017e8 <walkaddr>
    80006fe4:	00050613          	mv	a2,a0
    if(pa == 0)
    80006fe8:	fa0504e3          	beqz	a0,80006f90 <kexec+0x150>
      n = PGSIZE;
    80006fec:	000a0913          	mv	s2,s4
    if(sz - i < PGSIZE)
    80006ff0:	fb49f8e3          	bgeu	s3,s4,80006fa0 <kexec+0x160>
      n = sz - i;
    80006ff4:	00098913          	mv	s2,s3
    80006ff8:	fa9ff06f          	j	80006fa0 <kexec+0x160>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80006ffc:	00000913          	li	s2,0
  iunlockput(ip);
    80007000:	000a8513          	mv	a0,s5
    80007004:	ffffe097          	auipc	ra,0xffffe
    80007008:	1e0080e7          	jalr	480(ra) # 800051e4 <iunlockput>
  end_op();
    8000700c:	fffff097          	auipc	ra,0xfffff
    80007010:	f50080e7          	jalr	-176(ra) # 80005f5c <end_op>
  p = myproc();
    80007014:	ffffb097          	auipc	ra,0xffffb
    80007018:	6e4080e7          	jalr	1764(ra) # 800026f8 <myproc>
    8000701c:	00050b93          	mv	s7,a0
  uint64 oldsz = p->sz;
    80007020:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80007024:	000017b7          	lui	a5,0x1
    80007028:	fff78793          	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000702c:	00f907b3          	add	a5,s2,a5
    80007030:	fffff737          	lui	a4,0xfffff
    80007034:	00e7f7b3          	and	a5,a5,a4
    80007038:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000703c:	00400693          	li	a3,4
    80007040:	00002637          	lui	a2,0x2
    80007044:	00c78633          	add	a2,a5,a2
    80007048:	00078593          	mv	a1,a5
    8000704c:	000b0513          	mv	a0,s6
    80007050:	ffffb097          	auipc	ra,0xffffb
    80007054:	c68080e7          	jalr	-920(ra) # 80001cb8 <uvmalloc>
    80007058:	00050c13          	mv	s8,a0
  ip = 0;
    8000705c:	00000a93          	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80007060:	18050263          	beqz	a0,800071e4 <kexec+0x3a4>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80007064:	ffffe5b7          	lui	a1,0xffffe
    80007068:	00b505b3          	add	a1,a0,a1
    8000706c:	000b0513          	mv	a0,s6
    80007070:	ffffb097          	auipc	ra,0xffffb
    80007074:	f90080e7          	jalr	-112(ra) # 80002000 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80007078:	fffffab7          	lui	s5,0xfffff
    8000707c:	015c0ab3          	add	s5,s8,s5
  for(argc = 0; argv[argc]; argc++) {
    80007080:	df043783          	ld	a5,-528(s0)
    80007084:	0007b503          	ld	a0,0(a5)
    80007088:	08050463          	beqz	a0,80007110 <kexec+0x2d0>
    8000708c:	e9040993          	addi	s3,s0,-368
    80007090:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80007094:	000c0913          	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80007098:	00000493          	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000709c:	ffffa097          	auipc	ra,0xffffa
    800070a0:	3a0080e7          	jalr	928(ra) # 8000143c <strlen>
    800070a4:	0015079b          	addiw	a5,a0,1
    800070a8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800070ac:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800070b0:	17596863          	bltu	s2,s5,80007220 <kexec+0x3e0>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800070b4:	df043d83          	ld	s11,-528(s0)
    800070b8:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800070bc:	000a0513          	mv	a0,s4
    800070c0:	ffffa097          	auipc	ra,0xffffa
    800070c4:	37c080e7          	jalr	892(ra) # 8000143c <strlen>
    800070c8:	0015069b          	addiw	a3,a0,1
    800070cc:	000a0613          	mv	a2,s4
    800070d0:	00090593          	mv	a1,s2
    800070d4:	000b0513          	mv	a0,s6
    800070d8:	ffffb097          	auipc	ra,0xffffb
    800070dc:	1ac080e7          	jalr	428(ra) # 80002284 <copyout>
    800070e0:	14054663          	bltz	a0,8000722c <kexec+0x3ec>
    ustack[argc] = sp;
    800070e4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800070e8:	00148493          	addi	s1,s1,1
    800070ec:	008d8793          	addi	a5,s11,8
    800070f0:	def43823          	sd	a5,-528(s0)
    800070f4:	008db503          	ld	a0,8(s11)
    800070f8:	02050063          	beqz	a0,80007118 <kexec+0x2d8>
    if(argc >= MAXARG)
    800070fc:	00898993          	addi	s3,s3,8
    80007100:	f93c9ee3          	bne	s9,s3,8000709c <kexec+0x25c>
  sz = sz1;
    80007104:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80007108:	00000a93          	li	s5,0
    8000710c:	0d80006f          	j	800071e4 <kexec+0x3a4>
  sp = sz;
    80007110:	000c0913          	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80007114:	00000493          	li	s1,0
  ustack[argc] = 0;
    80007118:	00349793          	slli	a5,s1,0x3
    8000711c:	f9078793          	addi	a5,a5,-112
    80007120:	008787b3          	add	a5,a5,s0
    80007124:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80007128:	00148693          	addi	a3,s1,1
    8000712c:	00369693          	slli	a3,a3,0x3
    80007130:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80007134:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80007138:	01597863          	bgeu	s2,s5,80007148 <kexec+0x308>
  sz = sz1;
    8000713c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80007140:	00000a93          	li	s5,0
    80007144:	0a00006f          	j	800071e4 <kexec+0x3a4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80007148:	e9040613          	addi	a2,s0,-368
    8000714c:	00090593          	mv	a1,s2
    80007150:	000b0513          	mv	a0,s6
    80007154:	ffffb097          	auipc	ra,0xffffb
    80007158:	130080e7          	jalr	304(ra) # 80002284 <copyout>
    8000715c:	0c054e63          	bltz	a0,80007238 <kexec+0x3f8>
  p->trapframe->a1 = sp;
    80007160:	058bb783          	ld	a5,88(s7)
    80007164:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80007168:	de843783          	ld	a5,-536(s0)
    8000716c:	0007c703          	lbu	a4,0(a5)
    80007170:	02070463          	beqz	a4,80007198 <kexec+0x358>
    80007174:	00178793          	addi	a5,a5,1
    if(*s == '/')
    80007178:	02f00693          	li	a3,47
    8000717c:	0140006f          	j	80007190 <kexec+0x350>
      last = s+1;
    80007180:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80007184:	00178793          	addi	a5,a5,1
    80007188:	fff7c703          	lbu	a4,-1(a5)
    8000718c:	00070663          	beqz	a4,80007198 <kexec+0x358>
    if(*s == '/')
    80007190:	fed71ae3          	bne	a4,a3,80007184 <kexec+0x344>
    80007194:	fedff06f          	j	80007180 <kexec+0x340>
  safestrcpy(p->name, last, sizeof(p->name));
    80007198:	01000613          	li	a2,16
    8000719c:	de843583          	ld	a1,-536(s0)
    800071a0:	158b8513          	addi	a0,s7,344
    800071a4:	ffffa097          	auipc	ra,0xffffa
    800071a8:	24c080e7          	jalr	588(ra) # 800013f0 <safestrcpy>
  oldpagetable = p->pagetable;
    800071ac:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800071b0:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800071b4:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800071b8:	058bb783          	ld	a5,88(s7)
    800071bc:	e6843703          	ld	a4,-408(s0)
    800071c0:	00e7bc23          	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800071c4:	058bb783          	ld	a5,88(s7)
    800071c8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800071cc:	000d0593          	mv	a1,s10
    800071d0:	ffffb097          	auipc	ra,0xffffb
    800071d4:	7b8080e7          	jalr	1976(ra) # 80002988 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800071d8:	0004851b          	sext.w	a0,s1
    800071dc:	d29ff06f          	j	80006f04 <kexec+0xc4>
    800071e0:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800071e4:	df843583          	ld	a1,-520(s0)
    800071e8:	000b0513          	mv	a0,s6
    800071ec:	ffffb097          	auipc	ra,0xffffb
    800071f0:	79c080e7          	jalr	1948(ra) # 80002988 <proc_freepagetable>
  if(ip){
    800071f4:	ce0a9ce3          	bnez	s5,80006eec <kexec+0xac>
  return -1;
    800071f8:	fff00513          	li	a0,-1
    800071fc:	d09ff06f          	j	80006f04 <kexec+0xc4>
    80007200:	df243c23          	sd	s2,-520(s0)
    80007204:	fe1ff06f          	j	800071e4 <kexec+0x3a4>
    80007208:	df243c23          	sd	s2,-520(s0)
    8000720c:	fd9ff06f          	j	800071e4 <kexec+0x3a4>
    80007210:	df243c23          	sd	s2,-520(s0)
    80007214:	fd1ff06f          	j	800071e4 <kexec+0x3a4>
    80007218:	df243c23          	sd	s2,-520(s0)
    8000721c:	fc9ff06f          	j	800071e4 <kexec+0x3a4>
  sz = sz1;
    80007220:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80007224:	00000a93          	li	s5,0
    80007228:	fbdff06f          	j	800071e4 <kexec+0x3a4>
  sz = sz1;
    8000722c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80007230:	00000a93          	li	s5,0
    80007234:	fb1ff06f          	j	800071e4 <kexec+0x3a4>
  sz = sz1;
    80007238:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000723c:	00000a93          	li	s5,0
    80007240:	fa5ff06f          	j	800071e4 <kexec+0x3a4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80007244:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80007248:	e0843783          	ld	a5,-504(s0)
    8000724c:	0017869b          	addiw	a3,a5,1
    80007250:	e0d43423          	sd	a3,-504(s0)
    80007254:	e0043783          	ld	a5,-512(s0)
    80007258:	0387879b          	addiw	a5,a5,56
    8000725c:	e8845703          	lhu	a4,-376(s0)
    80007260:	dae6d0e3          	bge	a3,a4,80007000 <kexec+0x1c0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80007264:	0007879b          	sext.w	a5,a5
    80007268:	e0f43023          	sd	a5,-512(s0)
    8000726c:	03800713          	li	a4,56
    80007270:	00078693          	mv	a3,a5
    80007274:	e1840613          	addi	a2,s0,-488
    80007278:	00000593          	li	a1,0
    8000727c:	000a8513          	mv	a0,s5
    80007280:	ffffe097          	auipc	ra,0xffffe
    80007284:	1e0080e7          	jalr	480(ra) # 80005460 <readi>
    80007288:	03800793          	li	a5,56
    8000728c:	f4f51ae3          	bne	a0,a5,800071e0 <kexec+0x3a0>
    if(ph.type != ELF_PROG_LOAD)
    80007290:	e1842783          	lw	a5,-488(s0)
    80007294:	00100713          	li	a4,1
    80007298:	fae798e3          	bne	a5,a4,80007248 <kexec+0x408>
    if(ph.memsz < ph.filesz)
    8000729c:	e4043483          	ld	s1,-448(s0)
    800072a0:	e3843783          	ld	a5,-456(s0)
    800072a4:	f4f4eee3          	bltu	s1,a5,80007200 <kexec+0x3c0>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800072a8:	e2843783          	ld	a5,-472(s0)
    800072ac:	00f484b3          	add	s1,s1,a5
    800072b0:	f4f4ece3          	bltu	s1,a5,80007208 <kexec+0x3c8>
    if(ph.vaddr % PGSIZE != 0)
    800072b4:	de043703          	ld	a4,-544(s0)
    800072b8:	00e7f7b3          	and	a5,a5,a4
    800072bc:	f4079ae3          	bnez	a5,80007210 <kexec+0x3d0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800072c0:	e1c42503          	lw	a0,-484(s0)
    800072c4:	00000097          	auipc	ra,0x0
    800072c8:	b4c080e7          	jalr	-1204(ra) # 80006e10 <flags2perm>
    800072cc:	00050693          	mv	a3,a0
    800072d0:	00048613          	mv	a2,s1
    800072d4:	00090593          	mv	a1,s2
    800072d8:	000b0513          	mv	a0,s6
    800072dc:	ffffb097          	auipc	ra,0xffffb
    800072e0:	9dc080e7          	jalr	-1572(ra) # 80001cb8 <uvmalloc>
    800072e4:	dea43c23          	sd	a0,-520(s0)
    800072e8:	f20508e3          	beqz	a0,80007218 <kexec+0x3d8>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800072ec:	e2843c03          	ld	s8,-472(s0)
    800072f0:	e2042c83          	lw	s9,-480(s0)
    800072f4:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800072f8:	f40b86e3          	beqz	s7,80007244 <kexec+0x404>
    800072fc:	000b8993          	mv	s3,s7
    80007300:	00000493          	li	s1,0
    80007304:	cc9ff06f          	j	80006fcc <kexec+0x18c>

0000000080007308 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80007308:	fd010113          	addi	sp,sp,-48
    8000730c:	02113423          	sd	ra,40(sp)
    80007310:	02813023          	sd	s0,32(sp)
    80007314:	00913c23          	sd	s1,24(sp)
    80007318:	01213823          	sd	s2,16(sp)
    8000731c:	03010413          	addi	s0,sp,48
    80007320:	00058913          	mv	s2,a1
    80007324:	00060493          	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80007328:	fdc40593          	addi	a1,s0,-36
    8000732c:	ffffd097          	auipc	ra,0xffffd
    80007330:	c18080e7          	jalr	-1000(ra) # 80003f44 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80007334:	fdc42703          	lw	a4,-36(s0)
    80007338:	00f00793          	li	a5,15
    8000733c:	04e7e863          	bltu	a5,a4,8000738c <argfd+0x84>
    80007340:	ffffb097          	auipc	ra,0xffffb
    80007344:	3b8080e7          	jalr	952(ra) # 800026f8 <myproc>
    80007348:	fdc42703          	lw	a4,-36(s0)
    8000734c:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdb352>
    80007350:	00379793          	slli	a5,a5,0x3
    80007354:	00f50533          	add	a0,a0,a5
    80007358:	00053783          	ld	a5,0(a0)
    8000735c:	02078c63          	beqz	a5,80007394 <argfd+0x8c>
    return -1;
  if(pfd)
    80007360:	00090463          	beqz	s2,80007368 <argfd+0x60>
    *pfd = fd;
    80007364:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80007368:	00000513          	li	a0,0
  if(pf)
    8000736c:	00048463          	beqz	s1,80007374 <argfd+0x6c>
    *pf = f;
    80007370:	00f4b023          	sd	a5,0(s1)
}
    80007374:	02813083          	ld	ra,40(sp)
    80007378:	02013403          	ld	s0,32(sp)
    8000737c:	01813483          	ld	s1,24(sp)
    80007380:	01013903          	ld	s2,16(sp)
    80007384:	03010113          	addi	sp,sp,48
    80007388:	00008067          	ret
    return -1;
    8000738c:	fff00513          	li	a0,-1
    80007390:	fe5ff06f          	j	80007374 <argfd+0x6c>
    80007394:	fff00513          	li	a0,-1
    80007398:	fddff06f          	j	80007374 <argfd+0x6c>

000000008000739c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000739c:	fe010113          	addi	sp,sp,-32
    800073a0:	00113c23          	sd	ra,24(sp)
    800073a4:	00813823          	sd	s0,16(sp)
    800073a8:	00913423          	sd	s1,8(sp)
    800073ac:	02010413          	addi	s0,sp,32
    800073b0:	00050493          	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800073b4:	ffffb097          	auipc	ra,0xffffb
    800073b8:	344080e7          	jalr	836(ra) # 800026f8 <myproc>
    800073bc:	00050613          	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800073c0:	0d050793          	addi	a5,a0,208
    800073c4:	00000513          	li	a0,0
    800073c8:	01000693          	li	a3,16
    if(p->ofile[fd] == 0){
    800073cc:	0007b703          	ld	a4,0(a5)
    800073d0:	02070463          	beqz	a4,800073f8 <fdalloc+0x5c>
  for(fd = 0; fd < NOFILE; fd++){
    800073d4:	0015051b          	addiw	a0,a0,1
    800073d8:	00878793          	addi	a5,a5,8
    800073dc:	fed518e3          	bne	a0,a3,800073cc <fdalloc+0x30>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800073e0:	fff00513          	li	a0,-1
}
    800073e4:	01813083          	ld	ra,24(sp)
    800073e8:	01013403          	ld	s0,16(sp)
    800073ec:	00813483          	ld	s1,8(sp)
    800073f0:	02010113          	addi	sp,sp,32
    800073f4:	00008067          	ret
      p->ofile[fd] = f;
    800073f8:	01a50793          	addi	a5,a0,26
    800073fc:	00379793          	slli	a5,a5,0x3
    80007400:	00f60633          	add	a2,a2,a5
    80007404:	00963023          	sd	s1,0(a2) # 2000 <_entry-0x7fffe000>
      return fd;
    80007408:	fddff06f          	j	800073e4 <fdalloc+0x48>

000000008000740c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000740c:	fb010113          	addi	sp,sp,-80
    80007410:	04113423          	sd	ra,72(sp)
    80007414:	04813023          	sd	s0,64(sp)
    80007418:	02913c23          	sd	s1,56(sp)
    8000741c:	03213823          	sd	s2,48(sp)
    80007420:	03313423          	sd	s3,40(sp)
    80007424:	03413023          	sd	s4,32(sp)
    80007428:	01513c23          	sd	s5,24(sp)
    8000742c:	01613823          	sd	s6,16(sp)
    80007430:	05010413          	addi	s0,sp,80
    80007434:	00058b13          	mv	s6,a1
    80007438:	00060993          	mv	s3,a2
    8000743c:	00068913          	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80007440:	fb040593          	addi	a1,s0,-80
    80007444:	ffffe097          	auipc	ra,0xffffe
    80007448:	780080e7          	jalr	1920(ra) # 80005bc4 <nameiparent>
    8000744c:	00050493          	mv	s1,a0
    80007450:	1c050063          	beqz	a0,80007610 <create+0x204>
    return 0;

  ilock(dp);
    80007454:	ffffe097          	auipc	ra,0xffffe
    80007458:	a54080e7          	jalr	-1452(ra) # 80004ea8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000745c:	00000613          	li	a2,0
    80007460:	fb040593          	addi	a1,s0,-80
    80007464:	00048513          	mv	a0,s1
    80007468:	ffffe097          	auipc	ra,0xffffe
    8000746c:	330080e7          	jalr	816(ra) # 80005798 <dirlookup>
    80007470:	00050a93          	mv	s5,a0
    80007474:	08050063          	beqz	a0,800074f4 <create+0xe8>
    iunlockput(dp);
    80007478:	00048513          	mv	a0,s1
    8000747c:	ffffe097          	auipc	ra,0xffffe
    80007480:	d68080e7          	jalr	-664(ra) # 800051e4 <iunlockput>
    ilock(ip);
    80007484:	000a8513          	mv	a0,s5
    80007488:	ffffe097          	auipc	ra,0xffffe
    8000748c:	a20080e7          	jalr	-1504(ra) # 80004ea8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80007490:	000b059b          	sext.w	a1,s6
    80007494:	00200793          	li	a5,2
    80007498:	04f59463          	bne	a1,a5,800074e0 <create+0xd4>
    8000749c:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdb37c>
    800074a0:	ffe7879b          	addiw	a5,a5,-2
    800074a4:	03079793          	slli	a5,a5,0x30
    800074a8:	0307d793          	srli	a5,a5,0x30
    800074ac:	00100713          	li	a4,1
    800074b0:	02f76863          	bltu	a4,a5,800074e0 <create+0xd4>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800074b4:	000a8513          	mv	a0,s5
    800074b8:	04813083          	ld	ra,72(sp)
    800074bc:	04013403          	ld	s0,64(sp)
    800074c0:	03813483          	ld	s1,56(sp)
    800074c4:	03013903          	ld	s2,48(sp)
    800074c8:	02813983          	ld	s3,40(sp)
    800074cc:	02013a03          	ld	s4,32(sp)
    800074d0:	01813a83          	ld	s5,24(sp)
    800074d4:	01013b03          	ld	s6,16(sp)
    800074d8:	05010113          	addi	sp,sp,80
    800074dc:	00008067          	ret
    iunlockput(ip);
    800074e0:	000a8513          	mv	a0,s5
    800074e4:	ffffe097          	auipc	ra,0xffffe
    800074e8:	d00080e7          	jalr	-768(ra) # 800051e4 <iunlockput>
    return 0;
    800074ec:	00000a93          	li	s5,0
    800074f0:	fc5ff06f          	j	800074b4 <create+0xa8>
  if((ip = ialloc(dp->dev, type)) == 0){
    800074f4:	000b0593          	mv	a1,s6
    800074f8:	0004a503          	lw	a0,0(s1)
    800074fc:	ffffd097          	auipc	ra,0xffffd
    80007500:	76c080e7          	jalr	1900(ra) # 80004c68 <ialloc>
    80007504:	00050a13          	mv	s4,a0
    80007508:	04050e63          	beqz	a0,80007564 <create+0x158>
  ilock(ip);
    8000750c:	ffffe097          	auipc	ra,0xffffe
    80007510:	99c080e7          	jalr	-1636(ra) # 80004ea8 <ilock>
  ip->major = major;
    80007514:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80007518:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000751c:	00100913          	li	s2,1
    80007520:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80007524:	000a0513          	mv	a0,s4
    80007528:	ffffe097          	auipc	ra,0xffffe
    8000752c:	864080e7          	jalr	-1948(ra) # 80004d8c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80007530:	000b059b          	sext.w	a1,s6
    80007534:	05258263          	beq	a1,s2,80007578 <create+0x16c>
  if(dirlink(dp, name, ip->inum) < 0)
    80007538:	004a2603          	lw	a2,4(s4)
    8000753c:	fb040593          	addi	a1,s0,-80
    80007540:	00048513          	mv	a0,s1
    80007544:	ffffe097          	auipc	ra,0xffffe
    80007548:	550080e7          	jalr	1360(ra) # 80005a94 <dirlink>
    8000754c:	08054c63          	bltz	a0,800075e4 <create+0x1d8>
  iunlockput(dp);
    80007550:	00048513          	mv	a0,s1
    80007554:	ffffe097          	auipc	ra,0xffffe
    80007558:	c90080e7          	jalr	-880(ra) # 800051e4 <iunlockput>
  return ip;
    8000755c:	000a0a93          	mv	s5,s4
    80007560:	f55ff06f          	j	800074b4 <create+0xa8>
    iunlockput(dp);
    80007564:	00048513          	mv	a0,s1
    80007568:	ffffe097          	auipc	ra,0xffffe
    8000756c:	c7c080e7          	jalr	-900(ra) # 800051e4 <iunlockput>
    return 0;
    80007570:	000a0a93          	mv	s5,s4
    80007574:	f41ff06f          	j	800074b4 <create+0xa8>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80007578:	004a2603          	lw	a2,4(s4)
    8000757c:	00003597          	auipc	a1,0x3
    80007580:	2b458593          	addi	a1,a1,692 # 8000a830 <syscalls+0x2e0>
    80007584:	000a0513          	mv	a0,s4
    80007588:	ffffe097          	auipc	ra,0xffffe
    8000758c:	50c080e7          	jalr	1292(ra) # 80005a94 <dirlink>
    80007590:	04054a63          	bltz	a0,800075e4 <create+0x1d8>
    80007594:	0044a603          	lw	a2,4(s1)
    80007598:	00003597          	auipc	a1,0x3
    8000759c:	2a058593          	addi	a1,a1,672 # 8000a838 <syscalls+0x2e8>
    800075a0:	000a0513          	mv	a0,s4
    800075a4:	ffffe097          	auipc	ra,0xffffe
    800075a8:	4f0080e7          	jalr	1264(ra) # 80005a94 <dirlink>
    800075ac:	02054c63          	bltz	a0,800075e4 <create+0x1d8>
  if(dirlink(dp, name, ip->inum) < 0)
    800075b0:	004a2603          	lw	a2,4(s4)
    800075b4:	fb040593          	addi	a1,s0,-80
    800075b8:	00048513          	mv	a0,s1
    800075bc:	ffffe097          	auipc	ra,0xffffe
    800075c0:	4d8080e7          	jalr	1240(ra) # 80005a94 <dirlink>
    800075c4:	02054063          	bltz	a0,800075e4 <create+0x1d8>
    dp->nlink++;  // for ".."
    800075c8:	04a4d783          	lhu	a5,74(s1)
    800075cc:	0017879b          	addiw	a5,a5,1
    800075d0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800075d4:	00048513          	mv	a0,s1
    800075d8:	ffffd097          	auipc	ra,0xffffd
    800075dc:	7b4080e7          	jalr	1972(ra) # 80004d8c <iupdate>
    800075e0:	f71ff06f          	j	80007550 <create+0x144>
  ip->nlink = 0;
    800075e4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800075e8:	000a0513          	mv	a0,s4
    800075ec:	ffffd097          	auipc	ra,0xffffd
    800075f0:	7a0080e7          	jalr	1952(ra) # 80004d8c <iupdate>
  iunlockput(ip);
    800075f4:	000a0513          	mv	a0,s4
    800075f8:	ffffe097          	auipc	ra,0xffffe
    800075fc:	bec080e7          	jalr	-1044(ra) # 800051e4 <iunlockput>
  iunlockput(dp);
    80007600:	00048513          	mv	a0,s1
    80007604:	ffffe097          	auipc	ra,0xffffe
    80007608:	be0080e7          	jalr	-1056(ra) # 800051e4 <iunlockput>
  return 0;
    8000760c:	ea9ff06f          	j	800074b4 <create+0xa8>
    return 0;
    80007610:	00050a93          	mv	s5,a0
    80007614:	ea1ff06f          	j	800074b4 <create+0xa8>

0000000080007618 <sys_dup>:
{
    80007618:	fd010113          	addi	sp,sp,-48
    8000761c:	02113423          	sd	ra,40(sp)
    80007620:	02813023          	sd	s0,32(sp)
    80007624:	00913c23          	sd	s1,24(sp)
    80007628:	01213823          	sd	s2,16(sp)
    8000762c:	03010413          	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80007630:	fd840613          	addi	a2,s0,-40
    80007634:	00000593          	li	a1,0
    80007638:	00000513          	li	a0,0
    8000763c:	00000097          	auipc	ra,0x0
    80007640:	ccc080e7          	jalr	-820(ra) # 80007308 <argfd>
    return -1;
    80007644:	fff00793          	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80007648:	02054863          	bltz	a0,80007678 <sys_dup+0x60>
  if((fd=fdalloc(f)) < 0)
    8000764c:	fd843903          	ld	s2,-40(s0)
    80007650:	00090513          	mv	a0,s2
    80007654:	00000097          	auipc	ra,0x0
    80007658:	d48080e7          	jalr	-696(ra) # 8000739c <fdalloc>
    8000765c:	00050493          	mv	s1,a0
    return -1;
    80007660:	fff00793          	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80007664:	00054a63          	bltz	a0,80007678 <sys_dup+0x60>
  filedup(f);
    80007668:	00090513          	mv	a0,s2
    8000766c:	fffff097          	auipc	ra,0xfffff
    80007670:	e48080e7          	jalr	-440(ra) # 800064b4 <filedup>
  return fd;
    80007674:	00048793          	mv	a5,s1
}
    80007678:	00078513          	mv	a0,a5
    8000767c:	02813083          	ld	ra,40(sp)
    80007680:	02013403          	ld	s0,32(sp)
    80007684:	01813483          	ld	s1,24(sp)
    80007688:	01013903          	ld	s2,16(sp)
    8000768c:	03010113          	addi	sp,sp,48
    80007690:	00008067          	ret

0000000080007694 <sys_read>:
{
    80007694:	fd010113          	addi	sp,sp,-48
    80007698:	02113423          	sd	ra,40(sp)
    8000769c:	02813023          	sd	s0,32(sp)
    800076a0:	03010413          	addi	s0,sp,48
  argaddr(1, &p);
    800076a4:	fd840593          	addi	a1,s0,-40
    800076a8:	00100513          	li	a0,1
    800076ac:	ffffd097          	auipc	ra,0xffffd
    800076b0:	8d0080e7          	jalr	-1840(ra) # 80003f7c <argaddr>
  argint(2, &n);
    800076b4:	fe440593          	addi	a1,s0,-28
    800076b8:	00200513          	li	a0,2
    800076bc:	ffffd097          	auipc	ra,0xffffd
    800076c0:	888080e7          	jalr	-1912(ra) # 80003f44 <argint>
  if(argfd(0, 0, &f) < 0)
    800076c4:	fe840613          	addi	a2,s0,-24
    800076c8:	00000593          	li	a1,0
    800076cc:	00000513          	li	a0,0
    800076d0:	00000097          	auipc	ra,0x0
    800076d4:	c38080e7          	jalr	-968(ra) # 80007308 <argfd>
    800076d8:	00050793          	mv	a5,a0
    return -1;
    800076dc:	fff00513          	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800076e0:	0007cc63          	bltz	a5,800076f8 <sys_read+0x64>
  return fileread(f, p, n);
    800076e4:	fe442603          	lw	a2,-28(s0)
    800076e8:	fd843583          	ld	a1,-40(s0)
    800076ec:	fe843503          	ld	a0,-24(s0)
    800076f0:	fffff097          	auipc	ra,0xfffff
    800076f4:	fe0080e7          	jalr	-32(ra) # 800066d0 <fileread>
}
    800076f8:	02813083          	ld	ra,40(sp)
    800076fc:	02013403          	ld	s0,32(sp)
    80007700:	03010113          	addi	sp,sp,48
    80007704:	00008067          	ret

0000000080007708 <sys_write>:
{
    80007708:	fd010113          	addi	sp,sp,-48
    8000770c:	02113423          	sd	ra,40(sp)
    80007710:	02813023          	sd	s0,32(sp)
    80007714:	03010413          	addi	s0,sp,48
  argaddr(1, &p);
    80007718:	fd840593          	addi	a1,s0,-40
    8000771c:	00100513          	li	a0,1
    80007720:	ffffd097          	auipc	ra,0xffffd
    80007724:	85c080e7          	jalr	-1956(ra) # 80003f7c <argaddr>
  argint(2, &n);
    80007728:	fe440593          	addi	a1,s0,-28
    8000772c:	00200513          	li	a0,2
    80007730:	ffffd097          	auipc	ra,0xffffd
    80007734:	814080e7          	jalr	-2028(ra) # 80003f44 <argint>
  if(argfd(0, 0, &f) < 0)
    80007738:	fe840613          	addi	a2,s0,-24
    8000773c:	00000593          	li	a1,0
    80007740:	00000513          	li	a0,0
    80007744:	00000097          	auipc	ra,0x0
    80007748:	bc4080e7          	jalr	-1084(ra) # 80007308 <argfd>
    8000774c:	00050793          	mv	a5,a0
    return -1;
    80007750:	fff00513          	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80007754:	0007cc63          	bltz	a5,8000776c <sys_write+0x64>
  return filewrite(f, p, n);
    80007758:	fe442603          	lw	a2,-28(s0)
    8000775c:	fd843583          	ld	a1,-40(s0)
    80007760:	fe843503          	ld	a0,-24(s0)
    80007764:	fffff097          	auipc	ra,0xfffff
    80007768:	098080e7          	jalr	152(ra) # 800067fc <filewrite>
}
    8000776c:	02813083          	ld	ra,40(sp)
    80007770:	02013403          	ld	s0,32(sp)
    80007774:	03010113          	addi	sp,sp,48
    80007778:	00008067          	ret

000000008000777c <sys_close>:
{
    8000777c:	fe010113          	addi	sp,sp,-32
    80007780:	00113c23          	sd	ra,24(sp)
    80007784:	00813823          	sd	s0,16(sp)
    80007788:	02010413          	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000778c:	fe040613          	addi	a2,s0,-32
    80007790:	fec40593          	addi	a1,s0,-20
    80007794:	00000513          	li	a0,0
    80007798:	00000097          	auipc	ra,0x0
    8000779c:	b70080e7          	jalr	-1168(ra) # 80007308 <argfd>
    return -1;
    800077a0:	fff00793          	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800077a4:	02054863          	bltz	a0,800077d4 <sys_close+0x58>
  myproc()->ofile[fd] = 0;
    800077a8:	ffffb097          	auipc	ra,0xffffb
    800077ac:	f50080e7          	jalr	-176(ra) # 800026f8 <myproc>
    800077b0:	fec42783          	lw	a5,-20(s0)
    800077b4:	01a78793          	addi	a5,a5,26
    800077b8:	00379793          	slli	a5,a5,0x3
    800077bc:	00f50533          	add	a0,a0,a5
    800077c0:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800077c4:	fe043503          	ld	a0,-32(s0)
    800077c8:	fffff097          	auipc	ra,0xfffff
    800077cc:	d5c080e7          	jalr	-676(ra) # 80006524 <fileclose>
  return 0;
    800077d0:	00000793          	li	a5,0
}
    800077d4:	00078513          	mv	a0,a5
    800077d8:	01813083          	ld	ra,24(sp)
    800077dc:	01013403          	ld	s0,16(sp)
    800077e0:	02010113          	addi	sp,sp,32
    800077e4:	00008067          	ret

00000000800077e8 <sys_fstat>:
{
    800077e8:	fe010113          	addi	sp,sp,-32
    800077ec:	00113c23          	sd	ra,24(sp)
    800077f0:	00813823          	sd	s0,16(sp)
    800077f4:	02010413          	addi	s0,sp,32
  argaddr(1, &st);
    800077f8:	fe040593          	addi	a1,s0,-32
    800077fc:	00100513          	li	a0,1
    80007800:	ffffc097          	auipc	ra,0xffffc
    80007804:	77c080e7          	jalr	1916(ra) # 80003f7c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80007808:	fe840613          	addi	a2,s0,-24
    8000780c:	00000593          	li	a1,0
    80007810:	00000513          	li	a0,0
    80007814:	00000097          	auipc	ra,0x0
    80007818:	af4080e7          	jalr	-1292(ra) # 80007308 <argfd>
    8000781c:	00050793          	mv	a5,a0
    return -1;
    80007820:	fff00513          	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80007824:	0007ca63          	bltz	a5,80007838 <sys_fstat+0x50>
  return filestat(f, st);
    80007828:	fe043583          	ld	a1,-32(s0)
    8000782c:	fe843503          	ld	a0,-24(s0)
    80007830:	fffff097          	auipc	ra,0xfffff
    80007834:	df8080e7          	jalr	-520(ra) # 80006628 <filestat>
}
    80007838:	01813083          	ld	ra,24(sp)
    8000783c:	01013403          	ld	s0,16(sp)
    80007840:	02010113          	addi	sp,sp,32
    80007844:	00008067          	ret

0000000080007848 <sys_link>:
{
    80007848:	ed010113          	addi	sp,sp,-304
    8000784c:	12113423          	sd	ra,296(sp)
    80007850:	12813023          	sd	s0,288(sp)
    80007854:	10913c23          	sd	s1,280(sp)
    80007858:	11213823          	sd	s2,272(sp)
    8000785c:	13010413          	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80007860:	08000613          	li	a2,128
    80007864:	ed040593          	addi	a1,s0,-304
    80007868:	00000513          	li	a0,0
    8000786c:	ffffc097          	auipc	ra,0xffffc
    80007870:	748080e7          	jalr	1864(ra) # 80003fb4 <argstr>
    return -1;
    80007874:	fff00793          	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80007878:	14054a63          	bltz	a0,800079cc <sys_link+0x184>
    8000787c:	08000613          	li	a2,128
    80007880:	f5040593          	addi	a1,s0,-176
    80007884:	00100513          	li	a0,1
    80007888:	ffffc097          	auipc	ra,0xffffc
    8000788c:	72c080e7          	jalr	1836(ra) # 80003fb4 <argstr>
    return -1;
    80007890:	fff00793          	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80007894:	12054c63          	bltz	a0,800079cc <sys_link+0x184>
  begin_op();
    80007898:	ffffe097          	auipc	ra,0xffffe
    8000789c:	610080e7          	jalr	1552(ra) # 80005ea8 <begin_op>
  if((ip = namei(old)) == 0){
    800078a0:	ed040513          	addi	a0,s0,-304
    800078a4:	ffffe097          	auipc	ra,0xffffe
    800078a8:	2f0080e7          	jalr	752(ra) # 80005b94 <namei>
    800078ac:	00050493          	mv	s1,a0
    800078b0:	0a050463          	beqz	a0,80007958 <sys_link+0x110>
  ilock(ip);
    800078b4:	ffffd097          	auipc	ra,0xffffd
    800078b8:	5f4080e7          	jalr	1524(ra) # 80004ea8 <ilock>
  if(ip->type == T_DIR){
    800078bc:	04449703          	lh	a4,68(s1)
    800078c0:	00100793          	li	a5,1
    800078c4:	0af70263          	beq	a4,a5,80007968 <sys_link+0x120>
  ip->nlink++;
    800078c8:	04a4d783          	lhu	a5,74(s1)
    800078cc:	0017879b          	addiw	a5,a5,1
    800078d0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800078d4:	00048513          	mv	a0,s1
    800078d8:	ffffd097          	auipc	ra,0xffffd
    800078dc:	4b4080e7          	jalr	1204(ra) # 80004d8c <iupdate>
  iunlock(ip);
    800078e0:	00048513          	mv	a0,s1
    800078e4:	ffffd097          	auipc	ra,0xffffd
    800078e8:	6c8080e7          	jalr	1736(ra) # 80004fac <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800078ec:	fd040593          	addi	a1,s0,-48
    800078f0:	f5040513          	addi	a0,s0,-176
    800078f4:	ffffe097          	auipc	ra,0xffffe
    800078f8:	2d0080e7          	jalr	720(ra) # 80005bc4 <nameiparent>
    800078fc:	00050913          	mv	s2,a0
    80007900:	08050863          	beqz	a0,80007990 <sys_link+0x148>
  ilock(dp);
    80007904:	ffffd097          	auipc	ra,0xffffd
    80007908:	5a4080e7          	jalr	1444(ra) # 80004ea8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000790c:	00092703          	lw	a4,0(s2)
    80007910:	0004a783          	lw	a5,0(s1)
    80007914:	06f71863          	bne	a4,a5,80007984 <sys_link+0x13c>
    80007918:	0044a603          	lw	a2,4(s1)
    8000791c:	fd040593          	addi	a1,s0,-48
    80007920:	00090513          	mv	a0,s2
    80007924:	ffffe097          	auipc	ra,0xffffe
    80007928:	170080e7          	jalr	368(ra) # 80005a94 <dirlink>
    8000792c:	04054c63          	bltz	a0,80007984 <sys_link+0x13c>
  iunlockput(dp);
    80007930:	00090513          	mv	a0,s2
    80007934:	ffffe097          	auipc	ra,0xffffe
    80007938:	8b0080e7          	jalr	-1872(ra) # 800051e4 <iunlockput>
  iput(ip);
    8000793c:	00048513          	mv	a0,s1
    80007940:	ffffd097          	auipc	ra,0xffffd
    80007944:	7c8080e7          	jalr	1992(ra) # 80005108 <iput>
  end_op();
    80007948:	ffffe097          	auipc	ra,0xffffe
    8000794c:	614080e7          	jalr	1556(ra) # 80005f5c <end_op>
  return 0;
    80007950:	00000793          	li	a5,0
    80007954:	0780006f          	j	800079cc <sys_link+0x184>
    end_op();
    80007958:	ffffe097          	auipc	ra,0xffffe
    8000795c:	604080e7          	jalr	1540(ra) # 80005f5c <end_op>
    return -1;
    80007960:	fff00793          	li	a5,-1
    80007964:	0680006f          	j	800079cc <sys_link+0x184>
    iunlockput(ip);
    80007968:	00048513          	mv	a0,s1
    8000796c:	ffffe097          	auipc	ra,0xffffe
    80007970:	878080e7          	jalr	-1928(ra) # 800051e4 <iunlockput>
    end_op();
    80007974:	ffffe097          	auipc	ra,0xffffe
    80007978:	5e8080e7          	jalr	1512(ra) # 80005f5c <end_op>
    return -1;
    8000797c:	fff00793          	li	a5,-1
    80007980:	04c0006f          	j	800079cc <sys_link+0x184>
    iunlockput(dp);
    80007984:	00090513          	mv	a0,s2
    80007988:	ffffe097          	auipc	ra,0xffffe
    8000798c:	85c080e7          	jalr	-1956(ra) # 800051e4 <iunlockput>
  ilock(ip);
    80007990:	00048513          	mv	a0,s1
    80007994:	ffffd097          	auipc	ra,0xffffd
    80007998:	514080e7          	jalr	1300(ra) # 80004ea8 <ilock>
  ip->nlink--;
    8000799c:	04a4d783          	lhu	a5,74(s1)
    800079a0:	fff7879b          	addiw	a5,a5,-1
    800079a4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800079a8:	00048513          	mv	a0,s1
    800079ac:	ffffd097          	auipc	ra,0xffffd
    800079b0:	3e0080e7          	jalr	992(ra) # 80004d8c <iupdate>
  iunlockput(ip);
    800079b4:	00048513          	mv	a0,s1
    800079b8:	ffffe097          	auipc	ra,0xffffe
    800079bc:	82c080e7          	jalr	-2004(ra) # 800051e4 <iunlockput>
  end_op();
    800079c0:	ffffe097          	auipc	ra,0xffffe
    800079c4:	59c080e7          	jalr	1436(ra) # 80005f5c <end_op>
  return -1;
    800079c8:	fff00793          	li	a5,-1
}
    800079cc:	00078513          	mv	a0,a5
    800079d0:	12813083          	ld	ra,296(sp)
    800079d4:	12013403          	ld	s0,288(sp)
    800079d8:	11813483          	ld	s1,280(sp)
    800079dc:	11013903          	ld	s2,272(sp)
    800079e0:	13010113          	addi	sp,sp,304
    800079e4:	00008067          	ret

00000000800079e8 <sys_unlink>:
{
    800079e8:	f1010113          	addi	sp,sp,-240
    800079ec:	0e113423          	sd	ra,232(sp)
    800079f0:	0e813023          	sd	s0,224(sp)
    800079f4:	0c913c23          	sd	s1,216(sp)
    800079f8:	0d213823          	sd	s2,208(sp)
    800079fc:	0d313423          	sd	s3,200(sp)
    80007a00:	0f010413          	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80007a04:	08000613          	li	a2,128
    80007a08:	f3040593          	addi	a1,s0,-208
    80007a0c:	00000513          	li	a0,0
    80007a10:	ffffc097          	auipc	ra,0xffffc
    80007a14:	5a4080e7          	jalr	1444(ra) # 80003fb4 <argstr>
    80007a18:	1c054063          	bltz	a0,80007bd8 <sys_unlink+0x1f0>
  begin_op();
    80007a1c:	ffffe097          	auipc	ra,0xffffe
    80007a20:	48c080e7          	jalr	1164(ra) # 80005ea8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80007a24:	fb040593          	addi	a1,s0,-80
    80007a28:	f3040513          	addi	a0,s0,-208
    80007a2c:	ffffe097          	auipc	ra,0xffffe
    80007a30:	198080e7          	jalr	408(ra) # 80005bc4 <nameiparent>
    80007a34:	00050493          	mv	s1,a0
    80007a38:	0e050c63          	beqz	a0,80007b30 <sys_unlink+0x148>
  ilock(dp);
    80007a3c:	ffffd097          	auipc	ra,0xffffd
    80007a40:	46c080e7          	jalr	1132(ra) # 80004ea8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80007a44:	00003597          	auipc	a1,0x3
    80007a48:	dec58593          	addi	a1,a1,-532 # 8000a830 <syscalls+0x2e0>
    80007a4c:	fb040513          	addi	a0,s0,-80
    80007a50:	ffffe097          	auipc	ra,0xffffe
    80007a54:	d1c080e7          	jalr	-740(ra) # 8000576c <namecmp>
    80007a58:	18050a63          	beqz	a0,80007bec <sys_unlink+0x204>
    80007a5c:	00003597          	auipc	a1,0x3
    80007a60:	ddc58593          	addi	a1,a1,-548 # 8000a838 <syscalls+0x2e8>
    80007a64:	fb040513          	addi	a0,s0,-80
    80007a68:	ffffe097          	auipc	ra,0xffffe
    80007a6c:	d04080e7          	jalr	-764(ra) # 8000576c <namecmp>
    80007a70:	16050e63          	beqz	a0,80007bec <sys_unlink+0x204>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80007a74:	f2c40613          	addi	a2,s0,-212
    80007a78:	fb040593          	addi	a1,s0,-80
    80007a7c:	00048513          	mv	a0,s1
    80007a80:	ffffe097          	auipc	ra,0xffffe
    80007a84:	d18080e7          	jalr	-744(ra) # 80005798 <dirlookup>
    80007a88:	00050913          	mv	s2,a0
    80007a8c:	16050063          	beqz	a0,80007bec <sys_unlink+0x204>
  ilock(ip);
    80007a90:	ffffd097          	auipc	ra,0xffffd
    80007a94:	418080e7          	jalr	1048(ra) # 80004ea8 <ilock>
  if(ip->nlink < 1)
    80007a98:	04a91783          	lh	a5,74(s2)
    80007a9c:	0af05263          	blez	a5,80007b40 <sys_unlink+0x158>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80007aa0:	04491703          	lh	a4,68(s2)
    80007aa4:	00100793          	li	a5,1
    80007aa8:	0af70463          	beq	a4,a5,80007b50 <sys_unlink+0x168>
  memset(&de, 0, sizeof(de));
    80007aac:	01000613          	li	a2,16
    80007ab0:	00000593          	li	a1,0
    80007ab4:	fc040513          	addi	a0,s0,-64
    80007ab8:	ffff9097          	auipc	ra,0xffff9
    80007abc:	738080e7          	jalr	1848(ra) # 800011f0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80007ac0:	01000713          	li	a4,16
    80007ac4:	f2c42683          	lw	a3,-212(s0)
    80007ac8:	fc040613          	addi	a2,s0,-64
    80007acc:	00000593          	li	a1,0
    80007ad0:	00048513          	mv	a0,s1
    80007ad4:	ffffe097          	auipc	ra,0xffffe
    80007ad8:	afc080e7          	jalr	-1284(ra) # 800055d0 <writei>
    80007adc:	01000793          	li	a5,16
    80007ae0:	0cf51663          	bne	a0,a5,80007bac <sys_unlink+0x1c4>
  if(ip->type == T_DIR){
    80007ae4:	04491703          	lh	a4,68(s2)
    80007ae8:	00100793          	li	a5,1
    80007aec:	0cf70863          	beq	a4,a5,80007bbc <sys_unlink+0x1d4>
  iunlockput(dp);
    80007af0:	00048513          	mv	a0,s1
    80007af4:	ffffd097          	auipc	ra,0xffffd
    80007af8:	6f0080e7          	jalr	1776(ra) # 800051e4 <iunlockput>
  ip->nlink--;
    80007afc:	04a95783          	lhu	a5,74(s2)
    80007b00:	fff7879b          	addiw	a5,a5,-1
    80007b04:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80007b08:	00090513          	mv	a0,s2
    80007b0c:	ffffd097          	auipc	ra,0xffffd
    80007b10:	280080e7          	jalr	640(ra) # 80004d8c <iupdate>
  iunlockput(ip);
    80007b14:	00090513          	mv	a0,s2
    80007b18:	ffffd097          	auipc	ra,0xffffd
    80007b1c:	6cc080e7          	jalr	1740(ra) # 800051e4 <iunlockput>
  end_op();
    80007b20:	ffffe097          	auipc	ra,0xffffe
    80007b24:	43c080e7          	jalr	1084(ra) # 80005f5c <end_op>
  return 0;
    80007b28:	00000513          	li	a0,0
    80007b2c:	0d80006f          	j	80007c04 <sys_unlink+0x21c>
    end_op();
    80007b30:	ffffe097          	auipc	ra,0xffffe
    80007b34:	42c080e7          	jalr	1068(ra) # 80005f5c <end_op>
    return -1;
    80007b38:	fff00513          	li	a0,-1
    80007b3c:	0c80006f          	j	80007c04 <sys_unlink+0x21c>
    panic("unlink: nlink < 1");
    80007b40:	00003517          	auipc	a0,0x3
    80007b44:	d0050513          	addi	a0,a0,-768 # 8000a840 <syscalls+0x2f0>
    80007b48:	ffff9097          	auipc	ra,0xffff9
    80007b4c:	f38080e7          	jalr	-200(ra) # 80000a80 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80007b50:	04c92703          	lw	a4,76(s2)
    80007b54:	02000793          	li	a5,32
    80007b58:	f4e7fae3          	bgeu	a5,a4,80007aac <sys_unlink+0xc4>
    80007b5c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80007b60:	01000713          	li	a4,16
    80007b64:	00098693          	mv	a3,s3
    80007b68:	f1840613          	addi	a2,s0,-232
    80007b6c:	00000593          	li	a1,0
    80007b70:	00090513          	mv	a0,s2
    80007b74:	ffffe097          	auipc	ra,0xffffe
    80007b78:	8ec080e7          	jalr	-1812(ra) # 80005460 <readi>
    80007b7c:	01000793          	li	a5,16
    80007b80:	00f51e63          	bne	a0,a5,80007b9c <sys_unlink+0x1b4>
    if(de.inum != 0)
    80007b84:	f1845783          	lhu	a5,-232(s0)
    80007b88:	04079c63          	bnez	a5,80007be0 <sys_unlink+0x1f8>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80007b8c:	0109899b          	addiw	s3,s3,16
    80007b90:	04c92783          	lw	a5,76(s2)
    80007b94:	fcf9e6e3          	bltu	s3,a5,80007b60 <sys_unlink+0x178>
    80007b98:	f15ff06f          	j	80007aac <sys_unlink+0xc4>
      panic("isdirempty: readi");
    80007b9c:	00003517          	auipc	a0,0x3
    80007ba0:	cbc50513          	addi	a0,a0,-836 # 8000a858 <syscalls+0x308>
    80007ba4:	ffff9097          	auipc	ra,0xffff9
    80007ba8:	edc080e7          	jalr	-292(ra) # 80000a80 <panic>
    panic("unlink: writei");
    80007bac:	00003517          	auipc	a0,0x3
    80007bb0:	cc450513          	addi	a0,a0,-828 # 8000a870 <syscalls+0x320>
    80007bb4:	ffff9097          	auipc	ra,0xffff9
    80007bb8:	ecc080e7          	jalr	-308(ra) # 80000a80 <panic>
    dp->nlink--;
    80007bbc:	04a4d783          	lhu	a5,74(s1)
    80007bc0:	fff7879b          	addiw	a5,a5,-1
    80007bc4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80007bc8:	00048513          	mv	a0,s1
    80007bcc:	ffffd097          	auipc	ra,0xffffd
    80007bd0:	1c0080e7          	jalr	448(ra) # 80004d8c <iupdate>
    80007bd4:	f1dff06f          	j	80007af0 <sys_unlink+0x108>
    return -1;
    80007bd8:	fff00513          	li	a0,-1
    80007bdc:	0280006f          	j	80007c04 <sys_unlink+0x21c>
    iunlockput(ip);
    80007be0:	00090513          	mv	a0,s2
    80007be4:	ffffd097          	auipc	ra,0xffffd
    80007be8:	600080e7          	jalr	1536(ra) # 800051e4 <iunlockput>
  iunlockput(dp);
    80007bec:	00048513          	mv	a0,s1
    80007bf0:	ffffd097          	auipc	ra,0xffffd
    80007bf4:	5f4080e7          	jalr	1524(ra) # 800051e4 <iunlockput>
  end_op();
    80007bf8:	ffffe097          	auipc	ra,0xffffe
    80007bfc:	364080e7          	jalr	868(ra) # 80005f5c <end_op>
  return -1;
    80007c00:	fff00513          	li	a0,-1
}
    80007c04:	0e813083          	ld	ra,232(sp)
    80007c08:	0e013403          	ld	s0,224(sp)
    80007c0c:	0d813483          	ld	s1,216(sp)
    80007c10:	0d013903          	ld	s2,208(sp)
    80007c14:	0c813983          	ld	s3,200(sp)
    80007c18:	0f010113          	addi	sp,sp,240
    80007c1c:	00008067          	ret

0000000080007c20 <sys_open>:

uint64
sys_open(void)
{
    80007c20:	f4010113          	addi	sp,sp,-192
    80007c24:	0a113c23          	sd	ra,184(sp)
    80007c28:	0a813823          	sd	s0,176(sp)
    80007c2c:	0a913423          	sd	s1,168(sp)
    80007c30:	0b213023          	sd	s2,160(sp)
    80007c34:	09313c23          	sd	s3,152(sp)
    80007c38:	0c010413          	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80007c3c:	f4c40593          	addi	a1,s0,-180
    80007c40:	00100513          	li	a0,1
    80007c44:	ffffc097          	auipc	ra,0xffffc
    80007c48:	300080e7          	jalr	768(ra) # 80003f44 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80007c4c:	08000613          	li	a2,128
    80007c50:	f5040593          	addi	a1,s0,-176
    80007c54:	00000513          	li	a0,0
    80007c58:	ffffc097          	auipc	ra,0xffffc
    80007c5c:	35c080e7          	jalr	860(ra) # 80003fb4 <argstr>
    80007c60:	00050793          	mv	a5,a0
    return -1;
    80007c64:	fff00513          	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80007c68:	0c07ca63          	bltz	a5,80007d3c <sys_open+0x11c>

  begin_op();
    80007c6c:	ffffe097          	auipc	ra,0xffffe
    80007c70:	23c080e7          	jalr	572(ra) # 80005ea8 <begin_op>

  if(omode & O_CREATE){
    80007c74:	f4c42783          	lw	a5,-180(s0)
    80007c78:	2007f793          	andi	a5,a5,512
    80007c7c:	0e078663          	beqz	a5,80007d68 <sys_open+0x148>
    ip = create(path, T_FILE, 0, 0);
    80007c80:	00000693          	li	a3,0
    80007c84:	00000613          	li	a2,0
    80007c88:	00200593          	li	a1,2
    80007c8c:	f5040513          	addi	a0,s0,-176
    80007c90:	fffff097          	auipc	ra,0xfffff
    80007c94:	77c080e7          	jalr	1916(ra) # 8000740c <create>
    80007c98:	00050493          	mv	s1,a0
    if(ip == 0){
    80007c9c:	0a050e63          	beqz	a0,80007d58 <sys_open+0x138>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80007ca0:	04449703          	lh	a4,68(s1)
    80007ca4:	00300793          	li	a5,3
    80007ca8:	00f71863          	bne	a4,a5,80007cb8 <sys_open+0x98>
    80007cac:	0464d703          	lhu	a4,70(s1)
    80007cb0:	00900793          	li	a5,9
    80007cb4:	10e7e863          	bltu	a5,a4,80007dc4 <sys_open+0x1a4>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80007cb8:	ffffe097          	auipc	ra,0xffffe
    80007cbc:	770080e7          	jalr	1904(ra) # 80006428 <filealloc>
    80007cc0:	00050993          	mv	s3,a0
    80007cc4:	14050463          	beqz	a0,80007e0c <sys_open+0x1ec>
    80007cc8:	fffff097          	auipc	ra,0xfffff
    80007ccc:	6d4080e7          	jalr	1748(ra) # 8000739c <fdalloc>
    80007cd0:	00050913          	mv	s2,a0
    80007cd4:	12054663          	bltz	a0,80007e00 <sys_open+0x1e0>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80007cd8:	04449703          	lh	a4,68(s1)
    80007cdc:	00300793          	li	a5,3
    80007ce0:	10f70063          	beq	a4,a5,80007de0 <sys_open+0x1c0>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80007ce4:	00200793          	li	a5,2
    80007ce8:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80007cec:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80007cf0:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80007cf4:	f4c42783          	lw	a5,-180(s0)
    80007cf8:	0017c713          	xori	a4,a5,1
    80007cfc:	00177713          	andi	a4,a4,1
    80007d00:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80007d04:	0037f713          	andi	a4,a5,3
    80007d08:	00e03733          	snez	a4,a4
    80007d0c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80007d10:	4007f793          	andi	a5,a5,1024
    80007d14:	00078863          	beqz	a5,80007d24 <sys_open+0x104>
    80007d18:	04449703          	lh	a4,68(s1)
    80007d1c:	00200793          	li	a5,2
    80007d20:	0cf70863          	beq	a4,a5,80007df0 <sys_open+0x1d0>
    itrunc(ip);
  }

  iunlock(ip);
    80007d24:	00048513          	mv	a0,s1
    80007d28:	ffffd097          	auipc	ra,0xffffd
    80007d2c:	284080e7          	jalr	644(ra) # 80004fac <iunlock>
  end_op();
    80007d30:	ffffe097          	auipc	ra,0xffffe
    80007d34:	22c080e7          	jalr	556(ra) # 80005f5c <end_op>

  return fd;
    80007d38:	00090513          	mv	a0,s2
}
    80007d3c:	0b813083          	ld	ra,184(sp)
    80007d40:	0b013403          	ld	s0,176(sp)
    80007d44:	0a813483          	ld	s1,168(sp)
    80007d48:	0a013903          	ld	s2,160(sp)
    80007d4c:	09813983          	ld	s3,152(sp)
    80007d50:	0c010113          	addi	sp,sp,192
    80007d54:	00008067          	ret
      end_op();
    80007d58:	ffffe097          	auipc	ra,0xffffe
    80007d5c:	204080e7          	jalr	516(ra) # 80005f5c <end_op>
      return -1;
    80007d60:	fff00513          	li	a0,-1
    80007d64:	fd9ff06f          	j	80007d3c <sys_open+0x11c>
    if((ip = namei(path)) == 0){
    80007d68:	f5040513          	addi	a0,s0,-176
    80007d6c:	ffffe097          	auipc	ra,0xffffe
    80007d70:	e28080e7          	jalr	-472(ra) # 80005b94 <namei>
    80007d74:	00050493          	mv	s1,a0
    80007d78:	02050e63          	beqz	a0,80007db4 <sys_open+0x194>
    ilock(ip);
    80007d7c:	ffffd097          	auipc	ra,0xffffd
    80007d80:	12c080e7          	jalr	300(ra) # 80004ea8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80007d84:	04449703          	lh	a4,68(s1)
    80007d88:	00100793          	li	a5,1
    80007d8c:	f0f71ae3          	bne	a4,a5,80007ca0 <sys_open+0x80>
    80007d90:	f4c42783          	lw	a5,-180(s0)
    80007d94:	f20782e3          	beqz	a5,80007cb8 <sys_open+0x98>
      iunlockput(ip);
    80007d98:	00048513          	mv	a0,s1
    80007d9c:	ffffd097          	auipc	ra,0xffffd
    80007da0:	448080e7          	jalr	1096(ra) # 800051e4 <iunlockput>
      end_op();
    80007da4:	ffffe097          	auipc	ra,0xffffe
    80007da8:	1b8080e7          	jalr	440(ra) # 80005f5c <end_op>
      return -1;
    80007dac:	fff00513          	li	a0,-1
    80007db0:	f8dff06f          	j	80007d3c <sys_open+0x11c>
      end_op();
    80007db4:	ffffe097          	auipc	ra,0xffffe
    80007db8:	1a8080e7          	jalr	424(ra) # 80005f5c <end_op>
      return -1;
    80007dbc:	fff00513          	li	a0,-1
    80007dc0:	f7dff06f          	j	80007d3c <sys_open+0x11c>
    iunlockput(ip);
    80007dc4:	00048513          	mv	a0,s1
    80007dc8:	ffffd097          	auipc	ra,0xffffd
    80007dcc:	41c080e7          	jalr	1052(ra) # 800051e4 <iunlockput>
    end_op();
    80007dd0:	ffffe097          	auipc	ra,0xffffe
    80007dd4:	18c080e7          	jalr	396(ra) # 80005f5c <end_op>
    return -1;
    80007dd8:	fff00513          	li	a0,-1
    80007ddc:	f61ff06f          	j	80007d3c <sys_open+0x11c>
    f->type = FD_DEVICE;
    80007de0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80007de4:	04649783          	lh	a5,70(s1)
    80007de8:	02f99223          	sh	a5,36(s3)
    80007dec:	f05ff06f          	j	80007cf0 <sys_open+0xd0>
    itrunc(ip);
    80007df0:	00048513          	mv	a0,s1
    80007df4:	ffffd097          	auipc	ra,0xffffd
    80007df8:	228080e7          	jalr	552(ra) # 8000501c <itrunc>
    80007dfc:	f29ff06f          	j	80007d24 <sys_open+0x104>
      fileclose(f);
    80007e00:	00098513          	mv	a0,s3
    80007e04:	ffffe097          	auipc	ra,0xffffe
    80007e08:	720080e7          	jalr	1824(ra) # 80006524 <fileclose>
    iunlockput(ip);
    80007e0c:	00048513          	mv	a0,s1
    80007e10:	ffffd097          	auipc	ra,0xffffd
    80007e14:	3d4080e7          	jalr	980(ra) # 800051e4 <iunlockput>
    end_op();
    80007e18:	ffffe097          	auipc	ra,0xffffe
    80007e1c:	144080e7          	jalr	324(ra) # 80005f5c <end_op>
    return -1;
    80007e20:	fff00513          	li	a0,-1
    80007e24:	f19ff06f          	j	80007d3c <sys_open+0x11c>

0000000080007e28 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80007e28:	f7010113          	addi	sp,sp,-144
    80007e2c:	08113423          	sd	ra,136(sp)
    80007e30:	08813023          	sd	s0,128(sp)
    80007e34:	09010413          	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80007e38:	ffffe097          	auipc	ra,0xffffe
    80007e3c:	070080e7          	jalr	112(ra) # 80005ea8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80007e40:	08000613          	li	a2,128
    80007e44:	f7040593          	addi	a1,s0,-144
    80007e48:	00000513          	li	a0,0
    80007e4c:	ffffc097          	auipc	ra,0xffffc
    80007e50:	168080e7          	jalr	360(ra) # 80003fb4 <argstr>
    80007e54:	04054263          	bltz	a0,80007e98 <sys_mkdir+0x70>
    80007e58:	00000693          	li	a3,0
    80007e5c:	00000613          	li	a2,0
    80007e60:	00100593          	li	a1,1
    80007e64:	f7040513          	addi	a0,s0,-144
    80007e68:	fffff097          	auipc	ra,0xfffff
    80007e6c:	5a4080e7          	jalr	1444(ra) # 8000740c <create>
    80007e70:	02050463          	beqz	a0,80007e98 <sys_mkdir+0x70>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80007e74:	ffffd097          	auipc	ra,0xffffd
    80007e78:	370080e7          	jalr	880(ra) # 800051e4 <iunlockput>
  end_op();
    80007e7c:	ffffe097          	auipc	ra,0xffffe
    80007e80:	0e0080e7          	jalr	224(ra) # 80005f5c <end_op>
  return 0;
    80007e84:	00000513          	li	a0,0
}
    80007e88:	08813083          	ld	ra,136(sp)
    80007e8c:	08013403          	ld	s0,128(sp)
    80007e90:	09010113          	addi	sp,sp,144
    80007e94:	00008067          	ret
    end_op();
    80007e98:	ffffe097          	auipc	ra,0xffffe
    80007e9c:	0c4080e7          	jalr	196(ra) # 80005f5c <end_op>
    return -1;
    80007ea0:	fff00513          	li	a0,-1
    80007ea4:	fe5ff06f          	j	80007e88 <sys_mkdir+0x60>

0000000080007ea8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80007ea8:	f6010113          	addi	sp,sp,-160
    80007eac:	08113c23          	sd	ra,152(sp)
    80007eb0:	08813823          	sd	s0,144(sp)
    80007eb4:	0a010413          	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80007eb8:	ffffe097          	auipc	ra,0xffffe
    80007ebc:	ff0080e7          	jalr	-16(ra) # 80005ea8 <begin_op>
  argint(1, &major);
    80007ec0:	f6c40593          	addi	a1,s0,-148
    80007ec4:	00100513          	li	a0,1
    80007ec8:	ffffc097          	auipc	ra,0xffffc
    80007ecc:	07c080e7          	jalr	124(ra) # 80003f44 <argint>
  argint(2, &minor);
    80007ed0:	f6840593          	addi	a1,s0,-152
    80007ed4:	00200513          	li	a0,2
    80007ed8:	ffffc097          	auipc	ra,0xffffc
    80007edc:	06c080e7          	jalr	108(ra) # 80003f44 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80007ee0:	08000613          	li	a2,128
    80007ee4:	f7040593          	addi	a1,s0,-144
    80007ee8:	00000513          	li	a0,0
    80007eec:	ffffc097          	auipc	ra,0xffffc
    80007ef0:	0c8080e7          	jalr	200(ra) # 80003fb4 <argstr>
    80007ef4:	04054263          	bltz	a0,80007f38 <sys_mknod+0x90>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80007ef8:	f6841683          	lh	a3,-152(s0)
    80007efc:	f6c41603          	lh	a2,-148(s0)
    80007f00:	00300593          	li	a1,3
    80007f04:	f7040513          	addi	a0,s0,-144
    80007f08:	fffff097          	auipc	ra,0xfffff
    80007f0c:	504080e7          	jalr	1284(ra) # 8000740c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80007f10:	02050463          	beqz	a0,80007f38 <sys_mknod+0x90>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80007f14:	ffffd097          	auipc	ra,0xffffd
    80007f18:	2d0080e7          	jalr	720(ra) # 800051e4 <iunlockput>
  end_op();
    80007f1c:	ffffe097          	auipc	ra,0xffffe
    80007f20:	040080e7          	jalr	64(ra) # 80005f5c <end_op>
  return 0;
    80007f24:	00000513          	li	a0,0
}
    80007f28:	09813083          	ld	ra,152(sp)
    80007f2c:	09013403          	ld	s0,144(sp)
    80007f30:	0a010113          	addi	sp,sp,160
    80007f34:	00008067          	ret
    end_op();
    80007f38:	ffffe097          	auipc	ra,0xffffe
    80007f3c:	024080e7          	jalr	36(ra) # 80005f5c <end_op>
    return -1;
    80007f40:	fff00513          	li	a0,-1
    80007f44:	fe5ff06f          	j	80007f28 <sys_mknod+0x80>

0000000080007f48 <sys_chdir>:

uint64
sys_chdir(void)
{
    80007f48:	f6010113          	addi	sp,sp,-160
    80007f4c:	08113c23          	sd	ra,152(sp)
    80007f50:	08813823          	sd	s0,144(sp)
    80007f54:	08913423          	sd	s1,136(sp)
    80007f58:	09213023          	sd	s2,128(sp)
    80007f5c:	0a010413          	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80007f60:	ffffa097          	auipc	ra,0xffffa
    80007f64:	798080e7          	jalr	1944(ra) # 800026f8 <myproc>
    80007f68:	00050913          	mv	s2,a0
  
  begin_op();
    80007f6c:	ffffe097          	auipc	ra,0xffffe
    80007f70:	f3c080e7          	jalr	-196(ra) # 80005ea8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80007f74:	08000613          	li	a2,128
    80007f78:	f6040593          	addi	a1,s0,-160
    80007f7c:	00000513          	li	a0,0
    80007f80:	ffffc097          	auipc	ra,0xffffc
    80007f84:	034080e7          	jalr	52(ra) # 80003fb4 <argstr>
    80007f88:	06054663          	bltz	a0,80007ff4 <sys_chdir+0xac>
    80007f8c:	f6040513          	addi	a0,s0,-160
    80007f90:	ffffe097          	auipc	ra,0xffffe
    80007f94:	c04080e7          	jalr	-1020(ra) # 80005b94 <namei>
    80007f98:	00050493          	mv	s1,a0
    80007f9c:	04050c63          	beqz	a0,80007ff4 <sys_chdir+0xac>
    end_op();
    return -1;
  }
  ilock(ip);
    80007fa0:	ffffd097          	auipc	ra,0xffffd
    80007fa4:	f08080e7          	jalr	-248(ra) # 80004ea8 <ilock>
  if(ip->type != T_DIR){
    80007fa8:	04449703          	lh	a4,68(s1)
    80007fac:	00100793          	li	a5,1
    80007fb0:	04f71a63          	bne	a4,a5,80008004 <sys_chdir+0xbc>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80007fb4:	00048513          	mv	a0,s1
    80007fb8:	ffffd097          	auipc	ra,0xffffd
    80007fbc:	ff4080e7          	jalr	-12(ra) # 80004fac <iunlock>
  iput(p->cwd);
    80007fc0:	15093503          	ld	a0,336(s2)
    80007fc4:	ffffd097          	auipc	ra,0xffffd
    80007fc8:	144080e7          	jalr	324(ra) # 80005108 <iput>
  end_op();
    80007fcc:	ffffe097          	auipc	ra,0xffffe
    80007fd0:	f90080e7          	jalr	-112(ra) # 80005f5c <end_op>
  p->cwd = ip;
    80007fd4:	14993823          	sd	s1,336(s2)
  return 0;
    80007fd8:	00000513          	li	a0,0
}
    80007fdc:	09813083          	ld	ra,152(sp)
    80007fe0:	09013403          	ld	s0,144(sp)
    80007fe4:	08813483          	ld	s1,136(sp)
    80007fe8:	08013903          	ld	s2,128(sp)
    80007fec:	0a010113          	addi	sp,sp,160
    80007ff0:	00008067          	ret
    end_op();
    80007ff4:	ffffe097          	auipc	ra,0xffffe
    80007ff8:	f68080e7          	jalr	-152(ra) # 80005f5c <end_op>
    return -1;
    80007ffc:	fff00513          	li	a0,-1
    80008000:	fddff06f          	j	80007fdc <sys_chdir+0x94>
    iunlockput(ip);
    80008004:	00048513          	mv	a0,s1
    80008008:	ffffd097          	auipc	ra,0xffffd
    8000800c:	1dc080e7          	jalr	476(ra) # 800051e4 <iunlockput>
    end_op();
    80008010:	ffffe097          	auipc	ra,0xffffe
    80008014:	f4c080e7          	jalr	-180(ra) # 80005f5c <end_op>
    return -1;
    80008018:	fff00513          	li	a0,-1
    8000801c:	fc1ff06f          	j	80007fdc <sys_chdir+0x94>

0000000080008020 <sys_exec>:

uint64
sys_exec(void)
{
    80008020:	e3010113          	addi	sp,sp,-464
    80008024:	1c113423          	sd	ra,456(sp)
    80008028:	1c813023          	sd	s0,448(sp)
    8000802c:	1a913c23          	sd	s1,440(sp)
    80008030:	1b213823          	sd	s2,432(sp)
    80008034:	1b313423          	sd	s3,424(sp)
    80008038:	1b413023          	sd	s4,416(sp)
    8000803c:	19513c23          	sd	s5,408(sp)
    80008040:	1d010413          	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80008044:	e3840593          	addi	a1,s0,-456
    80008048:	00100513          	li	a0,1
    8000804c:	ffffc097          	auipc	ra,0xffffc
    80008050:	f30080e7          	jalr	-208(ra) # 80003f7c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80008054:	08000613          	li	a2,128
    80008058:	f4040593          	addi	a1,s0,-192
    8000805c:	00000513          	li	a0,0
    80008060:	ffffc097          	auipc	ra,0xffffc
    80008064:	f54080e7          	jalr	-172(ra) # 80003fb4 <argstr>
    80008068:	00050793          	mv	a5,a0
    return -1;
    8000806c:	fff00513          	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80008070:	0e07ca63          	bltz	a5,80008164 <sys_exec+0x144>
  }
  memset(argv, 0, sizeof(argv));
    80008074:	10000613          	li	a2,256
    80008078:	00000593          	li	a1,0
    8000807c:	e4040513          	addi	a0,s0,-448
    80008080:	ffff9097          	auipc	ra,0xffff9
    80008084:	170080e7          	jalr	368(ra) # 800011f0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80008088:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000808c:	00048993          	mv	s3,s1
    80008090:	00000913          	li	s2,0
    if(i >= NELEM(argv)){
    80008094:	02000a13          	li	s4,32
    80008098:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000809c:	00391513          	slli	a0,s2,0x3
    800080a0:	e3040593          	addi	a1,s0,-464
    800080a4:	e3843783          	ld	a5,-456(s0)
    800080a8:	00f50533          	add	a0,a0,a5
    800080ac:	ffffc097          	auipc	ra,0xffffc
    800080b0:	d9c080e7          	jalr	-612(ra) # 80003e48 <fetchaddr>
    800080b4:	04054063          	bltz	a0,800080f4 <sys_exec+0xd4>
      goto bad;
    }
    if(uarg == 0){
    800080b8:	e3043783          	ld	a5,-464(s0)
    800080bc:	04078e63          	beqz	a5,80008118 <sys_exec+0xf8>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800080c0:	ffff9097          	auipc	ra,0xffff9
    800080c4:	e6c080e7          	jalr	-404(ra) # 80000f2c <kalloc>
    800080c8:	00050593          	mv	a1,a0
    800080cc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800080d0:	02050263          	beqz	a0,800080f4 <sys_exec+0xd4>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800080d4:	00001637          	lui	a2,0x1
    800080d8:	e3043503          	ld	a0,-464(s0)
    800080dc:	ffffc097          	auipc	ra,0xffffc
    800080e0:	dec080e7          	jalr	-532(ra) # 80003ec8 <fetchstr>
    800080e4:	00054863          	bltz	a0,800080f4 <sys_exec+0xd4>
    if(i >= NELEM(argv)){
    800080e8:	00190913          	addi	s2,s2,1
    800080ec:	00898993          	addi	s3,s3,8
    800080f0:	fb4914e3          	bne	s2,s4,80008098 <sys_exec+0x78>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800080f4:	f4040913          	addi	s2,s0,-192
    800080f8:	0004b503          	ld	a0,0(s1)
    800080fc:	06050263          	beqz	a0,80008160 <sys_exec+0x140>
    kfree(argv[i]);
    80008100:	ffff9097          	auipc	ra,0xffff9
    80008104:	cc0080e7          	jalr	-832(ra) # 80000dc0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80008108:	00848493          	addi	s1,s1,8
    8000810c:	ff2496e3          	bne	s1,s2,800080f8 <sys_exec+0xd8>
  return -1;
    80008110:	fff00513          	li	a0,-1
    80008114:	0500006f          	j	80008164 <sys_exec+0x144>
      argv[i] = 0;
    80008118:	003a9a93          	slli	s5,s5,0x3
    8000811c:	fc0a8793          	addi	a5,s5,-64
    80008120:	00878ab3          	add	s5,a5,s0
    80008124:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80008128:	e4040593          	addi	a1,s0,-448
    8000812c:	f4040513          	addi	a0,s0,-192
    80008130:	fffff097          	auipc	ra,0xfffff
    80008134:	d10080e7          	jalr	-752(ra) # 80006e40 <kexec>
    80008138:	00050913          	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000813c:	f4040993          	addi	s3,s0,-192
    80008140:	0004b503          	ld	a0,0(s1)
    80008144:	00050a63          	beqz	a0,80008158 <sys_exec+0x138>
    kfree(argv[i]);
    80008148:	ffff9097          	auipc	ra,0xffff9
    8000814c:	c78080e7          	jalr	-904(ra) # 80000dc0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80008150:	00848493          	addi	s1,s1,8
    80008154:	ff3496e3          	bne	s1,s3,80008140 <sys_exec+0x120>
  return ret;
    80008158:	00090513          	mv	a0,s2
    8000815c:	0080006f          	j	80008164 <sys_exec+0x144>
  return -1;
    80008160:	fff00513          	li	a0,-1
}
    80008164:	1c813083          	ld	ra,456(sp)
    80008168:	1c013403          	ld	s0,448(sp)
    8000816c:	1b813483          	ld	s1,440(sp)
    80008170:	1b013903          	ld	s2,432(sp)
    80008174:	1a813983          	ld	s3,424(sp)
    80008178:	1a013a03          	ld	s4,416(sp)
    8000817c:	19813a83          	ld	s5,408(sp)
    80008180:	1d010113          	addi	sp,sp,464
    80008184:	00008067          	ret

0000000080008188 <sys_pipe>:

uint64
sys_pipe(void)
{
    80008188:	fc010113          	addi	sp,sp,-64
    8000818c:	02113c23          	sd	ra,56(sp)
    80008190:	02813823          	sd	s0,48(sp)
    80008194:	02913423          	sd	s1,40(sp)
    80008198:	04010413          	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000819c:	ffffa097          	auipc	ra,0xffffa
    800081a0:	55c080e7          	jalr	1372(ra) # 800026f8 <myproc>
    800081a4:	00050493          	mv	s1,a0

  argaddr(0, &fdarray);
    800081a8:	fd840593          	addi	a1,s0,-40
    800081ac:	00000513          	li	a0,0
    800081b0:	ffffc097          	auipc	ra,0xffffc
    800081b4:	dcc080e7          	jalr	-564(ra) # 80003f7c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800081b8:	fc840593          	addi	a1,s0,-56
    800081bc:	fd040513          	addi	a0,s0,-48
    800081c0:	ffffe097          	auipc	ra,0xffffe
    800081c4:	7f0080e7          	jalr	2032(ra) # 800069b0 <pipealloc>
    return -1;
    800081c8:	fff00793          	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800081cc:	0e054663          	bltz	a0,800082b8 <sys_pipe+0x130>
  fd0 = -1;
    800081d0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800081d4:	fd043503          	ld	a0,-48(s0)
    800081d8:	fffff097          	auipc	ra,0xfffff
    800081dc:	1c4080e7          	jalr	452(ra) # 8000739c <fdalloc>
    800081e0:	fca42223          	sw	a0,-60(s0)
    800081e4:	0a054c63          	bltz	a0,8000829c <sys_pipe+0x114>
    800081e8:	fc843503          	ld	a0,-56(s0)
    800081ec:	fffff097          	auipc	ra,0xfffff
    800081f0:	1b0080e7          	jalr	432(ra) # 8000739c <fdalloc>
    800081f4:	fca42023          	sw	a0,-64(s0)
    800081f8:	08054663          	bltz	a0,80008284 <sys_pipe+0xfc>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800081fc:	00400693          	li	a3,4
    80008200:	fc440613          	addi	a2,s0,-60
    80008204:	fd843583          	ld	a1,-40(s0)
    80008208:	0504b503          	ld	a0,80(s1)
    8000820c:	ffffa097          	auipc	ra,0xffffa
    80008210:	078080e7          	jalr	120(ra) # 80002284 <copyout>
    80008214:	02054463          	bltz	a0,8000823c <sys_pipe+0xb4>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80008218:	00400693          	li	a3,4
    8000821c:	fc040613          	addi	a2,s0,-64
    80008220:	fd843583          	ld	a1,-40(s0)
    80008224:	00458593          	addi	a1,a1,4
    80008228:	0504b503          	ld	a0,80(s1)
    8000822c:	ffffa097          	auipc	ra,0xffffa
    80008230:	058080e7          	jalr	88(ra) # 80002284 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80008234:	00000793          	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80008238:	08055063          	bgez	a0,800082b8 <sys_pipe+0x130>
    p->ofile[fd0] = 0;
    8000823c:	fc442783          	lw	a5,-60(s0)
    80008240:	01a78793          	addi	a5,a5,26
    80008244:	00379793          	slli	a5,a5,0x3
    80008248:	00f487b3          	add	a5,s1,a5
    8000824c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80008250:	fc042783          	lw	a5,-64(s0)
    80008254:	01a78793          	addi	a5,a5,26
    80008258:	00379793          	slli	a5,a5,0x3
    8000825c:	00f484b3          	add	s1,s1,a5
    80008260:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80008264:	fd043503          	ld	a0,-48(s0)
    80008268:	ffffe097          	auipc	ra,0xffffe
    8000826c:	2bc080e7          	jalr	700(ra) # 80006524 <fileclose>
    fileclose(wf);
    80008270:	fc843503          	ld	a0,-56(s0)
    80008274:	ffffe097          	auipc	ra,0xffffe
    80008278:	2b0080e7          	jalr	688(ra) # 80006524 <fileclose>
    return -1;
    8000827c:	fff00793          	li	a5,-1
    80008280:	0380006f          	j	800082b8 <sys_pipe+0x130>
    if(fd0 >= 0)
    80008284:	fc442783          	lw	a5,-60(s0)
    80008288:	0007ca63          	bltz	a5,8000829c <sys_pipe+0x114>
      p->ofile[fd0] = 0;
    8000828c:	01a78793          	addi	a5,a5,26
    80008290:	00379793          	slli	a5,a5,0x3
    80008294:	00f487b3          	add	a5,s1,a5
    80008298:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000829c:	fd043503          	ld	a0,-48(s0)
    800082a0:	ffffe097          	auipc	ra,0xffffe
    800082a4:	284080e7          	jalr	644(ra) # 80006524 <fileclose>
    fileclose(wf);
    800082a8:	fc843503          	ld	a0,-56(s0)
    800082ac:	ffffe097          	auipc	ra,0xffffe
    800082b0:	278080e7          	jalr	632(ra) # 80006524 <fileclose>
    return -1;
    800082b4:	fff00793          	li	a5,-1
}
    800082b8:	00078513          	mv	a0,a5
    800082bc:	03813083          	ld	ra,56(sp)
    800082c0:	03013403          	ld	s0,48(sp)
    800082c4:	02813483          	ld	s1,40(sp)
    800082c8:	04010113          	addi	sp,sp,64
    800082cc:	00008067          	ret

00000000800082d0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800082d0:	f0010113          	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800082d4:	00113023          	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800082d8:	00313823          	sd	gp,16(sp)
        sd tp, 24(sp)
    800082dc:	00413c23          	sd	tp,24(sp)
        sd t0, 32(sp)
    800082e0:	02513023          	sd	t0,32(sp)
        sd t1, 40(sp)
    800082e4:	02613423          	sd	t1,40(sp)
        sd t2, 48(sp)
    800082e8:	02713823          	sd	t2,48(sp)
        sd a0, 72(sp)
    800082ec:	04a13423          	sd	a0,72(sp)
        sd a1, 80(sp)
    800082f0:	04b13823          	sd	a1,80(sp)
        sd a2, 88(sp)
    800082f4:	04c13c23          	sd	a2,88(sp)
        sd a3, 96(sp)
    800082f8:	06d13023          	sd	a3,96(sp)
        sd a4, 104(sp)
    800082fc:	06e13423          	sd	a4,104(sp)
        sd a5, 112(sp)
    80008300:	06f13823          	sd	a5,112(sp)
        sd a6, 120(sp)
    80008304:	07013c23          	sd	a6,120(sp)
        sd a7, 128(sp)
    80008308:	09113023          	sd	a7,128(sp)
        sd t3, 216(sp)
    8000830c:	0dc13c23          	sd	t3,216(sp)
        sd t4, 224(sp)
    80008310:	0fd13023          	sd	t4,224(sp)
        sd t5, 232(sp)
    80008314:	0fe13423          	sd	t5,232(sp)
        sd t6, 240(sp)
    80008318:	0ff13823          	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    8000831c:	9a9fb0ef          	jal	ra,80003cc4 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80008320:	00013083          	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80008324:	01013183          	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80008328:	02013283          	ld	t0,32(sp)
        ld t1, 40(sp)
    8000832c:	02813303          	ld	t1,40(sp)
        ld t2, 48(sp)
    80008330:	03013383          	ld	t2,48(sp)
        ld a0, 72(sp)
    80008334:	04813503          	ld	a0,72(sp)
        ld a1, 80(sp)
    80008338:	05013583          	ld	a1,80(sp)
        ld a2, 88(sp)
    8000833c:	05813603          	ld	a2,88(sp)
        ld a3, 96(sp)
    80008340:	06013683          	ld	a3,96(sp)
        ld a4, 104(sp)
    80008344:	06813703          	ld	a4,104(sp)
        ld a5, 112(sp)
    80008348:	07013783          	ld	a5,112(sp)
        ld a6, 120(sp)
    8000834c:	07813803          	ld	a6,120(sp)
        ld a7, 128(sp)
    80008350:	08013883          	ld	a7,128(sp)
        ld t3, 216(sp)
    80008354:	0d813e03          	ld	t3,216(sp)
        ld t4, 224(sp)
    80008358:	0e013e83          	ld	t4,224(sp)
        ld t5, 232(sp)
    8000835c:	0e813f03          	ld	t5,232(sp)
        ld t6, 240(sp)
    80008360:	0f013f83          	ld	t6,240(sp)

        addi sp, sp, 256
    80008364:	10010113          	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80008368:	10200073          	sret
    8000836c:	0000                	.2byte	0x0
	...

0000000080008370 <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80008370:	ff010113          	addi	sp,sp,-16
    80008374:	00813423          	sd	s0,8(sp)
    80008378:	01010413          	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    8000837c:	0c0007b7          	lui	a5,0xc000
    80008380:	00100713          	li	a4,1
    80008384:	02e7a423          	sw	a4,40(a5) # c000028 <_entry-0x73ffffd8>
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80008388:	00e7a223          	sw	a4,4(a5)
}
    8000838c:	00813403          	ld	s0,8(sp)
    80008390:	01010113          	addi	sp,sp,16
    80008394:	00008067          	ret

0000000080008398 <plicinithart>:

void
plicinithart(void)
{
    80008398:	ff010113          	addi	sp,sp,-16
    8000839c:	00113423          	sd	ra,8(sp)
    800083a0:	00813023          	sd	s0,0(sp)
    800083a4:	01010413          	addi	s0,sp,16
  int hart = cpuid();
    800083a8:	ffffa097          	auipc	ra,0xffffa
    800083ac:	300080e7          	jalr	768(ra) # 800026a8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800083b0:	0085171b          	slliw	a4,a0,0x8
    800083b4:	0c0027b7          	lui	a5,0xc002
    800083b8:	00e787b3          	add	a5,a5,a4
    800083bc:	40200713          	li	a4,1026
    800083c0:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800083c4:	00d5151b          	slliw	a0,a0,0xd
    800083c8:	0c2017b7          	lui	a5,0xc201
    800083cc:	00a787b3          	add	a5,a5,a0
    800083d0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800083d4:	00813083          	ld	ra,8(sp)
    800083d8:	00013403          	ld	s0,0(sp)
    800083dc:	01010113          	addi	sp,sp,16
    800083e0:	00008067          	ret

00000000800083e4 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800083e4:	ff010113          	addi	sp,sp,-16
    800083e8:	00113423          	sd	ra,8(sp)
    800083ec:	00813023          	sd	s0,0(sp)
    800083f0:	01010413          	addi	s0,sp,16
  int hart = cpuid();
    800083f4:	ffffa097          	auipc	ra,0xffffa
    800083f8:	2b4080e7          	jalr	692(ra) # 800026a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800083fc:	00d5151b          	slliw	a0,a0,0xd
    80008400:	0c2017b7          	lui	a5,0xc201
    80008404:	00a787b3          	add	a5,a5,a0
  return irq;
}
    80008408:	0047a503          	lw	a0,4(a5) # c201004 <_entry-0x73dfeffc>
    8000840c:	00813083          	ld	ra,8(sp)
    80008410:	00013403          	ld	s0,0(sp)
    80008414:	01010113          	addi	sp,sp,16
    80008418:	00008067          	ret

000000008000841c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000841c:	fe010113          	addi	sp,sp,-32
    80008420:	00113c23          	sd	ra,24(sp)
    80008424:	00813823          	sd	s0,16(sp)
    80008428:	00913423          	sd	s1,8(sp)
    8000842c:	02010413          	addi	s0,sp,32
    80008430:	00050493          	mv	s1,a0
  int hart = cpuid();
    80008434:	ffffa097          	auipc	ra,0xffffa
    80008438:	274080e7          	jalr	628(ra) # 800026a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000843c:	00d5151b          	slliw	a0,a0,0xd
    80008440:	0c2017b7          	lui	a5,0xc201
    80008444:	00a787b3          	add	a5,a5,a0
    80008448:	0097a223          	sw	s1,4(a5) # c201004 <_entry-0x73dfeffc>
}
    8000844c:	01813083          	ld	ra,24(sp)
    80008450:	01013403          	ld	s0,16(sp)
    80008454:	00813483          	ld	s1,8(sp)
    80008458:	02010113          	addi	sp,sp,32
    8000845c:	00008067          	ret

0000000080008460 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80008460:	ff010113          	addi	sp,sp,-16
    80008464:	00113423          	sd	ra,8(sp)
    80008468:	00813023          	sd	s0,0(sp)
    8000846c:	01010413          	addi	s0,sp,16
  if(i >= NUM)
    80008470:	00700793          	li	a5,7
    80008474:	06a7c863          	blt	a5,a0,800084e4 <free_desc+0x84>
    panic("free_desc 1");
  if(disk.free[i])
    80008478:	0001b797          	auipc	a5,0x1b
    8000847c:	71078793          	addi	a5,a5,1808 # 80023b88 <disk>
    80008480:	00a787b3          	add	a5,a5,a0
    80008484:	0187c783          	lbu	a5,24(a5)
    80008488:	06079663          	bnez	a5,800084f4 <free_desc+0x94>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000848c:	00451693          	slli	a3,a0,0x4
    80008490:	0001b797          	auipc	a5,0x1b
    80008494:	6f878793          	addi	a5,a5,1784 # 80023b88 <disk>
    80008498:	0007b703          	ld	a4,0(a5)
    8000849c:	00d70733          	add	a4,a4,a3
    800084a0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800084a4:	0007b703          	ld	a4,0(a5)
    800084a8:	00d70733          	add	a4,a4,a3
    800084ac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800084b0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800084b4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800084b8:	00a787b3          	add	a5,a5,a0
    800084bc:	00100713          	li	a4,1
    800084c0:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800084c4:	0001b517          	auipc	a0,0x1b
    800084c8:	6dc50513          	addi	a0,a0,1756 # 80023ba0 <disk+0x18>
    800084cc:	ffffb097          	auipc	ra,0xffffb
    800084d0:	c74080e7          	jalr	-908(ra) # 80003140 <wakeup>
}
    800084d4:	00813083          	ld	ra,8(sp)
    800084d8:	00013403          	ld	s0,0(sp)
    800084dc:	01010113          	addi	sp,sp,16
    800084e0:	00008067          	ret
    panic("free_desc 1");
    800084e4:	00002517          	auipc	a0,0x2
    800084e8:	39c50513          	addi	a0,a0,924 # 8000a880 <syscalls+0x330>
    800084ec:	ffff8097          	auipc	ra,0xffff8
    800084f0:	594080e7          	jalr	1428(ra) # 80000a80 <panic>
    panic("free_desc 2");
    800084f4:	00002517          	auipc	a0,0x2
    800084f8:	39c50513          	addi	a0,a0,924 # 8000a890 <syscalls+0x340>
    800084fc:	ffff8097          	auipc	ra,0xffff8
    80008500:	584080e7          	jalr	1412(ra) # 80000a80 <panic>

0000000080008504 <virtio_disk_init>:
{
    80008504:	fe010113          	addi	sp,sp,-32
    80008508:	00113c23          	sd	ra,24(sp)
    8000850c:	00813823          	sd	s0,16(sp)
    80008510:	00913423          	sd	s1,8(sp)
    80008514:	01213023          	sd	s2,0(sp)
    80008518:	02010413          	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000851c:	00002597          	auipc	a1,0x2
    80008520:	38458593          	addi	a1,a1,900 # 8000a8a0 <syscalls+0x350>
    80008524:	0001b517          	auipc	a0,0x1b
    80008528:	78c50513          	addi	a0,a0,1932 # 80023cb0 <disk+0x128>
    8000852c:	ffff9097          	auipc	ra,0xffff9
    80008530:	a88080e7          	jalr	-1400(ra) # 80000fb4 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80008534:	100017b7          	lui	a5,0x10001
    80008538:	0007a703          	lw	a4,0(a5) # 10001000 <_entry-0x6ffff000>
    8000853c:	0007071b          	sext.w	a4,a4
    80008540:	747277b7          	lui	a5,0x74727
    80008544:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80008548:	1cf71263          	bne	a4,a5,8000870c <virtio_disk_init+0x208>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000854c:	100017b7          	lui	a5,0x10001
    80008550:	0047a783          	lw	a5,4(a5) # 10001004 <_entry-0x6fffeffc>
    80008554:	0007879b          	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80008558:	00200713          	li	a4,2
    8000855c:	1ae79863          	bne	a5,a4,8000870c <virtio_disk_init+0x208>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80008560:	100017b7          	lui	a5,0x10001
    80008564:	0087a783          	lw	a5,8(a5) # 10001008 <_entry-0x6fffeff8>
    80008568:	0007879b          	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000856c:	1ae79063          	bne	a5,a4,8000870c <virtio_disk_init+0x208>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80008570:	100017b7          	lui	a5,0x10001
    80008574:	00c7a703          	lw	a4,12(a5) # 1000100c <_entry-0x6fffeff4>
    80008578:	0007071b          	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000857c:	554d47b7          	lui	a5,0x554d4
    80008580:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80008584:	18f71463          	bne	a4,a5,8000870c <virtio_disk_init+0x208>
  *R(VIRTIO_MMIO_STATUS) = status;
    80008588:	100017b7          	lui	a5,0x10001
    8000858c:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80008590:	00100713          	li	a4,1
    80008594:	06e7a823          	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80008598:	00300713          	li	a4,3
    8000859c:	06e7a823          	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800085a0:	0107a703          	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800085a4:	c7ffe6b7          	lui	a3,0xc7ffe
    800085a8:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdaa97>
    800085ac:	00d77733          	and	a4,a4,a3
    800085b0:	02e7a023          	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800085b4:	00b00713          	li	a4,11
    800085b8:	06e7a823          	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800085bc:	0707a783          	lw	a5,112(a5)
    800085c0:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800085c4:	0087f793          	andi	a5,a5,8
    800085c8:	14078a63          	beqz	a5,8000871c <virtio_disk_init+0x218>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800085cc:	100017b7          	lui	a5,0x10001
    800085d0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800085d4:	0447a783          	lw	a5,68(a5)
    800085d8:	0007879b          	sext.w	a5,a5
    800085dc:	14079863          	bnez	a5,8000872c <virtio_disk_init+0x228>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800085e0:	100017b7          	lui	a5,0x10001
    800085e4:	0347a783          	lw	a5,52(a5) # 10001034 <_entry-0x6fffefcc>
    800085e8:	0007879b          	sext.w	a5,a5
  if(max == 0)
    800085ec:	14078863          	beqz	a5,8000873c <virtio_disk_init+0x238>
  if(max < NUM)
    800085f0:	00700713          	li	a4,7
    800085f4:	14f77c63          	bgeu	a4,a5,8000874c <virtio_disk_init+0x248>
  disk.desc = kalloc();
    800085f8:	ffff9097          	auipc	ra,0xffff9
    800085fc:	934080e7          	jalr	-1740(ra) # 80000f2c <kalloc>
    80008600:	0001b497          	auipc	s1,0x1b
    80008604:	58848493          	addi	s1,s1,1416 # 80023b88 <disk>
    80008608:	00a4b023          	sd	a0,0(s1)
  disk.avail = kalloc();
    8000860c:	ffff9097          	auipc	ra,0xffff9
    80008610:	920080e7          	jalr	-1760(ra) # 80000f2c <kalloc>
    80008614:	00a4b423          	sd	a0,8(s1)
  disk.used = kalloc();
    80008618:	ffff9097          	auipc	ra,0xffff9
    8000861c:	914080e7          	jalr	-1772(ra) # 80000f2c <kalloc>
    80008620:	00050793          	mv	a5,a0
    80008624:	00a4b823          	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80008628:	0004b503          	ld	a0,0(s1)
    8000862c:	12050863          	beqz	a0,8000875c <virtio_disk_init+0x258>
    80008630:	0001b717          	auipc	a4,0x1b
    80008634:	56073703          	ld	a4,1376(a4) # 80023b90 <disk+0x8>
    80008638:	12070263          	beqz	a4,8000875c <virtio_disk_init+0x258>
    8000863c:	12078063          	beqz	a5,8000875c <virtio_disk_init+0x258>
  memset(disk.desc, 0, PGSIZE);
    80008640:	00001637          	lui	a2,0x1
    80008644:	00000593          	li	a1,0
    80008648:	ffff9097          	auipc	ra,0xffff9
    8000864c:	ba8080e7          	jalr	-1112(ra) # 800011f0 <memset>
  memset(disk.avail, 0, PGSIZE);
    80008650:	0001b497          	auipc	s1,0x1b
    80008654:	53848493          	addi	s1,s1,1336 # 80023b88 <disk>
    80008658:	00001637          	lui	a2,0x1
    8000865c:	00000593          	li	a1,0
    80008660:	0084b503          	ld	a0,8(s1)
    80008664:	ffff9097          	auipc	ra,0xffff9
    80008668:	b8c080e7          	jalr	-1140(ra) # 800011f0 <memset>
  memset(disk.used, 0, PGSIZE);
    8000866c:	00001637          	lui	a2,0x1
    80008670:	00000593          	li	a1,0
    80008674:	0104b503          	ld	a0,16(s1)
    80008678:	ffff9097          	auipc	ra,0xffff9
    8000867c:	b78080e7          	jalr	-1160(ra) # 800011f0 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80008680:	100017b7          	lui	a5,0x10001
    80008684:	00800713          	li	a4,8
    80008688:	02e7ac23          	sw	a4,56(a5) # 10001038 <_entry-0x6fffefc8>
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000868c:	0004a703          	lw	a4,0(s1)
    80008690:	08e7a023          	sw	a4,128(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80008694:	0044a703          	lw	a4,4(s1)
    80008698:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000869c:	0084b703          	ld	a4,8(s1)
    800086a0:	0007069b          	sext.w	a3,a4
    800086a4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800086a8:	42075713          	srai	a4,a4,0x20
    800086ac:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800086b0:	0104b703          	ld	a4,16(s1)
    800086b4:	0007069b          	sext.w	a3,a4
    800086b8:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800086bc:	42075713          	srai	a4,a4,0x20
    800086c0:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800086c4:	00100713          	li	a4,1
    800086c8:	04e7a223          	sw	a4,68(a5)
    disk.free[i] = 1;
    800086cc:	00e48c23          	sb	a4,24(s1)
    800086d0:	00e48ca3          	sb	a4,25(s1)
    800086d4:	00e48d23          	sb	a4,26(s1)
    800086d8:	00e48da3          	sb	a4,27(s1)
    800086dc:	00e48e23          	sb	a4,28(s1)
    800086e0:	00e48ea3          	sb	a4,29(s1)
    800086e4:	00e48f23          	sb	a4,30(s1)
    800086e8:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800086ec:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800086f0:	0727a823          	sw	s2,112(a5)
}
    800086f4:	01813083          	ld	ra,24(sp)
    800086f8:	01013403          	ld	s0,16(sp)
    800086fc:	00813483          	ld	s1,8(sp)
    80008700:	00013903          	ld	s2,0(sp)
    80008704:	02010113          	addi	sp,sp,32
    80008708:	00008067          	ret
    panic("could not find virtio disk");
    8000870c:	00002517          	auipc	a0,0x2
    80008710:	1a450513          	addi	a0,a0,420 # 8000a8b0 <syscalls+0x360>
    80008714:	ffff8097          	auipc	ra,0xffff8
    80008718:	36c080e7          	jalr	876(ra) # 80000a80 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000871c:	00002517          	auipc	a0,0x2
    80008720:	1b450513          	addi	a0,a0,436 # 8000a8d0 <syscalls+0x380>
    80008724:	ffff8097          	auipc	ra,0xffff8
    80008728:	35c080e7          	jalr	860(ra) # 80000a80 <panic>
    panic("virtio disk should not be ready");
    8000872c:	00002517          	auipc	a0,0x2
    80008730:	1c450513          	addi	a0,a0,452 # 8000a8f0 <syscalls+0x3a0>
    80008734:	ffff8097          	auipc	ra,0xffff8
    80008738:	34c080e7          	jalr	844(ra) # 80000a80 <panic>
    panic("virtio disk has no queue 0");
    8000873c:	00002517          	auipc	a0,0x2
    80008740:	1d450513          	addi	a0,a0,468 # 8000a910 <syscalls+0x3c0>
    80008744:	ffff8097          	auipc	ra,0xffff8
    80008748:	33c080e7          	jalr	828(ra) # 80000a80 <panic>
    panic("virtio disk max queue too short");
    8000874c:	00002517          	auipc	a0,0x2
    80008750:	1e450513          	addi	a0,a0,484 # 8000a930 <syscalls+0x3e0>
    80008754:	ffff8097          	auipc	ra,0xffff8
    80008758:	32c080e7          	jalr	812(ra) # 80000a80 <panic>
    panic("virtio disk kalloc");
    8000875c:	00002517          	auipc	a0,0x2
    80008760:	1f450513          	addi	a0,a0,500 # 8000a950 <syscalls+0x400>
    80008764:	ffff8097          	auipc	ra,0xffff8
    80008768:	31c080e7          	jalr	796(ra) # 80000a80 <panic>

000000008000876c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000876c:	f8010113          	addi	sp,sp,-128
    80008770:	06113c23          	sd	ra,120(sp)
    80008774:	06813823          	sd	s0,112(sp)
    80008778:	06913423          	sd	s1,104(sp)
    8000877c:	07213023          	sd	s2,96(sp)
    80008780:	05313c23          	sd	s3,88(sp)
    80008784:	05413823          	sd	s4,80(sp)
    80008788:	05513423          	sd	s5,72(sp)
    8000878c:	05613023          	sd	s6,64(sp)
    80008790:	03713c23          	sd	s7,56(sp)
    80008794:	03813823          	sd	s8,48(sp)
    80008798:	03913423          	sd	s9,40(sp)
    8000879c:	03a13023          	sd	s10,32(sp)
    800087a0:	01b13c23          	sd	s11,24(sp)
    800087a4:	08010413          	addi	s0,sp,128
    800087a8:	00050a93          	mv	s5,a0
    800087ac:	00058c13          	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800087b0:	00c52d03          	lw	s10,12(a0)
    800087b4:	001d1d1b          	slliw	s10,s10,0x1
    800087b8:	020d1d13          	slli	s10,s10,0x20
    800087bc:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800087c0:	0001b517          	auipc	a0,0x1b
    800087c4:	4f050513          	addi	a0,a0,1264 # 80023cb0 <disk+0x128>
    800087c8:	ffff9097          	auipc	ra,0xffff9
    800087cc:	8d0080e7          	jalr	-1840(ra) # 80001098 <acquire>
  for(int i = 0; i < 3; i++){
    800087d0:	00000993          	li	s3,0
  for(int i = 0; i < NUM; i++){
    800087d4:	00800493          	li	s1,8
      disk.free[i] = 0;
    800087d8:	0001bb97          	auipc	s7,0x1b
    800087dc:	3b0b8b93          	addi	s7,s7,944 # 80023b88 <disk>
  for(int i = 0; i < 3; i++){
    800087e0:	00300b13          	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800087e4:	0001bc97          	auipc	s9,0x1b
    800087e8:	4ccc8c93          	addi	s9,s9,1228 # 80023cb0 <disk+0x128>
    800087ec:	0800006f          	j	8000886c <virtio_disk_rw+0x100>
      disk.free[i] = 0;
    800087f0:	00fb8733          	add	a4,s7,a5
    800087f4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800087f8:	00f5a023          	sw	a5,0(a1)
    if(idx[i] < 0){
    800087fc:	0207ce63          	bltz	a5,80008838 <virtio_disk_rw+0xcc>
  for(int i = 0; i < 3; i++){
    80008800:	0019091b          	addiw	s2,s2,1
    80008804:	00460613          	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80008808:	07690a63          	beq	s2,s6,8000887c <virtio_disk_rw+0x110>
    idx[i] = alloc_desc();
    8000880c:	00060593          	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80008810:	0001b717          	auipc	a4,0x1b
    80008814:	37870713          	addi	a4,a4,888 # 80023b88 <disk>
    80008818:	00098793          	mv	a5,s3
    if(disk.free[i]){
    8000881c:	01874683          	lbu	a3,24(a4)
    80008820:	fc0698e3          	bnez	a3,800087f0 <virtio_disk_rw+0x84>
  for(int i = 0; i < NUM; i++){
    80008824:	0017879b          	addiw	a5,a5,1
    80008828:	00170713          	addi	a4,a4,1
    8000882c:	fe9798e3          	bne	a5,s1,8000881c <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80008830:	fff00793          	li	a5,-1
    80008834:	00f5a023          	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80008838:	03205063          	blez	s2,80008858 <virtio_disk_rw+0xec>
    8000883c:	00098d93          	mv	s11,s3
        free_desc(idx[j]);
    80008840:	000a2503          	lw	a0,0(s4)
    80008844:	00000097          	auipc	ra,0x0
    80008848:	c1c080e7          	jalr	-996(ra) # 80008460 <free_desc>
      for(int j = 0; j < i; j++)
    8000884c:	001d8d9b          	addiw	s11,s11,1
    80008850:	004a0a13          	addi	s4,s4,4
    80008854:	ff2d96e3          	bne	s11,s2,80008840 <virtio_disk_rw+0xd4>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80008858:	000c8593          	mv	a1,s9
    8000885c:	0001b517          	auipc	a0,0x1b
    80008860:	34450513          	addi	a0,a0,836 # 80023ba0 <disk+0x18>
    80008864:	ffffb097          	auipc	ra,0xffffb
    80008868:	84c080e7          	jalr	-1972(ra) # 800030b0 <sleep>
  for(int i = 0; i < 3; i++){
    8000886c:	f8040a13          	addi	s4,s0,-128
{
    80008870:	000a0613          	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80008874:	00098913          	mv	s2,s3
    80008878:	f95ff06f          	j	8000880c <virtio_disk_rw+0xa0>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000887c:	f8042503          	lw	a0,-128(s0)
    80008880:	00a50713          	addi	a4,a0,10
    80008884:	00471713          	slli	a4,a4,0x4

  if(write)
    80008888:	0001b797          	auipc	a5,0x1b
    8000888c:	30078793          	addi	a5,a5,768 # 80023b88 <disk>
    80008890:	00e786b3          	add	a3,a5,a4
    80008894:	01803633          	snez	a2,s8
    80008898:	00c6a423          	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000889c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800088a0:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800088a4:	f6070613          	addi	a2,a4,-160
    800088a8:	0007b683          	ld	a3,0(a5)
    800088ac:	00c686b3          	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800088b0:	00870593          	addi	a1,a4,8
    800088b4:	00b785b3          	add	a1,a5,a1
  disk.desc[idx[0]].addr = (uint64) buf0;
    800088b8:	00b6b023          	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800088bc:	0007b803          	ld	a6,0(a5)
    800088c0:	00c80633          	add	a2,a6,a2
    800088c4:	01000693          	li	a3,16
    800088c8:	00d62423          	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800088cc:	00100593          	li	a1,1
    800088d0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800088d4:	f8442683          	lw	a3,-124(s0)
    800088d8:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800088dc:	00469693          	slli	a3,a3,0x4
    800088e0:	00d80833          	add	a6,a6,a3
    800088e4:	058a8613          	addi	a2,s5,88
    800088e8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800088ec:	0007b803          	ld	a6,0(a5)
    800088f0:	00d806b3          	add	a3,a6,a3
    800088f4:	40000613          	li	a2,1024
    800088f8:	00c6a423          	sw	a2,8(a3)
  if(write)
    800088fc:	001c3613          	seqz	a2,s8
    80008900:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80008904:	00166613          	ori	a2,a2,1
    80008908:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000890c:	f8842603          	lw	a2,-120(s0)
    80008910:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80008914:	00250693          	addi	a3,a0,2
    80008918:	00469693          	slli	a3,a3,0x4
    8000891c:	00d786b3          	add	a3,a5,a3
    80008920:	fff00893          	li	a7,-1
    80008924:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80008928:	00461613          	slli	a2,a2,0x4
    8000892c:	00c80833          	add	a6,a6,a2
    80008930:	f9070713          	addi	a4,a4,-112
    80008934:	00e78733          	add	a4,a5,a4
    80008938:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000893c:	0007b703          	ld	a4,0(a5)
    80008940:	00c70733          	add	a4,a4,a2
    80008944:	00b72423          	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80008948:	00200613          	li	a2,2
    8000894c:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80008950:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80008954:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80008958:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000895c:	0087b683          	ld	a3,8(a5)
    80008960:	0026d703          	lhu	a4,2(a3)
    80008964:	00777713          	andi	a4,a4,7
    80008968:	00171713          	slli	a4,a4,0x1
    8000896c:	00e686b3          	add	a3,a3,a4
    80008970:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80008974:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80008978:	0087b703          	ld	a4,8(a5)
    8000897c:	00275783          	lhu	a5,2(a4)
    80008980:	0017879b          	addiw	a5,a5,1
    80008984:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80008988:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000898c:	100017b7          	lui	a5,0x10001
    80008990:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80008994:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80008998:	0001b917          	auipc	s2,0x1b
    8000899c:	31890913          	addi	s2,s2,792 # 80023cb0 <disk+0x128>
  while(b->disk == 1) {
    800089a0:	00100493          	li	s1,1
    800089a4:	00b79e63          	bne	a5,a1,800089c0 <virtio_disk_rw+0x254>
    sleep(b, &disk.vdisk_lock);
    800089a8:	00090593          	mv	a1,s2
    800089ac:	000a8513          	mv	a0,s5
    800089b0:	ffffa097          	auipc	ra,0xffffa
    800089b4:	700080e7          	jalr	1792(ra) # 800030b0 <sleep>
  while(b->disk == 1) {
    800089b8:	004aa783          	lw	a5,4(s5)
    800089bc:	fe9786e3          	beq	a5,s1,800089a8 <virtio_disk_rw+0x23c>
  }

  disk.info[idx[0]].b = 0;
    800089c0:	f8042903          	lw	s2,-128(s0)
    800089c4:	00290713          	addi	a4,s2,2
    800089c8:	00471713          	slli	a4,a4,0x4
    800089cc:	0001b797          	auipc	a5,0x1b
    800089d0:	1bc78793          	addi	a5,a5,444 # 80023b88 <disk>
    800089d4:	00e787b3          	add	a5,a5,a4
    800089d8:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800089dc:	0001b997          	auipc	s3,0x1b
    800089e0:	1ac98993          	addi	s3,s3,428 # 80023b88 <disk>
    800089e4:	00491713          	slli	a4,s2,0x4
    800089e8:	0009b783          	ld	a5,0(s3)
    800089ec:	00e787b3          	add	a5,a5,a4
    800089f0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800089f4:	00090513          	mv	a0,s2
    800089f8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800089fc:	00000097          	auipc	ra,0x0
    80008a00:	a64080e7          	jalr	-1436(ra) # 80008460 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80008a04:	0014f493          	andi	s1,s1,1
    80008a08:	fc049ee3          	bnez	s1,800089e4 <virtio_disk_rw+0x278>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80008a0c:	0001b517          	auipc	a0,0x1b
    80008a10:	2a450513          	addi	a0,a0,676 # 80023cb0 <disk+0x128>
    80008a14:	ffff8097          	auipc	ra,0xffff8
    80008a18:	77c080e7          	jalr	1916(ra) # 80001190 <release>
}
    80008a1c:	07813083          	ld	ra,120(sp)
    80008a20:	07013403          	ld	s0,112(sp)
    80008a24:	06813483          	ld	s1,104(sp)
    80008a28:	06013903          	ld	s2,96(sp)
    80008a2c:	05813983          	ld	s3,88(sp)
    80008a30:	05013a03          	ld	s4,80(sp)
    80008a34:	04813a83          	ld	s5,72(sp)
    80008a38:	04013b03          	ld	s6,64(sp)
    80008a3c:	03813b83          	ld	s7,56(sp)
    80008a40:	03013c03          	ld	s8,48(sp)
    80008a44:	02813c83          	ld	s9,40(sp)
    80008a48:	02013d03          	ld	s10,32(sp)
    80008a4c:	01813d83          	ld	s11,24(sp)
    80008a50:	08010113          	addi	sp,sp,128
    80008a54:	00008067          	ret

0000000080008a58 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80008a58:	fe010113          	addi	sp,sp,-32
    80008a5c:	00113c23          	sd	ra,24(sp)
    80008a60:	00813823          	sd	s0,16(sp)
    80008a64:	00913423          	sd	s1,8(sp)
    80008a68:	02010413          	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80008a6c:	0001b497          	auipc	s1,0x1b
    80008a70:	11c48493          	addi	s1,s1,284 # 80023b88 <disk>
    80008a74:	0001b517          	auipc	a0,0x1b
    80008a78:	23c50513          	addi	a0,a0,572 # 80023cb0 <disk+0x128>
    80008a7c:	ffff8097          	auipc	ra,0xffff8
    80008a80:	61c080e7          	jalr	1564(ra) # 80001098 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80008a84:	10001737          	lui	a4,0x10001
    80008a88:	06072783          	lw	a5,96(a4) # 10001060 <_entry-0x6fffefa0>
    80008a8c:	0037f793          	andi	a5,a5,3
    80008a90:	06f72223          	sw	a5,100(a4)

  __sync_synchronize();
    80008a94:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80008a98:	0104b783          	ld	a5,16(s1)
    80008a9c:	0204d703          	lhu	a4,32(s1)
    80008aa0:	0027d783          	lhu	a5,2(a5)
    80008aa4:	06f70863          	beq	a4,a5,80008b14 <virtio_disk_intr+0xbc>
    __sync_synchronize();
    80008aa8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80008aac:	0104b703          	ld	a4,16(s1)
    80008ab0:	0204d783          	lhu	a5,32(s1)
    80008ab4:	0077f793          	andi	a5,a5,7
    80008ab8:	00379793          	slli	a5,a5,0x3
    80008abc:	00f707b3          	add	a5,a4,a5
    80008ac0:	0047a783          	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80008ac4:	00278713          	addi	a4,a5,2
    80008ac8:	00471713          	slli	a4,a4,0x4
    80008acc:	00e48733          	add	a4,s1,a4
    80008ad0:	01074703          	lbu	a4,16(a4)
    80008ad4:	06071263          	bnez	a4,80008b38 <virtio_disk_intr+0xe0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80008ad8:	00278793          	addi	a5,a5,2
    80008adc:	00479793          	slli	a5,a5,0x4
    80008ae0:	00f487b3          	add	a5,s1,a5
    80008ae4:	0087b503          	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80008ae8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80008aec:	ffffa097          	auipc	ra,0xffffa
    80008af0:	654080e7          	jalr	1620(ra) # 80003140 <wakeup>

    disk.used_idx += 1;
    80008af4:	0204d783          	lhu	a5,32(s1)
    80008af8:	0017879b          	addiw	a5,a5,1
    80008afc:	03079793          	slli	a5,a5,0x30
    80008b00:	0307d793          	srli	a5,a5,0x30
    80008b04:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80008b08:	0104b703          	ld	a4,16(s1)
    80008b0c:	00275703          	lhu	a4,2(a4)
    80008b10:	f8f71ce3          	bne	a4,a5,80008aa8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80008b14:	0001b517          	auipc	a0,0x1b
    80008b18:	19c50513          	addi	a0,a0,412 # 80023cb0 <disk+0x128>
    80008b1c:	ffff8097          	auipc	ra,0xffff8
    80008b20:	674080e7          	jalr	1652(ra) # 80001190 <release>
}
    80008b24:	01813083          	ld	ra,24(sp)
    80008b28:	01013403          	ld	s0,16(sp)
    80008b2c:	00813483          	ld	s1,8(sp)
    80008b30:	02010113          	addi	sp,sp,32
    80008b34:	00008067          	ret
      panic("virtio_disk_intr status");
    80008b38:	00002517          	auipc	a0,0x2
    80008b3c:	e3050513          	addi	a0,a0,-464 # 8000a968 <syscalls+0x418>
    80008b40:	ffff8097          	auipc	ra,0xffff8
    80008b44:	f40080e7          	jalr	-192(ra) # 80000a80 <panic>
	...

0000000080009000 <_trampoline>:
    80009000:	14051073          	csrw	sscratch,a0
    80009004:	02000537          	lui	a0,0x2000
    80009008:	fff5051b          	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000900c:	00d51513          	slli	a0,a0,0xd
    80009010:	02153423          	sd	ra,40(a0)
    80009014:	02253823          	sd	sp,48(a0)
    80009018:	02353c23          	sd	gp,56(a0)
    8000901c:	04453023          	sd	tp,64(a0)
    80009020:	04553423          	sd	t0,72(a0)
    80009024:	04653823          	sd	t1,80(a0)
    80009028:	04753c23          	sd	t2,88(a0)
    8000902c:	06853023          	sd	s0,96(a0)
    80009030:	06953423          	sd	s1,104(a0)
    80009034:	06b53c23          	sd	a1,120(a0)
    80009038:	08c53023          	sd	a2,128(a0)
    8000903c:	08d53423          	sd	a3,136(a0)
    80009040:	08e53823          	sd	a4,144(a0)
    80009044:	08f53c23          	sd	a5,152(a0)
    80009048:	0b053023          	sd	a6,160(a0)
    8000904c:	0b153423          	sd	a7,168(a0)
    80009050:	0b253823          	sd	s2,176(a0)
    80009054:	0b353c23          	sd	s3,184(a0)
    80009058:	0d453023          	sd	s4,192(a0)
    8000905c:	0d553423          	sd	s5,200(a0)
    80009060:	0d653823          	sd	s6,208(a0)
    80009064:	0d753c23          	sd	s7,216(a0)
    80009068:	0f853023          	sd	s8,224(a0)
    8000906c:	0f953423          	sd	s9,232(a0)
    80009070:	0fa53823          	sd	s10,240(a0)
    80009074:	0fb53c23          	sd	s11,248(a0)
    80009078:	11c53023          	sd	t3,256(a0)
    8000907c:	11d53423          	sd	t4,264(a0)
    80009080:	11e53823          	sd	t5,272(a0)
    80009084:	11f53c23          	sd	t6,280(a0)
    80009088:	140022f3          	csrr	t0,sscratch
    8000908c:	06553823          	sd	t0,112(a0)
    80009090:	00853103          	ld	sp,8(a0)
    80009094:	02053203          	ld	tp,32(a0)
    80009098:	01053283          	ld	t0,16(a0)
    8000909c:	00053303          	ld	t1,0(a0)
    800090a0:	12000073          	sfence.vma
    800090a4:	18031073          	csrw	satp,t1
    800090a8:	12000073          	sfence.vma
    800090ac:	000280e7          	jalr	t0

00000000800090b0 <userret>:
    800090b0:	12000073          	sfence.vma
    800090b4:	18051073          	csrw	satp,a0
    800090b8:	12000073          	sfence.vma
    800090bc:	02000537          	lui	a0,0x2000
    800090c0:	fff5051b          	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800090c4:	00d51513          	slli	a0,a0,0xd
    800090c8:	02853083          	ld	ra,40(a0)
    800090cc:	03053103          	ld	sp,48(a0)
    800090d0:	03853183          	ld	gp,56(a0)
    800090d4:	04053203          	ld	tp,64(a0)
    800090d8:	04853283          	ld	t0,72(a0)
    800090dc:	05053303          	ld	t1,80(a0)
    800090e0:	05853383          	ld	t2,88(a0)
    800090e4:	06053403          	ld	s0,96(a0)
    800090e8:	06853483          	ld	s1,104(a0)
    800090ec:	07853583          	ld	a1,120(a0)
    800090f0:	08053603          	ld	a2,128(a0)
    800090f4:	08853683          	ld	a3,136(a0)
    800090f8:	09053703          	ld	a4,144(a0)
    800090fc:	09853783          	ld	a5,152(a0)
    80009100:	0a053803          	ld	a6,160(a0)
    80009104:	0a853883          	ld	a7,168(a0)
    80009108:	0b053903          	ld	s2,176(a0)
    8000910c:	0b853983          	ld	s3,184(a0)
    80009110:	0c053a03          	ld	s4,192(a0)
    80009114:	0c853a83          	ld	s5,200(a0)
    80009118:	0d053b03          	ld	s6,208(a0)
    8000911c:	0d853b83          	ld	s7,216(a0)
    80009120:	0e053c03          	ld	s8,224(a0)
    80009124:	0e853c83          	ld	s9,232(a0)
    80009128:	0f053d03          	ld	s10,240(a0)
    8000912c:	0f853d83          	ld	s11,248(a0)
    80009130:	10053e03          	ld	t3,256(a0)
    80009134:	10853e83          	ld	t4,264(a0)
    80009138:	11053f03          	ld	t5,272(a0)
    8000913c:	11853f83          	ld	t6,280(a0)
    80009140:	07053503          	ld	a0,112(a0)
    80009144:	10200073          	sret
	...
