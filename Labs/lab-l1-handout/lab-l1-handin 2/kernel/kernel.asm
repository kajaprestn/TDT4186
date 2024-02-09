
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a8010113          	add	sp,sp,-1408 # 80008a80 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	1761                	add	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8f070713          	add	a4,a4,-1808 # 80008940 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	dae78793          	add	a5,a5,-594 # 80005e10 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca4f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e2678793          	add	a5,a5,-474 # 80000ed2 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	428080e7          	jalr	1064(ra) # 80002552 <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7e4080e7          	jalr	2020(ra) # 8000091e <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	add	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	add	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	add	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	8f450513          	add	a0,a0,-1804 # 80010a80 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	aa4080e7          	jalr	-1372(ra) # 80000c38 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	8e448493          	add	s1,s1,-1820 # 80010a80 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	00011917          	auipc	s2,0x11
    800001a8:	97490913          	add	s2,s2,-1676 # 80010b18 <cons+0x98>
  while(n > 0){
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
    while(cons.r == cons.w){
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
      if(killed(myproc())){
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	88e080e7          	jalr	-1906(ra) # 80001a4a <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	1d8080e7          	jalr	472(ra) # 8000239c <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
      sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	f22080e7          	jalr	-222(ra) # 800020f4 <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00011717          	auipc	a4,0x11
    800001ec:	89870713          	add	a4,a4,-1896 # 80010a80 <cons>
    800001f0:	0017869b          	addw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	and	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	add	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	2e2080e7          	jalr	738(ra) # 800024fc <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
      break;

    dst++;
    80000228:	0a05                	add	s4,s4,1
    --n;
    8000022a:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
        release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	84a50513          	add	a0,a0,-1974 # 80010a80 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	aae080e7          	jalr	-1362(ra) # 80000cec <release>
        return -1;
    80000246:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000248:	60e6                	ld	ra,88(sp)
    8000024a:	6446                	ld	s0,80(sp)
    8000024c:	64a6                	ld	s1,72(sp)
    8000024e:	6906                	ld	s2,64(sp)
    80000250:	79e2                	ld	s3,56(sp)
    80000252:	7a42                	ld	s4,48(sp)
    80000254:	7aa2                	ld	s5,40(sp)
    80000256:	7b02                	ld	s6,32(sp)
    80000258:	6125                	add	sp,sp,96
    8000025a:	8082                	ret
      if(n < target){
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
        cons.r--;
    80000264:	00011717          	auipc	a4,0x11
    80000268:	8af72a23          	sw	a5,-1868(a4) # 80010b18 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000027a:	00011517          	auipc	a0,0x11
    8000027e:	80650513          	add	a0,a0,-2042 # 80010a80 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	a6a080e7          	jalr	-1430(ra) # 80000cec <release>
  return target - n;
    8000028a:	413b053b          	subw	a0,s6,s3
    8000028e:	bf6d                	j	80000248 <consoleread+0xda>
    80000290:	6be2                	ld	s7,24(sp)
    80000292:	b7e5                	j	8000027a <consoleread+0x10c>

0000000080000294 <consputc>:
{
    80000294:	1141                	add	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
    uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	59c080e7          	jalr	1436(ra) # 80000840 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	add	sp,sp,16
    800002b2:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	58a080e7          	jalr	1418(ra) # 80000840 <uartputc_sync>
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	57e080e7          	jalr	1406(ra) # 80000840 <uartputc_sync>
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	574080e7          	jalr	1396(ra) # 80000840 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d6:	1101                	add	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	add	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e2:	00010517          	auipc	a0,0x10
    800002e6:	79e50513          	add	a0,a0,1950 # 80010a80 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	94e080e7          	jalr	-1714(ra) # 80000c38 <acquire>

  switch(c){
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
  case C('P'):  // Print process list.
    procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	2a0080e7          	jalr	672(ra) # 800025a8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00010517          	auipc	a0,0x10
    80000314:	77050513          	add	a0,a0,1904 # 80010a80 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	9d4080e7          	jalr	-1580(ra) # 80000cec <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	add	sp,sp,32
    80000328:	8082                	ret
  switch(c){
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000332:	00010717          	auipc	a4,0x10
    80000336:	74e70713          	add	a4,a4,1870 # 80010a80 <cons>
    8000033a:	0a072783          	lw	a5,160(a4)
    8000033e:	09872703          	lw	a4,152(a4)
    80000342:	9f99                	subw	a5,a5,a4
    80000344:	07f00713          	li	a4,127
    80000348:	fcf764e3          	bltu	a4,a5,80000310 <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    8000034c:	47b5                	li	a5,13
    8000034e:	0cf48d63          	beq	s1,a5,80000428 <consoleintr+0x152>
      consputc(c);
    80000352:	8526                	mv	a0,s1
    80000354:	00000097          	auipc	ra,0x0
    80000358:	f40080e7          	jalr	-192(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035c:	00010797          	auipc	a5,0x10
    80000360:	72478793          	add	a5,a5,1828 # 80010a80 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	and	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00010797          	auipc	a5,0x10
    8000038e:	78e7a783          	lw	a5,1934(a5) # 80010b18 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a0:	00010717          	auipc	a4,0x10
    800003a4:	6e070713          	add	a4,a4,1760 # 80010a80 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b0:	00010497          	auipc	s1,0x10
    800003b4:	6d048493          	add	s1,s1,1744 # 80010a80 <cons>
    while(cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003be:	37fd                	addw	a5,a5,-1
    800003c0:	07f7f713          	and	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
      cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
    while(cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f6:	00010717          	auipc	a4,0x10
    800003fa:	68a70713          	add	a4,a4,1674 # 80010a80 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
      cons.e--;
    8000040a:	37fd                	addw	a5,a5,-1
    8000040c:	00010717          	auipc	a4,0x10
    80000410:	70f72a23          	sw	a5,1812(a4) # 80010b20 <cons+0xa0>
      consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
      consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	64e78793          	add	a5,a5,1614 # 80010a80 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	and	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000456:	00010797          	auipc	a5,0x10
    8000045a:	6cc7a323          	sw	a2,1734(a5) # 80010b1c <cons+0x9c>
        wakeup(&cons.r);
    8000045e:	00010517          	auipc	a0,0x10
    80000462:	6ba50513          	add	a0,a0,1722 # 80010b18 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	cf2080e7          	jalr	-782(ra) # 80002158 <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void
consoleinit(void)
{
    80000470:	1141                	add	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b8858593          	add	a1,a1,-1144 # 80008000 <etext>
    80000480:	00010517          	auipc	a0,0x10
    80000484:	60050513          	add	a0,a0,1536 # 80010a80 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	720080e7          	jalr	1824(ra) # 80000ba8 <initlock>

  uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	354080e7          	jalr	852(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000498:	00020797          	auipc	a5,0x20
    8000049c:	78078793          	add	a5,a5,1920 # 80020c18 <devsw>
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	cce70713          	add	a4,a4,-818 # 8000016e <consoleread>
    800004a8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004aa:	00000717          	auipc	a4,0x0
    800004ae:	c5670713          	add	a4,a4,-938 # 80000100 <consolewrite>
    800004b2:	ef98                	sd	a4,24(a5)
}
    800004b4:	60a2                	ld	ra,8(sp)
    800004b6:	6402                	ld	s0,0(sp)
    800004b8:	0141                	add	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004bc:	7179                	add	sp,sp,-48
    800004be:	f406                	sd	ra,40(sp)
    800004c0:	f022                	sd	s0,32(sp)
    800004c2:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0xe>
    800004c6:	08054963          	bltz	a0,80000558 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	add	a3,s0,-48

  i = 0;
    800004d2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	2a260613          	add	a2,a2,674 # 80008778 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	sll	a5,a5,0x20
    800004e8:	9381                	srl	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	add	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

  if(sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
    buf[i++] = '-';
    80000506:	fe070793          	add	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    8000051a:	02e05b63          	blez	a4,80000550 <printint+0x94>
    8000051e:	ec26                	sd	s1,24(sp)
    80000520:	e84a                	sd	s2,16(sp)
    80000522:	fd040793          	add	a5,s0,-48
    80000526:	00e784b3          	add	s1,a5,a4
    8000052a:	fff78913          	add	s2,a5,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	377d                	addw	a4,a4,-1
    80000532:	1702                	sll	a4,a4,0x20
    80000534:	9301                	srl	a4,a4,0x20
    80000536:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d56080e7          	jalr	-682(ra) # 80000294 <consputc>
  while(--i >= 0)
    80000546:	14fd                	add	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x7e>
    8000054c:	64e2                	ld	s1,24(sp)
    8000054e:	6942                	ld	s2,16(sp)
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	6145                	add	sp,sp,48
    80000556:	8082                	ret
    x = -xx;
    80000558:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
    x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000560:	1101                	add	sp,sp,-32
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	add	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056c:	00010797          	auipc	a5,0x10
    80000570:	5c07aa23          	sw	zero,1492(a5) # 80010b40 <pr+0x18>
  printf("panic: ");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	a9450513          	add	a0,a0,-1388 # 80008008 <etext+0x8>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	02e080e7          	jalr	46(ra) # 800005aa <printf>
  printf(s);
    80000584:	8526                	mv	a0,s1
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  printf("\n");
    8000058e:	00008517          	auipc	a0,0x8
    80000592:	a8250513          	add	a0,a0,-1406 # 80008010 <etext+0x10>
    80000596:	00000097          	auipc	ra,0x0
    8000059a:	014080e7          	jalr	20(ra) # 800005aa <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059e:	4785                	li	a5,1
    800005a0:	00008717          	auipc	a4,0x8
    800005a4:	36f72023          	sw	a5,864(a4) # 80008900 <panicked>
  for(;;)
    800005a8:	a001                	j	800005a8 <panic+0x48>

00000000800005aa <printf>:
{
    800005aa:	7131                	add	sp,sp,-192
    800005ac:	fc86                	sd	ra,120(sp)
    800005ae:	f8a2                	sd	s0,112(sp)
    800005b0:	e8d2                	sd	s4,80(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	0100                	add	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00010d17          	auipc	s10,0x10
    800005ce:	576d2d03          	lw	s10,1398(s10) # 80010b40 <pr+0x18>
  if(locking)
    800005d2:	040d1463          	bnez	s10,8000061a <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0b63          	beqz	s4,8000062c <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	add	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	18050b63          	beqz	a0,8000077c <printf+0x1d2>
    800005ea:	f4a6                	sd	s1,104(sp)
    800005ec:	f0ca                	sd	s2,96(sp)
    800005ee:	ecce                	sd	s3,88(sp)
    800005f0:	e4d6                	sd	s5,72(sp)
    800005f2:	e0da                	sd	s6,64(sp)
    800005f4:	fc5e                	sd	s7,56(sp)
    800005f6:	f862                	sd	s8,48(sp)
    800005f8:	f466                	sd	s9,40(sp)
    800005fa:	ec6e                	sd	s11,24(sp)
    800005fc:	4981                	li	s3,0
    if(c != '%'){
    800005fe:	02500b13          	li	s6,37
    switch(c){
    80000602:	07000b93          	li	s7,112
  consputc('x');
    80000606:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000608:	00008a97          	auipc	s5,0x8
    8000060c:	170a8a93          	add	s5,s5,368 # 80008778 <digits>
    switch(c){
    80000610:	07300c13          	li	s8,115
    80000614:	06400d93          	li	s11,100
    80000618:	a0b1                	j	80000664 <printf+0xba>
    acquire(&pr.lock);
    8000061a:	00010517          	auipc	a0,0x10
    8000061e:	50e50513          	add	a0,a0,1294 # 80010b28 <pr>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	616080e7          	jalr	1558(ra) # 80000c38 <acquire>
    8000062a:	b775                	j	800005d6 <printf+0x2c>
    8000062c:	f4a6                	sd	s1,104(sp)
    8000062e:	f0ca                	sd	s2,96(sp)
    80000630:	ecce                	sd	s3,88(sp)
    80000632:	e4d6                	sd	s5,72(sp)
    80000634:	e0da                	sd	s6,64(sp)
    80000636:	fc5e                	sd	s7,56(sp)
    80000638:	f862                	sd	s8,48(sp)
    8000063a:	f466                	sd	s9,40(sp)
    8000063c:	ec6e                	sd	s11,24(sp)
    panic("null fmt");
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	9e250513          	add	a0,a0,-1566 # 80008020 <etext+0x20>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c46080e7          	jalr	-954(ra) # 80000294 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	2985                	addw	s3,s3,1
    80000658:	013a07b3          	add	a5,s4,s3
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050563          	beqz	a0,8000076a <printf+0x1c0>
    if(c != '%'){
    80000664:	ff6515e3          	bne	a0,s6,8000064e <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000668:	2985                	addw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c783          	lbu	a5,0(a5)
    80000672:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000676:	10078b63          	beqz	a5,8000078c <printf+0x1e2>
    switch(c){
    8000067a:	05778a63          	beq	a5,s7,800006ce <printf+0x124>
    8000067e:	02fbf663          	bgeu	s7,a5,800006aa <printf+0x100>
    80000682:	09878863          	beq	a5,s8,80000712 <printf+0x168>
    80000686:	07800713          	li	a4,120
    8000068a:	0ce79563          	bne	a5,a4,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	add	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85e6                	mv	a1,s9
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e1c080e7          	jalr	-484(ra) # 800004bc <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0xac>
    switch(c){
    800006aa:	09678f63          	beq	a5,s6,80000748 <printf+0x19e>
    800006ae:	0bb79363          	bne	a5,s11,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 10, 1);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	add	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4605                	li	a2,1
    800006c0:	45a9                	li	a1,10
    800006c2:	4388                	lw	a0,0(a5)
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	df8080e7          	jalr	-520(ra) # 800004bc <printint>
      break;
    800006cc:	b769                	j	80000656 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	add	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	00000097          	auipc	ra,0x0
    800006e6:	bb2080e7          	jalr	-1102(ra) # 80000294 <consputc>
  consputc('x');
    800006ea:	07800513          	li	a0,120
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	ba6080e7          	jalr	-1114(ra) # 80000294 <consputc>
    800006f6:	84e6                	mv	s1,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c95793          	srl	a5,s2,0x3c
    800006fc:	97d6                	add	a5,a5,s5
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b92080e7          	jalr	-1134(ra) # 80000294 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0912                	sll	s2,s2,0x4
    8000070c:	34fd                	addw	s1,s1,-1
    8000070e:	f4ed                	bnez	s1,800006f8 <printf+0x14e>
    80000710:	b799                	j	80000656 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000712:	f8843783          	ld	a5,-120(s0)
    80000716:	00878713          	add	a4,a5,8
    8000071a:	f8e43423          	sd	a4,-120(s0)
    8000071e:	6384                	ld	s1,0(a5)
    80000720:	cc89                	beqz	s1,8000073a <printf+0x190>
      for(; *s; s++)
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	d905                	beqz	a0,80000656 <printf+0xac>
        consputc(*s);
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b6c080e7          	jalr	-1172(ra) # 80000294 <consputc>
      for(; *s; s++)
    80000730:	0485                	add	s1,s1,1
    80000732:	0004c503          	lbu	a0,0(s1)
    80000736:	f96d                	bnez	a0,80000728 <printf+0x17e>
    80000738:	bf39                	j	80000656 <printf+0xac>
        s = "(null)";
    8000073a:	00008497          	auipc	s1,0x8
    8000073e:	8de48493          	add	s1,s1,-1826 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000742:	02800513          	li	a0,40
    80000746:	b7cd                	j	80000728 <printf+0x17e>
      consputc('%');
    80000748:	855a                	mv	a0,s6
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b4a080e7          	jalr	-1206(ra) # 80000294 <consputc>
      break;
    80000752:	b711                	j	80000656 <printf+0xac>
      consputc('%');
    80000754:	855a                	mv	a0,s6
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	b3e080e7          	jalr	-1218(ra) # 80000294 <consputc>
      consputc(c);
    8000075e:	8526                	mv	a0,s1
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b34080e7          	jalr	-1228(ra) # 80000294 <consputc>
      break;
    80000768:	b5fd                	j	80000656 <printf+0xac>
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	7906                	ld	s2,96(sp)
    8000076e:	69e6                	ld	s3,88(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	6de2                	ld	s11,24(sp)
  if(locking)
    8000077c:	020d1263          	bnez	s10,800007a0 <printf+0x1f6>
}
    80000780:	70e6                	ld	ra,120(sp)
    80000782:	7446                	ld	s0,112(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	7d02                	ld	s10,32(sp)
    80000788:	6129                	add	sp,sp,192
    8000078a:	8082                	ret
    8000078c:	74a6                	ld	s1,104(sp)
    8000078e:	7906                	ld	s2,96(sp)
    80000790:	69e6                	ld	s3,88(sp)
    80000792:	6aa6                	ld	s5,72(sp)
    80000794:	6b06                	ld	s6,64(sp)
    80000796:	7be2                	ld	s7,56(sp)
    80000798:	7c42                	ld	s8,48(sp)
    8000079a:	7ca2                	ld	s9,40(sp)
    8000079c:	6de2                	ld	s11,24(sp)
    8000079e:	bff9                	j	8000077c <printf+0x1d2>
    release(&pr.lock);
    800007a0:	00010517          	auipc	a0,0x10
    800007a4:	38850513          	add	a0,a0,904 # 80010b28 <pr>
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	544080e7          	jalr	1348(ra) # 80000cec <release>
}
    800007b0:	bfc1                	j	80000780 <printf+0x1d6>

00000000800007b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b2:	1101                	add	sp,sp,-32
    800007b4:	ec06                	sd	ra,24(sp)
    800007b6:	e822                	sd	s0,16(sp)
    800007b8:	e426                	sd	s1,8(sp)
    800007ba:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    800007bc:	00010497          	auipc	s1,0x10
    800007c0:	36c48493          	add	s1,s1,876 # 80010b28 <pr>
    800007c4:	00008597          	auipc	a1,0x8
    800007c8:	86c58593          	add	a1,a1,-1940 # 80008030 <etext+0x30>
    800007cc:	8526                	mv	a0,s1
    800007ce:	00000097          	auipc	ra,0x0
    800007d2:	3da080e7          	jalr	986(ra) # 80000ba8 <initlock>
  pr.locking = 1;
    800007d6:	4785                	li	a5,1
    800007d8:	cc9c                	sw	a5,24(s1)
}
    800007da:	60e2                	ld	ra,24(sp)
    800007dc:	6442                	ld	s0,16(sp)
    800007de:	64a2                	ld	s1,8(sp)
    800007e0:	6105                	add	sp,sp,32
    800007e2:	8082                	ret

00000000800007e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e4:	1141                	add	sp,sp,-16
    800007e6:	e406                	sd	ra,8(sp)
    800007e8:	e022                	sd	s0,0(sp)
    800007ea:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ec:	100007b7          	lui	a5,0x10000
    800007f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f4:	10000737          	lui	a4,0x10000
    800007f8:	f8000693          	li	a3,-128
    800007fc:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	468d                	li	a3,3
    80000802:	10000637          	lui	a2,0x10000
    80000806:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000812:	10000737          	lui	a4,0x10000
    80000816:	461d                	li	a2,7
    80000818:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000820:	00008597          	auipc	a1,0x8
    80000824:	81858593          	add	a1,a1,-2024 # 80008038 <etext+0x38>
    80000828:	00010517          	auipc	a0,0x10
    8000082c:	32050513          	add	a0,a0,800 # 80010b48 <uart_tx_lock>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	378080e7          	jalr	888(ra) # 80000ba8 <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	add	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000840:	1101                	add	sp,sp,-32
    80000842:	ec06                	sd	ra,24(sp)
    80000844:	e822                	sd	s0,16(sp)
    80000846:	e426                	sd	s1,8(sp)
    80000848:	1000                	add	s0,sp,32
    8000084a:	84aa                	mv	s1,a0
  push_off();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	3a0080e7          	jalr	928(ra) # 80000bec <push_off>

  if(panicked){
    80000854:	00008797          	auipc	a5,0x8
    80000858:	0ac7a783          	lw	a5,172(a5) # 80008900 <panicked>
    8000085c:	eb85                	bnez	a5,8000088c <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	0715                	add	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000864:	00074783          	lbu	a5,0(a4)
    80000868:	0207f793          	and	a5,a5,32
    8000086c:	dfe5                	beqz	a5,80000864 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086e:	0ff4f513          	zext.b	a0,s1
    80000872:	100007b7          	lui	a5,0x10000
    80000876:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	412080e7          	jalr	1042(ra) # 80000c8c <pop_off>
}
    80000882:	60e2                	ld	ra,24(sp)
    80000884:	6442                	ld	s0,16(sp)
    80000886:	64a2                	ld	s1,8(sp)
    80000888:	6105                	add	sp,sp,32
    8000088a:	8082                	ret
    for(;;)
    8000088c:	a001                	j	8000088c <uartputc_sync+0x4c>

000000008000088e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088e:	00008797          	auipc	a5,0x8
    80000892:	07a7b783          	ld	a5,122(a5) # 80008908 <uart_tx_r>
    80000896:	00008717          	auipc	a4,0x8
    8000089a:	07a73703          	ld	a4,122(a4) # 80008910 <uart_tx_w>
    8000089e:	06f70f63          	beq	a4,a5,8000091c <uartstart+0x8e>
{
    800008a2:	7139                	add	sp,sp,-64
    800008a4:	fc06                	sd	ra,56(sp)
    800008a6:	f822                	sd	s0,48(sp)
    800008a8:	f426                	sd	s1,40(sp)
    800008aa:	f04a                	sd	s2,32(sp)
    800008ac:	ec4e                	sd	s3,24(sp)
    800008ae:	e852                	sd	s4,16(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	e05a                	sd	s6,0(sp)
    800008b4:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b6:	10000937          	lui	s2,0x10000
    800008ba:	0915                	add	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008bc:	00010a97          	auipc	s5,0x10
    800008c0:	28ca8a93          	add	s5,s5,652 # 80010b48 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	00008497          	auipc	s1,0x8
    800008c8:	04448493          	add	s1,s1,68 # 80008908 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	00008997          	auipc	s3,0x8
    800008d4:	04098993          	add	s3,s3,64 # 80008910 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d8:	00094703          	lbu	a4,0(s2)
    800008dc:	02077713          	and	a4,a4,32
    800008e0:	c705                	beqz	a4,80000908 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e2:	01f7f713          	and	a4,a5,31
    800008e6:	9756                	add	a4,a4,s5
    800008e8:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ec:	0785                	add	a5,a5,1
    800008ee:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008f0:	8526                	mv	a0,s1
    800008f2:	00002097          	auipc	ra,0x2
    800008f6:	866080e7          	jalr	-1946(ra) # 80002158 <wakeup>
    WriteReg(THR, c);
    800008fa:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	609c                	ld	a5,0(s1)
    80000900:	0009b703          	ld	a4,0(s3)
    80000904:	fcf71ae3          	bne	a4,a5,800008d8 <uartstart+0x4a>
  }
}
    80000908:	70e2                	ld	ra,56(sp)
    8000090a:	7442                	ld	s0,48(sp)
    8000090c:	74a2                	ld	s1,40(sp)
    8000090e:	7902                	ld	s2,32(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6aa2                	ld	s5,8(sp)
    80000916:	6b02                	ld	s6,0(sp)
    80000918:	6121                	add	sp,sp,64
    8000091a:	8082                	ret
    8000091c:	8082                	ret

000000008000091e <uartputc>:
{
    8000091e:	7179                	add	sp,sp,-48
    80000920:	f406                	sd	ra,40(sp)
    80000922:	f022                	sd	s0,32(sp)
    80000924:	ec26                	sd	s1,24(sp)
    80000926:	e84a                	sd	s2,16(sp)
    80000928:	e44e                	sd	s3,8(sp)
    8000092a:	e052                	sd	s4,0(sp)
    8000092c:	1800                	add	s0,sp,48
    8000092e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000930:	00010517          	auipc	a0,0x10
    80000934:	21850513          	add	a0,a0,536 # 80010b48 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	300080e7          	jalr	768(ra) # 80000c38 <acquire>
  if(panicked){
    80000940:	00008797          	auipc	a5,0x8
    80000944:	fc07a783          	lw	a5,-64(a5) # 80008900 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	00008717          	auipc	a4,0x8
    8000094e:	fc673703          	ld	a4,-58(a4) # 80008910 <uart_tx_w>
    80000952:	00008797          	auipc	a5,0x8
    80000956:	fb67b783          	ld	a5,-74(a5) # 80008908 <uart_tx_r>
    8000095a:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00010997          	auipc	s3,0x10
    80000962:	1ea98993          	add	s3,s3,490 # 80010b48 <uart_tx_lock>
    80000966:	00008497          	auipc	s1,0x8
    8000096a:	fa248493          	add	s1,s1,-94 # 80008908 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	00008917          	auipc	s2,0x8
    80000972:	fa290913          	add	s2,s2,-94 # 80008910 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00001097          	auipc	ra,0x1
    80000982:	776080e7          	jalr	1910(ra) # 800020f4 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	add	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00010497          	auipc	s1,0x10
    80000998:	1b448493          	add	s1,s1,436 # 80010b48 <uart_tx_lock>
    8000099c:	01f77793          	and	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	add	a4,a4,1
    800009a8:	00008797          	auipc	a5,0x8
    800009ac:	f6e7b423          	sd	a4,-152(a5) # 80008910 <uart_tx_w>
  uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ede080e7          	jalr	-290(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	332080e7          	jalr	818(ra) # 80000cec <release>
}
    800009c2:	70a2                	ld	ra,40(sp)
    800009c4:	7402                	ld	s0,32(sp)
    800009c6:	64e2                	ld	s1,24(sp)
    800009c8:	6942                	ld	s2,16(sp)
    800009ca:	69a2                	ld	s3,8(sp)
    800009cc:	6a02                	ld	s4,0(sp)
    800009ce:	6145                	add	sp,sp,48
    800009d0:	8082                	ret
    for(;;)
    800009d2:	a001                	j	800009d2 <uartputc+0xb4>

00000000800009d4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d4:	1141                	add	sp,sp,-16
    800009d6:	e422                	sd	s0,8(sp)
    800009d8:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009da:	100007b7          	lui	a5,0x10000
    800009de:	0795                	add	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009e0:	0007c783          	lbu	a5,0(a5)
    800009e4:	8b85                	and	a5,a5,1
    800009e6:	cb81                	beqz	a5,800009f6 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009e8:	100007b7          	lui	a5,0x10000
    800009ec:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f0:	6422                	ld	s0,8(sp)
    800009f2:	0141                	add	sp,sp,16
    800009f4:	8082                	ret
    return -1;
    800009f6:	557d                	li	a0,-1
    800009f8:	bfe5                	j	800009f0 <uartgetc+0x1c>

00000000800009fa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009fa:	1101                	add	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a04:	54fd                	li	s1,-1
    80000a06:	a029                	j	80000a10 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	8ce080e7          	jalr	-1842(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	fc4080e7          	jalr	-60(ra) # 800009d4 <uartgetc>
    if(c == -1)
    80000a18:	fe9518e3          	bne	a0,s1,80000a08 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1c:	00010497          	auipc	s1,0x10
    80000a20:	12c48493          	add	s1,s1,300 # 80010b48 <uart_tx_lock>
    80000a24:	8526                	mv	a0,s1
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	212080e7          	jalr	530(ra) # 80000c38 <acquire>
  uartstart();
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	e60080e7          	jalr	-416(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	2b4080e7          	jalr	692(ra) # 80000cec <release>
}
    80000a40:	60e2                	ld	ra,24(sp)
    80000a42:	6442                	ld	s0,16(sp)
    80000a44:	64a2                	ld	s1,8(sp)
    80000a46:	6105                	add	sp,sp,32
    80000a48:	8082                	ret

0000000080000a4a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4a:	1101                	add	sp,sp,-32
    80000a4c:	ec06                	sd	ra,24(sp)
    80000a4e:	e822                	sd	s0,16(sp)
    80000a50:	e426                	sd	s1,8(sp)
    80000a52:	e04a                	sd	s2,0(sp)
    80000a54:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a56:	03451793          	sll	a5,a0,0x34
    80000a5a:	ebb9                	bnez	a5,80000ab0 <kfree+0x66>
    80000a5c:	84aa                	mv	s1,a0
    80000a5e:	00021797          	auipc	a5,0x21
    80000a62:	35278793          	add	a5,a5,850 # 80021db0 <end>
    80000a66:	04f56563          	bltu	a0,a5,80000ab0 <kfree+0x66>
    80000a6a:	47c5                	li	a5,17
    80000a6c:	07ee                	sll	a5,a5,0x1b
    80000a6e:	04f57163          	bgeu	a0,a5,80000ab0 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a72:	6605                	lui	a2,0x1
    80000a74:	4585                	li	a1,1
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	2be080e7          	jalr	702(ra) # 80000d34 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a7e:	00010917          	auipc	s2,0x10
    80000a82:	10290913          	add	s2,s2,258 # 80010b80 <kmem>
    80000a86:	854a                	mv	a0,s2
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	1b0080e7          	jalr	432(ra) # 80000c38 <acquire>
  r->next = kmem.freelist;
    80000a90:	01893783          	ld	a5,24(s2)
    80000a94:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a96:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	00000097          	auipc	ra,0x0
    80000aa0:	250080e7          	jalr	592(ra) # 80000cec <release>
}
    80000aa4:	60e2                	ld	ra,24(sp)
    80000aa6:	6442                	ld	s0,16(sp)
    80000aa8:	64a2                	ld	s1,8(sp)
    80000aaa:	6902                	ld	s2,0(sp)
    80000aac:	6105                	add	sp,sp,32
    80000aae:	8082                	ret
    panic("kfree");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	59050513          	add	a0,a0,1424 # 80008040 <etext+0x40>
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	aa8080e7          	jalr	-1368(ra) # 80000560 <panic>

0000000080000ac0 <freerange>:
{
    80000ac0:	7179                	add	sp,sp,-48
    80000ac2:	f406                	sd	ra,40(sp)
    80000ac4:	f022                	sd	s0,32(sp)
    80000ac6:	ec26                	sd	s1,24(sp)
    80000ac8:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aca:	6785                	lui	a5,0x1
    80000acc:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad0:	00e504b3          	add	s1,a0,a4
    80000ad4:	777d                	lui	a4,0xfffff
    80000ad6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad8:	94be                	add	s1,s1,a5
    80000ada:	0295e463          	bltu	a1,s1,80000b02 <freerange+0x42>
    80000ade:	e84a                	sd	s2,16(sp)
    80000ae0:	e44e                	sd	s3,8(sp)
    80000ae2:	e052                	sd	s4,0(sp)
    80000ae4:	892e                	mv	s2,a1
    kfree(p);
    80000ae6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae8:	6985                	lui	s3,0x1
    kfree(p);
    80000aea:	01448533          	add	a0,s1,s4
    80000aee:	00000097          	auipc	ra,0x0
    80000af2:	f5c080e7          	jalr	-164(ra) # 80000a4a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af6:	94ce                	add	s1,s1,s3
    80000af8:	fe9979e3          	bgeu	s2,s1,80000aea <freerange+0x2a>
    80000afc:	6942                	ld	s2,16(sp)
    80000afe:	69a2                	ld	s3,8(sp)
    80000b00:	6a02                	ld	s4,0(sp)
}
    80000b02:	70a2                	ld	ra,40(sp)
    80000b04:	7402                	ld	s0,32(sp)
    80000b06:	64e2                	ld	s1,24(sp)
    80000b08:	6145                	add	sp,sp,48
    80000b0a:	8082                	ret

0000000080000b0c <kinit>:
{
    80000b0c:	1141                	add	sp,sp,-16
    80000b0e:	e406                	sd	ra,8(sp)
    80000b10:	e022                	sd	s0,0(sp)
    80000b12:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b14:	00007597          	auipc	a1,0x7
    80000b18:	53458593          	add	a1,a1,1332 # 80008048 <etext+0x48>
    80000b1c:	00010517          	auipc	a0,0x10
    80000b20:	06450513          	add	a0,a0,100 # 80010b80 <kmem>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	084080e7          	jalr	132(ra) # 80000ba8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	sll	a1,a1,0x1b
    80000b30:	00021517          	auipc	a0,0x21
    80000b34:	28050513          	add	a0,a0,640 # 80021db0 <end>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	f88080e7          	jalr	-120(ra) # 80000ac0 <freerange>
}
    80000b40:	60a2                	ld	ra,8(sp)
    80000b42:	6402                	ld	s0,0(sp)
    80000b44:	0141                	add	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b48:	1101                	add	sp,sp,-32
    80000b4a:	ec06                	sd	ra,24(sp)
    80000b4c:	e822                	sd	s0,16(sp)
    80000b4e:	e426                	sd	s1,8(sp)
    80000b50:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b52:	00010497          	auipc	s1,0x10
    80000b56:	02e48493          	add	s1,s1,46 # 80010b80 <kmem>
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	0dc080e7          	jalr	220(ra) # 80000c38 <acquire>
  r = kmem.freelist;
    80000b64:	6c84                	ld	s1,24(s1)
  if(r)
    80000b66:	c885                	beqz	s1,80000b96 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b68:	609c                	ld	a5,0(s1)
    80000b6a:	00010517          	auipc	a0,0x10
    80000b6e:	01650513          	add	a0,a0,22 # 80010b80 <kmem>
    80000b72:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	178080e7          	jalr	376(ra) # 80000cec <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7c:	6605                	lui	a2,0x1
    80000b7e:	4595                	li	a1,5
    80000b80:	8526                	mv	a0,s1
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	1b2080e7          	jalr	434(ra) # 80000d34 <memset>
  return (void*)r;
}
    80000b8a:	8526                	mv	a0,s1
    80000b8c:	60e2                	ld	ra,24(sp)
    80000b8e:	6442                	ld	s0,16(sp)
    80000b90:	64a2                	ld	s1,8(sp)
    80000b92:	6105                	add	sp,sp,32
    80000b94:	8082                	ret
  release(&kmem.lock);
    80000b96:	00010517          	auipc	a0,0x10
    80000b9a:	fea50513          	add	a0,a0,-22 # 80010b80 <kmem>
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	14e080e7          	jalr	334(ra) # 80000cec <release>
  if(r)
    80000ba6:	b7d5                	j	80000b8a <kalloc+0x42>

0000000080000ba8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba8:	1141                	add	sp,sp,-16
    80000baa:	e422                	sd	s0,8(sp)
    80000bac:	0800                	add	s0,sp,16
  lk->name = name;
    80000bae:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb4:	00053823          	sd	zero,16(a0)
}
    80000bb8:	6422                	ld	s0,8(sp)
    80000bba:	0141                	add	sp,sp,16
    80000bbc:	8082                	ret

0000000080000bbe <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bbe:	411c                	lw	a5,0(a0)
    80000bc0:	e399                	bnez	a5,80000bc6 <holding+0x8>
    80000bc2:	4501                	li	a0,0
  return r;
}
    80000bc4:	8082                	ret
{
    80000bc6:	1101                	add	sp,sp,-32
    80000bc8:	ec06                	sd	ra,24(sp)
    80000bca:	e822                	sd	s0,16(sp)
    80000bcc:	e426                	sd	s1,8(sp)
    80000bce:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd0:	6904                	ld	s1,16(a0)
    80000bd2:	00001097          	auipc	ra,0x1
    80000bd6:	e5c080e7          	jalr	-420(ra) # 80001a2e <mycpu>
    80000bda:	40a48533          	sub	a0,s1,a0
    80000bde:	00153513          	seqz	a0,a0
}
    80000be2:	60e2                	ld	ra,24(sp)
    80000be4:	6442                	ld	s0,16(sp)
    80000be6:	64a2                	ld	s1,8(sp)
    80000be8:	6105                	add	sp,sp,32
    80000bea:	8082                	ret

0000000080000bec <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bec:	1101                	add	sp,sp,-32
    80000bee:	ec06                	sd	ra,24(sp)
    80000bf0:	e822                	sd	s0,16(sp)
    80000bf2:	e426                	sd	s1,8(sp)
    80000bf4:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf6:	100024f3          	csrr	s1,sstatus
    80000bfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bfe:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c00:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c04:	00001097          	auipc	ra,0x1
    80000c08:	e2a080e7          	jalr	-470(ra) # 80001a2e <mycpu>
    80000c0c:	5d3c                	lw	a5,120(a0)
    80000c0e:	cf89                	beqz	a5,80000c28 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	e1e080e7          	jalr	-482(ra) # 80001a2e <mycpu>
    80000c18:	5d3c                	lw	a5,120(a0)
    80000c1a:	2785                	addw	a5,a5,1
    80000c1c:	dd3c                	sw	a5,120(a0)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	add	sp,sp,32
    80000c26:	8082                	ret
    mycpu()->intena = old;
    80000c28:	00001097          	auipc	ra,0x1
    80000c2c:	e06080e7          	jalr	-506(ra) # 80001a2e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c30:	8085                	srl	s1,s1,0x1
    80000c32:	8885                	and	s1,s1,1
    80000c34:	dd64                	sw	s1,124(a0)
    80000c36:	bfe9                	j	80000c10 <push_off+0x24>

0000000080000c38 <acquire>:
{
    80000c38:	1101                	add	sp,sp,-32
    80000c3a:	ec06                	sd	ra,24(sp)
    80000c3c:	e822                	sd	s0,16(sp)
    80000c3e:	e426                	sd	s1,8(sp)
    80000c40:	1000                	add	s0,sp,32
    80000c42:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c44:	00000097          	auipc	ra,0x0
    80000c48:	fa8080e7          	jalr	-88(ra) # 80000bec <push_off>
  if(holding(lk))
    80000c4c:	8526                	mv	a0,s1
    80000c4e:	00000097          	auipc	ra,0x0
    80000c52:	f70080e7          	jalr	-144(ra) # 80000bbe <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c56:	4705                	li	a4,1
  if(holding(lk))
    80000c58:	e115                	bnez	a0,80000c7c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c5a:	87ba                	mv	a5,a4
    80000c5c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c60:	2781                	sext.w	a5,a5
    80000c62:	ffe5                	bnez	a5,80000c5a <acquire+0x22>
  __sync_synchronize();
    80000c64:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c68:	00001097          	auipc	ra,0x1
    80000c6c:	dc6080e7          	jalr	-570(ra) # 80001a2e <mycpu>
    80000c70:	e888                	sd	a0,16(s1)
}
    80000c72:	60e2                	ld	ra,24(sp)
    80000c74:	6442                	ld	s0,16(sp)
    80000c76:	64a2                	ld	s1,8(sp)
    80000c78:	6105                	add	sp,sp,32
    80000c7a:	8082                	ret
    panic("acquire");
    80000c7c:	00007517          	auipc	a0,0x7
    80000c80:	3d450513          	add	a0,a0,980 # 80008050 <etext+0x50>
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	8dc080e7          	jalr	-1828(ra) # 80000560 <panic>

0000000080000c8c <pop_off>:

void
pop_off(void)
{
    80000c8c:	1141                	add	sp,sp,-16
    80000c8e:	e406                	sd	ra,8(sp)
    80000c90:	e022                	sd	s0,0(sp)
    80000c92:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c94:	00001097          	auipc	ra,0x1
    80000c98:	d9a080e7          	jalr	-614(ra) # 80001a2e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ca0:	8b89                	and	a5,a5,2
  if(intr_get())
    80000ca2:	e78d                	bnez	a5,80000ccc <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ca4:	5d3c                	lw	a5,120(a0)
    80000ca6:	02f05b63          	blez	a5,80000cdc <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000caa:	37fd                	addw	a5,a5,-1
    80000cac:	0007871b          	sext.w	a4,a5
    80000cb0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb2:	eb09                	bnez	a4,80000cc4 <pop_off+0x38>
    80000cb4:	5d7c                	lw	a5,124(a0)
    80000cb6:	c799                	beqz	a5,80000cc4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cbc:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc4:	60a2                	ld	ra,8(sp)
    80000cc6:	6402                	ld	s0,0(sp)
    80000cc8:	0141                	add	sp,sp,16
    80000cca:	8082                	ret
    panic("pop_off - interruptible");
    80000ccc:	00007517          	auipc	a0,0x7
    80000cd0:	38c50513          	add	a0,a0,908 # 80008058 <etext+0x58>
    80000cd4:	00000097          	auipc	ra,0x0
    80000cd8:	88c080e7          	jalr	-1908(ra) # 80000560 <panic>
    panic("pop_off");
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	39450513          	add	a0,a0,916 # 80008070 <etext+0x70>
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	87c080e7          	jalr	-1924(ra) # 80000560 <panic>

0000000080000cec <release>:
{
    80000cec:	1101                	add	sp,sp,-32
    80000cee:	ec06                	sd	ra,24(sp)
    80000cf0:	e822                	sd	s0,16(sp)
    80000cf2:	e426                	sd	s1,8(sp)
    80000cf4:	1000                	add	s0,sp,32
    80000cf6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	ec6080e7          	jalr	-314(ra) # 80000bbe <holding>
    80000d00:	c115                	beqz	a0,80000d24 <release+0x38>
  lk->cpu = 0;
    80000d02:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d06:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d0a:	0f50000f          	fence	iorw,ow
    80000d0e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	f7a080e7          	jalr	-134(ra) # 80000c8c <pop_off>
}
    80000d1a:	60e2                	ld	ra,24(sp)
    80000d1c:	6442                	ld	s0,16(sp)
    80000d1e:	64a2                	ld	s1,8(sp)
    80000d20:	6105                	add	sp,sp,32
    80000d22:	8082                	ret
    panic("release");
    80000d24:	00007517          	auipc	a0,0x7
    80000d28:	35450513          	add	a0,a0,852 # 80008078 <etext+0x78>
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	834080e7          	jalr	-1996(ra) # 80000560 <panic>

0000000080000d34 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d34:	1141                	add	sp,sp,-16
    80000d36:	e422                	sd	s0,8(sp)
    80000d38:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d3a:	ca19                	beqz	a2,80000d50 <memset+0x1c>
    80000d3c:	87aa                	mv	a5,a0
    80000d3e:	1602                	sll	a2,a2,0x20
    80000d40:	9201                	srl	a2,a2,0x20
    80000d42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d4a:	0785                	add	a5,a5,1
    80000d4c:	fee79de3          	bne	a5,a4,80000d46 <memset+0x12>
  }
  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	add	sp,sp,16
    80000d54:	8082                	ret

0000000080000d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d56:	1141                	add	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d5c:	ca05                	beqz	a2,80000d8c <memcmp+0x36>
    80000d5e:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d62:	1682                	sll	a3,a3,0x20
    80000d64:	9281                	srl	a3,a3,0x20
    80000d66:	0685                	add	a3,a3,1
    80000d68:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d6a:	00054783          	lbu	a5,0(a0)
    80000d6e:	0005c703          	lbu	a4,0(a1)
    80000d72:	00e79863          	bne	a5,a4,80000d82 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d76:	0505                	add	a0,a0,1
    80000d78:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d7a:	fed518e3          	bne	a0,a3,80000d6a <memcmp+0x14>
  }

  return 0;
    80000d7e:	4501                	li	a0,0
    80000d80:	a019                	j	80000d86 <memcmp+0x30>
      return *s1 - *s2;
    80000d82:	40e7853b          	subw	a0,a5,a4
}
    80000d86:	6422                	ld	s0,8(sp)
    80000d88:	0141                	add	sp,sp,16
    80000d8a:	8082                	ret
  return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	bfe5                	j	80000d86 <memcmp+0x30>

0000000080000d90 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d90:	1141                	add	sp,sp,-16
    80000d92:	e422                	sd	s0,8(sp)
    80000d94:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d96:	c205                	beqz	a2,80000db6 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d98:	02a5e263          	bltu	a1,a0,80000dbc <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d9c:	1602                	sll	a2,a2,0x20
    80000d9e:	9201                	srl	a2,a2,0x20
    80000da0:	00c587b3          	add	a5,a1,a2
{
    80000da4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da6:	0585                	add	a1,a1,1
    80000da8:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd251>
    80000daa:	fff5c683          	lbu	a3,-1(a1)
    80000dae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000db2:	feb79ae3          	bne	a5,a1,80000da6 <memmove+0x16>

  return dst;
}
    80000db6:	6422                	ld	s0,8(sp)
    80000db8:	0141                	add	sp,sp,16
    80000dba:	8082                	ret
  if(s < d && s + n > d){
    80000dbc:	02061693          	sll	a3,a2,0x20
    80000dc0:	9281                	srl	a3,a3,0x20
    80000dc2:	00d58733          	add	a4,a1,a3
    80000dc6:	fce57be3          	bgeu	a0,a4,80000d9c <memmove+0xc>
    d += n;
    80000dca:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dcc:	fff6079b          	addw	a5,a2,-1
    80000dd0:	1782                	sll	a5,a5,0x20
    80000dd2:	9381                	srl	a5,a5,0x20
    80000dd4:	fff7c793          	not	a5,a5
    80000dd8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dda:	177d                	add	a4,a4,-1
    80000ddc:	16fd                	add	a3,a3,-1
    80000dde:	00074603          	lbu	a2,0(a4)
    80000de2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de6:	fef71ae3          	bne	a4,a5,80000dda <memmove+0x4a>
    80000dea:	b7f1                	j	80000db6 <memmove+0x26>

0000000080000dec <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dec:	1141                	add	sp,sp,-16
    80000dee:	e406                	sd	ra,8(sp)
    80000df0:	e022                	sd	s0,0(sp)
    80000df2:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000df4:	00000097          	auipc	ra,0x0
    80000df8:	f9c080e7          	jalr	-100(ra) # 80000d90 <memmove>
}
    80000dfc:	60a2                	ld	ra,8(sp)
    80000dfe:	6402                	ld	s0,0(sp)
    80000e00:	0141                	add	sp,sp,16
    80000e02:	8082                	ret

0000000080000e04 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e04:	1141                	add	sp,sp,-16
    80000e06:	e422                	sd	s0,8(sp)
    80000e08:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e0a:	ce11                	beqz	a2,80000e26 <strncmp+0x22>
    80000e0c:	00054783          	lbu	a5,0(a0)
    80000e10:	cf89                	beqz	a5,80000e2a <strncmp+0x26>
    80000e12:	0005c703          	lbu	a4,0(a1)
    80000e16:	00f71a63          	bne	a4,a5,80000e2a <strncmp+0x26>
    n--, p++, q++;
    80000e1a:	367d                	addw	a2,a2,-1
    80000e1c:	0505                	add	a0,a0,1
    80000e1e:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e20:	f675                	bnez	a2,80000e0c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e22:	4501                	li	a0,0
    80000e24:	a801                	j	80000e34 <strncmp+0x30>
    80000e26:	4501                	li	a0,0
    80000e28:	a031                	j	80000e34 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e2a:	00054503          	lbu	a0,0(a0)
    80000e2e:	0005c783          	lbu	a5,0(a1)
    80000e32:	9d1d                	subw	a0,a0,a5
}
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	add	sp,sp,16
    80000e38:	8082                	ret

0000000080000e3a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e3a:	1141                	add	sp,sp,-16
    80000e3c:	e422                	sd	s0,8(sp)
    80000e3e:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e40:	87aa                	mv	a5,a0
    80000e42:	86b2                	mv	a3,a2
    80000e44:	367d                	addw	a2,a2,-1
    80000e46:	02d05563          	blez	a3,80000e70 <strncpy+0x36>
    80000e4a:	0785                	add	a5,a5,1
    80000e4c:	0005c703          	lbu	a4,0(a1)
    80000e50:	fee78fa3          	sb	a4,-1(a5)
    80000e54:	0585                	add	a1,a1,1
    80000e56:	f775                	bnez	a4,80000e42 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e58:	873e                	mv	a4,a5
    80000e5a:	9fb5                	addw	a5,a5,a3
    80000e5c:	37fd                	addw	a5,a5,-1
    80000e5e:	00c05963          	blez	a2,80000e70 <strncpy+0x36>
    *s++ = 0;
    80000e62:	0705                	add	a4,a4,1
    80000e64:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e68:	40e786bb          	subw	a3,a5,a4
    80000e6c:	fed04be3          	bgtz	a3,80000e62 <strncpy+0x28>
  return os;
}
    80000e70:	6422                	ld	s0,8(sp)
    80000e72:	0141                	add	sp,sp,16
    80000e74:	8082                	ret

0000000080000e76 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e76:	1141                	add	sp,sp,-16
    80000e78:	e422                	sd	s0,8(sp)
    80000e7a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e7c:	02c05363          	blez	a2,80000ea2 <safestrcpy+0x2c>
    80000e80:	fff6069b          	addw	a3,a2,-1
    80000e84:	1682                	sll	a3,a3,0x20
    80000e86:	9281                	srl	a3,a3,0x20
    80000e88:	96ae                	add	a3,a3,a1
    80000e8a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e8c:	00d58963          	beq	a1,a3,80000e9e <safestrcpy+0x28>
    80000e90:	0585                	add	a1,a1,1
    80000e92:	0785                	add	a5,a5,1
    80000e94:	fff5c703          	lbu	a4,-1(a1)
    80000e98:	fee78fa3          	sb	a4,-1(a5)
    80000e9c:	fb65                	bnez	a4,80000e8c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e9e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ea2:	6422                	ld	s0,8(sp)
    80000ea4:	0141                	add	sp,sp,16
    80000ea6:	8082                	ret

0000000080000ea8 <strlen>:

int
strlen(const char *s)
{
    80000ea8:	1141                	add	sp,sp,-16
    80000eaa:	e422                	sd	s0,8(sp)
    80000eac:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eae:	00054783          	lbu	a5,0(a0)
    80000eb2:	cf91                	beqz	a5,80000ece <strlen+0x26>
    80000eb4:	0505                	add	a0,a0,1
    80000eb6:	87aa                	mv	a5,a0
    80000eb8:	86be                	mv	a3,a5
    80000eba:	0785                	add	a5,a5,1
    80000ebc:	fff7c703          	lbu	a4,-1(a5)
    80000ec0:	ff65                	bnez	a4,80000eb8 <strlen+0x10>
    80000ec2:	40a6853b          	subw	a0,a3,a0
    80000ec6:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000ec8:	6422                	ld	s0,8(sp)
    80000eca:	0141                	add	sp,sp,16
    80000ecc:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ece:	4501                	li	a0,0
    80000ed0:	bfe5                	j	80000ec8 <strlen+0x20>

0000000080000ed2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ed2:	1141                	add	sp,sp,-16
    80000ed4:	e406                	sd	ra,8(sp)
    80000ed6:	e022                	sd	s0,0(sp)
    80000ed8:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	b44080e7          	jalr	-1212(ra) # 80001a1e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ee2:	00008717          	auipc	a4,0x8
    80000ee6:	a3670713          	add	a4,a4,-1482 # 80008918 <started>
  if(cpuid() == 0){
    80000eea:	c139                	beqz	a0,80000f30 <main+0x5e>
    while(started == 0)
    80000eec:	431c                	lw	a5,0(a4)
    80000eee:	2781                	sext.w	a5,a5
    80000ef0:	dff5                	beqz	a5,80000eec <main+0x1a>
      ;
    __sync_synchronize();
    80000ef2:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ef6:	00001097          	auipc	ra,0x1
    80000efa:	b28080e7          	jalr	-1240(ra) # 80001a1e <cpuid>
    80000efe:	85aa                	mv	a1,a0
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	19850513          	add	a0,a0,408 # 80008098 <etext+0x98>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	6a2080e7          	jalr	1698(ra) # 800005aa <printf>
    kvminithart();    // turn on paging
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	0d8080e7          	jalr	216(ra) # 80000fe8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f18:	00002097          	auipc	ra,0x2
    80000f1c:	8aa080e7          	jalr	-1878(ra) # 800027c2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f20:	00005097          	auipc	ra,0x5
    80000f24:	f34080e7          	jalr	-204(ra) # 80005e54 <plicinithart>
  }

  scheduler();        
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	01a080e7          	jalr	26(ra) # 80001f42 <scheduler>
    consoleinit();
    80000f30:	fffff097          	auipc	ra,0xfffff
    80000f34:	540080e7          	jalr	1344(ra) # 80000470 <consoleinit>
    printfinit();
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	87a080e7          	jalr	-1926(ra) # 800007b2 <printfinit>
    printf("\n");
    80000f40:	00007517          	auipc	a0,0x7
    80000f44:	0d050513          	add	a0,a0,208 # 80008010 <etext+0x10>
    80000f48:	fffff097          	auipc	ra,0xfffff
    80000f4c:	662080e7          	jalr	1634(ra) # 800005aa <printf>
    printf("xv6 kernel is booting\n");
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	13050513          	add	a0,a0,304 # 80008080 <etext+0x80>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	652080e7          	jalr	1618(ra) # 800005aa <printf>
    printf("\n");
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	0b050513          	add	a0,a0,176 # 80008010 <etext+0x10>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	642080e7          	jalr	1602(ra) # 800005aa <printf>
    kinit();         // physical page allocator
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	b9c080e7          	jalr	-1124(ra) # 80000b0c <kinit>
    kvminit();       // create kernel page table
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	326080e7          	jalr	806(ra) # 8000129e <kvminit>
    kvminithart();   // turn on paging
    80000f80:	00000097          	auipc	ra,0x0
    80000f84:	068080e7          	jalr	104(ra) # 80000fe8 <kvminithart>
    procinit();      // process table
    80000f88:	00001097          	auipc	ra,0x1
    80000f8c:	9d4080e7          	jalr	-1580(ra) # 8000195c <procinit>
    trapinit();      // trap vectors
    80000f90:	00002097          	auipc	ra,0x2
    80000f94:	80a080e7          	jalr	-2038(ra) # 8000279a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	00002097          	auipc	ra,0x2
    80000f9c:	82a080e7          	jalr	-2006(ra) # 800027c2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fa0:	00005097          	auipc	ra,0x5
    80000fa4:	e9a080e7          	jalr	-358(ra) # 80005e3a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa8:	00005097          	auipc	ra,0x5
    80000fac:	eac080e7          	jalr	-340(ra) # 80005e54 <plicinithart>
    binit();         // buffer cache
    80000fb0:	00002097          	auipc	ra,0x2
    80000fb4:	f74080e7          	jalr	-140(ra) # 80002f24 <binit>
    iinit();         // inode table
    80000fb8:	00002097          	auipc	ra,0x2
    80000fbc:	62a080e7          	jalr	1578(ra) # 800035e2 <iinit>
    fileinit();      // file table
    80000fc0:	00003097          	auipc	ra,0x3
    80000fc4:	5da080e7          	jalr	1498(ra) # 8000459a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	f94080e7          	jalr	-108(ra) # 80005f5c <virtio_disk_init>
    userinit();      // first user process
    80000fd0:	00001097          	auipc	ra,0x1
    80000fd4:	d52080e7          	jalr	-686(ra) # 80001d22 <userinit>
    __sync_synchronize();
    80000fd8:	0ff0000f          	fence
    started = 1;
    80000fdc:	4785                	li	a5,1
    80000fde:	00008717          	auipc	a4,0x8
    80000fe2:	92f72d23          	sw	a5,-1734(a4) # 80008918 <started>
    80000fe6:	b789                	j	80000f28 <main+0x56>

0000000080000fe8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fe8:	1141                	add	sp,sp,-16
    80000fea:	e422                	sd	s0,8(sp)
    80000fec:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ff2:	00008797          	auipc	a5,0x8
    80000ff6:	92e7b783          	ld	a5,-1746(a5) # 80008920 <kernel_pagetable>
    80000ffa:	83b1                	srl	a5,a5,0xc
    80000ffc:	577d                	li	a4,-1
    80000ffe:	177e                	sll	a4,a4,0x3f
    80001000:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001002:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001006:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000100a:	6422                	ld	s0,8(sp)
    8000100c:	0141                	add	sp,sp,16
    8000100e:	8082                	ret

0000000080001010 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001010:	7139                	add	sp,sp,-64
    80001012:	fc06                	sd	ra,56(sp)
    80001014:	f822                	sd	s0,48(sp)
    80001016:	f426                	sd	s1,40(sp)
    80001018:	f04a                	sd	s2,32(sp)
    8000101a:	ec4e                	sd	s3,24(sp)
    8000101c:	e852                	sd	s4,16(sp)
    8000101e:	e456                	sd	s5,8(sp)
    80001020:	e05a                	sd	s6,0(sp)
    80001022:	0080                	add	s0,sp,64
    80001024:	84aa                	mv	s1,a0
    80001026:	89ae                	mv	s3,a1
    80001028:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000102a:	57fd                	li	a5,-1
    8000102c:	83e9                	srl	a5,a5,0x1a
    8000102e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001030:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001032:	04b7f263          	bgeu	a5,a1,80001076 <walk+0x66>
    panic("walk");
    80001036:	00007517          	auipc	a0,0x7
    8000103a:	07a50513          	add	a0,a0,122 # 800080b0 <etext+0xb0>
    8000103e:	fffff097          	auipc	ra,0xfffff
    80001042:	522080e7          	jalr	1314(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001046:	060a8663          	beqz	s5,800010b2 <walk+0xa2>
    8000104a:	00000097          	auipc	ra,0x0
    8000104e:	afe080e7          	jalr	-1282(ra) # 80000b48 <kalloc>
    80001052:	84aa                	mv	s1,a0
    80001054:	c529                	beqz	a0,8000109e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001056:	6605                	lui	a2,0x1
    80001058:	4581                	li	a1,0
    8000105a:	00000097          	auipc	ra,0x0
    8000105e:	cda080e7          	jalr	-806(ra) # 80000d34 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001062:	00c4d793          	srl	a5,s1,0xc
    80001066:	07aa                	sll	a5,a5,0xa
    80001068:	0017e793          	or	a5,a5,1
    8000106c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001070:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd247>
    80001072:	036a0063          	beq	s4,s6,80001092 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001076:	0149d933          	srl	s2,s3,s4
    8000107a:	1ff97913          	and	s2,s2,511
    8000107e:	090e                	sll	s2,s2,0x3
    80001080:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001082:	00093483          	ld	s1,0(s2)
    80001086:	0014f793          	and	a5,s1,1
    8000108a:	dfd5                	beqz	a5,80001046 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000108c:	80a9                	srl	s1,s1,0xa
    8000108e:	04b2                	sll	s1,s1,0xc
    80001090:	b7c5                	j	80001070 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001092:	00c9d513          	srl	a0,s3,0xc
    80001096:	1ff57513          	and	a0,a0,511
    8000109a:	050e                	sll	a0,a0,0x3
    8000109c:	9526                	add	a0,a0,s1
}
    8000109e:	70e2                	ld	ra,56(sp)
    800010a0:	7442                	ld	s0,48(sp)
    800010a2:	74a2                	ld	s1,40(sp)
    800010a4:	7902                	ld	s2,32(sp)
    800010a6:	69e2                	ld	s3,24(sp)
    800010a8:	6a42                	ld	s4,16(sp)
    800010aa:	6aa2                	ld	s5,8(sp)
    800010ac:	6b02                	ld	s6,0(sp)
    800010ae:	6121                	add	sp,sp,64
    800010b0:	8082                	ret
        return 0;
    800010b2:	4501                	li	a0,0
    800010b4:	b7ed                	j	8000109e <walk+0x8e>

00000000800010b6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010b6:	57fd                	li	a5,-1
    800010b8:	83e9                	srl	a5,a5,0x1a
    800010ba:	00b7f463          	bgeu	a5,a1,800010c2 <walkaddr+0xc>
    return 0;
    800010be:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010c0:	8082                	ret
{
    800010c2:	1141                	add	sp,sp,-16
    800010c4:	e406                	sd	ra,8(sp)
    800010c6:	e022                	sd	s0,0(sp)
    800010c8:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ca:	4601                	li	a2,0
    800010cc:	00000097          	auipc	ra,0x0
    800010d0:	f44080e7          	jalr	-188(ra) # 80001010 <walk>
  if(pte == 0)
    800010d4:	c105                	beqz	a0,800010f4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010d6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010d8:	0117f693          	and	a3,a5,17
    800010dc:	4745                	li	a4,17
    return 0;
    800010de:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010e0:	00e68663          	beq	a3,a4,800010ec <walkaddr+0x36>
}
    800010e4:	60a2                	ld	ra,8(sp)
    800010e6:	6402                	ld	s0,0(sp)
    800010e8:	0141                	add	sp,sp,16
    800010ea:	8082                	ret
  pa = PTE2PA(*pte);
    800010ec:	83a9                	srl	a5,a5,0xa
    800010ee:	00c79513          	sll	a0,a5,0xc
  return pa;
    800010f2:	bfcd                	j	800010e4 <walkaddr+0x2e>
    return 0;
    800010f4:	4501                	li	a0,0
    800010f6:	b7fd                	j	800010e4 <walkaddr+0x2e>

00000000800010f8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010f8:	715d                	add	sp,sp,-80
    800010fa:	e486                	sd	ra,72(sp)
    800010fc:	e0a2                	sd	s0,64(sp)
    800010fe:	fc26                	sd	s1,56(sp)
    80001100:	f84a                	sd	s2,48(sp)
    80001102:	f44e                	sd	s3,40(sp)
    80001104:	f052                	sd	s4,32(sp)
    80001106:	ec56                	sd	s5,24(sp)
    80001108:	e85a                	sd	s6,16(sp)
    8000110a:	e45e                	sd	s7,8(sp)
    8000110c:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000110e:	c639                	beqz	a2,8000115c <mappages+0x64>
    80001110:	8aaa                	mv	s5,a0
    80001112:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001114:	777d                	lui	a4,0xfffff
    80001116:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000111a:	fff58993          	add	s3,a1,-1
    8000111e:	99b2                	add	s3,s3,a2
    80001120:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001124:	893e                	mv	s2,a5
    80001126:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000112a:	6b85                	lui	s7,0x1
    8000112c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001130:	4605                	li	a2,1
    80001132:	85ca                	mv	a1,s2
    80001134:	8556                	mv	a0,s5
    80001136:	00000097          	auipc	ra,0x0
    8000113a:	eda080e7          	jalr	-294(ra) # 80001010 <walk>
    8000113e:	cd1d                	beqz	a0,8000117c <mappages+0x84>
    if(*pte & PTE_V)
    80001140:	611c                	ld	a5,0(a0)
    80001142:	8b85                	and	a5,a5,1
    80001144:	e785                	bnez	a5,8000116c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001146:	80b1                	srl	s1,s1,0xc
    80001148:	04aa                	sll	s1,s1,0xa
    8000114a:	0164e4b3          	or	s1,s1,s6
    8000114e:	0014e493          	or	s1,s1,1
    80001152:	e104                	sd	s1,0(a0)
    if(a == last)
    80001154:	05390063          	beq	s2,s3,80001194 <mappages+0x9c>
    a += PGSIZE;
    80001158:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115a:	bfc9                	j	8000112c <mappages+0x34>
    panic("mappages: size");
    8000115c:	00007517          	auipc	a0,0x7
    80001160:	f5c50513          	add	a0,a0,-164 # 800080b8 <etext+0xb8>
    80001164:	fffff097          	auipc	ra,0xfffff
    80001168:	3fc080e7          	jalr	1020(ra) # 80000560 <panic>
      panic("mappages: remap");
    8000116c:	00007517          	auipc	a0,0x7
    80001170:	f5c50513          	add	a0,a0,-164 # 800080c8 <etext+0xc8>
    80001174:	fffff097          	auipc	ra,0xfffff
    80001178:	3ec080e7          	jalr	1004(ra) # 80000560 <panic>
      return -1;
    8000117c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000117e:	60a6                	ld	ra,72(sp)
    80001180:	6406                	ld	s0,64(sp)
    80001182:	74e2                	ld	s1,56(sp)
    80001184:	7942                	ld	s2,48(sp)
    80001186:	79a2                	ld	s3,40(sp)
    80001188:	7a02                	ld	s4,32(sp)
    8000118a:	6ae2                	ld	s5,24(sp)
    8000118c:	6b42                	ld	s6,16(sp)
    8000118e:	6ba2                	ld	s7,8(sp)
    80001190:	6161                	add	sp,sp,80
    80001192:	8082                	ret
  return 0;
    80001194:	4501                	li	a0,0
    80001196:	b7e5                	j	8000117e <mappages+0x86>

0000000080001198 <kvmmap>:
{
    80001198:	1141                	add	sp,sp,-16
    8000119a:	e406                	sd	ra,8(sp)
    8000119c:	e022                	sd	s0,0(sp)
    8000119e:	0800                	add	s0,sp,16
    800011a0:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011a2:	86b2                	mv	a3,a2
    800011a4:	863e                	mv	a2,a5
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	f52080e7          	jalr	-174(ra) # 800010f8 <mappages>
    800011ae:	e509                	bnez	a0,800011b8 <kvmmap+0x20>
}
    800011b0:	60a2                	ld	ra,8(sp)
    800011b2:	6402                	ld	s0,0(sp)
    800011b4:	0141                	add	sp,sp,16
    800011b6:	8082                	ret
    panic("kvmmap");
    800011b8:	00007517          	auipc	a0,0x7
    800011bc:	f2050513          	add	a0,a0,-224 # 800080d8 <etext+0xd8>
    800011c0:	fffff097          	auipc	ra,0xfffff
    800011c4:	3a0080e7          	jalr	928(ra) # 80000560 <panic>

00000000800011c8 <kvmmake>:
{
    800011c8:	1101                	add	sp,sp,-32
    800011ca:	ec06                	sd	ra,24(sp)
    800011cc:	e822                	sd	s0,16(sp)
    800011ce:	e426                	sd	s1,8(sp)
    800011d0:	e04a                	sd	s2,0(sp)
    800011d2:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	974080e7          	jalr	-1676(ra) # 80000b48 <kalloc>
    800011dc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011de:	6605                	lui	a2,0x1
    800011e0:	4581                	li	a1,0
    800011e2:	00000097          	auipc	ra,0x0
    800011e6:	b52080e7          	jalr	-1198(ra) # 80000d34 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ea:	4719                	li	a4,6
    800011ec:	6685                	lui	a3,0x1
    800011ee:	10000637          	lui	a2,0x10000
    800011f2:	100005b7          	lui	a1,0x10000
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	fa0080e7          	jalr	-96(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001200:	4719                	li	a4,6
    80001202:	6685                	lui	a3,0x1
    80001204:	10001637          	lui	a2,0x10001
    80001208:	100015b7          	lui	a1,0x10001
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f8a080e7          	jalr	-118(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001216:	4719                	li	a4,6
    80001218:	004006b7          	lui	a3,0x400
    8000121c:	0c000637          	lui	a2,0xc000
    80001220:	0c0005b7          	lui	a1,0xc000
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f72080e7          	jalr	-142(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000122e:	00007917          	auipc	s2,0x7
    80001232:	dd290913          	add	s2,s2,-558 # 80008000 <etext>
    80001236:	4729                	li	a4,10
    80001238:	80007697          	auipc	a3,0x80007
    8000123c:	dc868693          	add	a3,a3,-568 # 8000 <_entry-0x7fff8000>
    80001240:	4605                	li	a2,1
    80001242:	067e                	sll	a2,a2,0x1f
    80001244:	85b2                	mv	a1,a2
    80001246:	8526                	mv	a0,s1
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f50080e7          	jalr	-176(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001250:	46c5                	li	a3,17
    80001252:	06ee                	sll	a3,a3,0x1b
    80001254:	4719                	li	a4,6
    80001256:	412686b3          	sub	a3,a3,s2
    8000125a:	864a                	mv	a2,s2
    8000125c:	85ca                	mv	a1,s2
    8000125e:	8526                	mv	a0,s1
    80001260:	00000097          	auipc	ra,0x0
    80001264:	f38080e7          	jalr	-200(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001268:	4729                	li	a4,10
    8000126a:	6685                	lui	a3,0x1
    8000126c:	00006617          	auipc	a2,0x6
    80001270:	d9460613          	add	a2,a2,-620 # 80007000 <_trampoline>
    80001274:	040005b7          	lui	a1,0x4000
    80001278:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000127a:	05b2                	sll	a1,a1,0xc
    8000127c:	8526                	mv	a0,s1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f1a080e7          	jalr	-230(ra) # 80001198 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001286:	8526                	mv	a0,s1
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	630080e7          	jalr	1584(ra) # 800018b8 <proc_mapstacks>
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6902                	ld	s2,0(sp)
    8000129a:	6105                	add	sp,sp,32
    8000129c:	8082                	ret

000000008000129e <kvminit>:
{
    8000129e:	1141                	add	sp,sp,-16
    800012a0:	e406                	sd	ra,8(sp)
    800012a2:	e022                	sd	s0,0(sp)
    800012a4:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	f22080e7          	jalr	-222(ra) # 800011c8 <kvmmake>
    800012ae:	00007797          	auipc	a5,0x7
    800012b2:	66a7b923          	sd	a0,1650(a5) # 80008920 <kernel_pagetable>
}
    800012b6:	60a2                	ld	ra,8(sp)
    800012b8:	6402                	ld	s0,0(sp)
    800012ba:	0141                	add	sp,sp,16
    800012bc:	8082                	ret

00000000800012be <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012be:	715d                	add	sp,sp,-80
    800012c0:	e486                	sd	ra,72(sp)
    800012c2:	e0a2                	sd	s0,64(sp)
    800012c4:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c6:	03459793          	sll	a5,a1,0x34
    800012ca:	e39d                	bnez	a5,800012f0 <uvmunmap+0x32>
    800012cc:	f84a                	sd	s2,48(sp)
    800012ce:	f44e                	sd	s3,40(sp)
    800012d0:	f052                	sd	s4,32(sp)
    800012d2:	ec56                	sd	s5,24(sp)
    800012d4:	e85a                	sd	s6,16(sp)
    800012d6:	e45e                	sd	s7,8(sp)
    800012d8:	8a2a                	mv	s4,a0
    800012da:	892e                	mv	s2,a1
    800012dc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012de:	0632                	sll	a2,a2,0xc
    800012e0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012e4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e6:	6b05                	lui	s6,0x1
    800012e8:	0935fb63          	bgeu	a1,s3,8000137e <uvmunmap+0xc0>
    800012ec:	fc26                	sd	s1,56(sp)
    800012ee:	a8a9                	j	80001348 <uvmunmap+0x8a>
    800012f0:	fc26                	sd	s1,56(sp)
    800012f2:	f84a                	sd	s2,48(sp)
    800012f4:	f44e                	sd	s3,40(sp)
    800012f6:	f052                	sd	s4,32(sp)
    800012f8:	ec56                	sd	s5,24(sp)
    800012fa:	e85a                	sd	s6,16(sp)
    800012fc:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800012fe:	00007517          	auipc	a0,0x7
    80001302:	de250513          	add	a0,a0,-542 # 800080e0 <etext+0xe0>
    80001306:	fffff097          	auipc	ra,0xfffff
    8000130a:	25a080e7          	jalr	602(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    8000130e:	00007517          	auipc	a0,0x7
    80001312:	dea50513          	add	a0,a0,-534 # 800080f8 <etext+0xf8>
    80001316:	fffff097          	auipc	ra,0xfffff
    8000131a:	24a080e7          	jalr	586(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    8000131e:	00007517          	auipc	a0,0x7
    80001322:	dea50513          	add	a0,a0,-534 # 80008108 <etext+0x108>
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	23a080e7          	jalr	570(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    8000132e:	00007517          	auipc	a0,0x7
    80001332:	df250513          	add	a0,a0,-526 # 80008120 <etext+0x120>
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	22a080e7          	jalr	554(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000133e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001342:	995a                	add	s2,s2,s6
    80001344:	03397c63          	bgeu	s2,s3,8000137c <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001348:	4601                	li	a2,0
    8000134a:	85ca                	mv	a1,s2
    8000134c:	8552                	mv	a0,s4
    8000134e:	00000097          	auipc	ra,0x0
    80001352:	cc2080e7          	jalr	-830(ra) # 80001010 <walk>
    80001356:	84aa                	mv	s1,a0
    80001358:	d95d                	beqz	a0,8000130e <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    8000135a:	6108                	ld	a0,0(a0)
    8000135c:	00157793          	and	a5,a0,1
    80001360:	dfdd                	beqz	a5,8000131e <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001362:	3ff57793          	and	a5,a0,1023
    80001366:	fd7784e3          	beq	a5,s7,8000132e <uvmunmap+0x70>
    if(do_free){
    8000136a:	fc0a8ae3          	beqz	s5,8000133e <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    8000136e:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    80001370:	0532                	sll	a0,a0,0xc
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	6d8080e7          	jalr	1752(ra) # 80000a4a <kfree>
    8000137a:	b7d1                	j	8000133e <uvmunmap+0x80>
    8000137c:	74e2                	ld	s1,56(sp)
    8000137e:	7942                	ld	s2,48(sp)
    80001380:	79a2                	ld	s3,40(sp)
    80001382:	7a02                	ld	s4,32(sp)
    80001384:	6ae2                	ld	s5,24(sp)
    80001386:	6b42                	ld	s6,16(sp)
    80001388:	6ba2                	ld	s7,8(sp)
  }
}
    8000138a:	60a6                	ld	ra,72(sp)
    8000138c:	6406                	ld	s0,64(sp)
    8000138e:	6161                	add	sp,sp,80
    80001390:	8082                	ret

0000000080001392 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001392:	1101                	add	sp,sp,-32
    80001394:	ec06                	sd	ra,24(sp)
    80001396:	e822                	sd	s0,16(sp)
    80001398:	e426                	sd	s1,8(sp)
    8000139a:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000139c:	fffff097          	auipc	ra,0xfffff
    800013a0:	7ac080e7          	jalr	1964(ra) # 80000b48 <kalloc>
    800013a4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013a6:	c519                	beqz	a0,800013b4 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	988080e7          	jalr	-1656(ra) # 80000d34 <memset>
  return pagetable;
}
    800013b4:	8526                	mv	a0,s1
    800013b6:	60e2                	ld	ra,24(sp)
    800013b8:	6442                	ld	s0,16(sp)
    800013ba:	64a2                	ld	s1,8(sp)
    800013bc:	6105                	add	sp,sp,32
    800013be:	8082                	ret

00000000800013c0 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013c0:	7179                	add	sp,sp,-48
    800013c2:	f406                	sd	ra,40(sp)
    800013c4:	f022                	sd	s0,32(sp)
    800013c6:	ec26                	sd	s1,24(sp)
    800013c8:	e84a                	sd	s2,16(sp)
    800013ca:	e44e                	sd	s3,8(sp)
    800013cc:	e052                	sd	s4,0(sp)
    800013ce:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013d0:	6785                	lui	a5,0x1
    800013d2:	04f67863          	bgeu	a2,a5,80001422 <uvmfirst+0x62>
    800013d6:	8a2a                	mv	s4,a0
    800013d8:	89ae                	mv	s3,a1
    800013da:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	76c080e7          	jalr	1900(ra) # 80000b48 <kalloc>
    800013e4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013e6:	6605                	lui	a2,0x1
    800013e8:	4581                	li	a1,0
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	94a080e7          	jalr	-1718(ra) # 80000d34 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013f2:	4779                	li	a4,30
    800013f4:	86ca                	mv	a3,s2
    800013f6:	6605                	lui	a2,0x1
    800013f8:	4581                	li	a1,0
    800013fa:	8552                	mv	a0,s4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	cfc080e7          	jalr	-772(ra) # 800010f8 <mappages>
  memmove(mem, src, sz);
    80001404:	8626                	mv	a2,s1
    80001406:	85ce                	mv	a1,s3
    80001408:	854a                	mv	a0,s2
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	986080e7          	jalr	-1658(ra) # 80000d90 <memmove>
}
    80001412:	70a2                	ld	ra,40(sp)
    80001414:	7402                	ld	s0,32(sp)
    80001416:	64e2                	ld	s1,24(sp)
    80001418:	6942                	ld	s2,16(sp)
    8000141a:	69a2                	ld	s3,8(sp)
    8000141c:	6a02                	ld	s4,0(sp)
    8000141e:	6145                	add	sp,sp,48
    80001420:	8082                	ret
    panic("uvmfirst: more than a page");
    80001422:	00007517          	auipc	a0,0x7
    80001426:	d1650513          	add	a0,a0,-746 # 80008138 <etext+0x138>
    8000142a:	fffff097          	auipc	ra,0xfffff
    8000142e:	136080e7          	jalr	310(ra) # 80000560 <panic>

0000000080001432 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001432:	1101                	add	sp,sp,-32
    80001434:	ec06                	sd	ra,24(sp)
    80001436:	e822                	sd	s0,16(sp)
    80001438:	e426                	sd	s1,8(sp)
    8000143a:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000143c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000143e:	00b67d63          	bgeu	a2,a1,80001458 <uvmdealloc+0x26>
    80001442:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001444:	6785                	lui	a5,0x1
    80001446:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001448:	00f60733          	add	a4,a2,a5
    8000144c:	76fd                	lui	a3,0xfffff
    8000144e:	8f75                	and	a4,a4,a3
    80001450:	97ae                	add	a5,a5,a1
    80001452:	8ff5                	and	a5,a5,a3
    80001454:	00f76863          	bltu	a4,a5,80001464 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001458:	8526                	mv	a0,s1
    8000145a:	60e2                	ld	ra,24(sp)
    8000145c:	6442                	ld	s0,16(sp)
    8000145e:	64a2                	ld	s1,8(sp)
    80001460:	6105                	add	sp,sp,32
    80001462:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001464:	8f99                	sub	a5,a5,a4
    80001466:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001468:	4685                	li	a3,1
    8000146a:	0007861b          	sext.w	a2,a5
    8000146e:	85ba                	mv	a1,a4
    80001470:	00000097          	auipc	ra,0x0
    80001474:	e4e080e7          	jalr	-434(ra) # 800012be <uvmunmap>
    80001478:	b7c5                	j	80001458 <uvmdealloc+0x26>

000000008000147a <uvmalloc>:
  if(newsz < oldsz)
    8000147a:	0ab66b63          	bltu	a2,a1,80001530 <uvmalloc+0xb6>
{
    8000147e:	7139                	add	sp,sp,-64
    80001480:	fc06                	sd	ra,56(sp)
    80001482:	f822                	sd	s0,48(sp)
    80001484:	ec4e                	sd	s3,24(sp)
    80001486:	e852                	sd	s4,16(sp)
    80001488:	e456                	sd	s5,8(sp)
    8000148a:	0080                	add	s0,sp,64
    8000148c:	8aaa                	mv	s5,a0
    8000148e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001490:	6785                	lui	a5,0x1
    80001492:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001494:	95be                	add	a1,a1,a5
    80001496:	77fd                	lui	a5,0xfffff
    80001498:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000149c:	08c9fc63          	bgeu	s3,a2,80001534 <uvmalloc+0xba>
    800014a0:	f426                	sd	s1,40(sp)
    800014a2:	f04a                	sd	s2,32(sp)
    800014a4:	e05a                	sd	s6,0(sp)
    800014a6:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014a8:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    800014ac:	fffff097          	auipc	ra,0xfffff
    800014b0:	69c080e7          	jalr	1692(ra) # 80000b48 <kalloc>
    800014b4:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b6:	c915                	beqz	a0,800014ea <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800014b8:	6605                	lui	a2,0x1
    800014ba:	4581                	li	a1,0
    800014bc:	00000097          	auipc	ra,0x0
    800014c0:	878080e7          	jalr	-1928(ra) # 80000d34 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014c4:	875a                	mv	a4,s6
    800014c6:	86a6                	mv	a3,s1
    800014c8:	6605                	lui	a2,0x1
    800014ca:	85ca                	mv	a1,s2
    800014cc:	8556                	mv	a0,s5
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	c2a080e7          	jalr	-982(ra) # 800010f8 <mappages>
    800014d6:	ed05                	bnez	a0,8000150e <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014d8:	6785                	lui	a5,0x1
    800014da:	993e                	add	s2,s2,a5
    800014dc:	fd4968e3          	bltu	s2,s4,800014ac <uvmalloc+0x32>
  return newsz;
    800014e0:	8552                	mv	a0,s4
    800014e2:	74a2                	ld	s1,40(sp)
    800014e4:	7902                	ld	s2,32(sp)
    800014e6:	6b02                	ld	s6,0(sp)
    800014e8:	a821                	j	80001500 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800014ea:	864e                	mv	a2,s3
    800014ec:	85ca                	mv	a1,s2
    800014ee:	8556                	mv	a0,s5
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	f42080e7          	jalr	-190(ra) # 80001432 <uvmdealloc>
      return 0;
    800014f8:	4501                	li	a0,0
    800014fa:	74a2                	ld	s1,40(sp)
    800014fc:	7902                	ld	s2,32(sp)
    800014fe:	6b02                	ld	s6,0(sp)
}
    80001500:	70e2                	ld	ra,56(sp)
    80001502:	7442                	ld	s0,48(sp)
    80001504:	69e2                	ld	s3,24(sp)
    80001506:	6a42                	ld	s4,16(sp)
    80001508:	6aa2                	ld	s5,8(sp)
    8000150a:	6121                	add	sp,sp,64
    8000150c:	8082                	ret
      kfree(mem);
    8000150e:	8526                	mv	a0,s1
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	53a080e7          	jalr	1338(ra) # 80000a4a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001518:	864e                	mv	a2,s3
    8000151a:	85ca                	mv	a1,s2
    8000151c:	8556                	mv	a0,s5
    8000151e:	00000097          	auipc	ra,0x0
    80001522:	f14080e7          	jalr	-236(ra) # 80001432 <uvmdealloc>
      return 0;
    80001526:	4501                	li	a0,0
    80001528:	74a2                	ld	s1,40(sp)
    8000152a:	7902                	ld	s2,32(sp)
    8000152c:	6b02                	ld	s6,0(sp)
    8000152e:	bfc9                	j	80001500 <uvmalloc+0x86>
    return oldsz;
    80001530:	852e                	mv	a0,a1
}
    80001532:	8082                	ret
  return newsz;
    80001534:	8532                	mv	a0,a2
    80001536:	b7e9                	j	80001500 <uvmalloc+0x86>

0000000080001538 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001538:	7179                	add	sp,sp,-48
    8000153a:	f406                	sd	ra,40(sp)
    8000153c:	f022                	sd	s0,32(sp)
    8000153e:	ec26                	sd	s1,24(sp)
    80001540:	e84a                	sd	s2,16(sp)
    80001542:	e44e                	sd	s3,8(sp)
    80001544:	e052                	sd	s4,0(sp)
    80001546:	1800                	add	s0,sp,48
    80001548:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000154a:	84aa                	mv	s1,a0
    8000154c:	6905                	lui	s2,0x1
    8000154e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001550:	4985                	li	s3,1
    80001552:	a829                	j	8000156c <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001554:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001556:	00c79513          	sll	a0,a5,0xc
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	fde080e7          	jalr	-34(ra) # 80001538 <freewalk>
      pagetable[i] = 0;
    80001562:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001566:	04a1                	add	s1,s1,8
    80001568:	03248163          	beq	s1,s2,8000158a <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000156c:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000156e:	00f7f713          	and	a4,a5,15
    80001572:	ff3701e3          	beq	a4,s3,80001554 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001576:	8b85                	and	a5,a5,1
    80001578:	d7fd                	beqz	a5,80001566 <freewalk+0x2e>
      panic("freewalk: leaf");
    8000157a:	00007517          	auipc	a0,0x7
    8000157e:	bde50513          	add	a0,a0,-1058 # 80008158 <etext+0x158>
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	fde080e7          	jalr	-34(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    8000158a:	8552                	mv	a0,s4
    8000158c:	fffff097          	auipc	ra,0xfffff
    80001590:	4be080e7          	jalr	1214(ra) # 80000a4a <kfree>
}
    80001594:	70a2                	ld	ra,40(sp)
    80001596:	7402                	ld	s0,32(sp)
    80001598:	64e2                	ld	s1,24(sp)
    8000159a:	6942                	ld	s2,16(sp)
    8000159c:	69a2                	ld	s3,8(sp)
    8000159e:	6a02                	ld	s4,0(sp)
    800015a0:	6145                	add	sp,sp,48
    800015a2:	8082                	ret

00000000800015a4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015a4:	1101                	add	sp,sp,-32
    800015a6:	ec06                	sd	ra,24(sp)
    800015a8:	e822                	sd	s0,16(sp)
    800015aa:	e426                	sd	s1,8(sp)
    800015ac:	1000                	add	s0,sp,32
    800015ae:	84aa                	mv	s1,a0
  if(sz > 0)
    800015b0:	e999                	bnez	a1,800015c6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015b2:	8526                	mv	a0,s1
    800015b4:	00000097          	auipc	ra,0x0
    800015b8:	f84080e7          	jalr	-124(ra) # 80001538 <freewalk>
}
    800015bc:	60e2                	ld	ra,24(sp)
    800015be:	6442                	ld	s0,16(sp)
    800015c0:	64a2                	ld	s1,8(sp)
    800015c2:	6105                	add	sp,sp,32
    800015c4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015c6:	6785                	lui	a5,0x1
    800015c8:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015ca:	95be                	add	a1,a1,a5
    800015cc:	4685                	li	a3,1
    800015ce:	00c5d613          	srl	a2,a1,0xc
    800015d2:	4581                	li	a1,0
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	cea080e7          	jalr	-790(ra) # 800012be <uvmunmap>
    800015dc:	bfd9                	j	800015b2 <uvmfree+0xe>

00000000800015de <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015de:	c679                	beqz	a2,800016ac <uvmcopy+0xce>
{
    800015e0:	715d                	add	sp,sp,-80
    800015e2:	e486                	sd	ra,72(sp)
    800015e4:	e0a2                	sd	s0,64(sp)
    800015e6:	fc26                	sd	s1,56(sp)
    800015e8:	f84a                	sd	s2,48(sp)
    800015ea:	f44e                	sd	s3,40(sp)
    800015ec:	f052                	sd	s4,32(sp)
    800015ee:	ec56                	sd	s5,24(sp)
    800015f0:	e85a                	sd	s6,16(sp)
    800015f2:	e45e                	sd	s7,8(sp)
    800015f4:	0880                	add	s0,sp,80
    800015f6:	8b2a                	mv	s6,a0
    800015f8:	8aae                	mv	s5,a1
    800015fa:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015fc:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015fe:	4601                	li	a2,0
    80001600:	85ce                	mv	a1,s3
    80001602:	855a                	mv	a0,s6
    80001604:	00000097          	auipc	ra,0x0
    80001608:	a0c080e7          	jalr	-1524(ra) # 80001010 <walk>
    8000160c:	c531                	beqz	a0,80001658 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000160e:	6118                	ld	a4,0(a0)
    80001610:	00177793          	and	a5,a4,1
    80001614:	cbb1                	beqz	a5,80001668 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001616:	00a75593          	srl	a1,a4,0xa
    8000161a:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000161e:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001622:	fffff097          	auipc	ra,0xfffff
    80001626:	526080e7          	jalr	1318(ra) # 80000b48 <kalloc>
    8000162a:	892a                	mv	s2,a0
    8000162c:	c939                	beqz	a0,80001682 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162e:	6605                	lui	a2,0x1
    80001630:	85de                	mv	a1,s7
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	75e080e7          	jalr	1886(ra) # 80000d90 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000163a:	8726                	mv	a4,s1
    8000163c:	86ca                	mv	a3,s2
    8000163e:	6605                	lui	a2,0x1
    80001640:	85ce                	mv	a1,s3
    80001642:	8556                	mv	a0,s5
    80001644:	00000097          	auipc	ra,0x0
    80001648:	ab4080e7          	jalr	-1356(ra) # 800010f8 <mappages>
    8000164c:	e515                	bnez	a0,80001678 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000164e:	6785                	lui	a5,0x1
    80001650:	99be                	add	s3,s3,a5
    80001652:	fb49e6e3          	bltu	s3,s4,800015fe <uvmcopy+0x20>
    80001656:	a081                	j	80001696 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b1050513          	add	a0,a0,-1264 # 80008168 <etext+0x168>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	f00080e7          	jalr	-256(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001668:	00007517          	auipc	a0,0x7
    8000166c:	b2050513          	add	a0,a0,-1248 # 80008188 <etext+0x188>
    80001670:	fffff097          	auipc	ra,0xfffff
    80001674:	ef0080e7          	jalr	-272(ra) # 80000560 <panic>
      kfree(mem);
    80001678:	854a                	mv	a0,s2
    8000167a:	fffff097          	auipc	ra,0xfffff
    8000167e:	3d0080e7          	jalr	976(ra) # 80000a4a <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001682:	4685                	li	a3,1
    80001684:	00c9d613          	srl	a2,s3,0xc
    80001688:	4581                	li	a1,0
    8000168a:	8556                	mv	a0,s5
    8000168c:	00000097          	auipc	ra,0x0
    80001690:	c32080e7          	jalr	-974(ra) # 800012be <uvmunmap>
  return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6161                	add	sp,sp,80
    800016aa:	8082                	ret
  return 0;
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret

00000000800016b0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016b0:	1141                	add	sp,sp,-16
    800016b2:	e406                	sd	ra,8(sp)
    800016b4:	e022                	sd	s0,0(sp)
    800016b6:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016b8:	4601                	li	a2,0
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	956080e7          	jalr	-1706(ra) # 80001010 <walk>
  if(pte == 0)
    800016c2:	c901                	beqz	a0,800016d2 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016c4:	611c                	ld	a5,0(a0)
    800016c6:	9bbd                	and	a5,a5,-17
    800016c8:	e11c                	sd	a5,0(a0)
}
    800016ca:	60a2                	ld	ra,8(sp)
    800016cc:	6402                	ld	s0,0(sp)
    800016ce:	0141                	add	sp,sp,16
    800016d0:	8082                	ret
    panic("uvmclear");
    800016d2:	00007517          	auipc	a0,0x7
    800016d6:	ad650513          	add	a0,a0,-1322 # 800081a8 <etext+0x1a8>
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	e86080e7          	jalr	-378(ra) # 80000560 <panic>

00000000800016e2 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e2:	c6bd                	beqz	a3,80001750 <copyout+0x6e>
{
    800016e4:	715d                	add	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	e062                	sd	s8,0(sp)
    800016fa:	0880                	add	s0,sp,80
    800016fc:	8b2a                	mv	s6,a0
    800016fe:	8c2e                	mv	s8,a1
    80001700:	8a32                	mv	s4,a2
    80001702:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001704:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001706:	6a85                	lui	s5,0x1
    80001708:	a015                	j	8000172c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000170a:	9562                	add	a0,a0,s8
    8000170c:	0004861b          	sext.w	a2,s1
    80001710:	85d2                	mv	a1,s4
    80001712:	41250533          	sub	a0,a0,s2
    80001716:	fffff097          	auipc	ra,0xfffff
    8000171a:	67a080e7          	jalr	1658(ra) # 80000d90 <memmove>

    len -= n;
    8000171e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001722:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001724:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001728:	02098263          	beqz	s3,8000174c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000172c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001730:	85ca                	mv	a1,s2
    80001732:	855a                	mv	a0,s6
    80001734:	00000097          	auipc	ra,0x0
    80001738:	982080e7          	jalr	-1662(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    8000173c:	cd01                	beqz	a0,80001754 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000173e:	418904b3          	sub	s1,s2,s8
    80001742:	94d6                	add	s1,s1,s5
    if(n > len)
    80001744:	fc99f3e3          	bgeu	s3,s1,8000170a <copyout+0x28>
    80001748:	84ce                	mv	s1,s3
    8000174a:	b7c1                	j	8000170a <copyout+0x28>
  }
  return 0;
    8000174c:	4501                	li	a0,0
    8000174e:	a021                	j	80001756 <copyout+0x74>
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret
      return -1;
    80001754:	557d                	li	a0,-1
}
    80001756:	60a6                	ld	ra,72(sp)
    80001758:	6406                	ld	s0,64(sp)
    8000175a:	74e2                	ld	s1,56(sp)
    8000175c:	7942                	ld	s2,48(sp)
    8000175e:	79a2                	ld	s3,40(sp)
    80001760:	7a02                	ld	s4,32(sp)
    80001762:	6ae2                	ld	s5,24(sp)
    80001764:	6b42                	ld	s6,16(sp)
    80001766:	6ba2                	ld	s7,8(sp)
    80001768:	6c02                	ld	s8,0(sp)
    8000176a:	6161                	add	sp,sp,80
    8000176c:	8082                	ret

000000008000176e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000176e:	caa5                	beqz	a3,800017de <copyin+0x70>
{
    80001770:	715d                	add	sp,sp,-80
    80001772:	e486                	sd	ra,72(sp)
    80001774:	e0a2                	sd	s0,64(sp)
    80001776:	fc26                	sd	s1,56(sp)
    80001778:	f84a                	sd	s2,48(sp)
    8000177a:	f44e                	sd	s3,40(sp)
    8000177c:	f052                	sd	s4,32(sp)
    8000177e:	ec56                	sd	s5,24(sp)
    80001780:	e85a                	sd	s6,16(sp)
    80001782:	e45e                	sd	s7,8(sp)
    80001784:	e062                	sd	s8,0(sp)
    80001786:	0880                	add	s0,sp,80
    80001788:	8b2a                	mv	s6,a0
    8000178a:	8a2e                	mv	s4,a1
    8000178c:	8c32                	mv	s8,a2
    8000178e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001790:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001792:	6a85                	lui	s5,0x1
    80001794:	a01d                	j	800017ba <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001796:	018505b3          	add	a1,a0,s8
    8000179a:	0004861b          	sext.w	a2,s1
    8000179e:	412585b3          	sub	a1,a1,s2
    800017a2:	8552                	mv	a0,s4
    800017a4:	fffff097          	auipc	ra,0xfffff
    800017a8:	5ec080e7          	jalr	1516(ra) # 80000d90 <memmove>

    len -= n;
    800017ac:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017b0:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017b2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017b6:	02098263          	beqz	s3,800017da <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017ba:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017be:	85ca                	mv	a1,s2
    800017c0:	855a                	mv	a0,s6
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	8f4080e7          	jalr	-1804(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    800017ca:	cd01                	beqz	a0,800017e2 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017cc:	418904b3          	sub	s1,s2,s8
    800017d0:	94d6                	add	s1,s1,s5
    if(n > len)
    800017d2:	fc99f2e3          	bgeu	s3,s1,80001796 <copyin+0x28>
    800017d6:	84ce                	mv	s1,s3
    800017d8:	bf7d                	j	80001796 <copyin+0x28>
  }
  return 0;
    800017da:	4501                	li	a0,0
    800017dc:	a021                	j	800017e4 <copyin+0x76>
    800017de:	4501                	li	a0,0
}
    800017e0:	8082                	ret
      return -1;
    800017e2:	557d                	li	a0,-1
}
    800017e4:	60a6                	ld	ra,72(sp)
    800017e6:	6406                	ld	s0,64(sp)
    800017e8:	74e2                	ld	s1,56(sp)
    800017ea:	7942                	ld	s2,48(sp)
    800017ec:	79a2                	ld	s3,40(sp)
    800017ee:	7a02                	ld	s4,32(sp)
    800017f0:	6ae2                	ld	s5,24(sp)
    800017f2:	6b42                	ld	s6,16(sp)
    800017f4:	6ba2                	ld	s7,8(sp)
    800017f6:	6c02                	ld	s8,0(sp)
    800017f8:	6161                	add	sp,sp,80
    800017fa:	8082                	ret

00000000800017fc <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017fc:	cacd                	beqz	a3,800018ae <copyinstr+0xb2>
{
    800017fe:	715d                	add	sp,sp,-80
    80001800:	e486                	sd	ra,72(sp)
    80001802:	e0a2                	sd	s0,64(sp)
    80001804:	fc26                	sd	s1,56(sp)
    80001806:	f84a                	sd	s2,48(sp)
    80001808:	f44e                	sd	s3,40(sp)
    8000180a:	f052                	sd	s4,32(sp)
    8000180c:	ec56                	sd	s5,24(sp)
    8000180e:	e85a                	sd	s6,16(sp)
    80001810:	e45e                	sd	s7,8(sp)
    80001812:	0880                	add	s0,sp,80
    80001814:	8a2a                	mv	s4,a0
    80001816:	8b2e                	mv	s6,a1
    80001818:	8bb2                	mv	s7,a2
    8000181a:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000181c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000181e:	6985                	lui	s3,0x1
    80001820:	a825                	j	80001858 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001822:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001826:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001828:	37fd                	addw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000182e:	60a6                	ld	ra,72(sp)
    80001830:	6406                	ld	s0,64(sp)
    80001832:	74e2                	ld	s1,56(sp)
    80001834:	7942                	ld	s2,48(sp)
    80001836:	79a2                	ld	s3,40(sp)
    80001838:	7a02                	ld	s4,32(sp)
    8000183a:	6ae2                	ld	s5,24(sp)
    8000183c:	6b42                	ld	s6,16(sp)
    8000183e:	6ba2                	ld	s7,8(sp)
    80001840:	6161                	add	sp,sp,80
    80001842:	8082                	ret
    80001844:	fff90713          	add	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001848:	9742                	add	a4,a4,a6
      --max;
    8000184a:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000184e:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001852:	04e58663          	beq	a1,a4,8000189e <copyinstr+0xa2>
{
    80001856:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001858:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000185c:	85a6                	mv	a1,s1
    8000185e:	8552                	mv	a0,s4
    80001860:	00000097          	auipc	ra,0x0
    80001864:	856080e7          	jalr	-1962(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    80001868:	cd0d                	beqz	a0,800018a2 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    8000186a:	417486b3          	sub	a3,s1,s7
    8000186e:	96ce                	add	a3,a3,s3
    if(n > max)
    80001870:	00d97363          	bgeu	s2,a3,80001876 <copyinstr+0x7a>
    80001874:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001876:	955e                	add	a0,a0,s7
    80001878:	8d05                	sub	a0,a0,s1
    while(n > 0){
    8000187a:	c695                	beqz	a3,800018a6 <copyinstr+0xaa>
    8000187c:	87da                	mv	a5,s6
    8000187e:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001880:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001884:	96da                	add	a3,a3,s6
    80001886:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001888:	00f60733          	add	a4,a2,a5
    8000188c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd250>
    80001890:	db49                	beqz	a4,80001822 <copyinstr+0x26>
        *dst = *p;
    80001892:	00e78023          	sb	a4,0(a5)
      dst++;
    80001896:	0785                	add	a5,a5,1
    while(n > 0){
    80001898:	fed797e3          	bne	a5,a3,80001886 <copyinstr+0x8a>
    8000189c:	b765                	j	80001844 <copyinstr+0x48>
    8000189e:	4781                	li	a5,0
    800018a0:	b761                	j	80001828 <copyinstr+0x2c>
      return -1;
    800018a2:	557d                	li	a0,-1
    800018a4:	b769                	j	8000182e <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800018a6:	6b85                	lui	s7,0x1
    800018a8:	9ba6                	add	s7,s7,s1
    800018aa:	87da                	mv	a5,s6
    800018ac:	b76d                	j	80001856 <copyinstr+0x5a>
  int got_null = 0;
    800018ae:	4781                	li	a5,0
  if(got_null){
    800018b0:	37fd                	addw	a5,a5,-1
    800018b2:	0007851b          	sext.w	a0,a5
}
    800018b6:	8082                	ret

00000000800018b8 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018b8:	7139                	add	sp,sp,-64
    800018ba:	fc06                	sd	ra,56(sp)
    800018bc:	f822                	sd	s0,48(sp)
    800018be:	f426                	sd	s1,40(sp)
    800018c0:	f04a                	sd	s2,32(sp)
    800018c2:	ec4e                	sd	s3,24(sp)
    800018c4:	e852                	sd	s4,16(sp)
    800018c6:	e456                	sd	s5,8(sp)
    800018c8:	e05a                	sd	s6,0(sp)
    800018ca:	0080                	add	s0,sp,64
    800018cc:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ce:	0000f497          	auipc	s1,0xf
    800018d2:	70248493          	add	s1,s1,1794 # 80010fd0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018d6:	8b26                	mv	s6,s1
    800018d8:	04fa5937          	lui	s2,0x4fa5
    800018dc:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800018e0:	0932                	sll	s2,s2,0xc
    800018e2:	fa590913          	add	s2,s2,-91
    800018e6:	0932                	sll	s2,s2,0xc
    800018e8:	fa590913          	add	s2,s2,-91
    800018ec:	0932                	sll	s2,s2,0xc
    800018ee:	fa590913          	add	s2,s2,-91
    800018f2:	040009b7          	lui	s3,0x4000
    800018f6:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018f8:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fa:	00015a97          	auipc	s5,0x15
    800018fe:	0d6a8a93          	add	s5,s5,214 # 800169d0 <tickslock>
    char *pa = kalloc();
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	246080e7          	jalr	582(ra) # 80000b48 <kalloc>
    8000190a:	862a                	mv	a2,a0
    if(pa == 0)
    8000190c:	c121                	beqz	a0,8000194c <proc_mapstacks+0x94>
    uint64 va = KSTACK((int) (p - proc));
    8000190e:	416485b3          	sub	a1,s1,s6
    80001912:	858d                	sra	a1,a1,0x3
    80001914:	032585b3          	mul	a1,a1,s2
    80001918:	2585                	addw	a1,a1,1
    8000191a:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000191e:	4719                	li	a4,6
    80001920:	6685                	lui	a3,0x1
    80001922:	40b985b3          	sub	a1,s3,a1
    80001926:	8552                	mv	a0,s4
    80001928:	00000097          	auipc	ra,0x0
    8000192c:	870080e7          	jalr	-1936(ra) # 80001198 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001930:	16848493          	add	s1,s1,360
    80001934:	fd5497e3          	bne	s1,s5,80001902 <proc_mapstacks+0x4a>
  }
}
    80001938:	70e2                	ld	ra,56(sp)
    8000193a:	7442                	ld	s0,48(sp)
    8000193c:	74a2                	ld	s1,40(sp)
    8000193e:	7902                	ld	s2,32(sp)
    80001940:	69e2                	ld	s3,24(sp)
    80001942:	6a42                	ld	s4,16(sp)
    80001944:	6aa2                	ld	s5,8(sp)
    80001946:	6b02                	ld	s6,0(sp)
    80001948:	6121                	add	sp,sp,64
    8000194a:	8082                	ret
      panic("kalloc");
    8000194c:	00007517          	auipc	a0,0x7
    80001950:	86c50513          	add	a0,a0,-1940 # 800081b8 <etext+0x1b8>
    80001954:	fffff097          	auipc	ra,0xfffff
    80001958:	c0c080e7          	jalr	-1012(ra) # 80000560 <panic>

000000008000195c <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000195c:	7139                	add	sp,sp,-64
    8000195e:	fc06                	sd	ra,56(sp)
    80001960:	f822                	sd	s0,48(sp)
    80001962:	f426                	sd	s1,40(sp)
    80001964:	f04a                	sd	s2,32(sp)
    80001966:	ec4e                	sd	s3,24(sp)
    80001968:	e852                	sd	s4,16(sp)
    8000196a:	e456                	sd	s5,8(sp)
    8000196c:	e05a                	sd	s6,0(sp)
    8000196e:	0080                	add	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001970:	00007597          	auipc	a1,0x7
    80001974:	85058593          	add	a1,a1,-1968 # 800081c0 <etext+0x1c0>
    80001978:	0000f517          	auipc	a0,0xf
    8000197c:	22850513          	add	a0,a0,552 # 80010ba0 <pid_lock>
    80001980:	fffff097          	auipc	ra,0xfffff
    80001984:	228080e7          	jalr	552(ra) # 80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001988:	00007597          	auipc	a1,0x7
    8000198c:	84058593          	add	a1,a1,-1984 # 800081c8 <etext+0x1c8>
    80001990:	0000f517          	auipc	a0,0xf
    80001994:	22850513          	add	a0,a0,552 # 80010bb8 <wait_lock>
    80001998:	fffff097          	auipc	ra,0xfffff
    8000199c:	210080e7          	jalr	528(ra) # 80000ba8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a0:	0000f497          	auipc	s1,0xf
    800019a4:	63048493          	add	s1,s1,1584 # 80010fd0 <proc>
      initlock(&p->lock, "proc");
    800019a8:	00007b17          	auipc	s6,0x7
    800019ac:	830b0b13          	add	s6,s6,-2000 # 800081d8 <etext+0x1d8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800019b0:	8aa6                	mv	s5,s1
    800019b2:	04fa5937          	lui	s2,0x4fa5
    800019b6:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800019ba:	0932                	sll	s2,s2,0xc
    800019bc:	fa590913          	add	s2,s2,-91
    800019c0:	0932                	sll	s2,s2,0xc
    800019c2:	fa590913          	add	s2,s2,-91
    800019c6:	0932                	sll	s2,s2,0xc
    800019c8:	fa590913          	add	s2,s2,-91
    800019cc:	040009b7          	lui	s3,0x4000
    800019d0:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019d2:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d4:	00015a17          	auipc	s4,0x15
    800019d8:	ffca0a13          	add	s4,s4,-4 # 800169d0 <tickslock>
      initlock(&p->lock, "proc");
    800019dc:	85da                	mv	a1,s6
    800019de:	8526                	mv	a0,s1
    800019e0:	fffff097          	auipc	ra,0xfffff
    800019e4:	1c8080e7          	jalr	456(ra) # 80000ba8 <initlock>
      p->state = UNUSED;
    800019e8:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800019ec:	415487b3          	sub	a5,s1,s5
    800019f0:	878d                	sra	a5,a5,0x3
    800019f2:	032787b3          	mul	a5,a5,s2
    800019f6:	2785                	addw	a5,a5,1
    800019f8:	00d7979b          	sllw	a5,a5,0xd
    800019fc:	40f987b3          	sub	a5,s3,a5
    80001a00:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a02:	16848493          	add	s1,s1,360
    80001a06:	fd449be3          	bne	s1,s4,800019dc <procinit+0x80>
  }
}
    80001a0a:	70e2                	ld	ra,56(sp)
    80001a0c:	7442                	ld	s0,48(sp)
    80001a0e:	74a2                	ld	s1,40(sp)
    80001a10:	7902                	ld	s2,32(sp)
    80001a12:	69e2                	ld	s3,24(sp)
    80001a14:	6a42                	ld	s4,16(sp)
    80001a16:	6aa2                	ld	s5,8(sp)
    80001a18:	6b02                	ld	s6,0(sp)
    80001a1a:	6121                	add	sp,sp,64
    80001a1c:	8082                	ret

0000000080001a1e <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a1e:	1141                	add	sp,sp,-16
    80001a20:	e422                	sd	s0,8(sp)
    80001a22:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a24:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a26:	2501                	sext.w	a0,a0
    80001a28:	6422                	ld	s0,8(sp)
    80001a2a:	0141                	add	sp,sp,16
    80001a2c:	8082                	ret

0000000080001a2e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001a2e:	1141                	add	sp,sp,-16
    80001a30:	e422                	sd	s0,8(sp)
    80001a32:	0800                	add	s0,sp,16
    80001a34:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a36:	2781                	sext.w	a5,a5
    80001a38:	079e                	sll	a5,a5,0x7
  return c;
}
    80001a3a:	0000f517          	auipc	a0,0xf
    80001a3e:	19650513          	add	a0,a0,406 # 80010bd0 <cpus>
    80001a42:	953e                	add	a0,a0,a5
    80001a44:	6422                	ld	s0,8(sp)
    80001a46:	0141                	add	sp,sp,16
    80001a48:	8082                	ret

0000000080001a4a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a4a:	1101                	add	sp,sp,-32
    80001a4c:	ec06                	sd	ra,24(sp)
    80001a4e:	e822                	sd	s0,16(sp)
    80001a50:	e426                	sd	s1,8(sp)
    80001a52:	1000                	add	s0,sp,32
  push_off();
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	198080e7          	jalr	408(ra) # 80000bec <push_off>
    80001a5c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a5e:	2781                	sext.w	a5,a5
    80001a60:	079e                	sll	a5,a5,0x7
    80001a62:	0000f717          	auipc	a4,0xf
    80001a66:	13e70713          	add	a4,a4,318 # 80010ba0 <pid_lock>
    80001a6a:	97ba                	add	a5,a5,a4
    80001a6c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	21e080e7          	jalr	542(ra) # 80000c8c <pop_off>
  return p;
}
    80001a76:	8526                	mv	a0,s1
    80001a78:	60e2                	ld	ra,24(sp)
    80001a7a:	6442                	ld	s0,16(sp)
    80001a7c:	64a2                	ld	s1,8(sp)
    80001a7e:	6105                	add	sp,sp,32
    80001a80:	8082                	ret

0000000080001a82 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a82:	1141                	add	sp,sp,-16
    80001a84:	e406                	sd	ra,8(sp)
    80001a86:	e022                	sd	s0,0(sp)
    80001a88:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a8a:	00000097          	auipc	ra,0x0
    80001a8e:	fc0080e7          	jalr	-64(ra) # 80001a4a <myproc>
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	25a080e7          	jalr	602(ra) # 80000cec <release>

  if (first) {
    80001a9a:	00007797          	auipc	a5,0x7
    80001a9e:	e167a783          	lw	a5,-490(a5) # 800088b0 <first.1>
    80001aa2:	eb89                	bnez	a5,80001ab4 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001aa4:	00001097          	auipc	ra,0x1
    80001aa8:	d36080e7          	jalr	-714(ra) # 800027da <usertrapret>
}
    80001aac:	60a2                	ld	ra,8(sp)
    80001aae:	6402                	ld	s0,0(sp)
    80001ab0:	0141                	add	sp,sp,16
    80001ab2:	8082                	ret
    first = 0;
    80001ab4:	00007797          	auipc	a5,0x7
    80001ab8:	de07ae23          	sw	zero,-516(a5) # 800088b0 <first.1>
    fsinit(ROOTDEV);
    80001abc:	4505                	li	a0,1
    80001abe:	00002097          	auipc	ra,0x2
    80001ac2:	aa4080e7          	jalr	-1372(ra) # 80003562 <fsinit>
    80001ac6:	bff9                	j	80001aa4 <forkret+0x22>

0000000080001ac8 <allocpid>:
{
    80001ac8:	1101                	add	sp,sp,-32
    80001aca:	ec06                	sd	ra,24(sp)
    80001acc:	e822                	sd	s0,16(sp)
    80001ace:	e426                	sd	s1,8(sp)
    80001ad0:	e04a                	sd	s2,0(sp)
    80001ad2:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001ad4:	0000f917          	auipc	s2,0xf
    80001ad8:	0cc90913          	add	s2,s2,204 # 80010ba0 <pid_lock>
    80001adc:	854a                	mv	a0,s2
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	15a080e7          	jalr	346(ra) # 80000c38 <acquire>
  pid = nextpid;
    80001ae6:	00007797          	auipc	a5,0x7
    80001aea:	dce78793          	add	a5,a5,-562 # 800088b4 <nextpid>
    80001aee:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001af0:	0014871b          	addw	a4,s1,1
    80001af4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001af6:	854a                	mv	a0,s2
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	1f4080e7          	jalr	500(ra) # 80000cec <release>
}
    80001b00:	8526                	mv	a0,s1
    80001b02:	60e2                	ld	ra,24(sp)
    80001b04:	6442                	ld	s0,16(sp)
    80001b06:	64a2                	ld	s1,8(sp)
    80001b08:	6902                	ld	s2,0(sp)
    80001b0a:	6105                	add	sp,sp,32
    80001b0c:	8082                	ret

0000000080001b0e <proc_pagetable>:
{
    80001b0e:	1101                	add	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	e04a                	sd	s2,0(sp)
    80001b18:	1000                	add	s0,sp,32
    80001b1a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b1c:	00000097          	auipc	ra,0x0
    80001b20:	876080e7          	jalr	-1930(ra) # 80001392 <uvmcreate>
    80001b24:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b26:	c121                	beqz	a0,80001b66 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b28:	4729                	li	a4,10
    80001b2a:	00005697          	auipc	a3,0x5
    80001b2e:	4d668693          	add	a3,a3,1238 # 80007000 <_trampoline>
    80001b32:	6605                	lui	a2,0x1
    80001b34:	040005b7          	lui	a1,0x4000
    80001b38:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b3a:	05b2                	sll	a1,a1,0xc
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	5bc080e7          	jalr	1468(ra) # 800010f8 <mappages>
    80001b44:	02054863          	bltz	a0,80001b74 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b48:	4719                	li	a4,6
    80001b4a:	05893683          	ld	a3,88(s2)
    80001b4e:	6605                	lui	a2,0x1
    80001b50:	020005b7          	lui	a1,0x2000
    80001b54:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b56:	05b6                	sll	a1,a1,0xd
    80001b58:	8526                	mv	a0,s1
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	59e080e7          	jalr	1438(ra) # 800010f8 <mappages>
    80001b62:	02054163          	bltz	a0,80001b84 <proc_pagetable+0x76>
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	add	sp,sp,32
    80001b72:	8082                	ret
    uvmfree(pagetable, 0);
    80001b74:	4581                	li	a1,0
    80001b76:	8526                	mv	a0,s1
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	a2c080e7          	jalr	-1492(ra) # 800015a4 <uvmfree>
    return 0;
    80001b80:	4481                	li	s1,0
    80001b82:	b7d5                	j	80001b66 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b84:	4681                	li	a3,0
    80001b86:	4605                	li	a2,1
    80001b88:	040005b7          	lui	a1,0x4000
    80001b8c:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b8e:	05b2                	sll	a1,a1,0xc
    80001b90:	8526                	mv	a0,s1
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	72c080e7          	jalr	1836(ra) # 800012be <uvmunmap>
    uvmfree(pagetable, 0);
    80001b9a:	4581                	li	a1,0
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	a06080e7          	jalr	-1530(ra) # 800015a4 <uvmfree>
    return 0;
    80001ba6:	4481                	li	s1,0
    80001ba8:	bf7d                	j	80001b66 <proc_pagetable+0x58>

0000000080001baa <proc_freepagetable>:
{
    80001baa:	1101                	add	sp,sp,-32
    80001bac:	ec06                	sd	ra,24(sp)
    80001bae:	e822                	sd	s0,16(sp)
    80001bb0:	e426                	sd	s1,8(sp)
    80001bb2:	e04a                	sd	s2,0(sp)
    80001bb4:	1000                	add	s0,sp,32
    80001bb6:	84aa                	mv	s1,a0
    80001bb8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bba:	4681                	li	a3,0
    80001bbc:	4605                	li	a2,1
    80001bbe:	040005b7          	lui	a1,0x4000
    80001bc2:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bc4:	05b2                	sll	a1,a1,0xc
    80001bc6:	fffff097          	auipc	ra,0xfffff
    80001bca:	6f8080e7          	jalr	1784(ra) # 800012be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bce:	4681                	li	a3,0
    80001bd0:	4605                	li	a2,1
    80001bd2:	020005b7          	lui	a1,0x2000
    80001bd6:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bd8:	05b6                	sll	a1,a1,0xd
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	6e2080e7          	jalr	1762(ra) # 800012be <uvmunmap>
  uvmfree(pagetable, sz);
    80001be4:	85ca                	mv	a1,s2
    80001be6:	8526                	mv	a0,s1
    80001be8:	00000097          	auipc	ra,0x0
    80001bec:	9bc080e7          	jalr	-1604(ra) # 800015a4 <uvmfree>
}
    80001bf0:	60e2                	ld	ra,24(sp)
    80001bf2:	6442                	ld	s0,16(sp)
    80001bf4:	64a2                	ld	s1,8(sp)
    80001bf6:	6902                	ld	s2,0(sp)
    80001bf8:	6105                	add	sp,sp,32
    80001bfa:	8082                	ret

0000000080001bfc <freeproc>:
{
    80001bfc:	1101                	add	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	1000                	add	s0,sp,32
    80001c06:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c08:	6d28                	ld	a0,88(a0)
    80001c0a:	c509                	beqz	a0,80001c14 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	e3e080e7          	jalr	-450(ra) # 80000a4a <kfree>
  p->trapframe = 0;
    80001c14:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c18:	68a8                	ld	a0,80(s1)
    80001c1a:	c511                	beqz	a0,80001c26 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c1c:	64ac                	ld	a1,72(s1)
    80001c1e:	00000097          	auipc	ra,0x0
    80001c22:	f8c080e7          	jalr	-116(ra) # 80001baa <proc_freepagetable>
  p->pagetable = 0;
    80001c26:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c2a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c2e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c32:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c36:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c3a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c3e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c42:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c46:	0004ac23          	sw	zero,24(s1)
}
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6105                	add	sp,sp,32
    80001c52:	8082                	ret

0000000080001c54 <allocproc>:
{
    80001c54:	1101                	add	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	add	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c60:	0000f497          	auipc	s1,0xf
    80001c64:	37048493          	add	s1,s1,880 # 80010fd0 <proc>
    80001c68:	00015917          	auipc	s2,0x15
    80001c6c:	d6890913          	add	s2,s2,-664 # 800169d0 <tickslock>
    acquire(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	fc6080e7          	jalr	-58(ra) # 80000c38 <acquire>
    if(p->state == UNUSED) {
    80001c7a:	4c9c                	lw	a5,24(s1)
    80001c7c:	cf81                	beqz	a5,80001c94 <allocproc+0x40>
      release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	06c080e7          	jalr	108(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c88:	16848493          	add	s1,s1,360
    80001c8c:	ff2492e3          	bne	s1,s2,80001c70 <allocproc+0x1c>
  return 0;
    80001c90:	4481                	li	s1,0
    80001c92:	a889                	j	80001ce4 <allocproc+0x90>
  p->pid = allocpid();
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	e34080e7          	jalr	-460(ra) # 80001ac8 <allocpid>
    80001c9c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c9e:	4785                	li	a5,1
    80001ca0:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	ea6080e7          	jalr	-346(ra) # 80000b48 <kalloc>
    80001caa:	892a                	mv	s2,a0
    80001cac:	eca8                	sd	a0,88(s1)
    80001cae:	c131                	beqz	a0,80001cf2 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	00000097          	auipc	ra,0x0
    80001cb6:	e5c080e7          	jalr	-420(ra) # 80001b0e <proc_pagetable>
    80001cba:	892a                	mv	s2,a0
    80001cbc:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cbe:	c531                	beqz	a0,80001d0a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001cc0:	07000613          	li	a2,112
    80001cc4:	4581                	li	a1,0
    80001cc6:	06048513          	add	a0,s1,96
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	06a080e7          	jalr	106(ra) # 80000d34 <memset>
  p->context.ra = (uint64)forkret;
    80001cd2:	00000797          	auipc	a5,0x0
    80001cd6:	db078793          	add	a5,a5,-592 # 80001a82 <forkret>
    80001cda:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cdc:	60bc                	ld	a5,64(s1)
    80001cde:	6705                	lui	a4,0x1
    80001ce0:	97ba                	add	a5,a5,a4
    80001ce2:	f4bc                	sd	a5,104(s1)
}
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	60e2                	ld	ra,24(sp)
    80001ce8:	6442                	ld	s0,16(sp)
    80001cea:	64a2                	ld	s1,8(sp)
    80001cec:	6902                	ld	s2,0(sp)
    80001cee:	6105                	add	sp,sp,32
    80001cf0:	8082                	ret
    freeproc(p);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	00000097          	auipc	ra,0x0
    80001cf8:	f08080e7          	jalr	-248(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	fee080e7          	jalr	-18(ra) # 80000cec <release>
    return 0;
    80001d06:	84ca                	mv	s1,s2
    80001d08:	bff1                	j	80001ce4 <allocproc+0x90>
    freeproc(p);
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	00000097          	auipc	ra,0x0
    80001d10:	ef0080e7          	jalr	-272(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001d14:	8526                	mv	a0,s1
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	fd6080e7          	jalr	-42(ra) # 80000cec <release>
    return 0;
    80001d1e:	84ca                	mv	s1,s2
    80001d20:	b7d1                	j	80001ce4 <allocproc+0x90>

0000000080001d22 <userinit>:
{
    80001d22:	1101                	add	sp,sp,-32
    80001d24:	ec06                	sd	ra,24(sp)
    80001d26:	e822                	sd	s0,16(sp)
    80001d28:	e426                	sd	s1,8(sp)
    80001d2a:	1000                	add	s0,sp,32
  p = allocproc();
    80001d2c:	00000097          	auipc	ra,0x0
    80001d30:	f28080e7          	jalr	-216(ra) # 80001c54 <allocproc>
    80001d34:	84aa                	mv	s1,a0
  initproc = p;
    80001d36:	00007797          	auipc	a5,0x7
    80001d3a:	bea7b923          	sd	a0,-1038(a5) # 80008928 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d3e:	03400613          	li	a2,52
    80001d42:	00007597          	auipc	a1,0x7
    80001d46:	b7e58593          	add	a1,a1,-1154 # 800088c0 <initcode>
    80001d4a:	6928                	ld	a0,80(a0)
    80001d4c:	fffff097          	auipc	ra,0xfffff
    80001d50:	674080e7          	jalr	1652(ra) # 800013c0 <uvmfirst>
  p->sz = PGSIZE;
    80001d54:	6785                	lui	a5,0x1
    80001d56:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d58:	6cb8                	ld	a4,88(s1)
    80001d5a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d5e:	6cb8                	ld	a4,88(s1)
    80001d60:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d62:	4641                	li	a2,16
    80001d64:	00006597          	auipc	a1,0x6
    80001d68:	47c58593          	add	a1,a1,1148 # 800081e0 <etext+0x1e0>
    80001d6c:	15848513          	add	a0,s1,344
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	106080e7          	jalr	262(ra) # 80000e76 <safestrcpy>
  p->cwd = namei("/");
    80001d78:	00006517          	auipc	a0,0x6
    80001d7c:	47850513          	add	a0,a0,1144 # 800081f0 <etext+0x1f0>
    80001d80:	00002097          	auipc	ra,0x2
    80001d84:	234080e7          	jalr	564(ra) # 80003fb4 <namei>
    80001d88:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d8c:	478d                	li	a5,3
    80001d8e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d90:	8526                	mv	a0,s1
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	f5a080e7          	jalr	-166(ra) # 80000cec <release>
}
    80001d9a:	60e2                	ld	ra,24(sp)
    80001d9c:	6442                	ld	s0,16(sp)
    80001d9e:	64a2                	ld	s1,8(sp)
    80001da0:	6105                	add	sp,sp,32
    80001da2:	8082                	ret

0000000080001da4 <growproc>:
{
    80001da4:	1101                	add	sp,sp,-32
    80001da6:	ec06                	sd	ra,24(sp)
    80001da8:	e822                	sd	s0,16(sp)
    80001daa:	e426                	sd	s1,8(sp)
    80001dac:	e04a                	sd	s2,0(sp)
    80001dae:	1000                	add	s0,sp,32
    80001db0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001db2:	00000097          	auipc	ra,0x0
    80001db6:	c98080e7          	jalr	-872(ra) # 80001a4a <myproc>
    80001dba:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dbc:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001dbe:	01204c63          	bgtz	s2,80001dd6 <growproc+0x32>
  } else if(n < 0){
    80001dc2:	02094663          	bltz	s2,80001dee <growproc+0x4a>
  p->sz = sz;
    80001dc6:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dc8:	4501                	li	a0,0
}
    80001dca:	60e2                	ld	ra,24(sp)
    80001dcc:	6442                	ld	s0,16(sp)
    80001dce:	64a2                	ld	s1,8(sp)
    80001dd0:	6902                	ld	s2,0(sp)
    80001dd2:	6105                	add	sp,sp,32
    80001dd4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dd6:	4691                	li	a3,4
    80001dd8:	00b90633          	add	a2,s2,a1
    80001ddc:	6928                	ld	a0,80(a0)
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	69c080e7          	jalr	1692(ra) # 8000147a <uvmalloc>
    80001de6:	85aa                	mv	a1,a0
    80001de8:	fd79                	bnez	a0,80001dc6 <growproc+0x22>
      return -1;
    80001dea:	557d                	li	a0,-1
    80001dec:	bff9                	j	80001dca <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dee:	00b90633          	add	a2,s2,a1
    80001df2:	6928                	ld	a0,80(a0)
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	63e080e7          	jalr	1598(ra) # 80001432 <uvmdealloc>
    80001dfc:	85aa                	mv	a1,a0
    80001dfe:	b7e1                	j	80001dc6 <growproc+0x22>

0000000080001e00 <fork>:
{
    80001e00:	7139                	add	sp,sp,-64
    80001e02:	fc06                	sd	ra,56(sp)
    80001e04:	f822                	sd	s0,48(sp)
    80001e06:	f04a                	sd	s2,32(sp)
    80001e08:	e456                	sd	s5,8(sp)
    80001e0a:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001e0c:	00000097          	auipc	ra,0x0
    80001e10:	c3e080e7          	jalr	-962(ra) # 80001a4a <myproc>
    80001e14:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e16:	00000097          	auipc	ra,0x0
    80001e1a:	e3e080e7          	jalr	-450(ra) # 80001c54 <allocproc>
    80001e1e:	12050063          	beqz	a0,80001f3e <fork+0x13e>
    80001e22:	e852                	sd	s4,16(sp)
    80001e24:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e26:	048ab603          	ld	a2,72(s5)
    80001e2a:	692c                	ld	a1,80(a0)
    80001e2c:	050ab503          	ld	a0,80(s5)
    80001e30:	fffff097          	auipc	ra,0xfffff
    80001e34:	7ae080e7          	jalr	1966(ra) # 800015de <uvmcopy>
    80001e38:	04054a63          	bltz	a0,80001e8c <fork+0x8c>
    80001e3c:	f426                	sd	s1,40(sp)
    80001e3e:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e40:	048ab783          	ld	a5,72(s5)
    80001e44:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e48:	058ab683          	ld	a3,88(s5)
    80001e4c:	87b6                	mv	a5,a3
    80001e4e:	058a3703          	ld	a4,88(s4)
    80001e52:	12068693          	add	a3,a3,288
    80001e56:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5a:	6788                	ld	a0,8(a5)
    80001e5c:	6b8c                	ld	a1,16(a5)
    80001e5e:	6f90                	ld	a2,24(a5)
    80001e60:	01073023          	sd	a6,0(a4)
    80001e64:	e708                	sd	a0,8(a4)
    80001e66:	eb0c                	sd	a1,16(a4)
    80001e68:	ef10                	sd	a2,24(a4)
    80001e6a:	02078793          	add	a5,a5,32
    80001e6e:	02070713          	add	a4,a4,32
    80001e72:	fed792e3          	bne	a5,a3,80001e56 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e76:	058a3783          	ld	a5,88(s4)
    80001e7a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e7e:	0d0a8493          	add	s1,s5,208
    80001e82:	0d0a0913          	add	s2,s4,208
    80001e86:	150a8993          	add	s3,s5,336
    80001e8a:	a015                	j	80001eae <fork+0xae>
    freeproc(np);
    80001e8c:	8552                	mv	a0,s4
    80001e8e:	00000097          	auipc	ra,0x0
    80001e92:	d6e080e7          	jalr	-658(ra) # 80001bfc <freeproc>
    release(&np->lock);
    80001e96:	8552                	mv	a0,s4
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	e54080e7          	jalr	-428(ra) # 80000cec <release>
    return -1;
    80001ea0:	597d                	li	s2,-1
    80001ea2:	6a42                	ld	s4,16(sp)
    80001ea4:	a071                	j	80001f30 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001ea6:	04a1                	add	s1,s1,8
    80001ea8:	0921                	add	s2,s2,8
    80001eaa:	01348b63          	beq	s1,s3,80001ec0 <fork+0xc0>
    if(p->ofile[i])
    80001eae:	6088                	ld	a0,0(s1)
    80001eb0:	d97d                	beqz	a0,80001ea6 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb2:	00002097          	auipc	ra,0x2
    80001eb6:	77a080e7          	jalr	1914(ra) # 8000462c <filedup>
    80001eba:	00a93023          	sd	a0,0(s2)
    80001ebe:	b7e5                	j	80001ea6 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ec0:	150ab503          	ld	a0,336(s5)
    80001ec4:	00002097          	auipc	ra,0x2
    80001ec8:	8e4080e7          	jalr	-1820(ra) # 800037a8 <idup>
    80001ecc:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed0:	4641                	li	a2,16
    80001ed2:	158a8593          	add	a1,s5,344
    80001ed6:	158a0513          	add	a0,s4,344
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	f9c080e7          	jalr	-100(ra) # 80000e76 <safestrcpy>
  pid = np->pid;
    80001ee2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ee6:	8552                	mv	a0,s4
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	e04080e7          	jalr	-508(ra) # 80000cec <release>
  acquire(&wait_lock);
    80001ef0:	0000f497          	auipc	s1,0xf
    80001ef4:	cc848493          	add	s1,s1,-824 # 80010bb8 <wait_lock>
    80001ef8:	8526                	mv	a0,s1
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	d3e080e7          	jalr	-706(ra) # 80000c38 <acquire>
  np->parent = p;
    80001f02:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f06:	8526                	mv	a0,s1
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	de4080e7          	jalr	-540(ra) # 80000cec <release>
  acquire(&np->lock);
    80001f10:	8552                	mv	a0,s4
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	d26080e7          	jalr	-730(ra) # 80000c38 <acquire>
  np->state = RUNNABLE;
    80001f1a:	478d                	li	a5,3
    80001f1c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f20:	8552                	mv	a0,s4
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	dca080e7          	jalr	-566(ra) # 80000cec <release>
  return pid;
    80001f2a:	74a2                	ld	s1,40(sp)
    80001f2c:	69e2                	ld	s3,24(sp)
    80001f2e:	6a42                	ld	s4,16(sp)
}
    80001f30:	854a                	mv	a0,s2
    80001f32:	70e2                	ld	ra,56(sp)
    80001f34:	7442                	ld	s0,48(sp)
    80001f36:	7902                	ld	s2,32(sp)
    80001f38:	6aa2                	ld	s5,8(sp)
    80001f3a:	6121                	add	sp,sp,64
    80001f3c:	8082                	ret
    return -1;
    80001f3e:	597d                	li	s2,-1
    80001f40:	bfc5                	j	80001f30 <fork+0x130>

0000000080001f42 <scheduler>:
{
    80001f42:	7139                	add	sp,sp,-64
    80001f44:	fc06                	sd	ra,56(sp)
    80001f46:	f822                	sd	s0,48(sp)
    80001f48:	f426                	sd	s1,40(sp)
    80001f4a:	f04a                	sd	s2,32(sp)
    80001f4c:	ec4e                	sd	s3,24(sp)
    80001f4e:	e852                	sd	s4,16(sp)
    80001f50:	e456                	sd	s5,8(sp)
    80001f52:	e05a                	sd	s6,0(sp)
    80001f54:	0080                	add	s0,sp,64
    80001f56:	8792                	mv	a5,tp
  int id = r_tp();
    80001f58:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f5a:	00779a93          	sll	s5,a5,0x7
    80001f5e:	0000f717          	auipc	a4,0xf
    80001f62:	c4270713          	add	a4,a4,-958 # 80010ba0 <pid_lock>
    80001f66:	9756                	add	a4,a4,s5
    80001f68:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f6c:	0000f717          	auipc	a4,0xf
    80001f70:	c6c70713          	add	a4,a4,-916 # 80010bd8 <cpus+0x8>
    80001f74:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f76:	498d                	li	s3,3
        p->state = RUNNING;
    80001f78:	4b11                	li	s6,4
        c->proc = p;
    80001f7a:	079e                	sll	a5,a5,0x7
    80001f7c:	0000fa17          	auipc	s4,0xf
    80001f80:	c24a0a13          	add	s4,s4,-988 # 80010ba0 <pid_lock>
    80001f84:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f86:	00015917          	auipc	s2,0x15
    80001f8a:	a4a90913          	add	s2,s2,-1462 # 800169d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f8e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f92:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f96:	10079073          	csrw	sstatus,a5
    80001f9a:	0000f497          	auipc	s1,0xf
    80001f9e:	03648493          	add	s1,s1,54 # 80010fd0 <proc>
    80001fa2:	a811                	j	80001fb6 <scheduler+0x74>
      release(&p->lock);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	d46080e7          	jalr	-698(ra) # 80000cec <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fae:	16848493          	add	s1,s1,360
    80001fb2:	fd248ee3          	beq	s1,s2,80001f8e <scheduler+0x4c>
      acquire(&p->lock);
    80001fb6:	8526                	mv	a0,s1
    80001fb8:	fffff097          	auipc	ra,0xfffff
    80001fbc:	c80080e7          	jalr	-896(ra) # 80000c38 <acquire>
      if(p->state == RUNNABLE) {
    80001fc0:	4c9c                	lw	a5,24(s1)
    80001fc2:	ff3791e3          	bne	a5,s3,80001fa4 <scheduler+0x62>
        p->state = RUNNING;
    80001fc6:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fca:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fce:	06048593          	add	a1,s1,96
    80001fd2:	8556                	mv	a0,s5
    80001fd4:	00000097          	auipc	ra,0x0
    80001fd8:	75c080e7          	jalr	1884(ra) # 80002730 <swtch>
        c->proc = 0;
    80001fdc:	020a3823          	sd	zero,48(s4)
    80001fe0:	b7d1                	j	80001fa4 <scheduler+0x62>

0000000080001fe2 <sched>:
{
    80001fe2:	7179                	add	sp,sp,-48
    80001fe4:	f406                	sd	ra,40(sp)
    80001fe6:	f022                	sd	s0,32(sp)
    80001fe8:	ec26                	sd	s1,24(sp)
    80001fea:	e84a                	sd	s2,16(sp)
    80001fec:	e44e                	sd	s3,8(sp)
    80001fee:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80001ff0:	00000097          	auipc	ra,0x0
    80001ff4:	a5a080e7          	jalr	-1446(ra) # 80001a4a <myproc>
    80001ff8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ffa:	fffff097          	auipc	ra,0xfffff
    80001ffe:	bc4080e7          	jalr	-1084(ra) # 80000bbe <holding>
    80002002:	c93d                	beqz	a0,80002078 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002004:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002006:	2781                	sext.w	a5,a5
    80002008:	079e                	sll	a5,a5,0x7
    8000200a:	0000f717          	auipc	a4,0xf
    8000200e:	b9670713          	add	a4,a4,-1130 # 80010ba0 <pid_lock>
    80002012:	97ba                	add	a5,a5,a4
    80002014:	0a87a703          	lw	a4,168(a5)
    80002018:	4785                	li	a5,1
    8000201a:	06f71763          	bne	a4,a5,80002088 <sched+0xa6>
  if(p->state == RUNNING)
    8000201e:	4c98                	lw	a4,24(s1)
    80002020:	4791                	li	a5,4
    80002022:	06f70b63          	beq	a4,a5,80002098 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002026:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000202a:	8b89                	and	a5,a5,2
  if(intr_get())
    8000202c:	efb5                	bnez	a5,800020a8 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000202e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002030:	0000f917          	auipc	s2,0xf
    80002034:	b7090913          	add	s2,s2,-1168 # 80010ba0 <pid_lock>
    80002038:	2781                	sext.w	a5,a5
    8000203a:	079e                	sll	a5,a5,0x7
    8000203c:	97ca                	add	a5,a5,s2
    8000203e:	0ac7a983          	lw	s3,172(a5)
    80002042:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002044:	2781                	sext.w	a5,a5
    80002046:	079e                	sll	a5,a5,0x7
    80002048:	0000f597          	auipc	a1,0xf
    8000204c:	b9058593          	add	a1,a1,-1136 # 80010bd8 <cpus+0x8>
    80002050:	95be                	add	a1,a1,a5
    80002052:	06048513          	add	a0,s1,96
    80002056:	00000097          	auipc	ra,0x0
    8000205a:	6da080e7          	jalr	1754(ra) # 80002730 <swtch>
    8000205e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002060:	2781                	sext.w	a5,a5
    80002062:	079e                	sll	a5,a5,0x7
    80002064:	993e                	add	s2,s2,a5
    80002066:	0b392623          	sw	s3,172(s2)
}
    8000206a:	70a2                	ld	ra,40(sp)
    8000206c:	7402                	ld	s0,32(sp)
    8000206e:	64e2                	ld	s1,24(sp)
    80002070:	6942                	ld	s2,16(sp)
    80002072:	69a2                	ld	s3,8(sp)
    80002074:	6145                	add	sp,sp,48
    80002076:	8082                	ret
    panic("sched p->lock");
    80002078:	00006517          	auipc	a0,0x6
    8000207c:	18050513          	add	a0,a0,384 # 800081f8 <etext+0x1f8>
    80002080:	ffffe097          	auipc	ra,0xffffe
    80002084:	4e0080e7          	jalr	1248(ra) # 80000560 <panic>
    panic("sched locks");
    80002088:	00006517          	auipc	a0,0x6
    8000208c:	18050513          	add	a0,a0,384 # 80008208 <etext+0x208>
    80002090:	ffffe097          	auipc	ra,0xffffe
    80002094:	4d0080e7          	jalr	1232(ra) # 80000560 <panic>
    panic("sched running");
    80002098:	00006517          	auipc	a0,0x6
    8000209c:	18050513          	add	a0,a0,384 # 80008218 <etext+0x218>
    800020a0:	ffffe097          	auipc	ra,0xffffe
    800020a4:	4c0080e7          	jalr	1216(ra) # 80000560 <panic>
    panic("sched interruptible");
    800020a8:	00006517          	auipc	a0,0x6
    800020ac:	18050513          	add	a0,a0,384 # 80008228 <etext+0x228>
    800020b0:	ffffe097          	auipc	ra,0xffffe
    800020b4:	4b0080e7          	jalr	1200(ra) # 80000560 <panic>

00000000800020b8 <yield>:
{
    800020b8:	1101                	add	sp,sp,-32
    800020ba:	ec06                	sd	ra,24(sp)
    800020bc:	e822                	sd	s0,16(sp)
    800020be:	e426                	sd	s1,8(sp)
    800020c0:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    800020c2:	00000097          	auipc	ra,0x0
    800020c6:	988080e7          	jalr	-1656(ra) # 80001a4a <myproc>
    800020ca:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	b6c080e7          	jalr	-1172(ra) # 80000c38 <acquire>
  p->state = RUNNABLE;
    800020d4:	478d                	li	a5,3
    800020d6:	cc9c                	sw	a5,24(s1)
  sched();
    800020d8:	00000097          	auipc	ra,0x0
    800020dc:	f0a080e7          	jalr	-246(ra) # 80001fe2 <sched>
  release(&p->lock);
    800020e0:	8526                	mv	a0,s1
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	c0a080e7          	jalr	-1014(ra) # 80000cec <release>
}
    800020ea:	60e2                	ld	ra,24(sp)
    800020ec:	6442                	ld	s0,16(sp)
    800020ee:	64a2                	ld	s1,8(sp)
    800020f0:	6105                	add	sp,sp,32
    800020f2:	8082                	ret

00000000800020f4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020f4:	7179                	add	sp,sp,-48
    800020f6:	f406                	sd	ra,40(sp)
    800020f8:	f022                	sd	s0,32(sp)
    800020fa:	ec26                	sd	s1,24(sp)
    800020fc:	e84a                	sd	s2,16(sp)
    800020fe:	e44e                	sd	s3,8(sp)
    80002100:	1800                	add	s0,sp,48
    80002102:	89aa                	mv	s3,a0
    80002104:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002106:	00000097          	auipc	ra,0x0
    8000210a:	944080e7          	jalr	-1724(ra) # 80001a4a <myproc>
    8000210e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	b28080e7          	jalr	-1240(ra) # 80000c38 <acquire>
  release(lk);
    80002118:	854a                	mv	a0,s2
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	bd2080e7          	jalr	-1070(ra) # 80000cec <release>

  // Go to sleep.
  p->chan = chan;
    80002122:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002126:	4789                	li	a5,2
    80002128:	cc9c                	sw	a5,24(s1)

  sched();
    8000212a:	00000097          	auipc	ra,0x0
    8000212e:	eb8080e7          	jalr	-328(ra) # 80001fe2 <sched>

  // Tidy up.
  p->chan = 0;
    80002132:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002136:	8526                	mv	a0,s1
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	bb4080e7          	jalr	-1100(ra) # 80000cec <release>
  acquire(lk);
    80002140:	854a                	mv	a0,s2
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	af6080e7          	jalr	-1290(ra) # 80000c38 <acquire>
}
    8000214a:	70a2                	ld	ra,40(sp)
    8000214c:	7402                	ld	s0,32(sp)
    8000214e:	64e2                	ld	s1,24(sp)
    80002150:	6942                	ld	s2,16(sp)
    80002152:	69a2                	ld	s3,8(sp)
    80002154:	6145                	add	sp,sp,48
    80002156:	8082                	ret

0000000080002158 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002158:	7139                	add	sp,sp,-64
    8000215a:	fc06                	sd	ra,56(sp)
    8000215c:	f822                	sd	s0,48(sp)
    8000215e:	f426                	sd	s1,40(sp)
    80002160:	f04a                	sd	s2,32(sp)
    80002162:	ec4e                	sd	s3,24(sp)
    80002164:	e852                	sd	s4,16(sp)
    80002166:	e456                	sd	s5,8(sp)
    80002168:	0080                	add	s0,sp,64
    8000216a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000216c:	0000f497          	auipc	s1,0xf
    80002170:	e6448493          	add	s1,s1,-412 # 80010fd0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002174:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002176:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002178:	00015917          	auipc	s2,0x15
    8000217c:	85890913          	add	s2,s2,-1960 # 800169d0 <tickslock>
    80002180:	a811                	j	80002194 <wakeup+0x3c>
      }
      release(&p->lock);
    80002182:	8526                	mv	a0,s1
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	b68080e7          	jalr	-1176(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000218c:	16848493          	add	s1,s1,360
    80002190:	03248663          	beq	s1,s2,800021bc <wakeup+0x64>
    if(p != myproc()){
    80002194:	00000097          	auipc	ra,0x0
    80002198:	8b6080e7          	jalr	-1866(ra) # 80001a4a <myproc>
    8000219c:	fea488e3          	beq	s1,a0,8000218c <wakeup+0x34>
      acquire(&p->lock);
    800021a0:	8526                	mv	a0,s1
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	a96080e7          	jalr	-1386(ra) # 80000c38 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021aa:	4c9c                	lw	a5,24(s1)
    800021ac:	fd379be3          	bne	a5,s3,80002182 <wakeup+0x2a>
    800021b0:	709c                	ld	a5,32(s1)
    800021b2:	fd4798e3          	bne	a5,s4,80002182 <wakeup+0x2a>
        p->state = RUNNABLE;
    800021b6:	0154ac23          	sw	s5,24(s1)
    800021ba:	b7e1                	j	80002182 <wakeup+0x2a>
    }
  }
}
    800021bc:	70e2                	ld	ra,56(sp)
    800021be:	7442                	ld	s0,48(sp)
    800021c0:	74a2                	ld	s1,40(sp)
    800021c2:	7902                	ld	s2,32(sp)
    800021c4:	69e2                	ld	s3,24(sp)
    800021c6:	6a42                	ld	s4,16(sp)
    800021c8:	6aa2                	ld	s5,8(sp)
    800021ca:	6121                	add	sp,sp,64
    800021cc:	8082                	ret

00000000800021ce <reparent>:
{
    800021ce:	7179                	add	sp,sp,-48
    800021d0:	f406                	sd	ra,40(sp)
    800021d2:	f022                	sd	s0,32(sp)
    800021d4:	ec26                	sd	s1,24(sp)
    800021d6:	e84a                	sd	s2,16(sp)
    800021d8:	e44e                	sd	s3,8(sp)
    800021da:	e052                	sd	s4,0(sp)
    800021dc:	1800                	add	s0,sp,48
    800021de:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e0:	0000f497          	auipc	s1,0xf
    800021e4:	df048493          	add	s1,s1,-528 # 80010fd0 <proc>
      pp->parent = initproc;
    800021e8:	00006a17          	auipc	s4,0x6
    800021ec:	740a0a13          	add	s4,s4,1856 # 80008928 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f0:	00014997          	auipc	s3,0x14
    800021f4:	7e098993          	add	s3,s3,2016 # 800169d0 <tickslock>
    800021f8:	a029                	j	80002202 <reparent+0x34>
    800021fa:	16848493          	add	s1,s1,360
    800021fe:	01348d63          	beq	s1,s3,80002218 <reparent+0x4a>
    if(pp->parent == p){
    80002202:	7c9c                	ld	a5,56(s1)
    80002204:	ff279be3          	bne	a5,s2,800021fa <reparent+0x2c>
      pp->parent = initproc;
    80002208:	000a3503          	ld	a0,0(s4)
    8000220c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000220e:	00000097          	auipc	ra,0x0
    80002212:	f4a080e7          	jalr	-182(ra) # 80002158 <wakeup>
    80002216:	b7d5                	j	800021fa <reparent+0x2c>
}
    80002218:	70a2                	ld	ra,40(sp)
    8000221a:	7402                	ld	s0,32(sp)
    8000221c:	64e2                	ld	s1,24(sp)
    8000221e:	6942                	ld	s2,16(sp)
    80002220:	69a2                	ld	s3,8(sp)
    80002222:	6a02                	ld	s4,0(sp)
    80002224:	6145                	add	sp,sp,48
    80002226:	8082                	ret

0000000080002228 <exit>:
{
    80002228:	7179                	add	sp,sp,-48
    8000222a:	f406                	sd	ra,40(sp)
    8000222c:	f022                	sd	s0,32(sp)
    8000222e:	ec26                	sd	s1,24(sp)
    80002230:	e84a                	sd	s2,16(sp)
    80002232:	e44e                	sd	s3,8(sp)
    80002234:	e052                	sd	s4,0(sp)
    80002236:	1800                	add	s0,sp,48
    80002238:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000223a:	00000097          	auipc	ra,0x0
    8000223e:	810080e7          	jalr	-2032(ra) # 80001a4a <myproc>
    80002242:	89aa                	mv	s3,a0
  if(p == initproc)
    80002244:	00006797          	auipc	a5,0x6
    80002248:	6e47b783          	ld	a5,1764(a5) # 80008928 <initproc>
    8000224c:	0d050493          	add	s1,a0,208
    80002250:	15050913          	add	s2,a0,336
    80002254:	02a79363          	bne	a5,a0,8000227a <exit+0x52>
    panic("init exiting");
    80002258:	00006517          	auipc	a0,0x6
    8000225c:	fe850513          	add	a0,a0,-24 # 80008240 <etext+0x240>
    80002260:	ffffe097          	auipc	ra,0xffffe
    80002264:	300080e7          	jalr	768(ra) # 80000560 <panic>
      fileclose(f);
    80002268:	00002097          	auipc	ra,0x2
    8000226c:	416080e7          	jalr	1046(ra) # 8000467e <fileclose>
      p->ofile[fd] = 0;
    80002270:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002274:	04a1                	add	s1,s1,8
    80002276:	01248563          	beq	s1,s2,80002280 <exit+0x58>
    if(p->ofile[fd]){
    8000227a:	6088                	ld	a0,0(s1)
    8000227c:	f575                	bnez	a0,80002268 <exit+0x40>
    8000227e:	bfdd                	j	80002274 <exit+0x4c>
  begin_op();
    80002280:	00002097          	auipc	ra,0x2
    80002284:	f34080e7          	jalr	-204(ra) # 800041b4 <begin_op>
  iput(p->cwd);
    80002288:	1509b503          	ld	a0,336(s3)
    8000228c:	00001097          	auipc	ra,0x1
    80002290:	718080e7          	jalr	1816(ra) # 800039a4 <iput>
  end_op();
    80002294:	00002097          	auipc	ra,0x2
    80002298:	f9a080e7          	jalr	-102(ra) # 8000422e <end_op>
  p->cwd = 0;
    8000229c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022a0:	0000f497          	auipc	s1,0xf
    800022a4:	91848493          	add	s1,s1,-1768 # 80010bb8 <wait_lock>
    800022a8:	8526                	mv	a0,s1
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	98e080e7          	jalr	-1650(ra) # 80000c38 <acquire>
  reparent(p);
    800022b2:	854e                	mv	a0,s3
    800022b4:	00000097          	auipc	ra,0x0
    800022b8:	f1a080e7          	jalr	-230(ra) # 800021ce <reparent>
  wakeup(p->parent);
    800022bc:	0389b503          	ld	a0,56(s3)
    800022c0:	00000097          	auipc	ra,0x0
    800022c4:	e98080e7          	jalr	-360(ra) # 80002158 <wakeup>
  acquire(&p->lock);
    800022c8:	854e                	mv	a0,s3
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	96e080e7          	jalr	-1682(ra) # 80000c38 <acquire>
  p->xstate = status;
    800022d2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022d6:	4795                	li	a5,5
    800022d8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	a0e080e7          	jalr	-1522(ra) # 80000cec <release>
  sched();
    800022e6:	00000097          	auipc	ra,0x0
    800022ea:	cfc080e7          	jalr	-772(ra) # 80001fe2 <sched>
  panic("zombie exit");
    800022ee:	00006517          	auipc	a0,0x6
    800022f2:	f6250513          	add	a0,a0,-158 # 80008250 <etext+0x250>
    800022f6:	ffffe097          	auipc	ra,0xffffe
    800022fa:	26a080e7          	jalr	618(ra) # 80000560 <panic>

00000000800022fe <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022fe:	7179                	add	sp,sp,-48
    80002300:	f406                	sd	ra,40(sp)
    80002302:	f022                	sd	s0,32(sp)
    80002304:	ec26                	sd	s1,24(sp)
    80002306:	e84a                	sd	s2,16(sp)
    80002308:	e44e                	sd	s3,8(sp)
    8000230a:	1800                	add	s0,sp,48
    8000230c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000230e:	0000f497          	auipc	s1,0xf
    80002312:	cc248493          	add	s1,s1,-830 # 80010fd0 <proc>
    80002316:	00014997          	auipc	s3,0x14
    8000231a:	6ba98993          	add	s3,s3,1722 # 800169d0 <tickslock>
    acquire(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	918080e7          	jalr	-1768(ra) # 80000c38 <acquire>
    if(p->pid == pid){
    80002328:	589c                	lw	a5,48(s1)
    8000232a:	01278d63          	beq	a5,s2,80002344 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	9bc080e7          	jalr	-1604(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002338:	16848493          	add	s1,s1,360
    8000233c:	ff3491e3          	bne	s1,s3,8000231e <kill+0x20>
  }
  return -1;
    80002340:	557d                	li	a0,-1
    80002342:	a829                	j	8000235c <kill+0x5e>
      p->killed = 1;
    80002344:	4785                	li	a5,1
    80002346:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002348:	4c98                	lw	a4,24(s1)
    8000234a:	4789                	li	a5,2
    8000234c:	00f70f63          	beq	a4,a5,8000236a <kill+0x6c>
      release(&p->lock);
    80002350:	8526                	mv	a0,s1
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	99a080e7          	jalr	-1638(ra) # 80000cec <release>
      return 0;
    8000235a:	4501                	li	a0,0
}
    8000235c:	70a2                	ld	ra,40(sp)
    8000235e:	7402                	ld	s0,32(sp)
    80002360:	64e2                	ld	s1,24(sp)
    80002362:	6942                	ld	s2,16(sp)
    80002364:	69a2                	ld	s3,8(sp)
    80002366:	6145                	add	sp,sp,48
    80002368:	8082                	ret
        p->state = RUNNABLE;
    8000236a:	478d                	li	a5,3
    8000236c:	cc9c                	sw	a5,24(s1)
    8000236e:	b7cd                	j	80002350 <kill+0x52>

0000000080002370 <setkilled>:

void
setkilled(struct proc *p)
{
    80002370:	1101                	add	sp,sp,-32
    80002372:	ec06                	sd	ra,24(sp)
    80002374:	e822                	sd	s0,16(sp)
    80002376:	e426                	sd	s1,8(sp)
    80002378:	1000                	add	s0,sp,32
    8000237a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	8bc080e7          	jalr	-1860(ra) # 80000c38 <acquire>
  p->killed = 1;
    80002384:	4785                	li	a5,1
    80002386:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002388:	8526                	mv	a0,s1
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	962080e7          	jalr	-1694(ra) # 80000cec <release>
}
    80002392:	60e2                	ld	ra,24(sp)
    80002394:	6442                	ld	s0,16(sp)
    80002396:	64a2                	ld	s1,8(sp)
    80002398:	6105                	add	sp,sp,32
    8000239a:	8082                	ret

000000008000239c <killed>:

int
killed(struct proc *p)
{
    8000239c:	1101                	add	sp,sp,-32
    8000239e:	ec06                	sd	ra,24(sp)
    800023a0:	e822                	sd	s0,16(sp)
    800023a2:	e426                	sd	s1,8(sp)
    800023a4:	e04a                	sd	s2,0(sp)
    800023a6:	1000                	add	s0,sp,32
    800023a8:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023aa:	fffff097          	auipc	ra,0xfffff
    800023ae:	88e080e7          	jalr	-1906(ra) # 80000c38 <acquire>
  k = p->killed;
    800023b2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023b6:	8526                	mv	a0,s1
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	934080e7          	jalr	-1740(ra) # 80000cec <release>
  return k;
}
    800023c0:	854a                	mv	a0,s2
    800023c2:	60e2                	ld	ra,24(sp)
    800023c4:	6442                	ld	s0,16(sp)
    800023c6:	64a2                	ld	s1,8(sp)
    800023c8:	6902                	ld	s2,0(sp)
    800023ca:	6105                	add	sp,sp,32
    800023cc:	8082                	ret

00000000800023ce <wait>:
{
    800023ce:	715d                	add	sp,sp,-80
    800023d0:	e486                	sd	ra,72(sp)
    800023d2:	e0a2                	sd	s0,64(sp)
    800023d4:	fc26                	sd	s1,56(sp)
    800023d6:	f84a                	sd	s2,48(sp)
    800023d8:	f44e                	sd	s3,40(sp)
    800023da:	f052                	sd	s4,32(sp)
    800023dc:	ec56                	sd	s5,24(sp)
    800023de:	e85a                	sd	s6,16(sp)
    800023e0:	e45e                	sd	s7,8(sp)
    800023e2:	e062                	sd	s8,0(sp)
    800023e4:	0880                	add	s0,sp,80
    800023e6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	662080e7          	jalr	1634(ra) # 80001a4a <myproc>
    800023f0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023f2:	0000e517          	auipc	a0,0xe
    800023f6:	7c650513          	add	a0,a0,1990 # 80010bb8 <wait_lock>
    800023fa:	fffff097          	auipc	ra,0xfffff
    800023fe:	83e080e7          	jalr	-1986(ra) # 80000c38 <acquire>
    havekids = 0;
    80002402:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002404:	4a15                	li	s4,5
        havekids = 1;
    80002406:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002408:	00014997          	auipc	s3,0x14
    8000240c:	5c898993          	add	s3,s3,1480 # 800169d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002410:	0000ec17          	auipc	s8,0xe
    80002414:	7a8c0c13          	add	s8,s8,1960 # 80010bb8 <wait_lock>
    80002418:	a0d1                	j	800024dc <wait+0x10e>
          pid = pp->pid;
    8000241a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000241e:	000b0e63          	beqz	s6,8000243a <wait+0x6c>
    80002422:	4691                	li	a3,4
    80002424:	02c48613          	add	a2,s1,44
    80002428:	85da                	mv	a1,s6
    8000242a:	05093503          	ld	a0,80(s2)
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	2b4080e7          	jalr	692(ra) # 800016e2 <copyout>
    80002436:	04054163          	bltz	a0,80002478 <wait+0xaa>
          freeproc(pp);
    8000243a:	8526                	mv	a0,s1
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	7c0080e7          	jalr	1984(ra) # 80001bfc <freeproc>
          release(&pp->lock);
    80002444:	8526                	mv	a0,s1
    80002446:	fffff097          	auipc	ra,0xfffff
    8000244a:	8a6080e7          	jalr	-1882(ra) # 80000cec <release>
          release(&wait_lock);
    8000244e:	0000e517          	auipc	a0,0xe
    80002452:	76a50513          	add	a0,a0,1898 # 80010bb8 <wait_lock>
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	896080e7          	jalr	-1898(ra) # 80000cec <release>
}
    8000245e:	854e                	mv	a0,s3
    80002460:	60a6                	ld	ra,72(sp)
    80002462:	6406                	ld	s0,64(sp)
    80002464:	74e2                	ld	s1,56(sp)
    80002466:	7942                	ld	s2,48(sp)
    80002468:	79a2                	ld	s3,40(sp)
    8000246a:	7a02                	ld	s4,32(sp)
    8000246c:	6ae2                	ld	s5,24(sp)
    8000246e:	6b42                	ld	s6,16(sp)
    80002470:	6ba2                	ld	s7,8(sp)
    80002472:	6c02                	ld	s8,0(sp)
    80002474:	6161                	add	sp,sp,80
    80002476:	8082                	ret
            release(&pp->lock);
    80002478:	8526                	mv	a0,s1
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	872080e7          	jalr	-1934(ra) # 80000cec <release>
            release(&wait_lock);
    80002482:	0000e517          	auipc	a0,0xe
    80002486:	73650513          	add	a0,a0,1846 # 80010bb8 <wait_lock>
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	862080e7          	jalr	-1950(ra) # 80000cec <release>
            return -1;
    80002492:	59fd                	li	s3,-1
    80002494:	b7e9                	j	8000245e <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002496:	16848493          	add	s1,s1,360
    8000249a:	03348463          	beq	s1,s3,800024c2 <wait+0xf4>
      if(pp->parent == p){
    8000249e:	7c9c                	ld	a5,56(s1)
    800024a0:	ff279be3          	bne	a5,s2,80002496 <wait+0xc8>
        acquire(&pp->lock);
    800024a4:	8526                	mv	a0,s1
    800024a6:	ffffe097          	auipc	ra,0xffffe
    800024aa:	792080e7          	jalr	1938(ra) # 80000c38 <acquire>
        if(pp->state == ZOMBIE){
    800024ae:	4c9c                	lw	a5,24(s1)
    800024b0:	f74785e3          	beq	a5,s4,8000241a <wait+0x4c>
        release(&pp->lock);
    800024b4:	8526                	mv	a0,s1
    800024b6:	fffff097          	auipc	ra,0xfffff
    800024ba:	836080e7          	jalr	-1994(ra) # 80000cec <release>
        havekids = 1;
    800024be:	8756                	mv	a4,s5
    800024c0:	bfd9                	j	80002496 <wait+0xc8>
    if(!havekids || killed(p)){
    800024c2:	c31d                	beqz	a4,800024e8 <wait+0x11a>
    800024c4:	854a                	mv	a0,s2
    800024c6:	00000097          	auipc	ra,0x0
    800024ca:	ed6080e7          	jalr	-298(ra) # 8000239c <killed>
    800024ce:	ed09                	bnez	a0,800024e8 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024d0:	85e2                	mv	a1,s8
    800024d2:	854a                	mv	a0,s2
    800024d4:	00000097          	auipc	ra,0x0
    800024d8:	c20080e7          	jalr	-992(ra) # 800020f4 <sleep>
    havekids = 0;
    800024dc:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024de:	0000f497          	auipc	s1,0xf
    800024e2:	af248493          	add	s1,s1,-1294 # 80010fd0 <proc>
    800024e6:	bf65                	j	8000249e <wait+0xd0>
      release(&wait_lock);
    800024e8:	0000e517          	auipc	a0,0xe
    800024ec:	6d050513          	add	a0,a0,1744 # 80010bb8 <wait_lock>
    800024f0:	ffffe097          	auipc	ra,0xffffe
    800024f4:	7fc080e7          	jalr	2044(ra) # 80000cec <release>
      return -1;
    800024f8:	59fd                	li	s3,-1
    800024fa:	b795                	j	8000245e <wait+0x90>

00000000800024fc <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024fc:	7179                	add	sp,sp,-48
    800024fe:	f406                	sd	ra,40(sp)
    80002500:	f022                	sd	s0,32(sp)
    80002502:	ec26                	sd	s1,24(sp)
    80002504:	e84a                	sd	s2,16(sp)
    80002506:	e44e                	sd	s3,8(sp)
    80002508:	e052                	sd	s4,0(sp)
    8000250a:	1800                	add	s0,sp,48
    8000250c:	84aa                	mv	s1,a0
    8000250e:	892e                	mv	s2,a1
    80002510:	89b2                	mv	s3,a2
    80002512:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002514:	fffff097          	auipc	ra,0xfffff
    80002518:	536080e7          	jalr	1334(ra) # 80001a4a <myproc>
  if(user_dst){
    8000251c:	c08d                	beqz	s1,8000253e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000251e:	86d2                	mv	a3,s4
    80002520:	864e                	mv	a2,s3
    80002522:	85ca                	mv	a1,s2
    80002524:	6928                	ld	a0,80(a0)
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	1bc080e7          	jalr	444(ra) # 800016e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000252e:	70a2                	ld	ra,40(sp)
    80002530:	7402                	ld	s0,32(sp)
    80002532:	64e2                	ld	s1,24(sp)
    80002534:	6942                	ld	s2,16(sp)
    80002536:	69a2                	ld	s3,8(sp)
    80002538:	6a02                	ld	s4,0(sp)
    8000253a:	6145                	add	sp,sp,48
    8000253c:	8082                	ret
    memmove((char *)dst, src, len);
    8000253e:	000a061b          	sext.w	a2,s4
    80002542:	85ce                	mv	a1,s3
    80002544:	854a                	mv	a0,s2
    80002546:	fffff097          	auipc	ra,0xfffff
    8000254a:	84a080e7          	jalr	-1974(ra) # 80000d90 <memmove>
    return 0;
    8000254e:	8526                	mv	a0,s1
    80002550:	bff9                	j	8000252e <either_copyout+0x32>

0000000080002552 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002552:	7179                	add	sp,sp,-48
    80002554:	f406                	sd	ra,40(sp)
    80002556:	f022                	sd	s0,32(sp)
    80002558:	ec26                	sd	s1,24(sp)
    8000255a:	e84a                	sd	s2,16(sp)
    8000255c:	e44e                	sd	s3,8(sp)
    8000255e:	e052                	sd	s4,0(sp)
    80002560:	1800                	add	s0,sp,48
    80002562:	892a                	mv	s2,a0
    80002564:	84ae                	mv	s1,a1
    80002566:	89b2                	mv	s3,a2
    80002568:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000256a:	fffff097          	auipc	ra,0xfffff
    8000256e:	4e0080e7          	jalr	1248(ra) # 80001a4a <myproc>
  if(user_src){
    80002572:	c08d                	beqz	s1,80002594 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002574:	86d2                	mv	a3,s4
    80002576:	864e                	mv	a2,s3
    80002578:	85ca                	mv	a1,s2
    8000257a:	6928                	ld	a0,80(a0)
    8000257c:	fffff097          	auipc	ra,0xfffff
    80002580:	1f2080e7          	jalr	498(ra) # 8000176e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002584:	70a2                	ld	ra,40(sp)
    80002586:	7402                	ld	s0,32(sp)
    80002588:	64e2                	ld	s1,24(sp)
    8000258a:	6942                	ld	s2,16(sp)
    8000258c:	69a2                	ld	s3,8(sp)
    8000258e:	6a02                	ld	s4,0(sp)
    80002590:	6145                	add	sp,sp,48
    80002592:	8082                	ret
    memmove(dst, (char*)src, len);
    80002594:	000a061b          	sext.w	a2,s4
    80002598:	85ce                	mv	a1,s3
    8000259a:	854a                	mv	a0,s2
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	7f4080e7          	jalr	2036(ra) # 80000d90 <memmove>
    return 0;
    800025a4:	8526                	mv	a0,s1
    800025a6:	bff9                	j	80002584 <either_copyin+0x32>

00000000800025a8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025a8:	715d                	add	sp,sp,-80
    800025aa:	e486                	sd	ra,72(sp)
    800025ac:	e0a2                	sd	s0,64(sp)
    800025ae:	fc26                	sd	s1,56(sp)
    800025b0:	f84a                	sd	s2,48(sp)
    800025b2:	f44e                	sd	s3,40(sp)
    800025b4:	f052                	sd	s4,32(sp)
    800025b6:	ec56                	sd	s5,24(sp)
    800025b8:	e85a                	sd	s6,16(sp)
    800025ba:	e45e                	sd	s7,8(sp)
    800025bc:	0880                	add	s0,sp,80
  [ZOMBIE]    "ZOOMBIE"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025be:	00006517          	auipc	a0,0x6
    800025c2:	a5250513          	add	a0,a0,-1454 # 80008010 <etext+0x10>
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	fe4080e7          	jalr	-28(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ce:	0000f497          	auipc	s1,0xf
    800025d2:	b5a48493          	add	s1,s1,-1190 # 80011128 <proc+0x158>
    800025d6:	00014917          	auipc	s2,0x14
    800025da:	55290913          	add	s2,s2,1362 # 80016b28 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025de:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025e0:	00006997          	auipc	s3,0x6
    800025e4:	c8098993          	add	s3,s3,-896 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    800025e8:	00006a97          	auipc	s5,0x6
    800025ec:	c80a8a93          	add	s5,s5,-896 # 80008268 <etext+0x268>
    printf("\n");
    800025f0:	00006a17          	auipc	s4,0x6
    800025f4:	a20a0a13          	add	s4,s4,-1504 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025f8:	00006b97          	auipc	s7,0x6
    800025fc:	1b0b8b93          	add	s7,s7,432 # 800087a8 <states.0>
    80002600:	a00d                	j	80002622 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002602:	ed86a583          	lw	a1,-296(a3)
    80002606:	8556                	mv	a0,s5
    80002608:	ffffe097          	auipc	ra,0xffffe
    8000260c:	fa2080e7          	jalr	-94(ra) # 800005aa <printf>
    printf("\n");
    80002610:	8552                	mv	a0,s4
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	f98080e7          	jalr	-104(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000261a:	16848493          	add	s1,s1,360
    8000261e:	03248263          	beq	s1,s2,80002642 <procdump+0x9a>
    if(p->state == UNUSED)
    80002622:	86a6                	mv	a3,s1
    80002624:	ec04a783          	lw	a5,-320(s1)
    80002628:	dbed                	beqz	a5,8000261a <procdump+0x72>
      state = "???";
    8000262a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000262c:	fcfb6be3          	bltu	s6,a5,80002602 <procdump+0x5a>
    80002630:	02079713          	sll	a4,a5,0x20
    80002634:	01d75793          	srl	a5,a4,0x1d
    80002638:	97de                	add	a5,a5,s7
    8000263a:	6390                	ld	a2,0(a5)
    8000263c:	f279                	bnez	a2,80002602 <procdump+0x5a>
      state = "???";
    8000263e:	864e                	mv	a2,s3
    80002640:	b7c9                	j	80002602 <procdump+0x5a>
  }
}
    80002642:	60a6                	ld	ra,72(sp)
    80002644:	6406                	ld	s0,64(sp)
    80002646:	74e2                	ld	s1,56(sp)
    80002648:	7942                	ld	s2,48(sp)
    8000264a:	79a2                	ld	s3,40(sp)
    8000264c:	7a02                	ld	s4,32(sp)
    8000264e:	6ae2                	ld	s5,24(sp)
    80002650:	6b42                	ld	s6,16(sp)
    80002652:	6ba2                	ld	s7,8(sp)
    80002654:	6161                	add	sp,sp,80
    80002656:	8082                	ret

0000000080002658 <ps>:


void 
ps(void)
{
    80002658:	711d                	add	sp,sp,-96
    8000265a:	ec86                	sd	ra,88(sp)
    8000265c:	e8a2                	sd	s0,80(sp)
    8000265e:	e4a6                	sd	s1,72(sp)
    80002660:	e0ca                	sd	s2,64(sp)
    80002662:	fc4e                	sd	s3,56(sp)
    80002664:	f852                	sd	s4,48(sp)
    80002666:	f456                	sd	s5,40(sp)
    80002668:	f05a                	sd	s6,32(sp)
    8000266a:	ec5e                	sd	s7,24(sp)
    8000266c:	e862                	sd	s8,16(sp)
    8000266e:	e466                	sd	s9,8(sp)
    80002670:	e06a                	sd	s10,0(sp)
    80002672:	1080                	add	s0,sp,96
    struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++){
    80002674:	0000f497          	auipc	s1,0xf
    80002678:	ab448493          	add	s1,s1,-1356 # 80011128 <proc+0x158>
    8000267c:	00014997          	auipc	s3,0x14
    80002680:	4ac98993          	add	s3,s3,1196 # 80016b28 <bcache+0x140>
        break;
      case ZOMBIE:
        state = "5";
        break;
      default:
        state = "-1";
    80002684:	00006d17          	auipc	s10,0x6
    80002688:	c1cd0d13          	add	s10,s10,-996 # 800082a0 <etext+0x2a0>
    switch (p->state){
    8000268c:	00006917          	auipc	s2,0x6
    80002690:	10490913          	add	s2,s2,260 # 80008790 <digits+0x18>
    80002694:	00006a97          	auipc	s5,0x6
    80002698:	fb4a8a93          	add	s5,s5,-76 # 80008648 <etext+0x648>
        state = "5";
    8000269c:	00006c97          	auipc	s9,0x6
    800026a0:	bfcc8c93          	add	s9,s9,-1028 # 80008298 <etext+0x298>
        state = "4";
    800026a4:	00006c17          	auipc	s8,0x6
    800026a8:	becc0c13          	add	s8,s8,-1044 # 80008290 <etext+0x290>
        state = "3";
    800026ac:	00006b97          	auipc	s7,0x6
    800026b0:	bdcb8b93          	add	s7,s7,-1060 # 80008288 <etext+0x288>
        state = "2";
    800026b4:	00006b17          	auipc	s6,0x6
    800026b8:	bccb0b13          	add	s6,s6,-1076 # 80008280 <etext+0x280>
        state = "0";
    800026bc:	00006a17          	auipc	s4,0x6
    800026c0:	bbca0a13          	add	s4,s4,-1092 # 80008278 <etext+0x278>
    800026c4:	a005                	j	800026e4 <ps+0x8c>
    800026c6:	86d2                	mv	a3,s4
        break;
    }
    printf("%s (%d): %s\n", p->name, p->pid, state);
    800026c8:	ed85a603          	lw	a2,-296(a1)
    800026cc:	00006517          	auipc	a0,0x6
    800026d0:	bdc50513          	add	a0,a0,-1060 # 800082a8 <etext+0x2a8>
    800026d4:	ffffe097          	auipc	ra,0xffffe
    800026d8:	ed6080e7          	jalr	-298(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++){
    800026dc:	16848493          	add	s1,s1,360
    800026e0:	03348a63          	beq	s1,s3,80002714 <ps+0xbc>
    if (p->state == UNUSED){
    800026e4:	85a6                	mv	a1,s1
    800026e6:	ec04a783          	lw	a5,-320(s1)
    800026ea:	dbed                	beqz	a5,800026dc <ps+0x84>
    switch (p->state){
    800026ec:	4715                	li	a4,5
    800026ee:	00f76f63          	bltu	a4,a5,8000270c <ps+0xb4>
    800026f2:	078a                	sll	a5,a5,0x2
    800026f4:	97ca                	add	a5,a5,s2
    800026f6:	439c                	lw	a5,0(a5)
    800026f8:	97ca                	add	a5,a5,s2
    800026fa:	8782                	jr	a5
        state = "2";
    800026fc:	86da                	mv	a3,s6
        break;
    800026fe:	b7e9                	j	800026c8 <ps+0x70>
        state = "3";
    80002700:	86de                	mv	a3,s7
        break;
    80002702:	b7d9                	j	800026c8 <ps+0x70>
        state = "4";
    80002704:	86e2                	mv	a3,s8
        break;
    80002706:	b7c9                	j	800026c8 <ps+0x70>
        state = "5";
    80002708:	86e6                	mv	a3,s9
        break;
    8000270a:	bf7d                	j	800026c8 <ps+0x70>
        state = "-1";
    8000270c:	86ea                	mv	a3,s10
        break;
    8000270e:	bf6d                	j	800026c8 <ps+0x70>
    switch (p->state){
    80002710:	86d6                	mv	a3,s5
    80002712:	bf5d                	j	800026c8 <ps+0x70>
  }
}
    80002714:	60e6                	ld	ra,88(sp)
    80002716:	6446                	ld	s0,80(sp)
    80002718:	64a6                	ld	s1,72(sp)
    8000271a:	6906                	ld	s2,64(sp)
    8000271c:	79e2                	ld	s3,56(sp)
    8000271e:	7a42                	ld	s4,48(sp)
    80002720:	7aa2                	ld	s5,40(sp)
    80002722:	7b02                	ld	s6,32(sp)
    80002724:	6be2                	ld	s7,24(sp)
    80002726:	6c42                	ld	s8,16(sp)
    80002728:	6ca2                	ld	s9,8(sp)
    8000272a:	6d02                	ld	s10,0(sp)
    8000272c:	6125                	add	sp,sp,96
    8000272e:	8082                	ret

0000000080002730 <swtch>:
    80002730:	00153023          	sd	ra,0(a0)
    80002734:	00253423          	sd	sp,8(a0)
    80002738:	e900                	sd	s0,16(a0)
    8000273a:	ed04                	sd	s1,24(a0)
    8000273c:	03253023          	sd	s2,32(a0)
    80002740:	03353423          	sd	s3,40(a0)
    80002744:	03453823          	sd	s4,48(a0)
    80002748:	03553c23          	sd	s5,56(a0)
    8000274c:	05653023          	sd	s6,64(a0)
    80002750:	05753423          	sd	s7,72(a0)
    80002754:	05853823          	sd	s8,80(a0)
    80002758:	05953c23          	sd	s9,88(a0)
    8000275c:	07a53023          	sd	s10,96(a0)
    80002760:	07b53423          	sd	s11,104(a0)
    80002764:	0005b083          	ld	ra,0(a1)
    80002768:	0085b103          	ld	sp,8(a1)
    8000276c:	6980                	ld	s0,16(a1)
    8000276e:	6d84                	ld	s1,24(a1)
    80002770:	0205b903          	ld	s2,32(a1)
    80002774:	0285b983          	ld	s3,40(a1)
    80002778:	0305ba03          	ld	s4,48(a1)
    8000277c:	0385ba83          	ld	s5,56(a1)
    80002780:	0405bb03          	ld	s6,64(a1)
    80002784:	0485bb83          	ld	s7,72(a1)
    80002788:	0505bc03          	ld	s8,80(a1)
    8000278c:	0585bc83          	ld	s9,88(a1)
    80002790:	0605bd03          	ld	s10,96(a1)
    80002794:	0685bd83          	ld	s11,104(a1)
    80002798:	8082                	ret

000000008000279a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000279a:	1141                	add	sp,sp,-16
    8000279c:	e406                	sd	ra,8(sp)
    8000279e:	e022                	sd	s0,0(sp)
    800027a0:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    800027a2:	00006597          	auipc	a1,0x6
    800027a6:	b5658593          	add	a1,a1,-1194 # 800082f8 <etext+0x2f8>
    800027aa:	00014517          	auipc	a0,0x14
    800027ae:	22650513          	add	a0,a0,550 # 800169d0 <tickslock>
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	3f6080e7          	jalr	1014(ra) # 80000ba8 <initlock>
}
    800027ba:	60a2                	ld	ra,8(sp)
    800027bc:	6402                	ld	s0,0(sp)
    800027be:	0141                	add	sp,sp,16
    800027c0:	8082                	ret

00000000800027c2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800027c2:	1141                	add	sp,sp,-16
    800027c4:	e422                	sd	s0,8(sp)
    800027c6:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027c8:	00003797          	auipc	a5,0x3
    800027cc:	5b878793          	add	a5,a5,1464 # 80005d80 <kernelvec>
    800027d0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800027d4:	6422                	ld	s0,8(sp)
    800027d6:	0141                	add	sp,sp,16
    800027d8:	8082                	ret

00000000800027da <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027da:	1141                	add	sp,sp,-16
    800027dc:	e406                	sd	ra,8(sp)
    800027de:	e022                	sd	s0,0(sp)
    800027e0:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    800027e2:	fffff097          	auipc	ra,0xfffff
    800027e6:	268080e7          	jalr	616(ra) # 80001a4a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ea:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027ee:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027f0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800027f4:	00005697          	auipc	a3,0x5
    800027f8:	80c68693          	add	a3,a3,-2036 # 80007000 <_trampoline>
    800027fc:	00005717          	auipc	a4,0x5
    80002800:	80470713          	add	a4,a4,-2044 # 80007000 <_trampoline>
    80002804:	8f15                	sub	a4,a4,a3
    80002806:	040007b7          	lui	a5,0x4000
    8000280a:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000280c:	07b2                	sll	a5,a5,0xc
    8000280e:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002810:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002814:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002816:	18002673          	csrr	a2,satp
    8000281a:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000281c:	6d30                	ld	a2,88(a0)
    8000281e:	6138                	ld	a4,64(a0)
    80002820:	6585                	lui	a1,0x1
    80002822:	972e                	add	a4,a4,a1
    80002824:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002826:	6d38                	ld	a4,88(a0)
    80002828:	00000617          	auipc	a2,0x0
    8000282c:	13860613          	add	a2,a2,312 # 80002960 <usertrap>
    80002830:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002832:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002834:	8612                	mv	a2,tp
    80002836:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002838:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000283c:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002840:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002844:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002848:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000284a:	6f18                	ld	a4,24(a4)
    8000284c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002850:	6928                	ld	a0,80(a0)
    80002852:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002854:	00005717          	auipc	a4,0x5
    80002858:	84870713          	add	a4,a4,-1976 # 8000709c <userret>
    8000285c:	8f15                	sub	a4,a4,a3
    8000285e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002860:	577d                	li	a4,-1
    80002862:	177e                	sll	a4,a4,0x3f
    80002864:	8d59                	or	a0,a0,a4
    80002866:	9782                	jalr	a5
}
    80002868:	60a2                	ld	ra,8(sp)
    8000286a:	6402                	ld	s0,0(sp)
    8000286c:	0141                	add	sp,sp,16
    8000286e:	8082                	ret

0000000080002870 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002870:	1101                	add	sp,sp,-32
    80002872:	ec06                	sd	ra,24(sp)
    80002874:	e822                	sd	s0,16(sp)
    80002876:	e426                	sd	s1,8(sp)
    80002878:	1000                	add	s0,sp,32
  acquire(&tickslock);
    8000287a:	00014497          	auipc	s1,0x14
    8000287e:	15648493          	add	s1,s1,342 # 800169d0 <tickslock>
    80002882:	8526                	mv	a0,s1
    80002884:	ffffe097          	auipc	ra,0xffffe
    80002888:	3b4080e7          	jalr	948(ra) # 80000c38 <acquire>
  ticks++;
    8000288c:	00006517          	auipc	a0,0x6
    80002890:	0a450513          	add	a0,a0,164 # 80008930 <ticks>
    80002894:	411c                	lw	a5,0(a0)
    80002896:	2785                	addw	a5,a5,1
    80002898:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000289a:	00000097          	auipc	ra,0x0
    8000289e:	8be080e7          	jalr	-1858(ra) # 80002158 <wakeup>
  release(&tickslock);
    800028a2:	8526                	mv	a0,s1
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	448080e7          	jalr	1096(ra) # 80000cec <release>
}
    800028ac:	60e2                	ld	ra,24(sp)
    800028ae:	6442                	ld	s0,16(sp)
    800028b0:	64a2                	ld	s1,8(sp)
    800028b2:	6105                	add	sp,sp,32
    800028b4:	8082                	ret

00000000800028b6 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b6:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800028ba:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    800028bc:	0a07d163          	bgez	a5,8000295e <devintr+0xa8>
{
    800028c0:	1101                	add	sp,sp,-32
    800028c2:	ec06                	sd	ra,24(sp)
    800028c4:	e822                	sd	s0,16(sp)
    800028c6:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    800028c8:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800028cc:	46a5                	li	a3,9
    800028ce:	00d70c63          	beq	a4,a3,800028e6 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    800028d2:	577d                	li	a4,-1
    800028d4:	177e                	sll	a4,a4,0x3f
    800028d6:	0705                	add	a4,a4,1
    return 0;
    800028d8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800028da:	06e78163          	beq	a5,a4,8000293c <devintr+0x86>
  }
}
    800028de:	60e2                	ld	ra,24(sp)
    800028e0:	6442                	ld	s0,16(sp)
    800028e2:	6105                	add	sp,sp,32
    800028e4:	8082                	ret
    800028e6:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800028e8:	00003097          	auipc	ra,0x3
    800028ec:	5a4080e7          	jalr	1444(ra) # 80005e8c <plic_claim>
    800028f0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028f2:	47a9                	li	a5,10
    800028f4:	00f50963          	beq	a0,a5,80002906 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    800028f8:	4785                	li	a5,1
    800028fa:	00f50b63          	beq	a0,a5,80002910 <devintr+0x5a>
    return 1;
    800028fe:	4505                	li	a0,1
    } else if(irq){
    80002900:	ec89                	bnez	s1,8000291a <devintr+0x64>
    80002902:	64a2                	ld	s1,8(sp)
    80002904:	bfe9                	j	800028de <devintr+0x28>
      uartintr();
    80002906:	ffffe097          	auipc	ra,0xffffe
    8000290a:	0f4080e7          	jalr	244(ra) # 800009fa <uartintr>
    if(irq)
    8000290e:	a839                	j	8000292c <devintr+0x76>
      virtio_disk_intr();
    80002910:	00004097          	auipc	ra,0x4
    80002914:	aa6080e7          	jalr	-1370(ra) # 800063b6 <virtio_disk_intr>
    if(irq)
    80002918:	a811                	j	8000292c <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    8000291a:	85a6                	mv	a1,s1
    8000291c:	00006517          	auipc	a0,0x6
    80002920:	9e450513          	add	a0,a0,-1564 # 80008300 <etext+0x300>
    80002924:	ffffe097          	auipc	ra,0xffffe
    80002928:	c86080e7          	jalr	-890(ra) # 800005aa <printf>
      plic_complete(irq);
    8000292c:	8526                	mv	a0,s1
    8000292e:	00003097          	auipc	ra,0x3
    80002932:	582080e7          	jalr	1410(ra) # 80005eb0 <plic_complete>
    return 1;
    80002936:	4505                	li	a0,1
    80002938:	64a2                	ld	s1,8(sp)
    8000293a:	b755                	j	800028de <devintr+0x28>
    if(cpuid() == 0){
    8000293c:	fffff097          	auipc	ra,0xfffff
    80002940:	0e2080e7          	jalr	226(ra) # 80001a1e <cpuid>
    80002944:	c901                	beqz	a0,80002954 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002946:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000294a:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000294c:	14479073          	csrw	sip,a5
    return 2;
    80002950:	4509                	li	a0,2
    80002952:	b771                	j	800028de <devintr+0x28>
      clockintr();
    80002954:	00000097          	auipc	ra,0x0
    80002958:	f1c080e7          	jalr	-228(ra) # 80002870 <clockintr>
    8000295c:	b7ed                	j	80002946 <devintr+0x90>
}
    8000295e:	8082                	ret

0000000080002960 <usertrap>:
{
    80002960:	1101                	add	sp,sp,-32
    80002962:	ec06                	sd	ra,24(sp)
    80002964:	e822                	sd	s0,16(sp)
    80002966:	e426                	sd	s1,8(sp)
    80002968:	e04a                	sd	s2,0(sp)
    8000296a:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000296c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002970:	1007f793          	and	a5,a5,256
    80002974:	e3b1                	bnez	a5,800029b8 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002976:	00003797          	auipc	a5,0x3
    8000297a:	40a78793          	add	a5,a5,1034 # 80005d80 <kernelvec>
    8000297e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002982:	fffff097          	auipc	ra,0xfffff
    80002986:	0c8080e7          	jalr	200(ra) # 80001a4a <myproc>
    8000298a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000298c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000298e:	14102773          	csrr	a4,sepc
    80002992:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002994:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002998:	47a1                	li	a5,8
    8000299a:	02f70763          	beq	a4,a5,800029c8 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000299e:	00000097          	auipc	ra,0x0
    800029a2:	f18080e7          	jalr	-232(ra) # 800028b6 <devintr>
    800029a6:	892a                	mv	s2,a0
    800029a8:	c151                	beqz	a0,80002a2c <usertrap+0xcc>
  if(killed(p))
    800029aa:	8526                	mv	a0,s1
    800029ac:	00000097          	auipc	ra,0x0
    800029b0:	9f0080e7          	jalr	-1552(ra) # 8000239c <killed>
    800029b4:	c929                	beqz	a0,80002a06 <usertrap+0xa6>
    800029b6:	a099                	j	800029fc <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800029b8:	00006517          	auipc	a0,0x6
    800029bc:	96850513          	add	a0,a0,-1688 # 80008320 <etext+0x320>
    800029c0:	ffffe097          	auipc	ra,0xffffe
    800029c4:	ba0080e7          	jalr	-1120(ra) # 80000560 <panic>
    if(killed(p))
    800029c8:	00000097          	auipc	ra,0x0
    800029cc:	9d4080e7          	jalr	-1580(ra) # 8000239c <killed>
    800029d0:	e921                	bnez	a0,80002a20 <usertrap+0xc0>
    p->trapframe->epc += 4;
    800029d2:	6cb8                	ld	a4,88(s1)
    800029d4:	6f1c                	ld	a5,24(a4)
    800029d6:	0791                	add	a5,a5,4
    800029d8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029da:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029de:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029e2:	10079073          	csrw	sstatus,a5
    syscall();
    800029e6:	00000097          	auipc	ra,0x0
    800029ea:	2d4080e7          	jalr	724(ra) # 80002cba <syscall>
  if(killed(p))
    800029ee:	8526                	mv	a0,s1
    800029f0:	00000097          	auipc	ra,0x0
    800029f4:	9ac080e7          	jalr	-1620(ra) # 8000239c <killed>
    800029f8:	c911                	beqz	a0,80002a0c <usertrap+0xac>
    800029fa:	4901                	li	s2,0
    exit(-1);
    800029fc:	557d                	li	a0,-1
    800029fe:	00000097          	auipc	ra,0x0
    80002a02:	82a080e7          	jalr	-2006(ra) # 80002228 <exit>
  if(which_dev == 2)
    80002a06:	4789                	li	a5,2
    80002a08:	04f90f63          	beq	s2,a5,80002a66 <usertrap+0x106>
  usertrapret();
    80002a0c:	00000097          	auipc	ra,0x0
    80002a10:	dce080e7          	jalr	-562(ra) # 800027da <usertrapret>
}
    80002a14:	60e2                	ld	ra,24(sp)
    80002a16:	6442                	ld	s0,16(sp)
    80002a18:	64a2                	ld	s1,8(sp)
    80002a1a:	6902                	ld	s2,0(sp)
    80002a1c:	6105                	add	sp,sp,32
    80002a1e:	8082                	ret
      exit(-1);
    80002a20:	557d                	li	a0,-1
    80002a22:	00000097          	auipc	ra,0x0
    80002a26:	806080e7          	jalr	-2042(ra) # 80002228 <exit>
    80002a2a:	b765                	j	800029d2 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a2c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a30:	5890                	lw	a2,48(s1)
    80002a32:	00006517          	auipc	a0,0x6
    80002a36:	90e50513          	add	a0,a0,-1778 # 80008340 <etext+0x340>
    80002a3a:	ffffe097          	auipc	ra,0xffffe
    80002a3e:	b70080e7          	jalr	-1168(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a42:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a46:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a4a:	00006517          	auipc	a0,0x6
    80002a4e:	92650513          	add	a0,a0,-1754 # 80008370 <etext+0x370>
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	b58080e7          	jalr	-1192(ra) # 800005aa <printf>
    setkilled(p);
    80002a5a:	8526                	mv	a0,s1
    80002a5c:	00000097          	auipc	ra,0x0
    80002a60:	914080e7          	jalr	-1772(ra) # 80002370 <setkilled>
    80002a64:	b769                	j	800029ee <usertrap+0x8e>
    yield();
    80002a66:	fffff097          	auipc	ra,0xfffff
    80002a6a:	652080e7          	jalr	1618(ra) # 800020b8 <yield>
    80002a6e:	bf79                	j	80002a0c <usertrap+0xac>

0000000080002a70 <kerneltrap>:
{
    80002a70:	7179                	add	sp,sp,-48
    80002a72:	f406                	sd	ra,40(sp)
    80002a74:	f022                	sd	s0,32(sp)
    80002a76:	ec26                	sd	s1,24(sp)
    80002a78:	e84a                	sd	s2,16(sp)
    80002a7a:	e44e                	sd	s3,8(sp)
    80002a7c:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a7e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a82:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a86:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a8a:	1004f793          	and	a5,s1,256
    80002a8e:	cb85                	beqz	a5,80002abe <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a90:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a94:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002a96:	ef85                	bnez	a5,80002ace <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a98:	00000097          	auipc	ra,0x0
    80002a9c:	e1e080e7          	jalr	-482(ra) # 800028b6 <devintr>
    80002aa0:	cd1d                	beqz	a0,80002ade <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002aa2:	4789                	li	a5,2
    80002aa4:	06f50a63          	beq	a0,a5,80002b18 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002aa8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aac:	10049073          	csrw	sstatus,s1
}
    80002ab0:	70a2                	ld	ra,40(sp)
    80002ab2:	7402                	ld	s0,32(sp)
    80002ab4:	64e2                	ld	s1,24(sp)
    80002ab6:	6942                	ld	s2,16(sp)
    80002ab8:	69a2                	ld	s3,8(sp)
    80002aba:	6145                	add	sp,sp,48
    80002abc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002abe:	00006517          	auipc	a0,0x6
    80002ac2:	8d250513          	add	a0,a0,-1838 # 80008390 <etext+0x390>
    80002ac6:	ffffe097          	auipc	ra,0xffffe
    80002aca:	a9a080e7          	jalr	-1382(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002ace:	00006517          	auipc	a0,0x6
    80002ad2:	8ea50513          	add	a0,a0,-1814 # 800083b8 <etext+0x3b8>
    80002ad6:	ffffe097          	auipc	ra,0xffffe
    80002ada:	a8a080e7          	jalr	-1398(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002ade:	85ce                	mv	a1,s3
    80002ae0:	00006517          	auipc	a0,0x6
    80002ae4:	8f850513          	add	a0,a0,-1800 # 800083d8 <etext+0x3d8>
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	ac2080e7          	jalr	-1342(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002af0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002af4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002af8:	00006517          	auipc	a0,0x6
    80002afc:	8f050513          	add	a0,a0,-1808 # 800083e8 <etext+0x3e8>
    80002b00:	ffffe097          	auipc	ra,0xffffe
    80002b04:	aaa080e7          	jalr	-1366(ra) # 800005aa <printf>
    panic("kerneltrap");
    80002b08:	00006517          	auipc	a0,0x6
    80002b0c:	8f850513          	add	a0,a0,-1800 # 80008400 <etext+0x400>
    80002b10:	ffffe097          	auipc	ra,0xffffe
    80002b14:	a50080e7          	jalr	-1456(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b18:	fffff097          	auipc	ra,0xfffff
    80002b1c:	f32080e7          	jalr	-206(ra) # 80001a4a <myproc>
    80002b20:	d541                	beqz	a0,80002aa8 <kerneltrap+0x38>
    80002b22:	fffff097          	auipc	ra,0xfffff
    80002b26:	f28080e7          	jalr	-216(ra) # 80001a4a <myproc>
    80002b2a:	4d18                	lw	a4,24(a0)
    80002b2c:	4791                	li	a5,4
    80002b2e:	f6f71de3          	bne	a4,a5,80002aa8 <kerneltrap+0x38>
    yield();
    80002b32:	fffff097          	auipc	ra,0xfffff
    80002b36:	586080e7          	jalr	1414(ra) # 800020b8 <yield>
    80002b3a:	b7bd                	j	80002aa8 <kerneltrap+0x38>

0000000080002b3c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b3c:	1101                	add	sp,sp,-32
    80002b3e:	ec06                	sd	ra,24(sp)
    80002b40:	e822                	sd	s0,16(sp)
    80002b42:	e426                	sd	s1,8(sp)
    80002b44:	1000                	add	s0,sp,32
    80002b46:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b48:	fffff097          	auipc	ra,0xfffff
    80002b4c:	f02080e7          	jalr	-254(ra) # 80001a4a <myproc>
  switch (n) {
    80002b50:	4795                	li	a5,5
    80002b52:	0497e163          	bltu	a5,s1,80002b94 <argraw+0x58>
    80002b56:	048a                	sll	s1,s1,0x2
    80002b58:	00006717          	auipc	a4,0x6
    80002b5c:	c8070713          	add	a4,a4,-896 # 800087d8 <states.0+0x30>
    80002b60:	94ba                	add	s1,s1,a4
    80002b62:	409c                	lw	a5,0(s1)
    80002b64:	97ba                	add	a5,a5,a4
    80002b66:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b68:	6d3c                	ld	a5,88(a0)
    80002b6a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b6c:	60e2                	ld	ra,24(sp)
    80002b6e:	6442                	ld	s0,16(sp)
    80002b70:	64a2                	ld	s1,8(sp)
    80002b72:	6105                	add	sp,sp,32
    80002b74:	8082                	ret
    return p->trapframe->a1;
    80002b76:	6d3c                	ld	a5,88(a0)
    80002b78:	7fa8                	ld	a0,120(a5)
    80002b7a:	bfcd                	j	80002b6c <argraw+0x30>
    return p->trapframe->a2;
    80002b7c:	6d3c                	ld	a5,88(a0)
    80002b7e:	63c8                	ld	a0,128(a5)
    80002b80:	b7f5                	j	80002b6c <argraw+0x30>
    return p->trapframe->a3;
    80002b82:	6d3c                	ld	a5,88(a0)
    80002b84:	67c8                	ld	a0,136(a5)
    80002b86:	b7dd                	j	80002b6c <argraw+0x30>
    return p->trapframe->a4;
    80002b88:	6d3c                	ld	a5,88(a0)
    80002b8a:	6bc8                	ld	a0,144(a5)
    80002b8c:	b7c5                	j	80002b6c <argraw+0x30>
    return p->trapframe->a5;
    80002b8e:	6d3c                	ld	a5,88(a0)
    80002b90:	6fc8                	ld	a0,152(a5)
    80002b92:	bfe9                	j	80002b6c <argraw+0x30>
  panic("argraw");
    80002b94:	00006517          	auipc	a0,0x6
    80002b98:	87c50513          	add	a0,a0,-1924 # 80008410 <etext+0x410>
    80002b9c:	ffffe097          	auipc	ra,0xffffe
    80002ba0:	9c4080e7          	jalr	-1596(ra) # 80000560 <panic>

0000000080002ba4 <fetchaddr>:
{
    80002ba4:	1101                	add	sp,sp,-32
    80002ba6:	ec06                	sd	ra,24(sp)
    80002ba8:	e822                	sd	s0,16(sp)
    80002baa:	e426                	sd	s1,8(sp)
    80002bac:	e04a                	sd	s2,0(sp)
    80002bae:	1000                	add	s0,sp,32
    80002bb0:	84aa                	mv	s1,a0
    80002bb2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002bb4:	fffff097          	auipc	ra,0xfffff
    80002bb8:	e96080e7          	jalr	-362(ra) # 80001a4a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002bbc:	653c                	ld	a5,72(a0)
    80002bbe:	02f4f863          	bgeu	s1,a5,80002bee <fetchaddr+0x4a>
    80002bc2:	00848713          	add	a4,s1,8
    80002bc6:	02e7e663          	bltu	a5,a4,80002bf2 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002bca:	46a1                	li	a3,8
    80002bcc:	8626                	mv	a2,s1
    80002bce:	85ca                	mv	a1,s2
    80002bd0:	6928                	ld	a0,80(a0)
    80002bd2:	fffff097          	auipc	ra,0xfffff
    80002bd6:	b9c080e7          	jalr	-1124(ra) # 8000176e <copyin>
    80002bda:	00a03533          	snez	a0,a0
    80002bde:	40a00533          	neg	a0,a0
}
    80002be2:	60e2                	ld	ra,24(sp)
    80002be4:	6442                	ld	s0,16(sp)
    80002be6:	64a2                	ld	s1,8(sp)
    80002be8:	6902                	ld	s2,0(sp)
    80002bea:	6105                	add	sp,sp,32
    80002bec:	8082                	ret
    return -1;
    80002bee:	557d                	li	a0,-1
    80002bf0:	bfcd                	j	80002be2 <fetchaddr+0x3e>
    80002bf2:	557d                	li	a0,-1
    80002bf4:	b7fd                	j	80002be2 <fetchaddr+0x3e>

0000000080002bf6 <fetchstr>:
{
    80002bf6:	7179                	add	sp,sp,-48
    80002bf8:	f406                	sd	ra,40(sp)
    80002bfa:	f022                	sd	s0,32(sp)
    80002bfc:	ec26                	sd	s1,24(sp)
    80002bfe:	e84a                	sd	s2,16(sp)
    80002c00:	e44e                	sd	s3,8(sp)
    80002c02:	1800                	add	s0,sp,48
    80002c04:	892a                	mv	s2,a0
    80002c06:	84ae                	mv	s1,a1
    80002c08:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c0a:	fffff097          	auipc	ra,0xfffff
    80002c0e:	e40080e7          	jalr	-448(ra) # 80001a4a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c12:	86ce                	mv	a3,s3
    80002c14:	864a                	mv	a2,s2
    80002c16:	85a6                	mv	a1,s1
    80002c18:	6928                	ld	a0,80(a0)
    80002c1a:	fffff097          	auipc	ra,0xfffff
    80002c1e:	be2080e7          	jalr	-1054(ra) # 800017fc <copyinstr>
    80002c22:	00054e63          	bltz	a0,80002c3e <fetchstr+0x48>
  return strlen(buf);
    80002c26:	8526                	mv	a0,s1
    80002c28:	ffffe097          	auipc	ra,0xffffe
    80002c2c:	280080e7          	jalr	640(ra) # 80000ea8 <strlen>
}
    80002c30:	70a2                	ld	ra,40(sp)
    80002c32:	7402                	ld	s0,32(sp)
    80002c34:	64e2                	ld	s1,24(sp)
    80002c36:	6942                	ld	s2,16(sp)
    80002c38:	69a2                	ld	s3,8(sp)
    80002c3a:	6145                	add	sp,sp,48
    80002c3c:	8082                	ret
    return -1;
    80002c3e:	557d                	li	a0,-1
    80002c40:	bfc5                	j	80002c30 <fetchstr+0x3a>

0000000080002c42 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002c42:	1101                	add	sp,sp,-32
    80002c44:	ec06                	sd	ra,24(sp)
    80002c46:	e822                	sd	s0,16(sp)
    80002c48:	e426                	sd	s1,8(sp)
    80002c4a:	1000                	add	s0,sp,32
    80002c4c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c4e:	00000097          	auipc	ra,0x0
    80002c52:	eee080e7          	jalr	-274(ra) # 80002b3c <argraw>
    80002c56:	c088                	sw	a0,0(s1)
}
    80002c58:	60e2                	ld	ra,24(sp)
    80002c5a:	6442                	ld	s0,16(sp)
    80002c5c:	64a2                	ld	s1,8(sp)
    80002c5e:	6105                	add	sp,sp,32
    80002c60:	8082                	ret

0000000080002c62 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c62:	1101                	add	sp,sp,-32
    80002c64:	ec06                	sd	ra,24(sp)
    80002c66:	e822                	sd	s0,16(sp)
    80002c68:	e426                	sd	s1,8(sp)
    80002c6a:	1000                	add	s0,sp,32
    80002c6c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	ece080e7          	jalr	-306(ra) # 80002b3c <argraw>
    80002c76:	e088                	sd	a0,0(s1)
}
    80002c78:	60e2                	ld	ra,24(sp)
    80002c7a:	6442                	ld	s0,16(sp)
    80002c7c:	64a2                	ld	s1,8(sp)
    80002c7e:	6105                	add	sp,sp,32
    80002c80:	8082                	ret

0000000080002c82 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c82:	7179                	add	sp,sp,-48
    80002c84:	f406                	sd	ra,40(sp)
    80002c86:	f022                	sd	s0,32(sp)
    80002c88:	ec26                	sd	s1,24(sp)
    80002c8a:	e84a                	sd	s2,16(sp)
    80002c8c:	1800                	add	s0,sp,48
    80002c8e:	84ae                	mv	s1,a1
    80002c90:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c92:	fd840593          	add	a1,s0,-40
    80002c96:	00000097          	auipc	ra,0x0
    80002c9a:	fcc080e7          	jalr	-52(ra) # 80002c62 <argaddr>
  return fetchstr(addr, buf, max);
    80002c9e:	864a                	mv	a2,s2
    80002ca0:	85a6                	mv	a1,s1
    80002ca2:	fd843503          	ld	a0,-40(s0)
    80002ca6:	00000097          	auipc	ra,0x0
    80002caa:	f50080e7          	jalr	-176(ra) # 80002bf6 <fetchstr>
}
    80002cae:	70a2                	ld	ra,40(sp)
    80002cb0:	7402                	ld	s0,32(sp)
    80002cb2:	64e2                	ld	s1,24(sp)
    80002cb4:	6942                	ld	s2,16(sp)
    80002cb6:	6145                	add	sp,sp,48
    80002cb8:	8082                	ret

0000000080002cba <syscall>:
[SYS_ps]   sys_ps,
};

void
syscall(void)
{
    80002cba:	1101                	add	sp,sp,-32
    80002cbc:	ec06                	sd	ra,24(sp)
    80002cbe:	e822                	sd	s0,16(sp)
    80002cc0:	e426                	sd	s1,8(sp)
    80002cc2:	e04a                	sd	s2,0(sp)
    80002cc4:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002cc6:	fffff097          	auipc	ra,0xfffff
    80002cca:	d84080e7          	jalr	-636(ra) # 80001a4a <myproc>
    80002cce:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002cd0:	05853903          	ld	s2,88(a0)
    80002cd4:	0a893783          	ld	a5,168(s2)
    80002cd8:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002cdc:	37fd                	addw	a5,a5,-1
    80002cde:	4755                	li	a4,21
    80002ce0:	00f76f63          	bltu	a4,a5,80002cfe <syscall+0x44>
    80002ce4:	00369713          	sll	a4,a3,0x3
    80002ce8:	00006797          	auipc	a5,0x6
    80002cec:	b0878793          	add	a5,a5,-1272 # 800087f0 <syscalls>
    80002cf0:	97ba                	add	a5,a5,a4
    80002cf2:	639c                	ld	a5,0(a5)
    80002cf4:	c789                	beqz	a5,80002cfe <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002cf6:	9782                	jalr	a5
    80002cf8:	06a93823          	sd	a0,112(s2)
    80002cfc:	a839                	j	80002d1a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002cfe:	15848613          	add	a2,s1,344
    80002d02:	588c                	lw	a1,48(s1)
    80002d04:	00005517          	auipc	a0,0x5
    80002d08:	71450513          	add	a0,a0,1812 # 80008418 <etext+0x418>
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	89e080e7          	jalr	-1890(ra) # 800005aa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d14:	6cbc                	ld	a5,88(s1)
    80002d16:	577d                	li	a4,-1
    80002d18:	fbb8                	sd	a4,112(a5)
  }
}
    80002d1a:	60e2                	ld	ra,24(sp)
    80002d1c:	6442                	ld	s0,16(sp)
    80002d1e:	64a2                	ld	s1,8(sp)
    80002d20:	6902                	ld	s2,0(sp)
    80002d22:	6105                	add	sp,sp,32
    80002d24:	8082                	ret

0000000080002d26 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d26:	1101                	add	sp,sp,-32
    80002d28:	ec06                	sd	ra,24(sp)
    80002d2a:	e822                	sd	s0,16(sp)
    80002d2c:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002d2e:	fec40593          	add	a1,s0,-20
    80002d32:	4501                	li	a0,0
    80002d34:	00000097          	auipc	ra,0x0
    80002d38:	f0e080e7          	jalr	-242(ra) # 80002c42 <argint>
  exit(n);
    80002d3c:	fec42503          	lw	a0,-20(s0)
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	4e8080e7          	jalr	1256(ra) # 80002228 <exit>
  return 0;  // not reached
}
    80002d48:	4501                	li	a0,0
    80002d4a:	60e2                	ld	ra,24(sp)
    80002d4c:	6442                	ld	s0,16(sp)
    80002d4e:	6105                	add	sp,sp,32
    80002d50:	8082                	ret

0000000080002d52 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d52:	1141                	add	sp,sp,-16
    80002d54:	e406                	sd	ra,8(sp)
    80002d56:	e022                	sd	s0,0(sp)
    80002d58:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	cf0080e7          	jalr	-784(ra) # 80001a4a <myproc>
}
    80002d62:	5908                	lw	a0,48(a0)
    80002d64:	60a2                	ld	ra,8(sp)
    80002d66:	6402                	ld	s0,0(sp)
    80002d68:	0141                	add	sp,sp,16
    80002d6a:	8082                	ret

0000000080002d6c <sys_fork>:

uint64
sys_fork(void)
{
    80002d6c:	1141                	add	sp,sp,-16
    80002d6e:	e406                	sd	ra,8(sp)
    80002d70:	e022                	sd	s0,0(sp)
    80002d72:	0800                	add	s0,sp,16
  return fork();
    80002d74:	fffff097          	auipc	ra,0xfffff
    80002d78:	08c080e7          	jalr	140(ra) # 80001e00 <fork>
}
    80002d7c:	60a2                	ld	ra,8(sp)
    80002d7e:	6402                	ld	s0,0(sp)
    80002d80:	0141                	add	sp,sp,16
    80002d82:	8082                	ret

0000000080002d84 <sys_wait>:

uint64
sys_wait(void)
{
    80002d84:	1101                	add	sp,sp,-32
    80002d86:	ec06                	sd	ra,24(sp)
    80002d88:	e822                	sd	s0,16(sp)
    80002d8a:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d8c:	fe840593          	add	a1,s0,-24
    80002d90:	4501                	li	a0,0
    80002d92:	00000097          	auipc	ra,0x0
    80002d96:	ed0080e7          	jalr	-304(ra) # 80002c62 <argaddr>
  return wait(p);
    80002d9a:	fe843503          	ld	a0,-24(s0)
    80002d9e:	fffff097          	auipc	ra,0xfffff
    80002da2:	630080e7          	jalr	1584(ra) # 800023ce <wait>
}
    80002da6:	60e2                	ld	ra,24(sp)
    80002da8:	6442                	ld	s0,16(sp)
    80002daa:	6105                	add	sp,sp,32
    80002dac:	8082                	ret

0000000080002dae <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002dae:	7179                	add	sp,sp,-48
    80002db0:	f406                	sd	ra,40(sp)
    80002db2:	f022                	sd	s0,32(sp)
    80002db4:	ec26                	sd	s1,24(sp)
    80002db6:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002db8:	fdc40593          	add	a1,s0,-36
    80002dbc:	4501                	li	a0,0
    80002dbe:	00000097          	auipc	ra,0x0
    80002dc2:	e84080e7          	jalr	-380(ra) # 80002c42 <argint>
  addr = myproc()->sz;
    80002dc6:	fffff097          	auipc	ra,0xfffff
    80002dca:	c84080e7          	jalr	-892(ra) # 80001a4a <myproc>
    80002dce:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002dd0:	fdc42503          	lw	a0,-36(s0)
    80002dd4:	fffff097          	auipc	ra,0xfffff
    80002dd8:	fd0080e7          	jalr	-48(ra) # 80001da4 <growproc>
    80002ddc:	00054863          	bltz	a0,80002dec <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002de0:	8526                	mv	a0,s1
    80002de2:	70a2                	ld	ra,40(sp)
    80002de4:	7402                	ld	s0,32(sp)
    80002de6:	64e2                	ld	s1,24(sp)
    80002de8:	6145                	add	sp,sp,48
    80002dea:	8082                	ret
    return -1;
    80002dec:	54fd                	li	s1,-1
    80002dee:	bfcd                	j	80002de0 <sys_sbrk+0x32>

0000000080002df0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002df0:	7139                	add	sp,sp,-64
    80002df2:	fc06                	sd	ra,56(sp)
    80002df4:	f822                	sd	s0,48(sp)
    80002df6:	f04a                	sd	s2,32(sp)
    80002df8:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002dfa:	fcc40593          	add	a1,s0,-52
    80002dfe:	4501                	li	a0,0
    80002e00:	00000097          	auipc	ra,0x0
    80002e04:	e42080e7          	jalr	-446(ra) # 80002c42 <argint>
  acquire(&tickslock);
    80002e08:	00014517          	auipc	a0,0x14
    80002e0c:	bc850513          	add	a0,a0,-1080 # 800169d0 <tickslock>
    80002e10:	ffffe097          	auipc	ra,0xffffe
    80002e14:	e28080e7          	jalr	-472(ra) # 80000c38 <acquire>
  ticks0 = ticks;
    80002e18:	00006917          	auipc	s2,0x6
    80002e1c:	b1892903          	lw	s2,-1256(s2) # 80008930 <ticks>
  while(ticks - ticks0 < n){
    80002e20:	fcc42783          	lw	a5,-52(s0)
    80002e24:	c3b9                	beqz	a5,80002e6a <sys_sleep+0x7a>
    80002e26:	f426                	sd	s1,40(sp)
    80002e28:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e2a:	00014997          	auipc	s3,0x14
    80002e2e:	ba698993          	add	s3,s3,-1114 # 800169d0 <tickslock>
    80002e32:	00006497          	auipc	s1,0x6
    80002e36:	afe48493          	add	s1,s1,-1282 # 80008930 <ticks>
    if(killed(myproc())){
    80002e3a:	fffff097          	auipc	ra,0xfffff
    80002e3e:	c10080e7          	jalr	-1008(ra) # 80001a4a <myproc>
    80002e42:	fffff097          	auipc	ra,0xfffff
    80002e46:	55a080e7          	jalr	1370(ra) # 8000239c <killed>
    80002e4a:	ed15                	bnez	a0,80002e86 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002e4c:	85ce                	mv	a1,s3
    80002e4e:	8526                	mv	a0,s1
    80002e50:	fffff097          	auipc	ra,0xfffff
    80002e54:	2a4080e7          	jalr	676(ra) # 800020f4 <sleep>
  while(ticks - ticks0 < n){
    80002e58:	409c                	lw	a5,0(s1)
    80002e5a:	412787bb          	subw	a5,a5,s2
    80002e5e:	fcc42703          	lw	a4,-52(s0)
    80002e62:	fce7ece3          	bltu	a5,a4,80002e3a <sys_sleep+0x4a>
    80002e66:	74a2                	ld	s1,40(sp)
    80002e68:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002e6a:	00014517          	auipc	a0,0x14
    80002e6e:	b6650513          	add	a0,a0,-1178 # 800169d0 <tickslock>
    80002e72:	ffffe097          	auipc	ra,0xffffe
    80002e76:	e7a080e7          	jalr	-390(ra) # 80000cec <release>
  return 0;
    80002e7a:	4501                	li	a0,0
}
    80002e7c:	70e2                	ld	ra,56(sp)
    80002e7e:	7442                	ld	s0,48(sp)
    80002e80:	7902                	ld	s2,32(sp)
    80002e82:	6121                	add	sp,sp,64
    80002e84:	8082                	ret
      release(&tickslock);
    80002e86:	00014517          	auipc	a0,0x14
    80002e8a:	b4a50513          	add	a0,a0,-1206 # 800169d0 <tickslock>
    80002e8e:	ffffe097          	auipc	ra,0xffffe
    80002e92:	e5e080e7          	jalr	-418(ra) # 80000cec <release>
      return -1;
    80002e96:	557d                	li	a0,-1
    80002e98:	74a2                	ld	s1,40(sp)
    80002e9a:	69e2                	ld	s3,24(sp)
    80002e9c:	b7c5                	j	80002e7c <sys_sleep+0x8c>

0000000080002e9e <sys_kill>:

uint64
sys_kill(void)
{
    80002e9e:	1101                	add	sp,sp,-32
    80002ea0:	ec06                	sd	ra,24(sp)
    80002ea2:	e822                	sd	s0,16(sp)
    80002ea4:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ea6:	fec40593          	add	a1,s0,-20
    80002eaa:	4501                	li	a0,0
    80002eac:	00000097          	auipc	ra,0x0
    80002eb0:	d96080e7          	jalr	-618(ra) # 80002c42 <argint>
  return kill(pid);
    80002eb4:	fec42503          	lw	a0,-20(s0)
    80002eb8:	fffff097          	auipc	ra,0xfffff
    80002ebc:	446080e7          	jalr	1094(ra) # 800022fe <kill>
}
    80002ec0:	60e2                	ld	ra,24(sp)
    80002ec2:	6442                	ld	s0,16(sp)
    80002ec4:	6105                	add	sp,sp,32
    80002ec6:	8082                	ret

0000000080002ec8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ec8:	1101                	add	sp,sp,-32
    80002eca:	ec06                	sd	ra,24(sp)
    80002ecc:	e822                	sd	s0,16(sp)
    80002ece:	e426                	sd	s1,8(sp)
    80002ed0:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ed2:	00014517          	auipc	a0,0x14
    80002ed6:	afe50513          	add	a0,a0,-1282 # 800169d0 <tickslock>
    80002eda:	ffffe097          	auipc	ra,0xffffe
    80002ede:	d5e080e7          	jalr	-674(ra) # 80000c38 <acquire>
  xticks = ticks;
    80002ee2:	00006497          	auipc	s1,0x6
    80002ee6:	a4e4a483          	lw	s1,-1458(s1) # 80008930 <ticks>
  release(&tickslock);
    80002eea:	00014517          	auipc	a0,0x14
    80002eee:	ae650513          	add	a0,a0,-1306 # 800169d0 <tickslock>
    80002ef2:	ffffe097          	auipc	ra,0xffffe
    80002ef6:	dfa080e7          	jalr	-518(ra) # 80000cec <release>
  return xticks;
}
    80002efa:	02049513          	sll	a0,s1,0x20
    80002efe:	9101                	srl	a0,a0,0x20
    80002f00:	60e2                	ld	ra,24(sp)
    80002f02:	6442                	ld	s0,16(sp)
    80002f04:	64a2                	ld	s1,8(sp)
    80002f06:	6105                	add	sp,sp,32
    80002f08:	8082                	ret

0000000080002f0a <sys_ps>:

uint64
sys_ps()
{
    80002f0a:	1141                	add	sp,sp,-16
    80002f0c:	e406                	sd	ra,8(sp)
    80002f0e:	e022                	sd	s0,0(sp)
    80002f10:	0800                	add	s0,sp,16
  ps();
    80002f12:	fffff097          	auipc	ra,0xfffff
    80002f16:	746080e7          	jalr	1862(ra) # 80002658 <ps>
  return 0;
    80002f1a:	4501                	li	a0,0
    80002f1c:	60a2                	ld	ra,8(sp)
    80002f1e:	6402                	ld	s0,0(sp)
    80002f20:	0141                	add	sp,sp,16
    80002f22:	8082                	ret

0000000080002f24 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f24:	7179                	add	sp,sp,-48
    80002f26:	f406                	sd	ra,40(sp)
    80002f28:	f022                	sd	s0,32(sp)
    80002f2a:	ec26                	sd	s1,24(sp)
    80002f2c:	e84a                	sd	s2,16(sp)
    80002f2e:	e44e                	sd	s3,8(sp)
    80002f30:	e052                	sd	s4,0(sp)
    80002f32:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f34:	00005597          	auipc	a1,0x5
    80002f38:	50458593          	add	a1,a1,1284 # 80008438 <etext+0x438>
    80002f3c:	00014517          	auipc	a0,0x14
    80002f40:	aac50513          	add	a0,a0,-1364 # 800169e8 <bcache>
    80002f44:	ffffe097          	auipc	ra,0xffffe
    80002f48:	c64080e7          	jalr	-924(ra) # 80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f4c:	0001c797          	auipc	a5,0x1c
    80002f50:	a9c78793          	add	a5,a5,-1380 # 8001e9e8 <bcache+0x8000>
    80002f54:	0001c717          	auipc	a4,0x1c
    80002f58:	cfc70713          	add	a4,a4,-772 # 8001ec50 <bcache+0x8268>
    80002f5c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f60:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f64:	00014497          	auipc	s1,0x14
    80002f68:	a9c48493          	add	s1,s1,-1380 # 80016a00 <bcache+0x18>
    b->next = bcache.head.next;
    80002f6c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f6e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f70:	00005a17          	auipc	s4,0x5
    80002f74:	4d0a0a13          	add	s4,s4,1232 # 80008440 <etext+0x440>
    b->next = bcache.head.next;
    80002f78:	2b893783          	ld	a5,696(s2)
    80002f7c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f7e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f82:	85d2                	mv	a1,s4
    80002f84:	01048513          	add	a0,s1,16
    80002f88:	00001097          	auipc	ra,0x1
    80002f8c:	4e8080e7          	jalr	1256(ra) # 80004470 <initsleeplock>
    bcache.head.next->prev = b;
    80002f90:	2b893783          	ld	a5,696(s2)
    80002f94:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f96:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f9a:	45848493          	add	s1,s1,1112
    80002f9e:	fd349de3          	bne	s1,s3,80002f78 <binit+0x54>
  }
}
    80002fa2:	70a2                	ld	ra,40(sp)
    80002fa4:	7402                	ld	s0,32(sp)
    80002fa6:	64e2                	ld	s1,24(sp)
    80002fa8:	6942                	ld	s2,16(sp)
    80002faa:	69a2                	ld	s3,8(sp)
    80002fac:	6a02                	ld	s4,0(sp)
    80002fae:	6145                	add	sp,sp,48
    80002fb0:	8082                	ret

0000000080002fb2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002fb2:	7179                	add	sp,sp,-48
    80002fb4:	f406                	sd	ra,40(sp)
    80002fb6:	f022                	sd	s0,32(sp)
    80002fb8:	ec26                	sd	s1,24(sp)
    80002fba:	e84a                	sd	s2,16(sp)
    80002fbc:	e44e                	sd	s3,8(sp)
    80002fbe:	1800                	add	s0,sp,48
    80002fc0:	892a                	mv	s2,a0
    80002fc2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002fc4:	00014517          	auipc	a0,0x14
    80002fc8:	a2450513          	add	a0,a0,-1500 # 800169e8 <bcache>
    80002fcc:	ffffe097          	auipc	ra,0xffffe
    80002fd0:	c6c080e7          	jalr	-916(ra) # 80000c38 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fd4:	0001c497          	auipc	s1,0x1c
    80002fd8:	ccc4b483          	ld	s1,-820(s1) # 8001eca0 <bcache+0x82b8>
    80002fdc:	0001c797          	auipc	a5,0x1c
    80002fe0:	c7478793          	add	a5,a5,-908 # 8001ec50 <bcache+0x8268>
    80002fe4:	02f48f63          	beq	s1,a5,80003022 <bread+0x70>
    80002fe8:	873e                	mv	a4,a5
    80002fea:	a021                	j	80002ff2 <bread+0x40>
    80002fec:	68a4                	ld	s1,80(s1)
    80002fee:	02e48a63          	beq	s1,a4,80003022 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002ff2:	449c                	lw	a5,8(s1)
    80002ff4:	ff279ce3          	bne	a5,s2,80002fec <bread+0x3a>
    80002ff8:	44dc                	lw	a5,12(s1)
    80002ffa:	ff3799e3          	bne	a5,s3,80002fec <bread+0x3a>
      b->refcnt++;
    80002ffe:	40bc                	lw	a5,64(s1)
    80003000:	2785                	addw	a5,a5,1
    80003002:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003004:	00014517          	auipc	a0,0x14
    80003008:	9e450513          	add	a0,a0,-1564 # 800169e8 <bcache>
    8000300c:	ffffe097          	auipc	ra,0xffffe
    80003010:	ce0080e7          	jalr	-800(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80003014:	01048513          	add	a0,s1,16
    80003018:	00001097          	auipc	ra,0x1
    8000301c:	492080e7          	jalr	1170(ra) # 800044aa <acquiresleep>
      return b;
    80003020:	a8b9                	j	8000307e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003022:	0001c497          	auipc	s1,0x1c
    80003026:	c764b483          	ld	s1,-906(s1) # 8001ec98 <bcache+0x82b0>
    8000302a:	0001c797          	auipc	a5,0x1c
    8000302e:	c2678793          	add	a5,a5,-986 # 8001ec50 <bcache+0x8268>
    80003032:	00f48863          	beq	s1,a5,80003042 <bread+0x90>
    80003036:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003038:	40bc                	lw	a5,64(s1)
    8000303a:	cf81                	beqz	a5,80003052 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000303c:	64a4                	ld	s1,72(s1)
    8000303e:	fee49de3          	bne	s1,a4,80003038 <bread+0x86>
  panic("bget: no buffers");
    80003042:	00005517          	auipc	a0,0x5
    80003046:	40650513          	add	a0,a0,1030 # 80008448 <etext+0x448>
    8000304a:	ffffd097          	auipc	ra,0xffffd
    8000304e:	516080e7          	jalr	1302(ra) # 80000560 <panic>
      b->dev = dev;
    80003052:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003056:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000305a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000305e:	4785                	li	a5,1
    80003060:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003062:	00014517          	auipc	a0,0x14
    80003066:	98650513          	add	a0,a0,-1658 # 800169e8 <bcache>
    8000306a:	ffffe097          	auipc	ra,0xffffe
    8000306e:	c82080e7          	jalr	-894(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80003072:	01048513          	add	a0,s1,16
    80003076:	00001097          	auipc	ra,0x1
    8000307a:	434080e7          	jalr	1076(ra) # 800044aa <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000307e:	409c                	lw	a5,0(s1)
    80003080:	cb89                	beqz	a5,80003092 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003082:	8526                	mv	a0,s1
    80003084:	70a2                	ld	ra,40(sp)
    80003086:	7402                	ld	s0,32(sp)
    80003088:	64e2                	ld	s1,24(sp)
    8000308a:	6942                	ld	s2,16(sp)
    8000308c:	69a2                	ld	s3,8(sp)
    8000308e:	6145                	add	sp,sp,48
    80003090:	8082                	ret
    virtio_disk_rw(b, 0);
    80003092:	4581                	li	a1,0
    80003094:	8526                	mv	a0,s1
    80003096:	00003097          	auipc	ra,0x3
    8000309a:	0f2080e7          	jalr	242(ra) # 80006188 <virtio_disk_rw>
    b->valid = 1;
    8000309e:	4785                	li	a5,1
    800030a0:	c09c                	sw	a5,0(s1)
  return b;
    800030a2:	b7c5                	j	80003082 <bread+0xd0>

00000000800030a4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800030a4:	1101                	add	sp,sp,-32
    800030a6:	ec06                	sd	ra,24(sp)
    800030a8:	e822                	sd	s0,16(sp)
    800030aa:	e426                	sd	s1,8(sp)
    800030ac:	1000                	add	s0,sp,32
    800030ae:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030b0:	0541                	add	a0,a0,16
    800030b2:	00001097          	auipc	ra,0x1
    800030b6:	492080e7          	jalr	1170(ra) # 80004544 <holdingsleep>
    800030ba:	cd01                	beqz	a0,800030d2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800030bc:	4585                	li	a1,1
    800030be:	8526                	mv	a0,s1
    800030c0:	00003097          	auipc	ra,0x3
    800030c4:	0c8080e7          	jalr	200(ra) # 80006188 <virtio_disk_rw>
}
    800030c8:	60e2                	ld	ra,24(sp)
    800030ca:	6442                	ld	s0,16(sp)
    800030cc:	64a2                	ld	s1,8(sp)
    800030ce:	6105                	add	sp,sp,32
    800030d0:	8082                	ret
    panic("bwrite");
    800030d2:	00005517          	auipc	a0,0x5
    800030d6:	38e50513          	add	a0,a0,910 # 80008460 <etext+0x460>
    800030da:	ffffd097          	auipc	ra,0xffffd
    800030de:	486080e7          	jalr	1158(ra) # 80000560 <panic>

00000000800030e2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030e2:	1101                	add	sp,sp,-32
    800030e4:	ec06                	sd	ra,24(sp)
    800030e6:	e822                	sd	s0,16(sp)
    800030e8:	e426                	sd	s1,8(sp)
    800030ea:	e04a                	sd	s2,0(sp)
    800030ec:	1000                	add	s0,sp,32
    800030ee:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030f0:	01050913          	add	s2,a0,16
    800030f4:	854a                	mv	a0,s2
    800030f6:	00001097          	auipc	ra,0x1
    800030fa:	44e080e7          	jalr	1102(ra) # 80004544 <holdingsleep>
    800030fe:	c925                	beqz	a0,8000316e <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003100:	854a                	mv	a0,s2
    80003102:	00001097          	auipc	ra,0x1
    80003106:	3fe080e7          	jalr	1022(ra) # 80004500 <releasesleep>

  acquire(&bcache.lock);
    8000310a:	00014517          	auipc	a0,0x14
    8000310e:	8de50513          	add	a0,a0,-1826 # 800169e8 <bcache>
    80003112:	ffffe097          	auipc	ra,0xffffe
    80003116:	b26080e7          	jalr	-1242(ra) # 80000c38 <acquire>
  b->refcnt--;
    8000311a:	40bc                	lw	a5,64(s1)
    8000311c:	37fd                	addw	a5,a5,-1
    8000311e:	0007871b          	sext.w	a4,a5
    80003122:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003124:	e71d                	bnez	a4,80003152 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003126:	68b8                	ld	a4,80(s1)
    80003128:	64bc                	ld	a5,72(s1)
    8000312a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000312c:	68b8                	ld	a4,80(s1)
    8000312e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003130:	0001c797          	auipc	a5,0x1c
    80003134:	8b878793          	add	a5,a5,-1864 # 8001e9e8 <bcache+0x8000>
    80003138:	2b87b703          	ld	a4,696(a5)
    8000313c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000313e:	0001c717          	auipc	a4,0x1c
    80003142:	b1270713          	add	a4,a4,-1262 # 8001ec50 <bcache+0x8268>
    80003146:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003148:	2b87b703          	ld	a4,696(a5)
    8000314c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000314e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003152:	00014517          	auipc	a0,0x14
    80003156:	89650513          	add	a0,a0,-1898 # 800169e8 <bcache>
    8000315a:	ffffe097          	auipc	ra,0xffffe
    8000315e:	b92080e7          	jalr	-1134(ra) # 80000cec <release>
}
    80003162:	60e2                	ld	ra,24(sp)
    80003164:	6442                	ld	s0,16(sp)
    80003166:	64a2                	ld	s1,8(sp)
    80003168:	6902                	ld	s2,0(sp)
    8000316a:	6105                	add	sp,sp,32
    8000316c:	8082                	ret
    panic("brelse");
    8000316e:	00005517          	auipc	a0,0x5
    80003172:	2fa50513          	add	a0,a0,762 # 80008468 <etext+0x468>
    80003176:	ffffd097          	auipc	ra,0xffffd
    8000317a:	3ea080e7          	jalr	1002(ra) # 80000560 <panic>

000000008000317e <bpin>:

void
bpin(struct buf *b) {
    8000317e:	1101                	add	sp,sp,-32
    80003180:	ec06                	sd	ra,24(sp)
    80003182:	e822                	sd	s0,16(sp)
    80003184:	e426                	sd	s1,8(sp)
    80003186:	1000                	add	s0,sp,32
    80003188:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000318a:	00014517          	auipc	a0,0x14
    8000318e:	85e50513          	add	a0,a0,-1954 # 800169e8 <bcache>
    80003192:	ffffe097          	auipc	ra,0xffffe
    80003196:	aa6080e7          	jalr	-1370(ra) # 80000c38 <acquire>
  b->refcnt++;
    8000319a:	40bc                	lw	a5,64(s1)
    8000319c:	2785                	addw	a5,a5,1
    8000319e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031a0:	00014517          	auipc	a0,0x14
    800031a4:	84850513          	add	a0,a0,-1976 # 800169e8 <bcache>
    800031a8:	ffffe097          	auipc	ra,0xffffe
    800031ac:	b44080e7          	jalr	-1212(ra) # 80000cec <release>
}
    800031b0:	60e2                	ld	ra,24(sp)
    800031b2:	6442                	ld	s0,16(sp)
    800031b4:	64a2                	ld	s1,8(sp)
    800031b6:	6105                	add	sp,sp,32
    800031b8:	8082                	ret

00000000800031ba <bunpin>:

void
bunpin(struct buf *b) {
    800031ba:	1101                	add	sp,sp,-32
    800031bc:	ec06                	sd	ra,24(sp)
    800031be:	e822                	sd	s0,16(sp)
    800031c0:	e426                	sd	s1,8(sp)
    800031c2:	1000                	add	s0,sp,32
    800031c4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031c6:	00014517          	auipc	a0,0x14
    800031ca:	82250513          	add	a0,a0,-2014 # 800169e8 <bcache>
    800031ce:	ffffe097          	auipc	ra,0xffffe
    800031d2:	a6a080e7          	jalr	-1430(ra) # 80000c38 <acquire>
  b->refcnt--;
    800031d6:	40bc                	lw	a5,64(s1)
    800031d8:	37fd                	addw	a5,a5,-1
    800031da:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031dc:	00014517          	auipc	a0,0x14
    800031e0:	80c50513          	add	a0,a0,-2036 # 800169e8 <bcache>
    800031e4:	ffffe097          	auipc	ra,0xffffe
    800031e8:	b08080e7          	jalr	-1272(ra) # 80000cec <release>
}
    800031ec:	60e2                	ld	ra,24(sp)
    800031ee:	6442                	ld	s0,16(sp)
    800031f0:	64a2                	ld	s1,8(sp)
    800031f2:	6105                	add	sp,sp,32
    800031f4:	8082                	ret

00000000800031f6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031f6:	1101                	add	sp,sp,-32
    800031f8:	ec06                	sd	ra,24(sp)
    800031fa:	e822                	sd	s0,16(sp)
    800031fc:	e426                	sd	s1,8(sp)
    800031fe:	e04a                	sd	s2,0(sp)
    80003200:	1000                	add	s0,sp,32
    80003202:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003204:	00d5d59b          	srlw	a1,a1,0xd
    80003208:	0001c797          	auipc	a5,0x1c
    8000320c:	ebc7a783          	lw	a5,-324(a5) # 8001f0c4 <sb+0x1c>
    80003210:	9dbd                	addw	a1,a1,a5
    80003212:	00000097          	auipc	ra,0x0
    80003216:	da0080e7          	jalr	-608(ra) # 80002fb2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000321a:	0074f713          	and	a4,s1,7
    8000321e:	4785                	li	a5,1
    80003220:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003224:	14ce                	sll	s1,s1,0x33
    80003226:	90d9                	srl	s1,s1,0x36
    80003228:	00950733          	add	a4,a0,s1
    8000322c:	05874703          	lbu	a4,88(a4)
    80003230:	00e7f6b3          	and	a3,a5,a4
    80003234:	c69d                	beqz	a3,80003262 <bfree+0x6c>
    80003236:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003238:	94aa                	add	s1,s1,a0
    8000323a:	fff7c793          	not	a5,a5
    8000323e:	8f7d                	and	a4,a4,a5
    80003240:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003244:	00001097          	auipc	ra,0x1
    80003248:	148080e7          	jalr	328(ra) # 8000438c <log_write>
  brelse(bp);
    8000324c:	854a                	mv	a0,s2
    8000324e:	00000097          	auipc	ra,0x0
    80003252:	e94080e7          	jalr	-364(ra) # 800030e2 <brelse>
}
    80003256:	60e2                	ld	ra,24(sp)
    80003258:	6442                	ld	s0,16(sp)
    8000325a:	64a2                	ld	s1,8(sp)
    8000325c:	6902                	ld	s2,0(sp)
    8000325e:	6105                	add	sp,sp,32
    80003260:	8082                	ret
    panic("freeing free block");
    80003262:	00005517          	auipc	a0,0x5
    80003266:	20e50513          	add	a0,a0,526 # 80008470 <etext+0x470>
    8000326a:	ffffd097          	auipc	ra,0xffffd
    8000326e:	2f6080e7          	jalr	758(ra) # 80000560 <panic>

0000000080003272 <balloc>:
{
    80003272:	711d                	add	sp,sp,-96
    80003274:	ec86                	sd	ra,88(sp)
    80003276:	e8a2                	sd	s0,80(sp)
    80003278:	e4a6                	sd	s1,72(sp)
    8000327a:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000327c:	0001c797          	auipc	a5,0x1c
    80003280:	e307a783          	lw	a5,-464(a5) # 8001f0ac <sb+0x4>
    80003284:	10078f63          	beqz	a5,800033a2 <balloc+0x130>
    80003288:	e0ca                	sd	s2,64(sp)
    8000328a:	fc4e                	sd	s3,56(sp)
    8000328c:	f852                	sd	s4,48(sp)
    8000328e:	f456                	sd	s5,40(sp)
    80003290:	f05a                	sd	s6,32(sp)
    80003292:	ec5e                	sd	s7,24(sp)
    80003294:	e862                	sd	s8,16(sp)
    80003296:	e466                	sd	s9,8(sp)
    80003298:	8baa                	mv	s7,a0
    8000329a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000329c:	0001cb17          	auipc	s6,0x1c
    800032a0:	e0cb0b13          	add	s6,s6,-500 # 8001f0a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032a4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800032a6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032a8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032aa:	6c89                	lui	s9,0x2
    800032ac:	a061                	j	80003334 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032ae:	97ca                	add	a5,a5,s2
    800032b0:	8e55                	or	a2,a2,a3
    800032b2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800032b6:	854a                	mv	a0,s2
    800032b8:	00001097          	auipc	ra,0x1
    800032bc:	0d4080e7          	jalr	212(ra) # 8000438c <log_write>
        brelse(bp);
    800032c0:	854a                	mv	a0,s2
    800032c2:	00000097          	auipc	ra,0x0
    800032c6:	e20080e7          	jalr	-480(ra) # 800030e2 <brelse>
  bp = bread(dev, bno);
    800032ca:	85a6                	mv	a1,s1
    800032cc:	855e                	mv	a0,s7
    800032ce:	00000097          	auipc	ra,0x0
    800032d2:	ce4080e7          	jalr	-796(ra) # 80002fb2 <bread>
    800032d6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032d8:	40000613          	li	a2,1024
    800032dc:	4581                	li	a1,0
    800032de:	05850513          	add	a0,a0,88
    800032e2:	ffffe097          	auipc	ra,0xffffe
    800032e6:	a52080e7          	jalr	-1454(ra) # 80000d34 <memset>
  log_write(bp);
    800032ea:	854a                	mv	a0,s2
    800032ec:	00001097          	auipc	ra,0x1
    800032f0:	0a0080e7          	jalr	160(ra) # 8000438c <log_write>
  brelse(bp);
    800032f4:	854a                	mv	a0,s2
    800032f6:	00000097          	auipc	ra,0x0
    800032fa:	dec080e7          	jalr	-532(ra) # 800030e2 <brelse>
}
    800032fe:	6906                	ld	s2,64(sp)
    80003300:	79e2                	ld	s3,56(sp)
    80003302:	7a42                	ld	s4,48(sp)
    80003304:	7aa2                	ld	s5,40(sp)
    80003306:	7b02                	ld	s6,32(sp)
    80003308:	6be2                	ld	s7,24(sp)
    8000330a:	6c42                	ld	s8,16(sp)
    8000330c:	6ca2                	ld	s9,8(sp)
}
    8000330e:	8526                	mv	a0,s1
    80003310:	60e6                	ld	ra,88(sp)
    80003312:	6446                	ld	s0,80(sp)
    80003314:	64a6                	ld	s1,72(sp)
    80003316:	6125                	add	sp,sp,96
    80003318:	8082                	ret
    brelse(bp);
    8000331a:	854a                	mv	a0,s2
    8000331c:	00000097          	auipc	ra,0x0
    80003320:	dc6080e7          	jalr	-570(ra) # 800030e2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003324:	015c87bb          	addw	a5,s9,s5
    80003328:	00078a9b          	sext.w	s5,a5
    8000332c:	004b2703          	lw	a4,4(s6)
    80003330:	06eaf163          	bgeu	s5,a4,80003392 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003334:	41fad79b          	sraw	a5,s5,0x1f
    80003338:	0137d79b          	srlw	a5,a5,0x13
    8000333c:	015787bb          	addw	a5,a5,s5
    80003340:	40d7d79b          	sraw	a5,a5,0xd
    80003344:	01cb2583          	lw	a1,28(s6)
    80003348:	9dbd                	addw	a1,a1,a5
    8000334a:	855e                	mv	a0,s7
    8000334c:	00000097          	auipc	ra,0x0
    80003350:	c66080e7          	jalr	-922(ra) # 80002fb2 <bread>
    80003354:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003356:	004b2503          	lw	a0,4(s6)
    8000335a:	000a849b          	sext.w	s1,s5
    8000335e:	8762                	mv	a4,s8
    80003360:	faa4fde3          	bgeu	s1,a0,8000331a <balloc+0xa8>
      m = 1 << (bi % 8);
    80003364:	00777693          	and	a3,a4,7
    80003368:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000336c:	41f7579b          	sraw	a5,a4,0x1f
    80003370:	01d7d79b          	srlw	a5,a5,0x1d
    80003374:	9fb9                	addw	a5,a5,a4
    80003376:	4037d79b          	sraw	a5,a5,0x3
    8000337a:	00f90633          	add	a2,s2,a5
    8000337e:	05864603          	lbu	a2,88(a2)
    80003382:	00c6f5b3          	and	a1,a3,a2
    80003386:	d585                	beqz	a1,800032ae <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003388:	2705                	addw	a4,a4,1
    8000338a:	2485                	addw	s1,s1,1
    8000338c:	fd471ae3          	bne	a4,s4,80003360 <balloc+0xee>
    80003390:	b769                	j	8000331a <balloc+0xa8>
    80003392:	6906                	ld	s2,64(sp)
    80003394:	79e2                	ld	s3,56(sp)
    80003396:	7a42                	ld	s4,48(sp)
    80003398:	7aa2                	ld	s5,40(sp)
    8000339a:	7b02                	ld	s6,32(sp)
    8000339c:	6be2                	ld	s7,24(sp)
    8000339e:	6c42                	ld	s8,16(sp)
    800033a0:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800033a2:	00005517          	auipc	a0,0x5
    800033a6:	0e650513          	add	a0,a0,230 # 80008488 <etext+0x488>
    800033aa:	ffffd097          	auipc	ra,0xffffd
    800033ae:	200080e7          	jalr	512(ra) # 800005aa <printf>
  return 0;
    800033b2:	4481                	li	s1,0
    800033b4:	bfa9                	j	8000330e <balloc+0x9c>

00000000800033b6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800033b6:	7179                	add	sp,sp,-48
    800033b8:	f406                	sd	ra,40(sp)
    800033ba:	f022                	sd	s0,32(sp)
    800033bc:	ec26                	sd	s1,24(sp)
    800033be:	e84a                	sd	s2,16(sp)
    800033c0:	e44e                	sd	s3,8(sp)
    800033c2:	1800                	add	s0,sp,48
    800033c4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033c6:	47ad                	li	a5,11
    800033c8:	02b7e863          	bltu	a5,a1,800033f8 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800033cc:	02059793          	sll	a5,a1,0x20
    800033d0:	01e7d593          	srl	a1,a5,0x1e
    800033d4:	00b504b3          	add	s1,a0,a1
    800033d8:	0504a903          	lw	s2,80(s1)
    800033dc:	08091263          	bnez	s2,80003460 <bmap+0xaa>
      addr = balloc(ip->dev);
    800033e0:	4108                	lw	a0,0(a0)
    800033e2:	00000097          	auipc	ra,0x0
    800033e6:	e90080e7          	jalr	-368(ra) # 80003272 <balloc>
    800033ea:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033ee:	06090963          	beqz	s2,80003460 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    800033f2:	0524a823          	sw	s2,80(s1)
    800033f6:	a0ad                	j	80003460 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033f8:	ff45849b          	addw	s1,a1,-12
    800033fc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003400:	0ff00793          	li	a5,255
    80003404:	08e7e863          	bltu	a5,a4,80003494 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003408:	08052903          	lw	s2,128(a0)
    8000340c:	00091f63          	bnez	s2,8000342a <bmap+0x74>
      addr = balloc(ip->dev);
    80003410:	4108                	lw	a0,0(a0)
    80003412:	00000097          	auipc	ra,0x0
    80003416:	e60080e7          	jalr	-416(ra) # 80003272 <balloc>
    8000341a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000341e:	04090163          	beqz	s2,80003460 <bmap+0xaa>
    80003422:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003424:	0929a023          	sw	s2,128(s3)
    80003428:	a011                	j	8000342c <bmap+0x76>
    8000342a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000342c:	85ca                	mv	a1,s2
    8000342e:	0009a503          	lw	a0,0(s3)
    80003432:	00000097          	auipc	ra,0x0
    80003436:	b80080e7          	jalr	-1152(ra) # 80002fb2 <bread>
    8000343a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000343c:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    80003440:	02049713          	sll	a4,s1,0x20
    80003444:	01e75593          	srl	a1,a4,0x1e
    80003448:	00b784b3          	add	s1,a5,a1
    8000344c:	0004a903          	lw	s2,0(s1)
    80003450:	02090063          	beqz	s2,80003470 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003454:	8552                	mv	a0,s4
    80003456:	00000097          	auipc	ra,0x0
    8000345a:	c8c080e7          	jalr	-884(ra) # 800030e2 <brelse>
    return addr;
    8000345e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003460:	854a                	mv	a0,s2
    80003462:	70a2                	ld	ra,40(sp)
    80003464:	7402                	ld	s0,32(sp)
    80003466:	64e2                	ld	s1,24(sp)
    80003468:	6942                	ld	s2,16(sp)
    8000346a:	69a2                	ld	s3,8(sp)
    8000346c:	6145                	add	sp,sp,48
    8000346e:	8082                	ret
      addr = balloc(ip->dev);
    80003470:	0009a503          	lw	a0,0(s3)
    80003474:	00000097          	auipc	ra,0x0
    80003478:	dfe080e7          	jalr	-514(ra) # 80003272 <balloc>
    8000347c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003480:	fc090ae3          	beqz	s2,80003454 <bmap+0x9e>
        a[bn] = addr;
    80003484:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003488:	8552                	mv	a0,s4
    8000348a:	00001097          	auipc	ra,0x1
    8000348e:	f02080e7          	jalr	-254(ra) # 8000438c <log_write>
    80003492:	b7c9                	j	80003454 <bmap+0x9e>
    80003494:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003496:	00005517          	auipc	a0,0x5
    8000349a:	00a50513          	add	a0,a0,10 # 800084a0 <etext+0x4a0>
    8000349e:	ffffd097          	auipc	ra,0xffffd
    800034a2:	0c2080e7          	jalr	194(ra) # 80000560 <panic>

00000000800034a6 <iget>:
{
    800034a6:	7179                	add	sp,sp,-48
    800034a8:	f406                	sd	ra,40(sp)
    800034aa:	f022                	sd	s0,32(sp)
    800034ac:	ec26                	sd	s1,24(sp)
    800034ae:	e84a                	sd	s2,16(sp)
    800034b0:	e44e                	sd	s3,8(sp)
    800034b2:	e052                	sd	s4,0(sp)
    800034b4:	1800                	add	s0,sp,48
    800034b6:	89aa                	mv	s3,a0
    800034b8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800034ba:	0001c517          	auipc	a0,0x1c
    800034be:	c0e50513          	add	a0,a0,-1010 # 8001f0c8 <itable>
    800034c2:	ffffd097          	auipc	ra,0xffffd
    800034c6:	776080e7          	jalr	1910(ra) # 80000c38 <acquire>
  empty = 0;
    800034ca:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034cc:	0001c497          	auipc	s1,0x1c
    800034d0:	c1448493          	add	s1,s1,-1004 # 8001f0e0 <itable+0x18>
    800034d4:	0001d697          	auipc	a3,0x1d
    800034d8:	69c68693          	add	a3,a3,1692 # 80020b70 <log>
    800034dc:	a039                	j	800034ea <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034de:	02090b63          	beqz	s2,80003514 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034e2:	08848493          	add	s1,s1,136
    800034e6:	02d48a63          	beq	s1,a3,8000351a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034ea:	449c                	lw	a5,8(s1)
    800034ec:	fef059e3          	blez	a5,800034de <iget+0x38>
    800034f0:	4098                	lw	a4,0(s1)
    800034f2:	ff3716e3          	bne	a4,s3,800034de <iget+0x38>
    800034f6:	40d8                	lw	a4,4(s1)
    800034f8:	ff4713e3          	bne	a4,s4,800034de <iget+0x38>
      ip->ref++;
    800034fc:	2785                	addw	a5,a5,1
    800034fe:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003500:	0001c517          	auipc	a0,0x1c
    80003504:	bc850513          	add	a0,a0,-1080 # 8001f0c8 <itable>
    80003508:	ffffd097          	auipc	ra,0xffffd
    8000350c:	7e4080e7          	jalr	2020(ra) # 80000cec <release>
      return ip;
    80003510:	8926                	mv	s2,s1
    80003512:	a03d                	j	80003540 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003514:	f7f9                	bnez	a5,800034e2 <iget+0x3c>
      empty = ip;
    80003516:	8926                	mv	s2,s1
    80003518:	b7e9                	j	800034e2 <iget+0x3c>
  if(empty == 0)
    8000351a:	02090c63          	beqz	s2,80003552 <iget+0xac>
  ip->dev = dev;
    8000351e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003522:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003526:	4785                	li	a5,1
    80003528:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000352c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003530:	0001c517          	auipc	a0,0x1c
    80003534:	b9850513          	add	a0,a0,-1128 # 8001f0c8 <itable>
    80003538:	ffffd097          	auipc	ra,0xffffd
    8000353c:	7b4080e7          	jalr	1972(ra) # 80000cec <release>
}
    80003540:	854a                	mv	a0,s2
    80003542:	70a2                	ld	ra,40(sp)
    80003544:	7402                	ld	s0,32(sp)
    80003546:	64e2                	ld	s1,24(sp)
    80003548:	6942                	ld	s2,16(sp)
    8000354a:	69a2                	ld	s3,8(sp)
    8000354c:	6a02                	ld	s4,0(sp)
    8000354e:	6145                	add	sp,sp,48
    80003550:	8082                	ret
    panic("iget: no inodes");
    80003552:	00005517          	auipc	a0,0x5
    80003556:	f6650513          	add	a0,a0,-154 # 800084b8 <etext+0x4b8>
    8000355a:	ffffd097          	auipc	ra,0xffffd
    8000355e:	006080e7          	jalr	6(ra) # 80000560 <panic>

0000000080003562 <fsinit>:
fsinit(int dev) {
    80003562:	7179                	add	sp,sp,-48
    80003564:	f406                	sd	ra,40(sp)
    80003566:	f022                	sd	s0,32(sp)
    80003568:	ec26                	sd	s1,24(sp)
    8000356a:	e84a                	sd	s2,16(sp)
    8000356c:	e44e                	sd	s3,8(sp)
    8000356e:	1800                	add	s0,sp,48
    80003570:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003572:	4585                	li	a1,1
    80003574:	00000097          	auipc	ra,0x0
    80003578:	a3e080e7          	jalr	-1474(ra) # 80002fb2 <bread>
    8000357c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000357e:	0001c997          	auipc	s3,0x1c
    80003582:	b2a98993          	add	s3,s3,-1238 # 8001f0a8 <sb>
    80003586:	02000613          	li	a2,32
    8000358a:	05850593          	add	a1,a0,88
    8000358e:	854e                	mv	a0,s3
    80003590:	ffffe097          	auipc	ra,0xffffe
    80003594:	800080e7          	jalr	-2048(ra) # 80000d90 <memmove>
  brelse(bp);
    80003598:	8526                	mv	a0,s1
    8000359a:	00000097          	auipc	ra,0x0
    8000359e:	b48080e7          	jalr	-1208(ra) # 800030e2 <brelse>
  if(sb.magic != FSMAGIC)
    800035a2:	0009a703          	lw	a4,0(s3)
    800035a6:	102037b7          	lui	a5,0x10203
    800035aa:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035ae:	02f71263          	bne	a4,a5,800035d2 <fsinit+0x70>
  initlog(dev, &sb);
    800035b2:	0001c597          	auipc	a1,0x1c
    800035b6:	af658593          	add	a1,a1,-1290 # 8001f0a8 <sb>
    800035ba:	854a                	mv	a0,s2
    800035bc:	00001097          	auipc	ra,0x1
    800035c0:	b60080e7          	jalr	-1184(ra) # 8000411c <initlog>
}
    800035c4:	70a2                	ld	ra,40(sp)
    800035c6:	7402                	ld	s0,32(sp)
    800035c8:	64e2                	ld	s1,24(sp)
    800035ca:	6942                	ld	s2,16(sp)
    800035cc:	69a2                	ld	s3,8(sp)
    800035ce:	6145                	add	sp,sp,48
    800035d0:	8082                	ret
    panic("invalid file system");
    800035d2:	00005517          	auipc	a0,0x5
    800035d6:	ef650513          	add	a0,a0,-266 # 800084c8 <etext+0x4c8>
    800035da:	ffffd097          	auipc	ra,0xffffd
    800035de:	f86080e7          	jalr	-122(ra) # 80000560 <panic>

00000000800035e2 <iinit>:
{
    800035e2:	7179                	add	sp,sp,-48
    800035e4:	f406                	sd	ra,40(sp)
    800035e6:	f022                	sd	s0,32(sp)
    800035e8:	ec26                	sd	s1,24(sp)
    800035ea:	e84a                	sd	s2,16(sp)
    800035ec:	e44e                	sd	s3,8(sp)
    800035ee:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    800035f0:	00005597          	auipc	a1,0x5
    800035f4:	ef058593          	add	a1,a1,-272 # 800084e0 <etext+0x4e0>
    800035f8:	0001c517          	auipc	a0,0x1c
    800035fc:	ad050513          	add	a0,a0,-1328 # 8001f0c8 <itable>
    80003600:	ffffd097          	auipc	ra,0xffffd
    80003604:	5a8080e7          	jalr	1448(ra) # 80000ba8 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003608:	0001c497          	auipc	s1,0x1c
    8000360c:	ae848493          	add	s1,s1,-1304 # 8001f0f0 <itable+0x28>
    80003610:	0001d997          	auipc	s3,0x1d
    80003614:	57098993          	add	s3,s3,1392 # 80020b80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003618:	00005917          	auipc	s2,0x5
    8000361c:	ed090913          	add	s2,s2,-304 # 800084e8 <etext+0x4e8>
    80003620:	85ca                	mv	a1,s2
    80003622:	8526                	mv	a0,s1
    80003624:	00001097          	auipc	ra,0x1
    80003628:	e4c080e7          	jalr	-436(ra) # 80004470 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000362c:	08848493          	add	s1,s1,136
    80003630:	ff3498e3          	bne	s1,s3,80003620 <iinit+0x3e>
}
    80003634:	70a2                	ld	ra,40(sp)
    80003636:	7402                	ld	s0,32(sp)
    80003638:	64e2                	ld	s1,24(sp)
    8000363a:	6942                	ld	s2,16(sp)
    8000363c:	69a2                	ld	s3,8(sp)
    8000363e:	6145                	add	sp,sp,48
    80003640:	8082                	ret

0000000080003642 <ialloc>:
{
    80003642:	7139                	add	sp,sp,-64
    80003644:	fc06                	sd	ra,56(sp)
    80003646:	f822                	sd	s0,48(sp)
    80003648:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000364a:	0001c717          	auipc	a4,0x1c
    8000364e:	a6a72703          	lw	a4,-1430(a4) # 8001f0b4 <sb+0xc>
    80003652:	4785                	li	a5,1
    80003654:	06e7f463          	bgeu	a5,a4,800036bc <ialloc+0x7a>
    80003658:	f426                	sd	s1,40(sp)
    8000365a:	f04a                	sd	s2,32(sp)
    8000365c:	ec4e                	sd	s3,24(sp)
    8000365e:	e852                	sd	s4,16(sp)
    80003660:	e456                	sd	s5,8(sp)
    80003662:	e05a                	sd	s6,0(sp)
    80003664:	8aaa                	mv	s5,a0
    80003666:	8b2e                	mv	s6,a1
    80003668:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000366a:	0001ca17          	auipc	s4,0x1c
    8000366e:	a3ea0a13          	add	s4,s4,-1474 # 8001f0a8 <sb>
    80003672:	00495593          	srl	a1,s2,0x4
    80003676:	018a2783          	lw	a5,24(s4)
    8000367a:	9dbd                	addw	a1,a1,a5
    8000367c:	8556                	mv	a0,s5
    8000367e:	00000097          	auipc	ra,0x0
    80003682:	934080e7          	jalr	-1740(ra) # 80002fb2 <bread>
    80003686:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003688:	05850993          	add	s3,a0,88
    8000368c:	00f97793          	and	a5,s2,15
    80003690:	079a                	sll	a5,a5,0x6
    80003692:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003694:	00099783          	lh	a5,0(s3)
    80003698:	cf9d                	beqz	a5,800036d6 <ialloc+0x94>
    brelse(bp);
    8000369a:	00000097          	auipc	ra,0x0
    8000369e:	a48080e7          	jalr	-1464(ra) # 800030e2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036a2:	0905                	add	s2,s2,1
    800036a4:	00ca2703          	lw	a4,12(s4)
    800036a8:	0009079b          	sext.w	a5,s2
    800036ac:	fce7e3e3          	bltu	a5,a4,80003672 <ialloc+0x30>
    800036b0:	74a2                	ld	s1,40(sp)
    800036b2:	7902                	ld	s2,32(sp)
    800036b4:	69e2                	ld	s3,24(sp)
    800036b6:	6a42                	ld	s4,16(sp)
    800036b8:	6aa2                	ld	s5,8(sp)
    800036ba:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800036bc:	00005517          	auipc	a0,0x5
    800036c0:	e3450513          	add	a0,a0,-460 # 800084f0 <etext+0x4f0>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	ee6080e7          	jalr	-282(ra) # 800005aa <printf>
  return 0;
    800036cc:	4501                	li	a0,0
}
    800036ce:	70e2                	ld	ra,56(sp)
    800036d0:	7442                	ld	s0,48(sp)
    800036d2:	6121                	add	sp,sp,64
    800036d4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800036d6:	04000613          	li	a2,64
    800036da:	4581                	li	a1,0
    800036dc:	854e                	mv	a0,s3
    800036de:	ffffd097          	auipc	ra,0xffffd
    800036e2:	656080e7          	jalr	1622(ra) # 80000d34 <memset>
      dip->type = type;
    800036e6:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036ea:	8526                	mv	a0,s1
    800036ec:	00001097          	auipc	ra,0x1
    800036f0:	ca0080e7          	jalr	-864(ra) # 8000438c <log_write>
      brelse(bp);
    800036f4:	8526                	mv	a0,s1
    800036f6:	00000097          	auipc	ra,0x0
    800036fa:	9ec080e7          	jalr	-1556(ra) # 800030e2 <brelse>
      return iget(dev, inum);
    800036fe:	0009059b          	sext.w	a1,s2
    80003702:	8556                	mv	a0,s5
    80003704:	00000097          	auipc	ra,0x0
    80003708:	da2080e7          	jalr	-606(ra) # 800034a6 <iget>
    8000370c:	74a2                	ld	s1,40(sp)
    8000370e:	7902                	ld	s2,32(sp)
    80003710:	69e2                	ld	s3,24(sp)
    80003712:	6a42                	ld	s4,16(sp)
    80003714:	6aa2                	ld	s5,8(sp)
    80003716:	6b02                	ld	s6,0(sp)
    80003718:	bf5d                	j	800036ce <ialloc+0x8c>

000000008000371a <iupdate>:
{
    8000371a:	1101                	add	sp,sp,-32
    8000371c:	ec06                	sd	ra,24(sp)
    8000371e:	e822                	sd	s0,16(sp)
    80003720:	e426                	sd	s1,8(sp)
    80003722:	e04a                	sd	s2,0(sp)
    80003724:	1000                	add	s0,sp,32
    80003726:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003728:	415c                	lw	a5,4(a0)
    8000372a:	0047d79b          	srlw	a5,a5,0x4
    8000372e:	0001c597          	auipc	a1,0x1c
    80003732:	9925a583          	lw	a1,-1646(a1) # 8001f0c0 <sb+0x18>
    80003736:	9dbd                	addw	a1,a1,a5
    80003738:	4108                	lw	a0,0(a0)
    8000373a:	00000097          	auipc	ra,0x0
    8000373e:	878080e7          	jalr	-1928(ra) # 80002fb2 <bread>
    80003742:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003744:	05850793          	add	a5,a0,88
    80003748:	40d8                	lw	a4,4(s1)
    8000374a:	8b3d                	and	a4,a4,15
    8000374c:	071a                	sll	a4,a4,0x6
    8000374e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003750:	04449703          	lh	a4,68(s1)
    80003754:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003758:	04649703          	lh	a4,70(s1)
    8000375c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003760:	04849703          	lh	a4,72(s1)
    80003764:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003768:	04a49703          	lh	a4,74(s1)
    8000376c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003770:	44f8                	lw	a4,76(s1)
    80003772:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003774:	03400613          	li	a2,52
    80003778:	05048593          	add	a1,s1,80
    8000377c:	00c78513          	add	a0,a5,12
    80003780:	ffffd097          	auipc	ra,0xffffd
    80003784:	610080e7          	jalr	1552(ra) # 80000d90 <memmove>
  log_write(bp);
    80003788:	854a                	mv	a0,s2
    8000378a:	00001097          	auipc	ra,0x1
    8000378e:	c02080e7          	jalr	-1022(ra) # 8000438c <log_write>
  brelse(bp);
    80003792:	854a                	mv	a0,s2
    80003794:	00000097          	auipc	ra,0x0
    80003798:	94e080e7          	jalr	-1714(ra) # 800030e2 <brelse>
}
    8000379c:	60e2                	ld	ra,24(sp)
    8000379e:	6442                	ld	s0,16(sp)
    800037a0:	64a2                	ld	s1,8(sp)
    800037a2:	6902                	ld	s2,0(sp)
    800037a4:	6105                	add	sp,sp,32
    800037a6:	8082                	ret

00000000800037a8 <idup>:
{
    800037a8:	1101                	add	sp,sp,-32
    800037aa:	ec06                	sd	ra,24(sp)
    800037ac:	e822                	sd	s0,16(sp)
    800037ae:	e426                	sd	s1,8(sp)
    800037b0:	1000                	add	s0,sp,32
    800037b2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037b4:	0001c517          	auipc	a0,0x1c
    800037b8:	91450513          	add	a0,a0,-1772 # 8001f0c8 <itable>
    800037bc:	ffffd097          	auipc	ra,0xffffd
    800037c0:	47c080e7          	jalr	1148(ra) # 80000c38 <acquire>
  ip->ref++;
    800037c4:	449c                	lw	a5,8(s1)
    800037c6:	2785                	addw	a5,a5,1
    800037c8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037ca:	0001c517          	auipc	a0,0x1c
    800037ce:	8fe50513          	add	a0,a0,-1794 # 8001f0c8 <itable>
    800037d2:	ffffd097          	auipc	ra,0xffffd
    800037d6:	51a080e7          	jalr	1306(ra) # 80000cec <release>
}
    800037da:	8526                	mv	a0,s1
    800037dc:	60e2                	ld	ra,24(sp)
    800037de:	6442                	ld	s0,16(sp)
    800037e0:	64a2                	ld	s1,8(sp)
    800037e2:	6105                	add	sp,sp,32
    800037e4:	8082                	ret

00000000800037e6 <ilock>:
{
    800037e6:	1101                	add	sp,sp,-32
    800037e8:	ec06                	sd	ra,24(sp)
    800037ea:	e822                	sd	s0,16(sp)
    800037ec:	e426                	sd	s1,8(sp)
    800037ee:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037f0:	c10d                	beqz	a0,80003812 <ilock+0x2c>
    800037f2:	84aa                	mv	s1,a0
    800037f4:	451c                	lw	a5,8(a0)
    800037f6:	00f05e63          	blez	a5,80003812 <ilock+0x2c>
  acquiresleep(&ip->lock);
    800037fa:	0541                	add	a0,a0,16
    800037fc:	00001097          	auipc	ra,0x1
    80003800:	cae080e7          	jalr	-850(ra) # 800044aa <acquiresleep>
  if(ip->valid == 0){
    80003804:	40bc                	lw	a5,64(s1)
    80003806:	cf99                	beqz	a5,80003824 <ilock+0x3e>
}
    80003808:	60e2                	ld	ra,24(sp)
    8000380a:	6442                	ld	s0,16(sp)
    8000380c:	64a2                	ld	s1,8(sp)
    8000380e:	6105                	add	sp,sp,32
    80003810:	8082                	ret
    80003812:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003814:	00005517          	auipc	a0,0x5
    80003818:	cf450513          	add	a0,a0,-780 # 80008508 <etext+0x508>
    8000381c:	ffffd097          	auipc	ra,0xffffd
    80003820:	d44080e7          	jalr	-700(ra) # 80000560 <panic>
    80003824:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003826:	40dc                	lw	a5,4(s1)
    80003828:	0047d79b          	srlw	a5,a5,0x4
    8000382c:	0001c597          	auipc	a1,0x1c
    80003830:	8945a583          	lw	a1,-1900(a1) # 8001f0c0 <sb+0x18>
    80003834:	9dbd                	addw	a1,a1,a5
    80003836:	4088                	lw	a0,0(s1)
    80003838:	fffff097          	auipc	ra,0xfffff
    8000383c:	77a080e7          	jalr	1914(ra) # 80002fb2 <bread>
    80003840:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003842:	05850593          	add	a1,a0,88
    80003846:	40dc                	lw	a5,4(s1)
    80003848:	8bbd                	and	a5,a5,15
    8000384a:	079a                	sll	a5,a5,0x6
    8000384c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000384e:	00059783          	lh	a5,0(a1)
    80003852:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003856:	00259783          	lh	a5,2(a1)
    8000385a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000385e:	00459783          	lh	a5,4(a1)
    80003862:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003866:	00659783          	lh	a5,6(a1)
    8000386a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000386e:	459c                	lw	a5,8(a1)
    80003870:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003872:	03400613          	li	a2,52
    80003876:	05b1                	add	a1,a1,12
    80003878:	05048513          	add	a0,s1,80
    8000387c:	ffffd097          	auipc	ra,0xffffd
    80003880:	514080e7          	jalr	1300(ra) # 80000d90 <memmove>
    brelse(bp);
    80003884:	854a                	mv	a0,s2
    80003886:	00000097          	auipc	ra,0x0
    8000388a:	85c080e7          	jalr	-1956(ra) # 800030e2 <brelse>
    ip->valid = 1;
    8000388e:	4785                	li	a5,1
    80003890:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003892:	04449783          	lh	a5,68(s1)
    80003896:	c399                	beqz	a5,8000389c <ilock+0xb6>
    80003898:	6902                	ld	s2,0(sp)
    8000389a:	b7bd                	j	80003808 <ilock+0x22>
      panic("ilock: no type");
    8000389c:	00005517          	auipc	a0,0x5
    800038a0:	c7450513          	add	a0,a0,-908 # 80008510 <etext+0x510>
    800038a4:	ffffd097          	auipc	ra,0xffffd
    800038a8:	cbc080e7          	jalr	-836(ra) # 80000560 <panic>

00000000800038ac <iunlock>:
{
    800038ac:	1101                	add	sp,sp,-32
    800038ae:	ec06                	sd	ra,24(sp)
    800038b0:	e822                	sd	s0,16(sp)
    800038b2:	e426                	sd	s1,8(sp)
    800038b4:	e04a                	sd	s2,0(sp)
    800038b6:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038b8:	c905                	beqz	a0,800038e8 <iunlock+0x3c>
    800038ba:	84aa                	mv	s1,a0
    800038bc:	01050913          	add	s2,a0,16
    800038c0:	854a                	mv	a0,s2
    800038c2:	00001097          	auipc	ra,0x1
    800038c6:	c82080e7          	jalr	-894(ra) # 80004544 <holdingsleep>
    800038ca:	cd19                	beqz	a0,800038e8 <iunlock+0x3c>
    800038cc:	449c                	lw	a5,8(s1)
    800038ce:	00f05d63          	blez	a5,800038e8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800038d2:	854a                	mv	a0,s2
    800038d4:	00001097          	auipc	ra,0x1
    800038d8:	c2c080e7          	jalr	-980(ra) # 80004500 <releasesleep>
}
    800038dc:	60e2                	ld	ra,24(sp)
    800038de:	6442                	ld	s0,16(sp)
    800038e0:	64a2                	ld	s1,8(sp)
    800038e2:	6902                	ld	s2,0(sp)
    800038e4:	6105                	add	sp,sp,32
    800038e6:	8082                	ret
    panic("iunlock");
    800038e8:	00005517          	auipc	a0,0x5
    800038ec:	c3850513          	add	a0,a0,-968 # 80008520 <etext+0x520>
    800038f0:	ffffd097          	auipc	ra,0xffffd
    800038f4:	c70080e7          	jalr	-912(ra) # 80000560 <panic>

00000000800038f8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038f8:	7179                	add	sp,sp,-48
    800038fa:	f406                	sd	ra,40(sp)
    800038fc:	f022                	sd	s0,32(sp)
    800038fe:	ec26                	sd	s1,24(sp)
    80003900:	e84a                	sd	s2,16(sp)
    80003902:	e44e                	sd	s3,8(sp)
    80003904:	1800                	add	s0,sp,48
    80003906:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003908:	05050493          	add	s1,a0,80
    8000390c:	08050913          	add	s2,a0,128
    80003910:	a021                	j	80003918 <itrunc+0x20>
    80003912:	0491                	add	s1,s1,4
    80003914:	01248d63          	beq	s1,s2,8000392e <itrunc+0x36>
    if(ip->addrs[i]){
    80003918:	408c                	lw	a1,0(s1)
    8000391a:	dde5                	beqz	a1,80003912 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000391c:	0009a503          	lw	a0,0(s3)
    80003920:	00000097          	auipc	ra,0x0
    80003924:	8d6080e7          	jalr	-1834(ra) # 800031f6 <bfree>
      ip->addrs[i] = 0;
    80003928:	0004a023          	sw	zero,0(s1)
    8000392c:	b7dd                	j	80003912 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000392e:	0809a583          	lw	a1,128(s3)
    80003932:	ed99                	bnez	a1,80003950 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003934:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003938:	854e                	mv	a0,s3
    8000393a:	00000097          	auipc	ra,0x0
    8000393e:	de0080e7          	jalr	-544(ra) # 8000371a <iupdate>
}
    80003942:	70a2                	ld	ra,40(sp)
    80003944:	7402                	ld	s0,32(sp)
    80003946:	64e2                	ld	s1,24(sp)
    80003948:	6942                	ld	s2,16(sp)
    8000394a:	69a2                	ld	s3,8(sp)
    8000394c:	6145                	add	sp,sp,48
    8000394e:	8082                	ret
    80003950:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003952:	0009a503          	lw	a0,0(s3)
    80003956:	fffff097          	auipc	ra,0xfffff
    8000395a:	65c080e7          	jalr	1628(ra) # 80002fb2 <bread>
    8000395e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003960:	05850493          	add	s1,a0,88
    80003964:	45850913          	add	s2,a0,1112
    80003968:	a021                	j	80003970 <itrunc+0x78>
    8000396a:	0491                	add	s1,s1,4
    8000396c:	01248b63          	beq	s1,s2,80003982 <itrunc+0x8a>
      if(a[j])
    80003970:	408c                	lw	a1,0(s1)
    80003972:	dde5                	beqz	a1,8000396a <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003974:	0009a503          	lw	a0,0(s3)
    80003978:	00000097          	auipc	ra,0x0
    8000397c:	87e080e7          	jalr	-1922(ra) # 800031f6 <bfree>
    80003980:	b7ed                	j	8000396a <itrunc+0x72>
    brelse(bp);
    80003982:	8552                	mv	a0,s4
    80003984:	fffff097          	auipc	ra,0xfffff
    80003988:	75e080e7          	jalr	1886(ra) # 800030e2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000398c:	0809a583          	lw	a1,128(s3)
    80003990:	0009a503          	lw	a0,0(s3)
    80003994:	00000097          	auipc	ra,0x0
    80003998:	862080e7          	jalr	-1950(ra) # 800031f6 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000399c:	0809a023          	sw	zero,128(s3)
    800039a0:	6a02                	ld	s4,0(sp)
    800039a2:	bf49                	j	80003934 <itrunc+0x3c>

00000000800039a4 <iput>:
{
    800039a4:	1101                	add	sp,sp,-32
    800039a6:	ec06                	sd	ra,24(sp)
    800039a8:	e822                	sd	s0,16(sp)
    800039aa:	e426                	sd	s1,8(sp)
    800039ac:	1000                	add	s0,sp,32
    800039ae:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039b0:	0001b517          	auipc	a0,0x1b
    800039b4:	71850513          	add	a0,a0,1816 # 8001f0c8 <itable>
    800039b8:	ffffd097          	auipc	ra,0xffffd
    800039bc:	280080e7          	jalr	640(ra) # 80000c38 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039c0:	4498                	lw	a4,8(s1)
    800039c2:	4785                	li	a5,1
    800039c4:	02f70263          	beq	a4,a5,800039e8 <iput+0x44>
  ip->ref--;
    800039c8:	449c                	lw	a5,8(s1)
    800039ca:	37fd                	addw	a5,a5,-1
    800039cc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039ce:	0001b517          	auipc	a0,0x1b
    800039d2:	6fa50513          	add	a0,a0,1786 # 8001f0c8 <itable>
    800039d6:	ffffd097          	auipc	ra,0xffffd
    800039da:	316080e7          	jalr	790(ra) # 80000cec <release>
}
    800039de:	60e2                	ld	ra,24(sp)
    800039e0:	6442                	ld	s0,16(sp)
    800039e2:	64a2                	ld	s1,8(sp)
    800039e4:	6105                	add	sp,sp,32
    800039e6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039e8:	40bc                	lw	a5,64(s1)
    800039ea:	dff9                	beqz	a5,800039c8 <iput+0x24>
    800039ec:	04a49783          	lh	a5,74(s1)
    800039f0:	ffe1                	bnez	a5,800039c8 <iput+0x24>
    800039f2:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800039f4:	01048913          	add	s2,s1,16
    800039f8:	854a                	mv	a0,s2
    800039fa:	00001097          	auipc	ra,0x1
    800039fe:	ab0080e7          	jalr	-1360(ra) # 800044aa <acquiresleep>
    release(&itable.lock);
    80003a02:	0001b517          	auipc	a0,0x1b
    80003a06:	6c650513          	add	a0,a0,1734 # 8001f0c8 <itable>
    80003a0a:	ffffd097          	auipc	ra,0xffffd
    80003a0e:	2e2080e7          	jalr	738(ra) # 80000cec <release>
    itrunc(ip);
    80003a12:	8526                	mv	a0,s1
    80003a14:	00000097          	auipc	ra,0x0
    80003a18:	ee4080e7          	jalr	-284(ra) # 800038f8 <itrunc>
    ip->type = 0;
    80003a1c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a20:	8526                	mv	a0,s1
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	cf8080e7          	jalr	-776(ra) # 8000371a <iupdate>
    ip->valid = 0;
    80003a2a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a2e:	854a                	mv	a0,s2
    80003a30:	00001097          	auipc	ra,0x1
    80003a34:	ad0080e7          	jalr	-1328(ra) # 80004500 <releasesleep>
    acquire(&itable.lock);
    80003a38:	0001b517          	auipc	a0,0x1b
    80003a3c:	69050513          	add	a0,a0,1680 # 8001f0c8 <itable>
    80003a40:	ffffd097          	auipc	ra,0xffffd
    80003a44:	1f8080e7          	jalr	504(ra) # 80000c38 <acquire>
    80003a48:	6902                	ld	s2,0(sp)
    80003a4a:	bfbd                	j	800039c8 <iput+0x24>

0000000080003a4c <iunlockput>:
{
    80003a4c:	1101                	add	sp,sp,-32
    80003a4e:	ec06                	sd	ra,24(sp)
    80003a50:	e822                	sd	s0,16(sp)
    80003a52:	e426                	sd	s1,8(sp)
    80003a54:	1000                	add	s0,sp,32
    80003a56:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a58:	00000097          	auipc	ra,0x0
    80003a5c:	e54080e7          	jalr	-428(ra) # 800038ac <iunlock>
  iput(ip);
    80003a60:	8526                	mv	a0,s1
    80003a62:	00000097          	auipc	ra,0x0
    80003a66:	f42080e7          	jalr	-190(ra) # 800039a4 <iput>
}
    80003a6a:	60e2                	ld	ra,24(sp)
    80003a6c:	6442                	ld	s0,16(sp)
    80003a6e:	64a2                	ld	s1,8(sp)
    80003a70:	6105                	add	sp,sp,32
    80003a72:	8082                	ret

0000000080003a74 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a74:	1141                	add	sp,sp,-16
    80003a76:	e422                	sd	s0,8(sp)
    80003a78:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003a7a:	411c                	lw	a5,0(a0)
    80003a7c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a7e:	415c                	lw	a5,4(a0)
    80003a80:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a82:	04451783          	lh	a5,68(a0)
    80003a86:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a8a:	04a51783          	lh	a5,74(a0)
    80003a8e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a92:	04c56783          	lwu	a5,76(a0)
    80003a96:	e99c                	sd	a5,16(a1)
}
    80003a98:	6422                	ld	s0,8(sp)
    80003a9a:	0141                	add	sp,sp,16
    80003a9c:	8082                	ret

0000000080003a9e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a9e:	457c                	lw	a5,76(a0)
    80003aa0:	10d7e563          	bltu	a5,a3,80003baa <readi+0x10c>
{
    80003aa4:	7159                	add	sp,sp,-112
    80003aa6:	f486                	sd	ra,104(sp)
    80003aa8:	f0a2                	sd	s0,96(sp)
    80003aaa:	eca6                	sd	s1,88(sp)
    80003aac:	e0d2                	sd	s4,64(sp)
    80003aae:	fc56                	sd	s5,56(sp)
    80003ab0:	f85a                	sd	s6,48(sp)
    80003ab2:	f45e                	sd	s7,40(sp)
    80003ab4:	1880                	add	s0,sp,112
    80003ab6:	8b2a                	mv	s6,a0
    80003ab8:	8bae                	mv	s7,a1
    80003aba:	8a32                	mv	s4,a2
    80003abc:	84b6                	mv	s1,a3
    80003abe:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ac0:	9f35                	addw	a4,a4,a3
    return 0;
    80003ac2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ac4:	0cd76a63          	bltu	a4,a3,80003b98 <readi+0xfa>
    80003ac8:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003aca:	00e7f463          	bgeu	a5,a4,80003ad2 <readi+0x34>
    n = ip->size - off;
    80003ace:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ad2:	0a0a8963          	beqz	s5,80003b84 <readi+0xe6>
    80003ad6:	e8ca                	sd	s2,80(sp)
    80003ad8:	f062                	sd	s8,32(sp)
    80003ada:	ec66                	sd	s9,24(sp)
    80003adc:	e86a                	sd	s10,16(sp)
    80003ade:	e46e                	sd	s11,8(sp)
    80003ae0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ae2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ae6:	5c7d                	li	s8,-1
    80003ae8:	a82d                	j	80003b22 <readi+0x84>
    80003aea:	020d1d93          	sll	s11,s10,0x20
    80003aee:	020ddd93          	srl	s11,s11,0x20
    80003af2:	05890613          	add	a2,s2,88
    80003af6:	86ee                	mv	a3,s11
    80003af8:	963a                	add	a2,a2,a4
    80003afa:	85d2                	mv	a1,s4
    80003afc:	855e                	mv	a0,s7
    80003afe:	fffff097          	auipc	ra,0xfffff
    80003b02:	9fe080e7          	jalr	-1538(ra) # 800024fc <either_copyout>
    80003b06:	05850d63          	beq	a0,s8,80003b60 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b0a:	854a                	mv	a0,s2
    80003b0c:	fffff097          	auipc	ra,0xfffff
    80003b10:	5d6080e7          	jalr	1494(ra) # 800030e2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b14:	013d09bb          	addw	s3,s10,s3
    80003b18:	009d04bb          	addw	s1,s10,s1
    80003b1c:	9a6e                	add	s4,s4,s11
    80003b1e:	0559fd63          	bgeu	s3,s5,80003b78 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003b22:	00a4d59b          	srlw	a1,s1,0xa
    80003b26:	855a                	mv	a0,s6
    80003b28:	00000097          	auipc	ra,0x0
    80003b2c:	88e080e7          	jalr	-1906(ra) # 800033b6 <bmap>
    80003b30:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b34:	c9b1                	beqz	a1,80003b88 <readi+0xea>
    bp = bread(ip->dev, addr);
    80003b36:	000b2503          	lw	a0,0(s6)
    80003b3a:	fffff097          	auipc	ra,0xfffff
    80003b3e:	478080e7          	jalr	1144(ra) # 80002fb2 <bread>
    80003b42:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b44:	3ff4f713          	and	a4,s1,1023
    80003b48:	40ec87bb          	subw	a5,s9,a4
    80003b4c:	413a86bb          	subw	a3,s5,s3
    80003b50:	8d3e                	mv	s10,a5
    80003b52:	2781                	sext.w	a5,a5
    80003b54:	0006861b          	sext.w	a2,a3
    80003b58:	f8f679e3          	bgeu	a2,a5,80003aea <readi+0x4c>
    80003b5c:	8d36                	mv	s10,a3
    80003b5e:	b771                	j	80003aea <readi+0x4c>
      brelse(bp);
    80003b60:	854a                	mv	a0,s2
    80003b62:	fffff097          	auipc	ra,0xfffff
    80003b66:	580080e7          	jalr	1408(ra) # 800030e2 <brelse>
      tot = -1;
    80003b6a:	59fd                	li	s3,-1
      break;
    80003b6c:	6946                	ld	s2,80(sp)
    80003b6e:	7c02                	ld	s8,32(sp)
    80003b70:	6ce2                	ld	s9,24(sp)
    80003b72:	6d42                	ld	s10,16(sp)
    80003b74:	6da2                	ld	s11,8(sp)
    80003b76:	a831                	j	80003b92 <readi+0xf4>
    80003b78:	6946                	ld	s2,80(sp)
    80003b7a:	7c02                	ld	s8,32(sp)
    80003b7c:	6ce2                	ld	s9,24(sp)
    80003b7e:	6d42                	ld	s10,16(sp)
    80003b80:	6da2                	ld	s11,8(sp)
    80003b82:	a801                	j	80003b92 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b84:	89d6                	mv	s3,s5
    80003b86:	a031                	j	80003b92 <readi+0xf4>
    80003b88:	6946                	ld	s2,80(sp)
    80003b8a:	7c02                	ld	s8,32(sp)
    80003b8c:	6ce2                	ld	s9,24(sp)
    80003b8e:	6d42                	ld	s10,16(sp)
    80003b90:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003b92:	0009851b          	sext.w	a0,s3
    80003b96:	69a6                	ld	s3,72(sp)
}
    80003b98:	70a6                	ld	ra,104(sp)
    80003b9a:	7406                	ld	s0,96(sp)
    80003b9c:	64e6                	ld	s1,88(sp)
    80003b9e:	6a06                	ld	s4,64(sp)
    80003ba0:	7ae2                	ld	s5,56(sp)
    80003ba2:	7b42                	ld	s6,48(sp)
    80003ba4:	7ba2                	ld	s7,40(sp)
    80003ba6:	6165                	add	sp,sp,112
    80003ba8:	8082                	ret
    return 0;
    80003baa:	4501                	li	a0,0
}
    80003bac:	8082                	ret

0000000080003bae <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bae:	457c                	lw	a5,76(a0)
    80003bb0:	10d7ee63          	bltu	a5,a3,80003ccc <writei+0x11e>
{
    80003bb4:	7159                	add	sp,sp,-112
    80003bb6:	f486                	sd	ra,104(sp)
    80003bb8:	f0a2                	sd	s0,96(sp)
    80003bba:	e8ca                	sd	s2,80(sp)
    80003bbc:	e0d2                	sd	s4,64(sp)
    80003bbe:	fc56                	sd	s5,56(sp)
    80003bc0:	f85a                	sd	s6,48(sp)
    80003bc2:	f45e                	sd	s7,40(sp)
    80003bc4:	1880                	add	s0,sp,112
    80003bc6:	8aaa                	mv	s5,a0
    80003bc8:	8bae                	mv	s7,a1
    80003bca:	8a32                	mv	s4,a2
    80003bcc:	8936                	mv	s2,a3
    80003bce:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bd0:	00e687bb          	addw	a5,a3,a4
    80003bd4:	0ed7ee63          	bltu	a5,a3,80003cd0 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003bd8:	00043737          	lui	a4,0x43
    80003bdc:	0ef76c63          	bltu	a4,a5,80003cd4 <writei+0x126>
    80003be0:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003be2:	0c0b0d63          	beqz	s6,80003cbc <writei+0x10e>
    80003be6:	eca6                	sd	s1,88(sp)
    80003be8:	f062                	sd	s8,32(sp)
    80003bea:	ec66                	sd	s9,24(sp)
    80003bec:	e86a                	sd	s10,16(sp)
    80003bee:	e46e                	sd	s11,8(sp)
    80003bf0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bf2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003bf6:	5c7d                	li	s8,-1
    80003bf8:	a091                	j	80003c3c <writei+0x8e>
    80003bfa:	020d1d93          	sll	s11,s10,0x20
    80003bfe:	020ddd93          	srl	s11,s11,0x20
    80003c02:	05848513          	add	a0,s1,88
    80003c06:	86ee                	mv	a3,s11
    80003c08:	8652                	mv	a2,s4
    80003c0a:	85de                	mv	a1,s7
    80003c0c:	953a                	add	a0,a0,a4
    80003c0e:	fffff097          	auipc	ra,0xfffff
    80003c12:	944080e7          	jalr	-1724(ra) # 80002552 <either_copyin>
    80003c16:	07850263          	beq	a0,s8,80003c7a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c1a:	8526                	mv	a0,s1
    80003c1c:	00000097          	auipc	ra,0x0
    80003c20:	770080e7          	jalr	1904(ra) # 8000438c <log_write>
    brelse(bp);
    80003c24:	8526                	mv	a0,s1
    80003c26:	fffff097          	auipc	ra,0xfffff
    80003c2a:	4bc080e7          	jalr	1212(ra) # 800030e2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c2e:	013d09bb          	addw	s3,s10,s3
    80003c32:	012d093b          	addw	s2,s10,s2
    80003c36:	9a6e                	add	s4,s4,s11
    80003c38:	0569f663          	bgeu	s3,s6,80003c84 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003c3c:	00a9559b          	srlw	a1,s2,0xa
    80003c40:	8556                	mv	a0,s5
    80003c42:	fffff097          	auipc	ra,0xfffff
    80003c46:	774080e7          	jalr	1908(ra) # 800033b6 <bmap>
    80003c4a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c4e:	c99d                	beqz	a1,80003c84 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003c50:	000aa503          	lw	a0,0(s5)
    80003c54:	fffff097          	auipc	ra,0xfffff
    80003c58:	35e080e7          	jalr	862(ra) # 80002fb2 <bread>
    80003c5c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c5e:	3ff97713          	and	a4,s2,1023
    80003c62:	40ec87bb          	subw	a5,s9,a4
    80003c66:	413b06bb          	subw	a3,s6,s3
    80003c6a:	8d3e                	mv	s10,a5
    80003c6c:	2781                	sext.w	a5,a5
    80003c6e:	0006861b          	sext.w	a2,a3
    80003c72:	f8f674e3          	bgeu	a2,a5,80003bfa <writei+0x4c>
    80003c76:	8d36                	mv	s10,a3
    80003c78:	b749                	j	80003bfa <writei+0x4c>
      brelse(bp);
    80003c7a:	8526                	mv	a0,s1
    80003c7c:	fffff097          	auipc	ra,0xfffff
    80003c80:	466080e7          	jalr	1126(ra) # 800030e2 <brelse>
  }

  if(off > ip->size)
    80003c84:	04caa783          	lw	a5,76(s5)
    80003c88:	0327fc63          	bgeu	a5,s2,80003cc0 <writei+0x112>
    ip->size = off;
    80003c8c:	052aa623          	sw	s2,76(s5)
    80003c90:	64e6                	ld	s1,88(sp)
    80003c92:	7c02                	ld	s8,32(sp)
    80003c94:	6ce2                	ld	s9,24(sp)
    80003c96:	6d42                	ld	s10,16(sp)
    80003c98:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c9a:	8556                	mv	a0,s5
    80003c9c:	00000097          	auipc	ra,0x0
    80003ca0:	a7e080e7          	jalr	-1410(ra) # 8000371a <iupdate>

  return tot;
    80003ca4:	0009851b          	sext.w	a0,s3
    80003ca8:	69a6                	ld	s3,72(sp)
}
    80003caa:	70a6                	ld	ra,104(sp)
    80003cac:	7406                	ld	s0,96(sp)
    80003cae:	6946                	ld	s2,80(sp)
    80003cb0:	6a06                	ld	s4,64(sp)
    80003cb2:	7ae2                	ld	s5,56(sp)
    80003cb4:	7b42                	ld	s6,48(sp)
    80003cb6:	7ba2                	ld	s7,40(sp)
    80003cb8:	6165                	add	sp,sp,112
    80003cba:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cbc:	89da                	mv	s3,s6
    80003cbe:	bff1                	j	80003c9a <writei+0xec>
    80003cc0:	64e6                	ld	s1,88(sp)
    80003cc2:	7c02                	ld	s8,32(sp)
    80003cc4:	6ce2                	ld	s9,24(sp)
    80003cc6:	6d42                	ld	s10,16(sp)
    80003cc8:	6da2                	ld	s11,8(sp)
    80003cca:	bfc1                	j	80003c9a <writei+0xec>
    return -1;
    80003ccc:	557d                	li	a0,-1
}
    80003cce:	8082                	ret
    return -1;
    80003cd0:	557d                	li	a0,-1
    80003cd2:	bfe1                	j	80003caa <writei+0xfc>
    return -1;
    80003cd4:	557d                	li	a0,-1
    80003cd6:	bfd1                	j	80003caa <writei+0xfc>

0000000080003cd8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003cd8:	1141                	add	sp,sp,-16
    80003cda:	e406                	sd	ra,8(sp)
    80003cdc:	e022                	sd	s0,0(sp)
    80003cde:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ce0:	4639                	li	a2,14
    80003ce2:	ffffd097          	auipc	ra,0xffffd
    80003ce6:	122080e7          	jalr	290(ra) # 80000e04 <strncmp>
}
    80003cea:	60a2                	ld	ra,8(sp)
    80003cec:	6402                	ld	s0,0(sp)
    80003cee:	0141                	add	sp,sp,16
    80003cf0:	8082                	ret

0000000080003cf2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003cf2:	7139                	add	sp,sp,-64
    80003cf4:	fc06                	sd	ra,56(sp)
    80003cf6:	f822                	sd	s0,48(sp)
    80003cf8:	f426                	sd	s1,40(sp)
    80003cfa:	f04a                	sd	s2,32(sp)
    80003cfc:	ec4e                	sd	s3,24(sp)
    80003cfe:	e852                	sd	s4,16(sp)
    80003d00:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d02:	04451703          	lh	a4,68(a0)
    80003d06:	4785                	li	a5,1
    80003d08:	00f71a63          	bne	a4,a5,80003d1c <dirlookup+0x2a>
    80003d0c:	892a                	mv	s2,a0
    80003d0e:	89ae                	mv	s3,a1
    80003d10:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d12:	457c                	lw	a5,76(a0)
    80003d14:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d16:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d18:	e79d                	bnez	a5,80003d46 <dirlookup+0x54>
    80003d1a:	a8a5                	j	80003d92 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d1c:	00005517          	auipc	a0,0x5
    80003d20:	80c50513          	add	a0,a0,-2036 # 80008528 <etext+0x528>
    80003d24:	ffffd097          	auipc	ra,0xffffd
    80003d28:	83c080e7          	jalr	-1988(ra) # 80000560 <panic>
      panic("dirlookup read");
    80003d2c:	00005517          	auipc	a0,0x5
    80003d30:	81450513          	add	a0,a0,-2028 # 80008540 <etext+0x540>
    80003d34:	ffffd097          	auipc	ra,0xffffd
    80003d38:	82c080e7          	jalr	-2004(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d3c:	24c1                	addw	s1,s1,16
    80003d3e:	04c92783          	lw	a5,76(s2)
    80003d42:	04f4f763          	bgeu	s1,a5,80003d90 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d46:	4741                	li	a4,16
    80003d48:	86a6                	mv	a3,s1
    80003d4a:	fc040613          	add	a2,s0,-64
    80003d4e:	4581                	li	a1,0
    80003d50:	854a                	mv	a0,s2
    80003d52:	00000097          	auipc	ra,0x0
    80003d56:	d4c080e7          	jalr	-692(ra) # 80003a9e <readi>
    80003d5a:	47c1                	li	a5,16
    80003d5c:	fcf518e3          	bne	a0,a5,80003d2c <dirlookup+0x3a>
    if(de.inum == 0)
    80003d60:	fc045783          	lhu	a5,-64(s0)
    80003d64:	dfe1                	beqz	a5,80003d3c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003d66:	fc240593          	add	a1,s0,-62
    80003d6a:	854e                	mv	a0,s3
    80003d6c:	00000097          	auipc	ra,0x0
    80003d70:	f6c080e7          	jalr	-148(ra) # 80003cd8 <namecmp>
    80003d74:	f561                	bnez	a0,80003d3c <dirlookup+0x4a>
      if(poff)
    80003d76:	000a0463          	beqz	s4,80003d7e <dirlookup+0x8c>
        *poff = off;
    80003d7a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d7e:	fc045583          	lhu	a1,-64(s0)
    80003d82:	00092503          	lw	a0,0(s2)
    80003d86:	fffff097          	auipc	ra,0xfffff
    80003d8a:	720080e7          	jalr	1824(ra) # 800034a6 <iget>
    80003d8e:	a011                	j	80003d92 <dirlookup+0xa0>
  return 0;
    80003d90:	4501                	li	a0,0
}
    80003d92:	70e2                	ld	ra,56(sp)
    80003d94:	7442                	ld	s0,48(sp)
    80003d96:	74a2                	ld	s1,40(sp)
    80003d98:	7902                	ld	s2,32(sp)
    80003d9a:	69e2                	ld	s3,24(sp)
    80003d9c:	6a42                	ld	s4,16(sp)
    80003d9e:	6121                	add	sp,sp,64
    80003da0:	8082                	ret

0000000080003da2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003da2:	711d                	add	sp,sp,-96
    80003da4:	ec86                	sd	ra,88(sp)
    80003da6:	e8a2                	sd	s0,80(sp)
    80003da8:	e4a6                	sd	s1,72(sp)
    80003daa:	e0ca                	sd	s2,64(sp)
    80003dac:	fc4e                	sd	s3,56(sp)
    80003dae:	f852                	sd	s4,48(sp)
    80003db0:	f456                	sd	s5,40(sp)
    80003db2:	f05a                	sd	s6,32(sp)
    80003db4:	ec5e                	sd	s7,24(sp)
    80003db6:	e862                	sd	s8,16(sp)
    80003db8:	e466                	sd	s9,8(sp)
    80003dba:	1080                	add	s0,sp,96
    80003dbc:	84aa                	mv	s1,a0
    80003dbe:	8b2e                	mv	s6,a1
    80003dc0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003dc2:	00054703          	lbu	a4,0(a0)
    80003dc6:	02f00793          	li	a5,47
    80003dca:	02f70263          	beq	a4,a5,80003dee <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003dce:	ffffe097          	auipc	ra,0xffffe
    80003dd2:	c7c080e7          	jalr	-900(ra) # 80001a4a <myproc>
    80003dd6:	15053503          	ld	a0,336(a0)
    80003dda:	00000097          	auipc	ra,0x0
    80003dde:	9ce080e7          	jalr	-1586(ra) # 800037a8 <idup>
    80003de2:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003de4:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003de8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003dea:	4b85                	li	s7,1
    80003dec:	a875                	j	80003ea8 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003dee:	4585                	li	a1,1
    80003df0:	4505                	li	a0,1
    80003df2:	fffff097          	auipc	ra,0xfffff
    80003df6:	6b4080e7          	jalr	1716(ra) # 800034a6 <iget>
    80003dfa:	8a2a                	mv	s4,a0
    80003dfc:	b7e5                	j	80003de4 <namex+0x42>
      iunlockput(ip);
    80003dfe:	8552                	mv	a0,s4
    80003e00:	00000097          	auipc	ra,0x0
    80003e04:	c4c080e7          	jalr	-948(ra) # 80003a4c <iunlockput>
      return 0;
    80003e08:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e0a:	8552                	mv	a0,s4
    80003e0c:	60e6                	ld	ra,88(sp)
    80003e0e:	6446                	ld	s0,80(sp)
    80003e10:	64a6                	ld	s1,72(sp)
    80003e12:	6906                	ld	s2,64(sp)
    80003e14:	79e2                	ld	s3,56(sp)
    80003e16:	7a42                	ld	s4,48(sp)
    80003e18:	7aa2                	ld	s5,40(sp)
    80003e1a:	7b02                	ld	s6,32(sp)
    80003e1c:	6be2                	ld	s7,24(sp)
    80003e1e:	6c42                	ld	s8,16(sp)
    80003e20:	6ca2                	ld	s9,8(sp)
    80003e22:	6125                	add	sp,sp,96
    80003e24:	8082                	ret
      iunlock(ip);
    80003e26:	8552                	mv	a0,s4
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	a84080e7          	jalr	-1404(ra) # 800038ac <iunlock>
      return ip;
    80003e30:	bfe9                	j	80003e0a <namex+0x68>
      iunlockput(ip);
    80003e32:	8552                	mv	a0,s4
    80003e34:	00000097          	auipc	ra,0x0
    80003e38:	c18080e7          	jalr	-1000(ra) # 80003a4c <iunlockput>
      return 0;
    80003e3c:	8a4e                	mv	s4,s3
    80003e3e:	b7f1                	j	80003e0a <namex+0x68>
  len = path - s;
    80003e40:	40998633          	sub	a2,s3,s1
    80003e44:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003e48:	099c5863          	bge	s8,s9,80003ed8 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003e4c:	4639                	li	a2,14
    80003e4e:	85a6                	mv	a1,s1
    80003e50:	8556                	mv	a0,s5
    80003e52:	ffffd097          	auipc	ra,0xffffd
    80003e56:	f3e080e7          	jalr	-194(ra) # 80000d90 <memmove>
    80003e5a:	84ce                	mv	s1,s3
  while(*path == '/')
    80003e5c:	0004c783          	lbu	a5,0(s1)
    80003e60:	01279763          	bne	a5,s2,80003e6e <namex+0xcc>
    path++;
    80003e64:	0485                	add	s1,s1,1
  while(*path == '/')
    80003e66:	0004c783          	lbu	a5,0(s1)
    80003e6a:	ff278de3          	beq	a5,s2,80003e64 <namex+0xc2>
    ilock(ip);
    80003e6e:	8552                	mv	a0,s4
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	976080e7          	jalr	-1674(ra) # 800037e6 <ilock>
    if(ip->type != T_DIR){
    80003e78:	044a1783          	lh	a5,68(s4)
    80003e7c:	f97791e3          	bne	a5,s7,80003dfe <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003e80:	000b0563          	beqz	s6,80003e8a <namex+0xe8>
    80003e84:	0004c783          	lbu	a5,0(s1)
    80003e88:	dfd9                	beqz	a5,80003e26 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e8a:	4601                	li	a2,0
    80003e8c:	85d6                	mv	a1,s5
    80003e8e:	8552                	mv	a0,s4
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	e62080e7          	jalr	-414(ra) # 80003cf2 <dirlookup>
    80003e98:	89aa                	mv	s3,a0
    80003e9a:	dd41                	beqz	a0,80003e32 <namex+0x90>
    iunlockput(ip);
    80003e9c:	8552                	mv	a0,s4
    80003e9e:	00000097          	auipc	ra,0x0
    80003ea2:	bae080e7          	jalr	-1106(ra) # 80003a4c <iunlockput>
    ip = next;
    80003ea6:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003ea8:	0004c783          	lbu	a5,0(s1)
    80003eac:	01279763          	bne	a5,s2,80003eba <namex+0x118>
    path++;
    80003eb0:	0485                	add	s1,s1,1
  while(*path == '/')
    80003eb2:	0004c783          	lbu	a5,0(s1)
    80003eb6:	ff278de3          	beq	a5,s2,80003eb0 <namex+0x10e>
  if(*path == 0)
    80003eba:	cb9d                	beqz	a5,80003ef0 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003ebc:	0004c783          	lbu	a5,0(s1)
    80003ec0:	89a6                	mv	s3,s1
  len = path - s;
    80003ec2:	4c81                	li	s9,0
    80003ec4:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003ec6:	01278963          	beq	a5,s2,80003ed8 <namex+0x136>
    80003eca:	dbbd                	beqz	a5,80003e40 <namex+0x9e>
    path++;
    80003ecc:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80003ece:	0009c783          	lbu	a5,0(s3)
    80003ed2:	ff279ce3          	bne	a5,s2,80003eca <namex+0x128>
    80003ed6:	b7ad                	j	80003e40 <namex+0x9e>
    memmove(name, s, len);
    80003ed8:	2601                	sext.w	a2,a2
    80003eda:	85a6                	mv	a1,s1
    80003edc:	8556                	mv	a0,s5
    80003ede:	ffffd097          	auipc	ra,0xffffd
    80003ee2:	eb2080e7          	jalr	-334(ra) # 80000d90 <memmove>
    name[len] = 0;
    80003ee6:	9cd6                	add	s9,s9,s5
    80003ee8:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003eec:	84ce                	mv	s1,s3
    80003eee:	b7bd                	j	80003e5c <namex+0xba>
  if(nameiparent){
    80003ef0:	f00b0de3          	beqz	s6,80003e0a <namex+0x68>
    iput(ip);
    80003ef4:	8552                	mv	a0,s4
    80003ef6:	00000097          	auipc	ra,0x0
    80003efa:	aae080e7          	jalr	-1362(ra) # 800039a4 <iput>
    return 0;
    80003efe:	4a01                	li	s4,0
    80003f00:	b729                	j	80003e0a <namex+0x68>

0000000080003f02 <dirlink>:
{
    80003f02:	7139                	add	sp,sp,-64
    80003f04:	fc06                	sd	ra,56(sp)
    80003f06:	f822                	sd	s0,48(sp)
    80003f08:	f04a                	sd	s2,32(sp)
    80003f0a:	ec4e                	sd	s3,24(sp)
    80003f0c:	e852                	sd	s4,16(sp)
    80003f0e:	0080                	add	s0,sp,64
    80003f10:	892a                	mv	s2,a0
    80003f12:	8a2e                	mv	s4,a1
    80003f14:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f16:	4601                	li	a2,0
    80003f18:	00000097          	auipc	ra,0x0
    80003f1c:	dda080e7          	jalr	-550(ra) # 80003cf2 <dirlookup>
    80003f20:	ed25                	bnez	a0,80003f98 <dirlink+0x96>
    80003f22:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f24:	04c92483          	lw	s1,76(s2)
    80003f28:	c49d                	beqz	s1,80003f56 <dirlink+0x54>
    80003f2a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f2c:	4741                	li	a4,16
    80003f2e:	86a6                	mv	a3,s1
    80003f30:	fc040613          	add	a2,s0,-64
    80003f34:	4581                	li	a1,0
    80003f36:	854a                	mv	a0,s2
    80003f38:	00000097          	auipc	ra,0x0
    80003f3c:	b66080e7          	jalr	-1178(ra) # 80003a9e <readi>
    80003f40:	47c1                	li	a5,16
    80003f42:	06f51163          	bne	a0,a5,80003fa4 <dirlink+0xa2>
    if(de.inum == 0)
    80003f46:	fc045783          	lhu	a5,-64(s0)
    80003f4a:	c791                	beqz	a5,80003f56 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f4c:	24c1                	addw	s1,s1,16
    80003f4e:	04c92783          	lw	a5,76(s2)
    80003f52:	fcf4ede3          	bltu	s1,a5,80003f2c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f56:	4639                	li	a2,14
    80003f58:	85d2                	mv	a1,s4
    80003f5a:	fc240513          	add	a0,s0,-62
    80003f5e:	ffffd097          	auipc	ra,0xffffd
    80003f62:	edc080e7          	jalr	-292(ra) # 80000e3a <strncpy>
  de.inum = inum;
    80003f66:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f6a:	4741                	li	a4,16
    80003f6c:	86a6                	mv	a3,s1
    80003f6e:	fc040613          	add	a2,s0,-64
    80003f72:	4581                	li	a1,0
    80003f74:	854a                	mv	a0,s2
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	c38080e7          	jalr	-968(ra) # 80003bae <writei>
    80003f7e:	1541                	add	a0,a0,-16
    80003f80:	00a03533          	snez	a0,a0
    80003f84:	40a00533          	neg	a0,a0
    80003f88:	74a2                	ld	s1,40(sp)
}
    80003f8a:	70e2                	ld	ra,56(sp)
    80003f8c:	7442                	ld	s0,48(sp)
    80003f8e:	7902                	ld	s2,32(sp)
    80003f90:	69e2                	ld	s3,24(sp)
    80003f92:	6a42                	ld	s4,16(sp)
    80003f94:	6121                	add	sp,sp,64
    80003f96:	8082                	ret
    iput(ip);
    80003f98:	00000097          	auipc	ra,0x0
    80003f9c:	a0c080e7          	jalr	-1524(ra) # 800039a4 <iput>
    return -1;
    80003fa0:	557d                	li	a0,-1
    80003fa2:	b7e5                	j	80003f8a <dirlink+0x88>
      panic("dirlink read");
    80003fa4:	00004517          	auipc	a0,0x4
    80003fa8:	5ac50513          	add	a0,a0,1452 # 80008550 <etext+0x550>
    80003fac:	ffffc097          	auipc	ra,0xffffc
    80003fb0:	5b4080e7          	jalr	1460(ra) # 80000560 <panic>

0000000080003fb4 <namei>:

struct inode*
namei(char *path)
{
    80003fb4:	1101                	add	sp,sp,-32
    80003fb6:	ec06                	sd	ra,24(sp)
    80003fb8:	e822                	sd	s0,16(sp)
    80003fba:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003fbc:	fe040613          	add	a2,s0,-32
    80003fc0:	4581                	li	a1,0
    80003fc2:	00000097          	auipc	ra,0x0
    80003fc6:	de0080e7          	jalr	-544(ra) # 80003da2 <namex>
}
    80003fca:	60e2                	ld	ra,24(sp)
    80003fcc:	6442                	ld	s0,16(sp)
    80003fce:	6105                	add	sp,sp,32
    80003fd0:	8082                	ret

0000000080003fd2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003fd2:	1141                	add	sp,sp,-16
    80003fd4:	e406                	sd	ra,8(sp)
    80003fd6:	e022                	sd	s0,0(sp)
    80003fd8:	0800                	add	s0,sp,16
    80003fda:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003fdc:	4585                	li	a1,1
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	dc4080e7          	jalr	-572(ra) # 80003da2 <namex>
}
    80003fe6:	60a2                	ld	ra,8(sp)
    80003fe8:	6402                	ld	s0,0(sp)
    80003fea:	0141                	add	sp,sp,16
    80003fec:	8082                	ret

0000000080003fee <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003fee:	1101                	add	sp,sp,-32
    80003ff0:	ec06                	sd	ra,24(sp)
    80003ff2:	e822                	sd	s0,16(sp)
    80003ff4:	e426                	sd	s1,8(sp)
    80003ff6:	e04a                	sd	s2,0(sp)
    80003ff8:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ffa:	0001d917          	auipc	s2,0x1d
    80003ffe:	b7690913          	add	s2,s2,-1162 # 80020b70 <log>
    80004002:	01892583          	lw	a1,24(s2)
    80004006:	02892503          	lw	a0,40(s2)
    8000400a:	fffff097          	auipc	ra,0xfffff
    8000400e:	fa8080e7          	jalr	-88(ra) # 80002fb2 <bread>
    80004012:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004014:	02c92603          	lw	a2,44(s2)
    80004018:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000401a:	00c05f63          	blez	a2,80004038 <write_head+0x4a>
    8000401e:	0001d717          	auipc	a4,0x1d
    80004022:	b8270713          	add	a4,a4,-1150 # 80020ba0 <log+0x30>
    80004026:	87aa                	mv	a5,a0
    80004028:	060a                	sll	a2,a2,0x2
    8000402a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000402c:	4314                	lw	a3,0(a4)
    8000402e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004030:	0711                	add	a4,a4,4
    80004032:	0791                	add	a5,a5,4
    80004034:	fec79ce3          	bne	a5,a2,8000402c <write_head+0x3e>
  }
  bwrite(buf);
    80004038:	8526                	mv	a0,s1
    8000403a:	fffff097          	auipc	ra,0xfffff
    8000403e:	06a080e7          	jalr	106(ra) # 800030a4 <bwrite>
  brelse(buf);
    80004042:	8526                	mv	a0,s1
    80004044:	fffff097          	auipc	ra,0xfffff
    80004048:	09e080e7          	jalr	158(ra) # 800030e2 <brelse>
}
    8000404c:	60e2                	ld	ra,24(sp)
    8000404e:	6442                	ld	s0,16(sp)
    80004050:	64a2                	ld	s1,8(sp)
    80004052:	6902                	ld	s2,0(sp)
    80004054:	6105                	add	sp,sp,32
    80004056:	8082                	ret

0000000080004058 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004058:	0001d797          	auipc	a5,0x1d
    8000405c:	b447a783          	lw	a5,-1212(a5) # 80020b9c <log+0x2c>
    80004060:	0af05d63          	blez	a5,8000411a <install_trans+0xc2>
{
    80004064:	7139                	add	sp,sp,-64
    80004066:	fc06                	sd	ra,56(sp)
    80004068:	f822                	sd	s0,48(sp)
    8000406a:	f426                	sd	s1,40(sp)
    8000406c:	f04a                	sd	s2,32(sp)
    8000406e:	ec4e                	sd	s3,24(sp)
    80004070:	e852                	sd	s4,16(sp)
    80004072:	e456                	sd	s5,8(sp)
    80004074:	e05a                	sd	s6,0(sp)
    80004076:	0080                	add	s0,sp,64
    80004078:	8b2a                	mv	s6,a0
    8000407a:	0001da97          	auipc	s5,0x1d
    8000407e:	b26a8a93          	add	s5,s5,-1242 # 80020ba0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004082:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004084:	0001d997          	auipc	s3,0x1d
    80004088:	aec98993          	add	s3,s3,-1300 # 80020b70 <log>
    8000408c:	a00d                	j	800040ae <install_trans+0x56>
    brelse(lbuf);
    8000408e:	854a                	mv	a0,s2
    80004090:	fffff097          	auipc	ra,0xfffff
    80004094:	052080e7          	jalr	82(ra) # 800030e2 <brelse>
    brelse(dbuf);
    80004098:	8526                	mv	a0,s1
    8000409a:	fffff097          	auipc	ra,0xfffff
    8000409e:	048080e7          	jalr	72(ra) # 800030e2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040a2:	2a05                	addw	s4,s4,1
    800040a4:	0a91                	add	s5,s5,4
    800040a6:	02c9a783          	lw	a5,44(s3)
    800040aa:	04fa5e63          	bge	s4,a5,80004106 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040ae:	0189a583          	lw	a1,24(s3)
    800040b2:	014585bb          	addw	a1,a1,s4
    800040b6:	2585                	addw	a1,a1,1
    800040b8:	0289a503          	lw	a0,40(s3)
    800040bc:	fffff097          	auipc	ra,0xfffff
    800040c0:	ef6080e7          	jalr	-266(ra) # 80002fb2 <bread>
    800040c4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800040c6:	000aa583          	lw	a1,0(s5)
    800040ca:	0289a503          	lw	a0,40(s3)
    800040ce:	fffff097          	auipc	ra,0xfffff
    800040d2:	ee4080e7          	jalr	-284(ra) # 80002fb2 <bread>
    800040d6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040d8:	40000613          	li	a2,1024
    800040dc:	05890593          	add	a1,s2,88
    800040e0:	05850513          	add	a0,a0,88
    800040e4:	ffffd097          	auipc	ra,0xffffd
    800040e8:	cac080e7          	jalr	-852(ra) # 80000d90 <memmove>
    bwrite(dbuf);  // write dst to disk
    800040ec:	8526                	mv	a0,s1
    800040ee:	fffff097          	auipc	ra,0xfffff
    800040f2:	fb6080e7          	jalr	-74(ra) # 800030a4 <bwrite>
    if(recovering == 0)
    800040f6:	f80b1ce3          	bnez	s6,8000408e <install_trans+0x36>
      bunpin(dbuf);
    800040fa:	8526                	mv	a0,s1
    800040fc:	fffff097          	auipc	ra,0xfffff
    80004100:	0be080e7          	jalr	190(ra) # 800031ba <bunpin>
    80004104:	b769                	j	8000408e <install_trans+0x36>
}
    80004106:	70e2                	ld	ra,56(sp)
    80004108:	7442                	ld	s0,48(sp)
    8000410a:	74a2                	ld	s1,40(sp)
    8000410c:	7902                	ld	s2,32(sp)
    8000410e:	69e2                	ld	s3,24(sp)
    80004110:	6a42                	ld	s4,16(sp)
    80004112:	6aa2                	ld	s5,8(sp)
    80004114:	6b02                	ld	s6,0(sp)
    80004116:	6121                	add	sp,sp,64
    80004118:	8082                	ret
    8000411a:	8082                	ret

000000008000411c <initlog>:
{
    8000411c:	7179                	add	sp,sp,-48
    8000411e:	f406                	sd	ra,40(sp)
    80004120:	f022                	sd	s0,32(sp)
    80004122:	ec26                	sd	s1,24(sp)
    80004124:	e84a                	sd	s2,16(sp)
    80004126:	e44e                	sd	s3,8(sp)
    80004128:	1800                	add	s0,sp,48
    8000412a:	892a                	mv	s2,a0
    8000412c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000412e:	0001d497          	auipc	s1,0x1d
    80004132:	a4248493          	add	s1,s1,-1470 # 80020b70 <log>
    80004136:	00004597          	auipc	a1,0x4
    8000413a:	42a58593          	add	a1,a1,1066 # 80008560 <etext+0x560>
    8000413e:	8526                	mv	a0,s1
    80004140:	ffffd097          	auipc	ra,0xffffd
    80004144:	a68080e7          	jalr	-1432(ra) # 80000ba8 <initlock>
  log.start = sb->logstart;
    80004148:	0149a583          	lw	a1,20(s3)
    8000414c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000414e:	0109a783          	lw	a5,16(s3)
    80004152:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004154:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004158:	854a                	mv	a0,s2
    8000415a:	fffff097          	auipc	ra,0xfffff
    8000415e:	e58080e7          	jalr	-424(ra) # 80002fb2 <bread>
  log.lh.n = lh->n;
    80004162:	4d30                	lw	a2,88(a0)
    80004164:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004166:	00c05f63          	blez	a2,80004184 <initlog+0x68>
    8000416a:	87aa                	mv	a5,a0
    8000416c:	0001d717          	auipc	a4,0x1d
    80004170:	a3470713          	add	a4,a4,-1484 # 80020ba0 <log+0x30>
    80004174:	060a                	sll	a2,a2,0x2
    80004176:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004178:	4ff4                	lw	a3,92(a5)
    8000417a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000417c:	0791                	add	a5,a5,4
    8000417e:	0711                	add	a4,a4,4
    80004180:	fec79ce3          	bne	a5,a2,80004178 <initlog+0x5c>
  brelse(buf);
    80004184:	fffff097          	auipc	ra,0xfffff
    80004188:	f5e080e7          	jalr	-162(ra) # 800030e2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000418c:	4505                	li	a0,1
    8000418e:	00000097          	auipc	ra,0x0
    80004192:	eca080e7          	jalr	-310(ra) # 80004058 <install_trans>
  log.lh.n = 0;
    80004196:	0001d797          	auipc	a5,0x1d
    8000419a:	a007a323          	sw	zero,-1530(a5) # 80020b9c <log+0x2c>
  write_head(); // clear the log
    8000419e:	00000097          	auipc	ra,0x0
    800041a2:	e50080e7          	jalr	-432(ra) # 80003fee <write_head>
}
    800041a6:	70a2                	ld	ra,40(sp)
    800041a8:	7402                	ld	s0,32(sp)
    800041aa:	64e2                	ld	s1,24(sp)
    800041ac:	6942                	ld	s2,16(sp)
    800041ae:	69a2                	ld	s3,8(sp)
    800041b0:	6145                	add	sp,sp,48
    800041b2:	8082                	ret

00000000800041b4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800041b4:	1101                	add	sp,sp,-32
    800041b6:	ec06                	sd	ra,24(sp)
    800041b8:	e822                	sd	s0,16(sp)
    800041ba:	e426                	sd	s1,8(sp)
    800041bc:	e04a                	sd	s2,0(sp)
    800041be:	1000                	add	s0,sp,32
  acquire(&log.lock);
    800041c0:	0001d517          	auipc	a0,0x1d
    800041c4:	9b050513          	add	a0,a0,-1616 # 80020b70 <log>
    800041c8:	ffffd097          	auipc	ra,0xffffd
    800041cc:	a70080e7          	jalr	-1424(ra) # 80000c38 <acquire>
  while(1){
    if(log.committing){
    800041d0:	0001d497          	auipc	s1,0x1d
    800041d4:	9a048493          	add	s1,s1,-1632 # 80020b70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041d8:	4979                	li	s2,30
    800041da:	a039                	j	800041e8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800041dc:	85a6                	mv	a1,s1
    800041de:	8526                	mv	a0,s1
    800041e0:	ffffe097          	auipc	ra,0xffffe
    800041e4:	f14080e7          	jalr	-236(ra) # 800020f4 <sleep>
    if(log.committing){
    800041e8:	50dc                	lw	a5,36(s1)
    800041ea:	fbed                	bnez	a5,800041dc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041ec:	5098                	lw	a4,32(s1)
    800041ee:	2705                	addw	a4,a4,1
    800041f0:	0027179b          	sllw	a5,a4,0x2
    800041f4:	9fb9                	addw	a5,a5,a4
    800041f6:	0017979b          	sllw	a5,a5,0x1
    800041fa:	54d4                	lw	a3,44(s1)
    800041fc:	9fb5                	addw	a5,a5,a3
    800041fe:	00f95963          	bge	s2,a5,80004210 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004202:	85a6                	mv	a1,s1
    80004204:	8526                	mv	a0,s1
    80004206:	ffffe097          	auipc	ra,0xffffe
    8000420a:	eee080e7          	jalr	-274(ra) # 800020f4 <sleep>
    8000420e:	bfe9                	j	800041e8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004210:	0001d517          	auipc	a0,0x1d
    80004214:	96050513          	add	a0,a0,-1696 # 80020b70 <log>
    80004218:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000421a:	ffffd097          	auipc	ra,0xffffd
    8000421e:	ad2080e7          	jalr	-1326(ra) # 80000cec <release>
      break;
    }
  }
}
    80004222:	60e2                	ld	ra,24(sp)
    80004224:	6442                	ld	s0,16(sp)
    80004226:	64a2                	ld	s1,8(sp)
    80004228:	6902                	ld	s2,0(sp)
    8000422a:	6105                	add	sp,sp,32
    8000422c:	8082                	ret

000000008000422e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000422e:	7139                	add	sp,sp,-64
    80004230:	fc06                	sd	ra,56(sp)
    80004232:	f822                	sd	s0,48(sp)
    80004234:	f426                	sd	s1,40(sp)
    80004236:	f04a                	sd	s2,32(sp)
    80004238:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000423a:	0001d497          	auipc	s1,0x1d
    8000423e:	93648493          	add	s1,s1,-1738 # 80020b70 <log>
    80004242:	8526                	mv	a0,s1
    80004244:	ffffd097          	auipc	ra,0xffffd
    80004248:	9f4080e7          	jalr	-1548(ra) # 80000c38 <acquire>
  log.outstanding -= 1;
    8000424c:	509c                	lw	a5,32(s1)
    8000424e:	37fd                	addw	a5,a5,-1
    80004250:	0007891b          	sext.w	s2,a5
    80004254:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004256:	50dc                	lw	a5,36(s1)
    80004258:	e7b9                	bnez	a5,800042a6 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    8000425a:	06091163          	bnez	s2,800042bc <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000425e:	0001d497          	auipc	s1,0x1d
    80004262:	91248493          	add	s1,s1,-1774 # 80020b70 <log>
    80004266:	4785                	li	a5,1
    80004268:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000426a:	8526                	mv	a0,s1
    8000426c:	ffffd097          	auipc	ra,0xffffd
    80004270:	a80080e7          	jalr	-1408(ra) # 80000cec <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004274:	54dc                	lw	a5,44(s1)
    80004276:	06f04763          	bgtz	a5,800042e4 <end_op+0xb6>
    acquire(&log.lock);
    8000427a:	0001d497          	auipc	s1,0x1d
    8000427e:	8f648493          	add	s1,s1,-1802 # 80020b70 <log>
    80004282:	8526                	mv	a0,s1
    80004284:	ffffd097          	auipc	ra,0xffffd
    80004288:	9b4080e7          	jalr	-1612(ra) # 80000c38 <acquire>
    log.committing = 0;
    8000428c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004290:	8526                	mv	a0,s1
    80004292:	ffffe097          	auipc	ra,0xffffe
    80004296:	ec6080e7          	jalr	-314(ra) # 80002158 <wakeup>
    release(&log.lock);
    8000429a:	8526                	mv	a0,s1
    8000429c:	ffffd097          	auipc	ra,0xffffd
    800042a0:	a50080e7          	jalr	-1456(ra) # 80000cec <release>
}
    800042a4:	a815                	j	800042d8 <end_op+0xaa>
    800042a6:	ec4e                	sd	s3,24(sp)
    800042a8:	e852                	sd	s4,16(sp)
    800042aa:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800042ac:	00004517          	auipc	a0,0x4
    800042b0:	2bc50513          	add	a0,a0,700 # 80008568 <etext+0x568>
    800042b4:	ffffc097          	auipc	ra,0xffffc
    800042b8:	2ac080e7          	jalr	684(ra) # 80000560 <panic>
    wakeup(&log);
    800042bc:	0001d497          	auipc	s1,0x1d
    800042c0:	8b448493          	add	s1,s1,-1868 # 80020b70 <log>
    800042c4:	8526                	mv	a0,s1
    800042c6:	ffffe097          	auipc	ra,0xffffe
    800042ca:	e92080e7          	jalr	-366(ra) # 80002158 <wakeup>
  release(&log.lock);
    800042ce:	8526                	mv	a0,s1
    800042d0:	ffffd097          	auipc	ra,0xffffd
    800042d4:	a1c080e7          	jalr	-1508(ra) # 80000cec <release>
}
    800042d8:	70e2                	ld	ra,56(sp)
    800042da:	7442                	ld	s0,48(sp)
    800042dc:	74a2                	ld	s1,40(sp)
    800042de:	7902                	ld	s2,32(sp)
    800042e0:	6121                	add	sp,sp,64
    800042e2:	8082                	ret
    800042e4:	ec4e                	sd	s3,24(sp)
    800042e6:	e852                	sd	s4,16(sp)
    800042e8:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800042ea:	0001da97          	auipc	s5,0x1d
    800042ee:	8b6a8a93          	add	s5,s5,-1866 # 80020ba0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800042f2:	0001da17          	auipc	s4,0x1d
    800042f6:	87ea0a13          	add	s4,s4,-1922 # 80020b70 <log>
    800042fa:	018a2583          	lw	a1,24(s4)
    800042fe:	012585bb          	addw	a1,a1,s2
    80004302:	2585                	addw	a1,a1,1
    80004304:	028a2503          	lw	a0,40(s4)
    80004308:	fffff097          	auipc	ra,0xfffff
    8000430c:	caa080e7          	jalr	-854(ra) # 80002fb2 <bread>
    80004310:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004312:	000aa583          	lw	a1,0(s5)
    80004316:	028a2503          	lw	a0,40(s4)
    8000431a:	fffff097          	auipc	ra,0xfffff
    8000431e:	c98080e7          	jalr	-872(ra) # 80002fb2 <bread>
    80004322:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004324:	40000613          	li	a2,1024
    80004328:	05850593          	add	a1,a0,88
    8000432c:	05848513          	add	a0,s1,88
    80004330:	ffffd097          	auipc	ra,0xffffd
    80004334:	a60080e7          	jalr	-1440(ra) # 80000d90 <memmove>
    bwrite(to);  // write the log
    80004338:	8526                	mv	a0,s1
    8000433a:	fffff097          	auipc	ra,0xfffff
    8000433e:	d6a080e7          	jalr	-662(ra) # 800030a4 <bwrite>
    brelse(from);
    80004342:	854e                	mv	a0,s3
    80004344:	fffff097          	auipc	ra,0xfffff
    80004348:	d9e080e7          	jalr	-610(ra) # 800030e2 <brelse>
    brelse(to);
    8000434c:	8526                	mv	a0,s1
    8000434e:	fffff097          	auipc	ra,0xfffff
    80004352:	d94080e7          	jalr	-620(ra) # 800030e2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004356:	2905                	addw	s2,s2,1
    80004358:	0a91                	add	s5,s5,4
    8000435a:	02ca2783          	lw	a5,44(s4)
    8000435e:	f8f94ee3          	blt	s2,a5,800042fa <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004362:	00000097          	auipc	ra,0x0
    80004366:	c8c080e7          	jalr	-884(ra) # 80003fee <write_head>
    install_trans(0); // Now install writes to home locations
    8000436a:	4501                	li	a0,0
    8000436c:	00000097          	auipc	ra,0x0
    80004370:	cec080e7          	jalr	-788(ra) # 80004058 <install_trans>
    log.lh.n = 0;
    80004374:	0001d797          	auipc	a5,0x1d
    80004378:	8207a423          	sw	zero,-2008(a5) # 80020b9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000437c:	00000097          	auipc	ra,0x0
    80004380:	c72080e7          	jalr	-910(ra) # 80003fee <write_head>
    80004384:	69e2                	ld	s3,24(sp)
    80004386:	6a42                	ld	s4,16(sp)
    80004388:	6aa2                	ld	s5,8(sp)
    8000438a:	bdc5                	j	8000427a <end_op+0x4c>

000000008000438c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000438c:	1101                	add	sp,sp,-32
    8000438e:	ec06                	sd	ra,24(sp)
    80004390:	e822                	sd	s0,16(sp)
    80004392:	e426                	sd	s1,8(sp)
    80004394:	e04a                	sd	s2,0(sp)
    80004396:	1000                	add	s0,sp,32
    80004398:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000439a:	0001c917          	auipc	s2,0x1c
    8000439e:	7d690913          	add	s2,s2,2006 # 80020b70 <log>
    800043a2:	854a                	mv	a0,s2
    800043a4:	ffffd097          	auipc	ra,0xffffd
    800043a8:	894080e7          	jalr	-1900(ra) # 80000c38 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800043ac:	02c92603          	lw	a2,44(s2)
    800043b0:	47f5                	li	a5,29
    800043b2:	06c7c563          	blt	a5,a2,8000441c <log_write+0x90>
    800043b6:	0001c797          	auipc	a5,0x1c
    800043ba:	7d67a783          	lw	a5,2006(a5) # 80020b8c <log+0x1c>
    800043be:	37fd                	addw	a5,a5,-1
    800043c0:	04f65e63          	bge	a2,a5,8000441c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043c4:	0001c797          	auipc	a5,0x1c
    800043c8:	7cc7a783          	lw	a5,1996(a5) # 80020b90 <log+0x20>
    800043cc:	06f05063          	blez	a5,8000442c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800043d0:	4781                	li	a5,0
    800043d2:	06c05563          	blez	a2,8000443c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043d6:	44cc                	lw	a1,12(s1)
    800043d8:	0001c717          	auipc	a4,0x1c
    800043dc:	7c870713          	add	a4,a4,1992 # 80020ba0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800043e0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043e2:	4314                	lw	a3,0(a4)
    800043e4:	04b68c63          	beq	a3,a1,8000443c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800043e8:	2785                	addw	a5,a5,1
    800043ea:	0711                	add	a4,a4,4
    800043ec:	fef61be3          	bne	a2,a5,800043e2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800043f0:	0621                	add	a2,a2,8
    800043f2:	060a                	sll	a2,a2,0x2
    800043f4:	0001c797          	auipc	a5,0x1c
    800043f8:	77c78793          	add	a5,a5,1916 # 80020b70 <log>
    800043fc:	97b2                	add	a5,a5,a2
    800043fe:	44d8                	lw	a4,12(s1)
    80004400:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004402:	8526                	mv	a0,s1
    80004404:	fffff097          	auipc	ra,0xfffff
    80004408:	d7a080e7          	jalr	-646(ra) # 8000317e <bpin>
    log.lh.n++;
    8000440c:	0001c717          	auipc	a4,0x1c
    80004410:	76470713          	add	a4,a4,1892 # 80020b70 <log>
    80004414:	575c                	lw	a5,44(a4)
    80004416:	2785                	addw	a5,a5,1
    80004418:	d75c                	sw	a5,44(a4)
    8000441a:	a82d                	j	80004454 <log_write+0xc8>
    panic("too big a transaction");
    8000441c:	00004517          	auipc	a0,0x4
    80004420:	15c50513          	add	a0,a0,348 # 80008578 <etext+0x578>
    80004424:	ffffc097          	auipc	ra,0xffffc
    80004428:	13c080e7          	jalr	316(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    8000442c:	00004517          	auipc	a0,0x4
    80004430:	16450513          	add	a0,a0,356 # 80008590 <etext+0x590>
    80004434:	ffffc097          	auipc	ra,0xffffc
    80004438:	12c080e7          	jalr	300(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    8000443c:	00878693          	add	a3,a5,8
    80004440:	068a                	sll	a3,a3,0x2
    80004442:	0001c717          	auipc	a4,0x1c
    80004446:	72e70713          	add	a4,a4,1838 # 80020b70 <log>
    8000444a:	9736                	add	a4,a4,a3
    8000444c:	44d4                	lw	a3,12(s1)
    8000444e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004450:	faf609e3          	beq	a2,a5,80004402 <log_write+0x76>
  }
  release(&log.lock);
    80004454:	0001c517          	auipc	a0,0x1c
    80004458:	71c50513          	add	a0,a0,1820 # 80020b70 <log>
    8000445c:	ffffd097          	auipc	ra,0xffffd
    80004460:	890080e7          	jalr	-1904(ra) # 80000cec <release>
}
    80004464:	60e2                	ld	ra,24(sp)
    80004466:	6442                	ld	s0,16(sp)
    80004468:	64a2                	ld	s1,8(sp)
    8000446a:	6902                	ld	s2,0(sp)
    8000446c:	6105                	add	sp,sp,32
    8000446e:	8082                	ret

0000000080004470 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004470:	1101                	add	sp,sp,-32
    80004472:	ec06                	sd	ra,24(sp)
    80004474:	e822                	sd	s0,16(sp)
    80004476:	e426                	sd	s1,8(sp)
    80004478:	e04a                	sd	s2,0(sp)
    8000447a:	1000                	add	s0,sp,32
    8000447c:	84aa                	mv	s1,a0
    8000447e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004480:	00004597          	auipc	a1,0x4
    80004484:	13058593          	add	a1,a1,304 # 800085b0 <etext+0x5b0>
    80004488:	0521                	add	a0,a0,8
    8000448a:	ffffc097          	auipc	ra,0xffffc
    8000448e:	71e080e7          	jalr	1822(ra) # 80000ba8 <initlock>
  lk->name = name;
    80004492:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004496:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000449a:	0204a423          	sw	zero,40(s1)
}
    8000449e:	60e2                	ld	ra,24(sp)
    800044a0:	6442                	ld	s0,16(sp)
    800044a2:	64a2                	ld	s1,8(sp)
    800044a4:	6902                	ld	s2,0(sp)
    800044a6:	6105                	add	sp,sp,32
    800044a8:	8082                	ret

00000000800044aa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044aa:	1101                	add	sp,sp,-32
    800044ac:	ec06                	sd	ra,24(sp)
    800044ae:	e822                	sd	s0,16(sp)
    800044b0:	e426                	sd	s1,8(sp)
    800044b2:	e04a                	sd	s2,0(sp)
    800044b4:	1000                	add	s0,sp,32
    800044b6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044b8:	00850913          	add	s2,a0,8
    800044bc:	854a                	mv	a0,s2
    800044be:	ffffc097          	auipc	ra,0xffffc
    800044c2:	77a080e7          	jalr	1914(ra) # 80000c38 <acquire>
  while (lk->locked) {
    800044c6:	409c                	lw	a5,0(s1)
    800044c8:	cb89                	beqz	a5,800044da <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800044ca:	85ca                	mv	a1,s2
    800044cc:	8526                	mv	a0,s1
    800044ce:	ffffe097          	auipc	ra,0xffffe
    800044d2:	c26080e7          	jalr	-986(ra) # 800020f4 <sleep>
  while (lk->locked) {
    800044d6:	409c                	lw	a5,0(s1)
    800044d8:	fbed                	bnez	a5,800044ca <acquiresleep+0x20>
  }
  lk->locked = 1;
    800044da:	4785                	li	a5,1
    800044dc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800044de:	ffffd097          	auipc	ra,0xffffd
    800044e2:	56c080e7          	jalr	1388(ra) # 80001a4a <myproc>
    800044e6:	591c                	lw	a5,48(a0)
    800044e8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800044ea:	854a                	mv	a0,s2
    800044ec:	ffffd097          	auipc	ra,0xffffd
    800044f0:	800080e7          	jalr	-2048(ra) # 80000cec <release>
}
    800044f4:	60e2                	ld	ra,24(sp)
    800044f6:	6442                	ld	s0,16(sp)
    800044f8:	64a2                	ld	s1,8(sp)
    800044fa:	6902                	ld	s2,0(sp)
    800044fc:	6105                	add	sp,sp,32
    800044fe:	8082                	ret

0000000080004500 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004500:	1101                	add	sp,sp,-32
    80004502:	ec06                	sd	ra,24(sp)
    80004504:	e822                	sd	s0,16(sp)
    80004506:	e426                	sd	s1,8(sp)
    80004508:	e04a                	sd	s2,0(sp)
    8000450a:	1000                	add	s0,sp,32
    8000450c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000450e:	00850913          	add	s2,a0,8
    80004512:	854a                	mv	a0,s2
    80004514:	ffffc097          	auipc	ra,0xffffc
    80004518:	724080e7          	jalr	1828(ra) # 80000c38 <acquire>
  lk->locked = 0;
    8000451c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004520:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004524:	8526                	mv	a0,s1
    80004526:	ffffe097          	auipc	ra,0xffffe
    8000452a:	c32080e7          	jalr	-974(ra) # 80002158 <wakeup>
  release(&lk->lk);
    8000452e:	854a                	mv	a0,s2
    80004530:	ffffc097          	auipc	ra,0xffffc
    80004534:	7bc080e7          	jalr	1980(ra) # 80000cec <release>
}
    80004538:	60e2                	ld	ra,24(sp)
    8000453a:	6442                	ld	s0,16(sp)
    8000453c:	64a2                	ld	s1,8(sp)
    8000453e:	6902                	ld	s2,0(sp)
    80004540:	6105                	add	sp,sp,32
    80004542:	8082                	ret

0000000080004544 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004544:	7179                	add	sp,sp,-48
    80004546:	f406                	sd	ra,40(sp)
    80004548:	f022                	sd	s0,32(sp)
    8000454a:	ec26                	sd	s1,24(sp)
    8000454c:	e84a                	sd	s2,16(sp)
    8000454e:	1800                	add	s0,sp,48
    80004550:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004552:	00850913          	add	s2,a0,8
    80004556:	854a                	mv	a0,s2
    80004558:	ffffc097          	auipc	ra,0xffffc
    8000455c:	6e0080e7          	jalr	1760(ra) # 80000c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004560:	409c                	lw	a5,0(s1)
    80004562:	ef91                	bnez	a5,8000457e <holdingsleep+0x3a>
    80004564:	4481                	li	s1,0
  release(&lk->lk);
    80004566:	854a                	mv	a0,s2
    80004568:	ffffc097          	auipc	ra,0xffffc
    8000456c:	784080e7          	jalr	1924(ra) # 80000cec <release>
  return r;
}
    80004570:	8526                	mv	a0,s1
    80004572:	70a2                	ld	ra,40(sp)
    80004574:	7402                	ld	s0,32(sp)
    80004576:	64e2                	ld	s1,24(sp)
    80004578:	6942                	ld	s2,16(sp)
    8000457a:	6145                	add	sp,sp,48
    8000457c:	8082                	ret
    8000457e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004580:	0284a983          	lw	s3,40(s1)
    80004584:	ffffd097          	auipc	ra,0xffffd
    80004588:	4c6080e7          	jalr	1222(ra) # 80001a4a <myproc>
    8000458c:	5904                	lw	s1,48(a0)
    8000458e:	413484b3          	sub	s1,s1,s3
    80004592:	0014b493          	seqz	s1,s1
    80004596:	69a2                	ld	s3,8(sp)
    80004598:	b7f9                	j	80004566 <holdingsleep+0x22>

000000008000459a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000459a:	1141                	add	sp,sp,-16
    8000459c:	e406                	sd	ra,8(sp)
    8000459e:	e022                	sd	s0,0(sp)
    800045a0:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045a2:	00004597          	auipc	a1,0x4
    800045a6:	01e58593          	add	a1,a1,30 # 800085c0 <etext+0x5c0>
    800045aa:	0001c517          	auipc	a0,0x1c
    800045ae:	70e50513          	add	a0,a0,1806 # 80020cb8 <ftable>
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	5f6080e7          	jalr	1526(ra) # 80000ba8 <initlock>
}
    800045ba:	60a2                	ld	ra,8(sp)
    800045bc:	6402                	ld	s0,0(sp)
    800045be:	0141                	add	sp,sp,16
    800045c0:	8082                	ret

00000000800045c2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045c2:	1101                	add	sp,sp,-32
    800045c4:	ec06                	sd	ra,24(sp)
    800045c6:	e822                	sd	s0,16(sp)
    800045c8:	e426                	sd	s1,8(sp)
    800045ca:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045cc:	0001c517          	auipc	a0,0x1c
    800045d0:	6ec50513          	add	a0,a0,1772 # 80020cb8 <ftable>
    800045d4:	ffffc097          	auipc	ra,0xffffc
    800045d8:	664080e7          	jalr	1636(ra) # 80000c38 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045dc:	0001c497          	auipc	s1,0x1c
    800045e0:	6f448493          	add	s1,s1,1780 # 80020cd0 <ftable+0x18>
    800045e4:	0001d717          	auipc	a4,0x1d
    800045e8:	68c70713          	add	a4,a4,1676 # 80021c70 <disk>
    if(f->ref == 0){
    800045ec:	40dc                	lw	a5,4(s1)
    800045ee:	cf99                	beqz	a5,8000460c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045f0:	02848493          	add	s1,s1,40
    800045f4:	fee49ce3          	bne	s1,a4,800045ec <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045f8:	0001c517          	auipc	a0,0x1c
    800045fc:	6c050513          	add	a0,a0,1728 # 80020cb8 <ftable>
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	6ec080e7          	jalr	1772(ra) # 80000cec <release>
  return 0;
    80004608:	4481                	li	s1,0
    8000460a:	a819                	j	80004620 <filealloc+0x5e>
      f->ref = 1;
    8000460c:	4785                	li	a5,1
    8000460e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004610:	0001c517          	auipc	a0,0x1c
    80004614:	6a850513          	add	a0,a0,1704 # 80020cb8 <ftable>
    80004618:	ffffc097          	auipc	ra,0xffffc
    8000461c:	6d4080e7          	jalr	1748(ra) # 80000cec <release>
}
    80004620:	8526                	mv	a0,s1
    80004622:	60e2                	ld	ra,24(sp)
    80004624:	6442                	ld	s0,16(sp)
    80004626:	64a2                	ld	s1,8(sp)
    80004628:	6105                	add	sp,sp,32
    8000462a:	8082                	ret

000000008000462c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000462c:	1101                	add	sp,sp,-32
    8000462e:	ec06                	sd	ra,24(sp)
    80004630:	e822                	sd	s0,16(sp)
    80004632:	e426                	sd	s1,8(sp)
    80004634:	1000                	add	s0,sp,32
    80004636:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004638:	0001c517          	auipc	a0,0x1c
    8000463c:	68050513          	add	a0,a0,1664 # 80020cb8 <ftable>
    80004640:	ffffc097          	auipc	ra,0xffffc
    80004644:	5f8080e7          	jalr	1528(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    80004648:	40dc                	lw	a5,4(s1)
    8000464a:	02f05263          	blez	a5,8000466e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000464e:	2785                	addw	a5,a5,1
    80004650:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004652:	0001c517          	auipc	a0,0x1c
    80004656:	66650513          	add	a0,a0,1638 # 80020cb8 <ftable>
    8000465a:	ffffc097          	auipc	ra,0xffffc
    8000465e:	692080e7          	jalr	1682(ra) # 80000cec <release>
  return f;
}
    80004662:	8526                	mv	a0,s1
    80004664:	60e2                	ld	ra,24(sp)
    80004666:	6442                	ld	s0,16(sp)
    80004668:	64a2                	ld	s1,8(sp)
    8000466a:	6105                	add	sp,sp,32
    8000466c:	8082                	ret
    panic("filedup");
    8000466e:	00004517          	auipc	a0,0x4
    80004672:	f5a50513          	add	a0,a0,-166 # 800085c8 <etext+0x5c8>
    80004676:	ffffc097          	auipc	ra,0xffffc
    8000467a:	eea080e7          	jalr	-278(ra) # 80000560 <panic>

000000008000467e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000467e:	7139                	add	sp,sp,-64
    80004680:	fc06                	sd	ra,56(sp)
    80004682:	f822                	sd	s0,48(sp)
    80004684:	f426                	sd	s1,40(sp)
    80004686:	0080                	add	s0,sp,64
    80004688:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000468a:	0001c517          	auipc	a0,0x1c
    8000468e:	62e50513          	add	a0,a0,1582 # 80020cb8 <ftable>
    80004692:	ffffc097          	auipc	ra,0xffffc
    80004696:	5a6080e7          	jalr	1446(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    8000469a:	40dc                	lw	a5,4(s1)
    8000469c:	04f05c63          	blez	a5,800046f4 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    800046a0:	37fd                	addw	a5,a5,-1
    800046a2:	0007871b          	sext.w	a4,a5
    800046a6:	c0dc                	sw	a5,4(s1)
    800046a8:	06e04263          	bgtz	a4,8000470c <fileclose+0x8e>
    800046ac:	f04a                	sd	s2,32(sp)
    800046ae:	ec4e                	sd	s3,24(sp)
    800046b0:	e852                	sd	s4,16(sp)
    800046b2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046b4:	0004a903          	lw	s2,0(s1)
    800046b8:	0094ca83          	lbu	s5,9(s1)
    800046bc:	0104ba03          	ld	s4,16(s1)
    800046c0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800046c4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046c8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800046cc:	0001c517          	auipc	a0,0x1c
    800046d0:	5ec50513          	add	a0,a0,1516 # 80020cb8 <ftable>
    800046d4:	ffffc097          	auipc	ra,0xffffc
    800046d8:	618080e7          	jalr	1560(ra) # 80000cec <release>

  if(ff.type == FD_PIPE){
    800046dc:	4785                	li	a5,1
    800046de:	04f90463          	beq	s2,a5,80004726 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800046e2:	3979                	addw	s2,s2,-2
    800046e4:	4785                	li	a5,1
    800046e6:	0527fb63          	bgeu	a5,s2,8000473c <fileclose+0xbe>
    800046ea:	7902                	ld	s2,32(sp)
    800046ec:	69e2                	ld	s3,24(sp)
    800046ee:	6a42                	ld	s4,16(sp)
    800046f0:	6aa2                	ld	s5,8(sp)
    800046f2:	a02d                	j	8000471c <fileclose+0x9e>
    800046f4:	f04a                	sd	s2,32(sp)
    800046f6:	ec4e                	sd	s3,24(sp)
    800046f8:	e852                	sd	s4,16(sp)
    800046fa:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800046fc:	00004517          	auipc	a0,0x4
    80004700:	ed450513          	add	a0,a0,-300 # 800085d0 <etext+0x5d0>
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	e5c080e7          	jalr	-420(ra) # 80000560 <panic>
    release(&ftable.lock);
    8000470c:	0001c517          	auipc	a0,0x1c
    80004710:	5ac50513          	add	a0,a0,1452 # 80020cb8 <ftable>
    80004714:	ffffc097          	auipc	ra,0xffffc
    80004718:	5d8080e7          	jalr	1496(ra) # 80000cec <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000471c:	70e2                	ld	ra,56(sp)
    8000471e:	7442                	ld	s0,48(sp)
    80004720:	74a2                	ld	s1,40(sp)
    80004722:	6121                	add	sp,sp,64
    80004724:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004726:	85d6                	mv	a1,s5
    80004728:	8552                	mv	a0,s4
    8000472a:	00000097          	auipc	ra,0x0
    8000472e:	3a2080e7          	jalr	930(ra) # 80004acc <pipeclose>
    80004732:	7902                	ld	s2,32(sp)
    80004734:	69e2                	ld	s3,24(sp)
    80004736:	6a42                	ld	s4,16(sp)
    80004738:	6aa2                	ld	s5,8(sp)
    8000473a:	b7cd                	j	8000471c <fileclose+0x9e>
    begin_op();
    8000473c:	00000097          	auipc	ra,0x0
    80004740:	a78080e7          	jalr	-1416(ra) # 800041b4 <begin_op>
    iput(ff.ip);
    80004744:	854e                	mv	a0,s3
    80004746:	fffff097          	auipc	ra,0xfffff
    8000474a:	25e080e7          	jalr	606(ra) # 800039a4 <iput>
    end_op();
    8000474e:	00000097          	auipc	ra,0x0
    80004752:	ae0080e7          	jalr	-1312(ra) # 8000422e <end_op>
    80004756:	7902                	ld	s2,32(sp)
    80004758:	69e2                	ld	s3,24(sp)
    8000475a:	6a42                	ld	s4,16(sp)
    8000475c:	6aa2                	ld	s5,8(sp)
    8000475e:	bf7d                	j	8000471c <fileclose+0x9e>

0000000080004760 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004760:	715d                	add	sp,sp,-80
    80004762:	e486                	sd	ra,72(sp)
    80004764:	e0a2                	sd	s0,64(sp)
    80004766:	fc26                	sd	s1,56(sp)
    80004768:	f44e                	sd	s3,40(sp)
    8000476a:	0880                	add	s0,sp,80
    8000476c:	84aa                	mv	s1,a0
    8000476e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004770:	ffffd097          	auipc	ra,0xffffd
    80004774:	2da080e7          	jalr	730(ra) # 80001a4a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004778:	409c                	lw	a5,0(s1)
    8000477a:	37f9                	addw	a5,a5,-2
    8000477c:	4705                	li	a4,1
    8000477e:	04f76863          	bltu	a4,a5,800047ce <filestat+0x6e>
    80004782:	f84a                	sd	s2,48(sp)
    80004784:	892a                	mv	s2,a0
    ilock(f->ip);
    80004786:	6c88                	ld	a0,24(s1)
    80004788:	fffff097          	auipc	ra,0xfffff
    8000478c:	05e080e7          	jalr	94(ra) # 800037e6 <ilock>
    stati(f->ip, &st);
    80004790:	fb840593          	add	a1,s0,-72
    80004794:	6c88                	ld	a0,24(s1)
    80004796:	fffff097          	auipc	ra,0xfffff
    8000479a:	2de080e7          	jalr	734(ra) # 80003a74 <stati>
    iunlock(f->ip);
    8000479e:	6c88                	ld	a0,24(s1)
    800047a0:	fffff097          	auipc	ra,0xfffff
    800047a4:	10c080e7          	jalr	268(ra) # 800038ac <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800047a8:	46e1                	li	a3,24
    800047aa:	fb840613          	add	a2,s0,-72
    800047ae:	85ce                	mv	a1,s3
    800047b0:	05093503          	ld	a0,80(s2)
    800047b4:	ffffd097          	auipc	ra,0xffffd
    800047b8:	f2e080e7          	jalr	-210(ra) # 800016e2 <copyout>
    800047bc:	41f5551b          	sraw	a0,a0,0x1f
    800047c0:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800047c2:	60a6                	ld	ra,72(sp)
    800047c4:	6406                	ld	s0,64(sp)
    800047c6:	74e2                	ld	s1,56(sp)
    800047c8:	79a2                	ld	s3,40(sp)
    800047ca:	6161                	add	sp,sp,80
    800047cc:	8082                	ret
  return -1;
    800047ce:	557d                	li	a0,-1
    800047d0:	bfcd                	j	800047c2 <filestat+0x62>

00000000800047d2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047d2:	7179                	add	sp,sp,-48
    800047d4:	f406                	sd	ra,40(sp)
    800047d6:	f022                	sd	s0,32(sp)
    800047d8:	e84a                	sd	s2,16(sp)
    800047da:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800047dc:	00854783          	lbu	a5,8(a0)
    800047e0:	cbc5                	beqz	a5,80004890 <fileread+0xbe>
    800047e2:	ec26                	sd	s1,24(sp)
    800047e4:	e44e                	sd	s3,8(sp)
    800047e6:	84aa                	mv	s1,a0
    800047e8:	89ae                	mv	s3,a1
    800047ea:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800047ec:	411c                	lw	a5,0(a0)
    800047ee:	4705                	li	a4,1
    800047f0:	04e78963          	beq	a5,a4,80004842 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047f4:	470d                	li	a4,3
    800047f6:	04e78f63          	beq	a5,a4,80004854 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800047fa:	4709                	li	a4,2
    800047fc:	08e79263          	bne	a5,a4,80004880 <fileread+0xae>
    ilock(f->ip);
    80004800:	6d08                	ld	a0,24(a0)
    80004802:	fffff097          	auipc	ra,0xfffff
    80004806:	fe4080e7          	jalr	-28(ra) # 800037e6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000480a:	874a                	mv	a4,s2
    8000480c:	5094                	lw	a3,32(s1)
    8000480e:	864e                	mv	a2,s3
    80004810:	4585                	li	a1,1
    80004812:	6c88                	ld	a0,24(s1)
    80004814:	fffff097          	auipc	ra,0xfffff
    80004818:	28a080e7          	jalr	650(ra) # 80003a9e <readi>
    8000481c:	892a                	mv	s2,a0
    8000481e:	00a05563          	blez	a0,80004828 <fileread+0x56>
      f->off += r;
    80004822:	509c                	lw	a5,32(s1)
    80004824:	9fa9                	addw	a5,a5,a0
    80004826:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004828:	6c88                	ld	a0,24(s1)
    8000482a:	fffff097          	auipc	ra,0xfffff
    8000482e:	082080e7          	jalr	130(ra) # 800038ac <iunlock>
    80004832:	64e2                	ld	s1,24(sp)
    80004834:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004836:	854a                	mv	a0,s2
    80004838:	70a2                	ld	ra,40(sp)
    8000483a:	7402                	ld	s0,32(sp)
    8000483c:	6942                	ld	s2,16(sp)
    8000483e:	6145                	add	sp,sp,48
    80004840:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004842:	6908                	ld	a0,16(a0)
    80004844:	00000097          	auipc	ra,0x0
    80004848:	400080e7          	jalr	1024(ra) # 80004c44 <piperead>
    8000484c:	892a                	mv	s2,a0
    8000484e:	64e2                	ld	s1,24(sp)
    80004850:	69a2                	ld	s3,8(sp)
    80004852:	b7d5                	j	80004836 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004854:	02451783          	lh	a5,36(a0)
    80004858:	03079693          	sll	a3,a5,0x30
    8000485c:	92c1                	srl	a3,a3,0x30
    8000485e:	4725                	li	a4,9
    80004860:	02d76a63          	bltu	a4,a3,80004894 <fileread+0xc2>
    80004864:	0792                	sll	a5,a5,0x4
    80004866:	0001c717          	auipc	a4,0x1c
    8000486a:	3b270713          	add	a4,a4,946 # 80020c18 <devsw>
    8000486e:	97ba                	add	a5,a5,a4
    80004870:	639c                	ld	a5,0(a5)
    80004872:	c78d                	beqz	a5,8000489c <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004874:	4505                	li	a0,1
    80004876:	9782                	jalr	a5
    80004878:	892a                	mv	s2,a0
    8000487a:	64e2                	ld	s1,24(sp)
    8000487c:	69a2                	ld	s3,8(sp)
    8000487e:	bf65                	j	80004836 <fileread+0x64>
    panic("fileread");
    80004880:	00004517          	auipc	a0,0x4
    80004884:	d6050513          	add	a0,a0,-672 # 800085e0 <etext+0x5e0>
    80004888:	ffffc097          	auipc	ra,0xffffc
    8000488c:	cd8080e7          	jalr	-808(ra) # 80000560 <panic>
    return -1;
    80004890:	597d                	li	s2,-1
    80004892:	b755                	j	80004836 <fileread+0x64>
      return -1;
    80004894:	597d                	li	s2,-1
    80004896:	64e2                	ld	s1,24(sp)
    80004898:	69a2                	ld	s3,8(sp)
    8000489a:	bf71                	j	80004836 <fileread+0x64>
    8000489c:	597d                	li	s2,-1
    8000489e:	64e2                	ld	s1,24(sp)
    800048a0:	69a2                	ld	s3,8(sp)
    800048a2:	bf51                	j	80004836 <fileread+0x64>

00000000800048a4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800048a4:	00954783          	lbu	a5,9(a0)
    800048a8:	12078963          	beqz	a5,800049da <filewrite+0x136>
{
    800048ac:	715d                	add	sp,sp,-80
    800048ae:	e486                	sd	ra,72(sp)
    800048b0:	e0a2                	sd	s0,64(sp)
    800048b2:	f84a                	sd	s2,48(sp)
    800048b4:	f052                	sd	s4,32(sp)
    800048b6:	e85a                	sd	s6,16(sp)
    800048b8:	0880                	add	s0,sp,80
    800048ba:	892a                	mv	s2,a0
    800048bc:	8b2e                	mv	s6,a1
    800048be:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800048c0:	411c                	lw	a5,0(a0)
    800048c2:	4705                	li	a4,1
    800048c4:	02e78763          	beq	a5,a4,800048f2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048c8:	470d                	li	a4,3
    800048ca:	02e78a63          	beq	a5,a4,800048fe <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800048ce:	4709                	li	a4,2
    800048d0:	0ee79863          	bne	a5,a4,800049c0 <filewrite+0x11c>
    800048d4:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048d6:	0cc05463          	blez	a2,8000499e <filewrite+0xfa>
    800048da:	fc26                	sd	s1,56(sp)
    800048dc:	ec56                	sd	s5,24(sp)
    800048de:	e45e                	sd	s7,8(sp)
    800048e0:	e062                	sd	s8,0(sp)
    int i = 0;
    800048e2:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800048e4:	6b85                	lui	s7,0x1
    800048e6:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800048ea:	6c05                	lui	s8,0x1
    800048ec:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800048f0:	a851                	j	80004984 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800048f2:	6908                	ld	a0,16(a0)
    800048f4:	00000097          	auipc	ra,0x0
    800048f8:	248080e7          	jalr	584(ra) # 80004b3c <pipewrite>
    800048fc:	a85d                	j	800049b2 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800048fe:	02451783          	lh	a5,36(a0)
    80004902:	03079693          	sll	a3,a5,0x30
    80004906:	92c1                	srl	a3,a3,0x30
    80004908:	4725                	li	a4,9
    8000490a:	0cd76a63          	bltu	a4,a3,800049de <filewrite+0x13a>
    8000490e:	0792                	sll	a5,a5,0x4
    80004910:	0001c717          	auipc	a4,0x1c
    80004914:	30870713          	add	a4,a4,776 # 80020c18 <devsw>
    80004918:	97ba                	add	a5,a5,a4
    8000491a:	679c                	ld	a5,8(a5)
    8000491c:	c3f9                	beqz	a5,800049e2 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    8000491e:	4505                	li	a0,1
    80004920:	9782                	jalr	a5
    80004922:	a841                	j	800049b2 <filewrite+0x10e>
      if(n1 > max)
    80004924:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004928:	00000097          	auipc	ra,0x0
    8000492c:	88c080e7          	jalr	-1908(ra) # 800041b4 <begin_op>
      ilock(f->ip);
    80004930:	01893503          	ld	a0,24(s2)
    80004934:	fffff097          	auipc	ra,0xfffff
    80004938:	eb2080e7          	jalr	-334(ra) # 800037e6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000493c:	8756                	mv	a4,s5
    8000493e:	02092683          	lw	a3,32(s2)
    80004942:	01698633          	add	a2,s3,s6
    80004946:	4585                	li	a1,1
    80004948:	01893503          	ld	a0,24(s2)
    8000494c:	fffff097          	auipc	ra,0xfffff
    80004950:	262080e7          	jalr	610(ra) # 80003bae <writei>
    80004954:	84aa                	mv	s1,a0
    80004956:	00a05763          	blez	a0,80004964 <filewrite+0xc0>
        f->off += r;
    8000495a:	02092783          	lw	a5,32(s2)
    8000495e:	9fa9                	addw	a5,a5,a0
    80004960:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004964:	01893503          	ld	a0,24(s2)
    80004968:	fffff097          	auipc	ra,0xfffff
    8000496c:	f44080e7          	jalr	-188(ra) # 800038ac <iunlock>
      end_op();
    80004970:	00000097          	auipc	ra,0x0
    80004974:	8be080e7          	jalr	-1858(ra) # 8000422e <end_op>

      if(r != n1){
    80004978:	029a9563          	bne	s5,s1,800049a2 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    8000497c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004980:	0149da63          	bge	s3,s4,80004994 <filewrite+0xf0>
      int n1 = n - i;
    80004984:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004988:	0004879b          	sext.w	a5,s1
    8000498c:	f8fbdce3          	bge	s7,a5,80004924 <filewrite+0x80>
    80004990:	84e2                	mv	s1,s8
    80004992:	bf49                	j	80004924 <filewrite+0x80>
    80004994:	74e2                	ld	s1,56(sp)
    80004996:	6ae2                	ld	s5,24(sp)
    80004998:	6ba2                	ld	s7,8(sp)
    8000499a:	6c02                	ld	s8,0(sp)
    8000499c:	a039                	j	800049aa <filewrite+0x106>
    int i = 0;
    8000499e:	4981                	li	s3,0
    800049a0:	a029                	j	800049aa <filewrite+0x106>
    800049a2:	74e2                	ld	s1,56(sp)
    800049a4:	6ae2                	ld	s5,24(sp)
    800049a6:	6ba2                	ld	s7,8(sp)
    800049a8:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800049aa:	033a1e63          	bne	s4,s3,800049e6 <filewrite+0x142>
    800049ae:	8552                	mv	a0,s4
    800049b0:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800049b2:	60a6                	ld	ra,72(sp)
    800049b4:	6406                	ld	s0,64(sp)
    800049b6:	7942                	ld	s2,48(sp)
    800049b8:	7a02                	ld	s4,32(sp)
    800049ba:	6b42                	ld	s6,16(sp)
    800049bc:	6161                	add	sp,sp,80
    800049be:	8082                	ret
    800049c0:	fc26                	sd	s1,56(sp)
    800049c2:	f44e                	sd	s3,40(sp)
    800049c4:	ec56                	sd	s5,24(sp)
    800049c6:	e45e                	sd	s7,8(sp)
    800049c8:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800049ca:	00004517          	auipc	a0,0x4
    800049ce:	c2650513          	add	a0,a0,-986 # 800085f0 <etext+0x5f0>
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	b8e080e7          	jalr	-1138(ra) # 80000560 <panic>
    return -1;
    800049da:	557d                	li	a0,-1
}
    800049dc:	8082                	ret
      return -1;
    800049de:	557d                	li	a0,-1
    800049e0:	bfc9                	j	800049b2 <filewrite+0x10e>
    800049e2:	557d                	li	a0,-1
    800049e4:	b7f9                	j	800049b2 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    800049e6:	557d                	li	a0,-1
    800049e8:	79a2                	ld	s3,40(sp)
    800049ea:	b7e1                	j	800049b2 <filewrite+0x10e>

00000000800049ec <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049ec:	7179                	add	sp,sp,-48
    800049ee:	f406                	sd	ra,40(sp)
    800049f0:	f022                	sd	s0,32(sp)
    800049f2:	ec26                	sd	s1,24(sp)
    800049f4:	e052                	sd	s4,0(sp)
    800049f6:	1800                	add	s0,sp,48
    800049f8:	84aa                	mv	s1,a0
    800049fa:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800049fc:	0005b023          	sd	zero,0(a1)
    80004a00:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a04:	00000097          	auipc	ra,0x0
    80004a08:	bbe080e7          	jalr	-1090(ra) # 800045c2 <filealloc>
    80004a0c:	e088                	sd	a0,0(s1)
    80004a0e:	cd49                	beqz	a0,80004aa8 <pipealloc+0xbc>
    80004a10:	00000097          	auipc	ra,0x0
    80004a14:	bb2080e7          	jalr	-1102(ra) # 800045c2 <filealloc>
    80004a18:	00aa3023          	sd	a0,0(s4)
    80004a1c:	c141                	beqz	a0,80004a9c <pipealloc+0xb0>
    80004a1e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	128080e7          	jalr	296(ra) # 80000b48 <kalloc>
    80004a28:	892a                	mv	s2,a0
    80004a2a:	c13d                	beqz	a0,80004a90 <pipealloc+0xa4>
    80004a2c:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004a2e:	4985                	li	s3,1
    80004a30:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a34:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a38:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a3c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a40:	00004597          	auipc	a1,0x4
    80004a44:	bc058593          	add	a1,a1,-1088 # 80008600 <etext+0x600>
    80004a48:	ffffc097          	auipc	ra,0xffffc
    80004a4c:	160080e7          	jalr	352(ra) # 80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004a50:	609c                	ld	a5,0(s1)
    80004a52:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a56:	609c                	ld	a5,0(s1)
    80004a58:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a5c:	609c                	ld	a5,0(s1)
    80004a5e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a62:	609c                	ld	a5,0(s1)
    80004a64:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a68:	000a3783          	ld	a5,0(s4)
    80004a6c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a70:	000a3783          	ld	a5,0(s4)
    80004a74:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a78:	000a3783          	ld	a5,0(s4)
    80004a7c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a80:	000a3783          	ld	a5,0(s4)
    80004a84:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a88:	4501                	li	a0,0
    80004a8a:	6942                	ld	s2,16(sp)
    80004a8c:	69a2                	ld	s3,8(sp)
    80004a8e:	a03d                	j	80004abc <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a90:	6088                	ld	a0,0(s1)
    80004a92:	c119                	beqz	a0,80004a98 <pipealloc+0xac>
    80004a94:	6942                	ld	s2,16(sp)
    80004a96:	a029                	j	80004aa0 <pipealloc+0xb4>
    80004a98:	6942                	ld	s2,16(sp)
    80004a9a:	a039                	j	80004aa8 <pipealloc+0xbc>
    80004a9c:	6088                	ld	a0,0(s1)
    80004a9e:	c50d                	beqz	a0,80004ac8 <pipealloc+0xdc>
    fileclose(*f0);
    80004aa0:	00000097          	auipc	ra,0x0
    80004aa4:	bde080e7          	jalr	-1058(ra) # 8000467e <fileclose>
  if(*f1)
    80004aa8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004aac:	557d                	li	a0,-1
  if(*f1)
    80004aae:	c799                	beqz	a5,80004abc <pipealloc+0xd0>
    fileclose(*f1);
    80004ab0:	853e                	mv	a0,a5
    80004ab2:	00000097          	auipc	ra,0x0
    80004ab6:	bcc080e7          	jalr	-1076(ra) # 8000467e <fileclose>
  return -1;
    80004aba:	557d                	li	a0,-1
}
    80004abc:	70a2                	ld	ra,40(sp)
    80004abe:	7402                	ld	s0,32(sp)
    80004ac0:	64e2                	ld	s1,24(sp)
    80004ac2:	6a02                	ld	s4,0(sp)
    80004ac4:	6145                	add	sp,sp,48
    80004ac6:	8082                	ret
  return -1;
    80004ac8:	557d                	li	a0,-1
    80004aca:	bfcd                	j	80004abc <pipealloc+0xd0>

0000000080004acc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004acc:	1101                	add	sp,sp,-32
    80004ace:	ec06                	sd	ra,24(sp)
    80004ad0:	e822                	sd	s0,16(sp)
    80004ad2:	e426                	sd	s1,8(sp)
    80004ad4:	e04a                	sd	s2,0(sp)
    80004ad6:	1000                	add	s0,sp,32
    80004ad8:	84aa                	mv	s1,a0
    80004ada:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004adc:	ffffc097          	auipc	ra,0xffffc
    80004ae0:	15c080e7          	jalr	348(ra) # 80000c38 <acquire>
  if(writable){
    80004ae4:	02090d63          	beqz	s2,80004b1e <pipeclose+0x52>
    pi->writeopen = 0;
    80004ae8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004aec:	21848513          	add	a0,s1,536
    80004af0:	ffffd097          	auipc	ra,0xffffd
    80004af4:	668080e7          	jalr	1640(ra) # 80002158 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004af8:	2204b783          	ld	a5,544(s1)
    80004afc:	eb95                	bnez	a5,80004b30 <pipeclose+0x64>
    release(&pi->lock);
    80004afe:	8526                	mv	a0,s1
    80004b00:	ffffc097          	auipc	ra,0xffffc
    80004b04:	1ec080e7          	jalr	492(ra) # 80000cec <release>
    kfree((char*)pi);
    80004b08:	8526                	mv	a0,s1
    80004b0a:	ffffc097          	auipc	ra,0xffffc
    80004b0e:	f40080e7          	jalr	-192(ra) # 80000a4a <kfree>
  } else
    release(&pi->lock);
}
    80004b12:	60e2                	ld	ra,24(sp)
    80004b14:	6442                	ld	s0,16(sp)
    80004b16:	64a2                	ld	s1,8(sp)
    80004b18:	6902                	ld	s2,0(sp)
    80004b1a:	6105                	add	sp,sp,32
    80004b1c:	8082                	ret
    pi->readopen = 0;
    80004b1e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b22:	21c48513          	add	a0,s1,540
    80004b26:	ffffd097          	auipc	ra,0xffffd
    80004b2a:	632080e7          	jalr	1586(ra) # 80002158 <wakeup>
    80004b2e:	b7e9                	j	80004af8 <pipeclose+0x2c>
    release(&pi->lock);
    80004b30:	8526                	mv	a0,s1
    80004b32:	ffffc097          	auipc	ra,0xffffc
    80004b36:	1ba080e7          	jalr	442(ra) # 80000cec <release>
}
    80004b3a:	bfe1                	j	80004b12 <pipeclose+0x46>

0000000080004b3c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b3c:	711d                	add	sp,sp,-96
    80004b3e:	ec86                	sd	ra,88(sp)
    80004b40:	e8a2                	sd	s0,80(sp)
    80004b42:	e4a6                	sd	s1,72(sp)
    80004b44:	e0ca                	sd	s2,64(sp)
    80004b46:	fc4e                	sd	s3,56(sp)
    80004b48:	f852                	sd	s4,48(sp)
    80004b4a:	f456                	sd	s5,40(sp)
    80004b4c:	1080                	add	s0,sp,96
    80004b4e:	84aa                	mv	s1,a0
    80004b50:	8aae                	mv	s5,a1
    80004b52:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004b54:	ffffd097          	auipc	ra,0xffffd
    80004b58:	ef6080e7          	jalr	-266(ra) # 80001a4a <myproc>
    80004b5c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004b5e:	8526                	mv	a0,s1
    80004b60:	ffffc097          	auipc	ra,0xffffc
    80004b64:	0d8080e7          	jalr	216(ra) # 80000c38 <acquire>
  while(i < n){
    80004b68:	0d405863          	blez	s4,80004c38 <pipewrite+0xfc>
    80004b6c:	f05a                	sd	s6,32(sp)
    80004b6e:	ec5e                	sd	s7,24(sp)
    80004b70:	e862                	sd	s8,16(sp)
  int i = 0;
    80004b72:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b74:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004b76:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b7a:	21c48b93          	add	s7,s1,540
    80004b7e:	a089                	j	80004bc0 <pipewrite+0x84>
      release(&pi->lock);
    80004b80:	8526                	mv	a0,s1
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	16a080e7          	jalr	362(ra) # 80000cec <release>
      return -1;
    80004b8a:	597d                	li	s2,-1
    80004b8c:	7b02                	ld	s6,32(sp)
    80004b8e:	6be2                	ld	s7,24(sp)
    80004b90:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004b92:	854a                	mv	a0,s2
    80004b94:	60e6                	ld	ra,88(sp)
    80004b96:	6446                	ld	s0,80(sp)
    80004b98:	64a6                	ld	s1,72(sp)
    80004b9a:	6906                	ld	s2,64(sp)
    80004b9c:	79e2                	ld	s3,56(sp)
    80004b9e:	7a42                	ld	s4,48(sp)
    80004ba0:	7aa2                	ld	s5,40(sp)
    80004ba2:	6125                	add	sp,sp,96
    80004ba4:	8082                	ret
      wakeup(&pi->nread);
    80004ba6:	8562                	mv	a0,s8
    80004ba8:	ffffd097          	auipc	ra,0xffffd
    80004bac:	5b0080e7          	jalr	1456(ra) # 80002158 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004bb0:	85a6                	mv	a1,s1
    80004bb2:	855e                	mv	a0,s7
    80004bb4:	ffffd097          	auipc	ra,0xffffd
    80004bb8:	540080e7          	jalr	1344(ra) # 800020f4 <sleep>
  while(i < n){
    80004bbc:	05495f63          	bge	s2,s4,80004c1a <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80004bc0:	2204a783          	lw	a5,544(s1)
    80004bc4:	dfd5                	beqz	a5,80004b80 <pipewrite+0x44>
    80004bc6:	854e                	mv	a0,s3
    80004bc8:	ffffd097          	auipc	ra,0xffffd
    80004bcc:	7d4080e7          	jalr	2004(ra) # 8000239c <killed>
    80004bd0:	f945                	bnez	a0,80004b80 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004bd2:	2184a783          	lw	a5,536(s1)
    80004bd6:	21c4a703          	lw	a4,540(s1)
    80004bda:	2007879b          	addw	a5,a5,512
    80004bde:	fcf704e3          	beq	a4,a5,80004ba6 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004be2:	4685                	li	a3,1
    80004be4:	01590633          	add	a2,s2,s5
    80004be8:	faf40593          	add	a1,s0,-81
    80004bec:	0509b503          	ld	a0,80(s3)
    80004bf0:	ffffd097          	auipc	ra,0xffffd
    80004bf4:	b7e080e7          	jalr	-1154(ra) # 8000176e <copyin>
    80004bf8:	05650263          	beq	a0,s6,80004c3c <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004bfc:	21c4a783          	lw	a5,540(s1)
    80004c00:	0017871b          	addw	a4,a5,1
    80004c04:	20e4ae23          	sw	a4,540(s1)
    80004c08:	1ff7f793          	and	a5,a5,511
    80004c0c:	97a6                	add	a5,a5,s1
    80004c0e:	faf44703          	lbu	a4,-81(s0)
    80004c12:	00e78c23          	sb	a4,24(a5)
      i++;
    80004c16:	2905                	addw	s2,s2,1
    80004c18:	b755                	j	80004bbc <pipewrite+0x80>
    80004c1a:	7b02                	ld	s6,32(sp)
    80004c1c:	6be2                	ld	s7,24(sp)
    80004c1e:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004c20:	21848513          	add	a0,s1,536
    80004c24:	ffffd097          	auipc	ra,0xffffd
    80004c28:	534080e7          	jalr	1332(ra) # 80002158 <wakeup>
  release(&pi->lock);
    80004c2c:	8526                	mv	a0,s1
    80004c2e:	ffffc097          	auipc	ra,0xffffc
    80004c32:	0be080e7          	jalr	190(ra) # 80000cec <release>
  return i;
    80004c36:	bfb1                	j	80004b92 <pipewrite+0x56>
  int i = 0;
    80004c38:	4901                	li	s2,0
    80004c3a:	b7dd                	j	80004c20 <pipewrite+0xe4>
    80004c3c:	7b02                	ld	s6,32(sp)
    80004c3e:	6be2                	ld	s7,24(sp)
    80004c40:	6c42                	ld	s8,16(sp)
    80004c42:	bff9                	j	80004c20 <pipewrite+0xe4>

0000000080004c44 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c44:	715d                	add	sp,sp,-80
    80004c46:	e486                	sd	ra,72(sp)
    80004c48:	e0a2                	sd	s0,64(sp)
    80004c4a:	fc26                	sd	s1,56(sp)
    80004c4c:	f84a                	sd	s2,48(sp)
    80004c4e:	f44e                	sd	s3,40(sp)
    80004c50:	f052                	sd	s4,32(sp)
    80004c52:	ec56                	sd	s5,24(sp)
    80004c54:	0880                	add	s0,sp,80
    80004c56:	84aa                	mv	s1,a0
    80004c58:	892e                	mv	s2,a1
    80004c5a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c5c:	ffffd097          	auipc	ra,0xffffd
    80004c60:	dee080e7          	jalr	-530(ra) # 80001a4a <myproc>
    80004c64:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c66:	8526                	mv	a0,s1
    80004c68:	ffffc097          	auipc	ra,0xffffc
    80004c6c:	fd0080e7          	jalr	-48(ra) # 80000c38 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c70:	2184a703          	lw	a4,536(s1)
    80004c74:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c78:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c7c:	02f71963          	bne	a4,a5,80004cae <piperead+0x6a>
    80004c80:	2244a783          	lw	a5,548(s1)
    80004c84:	cf95                	beqz	a5,80004cc0 <piperead+0x7c>
    if(killed(pr)){
    80004c86:	8552                	mv	a0,s4
    80004c88:	ffffd097          	auipc	ra,0xffffd
    80004c8c:	714080e7          	jalr	1812(ra) # 8000239c <killed>
    80004c90:	e10d                	bnez	a0,80004cb2 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c92:	85a6                	mv	a1,s1
    80004c94:	854e                	mv	a0,s3
    80004c96:	ffffd097          	auipc	ra,0xffffd
    80004c9a:	45e080e7          	jalr	1118(ra) # 800020f4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c9e:	2184a703          	lw	a4,536(s1)
    80004ca2:	21c4a783          	lw	a5,540(s1)
    80004ca6:	fcf70de3          	beq	a4,a5,80004c80 <piperead+0x3c>
    80004caa:	e85a                	sd	s6,16(sp)
    80004cac:	a819                	j	80004cc2 <piperead+0x7e>
    80004cae:	e85a                	sd	s6,16(sp)
    80004cb0:	a809                	j	80004cc2 <piperead+0x7e>
      release(&pi->lock);
    80004cb2:	8526                	mv	a0,s1
    80004cb4:	ffffc097          	auipc	ra,0xffffc
    80004cb8:	038080e7          	jalr	56(ra) # 80000cec <release>
      return -1;
    80004cbc:	59fd                	li	s3,-1
    80004cbe:	a0a5                	j	80004d26 <piperead+0xe2>
    80004cc0:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cc2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cc4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cc6:	05505463          	blez	s5,80004d0e <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80004cca:	2184a783          	lw	a5,536(s1)
    80004cce:	21c4a703          	lw	a4,540(s1)
    80004cd2:	02f70e63          	beq	a4,a5,80004d0e <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004cd6:	0017871b          	addw	a4,a5,1
    80004cda:	20e4ac23          	sw	a4,536(s1)
    80004cde:	1ff7f793          	and	a5,a5,511
    80004ce2:	97a6                	add	a5,a5,s1
    80004ce4:	0187c783          	lbu	a5,24(a5)
    80004ce8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cec:	4685                	li	a3,1
    80004cee:	fbf40613          	add	a2,s0,-65
    80004cf2:	85ca                	mv	a1,s2
    80004cf4:	050a3503          	ld	a0,80(s4)
    80004cf8:	ffffd097          	auipc	ra,0xffffd
    80004cfc:	9ea080e7          	jalr	-1558(ra) # 800016e2 <copyout>
    80004d00:	01650763          	beq	a0,s6,80004d0e <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d04:	2985                	addw	s3,s3,1
    80004d06:	0905                	add	s2,s2,1
    80004d08:	fd3a91e3          	bne	s5,s3,80004cca <piperead+0x86>
    80004d0c:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d0e:	21c48513          	add	a0,s1,540
    80004d12:	ffffd097          	auipc	ra,0xffffd
    80004d16:	446080e7          	jalr	1094(ra) # 80002158 <wakeup>
  release(&pi->lock);
    80004d1a:	8526                	mv	a0,s1
    80004d1c:	ffffc097          	auipc	ra,0xffffc
    80004d20:	fd0080e7          	jalr	-48(ra) # 80000cec <release>
    80004d24:	6b42                	ld	s6,16(sp)
  return i;
}
    80004d26:	854e                	mv	a0,s3
    80004d28:	60a6                	ld	ra,72(sp)
    80004d2a:	6406                	ld	s0,64(sp)
    80004d2c:	74e2                	ld	s1,56(sp)
    80004d2e:	7942                	ld	s2,48(sp)
    80004d30:	79a2                	ld	s3,40(sp)
    80004d32:	7a02                	ld	s4,32(sp)
    80004d34:	6ae2                	ld	s5,24(sp)
    80004d36:	6161                	add	sp,sp,80
    80004d38:	8082                	ret

0000000080004d3a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004d3a:	1141                	add	sp,sp,-16
    80004d3c:	e422                	sd	s0,8(sp)
    80004d3e:	0800                	add	s0,sp,16
    80004d40:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004d42:	8905                	and	a0,a0,1
    80004d44:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004d46:	8b89                	and	a5,a5,2
    80004d48:	c399                	beqz	a5,80004d4e <flags2perm+0x14>
      perm |= PTE_W;
    80004d4a:	00456513          	or	a0,a0,4
    return perm;
}
    80004d4e:	6422                	ld	s0,8(sp)
    80004d50:	0141                	add	sp,sp,16
    80004d52:	8082                	ret

0000000080004d54 <exec>:

int
exec(char *path, char **argv)
{
    80004d54:	df010113          	add	sp,sp,-528
    80004d58:	20113423          	sd	ra,520(sp)
    80004d5c:	20813023          	sd	s0,512(sp)
    80004d60:	ffa6                	sd	s1,504(sp)
    80004d62:	fbca                	sd	s2,496(sp)
    80004d64:	0c00                	add	s0,sp,528
    80004d66:	892a                	mv	s2,a0
    80004d68:	dea43c23          	sd	a0,-520(s0)
    80004d6c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d70:	ffffd097          	auipc	ra,0xffffd
    80004d74:	cda080e7          	jalr	-806(ra) # 80001a4a <myproc>
    80004d78:	84aa                	mv	s1,a0

  begin_op();
    80004d7a:	fffff097          	auipc	ra,0xfffff
    80004d7e:	43a080e7          	jalr	1082(ra) # 800041b4 <begin_op>

  if((ip = namei(path)) == 0){
    80004d82:	854a                	mv	a0,s2
    80004d84:	fffff097          	auipc	ra,0xfffff
    80004d88:	230080e7          	jalr	560(ra) # 80003fb4 <namei>
    80004d8c:	c135                	beqz	a0,80004df0 <exec+0x9c>
    80004d8e:	f3d2                	sd	s4,480(sp)
    80004d90:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d92:	fffff097          	auipc	ra,0xfffff
    80004d96:	a54080e7          	jalr	-1452(ra) # 800037e6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d9a:	04000713          	li	a4,64
    80004d9e:	4681                	li	a3,0
    80004da0:	e5040613          	add	a2,s0,-432
    80004da4:	4581                	li	a1,0
    80004da6:	8552                	mv	a0,s4
    80004da8:	fffff097          	auipc	ra,0xfffff
    80004dac:	cf6080e7          	jalr	-778(ra) # 80003a9e <readi>
    80004db0:	04000793          	li	a5,64
    80004db4:	00f51a63          	bne	a0,a5,80004dc8 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004db8:	e5042703          	lw	a4,-432(s0)
    80004dbc:	464c47b7          	lui	a5,0x464c4
    80004dc0:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004dc4:	02f70c63          	beq	a4,a5,80004dfc <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004dc8:	8552                	mv	a0,s4
    80004dca:	fffff097          	auipc	ra,0xfffff
    80004dce:	c82080e7          	jalr	-894(ra) # 80003a4c <iunlockput>
    end_op();
    80004dd2:	fffff097          	auipc	ra,0xfffff
    80004dd6:	45c080e7          	jalr	1116(ra) # 8000422e <end_op>
  }
  return -1;
    80004dda:	557d                	li	a0,-1
    80004ddc:	7a1e                	ld	s4,480(sp)
}
    80004dde:	20813083          	ld	ra,520(sp)
    80004de2:	20013403          	ld	s0,512(sp)
    80004de6:	74fe                	ld	s1,504(sp)
    80004de8:	795e                	ld	s2,496(sp)
    80004dea:	21010113          	add	sp,sp,528
    80004dee:	8082                	ret
    end_op();
    80004df0:	fffff097          	auipc	ra,0xfffff
    80004df4:	43e080e7          	jalr	1086(ra) # 8000422e <end_op>
    return -1;
    80004df8:	557d                	li	a0,-1
    80004dfa:	b7d5                	j	80004dde <exec+0x8a>
    80004dfc:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004dfe:	8526                	mv	a0,s1
    80004e00:	ffffd097          	auipc	ra,0xffffd
    80004e04:	d0e080e7          	jalr	-754(ra) # 80001b0e <proc_pagetable>
    80004e08:	8b2a                	mv	s6,a0
    80004e0a:	30050f63          	beqz	a0,80005128 <exec+0x3d4>
    80004e0e:	f7ce                	sd	s3,488(sp)
    80004e10:	efd6                	sd	s5,472(sp)
    80004e12:	e7de                	sd	s7,456(sp)
    80004e14:	e3e2                	sd	s8,448(sp)
    80004e16:	ff66                	sd	s9,440(sp)
    80004e18:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e1a:	e7042d03          	lw	s10,-400(s0)
    80004e1e:	e8845783          	lhu	a5,-376(s0)
    80004e22:	14078d63          	beqz	a5,80004f7c <exec+0x228>
    80004e26:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e28:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e2a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004e2c:	6c85                	lui	s9,0x1
    80004e2e:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004e32:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004e36:	6a85                	lui	s5,0x1
    80004e38:	a0b5                	j	80004ea4 <exec+0x150>
      panic("loadseg: address should exist");
    80004e3a:	00003517          	auipc	a0,0x3
    80004e3e:	7ce50513          	add	a0,a0,1998 # 80008608 <etext+0x608>
    80004e42:	ffffb097          	auipc	ra,0xffffb
    80004e46:	71e080e7          	jalr	1822(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80004e4a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e4c:	8726                	mv	a4,s1
    80004e4e:	012c06bb          	addw	a3,s8,s2
    80004e52:	4581                	li	a1,0
    80004e54:	8552                	mv	a0,s4
    80004e56:	fffff097          	auipc	ra,0xfffff
    80004e5a:	c48080e7          	jalr	-952(ra) # 80003a9e <readi>
    80004e5e:	2501                	sext.w	a0,a0
    80004e60:	28a49863          	bne	s1,a0,800050f0 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    80004e64:	012a893b          	addw	s2,s5,s2
    80004e68:	03397563          	bgeu	s2,s3,80004e92 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80004e6c:	02091593          	sll	a1,s2,0x20
    80004e70:	9181                	srl	a1,a1,0x20
    80004e72:	95de                	add	a1,a1,s7
    80004e74:	855a                	mv	a0,s6
    80004e76:	ffffc097          	auipc	ra,0xffffc
    80004e7a:	240080e7          	jalr	576(ra) # 800010b6 <walkaddr>
    80004e7e:	862a                	mv	a2,a0
    if(pa == 0)
    80004e80:	dd4d                	beqz	a0,80004e3a <exec+0xe6>
    if(sz - i < PGSIZE)
    80004e82:	412984bb          	subw	s1,s3,s2
    80004e86:	0004879b          	sext.w	a5,s1
    80004e8a:	fcfcf0e3          	bgeu	s9,a5,80004e4a <exec+0xf6>
    80004e8e:	84d6                	mv	s1,s5
    80004e90:	bf6d                	j	80004e4a <exec+0xf6>
    sz = sz1;
    80004e92:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e96:	2d85                	addw	s11,s11,1
    80004e98:	038d0d1b          	addw	s10,s10,56
    80004e9c:	e8845783          	lhu	a5,-376(s0)
    80004ea0:	08fdd663          	bge	s11,a5,80004f2c <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ea4:	2d01                	sext.w	s10,s10
    80004ea6:	03800713          	li	a4,56
    80004eaa:	86ea                	mv	a3,s10
    80004eac:	e1840613          	add	a2,s0,-488
    80004eb0:	4581                	li	a1,0
    80004eb2:	8552                	mv	a0,s4
    80004eb4:	fffff097          	auipc	ra,0xfffff
    80004eb8:	bea080e7          	jalr	-1046(ra) # 80003a9e <readi>
    80004ebc:	03800793          	li	a5,56
    80004ec0:	20f51063          	bne	a0,a5,800050c0 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    80004ec4:	e1842783          	lw	a5,-488(s0)
    80004ec8:	4705                	li	a4,1
    80004eca:	fce796e3          	bne	a5,a4,80004e96 <exec+0x142>
    if(ph.memsz < ph.filesz)
    80004ece:	e4043483          	ld	s1,-448(s0)
    80004ed2:	e3843783          	ld	a5,-456(s0)
    80004ed6:	1ef4e963          	bltu	s1,a5,800050c8 <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004eda:	e2843783          	ld	a5,-472(s0)
    80004ede:	94be                	add	s1,s1,a5
    80004ee0:	1ef4e863          	bltu	s1,a5,800050d0 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    80004ee4:	df043703          	ld	a4,-528(s0)
    80004ee8:	8ff9                	and	a5,a5,a4
    80004eea:	1e079763          	bnez	a5,800050d8 <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004eee:	e1c42503          	lw	a0,-484(s0)
    80004ef2:	00000097          	auipc	ra,0x0
    80004ef6:	e48080e7          	jalr	-440(ra) # 80004d3a <flags2perm>
    80004efa:	86aa                	mv	a3,a0
    80004efc:	8626                	mv	a2,s1
    80004efe:	85ca                	mv	a1,s2
    80004f00:	855a                	mv	a0,s6
    80004f02:	ffffc097          	auipc	ra,0xffffc
    80004f06:	578080e7          	jalr	1400(ra) # 8000147a <uvmalloc>
    80004f0a:	e0a43423          	sd	a0,-504(s0)
    80004f0e:	1c050963          	beqz	a0,800050e0 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f12:	e2843b83          	ld	s7,-472(s0)
    80004f16:	e2042c03          	lw	s8,-480(s0)
    80004f1a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f1e:	00098463          	beqz	s3,80004f26 <exec+0x1d2>
    80004f22:	4901                	li	s2,0
    80004f24:	b7a1                	j	80004e6c <exec+0x118>
    sz = sz1;
    80004f26:	e0843903          	ld	s2,-504(s0)
    80004f2a:	b7b5                	j	80004e96 <exec+0x142>
    80004f2c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004f2e:	8552                	mv	a0,s4
    80004f30:	fffff097          	auipc	ra,0xfffff
    80004f34:	b1c080e7          	jalr	-1252(ra) # 80003a4c <iunlockput>
  end_op();
    80004f38:	fffff097          	auipc	ra,0xfffff
    80004f3c:	2f6080e7          	jalr	758(ra) # 8000422e <end_op>
  p = myproc();
    80004f40:	ffffd097          	auipc	ra,0xffffd
    80004f44:	b0a080e7          	jalr	-1270(ra) # 80001a4a <myproc>
    80004f48:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f4a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004f4e:	6985                	lui	s3,0x1
    80004f50:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004f52:	99ca                	add	s3,s3,s2
    80004f54:	77fd                	lui	a5,0xfffff
    80004f56:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f5a:	4691                	li	a3,4
    80004f5c:	6609                	lui	a2,0x2
    80004f5e:	964e                	add	a2,a2,s3
    80004f60:	85ce                	mv	a1,s3
    80004f62:	855a                	mv	a0,s6
    80004f64:	ffffc097          	auipc	ra,0xffffc
    80004f68:	516080e7          	jalr	1302(ra) # 8000147a <uvmalloc>
    80004f6c:	892a                	mv	s2,a0
    80004f6e:	e0a43423          	sd	a0,-504(s0)
    80004f72:	e519                	bnez	a0,80004f80 <exec+0x22c>
  if(pagetable)
    80004f74:	e1343423          	sd	s3,-504(s0)
    80004f78:	4a01                	li	s4,0
    80004f7a:	aaa5                	j	800050f2 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f7c:	4901                	li	s2,0
    80004f7e:	bf45                	j	80004f2e <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f80:	75f9                	lui	a1,0xffffe
    80004f82:	95aa                	add	a1,a1,a0
    80004f84:	855a                	mv	a0,s6
    80004f86:	ffffc097          	auipc	ra,0xffffc
    80004f8a:	72a080e7          	jalr	1834(ra) # 800016b0 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f8e:	7bfd                	lui	s7,0xfffff
    80004f90:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004f92:	e0043783          	ld	a5,-512(s0)
    80004f96:	6388                	ld	a0,0(a5)
    80004f98:	c52d                	beqz	a0,80005002 <exec+0x2ae>
    80004f9a:	e9040993          	add	s3,s0,-368
    80004f9e:	f9040c13          	add	s8,s0,-112
    80004fa2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fa4:	ffffc097          	auipc	ra,0xffffc
    80004fa8:	f04080e7          	jalr	-252(ra) # 80000ea8 <strlen>
    80004fac:	0015079b          	addw	a5,a0,1
    80004fb0:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fb4:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    80004fb8:	13796863          	bltu	s2,s7,800050e8 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fbc:	e0043d03          	ld	s10,-512(s0)
    80004fc0:	000d3a03          	ld	s4,0(s10)
    80004fc4:	8552                	mv	a0,s4
    80004fc6:	ffffc097          	auipc	ra,0xffffc
    80004fca:	ee2080e7          	jalr	-286(ra) # 80000ea8 <strlen>
    80004fce:	0015069b          	addw	a3,a0,1
    80004fd2:	8652                	mv	a2,s4
    80004fd4:	85ca                	mv	a1,s2
    80004fd6:	855a                	mv	a0,s6
    80004fd8:	ffffc097          	auipc	ra,0xffffc
    80004fdc:	70a080e7          	jalr	1802(ra) # 800016e2 <copyout>
    80004fe0:	10054663          	bltz	a0,800050ec <exec+0x398>
    ustack[argc] = sp;
    80004fe4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004fe8:	0485                	add	s1,s1,1
    80004fea:	008d0793          	add	a5,s10,8
    80004fee:	e0f43023          	sd	a5,-512(s0)
    80004ff2:	008d3503          	ld	a0,8(s10)
    80004ff6:	c909                	beqz	a0,80005008 <exec+0x2b4>
    if(argc >= MAXARG)
    80004ff8:	09a1                	add	s3,s3,8
    80004ffa:	fb8995e3          	bne	s3,s8,80004fa4 <exec+0x250>
  ip = 0;
    80004ffe:	4a01                	li	s4,0
    80005000:	a8cd                	j	800050f2 <exec+0x39e>
  sp = sz;
    80005002:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005006:	4481                	li	s1,0
  ustack[argc] = 0;
    80005008:	00349793          	sll	a5,s1,0x3
    8000500c:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd1e0>
    80005010:	97a2                	add	a5,a5,s0
    80005012:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005016:	00148693          	add	a3,s1,1
    8000501a:	068e                	sll	a3,a3,0x3
    8000501c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005020:	ff097913          	and	s2,s2,-16
  sz = sz1;
    80005024:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005028:	f57966e3          	bltu	s2,s7,80004f74 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000502c:	e9040613          	add	a2,s0,-368
    80005030:	85ca                	mv	a1,s2
    80005032:	855a                	mv	a0,s6
    80005034:	ffffc097          	auipc	ra,0xffffc
    80005038:	6ae080e7          	jalr	1710(ra) # 800016e2 <copyout>
    8000503c:	0e054863          	bltz	a0,8000512c <exec+0x3d8>
  p->trapframe->a1 = sp;
    80005040:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005044:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005048:	df843783          	ld	a5,-520(s0)
    8000504c:	0007c703          	lbu	a4,0(a5)
    80005050:	cf11                	beqz	a4,8000506c <exec+0x318>
    80005052:	0785                	add	a5,a5,1
    if(*s == '/')
    80005054:	02f00693          	li	a3,47
    80005058:	a039                	j	80005066 <exec+0x312>
      last = s+1;
    8000505a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000505e:	0785                	add	a5,a5,1
    80005060:	fff7c703          	lbu	a4,-1(a5)
    80005064:	c701                	beqz	a4,8000506c <exec+0x318>
    if(*s == '/')
    80005066:	fed71ce3          	bne	a4,a3,8000505e <exec+0x30a>
    8000506a:	bfc5                	j	8000505a <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    8000506c:	4641                	li	a2,16
    8000506e:	df843583          	ld	a1,-520(s0)
    80005072:	158a8513          	add	a0,s5,344
    80005076:	ffffc097          	auipc	ra,0xffffc
    8000507a:	e00080e7          	jalr	-512(ra) # 80000e76 <safestrcpy>
  oldpagetable = p->pagetable;
    8000507e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005082:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005086:	e0843783          	ld	a5,-504(s0)
    8000508a:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000508e:	058ab783          	ld	a5,88(s5)
    80005092:	e6843703          	ld	a4,-408(s0)
    80005096:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005098:	058ab783          	ld	a5,88(s5)
    8000509c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050a0:	85e6                	mv	a1,s9
    800050a2:	ffffd097          	auipc	ra,0xffffd
    800050a6:	b08080e7          	jalr	-1272(ra) # 80001baa <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050aa:	0004851b          	sext.w	a0,s1
    800050ae:	79be                	ld	s3,488(sp)
    800050b0:	7a1e                	ld	s4,480(sp)
    800050b2:	6afe                	ld	s5,472(sp)
    800050b4:	6b5e                	ld	s6,464(sp)
    800050b6:	6bbe                	ld	s7,456(sp)
    800050b8:	6c1e                	ld	s8,448(sp)
    800050ba:	7cfa                	ld	s9,440(sp)
    800050bc:	7d5a                	ld	s10,432(sp)
    800050be:	b305                	j	80004dde <exec+0x8a>
    800050c0:	e1243423          	sd	s2,-504(s0)
    800050c4:	7dba                	ld	s11,424(sp)
    800050c6:	a035                	j	800050f2 <exec+0x39e>
    800050c8:	e1243423          	sd	s2,-504(s0)
    800050cc:	7dba                	ld	s11,424(sp)
    800050ce:	a015                	j	800050f2 <exec+0x39e>
    800050d0:	e1243423          	sd	s2,-504(s0)
    800050d4:	7dba                	ld	s11,424(sp)
    800050d6:	a831                	j	800050f2 <exec+0x39e>
    800050d8:	e1243423          	sd	s2,-504(s0)
    800050dc:	7dba                	ld	s11,424(sp)
    800050de:	a811                	j	800050f2 <exec+0x39e>
    800050e0:	e1243423          	sd	s2,-504(s0)
    800050e4:	7dba                	ld	s11,424(sp)
    800050e6:	a031                	j	800050f2 <exec+0x39e>
  ip = 0;
    800050e8:	4a01                	li	s4,0
    800050ea:	a021                	j	800050f2 <exec+0x39e>
    800050ec:	4a01                	li	s4,0
  if(pagetable)
    800050ee:	a011                	j	800050f2 <exec+0x39e>
    800050f0:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800050f2:	e0843583          	ld	a1,-504(s0)
    800050f6:	855a                	mv	a0,s6
    800050f8:	ffffd097          	auipc	ra,0xffffd
    800050fc:	ab2080e7          	jalr	-1358(ra) # 80001baa <proc_freepagetable>
  return -1;
    80005100:	557d                	li	a0,-1
  if(ip){
    80005102:	000a1b63          	bnez	s4,80005118 <exec+0x3c4>
    80005106:	79be                	ld	s3,488(sp)
    80005108:	7a1e                	ld	s4,480(sp)
    8000510a:	6afe                	ld	s5,472(sp)
    8000510c:	6b5e                	ld	s6,464(sp)
    8000510e:	6bbe                	ld	s7,456(sp)
    80005110:	6c1e                	ld	s8,448(sp)
    80005112:	7cfa                	ld	s9,440(sp)
    80005114:	7d5a                	ld	s10,432(sp)
    80005116:	b1e1                	j	80004dde <exec+0x8a>
    80005118:	79be                	ld	s3,488(sp)
    8000511a:	6afe                	ld	s5,472(sp)
    8000511c:	6b5e                	ld	s6,464(sp)
    8000511e:	6bbe                	ld	s7,456(sp)
    80005120:	6c1e                	ld	s8,448(sp)
    80005122:	7cfa                	ld	s9,440(sp)
    80005124:	7d5a                	ld	s10,432(sp)
    80005126:	b14d                	j	80004dc8 <exec+0x74>
    80005128:	6b5e                	ld	s6,464(sp)
    8000512a:	b979                	j	80004dc8 <exec+0x74>
  sz = sz1;
    8000512c:	e0843983          	ld	s3,-504(s0)
    80005130:	b591                	j	80004f74 <exec+0x220>

0000000080005132 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005132:	7179                	add	sp,sp,-48
    80005134:	f406                	sd	ra,40(sp)
    80005136:	f022                	sd	s0,32(sp)
    80005138:	ec26                	sd	s1,24(sp)
    8000513a:	e84a                	sd	s2,16(sp)
    8000513c:	1800                	add	s0,sp,48
    8000513e:	892e                	mv	s2,a1
    80005140:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005142:	fdc40593          	add	a1,s0,-36
    80005146:	ffffe097          	auipc	ra,0xffffe
    8000514a:	afc080e7          	jalr	-1284(ra) # 80002c42 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000514e:	fdc42703          	lw	a4,-36(s0)
    80005152:	47bd                	li	a5,15
    80005154:	02e7eb63          	bltu	a5,a4,8000518a <argfd+0x58>
    80005158:	ffffd097          	auipc	ra,0xffffd
    8000515c:	8f2080e7          	jalr	-1806(ra) # 80001a4a <myproc>
    80005160:	fdc42703          	lw	a4,-36(s0)
    80005164:	01a70793          	add	a5,a4,26
    80005168:	078e                	sll	a5,a5,0x3
    8000516a:	953e                	add	a0,a0,a5
    8000516c:	611c                	ld	a5,0(a0)
    8000516e:	c385                	beqz	a5,8000518e <argfd+0x5c>
    return -1;
  if(pfd)
    80005170:	00090463          	beqz	s2,80005178 <argfd+0x46>
    *pfd = fd;
    80005174:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005178:	4501                	li	a0,0
  if(pf)
    8000517a:	c091                	beqz	s1,8000517e <argfd+0x4c>
    *pf = f;
    8000517c:	e09c                	sd	a5,0(s1)
}
    8000517e:	70a2                	ld	ra,40(sp)
    80005180:	7402                	ld	s0,32(sp)
    80005182:	64e2                	ld	s1,24(sp)
    80005184:	6942                	ld	s2,16(sp)
    80005186:	6145                	add	sp,sp,48
    80005188:	8082                	ret
    return -1;
    8000518a:	557d                	li	a0,-1
    8000518c:	bfcd                	j	8000517e <argfd+0x4c>
    8000518e:	557d                	li	a0,-1
    80005190:	b7fd                	j	8000517e <argfd+0x4c>

0000000080005192 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005192:	1101                	add	sp,sp,-32
    80005194:	ec06                	sd	ra,24(sp)
    80005196:	e822                	sd	s0,16(sp)
    80005198:	e426                	sd	s1,8(sp)
    8000519a:	1000                	add	s0,sp,32
    8000519c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000519e:	ffffd097          	auipc	ra,0xffffd
    800051a2:	8ac080e7          	jalr	-1876(ra) # 80001a4a <myproc>
    800051a6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800051a8:	0d050793          	add	a5,a0,208
    800051ac:	4501                	li	a0,0
    800051ae:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800051b0:	6398                	ld	a4,0(a5)
    800051b2:	cb19                	beqz	a4,800051c8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800051b4:	2505                	addw	a0,a0,1
    800051b6:	07a1                	add	a5,a5,8
    800051b8:	fed51ce3          	bne	a0,a3,800051b0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800051bc:	557d                	li	a0,-1
}
    800051be:	60e2                	ld	ra,24(sp)
    800051c0:	6442                	ld	s0,16(sp)
    800051c2:	64a2                	ld	s1,8(sp)
    800051c4:	6105                	add	sp,sp,32
    800051c6:	8082                	ret
      p->ofile[fd] = f;
    800051c8:	01a50793          	add	a5,a0,26
    800051cc:	078e                	sll	a5,a5,0x3
    800051ce:	963e                	add	a2,a2,a5
    800051d0:	e204                	sd	s1,0(a2)
      return fd;
    800051d2:	b7f5                	j	800051be <fdalloc+0x2c>

00000000800051d4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051d4:	715d                	add	sp,sp,-80
    800051d6:	e486                	sd	ra,72(sp)
    800051d8:	e0a2                	sd	s0,64(sp)
    800051da:	fc26                	sd	s1,56(sp)
    800051dc:	f84a                	sd	s2,48(sp)
    800051de:	f44e                	sd	s3,40(sp)
    800051e0:	ec56                	sd	s5,24(sp)
    800051e2:	e85a                	sd	s6,16(sp)
    800051e4:	0880                	add	s0,sp,80
    800051e6:	8b2e                	mv	s6,a1
    800051e8:	89b2                	mv	s3,a2
    800051ea:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800051ec:	fb040593          	add	a1,s0,-80
    800051f0:	fffff097          	auipc	ra,0xfffff
    800051f4:	de2080e7          	jalr	-542(ra) # 80003fd2 <nameiparent>
    800051f8:	84aa                	mv	s1,a0
    800051fa:	14050e63          	beqz	a0,80005356 <create+0x182>
    return 0;

  ilock(dp);
    800051fe:	ffffe097          	auipc	ra,0xffffe
    80005202:	5e8080e7          	jalr	1512(ra) # 800037e6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005206:	4601                	li	a2,0
    80005208:	fb040593          	add	a1,s0,-80
    8000520c:	8526                	mv	a0,s1
    8000520e:	fffff097          	auipc	ra,0xfffff
    80005212:	ae4080e7          	jalr	-1308(ra) # 80003cf2 <dirlookup>
    80005216:	8aaa                	mv	s5,a0
    80005218:	c539                	beqz	a0,80005266 <create+0x92>
    iunlockput(dp);
    8000521a:	8526                	mv	a0,s1
    8000521c:	fffff097          	auipc	ra,0xfffff
    80005220:	830080e7          	jalr	-2000(ra) # 80003a4c <iunlockput>
    ilock(ip);
    80005224:	8556                	mv	a0,s5
    80005226:	ffffe097          	auipc	ra,0xffffe
    8000522a:	5c0080e7          	jalr	1472(ra) # 800037e6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000522e:	4789                	li	a5,2
    80005230:	02fb1463          	bne	s6,a5,80005258 <create+0x84>
    80005234:	044ad783          	lhu	a5,68(s5)
    80005238:	37f9                	addw	a5,a5,-2
    8000523a:	17c2                	sll	a5,a5,0x30
    8000523c:	93c1                	srl	a5,a5,0x30
    8000523e:	4705                	li	a4,1
    80005240:	00f76c63          	bltu	a4,a5,80005258 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005244:	8556                	mv	a0,s5
    80005246:	60a6                	ld	ra,72(sp)
    80005248:	6406                	ld	s0,64(sp)
    8000524a:	74e2                	ld	s1,56(sp)
    8000524c:	7942                	ld	s2,48(sp)
    8000524e:	79a2                	ld	s3,40(sp)
    80005250:	6ae2                	ld	s5,24(sp)
    80005252:	6b42                	ld	s6,16(sp)
    80005254:	6161                	add	sp,sp,80
    80005256:	8082                	ret
    iunlockput(ip);
    80005258:	8556                	mv	a0,s5
    8000525a:	ffffe097          	auipc	ra,0xffffe
    8000525e:	7f2080e7          	jalr	2034(ra) # 80003a4c <iunlockput>
    return 0;
    80005262:	4a81                	li	s5,0
    80005264:	b7c5                	j	80005244 <create+0x70>
    80005266:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005268:	85da                	mv	a1,s6
    8000526a:	4088                	lw	a0,0(s1)
    8000526c:	ffffe097          	auipc	ra,0xffffe
    80005270:	3d6080e7          	jalr	982(ra) # 80003642 <ialloc>
    80005274:	8a2a                	mv	s4,a0
    80005276:	c531                	beqz	a0,800052c2 <create+0xee>
  ilock(ip);
    80005278:	ffffe097          	auipc	ra,0xffffe
    8000527c:	56e080e7          	jalr	1390(ra) # 800037e6 <ilock>
  ip->major = major;
    80005280:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005284:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005288:	4905                	li	s2,1
    8000528a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000528e:	8552                	mv	a0,s4
    80005290:	ffffe097          	auipc	ra,0xffffe
    80005294:	48a080e7          	jalr	1162(ra) # 8000371a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005298:	032b0d63          	beq	s6,s2,800052d2 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000529c:	004a2603          	lw	a2,4(s4)
    800052a0:	fb040593          	add	a1,s0,-80
    800052a4:	8526                	mv	a0,s1
    800052a6:	fffff097          	auipc	ra,0xfffff
    800052aa:	c5c080e7          	jalr	-932(ra) # 80003f02 <dirlink>
    800052ae:	08054163          	bltz	a0,80005330 <create+0x15c>
  iunlockput(dp);
    800052b2:	8526                	mv	a0,s1
    800052b4:	ffffe097          	auipc	ra,0xffffe
    800052b8:	798080e7          	jalr	1944(ra) # 80003a4c <iunlockput>
  return ip;
    800052bc:	8ad2                	mv	s5,s4
    800052be:	7a02                	ld	s4,32(sp)
    800052c0:	b751                	j	80005244 <create+0x70>
    iunlockput(dp);
    800052c2:	8526                	mv	a0,s1
    800052c4:	ffffe097          	auipc	ra,0xffffe
    800052c8:	788080e7          	jalr	1928(ra) # 80003a4c <iunlockput>
    return 0;
    800052cc:	8ad2                	mv	s5,s4
    800052ce:	7a02                	ld	s4,32(sp)
    800052d0:	bf95                	j	80005244 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052d2:	004a2603          	lw	a2,4(s4)
    800052d6:	00003597          	auipc	a1,0x3
    800052da:	35258593          	add	a1,a1,850 # 80008628 <etext+0x628>
    800052de:	8552                	mv	a0,s4
    800052e0:	fffff097          	auipc	ra,0xfffff
    800052e4:	c22080e7          	jalr	-990(ra) # 80003f02 <dirlink>
    800052e8:	04054463          	bltz	a0,80005330 <create+0x15c>
    800052ec:	40d0                	lw	a2,4(s1)
    800052ee:	00003597          	auipc	a1,0x3
    800052f2:	34258593          	add	a1,a1,834 # 80008630 <etext+0x630>
    800052f6:	8552                	mv	a0,s4
    800052f8:	fffff097          	auipc	ra,0xfffff
    800052fc:	c0a080e7          	jalr	-1014(ra) # 80003f02 <dirlink>
    80005300:	02054863          	bltz	a0,80005330 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005304:	004a2603          	lw	a2,4(s4)
    80005308:	fb040593          	add	a1,s0,-80
    8000530c:	8526                	mv	a0,s1
    8000530e:	fffff097          	auipc	ra,0xfffff
    80005312:	bf4080e7          	jalr	-1036(ra) # 80003f02 <dirlink>
    80005316:	00054d63          	bltz	a0,80005330 <create+0x15c>
    dp->nlink++;  // for ".."
    8000531a:	04a4d783          	lhu	a5,74(s1)
    8000531e:	2785                	addw	a5,a5,1
    80005320:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005324:	8526                	mv	a0,s1
    80005326:	ffffe097          	auipc	ra,0xffffe
    8000532a:	3f4080e7          	jalr	1012(ra) # 8000371a <iupdate>
    8000532e:	b751                	j	800052b2 <create+0xde>
  ip->nlink = 0;
    80005330:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005334:	8552                	mv	a0,s4
    80005336:	ffffe097          	auipc	ra,0xffffe
    8000533a:	3e4080e7          	jalr	996(ra) # 8000371a <iupdate>
  iunlockput(ip);
    8000533e:	8552                	mv	a0,s4
    80005340:	ffffe097          	auipc	ra,0xffffe
    80005344:	70c080e7          	jalr	1804(ra) # 80003a4c <iunlockput>
  iunlockput(dp);
    80005348:	8526                	mv	a0,s1
    8000534a:	ffffe097          	auipc	ra,0xffffe
    8000534e:	702080e7          	jalr	1794(ra) # 80003a4c <iunlockput>
  return 0;
    80005352:	7a02                	ld	s4,32(sp)
    80005354:	bdc5                	j	80005244 <create+0x70>
    return 0;
    80005356:	8aaa                	mv	s5,a0
    80005358:	b5f5                	j	80005244 <create+0x70>

000000008000535a <sys_dup>:
{
    8000535a:	7179                	add	sp,sp,-48
    8000535c:	f406                	sd	ra,40(sp)
    8000535e:	f022                	sd	s0,32(sp)
    80005360:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005362:	fd840613          	add	a2,s0,-40
    80005366:	4581                	li	a1,0
    80005368:	4501                	li	a0,0
    8000536a:	00000097          	auipc	ra,0x0
    8000536e:	dc8080e7          	jalr	-568(ra) # 80005132 <argfd>
    return -1;
    80005372:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005374:	02054763          	bltz	a0,800053a2 <sys_dup+0x48>
    80005378:	ec26                	sd	s1,24(sp)
    8000537a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000537c:	fd843903          	ld	s2,-40(s0)
    80005380:	854a                	mv	a0,s2
    80005382:	00000097          	auipc	ra,0x0
    80005386:	e10080e7          	jalr	-496(ra) # 80005192 <fdalloc>
    8000538a:	84aa                	mv	s1,a0
    return -1;
    8000538c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000538e:	00054f63          	bltz	a0,800053ac <sys_dup+0x52>
  filedup(f);
    80005392:	854a                	mv	a0,s2
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	298080e7          	jalr	664(ra) # 8000462c <filedup>
  return fd;
    8000539c:	87a6                	mv	a5,s1
    8000539e:	64e2                	ld	s1,24(sp)
    800053a0:	6942                	ld	s2,16(sp)
}
    800053a2:	853e                	mv	a0,a5
    800053a4:	70a2                	ld	ra,40(sp)
    800053a6:	7402                	ld	s0,32(sp)
    800053a8:	6145                	add	sp,sp,48
    800053aa:	8082                	ret
    800053ac:	64e2                	ld	s1,24(sp)
    800053ae:	6942                	ld	s2,16(sp)
    800053b0:	bfcd                	j	800053a2 <sys_dup+0x48>

00000000800053b2 <sys_read>:
{
    800053b2:	7179                	add	sp,sp,-48
    800053b4:	f406                	sd	ra,40(sp)
    800053b6:	f022                	sd	s0,32(sp)
    800053b8:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800053ba:	fd840593          	add	a1,s0,-40
    800053be:	4505                	li	a0,1
    800053c0:	ffffe097          	auipc	ra,0xffffe
    800053c4:	8a2080e7          	jalr	-1886(ra) # 80002c62 <argaddr>
  argint(2, &n);
    800053c8:	fe440593          	add	a1,s0,-28
    800053cc:	4509                	li	a0,2
    800053ce:	ffffe097          	auipc	ra,0xffffe
    800053d2:	874080e7          	jalr	-1932(ra) # 80002c42 <argint>
  if(argfd(0, 0, &f) < 0)
    800053d6:	fe840613          	add	a2,s0,-24
    800053da:	4581                	li	a1,0
    800053dc:	4501                	li	a0,0
    800053de:	00000097          	auipc	ra,0x0
    800053e2:	d54080e7          	jalr	-684(ra) # 80005132 <argfd>
    800053e6:	87aa                	mv	a5,a0
    return -1;
    800053e8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053ea:	0007cc63          	bltz	a5,80005402 <sys_read+0x50>
  return fileread(f, p, n);
    800053ee:	fe442603          	lw	a2,-28(s0)
    800053f2:	fd843583          	ld	a1,-40(s0)
    800053f6:	fe843503          	ld	a0,-24(s0)
    800053fa:	fffff097          	auipc	ra,0xfffff
    800053fe:	3d8080e7          	jalr	984(ra) # 800047d2 <fileread>
}
    80005402:	70a2                	ld	ra,40(sp)
    80005404:	7402                	ld	s0,32(sp)
    80005406:	6145                	add	sp,sp,48
    80005408:	8082                	ret

000000008000540a <sys_write>:
{
    8000540a:	7179                	add	sp,sp,-48
    8000540c:	f406                	sd	ra,40(sp)
    8000540e:	f022                	sd	s0,32(sp)
    80005410:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005412:	fd840593          	add	a1,s0,-40
    80005416:	4505                	li	a0,1
    80005418:	ffffe097          	auipc	ra,0xffffe
    8000541c:	84a080e7          	jalr	-1974(ra) # 80002c62 <argaddr>
  argint(2, &n);
    80005420:	fe440593          	add	a1,s0,-28
    80005424:	4509                	li	a0,2
    80005426:	ffffe097          	auipc	ra,0xffffe
    8000542a:	81c080e7          	jalr	-2020(ra) # 80002c42 <argint>
  if(argfd(0, 0, &f) < 0)
    8000542e:	fe840613          	add	a2,s0,-24
    80005432:	4581                	li	a1,0
    80005434:	4501                	li	a0,0
    80005436:	00000097          	auipc	ra,0x0
    8000543a:	cfc080e7          	jalr	-772(ra) # 80005132 <argfd>
    8000543e:	87aa                	mv	a5,a0
    return -1;
    80005440:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005442:	0007cc63          	bltz	a5,8000545a <sys_write+0x50>
  return filewrite(f, p, n);
    80005446:	fe442603          	lw	a2,-28(s0)
    8000544a:	fd843583          	ld	a1,-40(s0)
    8000544e:	fe843503          	ld	a0,-24(s0)
    80005452:	fffff097          	auipc	ra,0xfffff
    80005456:	452080e7          	jalr	1106(ra) # 800048a4 <filewrite>
}
    8000545a:	70a2                	ld	ra,40(sp)
    8000545c:	7402                	ld	s0,32(sp)
    8000545e:	6145                	add	sp,sp,48
    80005460:	8082                	ret

0000000080005462 <sys_close>:
{
    80005462:	1101                	add	sp,sp,-32
    80005464:	ec06                	sd	ra,24(sp)
    80005466:	e822                	sd	s0,16(sp)
    80005468:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000546a:	fe040613          	add	a2,s0,-32
    8000546e:	fec40593          	add	a1,s0,-20
    80005472:	4501                	li	a0,0
    80005474:	00000097          	auipc	ra,0x0
    80005478:	cbe080e7          	jalr	-834(ra) # 80005132 <argfd>
    return -1;
    8000547c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000547e:	02054463          	bltz	a0,800054a6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005482:	ffffc097          	auipc	ra,0xffffc
    80005486:	5c8080e7          	jalr	1480(ra) # 80001a4a <myproc>
    8000548a:	fec42783          	lw	a5,-20(s0)
    8000548e:	07e9                	add	a5,a5,26
    80005490:	078e                	sll	a5,a5,0x3
    80005492:	953e                	add	a0,a0,a5
    80005494:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005498:	fe043503          	ld	a0,-32(s0)
    8000549c:	fffff097          	auipc	ra,0xfffff
    800054a0:	1e2080e7          	jalr	482(ra) # 8000467e <fileclose>
  return 0;
    800054a4:	4781                	li	a5,0
}
    800054a6:	853e                	mv	a0,a5
    800054a8:	60e2                	ld	ra,24(sp)
    800054aa:	6442                	ld	s0,16(sp)
    800054ac:	6105                	add	sp,sp,32
    800054ae:	8082                	ret

00000000800054b0 <sys_fstat>:
{
    800054b0:	1101                	add	sp,sp,-32
    800054b2:	ec06                	sd	ra,24(sp)
    800054b4:	e822                	sd	s0,16(sp)
    800054b6:	1000                	add	s0,sp,32
  argaddr(1, &st);
    800054b8:	fe040593          	add	a1,s0,-32
    800054bc:	4505                	li	a0,1
    800054be:	ffffd097          	auipc	ra,0xffffd
    800054c2:	7a4080e7          	jalr	1956(ra) # 80002c62 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800054c6:	fe840613          	add	a2,s0,-24
    800054ca:	4581                	li	a1,0
    800054cc:	4501                	li	a0,0
    800054ce:	00000097          	auipc	ra,0x0
    800054d2:	c64080e7          	jalr	-924(ra) # 80005132 <argfd>
    800054d6:	87aa                	mv	a5,a0
    return -1;
    800054d8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054da:	0007ca63          	bltz	a5,800054ee <sys_fstat+0x3e>
  return filestat(f, st);
    800054de:	fe043583          	ld	a1,-32(s0)
    800054e2:	fe843503          	ld	a0,-24(s0)
    800054e6:	fffff097          	auipc	ra,0xfffff
    800054ea:	27a080e7          	jalr	634(ra) # 80004760 <filestat>
}
    800054ee:	60e2                	ld	ra,24(sp)
    800054f0:	6442                	ld	s0,16(sp)
    800054f2:	6105                	add	sp,sp,32
    800054f4:	8082                	ret

00000000800054f6 <sys_link>:
{
    800054f6:	7169                	add	sp,sp,-304
    800054f8:	f606                	sd	ra,296(sp)
    800054fa:	f222                	sd	s0,288(sp)
    800054fc:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054fe:	08000613          	li	a2,128
    80005502:	ed040593          	add	a1,s0,-304
    80005506:	4501                	li	a0,0
    80005508:	ffffd097          	auipc	ra,0xffffd
    8000550c:	77a080e7          	jalr	1914(ra) # 80002c82 <argstr>
    return -1;
    80005510:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005512:	12054663          	bltz	a0,8000563e <sys_link+0x148>
    80005516:	08000613          	li	a2,128
    8000551a:	f5040593          	add	a1,s0,-176
    8000551e:	4505                	li	a0,1
    80005520:	ffffd097          	auipc	ra,0xffffd
    80005524:	762080e7          	jalr	1890(ra) # 80002c82 <argstr>
    return -1;
    80005528:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000552a:	10054a63          	bltz	a0,8000563e <sys_link+0x148>
    8000552e:	ee26                	sd	s1,280(sp)
  begin_op();
    80005530:	fffff097          	auipc	ra,0xfffff
    80005534:	c84080e7          	jalr	-892(ra) # 800041b4 <begin_op>
  if((ip = namei(old)) == 0){
    80005538:	ed040513          	add	a0,s0,-304
    8000553c:	fffff097          	auipc	ra,0xfffff
    80005540:	a78080e7          	jalr	-1416(ra) # 80003fb4 <namei>
    80005544:	84aa                	mv	s1,a0
    80005546:	c949                	beqz	a0,800055d8 <sys_link+0xe2>
  ilock(ip);
    80005548:	ffffe097          	auipc	ra,0xffffe
    8000554c:	29e080e7          	jalr	670(ra) # 800037e6 <ilock>
  if(ip->type == T_DIR){
    80005550:	04449703          	lh	a4,68(s1)
    80005554:	4785                	li	a5,1
    80005556:	08f70863          	beq	a4,a5,800055e6 <sys_link+0xf0>
    8000555a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000555c:	04a4d783          	lhu	a5,74(s1)
    80005560:	2785                	addw	a5,a5,1
    80005562:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005566:	8526                	mv	a0,s1
    80005568:	ffffe097          	auipc	ra,0xffffe
    8000556c:	1b2080e7          	jalr	434(ra) # 8000371a <iupdate>
  iunlock(ip);
    80005570:	8526                	mv	a0,s1
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	33a080e7          	jalr	826(ra) # 800038ac <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000557a:	fd040593          	add	a1,s0,-48
    8000557e:	f5040513          	add	a0,s0,-176
    80005582:	fffff097          	auipc	ra,0xfffff
    80005586:	a50080e7          	jalr	-1456(ra) # 80003fd2 <nameiparent>
    8000558a:	892a                	mv	s2,a0
    8000558c:	cd35                	beqz	a0,80005608 <sys_link+0x112>
  ilock(dp);
    8000558e:	ffffe097          	auipc	ra,0xffffe
    80005592:	258080e7          	jalr	600(ra) # 800037e6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005596:	00092703          	lw	a4,0(s2)
    8000559a:	409c                	lw	a5,0(s1)
    8000559c:	06f71163          	bne	a4,a5,800055fe <sys_link+0x108>
    800055a0:	40d0                	lw	a2,4(s1)
    800055a2:	fd040593          	add	a1,s0,-48
    800055a6:	854a                	mv	a0,s2
    800055a8:	fffff097          	auipc	ra,0xfffff
    800055ac:	95a080e7          	jalr	-1702(ra) # 80003f02 <dirlink>
    800055b0:	04054763          	bltz	a0,800055fe <sys_link+0x108>
  iunlockput(dp);
    800055b4:	854a                	mv	a0,s2
    800055b6:	ffffe097          	auipc	ra,0xffffe
    800055ba:	496080e7          	jalr	1174(ra) # 80003a4c <iunlockput>
  iput(ip);
    800055be:	8526                	mv	a0,s1
    800055c0:	ffffe097          	auipc	ra,0xffffe
    800055c4:	3e4080e7          	jalr	996(ra) # 800039a4 <iput>
  end_op();
    800055c8:	fffff097          	auipc	ra,0xfffff
    800055cc:	c66080e7          	jalr	-922(ra) # 8000422e <end_op>
  return 0;
    800055d0:	4781                	li	a5,0
    800055d2:	64f2                	ld	s1,280(sp)
    800055d4:	6952                	ld	s2,272(sp)
    800055d6:	a0a5                	j	8000563e <sys_link+0x148>
    end_op();
    800055d8:	fffff097          	auipc	ra,0xfffff
    800055dc:	c56080e7          	jalr	-938(ra) # 8000422e <end_op>
    return -1;
    800055e0:	57fd                	li	a5,-1
    800055e2:	64f2                	ld	s1,280(sp)
    800055e4:	a8a9                	j	8000563e <sys_link+0x148>
    iunlockput(ip);
    800055e6:	8526                	mv	a0,s1
    800055e8:	ffffe097          	auipc	ra,0xffffe
    800055ec:	464080e7          	jalr	1124(ra) # 80003a4c <iunlockput>
    end_op();
    800055f0:	fffff097          	auipc	ra,0xfffff
    800055f4:	c3e080e7          	jalr	-962(ra) # 8000422e <end_op>
    return -1;
    800055f8:	57fd                	li	a5,-1
    800055fa:	64f2                	ld	s1,280(sp)
    800055fc:	a089                	j	8000563e <sys_link+0x148>
    iunlockput(dp);
    800055fe:	854a                	mv	a0,s2
    80005600:	ffffe097          	auipc	ra,0xffffe
    80005604:	44c080e7          	jalr	1100(ra) # 80003a4c <iunlockput>
  ilock(ip);
    80005608:	8526                	mv	a0,s1
    8000560a:	ffffe097          	auipc	ra,0xffffe
    8000560e:	1dc080e7          	jalr	476(ra) # 800037e6 <ilock>
  ip->nlink--;
    80005612:	04a4d783          	lhu	a5,74(s1)
    80005616:	37fd                	addw	a5,a5,-1
    80005618:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000561c:	8526                	mv	a0,s1
    8000561e:	ffffe097          	auipc	ra,0xffffe
    80005622:	0fc080e7          	jalr	252(ra) # 8000371a <iupdate>
  iunlockput(ip);
    80005626:	8526                	mv	a0,s1
    80005628:	ffffe097          	auipc	ra,0xffffe
    8000562c:	424080e7          	jalr	1060(ra) # 80003a4c <iunlockput>
  end_op();
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	bfe080e7          	jalr	-1026(ra) # 8000422e <end_op>
  return -1;
    80005638:	57fd                	li	a5,-1
    8000563a:	64f2                	ld	s1,280(sp)
    8000563c:	6952                	ld	s2,272(sp)
}
    8000563e:	853e                	mv	a0,a5
    80005640:	70b2                	ld	ra,296(sp)
    80005642:	7412                	ld	s0,288(sp)
    80005644:	6155                	add	sp,sp,304
    80005646:	8082                	ret

0000000080005648 <sys_unlink>:
{
    80005648:	7151                	add	sp,sp,-240
    8000564a:	f586                	sd	ra,232(sp)
    8000564c:	f1a2                	sd	s0,224(sp)
    8000564e:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005650:	08000613          	li	a2,128
    80005654:	f3040593          	add	a1,s0,-208
    80005658:	4501                	li	a0,0
    8000565a:	ffffd097          	auipc	ra,0xffffd
    8000565e:	628080e7          	jalr	1576(ra) # 80002c82 <argstr>
    80005662:	1a054a63          	bltz	a0,80005816 <sys_unlink+0x1ce>
    80005666:	eda6                	sd	s1,216(sp)
  begin_op();
    80005668:	fffff097          	auipc	ra,0xfffff
    8000566c:	b4c080e7          	jalr	-1204(ra) # 800041b4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005670:	fb040593          	add	a1,s0,-80
    80005674:	f3040513          	add	a0,s0,-208
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	95a080e7          	jalr	-1702(ra) # 80003fd2 <nameiparent>
    80005680:	84aa                	mv	s1,a0
    80005682:	cd71                	beqz	a0,8000575e <sys_unlink+0x116>
  ilock(dp);
    80005684:	ffffe097          	auipc	ra,0xffffe
    80005688:	162080e7          	jalr	354(ra) # 800037e6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000568c:	00003597          	auipc	a1,0x3
    80005690:	f9c58593          	add	a1,a1,-100 # 80008628 <etext+0x628>
    80005694:	fb040513          	add	a0,s0,-80
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	640080e7          	jalr	1600(ra) # 80003cd8 <namecmp>
    800056a0:	14050c63          	beqz	a0,800057f8 <sys_unlink+0x1b0>
    800056a4:	00003597          	auipc	a1,0x3
    800056a8:	f8c58593          	add	a1,a1,-116 # 80008630 <etext+0x630>
    800056ac:	fb040513          	add	a0,s0,-80
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	628080e7          	jalr	1576(ra) # 80003cd8 <namecmp>
    800056b8:	14050063          	beqz	a0,800057f8 <sys_unlink+0x1b0>
    800056bc:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800056be:	f2c40613          	add	a2,s0,-212
    800056c2:	fb040593          	add	a1,s0,-80
    800056c6:	8526                	mv	a0,s1
    800056c8:	ffffe097          	auipc	ra,0xffffe
    800056cc:	62a080e7          	jalr	1578(ra) # 80003cf2 <dirlookup>
    800056d0:	892a                	mv	s2,a0
    800056d2:	12050263          	beqz	a0,800057f6 <sys_unlink+0x1ae>
  ilock(ip);
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	110080e7          	jalr	272(ra) # 800037e6 <ilock>
  if(ip->nlink < 1)
    800056de:	04a91783          	lh	a5,74(s2)
    800056e2:	08f05563          	blez	a5,8000576c <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800056e6:	04491703          	lh	a4,68(s2)
    800056ea:	4785                	li	a5,1
    800056ec:	08f70963          	beq	a4,a5,8000577e <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    800056f0:	4641                	li	a2,16
    800056f2:	4581                	li	a1,0
    800056f4:	fc040513          	add	a0,s0,-64
    800056f8:	ffffb097          	auipc	ra,0xffffb
    800056fc:	63c080e7          	jalr	1596(ra) # 80000d34 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005700:	4741                	li	a4,16
    80005702:	f2c42683          	lw	a3,-212(s0)
    80005706:	fc040613          	add	a2,s0,-64
    8000570a:	4581                	li	a1,0
    8000570c:	8526                	mv	a0,s1
    8000570e:	ffffe097          	auipc	ra,0xffffe
    80005712:	4a0080e7          	jalr	1184(ra) # 80003bae <writei>
    80005716:	47c1                	li	a5,16
    80005718:	0af51b63          	bne	a0,a5,800057ce <sys_unlink+0x186>
  if(ip->type == T_DIR){
    8000571c:	04491703          	lh	a4,68(s2)
    80005720:	4785                	li	a5,1
    80005722:	0af70f63          	beq	a4,a5,800057e0 <sys_unlink+0x198>
  iunlockput(dp);
    80005726:	8526                	mv	a0,s1
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	324080e7          	jalr	804(ra) # 80003a4c <iunlockput>
  ip->nlink--;
    80005730:	04a95783          	lhu	a5,74(s2)
    80005734:	37fd                	addw	a5,a5,-1
    80005736:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000573a:	854a                	mv	a0,s2
    8000573c:	ffffe097          	auipc	ra,0xffffe
    80005740:	fde080e7          	jalr	-34(ra) # 8000371a <iupdate>
  iunlockput(ip);
    80005744:	854a                	mv	a0,s2
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	306080e7          	jalr	774(ra) # 80003a4c <iunlockput>
  end_op();
    8000574e:	fffff097          	auipc	ra,0xfffff
    80005752:	ae0080e7          	jalr	-1312(ra) # 8000422e <end_op>
  return 0;
    80005756:	4501                	li	a0,0
    80005758:	64ee                	ld	s1,216(sp)
    8000575a:	694e                	ld	s2,208(sp)
    8000575c:	a84d                	j	8000580e <sys_unlink+0x1c6>
    end_op();
    8000575e:	fffff097          	auipc	ra,0xfffff
    80005762:	ad0080e7          	jalr	-1328(ra) # 8000422e <end_op>
    return -1;
    80005766:	557d                	li	a0,-1
    80005768:	64ee                	ld	s1,216(sp)
    8000576a:	a055                	j	8000580e <sys_unlink+0x1c6>
    8000576c:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000576e:	00003517          	auipc	a0,0x3
    80005772:	eca50513          	add	a0,a0,-310 # 80008638 <etext+0x638>
    80005776:	ffffb097          	auipc	ra,0xffffb
    8000577a:	dea080e7          	jalr	-534(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000577e:	04c92703          	lw	a4,76(s2)
    80005782:	02000793          	li	a5,32
    80005786:	f6e7f5e3          	bgeu	a5,a4,800056f0 <sys_unlink+0xa8>
    8000578a:	e5ce                	sd	s3,200(sp)
    8000578c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005790:	4741                	li	a4,16
    80005792:	86ce                	mv	a3,s3
    80005794:	f1840613          	add	a2,s0,-232
    80005798:	4581                	li	a1,0
    8000579a:	854a                	mv	a0,s2
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	302080e7          	jalr	770(ra) # 80003a9e <readi>
    800057a4:	47c1                	li	a5,16
    800057a6:	00f51c63          	bne	a0,a5,800057be <sys_unlink+0x176>
    if(de.inum != 0)
    800057aa:	f1845783          	lhu	a5,-232(s0)
    800057ae:	e7b5                	bnez	a5,8000581a <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057b0:	29c1                	addw	s3,s3,16
    800057b2:	04c92783          	lw	a5,76(s2)
    800057b6:	fcf9ede3          	bltu	s3,a5,80005790 <sys_unlink+0x148>
    800057ba:	69ae                	ld	s3,200(sp)
    800057bc:	bf15                	j	800056f0 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    800057be:	00003517          	auipc	a0,0x3
    800057c2:	e9250513          	add	a0,a0,-366 # 80008650 <etext+0x650>
    800057c6:	ffffb097          	auipc	ra,0xffffb
    800057ca:	d9a080e7          	jalr	-614(ra) # 80000560 <panic>
    800057ce:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800057d0:	00003517          	auipc	a0,0x3
    800057d4:	e9850513          	add	a0,a0,-360 # 80008668 <etext+0x668>
    800057d8:	ffffb097          	auipc	ra,0xffffb
    800057dc:	d88080e7          	jalr	-632(ra) # 80000560 <panic>
    dp->nlink--;
    800057e0:	04a4d783          	lhu	a5,74(s1)
    800057e4:	37fd                	addw	a5,a5,-1
    800057e6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057ea:	8526                	mv	a0,s1
    800057ec:	ffffe097          	auipc	ra,0xffffe
    800057f0:	f2e080e7          	jalr	-210(ra) # 8000371a <iupdate>
    800057f4:	bf0d                	j	80005726 <sys_unlink+0xde>
    800057f6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800057f8:	8526                	mv	a0,s1
    800057fa:	ffffe097          	auipc	ra,0xffffe
    800057fe:	252080e7          	jalr	594(ra) # 80003a4c <iunlockput>
  end_op();
    80005802:	fffff097          	auipc	ra,0xfffff
    80005806:	a2c080e7          	jalr	-1492(ra) # 8000422e <end_op>
  return -1;
    8000580a:	557d                	li	a0,-1
    8000580c:	64ee                	ld	s1,216(sp)
}
    8000580e:	70ae                	ld	ra,232(sp)
    80005810:	740e                	ld	s0,224(sp)
    80005812:	616d                	add	sp,sp,240
    80005814:	8082                	ret
    return -1;
    80005816:	557d                	li	a0,-1
    80005818:	bfdd                	j	8000580e <sys_unlink+0x1c6>
    iunlockput(ip);
    8000581a:	854a                	mv	a0,s2
    8000581c:	ffffe097          	auipc	ra,0xffffe
    80005820:	230080e7          	jalr	560(ra) # 80003a4c <iunlockput>
    goto bad;
    80005824:	694e                	ld	s2,208(sp)
    80005826:	69ae                	ld	s3,200(sp)
    80005828:	bfc1                	j	800057f8 <sys_unlink+0x1b0>

000000008000582a <sys_open>:

uint64
sys_open(void)
{
    8000582a:	7131                	add	sp,sp,-192
    8000582c:	fd06                	sd	ra,184(sp)
    8000582e:	f922                	sd	s0,176(sp)
    80005830:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005832:	f4c40593          	add	a1,s0,-180
    80005836:	4505                	li	a0,1
    80005838:	ffffd097          	auipc	ra,0xffffd
    8000583c:	40a080e7          	jalr	1034(ra) # 80002c42 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005840:	08000613          	li	a2,128
    80005844:	f5040593          	add	a1,s0,-176
    80005848:	4501                	li	a0,0
    8000584a:	ffffd097          	auipc	ra,0xffffd
    8000584e:	438080e7          	jalr	1080(ra) # 80002c82 <argstr>
    80005852:	87aa                	mv	a5,a0
    return -1;
    80005854:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005856:	0a07ce63          	bltz	a5,80005912 <sys_open+0xe8>
    8000585a:	f526                	sd	s1,168(sp)

  begin_op();
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	958080e7          	jalr	-1704(ra) # 800041b4 <begin_op>

  if(omode & O_CREATE){
    80005864:	f4c42783          	lw	a5,-180(s0)
    80005868:	2007f793          	and	a5,a5,512
    8000586c:	cfd5                	beqz	a5,80005928 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000586e:	4681                	li	a3,0
    80005870:	4601                	li	a2,0
    80005872:	4589                	li	a1,2
    80005874:	f5040513          	add	a0,s0,-176
    80005878:	00000097          	auipc	ra,0x0
    8000587c:	95c080e7          	jalr	-1700(ra) # 800051d4 <create>
    80005880:	84aa                	mv	s1,a0
    if(ip == 0){
    80005882:	cd41                	beqz	a0,8000591a <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005884:	04449703          	lh	a4,68(s1)
    80005888:	478d                	li	a5,3
    8000588a:	00f71763          	bne	a4,a5,80005898 <sys_open+0x6e>
    8000588e:	0464d703          	lhu	a4,70(s1)
    80005892:	47a5                	li	a5,9
    80005894:	0ee7e163          	bltu	a5,a4,80005976 <sys_open+0x14c>
    80005898:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000589a:	fffff097          	auipc	ra,0xfffff
    8000589e:	d28080e7          	jalr	-728(ra) # 800045c2 <filealloc>
    800058a2:	892a                	mv	s2,a0
    800058a4:	c97d                	beqz	a0,8000599a <sys_open+0x170>
    800058a6:	ed4e                	sd	s3,152(sp)
    800058a8:	00000097          	auipc	ra,0x0
    800058ac:	8ea080e7          	jalr	-1814(ra) # 80005192 <fdalloc>
    800058b0:	89aa                	mv	s3,a0
    800058b2:	0c054e63          	bltz	a0,8000598e <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058b6:	04449703          	lh	a4,68(s1)
    800058ba:	478d                	li	a5,3
    800058bc:	0ef70c63          	beq	a4,a5,800059b4 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800058c0:	4789                	li	a5,2
    800058c2:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800058c6:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800058ca:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800058ce:	f4c42783          	lw	a5,-180(s0)
    800058d2:	0017c713          	xor	a4,a5,1
    800058d6:	8b05                	and	a4,a4,1
    800058d8:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800058dc:	0037f713          	and	a4,a5,3
    800058e0:	00e03733          	snez	a4,a4
    800058e4:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058e8:	4007f793          	and	a5,a5,1024
    800058ec:	c791                	beqz	a5,800058f8 <sys_open+0xce>
    800058ee:	04449703          	lh	a4,68(s1)
    800058f2:	4789                	li	a5,2
    800058f4:	0cf70763          	beq	a4,a5,800059c2 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    800058f8:	8526                	mv	a0,s1
    800058fa:	ffffe097          	auipc	ra,0xffffe
    800058fe:	fb2080e7          	jalr	-78(ra) # 800038ac <iunlock>
  end_op();
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	92c080e7          	jalr	-1748(ra) # 8000422e <end_op>

  return fd;
    8000590a:	854e                	mv	a0,s3
    8000590c:	74aa                	ld	s1,168(sp)
    8000590e:	790a                	ld	s2,160(sp)
    80005910:	69ea                	ld	s3,152(sp)
}
    80005912:	70ea                	ld	ra,184(sp)
    80005914:	744a                	ld	s0,176(sp)
    80005916:	6129                	add	sp,sp,192
    80005918:	8082                	ret
      end_op();
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	914080e7          	jalr	-1772(ra) # 8000422e <end_op>
      return -1;
    80005922:	557d                	li	a0,-1
    80005924:	74aa                	ld	s1,168(sp)
    80005926:	b7f5                	j	80005912 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005928:	f5040513          	add	a0,s0,-176
    8000592c:	ffffe097          	auipc	ra,0xffffe
    80005930:	688080e7          	jalr	1672(ra) # 80003fb4 <namei>
    80005934:	84aa                	mv	s1,a0
    80005936:	c90d                	beqz	a0,80005968 <sys_open+0x13e>
    ilock(ip);
    80005938:	ffffe097          	auipc	ra,0xffffe
    8000593c:	eae080e7          	jalr	-338(ra) # 800037e6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005940:	04449703          	lh	a4,68(s1)
    80005944:	4785                	li	a5,1
    80005946:	f2f71fe3          	bne	a4,a5,80005884 <sys_open+0x5a>
    8000594a:	f4c42783          	lw	a5,-180(s0)
    8000594e:	d7a9                	beqz	a5,80005898 <sys_open+0x6e>
      iunlockput(ip);
    80005950:	8526                	mv	a0,s1
    80005952:	ffffe097          	auipc	ra,0xffffe
    80005956:	0fa080e7          	jalr	250(ra) # 80003a4c <iunlockput>
      end_op();
    8000595a:	fffff097          	auipc	ra,0xfffff
    8000595e:	8d4080e7          	jalr	-1836(ra) # 8000422e <end_op>
      return -1;
    80005962:	557d                	li	a0,-1
    80005964:	74aa                	ld	s1,168(sp)
    80005966:	b775                	j	80005912 <sys_open+0xe8>
      end_op();
    80005968:	fffff097          	auipc	ra,0xfffff
    8000596c:	8c6080e7          	jalr	-1850(ra) # 8000422e <end_op>
      return -1;
    80005970:	557d                	li	a0,-1
    80005972:	74aa                	ld	s1,168(sp)
    80005974:	bf79                	j	80005912 <sys_open+0xe8>
    iunlockput(ip);
    80005976:	8526                	mv	a0,s1
    80005978:	ffffe097          	auipc	ra,0xffffe
    8000597c:	0d4080e7          	jalr	212(ra) # 80003a4c <iunlockput>
    end_op();
    80005980:	fffff097          	auipc	ra,0xfffff
    80005984:	8ae080e7          	jalr	-1874(ra) # 8000422e <end_op>
    return -1;
    80005988:	557d                	li	a0,-1
    8000598a:	74aa                	ld	s1,168(sp)
    8000598c:	b759                	j	80005912 <sys_open+0xe8>
      fileclose(f);
    8000598e:	854a                	mv	a0,s2
    80005990:	fffff097          	auipc	ra,0xfffff
    80005994:	cee080e7          	jalr	-786(ra) # 8000467e <fileclose>
    80005998:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000599a:	8526                	mv	a0,s1
    8000599c:	ffffe097          	auipc	ra,0xffffe
    800059a0:	0b0080e7          	jalr	176(ra) # 80003a4c <iunlockput>
    end_op();
    800059a4:	fffff097          	auipc	ra,0xfffff
    800059a8:	88a080e7          	jalr	-1910(ra) # 8000422e <end_op>
    return -1;
    800059ac:	557d                	li	a0,-1
    800059ae:	74aa                	ld	s1,168(sp)
    800059b0:	790a                	ld	s2,160(sp)
    800059b2:	b785                	j	80005912 <sys_open+0xe8>
    f->type = FD_DEVICE;
    800059b4:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800059b8:	04649783          	lh	a5,70(s1)
    800059bc:	02f91223          	sh	a5,36(s2)
    800059c0:	b729                	j	800058ca <sys_open+0xa0>
    itrunc(ip);
    800059c2:	8526                	mv	a0,s1
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	f34080e7          	jalr	-204(ra) # 800038f8 <itrunc>
    800059cc:	b735                	j	800058f8 <sys_open+0xce>

00000000800059ce <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800059ce:	7175                	add	sp,sp,-144
    800059d0:	e506                	sd	ra,136(sp)
    800059d2:	e122                	sd	s0,128(sp)
    800059d4:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	7de080e7          	jalr	2014(ra) # 800041b4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800059de:	08000613          	li	a2,128
    800059e2:	f7040593          	add	a1,s0,-144
    800059e6:	4501                	li	a0,0
    800059e8:	ffffd097          	auipc	ra,0xffffd
    800059ec:	29a080e7          	jalr	666(ra) # 80002c82 <argstr>
    800059f0:	02054963          	bltz	a0,80005a22 <sys_mkdir+0x54>
    800059f4:	4681                	li	a3,0
    800059f6:	4601                	li	a2,0
    800059f8:	4585                	li	a1,1
    800059fa:	f7040513          	add	a0,s0,-144
    800059fe:	fffff097          	auipc	ra,0xfffff
    80005a02:	7d6080e7          	jalr	2006(ra) # 800051d4 <create>
    80005a06:	cd11                	beqz	a0,80005a22 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a08:	ffffe097          	auipc	ra,0xffffe
    80005a0c:	044080e7          	jalr	68(ra) # 80003a4c <iunlockput>
  end_op();
    80005a10:	fffff097          	auipc	ra,0xfffff
    80005a14:	81e080e7          	jalr	-2018(ra) # 8000422e <end_op>
  return 0;
    80005a18:	4501                	li	a0,0
}
    80005a1a:	60aa                	ld	ra,136(sp)
    80005a1c:	640a                	ld	s0,128(sp)
    80005a1e:	6149                	add	sp,sp,144
    80005a20:	8082                	ret
    end_op();
    80005a22:	fffff097          	auipc	ra,0xfffff
    80005a26:	80c080e7          	jalr	-2036(ra) # 8000422e <end_op>
    return -1;
    80005a2a:	557d                	li	a0,-1
    80005a2c:	b7fd                	j	80005a1a <sys_mkdir+0x4c>

0000000080005a2e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a2e:	7135                	add	sp,sp,-160
    80005a30:	ed06                	sd	ra,152(sp)
    80005a32:	e922                	sd	s0,144(sp)
    80005a34:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	77e080e7          	jalr	1918(ra) # 800041b4 <begin_op>
  argint(1, &major);
    80005a3e:	f6c40593          	add	a1,s0,-148
    80005a42:	4505                	li	a0,1
    80005a44:	ffffd097          	auipc	ra,0xffffd
    80005a48:	1fe080e7          	jalr	510(ra) # 80002c42 <argint>
  argint(2, &minor);
    80005a4c:	f6840593          	add	a1,s0,-152
    80005a50:	4509                	li	a0,2
    80005a52:	ffffd097          	auipc	ra,0xffffd
    80005a56:	1f0080e7          	jalr	496(ra) # 80002c42 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a5a:	08000613          	li	a2,128
    80005a5e:	f7040593          	add	a1,s0,-144
    80005a62:	4501                	li	a0,0
    80005a64:	ffffd097          	auipc	ra,0xffffd
    80005a68:	21e080e7          	jalr	542(ra) # 80002c82 <argstr>
    80005a6c:	02054b63          	bltz	a0,80005aa2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a70:	f6841683          	lh	a3,-152(s0)
    80005a74:	f6c41603          	lh	a2,-148(s0)
    80005a78:	458d                	li	a1,3
    80005a7a:	f7040513          	add	a0,s0,-144
    80005a7e:	fffff097          	auipc	ra,0xfffff
    80005a82:	756080e7          	jalr	1878(ra) # 800051d4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a86:	cd11                	beqz	a0,80005aa2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a88:	ffffe097          	auipc	ra,0xffffe
    80005a8c:	fc4080e7          	jalr	-60(ra) # 80003a4c <iunlockput>
  end_op();
    80005a90:	ffffe097          	auipc	ra,0xffffe
    80005a94:	79e080e7          	jalr	1950(ra) # 8000422e <end_op>
  return 0;
    80005a98:	4501                	li	a0,0
}
    80005a9a:	60ea                	ld	ra,152(sp)
    80005a9c:	644a                	ld	s0,144(sp)
    80005a9e:	610d                	add	sp,sp,160
    80005aa0:	8082                	ret
    end_op();
    80005aa2:	ffffe097          	auipc	ra,0xffffe
    80005aa6:	78c080e7          	jalr	1932(ra) # 8000422e <end_op>
    return -1;
    80005aaa:	557d                	li	a0,-1
    80005aac:	b7fd                	j	80005a9a <sys_mknod+0x6c>

0000000080005aae <sys_chdir>:

uint64
sys_chdir(void)
{
    80005aae:	7135                	add	sp,sp,-160
    80005ab0:	ed06                	sd	ra,152(sp)
    80005ab2:	e922                	sd	s0,144(sp)
    80005ab4:	e14a                	sd	s2,128(sp)
    80005ab6:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ab8:	ffffc097          	auipc	ra,0xffffc
    80005abc:	f92080e7          	jalr	-110(ra) # 80001a4a <myproc>
    80005ac0:	892a                	mv	s2,a0
  
  begin_op();
    80005ac2:	ffffe097          	auipc	ra,0xffffe
    80005ac6:	6f2080e7          	jalr	1778(ra) # 800041b4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005aca:	08000613          	li	a2,128
    80005ace:	f6040593          	add	a1,s0,-160
    80005ad2:	4501                	li	a0,0
    80005ad4:	ffffd097          	auipc	ra,0xffffd
    80005ad8:	1ae080e7          	jalr	430(ra) # 80002c82 <argstr>
    80005adc:	04054d63          	bltz	a0,80005b36 <sys_chdir+0x88>
    80005ae0:	e526                	sd	s1,136(sp)
    80005ae2:	f6040513          	add	a0,s0,-160
    80005ae6:	ffffe097          	auipc	ra,0xffffe
    80005aea:	4ce080e7          	jalr	1230(ra) # 80003fb4 <namei>
    80005aee:	84aa                	mv	s1,a0
    80005af0:	c131                	beqz	a0,80005b34 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005af2:	ffffe097          	auipc	ra,0xffffe
    80005af6:	cf4080e7          	jalr	-780(ra) # 800037e6 <ilock>
  if(ip->type != T_DIR){
    80005afa:	04449703          	lh	a4,68(s1)
    80005afe:	4785                	li	a5,1
    80005b00:	04f71163          	bne	a4,a5,80005b42 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b04:	8526                	mv	a0,s1
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	da6080e7          	jalr	-602(ra) # 800038ac <iunlock>
  iput(p->cwd);
    80005b0e:	15093503          	ld	a0,336(s2)
    80005b12:	ffffe097          	auipc	ra,0xffffe
    80005b16:	e92080e7          	jalr	-366(ra) # 800039a4 <iput>
  end_op();
    80005b1a:	ffffe097          	auipc	ra,0xffffe
    80005b1e:	714080e7          	jalr	1812(ra) # 8000422e <end_op>
  p->cwd = ip;
    80005b22:	14993823          	sd	s1,336(s2)
  return 0;
    80005b26:	4501                	li	a0,0
    80005b28:	64aa                	ld	s1,136(sp)
}
    80005b2a:	60ea                	ld	ra,152(sp)
    80005b2c:	644a                	ld	s0,144(sp)
    80005b2e:	690a                	ld	s2,128(sp)
    80005b30:	610d                	add	sp,sp,160
    80005b32:	8082                	ret
    80005b34:	64aa                	ld	s1,136(sp)
    end_op();
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	6f8080e7          	jalr	1784(ra) # 8000422e <end_op>
    return -1;
    80005b3e:	557d                	li	a0,-1
    80005b40:	b7ed                	j	80005b2a <sys_chdir+0x7c>
    iunlockput(ip);
    80005b42:	8526                	mv	a0,s1
    80005b44:	ffffe097          	auipc	ra,0xffffe
    80005b48:	f08080e7          	jalr	-248(ra) # 80003a4c <iunlockput>
    end_op();
    80005b4c:	ffffe097          	auipc	ra,0xffffe
    80005b50:	6e2080e7          	jalr	1762(ra) # 8000422e <end_op>
    return -1;
    80005b54:	557d                	li	a0,-1
    80005b56:	64aa                	ld	s1,136(sp)
    80005b58:	bfc9                	j	80005b2a <sys_chdir+0x7c>

0000000080005b5a <sys_exec>:

uint64
sys_exec(void)
{
    80005b5a:	7121                	add	sp,sp,-448
    80005b5c:	ff06                	sd	ra,440(sp)
    80005b5e:	fb22                	sd	s0,432(sp)
    80005b60:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005b62:	e4840593          	add	a1,s0,-440
    80005b66:	4505                	li	a0,1
    80005b68:	ffffd097          	auipc	ra,0xffffd
    80005b6c:	0fa080e7          	jalr	250(ra) # 80002c62 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005b70:	08000613          	li	a2,128
    80005b74:	f5040593          	add	a1,s0,-176
    80005b78:	4501                	li	a0,0
    80005b7a:	ffffd097          	auipc	ra,0xffffd
    80005b7e:	108080e7          	jalr	264(ra) # 80002c82 <argstr>
    80005b82:	87aa                	mv	a5,a0
    return -1;
    80005b84:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005b86:	0e07c263          	bltz	a5,80005c6a <sys_exec+0x110>
    80005b8a:	f726                	sd	s1,424(sp)
    80005b8c:	f34a                	sd	s2,416(sp)
    80005b8e:	ef4e                	sd	s3,408(sp)
    80005b90:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005b92:	10000613          	li	a2,256
    80005b96:	4581                	li	a1,0
    80005b98:	e5040513          	add	a0,s0,-432
    80005b9c:	ffffb097          	auipc	ra,0xffffb
    80005ba0:	198080e7          	jalr	408(ra) # 80000d34 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ba4:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005ba8:	89a6                	mv	s3,s1
    80005baa:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005bac:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005bb0:	00391513          	sll	a0,s2,0x3
    80005bb4:	e4040593          	add	a1,s0,-448
    80005bb8:	e4843783          	ld	a5,-440(s0)
    80005bbc:	953e                	add	a0,a0,a5
    80005bbe:	ffffd097          	auipc	ra,0xffffd
    80005bc2:	fe6080e7          	jalr	-26(ra) # 80002ba4 <fetchaddr>
    80005bc6:	02054a63          	bltz	a0,80005bfa <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005bca:	e4043783          	ld	a5,-448(s0)
    80005bce:	c7b9                	beqz	a5,80005c1c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005bd0:	ffffb097          	auipc	ra,0xffffb
    80005bd4:	f78080e7          	jalr	-136(ra) # 80000b48 <kalloc>
    80005bd8:	85aa                	mv	a1,a0
    80005bda:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005bde:	cd11                	beqz	a0,80005bfa <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005be0:	6605                	lui	a2,0x1
    80005be2:	e4043503          	ld	a0,-448(s0)
    80005be6:	ffffd097          	auipc	ra,0xffffd
    80005bea:	010080e7          	jalr	16(ra) # 80002bf6 <fetchstr>
    80005bee:	00054663          	bltz	a0,80005bfa <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005bf2:	0905                	add	s2,s2,1
    80005bf4:	09a1                	add	s3,s3,8
    80005bf6:	fb491de3          	bne	s2,s4,80005bb0 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bfa:	f5040913          	add	s2,s0,-176
    80005bfe:	6088                	ld	a0,0(s1)
    80005c00:	c125                	beqz	a0,80005c60 <sys_exec+0x106>
    kfree(argv[i]);
    80005c02:	ffffb097          	auipc	ra,0xffffb
    80005c06:	e48080e7          	jalr	-440(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c0a:	04a1                	add	s1,s1,8
    80005c0c:	ff2499e3          	bne	s1,s2,80005bfe <sys_exec+0xa4>
  return -1;
    80005c10:	557d                	li	a0,-1
    80005c12:	74ba                	ld	s1,424(sp)
    80005c14:	791a                	ld	s2,416(sp)
    80005c16:	69fa                	ld	s3,408(sp)
    80005c18:	6a5a                	ld	s4,400(sp)
    80005c1a:	a881                	j	80005c6a <sys_exec+0x110>
      argv[i] = 0;
    80005c1c:	0009079b          	sext.w	a5,s2
    80005c20:	078e                	sll	a5,a5,0x3
    80005c22:	fd078793          	add	a5,a5,-48
    80005c26:	97a2                	add	a5,a5,s0
    80005c28:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005c2c:	e5040593          	add	a1,s0,-432
    80005c30:	f5040513          	add	a0,s0,-176
    80005c34:	fffff097          	auipc	ra,0xfffff
    80005c38:	120080e7          	jalr	288(ra) # 80004d54 <exec>
    80005c3c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c3e:	f5040993          	add	s3,s0,-176
    80005c42:	6088                	ld	a0,0(s1)
    80005c44:	c901                	beqz	a0,80005c54 <sys_exec+0xfa>
    kfree(argv[i]);
    80005c46:	ffffb097          	auipc	ra,0xffffb
    80005c4a:	e04080e7          	jalr	-508(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c4e:	04a1                	add	s1,s1,8
    80005c50:	ff3499e3          	bne	s1,s3,80005c42 <sys_exec+0xe8>
  return ret;
    80005c54:	854a                	mv	a0,s2
    80005c56:	74ba                	ld	s1,424(sp)
    80005c58:	791a                	ld	s2,416(sp)
    80005c5a:	69fa                	ld	s3,408(sp)
    80005c5c:	6a5a                	ld	s4,400(sp)
    80005c5e:	a031                	j	80005c6a <sys_exec+0x110>
  return -1;
    80005c60:	557d                	li	a0,-1
    80005c62:	74ba                	ld	s1,424(sp)
    80005c64:	791a                	ld	s2,416(sp)
    80005c66:	69fa                	ld	s3,408(sp)
    80005c68:	6a5a                	ld	s4,400(sp)
}
    80005c6a:	70fa                	ld	ra,440(sp)
    80005c6c:	745a                	ld	s0,432(sp)
    80005c6e:	6139                	add	sp,sp,448
    80005c70:	8082                	ret

0000000080005c72 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c72:	7139                	add	sp,sp,-64
    80005c74:	fc06                	sd	ra,56(sp)
    80005c76:	f822                	sd	s0,48(sp)
    80005c78:	f426                	sd	s1,40(sp)
    80005c7a:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c7c:	ffffc097          	auipc	ra,0xffffc
    80005c80:	dce080e7          	jalr	-562(ra) # 80001a4a <myproc>
    80005c84:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005c86:	fd840593          	add	a1,s0,-40
    80005c8a:	4501                	li	a0,0
    80005c8c:	ffffd097          	auipc	ra,0xffffd
    80005c90:	fd6080e7          	jalr	-42(ra) # 80002c62 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005c94:	fc840593          	add	a1,s0,-56
    80005c98:	fd040513          	add	a0,s0,-48
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	d50080e7          	jalr	-688(ra) # 800049ec <pipealloc>
    return -1;
    80005ca4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ca6:	0c054463          	bltz	a0,80005d6e <sys_pipe+0xfc>
  fd0 = -1;
    80005caa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005cae:	fd043503          	ld	a0,-48(s0)
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	4e0080e7          	jalr	1248(ra) # 80005192 <fdalloc>
    80005cba:	fca42223          	sw	a0,-60(s0)
    80005cbe:	08054b63          	bltz	a0,80005d54 <sys_pipe+0xe2>
    80005cc2:	fc843503          	ld	a0,-56(s0)
    80005cc6:	fffff097          	auipc	ra,0xfffff
    80005cca:	4cc080e7          	jalr	1228(ra) # 80005192 <fdalloc>
    80005cce:	fca42023          	sw	a0,-64(s0)
    80005cd2:	06054863          	bltz	a0,80005d42 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cd6:	4691                	li	a3,4
    80005cd8:	fc440613          	add	a2,s0,-60
    80005cdc:	fd843583          	ld	a1,-40(s0)
    80005ce0:	68a8                	ld	a0,80(s1)
    80005ce2:	ffffc097          	auipc	ra,0xffffc
    80005ce6:	a00080e7          	jalr	-1536(ra) # 800016e2 <copyout>
    80005cea:	02054063          	bltz	a0,80005d0a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005cee:	4691                	li	a3,4
    80005cf0:	fc040613          	add	a2,s0,-64
    80005cf4:	fd843583          	ld	a1,-40(s0)
    80005cf8:	0591                	add	a1,a1,4
    80005cfa:	68a8                	ld	a0,80(s1)
    80005cfc:	ffffc097          	auipc	ra,0xffffc
    80005d00:	9e6080e7          	jalr	-1562(ra) # 800016e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d04:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d06:	06055463          	bgez	a0,80005d6e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005d0a:	fc442783          	lw	a5,-60(s0)
    80005d0e:	07e9                	add	a5,a5,26
    80005d10:	078e                	sll	a5,a5,0x3
    80005d12:	97a6                	add	a5,a5,s1
    80005d14:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d18:	fc042783          	lw	a5,-64(s0)
    80005d1c:	07e9                	add	a5,a5,26
    80005d1e:	078e                	sll	a5,a5,0x3
    80005d20:	94be                	add	s1,s1,a5
    80005d22:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d26:	fd043503          	ld	a0,-48(s0)
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	954080e7          	jalr	-1708(ra) # 8000467e <fileclose>
    fileclose(wf);
    80005d32:	fc843503          	ld	a0,-56(s0)
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	948080e7          	jalr	-1720(ra) # 8000467e <fileclose>
    return -1;
    80005d3e:	57fd                	li	a5,-1
    80005d40:	a03d                	j	80005d6e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005d42:	fc442783          	lw	a5,-60(s0)
    80005d46:	0007c763          	bltz	a5,80005d54 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005d4a:	07e9                	add	a5,a5,26
    80005d4c:	078e                	sll	a5,a5,0x3
    80005d4e:	97a6                	add	a5,a5,s1
    80005d50:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005d54:	fd043503          	ld	a0,-48(s0)
    80005d58:	fffff097          	auipc	ra,0xfffff
    80005d5c:	926080e7          	jalr	-1754(ra) # 8000467e <fileclose>
    fileclose(wf);
    80005d60:	fc843503          	ld	a0,-56(s0)
    80005d64:	fffff097          	auipc	ra,0xfffff
    80005d68:	91a080e7          	jalr	-1766(ra) # 8000467e <fileclose>
    return -1;
    80005d6c:	57fd                	li	a5,-1
}
    80005d6e:	853e                	mv	a0,a5
    80005d70:	70e2                	ld	ra,56(sp)
    80005d72:	7442                	ld	s0,48(sp)
    80005d74:	74a2                	ld	s1,40(sp)
    80005d76:	6121                	add	sp,sp,64
    80005d78:	8082                	ret
    80005d7a:	0000                	unimp
    80005d7c:	0000                	unimp
	...

0000000080005d80 <kernelvec>:
    80005d80:	7111                	add	sp,sp,-256
    80005d82:	e006                	sd	ra,0(sp)
    80005d84:	e40a                	sd	sp,8(sp)
    80005d86:	e80e                	sd	gp,16(sp)
    80005d88:	ec12                	sd	tp,24(sp)
    80005d8a:	f016                	sd	t0,32(sp)
    80005d8c:	f41a                	sd	t1,40(sp)
    80005d8e:	f81e                	sd	t2,48(sp)
    80005d90:	fc22                	sd	s0,56(sp)
    80005d92:	e0a6                	sd	s1,64(sp)
    80005d94:	e4aa                	sd	a0,72(sp)
    80005d96:	e8ae                	sd	a1,80(sp)
    80005d98:	ecb2                	sd	a2,88(sp)
    80005d9a:	f0b6                	sd	a3,96(sp)
    80005d9c:	f4ba                	sd	a4,104(sp)
    80005d9e:	f8be                	sd	a5,112(sp)
    80005da0:	fcc2                	sd	a6,120(sp)
    80005da2:	e146                	sd	a7,128(sp)
    80005da4:	e54a                	sd	s2,136(sp)
    80005da6:	e94e                	sd	s3,144(sp)
    80005da8:	ed52                	sd	s4,152(sp)
    80005daa:	f156                	sd	s5,160(sp)
    80005dac:	f55a                	sd	s6,168(sp)
    80005dae:	f95e                	sd	s7,176(sp)
    80005db0:	fd62                	sd	s8,184(sp)
    80005db2:	e1e6                	sd	s9,192(sp)
    80005db4:	e5ea                	sd	s10,200(sp)
    80005db6:	e9ee                	sd	s11,208(sp)
    80005db8:	edf2                	sd	t3,216(sp)
    80005dba:	f1f6                	sd	t4,224(sp)
    80005dbc:	f5fa                	sd	t5,232(sp)
    80005dbe:	f9fe                	sd	t6,240(sp)
    80005dc0:	cb1fc0ef          	jal	80002a70 <kerneltrap>
    80005dc4:	6082                	ld	ra,0(sp)
    80005dc6:	6122                	ld	sp,8(sp)
    80005dc8:	61c2                	ld	gp,16(sp)
    80005dca:	7282                	ld	t0,32(sp)
    80005dcc:	7322                	ld	t1,40(sp)
    80005dce:	73c2                	ld	t2,48(sp)
    80005dd0:	7462                	ld	s0,56(sp)
    80005dd2:	6486                	ld	s1,64(sp)
    80005dd4:	6526                	ld	a0,72(sp)
    80005dd6:	65c6                	ld	a1,80(sp)
    80005dd8:	6666                	ld	a2,88(sp)
    80005dda:	7686                	ld	a3,96(sp)
    80005ddc:	7726                	ld	a4,104(sp)
    80005dde:	77c6                	ld	a5,112(sp)
    80005de0:	7866                	ld	a6,120(sp)
    80005de2:	688a                	ld	a7,128(sp)
    80005de4:	692a                	ld	s2,136(sp)
    80005de6:	69ca                	ld	s3,144(sp)
    80005de8:	6a6a                	ld	s4,152(sp)
    80005dea:	7a8a                	ld	s5,160(sp)
    80005dec:	7b2a                	ld	s6,168(sp)
    80005dee:	7bca                	ld	s7,176(sp)
    80005df0:	7c6a                	ld	s8,184(sp)
    80005df2:	6c8e                	ld	s9,192(sp)
    80005df4:	6d2e                	ld	s10,200(sp)
    80005df6:	6dce                	ld	s11,208(sp)
    80005df8:	6e6e                	ld	t3,216(sp)
    80005dfa:	7e8e                	ld	t4,224(sp)
    80005dfc:	7f2e                	ld	t5,232(sp)
    80005dfe:	7fce                	ld	t6,240(sp)
    80005e00:	6111                	add	sp,sp,256
    80005e02:	10200073          	sret
    80005e06:	00000013          	nop
    80005e0a:	00000013          	nop
    80005e0e:	0001                	nop

0000000080005e10 <timervec>:
    80005e10:	34051573          	csrrw	a0,mscratch,a0
    80005e14:	e10c                	sd	a1,0(a0)
    80005e16:	e510                	sd	a2,8(a0)
    80005e18:	e914                	sd	a3,16(a0)
    80005e1a:	6d0c                	ld	a1,24(a0)
    80005e1c:	7110                	ld	a2,32(a0)
    80005e1e:	6194                	ld	a3,0(a1)
    80005e20:	96b2                	add	a3,a3,a2
    80005e22:	e194                	sd	a3,0(a1)
    80005e24:	4589                	li	a1,2
    80005e26:	14459073          	csrw	sip,a1
    80005e2a:	6914                	ld	a3,16(a0)
    80005e2c:	6510                	ld	a2,8(a0)
    80005e2e:	610c                	ld	a1,0(a0)
    80005e30:	34051573          	csrrw	a0,mscratch,a0
    80005e34:	30200073          	mret
	...

0000000080005e3a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e3a:	1141                	add	sp,sp,-16
    80005e3c:	e422                	sd	s0,8(sp)
    80005e3e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e40:	0c0007b7          	lui	a5,0xc000
    80005e44:	4705                	li	a4,1
    80005e46:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e48:	0c0007b7          	lui	a5,0xc000
    80005e4c:	c3d8                	sw	a4,4(a5)
}
    80005e4e:	6422                	ld	s0,8(sp)
    80005e50:	0141                	add	sp,sp,16
    80005e52:	8082                	ret

0000000080005e54 <plicinithart>:

void
plicinithart(void)
{
    80005e54:	1141                	add	sp,sp,-16
    80005e56:	e406                	sd	ra,8(sp)
    80005e58:	e022                	sd	s0,0(sp)
    80005e5a:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005e5c:	ffffc097          	auipc	ra,0xffffc
    80005e60:	bc2080e7          	jalr	-1086(ra) # 80001a1e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e64:	0085171b          	sllw	a4,a0,0x8
    80005e68:	0c0027b7          	lui	a5,0xc002
    80005e6c:	97ba                	add	a5,a5,a4
    80005e6e:	40200713          	li	a4,1026
    80005e72:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e76:	00d5151b          	sllw	a0,a0,0xd
    80005e7a:	0c2017b7          	lui	a5,0xc201
    80005e7e:	97aa                	add	a5,a5,a0
    80005e80:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005e84:	60a2                	ld	ra,8(sp)
    80005e86:	6402                	ld	s0,0(sp)
    80005e88:	0141                	add	sp,sp,16
    80005e8a:	8082                	ret

0000000080005e8c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e8c:	1141                	add	sp,sp,-16
    80005e8e:	e406                	sd	ra,8(sp)
    80005e90:	e022                	sd	s0,0(sp)
    80005e92:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005e94:	ffffc097          	auipc	ra,0xffffc
    80005e98:	b8a080e7          	jalr	-1142(ra) # 80001a1e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e9c:	00d5151b          	sllw	a0,a0,0xd
    80005ea0:	0c2017b7          	lui	a5,0xc201
    80005ea4:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ea6:	43c8                	lw	a0,4(a5)
    80005ea8:	60a2                	ld	ra,8(sp)
    80005eaa:	6402                	ld	s0,0(sp)
    80005eac:	0141                	add	sp,sp,16
    80005eae:	8082                	ret

0000000080005eb0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005eb0:	1101                	add	sp,sp,-32
    80005eb2:	ec06                	sd	ra,24(sp)
    80005eb4:	e822                	sd	s0,16(sp)
    80005eb6:	e426                	sd	s1,8(sp)
    80005eb8:	1000                	add	s0,sp,32
    80005eba:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ebc:	ffffc097          	auipc	ra,0xffffc
    80005ec0:	b62080e7          	jalr	-1182(ra) # 80001a1e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ec4:	00d5151b          	sllw	a0,a0,0xd
    80005ec8:	0c2017b7          	lui	a5,0xc201
    80005ecc:	97aa                	add	a5,a5,a0
    80005ece:	c3c4                	sw	s1,4(a5)
}
    80005ed0:	60e2                	ld	ra,24(sp)
    80005ed2:	6442                	ld	s0,16(sp)
    80005ed4:	64a2                	ld	s1,8(sp)
    80005ed6:	6105                	add	sp,sp,32
    80005ed8:	8082                	ret

0000000080005eda <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005eda:	1141                	add	sp,sp,-16
    80005edc:	e406                	sd	ra,8(sp)
    80005ede:	e022                	sd	s0,0(sp)
    80005ee0:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005ee2:	479d                	li	a5,7
    80005ee4:	04a7cc63          	blt	a5,a0,80005f3c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005ee8:	0001c797          	auipc	a5,0x1c
    80005eec:	d8878793          	add	a5,a5,-632 # 80021c70 <disk>
    80005ef0:	97aa                	add	a5,a5,a0
    80005ef2:	0187c783          	lbu	a5,24(a5)
    80005ef6:	ebb9                	bnez	a5,80005f4c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ef8:	00451693          	sll	a3,a0,0x4
    80005efc:	0001c797          	auipc	a5,0x1c
    80005f00:	d7478793          	add	a5,a5,-652 # 80021c70 <disk>
    80005f04:	6398                	ld	a4,0(a5)
    80005f06:	9736                	add	a4,a4,a3
    80005f08:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005f0c:	6398                	ld	a4,0(a5)
    80005f0e:	9736                	add	a4,a4,a3
    80005f10:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005f14:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005f18:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005f1c:	97aa                	add	a5,a5,a0
    80005f1e:	4705                	li	a4,1
    80005f20:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005f24:	0001c517          	auipc	a0,0x1c
    80005f28:	d6450513          	add	a0,a0,-668 # 80021c88 <disk+0x18>
    80005f2c:	ffffc097          	auipc	ra,0xffffc
    80005f30:	22c080e7          	jalr	556(ra) # 80002158 <wakeup>
}
    80005f34:	60a2                	ld	ra,8(sp)
    80005f36:	6402                	ld	s0,0(sp)
    80005f38:	0141                	add	sp,sp,16
    80005f3a:	8082                	ret
    panic("free_desc 1");
    80005f3c:	00002517          	auipc	a0,0x2
    80005f40:	73c50513          	add	a0,a0,1852 # 80008678 <etext+0x678>
    80005f44:	ffffa097          	auipc	ra,0xffffa
    80005f48:	61c080e7          	jalr	1564(ra) # 80000560 <panic>
    panic("free_desc 2");
    80005f4c:	00002517          	auipc	a0,0x2
    80005f50:	73c50513          	add	a0,a0,1852 # 80008688 <etext+0x688>
    80005f54:	ffffa097          	auipc	ra,0xffffa
    80005f58:	60c080e7          	jalr	1548(ra) # 80000560 <panic>

0000000080005f5c <virtio_disk_init>:
{
    80005f5c:	1101                	add	sp,sp,-32
    80005f5e:	ec06                	sd	ra,24(sp)
    80005f60:	e822                	sd	s0,16(sp)
    80005f62:	e426                	sd	s1,8(sp)
    80005f64:	e04a                	sd	s2,0(sp)
    80005f66:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f68:	00002597          	auipc	a1,0x2
    80005f6c:	73058593          	add	a1,a1,1840 # 80008698 <etext+0x698>
    80005f70:	0001c517          	auipc	a0,0x1c
    80005f74:	e2850513          	add	a0,a0,-472 # 80021d98 <disk+0x128>
    80005f78:	ffffb097          	auipc	ra,0xffffb
    80005f7c:	c30080e7          	jalr	-976(ra) # 80000ba8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f80:	100017b7          	lui	a5,0x10001
    80005f84:	4398                	lw	a4,0(a5)
    80005f86:	2701                	sext.w	a4,a4
    80005f88:	747277b7          	lui	a5,0x74727
    80005f8c:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f90:	18f71c63          	bne	a4,a5,80006128 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f94:	100017b7          	lui	a5,0x10001
    80005f98:	0791                	add	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005f9a:	439c                	lw	a5,0(a5)
    80005f9c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f9e:	4709                	li	a4,2
    80005fa0:	18e79463          	bne	a5,a4,80006128 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fa4:	100017b7          	lui	a5,0x10001
    80005fa8:	07a1                	add	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005faa:	439c                	lw	a5,0(a5)
    80005fac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005fae:	16e79d63          	bne	a5,a4,80006128 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005fb2:	100017b7          	lui	a5,0x10001
    80005fb6:	47d8                	lw	a4,12(a5)
    80005fb8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fba:	554d47b7          	lui	a5,0x554d4
    80005fbe:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005fc2:	16f71363          	bne	a4,a5,80006128 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fc6:	100017b7          	lui	a5,0x10001
    80005fca:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fce:	4705                	li	a4,1
    80005fd0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fd2:	470d                	li	a4,3
    80005fd4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005fd6:	10001737          	lui	a4,0x10001
    80005fda:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005fdc:	c7ffe737          	lui	a4,0xc7ffe
    80005fe0:	75f70713          	add	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9af>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005fe4:	8ef9                	and	a3,a3,a4
    80005fe6:	10001737          	lui	a4,0x10001
    80005fea:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fec:	472d                	li	a4,11
    80005fee:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ff0:	07078793          	add	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005ff4:	439c                	lw	a5,0(a5)
    80005ff6:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005ffa:	8ba1                	and	a5,a5,8
    80005ffc:	12078e63          	beqz	a5,80006138 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006000:	100017b7          	lui	a5,0x10001
    80006004:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006008:	100017b7          	lui	a5,0x10001
    8000600c:	04478793          	add	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006010:	439c                	lw	a5,0(a5)
    80006012:	2781                	sext.w	a5,a5
    80006014:	12079a63          	bnez	a5,80006148 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006018:	100017b7          	lui	a5,0x10001
    8000601c:	03478793          	add	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006020:	439c                	lw	a5,0(a5)
    80006022:	2781                	sext.w	a5,a5
  if(max == 0)
    80006024:	12078a63          	beqz	a5,80006158 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006028:	471d                	li	a4,7
    8000602a:	12f77f63          	bgeu	a4,a5,80006168 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000602e:	ffffb097          	auipc	ra,0xffffb
    80006032:	b1a080e7          	jalr	-1254(ra) # 80000b48 <kalloc>
    80006036:	0001c497          	auipc	s1,0x1c
    8000603a:	c3a48493          	add	s1,s1,-966 # 80021c70 <disk>
    8000603e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006040:	ffffb097          	auipc	ra,0xffffb
    80006044:	b08080e7          	jalr	-1272(ra) # 80000b48 <kalloc>
    80006048:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000604a:	ffffb097          	auipc	ra,0xffffb
    8000604e:	afe080e7          	jalr	-1282(ra) # 80000b48 <kalloc>
    80006052:	87aa                	mv	a5,a0
    80006054:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006056:	6088                	ld	a0,0(s1)
    80006058:	12050063          	beqz	a0,80006178 <virtio_disk_init+0x21c>
    8000605c:	0001c717          	auipc	a4,0x1c
    80006060:	c1c73703          	ld	a4,-996(a4) # 80021c78 <disk+0x8>
    80006064:	10070a63          	beqz	a4,80006178 <virtio_disk_init+0x21c>
    80006068:	10078863          	beqz	a5,80006178 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    8000606c:	6605                	lui	a2,0x1
    8000606e:	4581                	li	a1,0
    80006070:	ffffb097          	auipc	ra,0xffffb
    80006074:	cc4080e7          	jalr	-828(ra) # 80000d34 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006078:	0001c497          	auipc	s1,0x1c
    8000607c:	bf848493          	add	s1,s1,-1032 # 80021c70 <disk>
    80006080:	6605                	lui	a2,0x1
    80006082:	4581                	li	a1,0
    80006084:	6488                	ld	a0,8(s1)
    80006086:	ffffb097          	auipc	ra,0xffffb
    8000608a:	cae080e7          	jalr	-850(ra) # 80000d34 <memset>
  memset(disk.used, 0, PGSIZE);
    8000608e:	6605                	lui	a2,0x1
    80006090:	4581                	li	a1,0
    80006092:	6888                	ld	a0,16(s1)
    80006094:	ffffb097          	auipc	ra,0xffffb
    80006098:	ca0080e7          	jalr	-864(ra) # 80000d34 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000609c:	100017b7          	lui	a5,0x10001
    800060a0:	4721                	li	a4,8
    800060a2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800060a4:	4098                	lw	a4,0(s1)
    800060a6:	100017b7          	lui	a5,0x10001
    800060aa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800060ae:	40d8                	lw	a4,4(s1)
    800060b0:	100017b7          	lui	a5,0x10001
    800060b4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800060b8:	649c                	ld	a5,8(s1)
    800060ba:	0007869b          	sext.w	a3,a5
    800060be:	10001737          	lui	a4,0x10001
    800060c2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800060c6:	9781                	sra	a5,a5,0x20
    800060c8:	10001737          	lui	a4,0x10001
    800060cc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800060d0:	689c                	ld	a5,16(s1)
    800060d2:	0007869b          	sext.w	a3,a5
    800060d6:	10001737          	lui	a4,0x10001
    800060da:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800060de:	9781                	sra	a5,a5,0x20
    800060e0:	10001737          	lui	a4,0x10001
    800060e4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800060e8:	10001737          	lui	a4,0x10001
    800060ec:	4785                	li	a5,1
    800060ee:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800060f0:	00f48c23          	sb	a5,24(s1)
    800060f4:	00f48ca3          	sb	a5,25(s1)
    800060f8:	00f48d23          	sb	a5,26(s1)
    800060fc:	00f48da3          	sb	a5,27(s1)
    80006100:	00f48e23          	sb	a5,28(s1)
    80006104:	00f48ea3          	sb	a5,29(s1)
    80006108:	00f48f23          	sb	a5,30(s1)
    8000610c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006110:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006114:	100017b7          	lui	a5,0x10001
    80006118:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000611c:	60e2                	ld	ra,24(sp)
    8000611e:	6442                	ld	s0,16(sp)
    80006120:	64a2                	ld	s1,8(sp)
    80006122:	6902                	ld	s2,0(sp)
    80006124:	6105                	add	sp,sp,32
    80006126:	8082                	ret
    panic("could not find virtio disk");
    80006128:	00002517          	auipc	a0,0x2
    8000612c:	58050513          	add	a0,a0,1408 # 800086a8 <etext+0x6a8>
    80006130:	ffffa097          	auipc	ra,0xffffa
    80006134:	430080e7          	jalr	1072(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006138:	00002517          	auipc	a0,0x2
    8000613c:	59050513          	add	a0,a0,1424 # 800086c8 <etext+0x6c8>
    80006140:	ffffa097          	auipc	ra,0xffffa
    80006144:	420080e7          	jalr	1056(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006148:	00002517          	auipc	a0,0x2
    8000614c:	5a050513          	add	a0,a0,1440 # 800086e8 <etext+0x6e8>
    80006150:	ffffa097          	auipc	ra,0xffffa
    80006154:	410080e7          	jalr	1040(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006158:	00002517          	auipc	a0,0x2
    8000615c:	5b050513          	add	a0,a0,1456 # 80008708 <etext+0x708>
    80006160:	ffffa097          	auipc	ra,0xffffa
    80006164:	400080e7          	jalr	1024(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006168:	00002517          	auipc	a0,0x2
    8000616c:	5c050513          	add	a0,a0,1472 # 80008728 <etext+0x728>
    80006170:	ffffa097          	auipc	ra,0xffffa
    80006174:	3f0080e7          	jalr	1008(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006178:	00002517          	auipc	a0,0x2
    8000617c:	5d050513          	add	a0,a0,1488 # 80008748 <etext+0x748>
    80006180:	ffffa097          	auipc	ra,0xffffa
    80006184:	3e0080e7          	jalr	992(ra) # 80000560 <panic>

0000000080006188 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006188:	7159                	add	sp,sp,-112
    8000618a:	f486                	sd	ra,104(sp)
    8000618c:	f0a2                	sd	s0,96(sp)
    8000618e:	eca6                	sd	s1,88(sp)
    80006190:	e8ca                	sd	s2,80(sp)
    80006192:	e4ce                	sd	s3,72(sp)
    80006194:	e0d2                	sd	s4,64(sp)
    80006196:	fc56                	sd	s5,56(sp)
    80006198:	f85a                	sd	s6,48(sp)
    8000619a:	f45e                	sd	s7,40(sp)
    8000619c:	f062                	sd	s8,32(sp)
    8000619e:	ec66                	sd	s9,24(sp)
    800061a0:	1880                	add	s0,sp,112
    800061a2:	8a2a                	mv	s4,a0
    800061a4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061a6:	00c52c83          	lw	s9,12(a0)
    800061aa:	001c9c9b          	sllw	s9,s9,0x1
    800061ae:	1c82                	sll	s9,s9,0x20
    800061b0:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800061b4:	0001c517          	auipc	a0,0x1c
    800061b8:	be450513          	add	a0,a0,-1052 # 80021d98 <disk+0x128>
    800061bc:	ffffb097          	auipc	ra,0xffffb
    800061c0:	a7c080e7          	jalr	-1412(ra) # 80000c38 <acquire>
  for(int i = 0; i < 3; i++){
    800061c4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800061c6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800061c8:	0001cb17          	auipc	s6,0x1c
    800061cc:	aa8b0b13          	add	s6,s6,-1368 # 80021c70 <disk>
  for(int i = 0; i < 3; i++){
    800061d0:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061d2:	0001cc17          	auipc	s8,0x1c
    800061d6:	bc6c0c13          	add	s8,s8,-1082 # 80021d98 <disk+0x128>
    800061da:	a0ad                	j	80006244 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800061dc:	00fb0733          	add	a4,s6,a5
    800061e0:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800061e4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800061e6:	0207c563          	bltz	a5,80006210 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800061ea:	2905                	addw	s2,s2,1
    800061ec:	0611                	add	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800061ee:	05590f63          	beq	s2,s5,8000624c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    800061f2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800061f4:	0001c717          	auipc	a4,0x1c
    800061f8:	a7c70713          	add	a4,a4,-1412 # 80021c70 <disk>
    800061fc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800061fe:	01874683          	lbu	a3,24(a4)
    80006202:	fee9                	bnez	a3,800061dc <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006204:	2785                	addw	a5,a5,1
    80006206:	0705                	add	a4,a4,1
    80006208:	fe979be3          	bne	a5,s1,800061fe <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000620c:	57fd                	li	a5,-1
    8000620e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006210:	03205163          	blez	s2,80006232 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006214:	f9042503          	lw	a0,-112(s0)
    80006218:	00000097          	auipc	ra,0x0
    8000621c:	cc2080e7          	jalr	-830(ra) # 80005eda <free_desc>
      for(int j = 0; j < i; j++)
    80006220:	4785                	li	a5,1
    80006222:	0127d863          	bge	a5,s2,80006232 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006226:	f9442503          	lw	a0,-108(s0)
    8000622a:	00000097          	auipc	ra,0x0
    8000622e:	cb0080e7          	jalr	-848(ra) # 80005eda <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006232:	85e2                	mv	a1,s8
    80006234:	0001c517          	auipc	a0,0x1c
    80006238:	a5450513          	add	a0,a0,-1452 # 80021c88 <disk+0x18>
    8000623c:	ffffc097          	auipc	ra,0xffffc
    80006240:	eb8080e7          	jalr	-328(ra) # 800020f4 <sleep>
  for(int i = 0; i < 3; i++){
    80006244:	f9040613          	add	a2,s0,-112
    80006248:	894e                	mv	s2,s3
    8000624a:	b765                	j	800061f2 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000624c:	f9042503          	lw	a0,-112(s0)
    80006250:	00451693          	sll	a3,a0,0x4

  if(write)
    80006254:	0001c797          	auipc	a5,0x1c
    80006258:	a1c78793          	add	a5,a5,-1508 # 80021c70 <disk>
    8000625c:	00a50713          	add	a4,a0,10
    80006260:	0712                	sll	a4,a4,0x4
    80006262:	973e                	add	a4,a4,a5
    80006264:	01703633          	snez	a2,s7
    80006268:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000626a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000626e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006272:	6398                	ld	a4,0(a5)
    80006274:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006276:	0a868613          	add	a2,a3,168
    8000627a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000627c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000627e:	6390                	ld	a2,0(a5)
    80006280:	00d605b3          	add	a1,a2,a3
    80006284:	4741                	li	a4,16
    80006286:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006288:	4805                	li	a6,1
    8000628a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000628e:	f9442703          	lw	a4,-108(s0)
    80006292:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006296:	0712                	sll	a4,a4,0x4
    80006298:	963a                	add	a2,a2,a4
    8000629a:	058a0593          	add	a1,s4,88
    8000629e:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800062a0:	0007b883          	ld	a7,0(a5)
    800062a4:	9746                	add	a4,a4,a7
    800062a6:	40000613          	li	a2,1024
    800062aa:	c710                	sw	a2,8(a4)
  if(write)
    800062ac:	001bb613          	seqz	a2,s7
    800062b0:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062b4:	00166613          	or	a2,a2,1
    800062b8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800062bc:	f9842583          	lw	a1,-104(s0)
    800062c0:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800062c4:	00250613          	add	a2,a0,2
    800062c8:	0612                	sll	a2,a2,0x4
    800062ca:	963e                	add	a2,a2,a5
    800062cc:	577d                	li	a4,-1
    800062ce:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062d2:	0592                	sll	a1,a1,0x4
    800062d4:	98ae                	add	a7,a7,a1
    800062d6:	03068713          	add	a4,a3,48
    800062da:	973e                	add	a4,a4,a5
    800062dc:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800062e0:	6398                	ld	a4,0(a5)
    800062e2:	972e                	add	a4,a4,a1
    800062e4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062e8:	4689                	li	a3,2
    800062ea:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800062ee:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062f2:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800062f6:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800062fa:	6794                	ld	a3,8(a5)
    800062fc:	0026d703          	lhu	a4,2(a3)
    80006300:	8b1d                	and	a4,a4,7
    80006302:	0706                	sll	a4,a4,0x1
    80006304:	96ba                	add	a3,a3,a4
    80006306:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000630a:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000630e:	6798                	ld	a4,8(a5)
    80006310:	00275783          	lhu	a5,2(a4)
    80006314:	2785                	addw	a5,a5,1
    80006316:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000631a:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000631e:	100017b7          	lui	a5,0x10001
    80006322:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006326:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000632a:	0001c917          	auipc	s2,0x1c
    8000632e:	a6e90913          	add	s2,s2,-1426 # 80021d98 <disk+0x128>
  while(b->disk == 1) {
    80006332:	4485                	li	s1,1
    80006334:	01079c63          	bne	a5,a6,8000634c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006338:	85ca                	mv	a1,s2
    8000633a:	8552                	mv	a0,s4
    8000633c:	ffffc097          	auipc	ra,0xffffc
    80006340:	db8080e7          	jalr	-584(ra) # 800020f4 <sleep>
  while(b->disk == 1) {
    80006344:	004a2783          	lw	a5,4(s4)
    80006348:	fe9788e3          	beq	a5,s1,80006338 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000634c:	f9042903          	lw	s2,-112(s0)
    80006350:	00290713          	add	a4,s2,2
    80006354:	0712                	sll	a4,a4,0x4
    80006356:	0001c797          	auipc	a5,0x1c
    8000635a:	91a78793          	add	a5,a5,-1766 # 80021c70 <disk>
    8000635e:	97ba                	add	a5,a5,a4
    80006360:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006364:	0001c997          	auipc	s3,0x1c
    80006368:	90c98993          	add	s3,s3,-1780 # 80021c70 <disk>
    8000636c:	00491713          	sll	a4,s2,0x4
    80006370:	0009b783          	ld	a5,0(s3)
    80006374:	97ba                	add	a5,a5,a4
    80006376:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000637a:	854a                	mv	a0,s2
    8000637c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006380:	00000097          	auipc	ra,0x0
    80006384:	b5a080e7          	jalr	-1190(ra) # 80005eda <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006388:	8885                	and	s1,s1,1
    8000638a:	f0ed                	bnez	s1,8000636c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000638c:	0001c517          	auipc	a0,0x1c
    80006390:	a0c50513          	add	a0,a0,-1524 # 80021d98 <disk+0x128>
    80006394:	ffffb097          	auipc	ra,0xffffb
    80006398:	958080e7          	jalr	-1704(ra) # 80000cec <release>
}
    8000639c:	70a6                	ld	ra,104(sp)
    8000639e:	7406                	ld	s0,96(sp)
    800063a0:	64e6                	ld	s1,88(sp)
    800063a2:	6946                	ld	s2,80(sp)
    800063a4:	69a6                	ld	s3,72(sp)
    800063a6:	6a06                	ld	s4,64(sp)
    800063a8:	7ae2                	ld	s5,56(sp)
    800063aa:	7b42                	ld	s6,48(sp)
    800063ac:	7ba2                	ld	s7,40(sp)
    800063ae:	7c02                	ld	s8,32(sp)
    800063b0:	6ce2                	ld	s9,24(sp)
    800063b2:	6165                	add	sp,sp,112
    800063b4:	8082                	ret

00000000800063b6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063b6:	1101                	add	sp,sp,-32
    800063b8:	ec06                	sd	ra,24(sp)
    800063ba:	e822                	sd	s0,16(sp)
    800063bc:	e426                	sd	s1,8(sp)
    800063be:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063c0:	0001c497          	auipc	s1,0x1c
    800063c4:	8b048493          	add	s1,s1,-1872 # 80021c70 <disk>
    800063c8:	0001c517          	auipc	a0,0x1c
    800063cc:	9d050513          	add	a0,a0,-1584 # 80021d98 <disk+0x128>
    800063d0:	ffffb097          	auipc	ra,0xffffb
    800063d4:	868080e7          	jalr	-1944(ra) # 80000c38 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063d8:	100017b7          	lui	a5,0x10001
    800063dc:	53b8                	lw	a4,96(a5)
    800063de:	8b0d                	and	a4,a4,3
    800063e0:	100017b7          	lui	a5,0x10001
    800063e4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800063e6:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800063ea:	689c                	ld	a5,16(s1)
    800063ec:	0204d703          	lhu	a4,32(s1)
    800063f0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800063f4:	04f70863          	beq	a4,a5,80006444 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    800063f8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800063fc:	6898                	ld	a4,16(s1)
    800063fe:	0204d783          	lhu	a5,32(s1)
    80006402:	8b9d                	and	a5,a5,7
    80006404:	078e                	sll	a5,a5,0x3
    80006406:	97ba                	add	a5,a5,a4
    80006408:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000640a:	00278713          	add	a4,a5,2
    8000640e:	0712                	sll	a4,a4,0x4
    80006410:	9726                	add	a4,a4,s1
    80006412:	01074703          	lbu	a4,16(a4)
    80006416:	e721                	bnez	a4,8000645e <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006418:	0789                	add	a5,a5,2
    8000641a:	0792                	sll	a5,a5,0x4
    8000641c:	97a6                	add	a5,a5,s1
    8000641e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006420:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006424:	ffffc097          	auipc	ra,0xffffc
    80006428:	d34080e7          	jalr	-716(ra) # 80002158 <wakeup>

    disk.used_idx += 1;
    8000642c:	0204d783          	lhu	a5,32(s1)
    80006430:	2785                	addw	a5,a5,1
    80006432:	17c2                	sll	a5,a5,0x30
    80006434:	93c1                	srl	a5,a5,0x30
    80006436:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000643a:	6898                	ld	a4,16(s1)
    8000643c:	00275703          	lhu	a4,2(a4)
    80006440:	faf71ce3          	bne	a4,a5,800063f8 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006444:	0001c517          	auipc	a0,0x1c
    80006448:	95450513          	add	a0,a0,-1708 # 80021d98 <disk+0x128>
    8000644c:	ffffb097          	auipc	ra,0xffffb
    80006450:	8a0080e7          	jalr	-1888(ra) # 80000cec <release>
}
    80006454:	60e2                	ld	ra,24(sp)
    80006456:	6442                	ld	s0,16(sp)
    80006458:	64a2                	ld	s1,8(sp)
    8000645a:	6105                	add	sp,sp,32
    8000645c:	8082                	ret
      panic("virtio_disk_intr status");
    8000645e:	00002517          	auipc	a0,0x2
    80006462:	30250513          	add	a0,a0,770 # 80008760 <etext+0x760>
    80006466:	ffffa097          	auipc	ra,0xffffa
    8000646a:	0fa080e7          	jalr	250(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	sll	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	sll	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
