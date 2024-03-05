
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	be010113          	add	sp,sp,-1056 # 80008be0 <stack0>
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
    80000054:	a5070713          	add	a4,a4,-1456 # 80008aa0 <timer_scratch>
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
    80000066:	14e78793          	add	a5,a5,334 # 800061b0 <timervec>
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
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc8ef>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	eee78793          	add	a5,a5,-274 # 80000f9a <main>
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
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	add	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    {
        char c;
        if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	6ec080e7          	jalr	1772(ra) # 80002816 <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7f6080e7          	jalr	2038(ra) # 80000930 <uartputc>
    for (i = 0; i < n; i++)
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
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
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
    80000190:	a5450513          	add	a0,a0,-1452 # 80010be0 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	b6c080e7          	jalr	-1172(ra) # 80000d00 <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	a4448493          	add	s1,s1,-1468 # 80010be0 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a4:	00011917          	auipc	s2,0x11
    800001a8:	ad490913          	add	s2,s2,-1324 # 80010c78 <cons+0x98>
    while (n > 0)
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
        while (cons.r == cons.w)
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
            if (killed(myproc()))
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	a4a080e7          	jalr	-1462(ra) # 80001c06 <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	49c080e7          	jalr	1180(ra) # 80002660 <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
            sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	1e6080e7          	jalr	486(ra) # 800023b8 <sleep>
        while (cons.r == cons.w)
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00011717          	auipc	a4,0x11
    800001ec:	9f870713          	add	a4,a4,-1544 # 80010be0 <cons>
    800001f0:	0017869b          	addw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	and	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

        if (c == C('D'))
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
            }
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	add	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	5a6080e7          	jalr	1446(ra) # 800027c0 <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
            break;

        dst++;
    80000228:	0a05                	add	s4,s4,1
        --n;
    8000022a:	39fd                	addw	s3,s3,-1

        if (c == '\n')
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
                release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	9aa50513          	add	a0,a0,-1622 # 80010be0 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	b76080e7          	jalr	-1162(ra) # 80000db4 <release>
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
            if (n < target)
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
                cons.r--;
    80000264:	00011717          	auipc	a4,0x11
    80000268:	a0f72a23          	sw	a5,-1516(a4) # 80010c78 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
    release(&cons.lock);
    8000027a:	00011517          	auipc	a0,0x11
    8000027e:	96650513          	add	a0,a0,-1690 # 80010be0 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	b32080e7          	jalr	-1230(ra) # 80000db4 <release>
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
    if (c == BACKSPACE)
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
        uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	5ae080e7          	jalr	1454(ra) # 80000852 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	add	sp,sp,16
    800002b2:	8082                	ret
        uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	59c080e7          	jalr	1436(ra) # 80000852 <uartputc_sync>
        uartputc_sync(' ');
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	590080e7          	jalr	1424(ra) # 80000852 <uartputc_sync>
        uartputc_sync('\b');
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	586080e7          	jalr	1414(ra) # 80000852 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002d6:	1101                	add	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	add	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002e2:	00011517          	auipc	a0,0x11
    800002e6:	8fe50513          	add	a0,a0,-1794 # 80010be0 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	a16080e7          	jalr	-1514(ra) # 80000d00 <acquire>

    switch (c)
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
    {
    case C('P'): // Print process list.
        procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	564080e7          	jalr	1380(ra) # 8000286c <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    80000310:	00011517          	auipc	a0,0x11
    80000314:	8d050513          	add	a0,a0,-1840 # 80010be0 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	a9c080e7          	jalr	-1380(ra) # 80000db4 <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	add	sp,sp,32
    80000328:	8082                	ret
    switch (c)
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000332:	00011717          	auipc	a4,0x11
    80000336:	8ae70713          	add	a4,a4,-1874 # 80010be0 <cons>
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
    8000035c:	00011797          	auipc	a5,0x11
    80000360:	88478793          	add	a5,a5,-1916 # 80010be0 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	and	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00011797          	auipc	a5,0x11
    8000038e:	8ee7a783          	lw	a5,-1810(a5) # 80010c78 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
        while (cons.e != cons.w &&
    800003a0:	00011717          	auipc	a4,0x11
    800003a4:	84070713          	add	a4,a4,-1984 # 80010be0 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003b0:	00011497          	auipc	s1,0x11
    800003b4:	83048493          	add	s1,s1,-2000 # 80010be0 <cons>
        while (cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003be:	37fd                	addw	a5,a5,-1
    800003c0:	07f7f713          	and	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
            cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
        while (cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
        if (cons.e != cons.w)
    800003f6:	00010717          	auipc	a4,0x10
    800003fa:	7ea70713          	add	a4,a4,2026 # 80010be0 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
            cons.e--;
    8000040a:	37fd                	addw	a5,a5,-1
    8000040c:	00011717          	auipc	a4,0x11
    80000410:	86f72a23          	sw	a5,-1932(a4) # 80010c80 <cons+0xa0>
            consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
            consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	7ae78793          	add	a5,a5,1966 # 80010be0 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	and	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000456:	00011797          	auipc	a5,0x11
    8000045a:	82c7a323          	sw	a2,-2010(a5) # 80010c7c <cons+0x9c>
                wakeup(&cons.r);
    8000045e:	00011517          	auipc	a0,0x11
    80000462:	81a50513          	add	a0,a0,-2022 # 80010c78 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	fb6080e7          	jalr	-74(ra) # 8000241c <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void consoleinit(void)
{
    80000470:	1141                	add	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	add	s0,sp,16
    initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b9858593          	add	a1,a1,-1128 # 80008010 <__func__.1+0x8>
    80000480:	00010517          	auipc	a0,0x10
    80000484:	76050513          	add	a0,a0,1888 # 80010be0 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	7e8080e7          	jalr	2024(ra) # 80000c70 <initlock>

    uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	366080e7          	jalr	870(ra) # 800007f6 <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000498:	00021797          	auipc	a5,0x21
    8000049c:	8e078793          	add	a5,a5,-1824 # 80020d78 <devsw>
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

    if (sign && (sign = xx < 0))
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
    do
    {
        buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	3aa60613          	add	a2,a2,938 # 80008880 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	sll	a5,a5,0x20
    800004e8:	9381                	srl	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	add	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

    if (sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
        buf[i++] = '-';
    80000506:	fe070793          	add	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addw	a4,a6,2

    while (--i >= 0)
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
    while (--i >= 0)
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
    if (sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
        x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    if (locking)
        release(&pr.lock);
}

void panic(char *s, ...)
{
    80000560:	711d                	add	sp,sp,-96
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	add	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
    8000056c:	e40c                	sd	a1,8(s0)
    8000056e:	e810                	sd	a2,16(s0)
    80000570:	ec14                	sd	a3,24(s0)
    80000572:	f018                	sd	a4,32(s0)
    80000574:	f41c                	sd	a5,40(s0)
    80000576:	03043823          	sd	a6,48(s0)
    8000057a:	03143c23          	sd	a7,56(s0)
    pr.locking = 0;
    8000057e:	00010797          	auipc	a5,0x10
    80000582:	7207a123          	sw	zero,1826(a5) # 80010ca0 <pr+0x18>
    printf("panic: ");
    80000586:	00008517          	auipc	a0,0x8
    8000058a:	a9250513          	add	a0,a0,-1390 # 80008018 <__func__.1+0x10>
    8000058e:	00000097          	auipc	ra,0x0
    80000592:	02e080e7          	jalr	46(ra) # 800005bc <printf>
    printf(s);
    80000596:	8526                	mv	a0,s1
    80000598:	00000097          	auipc	ra,0x0
    8000059c:	024080e7          	jalr	36(ra) # 800005bc <printf>
    printf("\n");
    800005a0:	00008517          	auipc	a0,0x8
    800005a4:	a8050513          	add	a0,a0,-1408 # 80008020 <__func__.1+0x18>
    800005a8:	00000097          	auipc	ra,0x0
    800005ac:	014080e7          	jalr	20(ra) # 800005bc <printf>
    panicked = 1; // freeze uart output from other CPUs
    800005b0:	4785                	li	a5,1
    800005b2:	00008717          	auipc	a4,0x8
    800005b6:	48f72f23          	sw	a5,1182(a4) # 80008a50 <panicked>
    for (;;)
    800005ba:	a001                	j	800005ba <panic+0x5a>

00000000800005bc <printf>:
{
    800005bc:	7131                	add	sp,sp,-192
    800005be:	fc86                	sd	ra,120(sp)
    800005c0:	f8a2                	sd	s0,112(sp)
    800005c2:	e8d2                	sd	s4,80(sp)
    800005c4:	f06a                	sd	s10,32(sp)
    800005c6:	0100                	add	s0,sp,128
    800005c8:	8a2a                	mv	s4,a0
    800005ca:	e40c                	sd	a1,8(s0)
    800005cc:	e810                	sd	a2,16(s0)
    800005ce:	ec14                	sd	a3,24(s0)
    800005d0:	f018                	sd	a4,32(s0)
    800005d2:	f41c                	sd	a5,40(s0)
    800005d4:	03043823          	sd	a6,48(s0)
    800005d8:	03143c23          	sd	a7,56(s0)
    locking = pr.locking;
    800005dc:	00010d17          	auipc	s10,0x10
    800005e0:	6c4d2d03          	lw	s10,1732(s10) # 80010ca0 <pr+0x18>
    if (locking)
    800005e4:	040d1463          	bnez	s10,8000062c <printf+0x70>
    if (fmt == 0)
    800005e8:	040a0b63          	beqz	s4,8000063e <printf+0x82>
    va_start(ap, fmt);
    800005ec:	00840793          	add	a5,s0,8
    800005f0:	f8f43423          	sd	a5,-120(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005f4:	000a4503          	lbu	a0,0(s4)
    800005f8:	18050b63          	beqz	a0,8000078e <printf+0x1d2>
    800005fc:	f4a6                	sd	s1,104(sp)
    800005fe:	f0ca                	sd	s2,96(sp)
    80000600:	ecce                	sd	s3,88(sp)
    80000602:	e4d6                	sd	s5,72(sp)
    80000604:	e0da                	sd	s6,64(sp)
    80000606:	fc5e                	sd	s7,56(sp)
    80000608:	f862                	sd	s8,48(sp)
    8000060a:	f466                	sd	s9,40(sp)
    8000060c:	ec6e                	sd	s11,24(sp)
    8000060e:	4981                	li	s3,0
        if (c != '%')
    80000610:	02500b13          	li	s6,37
        switch (c)
    80000614:	07000b93          	li	s7,112
    consputc('x');
    80000618:	4cc1                	li	s9,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000061a:	00008a97          	auipc	s5,0x8
    8000061e:	266a8a93          	add	s5,s5,614 # 80008880 <digits>
        switch (c)
    80000622:	07300c13          	li	s8,115
    80000626:	06400d93          	li	s11,100
    8000062a:	a0b1                	j	80000676 <printf+0xba>
        acquire(&pr.lock);
    8000062c:	00010517          	auipc	a0,0x10
    80000630:	65c50513          	add	a0,a0,1628 # 80010c88 <pr>
    80000634:	00000097          	auipc	ra,0x0
    80000638:	6cc080e7          	jalr	1740(ra) # 80000d00 <acquire>
    8000063c:	b775                	j	800005e8 <printf+0x2c>
    8000063e:	f4a6                	sd	s1,104(sp)
    80000640:	f0ca                	sd	s2,96(sp)
    80000642:	ecce                	sd	s3,88(sp)
    80000644:	e4d6                	sd	s5,72(sp)
    80000646:	e0da                	sd	s6,64(sp)
    80000648:	fc5e                	sd	s7,56(sp)
    8000064a:	f862                	sd	s8,48(sp)
    8000064c:	f466                	sd	s9,40(sp)
    8000064e:	ec6e                	sd	s11,24(sp)
        panic("null fmt");
    80000650:	00008517          	auipc	a0,0x8
    80000654:	9e050513          	add	a0,a0,-1568 # 80008030 <__func__.1+0x28>
    80000658:	00000097          	auipc	ra,0x0
    8000065c:	f08080e7          	jalr	-248(ra) # 80000560 <panic>
            consputc(c);
    80000660:	00000097          	auipc	ra,0x0
    80000664:	c34080e7          	jalr	-972(ra) # 80000294 <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000668:	2985                	addw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c503          	lbu	a0,0(a5)
    80000672:	10050563          	beqz	a0,8000077c <printf+0x1c0>
        if (c != '%')
    80000676:	ff6515e3          	bne	a0,s6,80000660 <printf+0xa4>
        c = fmt[++i] & 0xff;
    8000067a:	2985                	addw	s3,s3,1
    8000067c:	013a07b3          	add	a5,s4,s3
    80000680:	0007c783          	lbu	a5,0(a5)
    80000684:	0007849b          	sext.w	s1,a5
        if (c == 0)
    80000688:	10078b63          	beqz	a5,8000079e <printf+0x1e2>
        switch (c)
    8000068c:	05778a63          	beq	a5,s7,800006e0 <printf+0x124>
    80000690:	02fbf663          	bgeu	s7,a5,800006bc <printf+0x100>
    80000694:	09878863          	beq	a5,s8,80000724 <printf+0x168>
    80000698:	07800713          	li	a4,120
    8000069c:	0ce79563          	bne	a5,a4,80000766 <printf+0x1aa>
            printint(va_arg(ap, int), 16, 1);
    800006a0:	f8843783          	ld	a5,-120(s0)
    800006a4:	00878713          	add	a4,a5,8
    800006a8:	f8e43423          	sd	a4,-120(s0)
    800006ac:	4605                	li	a2,1
    800006ae:	85e6                	mv	a1,s9
    800006b0:	4388                	lw	a0,0(a5)
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	e0a080e7          	jalr	-502(ra) # 800004bc <printint>
            break;
    800006ba:	b77d                	j	80000668 <printf+0xac>
        switch (c)
    800006bc:	09678f63          	beq	a5,s6,8000075a <printf+0x19e>
    800006c0:	0bb79363          	bne	a5,s11,80000766 <printf+0x1aa>
            printint(va_arg(ap, int), 10, 1);
    800006c4:	f8843783          	ld	a5,-120(s0)
    800006c8:	00878713          	add	a4,a5,8
    800006cc:	f8e43423          	sd	a4,-120(s0)
    800006d0:	4605                	li	a2,1
    800006d2:	45a9                	li	a1,10
    800006d4:	4388                	lw	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	de6080e7          	jalr	-538(ra) # 800004bc <printint>
            break;
    800006de:	b769                	j	80000668 <printf+0xac>
            printptr(va_arg(ap, uint64));
    800006e0:	f8843783          	ld	a5,-120(s0)
    800006e4:	00878713          	add	a4,a5,8
    800006e8:	f8e43423          	sd	a4,-120(s0)
    800006ec:	0007b903          	ld	s2,0(a5)
    consputc('0');
    800006f0:	03000513          	li	a0,48
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	ba0080e7          	jalr	-1120(ra) # 80000294 <consputc>
    consputc('x');
    800006fc:	07800513          	li	a0,120
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b94080e7          	jalr	-1132(ra) # 80000294 <consputc>
    80000708:	84e6                	mv	s1,s9
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000070a:	03c95793          	srl	a5,s2,0x3c
    8000070e:	97d6                	add	a5,a5,s5
    80000710:	0007c503          	lbu	a0,0(a5)
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b80080e7          	jalr	-1152(ra) # 80000294 <consputc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000071c:	0912                	sll	s2,s2,0x4
    8000071e:	34fd                	addw	s1,s1,-1
    80000720:	f4ed                	bnez	s1,8000070a <printf+0x14e>
    80000722:	b799                	j	80000668 <printf+0xac>
            if ((s = va_arg(ap, char *)) == 0)
    80000724:	f8843783          	ld	a5,-120(s0)
    80000728:	00878713          	add	a4,a5,8
    8000072c:	f8e43423          	sd	a4,-120(s0)
    80000730:	6384                	ld	s1,0(a5)
    80000732:	cc89                	beqz	s1,8000074c <printf+0x190>
            for (; *s; s++)
    80000734:	0004c503          	lbu	a0,0(s1)
    80000738:	d905                	beqz	a0,80000668 <printf+0xac>
                consputc(*s);
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b5a080e7          	jalr	-1190(ra) # 80000294 <consputc>
            for (; *s; s++)
    80000742:	0485                	add	s1,s1,1
    80000744:	0004c503          	lbu	a0,0(s1)
    80000748:	f96d                	bnez	a0,8000073a <printf+0x17e>
    8000074a:	bf39                	j	80000668 <printf+0xac>
                s = "(null)";
    8000074c:	00008497          	auipc	s1,0x8
    80000750:	8dc48493          	add	s1,s1,-1828 # 80008028 <__func__.1+0x20>
            for (; *s; s++)
    80000754:	02800513          	li	a0,40
    80000758:	b7cd                	j	8000073a <printf+0x17e>
            consputc('%');
    8000075a:	855a                	mv	a0,s6
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	b38080e7          	jalr	-1224(ra) # 80000294 <consputc>
            break;
    80000764:	b711                	j	80000668 <printf+0xac>
            consputc('%');
    80000766:	855a                	mv	a0,s6
    80000768:	00000097          	auipc	ra,0x0
    8000076c:	b2c080e7          	jalr	-1236(ra) # 80000294 <consputc>
            consputc(c);
    80000770:	8526                	mv	a0,s1
    80000772:	00000097          	auipc	ra,0x0
    80000776:	b22080e7          	jalr	-1246(ra) # 80000294 <consputc>
            break;
    8000077a:	b5fd                	j	80000668 <printf+0xac>
    8000077c:	74a6                	ld	s1,104(sp)
    8000077e:	7906                	ld	s2,96(sp)
    80000780:	69e6                	ld	s3,88(sp)
    80000782:	6aa6                	ld	s5,72(sp)
    80000784:	6b06                	ld	s6,64(sp)
    80000786:	7be2                	ld	s7,56(sp)
    80000788:	7c42                	ld	s8,48(sp)
    8000078a:	7ca2                	ld	s9,40(sp)
    8000078c:	6de2                	ld	s11,24(sp)
    if (locking)
    8000078e:	020d1263          	bnez	s10,800007b2 <printf+0x1f6>
}
    80000792:	70e6                	ld	ra,120(sp)
    80000794:	7446                	ld	s0,112(sp)
    80000796:	6a46                	ld	s4,80(sp)
    80000798:	7d02                	ld	s10,32(sp)
    8000079a:	6129                	add	sp,sp,192
    8000079c:	8082                	ret
    8000079e:	74a6                	ld	s1,104(sp)
    800007a0:	7906                	ld	s2,96(sp)
    800007a2:	69e6                	ld	s3,88(sp)
    800007a4:	6aa6                	ld	s5,72(sp)
    800007a6:	6b06                	ld	s6,64(sp)
    800007a8:	7be2                	ld	s7,56(sp)
    800007aa:	7c42                	ld	s8,48(sp)
    800007ac:	7ca2                	ld	s9,40(sp)
    800007ae:	6de2                	ld	s11,24(sp)
    800007b0:	bff9                	j	8000078e <printf+0x1d2>
        release(&pr.lock);
    800007b2:	00010517          	auipc	a0,0x10
    800007b6:	4d650513          	add	a0,a0,1238 # 80010c88 <pr>
    800007ba:	00000097          	auipc	ra,0x0
    800007be:	5fa080e7          	jalr	1530(ra) # 80000db4 <release>
}
    800007c2:	bfc1                	j	80000792 <printf+0x1d6>

00000000800007c4 <printfinit>:
        ;
}

void printfinit(void)
{
    800007c4:	1101                	add	sp,sp,-32
    800007c6:	ec06                	sd	ra,24(sp)
    800007c8:	e822                	sd	s0,16(sp)
    800007ca:	e426                	sd	s1,8(sp)
    800007cc:	1000                	add	s0,sp,32
    initlock(&pr.lock, "pr");
    800007ce:	00010497          	auipc	s1,0x10
    800007d2:	4ba48493          	add	s1,s1,1210 # 80010c88 <pr>
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	86a58593          	add	a1,a1,-1942 # 80008040 <__func__.1+0x38>
    800007de:	8526                	mv	a0,s1
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	490080e7          	jalr	1168(ra) # 80000c70 <initlock>
    pr.locking = 1;
    800007e8:	4785                	li	a5,1
    800007ea:	cc9c                	sw	a5,24(s1)
}
    800007ec:	60e2                	ld	ra,24(sp)
    800007ee:	6442                	ld	s0,16(sp)
    800007f0:	64a2                	ld	s1,8(sp)
    800007f2:	6105                	add	sp,sp,32
    800007f4:	8082                	ret

00000000800007f6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007f6:	1141                	add	sp,sp,-16
    800007f8:	e406                	sd	ra,8(sp)
    800007fa:	e022                	sd	s0,0(sp)
    800007fc:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007fe:	100007b7          	lui	a5,0x10000
    80000802:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000806:	10000737          	lui	a4,0x10000
    8000080a:	f8000693          	li	a3,-128
    8000080e:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000812:	468d                	li	a3,3
    80000814:	10000637          	lui	a2,0x10000
    80000818:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000081c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000820:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000824:	10000737          	lui	a4,0x10000
    80000828:	461d                	li	a2,7
    8000082a:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000082e:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000832:	00008597          	auipc	a1,0x8
    80000836:	81658593          	add	a1,a1,-2026 # 80008048 <__func__.1+0x40>
    8000083a:	00010517          	auipc	a0,0x10
    8000083e:	46e50513          	add	a0,a0,1134 # 80010ca8 <uart_tx_lock>
    80000842:	00000097          	auipc	ra,0x0
    80000846:	42e080e7          	jalr	1070(ra) # 80000c70 <initlock>
}
    8000084a:	60a2                	ld	ra,8(sp)
    8000084c:	6402                	ld	s0,0(sp)
    8000084e:	0141                	add	sp,sp,16
    80000850:	8082                	ret

0000000080000852 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000852:	1101                	add	sp,sp,-32
    80000854:	ec06                	sd	ra,24(sp)
    80000856:	e822                	sd	s0,16(sp)
    80000858:	e426                	sd	s1,8(sp)
    8000085a:	1000                	add	s0,sp,32
    8000085c:	84aa                	mv	s1,a0
  push_off();
    8000085e:	00000097          	auipc	ra,0x0
    80000862:	456080e7          	jalr	1110(ra) # 80000cb4 <push_off>

  if(panicked){
    80000866:	00008797          	auipc	a5,0x8
    8000086a:	1ea7a783          	lw	a5,490(a5) # 80008a50 <panicked>
    8000086e:	eb85                	bnez	a5,8000089e <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000870:	10000737          	lui	a4,0x10000
    80000874:	0715                	add	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000876:	00074783          	lbu	a5,0(a4)
    8000087a:	0207f793          	and	a5,a5,32
    8000087e:	dfe5                	beqz	a5,80000876 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000880:	0ff4f513          	zext.b	a0,s1
    80000884:	100007b7          	lui	a5,0x10000
    80000888:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088c:	00000097          	auipc	ra,0x0
    80000890:	4c8080e7          	jalr	1224(ra) # 80000d54 <pop_off>
}
    80000894:	60e2                	ld	ra,24(sp)
    80000896:	6442                	ld	s0,16(sp)
    80000898:	64a2                	ld	s1,8(sp)
    8000089a:	6105                	add	sp,sp,32
    8000089c:	8082                	ret
    for(;;)
    8000089e:	a001                	j	8000089e <uartputc_sync+0x4c>

00000000800008a0 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008a0:	00008797          	auipc	a5,0x8
    800008a4:	1b87b783          	ld	a5,440(a5) # 80008a58 <uart_tx_r>
    800008a8:	00008717          	auipc	a4,0x8
    800008ac:	1b873703          	ld	a4,440(a4) # 80008a60 <uart_tx_w>
    800008b0:	06f70f63          	beq	a4,a5,8000092e <uartstart+0x8e>
{
    800008b4:	7139                	add	sp,sp,-64
    800008b6:	fc06                	sd	ra,56(sp)
    800008b8:	f822                	sd	s0,48(sp)
    800008ba:	f426                	sd	s1,40(sp)
    800008bc:	f04a                	sd	s2,32(sp)
    800008be:	ec4e                	sd	s3,24(sp)
    800008c0:	e852                	sd	s4,16(sp)
    800008c2:	e456                	sd	s5,8(sp)
    800008c4:	e05a                	sd	s6,0(sp)
    800008c6:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c8:	10000937          	lui	s2,0x10000
    800008cc:	0915                	add	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ce:	00010a97          	auipc	s5,0x10
    800008d2:	3daa8a93          	add	s5,s5,986 # 80010ca8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d6:	00008497          	auipc	s1,0x8
    800008da:	18248493          	add	s1,s1,386 # 80008a58 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008de:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e2:	00008997          	auipc	s3,0x8
    800008e6:	17e98993          	add	s3,s3,382 # 80008a60 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ea:	00094703          	lbu	a4,0(s2)
    800008ee:	02077713          	and	a4,a4,32
    800008f2:	c705                	beqz	a4,8000091a <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008f4:	01f7f713          	and	a4,a5,31
    800008f8:	9756                	add	a4,a4,s5
    800008fa:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008fe:	0785                	add	a5,a5,1
    80000900:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    80000902:	8526                	mv	a0,s1
    80000904:	00002097          	auipc	ra,0x2
    80000908:	b18080e7          	jalr	-1256(ra) # 8000241c <wakeup>
    WriteReg(THR, c);
    8000090c:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000910:	609c                	ld	a5,0(s1)
    80000912:	0009b703          	ld	a4,0(s3)
    80000916:	fcf71ae3          	bne	a4,a5,800008ea <uartstart+0x4a>
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	add	sp,sp,64
    8000092c:	8082                	ret
    8000092e:	8082                	ret

0000000080000930 <uartputc>:
{
    80000930:	7179                	add	sp,sp,-48
    80000932:	f406                	sd	ra,40(sp)
    80000934:	f022                	sd	s0,32(sp)
    80000936:	ec26                	sd	s1,24(sp)
    80000938:	e84a                	sd	s2,16(sp)
    8000093a:	e44e                	sd	s3,8(sp)
    8000093c:	e052                	sd	s4,0(sp)
    8000093e:	1800                	add	s0,sp,48
    80000940:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000942:	00010517          	auipc	a0,0x10
    80000946:	36650513          	add	a0,a0,870 # 80010ca8 <uart_tx_lock>
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	3b6080e7          	jalr	950(ra) # 80000d00 <acquire>
  if(panicked){
    80000952:	00008797          	auipc	a5,0x8
    80000956:	0fe7a783          	lw	a5,254(a5) # 80008a50 <panicked>
    8000095a:	e7c9                	bnez	a5,800009e4 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000095c:	00008717          	auipc	a4,0x8
    80000960:	10473703          	ld	a4,260(a4) # 80008a60 <uart_tx_w>
    80000964:	00008797          	auipc	a5,0x8
    80000968:	0f47b783          	ld	a5,244(a5) # 80008a58 <uart_tx_r>
    8000096c:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000970:	00010997          	auipc	s3,0x10
    80000974:	33898993          	add	s3,s3,824 # 80010ca8 <uart_tx_lock>
    80000978:	00008497          	auipc	s1,0x8
    8000097c:	0e048493          	add	s1,s1,224 # 80008a58 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000980:	00008917          	auipc	s2,0x8
    80000984:	0e090913          	add	s2,s2,224 # 80008a60 <uart_tx_w>
    80000988:	00e79f63          	bne	a5,a4,800009a6 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000098c:	85ce                	mv	a1,s3
    8000098e:	8526                	mv	a0,s1
    80000990:	00002097          	auipc	ra,0x2
    80000994:	a28080e7          	jalr	-1496(ra) # 800023b8 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000998:	00093703          	ld	a4,0(s2)
    8000099c:	609c                	ld	a5,0(s1)
    8000099e:	02078793          	add	a5,a5,32
    800009a2:	fee785e3          	beq	a5,a4,8000098c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a6:	00010497          	auipc	s1,0x10
    800009aa:	30248493          	add	s1,s1,770 # 80010ca8 <uart_tx_lock>
    800009ae:	01f77793          	and	a5,a4,31
    800009b2:	97a6                	add	a5,a5,s1
    800009b4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009b8:	0705                	add	a4,a4,1
    800009ba:	00008797          	auipc	a5,0x8
    800009be:	0ae7b323          	sd	a4,166(a5) # 80008a60 <uart_tx_w>
  uartstart();
    800009c2:	00000097          	auipc	ra,0x0
    800009c6:	ede080e7          	jalr	-290(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    800009ca:	8526                	mv	a0,s1
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	3e8080e7          	jalr	1000(ra) # 80000db4 <release>
}
    800009d4:	70a2                	ld	ra,40(sp)
    800009d6:	7402                	ld	s0,32(sp)
    800009d8:	64e2                	ld	s1,24(sp)
    800009da:	6942                	ld	s2,16(sp)
    800009dc:	69a2                	ld	s3,8(sp)
    800009de:	6a02                	ld	s4,0(sp)
    800009e0:	6145                	add	sp,sp,48
    800009e2:	8082                	ret
    for(;;)
    800009e4:	a001                	j	800009e4 <uartputc+0xb4>

00000000800009e6 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e6:	1141                	add	sp,sp,-16
    800009e8:	e422                	sd	s0,8(sp)
    800009ea:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0795                	add	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009f2:	0007c783          	lbu	a5,0(a5)
    800009f6:	8b85                	and	a5,a5,1
    800009f8:	cb81                	beqz	a5,80000a08 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009fa:	100007b7          	lui	a5,0x10000
    800009fe:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a02:	6422                	ld	s0,8(sp)
    80000a04:	0141                	add	sp,sp,16
    80000a06:	8082                	ret
    return -1;
    80000a08:	557d                	li	a0,-1
    80000a0a:	bfe5                	j	80000a02 <uartgetc+0x1c>

0000000080000a0c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a0c:	1101                	add	sp,sp,-32
    80000a0e:	ec06                	sd	ra,24(sp)
    80000a10:	e822                	sd	s0,16(sp)
    80000a12:	e426                	sd	s1,8(sp)
    80000a14:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a16:	54fd                	li	s1,-1
    80000a18:	a029                	j	80000a22 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a1a:	00000097          	auipc	ra,0x0
    80000a1e:	8bc080e7          	jalr	-1860(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	fc4080e7          	jalr	-60(ra) # 800009e6 <uartgetc>
    if(c == -1)
    80000a2a:	fe9518e3          	bne	a0,s1,80000a1a <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a2e:	00010497          	auipc	s1,0x10
    80000a32:	27a48493          	add	s1,s1,634 # 80010ca8 <uart_tx_lock>
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	2c8080e7          	jalr	712(ra) # 80000d00 <acquire>
  uartstart();
    80000a40:	00000097          	auipc	ra,0x0
    80000a44:	e60080e7          	jalr	-416(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    80000a48:	8526                	mv	a0,s1
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	36a080e7          	jalr	874(ra) # 80000db4 <release>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	add	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000a5c:	1101                	add	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	add	s0,sp,32
    80000a68:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0) // On kinit MAX_PAGES is not yet set
    80000a6a:	00008797          	auipc	a5,0x8
    80000a6e:	0067b783          	ld	a5,6(a5) # 80008a70 <MAX_PAGES>
    80000a72:	c799                	beqz	a5,80000a80 <kfree+0x24>
        assert(FREE_PAGES < MAX_PAGES);
    80000a74:	00008717          	auipc	a4,0x8
    80000a78:	ff473703          	ld	a4,-12(a4) # 80008a68 <FREE_PAGES>
    80000a7c:	06f77663          	bgeu	a4,a5,80000ae8 <kfree+0x8c>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a80:	03449793          	sll	a5,s1,0x34
    80000a84:	efc1                	bnez	a5,80000b1c <kfree+0xc0>
    80000a86:	00021797          	auipc	a5,0x21
    80000a8a:	48a78793          	add	a5,a5,1162 # 80021f10 <end>
    80000a8e:	08f4e763          	bltu	s1,a5,80000b1c <kfree+0xc0>
    80000a92:	47c5                	li	a5,17
    80000a94:	07ee                	sll	a5,a5,0x1b
    80000a96:	08f4f363          	bgeu	s1,a5,80000b1c <kfree+0xc0>
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);
    80000a9a:	6605                	lui	a2,0x1
    80000a9c:	4585                	li	a1,1
    80000a9e:	8526                	mv	a0,s1
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	35c080e7          	jalr	860(ra) # 80000dfc <memset>

    r = (struct run *)pa;

    acquire(&kmem.lock);
    80000aa8:	00010917          	auipc	s2,0x10
    80000aac:	23890913          	add	s2,s2,568 # 80010ce0 <kmem>
    80000ab0:	854a                	mv	a0,s2
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	24e080e7          	jalr	590(ra) # 80000d00 <acquire>
    r->next = kmem.freelist;
    80000aba:	01893783          	ld	a5,24(s2)
    80000abe:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000ac0:	00993c23          	sd	s1,24(s2)
    FREE_PAGES++;
    80000ac4:	00008717          	auipc	a4,0x8
    80000ac8:	fa470713          	add	a4,a4,-92 # 80008a68 <FREE_PAGES>
    80000acc:	631c                	ld	a5,0(a4)
    80000ace:	0785                	add	a5,a5,1
    80000ad0:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000ad2:	854a                	mv	a0,s2
    80000ad4:	00000097          	auipc	ra,0x0
    80000ad8:	2e0080e7          	jalr	736(ra) # 80000db4 <release>
}
    80000adc:	60e2                	ld	ra,24(sp)
    80000ade:	6442                	ld	s0,16(sp)
    80000ae0:	64a2                	ld	s1,8(sp)
    80000ae2:	6902                	ld	s2,0(sp)
    80000ae4:	6105                	add	sp,sp,32
    80000ae6:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000ae8:	03700693          	li	a3,55
    80000aec:	00007617          	auipc	a2,0x7
    80000af0:	51c60613          	add	a2,a2,1308 # 80008008 <__func__.1>
    80000af4:	00007597          	auipc	a1,0x7
    80000af8:	55c58593          	add	a1,a1,1372 # 80008050 <__func__.1+0x48>
    80000afc:	00007517          	auipc	a0,0x7
    80000b00:	56450513          	add	a0,a0,1380 # 80008060 <__func__.1+0x58>
    80000b04:	00000097          	auipc	ra,0x0
    80000b08:	ab8080e7          	jalr	-1352(ra) # 800005bc <printf>
    80000b0c:	00007517          	auipc	a0,0x7
    80000b10:	56450513          	add	a0,a0,1380 # 80008070 <__func__.1+0x68>
    80000b14:	00000097          	auipc	ra,0x0
    80000b18:	a4c080e7          	jalr	-1460(ra) # 80000560 <panic>
        panic("kfree");
    80000b1c:	00007517          	auipc	a0,0x7
    80000b20:	56450513          	add	a0,a0,1380 # 80008080 <__func__.1+0x78>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	a3c080e7          	jalr	-1476(ra) # 80000560 <panic>

0000000080000b2c <freerange>:
{
    80000b2c:	7179                	add	sp,sp,-48
    80000b2e:	f406                	sd	ra,40(sp)
    80000b30:	f022                	sd	s0,32(sp)
    80000b32:	ec26                	sd	s1,24(sp)
    80000b34:	1800                	add	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000b36:	6785                	lui	a5,0x1
    80000b38:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b3c:	00e504b3          	add	s1,a0,a4
    80000b40:	777d                	lui	a4,0xfffff
    80000b42:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b44:	94be                	add	s1,s1,a5
    80000b46:	0295e463          	bltu	a1,s1,80000b6e <freerange+0x42>
    80000b4a:	e84a                	sd	s2,16(sp)
    80000b4c:	e44e                	sd	s3,8(sp)
    80000b4e:	e052                	sd	s4,0(sp)
    80000b50:	892e                	mv	s2,a1
        kfree(p);
    80000b52:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b54:	6985                	lui	s3,0x1
        kfree(p);
    80000b56:	01448533          	add	a0,s1,s4
    80000b5a:	00000097          	auipc	ra,0x0
    80000b5e:	f02080e7          	jalr	-254(ra) # 80000a5c <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b62:	94ce                	add	s1,s1,s3
    80000b64:	fe9979e3          	bgeu	s2,s1,80000b56 <freerange+0x2a>
    80000b68:	6942                	ld	s2,16(sp)
    80000b6a:	69a2                	ld	s3,8(sp)
    80000b6c:	6a02                	ld	s4,0(sp)
}
    80000b6e:	70a2                	ld	ra,40(sp)
    80000b70:	7402                	ld	s0,32(sp)
    80000b72:	64e2                	ld	s1,24(sp)
    80000b74:	6145                	add	sp,sp,48
    80000b76:	8082                	ret

0000000080000b78 <kinit>:
{
    80000b78:	1141                	add	sp,sp,-16
    80000b7a:	e406                	sd	ra,8(sp)
    80000b7c:	e022                	sd	s0,0(sp)
    80000b7e:	0800                	add	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000b80:	00007597          	auipc	a1,0x7
    80000b84:	50858593          	add	a1,a1,1288 # 80008088 <__func__.1+0x80>
    80000b88:	00010517          	auipc	a0,0x10
    80000b8c:	15850513          	add	a0,a0,344 # 80010ce0 <kmem>
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	0e0080e7          	jalr	224(ra) # 80000c70 <initlock>
    freerange(end, (void *)PHYSTOP);
    80000b98:	45c5                	li	a1,17
    80000b9a:	05ee                	sll	a1,a1,0x1b
    80000b9c:	00021517          	auipc	a0,0x21
    80000ba0:	37450513          	add	a0,a0,884 # 80021f10 <end>
    80000ba4:	00000097          	auipc	ra,0x0
    80000ba8:	f88080e7          	jalr	-120(ra) # 80000b2c <freerange>
    MAX_PAGES = FREE_PAGES;
    80000bac:	00008797          	auipc	a5,0x8
    80000bb0:	ebc7b783          	ld	a5,-324(a5) # 80008a68 <FREE_PAGES>
    80000bb4:	00008717          	auipc	a4,0x8
    80000bb8:	eaf73e23          	sd	a5,-324(a4) # 80008a70 <MAX_PAGES>
}
    80000bbc:	60a2                	ld	ra,8(sp)
    80000bbe:	6402                	ld	s0,0(sp)
    80000bc0:	0141                	add	sp,sp,16
    80000bc2:	8082                	ret

0000000080000bc4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000bc4:	1101                	add	sp,sp,-32
    80000bc6:	ec06                	sd	ra,24(sp)
    80000bc8:	e822                	sd	s0,16(sp)
    80000bca:	e426                	sd	s1,8(sp)
    80000bcc:	1000                	add	s0,sp,32
    assert(FREE_PAGES > 0);
    80000bce:	00008797          	auipc	a5,0x8
    80000bd2:	e9a7b783          	ld	a5,-358(a5) # 80008a68 <FREE_PAGES>
    80000bd6:	cbb1                	beqz	a5,80000c2a <kalloc+0x66>
    struct run *r;

    acquire(&kmem.lock);
    80000bd8:	00010497          	auipc	s1,0x10
    80000bdc:	10848493          	add	s1,s1,264 # 80010ce0 <kmem>
    80000be0:	8526                	mv	a0,s1
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	11e080e7          	jalr	286(ra) # 80000d00 <acquire>
    r = kmem.freelist;
    80000bea:	6c84                	ld	s1,24(s1)
    if (r)
    80000bec:	c8ad                	beqz	s1,80000c5e <kalloc+0x9a>
        kmem.freelist = r->next;
    80000bee:	609c                	ld	a5,0(s1)
    80000bf0:	00010517          	auipc	a0,0x10
    80000bf4:	0f050513          	add	a0,a0,240 # 80010ce0 <kmem>
    80000bf8:	ed1c                	sd	a5,24(a0)
    release(&kmem.lock);
    80000bfa:	00000097          	auipc	ra,0x0
    80000bfe:	1ba080e7          	jalr	442(ra) # 80000db4 <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000c02:	6605                	lui	a2,0x1
    80000c04:	4595                	li	a1,5
    80000c06:	8526                	mv	a0,s1
    80000c08:	00000097          	auipc	ra,0x0
    80000c0c:	1f4080e7          	jalr	500(ra) # 80000dfc <memset>
    FREE_PAGES--;
    80000c10:	00008717          	auipc	a4,0x8
    80000c14:	e5870713          	add	a4,a4,-424 # 80008a68 <FREE_PAGES>
    80000c18:	631c                	ld	a5,0(a4)
    80000c1a:	17fd                	add	a5,a5,-1
    80000c1c:	e31c                	sd	a5,0(a4)
    return (void *)r;
}
    80000c1e:	8526                	mv	a0,s1
    80000c20:	60e2                	ld	ra,24(sp)
    80000c22:	6442                	ld	s0,16(sp)
    80000c24:	64a2                	ld	s1,8(sp)
    80000c26:	6105                	add	sp,sp,32
    80000c28:	8082                	ret
    assert(FREE_PAGES > 0);
    80000c2a:	04f00693          	li	a3,79
    80000c2e:	00007617          	auipc	a2,0x7
    80000c32:	3d260613          	add	a2,a2,978 # 80008000 <etext>
    80000c36:	00007597          	auipc	a1,0x7
    80000c3a:	41a58593          	add	a1,a1,1050 # 80008050 <__func__.1+0x48>
    80000c3e:	00007517          	auipc	a0,0x7
    80000c42:	42250513          	add	a0,a0,1058 # 80008060 <__func__.1+0x58>
    80000c46:	00000097          	auipc	ra,0x0
    80000c4a:	976080e7          	jalr	-1674(ra) # 800005bc <printf>
    80000c4e:	00007517          	auipc	a0,0x7
    80000c52:	42250513          	add	a0,a0,1058 # 80008070 <__func__.1+0x68>
    80000c56:	00000097          	auipc	ra,0x0
    80000c5a:	90a080e7          	jalr	-1782(ra) # 80000560 <panic>
    release(&kmem.lock);
    80000c5e:	00010517          	auipc	a0,0x10
    80000c62:	08250513          	add	a0,a0,130 # 80010ce0 <kmem>
    80000c66:	00000097          	auipc	ra,0x0
    80000c6a:	14e080e7          	jalr	334(ra) # 80000db4 <release>
    if (r)
    80000c6e:	b74d                	j	80000c10 <kalloc+0x4c>

0000000080000c70 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c70:	1141                	add	sp,sp,-16
    80000c72:	e422                	sd	s0,8(sp)
    80000c74:	0800                	add	s0,sp,16
  lk->name = name;
    80000c76:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c78:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c7c:	00053823          	sd	zero,16(a0)
}
    80000c80:	6422                	ld	s0,8(sp)
    80000c82:	0141                	add	sp,sp,16
    80000c84:	8082                	ret

0000000080000c86 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c86:	411c                	lw	a5,0(a0)
    80000c88:	e399                	bnez	a5,80000c8e <holding+0x8>
    80000c8a:	4501                	li	a0,0
  return r;
}
    80000c8c:	8082                	ret
{
    80000c8e:	1101                	add	sp,sp,-32
    80000c90:	ec06                	sd	ra,24(sp)
    80000c92:	e822                	sd	s0,16(sp)
    80000c94:	e426                	sd	s1,8(sp)
    80000c96:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c98:	6904                	ld	s1,16(a0)
    80000c9a:	00001097          	auipc	ra,0x1
    80000c9e:	f50080e7          	jalr	-176(ra) # 80001bea <mycpu>
    80000ca2:	40a48533          	sub	a0,s1,a0
    80000ca6:	00153513          	seqz	a0,a0
}
    80000caa:	60e2                	ld	ra,24(sp)
    80000cac:	6442                	ld	s0,16(sp)
    80000cae:	64a2                	ld	s1,8(sp)
    80000cb0:	6105                	add	sp,sp,32
    80000cb2:	8082                	ret

0000000080000cb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000cb4:	1101                	add	sp,sp,-32
    80000cb6:	ec06                	sd	ra,24(sp)
    80000cb8:	e822                	sd	s0,16(sp)
    80000cba:	e426                	sd	s1,8(sp)
    80000cbc:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cbe:	100024f3          	csrr	s1,sstatus
    80000cc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cc6:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ccc:	00001097          	auipc	ra,0x1
    80000cd0:	f1e080e7          	jalr	-226(ra) # 80001bea <mycpu>
    80000cd4:	5d3c                	lw	a5,120(a0)
    80000cd6:	cf89                	beqz	a5,80000cf0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000cd8:	00001097          	auipc	ra,0x1
    80000cdc:	f12080e7          	jalr	-238(ra) # 80001bea <mycpu>
    80000ce0:	5d3c                	lw	a5,120(a0)
    80000ce2:	2785                	addw	a5,a5,1
    80000ce4:	dd3c                	sw	a5,120(a0)
}
    80000ce6:	60e2                	ld	ra,24(sp)
    80000ce8:	6442                	ld	s0,16(sp)
    80000cea:	64a2                	ld	s1,8(sp)
    80000cec:	6105                	add	sp,sp,32
    80000cee:	8082                	ret
    mycpu()->intena = old;
    80000cf0:	00001097          	auipc	ra,0x1
    80000cf4:	efa080e7          	jalr	-262(ra) # 80001bea <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000cf8:	8085                	srl	s1,s1,0x1
    80000cfa:	8885                	and	s1,s1,1
    80000cfc:	dd64                	sw	s1,124(a0)
    80000cfe:	bfe9                	j	80000cd8 <push_off+0x24>

0000000080000d00 <acquire>:
{
    80000d00:	1101                	add	sp,sp,-32
    80000d02:	ec06                	sd	ra,24(sp)
    80000d04:	e822                	sd	s0,16(sp)
    80000d06:	e426                	sd	s1,8(sp)
    80000d08:	1000                	add	s0,sp,32
    80000d0a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d0c:	00000097          	auipc	ra,0x0
    80000d10:	fa8080e7          	jalr	-88(ra) # 80000cb4 <push_off>
  if(holding(lk))
    80000d14:	8526                	mv	a0,s1
    80000d16:	00000097          	auipc	ra,0x0
    80000d1a:	f70080e7          	jalr	-144(ra) # 80000c86 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d1e:	4705                	li	a4,1
  if(holding(lk))
    80000d20:	e115                	bnez	a0,80000d44 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d22:	87ba                	mv	a5,a4
    80000d24:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d28:	2781                	sext.w	a5,a5
    80000d2a:	ffe5                	bnez	a5,80000d22 <acquire+0x22>
  __sync_synchronize();
    80000d2c:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d30:	00001097          	auipc	ra,0x1
    80000d34:	eba080e7          	jalr	-326(ra) # 80001bea <mycpu>
    80000d38:	e888                	sd	a0,16(s1)
}
    80000d3a:	60e2                	ld	ra,24(sp)
    80000d3c:	6442                	ld	s0,16(sp)
    80000d3e:	64a2                	ld	s1,8(sp)
    80000d40:	6105                	add	sp,sp,32
    80000d42:	8082                	ret
    panic("acquire");
    80000d44:	00007517          	auipc	a0,0x7
    80000d48:	34c50513          	add	a0,a0,844 # 80008090 <__func__.1+0x88>
    80000d4c:	00000097          	auipc	ra,0x0
    80000d50:	814080e7          	jalr	-2028(ra) # 80000560 <panic>

0000000080000d54 <pop_off>:

void
pop_off(void)
{
    80000d54:	1141                	add	sp,sp,-16
    80000d56:	e406                	sd	ra,8(sp)
    80000d58:	e022                	sd	s0,0(sp)
    80000d5a:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000d5c:	00001097          	auipc	ra,0x1
    80000d60:	e8e080e7          	jalr	-370(ra) # 80001bea <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d64:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d68:	8b89                	and	a5,a5,2
  if(intr_get())
    80000d6a:	e78d                	bnez	a5,80000d94 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d6c:	5d3c                	lw	a5,120(a0)
    80000d6e:	02f05b63          	blez	a5,80000da4 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d72:	37fd                	addw	a5,a5,-1
    80000d74:	0007871b          	sext.w	a4,a5
    80000d78:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d7a:	eb09                	bnez	a4,80000d8c <pop_off+0x38>
    80000d7c:	5d7c                	lw	a5,124(a0)
    80000d7e:	c799                	beqz	a5,80000d8c <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d80:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d84:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d88:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	add	sp,sp,16
    80000d92:	8082                	ret
    panic("pop_off - interruptible");
    80000d94:	00007517          	auipc	a0,0x7
    80000d98:	30450513          	add	a0,a0,772 # 80008098 <__func__.1+0x90>
    80000d9c:	fffff097          	auipc	ra,0xfffff
    80000da0:	7c4080e7          	jalr	1988(ra) # 80000560 <panic>
    panic("pop_off");
    80000da4:	00007517          	auipc	a0,0x7
    80000da8:	30c50513          	add	a0,a0,780 # 800080b0 <__func__.1+0xa8>
    80000dac:	fffff097          	auipc	ra,0xfffff
    80000db0:	7b4080e7          	jalr	1972(ra) # 80000560 <panic>

0000000080000db4 <release>:
{
    80000db4:	1101                	add	sp,sp,-32
    80000db6:	ec06                	sd	ra,24(sp)
    80000db8:	e822                	sd	s0,16(sp)
    80000dba:	e426                	sd	s1,8(sp)
    80000dbc:	1000                	add	s0,sp,32
    80000dbe:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000dc0:	00000097          	auipc	ra,0x0
    80000dc4:	ec6080e7          	jalr	-314(ra) # 80000c86 <holding>
    80000dc8:	c115                	beqz	a0,80000dec <release+0x38>
  lk->cpu = 0;
    80000dca:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000dce:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000dd2:	0f50000f          	fence	iorw,ow
    80000dd6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000dda:	00000097          	auipc	ra,0x0
    80000dde:	f7a080e7          	jalr	-134(ra) # 80000d54 <pop_off>
}
    80000de2:	60e2                	ld	ra,24(sp)
    80000de4:	6442                	ld	s0,16(sp)
    80000de6:	64a2                	ld	s1,8(sp)
    80000de8:	6105                	add	sp,sp,32
    80000dea:	8082                	ret
    panic("release");
    80000dec:	00007517          	auipc	a0,0x7
    80000df0:	2cc50513          	add	a0,a0,716 # 800080b8 <__func__.1+0xb0>
    80000df4:	fffff097          	auipc	ra,0xfffff
    80000df8:	76c080e7          	jalr	1900(ra) # 80000560 <panic>

0000000080000dfc <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000dfc:	1141                	add	sp,sp,-16
    80000dfe:	e422                	sd	s0,8(sp)
    80000e00:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e02:	ca19                	beqz	a2,80000e18 <memset+0x1c>
    80000e04:	87aa                	mv	a5,a0
    80000e06:	1602                	sll	a2,a2,0x20
    80000e08:	9201                	srl	a2,a2,0x20
    80000e0a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e0e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e12:	0785                	add	a5,a5,1
    80000e14:	fee79de3          	bne	a5,a4,80000e0e <memset+0x12>
  }
  return dst;
}
    80000e18:	6422                	ld	s0,8(sp)
    80000e1a:	0141                	add	sp,sp,16
    80000e1c:	8082                	ret

0000000080000e1e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e1e:	1141                	add	sp,sp,-16
    80000e20:	e422                	sd	s0,8(sp)
    80000e22:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e24:	ca05                	beqz	a2,80000e54 <memcmp+0x36>
    80000e26:	fff6069b          	addw	a3,a2,-1
    80000e2a:	1682                	sll	a3,a3,0x20
    80000e2c:	9281                	srl	a3,a3,0x20
    80000e2e:	0685                	add	a3,a3,1
    80000e30:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e32:	00054783          	lbu	a5,0(a0)
    80000e36:	0005c703          	lbu	a4,0(a1)
    80000e3a:	00e79863          	bne	a5,a4,80000e4a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e3e:	0505                	add	a0,a0,1
    80000e40:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000e42:	fed518e3          	bne	a0,a3,80000e32 <memcmp+0x14>
  }

  return 0;
    80000e46:	4501                	li	a0,0
    80000e48:	a019                	j	80000e4e <memcmp+0x30>
      return *s1 - *s2;
    80000e4a:	40e7853b          	subw	a0,a5,a4
}
    80000e4e:	6422                	ld	s0,8(sp)
    80000e50:	0141                	add	sp,sp,16
    80000e52:	8082                	ret
  return 0;
    80000e54:	4501                	li	a0,0
    80000e56:	bfe5                	j	80000e4e <memcmp+0x30>

0000000080000e58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e58:	1141                	add	sp,sp,-16
    80000e5a:	e422                	sd	s0,8(sp)
    80000e5c:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000e5e:	c205                	beqz	a2,80000e7e <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e60:	02a5e263          	bltu	a1,a0,80000e84 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e64:	1602                	sll	a2,a2,0x20
    80000e66:	9201                	srl	a2,a2,0x20
    80000e68:	00c587b3          	add	a5,a1,a2
{
    80000e6c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e6e:	0585                	add	a1,a1,1
    80000e70:	0705                	add	a4,a4,1
    80000e72:	fff5c683          	lbu	a3,-1(a1)
    80000e76:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e7a:	feb79ae3          	bne	a5,a1,80000e6e <memmove+0x16>

  return dst;
}
    80000e7e:	6422                	ld	s0,8(sp)
    80000e80:	0141                	add	sp,sp,16
    80000e82:	8082                	ret
  if(s < d && s + n > d){
    80000e84:	02061693          	sll	a3,a2,0x20
    80000e88:	9281                	srl	a3,a3,0x20
    80000e8a:	00d58733          	add	a4,a1,a3
    80000e8e:	fce57be3          	bgeu	a0,a4,80000e64 <memmove+0xc>
    d += n;
    80000e92:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e94:	fff6079b          	addw	a5,a2,-1
    80000e98:	1782                	sll	a5,a5,0x20
    80000e9a:	9381                	srl	a5,a5,0x20
    80000e9c:	fff7c793          	not	a5,a5
    80000ea0:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000ea2:	177d                	add	a4,a4,-1
    80000ea4:	16fd                	add	a3,a3,-1
    80000ea6:	00074603          	lbu	a2,0(a4)
    80000eaa:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000eae:	fef71ae3          	bne	a4,a5,80000ea2 <memmove+0x4a>
    80000eb2:	b7f1                	j	80000e7e <memmove+0x26>

0000000080000eb4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000eb4:	1141                	add	sp,sp,-16
    80000eb6:	e406                	sd	ra,8(sp)
    80000eb8:	e022                	sd	s0,0(sp)
    80000eba:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000ebc:	00000097          	auipc	ra,0x0
    80000ec0:	f9c080e7          	jalr	-100(ra) # 80000e58 <memmove>
}
    80000ec4:	60a2                	ld	ra,8(sp)
    80000ec6:	6402                	ld	s0,0(sp)
    80000ec8:	0141                	add	sp,sp,16
    80000eca:	8082                	ret

0000000080000ecc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000ecc:	1141                	add	sp,sp,-16
    80000ece:	e422                	sd	s0,8(sp)
    80000ed0:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ed2:	ce11                	beqz	a2,80000eee <strncmp+0x22>
    80000ed4:	00054783          	lbu	a5,0(a0)
    80000ed8:	cf89                	beqz	a5,80000ef2 <strncmp+0x26>
    80000eda:	0005c703          	lbu	a4,0(a1)
    80000ede:	00f71a63          	bne	a4,a5,80000ef2 <strncmp+0x26>
    n--, p++, q++;
    80000ee2:	367d                	addw	a2,a2,-1
    80000ee4:	0505                	add	a0,a0,1
    80000ee6:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ee8:	f675                	bnez	a2,80000ed4 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000eea:	4501                	li	a0,0
    80000eec:	a801                	j	80000efc <strncmp+0x30>
    80000eee:	4501                	li	a0,0
    80000ef0:	a031                	j	80000efc <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000ef2:	00054503          	lbu	a0,0(a0)
    80000ef6:	0005c783          	lbu	a5,0(a1)
    80000efa:	9d1d                	subw	a0,a0,a5
}
    80000efc:	6422                	ld	s0,8(sp)
    80000efe:	0141                	add	sp,sp,16
    80000f00:	8082                	ret

0000000080000f02 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f02:	1141                	add	sp,sp,-16
    80000f04:	e422                	sd	s0,8(sp)
    80000f06:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f08:	87aa                	mv	a5,a0
    80000f0a:	86b2                	mv	a3,a2
    80000f0c:	367d                	addw	a2,a2,-1
    80000f0e:	02d05563          	blez	a3,80000f38 <strncpy+0x36>
    80000f12:	0785                	add	a5,a5,1
    80000f14:	0005c703          	lbu	a4,0(a1)
    80000f18:	fee78fa3          	sb	a4,-1(a5)
    80000f1c:	0585                	add	a1,a1,1
    80000f1e:	f775                	bnez	a4,80000f0a <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f20:	873e                	mv	a4,a5
    80000f22:	9fb5                	addw	a5,a5,a3
    80000f24:	37fd                	addw	a5,a5,-1
    80000f26:	00c05963          	blez	a2,80000f38 <strncpy+0x36>
    *s++ = 0;
    80000f2a:	0705                	add	a4,a4,1
    80000f2c:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000f30:	40e786bb          	subw	a3,a5,a4
    80000f34:	fed04be3          	bgtz	a3,80000f2a <strncpy+0x28>
  return os;
}
    80000f38:	6422                	ld	s0,8(sp)
    80000f3a:	0141                	add	sp,sp,16
    80000f3c:	8082                	ret

0000000080000f3e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f3e:	1141                	add	sp,sp,-16
    80000f40:	e422                	sd	s0,8(sp)
    80000f42:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f44:	02c05363          	blez	a2,80000f6a <safestrcpy+0x2c>
    80000f48:	fff6069b          	addw	a3,a2,-1
    80000f4c:	1682                	sll	a3,a3,0x20
    80000f4e:	9281                	srl	a3,a3,0x20
    80000f50:	96ae                	add	a3,a3,a1
    80000f52:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f54:	00d58963          	beq	a1,a3,80000f66 <safestrcpy+0x28>
    80000f58:	0585                	add	a1,a1,1
    80000f5a:	0785                	add	a5,a5,1
    80000f5c:	fff5c703          	lbu	a4,-1(a1)
    80000f60:	fee78fa3          	sb	a4,-1(a5)
    80000f64:	fb65                	bnez	a4,80000f54 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f66:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f6a:	6422                	ld	s0,8(sp)
    80000f6c:	0141                	add	sp,sp,16
    80000f6e:	8082                	ret

0000000080000f70 <strlen>:

int
strlen(const char *s)
{
    80000f70:	1141                	add	sp,sp,-16
    80000f72:	e422                	sd	s0,8(sp)
    80000f74:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f76:	00054783          	lbu	a5,0(a0)
    80000f7a:	cf91                	beqz	a5,80000f96 <strlen+0x26>
    80000f7c:	0505                	add	a0,a0,1
    80000f7e:	87aa                	mv	a5,a0
    80000f80:	86be                	mv	a3,a5
    80000f82:	0785                	add	a5,a5,1
    80000f84:	fff7c703          	lbu	a4,-1(a5)
    80000f88:	ff65                	bnez	a4,80000f80 <strlen+0x10>
    80000f8a:	40a6853b          	subw	a0,a3,a0
    80000f8e:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000f90:	6422                	ld	s0,8(sp)
    80000f92:	0141                	add	sp,sp,16
    80000f94:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f96:	4501                	li	a0,0
    80000f98:	bfe5                	j	80000f90 <strlen+0x20>

0000000080000f9a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f9a:	1141                	add	sp,sp,-16
    80000f9c:	e406                	sd	ra,8(sp)
    80000f9e:	e022                	sd	s0,0(sp)
    80000fa0:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000fa2:	00001097          	auipc	ra,0x1
    80000fa6:	c38080e7          	jalr	-968(ra) # 80001bda <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000faa:	00008717          	auipc	a4,0x8
    80000fae:	ace70713          	add	a4,a4,-1330 # 80008a78 <started>
  if(cpuid() == 0){
    80000fb2:	c139                	beqz	a0,80000ff8 <main+0x5e>
    while(started == 0)
    80000fb4:	431c                	lw	a5,0(a4)
    80000fb6:	2781                	sext.w	a5,a5
    80000fb8:	dff5                	beqz	a5,80000fb4 <main+0x1a>
      ;
    __sync_synchronize();
    80000fba:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000fbe:	00001097          	auipc	ra,0x1
    80000fc2:	c1c080e7          	jalr	-996(ra) # 80001bda <cpuid>
    80000fc6:	85aa                	mv	a1,a0
    80000fc8:	00007517          	auipc	a0,0x7
    80000fcc:	11050513          	add	a0,a0,272 # 800080d8 <__func__.1+0xd0>
    80000fd0:	fffff097          	auipc	ra,0xfffff
    80000fd4:	5ec080e7          	jalr	1516(ra) # 800005bc <printf>
    kvminithart();    // turn on paging
    80000fd8:	00000097          	auipc	ra,0x0
    80000fdc:	0d8080e7          	jalr	216(ra) # 800010b0 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fe0:	00002097          	auipc	ra,0x2
    80000fe4:	ab0080e7          	jalr	-1360(ra) # 80002a90 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000fe8:	00005097          	auipc	ra,0x5
    80000fec:	20c080e7          	jalr	524(ra) # 800061f4 <plicinithart>
  }

  scheduler();        
    80000ff0:	00001097          	auipc	ra,0x1
    80000ff4:	2a6080e7          	jalr	678(ra) # 80002296 <scheduler>
    consoleinit();
    80000ff8:	fffff097          	auipc	ra,0xfffff
    80000ffc:	478080e7          	jalr	1144(ra) # 80000470 <consoleinit>
    printfinit();
    80001000:	fffff097          	auipc	ra,0xfffff
    80001004:	7c4080e7          	jalr	1988(ra) # 800007c4 <printfinit>
    printf("\n");
    80001008:	00007517          	auipc	a0,0x7
    8000100c:	01850513          	add	a0,a0,24 # 80008020 <__func__.1+0x18>
    80001010:	fffff097          	auipc	ra,0xfffff
    80001014:	5ac080e7          	jalr	1452(ra) # 800005bc <printf>
    printf("xv6 kernel is booting\n");
    80001018:	00007517          	auipc	a0,0x7
    8000101c:	0a850513          	add	a0,a0,168 # 800080c0 <__func__.1+0xb8>
    80001020:	fffff097          	auipc	ra,0xfffff
    80001024:	59c080e7          	jalr	1436(ra) # 800005bc <printf>
    printf("\n");
    80001028:	00007517          	auipc	a0,0x7
    8000102c:	ff850513          	add	a0,a0,-8 # 80008020 <__func__.1+0x18>
    80001030:	fffff097          	auipc	ra,0xfffff
    80001034:	58c080e7          	jalr	1420(ra) # 800005bc <printf>
    kinit();         // physical page allocator
    80001038:	00000097          	auipc	ra,0x0
    8000103c:	b40080e7          	jalr	-1216(ra) # 80000b78 <kinit>
    kvminit();       // create kernel page table
    80001040:	00000097          	auipc	ra,0x0
    80001044:	326080e7          	jalr	806(ra) # 80001366 <kvminit>
    kvminithart();   // turn on paging
    80001048:	00000097          	auipc	ra,0x0
    8000104c:	068080e7          	jalr	104(ra) # 800010b0 <kvminithart>
    procinit();      // process table
    80001050:	00001097          	auipc	ra,0x1
    80001054:	aa4080e7          	jalr	-1372(ra) # 80001af4 <procinit>
    trapinit();      // trap vectors
    80001058:	00002097          	auipc	ra,0x2
    8000105c:	a10080e7          	jalr	-1520(ra) # 80002a68 <trapinit>
    trapinithart();  // install kernel trap vector
    80001060:	00002097          	auipc	ra,0x2
    80001064:	a30080e7          	jalr	-1488(ra) # 80002a90 <trapinithart>
    plicinit();      // set up interrupt controller
    80001068:	00005097          	auipc	ra,0x5
    8000106c:	172080e7          	jalr	370(ra) # 800061da <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001070:	00005097          	auipc	ra,0x5
    80001074:	184080e7          	jalr	388(ra) # 800061f4 <plicinithart>
    binit();         // buffer cache
    80001078:	00002097          	auipc	ra,0x2
    8000107c:	250080e7          	jalr	592(ra) # 800032c8 <binit>
    iinit();         // inode table
    80001080:	00003097          	auipc	ra,0x3
    80001084:	906080e7          	jalr	-1786(ra) # 80003986 <iinit>
    fileinit();      // file table
    80001088:	00004097          	auipc	ra,0x4
    8000108c:	8b6080e7          	jalr	-1866(ra) # 8000493e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001090:	00005097          	auipc	ra,0x5
    80001094:	26c080e7          	jalr	620(ra) # 800062fc <virtio_disk_init>
    userinit();      // first user process
    80001098:	00001097          	auipc	ra,0x1
    8000109c:	e46080e7          	jalr	-442(ra) # 80001ede <userinit>
    __sync_synchronize();
    800010a0:	0ff0000f          	fence
    started = 1;
    800010a4:	4785                	li	a5,1
    800010a6:	00008717          	auipc	a4,0x8
    800010aa:	9cf72923          	sw	a5,-1582(a4) # 80008a78 <started>
    800010ae:	b789                	j	80000ff0 <main+0x56>

00000000800010b0 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800010b0:	1141                	add	sp,sp,-16
    800010b2:	e422                	sd	s0,8(sp)
    800010b4:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800010b6:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800010ba:	00008797          	auipc	a5,0x8
    800010be:	9c67b783          	ld	a5,-1594(a5) # 80008a80 <kernel_pagetable>
    800010c2:	83b1                	srl	a5,a5,0xc
    800010c4:	577d                	li	a4,-1
    800010c6:	177e                	sll	a4,a4,0x3f
    800010c8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800010ca:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800010ce:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800010d2:	6422                	ld	s0,8(sp)
    800010d4:	0141                	add	sp,sp,16
    800010d6:	8082                	ret

00000000800010d8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010d8:	7139                	add	sp,sp,-64
    800010da:	fc06                	sd	ra,56(sp)
    800010dc:	f822                	sd	s0,48(sp)
    800010de:	f426                	sd	s1,40(sp)
    800010e0:	f04a                	sd	s2,32(sp)
    800010e2:	ec4e                	sd	s3,24(sp)
    800010e4:	e852                	sd	s4,16(sp)
    800010e6:	e456                	sd	s5,8(sp)
    800010e8:	e05a                	sd	s6,0(sp)
    800010ea:	0080                	add	s0,sp,64
    800010ec:	84aa                	mv	s1,a0
    800010ee:	89ae                	mv	s3,a1
    800010f0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800010f2:	57fd                	li	a5,-1
    800010f4:	83e9                	srl	a5,a5,0x1a
    800010f6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800010f8:	4b31                	li	s6,12
  if(va >= MAXVA)
    800010fa:	04b7f263          	bgeu	a5,a1,8000113e <walk+0x66>
    panic("walk");
    800010fe:	00007517          	auipc	a0,0x7
    80001102:	ff250513          	add	a0,a0,-14 # 800080f0 <__func__.1+0xe8>
    80001106:	fffff097          	auipc	ra,0xfffff
    8000110a:	45a080e7          	jalr	1114(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000110e:	060a8663          	beqz	s5,8000117a <walk+0xa2>
    80001112:	00000097          	auipc	ra,0x0
    80001116:	ab2080e7          	jalr	-1358(ra) # 80000bc4 <kalloc>
    8000111a:	84aa                	mv	s1,a0
    8000111c:	c529                	beqz	a0,80001166 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000111e:	6605                	lui	a2,0x1
    80001120:	4581                	li	a1,0
    80001122:	00000097          	auipc	ra,0x0
    80001126:	cda080e7          	jalr	-806(ra) # 80000dfc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000112a:	00c4d793          	srl	a5,s1,0xc
    8000112e:	07aa                	sll	a5,a5,0xa
    80001130:	0017e793          	or	a5,a5,1
    80001134:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001138:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd0e7>
    8000113a:	036a0063          	beq	s4,s6,8000115a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000113e:	0149d933          	srl	s2,s3,s4
    80001142:	1ff97913          	and	s2,s2,511
    80001146:	090e                	sll	s2,s2,0x3
    80001148:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000114a:	00093483          	ld	s1,0(s2)
    8000114e:	0014f793          	and	a5,s1,1
    80001152:	dfd5                	beqz	a5,8000110e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001154:	80a9                	srl	s1,s1,0xa
    80001156:	04b2                	sll	s1,s1,0xc
    80001158:	b7c5                	j	80001138 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000115a:	00c9d513          	srl	a0,s3,0xc
    8000115e:	1ff57513          	and	a0,a0,511
    80001162:	050e                	sll	a0,a0,0x3
    80001164:	9526                	add	a0,a0,s1
}
    80001166:	70e2                	ld	ra,56(sp)
    80001168:	7442                	ld	s0,48(sp)
    8000116a:	74a2                	ld	s1,40(sp)
    8000116c:	7902                	ld	s2,32(sp)
    8000116e:	69e2                	ld	s3,24(sp)
    80001170:	6a42                	ld	s4,16(sp)
    80001172:	6aa2                	ld	s5,8(sp)
    80001174:	6b02                	ld	s6,0(sp)
    80001176:	6121                	add	sp,sp,64
    80001178:	8082                	ret
        return 0;
    8000117a:	4501                	li	a0,0
    8000117c:	b7ed                	j	80001166 <walk+0x8e>

000000008000117e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000117e:	57fd                	li	a5,-1
    80001180:	83e9                	srl	a5,a5,0x1a
    80001182:	00b7f463          	bgeu	a5,a1,8000118a <walkaddr+0xc>
    return 0;
    80001186:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001188:	8082                	ret
{
    8000118a:	1141                	add	sp,sp,-16
    8000118c:	e406                	sd	ra,8(sp)
    8000118e:	e022                	sd	s0,0(sp)
    80001190:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001192:	4601                	li	a2,0
    80001194:	00000097          	auipc	ra,0x0
    80001198:	f44080e7          	jalr	-188(ra) # 800010d8 <walk>
  if(pte == 0)
    8000119c:	c105                	beqz	a0,800011bc <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000119e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011a0:	0117f693          	and	a3,a5,17
    800011a4:	4745                	li	a4,17
    return 0;
    800011a6:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011a8:	00e68663          	beq	a3,a4,800011b4 <walkaddr+0x36>
}
    800011ac:	60a2                	ld	ra,8(sp)
    800011ae:	6402                	ld	s0,0(sp)
    800011b0:	0141                	add	sp,sp,16
    800011b2:	8082                	ret
  pa = PTE2PA(*pte);
    800011b4:	83a9                	srl	a5,a5,0xa
    800011b6:	00c79513          	sll	a0,a5,0xc
  return pa;
    800011ba:	bfcd                	j	800011ac <walkaddr+0x2e>
    return 0;
    800011bc:	4501                	li	a0,0
    800011be:	b7fd                	j	800011ac <walkaddr+0x2e>

00000000800011c0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011c0:	715d                	add	sp,sp,-80
    800011c2:	e486                	sd	ra,72(sp)
    800011c4:	e0a2                	sd	s0,64(sp)
    800011c6:	fc26                	sd	s1,56(sp)
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800011d6:	c639                	beqz	a2,80001224 <mappages+0x64>
    800011d8:	8aaa                	mv	s5,a0
    800011da:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800011dc:	777d                	lui	a4,0xfffff
    800011de:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011e2:	fff58993          	add	s3,a1,-1
    800011e6:	99b2                	add	s3,s3,a2
    800011e8:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011ec:	893e                	mv	s2,a5
    800011ee:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011f2:	6b85                	lui	s7,0x1
    800011f4:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800011f8:	4605                	li	a2,1
    800011fa:	85ca                	mv	a1,s2
    800011fc:	8556                	mv	a0,s5
    800011fe:	00000097          	auipc	ra,0x0
    80001202:	eda080e7          	jalr	-294(ra) # 800010d8 <walk>
    80001206:	cd1d                	beqz	a0,80001244 <mappages+0x84>
    if(*pte & PTE_V)
    80001208:	611c                	ld	a5,0(a0)
    8000120a:	8b85                	and	a5,a5,1
    8000120c:	e785                	bnez	a5,80001234 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000120e:	80b1                	srl	s1,s1,0xc
    80001210:	04aa                	sll	s1,s1,0xa
    80001212:	0164e4b3          	or	s1,s1,s6
    80001216:	0014e493          	or	s1,s1,1
    8000121a:	e104                	sd	s1,0(a0)
    if(a == last)
    8000121c:	05390063          	beq	s2,s3,8000125c <mappages+0x9c>
    a += PGSIZE;
    80001220:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001222:	bfc9                	j	800011f4 <mappages+0x34>
    panic("mappages: size");
    80001224:	00007517          	auipc	a0,0x7
    80001228:	ed450513          	add	a0,a0,-300 # 800080f8 <__func__.1+0xf0>
    8000122c:	fffff097          	auipc	ra,0xfffff
    80001230:	334080e7          	jalr	820(ra) # 80000560 <panic>
      panic("mappages: remap");
    80001234:	00007517          	auipc	a0,0x7
    80001238:	ed450513          	add	a0,a0,-300 # 80008108 <__func__.1+0x100>
    8000123c:	fffff097          	auipc	ra,0xfffff
    80001240:	324080e7          	jalr	804(ra) # 80000560 <panic>
      return -1;
    80001244:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001246:	60a6                	ld	ra,72(sp)
    80001248:	6406                	ld	s0,64(sp)
    8000124a:	74e2                	ld	s1,56(sp)
    8000124c:	7942                	ld	s2,48(sp)
    8000124e:	79a2                	ld	s3,40(sp)
    80001250:	7a02                	ld	s4,32(sp)
    80001252:	6ae2                	ld	s5,24(sp)
    80001254:	6b42                	ld	s6,16(sp)
    80001256:	6ba2                	ld	s7,8(sp)
    80001258:	6161                	add	sp,sp,80
    8000125a:	8082                	ret
  return 0;
    8000125c:	4501                	li	a0,0
    8000125e:	b7e5                	j	80001246 <mappages+0x86>

0000000080001260 <kvmmap>:
{
    80001260:	1141                	add	sp,sp,-16
    80001262:	e406                	sd	ra,8(sp)
    80001264:	e022                	sd	s0,0(sp)
    80001266:	0800                	add	s0,sp,16
    80001268:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000126a:	86b2                	mv	a3,a2
    8000126c:	863e                	mv	a2,a5
    8000126e:	00000097          	auipc	ra,0x0
    80001272:	f52080e7          	jalr	-174(ra) # 800011c0 <mappages>
    80001276:	e509                	bnez	a0,80001280 <kvmmap+0x20>
}
    80001278:	60a2                	ld	ra,8(sp)
    8000127a:	6402                	ld	s0,0(sp)
    8000127c:	0141                	add	sp,sp,16
    8000127e:	8082                	ret
    panic("kvmmap");
    80001280:	00007517          	auipc	a0,0x7
    80001284:	e9850513          	add	a0,a0,-360 # 80008118 <__func__.1+0x110>
    80001288:	fffff097          	auipc	ra,0xfffff
    8000128c:	2d8080e7          	jalr	728(ra) # 80000560 <panic>

0000000080001290 <kvmmake>:
{
    80001290:	1101                	add	sp,sp,-32
    80001292:	ec06                	sd	ra,24(sp)
    80001294:	e822                	sd	s0,16(sp)
    80001296:	e426                	sd	s1,8(sp)
    80001298:	e04a                	sd	s2,0(sp)
    8000129a:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	928080e7          	jalr	-1752(ra) # 80000bc4 <kalloc>
    800012a4:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012a6:	6605                	lui	a2,0x1
    800012a8:	4581                	li	a1,0
    800012aa:	00000097          	auipc	ra,0x0
    800012ae:	b52080e7          	jalr	-1198(ra) # 80000dfc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012b2:	4719                	li	a4,6
    800012b4:	6685                	lui	a3,0x1
    800012b6:	10000637          	lui	a2,0x10000
    800012ba:	100005b7          	lui	a1,0x10000
    800012be:	8526                	mv	a0,s1
    800012c0:	00000097          	auipc	ra,0x0
    800012c4:	fa0080e7          	jalr	-96(ra) # 80001260 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012c8:	4719                	li	a4,6
    800012ca:	6685                	lui	a3,0x1
    800012cc:	10001637          	lui	a2,0x10001
    800012d0:	100015b7          	lui	a1,0x10001
    800012d4:	8526                	mv	a0,s1
    800012d6:	00000097          	auipc	ra,0x0
    800012da:	f8a080e7          	jalr	-118(ra) # 80001260 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012de:	4719                	li	a4,6
    800012e0:	004006b7          	lui	a3,0x400
    800012e4:	0c000637          	lui	a2,0xc000
    800012e8:	0c0005b7          	lui	a1,0xc000
    800012ec:	8526                	mv	a0,s1
    800012ee:	00000097          	auipc	ra,0x0
    800012f2:	f72080e7          	jalr	-142(ra) # 80001260 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012f6:	00007917          	auipc	s2,0x7
    800012fa:	d0a90913          	add	s2,s2,-758 # 80008000 <etext>
    800012fe:	4729                	li	a4,10
    80001300:	80007697          	auipc	a3,0x80007
    80001304:	d0068693          	add	a3,a3,-768 # 8000 <_entry-0x7fff8000>
    80001308:	4605                	li	a2,1
    8000130a:	067e                	sll	a2,a2,0x1f
    8000130c:	85b2                	mv	a1,a2
    8000130e:	8526                	mv	a0,s1
    80001310:	00000097          	auipc	ra,0x0
    80001314:	f50080e7          	jalr	-176(ra) # 80001260 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001318:	46c5                	li	a3,17
    8000131a:	06ee                	sll	a3,a3,0x1b
    8000131c:	4719                	li	a4,6
    8000131e:	412686b3          	sub	a3,a3,s2
    80001322:	864a                	mv	a2,s2
    80001324:	85ca                	mv	a1,s2
    80001326:	8526                	mv	a0,s1
    80001328:	00000097          	auipc	ra,0x0
    8000132c:	f38080e7          	jalr	-200(ra) # 80001260 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001330:	4729                	li	a4,10
    80001332:	6685                	lui	a3,0x1
    80001334:	00006617          	auipc	a2,0x6
    80001338:	ccc60613          	add	a2,a2,-820 # 80007000 <_trampoline>
    8000133c:	040005b7          	lui	a1,0x4000
    80001340:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001342:	05b2                	sll	a1,a1,0xc
    80001344:	8526                	mv	a0,s1
    80001346:	00000097          	auipc	ra,0x0
    8000134a:	f1a080e7          	jalr	-230(ra) # 80001260 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000134e:	8526                	mv	a0,s1
    80001350:	00000097          	auipc	ra,0x0
    80001354:	700080e7          	jalr	1792(ra) # 80001a50 <proc_mapstacks>
}
    80001358:	8526                	mv	a0,s1
    8000135a:	60e2                	ld	ra,24(sp)
    8000135c:	6442                	ld	s0,16(sp)
    8000135e:	64a2                	ld	s1,8(sp)
    80001360:	6902                	ld	s2,0(sp)
    80001362:	6105                	add	sp,sp,32
    80001364:	8082                	ret

0000000080001366 <kvminit>:
{
    80001366:	1141                	add	sp,sp,-16
    80001368:	e406                	sd	ra,8(sp)
    8000136a:	e022                	sd	s0,0(sp)
    8000136c:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    8000136e:	00000097          	auipc	ra,0x0
    80001372:	f22080e7          	jalr	-222(ra) # 80001290 <kvmmake>
    80001376:	00007797          	auipc	a5,0x7
    8000137a:	70a7b523          	sd	a0,1802(a5) # 80008a80 <kernel_pagetable>
}
    8000137e:	60a2                	ld	ra,8(sp)
    80001380:	6402                	ld	s0,0(sp)
    80001382:	0141                	add	sp,sp,16
    80001384:	8082                	ret

0000000080001386 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001386:	715d                	add	sp,sp,-80
    80001388:	e486                	sd	ra,72(sp)
    8000138a:	e0a2                	sd	s0,64(sp)
    8000138c:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000138e:	03459793          	sll	a5,a1,0x34
    80001392:	e39d                	bnez	a5,800013b8 <uvmunmap+0x32>
    80001394:	f84a                	sd	s2,48(sp)
    80001396:	f44e                	sd	s3,40(sp)
    80001398:	f052                	sd	s4,32(sp)
    8000139a:	ec56                	sd	s5,24(sp)
    8000139c:	e85a                	sd	s6,16(sp)
    8000139e:	e45e                	sd	s7,8(sp)
    800013a0:	8a2a                	mv	s4,a0
    800013a2:	892e                	mv	s2,a1
    800013a4:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013a6:	0632                	sll	a2,a2,0xc
    800013a8:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800013ac:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013ae:	6b05                	lui	s6,0x1
    800013b0:	0935fb63          	bgeu	a1,s3,80001446 <uvmunmap+0xc0>
    800013b4:	fc26                	sd	s1,56(sp)
    800013b6:	a8a9                	j	80001410 <uvmunmap+0x8a>
    800013b8:	fc26                	sd	s1,56(sp)
    800013ba:	f84a                	sd	s2,48(sp)
    800013bc:	f44e                	sd	s3,40(sp)
    800013be:	f052                	sd	s4,32(sp)
    800013c0:	ec56                	sd	s5,24(sp)
    800013c2:	e85a                	sd	s6,16(sp)
    800013c4:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800013c6:	00007517          	auipc	a0,0x7
    800013ca:	d5a50513          	add	a0,a0,-678 # 80008120 <__func__.1+0x118>
    800013ce:	fffff097          	auipc	ra,0xfffff
    800013d2:	192080e7          	jalr	402(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    800013d6:	00007517          	auipc	a0,0x7
    800013da:	d6250513          	add	a0,a0,-670 # 80008138 <__func__.1+0x130>
    800013de:	fffff097          	auipc	ra,0xfffff
    800013e2:	182080e7          	jalr	386(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    800013e6:	00007517          	auipc	a0,0x7
    800013ea:	d6250513          	add	a0,a0,-670 # 80008148 <__func__.1+0x140>
    800013ee:	fffff097          	auipc	ra,0xfffff
    800013f2:	172080e7          	jalr	370(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    800013f6:	00007517          	auipc	a0,0x7
    800013fa:	d6a50513          	add	a0,a0,-662 # 80008160 <__func__.1+0x158>
    800013fe:	fffff097          	auipc	ra,0xfffff
    80001402:	162080e7          	jalr	354(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001406:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000140a:	995a                	add	s2,s2,s6
    8000140c:	03397c63          	bgeu	s2,s3,80001444 <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001410:	4601                	li	a2,0
    80001412:	85ca                	mv	a1,s2
    80001414:	8552                	mv	a0,s4
    80001416:	00000097          	auipc	ra,0x0
    8000141a:	cc2080e7          	jalr	-830(ra) # 800010d8 <walk>
    8000141e:	84aa                	mv	s1,a0
    80001420:	d95d                	beqz	a0,800013d6 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001422:	6108                	ld	a0,0(a0)
    80001424:	00157793          	and	a5,a0,1
    80001428:	dfdd                	beqz	a5,800013e6 <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000142a:	3ff57793          	and	a5,a0,1023
    8000142e:	fd7784e3          	beq	a5,s7,800013f6 <uvmunmap+0x70>
    if(do_free){
    80001432:	fc0a8ae3          	beqz	s5,80001406 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    80001436:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    80001438:	0532                	sll	a0,a0,0xc
    8000143a:	fffff097          	auipc	ra,0xfffff
    8000143e:	622080e7          	jalr	1570(ra) # 80000a5c <kfree>
    80001442:	b7d1                	j	80001406 <uvmunmap+0x80>
    80001444:	74e2                	ld	s1,56(sp)
    80001446:	7942                	ld	s2,48(sp)
    80001448:	79a2                	ld	s3,40(sp)
    8000144a:	7a02                	ld	s4,32(sp)
    8000144c:	6ae2                	ld	s5,24(sp)
    8000144e:	6b42                	ld	s6,16(sp)
    80001450:	6ba2                	ld	s7,8(sp)
  }
}
    80001452:	60a6                	ld	ra,72(sp)
    80001454:	6406                	ld	s0,64(sp)
    80001456:	6161                	add	sp,sp,80
    80001458:	8082                	ret

000000008000145a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000145a:	1101                	add	sp,sp,-32
    8000145c:	ec06                	sd	ra,24(sp)
    8000145e:	e822                	sd	s0,16(sp)
    80001460:	e426                	sd	s1,8(sp)
    80001462:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001464:	fffff097          	auipc	ra,0xfffff
    80001468:	760080e7          	jalr	1888(ra) # 80000bc4 <kalloc>
    8000146c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000146e:	c519                	beqz	a0,8000147c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001470:	6605                	lui	a2,0x1
    80001472:	4581                	li	a1,0
    80001474:	00000097          	auipc	ra,0x0
    80001478:	988080e7          	jalr	-1656(ra) # 80000dfc <memset>
  return pagetable;
}
    8000147c:	8526                	mv	a0,s1
    8000147e:	60e2                	ld	ra,24(sp)
    80001480:	6442                	ld	s0,16(sp)
    80001482:	64a2                	ld	s1,8(sp)
    80001484:	6105                	add	sp,sp,32
    80001486:	8082                	ret

0000000080001488 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001488:	7179                	add	sp,sp,-48
    8000148a:	f406                	sd	ra,40(sp)
    8000148c:	f022                	sd	s0,32(sp)
    8000148e:	ec26                	sd	s1,24(sp)
    80001490:	e84a                	sd	s2,16(sp)
    80001492:	e44e                	sd	s3,8(sp)
    80001494:	e052                	sd	s4,0(sp)
    80001496:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001498:	6785                	lui	a5,0x1
    8000149a:	04f67863          	bgeu	a2,a5,800014ea <uvmfirst+0x62>
    8000149e:	8a2a                	mv	s4,a0
    800014a0:	89ae                	mv	s3,a1
    800014a2:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800014a4:	fffff097          	auipc	ra,0xfffff
    800014a8:	720080e7          	jalr	1824(ra) # 80000bc4 <kalloc>
    800014ac:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014ae:	6605                	lui	a2,0x1
    800014b0:	4581                	li	a1,0
    800014b2:	00000097          	auipc	ra,0x0
    800014b6:	94a080e7          	jalr	-1718(ra) # 80000dfc <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014ba:	4779                	li	a4,30
    800014bc:	86ca                	mv	a3,s2
    800014be:	6605                	lui	a2,0x1
    800014c0:	4581                	li	a1,0
    800014c2:	8552                	mv	a0,s4
    800014c4:	00000097          	auipc	ra,0x0
    800014c8:	cfc080e7          	jalr	-772(ra) # 800011c0 <mappages>
  memmove(mem, src, sz);
    800014cc:	8626                	mv	a2,s1
    800014ce:	85ce                	mv	a1,s3
    800014d0:	854a                	mv	a0,s2
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	986080e7          	jalr	-1658(ra) # 80000e58 <memmove>
}
    800014da:	70a2                	ld	ra,40(sp)
    800014dc:	7402                	ld	s0,32(sp)
    800014de:	64e2                	ld	s1,24(sp)
    800014e0:	6942                	ld	s2,16(sp)
    800014e2:	69a2                	ld	s3,8(sp)
    800014e4:	6a02                	ld	s4,0(sp)
    800014e6:	6145                	add	sp,sp,48
    800014e8:	8082                	ret
    panic("uvmfirst: more than a page");
    800014ea:	00007517          	auipc	a0,0x7
    800014ee:	c8e50513          	add	a0,a0,-882 # 80008178 <__func__.1+0x170>
    800014f2:	fffff097          	auipc	ra,0xfffff
    800014f6:	06e080e7          	jalr	110(ra) # 80000560 <panic>

00000000800014fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800014fa:	1101                	add	sp,sp,-32
    800014fc:	ec06                	sd	ra,24(sp)
    800014fe:	e822                	sd	s0,16(sp)
    80001500:	e426                	sd	s1,8(sp)
    80001502:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001504:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001506:	00b67d63          	bgeu	a2,a1,80001520 <uvmdealloc+0x26>
    8000150a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000150c:	6785                	lui	a5,0x1
    8000150e:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001510:	00f60733          	add	a4,a2,a5
    80001514:	76fd                	lui	a3,0xfffff
    80001516:	8f75                	and	a4,a4,a3
    80001518:	97ae                	add	a5,a5,a1
    8000151a:	8ff5                	and	a5,a5,a3
    8000151c:	00f76863          	bltu	a4,a5,8000152c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001520:	8526                	mv	a0,s1
    80001522:	60e2                	ld	ra,24(sp)
    80001524:	6442                	ld	s0,16(sp)
    80001526:	64a2                	ld	s1,8(sp)
    80001528:	6105                	add	sp,sp,32
    8000152a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000152c:	8f99                	sub	a5,a5,a4
    8000152e:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001530:	4685                	li	a3,1
    80001532:	0007861b          	sext.w	a2,a5
    80001536:	85ba                	mv	a1,a4
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	e4e080e7          	jalr	-434(ra) # 80001386 <uvmunmap>
    80001540:	b7c5                	j	80001520 <uvmdealloc+0x26>

0000000080001542 <uvmalloc>:
  if(newsz < oldsz)
    80001542:	0ab66b63          	bltu	a2,a1,800015f8 <uvmalloc+0xb6>
{
    80001546:	7139                	add	sp,sp,-64
    80001548:	fc06                	sd	ra,56(sp)
    8000154a:	f822                	sd	s0,48(sp)
    8000154c:	ec4e                	sd	s3,24(sp)
    8000154e:	e852                	sd	s4,16(sp)
    80001550:	e456                	sd	s5,8(sp)
    80001552:	0080                	add	s0,sp,64
    80001554:	8aaa                	mv	s5,a0
    80001556:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001558:	6785                	lui	a5,0x1
    8000155a:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000155c:	95be                	add	a1,a1,a5
    8000155e:	77fd                	lui	a5,0xfffff
    80001560:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001564:	08c9fc63          	bgeu	s3,a2,800015fc <uvmalloc+0xba>
    80001568:	f426                	sd	s1,40(sp)
    8000156a:	f04a                	sd	s2,32(sp)
    8000156c:	e05a                	sd	s6,0(sp)
    8000156e:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001570:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    80001574:	fffff097          	auipc	ra,0xfffff
    80001578:	650080e7          	jalr	1616(ra) # 80000bc4 <kalloc>
    8000157c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000157e:	c915                	beqz	a0,800015b2 <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    80001580:	6605                	lui	a2,0x1
    80001582:	4581                	li	a1,0
    80001584:	00000097          	auipc	ra,0x0
    80001588:	878080e7          	jalr	-1928(ra) # 80000dfc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000158c:	875a                	mv	a4,s6
    8000158e:	86a6                	mv	a3,s1
    80001590:	6605                	lui	a2,0x1
    80001592:	85ca                	mv	a1,s2
    80001594:	8556                	mv	a0,s5
    80001596:	00000097          	auipc	ra,0x0
    8000159a:	c2a080e7          	jalr	-982(ra) # 800011c0 <mappages>
    8000159e:	ed05                	bnez	a0,800015d6 <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015a0:	6785                	lui	a5,0x1
    800015a2:	993e                	add	s2,s2,a5
    800015a4:	fd4968e3          	bltu	s2,s4,80001574 <uvmalloc+0x32>
  return newsz;
    800015a8:	8552                	mv	a0,s4
    800015aa:	74a2                	ld	s1,40(sp)
    800015ac:	7902                	ld	s2,32(sp)
    800015ae:	6b02                	ld	s6,0(sp)
    800015b0:	a821                	j	800015c8 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800015b2:	864e                	mv	a2,s3
    800015b4:	85ca                	mv	a1,s2
    800015b6:	8556                	mv	a0,s5
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	f42080e7          	jalr	-190(ra) # 800014fa <uvmdealloc>
      return 0;
    800015c0:	4501                	li	a0,0
    800015c2:	74a2                	ld	s1,40(sp)
    800015c4:	7902                	ld	s2,32(sp)
    800015c6:	6b02                	ld	s6,0(sp)
}
    800015c8:	70e2                	ld	ra,56(sp)
    800015ca:	7442                	ld	s0,48(sp)
    800015cc:	69e2                	ld	s3,24(sp)
    800015ce:	6a42                	ld	s4,16(sp)
    800015d0:	6aa2                	ld	s5,8(sp)
    800015d2:	6121                	add	sp,sp,64
    800015d4:	8082                	ret
      kfree(mem);
    800015d6:	8526                	mv	a0,s1
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	484080e7          	jalr	1156(ra) # 80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015e0:	864e                	mv	a2,s3
    800015e2:	85ca                	mv	a1,s2
    800015e4:	8556                	mv	a0,s5
    800015e6:	00000097          	auipc	ra,0x0
    800015ea:	f14080e7          	jalr	-236(ra) # 800014fa <uvmdealloc>
      return 0;
    800015ee:	4501                	li	a0,0
    800015f0:	74a2                	ld	s1,40(sp)
    800015f2:	7902                	ld	s2,32(sp)
    800015f4:	6b02                	ld	s6,0(sp)
    800015f6:	bfc9                	j	800015c8 <uvmalloc+0x86>
    return oldsz;
    800015f8:	852e                	mv	a0,a1
}
    800015fa:	8082                	ret
  return newsz;
    800015fc:	8532                	mv	a0,a2
    800015fe:	b7e9                	j	800015c8 <uvmalloc+0x86>

0000000080001600 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001600:	7179                	add	sp,sp,-48
    80001602:	f406                	sd	ra,40(sp)
    80001604:	f022                	sd	s0,32(sp)
    80001606:	ec26                	sd	s1,24(sp)
    80001608:	e84a                	sd	s2,16(sp)
    8000160a:	e44e                	sd	s3,8(sp)
    8000160c:	e052                	sd	s4,0(sp)
    8000160e:	1800                	add	s0,sp,48
    80001610:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001612:	84aa                	mv	s1,a0
    80001614:	6905                	lui	s2,0x1
    80001616:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001618:	4985                	li	s3,1
    8000161a:	a829                	j	80001634 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000161c:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000161e:	00c79513          	sll	a0,a5,0xc
    80001622:	00000097          	auipc	ra,0x0
    80001626:	fde080e7          	jalr	-34(ra) # 80001600 <freewalk>
      pagetable[i] = 0;
    8000162a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000162e:	04a1                	add	s1,s1,8
    80001630:	03248163          	beq	s1,s2,80001652 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001634:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001636:	00f7f713          	and	a4,a5,15
    8000163a:	ff3701e3          	beq	a4,s3,8000161c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000163e:	8b85                	and	a5,a5,1
    80001640:	d7fd                	beqz	a5,8000162e <freewalk+0x2e>
      panic("freewalk: leaf");
    80001642:	00007517          	auipc	a0,0x7
    80001646:	b5650513          	add	a0,a0,-1194 # 80008198 <__func__.1+0x190>
    8000164a:	fffff097          	auipc	ra,0xfffff
    8000164e:	f16080e7          	jalr	-234(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    80001652:	8552                	mv	a0,s4
    80001654:	fffff097          	auipc	ra,0xfffff
    80001658:	408080e7          	jalr	1032(ra) # 80000a5c <kfree>
}
    8000165c:	70a2                	ld	ra,40(sp)
    8000165e:	7402                	ld	s0,32(sp)
    80001660:	64e2                	ld	s1,24(sp)
    80001662:	6942                	ld	s2,16(sp)
    80001664:	69a2                	ld	s3,8(sp)
    80001666:	6a02                	ld	s4,0(sp)
    80001668:	6145                	add	sp,sp,48
    8000166a:	8082                	ret

000000008000166c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000166c:	1101                	add	sp,sp,-32
    8000166e:	ec06                	sd	ra,24(sp)
    80001670:	e822                	sd	s0,16(sp)
    80001672:	e426                	sd	s1,8(sp)
    80001674:	1000                	add	s0,sp,32
    80001676:	84aa                	mv	s1,a0
  if(sz > 0)
    80001678:	e999                	bnez	a1,8000168e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000167a:	8526                	mv	a0,s1
    8000167c:	00000097          	auipc	ra,0x0
    80001680:	f84080e7          	jalr	-124(ra) # 80001600 <freewalk>
}
    80001684:	60e2                	ld	ra,24(sp)
    80001686:	6442                	ld	s0,16(sp)
    80001688:	64a2                	ld	s1,8(sp)
    8000168a:	6105                	add	sp,sp,32
    8000168c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000168e:	6785                	lui	a5,0x1
    80001690:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001692:	95be                	add	a1,a1,a5
    80001694:	4685                	li	a3,1
    80001696:	00c5d613          	srl	a2,a1,0xc
    8000169a:	4581                	li	a1,0
    8000169c:	00000097          	auipc	ra,0x0
    800016a0:	cea080e7          	jalr	-790(ra) # 80001386 <uvmunmap>
    800016a4:	bfd9                	j	8000167a <uvmfree+0xe>

00000000800016a6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016a6:	c679                	beqz	a2,80001774 <uvmcopy+0xce>
{
    800016a8:	715d                	add	sp,sp,-80
    800016aa:	e486                	sd	ra,72(sp)
    800016ac:	e0a2                	sd	s0,64(sp)
    800016ae:	fc26                	sd	s1,56(sp)
    800016b0:	f84a                	sd	s2,48(sp)
    800016b2:	f44e                	sd	s3,40(sp)
    800016b4:	f052                	sd	s4,32(sp)
    800016b6:	ec56                	sd	s5,24(sp)
    800016b8:	e85a                	sd	s6,16(sp)
    800016ba:	e45e                	sd	s7,8(sp)
    800016bc:	0880                	add	s0,sp,80
    800016be:	8b2a                	mv	s6,a0
    800016c0:	8aae                	mv	s5,a1
    800016c2:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016c4:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800016c6:	4601                	li	a2,0
    800016c8:	85ce                	mv	a1,s3
    800016ca:	855a                	mv	a0,s6
    800016cc:	00000097          	auipc	ra,0x0
    800016d0:	a0c080e7          	jalr	-1524(ra) # 800010d8 <walk>
    800016d4:	c531                	beqz	a0,80001720 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016d6:	6118                	ld	a4,0(a0)
    800016d8:	00177793          	and	a5,a4,1
    800016dc:	cbb1                	beqz	a5,80001730 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016de:	00a75593          	srl	a1,a4,0xa
    800016e2:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016e6:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    800016ea:	fffff097          	auipc	ra,0xfffff
    800016ee:	4da080e7          	jalr	1242(ra) # 80000bc4 <kalloc>
    800016f2:	892a                	mv	s2,a0
    800016f4:	c939                	beqz	a0,8000174a <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016f6:	6605                	lui	a2,0x1
    800016f8:	85de                	mv	a1,s7
    800016fa:	fffff097          	auipc	ra,0xfffff
    800016fe:	75e080e7          	jalr	1886(ra) # 80000e58 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001702:	8726                	mv	a4,s1
    80001704:	86ca                	mv	a3,s2
    80001706:	6605                	lui	a2,0x1
    80001708:	85ce                	mv	a1,s3
    8000170a:	8556                	mv	a0,s5
    8000170c:	00000097          	auipc	ra,0x0
    80001710:	ab4080e7          	jalr	-1356(ra) # 800011c0 <mappages>
    80001714:	e515                	bnez	a0,80001740 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001716:	6785                	lui	a5,0x1
    80001718:	99be                	add	s3,s3,a5
    8000171a:	fb49e6e3          	bltu	s3,s4,800016c6 <uvmcopy+0x20>
    8000171e:	a081                	j	8000175e <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001720:	00007517          	auipc	a0,0x7
    80001724:	a8850513          	add	a0,a0,-1400 # 800081a8 <__func__.1+0x1a0>
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	e38080e7          	jalr	-456(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001730:	00007517          	auipc	a0,0x7
    80001734:	a9850513          	add	a0,a0,-1384 # 800081c8 <__func__.1+0x1c0>
    80001738:	fffff097          	auipc	ra,0xfffff
    8000173c:	e28080e7          	jalr	-472(ra) # 80000560 <panic>
      kfree(mem);
    80001740:	854a                	mv	a0,s2
    80001742:	fffff097          	auipc	ra,0xfffff
    80001746:	31a080e7          	jalr	794(ra) # 80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000174a:	4685                	li	a3,1
    8000174c:	00c9d613          	srl	a2,s3,0xc
    80001750:	4581                	li	a1,0
    80001752:	8556                	mv	a0,s5
    80001754:	00000097          	auipc	ra,0x0
    80001758:	c32080e7          	jalr	-974(ra) # 80001386 <uvmunmap>
  return -1;
    8000175c:	557d                	li	a0,-1
}
    8000175e:	60a6                	ld	ra,72(sp)
    80001760:	6406                	ld	s0,64(sp)
    80001762:	74e2                	ld	s1,56(sp)
    80001764:	7942                	ld	s2,48(sp)
    80001766:	79a2                	ld	s3,40(sp)
    80001768:	7a02                	ld	s4,32(sp)
    8000176a:	6ae2                	ld	s5,24(sp)
    8000176c:	6b42                	ld	s6,16(sp)
    8000176e:	6ba2                	ld	s7,8(sp)
    80001770:	6161                	add	sp,sp,80
    80001772:	8082                	ret
  return 0;
    80001774:	4501                	li	a0,0
}
    80001776:	8082                	ret

0000000080001778 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001778:	1141                	add	sp,sp,-16
    8000177a:	e406                	sd	ra,8(sp)
    8000177c:	e022                	sd	s0,0(sp)
    8000177e:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001780:	4601                	li	a2,0
    80001782:	00000097          	auipc	ra,0x0
    80001786:	956080e7          	jalr	-1706(ra) # 800010d8 <walk>
  if(pte == 0)
    8000178a:	c901                	beqz	a0,8000179a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000178c:	611c                	ld	a5,0(a0)
    8000178e:	9bbd                	and	a5,a5,-17
    80001790:	e11c                	sd	a5,0(a0)
}
    80001792:	60a2                	ld	ra,8(sp)
    80001794:	6402                	ld	s0,0(sp)
    80001796:	0141                	add	sp,sp,16
    80001798:	8082                	ret
    panic("uvmclear");
    8000179a:	00007517          	auipc	a0,0x7
    8000179e:	a4e50513          	add	a0,a0,-1458 # 800081e8 <__func__.1+0x1e0>
    800017a2:	fffff097          	auipc	ra,0xfffff
    800017a6:	dbe080e7          	jalr	-578(ra) # 80000560 <panic>

00000000800017aa <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017aa:	c6bd                	beqz	a3,80001818 <copyout+0x6e>
{
    800017ac:	715d                	add	sp,sp,-80
    800017ae:	e486                	sd	ra,72(sp)
    800017b0:	e0a2                	sd	s0,64(sp)
    800017b2:	fc26                	sd	s1,56(sp)
    800017b4:	f84a                	sd	s2,48(sp)
    800017b6:	f44e                	sd	s3,40(sp)
    800017b8:	f052                	sd	s4,32(sp)
    800017ba:	ec56                	sd	s5,24(sp)
    800017bc:	e85a                	sd	s6,16(sp)
    800017be:	e45e                	sd	s7,8(sp)
    800017c0:	e062                	sd	s8,0(sp)
    800017c2:	0880                	add	s0,sp,80
    800017c4:	8b2a                	mv	s6,a0
    800017c6:	8c2e                	mv	s8,a1
    800017c8:	8a32                	mv	s4,a2
    800017ca:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800017cc:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800017ce:	6a85                	lui	s5,0x1
    800017d0:	a015                	j	800017f4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017d2:	9562                	add	a0,a0,s8
    800017d4:	0004861b          	sext.w	a2,s1
    800017d8:	85d2                	mv	a1,s4
    800017da:	41250533          	sub	a0,a0,s2
    800017de:	fffff097          	auipc	ra,0xfffff
    800017e2:	67a080e7          	jalr	1658(ra) # 80000e58 <memmove>

    len -= n;
    800017e6:	409989b3          	sub	s3,s3,s1
    src += n;
    800017ea:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800017ec:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017f0:	02098263          	beqz	s3,80001814 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800017f4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017f8:	85ca                	mv	a1,s2
    800017fa:	855a                	mv	a0,s6
    800017fc:	00000097          	auipc	ra,0x0
    80001800:	982080e7          	jalr	-1662(ra) # 8000117e <walkaddr>
    if(pa0 == 0)
    80001804:	cd01                	beqz	a0,8000181c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001806:	418904b3          	sub	s1,s2,s8
    8000180a:	94d6                	add	s1,s1,s5
    if(n > len)
    8000180c:	fc99f3e3          	bgeu	s3,s1,800017d2 <copyout+0x28>
    80001810:	84ce                	mv	s1,s3
    80001812:	b7c1                	j	800017d2 <copyout+0x28>
  }
  return 0;
    80001814:	4501                	li	a0,0
    80001816:	a021                	j	8000181e <copyout+0x74>
    80001818:	4501                	li	a0,0
}
    8000181a:	8082                	ret
      return -1;
    8000181c:	557d                	li	a0,-1
}
    8000181e:	60a6                	ld	ra,72(sp)
    80001820:	6406                	ld	s0,64(sp)
    80001822:	74e2                	ld	s1,56(sp)
    80001824:	7942                	ld	s2,48(sp)
    80001826:	79a2                	ld	s3,40(sp)
    80001828:	7a02                	ld	s4,32(sp)
    8000182a:	6ae2                	ld	s5,24(sp)
    8000182c:	6b42                	ld	s6,16(sp)
    8000182e:	6ba2                	ld	s7,8(sp)
    80001830:	6c02                	ld	s8,0(sp)
    80001832:	6161                	add	sp,sp,80
    80001834:	8082                	ret

0000000080001836 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001836:	caa5                	beqz	a3,800018a6 <copyin+0x70>
{
    80001838:	715d                	add	sp,sp,-80
    8000183a:	e486                	sd	ra,72(sp)
    8000183c:	e0a2                	sd	s0,64(sp)
    8000183e:	fc26                	sd	s1,56(sp)
    80001840:	f84a                	sd	s2,48(sp)
    80001842:	f44e                	sd	s3,40(sp)
    80001844:	f052                	sd	s4,32(sp)
    80001846:	ec56                	sd	s5,24(sp)
    80001848:	e85a                	sd	s6,16(sp)
    8000184a:	e45e                	sd	s7,8(sp)
    8000184c:	e062                	sd	s8,0(sp)
    8000184e:	0880                	add	s0,sp,80
    80001850:	8b2a                	mv	s6,a0
    80001852:	8a2e                	mv	s4,a1
    80001854:	8c32                	mv	s8,a2
    80001856:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001858:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000185a:	6a85                	lui	s5,0x1
    8000185c:	a01d                	j	80001882 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000185e:	018505b3          	add	a1,a0,s8
    80001862:	0004861b          	sext.w	a2,s1
    80001866:	412585b3          	sub	a1,a1,s2
    8000186a:	8552                	mv	a0,s4
    8000186c:	fffff097          	auipc	ra,0xfffff
    80001870:	5ec080e7          	jalr	1516(ra) # 80000e58 <memmove>

    len -= n;
    80001874:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001878:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000187a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000187e:	02098263          	beqz	s3,800018a2 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001882:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001886:	85ca                	mv	a1,s2
    80001888:	855a                	mv	a0,s6
    8000188a:	00000097          	auipc	ra,0x0
    8000188e:	8f4080e7          	jalr	-1804(ra) # 8000117e <walkaddr>
    if(pa0 == 0)
    80001892:	cd01                	beqz	a0,800018aa <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001894:	418904b3          	sub	s1,s2,s8
    80001898:	94d6                	add	s1,s1,s5
    if(n > len)
    8000189a:	fc99f2e3          	bgeu	s3,s1,8000185e <copyin+0x28>
    8000189e:	84ce                	mv	s1,s3
    800018a0:	bf7d                	j	8000185e <copyin+0x28>
  }
  return 0;
    800018a2:	4501                	li	a0,0
    800018a4:	a021                	j	800018ac <copyin+0x76>
    800018a6:	4501                	li	a0,0
}
    800018a8:	8082                	ret
      return -1;
    800018aa:	557d                	li	a0,-1
}
    800018ac:	60a6                	ld	ra,72(sp)
    800018ae:	6406                	ld	s0,64(sp)
    800018b0:	74e2                	ld	s1,56(sp)
    800018b2:	7942                	ld	s2,48(sp)
    800018b4:	79a2                	ld	s3,40(sp)
    800018b6:	7a02                	ld	s4,32(sp)
    800018b8:	6ae2                	ld	s5,24(sp)
    800018ba:	6b42                	ld	s6,16(sp)
    800018bc:	6ba2                	ld	s7,8(sp)
    800018be:	6c02                	ld	s8,0(sp)
    800018c0:	6161                	add	sp,sp,80
    800018c2:	8082                	ret

00000000800018c4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800018c4:	cacd                	beqz	a3,80001976 <copyinstr+0xb2>
{
    800018c6:	715d                	add	sp,sp,-80
    800018c8:	e486                	sd	ra,72(sp)
    800018ca:	e0a2                	sd	s0,64(sp)
    800018cc:	fc26                	sd	s1,56(sp)
    800018ce:	f84a                	sd	s2,48(sp)
    800018d0:	f44e                	sd	s3,40(sp)
    800018d2:	f052                	sd	s4,32(sp)
    800018d4:	ec56                	sd	s5,24(sp)
    800018d6:	e85a                	sd	s6,16(sp)
    800018d8:	e45e                	sd	s7,8(sp)
    800018da:	0880                	add	s0,sp,80
    800018dc:	8a2a                	mv	s4,a0
    800018de:	8b2e                	mv	s6,a1
    800018e0:	8bb2                	mv	s7,a2
    800018e2:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800018e4:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018e6:	6985                	lui	s3,0x1
    800018e8:	a825                	j	80001920 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800018ea:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800018ee:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800018f0:	37fd                	addw	a5,a5,-1
    800018f2:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800018f6:	60a6                	ld	ra,72(sp)
    800018f8:	6406                	ld	s0,64(sp)
    800018fa:	74e2                	ld	s1,56(sp)
    800018fc:	7942                	ld	s2,48(sp)
    800018fe:	79a2                	ld	s3,40(sp)
    80001900:	7a02                	ld	s4,32(sp)
    80001902:	6ae2                	ld	s5,24(sp)
    80001904:	6b42                	ld	s6,16(sp)
    80001906:	6ba2                	ld	s7,8(sp)
    80001908:	6161                	add	sp,sp,80
    8000190a:	8082                	ret
    8000190c:	fff90713          	add	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001910:	9742                	add	a4,a4,a6
      --max;
    80001912:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001916:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    8000191a:	04e58663          	beq	a1,a4,80001966 <copyinstr+0xa2>
{
    8000191e:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001920:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001924:	85a6                	mv	a1,s1
    80001926:	8552                	mv	a0,s4
    80001928:	00000097          	auipc	ra,0x0
    8000192c:	856080e7          	jalr	-1962(ra) # 8000117e <walkaddr>
    if(pa0 == 0)
    80001930:	cd0d                	beqz	a0,8000196a <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80001932:	417486b3          	sub	a3,s1,s7
    80001936:	96ce                	add	a3,a3,s3
    if(n > max)
    80001938:	00d97363          	bgeu	s2,a3,8000193e <copyinstr+0x7a>
    8000193c:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    8000193e:	955e                	add	a0,a0,s7
    80001940:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001942:	c695                	beqz	a3,8000196e <copyinstr+0xaa>
    80001944:	87da                	mv	a5,s6
    80001946:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001948:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000194c:	96da                	add	a3,a3,s6
    8000194e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001950:	00f60733          	add	a4,a2,a5
    80001954:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd0f0>
    80001958:	db49                	beqz	a4,800018ea <copyinstr+0x26>
        *dst = *p;
    8000195a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000195e:	0785                	add	a5,a5,1
    while(n > 0){
    80001960:	fed797e3          	bne	a5,a3,8000194e <copyinstr+0x8a>
    80001964:	b765                	j	8000190c <copyinstr+0x48>
    80001966:	4781                	li	a5,0
    80001968:	b761                	j	800018f0 <copyinstr+0x2c>
      return -1;
    8000196a:	557d                	li	a0,-1
    8000196c:	b769                	j	800018f6 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000196e:	6b85                	lui	s7,0x1
    80001970:	9ba6                	add	s7,s7,s1
    80001972:	87da                	mv	a5,s6
    80001974:	b76d                	j	8000191e <copyinstr+0x5a>
  int got_null = 0;
    80001976:	4781                	li	a5,0
  if(got_null){
    80001978:	37fd                	addw	a5,a5,-1
    8000197a:	0007851b          	sext.w	a0,a5
}
    8000197e:	8082                	ret

0000000080001980 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001980:	715d                	add	sp,sp,-80
    80001982:	e486                	sd	ra,72(sp)
    80001984:	e0a2                	sd	s0,64(sp)
    80001986:	fc26                	sd	s1,56(sp)
    80001988:	f84a                	sd	s2,48(sp)
    8000198a:	f44e                	sd	s3,40(sp)
    8000198c:	f052                	sd	s4,32(sp)
    8000198e:	ec56                	sd	s5,24(sp)
    80001990:	e85a                	sd	s6,16(sp)
    80001992:	e45e                	sd	s7,8(sp)
    80001994:	e062                	sd	s8,0(sp)
    80001996:	0880                	add	s0,sp,80
  asm volatile("mv %0, tp" : "=r" (x) );
    80001998:	8792                	mv	a5,tp
    int id = r_tp();
    8000199a:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    8000199c:	0000fa97          	auipc	s5,0xf
    800019a0:	364a8a93          	add	s5,s5,868 # 80010d00 <cpus>
    800019a4:	00779713          	sll	a4,a5,0x7
    800019a8:	00ea86b3          	add	a3,s5,a4
    800019ac:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffdd0f0>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    800019b0:	0721                	add	a4,a4,8
    800019b2:	9aba                	add	s5,s5,a4
                c->proc = p;
    800019b4:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    800019b6:	00007c17          	auipc	s8,0x7
    800019ba:	022c0c13          	add	s8,s8,34 # 800089d8 <sched_pointer>
    800019be:	00000b97          	auipc	s7,0x0
    800019c2:	fc2b8b93          	add	s7,s7,-62 # 80001980 <rr_scheduler>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800019c6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800019ca:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800019ce:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    800019d2:	0000f497          	auipc	s1,0xf
    800019d6:	75e48493          	add	s1,s1,1886 # 80011130 <proc>
            if (p->state == RUNNABLE)
    800019da:	498d                	li	s3,3
                p->state = RUNNING;
    800019dc:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    800019de:	00015a17          	auipc	s4,0x15
    800019e2:	152a0a13          	add	s4,s4,338 # 80016b30 <tickslock>
    800019e6:	a81d                	j	80001a1c <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    800019e8:	8526                	mv	a0,s1
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	3ca080e7          	jalr	970(ra) # 80000db4 <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    800019f2:	60a6                	ld	ra,72(sp)
    800019f4:	6406                	ld	s0,64(sp)
    800019f6:	74e2                	ld	s1,56(sp)
    800019f8:	7942                	ld	s2,48(sp)
    800019fa:	79a2                	ld	s3,40(sp)
    800019fc:	7a02                	ld	s4,32(sp)
    800019fe:	6ae2                	ld	s5,24(sp)
    80001a00:	6b42                	ld	s6,16(sp)
    80001a02:	6ba2                	ld	s7,8(sp)
    80001a04:	6c02                	ld	s8,0(sp)
    80001a06:	6161                	add	sp,sp,80
    80001a08:	8082                	ret
            release(&p->lock);
    80001a0a:	8526                	mv	a0,s1
    80001a0c:	fffff097          	auipc	ra,0xfffff
    80001a10:	3a8080e7          	jalr	936(ra) # 80000db4 <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001a14:	16848493          	add	s1,s1,360
    80001a18:	fb4487e3          	beq	s1,s4,800019c6 <rr_scheduler+0x46>
            acquire(&p->lock);
    80001a1c:	8526                	mv	a0,s1
    80001a1e:	fffff097          	auipc	ra,0xfffff
    80001a22:	2e2080e7          	jalr	738(ra) # 80000d00 <acquire>
            if (p->state == RUNNABLE)
    80001a26:	4c9c                	lw	a5,24(s1)
    80001a28:	ff3791e3          	bne	a5,s3,80001a0a <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001a2c:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001a30:	00993023          	sd	s1,0(s2)
                swtch(&c->context, &p->context);
    80001a34:	06048593          	add	a1,s1,96
    80001a38:	8556                	mv	a0,s5
    80001a3a:	00001097          	auipc	ra,0x1
    80001a3e:	fc4080e7          	jalr	-60(ra) # 800029fe <swtch>
                if (sched_pointer != &rr_scheduler)
    80001a42:	000c3783          	ld	a5,0(s8)
    80001a46:	fb7791e3          	bne	a5,s7,800019e8 <rr_scheduler+0x68>
                c->proc = 0;
    80001a4a:	00093023          	sd	zero,0(s2)
    80001a4e:	bf75                	j	80001a0a <rr_scheduler+0x8a>

0000000080001a50 <proc_mapstacks>:
{
    80001a50:	7139                	add	sp,sp,-64
    80001a52:	fc06                	sd	ra,56(sp)
    80001a54:	f822                	sd	s0,48(sp)
    80001a56:	f426                	sd	s1,40(sp)
    80001a58:	f04a                	sd	s2,32(sp)
    80001a5a:	ec4e                	sd	s3,24(sp)
    80001a5c:	e852                	sd	s4,16(sp)
    80001a5e:	e456                	sd	s5,8(sp)
    80001a60:	e05a                	sd	s6,0(sp)
    80001a62:	0080                	add	s0,sp,64
    80001a64:	8a2a                	mv	s4,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001a66:	0000f497          	auipc	s1,0xf
    80001a6a:	6ca48493          	add	s1,s1,1738 # 80011130 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001a6e:	8b26                	mv	s6,s1
    80001a70:	04fa5937          	lui	s2,0x4fa5
    80001a74:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001a78:	0932                	sll	s2,s2,0xc
    80001a7a:	fa590913          	add	s2,s2,-91
    80001a7e:	0932                	sll	s2,s2,0xc
    80001a80:	fa590913          	add	s2,s2,-91
    80001a84:	0932                	sll	s2,s2,0xc
    80001a86:	fa590913          	add	s2,s2,-91
    80001a8a:	040009b7          	lui	s3,0x4000
    80001a8e:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a90:	09b2                	sll	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001a92:	00015a97          	auipc	s5,0x15
    80001a96:	09ea8a93          	add	s5,s5,158 # 80016b30 <tickslock>
        char *pa = kalloc();
    80001a9a:	fffff097          	auipc	ra,0xfffff
    80001a9e:	12a080e7          	jalr	298(ra) # 80000bc4 <kalloc>
    80001aa2:	862a                	mv	a2,a0
        if (pa == 0)
    80001aa4:	c121                	beqz	a0,80001ae4 <proc_mapstacks+0x94>
        uint64 va = KSTACK((int)(p - proc));
    80001aa6:	416485b3          	sub	a1,s1,s6
    80001aaa:	858d                	sra	a1,a1,0x3
    80001aac:	032585b3          	mul	a1,a1,s2
    80001ab0:	2585                	addw	a1,a1,1
    80001ab2:	00d5959b          	sllw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001ab6:	4719                	li	a4,6
    80001ab8:	6685                	lui	a3,0x1
    80001aba:	40b985b3          	sub	a1,s3,a1
    80001abe:	8552                	mv	a0,s4
    80001ac0:	fffff097          	auipc	ra,0xfffff
    80001ac4:	7a0080e7          	jalr	1952(ra) # 80001260 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001ac8:	16848493          	add	s1,s1,360
    80001acc:	fd5497e3          	bne	s1,s5,80001a9a <proc_mapstacks+0x4a>
}
    80001ad0:	70e2                	ld	ra,56(sp)
    80001ad2:	7442                	ld	s0,48(sp)
    80001ad4:	74a2                	ld	s1,40(sp)
    80001ad6:	7902                	ld	s2,32(sp)
    80001ad8:	69e2                	ld	s3,24(sp)
    80001ada:	6a42                	ld	s4,16(sp)
    80001adc:	6aa2                	ld	s5,8(sp)
    80001ade:	6b02                	ld	s6,0(sp)
    80001ae0:	6121                	add	sp,sp,64
    80001ae2:	8082                	ret
            panic("kalloc");
    80001ae4:	00006517          	auipc	a0,0x6
    80001ae8:	71450513          	add	a0,a0,1812 # 800081f8 <__func__.1+0x1f0>
    80001aec:	fffff097          	auipc	ra,0xfffff
    80001af0:	a74080e7          	jalr	-1420(ra) # 80000560 <panic>

0000000080001af4 <procinit>:
{
    80001af4:	7139                	add	sp,sp,-64
    80001af6:	fc06                	sd	ra,56(sp)
    80001af8:	f822                	sd	s0,48(sp)
    80001afa:	f426                	sd	s1,40(sp)
    80001afc:	f04a                	sd	s2,32(sp)
    80001afe:	ec4e                	sd	s3,24(sp)
    80001b00:	e852                	sd	s4,16(sp)
    80001b02:	e456                	sd	s5,8(sp)
    80001b04:	e05a                	sd	s6,0(sp)
    80001b06:	0080                	add	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001b08:	00006597          	auipc	a1,0x6
    80001b0c:	6f858593          	add	a1,a1,1784 # 80008200 <__func__.1+0x1f8>
    80001b10:	0000f517          	auipc	a0,0xf
    80001b14:	5f050513          	add	a0,a0,1520 # 80011100 <pid_lock>
    80001b18:	fffff097          	auipc	ra,0xfffff
    80001b1c:	158080e7          	jalr	344(ra) # 80000c70 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001b20:	00006597          	auipc	a1,0x6
    80001b24:	6e858593          	add	a1,a1,1768 # 80008208 <__func__.1+0x200>
    80001b28:	0000f517          	auipc	a0,0xf
    80001b2c:	5f050513          	add	a0,a0,1520 # 80011118 <wait_lock>
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	140080e7          	jalr	320(ra) # 80000c70 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b38:	0000f497          	auipc	s1,0xf
    80001b3c:	5f848493          	add	s1,s1,1528 # 80011130 <proc>
        initlock(&p->lock, "proc");
    80001b40:	00006b17          	auipc	s6,0x6
    80001b44:	6d8b0b13          	add	s6,s6,1752 # 80008218 <__func__.1+0x210>
        p->kstack = KSTACK((int)(p - proc));
    80001b48:	8aa6                	mv	s5,s1
    80001b4a:	04fa5937          	lui	s2,0x4fa5
    80001b4e:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001b52:	0932                	sll	s2,s2,0xc
    80001b54:	fa590913          	add	s2,s2,-91
    80001b58:	0932                	sll	s2,s2,0xc
    80001b5a:	fa590913          	add	s2,s2,-91
    80001b5e:	0932                	sll	s2,s2,0xc
    80001b60:	fa590913          	add	s2,s2,-91
    80001b64:	040009b7          	lui	s3,0x4000
    80001b68:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001b6a:	09b2                	sll	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001b6c:	00015a17          	auipc	s4,0x15
    80001b70:	fc4a0a13          	add	s4,s4,-60 # 80016b30 <tickslock>
        initlock(&p->lock, "proc");
    80001b74:	85da                	mv	a1,s6
    80001b76:	8526                	mv	a0,s1
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	0f8080e7          	jalr	248(ra) # 80000c70 <initlock>
        p->state = UNUSED;
    80001b80:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001b84:	415487b3          	sub	a5,s1,s5
    80001b88:	878d                	sra	a5,a5,0x3
    80001b8a:	032787b3          	mul	a5,a5,s2
    80001b8e:	2785                	addw	a5,a5,1
    80001b90:	00d7979b          	sllw	a5,a5,0xd
    80001b94:	40f987b3          	sub	a5,s3,a5
    80001b98:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001b9a:	16848493          	add	s1,s1,360
    80001b9e:	fd449be3          	bne	s1,s4,80001b74 <procinit+0x80>
}
    80001ba2:	70e2                	ld	ra,56(sp)
    80001ba4:	7442                	ld	s0,48(sp)
    80001ba6:	74a2                	ld	s1,40(sp)
    80001ba8:	7902                	ld	s2,32(sp)
    80001baa:	69e2                	ld	s3,24(sp)
    80001bac:	6a42                	ld	s4,16(sp)
    80001bae:	6aa2                	ld	s5,8(sp)
    80001bb0:	6b02                	ld	s6,0(sp)
    80001bb2:	6121                	add	sp,sp,64
    80001bb4:	8082                	ret

0000000080001bb6 <copy_array>:
{
    80001bb6:	1141                	add	sp,sp,-16
    80001bb8:	e422                	sd	s0,8(sp)
    80001bba:	0800                	add	s0,sp,16
    for (int i = 0; i < len; i++)
    80001bbc:	00c05c63          	blez	a2,80001bd4 <copy_array+0x1e>
    80001bc0:	87aa                	mv	a5,a0
    80001bc2:	9532                	add	a0,a0,a2
        dst[i] = src[i];
    80001bc4:	0007c703          	lbu	a4,0(a5)
    80001bc8:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001bcc:	0785                	add	a5,a5,1
    80001bce:	0585                	add	a1,a1,1
    80001bd0:	fea79ae3          	bne	a5,a0,80001bc4 <copy_array+0xe>
}
    80001bd4:	6422                	ld	s0,8(sp)
    80001bd6:	0141                	add	sp,sp,16
    80001bd8:	8082                	ret

0000000080001bda <cpuid>:
{
    80001bda:	1141                	add	sp,sp,-16
    80001bdc:	e422                	sd	s0,8(sp)
    80001bde:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001be0:	8512                	mv	a0,tp
}
    80001be2:	2501                	sext.w	a0,a0
    80001be4:	6422                	ld	s0,8(sp)
    80001be6:	0141                	add	sp,sp,16
    80001be8:	8082                	ret

0000000080001bea <mycpu>:
{
    80001bea:	1141                	add	sp,sp,-16
    80001bec:	e422                	sd	s0,8(sp)
    80001bee:	0800                	add	s0,sp,16
    80001bf0:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001bf2:	2781                	sext.w	a5,a5
    80001bf4:	079e                	sll	a5,a5,0x7
}
    80001bf6:	0000f517          	auipc	a0,0xf
    80001bfa:	10a50513          	add	a0,a0,266 # 80010d00 <cpus>
    80001bfe:	953e                	add	a0,a0,a5
    80001c00:	6422                	ld	s0,8(sp)
    80001c02:	0141                	add	sp,sp,16
    80001c04:	8082                	ret

0000000080001c06 <myproc>:
{
    80001c06:	1101                	add	sp,sp,-32
    80001c08:	ec06                	sd	ra,24(sp)
    80001c0a:	e822                	sd	s0,16(sp)
    80001c0c:	e426                	sd	s1,8(sp)
    80001c0e:	1000                	add	s0,sp,32
    push_off();
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	0a4080e7          	jalr	164(ra) # 80000cb4 <push_off>
    80001c18:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001c1a:	2781                	sext.w	a5,a5
    80001c1c:	079e                	sll	a5,a5,0x7
    80001c1e:	0000f717          	auipc	a4,0xf
    80001c22:	0e270713          	add	a4,a4,226 # 80010d00 <cpus>
    80001c26:	97ba                	add	a5,a5,a4
    80001c28:	6384                	ld	s1,0(a5)
    pop_off();
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	12a080e7          	jalr	298(ra) # 80000d54 <pop_off>
}
    80001c32:	8526                	mv	a0,s1
    80001c34:	60e2                	ld	ra,24(sp)
    80001c36:	6442                	ld	s0,16(sp)
    80001c38:	64a2                	ld	s1,8(sp)
    80001c3a:	6105                	add	sp,sp,32
    80001c3c:	8082                	ret

0000000080001c3e <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001c3e:	1141                	add	sp,sp,-16
    80001c40:	e406                	sd	ra,8(sp)
    80001c42:	e022                	sd	s0,0(sp)
    80001c44:	0800                	add	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001c46:	00000097          	auipc	ra,0x0
    80001c4a:	fc0080e7          	jalr	-64(ra) # 80001c06 <myproc>
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	166080e7          	jalr	358(ra) # 80000db4 <release>

    if (first)
    80001c56:	00007797          	auipc	a5,0x7
    80001c5a:	d7a7a783          	lw	a5,-646(a5) # 800089d0 <first.1>
    80001c5e:	eb89                	bnez	a5,80001c70 <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001c60:	00001097          	auipc	ra,0x1
    80001c64:	e48080e7          	jalr	-440(ra) # 80002aa8 <usertrapret>
}
    80001c68:	60a2                	ld	ra,8(sp)
    80001c6a:	6402                	ld	s0,0(sp)
    80001c6c:	0141                	add	sp,sp,16
    80001c6e:	8082                	ret
        first = 0;
    80001c70:	00007797          	auipc	a5,0x7
    80001c74:	d607a023          	sw	zero,-672(a5) # 800089d0 <first.1>
        fsinit(ROOTDEV);
    80001c78:	4505                	li	a0,1
    80001c7a:	00002097          	auipc	ra,0x2
    80001c7e:	c8c080e7          	jalr	-884(ra) # 80003906 <fsinit>
    80001c82:	bff9                	j	80001c60 <forkret+0x22>

0000000080001c84 <allocpid>:
{
    80001c84:	1101                	add	sp,sp,-32
    80001c86:	ec06                	sd	ra,24(sp)
    80001c88:	e822                	sd	s0,16(sp)
    80001c8a:	e426                	sd	s1,8(sp)
    80001c8c:	e04a                	sd	s2,0(sp)
    80001c8e:	1000                	add	s0,sp,32
    acquire(&pid_lock);
    80001c90:	0000f917          	auipc	s2,0xf
    80001c94:	47090913          	add	s2,s2,1136 # 80011100 <pid_lock>
    80001c98:	854a                	mv	a0,s2
    80001c9a:	fffff097          	auipc	ra,0xfffff
    80001c9e:	066080e7          	jalr	102(ra) # 80000d00 <acquire>
    pid = nextpid;
    80001ca2:	00007797          	auipc	a5,0x7
    80001ca6:	d3e78793          	add	a5,a5,-706 # 800089e0 <nextpid>
    80001caa:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001cac:	0014871b          	addw	a4,s1,1
    80001cb0:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001cb2:	854a                	mv	a0,s2
    80001cb4:	fffff097          	auipc	ra,0xfffff
    80001cb8:	100080e7          	jalr	256(ra) # 80000db4 <release>
}
    80001cbc:	8526                	mv	a0,s1
    80001cbe:	60e2                	ld	ra,24(sp)
    80001cc0:	6442                	ld	s0,16(sp)
    80001cc2:	64a2                	ld	s1,8(sp)
    80001cc4:	6902                	ld	s2,0(sp)
    80001cc6:	6105                	add	sp,sp,32
    80001cc8:	8082                	ret

0000000080001cca <proc_pagetable>:
{
    80001cca:	1101                	add	sp,sp,-32
    80001ccc:	ec06                	sd	ra,24(sp)
    80001cce:	e822                	sd	s0,16(sp)
    80001cd0:	e426                	sd	s1,8(sp)
    80001cd2:	e04a                	sd	s2,0(sp)
    80001cd4:	1000                	add	s0,sp,32
    80001cd6:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001cd8:	fffff097          	auipc	ra,0xfffff
    80001cdc:	782080e7          	jalr	1922(ra) # 8000145a <uvmcreate>
    80001ce0:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001ce2:	c121                	beqz	a0,80001d22 <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ce4:	4729                	li	a4,10
    80001ce6:	00005697          	auipc	a3,0x5
    80001cea:	31a68693          	add	a3,a3,794 # 80007000 <_trampoline>
    80001cee:	6605                	lui	a2,0x1
    80001cf0:	040005b7          	lui	a1,0x4000
    80001cf4:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cf6:	05b2                	sll	a1,a1,0xc
    80001cf8:	fffff097          	auipc	ra,0xfffff
    80001cfc:	4c8080e7          	jalr	1224(ra) # 800011c0 <mappages>
    80001d00:	02054863          	bltz	a0,80001d30 <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d04:	4719                	li	a4,6
    80001d06:	05893683          	ld	a3,88(s2)
    80001d0a:	6605                	lui	a2,0x1
    80001d0c:	020005b7          	lui	a1,0x2000
    80001d10:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d12:	05b6                	sll	a1,a1,0xd
    80001d14:	8526                	mv	a0,s1
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	4aa080e7          	jalr	1194(ra) # 800011c0 <mappages>
    80001d1e:	02054163          	bltz	a0,80001d40 <proc_pagetable+0x76>
}
    80001d22:	8526                	mv	a0,s1
    80001d24:	60e2                	ld	ra,24(sp)
    80001d26:	6442                	ld	s0,16(sp)
    80001d28:	64a2                	ld	s1,8(sp)
    80001d2a:	6902                	ld	s2,0(sp)
    80001d2c:	6105                	add	sp,sp,32
    80001d2e:	8082                	ret
        uvmfree(pagetable, 0);
    80001d30:	4581                	li	a1,0
    80001d32:	8526                	mv	a0,s1
    80001d34:	00000097          	auipc	ra,0x0
    80001d38:	938080e7          	jalr	-1736(ra) # 8000166c <uvmfree>
        return 0;
    80001d3c:	4481                	li	s1,0
    80001d3e:	b7d5                	j	80001d22 <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d40:	4681                	li	a3,0
    80001d42:	4605                	li	a2,1
    80001d44:	040005b7          	lui	a1,0x4000
    80001d48:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d4a:	05b2                	sll	a1,a1,0xc
    80001d4c:	8526                	mv	a0,s1
    80001d4e:	fffff097          	auipc	ra,0xfffff
    80001d52:	638080e7          	jalr	1592(ra) # 80001386 <uvmunmap>
        uvmfree(pagetable, 0);
    80001d56:	4581                	li	a1,0
    80001d58:	8526                	mv	a0,s1
    80001d5a:	00000097          	auipc	ra,0x0
    80001d5e:	912080e7          	jalr	-1774(ra) # 8000166c <uvmfree>
        return 0;
    80001d62:	4481                	li	s1,0
    80001d64:	bf7d                	j	80001d22 <proc_pagetable+0x58>

0000000080001d66 <proc_freepagetable>:
{
    80001d66:	1101                	add	sp,sp,-32
    80001d68:	ec06                	sd	ra,24(sp)
    80001d6a:	e822                	sd	s0,16(sp)
    80001d6c:	e426                	sd	s1,8(sp)
    80001d6e:	e04a                	sd	s2,0(sp)
    80001d70:	1000                	add	s0,sp,32
    80001d72:	84aa                	mv	s1,a0
    80001d74:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d76:	4681                	li	a3,0
    80001d78:	4605                	li	a2,1
    80001d7a:	040005b7          	lui	a1,0x4000
    80001d7e:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d80:	05b2                	sll	a1,a1,0xc
    80001d82:	fffff097          	auipc	ra,0xfffff
    80001d86:	604080e7          	jalr	1540(ra) # 80001386 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d8a:	4681                	li	a3,0
    80001d8c:	4605                	li	a2,1
    80001d8e:	020005b7          	lui	a1,0x2000
    80001d92:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d94:	05b6                	sll	a1,a1,0xd
    80001d96:	8526                	mv	a0,s1
    80001d98:	fffff097          	auipc	ra,0xfffff
    80001d9c:	5ee080e7          	jalr	1518(ra) # 80001386 <uvmunmap>
    uvmfree(pagetable, sz);
    80001da0:	85ca                	mv	a1,s2
    80001da2:	8526                	mv	a0,s1
    80001da4:	00000097          	auipc	ra,0x0
    80001da8:	8c8080e7          	jalr	-1848(ra) # 8000166c <uvmfree>
}
    80001dac:	60e2                	ld	ra,24(sp)
    80001dae:	6442                	ld	s0,16(sp)
    80001db0:	64a2                	ld	s1,8(sp)
    80001db2:	6902                	ld	s2,0(sp)
    80001db4:	6105                	add	sp,sp,32
    80001db6:	8082                	ret

0000000080001db8 <freeproc>:
{
    80001db8:	1101                	add	sp,sp,-32
    80001dba:	ec06                	sd	ra,24(sp)
    80001dbc:	e822                	sd	s0,16(sp)
    80001dbe:	e426                	sd	s1,8(sp)
    80001dc0:	1000                	add	s0,sp,32
    80001dc2:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001dc4:	6d28                	ld	a0,88(a0)
    80001dc6:	c509                	beqz	a0,80001dd0 <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001dc8:	fffff097          	auipc	ra,0xfffff
    80001dcc:	c94080e7          	jalr	-876(ra) # 80000a5c <kfree>
    p->trapframe = 0;
    80001dd0:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001dd4:	68a8                	ld	a0,80(s1)
    80001dd6:	c511                	beqz	a0,80001de2 <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001dd8:	64ac                	ld	a1,72(s1)
    80001dda:	00000097          	auipc	ra,0x0
    80001dde:	f8c080e7          	jalr	-116(ra) # 80001d66 <proc_freepagetable>
    p->pagetable = 0;
    80001de2:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001de6:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001dea:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001dee:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001df2:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001df6:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001dfa:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001dfe:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001e02:	0004ac23          	sw	zero,24(s1)
}
    80001e06:	60e2                	ld	ra,24(sp)
    80001e08:	6442                	ld	s0,16(sp)
    80001e0a:	64a2                	ld	s1,8(sp)
    80001e0c:	6105                	add	sp,sp,32
    80001e0e:	8082                	ret

0000000080001e10 <allocproc>:
{
    80001e10:	1101                	add	sp,sp,-32
    80001e12:	ec06                	sd	ra,24(sp)
    80001e14:	e822                	sd	s0,16(sp)
    80001e16:	e426                	sd	s1,8(sp)
    80001e18:	e04a                	sd	s2,0(sp)
    80001e1a:	1000                	add	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001e1c:	0000f497          	auipc	s1,0xf
    80001e20:	31448493          	add	s1,s1,788 # 80011130 <proc>
    80001e24:	00015917          	auipc	s2,0x15
    80001e28:	d0c90913          	add	s2,s2,-756 # 80016b30 <tickslock>
        acquire(&p->lock);
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	fffff097          	auipc	ra,0xfffff
    80001e32:	ed2080e7          	jalr	-302(ra) # 80000d00 <acquire>
        if (p->state == UNUSED)
    80001e36:	4c9c                	lw	a5,24(s1)
    80001e38:	cf81                	beqz	a5,80001e50 <allocproc+0x40>
            release(&p->lock);
    80001e3a:	8526                	mv	a0,s1
    80001e3c:	fffff097          	auipc	ra,0xfffff
    80001e40:	f78080e7          	jalr	-136(ra) # 80000db4 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001e44:	16848493          	add	s1,s1,360
    80001e48:	ff2492e3          	bne	s1,s2,80001e2c <allocproc+0x1c>
    return 0;
    80001e4c:	4481                	li	s1,0
    80001e4e:	a889                	j	80001ea0 <allocproc+0x90>
    p->pid = allocpid();
    80001e50:	00000097          	auipc	ra,0x0
    80001e54:	e34080e7          	jalr	-460(ra) # 80001c84 <allocpid>
    80001e58:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001e5a:	4785                	li	a5,1
    80001e5c:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e5e:	fffff097          	auipc	ra,0xfffff
    80001e62:	d66080e7          	jalr	-666(ra) # 80000bc4 <kalloc>
    80001e66:	892a                	mv	s2,a0
    80001e68:	eca8                	sd	a0,88(s1)
    80001e6a:	c131                	beqz	a0,80001eae <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001e6c:	8526                	mv	a0,s1
    80001e6e:	00000097          	auipc	ra,0x0
    80001e72:	e5c080e7          	jalr	-420(ra) # 80001cca <proc_pagetable>
    80001e76:	892a                	mv	s2,a0
    80001e78:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001e7a:	c531                	beqz	a0,80001ec6 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001e7c:	07000613          	li	a2,112
    80001e80:	4581                	li	a1,0
    80001e82:	06048513          	add	a0,s1,96
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	f76080e7          	jalr	-138(ra) # 80000dfc <memset>
    p->context.ra = (uint64)forkret;
    80001e8e:	00000797          	auipc	a5,0x0
    80001e92:	db078793          	add	a5,a5,-592 # 80001c3e <forkret>
    80001e96:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001e98:	60bc                	ld	a5,64(s1)
    80001e9a:	6705                	lui	a4,0x1
    80001e9c:	97ba                	add	a5,a5,a4
    80001e9e:	f4bc                	sd	a5,104(s1)
}
    80001ea0:	8526                	mv	a0,s1
    80001ea2:	60e2                	ld	ra,24(sp)
    80001ea4:	6442                	ld	s0,16(sp)
    80001ea6:	64a2                	ld	s1,8(sp)
    80001ea8:	6902                	ld	s2,0(sp)
    80001eaa:	6105                	add	sp,sp,32
    80001eac:	8082                	ret
        freeproc(p);
    80001eae:	8526                	mv	a0,s1
    80001eb0:	00000097          	auipc	ra,0x0
    80001eb4:	f08080e7          	jalr	-248(ra) # 80001db8 <freeproc>
        release(&p->lock);
    80001eb8:	8526                	mv	a0,s1
    80001eba:	fffff097          	auipc	ra,0xfffff
    80001ebe:	efa080e7          	jalr	-262(ra) # 80000db4 <release>
        return 0;
    80001ec2:	84ca                	mv	s1,s2
    80001ec4:	bff1                	j	80001ea0 <allocproc+0x90>
        freeproc(p);
    80001ec6:	8526                	mv	a0,s1
    80001ec8:	00000097          	auipc	ra,0x0
    80001ecc:	ef0080e7          	jalr	-272(ra) # 80001db8 <freeproc>
        release(&p->lock);
    80001ed0:	8526                	mv	a0,s1
    80001ed2:	fffff097          	auipc	ra,0xfffff
    80001ed6:	ee2080e7          	jalr	-286(ra) # 80000db4 <release>
        return 0;
    80001eda:	84ca                	mv	s1,s2
    80001edc:	b7d1                	j	80001ea0 <allocproc+0x90>

0000000080001ede <userinit>:
{
    80001ede:	1101                	add	sp,sp,-32
    80001ee0:	ec06                	sd	ra,24(sp)
    80001ee2:	e822                	sd	s0,16(sp)
    80001ee4:	e426                	sd	s1,8(sp)
    80001ee6:	1000                	add	s0,sp,32
    p = allocproc();
    80001ee8:	00000097          	auipc	ra,0x0
    80001eec:	f28080e7          	jalr	-216(ra) # 80001e10 <allocproc>
    80001ef0:	84aa                	mv	s1,a0
    initproc = p;
    80001ef2:	00007797          	auipc	a5,0x7
    80001ef6:	b8a7bb23          	sd	a0,-1130(a5) # 80008a88 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001efa:	03400613          	li	a2,52
    80001efe:	00007597          	auipc	a1,0x7
    80001f02:	af258593          	add	a1,a1,-1294 # 800089f0 <initcode>
    80001f06:	6928                	ld	a0,80(a0)
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	580080e7          	jalr	1408(ra) # 80001488 <uvmfirst>
    p->sz = PGSIZE;
    80001f10:	6785                	lui	a5,0x1
    80001f12:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80001f14:	6cb8                	ld	a4,88(s1)
    80001f16:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001f1a:	6cb8                	ld	a4,88(s1)
    80001f1c:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f1e:	4641                	li	a2,16
    80001f20:	00006597          	auipc	a1,0x6
    80001f24:	30058593          	add	a1,a1,768 # 80008220 <__func__.1+0x218>
    80001f28:	15848513          	add	a0,s1,344
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	012080e7          	jalr	18(ra) # 80000f3e <safestrcpy>
    p->cwd = namei("/");
    80001f34:	00006517          	auipc	a0,0x6
    80001f38:	2fc50513          	add	a0,a0,764 # 80008230 <__func__.1+0x228>
    80001f3c:	00002097          	auipc	ra,0x2
    80001f40:	41c080e7          	jalr	1052(ra) # 80004358 <namei>
    80001f44:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80001f48:	478d                	li	a5,3
    80001f4a:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001f4c:	8526                	mv	a0,s1
    80001f4e:	fffff097          	auipc	ra,0xfffff
    80001f52:	e66080e7          	jalr	-410(ra) # 80000db4 <release>
}
    80001f56:	60e2                	ld	ra,24(sp)
    80001f58:	6442                	ld	s0,16(sp)
    80001f5a:	64a2                	ld	s1,8(sp)
    80001f5c:	6105                	add	sp,sp,32
    80001f5e:	8082                	ret

0000000080001f60 <growproc>:
{
    80001f60:	1101                	add	sp,sp,-32
    80001f62:	ec06                	sd	ra,24(sp)
    80001f64:	e822                	sd	s0,16(sp)
    80001f66:	e426                	sd	s1,8(sp)
    80001f68:	e04a                	sd	s2,0(sp)
    80001f6a:	1000                	add	s0,sp,32
    80001f6c:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80001f6e:	00000097          	auipc	ra,0x0
    80001f72:	c98080e7          	jalr	-872(ra) # 80001c06 <myproc>
    80001f76:	84aa                	mv	s1,a0
    sz = p->sz;
    80001f78:	652c                	ld	a1,72(a0)
    if (n > 0)
    80001f7a:	01204c63          	bgtz	s2,80001f92 <growproc+0x32>
    else if (n < 0)
    80001f7e:	02094663          	bltz	s2,80001faa <growproc+0x4a>
    p->sz = sz;
    80001f82:	e4ac                	sd	a1,72(s1)
    return 0;
    80001f84:	4501                	li	a0,0
}
    80001f86:	60e2                	ld	ra,24(sp)
    80001f88:	6442                	ld	s0,16(sp)
    80001f8a:	64a2                	ld	s1,8(sp)
    80001f8c:	6902                	ld	s2,0(sp)
    80001f8e:	6105                	add	sp,sp,32
    80001f90:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001f92:	4691                	li	a3,4
    80001f94:	00b90633          	add	a2,s2,a1
    80001f98:	6928                	ld	a0,80(a0)
    80001f9a:	fffff097          	auipc	ra,0xfffff
    80001f9e:	5a8080e7          	jalr	1448(ra) # 80001542 <uvmalloc>
    80001fa2:	85aa                	mv	a1,a0
    80001fa4:	fd79                	bnez	a0,80001f82 <growproc+0x22>
            return -1;
    80001fa6:	557d                	li	a0,-1
    80001fa8:	bff9                	j	80001f86 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001faa:	00b90633          	add	a2,s2,a1
    80001fae:	6928                	ld	a0,80(a0)
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	54a080e7          	jalr	1354(ra) # 800014fa <uvmdealloc>
    80001fb8:	85aa                	mv	a1,a0
    80001fba:	b7e1                	j	80001f82 <growproc+0x22>

0000000080001fbc <ps>:
{
    80001fbc:	715d                	add	sp,sp,-80
    80001fbe:	e486                	sd	ra,72(sp)
    80001fc0:	e0a2                	sd	s0,64(sp)
    80001fc2:	fc26                	sd	s1,56(sp)
    80001fc4:	f84a                	sd	s2,48(sp)
    80001fc6:	f44e                	sd	s3,40(sp)
    80001fc8:	f052                	sd	s4,32(sp)
    80001fca:	ec56                	sd	s5,24(sp)
    80001fcc:	e85a                	sd	s6,16(sp)
    80001fce:	e45e                	sd	s7,8(sp)
    80001fd0:	e062                	sd	s8,0(sp)
    80001fd2:	0880                	add	s0,sp,80
    80001fd4:	84aa                	mv	s1,a0
    80001fd6:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    80001fd8:	00000097          	auipc	ra,0x0
    80001fdc:	c2e080e7          	jalr	-978(ra) # 80001c06 <myproc>
        return result;
    80001fe0:	4901                	li	s2,0
    if (count == 0)
    80001fe2:	0c0b8663          	beqz	s7,800020ae <ps+0xf2>
    void *result = (void *)myproc()->sz;
    80001fe6:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    80001fea:	003b951b          	sllw	a0,s7,0x3
    80001fee:	0175053b          	addw	a0,a0,s7
    80001ff2:	0025151b          	sllw	a0,a0,0x2
    80001ff6:	2501                	sext.w	a0,a0
    80001ff8:	00000097          	auipc	ra,0x0
    80001ffc:	f68080e7          	jalr	-152(ra) # 80001f60 <growproc>
    80002000:	12054f63          	bltz	a0,8000213e <ps+0x182>
    struct user_proc loc_result[count];
    80002004:	003b9a13          	sll	s4,s7,0x3
    80002008:	9a5e                	add	s4,s4,s7
    8000200a:	0a0a                	sll	s4,s4,0x2
    8000200c:	00fa0793          	add	a5,s4,15
    80002010:	8391                	srl	a5,a5,0x4
    80002012:	0792                	sll	a5,a5,0x4
    80002014:	40f10133          	sub	sp,sp,a5
    80002018:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    8000201a:	16800793          	li	a5,360
    8000201e:	02f484b3          	mul	s1,s1,a5
    80002022:	0000f797          	auipc	a5,0xf
    80002026:	10e78793          	add	a5,a5,270 # 80011130 <proc>
    8000202a:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    8000202c:	00015797          	auipc	a5,0x15
    80002030:	b0478793          	add	a5,a5,-1276 # 80016b30 <tickslock>
        return result;
    80002034:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    80002036:	06f4fc63          	bgeu	s1,a5,800020ae <ps+0xf2>
    acquire(&wait_lock);
    8000203a:	0000f517          	auipc	a0,0xf
    8000203e:	0de50513          	add	a0,a0,222 # 80011118 <wait_lock>
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	cbe080e7          	jalr	-834(ra) # 80000d00 <acquire>
        if (localCount == count)
    8000204a:	014a8913          	add	s2,s5,20
    uint8 localCount = 0;
    8000204e:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80002050:	00015c17          	auipc	s8,0x15
    80002054:	ae0c0c13          	add	s8,s8,-1312 # 80016b30 <tickslock>
    80002058:	a851                	j	800020ec <ps+0x130>
            loc_result[localCount].state = UNUSED;
    8000205a:	00399793          	sll	a5,s3,0x3
    8000205e:	97ce                	add	a5,a5,s3
    80002060:	078a                	sll	a5,a5,0x2
    80002062:	97d6                	add	a5,a5,s5
    80002064:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80002068:	8526                	mv	a0,s1
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	d4a080e7          	jalr	-694(ra) # 80000db4 <release>
    release(&wait_lock);
    80002072:	0000f517          	auipc	a0,0xf
    80002076:	0a650513          	add	a0,a0,166 # 80011118 <wait_lock>
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	d3a080e7          	jalr	-710(ra) # 80000db4 <release>
    if (localCount < count)
    80002082:	0179f963          	bgeu	s3,s7,80002094 <ps+0xd8>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    80002086:	00399793          	sll	a5,s3,0x3
    8000208a:	97ce                	add	a5,a5,s3
    8000208c:	078a                	sll	a5,a5,0x2
    8000208e:	97d6                	add	a5,a5,s5
    80002090:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    80002094:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    80002096:	00000097          	auipc	ra,0x0
    8000209a:	b70080e7          	jalr	-1168(ra) # 80001c06 <myproc>
    8000209e:	86d2                	mv	a3,s4
    800020a0:	8656                	mv	a2,s5
    800020a2:	85da                	mv	a1,s6
    800020a4:	6928                	ld	a0,80(a0)
    800020a6:	fffff097          	auipc	ra,0xfffff
    800020aa:	704080e7          	jalr	1796(ra) # 800017aa <copyout>
}
    800020ae:	854a                	mv	a0,s2
    800020b0:	fb040113          	add	sp,s0,-80
    800020b4:	60a6                	ld	ra,72(sp)
    800020b6:	6406                	ld	s0,64(sp)
    800020b8:	74e2                	ld	s1,56(sp)
    800020ba:	7942                	ld	s2,48(sp)
    800020bc:	79a2                	ld	s3,40(sp)
    800020be:	7a02                	ld	s4,32(sp)
    800020c0:	6ae2                	ld	s5,24(sp)
    800020c2:	6b42                	ld	s6,16(sp)
    800020c4:	6ba2                	ld	s7,8(sp)
    800020c6:	6c02                	ld	s8,0(sp)
    800020c8:	6161                	add	sp,sp,80
    800020ca:	8082                	ret
        release(&p->lock);
    800020cc:	8526                	mv	a0,s1
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	ce6080e7          	jalr	-794(ra) # 80000db4 <release>
        localCount++;
    800020d6:	2985                	addw	s3,s3,1
    800020d8:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    800020dc:	16848493          	add	s1,s1,360
    800020e0:	f984f9e3          	bgeu	s1,s8,80002072 <ps+0xb6>
        if (localCount == count)
    800020e4:	02490913          	add	s2,s2,36
    800020e8:	053b8d63          	beq	s7,s3,80002142 <ps+0x186>
        acquire(&p->lock);
    800020ec:	8526                	mv	a0,s1
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	c12080e7          	jalr	-1006(ra) # 80000d00 <acquire>
        if (p->state == UNUSED)
    800020f6:	4c9c                	lw	a5,24(s1)
    800020f8:	d3ad                	beqz	a5,8000205a <ps+0x9e>
        loc_result[localCount].state = p->state;
    800020fa:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    800020fe:	549c                	lw	a5,40(s1)
    80002100:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    80002104:	54dc                	lw	a5,44(s1)
    80002106:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    8000210a:	589c                	lw	a5,48(s1)
    8000210c:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    80002110:	4641                	li	a2,16
    80002112:	85ca                	mv	a1,s2
    80002114:	15848513          	add	a0,s1,344
    80002118:	00000097          	auipc	ra,0x0
    8000211c:	a9e080e7          	jalr	-1378(ra) # 80001bb6 <copy_array>
        if (p->parent != 0) // init
    80002120:	7c88                	ld	a0,56(s1)
    80002122:	d54d                	beqz	a0,800020cc <ps+0x110>
            acquire(&p->parent->lock);
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	bdc080e7          	jalr	-1060(ra) # 80000d00 <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    8000212c:	7c88                	ld	a0,56(s1)
    8000212e:	591c                	lw	a5,48(a0)
    80002130:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	c80080e7          	jalr	-896(ra) # 80000db4 <release>
    8000213c:	bf41                	j	800020cc <ps+0x110>
        return result;
    8000213e:	4901                	li	s2,0
    80002140:	b7bd                	j	800020ae <ps+0xf2>
    release(&wait_lock);
    80002142:	0000f517          	auipc	a0,0xf
    80002146:	fd650513          	add	a0,a0,-42 # 80011118 <wait_lock>
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	c6a080e7          	jalr	-918(ra) # 80000db4 <release>
    if (localCount < count)
    80002152:	b789                	j	80002094 <ps+0xd8>

0000000080002154 <fork>:
{
    80002154:	7139                	add	sp,sp,-64
    80002156:	fc06                	sd	ra,56(sp)
    80002158:	f822                	sd	s0,48(sp)
    8000215a:	f04a                	sd	s2,32(sp)
    8000215c:	e456                	sd	s5,8(sp)
    8000215e:	0080                	add	s0,sp,64
    struct proc *p = myproc();
    80002160:	00000097          	auipc	ra,0x0
    80002164:	aa6080e7          	jalr	-1370(ra) # 80001c06 <myproc>
    80002168:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    8000216a:	00000097          	auipc	ra,0x0
    8000216e:	ca6080e7          	jalr	-858(ra) # 80001e10 <allocproc>
    80002172:	12050063          	beqz	a0,80002292 <fork+0x13e>
    80002176:	e852                	sd	s4,16(sp)
    80002178:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    8000217a:	048ab603          	ld	a2,72(s5)
    8000217e:	692c                	ld	a1,80(a0)
    80002180:	050ab503          	ld	a0,80(s5)
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	522080e7          	jalr	1314(ra) # 800016a6 <uvmcopy>
    8000218c:	04054a63          	bltz	a0,800021e0 <fork+0x8c>
    80002190:	f426                	sd	s1,40(sp)
    80002192:	ec4e                	sd	s3,24(sp)
    np->sz = p->sz;
    80002194:	048ab783          	ld	a5,72(s5)
    80002198:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    8000219c:	058ab683          	ld	a3,88(s5)
    800021a0:	87b6                	mv	a5,a3
    800021a2:	058a3703          	ld	a4,88(s4)
    800021a6:	12068693          	add	a3,a3,288
    800021aa:	0007b803          	ld	a6,0(a5)
    800021ae:	6788                	ld	a0,8(a5)
    800021b0:	6b8c                	ld	a1,16(a5)
    800021b2:	6f90                	ld	a2,24(a5)
    800021b4:	01073023          	sd	a6,0(a4)
    800021b8:	e708                	sd	a0,8(a4)
    800021ba:	eb0c                	sd	a1,16(a4)
    800021bc:	ef10                	sd	a2,24(a4)
    800021be:	02078793          	add	a5,a5,32
    800021c2:	02070713          	add	a4,a4,32
    800021c6:	fed792e3          	bne	a5,a3,800021aa <fork+0x56>
    np->trapframe->a0 = 0;
    800021ca:	058a3783          	ld	a5,88(s4)
    800021ce:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    800021d2:	0d0a8493          	add	s1,s5,208
    800021d6:	0d0a0913          	add	s2,s4,208
    800021da:	150a8993          	add	s3,s5,336
    800021de:	a015                	j	80002202 <fork+0xae>
        freeproc(np);
    800021e0:	8552                	mv	a0,s4
    800021e2:	00000097          	auipc	ra,0x0
    800021e6:	bd6080e7          	jalr	-1066(ra) # 80001db8 <freeproc>
        release(&np->lock);
    800021ea:	8552                	mv	a0,s4
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	bc8080e7          	jalr	-1080(ra) # 80000db4 <release>
        return -1;
    800021f4:	597d                	li	s2,-1
    800021f6:	6a42                	ld	s4,16(sp)
    800021f8:	a071                	j	80002284 <fork+0x130>
    for (i = 0; i < NOFILE; i++)
    800021fa:	04a1                	add	s1,s1,8
    800021fc:	0921                	add	s2,s2,8
    800021fe:	01348b63          	beq	s1,s3,80002214 <fork+0xc0>
        if (p->ofile[i])
    80002202:	6088                	ld	a0,0(s1)
    80002204:	d97d                	beqz	a0,800021fa <fork+0xa6>
            np->ofile[i] = filedup(p->ofile[i]);
    80002206:	00002097          	auipc	ra,0x2
    8000220a:	7ca080e7          	jalr	1994(ra) # 800049d0 <filedup>
    8000220e:	00a93023          	sd	a0,0(s2)
    80002212:	b7e5                	j	800021fa <fork+0xa6>
    np->cwd = idup(p->cwd);
    80002214:	150ab503          	ld	a0,336(s5)
    80002218:	00002097          	auipc	ra,0x2
    8000221c:	934080e7          	jalr	-1740(ra) # 80003b4c <idup>
    80002220:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    80002224:	4641                	li	a2,16
    80002226:	158a8593          	add	a1,s5,344
    8000222a:	158a0513          	add	a0,s4,344
    8000222e:	fffff097          	auipc	ra,0xfffff
    80002232:	d10080e7          	jalr	-752(ra) # 80000f3e <safestrcpy>
    pid = np->pid;
    80002236:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    8000223a:	8552                	mv	a0,s4
    8000223c:	fffff097          	auipc	ra,0xfffff
    80002240:	b78080e7          	jalr	-1160(ra) # 80000db4 <release>
    acquire(&wait_lock);
    80002244:	0000f497          	auipc	s1,0xf
    80002248:	ed448493          	add	s1,s1,-300 # 80011118 <wait_lock>
    8000224c:	8526                	mv	a0,s1
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	ab2080e7          	jalr	-1358(ra) # 80000d00 <acquire>
    np->parent = p;
    80002256:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    8000225a:	8526                	mv	a0,s1
    8000225c:	fffff097          	auipc	ra,0xfffff
    80002260:	b58080e7          	jalr	-1192(ra) # 80000db4 <release>
    acquire(&np->lock);
    80002264:	8552                	mv	a0,s4
    80002266:	fffff097          	auipc	ra,0xfffff
    8000226a:	a9a080e7          	jalr	-1382(ra) # 80000d00 <acquire>
    np->state = RUNNABLE;
    8000226e:	478d                	li	a5,3
    80002270:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002274:	8552                	mv	a0,s4
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	b3e080e7          	jalr	-1218(ra) # 80000db4 <release>
    return pid;
    8000227e:	74a2                	ld	s1,40(sp)
    80002280:	69e2                	ld	s3,24(sp)
    80002282:	6a42                	ld	s4,16(sp)
}
    80002284:	854a                	mv	a0,s2
    80002286:	70e2                	ld	ra,56(sp)
    80002288:	7442                	ld	s0,48(sp)
    8000228a:	7902                	ld	s2,32(sp)
    8000228c:	6aa2                	ld	s5,8(sp)
    8000228e:	6121                	add	sp,sp,64
    80002290:	8082                	ret
        return -1;
    80002292:	597d                	li	s2,-1
    80002294:	bfc5                	j	80002284 <fork+0x130>

0000000080002296 <scheduler>:
{
    80002296:	1101                	add	sp,sp,-32
    80002298:	ec06                	sd	ra,24(sp)
    8000229a:	e822                	sd	s0,16(sp)
    8000229c:	e426                	sd	s1,8(sp)
    8000229e:	1000                	add	s0,sp,32
        (*sched_pointer)();
    800022a0:	00006497          	auipc	s1,0x6
    800022a4:	73848493          	add	s1,s1,1848 # 800089d8 <sched_pointer>
    800022a8:	609c                	ld	a5,0(s1)
    800022aa:	9782                	jalr	a5
    while (1)
    800022ac:	bff5                	j	800022a8 <scheduler+0x12>

00000000800022ae <sched>:
{
    800022ae:	7179                	add	sp,sp,-48
    800022b0:	f406                	sd	ra,40(sp)
    800022b2:	f022                	sd	s0,32(sp)
    800022b4:	ec26                	sd	s1,24(sp)
    800022b6:	e84a                	sd	s2,16(sp)
    800022b8:	e44e                	sd	s3,8(sp)
    800022ba:	1800                	add	s0,sp,48
    struct proc *p = myproc();
    800022bc:	00000097          	auipc	ra,0x0
    800022c0:	94a080e7          	jalr	-1718(ra) # 80001c06 <myproc>
    800022c4:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	9c0080e7          	jalr	-1600(ra) # 80000c86 <holding>
    800022ce:	c53d                	beqz	a0,8000233c <sched+0x8e>
    800022d0:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    800022d2:	2781                	sext.w	a5,a5
    800022d4:	079e                	sll	a5,a5,0x7
    800022d6:	0000f717          	auipc	a4,0xf
    800022da:	a2a70713          	add	a4,a4,-1494 # 80010d00 <cpus>
    800022de:	97ba                	add	a5,a5,a4
    800022e0:	5fb8                	lw	a4,120(a5)
    800022e2:	4785                	li	a5,1
    800022e4:	06f71463          	bne	a4,a5,8000234c <sched+0x9e>
    if (p->state == RUNNING)
    800022e8:	4c98                	lw	a4,24(s1)
    800022ea:	4791                	li	a5,4
    800022ec:	06f70863          	beq	a4,a5,8000235c <sched+0xae>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022f0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022f4:	8b89                	and	a5,a5,2
    if (intr_get())
    800022f6:	ebbd                	bnez	a5,8000236c <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022f8:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    800022fa:	0000f917          	auipc	s2,0xf
    800022fe:	a0690913          	add	s2,s2,-1530 # 80010d00 <cpus>
    80002302:	2781                	sext.w	a5,a5
    80002304:	079e                	sll	a5,a5,0x7
    80002306:	97ca                	add	a5,a5,s2
    80002308:	07c7a983          	lw	s3,124(a5)
    8000230c:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    8000230e:	2581                	sext.w	a1,a1
    80002310:	059e                	sll	a1,a1,0x7
    80002312:	05a1                	add	a1,a1,8
    80002314:	95ca                	add	a1,a1,s2
    80002316:	06048513          	add	a0,s1,96
    8000231a:	00000097          	auipc	ra,0x0
    8000231e:	6e4080e7          	jalr	1764(ra) # 800029fe <swtch>
    80002322:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    80002324:	2781                	sext.w	a5,a5
    80002326:	079e                	sll	a5,a5,0x7
    80002328:	993e                	add	s2,s2,a5
    8000232a:	07392e23          	sw	s3,124(s2)
}
    8000232e:	70a2                	ld	ra,40(sp)
    80002330:	7402                	ld	s0,32(sp)
    80002332:	64e2                	ld	s1,24(sp)
    80002334:	6942                	ld	s2,16(sp)
    80002336:	69a2                	ld	s3,8(sp)
    80002338:	6145                	add	sp,sp,48
    8000233a:	8082                	ret
        panic("sched p->lock");
    8000233c:	00006517          	auipc	a0,0x6
    80002340:	efc50513          	add	a0,a0,-260 # 80008238 <__func__.1+0x230>
    80002344:	ffffe097          	auipc	ra,0xffffe
    80002348:	21c080e7          	jalr	540(ra) # 80000560 <panic>
        panic("sched locks");
    8000234c:	00006517          	auipc	a0,0x6
    80002350:	efc50513          	add	a0,a0,-260 # 80008248 <__func__.1+0x240>
    80002354:	ffffe097          	auipc	ra,0xffffe
    80002358:	20c080e7          	jalr	524(ra) # 80000560 <panic>
        panic("sched running");
    8000235c:	00006517          	auipc	a0,0x6
    80002360:	efc50513          	add	a0,a0,-260 # 80008258 <__func__.1+0x250>
    80002364:	ffffe097          	auipc	ra,0xffffe
    80002368:	1fc080e7          	jalr	508(ra) # 80000560 <panic>
        panic("sched interruptible");
    8000236c:	00006517          	auipc	a0,0x6
    80002370:	efc50513          	add	a0,a0,-260 # 80008268 <__func__.1+0x260>
    80002374:	ffffe097          	auipc	ra,0xffffe
    80002378:	1ec080e7          	jalr	492(ra) # 80000560 <panic>

000000008000237c <yield>:
{
    8000237c:	1101                	add	sp,sp,-32
    8000237e:	ec06                	sd	ra,24(sp)
    80002380:	e822                	sd	s0,16(sp)
    80002382:	e426                	sd	s1,8(sp)
    80002384:	1000                	add	s0,sp,32
    struct proc *p = myproc();
    80002386:	00000097          	auipc	ra,0x0
    8000238a:	880080e7          	jalr	-1920(ra) # 80001c06 <myproc>
    8000238e:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	970080e7          	jalr	-1680(ra) # 80000d00 <acquire>
    p->state = RUNNABLE;
    80002398:	478d                	li	a5,3
    8000239a:	cc9c                	sw	a5,24(s1)
    sched();
    8000239c:	00000097          	auipc	ra,0x0
    800023a0:	f12080e7          	jalr	-238(ra) # 800022ae <sched>
    release(&p->lock);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	a0e080e7          	jalr	-1522(ra) # 80000db4 <release>
}
    800023ae:	60e2                	ld	ra,24(sp)
    800023b0:	6442                	ld	s0,16(sp)
    800023b2:	64a2                	ld	s1,8(sp)
    800023b4:	6105                	add	sp,sp,32
    800023b6:	8082                	ret

00000000800023b8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800023b8:	7179                	add	sp,sp,-48
    800023ba:	f406                	sd	ra,40(sp)
    800023bc:	f022                	sd	s0,32(sp)
    800023be:	ec26                	sd	s1,24(sp)
    800023c0:	e84a                	sd	s2,16(sp)
    800023c2:	e44e                	sd	s3,8(sp)
    800023c4:	1800                	add	s0,sp,48
    800023c6:	89aa                	mv	s3,a0
    800023c8:	892e                	mv	s2,a1
    struct proc *p = myproc();
    800023ca:	00000097          	auipc	ra,0x0
    800023ce:	83c080e7          	jalr	-1988(ra) # 80001c06 <myproc>
    800023d2:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	92c080e7          	jalr	-1748(ra) # 80000d00 <acquire>
    release(lk);
    800023dc:	854a                	mv	a0,s2
    800023de:	fffff097          	auipc	ra,0xfffff
    800023e2:	9d6080e7          	jalr	-1578(ra) # 80000db4 <release>

    // Go to sleep.
    p->chan = chan;
    800023e6:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    800023ea:	4789                	li	a5,2
    800023ec:	cc9c                	sw	a5,24(s1)

    sched();
    800023ee:	00000097          	auipc	ra,0x0
    800023f2:	ec0080e7          	jalr	-320(ra) # 800022ae <sched>

    // Tidy up.
    p->chan = 0;
    800023f6:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    800023fa:	8526                	mv	a0,s1
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	9b8080e7          	jalr	-1608(ra) # 80000db4 <release>
    acquire(lk);
    80002404:	854a                	mv	a0,s2
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	8fa080e7          	jalr	-1798(ra) # 80000d00 <acquire>
}
    8000240e:	70a2                	ld	ra,40(sp)
    80002410:	7402                	ld	s0,32(sp)
    80002412:	64e2                	ld	s1,24(sp)
    80002414:	6942                	ld	s2,16(sp)
    80002416:	69a2                	ld	s3,8(sp)
    80002418:	6145                	add	sp,sp,48
    8000241a:	8082                	ret

000000008000241c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000241c:	7139                	add	sp,sp,-64
    8000241e:	fc06                	sd	ra,56(sp)
    80002420:	f822                	sd	s0,48(sp)
    80002422:	f426                	sd	s1,40(sp)
    80002424:	f04a                	sd	s2,32(sp)
    80002426:	ec4e                	sd	s3,24(sp)
    80002428:	e852                	sd	s4,16(sp)
    8000242a:	e456                	sd	s5,8(sp)
    8000242c:	0080                	add	s0,sp,64
    8000242e:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002430:	0000f497          	auipc	s1,0xf
    80002434:	d0048493          	add	s1,s1,-768 # 80011130 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    80002438:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    8000243a:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    8000243c:	00014917          	auipc	s2,0x14
    80002440:	6f490913          	add	s2,s2,1780 # 80016b30 <tickslock>
    80002444:	a811                	j	80002458 <wakeup+0x3c>
            }
            release(&p->lock);
    80002446:	8526                	mv	a0,s1
    80002448:	fffff097          	auipc	ra,0xfffff
    8000244c:	96c080e7          	jalr	-1684(ra) # 80000db4 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002450:	16848493          	add	s1,s1,360
    80002454:	03248663          	beq	s1,s2,80002480 <wakeup+0x64>
        if (p != myproc())
    80002458:	fffff097          	auipc	ra,0xfffff
    8000245c:	7ae080e7          	jalr	1966(ra) # 80001c06 <myproc>
    80002460:	fea488e3          	beq	s1,a0,80002450 <wakeup+0x34>
            acquire(&p->lock);
    80002464:	8526                	mv	a0,s1
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	89a080e7          	jalr	-1894(ra) # 80000d00 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    8000246e:	4c9c                	lw	a5,24(s1)
    80002470:	fd379be3          	bne	a5,s3,80002446 <wakeup+0x2a>
    80002474:	709c                	ld	a5,32(s1)
    80002476:	fd4798e3          	bne	a5,s4,80002446 <wakeup+0x2a>
                p->state = RUNNABLE;
    8000247a:	0154ac23          	sw	s5,24(s1)
    8000247e:	b7e1                	j	80002446 <wakeup+0x2a>
        }
    }
}
    80002480:	70e2                	ld	ra,56(sp)
    80002482:	7442                	ld	s0,48(sp)
    80002484:	74a2                	ld	s1,40(sp)
    80002486:	7902                	ld	s2,32(sp)
    80002488:	69e2                	ld	s3,24(sp)
    8000248a:	6a42                	ld	s4,16(sp)
    8000248c:	6aa2                	ld	s5,8(sp)
    8000248e:	6121                	add	sp,sp,64
    80002490:	8082                	ret

0000000080002492 <reparent>:
{
    80002492:	7179                	add	sp,sp,-48
    80002494:	f406                	sd	ra,40(sp)
    80002496:	f022                	sd	s0,32(sp)
    80002498:	ec26                	sd	s1,24(sp)
    8000249a:	e84a                	sd	s2,16(sp)
    8000249c:	e44e                	sd	s3,8(sp)
    8000249e:	e052                	sd	s4,0(sp)
    800024a0:	1800                	add	s0,sp,48
    800024a2:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024a4:	0000f497          	auipc	s1,0xf
    800024a8:	c8c48493          	add	s1,s1,-884 # 80011130 <proc>
            pp->parent = initproc;
    800024ac:	00006a17          	auipc	s4,0x6
    800024b0:	5dca0a13          	add	s4,s4,1500 # 80008a88 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024b4:	00014997          	auipc	s3,0x14
    800024b8:	67c98993          	add	s3,s3,1660 # 80016b30 <tickslock>
    800024bc:	a029                	j	800024c6 <reparent+0x34>
    800024be:	16848493          	add	s1,s1,360
    800024c2:	01348d63          	beq	s1,s3,800024dc <reparent+0x4a>
        if (pp->parent == p)
    800024c6:	7c9c                	ld	a5,56(s1)
    800024c8:	ff279be3          	bne	a5,s2,800024be <reparent+0x2c>
            pp->parent = initproc;
    800024cc:	000a3503          	ld	a0,0(s4)
    800024d0:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    800024d2:	00000097          	auipc	ra,0x0
    800024d6:	f4a080e7          	jalr	-182(ra) # 8000241c <wakeup>
    800024da:	b7d5                	j	800024be <reparent+0x2c>
}
    800024dc:	70a2                	ld	ra,40(sp)
    800024de:	7402                	ld	s0,32(sp)
    800024e0:	64e2                	ld	s1,24(sp)
    800024e2:	6942                	ld	s2,16(sp)
    800024e4:	69a2                	ld	s3,8(sp)
    800024e6:	6a02                	ld	s4,0(sp)
    800024e8:	6145                	add	sp,sp,48
    800024ea:	8082                	ret

00000000800024ec <exit>:
{
    800024ec:	7179                	add	sp,sp,-48
    800024ee:	f406                	sd	ra,40(sp)
    800024f0:	f022                	sd	s0,32(sp)
    800024f2:	ec26                	sd	s1,24(sp)
    800024f4:	e84a                	sd	s2,16(sp)
    800024f6:	e44e                	sd	s3,8(sp)
    800024f8:	e052                	sd	s4,0(sp)
    800024fa:	1800                	add	s0,sp,48
    800024fc:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    800024fe:	fffff097          	auipc	ra,0xfffff
    80002502:	708080e7          	jalr	1800(ra) # 80001c06 <myproc>
    80002506:	89aa                	mv	s3,a0
    if (p == initproc)
    80002508:	00006797          	auipc	a5,0x6
    8000250c:	5807b783          	ld	a5,1408(a5) # 80008a88 <initproc>
    80002510:	0d050493          	add	s1,a0,208
    80002514:	15050913          	add	s2,a0,336
    80002518:	02a79363          	bne	a5,a0,8000253e <exit+0x52>
        panic("init exiting");
    8000251c:	00006517          	auipc	a0,0x6
    80002520:	d6450513          	add	a0,a0,-668 # 80008280 <__func__.1+0x278>
    80002524:	ffffe097          	auipc	ra,0xffffe
    80002528:	03c080e7          	jalr	60(ra) # 80000560 <panic>
            fileclose(f);
    8000252c:	00002097          	auipc	ra,0x2
    80002530:	4f6080e7          	jalr	1270(ra) # 80004a22 <fileclose>
            p->ofile[fd] = 0;
    80002534:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    80002538:	04a1                	add	s1,s1,8
    8000253a:	01248563          	beq	s1,s2,80002544 <exit+0x58>
        if (p->ofile[fd])
    8000253e:	6088                	ld	a0,0(s1)
    80002540:	f575                	bnez	a0,8000252c <exit+0x40>
    80002542:	bfdd                	j	80002538 <exit+0x4c>
    begin_op();
    80002544:	00002097          	auipc	ra,0x2
    80002548:	014080e7          	jalr	20(ra) # 80004558 <begin_op>
    iput(p->cwd);
    8000254c:	1509b503          	ld	a0,336(s3)
    80002550:	00001097          	auipc	ra,0x1
    80002554:	7f8080e7          	jalr	2040(ra) # 80003d48 <iput>
    end_op();
    80002558:	00002097          	auipc	ra,0x2
    8000255c:	07a080e7          	jalr	122(ra) # 800045d2 <end_op>
    p->cwd = 0;
    80002560:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002564:	0000f497          	auipc	s1,0xf
    80002568:	bb448493          	add	s1,s1,-1100 # 80011118 <wait_lock>
    8000256c:	8526                	mv	a0,s1
    8000256e:	ffffe097          	auipc	ra,0xffffe
    80002572:	792080e7          	jalr	1938(ra) # 80000d00 <acquire>
    reparent(p);
    80002576:	854e                	mv	a0,s3
    80002578:	00000097          	auipc	ra,0x0
    8000257c:	f1a080e7          	jalr	-230(ra) # 80002492 <reparent>
    wakeup(p->parent);
    80002580:	0389b503          	ld	a0,56(s3)
    80002584:	00000097          	auipc	ra,0x0
    80002588:	e98080e7          	jalr	-360(ra) # 8000241c <wakeup>
    acquire(&p->lock);
    8000258c:	854e                	mv	a0,s3
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	772080e7          	jalr	1906(ra) # 80000d00 <acquire>
    p->xstate = status;
    80002596:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    8000259a:	4795                	li	a5,5
    8000259c:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    800025a0:	8526                	mv	a0,s1
    800025a2:	fffff097          	auipc	ra,0xfffff
    800025a6:	812080e7          	jalr	-2030(ra) # 80000db4 <release>
    sched();
    800025aa:	00000097          	auipc	ra,0x0
    800025ae:	d04080e7          	jalr	-764(ra) # 800022ae <sched>
    panic("zombie exit");
    800025b2:	00006517          	auipc	a0,0x6
    800025b6:	cde50513          	add	a0,a0,-802 # 80008290 <__func__.1+0x288>
    800025ba:	ffffe097          	auipc	ra,0xffffe
    800025be:	fa6080e7          	jalr	-90(ra) # 80000560 <panic>

00000000800025c2 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800025c2:	7179                	add	sp,sp,-48
    800025c4:	f406                	sd	ra,40(sp)
    800025c6:	f022                	sd	s0,32(sp)
    800025c8:	ec26                	sd	s1,24(sp)
    800025ca:	e84a                	sd	s2,16(sp)
    800025cc:	e44e                	sd	s3,8(sp)
    800025ce:	1800                	add	s0,sp,48
    800025d0:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800025d2:	0000f497          	auipc	s1,0xf
    800025d6:	b5e48493          	add	s1,s1,-1186 # 80011130 <proc>
    800025da:	00014997          	auipc	s3,0x14
    800025de:	55698993          	add	s3,s3,1366 # 80016b30 <tickslock>
    {
        acquire(&p->lock);
    800025e2:	8526                	mv	a0,s1
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	71c080e7          	jalr	1820(ra) # 80000d00 <acquire>
        if (p->pid == pid)
    800025ec:	589c                	lw	a5,48(s1)
    800025ee:	01278d63          	beq	a5,s2,80002608 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    800025f2:	8526                	mv	a0,s1
    800025f4:	ffffe097          	auipc	ra,0xffffe
    800025f8:	7c0080e7          	jalr	1984(ra) # 80000db4 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800025fc:	16848493          	add	s1,s1,360
    80002600:	ff3491e3          	bne	s1,s3,800025e2 <kill+0x20>
    }
    return -1;
    80002604:	557d                	li	a0,-1
    80002606:	a829                	j	80002620 <kill+0x5e>
            p->killed = 1;
    80002608:	4785                	li	a5,1
    8000260a:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    8000260c:	4c98                	lw	a4,24(s1)
    8000260e:	4789                	li	a5,2
    80002610:	00f70f63          	beq	a4,a5,8000262e <kill+0x6c>
            release(&p->lock);
    80002614:	8526                	mv	a0,s1
    80002616:	ffffe097          	auipc	ra,0xffffe
    8000261a:	79e080e7          	jalr	1950(ra) # 80000db4 <release>
            return 0;
    8000261e:	4501                	li	a0,0
}
    80002620:	70a2                	ld	ra,40(sp)
    80002622:	7402                	ld	s0,32(sp)
    80002624:	64e2                	ld	s1,24(sp)
    80002626:	6942                	ld	s2,16(sp)
    80002628:	69a2                	ld	s3,8(sp)
    8000262a:	6145                	add	sp,sp,48
    8000262c:	8082                	ret
                p->state = RUNNABLE;
    8000262e:	478d                	li	a5,3
    80002630:	cc9c                	sw	a5,24(s1)
    80002632:	b7cd                	j	80002614 <kill+0x52>

0000000080002634 <setkilled>:

void setkilled(struct proc *p)
{
    80002634:	1101                	add	sp,sp,-32
    80002636:	ec06                	sd	ra,24(sp)
    80002638:	e822                	sd	s0,16(sp)
    8000263a:	e426                	sd	s1,8(sp)
    8000263c:	1000                	add	s0,sp,32
    8000263e:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	6c0080e7          	jalr	1728(ra) # 80000d00 <acquire>
    p->killed = 1;
    80002648:	4785                	li	a5,1
    8000264a:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    8000264c:	8526                	mv	a0,s1
    8000264e:	ffffe097          	auipc	ra,0xffffe
    80002652:	766080e7          	jalr	1894(ra) # 80000db4 <release>
}
    80002656:	60e2                	ld	ra,24(sp)
    80002658:	6442                	ld	s0,16(sp)
    8000265a:	64a2                	ld	s1,8(sp)
    8000265c:	6105                	add	sp,sp,32
    8000265e:	8082                	ret

0000000080002660 <killed>:

int killed(struct proc *p)
{
    80002660:	1101                	add	sp,sp,-32
    80002662:	ec06                	sd	ra,24(sp)
    80002664:	e822                	sd	s0,16(sp)
    80002666:	e426                	sd	s1,8(sp)
    80002668:	e04a                	sd	s2,0(sp)
    8000266a:	1000                	add	s0,sp,32
    8000266c:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	692080e7          	jalr	1682(ra) # 80000d00 <acquire>
    k = p->killed;
    80002676:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    8000267a:	8526                	mv	a0,s1
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	738080e7          	jalr	1848(ra) # 80000db4 <release>
    return k;
}
    80002684:	854a                	mv	a0,s2
    80002686:	60e2                	ld	ra,24(sp)
    80002688:	6442                	ld	s0,16(sp)
    8000268a:	64a2                	ld	s1,8(sp)
    8000268c:	6902                	ld	s2,0(sp)
    8000268e:	6105                	add	sp,sp,32
    80002690:	8082                	ret

0000000080002692 <wait>:
{
    80002692:	715d                	add	sp,sp,-80
    80002694:	e486                	sd	ra,72(sp)
    80002696:	e0a2                	sd	s0,64(sp)
    80002698:	fc26                	sd	s1,56(sp)
    8000269a:	f84a                	sd	s2,48(sp)
    8000269c:	f44e                	sd	s3,40(sp)
    8000269e:	f052                	sd	s4,32(sp)
    800026a0:	ec56                	sd	s5,24(sp)
    800026a2:	e85a                	sd	s6,16(sp)
    800026a4:	e45e                	sd	s7,8(sp)
    800026a6:	e062                	sd	s8,0(sp)
    800026a8:	0880                	add	s0,sp,80
    800026aa:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    800026ac:	fffff097          	auipc	ra,0xfffff
    800026b0:	55a080e7          	jalr	1370(ra) # 80001c06 <myproc>
    800026b4:	892a                	mv	s2,a0
    acquire(&wait_lock);
    800026b6:	0000f517          	auipc	a0,0xf
    800026ba:	a6250513          	add	a0,a0,-1438 # 80011118 <wait_lock>
    800026be:	ffffe097          	auipc	ra,0xffffe
    800026c2:	642080e7          	jalr	1602(ra) # 80000d00 <acquire>
        havekids = 0;
    800026c6:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    800026c8:	4a15                	li	s4,5
                havekids = 1;
    800026ca:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800026cc:	00014997          	auipc	s3,0x14
    800026d0:	46498993          	add	s3,s3,1124 # 80016b30 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    800026d4:	0000fc17          	auipc	s8,0xf
    800026d8:	a44c0c13          	add	s8,s8,-1468 # 80011118 <wait_lock>
    800026dc:	a0d1                	j	800027a0 <wait+0x10e>
                    pid = pp->pid;
    800026de:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026e2:	000b0e63          	beqz	s6,800026fe <wait+0x6c>
    800026e6:	4691                	li	a3,4
    800026e8:	02c48613          	add	a2,s1,44
    800026ec:	85da                	mv	a1,s6
    800026ee:	05093503          	ld	a0,80(s2)
    800026f2:	fffff097          	auipc	ra,0xfffff
    800026f6:	0b8080e7          	jalr	184(ra) # 800017aa <copyout>
    800026fa:	04054163          	bltz	a0,8000273c <wait+0xaa>
                    freeproc(pp);
    800026fe:	8526                	mv	a0,s1
    80002700:	fffff097          	auipc	ra,0xfffff
    80002704:	6b8080e7          	jalr	1720(ra) # 80001db8 <freeproc>
                    release(&pp->lock);
    80002708:	8526                	mv	a0,s1
    8000270a:	ffffe097          	auipc	ra,0xffffe
    8000270e:	6aa080e7          	jalr	1706(ra) # 80000db4 <release>
                    release(&wait_lock);
    80002712:	0000f517          	auipc	a0,0xf
    80002716:	a0650513          	add	a0,a0,-1530 # 80011118 <wait_lock>
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	69a080e7          	jalr	1690(ra) # 80000db4 <release>
}
    80002722:	854e                	mv	a0,s3
    80002724:	60a6                	ld	ra,72(sp)
    80002726:	6406                	ld	s0,64(sp)
    80002728:	74e2                	ld	s1,56(sp)
    8000272a:	7942                	ld	s2,48(sp)
    8000272c:	79a2                	ld	s3,40(sp)
    8000272e:	7a02                	ld	s4,32(sp)
    80002730:	6ae2                	ld	s5,24(sp)
    80002732:	6b42                	ld	s6,16(sp)
    80002734:	6ba2                	ld	s7,8(sp)
    80002736:	6c02                	ld	s8,0(sp)
    80002738:	6161                	add	sp,sp,80
    8000273a:	8082                	ret
                        release(&pp->lock);
    8000273c:	8526                	mv	a0,s1
    8000273e:	ffffe097          	auipc	ra,0xffffe
    80002742:	676080e7          	jalr	1654(ra) # 80000db4 <release>
                        release(&wait_lock);
    80002746:	0000f517          	auipc	a0,0xf
    8000274a:	9d250513          	add	a0,a0,-1582 # 80011118 <wait_lock>
    8000274e:	ffffe097          	auipc	ra,0xffffe
    80002752:	666080e7          	jalr	1638(ra) # 80000db4 <release>
                        return -1;
    80002756:	59fd                	li	s3,-1
    80002758:	b7e9                	j	80002722 <wait+0x90>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    8000275a:	16848493          	add	s1,s1,360
    8000275e:	03348463          	beq	s1,s3,80002786 <wait+0xf4>
            if (pp->parent == p)
    80002762:	7c9c                	ld	a5,56(s1)
    80002764:	ff279be3          	bne	a5,s2,8000275a <wait+0xc8>
                acquire(&pp->lock);
    80002768:	8526                	mv	a0,s1
    8000276a:	ffffe097          	auipc	ra,0xffffe
    8000276e:	596080e7          	jalr	1430(ra) # 80000d00 <acquire>
                if (pp->state == ZOMBIE)
    80002772:	4c9c                	lw	a5,24(s1)
    80002774:	f74785e3          	beq	a5,s4,800026de <wait+0x4c>
                release(&pp->lock);
    80002778:	8526                	mv	a0,s1
    8000277a:	ffffe097          	auipc	ra,0xffffe
    8000277e:	63a080e7          	jalr	1594(ra) # 80000db4 <release>
                havekids = 1;
    80002782:	8756                	mv	a4,s5
    80002784:	bfd9                	j	8000275a <wait+0xc8>
        if (!havekids || killed(p))
    80002786:	c31d                	beqz	a4,800027ac <wait+0x11a>
    80002788:	854a                	mv	a0,s2
    8000278a:	00000097          	auipc	ra,0x0
    8000278e:	ed6080e7          	jalr	-298(ra) # 80002660 <killed>
    80002792:	ed09                	bnez	a0,800027ac <wait+0x11a>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002794:	85e2                	mv	a1,s8
    80002796:	854a                	mv	a0,s2
    80002798:	00000097          	auipc	ra,0x0
    8000279c:	c20080e7          	jalr	-992(ra) # 800023b8 <sleep>
        havekids = 0;
    800027a0:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800027a2:	0000f497          	auipc	s1,0xf
    800027a6:	98e48493          	add	s1,s1,-1650 # 80011130 <proc>
    800027aa:	bf65                	j	80002762 <wait+0xd0>
            release(&wait_lock);
    800027ac:	0000f517          	auipc	a0,0xf
    800027b0:	96c50513          	add	a0,a0,-1684 # 80011118 <wait_lock>
    800027b4:	ffffe097          	auipc	ra,0xffffe
    800027b8:	600080e7          	jalr	1536(ra) # 80000db4 <release>
            return -1;
    800027bc:	59fd                	li	s3,-1
    800027be:	b795                	j	80002722 <wait+0x90>

00000000800027c0 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027c0:	7179                	add	sp,sp,-48
    800027c2:	f406                	sd	ra,40(sp)
    800027c4:	f022                	sd	s0,32(sp)
    800027c6:	ec26                	sd	s1,24(sp)
    800027c8:	e84a                	sd	s2,16(sp)
    800027ca:	e44e                	sd	s3,8(sp)
    800027cc:	e052                	sd	s4,0(sp)
    800027ce:	1800                	add	s0,sp,48
    800027d0:	84aa                	mv	s1,a0
    800027d2:	892e                	mv	s2,a1
    800027d4:	89b2                	mv	s3,a2
    800027d6:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800027d8:	fffff097          	auipc	ra,0xfffff
    800027dc:	42e080e7          	jalr	1070(ra) # 80001c06 <myproc>
    if (user_dst)
    800027e0:	c08d                	beqz	s1,80002802 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    800027e2:	86d2                	mv	a3,s4
    800027e4:	864e                	mv	a2,s3
    800027e6:	85ca                	mv	a1,s2
    800027e8:	6928                	ld	a0,80(a0)
    800027ea:	fffff097          	auipc	ra,0xfffff
    800027ee:	fc0080e7          	jalr	-64(ra) # 800017aa <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    800027f2:	70a2                	ld	ra,40(sp)
    800027f4:	7402                	ld	s0,32(sp)
    800027f6:	64e2                	ld	s1,24(sp)
    800027f8:	6942                	ld	s2,16(sp)
    800027fa:	69a2                	ld	s3,8(sp)
    800027fc:	6a02                	ld	s4,0(sp)
    800027fe:	6145                	add	sp,sp,48
    80002800:	8082                	ret
        memmove((char *)dst, src, len);
    80002802:	000a061b          	sext.w	a2,s4
    80002806:	85ce                	mv	a1,s3
    80002808:	854a                	mv	a0,s2
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	64e080e7          	jalr	1614(ra) # 80000e58 <memmove>
        return 0;
    80002812:	8526                	mv	a0,s1
    80002814:	bff9                	j	800027f2 <either_copyout+0x32>

0000000080002816 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002816:	7179                	add	sp,sp,-48
    80002818:	f406                	sd	ra,40(sp)
    8000281a:	f022                	sd	s0,32(sp)
    8000281c:	ec26                	sd	s1,24(sp)
    8000281e:	e84a                	sd	s2,16(sp)
    80002820:	e44e                	sd	s3,8(sp)
    80002822:	e052                	sd	s4,0(sp)
    80002824:	1800                	add	s0,sp,48
    80002826:	892a                	mv	s2,a0
    80002828:	84ae                	mv	s1,a1
    8000282a:	89b2                	mv	s3,a2
    8000282c:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    8000282e:	fffff097          	auipc	ra,0xfffff
    80002832:	3d8080e7          	jalr	984(ra) # 80001c06 <myproc>
    if (user_src)
    80002836:	c08d                	beqz	s1,80002858 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    80002838:	86d2                	mv	a3,s4
    8000283a:	864e                	mv	a2,s3
    8000283c:	85ca                	mv	a1,s2
    8000283e:	6928                	ld	a0,80(a0)
    80002840:	fffff097          	auipc	ra,0xfffff
    80002844:	ff6080e7          	jalr	-10(ra) # 80001836 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    80002848:	70a2                	ld	ra,40(sp)
    8000284a:	7402                	ld	s0,32(sp)
    8000284c:	64e2                	ld	s1,24(sp)
    8000284e:	6942                	ld	s2,16(sp)
    80002850:	69a2                	ld	s3,8(sp)
    80002852:	6a02                	ld	s4,0(sp)
    80002854:	6145                	add	sp,sp,48
    80002856:	8082                	ret
        memmove(dst, (char *)src, len);
    80002858:	000a061b          	sext.w	a2,s4
    8000285c:	85ce                	mv	a1,s3
    8000285e:	854a                	mv	a0,s2
    80002860:	ffffe097          	auipc	ra,0xffffe
    80002864:	5f8080e7          	jalr	1528(ra) # 80000e58 <memmove>
        return 0;
    80002868:	8526                	mv	a0,s1
    8000286a:	bff9                	j	80002848 <either_copyin+0x32>

000000008000286c <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000286c:	715d                	add	sp,sp,-80
    8000286e:	e486                	sd	ra,72(sp)
    80002870:	e0a2                	sd	s0,64(sp)
    80002872:	fc26                	sd	s1,56(sp)
    80002874:	f84a                	sd	s2,48(sp)
    80002876:	f44e                	sd	s3,40(sp)
    80002878:	f052                	sd	s4,32(sp)
    8000287a:	ec56                	sd	s5,24(sp)
    8000287c:	e85a                	sd	s6,16(sp)
    8000287e:	e45e                	sd	s7,8(sp)
    80002880:	0880                	add	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002882:	00005517          	auipc	a0,0x5
    80002886:	79e50513          	add	a0,a0,1950 # 80008020 <__func__.1+0x18>
    8000288a:	ffffe097          	auipc	ra,0xffffe
    8000288e:	d32080e7          	jalr	-718(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002892:	0000f497          	auipc	s1,0xf
    80002896:	9f648493          	add	s1,s1,-1546 # 80011288 <proc+0x158>
    8000289a:	00014917          	auipc	s2,0x14
    8000289e:	3ee90913          	add	s2,s2,1006 # 80016c88 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028a2:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    800028a4:	00006997          	auipc	s3,0x6
    800028a8:	9fc98993          	add	s3,s3,-1540 # 800082a0 <__func__.1+0x298>
        printf("%d <%s %s", p->pid, state, p->name);
    800028ac:	00006a97          	auipc	s5,0x6
    800028b0:	9fca8a93          	add	s5,s5,-1540 # 800082a8 <__func__.1+0x2a0>
        printf("\n");
    800028b4:	00005a17          	auipc	s4,0x5
    800028b8:	76ca0a13          	add	s4,s4,1900 # 80008020 <__func__.1+0x18>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028bc:	00006b97          	auipc	s7,0x6
    800028c0:	fdcb8b93          	add	s7,s7,-36 # 80008898 <states.0>
    800028c4:	a00d                	j	800028e6 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    800028c6:	ed86a583          	lw	a1,-296(a3)
    800028ca:	8556                	mv	a0,s5
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	cf0080e7          	jalr	-784(ra) # 800005bc <printf>
        printf("\n");
    800028d4:	8552                	mv	a0,s4
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	ce6080e7          	jalr	-794(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800028de:	16848493          	add	s1,s1,360
    800028e2:	03248263          	beq	s1,s2,80002906 <procdump+0x9a>
        if (p->state == UNUSED)
    800028e6:	86a6                	mv	a3,s1
    800028e8:	ec04a783          	lw	a5,-320(s1)
    800028ec:	dbed                	beqz	a5,800028de <procdump+0x72>
            state = "???";
    800028ee:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028f0:	fcfb6be3          	bltu	s6,a5,800028c6 <procdump+0x5a>
    800028f4:	02079713          	sll	a4,a5,0x20
    800028f8:	01d75793          	srl	a5,a4,0x1d
    800028fc:	97de                	add	a5,a5,s7
    800028fe:	6390                	ld	a2,0(a5)
    80002900:	f279                	bnez	a2,800028c6 <procdump+0x5a>
            state = "???";
    80002902:	864e                	mv	a2,s3
    80002904:	b7c9                	j	800028c6 <procdump+0x5a>
    }
}
    80002906:	60a6                	ld	ra,72(sp)
    80002908:	6406                	ld	s0,64(sp)
    8000290a:	74e2                	ld	s1,56(sp)
    8000290c:	7942                	ld	s2,48(sp)
    8000290e:	79a2                	ld	s3,40(sp)
    80002910:	7a02                	ld	s4,32(sp)
    80002912:	6ae2                	ld	s5,24(sp)
    80002914:	6b42                	ld	s6,16(sp)
    80002916:	6ba2                	ld	s7,8(sp)
    80002918:	6161                	add	sp,sp,80
    8000291a:	8082                	ret

000000008000291c <schedls>:

void schedls()
{
    8000291c:	1141                	add	sp,sp,-16
    8000291e:	e406                	sd	ra,8(sp)
    80002920:	e022                	sd	s0,0(sp)
    80002922:	0800                	add	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002924:	00006517          	auipc	a0,0x6
    80002928:	99450513          	add	a0,a0,-1644 # 800082b8 <__func__.1+0x2b0>
    8000292c:	ffffe097          	auipc	ra,0xffffe
    80002930:	c90080e7          	jalr	-880(ra) # 800005bc <printf>
    printf("====================================\n");
    80002934:	00006517          	auipc	a0,0x6
    80002938:	9ac50513          	add	a0,a0,-1620 # 800082e0 <__func__.1+0x2d8>
    8000293c:	ffffe097          	auipc	ra,0xffffe
    80002940:	c80080e7          	jalr	-896(ra) # 800005bc <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002944:	00006717          	auipc	a4,0x6
    80002948:	0f473703          	ld	a4,244(a4) # 80008a38 <available_schedulers+0x10>
    8000294c:	00006797          	auipc	a5,0x6
    80002950:	08c7b783          	ld	a5,140(a5) # 800089d8 <sched_pointer>
    80002954:	04f70663          	beq	a4,a5,800029a0 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002958:	00006517          	auipc	a0,0x6
    8000295c:	9b850513          	add	a0,a0,-1608 # 80008310 <__func__.1+0x308>
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	c5c080e7          	jalr	-932(ra) # 800005bc <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002968:	00006617          	auipc	a2,0x6
    8000296c:	0d862603          	lw	a2,216(a2) # 80008a40 <available_schedulers+0x18>
    80002970:	00006597          	auipc	a1,0x6
    80002974:	0b858593          	add	a1,a1,184 # 80008a28 <available_schedulers>
    80002978:	00006517          	auipc	a0,0x6
    8000297c:	9a050513          	add	a0,a0,-1632 # 80008318 <__func__.1+0x310>
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	c3c080e7          	jalr	-964(ra) # 800005bc <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002988:	00006517          	auipc	a0,0x6
    8000298c:	99850513          	add	a0,a0,-1640 # 80008320 <__func__.1+0x318>
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	c2c080e7          	jalr	-980(ra) # 800005bc <printf>
}
    80002998:	60a2                	ld	ra,8(sp)
    8000299a:	6402                	ld	s0,0(sp)
    8000299c:	0141                	add	sp,sp,16
    8000299e:	8082                	ret
            printf("[*]\t");
    800029a0:	00006517          	auipc	a0,0x6
    800029a4:	96850513          	add	a0,a0,-1688 # 80008308 <__func__.1+0x300>
    800029a8:	ffffe097          	auipc	ra,0xffffe
    800029ac:	c14080e7          	jalr	-1004(ra) # 800005bc <printf>
    800029b0:	bf65                	j	80002968 <schedls+0x4c>

00000000800029b2 <schedset>:

void schedset(int id)
{
    800029b2:	1141                	add	sp,sp,-16
    800029b4:	e406                	sd	ra,8(sp)
    800029b6:	e022                	sd	s0,0(sp)
    800029b8:	0800                	add	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    800029ba:	e90d                	bnez	a0,800029ec <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    800029bc:	00006797          	auipc	a5,0x6
    800029c0:	07c7b783          	ld	a5,124(a5) # 80008a38 <available_schedulers+0x10>
    800029c4:	00006717          	auipc	a4,0x6
    800029c8:	00f73a23          	sd	a5,20(a4) # 800089d8 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    800029cc:	00006597          	auipc	a1,0x6
    800029d0:	05c58593          	add	a1,a1,92 # 80008a28 <available_schedulers>
    800029d4:	00006517          	auipc	a0,0x6
    800029d8:	98c50513          	add	a0,a0,-1652 # 80008360 <__func__.1+0x358>
    800029dc:	ffffe097          	auipc	ra,0xffffe
    800029e0:	be0080e7          	jalr	-1056(ra) # 800005bc <printf>
    800029e4:	60a2                	ld	ra,8(sp)
    800029e6:	6402                	ld	s0,0(sp)
    800029e8:	0141                	add	sp,sp,16
    800029ea:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    800029ec:	00006517          	auipc	a0,0x6
    800029f0:	94c50513          	add	a0,a0,-1716 # 80008338 <__func__.1+0x330>
    800029f4:	ffffe097          	auipc	ra,0xffffe
    800029f8:	bc8080e7          	jalr	-1080(ra) # 800005bc <printf>
        return;
    800029fc:	b7e5                	j	800029e4 <schedset+0x32>

00000000800029fe <swtch>:
    800029fe:	00153023          	sd	ra,0(a0)
    80002a02:	00253423          	sd	sp,8(a0)
    80002a06:	e900                	sd	s0,16(a0)
    80002a08:	ed04                	sd	s1,24(a0)
    80002a0a:	03253023          	sd	s2,32(a0)
    80002a0e:	03353423          	sd	s3,40(a0)
    80002a12:	03453823          	sd	s4,48(a0)
    80002a16:	03553c23          	sd	s5,56(a0)
    80002a1a:	05653023          	sd	s6,64(a0)
    80002a1e:	05753423          	sd	s7,72(a0)
    80002a22:	05853823          	sd	s8,80(a0)
    80002a26:	05953c23          	sd	s9,88(a0)
    80002a2a:	07a53023          	sd	s10,96(a0)
    80002a2e:	07b53423          	sd	s11,104(a0)
    80002a32:	0005b083          	ld	ra,0(a1)
    80002a36:	0085b103          	ld	sp,8(a1)
    80002a3a:	6980                	ld	s0,16(a1)
    80002a3c:	6d84                	ld	s1,24(a1)
    80002a3e:	0205b903          	ld	s2,32(a1)
    80002a42:	0285b983          	ld	s3,40(a1)
    80002a46:	0305ba03          	ld	s4,48(a1)
    80002a4a:	0385ba83          	ld	s5,56(a1)
    80002a4e:	0405bb03          	ld	s6,64(a1)
    80002a52:	0485bb83          	ld	s7,72(a1)
    80002a56:	0505bc03          	ld	s8,80(a1)
    80002a5a:	0585bc83          	ld	s9,88(a1)
    80002a5e:	0605bd03          	ld	s10,96(a1)
    80002a62:	0685bd83          	ld	s11,104(a1)
    80002a66:	8082                	ret

0000000080002a68 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a68:	1141                	add	sp,sp,-16
    80002a6a:	e406                	sd	ra,8(sp)
    80002a6c:	e022                	sd	s0,0(sp)
    80002a6e:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    80002a70:	00006597          	auipc	a1,0x6
    80002a74:	94858593          	add	a1,a1,-1720 # 800083b8 <__func__.1+0x3b0>
    80002a78:	00014517          	auipc	a0,0x14
    80002a7c:	0b850513          	add	a0,a0,184 # 80016b30 <tickslock>
    80002a80:	ffffe097          	auipc	ra,0xffffe
    80002a84:	1f0080e7          	jalr	496(ra) # 80000c70 <initlock>
}
    80002a88:	60a2                	ld	ra,8(sp)
    80002a8a:	6402                	ld	s0,0(sp)
    80002a8c:	0141                	add	sp,sp,16
    80002a8e:	8082                	ret

0000000080002a90 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a90:	1141                	add	sp,sp,-16
    80002a92:	e422                	sd	s0,8(sp)
    80002a94:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a96:	00003797          	auipc	a5,0x3
    80002a9a:	68a78793          	add	a5,a5,1674 # 80006120 <kernelvec>
    80002a9e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002aa2:	6422                	ld	s0,8(sp)
    80002aa4:	0141                	add	sp,sp,16
    80002aa6:	8082                	ret

0000000080002aa8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002aa8:	1141                	add	sp,sp,-16
    80002aaa:	e406                	sd	ra,8(sp)
    80002aac:	e022                	sd	s0,0(sp)
    80002aae:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    80002ab0:	fffff097          	auipc	ra,0xfffff
    80002ab4:	156080e7          	jalr	342(ra) # 80001c06 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ab8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002abc:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002abe:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002ac2:	00004697          	auipc	a3,0x4
    80002ac6:	53e68693          	add	a3,a3,1342 # 80007000 <_trampoline>
    80002aca:	00004717          	auipc	a4,0x4
    80002ace:	53670713          	add	a4,a4,1334 # 80007000 <_trampoline>
    80002ad2:	8f15                	sub	a4,a4,a3
    80002ad4:	040007b7          	lui	a5,0x4000
    80002ad8:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002ada:	07b2                	sll	a5,a5,0xc
    80002adc:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ade:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ae2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ae4:	18002673          	csrr	a2,satp
    80002ae8:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002aea:	6d30                	ld	a2,88(a0)
    80002aec:	6138                	ld	a4,64(a0)
    80002aee:	6585                	lui	a1,0x1
    80002af0:	972e                	add	a4,a4,a1
    80002af2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002af4:	6d38                	ld	a4,88(a0)
    80002af6:	00000617          	auipc	a2,0x0
    80002afa:	13860613          	add	a2,a2,312 # 80002c2e <usertrap>
    80002afe:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b00:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b02:	8612                	mv	a2,tp
    80002b04:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b06:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b0a:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b0e:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b12:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b16:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b18:	6f18                	ld	a4,24(a4)
    80002b1a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b1e:	6928                	ld	a0,80(a0)
    80002b20:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b22:	00004717          	auipc	a4,0x4
    80002b26:	57a70713          	add	a4,a4,1402 # 8000709c <userret>
    80002b2a:	8f15                	sub	a4,a4,a3
    80002b2c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002b2e:	577d                	li	a4,-1
    80002b30:	177e                	sll	a4,a4,0x3f
    80002b32:	8d59                	or	a0,a0,a4
    80002b34:	9782                	jalr	a5
}
    80002b36:	60a2                	ld	ra,8(sp)
    80002b38:	6402                	ld	s0,0(sp)
    80002b3a:	0141                	add	sp,sp,16
    80002b3c:	8082                	ret

0000000080002b3e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b3e:	1101                	add	sp,sp,-32
    80002b40:	ec06                	sd	ra,24(sp)
    80002b42:	e822                	sd	s0,16(sp)
    80002b44:	e426                	sd	s1,8(sp)
    80002b46:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002b48:	00014497          	auipc	s1,0x14
    80002b4c:	fe848493          	add	s1,s1,-24 # 80016b30 <tickslock>
    80002b50:	8526                	mv	a0,s1
    80002b52:	ffffe097          	auipc	ra,0xffffe
    80002b56:	1ae080e7          	jalr	430(ra) # 80000d00 <acquire>
  ticks++;
    80002b5a:	00006517          	auipc	a0,0x6
    80002b5e:	f3650513          	add	a0,a0,-202 # 80008a90 <ticks>
    80002b62:	411c                	lw	a5,0(a0)
    80002b64:	2785                	addw	a5,a5,1
    80002b66:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002b68:	00000097          	auipc	ra,0x0
    80002b6c:	8b4080e7          	jalr	-1868(ra) # 8000241c <wakeup>
  release(&tickslock);
    80002b70:	8526                	mv	a0,s1
    80002b72:	ffffe097          	auipc	ra,0xffffe
    80002b76:	242080e7          	jalr	578(ra) # 80000db4 <release>
}
    80002b7a:	60e2                	ld	ra,24(sp)
    80002b7c:	6442                	ld	s0,16(sp)
    80002b7e:	64a2                	ld	s1,8(sp)
    80002b80:	6105                	add	sp,sp,32
    80002b82:	8082                	ret

0000000080002b84 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b84:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b88:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002b8a:	0a07d163          	bgez	a5,80002c2c <devintr+0xa8>
{
    80002b8e:	1101                	add	sp,sp,-32
    80002b90:	ec06                	sd	ra,24(sp)
    80002b92:	e822                	sd	s0,16(sp)
    80002b94:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    80002b96:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002b9a:	46a5                	li	a3,9
    80002b9c:	00d70c63          	beq	a4,a3,80002bb4 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002ba0:	577d                	li	a4,-1
    80002ba2:	177e                	sll	a4,a4,0x3f
    80002ba4:	0705                	add	a4,a4,1
    return 0;
    80002ba6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ba8:	06e78163          	beq	a5,a4,80002c0a <devintr+0x86>
  }
}
    80002bac:	60e2                	ld	ra,24(sp)
    80002bae:	6442                	ld	s0,16(sp)
    80002bb0:	6105                	add	sp,sp,32
    80002bb2:	8082                	ret
    80002bb4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002bb6:	00003097          	auipc	ra,0x3
    80002bba:	676080e7          	jalr	1654(ra) # 8000622c <plic_claim>
    80002bbe:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002bc0:	47a9                	li	a5,10
    80002bc2:	00f50963          	beq	a0,a5,80002bd4 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002bc6:	4785                	li	a5,1
    80002bc8:	00f50b63          	beq	a0,a5,80002bde <devintr+0x5a>
    return 1;
    80002bcc:	4505                	li	a0,1
    } else if(irq){
    80002bce:	ec89                	bnez	s1,80002be8 <devintr+0x64>
    80002bd0:	64a2                	ld	s1,8(sp)
    80002bd2:	bfe9                	j	80002bac <devintr+0x28>
      uartintr();
    80002bd4:	ffffe097          	auipc	ra,0xffffe
    80002bd8:	e38080e7          	jalr	-456(ra) # 80000a0c <uartintr>
    if(irq)
    80002bdc:	a839                	j	80002bfa <devintr+0x76>
      virtio_disk_intr();
    80002bde:	00004097          	auipc	ra,0x4
    80002be2:	b78080e7          	jalr	-1160(ra) # 80006756 <virtio_disk_intr>
    if(irq)
    80002be6:	a811                	j	80002bfa <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002be8:	85a6                	mv	a1,s1
    80002bea:	00005517          	auipc	a0,0x5
    80002bee:	7d650513          	add	a0,a0,2006 # 800083c0 <__func__.1+0x3b8>
    80002bf2:	ffffe097          	auipc	ra,0xffffe
    80002bf6:	9ca080e7          	jalr	-1590(ra) # 800005bc <printf>
      plic_complete(irq);
    80002bfa:	8526                	mv	a0,s1
    80002bfc:	00003097          	auipc	ra,0x3
    80002c00:	654080e7          	jalr	1620(ra) # 80006250 <plic_complete>
    return 1;
    80002c04:	4505                	li	a0,1
    80002c06:	64a2                	ld	s1,8(sp)
    80002c08:	b755                	j	80002bac <devintr+0x28>
    if(cpuid() == 0){
    80002c0a:	fffff097          	auipc	ra,0xfffff
    80002c0e:	fd0080e7          	jalr	-48(ra) # 80001bda <cpuid>
    80002c12:	c901                	beqz	a0,80002c22 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c14:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c18:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c1a:	14479073          	csrw	sip,a5
    return 2;
    80002c1e:	4509                	li	a0,2
    80002c20:	b771                	j	80002bac <devintr+0x28>
      clockintr();
    80002c22:	00000097          	auipc	ra,0x0
    80002c26:	f1c080e7          	jalr	-228(ra) # 80002b3e <clockintr>
    80002c2a:	b7ed                	j	80002c14 <devintr+0x90>
}
    80002c2c:	8082                	ret

0000000080002c2e <usertrap>:
{
    80002c2e:	1101                	add	sp,sp,-32
    80002c30:	ec06                	sd	ra,24(sp)
    80002c32:	e822                	sd	s0,16(sp)
    80002c34:	e426                	sd	s1,8(sp)
    80002c36:	e04a                	sd	s2,0(sp)
    80002c38:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c3a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c3e:	1007f793          	and	a5,a5,256
    80002c42:	e3b1                	bnez	a5,80002c86 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c44:	00003797          	auipc	a5,0x3
    80002c48:	4dc78793          	add	a5,a5,1244 # 80006120 <kernelvec>
    80002c4c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c50:	fffff097          	auipc	ra,0xfffff
    80002c54:	fb6080e7          	jalr	-74(ra) # 80001c06 <myproc>
    80002c58:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c5a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c5c:	14102773          	csrr	a4,sepc
    80002c60:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c62:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c66:	47a1                	li	a5,8
    80002c68:	02f70763          	beq	a4,a5,80002c96 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002c6c:	00000097          	auipc	ra,0x0
    80002c70:	f18080e7          	jalr	-232(ra) # 80002b84 <devintr>
    80002c74:	892a                	mv	s2,a0
    80002c76:	c151                	beqz	a0,80002cfa <usertrap+0xcc>
  if(killed(p))
    80002c78:	8526                	mv	a0,s1
    80002c7a:	00000097          	auipc	ra,0x0
    80002c7e:	9e6080e7          	jalr	-1562(ra) # 80002660 <killed>
    80002c82:	c929                	beqz	a0,80002cd4 <usertrap+0xa6>
    80002c84:	a099                	j	80002cca <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002c86:	00005517          	auipc	a0,0x5
    80002c8a:	75a50513          	add	a0,a0,1882 # 800083e0 <__func__.1+0x3d8>
    80002c8e:	ffffe097          	auipc	ra,0xffffe
    80002c92:	8d2080e7          	jalr	-1838(ra) # 80000560 <panic>
    if(killed(p))
    80002c96:	00000097          	auipc	ra,0x0
    80002c9a:	9ca080e7          	jalr	-1590(ra) # 80002660 <killed>
    80002c9e:	e921                	bnez	a0,80002cee <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002ca0:	6cb8                	ld	a4,88(s1)
    80002ca2:	6f1c                	ld	a5,24(a4)
    80002ca4:	0791                	add	a5,a5,4
    80002ca6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ca8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002cac:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cb0:	10079073          	csrw	sstatus,a5
    syscall();
    80002cb4:	00000097          	auipc	ra,0x0
    80002cb8:	2d4080e7          	jalr	724(ra) # 80002f88 <syscall>
  if(killed(p))
    80002cbc:	8526                	mv	a0,s1
    80002cbe:	00000097          	auipc	ra,0x0
    80002cc2:	9a2080e7          	jalr	-1630(ra) # 80002660 <killed>
    80002cc6:	c911                	beqz	a0,80002cda <usertrap+0xac>
    80002cc8:	4901                	li	s2,0
    exit(-1);
    80002cca:	557d                	li	a0,-1
    80002ccc:	00000097          	auipc	ra,0x0
    80002cd0:	820080e7          	jalr	-2016(ra) # 800024ec <exit>
  if(which_dev == 2)
    80002cd4:	4789                	li	a5,2
    80002cd6:	04f90f63          	beq	s2,a5,80002d34 <usertrap+0x106>
  usertrapret();
    80002cda:	00000097          	auipc	ra,0x0
    80002cde:	dce080e7          	jalr	-562(ra) # 80002aa8 <usertrapret>
}
    80002ce2:	60e2                	ld	ra,24(sp)
    80002ce4:	6442                	ld	s0,16(sp)
    80002ce6:	64a2                	ld	s1,8(sp)
    80002ce8:	6902                	ld	s2,0(sp)
    80002cea:	6105                	add	sp,sp,32
    80002cec:	8082                	ret
      exit(-1);
    80002cee:	557d                	li	a0,-1
    80002cf0:	fffff097          	auipc	ra,0xfffff
    80002cf4:	7fc080e7          	jalr	2044(ra) # 800024ec <exit>
    80002cf8:	b765                	j	80002ca0 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cfa:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002cfe:	5890                	lw	a2,48(s1)
    80002d00:	00005517          	auipc	a0,0x5
    80002d04:	70050513          	add	a0,a0,1792 # 80008400 <__func__.1+0x3f8>
    80002d08:	ffffe097          	auipc	ra,0xffffe
    80002d0c:	8b4080e7          	jalr	-1868(ra) # 800005bc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d10:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d14:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d18:	00005517          	auipc	a0,0x5
    80002d1c:	71850513          	add	a0,a0,1816 # 80008430 <__func__.1+0x428>
    80002d20:	ffffe097          	auipc	ra,0xffffe
    80002d24:	89c080e7          	jalr	-1892(ra) # 800005bc <printf>
    setkilled(p);
    80002d28:	8526                	mv	a0,s1
    80002d2a:	00000097          	auipc	ra,0x0
    80002d2e:	90a080e7          	jalr	-1782(ra) # 80002634 <setkilled>
    80002d32:	b769                	j	80002cbc <usertrap+0x8e>
    yield();
    80002d34:	fffff097          	auipc	ra,0xfffff
    80002d38:	648080e7          	jalr	1608(ra) # 8000237c <yield>
    80002d3c:	bf79                	j	80002cda <usertrap+0xac>

0000000080002d3e <kerneltrap>:
{
    80002d3e:	7179                	add	sp,sp,-48
    80002d40:	f406                	sd	ra,40(sp)
    80002d42:	f022                	sd	s0,32(sp)
    80002d44:	ec26                	sd	s1,24(sp)
    80002d46:	e84a                	sd	s2,16(sp)
    80002d48:	e44e                	sd	s3,8(sp)
    80002d4a:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d4c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d50:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d54:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d58:	1004f793          	and	a5,s1,256
    80002d5c:	cb85                	beqz	a5,80002d8c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d5e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d62:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002d64:	ef85                	bnez	a5,80002d9c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002d66:	00000097          	auipc	ra,0x0
    80002d6a:	e1e080e7          	jalr	-482(ra) # 80002b84 <devintr>
    80002d6e:	cd1d                	beqz	a0,80002dac <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d70:	4789                	li	a5,2
    80002d72:	06f50a63          	beq	a0,a5,80002de6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d76:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d7a:	10049073          	csrw	sstatus,s1
}
    80002d7e:	70a2                	ld	ra,40(sp)
    80002d80:	7402                	ld	s0,32(sp)
    80002d82:	64e2                	ld	s1,24(sp)
    80002d84:	6942                	ld	s2,16(sp)
    80002d86:	69a2                	ld	s3,8(sp)
    80002d88:	6145                	add	sp,sp,48
    80002d8a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d8c:	00005517          	auipc	a0,0x5
    80002d90:	6c450513          	add	a0,a0,1732 # 80008450 <__func__.1+0x448>
    80002d94:	ffffd097          	auipc	ra,0xffffd
    80002d98:	7cc080e7          	jalr	1996(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d9c:	00005517          	auipc	a0,0x5
    80002da0:	6dc50513          	add	a0,a0,1756 # 80008478 <__func__.1+0x470>
    80002da4:	ffffd097          	auipc	ra,0xffffd
    80002da8:	7bc080e7          	jalr	1980(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002dac:	85ce                	mv	a1,s3
    80002dae:	00005517          	auipc	a0,0x5
    80002db2:	6ea50513          	add	a0,a0,1770 # 80008498 <__func__.1+0x490>
    80002db6:	ffffe097          	auipc	ra,0xffffe
    80002dba:	806080e7          	jalr	-2042(ra) # 800005bc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dbe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002dc2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002dc6:	00005517          	auipc	a0,0x5
    80002dca:	6e250513          	add	a0,a0,1762 # 800084a8 <__func__.1+0x4a0>
    80002dce:	ffffd097          	auipc	ra,0xffffd
    80002dd2:	7ee080e7          	jalr	2030(ra) # 800005bc <printf>
    panic("kerneltrap");
    80002dd6:	00005517          	auipc	a0,0x5
    80002dda:	6ea50513          	add	a0,a0,1770 # 800084c0 <__func__.1+0x4b8>
    80002dde:	ffffd097          	auipc	ra,0xffffd
    80002de2:	782080e7          	jalr	1922(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002de6:	fffff097          	auipc	ra,0xfffff
    80002dea:	e20080e7          	jalr	-480(ra) # 80001c06 <myproc>
    80002dee:	d541                	beqz	a0,80002d76 <kerneltrap+0x38>
    80002df0:	fffff097          	auipc	ra,0xfffff
    80002df4:	e16080e7          	jalr	-490(ra) # 80001c06 <myproc>
    80002df8:	4d18                	lw	a4,24(a0)
    80002dfa:	4791                	li	a5,4
    80002dfc:	f6f71de3          	bne	a4,a5,80002d76 <kerneltrap+0x38>
    yield();
    80002e00:	fffff097          	auipc	ra,0xfffff
    80002e04:	57c080e7          	jalr	1404(ra) # 8000237c <yield>
    80002e08:	b7bd                	j	80002d76 <kerneltrap+0x38>

0000000080002e0a <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e0a:	1101                	add	sp,sp,-32
    80002e0c:	ec06                	sd	ra,24(sp)
    80002e0e:	e822                	sd	s0,16(sp)
    80002e10:	e426                	sd	s1,8(sp)
    80002e12:	1000                	add	s0,sp,32
    80002e14:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80002e16:	fffff097          	auipc	ra,0xfffff
    80002e1a:	df0080e7          	jalr	-528(ra) # 80001c06 <myproc>
    switch (n)
    80002e1e:	4795                	li	a5,5
    80002e20:	0497e163          	bltu	a5,s1,80002e62 <argraw+0x58>
    80002e24:	048a                	sll	s1,s1,0x2
    80002e26:	00006717          	auipc	a4,0x6
    80002e2a:	aa270713          	add	a4,a4,-1374 # 800088c8 <states.0+0x30>
    80002e2e:	94ba                	add	s1,s1,a4
    80002e30:	409c                	lw	a5,0(s1)
    80002e32:	97ba                	add	a5,a5,a4
    80002e34:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80002e36:	6d3c                	ld	a5,88(a0)
    80002e38:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002e3a:	60e2                	ld	ra,24(sp)
    80002e3c:	6442                	ld	s0,16(sp)
    80002e3e:	64a2                	ld	s1,8(sp)
    80002e40:	6105                	add	sp,sp,32
    80002e42:	8082                	ret
        return p->trapframe->a1;
    80002e44:	6d3c                	ld	a5,88(a0)
    80002e46:	7fa8                	ld	a0,120(a5)
    80002e48:	bfcd                	j	80002e3a <argraw+0x30>
        return p->trapframe->a2;
    80002e4a:	6d3c                	ld	a5,88(a0)
    80002e4c:	63c8                	ld	a0,128(a5)
    80002e4e:	b7f5                	j	80002e3a <argraw+0x30>
        return p->trapframe->a3;
    80002e50:	6d3c                	ld	a5,88(a0)
    80002e52:	67c8                	ld	a0,136(a5)
    80002e54:	b7dd                	j	80002e3a <argraw+0x30>
        return p->trapframe->a4;
    80002e56:	6d3c                	ld	a5,88(a0)
    80002e58:	6bc8                	ld	a0,144(a5)
    80002e5a:	b7c5                	j	80002e3a <argraw+0x30>
        return p->trapframe->a5;
    80002e5c:	6d3c                	ld	a5,88(a0)
    80002e5e:	6fc8                	ld	a0,152(a5)
    80002e60:	bfe9                	j	80002e3a <argraw+0x30>
    panic("argraw");
    80002e62:	00005517          	auipc	a0,0x5
    80002e66:	66e50513          	add	a0,a0,1646 # 800084d0 <__func__.1+0x4c8>
    80002e6a:	ffffd097          	auipc	ra,0xffffd
    80002e6e:	6f6080e7          	jalr	1782(ra) # 80000560 <panic>

0000000080002e72 <fetchaddr>:
{
    80002e72:	1101                	add	sp,sp,-32
    80002e74:	ec06                	sd	ra,24(sp)
    80002e76:	e822                	sd	s0,16(sp)
    80002e78:	e426                	sd	s1,8(sp)
    80002e7a:	e04a                	sd	s2,0(sp)
    80002e7c:	1000                	add	s0,sp,32
    80002e7e:	84aa                	mv	s1,a0
    80002e80:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002e82:	fffff097          	auipc	ra,0xfffff
    80002e86:	d84080e7          	jalr	-636(ra) # 80001c06 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002e8a:	653c                	ld	a5,72(a0)
    80002e8c:	02f4f863          	bgeu	s1,a5,80002ebc <fetchaddr+0x4a>
    80002e90:	00848713          	add	a4,s1,8
    80002e94:	02e7e663          	bltu	a5,a4,80002ec0 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e98:	46a1                	li	a3,8
    80002e9a:	8626                	mv	a2,s1
    80002e9c:	85ca                	mv	a1,s2
    80002e9e:	6928                	ld	a0,80(a0)
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	996080e7          	jalr	-1642(ra) # 80001836 <copyin>
    80002ea8:	00a03533          	snez	a0,a0
    80002eac:	40a00533          	neg	a0,a0
}
    80002eb0:	60e2                	ld	ra,24(sp)
    80002eb2:	6442                	ld	s0,16(sp)
    80002eb4:	64a2                	ld	s1,8(sp)
    80002eb6:	6902                	ld	s2,0(sp)
    80002eb8:	6105                	add	sp,sp,32
    80002eba:	8082                	ret
        return -1;
    80002ebc:	557d                	li	a0,-1
    80002ebe:	bfcd                	j	80002eb0 <fetchaddr+0x3e>
    80002ec0:	557d                	li	a0,-1
    80002ec2:	b7fd                	j	80002eb0 <fetchaddr+0x3e>

0000000080002ec4 <fetchstr>:
{
    80002ec4:	7179                	add	sp,sp,-48
    80002ec6:	f406                	sd	ra,40(sp)
    80002ec8:	f022                	sd	s0,32(sp)
    80002eca:	ec26                	sd	s1,24(sp)
    80002ecc:	e84a                	sd	s2,16(sp)
    80002ece:	e44e                	sd	s3,8(sp)
    80002ed0:	1800                	add	s0,sp,48
    80002ed2:	892a                	mv	s2,a0
    80002ed4:	84ae                	mv	s1,a1
    80002ed6:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80002ed8:	fffff097          	auipc	ra,0xfffff
    80002edc:	d2e080e7          	jalr	-722(ra) # 80001c06 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002ee0:	86ce                	mv	a3,s3
    80002ee2:	864a                	mv	a2,s2
    80002ee4:	85a6                	mv	a1,s1
    80002ee6:	6928                	ld	a0,80(a0)
    80002ee8:	fffff097          	auipc	ra,0xfffff
    80002eec:	9dc080e7          	jalr	-1572(ra) # 800018c4 <copyinstr>
    80002ef0:	00054e63          	bltz	a0,80002f0c <fetchstr+0x48>
    return strlen(buf);
    80002ef4:	8526                	mv	a0,s1
    80002ef6:	ffffe097          	auipc	ra,0xffffe
    80002efa:	07a080e7          	jalr	122(ra) # 80000f70 <strlen>
}
    80002efe:	70a2                	ld	ra,40(sp)
    80002f00:	7402                	ld	s0,32(sp)
    80002f02:	64e2                	ld	s1,24(sp)
    80002f04:	6942                	ld	s2,16(sp)
    80002f06:	69a2                	ld	s3,8(sp)
    80002f08:	6145                	add	sp,sp,48
    80002f0a:	8082                	ret
        return -1;
    80002f0c:	557d                	li	a0,-1
    80002f0e:	bfc5                	j	80002efe <fetchstr+0x3a>

0000000080002f10 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002f10:	1101                	add	sp,sp,-32
    80002f12:	ec06                	sd	ra,24(sp)
    80002f14:	e822                	sd	s0,16(sp)
    80002f16:	e426                	sd	s1,8(sp)
    80002f18:	1000                	add	s0,sp,32
    80002f1a:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002f1c:	00000097          	auipc	ra,0x0
    80002f20:	eee080e7          	jalr	-274(ra) # 80002e0a <argraw>
    80002f24:	c088                	sw	a0,0(s1)
}
    80002f26:	60e2                	ld	ra,24(sp)
    80002f28:	6442                	ld	s0,16(sp)
    80002f2a:	64a2                	ld	s1,8(sp)
    80002f2c:	6105                	add	sp,sp,32
    80002f2e:	8082                	ret

0000000080002f30 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002f30:	1101                	add	sp,sp,-32
    80002f32:	ec06                	sd	ra,24(sp)
    80002f34:	e822                	sd	s0,16(sp)
    80002f36:	e426                	sd	s1,8(sp)
    80002f38:	1000                	add	s0,sp,32
    80002f3a:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002f3c:	00000097          	auipc	ra,0x0
    80002f40:	ece080e7          	jalr	-306(ra) # 80002e0a <argraw>
    80002f44:	e088                	sd	a0,0(s1)
}
    80002f46:	60e2                	ld	ra,24(sp)
    80002f48:	6442                	ld	s0,16(sp)
    80002f4a:	64a2                	ld	s1,8(sp)
    80002f4c:	6105                	add	sp,sp,32
    80002f4e:	8082                	ret

0000000080002f50 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002f50:	7179                	add	sp,sp,-48
    80002f52:	f406                	sd	ra,40(sp)
    80002f54:	f022                	sd	s0,32(sp)
    80002f56:	ec26                	sd	s1,24(sp)
    80002f58:	e84a                	sd	s2,16(sp)
    80002f5a:	1800                	add	s0,sp,48
    80002f5c:	84ae                	mv	s1,a1
    80002f5e:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80002f60:	fd840593          	add	a1,s0,-40
    80002f64:	00000097          	auipc	ra,0x0
    80002f68:	fcc080e7          	jalr	-52(ra) # 80002f30 <argaddr>
    return fetchstr(addr, buf, max);
    80002f6c:	864a                	mv	a2,s2
    80002f6e:	85a6                	mv	a1,s1
    80002f70:	fd843503          	ld	a0,-40(s0)
    80002f74:	00000097          	auipc	ra,0x0
    80002f78:	f50080e7          	jalr	-176(ra) # 80002ec4 <fetchstr>
}
    80002f7c:	70a2                	ld	ra,40(sp)
    80002f7e:	7402                	ld	s0,32(sp)
    80002f80:	64e2                	ld	s1,24(sp)
    80002f82:	6942                	ld	s2,16(sp)
    80002f84:	6145                	add	sp,sp,48
    80002f86:	8082                	ret

0000000080002f88 <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    80002f88:	1101                	add	sp,sp,-32
    80002f8a:	ec06                	sd	ra,24(sp)
    80002f8c:	e822                	sd	s0,16(sp)
    80002f8e:	e426                	sd	s1,8(sp)
    80002f90:	e04a                	sd	s2,0(sp)
    80002f92:	1000                	add	s0,sp,32
    int num;
    struct proc *p = myproc();
    80002f94:	fffff097          	auipc	ra,0xfffff
    80002f98:	c72080e7          	jalr	-910(ra) # 80001c06 <myproc>
    80002f9c:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80002f9e:	05853903          	ld	s2,88(a0)
    80002fa2:	0a893783          	ld	a5,168(s2)
    80002fa6:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002faa:	37fd                	addw	a5,a5,-1
    80002fac:	4765                	li	a4,25
    80002fae:	00f76f63          	bltu	a4,a5,80002fcc <syscall+0x44>
    80002fb2:	00369713          	sll	a4,a3,0x3
    80002fb6:	00006797          	auipc	a5,0x6
    80002fba:	92a78793          	add	a5,a5,-1750 # 800088e0 <syscalls>
    80002fbe:	97ba                	add	a5,a5,a4
    80002fc0:	639c                	ld	a5,0(a5)
    80002fc2:	c789                	beqz	a5,80002fcc <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80002fc4:	9782                	jalr	a5
    80002fc6:	06a93823          	sd	a0,112(s2)
    80002fca:	a839                	j	80002fe8 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    80002fcc:	15848613          	add	a2,s1,344
    80002fd0:	588c                	lw	a1,48(s1)
    80002fd2:	00005517          	auipc	a0,0x5
    80002fd6:	50650513          	add	a0,a0,1286 # 800084d8 <__func__.1+0x4d0>
    80002fda:	ffffd097          	auipc	ra,0xffffd
    80002fde:	5e2080e7          	jalr	1506(ra) # 800005bc <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80002fe2:	6cbc                	ld	a5,88(s1)
    80002fe4:	577d                	li	a4,-1
    80002fe6:	fbb8                	sd	a4,112(a5)
    }
}
    80002fe8:	60e2                	ld	ra,24(sp)
    80002fea:	6442                	ld	s0,16(sp)
    80002fec:	64a2                	ld	s1,8(sp)
    80002fee:	6902                	ld	s2,0(sp)
    80002ff0:	6105                	add	sp,sp,32
    80002ff2:	8082                	ret

0000000080002ff4 <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    80002ff4:	1101                	add	sp,sp,-32
    80002ff6:	ec06                	sd	ra,24(sp)
    80002ff8:	e822                	sd	s0,16(sp)
    80002ffa:	1000                	add	s0,sp,32
    int n;
    argint(0, &n);
    80002ffc:	fec40593          	add	a1,s0,-20
    80003000:	4501                	li	a0,0
    80003002:	00000097          	auipc	ra,0x0
    80003006:	f0e080e7          	jalr	-242(ra) # 80002f10 <argint>
    exit(n);
    8000300a:	fec42503          	lw	a0,-20(s0)
    8000300e:	fffff097          	auipc	ra,0xfffff
    80003012:	4de080e7          	jalr	1246(ra) # 800024ec <exit>
    return 0; // not reached
}
    80003016:	4501                	li	a0,0
    80003018:	60e2                	ld	ra,24(sp)
    8000301a:	6442                	ld	s0,16(sp)
    8000301c:	6105                	add	sp,sp,32
    8000301e:	8082                	ret

0000000080003020 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003020:	1141                	add	sp,sp,-16
    80003022:	e406                	sd	ra,8(sp)
    80003024:	e022                	sd	s0,0(sp)
    80003026:	0800                	add	s0,sp,16
    return myproc()->pid;
    80003028:	fffff097          	auipc	ra,0xfffff
    8000302c:	bde080e7          	jalr	-1058(ra) # 80001c06 <myproc>
}
    80003030:	5908                	lw	a0,48(a0)
    80003032:	60a2                	ld	ra,8(sp)
    80003034:	6402                	ld	s0,0(sp)
    80003036:	0141                	add	sp,sp,16
    80003038:	8082                	ret

000000008000303a <sys_fork>:

uint64
sys_fork(void)
{
    8000303a:	1141                	add	sp,sp,-16
    8000303c:	e406                	sd	ra,8(sp)
    8000303e:	e022                	sd	s0,0(sp)
    80003040:	0800                	add	s0,sp,16
    return fork();
    80003042:	fffff097          	auipc	ra,0xfffff
    80003046:	112080e7          	jalr	274(ra) # 80002154 <fork>
}
    8000304a:	60a2                	ld	ra,8(sp)
    8000304c:	6402                	ld	s0,0(sp)
    8000304e:	0141                	add	sp,sp,16
    80003050:	8082                	ret

0000000080003052 <sys_wait>:

uint64
sys_wait(void)
{
    80003052:	1101                	add	sp,sp,-32
    80003054:	ec06                	sd	ra,24(sp)
    80003056:	e822                	sd	s0,16(sp)
    80003058:	1000                	add	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    8000305a:	fe840593          	add	a1,s0,-24
    8000305e:	4501                	li	a0,0
    80003060:	00000097          	auipc	ra,0x0
    80003064:	ed0080e7          	jalr	-304(ra) # 80002f30 <argaddr>
    return wait(p);
    80003068:	fe843503          	ld	a0,-24(s0)
    8000306c:	fffff097          	auipc	ra,0xfffff
    80003070:	626080e7          	jalr	1574(ra) # 80002692 <wait>
}
    80003074:	60e2                	ld	ra,24(sp)
    80003076:	6442                	ld	s0,16(sp)
    80003078:	6105                	add	sp,sp,32
    8000307a:	8082                	ret

000000008000307c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000307c:	7179                	add	sp,sp,-48
    8000307e:	f406                	sd	ra,40(sp)
    80003080:	f022                	sd	s0,32(sp)
    80003082:	ec26                	sd	s1,24(sp)
    80003084:	1800                	add	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    80003086:	fdc40593          	add	a1,s0,-36
    8000308a:	4501                	li	a0,0
    8000308c:	00000097          	auipc	ra,0x0
    80003090:	e84080e7          	jalr	-380(ra) # 80002f10 <argint>
    addr = myproc()->sz;
    80003094:	fffff097          	auipc	ra,0xfffff
    80003098:	b72080e7          	jalr	-1166(ra) # 80001c06 <myproc>
    8000309c:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    8000309e:	fdc42503          	lw	a0,-36(s0)
    800030a2:	fffff097          	auipc	ra,0xfffff
    800030a6:	ebe080e7          	jalr	-322(ra) # 80001f60 <growproc>
    800030aa:	00054863          	bltz	a0,800030ba <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    800030ae:	8526                	mv	a0,s1
    800030b0:	70a2                	ld	ra,40(sp)
    800030b2:	7402                	ld	s0,32(sp)
    800030b4:	64e2                	ld	s1,24(sp)
    800030b6:	6145                	add	sp,sp,48
    800030b8:	8082                	ret
        return -1;
    800030ba:	54fd                	li	s1,-1
    800030bc:	bfcd                	j	800030ae <sys_sbrk+0x32>

00000000800030be <sys_sleep>:

uint64
sys_sleep(void)
{
    800030be:	7139                	add	sp,sp,-64
    800030c0:	fc06                	sd	ra,56(sp)
    800030c2:	f822                	sd	s0,48(sp)
    800030c4:	f04a                	sd	s2,32(sp)
    800030c6:	0080                	add	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    800030c8:	fcc40593          	add	a1,s0,-52
    800030cc:	4501                	li	a0,0
    800030ce:	00000097          	auipc	ra,0x0
    800030d2:	e42080e7          	jalr	-446(ra) # 80002f10 <argint>
    acquire(&tickslock);
    800030d6:	00014517          	auipc	a0,0x14
    800030da:	a5a50513          	add	a0,a0,-1446 # 80016b30 <tickslock>
    800030de:	ffffe097          	auipc	ra,0xffffe
    800030e2:	c22080e7          	jalr	-990(ra) # 80000d00 <acquire>
    ticks0 = ticks;
    800030e6:	00006917          	auipc	s2,0x6
    800030ea:	9aa92903          	lw	s2,-1622(s2) # 80008a90 <ticks>
    while (ticks - ticks0 < n)
    800030ee:	fcc42783          	lw	a5,-52(s0)
    800030f2:	c3b9                	beqz	a5,80003138 <sys_sleep+0x7a>
    800030f4:	f426                	sd	s1,40(sp)
    800030f6:	ec4e                	sd	s3,24(sp)
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    800030f8:	00014997          	auipc	s3,0x14
    800030fc:	a3898993          	add	s3,s3,-1480 # 80016b30 <tickslock>
    80003100:	00006497          	auipc	s1,0x6
    80003104:	99048493          	add	s1,s1,-1648 # 80008a90 <ticks>
        if (killed(myproc()))
    80003108:	fffff097          	auipc	ra,0xfffff
    8000310c:	afe080e7          	jalr	-1282(ra) # 80001c06 <myproc>
    80003110:	fffff097          	auipc	ra,0xfffff
    80003114:	550080e7          	jalr	1360(ra) # 80002660 <killed>
    80003118:	ed15                	bnez	a0,80003154 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    8000311a:	85ce                	mv	a1,s3
    8000311c:	8526                	mv	a0,s1
    8000311e:	fffff097          	auipc	ra,0xfffff
    80003122:	29a080e7          	jalr	666(ra) # 800023b8 <sleep>
    while (ticks - ticks0 < n)
    80003126:	409c                	lw	a5,0(s1)
    80003128:	412787bb          	subw	a5,a5,s2
    8000312c:	fcc42703          	lw	a4,-52(s0)
    80003130:	fce7ece3          	bltu	a5,a4,80003108 <sys_sleep+0x4a>
    80003134:	74a2                	ld	s1,40(sp)
    80003136:	69e2                	ld	s3,24(sp)
    }
    release(&tickslock);
    80003138:	00014517          	auipc	a0,0x14
    8000313c:	9f850513          	add	a0,a0,-1544 # 80016b30 <tickslock>
    80003140:	ffffe097          	auipc	ra,0xffffe
    80003144:	c74080e7          	jalr	-908(ra) # 80000db4 <release>
    return 0;
    80003148:	4501                	li	a0,0
}
    8000314a:	70e2                	ld	ra,56(sp)
    8000314c:	7442                	ld	s0,48(sp)
    8000314e:	7902                	ld	s2,32(sp)
    80003150:	6121                	add	sp,sp,64
    80003152:	8082                	ret
            release(&tickslock);
    80003154:	00014517          	auipc	a0,0x14
    80003158:	9dc50513          	add	a0,a0,-1572 # 80016b30 <tickslock>
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	c58080e7          	jalr	-936(ra) # 80000db4 <release>
            return -1;
    80003164:	557d                	li	a0,-1
    80003166:	74a2                	ld	s1,40(sp)
    80003168:	69e2                	ld	s3,24(sp)
    8000316a:	b7c5                	j	8000314a <sys_sleep+0x8c>

000000008000316c <sys_kill>:

uint64
sys_kill(void)
{
    8000316c:	1101                	add	sp,sp,-32
    8000316e:	ec06                	sd	ra,24(sp)
    80003170:	e822                	sd	s0,16(sp)
    80003172:	1000                	add	s0,sp,32
    int pid;

    argint(0, &pid);
    80003174:	fec40593          	add	a1,s0,-20
    80003178:	4501                	li	a0,0
    8000317a:	00000097          	auipc	ra,0x0
    8000317e:	d96080e7          	jalr	-618(ra) # 80002f10 <argint>
    return kill(pid);
    80003182:	fec42503          	lw	a0,-20(s0)
    80003186:	fffff097          	auipc	ra,0xfffff
    8000318a:	43c080e7          	jalr	1084(ra) # 800025c2 <kill>
}
    8000318e:	60e2                	ld	ra,24(sp)
    80003190:	6442                	ld	s0,16(sp)
    80003192:	6105                	add	sp,sp,32
    80003194:	8082                	ret

0000000080003196 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003196:	1101                	add	sp,sp,-32
    80003198:	ec06                	sd	ra,24(sp)
    8000319a:	e822                	sd	s0,16(sp)
    8000319c:	e426                	sd	s1,8(sp)
    8000319e:	1000                	add	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    800031a0:	00014517          	auipc	a0,0x14
    800031a4:	99050513          	add	a0,a0,-1648 # 80016b30 <tickslock>
    800031a8:	ffffe097          	auipc	ra,0xffffe
    800031ac:	b58080e7          	jalr	-1192(ra) # 80000d00 <acquire>
    xticks = ticks;
    800031b0:	00006497          	auipc	s1,0x6
    800031b4:	8e04a483          	lw	s1,-1824(s1) # 80008a90 <ticks>
    release(&tickslock);
    800031b8:	00014517          	auipc	a0,0x14
    800031bc:	97850513          	add	a0,a0,-1672 # 80016b30 <tickslock>
    800031c0:	ffffe097          	auipc	ra,0xffffe
    800031c4:	bf4080e7          	jalr	-1036(ra) # 80000db4 <release>
    return xticks;
}
    800031c8:	02049513          	sll	a0,s1,0x20
    800031cc:	9101                	srl	a0,a0,0x20
    800031ce:	60e2                	ld	ra,24(sp)
    800031d0:	6442                	ld	s0,16(sp)
    800031d2:	64a2                	ld	s1,8(sp)
    800031d4:	6105                	add	sp,sp,32
    800031d6:	8082                	ret

00000000800031d8 <sys_ps>:

void *
sys_ps(void)
{
    800031d8:	1101                	add	sp,sp,-32
    800031da:	ec06                	sd	ra,24(sp)
    800031dc:	e822                	sd	s0,16(sp)
    800031de:	1000                	add	s0,sp,32
    int start = 0, count = 0;
    800031e0:	fe042623          	sw	zero,-20(s0)
    800031e4:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    800031e8:	fec40593          	add	a1,s0,-20
    800031ec:	4501                	li	a0,0
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	d22080e7          	jalr	-734(ra) # 80002f10 <argint>
    argint(1, &count);
    800031f6:	fe840593          	add	a1,s0,-24
    800031fa:	4505                	li	a0,1
    800031fc:	00000097          	auipc	ra,0x0
    80003200:	d14080e7          	jalr	-748(ra) # 80002f10 <argint>
    return ps((uint8)start, (uint8)count);
    80003204:	fe844583          	lbu	a1,-24(s0)
    80003208:	fec44503          	lbu	a0,-20(s0)
    8000320c:	fffff097          	auipc	ra,0xfffff
    80003210:	db0080e7          	jalr	-592(ra) # 80001fbc <ps>
}
    80003214:	60e2                	ld	ra,24(sp)
    80003216:	6442                	ld	s0,16(sp)
    80003218:	6105                	add	sp,sp,32
    8000321a:	8082                	ret

000000008000321c <sys_schedls>:

uint64 sys_schedls(void)
{
    8000321c:	1141                	add	sp,sp,-16
    8000321e:	e406                	sd	ra,8(sp)
    80003220:	e022                	sd	s0,0(sp)
    80003222:	0800                	add	s0,sp,16
    schedls();
    80003224:	fffff097          	auipc	ra,0xfffff
    80003228:	6f8080e7          	jalr	1784(ra) # 8000291c <schedls>
    return 0;
}
    8000322c:	4501                	li	a0,0
    8000322e:	60a2                	ld	ra,8(sp)
    80003230:	6402                	ld	s0,0(sp)
    80003232:	0141                	add	sp,sp,16
    80003234:	8082                	ret

0000000080003236 <sys_schedset>:

uint64 sys_schedset(void)
{
    80003236:	1101                	add	sp,sp,-32
    80003238:	ec06                	sd	ra,24(sp)
    8000323a:	e822                	sd	s0,16(sp)
    8000323c:	1000                	add	s0,sp,32
    int id = 0;
    8000323e:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    80003242:	fec40593          	add	a1,s0,-20
    80003246:	4501                	li	a0,0
    80003248:	00000097          	auipc	ra,0x0
    8000324c:	cc8080e7          	jalr	-824(ra) # 80002f10 <argint>
    schedset(id - 1);
    80003250:	fec42503          	lw	a0,-20(s0)
    80003254:	357d                	addw	a0,a0,-1
    80003256:	fffff097          	auipc	ra,0xfffff
    8000325a:	75c080e7          	jalr	1884(ra) # 800029b2 <schedset>
    return 0;
}
    8000325e:	4501                	li	a0,0
    80003260:	60e2                	ld	ra,24(sp)
    80003262:	6442                	ld	s0,16(sp)
    80003264:	6105                	add	sp,sp,32
    80003266:	8082                	ret

0000000080003268 <sys_va2pa>:

uint64 sys_va2pa(void)
{
    80003268:	1141                	add	sp,sp,-16
    8000326a:	e406                	sd	ra,8(sp)
    8000326c:	e022                	sd	s0,0(sp)
    8000326e:	0800                	add	s0,sp,16
    printf("TODO: IMPLEMENT ME [%s@%s (line %d)]", __func__, __FILE__, __LINE__);
    80003270:	07a00693          	li	a3,122
    80003274:	00005617          	auipc	a2,0x5
    80003278:	28460613          	add	a2,a2,644 # 800084f8 <__func__.1+0x4f0>
    8000327c:	00005597          	auipc	a1,0x5
    80003280:	73c58593          	add	a1,a1,1852 # 800089b8 <__func__.0>
    80003284:	00005517          	auipc	a0,0x5
    80003288:	28c50513          	add	a0,a0,652 # 80008510 <__func__.1+0x508>
    8000328c:	ffffd097          	auipc	ra,0xffffd
    80003290:	330080e7          	jalr	816(ra) # 800005bc <printf>
    return 0;
}
    80003294:	4501                	li	a0,0
    80003296:	60a2                	ld	ra,8(sp)
    80003298:	6402                	ld	s0,0(sp)
    8000329a:	0141                	add	sp,sp,16
    8000329c:	8082                	ret

000000008000329e <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    8000329e:	1141                	add	sp,sp,-16
    800032a0:	e406                	sd	ra,8(sp)
    800032a2:	e022                	sd	s0,0(sp)
    800032a4:	0800                	add	s0,sp,16
    printf("%d\n", FREE_PAGES);
    800032a6:	00005597          	auipc	a1,0x5
    800032aa:	7c25b583          	ld	a1,1986(a1) # 80008a68 <FREE_PAGES>
    800032ae:	00005517          	auipc	a0,0x5
    800032b2:	28a50513          	add	a0,a0,650 # 80008538 <__func__.1+0x530>
    800032b6:	ffffd097          	auipc	ra,0xffffd
    800032ba:	306080e7          	jalr	774(ra) # 800005bc <printf>
    return 0;
    800032be:	4501                	li	a0,0
    800032c0:	60a2                	ld	ra,8(sp)
    800032c2:	6402                	ld	s0,0(sp)
    800032c4:	0141                	add	sp,sp,16
    800032c6:	8082                	ret

00000000800032c8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800032c8:	7179                	add	sp,sp,-48
    800032ca:	f406                	sd	ra,40(sp)
    800032cc:	f022                	sd	s0,32(sp)
    800032ce:	ec26                	sd	s1,24(sp)
    800032d0:	e84a                	sd	s2,16(sp)
    800032d2:	e44e                	sd	s3,8(sp)
    800032d4:	e052                	sd	s4,0(sp)
    800032d6:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800032d8:	00005597          	auipc	a1,0x5
    800032dc:	26858593          	add	a1,a1,616 # 80008540 <__func__.1+0x538>
    800032e0:	00014517          	auipc	a0,0x14
    800032e4:	86850513          	add	a0,a0,-1944 # 80016b48 <bcache>
    800032e8:	ffffe097          	auipc	ra,0xffffe
    800032ec:	988080e7          	jalr	-1656(ra) # 80000c70 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800032f0:	0001c797          	auipc	a5,0x1c
    800032f4:	85878793          	add	a5,a5,-1960 # 8001eb48 <bcache+0x8000>
    800032f8:	0001c717          	auipc	a4,0x1c
    800032fc:	ab870713          	add	a4,a4,-1352 # 8001edb0 <bcache+0x8268>
    80003300:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003304:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003308:	00014497          	auipc	s1,0x14
    8000330c:	85848493          	add	s1,s1,-1960 # 80016b60 <bcache+0x18>
    b->next = bcache.head.next;
    80003310:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003312:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003314:	00005a17          	auipc	s4,0x5
    80003318:	234a0a13          	add	s4,s4,564 # 80008548 <__func__.1+0x540>
    b->next = bcache.head.next;
    8000331c:	2b893783          	ld	a5,696(s2)
    80003320:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003322:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003326:	85d2                	mv	a1,s4
    80003328:	01048513          	add	a0,s1,16
    8000332c:	00001097          	auipc	ra,0x1
    80003330:	4e8080e7          	jalr	1256(ra) # 80004814 <initsleeplock>
    bcache.head.next->prev = b;
    80003334:	2b893783          	ld	a5,696(s2)
    80003338:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000333a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000333e:	45848493          	add	s1,s1,1112
    80003342:	fd349de3          	bne	s1,s3,8000331c <binit+0x54>
  }
}
    80003346:	70a2                	ld	ra,40(sp)
    80003348:	7402                	ld	s0,32(sp)
    8000334a:	64e2                	ld	s1,24(sp)
    8000334c:	6942                	ld	s2,16(sp)
    8000334e:	69a2                	ld	s3,8(sp)
    80003350:	6a02                	ld	s4,0(sp)
    80003352:	6145                	add	sp,sp,48
    80003354:	8082                	ret

0000000080003356 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003356:	7179                	add	sp,sp,-48
    80003358:	f406                	sd	ra,40(sp)
    8000335a:	f022                	sd	s0,32(sp)
    8000335c:	ec26                	sd	s1,24(sp)
    8000335e:	e84a                	sd	s2,16(sp)
    80003360:	e44e                	sd	s3,8(sp)
    80003362:	1800                	add	s0,sp,48
    80003364:	892a                	mv	s2,a0
    80003366:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003368:	00013517          	auipc	a0,0x13
    8000336c:	7e050513          	add	a0,a0,2016 # 80016b48 <bcache>
    80003370:	ffffe097          	auipc	ra,0xffffe
    80003374:	990080e7          	jalr	-1648(ra) # 80000d00 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003378:	0001c497          	auipc	s1,0x1c
    8000337c:	a884b483          	ld	s1,-1400(s1) # 8001ee00 <bcache+0x82b8>
    80003380:	0001c797          	auipc	a5,0x1c
    80003384:	a3078793          	add	a5,a5,-1488 # 8001edb0 <bcache+0x8268>
    80003388:	02f48f63          	beq	s1,a5,800033c6 <bread+0x70>
    8000338c:	873e                	mv	a4,a5
    8000338e:	a021                	j	80003396 <bread+0x40>
    80003390:	68a4                	ld	s1,80(s1)
    80003392:	02e48a63          	beq	s1,a4,800033c6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003396:	449c                	lw	a5,8(s1)
    80003398:	ff279ce3          	bne	a5,s2,80003390 <bread+0x3a>
    8000339c:	44dc                	lw	a5,12(s1)
    8000339e:	ff3799e3          	bne	a5,s3,80003390 <bread+0x3a>
      b->refcnt++;
    800033a2:	40bc                	lw	a5,64(s1)
    800033a4:	2785                	addw	a5,a5,1
    800033a6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033a8:	00013517          	auipc	a0,0x13
    800033ac:	7a050513          	add	a0,a0,1952 # 80016b48 <bcache>
    800033b0:	ffffe097          	auipc	ra,0xffffe
    800033b4:	a04080e7          	jalr	-1532(ra) # 80000db4 <release>
      acquiresleep(&b->lock);
    800033b8:	01048513          	add	a0,s1,16
    800033bc:	00001097          	auipc	ra,0x1
    800033c0:	492080e7          	jalr	1170(ra) # 8000484e <acquiresleep>
      return b;
    800033c4:	a8b9                	j	80003422 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033c6:	0001c497          	auipc	s1,0x1c
    800033ca:	a324b483          	ld	s1,-1486(s1) # 8001edf8 <bcache+0x82b0>
    800033ce:	0001c797          	auipc	a5,0x1c
    800033d2:	9e278793          	add	a5,a5,-1566 # 8001edb0 <bcache+0x8268>
    800033d6:	00f48863          	beq	s1,a5,800033e6 <bread+0x90>
    800033da:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800033dc:	40bc                	lw	a5,64(s1)
    800033de:	cf81                	beqz	a5,800033f6 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033e0:	64a4                	ld	s1,72(s1)
    800033e2:	fee49de3          	bne	s1,a4,800033dc <bread+0x86>
  panic("bget: no buffers");
    800033e6:	00005517          	auipc	a0,0x5
    800033ea:	16a50513          	add	a0,a0,362 # 80008550 <__func__.1+0x548>
    800033ee:	ffffd097          	auipc	ra,0xffffd
    800033f2:	172080e7          	jalr	370(ra) # 80000560 <panic>
      b->dev = dev;
    800033f6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800033fa:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800033fe:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003402:	4785                	li	a5,1
    80003404:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003406:	00013517          	auipc	a0,0x13
    8000340a:	74250513          	add	a0,a0,1858 # 80016b48 <bcache>
    8000340e:	ffffe097          	auipc	ra,0xffffe
    80003412:	9a6080e7          	jalr	-1626(ra) # 80000db4 <release>
      acquiresleep(&b->lock);
    80003416:	01048513          	add	a0,s1,16
    8000341a:	00001097          	auipc	ra,0x1
    8000341e:	434080e7          	jalr	1076(ra) # 8000484e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003422:	409c                	lw	a5,0(s1)
    80003424:	cb89                	beqz	a5,80003436 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003426:	8526                	mv	a0,s1
    80003428:	70a2                	ld	ra,40(sp)
    8000342a:	7402                	ld	s0,32(sp)
    8000342c:	64e2                	ld	s1,24(sp)
    8000342e:	6942                	ld	s2,16(sp)
    80003430:	69a2                	ld	s3,8(sp)
    80003432:	6145                	add	sp,sp,48
    80003434:	8082                	ret
    virtio_disk_rw(b, 0);
    80003436:	4581                	li	a1,0
    80003438:	8526                	mv	a0,s1
    8000343a:	00003097          	auipc	ra,0x3
    8000343e:	0ee080e7          	jalr	238(ra) # 80006528 <virtio_disk_rw>
    b->valid = 1;
    80003442:	4785                	li	a5,1
    80003444:	c09c                	sw	a5,0(s1)
  return b;
    80003446:	b7c5                	j	80003426 <bread+0xd0>

0000000080003448 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003448:	1101                	add	sp,sp,-32
    8000344a:	ec06                	sd	ra,24(sp)
    8000344c:	e822                	sd	s0,16(sp)
    8000344e:	e426                	sd	s1,8(sp)
    80003450:	1000                	add	s0,sp,32
    80003452:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003454:	0541                	add	a0,a0,16
    80003456:	00001097          	auipc	ra,0x1
    8000345a:	492080e7          	jalr	1170(ra) # 800048e8 <holdingsleep>
    8000345e:	cd01                	beqz	a0,80003476 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003460:	4585                	li	a1,1
    80003462:	8526                	mv	a0,s1
    80003464:	00003097          	auipc	ra,0x3
    80003468:	0c4080e7          	jalr	196(ra) # 80006528 <virtio_disk_rw>
}
    8000346c:	60e2                	ld	ra,24(sp)
    8000346e:	6442                	ld	s0,16(sp)
    80003470:	64a2                	ld	s1,8(sp)
    80003472:	6105                	add	sp,sp,32
    80003474:	8082                	ret
    panic("bwrite");
    80003476:	00005517          	auipc	a0,0x5
    8000347a:	0f250513          	add	a0,a0,242 # 80008568 <__func__.1+0x560>
    8000347e:	ffffd097          	auipc	ra,0xffffd
    80003482:	0e2080e7          	jalr	226(ra) # 80000560 <panic>

0000000080003486 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003486:	1101                	add	sp,sp,-32
    80003488:	ec06                	sd	ra,24(sp)
    8000348a:	e822                	sd	s0,16(sp)
    8000348c:	e426                	sd	s1,8(sp)
    8000348e:	e04a                	sd	s2,0(sp)
    80003490:	1000                	add	s0,sp,32
    80003492:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003494:	01050913          	add	s2,a0,16
    80003498:	854a                	mv	a0,s2
    8000349a:	00001097          	auipc	ra,0x1
    8000349e:	44e080e7          	jalr	1102(ra) # 800048e8 <holdingsleep>
    800034a2:	c925                	beqz	a0,80003512 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800034a4:	854a                	mv	a0,s2
    800034a6:	00001097          	auipc	ra,0x1
    800034aa:	3fe080e7          	jalr	1022(ra) # 800048a4 <releasesleep>

  acquire(&bcache.lock);
    800034ae:	00013517          	auipc	a0,0x13
    800034b2:	69a50513          	add	a0,a0,1690 # 80016b48 <bcache>
    800034b6:	ffffe097          	auipc	ra,0xffffe
    800034ba:	84a080e7          	jalr	-1974(ra) # 80000d00 <acquire>
  b->refcnt--;
    800034be:	40bc                	lw	a5,64(s1)
    800034c0:	37fd                	addw	a5,a5,-1
    800034c2:	0007871b          	sext.w	a4,a5
    800034c6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800034c8:	e71d                	bnez	a4,800034f6 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800034ca:	68b8                	ld	a4,80(s1)
    800034cc:	64bc                	ld	a5,72(s1)
    800034ce:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800034d0:	68b8                	ld	a4,80(s1)
    800034d2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800034d4:	0001b797          	auipc	a5,0x1b
    800034d8:	67478793          	add	a5,a5,1652 # 8001eb48 <bcache+0x8000>
    800034dc:	2b87b703          	ld	a4,696(a5)
    800034e0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800034e2:	0001c717          	auipc	a4,0x1c
    800034e6:	8ce70713          	add	a4,a4,-1842 # 8001edb0 <bcache+0x8268>
    800034ea:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800034ec:	2b87b703          	ld	a4,696(a5)
    800034f0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800034f2:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800034f6:	00013517          	auipc	a0,0x13
    800034fa:	65250513          	add	a0,a0,1618 # 80016b48 <bcache>
    800034fe:	ffffe097          	auipc	ra,0xffffe
    80003502:	8b6080e7          	jalr	-1866(ra) # 80000db4 <release>
}
    80003506:	60e2                	ld	ra,24(sp)
    80003508:	6442                	ld	s0,16(sp)
    8000350a:	64a2                	ld	s1,8(sp)
    8000350c:	6902                	ld	s2,0(sp)
    8000350e:	6105                	add	sp,sp,32
    80003510:	8082                	ret
    panic("brelse");
    80003512:	00005517          	auipc	a0,0x5
    80003516:	05e50513          	add	a0,a0,94 # 80008570 <__func__.1+0x568>
    8000351a:	ffffd097          	auipc	ra,0xffffd
    8000351e:	046080e7          	jalr	70(ra) # 80000560 <panic>

0000000080003522 <bpin>:

void
bpin(struct buf *b) {
    80003522:	1101                	add	sp,sp,-32
    80003524:	ec06                	sd	ra,24(sp)
    80003526:	e822                	sd	s0,16(sp)
    80003528:	e426                	sd	s1,8(sp)
    8000352a:	1000                	add	s0,sp,32
    8000352c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000352e:	00013517          	auipc	a0,0x13
    80003532:	61a50513          	add	a0,a0,1562 # 80016b48 <bcache>
    80003536:	ffffd097          	auipc	ra,0xffffd
    8000353a:	7ca080e7          	jalr	1994(ra) # 80000d00 <acquire>
  b->refcnt++;
    8000353e:	40bc                	lw	a5,64(s1)
    80003540:	2785                	addw	a5,a5,1
    80003542:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003544:	00013517          	auipc	a0,0x13
    80003548:	60450513          	add	a0,a0,1540 # 80016b48 <bcache>
    8000354c:	ffffe097          	auipc	ra,0xffffe
    80003550:	868080e7          	jalr	-1944(ra) # 80000db4 <release>
}
    80003554:	60e2                	ld	ra,24(sp)
    80003556:	6442                	ld	s0,16(sp)
    80003558:	64a2                	ld	s1,8(sp)
    8000355a:	6105                	add	sp,sp,32
    8000355c:	8082                	ret

000000008000355e <bunpin>:

void
bunpin(struct buf *b) {
    8000355e:	1101                	add	sp,sp,-32
    80003560:	ec06                	sd	ra,24(sp)
    80003562:	e822                	sd	s0,16(sp)
    80003564:	e426                	sd	s1,8(sp)
    80003566:	1000                	add	s0,sp,32
    80003568:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000356a:	00013517          	auipc	a0,0x13
    8000356e:	5de50513          	add	a0,a0,1502 # 80016b48 <bcache>
    80003572:	ffffd097          	auipc	ra,0xffffd
    80003576:	78e080e7          	jalr	1934(ra) # 80000d00 <acquire>
  b->refcnt--;
    8000357a:	40bc                	lw	a5,64(s1)
    8000357c:	37fd                	addw	a5,a5,-1
    8000357e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003580:	00013517          	auipc	a0,0x13
    80003584:	5c850513          	add	a0,a0,1480 # 80016b48 <bcache>
    80003588:	ffffe097          	auipc	ra,0xffffe
    8000358c:	82c080e7          	jalr	-2004(ra) # 80000db4 <release>
}
    80003590:	60e2                	ld	ra,24(sp)
    80003592:	6442                	ld	s0,16(sp)
    80003594:	64a2                	ld	s1,8(sp)
    80003596:	6105                	add	sp,sp,32
    80003598:	8082                	ret

000000008000359a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000359a:	1101                	add	sp,sp,-32
    8000359c:	ec06                	sd	ra,24(sp)
    8000359e:	e822                	sd	s0,16(sp)
    800035a0:	e426                	sd	s1,8(sp)
    800035a2:	e04a                	sd	s2,0(sp)
    800035a4:	1000                	add	s0,sp,32
    800035a6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800035a8:	00d5d59b          	srlw	a1,a1,0xd
    800035ac:	0001c797          	auipc	a5,0x1c
    800035b0:	c787a783          	lw	a5,-904(a5) # 8001f224 <sb+0x1c>
    800035b4:	9dbd                	addw	a1,a1,a5
    800035b6:	00000097          	auipc	ra,0x0
    800035ba:	da0080e7          	jalr	-608(ra) # 80003356 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800035be:	0074f713          	and	a4,s1,7
    800035c2:	4785                	li	a5,1
    800035c4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800035c8:	14ce                	sll	s1,s1,0x33
    800035ca:	90d9                	srl	s1,s1,0x36
    800035cc:	00950733          	add	a4,a0,s1
    800035d0:	05874703          	lbu	a4,88(a4)
    800035d4:	00e7f6b3          	and	a3,a5,a4
    800035d8:	c69d                	beqz	a3,80003606 <bfree+0x6c>
    800035da:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800035dc:	94aa                	add	s1,s1,a0
    800035de:	fff7c793          	not	a5,a5
    800035e2:	8f7d                	and	a4,a4,a5
    800035e4:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800035e8:	00001097          	auipc	ra,0x1
    800035ec:	148080e7          	jalr	328(ra) # 80004730 <log_write>
  brelse(bp);
    800035f0:	854a                	mv	a0,s2
    800035f2:	00000097          	auipc	ra,0x0
    800035f6:	e94080e7          	jalr	-364(ra) # 80003486 <brelse>
}
    800035fa:	60e2                	ld	ra,24(sp)
    800035fc:	6442                	ld	s0,16(sp)
    800035fe:	64a2                	ld	s1,8(sp)
    80003600:	6902                	ld	s2,0(sp)
    80003602:	6105                	add	sp,sp,32
    80003604:	8082                	ret
    panic("freeing free block");
    80003606:	00005517          	auipc	a0,0x5
    8000360a:	f7250513          	add	a0,a0,-142 # 80008578 <__func__.1+0x570>
    8000360e:	ffffd097          	auipc	ra,0xffffd
    80003612:	f52080e7          	jalr	-174(ra) # 80000560 <panic>

0000000080003616 <balloc>:
{
    80003616:	711d                	add	sp,sp,-96
    80003618:	ec86                	sd	ra,88(sp)
    8000361a:	e8a2                	sd	s0,80(sp)
    8000361c:	e4a6                	sd	s1,72(sp)
    8000361e:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003620:	0001c797          	auipc	a5,0x1c
    80003624:	bec7a783          	lw	a5,-1044(a5) # 8001f20c <sb+0x4>
    80003628:	10078f63          	beqz	a5,80003746 <balloc+0x130>
    8000362c:	e0ca                	sd	s2,64(sp)
    8000362e:	fc4e                	sd	s3,56(sp)
    80003630:	f852                	sd	s4,48(sp)
    80003632:	f456                	sd	s5,40(sp)
    80003634:	f05a                	sd	s6,32(sp)
    80003636:	ec5e                	sd	s7,24(sp)
    80003638:	e862                	sd	s8,16(sp)
    8000363a:	e466                	sd	s9,8(sp)
    8000363c:	8baa                	mv	s7,a0
    8000363e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003640:	0001cb17          	auipc	s6,0x1c
    80003644:	bc8b0b13          	add	s6,s6,-1080 # 8001f208 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003648:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000364a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000364c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000364e:	6c89                	lui	s9,0x2
    80003650:	a061                	j	800036d8 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003652:	97ca                	add	a5,a5,s2
    80003654:	8e55                	or	a2,a2,a3
    80003656:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000365a:	854a                	mv	a0,s2
    8000365c:	00001097          	auipc	ra,0x1
    80003660:	0d4080e7          	jalr	212(ra) # 80004730 <log_write>
        brelse(bp);
    80003664:	854a                	mv	a0,s2
    80003666:	00000097          	auipc	ra,0x0
    8000366a:	e20080e7          	jalr	-480(ra) # 80003486 <brelse>
  bp = bread(dev, bno);
    8000366e:	85a6                	mv	a1,s1
    80003670:	855e                	mv	a0,s7
    80003672:	00000097          	auipc	ra,0x0
    80003676:	ce4080e7          	jalr	-796(ra) # 80003356 <bread>
    8000367a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000367c:	40000613          	li	a2,1024
    80003680:	4581                	li	a1,0
    80003682:	05850513          	add	a0,a0,88
    80003686:	ffffd097          	auipc	ra,0xffffd
    8000368a:	776080e7          	jalr	1910(ra) # 80000dfc <memset>
  log_write(bp);
    8000368e:	854a                	mv	a0,s2
    80003690:	00001097          	auipc	ra,0x1
    80003694:	0a0080e7          	jalr	160(ra) # 80004730 <log_write>
  brelse(bp);
    80003698:	854a                	mv	a0,s2
    8000369a:	00000097          	auipc	ra,0x0
    8000369e:	dec080e7          	jalr	-532(ra) # 80003486 <brelse>
}
    800036a2:	6906                	ld	s2,64(sp)
    800036a4:	79e2                	ld	s3,56(sp)
    800036a6:	7a42                	ld	s4,48(sp)
    800036a8:	7aa2                	ld	s5,40(sp)
    800036aa:	7b02                	ld	s6,32(sp)
    800036ac:	6be2                	ld	s7,24(sp)
    800036ae:	6c42                	ld	s8,16(sp)
    800036b0:	6ca2                	ld	s9,8(sp)
}
    800036b2:	8526                	mv	a0,s1
    800036b4:	60e6                	ld	ra,88(sp)
    800036b6:	6446                	ld	s0,80(sp)
    800036b8:	64a6                	ld	s1,72(sp)
    800036ba:	6125                	add	sp,sp,96
    800036bc:	8082                	ret
    brelse(bp);
    800036be:	854a                	mv	a0,s2
    800036c0:	00000097          	auipc	ra,0x0
    800036c4:	dc6080e7          	jalr	-570(ra) # 80003486 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800036c8:	015c87bb          	addw	a5,s9,s5
    800036cc:	00078a9b          	sext.w	s5,a5
    800036d0:	004b2703          	lw	a4,4(s6)
    800036d4:	06eaf163          	bgeu	s5,a4,80003736 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    800036d8:	41fad79b          	sraw	a5,s5,0x1f
    800036dc:	0137d79b          	srlw	a5,a5,0x13
    800036e0:	015787bb          	addw	a5,a5,s5
    800036e4:	40d7d79b          	sraw	a5,a5,0xd
    800036e8:	01cb2583          	lw	a1,28(s6)
    800036ec:	9dbd                	addw	a1,a1,a5
    800036ee:	855e                	mv	a0,s7
    800036f0:	00000097          	auipc	ra,0x0
    800036f4:	c66080e7          	jalr	-922(ra) # 80003356 <bread>
    800036f8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036fa:	004b2503          	lw	a0,4(s6)
    800036fe:	000a849b          	sext.w	s1,s5
    80003702:	8762                	mv	a4,s8
    80003704:	faa4fde3          	bgeu	s1,a0,800036be <balloc+0xa8>
      m = 1 << (bi % 8);
    80003708:	00777693          	and	a3,a4,7
    8000370c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003710:	41f7579b          	sraw	a5,a4,0x1f
    80003714:	01d7d79b          	srlw	a5,a5,0x1d
    80003718:	9fb9                	addw	a5,a5,a4
    8000371a:	4037d79b          	sraw	a5,a5,0x3
    8000371e:	00f90633          	add	a2,s2,a5
    80003722:	05864603          	lbu	a2,88(a2)
    80003726:	00c6f5b3          	and	a1,a3,a2
    8000372a:	d585                	beqz	a1,80003652 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000372c:	2705                	addw	a4,a4,1
    8000372e:	2485                	addw	s1,s1,1
    80003730:	fd471ae3          	bne	a4,s4,80003704 <balloc+0xee>
    80003734:	b769                	j	800036be <balloc+0xa8>
    80003736:	6906                	ld	s2,64(sp)
    80003738:	79e2                	ld	s3,56(sp)
    8000373a:	7a42                	ld	s4,48(sp)
    8000373c:	7aa2                	ld	s5,40(sp)
    8000373e:	7b02                	ld	s6,32(sp)
    80003740:	6be2                	ld	s7,24(sp)
    80003742:	6c42                	ld	s8,16(sp)
    80003744:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003746:	00005517          	auipc	a0,0x5
    8000374a:	e4a50513          	add	a0,a0,-438 # 80008590 <__func__.1+0x588>
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	e6e080e7          	jalr	-402(ra) # 800005bc <printf>
  return 0;
    80003756:	4481                	li	s1,0
    80003758:	bfa9                	j	800036b2 <balloc+0x9c>

000000008000375a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000375a:	7179                	add	sp,sp,-48
    8000375c:	f406                	sd	ra,40(sp)
    8000375e:	f022                	sd	s0,32(sp)
    80003760:	ec26                	sd	s1,24(sp)
    80003762:	e84a                	sd	s2,16(sp)
    80003764:	e44e                	sd	s3,8(sp)
    80003766:	1800                	add	s0,sp,48
    80003768:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000376a:	47ad                	li	a5,11
    8000376c:	02b7e863          	bltu	a5,a1,8000379c <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003770:	02059793          	sll	a5,a1,0x20
    80003774:	01e7d593          	srl	a1,a5,0x1e
    80003778:	00b504b3          	add	s1,a0,a1
    8000377c:	0504a903          	lw	s2,80(s1)
    80003780:	08091263          	bnez	s2,80003804 <bmap+0xaa>
      addr = balloc(ip->dev);
    80003784:	4108                	lw	a0,0(a0)
    80003786:	00000097          	auipc	ra,0x0
    8000378a:	e90080e7          	jalr	-368(ra) # 80003616 <balloc>
    8000378e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003792:	06090963          	beqz	s2,80003804 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003796:	0524a823          	sw	s2,80(s1)
    8000379a:	a0ad                	j	80003804 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000379c:	ff45849b          	addw	s1,a1,-12
    800037a0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800037a4:	0ff00793          	li	a5,255
    800037a8:	08e7e863          	bltu	a5,a4,80003838 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800037ac:	08052903          	lw	s2,128(a0)
    800037b0:	00091f63          	bnez	s2,800037ce <bmap+0x74>
      addr = balloc(ip->dev);
    800037b4:	4108                	lw	a0,0(a0)
    800037b6:	00000097          	auipc	ra,0x0
    800037ba:	e60080e7          	jalr	-416(ra) # 80003616 <balloc>
    800037be:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037c2:	04090163          	beqz	s2,80003804 <bmap+0xaa>
    800037c6:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800037c8:	0929a023          	sw	s2,128(s3)
    800037cc:	a011                	j	800037d0 <bmap+0x76>
    800037ce:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800037d0:	85ca                	mv	a1,s2
    800037d2:	0009a503          	lw	a0,0(s3)
    800037d6:	00000097          	auipc	ra,0x0
    800037da:	b80080e7          	jalr	-1152(ra) # 80003356 <bread>
    800037de:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800037e0:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    800037e4:	02049713          	sll	a4,s1,0x20
    800037e8:	01e75593          	srl	a1,a4,0x1e
    800037ec:	00b784b3          	add	s1,a5,a1
    800037f0:	0004a903          	lw	s2,0(s1)
    800037f4:	02090063          	beqz	s2,80003814 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800037f8:	8552                	mv	a0,s4
    800037fa:	00000097          	auipc	ra,0x0
    800037fe:	c8c080e7          	jalr	-884(ra) # 80003486 <brelse>
    return addr;
    80003802:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003804:	854a                	mv	a0,s2
    80003806:	70a2                	ld	ra,40(sp)
    80003808:	7402                	ld	s0,32(sp)
    8000380a:	64e2                	ld	s1,24(sp)
    8000380c:	6942                	ld	s2,16(sp)
    8000380e:	69a2                	ld	s3,8(sp)
    80003810:	6145                	add	sp,sp,48
    80003812:	8082                	ret
      addr = balloc(ip->dev);
    80003814:	0009a503          	lw	a0,0(s3)
    80003818:	00000097          	auipc	ra,0x0
    8000381c:	dfe080e7          	jalr	-514(ra) # 80003616 <balloc>
    80003820:	0005091b          	sext.w	s2,a0
      if(addr){
    80003824:	fc090ae3          	beqz	s2,800037f8 <bmap+0x9e>
        a[bn] = addr;
    80003828:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000382c:	8552                	mv	a0,s4
    8000382e:	00001097          	auipc	ra,0x1
    80003832:	f02080e7          	jalr	-254(ra) # 80004730 <log_write>
    80003836:	b7c9                	j	800037f8 <bmap+0x9e>
    80003838:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000383a:	00005517          	auipc	a0,0x5
    8000383e:	d6e50513          	add	a0,a0,-658 # 800085a8 <__func__.1+0x5a0>
    80003842:	ffffd097          	auipc	ra,0xffffd
    80003846:	d1e080e7          	jalr	-738(ra) # 80000560 <panic>

000000008000384a <iget>:
{
    8000384a:	7179                	add	sp,sp,-48
    8000384c:	f406                	sd	ra,40(sp)
    8000384e:	f022                	sd	s0,32(sp)
    80003850:	ec26                	sd	s1,24(sp)
    80003852:	e84a                	sd	s2,16(sp)
    80003854:	e44e                	sd	s3,8(sp)
    80003856:	e052                	sd	s4,0(sp)
    80003858:	1800                	add	s0,sp,48
    8000385a:	89aa                	mv	s3,a0
    8000385c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000385e:	0001c517          	auipc	a0,0x1c
    80003862:	9ca50513          	add	a0,a0,-1590 # 8001f228 <itable>
    80003866:	ffffd097          	auipc	ra,0xffffd
    8000386a:	49a080e7          	jalr	1178(ra) # 80000d00 <acquire>
  empty = 0;
    8000386e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003870:	0001c497          	auipc	s1,0x1c
    80003874:	9d048493          	add	s1,s1,-1584 # 8001f240 <itable+0x18>
    80003878:	0001d697          	auipc	a3,0x1d
    8000387c:	45868693          	add	a3,a3,1112 # 80020cd0 <log>
    80003880:	a039                	j	8000388e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003882:	02090b63          	beqz	s2,800038b8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003886:	08848493          	add	s1,s1,136
    8000388a:	02d48a63          	beq	s1,a3,800038be <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000388e:	449c                	lw	a5,8(s1)
    80003890:	fef059e3          	blez	a5,80003882 <iget+0x38>
    80003894:	4098                	lw	a4,0(s1)
    80003896:	ff3716e3          	bne	a4,s3,80003882 <iget+0x38>
    8000389a:	40d8                	lw	a4,4(s1)
    8000389c:	ff4713e3          	bne	a4,s4,80003882 <iget+0x38>
      ip->ref++;
    800038a0:	2785                	addw	a5,a5,1
    800038a2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800038a4:	0001c517          	auipc	a0,0x1c
    800038a8:	98450513          	add	a0,a0,-1660 # 8001f228 <itable>
    800038ac:	ffffd097          	auipc	ra,0xffffd
    800038b0:	508080e7          	jalr	1288(ra) # 80000db4 <release>
      return ip;
    800038b4:	8926                	mv	s2,s1
    800038b6:	a03d                	j	800038e4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038b8:	f7f9                	bnez	a5,80003886 <iget+0x3c>
      empty = ip;
    800038ba:	8926                	mv	s2,s1
    800038bc:	b7e9                	j	80003886 <iget+0x3c>
  if(empty == 0)
    800038be:	02090c63          	beqz	s2,800038f6 <iget+0xac>
  ip->dev = dev;
    800038c2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800038c6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800038ca:	4785                	li	a5,1
    800038cc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800038d0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800038d4:	0001c517          	auipc	a0,0x1c
    800038d8:	95450513          	add	a0,a0,-1708 # 8001f228 <itable>
    800038dc:	ffffd097          	auipc	ra,0xffffd
    800038e0:	4d8080e7          	jalr	1240(ra) # 80000db4 <release>
}
    800038e4:	854a                	mv	a0,s2
    800038e6:	70a2                	ld	ra,40(sp)
    800038e8:	7402                	ld	s0,32(sp)
    800038ea:	64e2                	ld	s1,24(sp)
    800038ec:	6942                	ld	s2,16(sp)
    800038ee:	69a2                	ld	s3,8(sp)
    800038f0:	6a02                	ld	s4,0(sp)
    800038f2:	6145                	add	sp,sp,48
    800038f4:	8082                	ret
    panic("iget: no inodes");
    800038f6:	00005517          	auipc	a0,0x5
    800038fa:	cca50513          	add	a0,a0,-822 # 800085c0 <__func__.1+0x5b8>
    800038fe:	ffffd097          	auipc	ra,0xffffd
    80003902:	c62080e7          	jalr	-926(ra) # 80000560 <panic>

0000000080003906 <fsinit>:
fsinit(int dev) {
    80003906:	7179                	add	sp,sp,-48
    80003908:	f406                	sd	ra,40(sp)
    8000390a:	f022                	sd	s0,32(sp)
    8000390c:	ec26                	sd	s1,24(sp)
    8000390e:	e84a                	sd	s2,16(sp)
    80003910:	e44e                	sd	s3,8(sp)
    80003912:	1800                	add	s0,sp,48
    80003914:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003916:	4585                	li	a1,1
    80003918:	00000097          	auipc	ra,0x0
    8000391c:	a3e080e7          	jalr	-1474(ra) # 80003356 <bread>
    80003920:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003922:	0001c997          	auipc	s3,0x1c
    80003926:	8e698993          	add	s3,s3,-1818 # 8001f208 <sb>
    8000392a:	02000613          	li	a2,32
    8000392e:	05850593          	add	a1,a0,88
    80003932:	854e                	mv	a0,s3
    80003934:	ffffd097          	auipc	ra,0xffffd
    80003938:	524080e7          	jalr	1316(ra) # 80000e58 <memmove>
  brelse(bp);
    8000393c:	8526                	mv	a0,s1
    8000393e:	00000097          	auipc	ra,0x0
    80003942:	b48080e7          	jalr	-1208(ra) # 80003486 <brelse>
  if(sb.magic != FSMAGIC)
    80003946:	0009a703          	lw	a4,0(s3)
    8000394a:	102037b7          	lui	a5,0x10203
    8000394e:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003952:	02f71263          	bne	a4,a5,80003976 <fsinit+0x70>
  initlog(dev, &sb);
    80003956:	0001c597          	auipc	a1,0x1c
    8000395a:	8b258593          	add	a1,a1,-1870 # 8001f208 <sb>
    8000395e:	854a                	mv	a0,s2
    80003960:	00001097          	auipc	ra,0x1
    80003964:	b60080e7          	jalr	-1184(ra) # 800044c0 <initlog>
}
    80003968:	70a2                	ld	ra,40(sp)
    8000396a:	7402                	ld	s0,32(sp)
    8000396c:	64e2                	ld	s1,24(sp)
    8000396e:	6942                	ld	s2,16(sp)
    80003970:	69a2                	ld	s3,8(sp)
    80003972:	6145                	add	sp,sp,48
    80003974:	8082                	ret
    panic("invalid file system");
    80003976:	00005517          	auipc	a0,0x5
    8000397a:	c5a50513          	add	a0,a0,-934 # 800085d0 <__func__.1+0x5c8>
    8000397e:	ffffd097          	auipc	ra,0xffffd
    80003982:	be2080e7          	jalr	-1054(ra) # 80000560 <panic>

0000000080003986 <iinit>:
{
    80003986:	7179                	add	sp,sp,-48
    80003988:	f406                	sd	ra,40(sp)
    8000398a:	f022                	sd	s0,32(sp)
    8000398c:	ec26                	sd	s1,24(sp)
    8000398e:	e84a                	sd	s2,16(sp)
    80003990:	e44e                	sd	s3,8(sp)
    80003992:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    80003994:	00005597          	auipc	a1,0x5
    80003998:	c5458593          	add	a1,a1,-940 # 800085e8 <__func__.1+0x5e0>
    8000399c:	0001c517          	auipc	a0,0x1c
    800039a0:	88c50513          	add	a0,a0,-1908 # 8001f228 <itable>
    800039a4:	ffffd097          	auipc	ra,0xffffd
    800039a8:	2cc080e7          	jalr	716(ra) # 80000c70 <initlock>
  for(i = 0; i < NINODE; i++) {
    800039ac:	0001c497          	auipc	s1,0x1c
    800039b0:	8a448493          	add	s1,s1,-1884 # 8001f250 <itable+0x28>
    800039b4:	0001d997          	auipc	s3,0x1d
    800039b8:	32c98993          	add	s3,s3,812 # 80020ce0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800039bc:	00005917          	auipc	s2,0x5
    800039c0:	c3490913          	add	s2,s2,-972 # 800085f0 <__func__.1+0x5e8>
    800039c4:	85ca                	mv	a1,s2
    800039c6:	8526                	mv	a0,s1
    800039c8:	00001097          	auipc	ra,0x1
    800039cc:	e4c080e7          	jalr	-436(ra) # 80004814 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800039d0:	08848493          	add	s1,s1,136
    800039d4:	ff3498e3          	bne	s1,s3,800039c4 <iinit+0x3e>
}
    800039d8:	70a2                	ld	ra,40(sp)
    800039da:	7402                	ld	s0,32(sp)
    800039dc:	64e2                	ld	s1,24(sp)
    800039de:	6942                	ld	s2,16(sp)
    800039e0:	69a2                	ld	s3,8(sp)
    800039e2:	6145                	add	sp,sp,48
    800039e4:	8082                	ret

00000000800039e6 <ialloc>:
{
    800039e6:	7139                	add	sp,sp,-64
    800039e8:	fc06                	sd	ra,56(sp)
    800039ea:	f822                	sd	s0,48(sp)
    800039ec:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800039ee:	0001c717          	auipc	a4,0x1c
    800039f2:	82672703          	lw	a4,-2010(a4) # 8001f214 <sb+0xc>
    800039f6:	4785                	li	a5,1
    800039f8:	06e7f463          	bgeu	a5,a4,80003a60 <ialloc+0x7a>
    800039fc:	f426                	sd	s1,40(sp)
    800039fe:	f04a                	sd	s2,32(sp)
    80003a00:	ec4e                	sd	s3,24(sp)
    80003a02:	e852                	sd	s4,16(sp)
    80003a04:	e456                	sd	s5,8(sp)
    80003a06:	e05a                	sd	s6,0(sp)
    80003a08:	8aaa                	mv	s5,a0
    80003a0a:	8b2e                	mv	s6,a1
    80003a0c:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a0e:	0001ba17          	auipc	s4,0x1b
    80003a12:	7faa0a13          	add	s4,s4,2042 # 8001f208 <sb>
    80003a16:	00495593          	srl	a1,s2,0x4
    80003a1a:	018a2783          	lw	a5,24(s4)
    80003a1e:	9dbd                	addw	a1,a1,a5
    80003a20:	8556                	mv	a0,s5
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	934080e7          	jalr	-1740(ra) # 80003356 <bread>
    80003a2a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a2c:	05850993          	add	s3,a0,88
    80003a30:	00f97793          	and	a5,s2,15
    80003a34:	079a                	sll	a5,a5,0x6
    80003a36:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a38:	00099783          	lh	a5,0(s3)
    80003a3c:	cf9d                	beqz	a5,80003a7a <ialloc+0x94>
    brelse(bp);
    80003a3e:	00000097          	auipc	ra,0x0
    80003a42:	a48080e7          	jalr	-1464(ra) # 80003486 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a46:	0905                	add	s2,s2,1
    80003a48:	00ca2703          	lw	a4,12(s4)
    80003a4c:	0009079b          	sext.w	a5,s2
    80003a50:	fce7e3e3          	bltu	a5,a4,80003a16 <ialloc+0x30>
    80003a54:	74a2                	ld	s1,40(sp)
    80003a56:	7902                	ld	s2,32(sp)
    80003a58:	69e2                	ld	s3,24(sp)
    80003a5a:	6a42                	ld	s4,16(sp)
    80003a5c:	6aa2                	ld	s5,8(sp)
    80003a5e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003a60:	00005517          	auipc	a0,0x5
    80003a64:	b9850513          	add	a0,a0,-1128 # 800085f8 <__func__.1+0x5f0>
    80003a68:	ffffd097          	auipc	ra,0xffffd
    80003a6c:	b54080e7          	jalr	-1196(ra) # 800005bc <printf>
  return 0;
    80003a70:	4501                	li	a0,0
}
    80003a72:	70e2                	ld	ra,56(sp)
    80003a74:	7442                	ld	s0,48(sp)
    80003a76:	6121                	add	sp,sp,64
    80003a78:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a7a:	04000613          	li	a2,64
    80003a7e:	4581                	li	a1,0
    80003a80:	854e                	mv	a0,s3
    80003a82:	ffffd097          	auipc	ra,0xffffd
    80003a86:	37a080e7          	jalr	890(ra) # 80000dfc <memset>
      dip->type = type;
    80003a8a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a8e:	8526                	mv	a0,s1
    80003a90:	00001097          	auipc	ra,0x1
    80003a94:	ca0080e7          	jalr	-864(ra) # 80004730 <log_write>
      brelse(bp);
    80003a98:	8526                	mv	a0,s1
    80003a9a:	00000097          	auipc	ra,0x0
    80003a9e:	9ec080e7          	jalr	-1556(ra) # 80003486 <brelse>
      return iget(dev, inum);
    80003aa2:	0009059b          	sext.w	a1,s2
    80003aa6:	8556                	mv	a0,s5
    80003aa8:	00000097          	auipc	ra,0x0
    80003aac:	da2080e7          	jalr	-606(ra) # 8000384a <iget>
    80003ab0:	74a2                	ld	s1,40(sp)
    80003ab2:	7902                	ld	s2,32(sp)
    80003ab4:	69e2                	ld	s3,24(sp)
    80003ab6:	6a42                	ld	s4,16(sp)
    80003ab8:	6aa2                	ld	s5,8(sp)
    80003aba:	6b02                	ld	s6,0(sp)
    80003abc:	bf5d                	j	80003a72 <ialloc+0x8c>

0000000080003abe <iupdate>:
{
    80003abe:	1101                	add	sp,sp,-32
    80003ac0:	ec06                	sd	ra,24(sp)
    80003ac2:	e822                	sd	s0,16(sp)
    80003ac4:	e426                	sd	s1,8(sp)
    80003ac6:	e04a                	sd	s2,0(sp)
    80003ac8:	1000                	add	s0,sp,32
    80003aca:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003acc:	415c                	lw	a5,4(a0)
    80003ace:	0047d79b          	srlw	a5,a5,0x4
    80003ad2:	0001b597          	auipc	a1,0x1b
    80003ad6:	74e5a583          	lw	a1,1870(a1) # 8001f220 <sb+0x18>
    80003ada:	9dbd                	addw	a1,a1,a5
    80003adc:	4108                	lw	a0,0(a0)
    80003ade:	00000097          	auipc	ra,0x0
    80003ae2:	878080e7          	jalr	-1928(ra) # 80003356 <bread>
    80003ae6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ae8:	05850793          	add	a5,a0,88
    80003aec:	40d8                	lw	a4,4(s1)
    80003aee:	8b3d                	and	a4,a4,15
    80003af0:	071a                	sll	a4,a4,0x6
    80003af2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003af4:	04449703          	lh	a4,68(s1)
    80003af8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003afc:	04649703          	lh	a4,70(s1)
    80003b00:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003b04:	04849703          	lh	a4,72(s1)
    80003b08:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003b0c:	04a49703          	lh	a4,74(s1)
    80003b10:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003b14:	44f8                	lw	a4,76(s1)
    80003b16:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b18:	03400613          	li	a2,52
    80003b1c:	05048593          	add	a1,s1,80
    80003b20:	00c78513          	add	a0,a5,12
    80003b24:	ffffd097          	auipc	ra,0xffffd
    80003b28:	334080e7          	jalr	820(ra) # 80000e58 <memmove>
  log_write(bp);
    80003b2c:	854a                	mv	a0,s2
    80003b2e:	00001097          	auipc	ra,0x1
    80003b32:	c02080e7          	jalr	-1022(ra) # 80004730 <log_write>
  brelse(bp);
    80003b36:	854a                	mv	a0,s2
    80003b38:	00000097          	auipc	ra,0x0
    80003b3c:	94e080e7          	jalr	-1714(ra) # 80003486 <brelse>
}
    80003b40:	60e2                	ld	ra,24(sp)
    80003b42:	6442                	ld	s0,16(sp)
    80003b44:	64a2                	ld	s1,8(sp)
    80003b46:	6902                	ld	s2,0(sp)
    80003b48:	6105                	add	sp,sp,32
    80003b4a:	8082                	ret

0000000080003b4c <idup>:
{
    80003b4c:	1101                	add	sp,sp,-32
    80003b4e:	ec06                	sd	ra,24(sp)
    80003b50:	e822                	sd	s0,16(sp)
    80003b52:	e426                	sd	s1,8(sp)
    80003b54:	1000                	add	s0,sp,32
    80003b56:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b58:	0001b517          	auipc	a0,0x1b
    80003b5c:	6d050513          	add	a0,a0,1744 # 8001f228 <itable>
    80003b60:	ffffd097          	auipc	ra,0xffffd
    80003b64:	1a0080e7          	jalr	416(ra) # 80000d00 <acquire>
  ip->ref++;
    80003b68:	449c                	lw	a5,8(s1)
    80003b6a:	2785                	addw	a5,a5,1
    80003b6c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b6e:	0001b517          	auipc	a0,0x1b
    80003b72:	6ba50513          	add	a0,a0,1722 # 8001f228 <itable>
    80003b76:	ffffd097          	auipc	ra,0xffffd
    80003b7a:	23e080e7          	jalr	574(ra) # 80000db4 <release>
}
    80003b7e:	8526                	mv	a0,s1
    80003b80:	60e2                	ld	ra,24(sp)
    80003b82:	6442                	ld	s0,16(sp)
    80003b84:	64a2                	ld	s1,8(sp)
    80003b86:	6105                	add	sp,sp,32
    80003b88:	8082                	ret

0000000080003b8a <ilock>:
{
    80003b8a:	1101                	add	sp,sp,-32
    80003b8c:	ec06                	sd	ra,24(sp)
    80003b8e:	e822                	sd	s0,16(sp)
    80003b90:	e426                	sd	s1,8(sp)
    80003b92:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b94:	c10d                	beqz	a0,80003bb6 <ilock+0x2c>
    80003b96:	84aa                	mv	s1,a0
    80003b98:	451c                	lw	a5,8(a0)
    80003b9a:	00f05e63          	blez	a5,80003bb6 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003b9e:	0541                	add	a0,a0,16
    80003ba0:	00001097          	auipc	ra,0x1
    80003ba4:	cae080e7          	jalr	-850(ra) # 8000484e <acquiresleep>
  if(ip->valid == 0){
    80003ba8:	40bc                	lw	a5,64(s1)
    80003baa:	cf99                	beqz	a5,80003bc8 <ilock+0x3e>
}
    80003bac:	60e2                	ld	ra,24(sp)
    80003bae:	6442                	ld	s0,16(sp)
    80003bb0:	64a2                	ld	s1,8(sp)
    80003bb2:	6105                	add	sp,sp,32
    80003bb4:	8082                	ret
    80003bb6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003bb8:	00005517          	auipc	a0,0x5
    80003bbc:	a5850513          	add	a0,a0,-1448 # 80008610 <__func__.1+0x608>
    80003bc0:	ffffd097          	auipc	ra,0xffffd
    80003bc4:	9a0080e7          	jalr	-1632(ra) # 80000560 <panic>
    80003bc8:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bca:	40dc                	lw	a5,4(s1)
    80003bcc:	0047d79b          	srlw	a5,a5,0x4
    80003bd0:	0001b597          	auipc	a1,0x1b
    80003bd4:	6505a583          	lw	a1,1616(a1) # 8001f220 <sb+0x18>
    80003bd8:	9dbd                	addw	a1,a1,a5
    80003bda:	4088                	lw	a0,0(s1)
    80003bdc:	fffff097          	auipc	ra,0xfffff
    80003be0:	77a080e7          	jalr	1914(ra) # 80003356 <bread>
    80003be4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003be6:	05850593          	add	a1,a0,88
    80003bea:	40dc                	lw	a5,4(s1)
    80003bec:	8bbd                	and	a5,a5,15
    80003bee:	079a                	sll	a5,a5,0x6
    80003bf0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003bf2:	00059783          	lh	a5,0(a1)
    80003bf6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003bfa:	00259783          	lh	a5,2(a1)
    80003bfe:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c02:	00459783          	lh	a5,4(a1)
    80003c06:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c0a:	00659783          	lh	a5,6(a1)
    80003c0e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c12:	459c                	lw	a5,8(a1)
    80003c14:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c16:	03400613          	li	a2,52
    80003c1a:	05b1                	add	a1,a1,12
    80003c1c:	05048513          	add	a0,s1,80
    80003c20:	ffffd097          	auipc	ra,0xffffd
    80003c24:	238080e7          	jalr	568(ra) # 80000e58 <memmove>
    brelse(bp);
    80003c28:	854a                	mv	a0,s2
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	85c080e7          	jalr	-1956(ra) # 80003486 <brelse>
    ip->valid = 1;
    80003c32:	4785                	li	a5,1
    80003c34:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c36:	04449783          	lh	a5,68(s1)
    80003c3a:	c399                	beqz	a5,80003c40 <ilock+0xb6>
    80003c3c:	6902                	ld	s2,0(sp)
    80003c3e:	b7bd                	j	80003bac <ilock+0x22>
      panic("ilock: no type");
    80003c40:	00005517          	auipc	a0,0x5
    80003c44:	9d850513          	add	a0,a0,-1576 # 80008618 <__func__.1+0x610>
    80003c48:	ffffd097          	auipc	ra,0xffffd
    80003c4c:	918080e7          	jalr	-1768(ra) # 80000560 <panic>

0000000080003c50 <iunlock>:
{
    80003c50:	1101                	add	sp,sp,-32
    80003c52:	ec06                	sd	ra,24(sp)
    80003c54:	e822                	sd	s0,16(sp)
    80003c56:	e426                	sd	s1,8(sp)
    80003c58:	e04a                	sd	s2,0(sp)
    80003c5a:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c5c:	c905                	beqz	a0,80003c8c <iunlock+0x3c>
    80003c5e:	84aa                	mv	s1,a0
    80003c60:	01050913          	add	s2,a0,16
    80003c64:	854a                	mv	a0,s2
    80003c66:	00001097          	auipc	ra,0x1
    80003c6a:	c82080e7          	jalr	-894(ra) # 800048e8 <holdingsleep>
    80003c6e:	cd19                	beqz	a0,80003c8c <iunlock+0x3c>
    80003c70:	449c                	lw	a5,8(s1)
    80003c72:	00f05d63          	blez	a5,80003c8c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c76:	854a                	mv	a0,s2
    80003c78:	00001097          	auipc	ra,0x1
    80003c7c:	c2c080e7          	jalr	-980(ra) # 800048a4 <releasesleep>
}
    80003c80:	60e2                	ld	ra,24(sp)
    80003c82:	6442                	ld	s0,16(sp)
    80003c84:	64a2                	ld	s1,8(sp)
    80003c86:	6902                	ld	s2,0(sp)
    80003c88:	6105                	add	sp,sp,32
    80003c8a:	8082                	ret
    panic("iunlock");
    80003c8c:	00005517          	auipc	a0,0x5
    80003c90:	99c50513          	add	a0,a0,-1636 # 80008628 <__func__.1+0x620>
    80003c94:	ffffd097          	auipc	ra,0xffffd
    80003c98:	8cc080e7          	jalr	-1844(ra) # 80000560 <panic>

0000000080003c9c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c9c:	7179                	add	sp,sp,-48
    80003c9e:	f406                	sd	ra,40(sp)
    80003ca0:	f022                	sd	s0,32(sp)
    80003ca2:	ec26                	sd	s1,24(sp)
    80003ca4:	e84a                	sd	s2,16(sp)
    80003ca6:	e44e                	sd	s3,8(sp)
    80003ca8:	1800                	add	s0,sp,48
    80003caa:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003cac:	05050493          	add	s1,a0,80
    80003cb0:	08050913          	add	s2,a0,128
    80003cb4:	a021                	j	80003cbc <itrunc+0x20>
    80003cb6:	0491                	add	s1,s1,4
    80003cb8:	01248d63          	beq	s1,s2,80003cd2 <itrunc+0x36>
    if(ip->addrs[i]){
    80003cbc:	408c                	lw	a1,0(s1)
    80003cbe:	dde5                	beqz	a1,80003cb6 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003cc0:	0009a503          	lw	a0,0(s3)
    80003cc4:	00000097          	auipc	ra,0x0
    80003cc8:	8d6080e7          	jalr	-1834(ra) # 8000359a <bfree>
      ip->addrs[i] = 0;
    80003ccc:	0004a023          	sw	zero,0(s1)
    80003cd0:	b7dd                	j	80003cb6 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003cd2:	0809a583          	lw	a1,128(s3)
    80003cd6:	ed99                	bnez	a1,80003cf4 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003cd8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003cdc:	854e                	mv	a0,s3
    80003cde:	00000097          	auipc	ra,0x0
    80003ce2:	de0080e7          	jalr	-544(ra) # 80003abe <iupdate>
}
    80003ce6:	70a2                	ld	ra,40(sp)
    80003ce8:	7402                	ld	s0,32(sp)
    80003cea:	64e2                	ld	s1,24(sp)
    80003cec:	6942                	ld	s2,16(sp)
    80003cee:	69a2                	ld	s3,8(sp)
    80003cf0:	6145                	add	sp,sp,48
    80003cf2:	8082                	ret
    80003cf4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003cf6:	0009a503          	lw	a0,0(s3)
    80003cfa:	fffff097          	auipc	ra,0xfffff
    80003cfe:	65c080e7          	jalr	1628(ra) # 80003356 <bread>
    80003d02:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d04:	05850493          	add	s1,a0,88
    80003d08:	45850913          	add	s2,a0,1112
    80003d0c:	a021                	j	80003d14 <itrunc+0x78>
    80003d0e:	0491                	add	s1,s1,4
    80003d10:	01248b63          	beq	s1,s2,80003d26 <itrunc+0x8a>
      if(a[j])
    80003d14:	408c                	lw	a1,0(s1)
    80003d16:	dde5                	beqz	a1,80003d0e <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003d18:	0009a503          	lw	a0,0(s3)
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	87e080e7          	jalr	-1922(ra) # 8000359a <bfree>
    80003d24:	b7ed                	j	80003d0e <itrunc+0x72>
    brelse(bp);
    80003d26:	8552                	mv	a0,s4
    80003d28:	fffff097          	auipc	ra,0xfffff
    80003d2c:	75e080e7          	jalr	1886(ra) # 80003486 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d30:	0809a583          	lw	a1,128(s3)
    80003d34:	0009a503          	lw	a0,0(s3)
    80003d38:	00000097          	auipc	ra,0x0
    80003d3c:	862080e7          	jalr	-1950(ra) # 8000359a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d40:	0809a023          	sw	zero,128(s3)
    80003d44:	6a02                	ld	s4,0(sp)
    80003d46:	bf49                	j	80003cd8 <itrunc+0x3c>

0000000080003d48 <iput>:
{
    80003d48:	1101                	add	sp,sp,-32
    80003d4a:	ec06                	sd	ra,24(sp)
    80003d4c:	e822                	sd	s0,16(sp)
    80003d4e:	e426                	sd	s1,8(sp)
    80003d50:	1000                	add	s0,sp,32
    80003d52:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d54:	0001b517          	auipc	a0,0x1b
    80003d58:	4d450513          	add	a0,a0,1236 # 8001f228 <itable>
    80003d5c:	ffffd097          	auipc	ra,0xffffd
    80003d60:	fa4080e7          	jalr	-92(ra) # 80000d00 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d64:	4498                	lw	a4,8(s1)
    80003d66:	4785                	li	a5,1
    80003d68:	02f70263          	beq	a4,a5,80003d8c <iput+0x44>
  ip->ref--;
    80003d6c:	449c                	lw	a5,8(s1)
    80003d6e:	37fd                	addw	a5,a5,-1
    80003d70:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d72:	0001b517          	auipc	a0,0x1b
    80003d76:	4b650513          	add	a0,a0,1206 # 8001f228 <itable>
    80003d7a:	ffffd097          	auipc	ra,0xffffd
    80003d7e:	03a080e7          	jalr	58(ra) # 80000db4 <release>
}
    80003d82:	60e2                	ld	ra,24(sp)
    80003d84:	6442                	ld	s0,16(sp)
    80003d86:	64a2                	ld	s1,8(sp)
    80003d88:	6105                	add	sp,sp,32
    80003d8a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d8c:	40bc                	lw	a5,64(s1)
    80003d8e:	dff9                	beqz	a5,80003d6c <iput+0x24>
    80003d90:	04a49783          	lh	a5,74(s1)
    80003d94:	ffe1                	bnez	a5,80003d6c <iput+0x24>
    80003d96:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003d98:	01048913          	add	s2,s1,16
    80003d9c:	854a                	mv	a0,s2
    80003d9e:	00001097          	auipc	ra,0x1
    80003da2:	ab0080e7          	jalr	-1360(ra) # 8000484e <acquiresleep>
    release(&itable.lock);
    80003da6:	0001b517          	auipc	a0,0x1b
    80003daa:	48250513          	add	a0,a0,1154 # 8001f228 <itable>
    80003dae:	ffffd097          	auipc	ra,0xffffd
    80003db2:	006080e7          	jalr	6(ra) # 80000db4 <release>
    itrunc(ip);
    80003db6:	8526                	mv	a0,s1
    80003db8:	00000097          	auipc	ra,0x0
    80003dbc:	ee4080e7          	jalr	-284(ra) # 80003c9c <itrunc>
    ip->type = 0;
    80003dc0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003dc4:	8526                	mv	a0,s1
    80003dc6:	00000097          	auipc	ra,0x0
    80003dca:	cf8080e7          	jalr	-776(ra) # 80003abe <iupdate>
    ip->valid = 0;
    80003dce:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003dd2:	854a                	mv	a0,s2
    80003dd4:	00001097          	auipc	ra,0x1
    80003dd8:	ad0080e7          	jalr	-1328(ra) # 800048a4 <releasesleep>
    acquire(&itable.lock);
    80003ddc:	0001b517          	auipc	a0,0x1b
    80003de0:	44c50513          	add	a0,a0,1100 # 8001f228 <itable>
    80003de4:	ffffd097          	auipc	ra,0xffffd
    80003de8:	f1c080e7          	jalr	-228(ra) # 80000d00 <acquire>
    80003dec:	6902                	ld	s2,0(sp)
    80003dee:	bfbd                	j	80003d6c <iput+0x24>

0000000080003df0 <iunlockput>:
{
    80003df0:	1101                	add	sp,sp,-32
    80003df2:	ec06                	sd	ra,24(sp)
    80003df4:	e822                	sd	s0,16(sp)
    80003df6:	e426                	sd	s1,8(sp)
    80003df8:	1000                	add	s0,sp,32
    80003dfa:	84aa                	mv	s1,a0
  iunlock(ip);
    80003dfc:	00000097          	auipc	ra,0x0
    80003e00:	e54080e7          	jalr	-428(ra) # 80003c50 <iunlock>
  iput(ip);
    80003e04:	8526                	mv	a0,s1
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	f42080e7          	jalr	-190(ra) # 80003d48 <iput>
}
    80003e0e:	60e2                	ld	ra,24(sp)
    80003e10:	6442                	ld	s0,16(sp)
    80003e12:	64a2                	ld	s1,8(sp)
    80003e14:	6105                	add	sp,sp,32
    80003e16:	8082                	ret

0000000080003e18 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e18:	1141                	add	sp,sp,-16
    80003e1a:	e422                	sd	s0,8(sp)
    80003e1c:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003e1e:	411c                	lw	a5,0(a0)
    80003e20:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e22:	415c                	lw	a5,4(a0)
    80003e24:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e26:	04451783          	lh	a5,68(a0)
    80003e2a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e2e:	04a51783          	lh	a5,74(a0)
    80003e32:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e36:	04c56783          	lwu	a5,76(a0)
    80003e3a:	e99c                	sd	a5,16(a1)
}
    80003e3c:	6422                	ld	s0,8(sp)
    80003e3e:	0141                	add	sp,sp,16
    80003e40:	8082                	ret

0000000080003e42 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e42:	457c                	lw	a5,76(a0)
    80003e44:	10d7e563          	bltu	a5,a3,80003f4e <readi+0x10c>
{
    80003e48:	7159                	add	sp,sp,-112
    80003e4a:	f486                	sd	ra,104(sp)
    80003e4c:	f0a2                	sd	s0,96(sp)
    80003e4e:	eca6                	sd	s1,88(sp)
    80003e50:	e0d2                	sd	s4,64(sp)
    80003e52:	fc56                	sd	s5,56(sp)
    80003e54:	f85a                	sd	s6,48(sp)
    80003e56:	f45e                	sd	s7,40(sp)
    80003e58:	1880                	add	s0,sp,112
    80003e5a:	8b2a                	mv	s6,a0
    80003e5c:	8bae                	mv	s7,a1
    80003e5e:	8a32                	mv	s4,a2
    80003e60:	84b6                	mv	s1,a3
    80003e62:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e64:	9f35                	addw	a4,a4,a3
    return 0;
    80003e66:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e68:	0cd76a63          	bltu	a4,a3,80003f3c <readi+0xfa>
    80003e6c:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003e6e:	00e7f463          	bgeu	a5,a4,80003e76 <readi+0x34>
    n = ip->size - off;
    80003e72:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e76:	0a0a8963          	beqz	s5,80003f28 <readi+0xe6>
    80003e7a:	e8ca                	sd	s2,80(sp)
    80003e7c:	f062                	sd	s8,32(sp)
    80003e7e:	ec66                	sd	s9,24(sp)
    80003e80:	e86a                	sd	s10,16(sp)
    80003e82:	e46e                	sd	s11,8(sp)
    80003e84:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e86:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e8a:	5c7d                	li	s8,-1
    80003e8c:	a82d                	j	80003ec6 <readi+0x84>
    80003e8e:	020d1d93          	sll	s11,s10,0x20
    80003e92:	020ddd93          	srl	s11,s11,0x20
    80003e96:	05890613          	add	a2,s2,88
    80003e9a:	86ee                	mv	a3,s11
    80003e9c:	963a                	add	a2,a2,a4
    80003e9e:	85d2                	mv	a1,s4
    80003ea0:	855e                	mv	a0,s7
    80003ea2:	fffff097          	auipc	ra,0xfffff
    80003ea6:	91e080e7          	jalr	-1762(ra) # 800027c0 <either_copyout>
    80003eaa:	05850d63          	beq	a0,s8,80003f04 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003eae:	854a                	mv	a0,s2
    80003eb0:	fffff097          	auipc	ra,0xfffff
    80003eb4:	5d6080e7          	jalr	1494(ra) # 80003486 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003eb8:	013d09bb          	addw	s3,s10,s3
    80003ebc:	009d04bb          	addw	s1,s10,s1
    80003ec0:	9a6e                	add	s4,s4,s11
    80003ec2:	0559fd63          	bgeu	s3,s5,80003f1c <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003ec6:	00a4d59b          	srlw	a1,s1,0xa
    80003eca:	855a                	mv	a0,s6
    80003ecc:	00000097          	auipc	ra,0x0
    80003ed0:	88e080e7          	jalr	-1906(ra) # 8000375a <bmap>
    80003ed4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ed8:	c9b1                	beqz	a1,80003f2c <readi+0xea>
    bp = bread(ip->dev, addr);
    80003eda:	000b2503          	lw	a0,0(s6)
    80003ede:	fffff097          	auipc	ra,0xfffff
    80003ee2:	478080e7          	jalr	1144(ra) # 80003356 <bread>
    80003ee6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ee8:	3ff4f713          	and	a4,s1,1023
    80003eec:	40ec87bb          	subw	a5,s9,a4
    80003ef0:	413a86bb          	subw	a3,s5,s3
    80003ef4:	8d3e                	mv	s10,a5
    80003ef6:	2781                	sext.w	a5,a5
    80003ef8:	0006861b          	sext.w	a2,a3
    80003efc:	f8f679e3          	bgeu	a2,a5,80003e8e <readi+0x4c>
    80003f00:	8d36                	mv	s10,a3
    80003f02:	b771                	j	80003e8e <readi+0x4c>
      brelse(bp);
    80003f04:	854a                	mv	a0,s2
    80003f06:	fffff097          	auipc	ra,0xfffff
    80003f0a:	580080e7          	jalr	1408(ra) # 80003486 <brelse>
      tot = -1;
    80003f0e:	59fd                	li	s3,-1
      break;
    80003f10:	6946                	ld	s2,80(sp)
    80003f12:	7c02                	ld	s8,32(sp)
    80003f14:	6ce2                	ld	s9,24(sp)
    80003f16:	6d42                	ld	s10,16(sp)
    80003f18:	6da2                	ld	s11,8(sp)
    80003f1a:	a831                	j	80003f36 <readi+0xf4>
    80003f1c:	6946                	ld	s2,80(sp)
    80003f1e:	7c02                	ld	s8,32(sp)
    80003f20:	6ce2                	ld	s9,24(sp)
    80003f22:	6d42                	ld	s10,16(sp)
    80003f24:	6da2                	ld	s11,8(sp)
    80003f26:	a801                	j	80003f36 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f28:	89d6                	mv	s3,s5
    80003f2a:	a031                	j	80003f36 <readi+0xf4>
    80003f2c:	6946                	ld	s2,80(sp)
    80003f2e:	7c02                	ld	s8,32(sp)
    80003f30:	6ce2                	ld	s9,24(sp)
    80003f32:	6d42                	ld	s10,16(sp)
    80003f34:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003f36:	0009851b          	sext.w	a0,s3
    80003f3a:	69a6                	ld	s3,72(sp)
}
    80003f3c:	70a6                	ld	ra,104(sp)
    80003f3e:	7406                	ld	s0,96(sp)
    80003f40:	64e6                	ld	s1,88(sp)
    80003f42:	6a06                	ld	s4,64(sp)
    80003f44:	7ae2                	ld	s5,56(sp)
    80003f46:	7b42                	ld	s6,48(sp)
    80003f48:	7ba2                	ld	s7,40(sp)
    80003f4a:	6165                	add	sp,sp,112
    80003f4c:	8082                	ret
    return 0;
    80003f4e:	4501                	li	a0,0
}
    80003f50:	8082                	ret

0000000080003f52 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f52:	457c                	lw	a5,76(a0)
    80003f54:	10d7ee63          	bltu	a5,a3,80004070 <writei+0x11e>
{
    80003f58:	7159                	add	sp,sp,-112
    80003f5a:	f486                	sd	ra,104(sp)
    80003f5c:	f0a2                	sd	s0,96(sp)
    80003f5e:	e8ca                	sd	s2,80(sp)
    80003f60:	e0d2                	sd	s4,64(sp)
    80003f62:	fc56                	sd	s5,56(sp)
    80003f64:	f85a                	sd	s6,48(sp)
    80003f66:	f45e                	sd	s7,40(sp)
    80003f68:	1880                	add	s0,sp,112
    80003f6a:	8aaa                	mv	s5,a0
    80003f6c:	8bae                	mv	s7,a1
    80003f6e:	8a32                	mv	s4,a2
    80003f70:	8936                	mv	s2,a3
    80003f72:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f74:	00e687bb          	addw	a5,a3,a4
    80003f78:	0ed7ee63          	bltu	a5,a3,80004074 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f7c:	00043737          	lui	a4,0x43
    80003f80:	0ef76c63          	bltu	a4,a5,80004078 <writei+0x126>
    80003f84:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f86:	0c0b0d63          	beqz	s6,80004060 <writei+0x10e>
    80003f8a:	eca6                	sd	s1,88(sp)
    80003f8c:	f062                	sd	s8,32(sp)
    80003f8e:	ec66                	sd	s9,24(sp)
    80003f90:	e86a                	sd	s10,16(sp)
    80003f92:	e46e                	sd	s11,8(sp)
    80003f94:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f96:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f9a:	5c7d                	li	s8,-1
    80003f9c:	a091                	j	80003fe0 <writei+0x8e>
    80003f9e:	020d1d93          	sll	s11,s10,0x20
    80003fa2:	020ddd93          	srl	s11,s11,0x20
    80003fa6:	05848513          	add	a0,s1,88
    80003faa:	86ee                	mv	a3,s11
    80003fac:	8652                	mv	a2,s4
    80003fae:	85de                	mv	a1,s7
    80003fb0:	953a                	add	a0,a0,a4
    80003fb2:	fffff097          	auipc	ra,0xfffff
    80003fb6:	864080e7          	jalr	-1948(ra) # 80002816 <either_copyin>
    80003fba:	07850263          	beq	a0,s8,8000401e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003fbe:	8526                	mv	a0,s1
    80003fc0:	00000097          	auipc	ra,0x0
    80003fc4:	770080e7          	jalr	1904(ra) # 80004730 <log_write>
    brelse(bp);
    80003fc8:	8526                	mv	a0,s1
    80003fca:	fffff097          	auipc	ra,0xfffff
    80003fce:	4bc080e7          	jalr	1212(ra) # 80003486 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fd2:	013d09bb          	addw	s3,s10,s3
    80003fd6:	012d093b          	addw	s2,s10,s2
    80003fda:	9a6e                	add	s4,s4,s11
    80003fdc:	0569f663          	bgeu	s3,s6,80004028 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003fe0:	00a9559b          	srlw	a1,s2,0xa
    80003fe4:	8556                	mv	a0,s5
    80003fe6:	fffff097          	auipc	ra,0xfffff
    80003fea:	774080e7          	jalr	1908(ra) # 8000375a <bmap>
    80003fee:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ff2:	c99d                	beqz	a1,80004028 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003ff4:	000aa503          	lw	a0,0(s5)
    80003ff8:	fffff097          	auipc	ra,0xfffff
    80003ffc:	35e080e7          	jalr	862(ra) # 80003356 <bread>
    80004000:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004002:	3ff97713          	and	a4,s2,1023
    80004006:	40ec87bb          	subw	a5,s9,a4
    8000400a:	413b06bb          	subw	a3,s6,s3
    8000400e:	8d3e                	mv	s10,a5
    80004010:	2781                	sext.w	a5,a5
    80004012:	0006861b          	sext.w	a2,a3
    80004016:	f8f674e3          	bgeu	a2,a5,80003f9e <writei+0x4c>
    8000401a:	8d36                	mv	s10,a3
    8000401c:	b749                	j	80003f9e <writei+0x4c>
      brelse(bp);
    8000401e:	8526                	mv	a0,s1
    80004020:	fffff097          	auipc	ra,0xfffff
    80004024:	466080e7          	jalr	1126(ra) # 80003486 <brelse>
  }

  if(off > ip->size)
    80004028:	04caa783          	lw	a5,76(s5)
    8000402c:	0327fc63          	bgeu	a5,s2,80004064 <writei+0x112>
    ip->size = off;
    80004030:	052aa623          	sw	s2,76(s5)
    80004034:	64e6                	ld	s1,88(sp)
    80004036:	7c02                	ld	s8,32(sp)
    80004038:	6ce2                	ld	s9,24(sp)
    8000403a:	6d42                	ld	s10,16(sp)
    8000403c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000403e:	8556                	mv	a0,s5
    80004040:	00000097          	auipc	ra,0x0
    80004044:	a7e080e7          	jalr	-1410(ra) # 80003abe <iupdate>

  return tot;
    80004048:	0009851b          	sext.w	a0,s3
    8000404c:	69a6                	ld	s3,72(sp)
}
    8000404e:	70a6                	ld	ra,104(sp)
    80004050:	7406                	ld	s0,96(sp)
    80004052:	6946                	ld	s2,80(sp)
    80004054:	6a06                	ld	s4,64(sp)
    80004056:	7ae2                	ld	s5,56(sp)
    80004058:	7b42                	ld	s6,48(sp)
    8000405a:	7ba2                	ld	s7,40(sp)
    8000405c:	6165                	add	sp,sp,112
    8000405e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004060:	89da                	mv	s3,s6
    80004062:	bff1                	j	8000403e <writei+0xec>
    80004064:	64e6                	ld	s1,88(sp)
    80004066:	7c02                	ld	s8,32(sp)
    80004068:	6ce2                	ld	s9,24(sp)
    8000406a:	6d42                	ld	s10,16(sp)
    8000406c:	6da2                	ld	s11,8(sp)
    8000406e:	bfc1                	j	8000403e <writei+0xec>
    return -1;
    80004070:	557d                	li	a0,-1
}
    80004072:	8082                	ret
    return -1;
    80004074:	557d                	li	a0,-1
    80004076:	bfe1                	j	8000404e <writei+0xfc>
    return -1;
    80004078:	557d                	li	a0,-1
    8000407a:	bfd1                	j	8000404e <writei+0xfc>

000000008000407c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000407c:	1141                	add	sp,sp,-16
    8000407e:	e406                	sd	ra,8(sp)
    80004080:	e022                	sd	s0,0(sp)
    80004082:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004084:	4639                	li	a2,14
    80004086:	ffffd097          	auipc	ra,0xffffd
    8000408a:	e46080e7          	jalr	-442(ra) # 80000ecc <strncmp>
}
    8000408e:	60a2                	ld	ra,8(sp)
    80004090:	6402                	ld	s0,0(sp)
    80004092:	0141                	add	sp,sp,16
    80004094:	8082                	ret

0000000080004096 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004096:	7139                	add	sp,sp,-64
    80004098:	fc06                	sd	ra,56(sp)
    8000409a:	f822                	sd	s0,48(sp)
    8000409c:	f426                	sd	s1,40(sp)
    8000409e:	f04a                	sd	s2,32(sp)
    800040a0:	ec4e                	sd	s3,24(sp)
    800040a2:	e852                	sd	s4,16(sp)
    800040a4:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040a6:	04451703          	lh	a4,68(a0)
    800040aa:	4785                	li	a5,1
    800040ac:	00f71a63          	bne	a4,a5,800040c0 <dirlookup+0x2a>
    800040b0:	892a                	mv	s2,a0
    800040b2:	89ae                	mv	s3,a1
    800040b4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800040b6:	457c                	lw	a5,76(a0)
    800040b8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800040ba:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040bc:	e79d                	bnez	a5,800040ea <dirlookup+0x54>
    800040be:	a8a5                	j	80004136 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800040c0:	00004517          	auipc	a0,0x4
    800040c4:	57050513          	add	a0,a0,1392 # 80008630 <__func__.1+0x628>
    800040c8:	ffffc097          	auipc	ra,0xffffc
    800040cc:	498080e7          	jalr	1176(ra) # 80000560 <panic>
      panic("dirlookup read");
    800040d0:	00004517          	auipc	a0,0x4
    800040d4:	57850513          	add	a0,a0,1400 # 80008648 <__func__.1+0x640>
    800040d8:	ffffc097          	auipc	ra,0xffffc
    800040dc:	488080e7          	jalr	1160(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040e0:	24c1                	addw	s1,s1,16
    800040e2:	04c92783          	lw	a5,76(s2)
    800040e6:	04f4f763          	bgeu	s1,a5,80004134 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040ea:	4741                	li	a4,16
    800040ec:	86a6                	mv	a3,s1
    800040ee:	fc040613          	add	a2,s0,-64
    800040f2:	4581                	li	a1,0
    800040f4:	854a                	mv	a0,s2
    800040f6:	00000097          	auipc	ra,0x0
    800040fa:	d4c080e7          	jalr	-692(ra) # 80003e42 <readi>
    800040fe:	47c1                	li	a5,16
    80004100:	fcf518e3          	bne	a0,a5,800040d0 <dirlookup+0x3a>
    if(de.inum == 0)
    80004104:	fc045783          	lhu	a5,-64(s0)
    80004108:	dfe1                	beqz	a5,800040e0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000410a:	fc240593          	add	a1,s0,-62
    8000410e:	854e                	mv	a0,s3
    80004110:	00000097          	auipc	ra,0x0
    80004114:	f6c080e7          	jalr	-148(ra) # 8000407c <namecmp>
    80004118:	f561                	bnez	a0,800040e0 <dirlookup+0x4a>
      if(poff)
    8000411a:	000a0463          	beqz	s4,80004122 <dirlookup+0x8c>
        *poff = off;
    8000411e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004122:	fc045583          	lhu	a1,-64(s0)
    80004126:	00092503          	lw	a0,0(s2)
    8000412a:	fffff097          	auipc	ra,0xfffff
    8000412e:	720080e7          	jalr	1824(ra) # 8000384a <iget>
    80004132:	a011                	j	80004136 <dirlookup+0xa0>
  return 0;
    80004134:	4501                	li	a0,0
}
    80004136:	70e2                	ld	ra,56(sp)
    80004138:	7442                	ld	s0,48(sp)
    8000413a:	74a2                	ld	s1,40(sp)
    8000413c:	7902                	ld	s2,32(sp)
    8000413e:	69e2                	ld	s3,24(sp)
    80004140:	6a42                	ld	s4,16(sp)
    80004142:	6121                	add	sp,sp,64
    80004144:	8082                	ret

0000000080004146 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004146:	711d                	add	sp,sp,-96
    80004148:	ec86                	sd	ra,88(sp)
    8000414a:	e8a2                	sd	s0,80(sp)
    8000414c:	e4a6                	sd	s1,72(sp)
    8000414e:	e0ca                	sd	s2,64(sp)
    80004150:	fc4e                	sd	s3,56(sp)
    80004152:	f852                	sd	s4,48(sp)
    80004154:	f456                	sd	s5,40(sp)
    80004156:	f05a                	sd	s6,32(sp)
    80004158:	ec5e                	sd	s7,24(sp)
    8000415a:	e862                	sd	s8,16(sp)
    8000415c:	e466                	sd	s9,8(sp)
    8000415e:	1080                	add	s0,sp,96
    80004160:	84aa                	mv	s1,a0
    80004162:	8b2e                	mv	s6,a1
    80004164:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004166:	00054703          	lbu	a4,0(a0)
    8000416a:	02f00793          	li	a5,47
    8000416e:	02f70263          	beq	a4,a5,80004192 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004172:	ffffe097          	auipc	ra,0xffffe
    80004176:	a94080e7          	jalr	-1388(ra) # 80001c06 <myproc>
    8000417a:	15053503          	ld	a0,336(a0)
    8000417e:	00000097          	auipc	ra,0x0
    80004182:	9ce080e7          	jalr	-1586(ra) # 80003b4c <idup>
    80004186:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004188:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000418c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000418e:	4b85                	li	s7,1
    80004190:	a875                	j	8000424c <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80004192:	4585                	li	a1,1
    80004194:	4505                	li	a0,1
    80004196:	fffff097          	auipc	ra,0xfffff
    8000419a:	6b4080e7          	jalr	1716(ra) # 8000384a <iget>
    8000419e:	8a2a                	mv	s4,a0
    800041a0:	b7e5                	j	80004188 <namex+0x42>
      iunlockput(ip);
    800041a2:	8552                	mv	a0,s4
    800041a4:	00000097          	auipc	ra,0x0
    800041a8:	c4c080e7          	jalr	-948(ra) # 80003df0 <iunlockput>
      return 0;
    800041ac:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800041ae:	8552                	mv	a0,s4
    800041b0:	60e6                	ld	ra,88(sp)
    800041b2:	6446                	ld	s0,80(sp)
    800041b4:	64a6                	ld	s1,72(sp)
    800041b6:	6906                	ld	s2,64(sp)
    800041b8:	79e2                	ld	s3,56(sp)
    800041ba:	7a42                	ld	s4,48(sp)
    800041bc:	7aa2                	ld	s5,40(sp)
    800041be:	7b02                	ld	s6,32(sp)
    800041c0:	6be2                	ld	s7,24(sp)
    800041c2:	6c42                	ld	s8,16(sp)
    800041c4:	6ca2                	ld	s9,8(sp)
    800041c6:	6125                	add	sp,sp,96
    800041c8:	8082                	ret
      iunlock(ip);
    800041ca:	8552                	mv	a0,s4
    800041cc:	00000097          	auipc	ra,0x0
    800041d0:	a84080e7          	jalr	-1404(ra) # 80003c50 <iunlock>
      return ip;
    800041d4:	bfe9                	j	800041ae <namex+0x68>
      iunlockput(ip);
    800041d6:	8552                	mv	a0,s4
    800041d8:	00000097          	auipc	ra,0x0
    800041dc:	c18080e7          	jalr	-1000(ra) # 80003df0 <iunlockput>
      return 0;
    800041e0:	8a4e                	mv	s4,s3
    800041e2:	b7f1                	j	800041ae <namex+0x68>
  len = path - s;
    800041e4:	40998633          	sub	a2,s3,s1
    800041e8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800041ec:	099c5863          	bge	s8,s9,8000427c <namex+0x136>
    memmove(name, s, DIRSIZ);
    800041f0:	4639                	li	a2,14
    800041f2:	85a6                	mv	a1,s1
    800041f4:	8556                	mv	a0,s5
    800041f6:	ffffd097          	auipc	ra,0xffffd
    800041fa:	c62080e7          	jalr	-926(ra) # 80000e58 <memmove>
    800041fe:	84ce                	mv	s1,s3
  while(*path == '/')
    80004200:	0004c783          	lbu	a5,0(s1)
    80004204:	01279763          	bne	a5,s2,80004212 <namex+0xcc>
    path++;
    80004208:	0485                	add	s1,s1,1
  while(*path == '/')
    8000420a:	0004c783          	lbu	a5,0(s1)
    8000420e:	ff278de3          	beq	a5,s2,80004208 <namex+0xc2>
    ilock(ip);
    80004212:	8552                	mv	a0,s4
    80004214:	00000097          	auipc	ra,0x0
    80004218:	976080e7          	jalr	-1674(ra) # 80003b8a <ilock>
    if(ip->type != T_DIR){
    8000421c:	044a1783          	lh	a5,68(s4)
    80004220:	f97791e3          	bne	a5,s7,800041a2 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004224:	000b0563          	beqz	s6,8000422e <namex+0xe8>
    80004228:	0004c783          	lbu	a5,0(s1)
    8000422c:	dfd9                	beqz	a5,800041ca <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000422e:	4601                	li	a2,0
    80004230:	85d6                	mv	a1,s5
    80004232:	8552                	mv	a0,s4
    80004234:	00000097          	auipc	ra,0x0
    80004238:	e62080e7          	jalr	-414(ra) # 80004096 <dirlookup>
    8000423c:	89aa                	mv	s3,a0
    8000423e:	dd41                	beqz	a0,800041d6 <namex+0x90>
    iunlockput(ip);
    80004240:	8552                	mv	a0,s4
    80004242:	00000097          	auipc	ra,0x0
    80004246:	bae080e7          	jalr	-1106(ra) # 80003df0 <iunlockput>
    ip = next;
    8000424a:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000424c:	0004c783          	lbu	a5,0(s1)
    80004250:	01279763          	bne	a5,s2,8000425e <namex+0x118>
    path++;
    80004254:	0485                	add	s1,s1,1
  while(*path == '/')
    80004256:	0004c783          	lbu	a5,0(s1)
    8000425a:	ff278de3          	beq	a5,s2,80004254 <namex+0x10e>
  if(*path == 0)
    8000425e:	cb9d                	beqz	a5,80004294 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004260:	0004c783          	lbu	a5,0(s1)
    80004264:	89a6                	mv	s3,s1
  len = path - s;
    80004266:	4c81                	li	s9,0
    80004268:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000426a:	01278963          	beq	a5,s2,8000427c <namex+0x136>
    8000426e:	dbbd                	beqz	a5,800041e4 <namex+0x9e>
    path++;
    80004270:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80004272:	0009c783          	lbu	a5,0(s3)
    80004276:	ff279ce3          	bne	a5,s2,8000426e <namex+0x128>
    8000427a:	b7ad                	j	800041e4 <namex+0x9e>
    memmove(name, s, len);
    8000427c:	2601                	sext.w	a2,a2
    8000427e:	85a6                	mv	a1,s1
    80004280:	8556                	mv	a0,s5
    80004282:	ffffd097          	auipc	ra,0xffffd
    80004286:	bd6080e7          	jalr	-1066(ra) # 80000e58 <memmove>
    name[len] = 0;
    8000428a:	9cd6                	add	s9,s9,s5
    8000428c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004290:	84ce                	mv	s1,s3
    80004292:	b7bd                	j	80004200 <namex+0xba>
  if(nameiparent){
    80004294:	f00b0de3          	beqz	s6,800041ae <namex+0x68>
    iput(ip);
    80004298:	8552                	mv	a0,s4
    8000429a:	00000097          	auipc	ra,0x0
    8000429e:	aae080e7          	jalr	-1362(ra) # 80003d48 <iput>
    return 0;
    800042a2:	4a01                	li	s4,0
    800042a4:	b729                	j	800041ae <namex+0x68>

00000000800042a6 <dirlink>:
{
    800042a6:	7139                	add	sp,sp,-64
    800042a8:	fc06                	sd	ra,56(sp)
    800042aa:	f822                	sd	s0,48(sp)
    800042ac:	f04a                	sd	s2,32(sp)
    800042ae:	ec4e                	sd	s3,24(sp)
    800042b0:	e852                	sd	s4,16(sp)
    800042b2:	0080                	add	s0,sp,64
    800042b4:	892a                	mv	s2,a0
    800042b6:	8a2e                	mv	s4,a1
    800042b8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042ba:	4601                	li	a2,0
    800042bc:	00000097          	auipc	ra,0x0
    800042c0:	dda080e7          	jalr	-550(ra) # 80004096 <dirlookup>
    800042c4:	ed25                	bnez	a0,8000433c <dirlink+0x96>
    800042c6:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042c8:	04c92483          	lw	s1,76(s2)
    800042cc:	c49d                	beqz	s1,800042fa <dirlink+0x54>
    800042ce:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042d0:	4741                	li	a4,16
    800042d2:	86a6                	mv	a3,s1
    800042d4:	fc040613          	add	a2,s0,-64
    800042d8:	4581                	li	a1,0
    800042da:	854a                	mv	a0,s2
    800042dc:	00000097          	auipc	ra,0x0
    800042e0:	b66080e7          	jalr	-1178(ra) # 80003e42 <readi>
    800042e4:	47c1                	li	a5,16
    800042e6:	06f51163          	bne	a0,a5,80004348 <dirlink+0xa2>
    if(de.inum == 0)
    800042ea:	fc045783          	lhu	a5,-64(s0)
    800042ee:	c791                	beqz	a5,800042fa <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042f0:	24c1                	addw	s1,s1,16
    800042f2:	04c92783          	lw	a5,76(s2)
    800042f6:	fcf4ede3          	bltu	s1,a5,800042d0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800042fa:	4639                	li	a2,14
    800042fc:	85d2                	mv	a1,s4
    800042fe:	fc240513          	add	a0,s0,-62
    80004302:	ffffd097          	auipc	ra,0xffffd
    80004306:	c00080e7          	jalr	-1024(ra) # 80000f02 <strncpy>
  de.inum = inum;
    8000430a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000430e:	4741                	li	a4,16
    80004310:	86a6                	mv	a3,s1
    80004312:	fc040613          	add	a2,s0,-64
    80004316:	4581                	li	a1,0
    80004318:	854a                	mv	a0,s2
    8000431a:	00000097          	auipc	ra,0x0
    8000431e:	c38080e7          	jalr	-968(ra) # 80003f52 <writei>
    80004322:	1541                	add	a0,a0,-16
    80004324:	00a03533          	snez	a0,a0
    80004328:	40a00533          	neg	a0,a0
    8000432c:	74a2                	ld	s1,40(sp)
}
    8000432e:	70e2                	ld	ra,56(sp)
    80004330:	7442                	ld	s0,48(sp)
    80004332:	7902                	ld	s2,32(sp)
    80004334:	69e2                	ld	s3,24(sp)
    80004336:	6a42                	ld	s4,16(sp)
    80004338:	6121                	add	sp,sp,64
    8000433a:	8082                	ret
    iput(ip);
    8000433c:	00000097          	auipc	ra,0x0
    80004340:	a0c080e7          	jalr	-1524(ra) # 80003d48 <iput>
    return -1;
    80004344:	557d                	li	a0,-1
    80004346:	b7e5                	j	8000432e <dirlink+0x88>
      panic("dirlink read");
    80004348:	00004517          	auipc	a0,0x4
    8000434c:	31050513          	add	a0,a0,784 # 80008658 <__func__.1+0x650>
    80004350:	ffffc097          	auipc	ra,0xffffc
    80004354:	210080e7          	jalr	528(ra) # 80000560 <panic>

0000000080004358 <namei>:

struct inode*
namei(char *path)
{
    80004358:	1101                	add	sp,sp,-32
    8000435a:	ec06                	sd	ra,24(sp)
    8000435c:	e822                	sd	s0,16(sp)
    8000435e:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004360:	fe040613          	add	a2,s0,-32
    80004364:	4581                	li	a1,0
    80004366:	00000097          	auipc	ra,0x0
    8000436a:	de0080e7          	jalr	-544(ra) # 80004146 <namex>
}
    8000436e:	60e2                	ld	ra,24(sp)
    80004370:	6442                	ld	s0,16(sp)
    80004372:	6105                	add	sp,sp,32
    80004374:	8082                	ret

0000000080004376 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004376:	1141                	add	sp,sp,-16
    80004378:	e406                	sd	ra,8(sp)
    8000437a:	e022                	sd	s0,0(sp)
    8000437c:	0800                	add	s0,sp,16
    8000437e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004380:	4585                	li	a1,1
    80004382:	00000097          	auipc	ra,0x0
    80004386:	dc4080e7          	jalr	-572(ra) # 80004146 <namex>
}
    8000438a:	60a2                	ld	ra,8(sp)
    8000438c:	6402                	ld	s0,0(sp)
    8000438e:	0141                	add	sp,sp,16
    80004390:	8082                	ret

0000000080004392 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004392:	1101                	add	sp,sp,-32
    80004394:	ec06                	sd	ra,24(sp)
    80004396:	e822                	sd	s0,16(sp)
    80004398:	e426                	sd	s1,8(sp)
    8000439a:	e04a                	sd	s2,0(sp)
    8000439c:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000439e:	0001d917          	auipc	s2,0x1d
    800043a2:	93290913          	add	s2,s2,-1742 # 80020cd0 <log>
    800043a6:	01892583          	lw	a1,24(s2)
    800043aa:	02892503          	lw	a0,40(s2)
    800043ae:	fffff097          	auipc	ra,0xfffff
    800043b2:	fa8080e7          	jalr	-88(ra) # 80003356 <bread>
    800043b6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043b8:	02c92603          	lw	a2,44(s2)
    800043bc:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800043be:	00c05f63          	blez	a2,800043dc <write_head+0x4a>
    800043c2:	0001d717          	auipc	a4,0x1d
    800043c6:	93e70713          	add	a4,a4,-1730 # 80020d00 <log+0x30>
    800043ca:	87aa                	mv	a5,a0
    800043cc:	060a                	sll	a2,a2,0x2
    800043ce:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800043d0:	4314                	lw	a3,0(a4)
    800043d2:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800043d4:	0711                	add	a4,a4,4
    800043d6:	0791                	add	a5,a5,4
    800043d8:	fec79ce3          	bne	a5,a2,800043d0 <write_head+0x3e>
  }
  bwrite(buf);
    800043dc:	8526                	mv	a0,s1
    800043de:	fffff097          	auipc	ra,0xfffff
    800043e2:	06a080e7          	jalr	106(ra) # 80003448 <bwrite>
  brelse(buf);
    800043e6:	8526                	mv	a0,s1
    800043e8:	fffff097          	auipc	ra,0xfffff
    800043ec:	09e080e7          	jalr	158(ra) # 80003486 <brelse>
}
    800043f0:	60e2                	ld	ra,24(sp)
    800043f2:	6442                	ld	s0,16(sp)
    800043f4:	64a2                	ld	s1,8(sp)
    800043f6:	6902                	ld	s2,0(sp)
    800043f8:	6105                	add	sp,sp,32
    800043fa:	8082                	ret

00000000800043fc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043fc:	0001d797          	auipc	a5,0x1d
    80004400:	9007a783          	lw	a5,-1792(a5) # 80020cfc <log+0x2c>
    80004404:	0af05d63          	blez	a5,800044be <install_trans+0xc2>
{
    80004408:	7139                	add	sp,sp,-64
    8000440a:	fc06                	sd	ra,56(sp)
    8000440c:	f822                	sd	s0,48(sp)
    8000440e:	f426                	sd	s1,40(sp)
    80004410:	f04a                	sd	s2,32(sp)
    80004412:	ec4e                	sd	s3,24(sp)
    80004414:	e852                	sd	s4,16(sp)
    80004416:	e456                	sd	s5,8(sp)
    80004418:	e05a                	sd	s6,0(sp)
    8000441a:	0080                	add	s0,sp,64
    8000441c:	8b2a                	mv	s6,a0
    8000441e:	0001da97          	auipc	s5,0x1d
    80004422:	8e2a8a93          	add	s5,s5,-1822 # 80020d00 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004426:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004428:	0001d997          	auipc	s3,0x1d
    8000442c:	8a898993          	add	s3,s3,-1880 # 80020cd0 <log>
    80004430:	a00d                	j	80004452 <install_trans+0x56>
    brelse(lbuf);
    80004432:	854a                	mv	a0,s2
    80004434:	fffff097          	auipc	ra,0xfffff
    80004438:	052080e7          	jalr	82(ra) # 80003486 <brelse>
    brelse(dbuf);
    8000443c:	8526                	mv	a0,s1
    8000443e:	fffff097          	auipc	ra,0xfffff
    80004442:	048080e7          	jalr	72(ra) # 80003486 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004446:	2a05                	addw	s4,s4,1
    80004448:	0a91                	add	s5,s5,4
    8000444a:	02c9a783          	lw	a5,44(s3)
    8000444e:	04fa5e63          	bge	s4,a5,800044aa <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004452:	0189a583          	lw	a1,24(s3)
    80004456:	014585bb          	addw	a1,a1,s4
    8000445a:	2585                	addw	a1,a1,1
    8000445c:	0289a503          	lw	a0,40(s3)
    80004460:	fffff097          	auipc	ra,0xfffff
    80004464:	ef6080e7          	jalr	-266(ra) # 80003356 <bread>
    80004468:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000446a:	000aa583          	lw	a1,0(s5)
    8000446e:	0289a503          	lw	a0,40(s3)
    80004472:	fffff097          	auipc	ra,0xfffff
    80004476:	ee4080e7          	jalr	-284(ra) # 80003356 <bread>
    8000447a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000447c:	40000613          	li	a2,1024
    80004480:	05890593          	add	a1,s2,88
    80004484:	05850513          	add	a0,a0,88
    80004488:	ffffd097          	auipc	ra,0xffffd
    8000448c:	9d0080e7          	jalr	-1584(ra) # 80000e58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004490:	8526                	mv	a0,s1
    80004492:	fffff097          	auipc	ra,0xfffff
    80004496:	fb6080e7          	jalr	-74(ra) # 80003448 <bwrite>
    if(recovering == 0)
    8000449a:	f80b1ce3          	bnez	s6,80004432 <install_trans+0x36>
      bunpin(dbuf);
    8000449e:	8526                	mv	a0,s1
    800044a0:	fffff097          	auipc	ra,0xfffff
    800044a4:	0be080e7          	jalr	190(ra) # 8000355e <bunpin>
    800044a8:	b769                	j	80004432 <install_trans+0x36>
}
    800044aa:	70e2                	ld	ra,56(sp)
    800044ac:	7442                	ld	s0,48(sp)
    800044ae:	74a2                	ld	s1,40(sp)
    800044b0:	7902                	ld	s2,32(sp)
    800044b2:	69e2                	ld	s3,24(sp)
    800044b4:	6a42                	ld	s4,16(sp)
    800044b6:	6aa2                	ld	s5,8(sp)
    800044b8:	6b02                	ld	s6,0(sp)
    800044ba:	6121                	add	sp,sp,64
    800044bc:	8082                	ret
    800044be:	8082                	ret

00000000800044c0 <initlog>:
{
    800044c0:	7179                	add	sp,sp,-48
    800044c2:	f406                	sd	ra,40(sp)
    800044c4:	f022                	sd	s0,32(sp)
    800044c6:	ec26                	sd	s1,24(sp)
    800044c8:	e84a                	sd	s2,16(sp)
    800044ca:	e44e                	sd	s3,8(sp)
    800044cc:	1800                	add	s0,sp,48
    800044ce:	892a                	mv	s2,a0
    800044d0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800044d2:	0001c497          	auipc	s1,0x1c
    800044d6:	7fe48493          	add	s1,s1,2046 # 80020cd0 <log>
    800044da:	00004597          	auipc	a1,0x4
    800044de:	18e58593          	add	a1,a1,398 # 80008668 <__func__.1+0x660>
    800044e2:	8526                	mv	a0,s1
    800044e4:	ffffc097          	auipc	ra,0xffffc
    800044e8:	78c080e7          	jalr	1932(ra) # 80000c70 <initlock>
  log.start = sb->logstart;
    800044ec:	0149a583          	lw	a1,20(s3)
    800044f0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800044f2:	0109a783          	lw	a5,16(s3)
    800044f6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800044f8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044fc:	854a                	mv	a0,s2
    800044fe:	fffff097          	auipc	ra,0xfffff
    80004502:	e58080e7          	jalr	-424(ra) # 80003356 <bread>
  log.lh.n = lh->n;
    80004506:	4d30                	lw	a2,88(a0)
    80004508:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000450a:	00c05f63          	blez	a2,80004528 <initlog+0x68>
    8000450e:	87aa                	mv	a5,a0
    80004510:	0001c717          	auipc	a4,0x1c
    80004514:	7f070713          	add	a4,a4,2032 # 80020d00 <log+0x30>
    80004518:	060a                	sll	a2,a2,0x2
    8000451a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000451c:	4ff4                	lw	a3,92(a5)
    8000451e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004520:	0791                	add	a5,a5,4
    80004522:	0711                	add	a4,a4,4
    80004524:	fec79ce3          	bne	a5,a2,8000451c <initlog+0x5c>
  brelse(buf);
    80004528:	fffff097          	auipc	ra,0xfffff
    8000452c:	f5e080e7          	jalr	-162(ra) # 80003486 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004530:	4505                	li	a0,1
    80004532:	00000097          	auipc	ra,0x0
    80004536:	eca080e7          	jalr	-310(ra) # 800043fc <install_trans>
  log.lh.n = 0;
    8000453a:	0001c797          	auipc	a5,0x1c
    8000453e:	7c07a123          	sw	zero,1986(a5) # 80020cfc <log+0x2c>
  write_head(); // clear the log
    80004542:	00000097          	auipc	ra,0x0
    80004546:	e50080e7          	jalr	-432(ra) # 80004392 <write_head>
}
    8000454a:	70a2                	ld	ra,40(sp)
    8000454c:	7402                	ld	s0,32(sp)
    8000454e:	64e2                	ld	s1,24(sp)
    80004550:	6942                	ld	s2,16(sp)
    80004552:	69a2                	ld	s3,8(sp)
    80004554:	6145                	add	sp,sp,48
    80004556:	8082                	ret

0000000080004558 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004558:	1101                	add	sp,sp,-32
    8000455a:	ec06                	sd	ra,24(sp)
    8000455c:	e822                	sd	s0,16(sp)
    8000455e:	e426                	sd	s1,8(sp)
    80004560:	e04a                	sd	s2,0(sp)
    80004562:	1000                	add	s0,sp,32
  acquire(&log.lock);
    80004564:	0001c517          	auipc	a0,0x1c
    80004568:	76c50513          	add	a0,a0,1900 # 80020cd0 <log>
    8000456c:	ffffc097          	auipc	ra,0xffffc
    80004570:	794080e7          	jalr	1940(ra) # 80000d00 <acquire>
  while(1){
    if(log.committing){
    80004574:	0001c497          	auipc	s1,0x1c
    80004578:	75c48493          	add	s1,s1,1884 # 80020cd0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000457c:	4979                	li	s2,30
    8000457e:	a039                	j	8000458c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004580:	85a6                	mv	a1,s1
    80004582:	8526                	mv	a0,s1
    80004584:	ffffe097          	auipc	ra,0xffffe
    80004588:	e34080e7          	jalr	-460(ra) # 800023b8 <sleep>
    if(log.committing){
    8000458c:	50dc                	lw	a5,36(s1)
    8000458e:	fbed                	bnez	a5,80004580 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004590:	5098                	lw	a4,32(s1)
    80004592:	2705                	addw	a4,a4,1
    80004594:	0027179b          	sllw	a5,a4,0x2
    80004598:	9fb9                	addw	a5,a5,a4
    8000459a:	0017979b          	sllw	a5,a5,0x1
    8000459e:	54d4                	lw	a3,44(s1)
    800045a0:	9fb5                	addw	a5,a5,a3
    800045a2:	00f95963          	bge	s2,a5,800045b4 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800045a6:	85a6                	mv	a1,s1
    800045a8:	8526                	mv	a0,s1
    800045aa:	ffffe097          	auipc	ra,0xffffe
    800045ae:	e0e080e7          	jalr	-498(ra) # 800023b8 <sleep>
    800045b2:	bfe9                	j	8000458c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800045b4:	0001c517          	auipc	a0,0x1c
    800045b8:	71c50513          	add	a0,a0,1820 # 80020cd0 <log>
    800045bc:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800045be:	ffffc097          	auipc	ra,0xffffc
    800045c2:	7f6080e7          	jalr	2038(ra) # 80000db4 <release>
      break;
    }
  }
}
    800045c6:	60e2                	ld	ra,24(sp)
    800045c8:	6442                	ld	s0,16(sp)
    800045ca:	64a2                	ld	s1,8(sp)
    800045cc:	6902                	ld	s2,0(sp)
    800045ce:	6105                	add	sp,sp,32
    800045d0:	8082                	ret

00000000800045d2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800045d2:	7139                	add	sp,sp,-64
    800045d4:	fc06                	sd	ra,56(sp)
    800045d6:	f822                	sd	s0,48(sp)
    800045d8:	f426                	sd	s1,40(sp)
    800045da:	f04a                	sd	s2,32(sp)
    800045dc:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800045de:	0001c497          	auipc	s1,0x1c
    800045e2:	6f248493          	add	s1,s1,1778 # 80020cd0 <log>
    800045e6:	8526                	mv	a0,s1
    800045e8:	ffffc097          	auipc	ra,0xffffc
    800045ec:	718080e7          	jalr	1816(ra) # 80000d00 <acquire>
  log.outstanding -= 1;
    800045f0:	509c                	lw	a5,32(s1)
    800045f2:	37fd                	addw	a5,a5,-1
    800045f4:	0007891b          	sext.w	s2,a5
    800045f8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800045fa:	50dc                	lw	a5,36(s1)
    800045fc:	e7b9                	bnez	a5,8000464a <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    800045fe:	06091163          	bnez	s2,80004660 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004602:	0001c497          	auipc	s1,0x1c
    80004606:	6ce48493          	add	s1,s1,1742 # 80020cd0 <log>
    8000460a:	4785                	li	a5,1
    8000460c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000460e:	8526                	mv	a0,s1
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	7a4080e7          	jalr	1956(ra) # 80000db4 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004618:	54dc                	lw	a5,44(s1)
    8000461a:	06f04763          	bgtz	a5,80004688 <end_op+0xb6>
    acquire(&log.lock);
    8000461e:	0001c497          	auipc	s1,0x1c
    80004622:	6b248493          	add	s1,s1,1714 # 80020cd0 <log>
    80004626:	8526                	mv	a0,s1
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	6d8080e7          	jalr	1752(ra) # 80000d00 <acquire>
    log.committing = 0;
    80004630:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004634:	8526                	mv	a0,s1
    80004636:	ffffe097          	auipc	ra,0xffffe
    8000463a:	de6080e7          	jalr	-538(ra) # 8000241c <wakeup>
    release(&log.lock);
    8000463e:	8526                	mv	a0,s1
    80004640:	ffffc097          	auipc	ra,0xffffc
    80004644:	774080e7          	jalr	1908(ra) # 80000db4 <release>
}
    80004648:	a815                	j	8000467c <end_op+0xaa>
    8000464a:	ec4e                	sd	s3,24(sp)
    8000464c:	e852                	sd	s4,16(sp)
    8000464e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004650:	00004517          	auipc	a0,0x4
    80004654:	02050513          	add	a0,a0,32 # 80008670 <__func__.1+0x668>
    80004658:	ffffc097          	auipc	ra,0xffffc
    8000465c:	f08080e7          	jalr	-248(ra) # 80000560 <panic>
    wakeup(&log);
    80004660:	0001c497          	auipc	s1,0x1c
    80004664:	67048493          	add	s1,s1,1648 # 80020cd0 <log>
    80004668:	8526                	mv	a0,s1
    8000466a:	ffffe097          	auipc	ra,0xffffe
    8000466e:	db2080e7          	jalr	-590(ra) # 8000241c <wakeup>
  release(&log.lock);
    80004672:	8526                	mv	a0,s1
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	740080e7          	jalr	1856(ra) # 80000db4 <release>
}
    8000467c:	70e2                	ld	ra,56(sp)
    8000467e:	7442                	ld	s0,48(sp)
    80004680:	74a2                	ld	s1,40(sp)
    80004682:	7902                	ld	s2,32(sp)
    80004684:	6121                	add	sp,sp,64
    80004686:	8082                	ret
    80004688:	ec4e                	sd	s3,24(sp)
    8000468a:	e852                	sd	s4,16(sp)
    8000468c:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000468e:	0001ca97          	auipc	s5,0x1c
    80004692:	672a8a93          	add	s5,s5,1650 # 80020d00 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004696:	0001ca17          	auipc	s4,0x1c
    8000469a:	63aa0a13          	add	s4,s4,1594 # 80020cd0 <log>
    8000469e:	018a2583          	lw	a1,24(s4)
    800046a2:	012585bb          	addw	a1,a1,s2
    800046a6:	2585                	addw	a1,a1,1
    800046a8:	028a2503          	lw	a0,40(s4)
    800046ac:	fffff097          	auipc	ra,0xfffff
    800046b0:	caa080e7          	jalr	-854(ra) # 80003356 <bread>
    800046b4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800046b6:	000aa583          	lw	a1,0(s5)
    800046ba:	028a2503          	lw	a0,40(s4)
    800046be:	fffff097          	auipc	ra,0xfffff
    800046c2:	c98080e7          	jalr	-872(ra) # 80003356 <bread>
    800046c6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800046c8:	40000613          	li	a2,1024
    800046cc:	05850593          	add	a1,a0,88
    800046d0:	05848513          	add	a0,s1,88
    800046d4:	ffffc097          	auipc	ra,0xffffc
    800046d8:	784080e7          	jalr	1924(ra) # 80000e58 <memmove>
    bwrite(to);  // write the log
    800046dc:	8526                	mv	a0,s1
    800046de:	fffff097          	auipc	ra,0xfffff
    800046e2:	d6a080e7          	jalr	-662(ra) # 80003448 <bwrite>
    brelse(from);
    800046e6:	854e                	mv	a0,s3
    800046e8:	fffff097          	auipc	ra,0xfffff
    800046ec:	d9e080e7          	jalr	-610(ra) # 80003486 <brelse>
    brelse(to);
    800046f0:	8526                	mv	a0,s1
    800046f2:	fffff097          	auipc	ra,0xfffff
    800046f6:	d94080e7          	jalr	-620(ra) # 80003486 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046fa:	2905                	addw	s2,s2,1
    800046fc:	0a91                	add	s5,s5,4
    800046fe:	02ca2783          	lw	a5,44(s4)
    80004702:	f8f94ee3          	blt	s2,a5,8000469e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004706:	00000097          	auipc	ra,0x0
    8000470a:	c8c080e7          	jalr	-884(ra) # 80004392 <write_head>
    install_trans(0); // Now install writes to home locations
    8000470e:	4501                	li	a0,0
    80004710:	00000097          	auipc	ra,0x0
    80004714:	cec080e7          	jalr	-788(ra) # 800043fc <install_trans>
    log.lh.n = 0;
    80004718:	0001c797          	auipc	a5,0x1c
    8000471c:	5e07a223          	sw	zero,1508(a5) # 80020cfc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004720:	00000097          	auipc	ra,0x0
    80004724:	c72080e7          	jalr	-910(ra) # 80004392 <write_head>
    80004728:	69e2                	ld	s3,24(sp)
    8000472a:	6a42                	ld	s4,16(sp)
    8000472c:	6aa2                	ld	s5,8(sp)
    8000472e:	bdc5                	j	8000461e <end_op+0x4c>

0000000080004730 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004730:	1101                	add	sp,sp,-32
    80004732:	ec06                	sd	ra,24(sp)
    80004734:	e822                	sd	s0,16(sp)
    80004736:	e426                	sd	s1,8(sp)
    80004738:	e04a                	sd	s2,0(sp)
    8000473a:	1000                	add	s0,sp,32
    8000473c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000473e:	0001c917          	auipc	s2,0x1c
    80004742:	59290913          	add	s2,s2,1426 # 80020cd0 <log>
    80004746:	854a                	mv	a0,s2
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	5b8080e7          	jalr	1464(ra) # 80000d00 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004750:	02c92603          	lw	a2,44(s2)
    80004754:	47f5                	li	a5,29
    80004756:	06c7c563          	blt	a5,a2,800047c0 <log_write+0x90>
    8000475a:	0001c797          	auipc	a5,0x1c
    8000475e:	5927a783          	lw	a5,1426(a5) # 80020cec <log+0x1c>
    80004762:	37fd                	addw	a5,a5,-1
    80004764:	04f65e63          	bge	a2,a5,800047c0 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004768:	0001c797          	auipc	a5,0x1c
    8000476c:	5887a783          	lw	a5,1416(a5) # 80020cf0 <log+0x20>
    80004770:	06f05063          	blez	a5,800047d0 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004774:	4781                	li	a5,0
    80004776:	06c05563          	blez	a2,800047e0 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000477a:	44cc                	lw	a1,12(s1)
    8000477c:	0001c717          	auipc	a4,0x1c
    80004780:	58470713          	add	a4,a4,1412 # 80020d00 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004784:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004786:	4314                	lw	a3,0(a4)
    80004788:	04b68c63          	beq	a3,a1,800047e0 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000478c:	2785                	addw	a5,a5,1
    8000478e:	0711                	add	a4,a4,4
    80004790:	fef61be3          	bne	a2,a5,80004786 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004794:	0621                	add	a2,a2,8
    80004796:	060a                	sll	a2,a2,0x2
    80004798:	0001c797          	auipc	a5,0x1c
    8000479c:	53878793          	add	a5,a5,1336 # 80020cd0 <log>
    800047a0:	97b2                	add	a5,a5,a2
    800047a2:	44d8                	lw	a4,12(s1)
    800047a4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800047a6:	8526                	mv	a0,s1
    800047a8:	fffff097          	auipc	ra,0xfffff
    800047ac:	d7a080e7          	jalr	-646(ra) # 80003522 <bpin>
    log.lh.n++;
    800047b0:	0001c717          	auipc	a4,0x1c
    800047b4:	52070713          	add	a4,a4,1312 # 80020cd0 <log>
    800047b8:	575c                	lw	a5,44(a4)
    800047ba:	2785                	addw	a5,a5,1
    800047bc:	d75c                	sw	a5,44(a4)
    800047be:	a82d                	j	800047f8 <log_write+0xc8>
    panic("too big a transaction");
    800047c0:	00004517          	auipc	a0,0x4
    800047c4:	ec050513          	add	a0,a0,-320 # 80008680 <__func__.1+0x678>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	d98080e7          	jalr	-616(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    800047d0:	00004517          	auipc	a0,0x4
    800047d4:	ec850513          	add	a0,a0,-312 # 80008698 <__func__.1+0x690>
    800047d8:	ffffc097          	auipc	ra,0xffffc
    800047dc:	d88080e7          	jalr	-632(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    800047e0:	00878693          	add	a3,a5,8
    800047e4:	068a                	sll	a3,a3,0x2
    800047e6:	0001c717          	auipc	a4,0x1c
    800047ea:	4ea70713          	add	a4,a4,1258 # 80020cd0 <log>
    800047ee:	9736                	add	a4,a4,a3
    800047f0:	44d4                	lw	a3,12(s1)
    800047f2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800047f4:	faf609e3          	beq	a2,a5,800047a6 <log_write+0x76>
  }
  release(&log.lock);
    800047f8:	0001c517          	auipc	a0,0x1c
    800047fc:	4d850513          	add	a0,a0,1240 # 80020cd0 <log>
    80004800:	ffffc097          	auipc	ra,0xffffc
    80004804:	5b4080e7          	jalr	1460(ra) # 80000db4 <release>
}
    80004808:	60e2                	ld	ra,24(sp)
    8000480a:	6442                	ld	s0,16(sp)
    8000480c:	64a2                	ld	s1,8(sp)
    8000480e:	6902                	ld	s2,0(sp)
    80004810:	6105                	add	sp,sp,32
    80004812:	8082                	ret

0000000080004814 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004814:	1101                	add	sp,sp,-32
    80004816:	ec06                	sd	ra,24(sp)
    80004818:	e822                	sd	s0,16(sp)
    8000481a:	e426                	sd	s1,8(sp)
    8000481c:	e04a                	sd	s2,0(sp)
    8000481e:	1000                	add	s0,sp,32
    80004820:	84aa                	mv	s1,a0
    80004822:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004824:	00004597          	auipc	a1,0x4
    80004828:	e9458593          	add	a1,a1,-364 # 800086b8 <__func__.1+0x6b0>
    8000482c:	0521                	add	a0,a0,8
    8000482e:	ffffc097          	auipc	ra,0xffffc
    80004832:	442080e7          	jalr	1090(ra) # 80000c70 <initlock>
  lk->name = name;
    80004836:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000483a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000483e:	0204a423          	sw	zero,40(s1)
}
    80004842:	60e2                	ld	ra,24(sp)
    80004844:	6442                	ld	s0,16(sp)
    80004846:	64a2                	ld	s1,8(sp)
    80004848:	6902                	ld	s2,0(sp)
    8000484a:	6105                	add	sp,sp,32
    8000484c:	8082                	ret

000000008000484e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000484e:	1101                	add	sp,sp,-32
    80004850:	ec06                	sd	ra,24(sp)
    80004852:	e822                	sd	s0,16(sp)
    80004854:	e426                	sd	s1,8(sp)
    80004856:	e04a                	sd	s2,0(sp)
    80004858:	1000                	add	s0,sp,32
    8000485a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000485c:	00850913          	add	s2,a0,8
    80004860:	854a                	mv	a0,s2
    80004862:	ffffc097          	auipc	ra,0xffffc
    80004866:	49e080e7          	jalr	1182(ra) # 80000d00 <acquire>
  while (lk->locked) {
    8000486a:	409c                	lw	a5,0(s1)
    8000486c:	cb89                	beqz	a5,8000487e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000486e:	85ca                	mv	a1,s2
    80004870:	8526                	mv	a0,s1
    80004872:	ffffe097          	auipc	ra,0xffffe
    80004876:	b46080e7          	jalr	-1210(ra) # 800023b8 <sleep>
  while (lk->locked) {
    8000487a:	409c                	lw	a5,0(s1)
    8000487c:	fbed                	bnez	a5,8000486e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000487e:	4785                	li	a5,1
    80004880:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004882:	ffffd097          	auipc	ra,0xffffd
    80004886:	384080e7          	jalr	900(ra) # 80001c06 <myproc>
    8000488a:	591c                	lw	a5,48(a0)
    8000488c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000488e:	854a                	mv	a0,s2
    80004890:	ffffc097          	auipc	ra,0xffffc
    80004894:	524080e7          	jalr	1316(ra) # 80000db4 <release>
}
    80004898:	60e2                	ld	ra,24(sp)
    8000489a:	6442                	ld	s0,16(sp)
    8000489c:	64a2                	ld	s1,8(sp)
    8000489e:	6902                	ld	s2,0(sp)
    800048a0:	6105                	add	sp,sp,32
    800048a2:	8082                	ret

00000000800048a4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800048a4:	1101                	add	sp,sp,-32
    800048a6:	ec06                	sd	ra,24(sp)
    800048a8:	e822                	sd	s0,16(sp)
    800048aa:	e426                	sd	s1,8(sp)
    800048ac:	e04a                	sd	s2,0(sp)
    800048ae:	1000                	add	s0,sp,32
    800048b0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048b2:	00850913          	add	s2,a0,8
    800048b6:	854a                	mv	a0,s2
    800048b8:	ffffc097          	auipc	ra,0xffffc
    800048bc:	448080e7          	jalr	1096(ra) # 80000d00 <acquire>
  lk->locked = 0;
    800048c0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048c4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800048c8:	8526                	mv	a0,s1
    800048ca:	ffffe097          	auipc	ra,0xffffe
    800048ce:	b52080e7          	jalr	-1198(ra) # 8000241c <wakeup>
  release(&lk->lk);
    800048d2:	854a                	mv	a0,s2
    800048d4:	ffffc097          	auipc	ra,0xffffc
    800048d8:	4e0080e7          	jalr	1248(ra) # 80000db4 <release>
}
    800048dc:	60e2                	ld	ra,24(sp)
    800048de:	6442                	ld	s0,16(sp)
    800048e0:	64a2                	ld	s1,8(sp)
    800048e2:	6902                	ld	s2,0(sp)
    800048e4:	6105                	add	sp,sp,32
    800048e6:	8082                	ret

00000000800048e8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800048e8:	7179                	add	sp,sp,-48
    800048ea:	f406                	sd	ra,40(sp)
    800048ec:	f022                	sd	s0,32(sp)
    800048ee:	ec26                	sd	s1,24(sp)
    800048f0:	e84a                	sd	s2,16(sp)
    800048f2:	1800                	add	s0,sp,48
    800048f4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048f6:	00850913          	add	s2,a0,8
    800048fa:	854a                	mv	a0,s2
    800048fc:	ffffc097          	auipc	ra,0xffffc
    80004900:	404080e7          	jalr	1028(ra) # 80000d00 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004904:	409c                	lw	a5,0(s1)
    80004906:	ef91                	bnez	a5,80004922 <holdingsleep+0x3a>
    80004908:	4481                	li	s1,0
  release(&lk->lk);
    8000490a:	854a                	mv	a0,s2
    8000490c:	ffffc097          	auipc	ra,0xffffc
    80004910:	4a8080e7          	jalr	1192(ra) # 80000db4 <release>
  return r;
}
    80004914:	8526                	mv	a0,s1
    80004916:	70a2                	ld	ra,40(sp)
    80004918:	7402                	ld	s0,32(sp)
    8000491a:	64e2                	ld	s1,24(sp)
    8000491c:	6942                	ld	s2,16(sp)
    8000491e:	6145                	add	sp,sp,48
    80004920:	8082                	ret
    80004922:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004924:	0284a983          	lw	s3,40(s1)
    80004928:	ffffd097          	auipc	ra,0xffffd
    8000492c:	2de080e7          	jalr	734(ra) # 80001c06 <myproc>
    80004930:	5904                	lw	s1,48(a0)
    80004932:	413484b3          	sub	s1,s1,s3
    80004936:	0014b493          	seqz	s1,s1
    8000493a:	69a2                	ld	s3,8(sp)
    8000493c:	b7f9                	j	8000490a <holdingsleep+0x22>

000000008000493e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000493e:	1141                	add	sp,sp,-16
    80004940:	e406                	sd	ra,8(sp)
    80004942:	e022                	sd	s0,0(sp)
    80004944:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004946:	00004597          	auipc	a1,0x4
    8000494a:	d8258593          	add	a1,a1,-638 # 800086c8 <__func__.1+0x6c0>
    8000494e:	0001c517          	auipc	a0,0x1c
    80004952:	4ca50513          	add	a0,a0,1226 # 80020e18 <ftable>
    80004956:	ffffc097          	auipc	ra,0xffffc
    8000495a:	31a080e7          	jalr	794(ra) # 80000c70 <initlock>
}
    8000495e:	60a2                	ld	ra,8(sp)
    80004960:	6402                	ld	s0,0(sp)
    80004962:	0141                	add	sp,sp,16
    80004964:	8082                	ret

0000000080004966 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004966:	1101                	add	sp,sp,-32
    80004968:	ec06                	sd	ra,24(sp)
    8000496a:	e822                	sd	s0,16(sp)
    8000496c:	e426                	sd	s1,8(sp)
    8000496e:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004970:	0001c517          	auipc	a0,0x1c
    80004974:	4a850513          	add	a0,a0,1192 # 80020e18 <ftable>
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	388080e7          	jalr	904(ra) # 80000d00 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004980:	0001c497          	auipc	s1,0x1c
    80004984:	4b048493          	add	s1,s1,1200 # 80020e30 <ftable+0x18>
    80004988:	0001d717          	auipc	a4,0x1d
    8000498c:	44870713          	add	a4,a4,1096 # 80021dd0 <disk>
    if(f->ref == 0){
    80004990:	40dc                	lw	a5,4(s1)
    80004992:	cf99                	beqz	a5,800049b0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004994:	02848493          	add	s1,s1,40
    80004998:	fee49ce3          	bne	s1,a4,80004990 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000499c:	0001c517          	auipc	a0,0x1c
    800049a0:	47c50513          	add	a0,a0,1148 # 80020e18 <ftable>
    800049a4:	ffffc097          	auipc	ra,0xffffc
    800049a8:	410080e7          	jalr	1040(ra) # 80000db4 <release>
  return 0;
    800049ac:	4481                	li	s1,0
    800049ae:	a819                	j	800049c4 <filealloc+0x5e>
      f->ref = 1;
    800049b0:	4785                	li	a5,1
    800049b2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800049b4:	0001c517          	auipc	a0,0x1c
    800049b8:	46450513          	add	a0,a0,1124 # 80020e18 <ftable>
    800049bc:	ffffc097          	auipc	ra,0xffffc
    800049c0:	3f8080e7          	jalr	1016(ra) # 80000db4 <release>
}
    800049c4:	8526                	mv	a0,s1
    800049c6:	60e2                	ld	ra,24(sp)
    800049c8:	6442                	ld	s0,16(sp)
    800049ca:	64a2                	ld	s1,8(sp)
    800049cc:	6105                	add	sp,sp,32
    800049ce:	8082                	ret

00000000800049d0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800049d0:	1101                	add	sp,sp,-32
    800049d2:	ec06                	sd	ra,24(sp)
    800049d4:	e822                	sd	s0,16(sp)
    800049d6:	e426                	sd	s1,8(sp)
    800049d8:	1000                	add	s0,sp,32
    800049da:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049dc:	0001c517          	auipc	a0,0x1c
    800049e0:	43c50513          	add	a0,a0,1084 # 80020e18 <ftable>
    800049e4:	ffffc097          	auipc	ra,0xffffc
    800049e8:	31c080e7          	jalr	796(ra) # 80000d00 <acquire>
  if(f->ref < 1)
    800049ec:	40dc                	lw	a5,4(s1)
    800049ee:	02f05263          	blez	a5,80004a12 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800049f2:	2785                	addw	a5,a5,1
    800049f4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049f6:	0001c517          	auipc	a0,0x1c
    800049fa:	42250513          	add	a0,a0,1058 # 80020e18 <ftable>
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	3b6080e7          	jalr	950(ra) # 80000db4 <release>
  return f;
}
    80004a06:	8526                	mv	a0,s1
    80004a08:	60e2                	ld	ra,24(sp)
    80004a0a:	6442                	ld	s0,16(sp)
    80004a0c:	64a2                	ld	s1,8(sp)
    80004a0e:	6105                	add	sp,sp,32
    80004a10:	8082                	ret
    panic("filedup");
    80004a12:	00004517          	auipc	a0,0x4
    80004a16:	cbe50513          	add	a0,a0,-834 # 800086d0 <__func__.1+0x6c8>
    80004a1a:	ffffc097          	auipc	ra,0xffffc
    80004a1e:	b46080e7          	jalr	-1210(ra) # 80000560 <panic>

0000000080004a22 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a22:	7139                	add	sp,sp,-64
    80004a24:	fc06                	sd	ra,56(sp)
    80004a26:	f822                	sd	s0,48(sp)
    80004a28:	f426                	sd	s1,40(sp)
    80004a2a:	0080                	add	s0,sp,64
    80004a2c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a2e:	0001c517          	auipc	a0,0x1c
    80004a32:	3ea50513          	add	a0,a0,1002 # 80020e18 <ftable>
    80004a36:	ffffc097          	auipc	ra,0xffffc
    80004a3a:	2ca080e7          	jalr	714(ra) # 80000d00 <acquire>
  if(f->ref < 1)
    80004a3e:	40dc                	lw	a5,4(s1)
    80004a40:	04f05c63          	blez	a5,80004a98 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004a44:	37fd                	addw	a5,a5,-1
    80004a46:	0007871b          	sext.w	a4,a5
    80004a4a:	c0dc                	sw	a5,4(s1)
    80004a4c:	06e04263          	bgtz	a4,80004ab0 <fileclose+0x8e>
    80004a50:	f04a                	sd	s2,32(sp)
    80004a52:	ec4e                	sd	s3,24(sp)
    80004a54:	e852                	sd	s4,16(sp)
    80004a56:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a58:	0004a903          	lw	s2,0(s1)
    80004a5c:	0094ca83          	lbu	s5,9(s1)
    80004a60:	0104ba03          	ld	s4,16(s1)
    80004a64:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a68:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a6c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a70:	0001c517          	auipc	a0,0x1c
    80004a74:	3a850513          	add	a0,a0,936 # 80020e18 <ftable>
    80004a78:	ffffc097          	auipc	ra,0xffffc
    80004a7c:	33c080e7          	jalr	828(ra) # 80000db4 <release>

  if(ff.type == FD_PIPE){
    80004a80:	4785                	li	a5,1
    80004a82:	04f90463          	beq	s2,a5,80004aca <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a86:	3979                	addw	s2,s2,-2
    80004a88:	4785                	li	a5,1
    80004a8a:	0527fb63          	bgeu	a5,s2,80004ae0 <fileclose+0xbe>
    80004a8e:	7902                	ld	s2,32(sp)
    80004a90:	69e2                	ld	s3,24(sp)
    80004a92:	6a42                	ld	s4,16(sp)
    80004a94:	6aa2                	ld	s5,8(sp)
    80004a96:	a02d                	j	80004ac0 <fileclose+0x9e>
    80004a98:	f04a                	sd	s2,32(sp)
    80004a9a:	ec4e                	sd	s3,24(sp)
    80004a9c:	e852                	sd	s4,16(sp)
    80004a9e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004aa0:	00004517          	auipc	a0,0x4
    80004aa4:	c3850513          	add	a0,a0,-968 # 800086d8 <__func__.1+0x6d0>
    80004aa8:	ffffc097          	auipc	ra,0xffffc
    80004aac:	ab8080e7          	jalr	-1352(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004ab0:	0001c517          	auipc	a0,0x1c
    80004ab4:	36850513          	add	a0,a0,872 # 80020e18 <ftable>
    80004ab8:	ffffc097          	auipc	ra,0xffffc
    80004abc:	2fc080e7          	jalr	764(ra) # 80000db4 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004ac0:	70e2                	ld	ra,56(sp)
    80004ac2:	7442                	ld	s0,48(sp)
    80004ac4:	74a2                	ld	s1,40(sp)
    80004ac6:	6121                	add	sp,sp,64
    80004ac8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004aca:	85d6                	mv	a1,s5
    80004acc:	8552                	mv	a0,s4
    80004ace:	00000097          	auipc	ra,0x0
    80004ad2:	3a2080e7          	jalr	930(ra) # 80004e70 <pipeclose>
    80004ad6:	7902                	ld	s2,32(sp)
    80004ad8:	69e2                	ld	s3,24(sp)
    80004ada:	6a42                	ld	s4,16(sp)
    80004adc:	6aa2                	ld	s5,8(sp)
    80004ade:	b7cd                	j	80004ac0 <fileclose+0x9e>
    begin_op();
    80004ae0:	00000097          	auipc	ra,0x0
    80004ae4:	a78080e7          	jalr	-1416(ra) # 80004558 <begin_op>
    iput(ff.ip);
    80004ae8:	854e                	mv	a0,s3
    80004aea:	fffff097          	auipc	ra,0xfffff
    80004aee:	25e080e7          	jalr	606(ra) # 80003d48 <iput>
    end_op();
    80004af2:	00000097          	auipc	ra,0x0
    80004af6:	ae0080e7          	jalr	-1312(ra) # 800045d2 <end_op>
    80004afa:	7902                	ld	s2,32(sp)
    80004afc:	69e2                	ld	s3,24(sp)
    80004afe:	6a42                	ld	s4,16(sp)
    80004b00:	6aa2                	ld	s5,8(sp)
    80004b02:	bf7d                	j	80004ac0 <fileclose+0x9e>

0000000080004b04 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b04:	715d                	add	sp,sp,-80
    80004b06:	e486                	sd	ra,72(sp)
    80004b08:	e0a2                	sd	s0,64(sp)
    80004b0a:	fc26                	sd	s1,56(sp)
    80004b0c:	f44e                	sd	s3,40(sp)
    80004b0e:	0880                	add	s0,sp,80
    80004b10:	84aa                	mv	s1,a0
    80004b12:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b14:	ffffd097          	auipc	ra,0xffffd
    80004b18:	0f2080e7          	jalr	242(ra) # 80001c06 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b1c:	409c                	lw	a5,0(s1)
    80004b1e:	37f9                	addw	a5,a5,-2
    80004b20:	4705                	li	a4,1
    80004b22:	04f76863          	bltu	a4,a5,80004b72 <filestat+0x6e>
    80004b26:	f84a                	sd	s2,48(sp)
    80004b28:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b2a:	6c88                	ld	a0,24(s1)
    80004b2c:	fffff097          	auipc	ra,0xfffff
    80004b30:	05e080e7          	jalr	94(ra) # 80003b8a <ilock>
    stati(f->ip, &st);
    80004b34:	fb840593          	add	a1,s0,-72
    80004b38:	6c88                	ld	a0,24(s1)
    80004b3a:	fffff097          	auipc	ra,0xfffff
    80004b3e:	2de080e7          	jalr	734(ra) # 80003e18 <stati>
    iunlock(f->ip);
    80004b42:	6c88                	ld	a0,24(s1)
    80004b44:	fffff097          	auipc	ra,0xfffff
    80004b48:	10c080e7          	jalr	268(ra) # 80003c50 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b4c:	46e1                	li	a3,24
    80004b4e:	fb840613          	add	a2,s0,-72
    80004b52:	85ce                	mv	a1,s3
    80004b54:	05093503          	ld	a0,80(s2)
    80004b58:	ffffd097          	auipc	ra,0xffffd
    80004b5c:	c52080e7          	jalr	-942(ra) # 800017aa <copyout>
    80004b60:	41f5551b          	sraw	a0,a0,0x1f
    80004b64:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004b66:	60a6                	ld	ra,72(sp)
    80004b68:	6406                	ld	s0,64(sp)
    80004b6a:	74e2                	ld	s1,56(sp)
    80004b6c:	79a2                	ld	s3,40(sp)
    80004b6e:	6161                	add	sp,sp,80
    80004b70:	8082                	ret
  return -1;
    80004b72:	557d                	li	a0,-1
    80004b74:	bfcd                	j	80004b66 <filestat+0x62>

0000000080004b76 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b76:	7179                	add	sp,sp,-48
    80004b78:	f406                	sd	ra,40(sp)
    80004b7a:	f022                	sd	s0,32(sp)
    80004b7c:	e84a                	sd	s2,16(sp)
    80004b7e:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b80:	00854783          	lbu	a5,8(a0)
    80004b84:	cbc5                	beqz	a5,80004c34 <fileread+0xbe>
    80004b86:	ec26                	sd	s1,24(sp)
    80004b88:	e44e                	sd	s3,8(sp)
    80004b8a:	84aa                	mv	s1,a0
    80004b8c:	89ae                	mv	s3,a1
    80004b8e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b90:	411c                	lw	a5,0(a0)
    80004b92:	4705                	li	a4,1
    80004b94:	04e78963          	beq	a5,a4,80004be6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b98:	470d                	li	a4,3
    80004b9a:	04e78f63          	beq	a5,a4,80004bf8 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b9e:	4709                	li	a4,2
    80004ba0:	08e79263          	bne	a5,a4,80004c24 <fileread+0xae>
    ilock(f->ip);
    80004ba4:	6d08                	ld	a0,24(a0)
    80004ba6:	fffff097          	auipc	ra,0xfffff
    80004baa:	fe4080e7          	jalr	-28(ra) # 80003b8a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004bae:	874a                	mv	a4,s2
    80004bb0:	5094                	lw	a3,32(s1)
    80004bb2:	864e                	mv	a2,s3
    80004bb4:	4585                	li	a1,1
    80004bb6:	6c88                	ld	a0,24(s1)
    80004bb8:	fffff097          	auipc	ra,0xfffff
    80004bbc:	28a080e7          	jalr	650(ra) # 80003e42 <readi>
    80004bc0:	892a                	mv	s2,a0
    80004bc2:	00a05563          	blez	a0,80004bcc <fileread+0x56>
      f->off += r;
    80004bc6:	509c                	lw	a5,32(s1)
    80004bc8:	9fa9                	addw	a5,a5,a0
    80004bca:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004bcc:	6c88                	ld	a0,24(s1)
    80004bce:	fffff097          	auipc	ra,0xfffff
    80004bd2:	082080e7          	jalr	130(ra) # 80003c50 <iunlock>
    80004bd6:	64e2                	ld	s1,24(sp)
    80004bd8:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004bda:	854a                	mv	a0,s2
    80004bdc:	70a2                	ld	ra,40(sp)
    80004bde:	7402                	ld	s0,32(sp)
    80004be0:	6942                	ld	s2,16(sp)
    80004be2:	6145                	add	sp,sp,48
    80004be4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004be6:	6908                	ld	a0,16(a0)
    80004be8:	00000097          	auipc	ra,0x0
    80004bec:	400080e7          	jalr	1024(ra) # 80004fe8 <piperead>
    80004bf0:	892a                	mv	s2,a0
    80004bf2:	64e2                	ld	s1,24(sp)
    80004bf4:	69a2                	ld	s3,8(sp)
    80004bf6:	b7d5                	j	80004bda <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004bf8:	02451783          	lh	a5,36(a0)
    80004bfc:	03079693          	sll	a3,a5,0x30
    80004c00:	92c1                	srl	a3,a3,0x30
    80004c02:	4725                	li	a4,9
    80004c04:	02d76a63          	bltu	a4,a3,80004c38 <fileread+0xc2>
    80004c08:	0792                	sll	a5,a5,0x4
    80004c0a:	0001c717          	auipc	a4,0x1c
    80004c0e:	16e70713          	add	a4,a4,366 # 80020d78 <devsw>
    80004c12:	97ba                	add	a5,a5,a4
    80004c14:	639c                	ld	a5,0(a5)
    80004c16:	c78d                	beqz	a5,80004c40 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004c18:	4505                	li	a0,1
    80004c1a:	9782                	jalr	a5
    80004c1c:	892a                	mv	s2,a0
    80004c1e:	64e2                	ld	s1,24(sp)
    80004c20:	69a2                	ld	s3,8(sp)
    80004c22:	bf65                	j	80004bda <fileread+0x64>
    panic("fileread");
    80004c24:	00004517          	auipc	a0,0x4
    80004c28:	ac450513          	add	a0,a0,-1340 # 800086e8 <__func__.1+0x6e0>
    80004c2c:	ffffc097          	auipc	ra,0xffffc
    80004c30:	934080e7          	jalr	-1740(ra) # 80000560 <panic>
    return -1;
    80004c34:	597d                	li	s2,-1
    80004c36:	b755                	j	80004bda <fileread+0x64>
      return -1;
    80004c38:	597d                	li	s2,-1
    80004c3a:	64e2                	ld	s1,24(sp)
    80004c3c:	69a2                	ld	s3,8(sp)
    80004c3e:	bf71                	j	80004bda <fileread+0x64>
    80004c40:	597d                	li	s2,-1
    80004c42:	64e2                	ld	s1,24(sp)
    80004c44:	69a2                	ld	s3,8(sp)
    80004c46:	bf51                	j	80004bda <fileread+0x64>

0000000080004c48 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004c48:	00954783          	lbu	a5,9(a0)
    80004c4c:	12078963          	beqz	a5,80004d7e <filewrite+0x136>
{
    80004c50:	715d                	add	sp,sp,-80
    80004c52:	e486                	sd	ra,72(sp)
    80004c54:	e0a2                	sd	s0,64(sp)
    80004c56:	f84a                	sd	s2,48(sp)
    80004c58:	f052                	sd	s4,32(sp)
    80004c5a:	e85a                	sd	s6,16(sp)
    80004c5c:	0880                	add	s0,sp,80
    80004c5e:	892a                	mv	s2,a0
    80004c60:	8b2e                	mv	s6,a1
    80004c62:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c64:	411c                	lw	a5,0(a0)
    80004c66:	4705                	li	a4,1
    80004c68:	02e78763          	beq	a5,a4,80004c96 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c6c:	470d                	li	a4,3
    80004c6e:	02e78a63          	beq	a5,a4,80004ca2 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c72:	4709                	li	a4,2
    80004c74:	0ee79863          	bne	a5,a4,80004d64 <filewrite+0x11c>
    80004c78:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c7a:	0cc05463          	blez	a2,80004d42 <filewrite+0xfa>
    80004c7e:	fc26                	sd	s1,56(sp)
    80004c80:	ec56                	sd	s5,24(sp)
    80004c82:	e45e                	sd	s7,8(sp)
    80004c84:	e062                	sd	s8,0(sp)
    int i = 0;
    80004c86:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004c88:	6b85                	lui	s7,0x1
    80004c8a:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004c8e:	6c05                	lui	s8,0x1
    80004c90:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004c94:	a851                	j	80004d28 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004c96:	6908                	ld	a0,16(a0)
    80004c98:	00000097          	auipc	ra,0x0
    80004c9c:	248080e7          	jalr	584(ra) # 80004ee0 <pipewrite>
    80004ca0:	a85d                	j	80004d56 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ca2:	02451783          	lh	a5,36(a0)
    80004ca6:	03079693          	sll	a3,a5,0x30
    80004caa:	92c1                	srl	a3,a3,0x30
    80004cac:	4725                	li	a4,9
    80004cae:	0cd76a63          	bltu	a4,a3,80004d82 <filewrite+0x13a>
    80004cb2:	0792                	sll	a5,a5,0x4
    80004cb4:	0001c717          	auipc	a4,0x1c
    80004cb8:	0c470713          	add	a4,a4,196 # 80020d78 <devsw>
    80004cbc:	97ba                	add	a5,a5,a4
    80004cbe:	679c                	ld	a5,8(a5)
    80004cc0:	c3f9                	beqz	a5,80004d86 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004cc2:	4505                	li	a0,1
    80004cc4:	9782                	jalr	a5
    80004cc6:	a841                	j	80004d56 <filewrite+0x10e>
      if(n1 > max)
    80004cc8:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004ccc:	00000097          	auipc	ra,0x0
    80004cd0:	88c080e7          	jalr	-1908(ra) # 80004558 <begin_op>
      ilock(f->ip);
    80004cd4:	01893503          	ld	a0,24(s2)
    80004cd8:	fffff097          	auipc	ra,0xfffff
    80004cdc:	eb2080e7          	jalr	-334(ra) # 80003b8a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ce0:	8756                	mv	a4,s5
    80004ce2:	02092683          	lw	a3,32(s2)
    80004ce6:	01698633          	add	a2,s3,s6
    80004cea:	4585                	li	a1,1
    80004cec:	01893503          	ld	a0,24(s2)
    80004cf0:	fffff097          	auipc	ra,0xfffff
    80004cf4:	262080e7          	jalr	610(ra) # 80003f52 <writei>
    80004cf8:	84aa                	mv	s1,a0
    80004cfa:	00a05763          	blez	a0,80004d08 <filewrite+0xc0>
        f->off += r;
    80004cfe:	02092783          	lw	a5,32(s2)
    80004d02:	9fa9                	addw	a5,a5,a0
    80004d04:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d08:	01893503          	ld	a0,24(s2)
    80004d0c:	fffff097          	auipc	ra,0xfffff
    80004d10:	f44080e7          	jalr	-188(ra) # 80003c50 <iunlock>
      end_op();
    80004d14:	00000097          	auipc	ra,0x0
    80004d18:	8be080e7          	jalr	-1858(ra) # 800045d2 <end_op>

      if(r != n1){
    80004d1c:	029a9563          	bne	s5,s1,80004d46 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004d20:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d24:	0149da63          	bge	s3,s4,80004d38 <filewrite+0xf0>
      int n1 = n - i;
    80004d28:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004d2c:	0004879b          	sext.w	a5,s1
    80004d30:	f8fbdce3          	bge	s7,a5,80004cc8 <filewrite+0x80>
    80004d34:	84e2                	mv	s1,s8
    80004d36:	bf49                	j	80004cc8 <filewrite+0x80>
    80004d38:	74e2                	ld	s1,56(sp)
    80004d3a:	6ae2                	ld	s5,24(sp)
    80004d3c:	6ba2                	ld	s7,8(sp)
    80004d3e:	6c02                	ld	s8,0(sp)
    80004d40:	a039                	j	80004d4e <filewrite+0x106>
    int i = 0;
    80004d42:	4981                	li	s3,0
    80004d44:	a029                	j	80004d4e <filewrite+0x106>
    80004d46:	74e2                	ld	s1,56(sp)
    80004d48:	6ae2                	ld	s5,24(sp)
    80004d4a:	6ba2                	ld	s7,8(sp)
    80004d4c:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004d4e:	033a1e63          	bne	s4,s3,80004d8a <filewrite+0x142>
    80004d52:	8552                	mv	a0,s4
    80004d54:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d56:	60a6                	ld	ra,72(sp)
    80004d58:	6406                	ld	s0,64(sp)
    80004d5a:	7942                	ld	s2,48(sp)
    80004d5c:	7a02                	ld	s4,32(sp)
    80004d5e:	6b42                	ld	s6,16(sp)
    80004d60:	6161                	add	sp,sp,80
    80004d62:	8082                	ret
    80004d64:	fc26                	sd	s1,56(sp)
    80004d66:	f44e                	sd	s3,40(sp)
    80004d68:	ec56                	sd	s5,24(sp)
    80004d6a:	e45e                	sd	s7,8(sp)
    80004d6c:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004d6e:	00004517          	auipc	a0,0x4
    80004d72:	98a50513          	add	a0,a0,-1654 # 800086f8 <__func__.1+0x6f0>
    80004d76:	ffffb097          	auipc	ra,0xffffb
    80004d7a:	7ea080e7          	jalr	2026(ra) # 80000560 <panic>
    return -1;
    80004d7e:	557d                	li	a0,-1
}
    80004d80:	8082                	ret
      return -1;
    80004d82:	557d                	li	a0,-1
    80004d84:	bfc9                	j	80004d56 <filewrite+0x10e>
    80004d86:	557d                	li	a0,-1
    80004d88:	b7f9                	j	80004d56 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004d8a:	557d                	li	a0,-1
    80004d8c:	79a2                	ld	s3,40(sp)
    80004d8e:	b7e1                	j	80004d56 <filewrite+0x10e>

0000000080004d90 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d90:	7179                	add	sp,sp,-48
    80004d92:	f406                	sd	ra,40(sp)
    80004d94:	f022                	sd	s0,32(sp)
    80004d96:	ec26                	sd	s1,24(sp)
    80004d98:	e052                	sd	s4,0(sp)
    80004d9a:	1800                	add	s0,sp,48
    80004d9c:	84aa                	mv	s1,a0
    80004d9e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004da0:	0005b023          	sd	zero,0(a1)
    80004da4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004da8:	00000097          	auipc	ra,0x0
    80004dac:	bbe080e7          	jalr	-1090(ra) # 80004966 <filealloc>
    80004db0:	e088                	sd	a0,0(s1)
    80004db2:	cd49                	beqz	a0,80004e4c <pipealloc+0xbc>
    80004db4:	00000097          	auipc	ra,0x0
    80004db8:	bb2080e7          	jalr	-1102(ra) # 80004966 <filealloc>
    80004dbc:	00aa3023          	sd	a0,0(s4)
    80004dc0:	c141                	beqz	a0,80004e40 <pipealloc+0xb0>
    80004dc2:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004dc4:	ffffc097          	auipc	ra,0xffffc
    80004dc8:	e00080e7          	jalr	-512(ra) # 80000bc4 <kalloc>
    80004dcc:	892a                	mv	s2,a0
    80004dce:	c13d                	beqz	a0,80004e34 <pipealloc+0xa4>
    80004dd0:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004dd2:	4985                	li	s3,1
    80004dd4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004dd8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ddc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004de0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004de4:	00004597          	auipc	a1,0x4
    80004de8:	92458593          	add	a1,a1,-1756 # 80008708 <__func__.1+0x700>
    80004dec:	ffffc097          	auipc	ra,0xffffc
    80004df0:	e84080e7          	jalr	-380(ra) # 80000c70 <initlock>
  (*f0)->type = FD_PIPE;
    80004df4:	609c                	ld	a5,0(s1)
    80004df6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004dfa:	609c                	ld	a5,0(s1)
    80004dfc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e00:	609c                	ld	a5,0(s1)
    80004e02:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e06:	609c                	ld	a5,0(s1)
    80004e08:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e0c:	000a3783          	ld	a5,0(s4)
    80004e10:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e14:	000a3783          	ld	a5,0(s4)
    80004e18:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e1c:	000a3783          	ld	a5,0(s4)
    80004e20:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e24:	000a3783          	ld	a5,0(s4)
    80004e28:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e2c:	4501                	li	a0,0
    80004e2e:	6942                	ld	s2,16(sp)
    80004e30:	69a2                	ld	s3,8(sp)
    80004e32:	a03d                	j	80004e60 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e34:	6088                	ld	a0,0(s1)
    80004e36:	c119                	beqz	a0,80004e3c <pipealloc+0xac>
    80004e38:	6942                	ld	s2,16(sp)
    80004e3a:	a029                	j	80004e44 <pipealloc+0xb4>
    80004e3c:	6942                	ld	s2,16(sp)
    80004e3e:	a039                	j	80004e4c <pipealloc+0xbc>
    80004e40:	6088                	ld	a0,0(s1)
    80004e42:	c50d                	beqz	a0,80004e6c <pipealloc+0xdc>
    fileclose(*f0);
    80004e44:	00000097          	auipc	ra,0x0
    80004e48:	bde080e7          	jalr	-1058(ra) # 80004a22 <fileclose>
  if(*f1)
    80004e4c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e50:	557d                	li	a0,-1
  if(*f1)
    80004e52:	c799                	beqz	a5,80004e60 <pipealloc+0xd0>
    fileclose(*f1);
    80004e54:	853e                	mv	a0,a5
    80004e56:	00000097          	auipc	ra,0x0
    80004e5a:	bcc080e7          	jalr	-1076(ra) # 80004a22 <fileclose>
  return -1;
    80004e5e:	557d                	li	a0,-1
}
    80004e60:	70a2                	ld	ra,40(sp)
    80004e62:	7402                	ld	s0,32(sp)
    80004e64:	64e2                	ld	s1,24(sp)
    80004e66:	6a02                	ld	s4,0(sp)
    80004e68:	6145                	add	sp,sp,48
    80004e6a:	8082                	ret
  return -1;
    80004e6c:	557d                	li	a0,-1
    80004e6e:	bfcd                	j	80004e60 <pipealloc+0xd0>

0000000080004e70 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e70:	1101                	add	sp,sp,-32
    80004e72:	ec06                	sd	ra,24(sp)
    80004e74:	e822                	sd	s0,16(sp)
    80004e76:	e426                	sd	s1,8(sp)
    80004e78:	e04a                	sd	s2,0(sp)
    80004e7a:	1000                	add	s0,sp,32
    80004e7c:	84aa                	mv	s1,a0
    80004e7e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e80:	ffffc097          	auipc	ra,0xffffc
    80004e84:	e80080e7          	jalr	-384(ra) # 80000d00 <acquire>
  if(writable){
    80004e88:	02090d63          	beqz	s2,80004ec2 <pipeclose+0x52>
    pi->writeopen = 0;
    80004e8c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e90:	21848513          	add	a0,s1,536
    80004e94:	ffffd097          	auipc	ra,0xffffd
    80004e98:	588080e7          	jalr	1416(ra) # 8000241c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e9c:	2204b783          	ld	a5,544(s1)
    80004ea0:	eb95                	bnez	a5,80004ed4 <pipeclose+0x64>
    release(&pi->lock);
    80004ea2:	8526                	mv	a0,s1
    80004ea4:	ffffc097          	auipc	ra,0xffffc
    80004ea8:	f10080e7          	jalr	-240(ra) # 80000db4 <release>
    kfree((char*)pi);
    80004eac:	8526                	mv	a0,s1
    80004eae:	ffffc097          	auipc	ra,0xffffc
    80004eb2:	bae080e7          	jalr	-1106(ra) # 80000a5c <kfree>
  } else
    release(&pi->lock);
}
    80004eb6:	60e2                	ld	ra,24(sp)
    80004eb8:	6442                	ld	s0,16(sp)
    80004eba:	64a2                	ld	s1,8(sp)
    80004ebc:	6902                	ld	s2,0(sp)
    80004ebe:	6105                	add	sp,sp,32
    80004ec0:	8082                	ret
    pi->readopen = 0;
    80004ec2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ec6:	21c48513          	add	a0,s1,540
    80004eca:	ffffd097          	auipc	ra,0xffffd
    80004ece:	552080e7          	jalr	1362(ra) # 8000241c <wakeup>
    80004ed2:	b7e9                	j	80004e9c <pipeclose+0x2c>
    release(&pi->lock);
    80004ed4:	8526                	mv	a0,s1
    80004ed6:	ffffc097          	auipc	ra,0xffffc
    80004eda:	ede080e7          	jalr	-290(ra) # 80000db4 <release>
}
    80004ede:	bfe1                	j	80004eb6 <pipeclose+0x46>

0000000080004ee0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ee0:	711d                	add	sp,sp,-96
    80004ee2:	ec86                	sd	ra,88(sp)
    80004ee4:	e8a2                	sd	s0,80(sp)
    80004ee6:	e4a6                	sd	s1,72(sp)
    80004ee8:	e0ca                	sd	s2,64(sp)
    80004eea:	fc4e                	sd	s3,56(sp)
    80004eec:	f852                	sd	s4,48(sp)
    80004eee:	f456                	sd	s5,40(sp)
    80004ef0:	1080                	add	s0,sp,96
    80004ef2:	84aa                	mv	s1,a0
    80004ef4:	8aae                	mv	s5,a1
    80004ef6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ef8:	ffffd097          	auipc	ra,0xffffd
    80004efc:	d0e080e7          	jalr	-754(ra) # 80001c06 <myproc>
    80004f00:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f02:	8526                	mv	a0,s1
    80004f04:	ffffc097          	auipc	ra,0xffffc
    80004f08:	dfc080e7          	jalr	-516(ra) # 80000d00 <acquire>
  while(i < n){
    80004f0c:	0d405863          	blez	s4,80004fdc <pipewrite+0xfc>
    80004f10:	f05a                	sd	s6,32(sp)
    80004f12:	ec5e                	sd	s7,24(sp)
    80004f14:	e862                	sd	s8,16(sp)
  int i = 0;
    80004f16:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f18:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f1a:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f1e:	21c48b93          	add	s7,s1,540
    80004f22:	a089                	j	80004f64 <pipewrite+0x84>
      release(&pi->lock);
    80004f24:	8526                	mv	a0,s1
    80004f26:	ffffc097          	auipc	ra,0xffffc
    80004f2a:	e8e080e7          	jalr	-370(ra) # 80000db4 <release>
      return -1;
    80004f2e:	597d                	li	s2,-1
    80004f30:	7b02                	ld	s6,32(sp)
    80004f32:	6be2                	ld	s7,24(sp)
    80004f34:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f36:	854a                	mv	a0,s2
    80004f38:	60e6                	ld	ra,88(sp)
    80004f3a:	6446                	ld	s0,80(sp)
    80004f3c:	64a6                	ld	s1,72(sp)
    80004f3e:	6906                	ld	s2,64(sp)
    80004f40:	79e2                	ld	s3,56(sp)
    80004f42:	7a42                	ld	s4,48(sp)
    80004f44:	7aa2                	ld	s5,40(sp)
    80004f46:	6125                	add	sp,sp,96
    80004f48:	8082                	ret
      wakeup(&pi->nread);
    80004f4a:	8562                	mv	a0,s8
    80004f4c:	ffffd097          	auipc	ra,0xffffd
    80004f50:	4d0080e7          	jalr	1232(ra) # 8000241c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f54:	85a6                	mv	a1,s1
    80004f56:	855e                	mv	a0,s7
    80004f58:	ffffd097          	auipc	ra,0xffffd
    80004f5c:	460080e7          	jalr	1120(ra) # 800023b8 <sleep>
  while(i < n){
    80004f60:	05495f63          	bge	s2,s4,80004fbe <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80004f64:	2204a783          	lw	a5,544(s1)
    80004f68:	dfd5                	beqz	a5,80004f24 <pipewrite+0x44>
    80004f6a:	854e                	mv	a0,s3
    80004f6c:	ffffd097          	auipc	ra,0xffffd
    80004f70:	6f4080e7          	jalr	1780(ra) # 80002660 <killed>
    80004f74:	f945                	bnez	a0,80004f24 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f76:	2184a783          	lw	a5,536(s1)
    80004f7a:	21c4a703          	lw	a4,540(s1)
    80004f7e:	2007879b          	addw	a5,a5,512
    80004f82:	fcf704e3          	beq	a4,a5,80004f4a <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f86:	4685                	li	a3,1
    80004f88:	01590633          	add	a2,s2,s5
    80004f8c:	faf40593          	add	a1,s0,-81
    80004f90:	0509b503          	ld	a0,80(s3)
    80004f94:	ffffd097          	auipc	ra,0xffffd
    80004f98:	8a2080e7          	jalr	-1886(ra) # 80001836 <copyin>
    80004f9c:	05650263          	beq	a0,s6,80004fe0 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004fa0:	21c4a783          	lw	a5,540(s1)
    80004fa4:	0017871b          	addw	a4,a5,1
    80004fa8:	20e4ae23          	sw	a4,540(s1)
    80004fac:	1ff7f793          	and	a5,a5,511
    80004fb0:	97a6                	add	a5,a5,s1
    80004fb2:	faf44703          	lbu	a4,-81(s0)
    80004fb6:	00e78c23          	sb	a4,24(a5)
      i++;
    80004fba:	2905                	addw	s2,s2,1
    80004fbc:	b755                	j	80004f60 <pipewrite+0x80>
    80004fbe:	7b02                	ld	s6,32(sp)
    80004fc0:	6be2                	ld	s7,24(sp)
    80004fc2:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004fc4:	21848513          	add	a0,s1,536
    80004fc8:	ffffd097          	auipc	ra,0xffffd
    80004fcc:	454080e7          	jalr	1108(ra) # 8000241c <wakeup>
  release(&pi->lock);
    80004fd0:	8526                	mv	a0,s1
    80004fd2:	ffffc097          	auipc	ra,0xffffc
    80004fd6:	de2080e7          	jalr	-542(ra) # 80000db4 <release>
  return i;
    80004fda:	bfb1                	j	80004f36 <pipewrite+0x56>
  int i = 0;
    80004fdc:	4901                	li	s2,0
    80004fde:	b7dd                	j	80004fc4 <pipewrite+0xe4>
    80004fe0:	7b02                	ld	s6,32(sp)
    80004fe2:	6be2                	ld	s7,24(sp)
    80004fe4:	6c42                	ld	s8,16(sp)
    80004fe6:	bff9                	j	80004fc4 <pipewrite+0xe4>

0000000080004fe8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004fe8:	715d                	add	sp,sp,-80
    80004fea:	e486                	sd	ra,72(sp)
    80004fec:	e0a2                	sd	s0,64(sp)
    80004fee:	fc26                	sd	s1,56(sp)
    80004ff0:	f84a                	sd	s2,48(sp)
    80004ff2:	f44e                	sd	s3,40(sp)
    80004ff4:	f052                	sd	s4,32(sp)
    80004ff6:	ec56                	sd	s5,24(sp)
    80004ff8:	0880                	add	s0,sp,80
    80004ffa:	84aa                	mv	s1,a0
    80004ffc:	892e                	mv	s2,a1
    80004ffe:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005000:	ffffd097          	auipc	ra,0xffffd
    80005004:	c06080e7          	jalr	-1018(ra) # 80001c06 <myproc>
    80005008:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000500a:	8526                	mv	a0,s1
    8000500c:	ffffc097          	auipc	ra,0xffffc
    80005010:	cf4080e7          	jalr	-780(ra) # 80000d00 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005014:	2184a703          	lw	a4,536(s1)
    80005018:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000501c:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005020:	02f71963          	bne	a4,a5,80005052 <piperead+0x6a>
    80005024:	2244a783          	lw	a5,548(s1)
    80005028:	cf95                	beqz	a5,80005064 <piperead+0x7c>
    if(killed(pr)){
    8000502a:	8552                	mv	a0,s4
    8000502c:	ffffd097          	auipc	ra,0xffffd
    80005030:	634080e7          	jalr	1588(ra) # 80002660 <killed>
    80005034:	e10d                	bnez	a0,80005056 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005036:	85a6                	mv	a1,s1
    80005038:	854e                	mv	a0,s3
    8000503a:	ffffd097          	auipc	ra,0xffffd
    8000503e:	37e080e7          	jalr	894(ra) # 800023b8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005042:	2184a703          	lw	a4,536(s1)
    80005046:	21c4a783          	lw	a5,540(s1)
    8000504a:	fcf70de3          	beq	a4,a5,80005024 <piperead+0x3c>
    8000504e:	e85a                	sd	s6,16(sp)
    80005050:	a819                	j	80005066 <piperead+0x7e>
    80005052:	e85a                	sd	s6,16(sp)
    80005054:	a809                	j	80005066 <piperead+0x7e>
      release(&pi->lock);
    80005056:	8526                	mv	a0,s1
    80005058:	ffffc097          	auipc	ra,0xffffc
    8000505c:	d5c080e7          	jalr	-676(ra) # 80000db4 <release>
      return -1;
    80005060:	59fd                	li	s3,-1
    80005062:	a0a5                	j	800050ca <piperead+0xe2>
    80005064:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005066:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005068:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000506a:	05505463          	blez	s5,800050b2 <piperead+0xca>
    if(pi->nread == pi->nwrite)
    8000506e:	2184a783          	lw	a5,536(s1)
    80005072:	21c4a703          	lw	a4,540(s1)
    80005076:	02f70e63          	beq	a4,a5,800050b2 <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000507a:	0017871b          	addw	a4,a5,1
    8000507e:	20e4ac23          	sw	a4,536(s1)
    80005082:	1ff7f793          	and	a5,a5,511
    80005086:	97a6                	add	a5,a5,s1
    80005088:	0187c783          	lbu	a5,24(a5)
    8000508c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005090:	4685                	li	a3,1
    80005092:	fbf40613          	add	a2,s0,-65
    80005096:	85ca                	mv	a1,s2
    80005098:	050a3503          	ld	a0,80(s4)
    8000509c:	ffffc097          	auipc	ra,0xffffc
    800050a0:	70e080e7          	jalr	1806(ra) # 800017aa <copyout>
    800050a4:	01650763          	beq	a0,s6,800050b2 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050a8:	2985                	addw	s3,s3,1
    800050aa:	0905                	add	s2,s2,1
    800050ac:	fd3a91e3          	bne	s5,s3,8000506e <piperead+0x86>
    800050b0:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050b2:	21c48513          	add	a0,s1,540
    800050b6:	ffffd097          	auipc	ra,0xffffd
    800050ba:	366080e7          	jalr	870(ra) # 8000241c <wakeup>
  release(&pi->lock);
    800050be:	8526                	mv	a0,s1
    800050c0:	ffffc097          	auipc	ra,0xffffc
    800050c4:	cf4080e7          	jalr	-780(ra) # 80000db4 <release>
    800050c8:	6b42                	ld	s6,16(sp)
  return i;
}
    800050ca:	854e                	mv	a0,s3
    800050cc:	60a6                	ld	ra,72(sp)
    800050ce:	6406                	ld	s0,64(sp)
    800050d0:	74e2                	ld	s1,56(sp)
    800050d2:	7942                	ld	s2,48(sp)
    800050d4:	79a2                	ld	s3,40(sp)
    800050d6:	7a02                	ld	s4,32(sp)
    800050d8:	6ae2                	ld	s5,24(sp)
    800050da:	6161                	add	sp,sp,80
    800050dc:	8082                	ret

00000000800050de <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800050de:	1141                	add	sp,sp,-16
    800050e0:	e422                	sd	s0,8(sp)
    800050e2:	0800                	add	s0,sp,16
    800050e4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800050e6:	8905                	and	a0,a0,1
    800050e8:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800050ea:	8b89                	and	a5,a5,2
    800050ec:	c399                	beqz	a5,800050f2 <flags2perm+0x14>
      perm |= PTE_W;
    800050ee:	00456513          	or	a0,a0,4
    return perm;
}
    800050f2:	6422                	ld	s0,8(sp)
    800050f4:	0141                	add	sp,sp,16
    800050f6:	8082                	ret

00000000800050f8 <exec>:

int
exec(char *path, char **argv)
{
    800050f8:	df010113          	add	sp,sp,-528
    800050fc:	20113423          	sd	ra,520(sp)
    80005100:	20813023          	sd	s0,512(sp)
    80005104:	ffa6                	sd	s1,504(sp)
    80005106:	fbca                	sd	s2,496(sp)
    80005108:	0c00                	add	s0,sp,528
    8000510a:	892a                	mv	s2,a0
    8000510c:	dea43c23          	sd	a0,-520(s0)
    80005110:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005114:	ffffd097          	auipc	ra,0xffffd
    80005118:	af2080e7          	jalr	-1294(ra) # 80001c06 <myproc>
    8000511c:	84aa                	mv	s1,a0

  begin_op();
    8000511e:	fffff097          	auipc	ra,0xfffff
    80005122:	43a080e7          	jalr	1082(ra) # 80004558 <begin_op>

  if((ip = namei(path)) == 0){
    80005126:	854a                	mv	a0,s2
    80005128:	fffff097          	auipc	ra,0xfffff
    8000512c:	230080e7          	jalr	560(ra) # 80004358 <namei>
    80005130:	c135                	beqz	a0,80005194 <exec+0x9c>
    80005132:	f3d2                	sd	s4,480(sp)
    80005134:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005136:	fffff097          	auipc	ra,0xfffff
    8000513a:	a54080e7          	jalr	-1452(ra) # 80003b8a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000513e:	04000713          	li	a4,64
    80005142:	4681                	li	a3,0
    80005144:	e5040613          	add	a2,s0,-432
    80005148:	4581                	li	a1,0
    8000514a:	8552                	mv	a0,s4
    8000514c:	fffff097          	auipc	ra,0xfffff
    80005150:	cf6080e7          	jalr	-778(ra) # 80003e42 <readi>
    80005154:	04000793          	li	a5,64
    80005158:	00f51a63          	bne	a0,a5,8000516c <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000515c:	e5042703          	lw	a4,-432(s0)
    80005160:	464c47b7          	lui	a5,0x464c4
    80005164:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005168:	02f70c63          	beq	a4,a5,800051a0 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000516c:	8552                	mv	a0,s4
    8000516e:	fffff097          	auipc	ra,0xfffff
    80005172:	c82080e7          	jalr	-894(ra) # 80003df0 <iunlockput>
    end_op();
    80005176:	fffff097          	auipc	ra,0xfffff
    8000517a:	45c080e7          	jalr	1116(ra) # 800045d2 <end_op>
  }
  return -1;
    8000517e:	557d                	li	a0,-1
    80005180:	7a1e                	ld	s4,480(sp)
}
    80005182:	20813083          	ld	ra,520(sp)
    80005186:	20013403          	ld	s0,512(sp)
    8000518a:	74fe                	ld	s1,504(sp)
    8000518c:	795e                	ld	s2,496(sp)
    8000518e:	21010113          	add	sp,sp,528
    80005192:	8082                	ret
    end_op();
    80005194:	fffff097          	auipc	ra,0xfffff
    80005198:	43e080e7          	jalr	1086(ra) # 800045d2 <end_op>
    return -1;
    8000519c:	557d                	li	a0,-1
    8000519e:	b7d5                	j	80005182 <exec+0x8a>
    800051a0:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800051a2:	8526                	mv	a0,s1
    800051a4:	ffffd097          	auipc	ra,0xffffd
    800051a8:	b26080e7          	jalr	-1242(ra) # 80001cca <proc_pagetable>
    800051ac:	8b2a                	mv	s6,a0
    800051ae:	30050f63          	beqz	a0,800054cc <exec+0x3d4>
    800051b2:	f7ce                	sd	s3,488(sp)
    800051b4:	efd6                	sd	s5,472(sp)
    800051b6:	e7de                	sd	s7,456(sp)
    800051b8:	e3e2                	sd	s8,448(sp)
    800051ba:	ff66                	sd	s9,440(sp)
    800051bc:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051be:	e7042d03          	lw	s10,-400(s0)
    800051c2:	e8845783          	lhu	a5,-376(s0)
    800051c6:	14078d63          	beqz	a5,80005320 <exec+0x228>
    800051ca:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051cc:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051ce:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800051d0:	6c85                	lui	s9,0x1
    800051d2:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    800051d6:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800051da:	6a85                	lui	s5,0x1
    800051dc:	a0b5                	j	80005248 <exec+0x150>
      panic("loadseg: address should exist");
    800051de:	00003517          	auipc	a0,0x3
    800051e2:	53250513          	add	a0,a0,1330 # 80008710 <__func__.1+0x708>
    800051e6:	ffffb097          	auipc	ra,0xffffb
    800051ea:	37a080e7          	jalr	890(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    800051ee:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800051f0:	8726                	mv	a4,s1
    800051f2:	012c06bb          	addw	a3,s8,s2
    800051f6:	4581                	li	a1,0
    800051f8:	8552                	mv	a0,s4
    800051fa:	fffff097          	auipc	ra,0xfffff
    800051fe:	c48080e7          	jalr	-952(ra) # 80003e42 <readi>
    80005202:	2501                	sext.w	a0,a0
    80005204:	28a49863          	bne	s1,a0,80005494 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    80005208:	012a893b          	addw	s2,s5,s2
    8000520c:	03397563          	bgeu	s2,s3,80005236 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80005210:	02091593          	sll	a1,s2,0x20
    80005214:	9181                	srl	a1,a1,0x20
    80005216:	95de                	add	a1,a1,s7
    80005218:	855a                	mv	a0,s6
    8000521a:	ffffc097          	auipc	ra,0xffffc
    8000521e:	f64080e7          	jalr	-156(ra) # 8000117e <walkaddr>
    80005222:	862a                	mv	a2,a0
    if(pa == 0)
    80005224:	dd4d                	beqz	a0,800051de <exec+0xe6>
    if(sz - i < PGSIZE)
    80005226:	412984bb          	subw	s1,s3,s2
    8000522a:	0004879b          	sext.w	a5,s1
    8000522e:	fcfcf0e3          	bgeu	s9,a5,800051ee <exec+0xf6>
    80005232:	84d6                	mv	s1,s5
    80005234:	bf6d                	j	800051ee <exec+0xf6>
    sz = sz1;
    80005236:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000523a:	2d85                	addw	s11,s11,1
    8000523c:	038d0d1b          	addw	s10,s10,56
    80005240:	e8845783          	lhu	a5,-376(s0)
    80005244:	08fdd663          	bge	s11,a5,800052d0 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005248:	2d01                	sext.w	s10,s10
    8000524a:	03800713          	li	a4,56
    8000524e:	86ea                	mv	a3,s10
    80005250:	e1840613          	add	a2,s0,-488
    80005254:	4581                	li	a1,0
    80005256:	8552                	mv	a0,s4
    80005258:	fffff097          	auipc	ra,0xfffff
    8000525c:	bea080e7          	jalr	-1046(ra) # 80003e42 <readi>
    80005260:	03800793          	li	a5,56
    80005264:	20f51063          	bne	a0,a5,80005464 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    80005268:	e1842783          	lw	a5,-488(s0)
    8000526c:	4705                	li	a4,1
    8000526e:	fce796e3          	bne	a5,a4,8000523a <exec+0x142>
    if(ph.memsz < ph.filesz)
    80005272:	e4043483          	ld	s1,-448(s0)
    80005276:	e3843783          	ld	a5,-456(s0)
    8000527a:	1ef4e963          	bltu	s1,a5,8000546c <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000527e:	e2843783          	ld	a5,-472(s0)
    80005282:	94be                	add	s1,s1,a5
    80005284:	1ef4e863          	bltu	s1,a5,80005474 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    80005288:	df043703          	ld	a4,-528(s0)
    8000528c:	8ff9                	and	a5,a5,a4
    8000528e:	1e079763          	bnez	a5,8000547c <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005292:	e1c42503          	lw	a0,-484(s0)
    80005296:	00000097          	auipc	ra,0x0
    8000529a:	e48080e7          	jalr	-440(ra) # 800050de <flags2perm>
    8000529e:	86aa                	mv	a3,a0
    800052a0:	8626                	mv	a2,s1
    800052a2:	85ca                	mv	a1,s2
    800052a4:	855a                	mv	a0,s6
    800052a6:	ffffc097          	auipc	ra,0xffffc
    800052aa:	29c080e7          	jalr	668(ra) # 80001542 <uvmalloc>
    800052ae:	e0a43423          	sd	a0,-504(s0)
    800052b2:	1c050963          	beqz	a0,80005484 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052b6:	e2843b83          	ld	s7,-472(s0)
    800052ba:	e2042c03          	lw	s8,-480(s0)
    800052be:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052c2:	00098463          	beqz	s3,800052ca <exec+0x1d2>
    800052c6:	4901                	li	s2,0
    800052c8:	b7a1                	j	80005210 <exec+0x118>
    sz = sz1;
    800052ca:	e0843903          	ld	s2,-504(s0)
    800052ce:	b7b5                	j	8000523a <exec+0x142>
    800052d0:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800052d2:	8552                	mv	a0,s4
    800052d4:	fffff097          	auipc	ra,0xfffff
    800052d8:	b1c080e7          	jalr	-1252(ra) # 80003df0 <iunlockput>
  end_op();
    800052dc:	fffff097          	auipc	ra,0xfffff
    800052e0:	2f6080e7          	jalr	758(ra) # 800045d2 <end_op>
  p = myproc();
    800052e4:	ffffd097          	auipc	ra,0xffffd
    800052e8:	922080e7          	jalr	-1758(ra) # 80001c06 <myproc>
    800052ec:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800052ee:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800052f2:	6985                	lui	s3,0x1
    800052f4:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    800052f6:	99ca                	add	s3,s3,s2
    800052f8:	77fd                	lui	a5,0xfffff
    800052fa:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052fe:	4691                	li	a3,4
    80005300:	6609                	lui	a2,0x2
    80005302:	964e                	add	a2,a2,s3
    80005304:	85ce                	mv	a1,s3
    80005306:	855a                	mv	a0,s6
    80005308:	ffffc097          	auipc	ra,0xffffc
    8000530c:	23a080e7          	jalr	570(ra) # 80001542 <uvmalloc>
    80005310:	892a                	mv	s2,a0
    80005312:	e0a43423          	sd	a0,-504(s0)
    80005316:	e519                	bnez	a0,80005324 <exec+0x22c>
  if(pagetable)
    80005318:	e1343423          	sd	s3,-504(s0)
    8000531c:	4a01                	li	s4,0
    8000531e:	aaa5                	j	80005496 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005320:	4901                	li	s2,0
    80005322:	bf45                	j	800052d2 <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005324:	75f9                	lui	a1,0xffffe
    80005326:	95aa                	add	a1,a1,a0
    80005328:	855a                	mv	a0,s6
    8000532a:	ffffc097          	auipc	ra,0xffffc
    8000532e:	44e080e7          	jalr	1102(ra) # 80001778 <uvmclear>
  stackbase = sp - PGSIZE;
    80005332:	7bfd                	lui	s7,0xfffff
    80005334:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005336:	e0043783          	ld	a5,-512(s0)
    8000533a:	6388                	ld	a0,0(a5)
    8000533c:	c52d                	beqz	a0,800053a6 <exec+0x2ae>
    8000533e:	e9040993          	add	s3,s0,-368
    80005342:	f9040c13          	add	s8,s0,-112
    80005346:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005348:	ffffc097          	auipc	ra,0xffffc
    8000534c:	c28080e7          	jalr	-984(ra) # 80000f70 <strlen>
    80005350:	0015079b          	addw	a5,a0,1
    80005354:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005358:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    8000535c:	13796863          	bltu	s2,s7,8000548c <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005360:	e0043d03          	ld	s10,-512(s0)
    80005364:	000d3a03          	ld	s4,0(s10)
    80005368:	8552                	mv	a0,s4
    8000536a:	ffffc097          	auipc	ra,0xffffc
    8000536e:	c06080e7          	jalr	-1018(ra) # 80000f70 <strlen>
    80005372:	0015069b          	addw	a3,a0,1
    80005376:	8652                	mv	a2,s4
    80005378:	85ca                	mv	a1,s2
    8000537a:	855a                	mv	a0,s6
    8000537c:	ffffc097          	auipc	ra,0xffffc
    80005380:	42e080e7          	jalr	1070(ra) # 800017aa <copyout>
    80005384:	10054663          	bltz	a0,80005490 <exec+0x398>
    ustack[argc] = sp;
    80005388:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000538c:	0485                	add	s1,s1,1
    8000538e:	008d0793          	add	a5,s10,8
    80005392:	e0f43023          	sd	a5,-512(s0)
    80005396:	008d3503          	ld	a0,8(s10)
    8000539a:	c909                	beqz	a0,800053ac <exec+0x2b4>
    if(argc >= MAXARG)
    8000539c:	09a1                	add	s3,s3,8
    8000539e:	fb8995e3          	bne	s3,s8,80005348 <exec+0x250>
  ip = 0;
    800053a2:	4a01                	li	s4,0
    800053a4:	a8cd                	j	80005496 <exec+0x39e>
  sp = sz;
    800053a6:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800053aa:	4481                	li	s1,0
  ustack[argc] = 0;
    800053ac:	00349793          	sll	a5,s1,0x3
    800053b0:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd080>
    800053b4:	97a2                	add	a5,a5,s0
    800053b6:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800053ba:	00148693          	add	a3,s1,1
    800053be:	068e                	sll	a3,a3,0x3
    800053c0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800053c4:	ff097913          	and	s2,s2,-16
  sz = sz1;
    800053c8:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800053cc:	f57966e3          	bltu	s2,s7,80005318 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800053d0:	e9040613          	add	a2,s0,-368
    800053d4:	85ca                	mv	a1,s2
    800053d6:	855a                	mv	a0,s6
    800053d8:	ffffc097          	auipc	ra,0xffffc
    800053dc:	3d2080e7          	jalr	978(ra) # 800017aa <copyout>
    800053e0:	0e054863          	bltz	a0,800054d0 <exec+0x3d8>
  p->trapframe->a1 = sp;
    800053e4:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800053e8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800053ec:	df843783          	ld	a5,-520(s0)
    800053f0:	0007c703          	lbu	a4,0(a5)
    800053f4:	cf11                	beqz	a4,80005410 <exec+0x318>
    800053f6:	0785                	add	a5,a5,1
    if(*s == '/')
    800053f8:	02f00693          	li	a3,47
    800053fc:	a039                	j	8000540a <exec+0x312>
      last = s+1;
    800053fe:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005402:	0785                	add	a5,a5,1
    80005404:	fff7c703          	lbu	a4,-1(a5)
    80005408:	c701                	beqz	a4,80005410 <exec+0x318>
    if(*s == '/')
    8000540a:	fed71ce3          	bne	a4,a3,80005402 <exec+0x30a>
    8000540e:	bfc5                	j	800053fe <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    80005410:	4641                	li	a2,16
    80005412:	df843583          	ld	a1,-520(s0)
    80005416:	158a8513          	add	a0,s5,344
    8000541a:	ffffc097          	auipc	ra,0xffffc
    8000541e:	b24080e7          	jalr	-1244(ra) # 80000f3e <safestrcpy>
  oldpagetable = p->pagetable;
    80005422:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005426:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000542a:	e0843783          	ld	a5,-504(s0)
    8000542e:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005432:	058ab783          	ld	a5,88(s5)
    80005436:	e6843703          	ld	a4,-408(s0)
    8000543a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000543c:	058ab783          	ld	a5,88(s5)
    80005440:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005444:	85e6                	mv	a1,s9
    80005446:	ffffd097          	auipc	ra,0xffffd
    8000544a:	920080e7          	jalr	-1760(ra) # 80001d66 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000544e:	0004851b          	sext.w	a0,s1
    80005452:	79be                	ld	s3,488(sp)
    80005454:	7a1e                	ld	s4,480(sp)
    80005456:	6afe                	ld	s5,472(sp)
    80005458:	6b5e                	ld	s6,464(sp)
    8000545a:	6bbe                	ld	s7,456(sp)
    8000545c:	6c1e                	ld	s8,448(sp)
    8000545e:	7cfa                	ld	s9,440(sp)
    80005460:	7d5a                	ld	s10,432(sp)
    80005462:	b305                	j	80005182 <exec+0x8a>
    80005464:	e1243423          	sd	s2,-504(s0)
    80005468:	7dba                	ld	s11,424(sp)
    8000546a:	a035                	j	80005496 <exec+0x39e>
    8000546c:	e1243423          	sd	s2,-504(s0)
    80005470:	7dba                	ld	s11,424(sp)
    80005472:	a015                	j	80005496 <exec+0x39e>
    80005474:	e1243423          	sd	s2,-504(s0)
    80005478:	7dba                	ld	s11,424(sp)
    8000547a:	a831                	j	80005496 <exec+0x39e>
    8000547c:	e1243423          	sd	s2,-504(s0)
    80005480:	7dba                	ld	s11,424(sp)
    80005482:	a811                	j	80005496 <exec+0x39e>
    80005484:	e1243423          	sd	s2,-504(s0)
    80005488:	7dba                	ld	s11,424(sp)
    8000548a:	a031                	j	80005496 <exec+0x39e>
  ip = 0;
    8000548c:	4a01                	li	s4,0
    8000548e:	a021                	j	80005496 <exec+0x39e>
    80005490:	4a01                	li	s4,0
  if(pagetable)
    80005492:	a011                	j	80005496 <exec+0x39e>
    80005494:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005496:	e0843583          	ld	a1,-504(s0)
    8000549a:	855a                	mv	a0,s6
    8000549c:	ffffd097          	auipc	ra,0xffffd
    800054a0:	8ca080e7          	jalr	-1846(ra) # 80001d66 <proc_freepagetable>
  return -1;
    800054a4:	557d                	li	a0,-1
  if(ip){
    800054a6:	000a1b63          	bnez	s4,800054bc <exec+0x3c4>
    800054aa:	79be                	ld	s3,488(sp)
    800054ac:	7a1e                	ld	s4,480(sp)
    800054ae:	6afe                	ld	s5,472(sp)
    800054b0:	6b5e                	ld	s6,464(sp)
    800054b2:	6bbe                	ld	s7,456(sp)
    800054b4:	6c1e                	ld	s8,448(sp)
    800054b6:	7cfa                	ld	s9,440(sp)
    800054b8:	7d5a                	ld	s10,432(sp)
    800054ba:	b1e1                	j	80005182 <exec+0x8a>
    800054bc:	79be                	ld	s3,488(sp)
    800054be:	6afe                	ld	s5,472(sp)
    800054c0:	6b5e                	ld	s6,464(sp)
    800054c2:	6bbe                	ld	s7,456(sp)
    800054c4:	6c1e                	ld	s8,448(sp)
    800054c6:	7cfa                	ld	s9,440(sp)
    800054c8:	7d5a                	ld	s10,432(sp)
    800054ca:	b14d                	j	8000516c <exec+0x74>
    800054cc:	6b5e                	ld	s6,464(sp)
    800054ce:	b979                	j	8000516c <exec+0x74>
  sz = sz1;
    800054d0:	e0843983          	ld	s3,-504(s0)
    800054d4:	b591                	j	80005318 <exec+0x220>

00000000800054d6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054d6:	7179                	add	sp,sp,-48
    800054d8:	f406                	sd	ra,40(sp)
    800054da:	f022                	sd	s0,32(sp)
    800054dc:	ec26                	sd	s1,24(sp)
    800054de:	e84a                	sd	s2,16(sp)
    800054e0:	1800                	add	s0,sp,48
    800054e2:	892e                	mv	s2,a1
    800054e4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054e6:	fdc40593          	add	a1,s0,-36
    800054ea:	ffffe097          	auipc	ra,0xffffe
    800054ee:	a26080e7          	jalr	-1498(ra) # 80002f10 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054f2:	fdc42703          	lw	a4,-36(s0)
    800054f6:	47bd                	li	a5,15
    800054f8:	02e7eb63          	bltu	a5,a4,8000552e <argfd+0x58>
    800054fc:	ffffc097          	auipc	ra,0xffffc
    80005500:	70a080e7          	jalr	1802(ra) # 80001c06 <myproc>
    80005504:	fdc42703          	lw	a4,-36(s0)
    80005508:	01a70793          	add	a5,a4,26
    8000550c:	078e                	sll	a5,a5,0x3
    8000550e:	953e                	add	a0,a0,a5
    80005510:	611c                	ld	a5,0(a0)
    80005512:	c385                	beqz	a5,80005532 <argfd+0x5c>
    return -1;
  if(pfd)
    80005514:	00090463          	beqz	s2,8000551c <argfd+0x46>
    *pfd = fd;
    80005518:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000551c:	4501                	li	a0,0
  if(pf)
    8000551e:	c091                	beqz	s1,80005522 <argfd+0x4c>
    *pf = f;
    80005520:	e09c                	sd	a5,0(s1)
}
    80005522:	70a2                	ld	ra,40(sp)
    80005524:	7402                	ld	s0,32(sp)
    80005526:	64e2                	ld	s1,24(sp)
    80005528:	6942                	ld	s2,16(sp)
    8000552a:	6145                	add	sp,sp,48
    8000552c:	8082                	ret
    return -1;
    8000552e:	557d                	li	a0,-1
    80005530:	bfcd                	j	80005522 <argfd+0x4c>
    80005532:	557d                	li	a0,-1
    80005534:	b7fd                	j	80005522 <argfd+0x4c>

0000000080005536 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005536:	1101                	add	sp,sp,-32
    80005538:	ec06                	sd	ra,24(sp)
    8000553a:	e822                	sd	s0,16(sp)
    8000553c:	e426                	sd	s1,8(sp)
    8000553e:	1000                	add	s0,sp,32
    80005540:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005542:	ffffc097          	auipc	ra,0xffffc
    80005546:	6c4080e7          	jalr	1732(ra) # 80001c06 <myproc>
    8000554a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000554c:	0d050793          	add	a5,a0,208
    80005550:	4501                	li	a0,0
    80005552:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005554:	6398                	ld	a4,0(a5)
    80005556:	cb19                	beqz	a4,8000556c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005558:	2505                	addw	a0,a0,1
    8000555a:	07a1                	add	a5,a5,8
    8000555c:	fed51ce3          	bne	a0,a3,80005554 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005560:	557d                	li	a0,-1
}
    80005562:	60e2                	ld	ra,24(sp)
    80005564:	6442                	ld	s0,16(sp)
    80005566:	64a2                	ld	s1,8(sp)
    80005568:	6105                	add	sp,sp,32
    8000556a:	8082                	ret
      p->ofile[fd] = f;
    8000556c:	01a50793          	add	a5,a0,26
    80005570:	078e                	sll	a5,a5,0x3
    80005572:	963e                	add	a2,a2,a5
    80005574:	e204                	sd	s1,0(a2)
      return fd;
    80005576:	b7f5                	j	80005562 <fdalloc+0x2c>

0000000080005578 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005578:	715d                	add	sp,sp,-80
    8000557a:	e486                	sd	ra,72(sp)
    8000557c:	e0a2                	sd	s0,64(sp)
    8000557e:	fc26                	sd	s1,56(sp)
    80005580:	f84a                	sd	s2,48(sp)
    80005582:	f44e                	sd	s3,40(sp)
    80005584:	ec56                	sd	s5,24(sp)
    80005586:	e85a                	sd	s6,16(sp)
    80005588:	0880                	add	s0,sp,80
    8000558a:	8b2e                	mv	s6,a1
    8000558c:	89b2                	mv	s3,a2
    8000558e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005590:	fb040593          	add	a1,s0,-80
    80005594:	fffff097          	auipc	ra,0xfffff
    80005598:	de2080e7          	jalr	-542(ra) # 80004376 <nameiparent>
    8000559c:	84aa                	mv	s1,a0
    8000559e:	14050e63          	beqz	a0,800056fa <create+0x182>
    return 0;

  ilock(dp);
    800055a2:	ffffe097          	auipc	ra,0xffffe
    800055a6:	5e8080e7          	jalr	1512(ra) # 80003b8a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055aa:	4601                	li	a2,0
    800055ac:	fb040593          	add	a1,s0,-80
    800055b0:	8526                	mv	a0,s1
    800055b2:	fffff097          	auipc	ra,0xfffff
    800055b6:	ae4080e7          	jalr	-1308(ra) # 80004096 <dirlookup>
    800055ba:	8aaa                	mv	s5,a0
    800055bc:	c539                	beqz	a0,8000560a <create+0x92>
    iunlockput(dp);
    800055be:	8526                	mv	a0,s1
    800055c0:	fffff097          	auipc	ra,0xfffff
    800055c4:	830080e7          	jalr	-2000(ra) # 80003df0 <iunlockput>
    ilock(ip);
    800055c8:	8556                	mv	a0,s5
    800055ca:	ffffe097          	auipc	ra,0xffffe
    800055ce:	5c0080e7          	jalr	1472(ra) # 80003b8a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055d2:	4789                	li	a5,2
    800055d4:	02fb1463          	bne	s6,a5,800055fc <create+0x84>
    800055d8:	044ad783          	lhu	a5,68(s5)
    800055dc:	37f9                	addw	a5,a5,-2
    800055de:	17c2                	sll	a5,a5,0x30
    800055e0:	93c1                	srl	a5,a5,0x30
    800055e2:	4705                	li	a4,1
    800055e4:	00f76c63          	bltu	a4,a5,800055fc <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055e8:	8556                	mv	a0,s5
    800055ea:	60a6                	ld	ra,72(sp)
    800055ec:	6406                	ld	s0,64(sp)
    800055ee:	74e2                	ld	s1,56(sp)
    800055f0:	7942                	ld	s2,48(sp)
    800055f2:	79a2                	ld	s3,40(sp)
    800055f4:	6ae2                	ld	s5,24(sp)
    800055f6:	6b42                	ld	s6,16(sp)
    800055f8:	6161                	add	sp,sp,80
    800055fa:	8082                	ret
    iunlockput(ip);
    800055fc:	8556                	mv	a0,s5
    800055fe:	ffffe097          	auipc	ra,0xffffe
    80005602:	7f2080e7          	jalr	2034(ra) # 80003df0 <iunlockput>
    return 0;
    80005606:	4a81                	li	s5,0
    80005608:	b7c5                	j	800055e8 <create+0x70>
    8000560a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    8000560c:	85da                	mv	a1,s6
    8000560e:	4088                	lw	a0,0(s1)
    80005610:	ffffe097          	auipc	ra,0xffffe
    80005614:	3d6080e7          	jalr	982(ra) # 800039e6 <ialloc>
    80005618:	8a2a                	mv	s4,a0
    8000561a:	c531                	beqz	a0,80005666 <create+0xee>
  ilock(ip);
    8000561c:	ffffe097          	auipc	ra,0xffffe
    80005620:	56e080e7          	jalr	1390(ra) # 80003b8a <ilock>
  ip->major = major;
    80005624:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005628:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000562c:	4905                	li	s2,1
    8000562e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005632:	8552                	mv	a0,s4
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	48a080e7          	jalr	1162(ra) # 80003abe <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000563c:	032b0d63          	beq	s6,s2,80005676 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005640:	004a2603          	lw	a2,4(s4)
    80005644:	fb040593          	add	a1,s0,-80
    80005648:	8526                	mv	a0,s1
    8000564a:	fffff097          	auipc	ra,0xfffff
    8000564e:	c5c080e7          	jalr	-932(ra) # 800042a6 <dirlink>
    80005652:	08054163          	bltz	a0,800056d4 <create+0x15c>
  iunlockput(dp);
    80005656:	8526                	mv	a0,s1
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	798080e7          	jalr	1944(ra) # 80003df0 <iunlockput>
  return ip;
    80005660:	8ad2                	mv	s5,s4
    80005662:	7a02                	ld	s4,32(sp)
    80005664:	b751                	j	800055e8 <create+0x70>
    iunlockput(dp);
    80005666:	8526                	mv	a0,s1
    80005668:	ffffe097          	auipc	ra,0xffffe
    8000566c:	788080e7          	jalr	1928(ra) # 80003df0 <iunlockput>
    return 0;
    80005670:	8ad2                	mv	s5,s4
    80005672:	7a02                	ld	s4,32(sp)
    80005674:	bf95                	j	800055e8 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005676:	004a2603          	lw	a2,4(s4)
    8000567a:	00003597          	auipc	a1,0x3
    8000567e:	0b658593          	add	a1,a1,182 # 80008730 <__func__.1+0x728>
    80005682:	8552                	mv	a0,s4
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	c22080e7          	jalr	-990(ra) # 800042a6 <dirlink>
    8000568c:	04054463          	bltz	a0,800056d4 <create+0x15c>
    80005690:	40d0                	lw	a2,4(s1)
    80005692:	00003597          	auipc	a1,0x3
    80005696:	0a658593          	add	a1,a1,166 # 80008738 <__func__.1+0x730>
    8000569a:	8552                	mv	a0,s4
    8000569c:	fffff097          	auipc	ra,0xfffff
    800056a0:	c0a080e7          	jalr	-1014(ra) # 800042a6 <dirlink>
    800056a4:	02054863          	bltz	a0,800056d4 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    800056a8:	004a2603          	lw	a2,4(s4)
    800056ac:	fb040593          	add	a1,s0,-80
    800056b0:	8526                	mv	a0,s1
    800056b2:	fffff097          	auipc	ra,0xfffff
    800056b6:	bf4080e7          	jalr	-1036(ra) # 800042a6 <dirlink>
    800056ba:	00054d63          	bltz	a0,800056d4 <create+0x15c>
    dp->nlink++;  // for ".."
    800056be:	04a4d783          	lhu	a5,74(s1)
    800056c2:	2785                	addw	a5,a5,1
    800056c4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056c8:	8526                	mv	a0,s1
    800056ca:	ffffe097          	auipc	ra,0xffffe
    800056ce:	3f4080e7          	jalr	1012(ra) # 80003abe <iupdate>
    800056d2:	b751                	j	80005656 <create+0xde>
  ip->nlink = 0;
    800056d4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800056d8:	8552                	mv	a0,s4
    800056da:	ffffe097          	auipc	ra,0xffffe
    800056de:	3e4080e7          	jalr	996(ra) # 80003abe <iupdate>
  iunlockput(ip);
    800056e2:	8552                	mv	a0,s4
    800056e4:	ffffe097          	auipc	ra,0xffffe
    800056e8:	70c080e7          	jalr	1804(ra) # 80003df0 <iunlockput>
  iunlockput(dp);
    800056ec:	8526                	mv	a0,s1
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	702080e7          	jalr	1794(ra) # 80003df0 <iunlockput>
  return 0;
    800056f6:	7a02                	ld	s4,32(sp)
    800056f8:	bdc5                	j	800055e8 <create+0x70>
    return 0;
    800056fa:	8aaa                	mv	s5,a0
    800056fc:	b5f5                	j	800055e8 <create+0x70>

00000000800056fe <sys_dup>:
{
    800056fe:	7179                	add	sp,sp,-48
    80005700:	f406                	sd	ra,40(sp)
    80005702:	f022                	sd	s0,32(sp)
    80005704:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005706:	fd840613          	add	a2,s0,-40
    8000570a:	4581                	li	a1,0
    8000570c:	4501                	li	a0,0
    8000570e:	00000097          	auipc	ra,0x0
    80005712:	dc8080e7          	jalr	-568(ra) # 800054d6 <argfd>
    return -1;
    80005716:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005718:	02054763          	bltz	a0,80005746 <sys_dup+0x48>
    8000571c:	ec26                	sd	s1,24(sp)
    8000571e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005720:	fd843903          	ld	s2,-40(s0)
    80005724:	854a                	mv	a0,s2
    80005726:	00000097          	auipc	ra,0x0
    8000572a:	e10080e7          	jalr	-496(ra) # 80005536 <fdalloc>
    8000572e:	84aa                	mv	s1,a0
    return -1;
    80005730:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005732:	00054f63          	bltz	a0,80005750 <sys_dup+0x52>
  filedup(f);
    80005736:	854a                	mv	a0,s2
    80005738:	fffff097          	auipc	ra,0xfffff
    8000573c:	298080e7          	jalr	664(ra) # 800049d0 <filedup>
  return fd;
    80005740:	87a6                	mv	a5,s1
    80005742:	64e2                	ld	s1,24(sp)
    80005744:	6942                	ld	s2,16(sp)
}
    80005746:	853e                	mv	a0,a5
    80005748:	70a2                	ld	ra,40(sp)
    8000574a:	7402                	ld	s0,32(sp)
    8000574c:	6145                	add	sp,sp,48
    8000574e:	8082                	ret
    80005750:	64e2                	ld	s1,24(sp)
    80005752:	6942                	ld	s2,16(sp)
    80005754:	bfcd                	j	80005746 <sys_dup+0x48>

0000000080005756 <sys_read>:
{
    80005756:	7179                	add	sp,sp,-48
    80005758:	f406                	sd	ra,40(sp)
    8000575a:	f022                	sd	s0,32(sp)
    8000575c:	1800                	add	s0,sp,48
  argaddr(1, &p);
    8000575e:	fd840593          	add	a1,s0,-40
    80005762:	4505                	li	a0,1
    80005764:	ffffd097          	auipc	ra,0xffffd
    80005768:	7cc080e7          	jalr	1996(ra) # 80002f30 <argaddr>
  argint(2, &n);
    8000576c:	fe440593          	add	a1,s0,-28
    80005770:	4509                	li	a0,2
    80005772:	ffffd097          	auipc	ra,0xffffd
    80005776:	79e080e7          	jalr	1950(ra) # 80002f10 <argint>
  if(argfd(0, 0, &f) < 0)
    8000577a:	fe840613          	add	a2,s0,-24
    8000577e:	4581                	li	a1,0
    80005780:	4501                	li	a0,0
    80005782:	00000097          	auipc	ra,0x0
    80005786:	d54080e7          	jalr	-684(ra) # 800054d6 <argfd>
    8000578a:	87aa                	mv	a5,a0
    return -1;
    8000578c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000578e:	0007cc63          	bltz	a5,800057a6 <sys_read+0x50>
  return fileread(f, p, n);
    80005792:	fe442603          	lw	a2,-28(s0)
    80005796:	fd843583          	ld	a1,-40(s0)
    8000579a:	fe843503          	ld	a0,-24(s0)
    8000579e:	fffff097          	auipc	ra,0xfffff
    800057a2:	3d8080e7          	jalr	984(ra) # 80004b76 <fileread>
}
    800057a6:	70a2                	ld	ra,40(sp)
    800057a8:	7402                	ld	s0,32(sp)
    800057aa:	6145                	add	sp,sp,48
    800057ac:	8082                	ret

00000000800057ae <sys_write>:
{
    800057ae:	7179                	add	sp,sp,-48
    800057b0:	f406                	sd	ra,40(sp)
    800057b2:	f022                	sd	s0,32(sp)
    800057b4:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800057b6:	fd840593          	add	a1,s0,-40
    800057ba:	4505                	li	a0,1
    800057bc:	ffffd097          	auipc	ra,0xffffd
    800057c0:	774080e7          	jalr	1908(ra) # 80002f30 <argaddr>
  argint(2, &n);
    800057c4:	fe440593          	add	a1,s0,-28
    800057c8:	4509                	li	a0,2
    800057ca:	ffffd097          	auipc	ra,0xffffd
    800057ce:	746080e7          	jalr	1862(ra) # 80002f10 <argint>
  if(argfd(0, 0, &f) < 0)
    800057d2:	fe840613          	add	a2,s0,-24
    800057d6:	4581                	li	a1,0
    800057d8:	4501                	li	a0,0
    800057da:	00000097          	auipc	ra,0x0
    800057de:	cfc080e7          	jalr	-772(ra) # 800054d6 <argfd>
    800057e2:	87aa                	mv	a5,a0
    return -1;
    800057e4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057e6:	0007cc63          	bltz	a5,800057fe <sys_write+0x50>
  return filewrite(f, p, n);
    800057ea:	fe442603          	lw	a2,-28(s0)
    800057ee:	fd843583          	ld	a1,-40(s0)
    800057f2:	fe843503          	ld	a0,-24(s0)
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	452080e7          	jalr	1106(ra) # 80004c48 <filewrite>
}
    800057fe:	70a2                	ld	ra,40(sp)
    80005800:	7402                	ld	s0,32(sp)
    80005802:	6145                	add	sp,sp,48
    80005804:	8082                	ret

0000000080005806 <sys_close>:
{
    80005806:	1101                	add	sp,sp,-32
    80005808:	ec06                	sd	ra,24(sp)
    8000580a:	e822                	sd	s0,16(sp)
    8000580c:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000580e:	fe040613          	add	a2,s0,-32
    80005812:	fec40593          	add	a1,s0,-20
    80005816:	4501                	li	a0,0
    80005818:	00000097          	auipc	ra,0x0
    8000581c:	cbe080e7          	jalr	-834(ra) # 800054d6 <argfd>
    return -1;
    80005820:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005822:	02054463          	bltz	a0,8000584a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005826:	ffffc097          	auipc	ra,0xffffc
    8000582a:	3e0080e7          	jalr	992(ra) # 80001c06 <myproc>
    8000582e:	fec42783          	lw	a5,-20(s0)
    80005832:	07e9                	add	a5,a5,26
    80005834:	078e                	sll	a5,a5,0x3
    80005836:	953e                	add	a0,a0,a5
    80005838:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000583c:	fe043503          	ld	a0,-32(s0)
    80005840:	fffff097          	auipc	ra,0xfffff
    80005844:	1e2080e7          	jalr	482(ra) # 80004a22 <fileclose>
  return 0;
    80005848:	4781                	li	a5,0
}
    8000584a:	853e                	mv	a0,a5
    8000584c:	60e2                	ld	ra,24(sp)
    8000584e:	6442                	ld	s0,16(sp)
    80005850:	6105                	add	sp,sp,32
    80005852:	8082                	ret

0000000080005854 <sys_fstat>:
{
    80005854:	1101                	add	sp,sp,-32
    80005856:	ec06                	sd	ra,24(sp)
    80005858:	e822                	sd	s0,16(sp)
    8000585a:	1000                	add	s0,sp,32
  argaddr(1, &st);
    8000585c:	fe040593          	add	a1,s0,-32
    80005860:	4505                	li	a0,1
    80005862:	ffffd097          	auipc	ra,0xffffd
    80005866:	6ce080e7          	jalr	1742(ra) # 80002f30 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000586a:	fe840613          	add	a2,s0,-24
    8000586e:	4581                	li	a1,0
    80005870:	4501                	li	a0,0
    80005872:	00000097          	auipc	ra,0x0
    80005876:	c64080e7          	jalr	-924(ra) # 800054d6 <argfd>
    8000587a:	87aa                	mv	a5,a0
    return -1;
    8000587c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000587e:	0007ca63          	bltz	a5,80005892 <sys_fstat+0x3e>
  return filestat(f, st);
    80005882:	fe043583          	ld	a1,-32(s0)
    80005886:	fe843503          	ld	a0,-24(s0)
    8000588a:	fffff097          	auipc	ra,0xfffff
    8000588e:	27a080e7          	jalr	634(ra) # 80004b04 <filestat>
}
    80005892:	60e2                	ld	ra,24(sp)
    80005894:	6442                	ld	s0,16(sp)
    80005896:	6105                	add	sp,sp,32
    80005898:	8082                	ret

000000008000589a <sys_link>:
{
    8000589a:	7169                	add	sp,sp,-304
    8000589c:	f606                	sd	ra,296(sp)
    8000589e:	f222                	sd	s0,288(sp)
    800058a0:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058a2:	08000613          	li	a2,128
    800058a6:	ed040593          	add	a1,s0,-304
    800058aa:	4501                	li	a0,0
    800058ac:	ffffd097          	auipc	ra,0xffffd
    800058b0:	6a4080e7          	jalr	1700(ra) # 80002f50 <argstr>
    return -1;
    800058b4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058b6:	12054663          	bltz	a0,800059e2 <sys_link+0x148>
    800058ba:	08000613          	li	a2,128
    800058be:	f5040593          	add	a1,s0,-176
    800058c2:	4505                	li	a0,1
    800058c4:	ffffd097          	auipc	ra,0xffffd
    800058c8:	68c080e7          	jalr	1676(ra) # 80002f50 <argstr>
    return -1;
    800058cc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058ce:	10054a63          	bltz	a0,800059e2 <sys_link+0x148>
    800058d2:	ee26                	sd	s1,280(sp)
  begin_op();
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	c84080e7          	jalr	-892(ra) # 80004558 <begin_op>
  if((ip = namei(old)) == 0){
    800058dc:	ed040513          	add	a0,s0,-304
    800058e0:	fffff097          	auipc	ra,0xfffff
    800058e4:	a78080e7          	jalr	-1416(ra) # 80004358 <namei>
    800058e8:	84aa                	mv	s1,a0
    800058ea:	c949                	beqz	a0,8000597c <sys_link+0xe2>
  ilock(ip);
    800058ec:	ffffe097          	auipc	ra,0xffffe
    800058f0:	29e080e7          	jalr	670(ra) # 80003b8a <ilock>
  if(ip->type == T_DIR){
    800058f4:	04449703          	lh	a4,68(s1)
    800058f8:	4785                	li	a5,1
    800058fa:	08f70863          	beq	a4,a5,8000598a <sys_link+0xf0>
    800058fe:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005900:	04a4d783          	lhu	a5,74(s1)
    80005904:	2785                	addw	a5,a5,1
    80005906:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000590a:	8526                	mv	a0,s1
    8000590c:	ffffe097          	auipc	ra,0xffffe
    80005910:	1b2080e7          	jalr	434(ra) # 80003abe <iupdate>
  iunlock(ip);
    80005914:	8526                	mv	a0,s1
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	33a080e7          	jalr	826(ra) # 80003c50 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000591e:	fd040593          	add	a1,s0,-48
    80005922:	f5040513          	add	a0,s0,-176
    80005926:	fffff097          	auipc	ra,0xfffff
    8000592a:	a50080e7          	jalr	-1456(ra) # 80004376 <nameiparent>
    8000592e:	892a                	mv	s2,a0
    80005930:	cd35                	beqz	a0,800059ac <sys_link+0x112>
  ilock(dp);
    80005932:	ffffe097          	auipc	ra,0xffffe
    80005936:	258080e7          	jalr	600(ra) # 80003b8a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000593a:	00092703          	lw	a4,0(s2)
    8000593e:	409c                	lw	a5,0(s1)
    80005940:	06f71163          	bne	a4,a5,800059a2 <sys_link+0x108>
    80005944:	40d0                	lw	a2,4(s1)
    80005946:	fd040593          	add	a1,s0,-48
    8000594a:	854a                	mv	a0,s2
    8000594c:	fffff097          	auipc	ra,0xfffff
    80005950:	95a080e7          	jalr	-1702(ra) # 800042a6 <dirlink>
    80005954:	04054763          	bltz	a0,800059a2 <sys_link+0x108>
  iunlockput(dp);
    80005958:	854a                	mv	a0,s2
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	496080e7          	jalr	1174(ra) # 80003df0 <iunlockput>
  iput(ip);
    80005962:	8526                	mv	a0,s1
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	3e4080e7          	jalr	996(ra) # 80003d48 <iput>
  end_op();
    8000596c:	fffff097          	auipc	ra,0xfffff
    80005970:	c66080e7          	jalr	-922(ra) # 800045d2 <end_op>
  return 0;
    80005974:	4781                	li	a5,0
    80005976:	64f2                	ld	s1,280(sp)
    80005978:	6952                	ld	s2,272(sp)
    8000597a:	a0a5                	j	800059e2 <sys_link+0x148>
    end_op();
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	c56080e7          	jalr	-938(ra) # 800045d2 <end_op>
    return -1;
    80005984:	57fd                	li	a5,-1
    80005986:	64f2                	ld	s1,280(sp)
    80005988:	a8a9                	j	800059e2 <sys_link+0x148>
    iunlockput(ip);
    8000598a:	8526                	mv	a0,s1
    8000598c:	ffffe097          	auipc	ra,0xffffe
    80005990:	464080e7          	jalr	1124(ra) # 80003df0 <iunlockput>
    end_op();
    80005994:	fffff097          	auipc	ra,0xfffff
    80005998:	c3e080e7          	jalr	-962(ra) # 800045d2 <end_op>
    return -1;
    8000599c:	57fd                	li	a5,-1
    8000599e:	64f2                	ld	s1,280(sp)
    800059a0:	a089                	j	800059e2 <sys_link+0x148>
    iunlockput(dp);
    800059a2:	854a                	mv	a0,s2
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	44c080e7          	jalr	1100(ra) # 80003df0 <iunlockput>
  ilock(ip);
    800059ac:	8526                	mv	a0,s1
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	1dc080e7          	jalr	476(ra) # 80003b8a <ilock>
  ip->nlink--;
    800059b6:	04a4d783          	lhu	a5,74(s1)
    800059ba:	37fd                	addw	a5,a5,-1
    800059bc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059c0:	8526                	mv	a0,s1
    800059c2:	ffffe097          	auipc	ra,0xffffe
    800059c6:	0fc080e7          	jalr	252(ra) # 80003abe <iupdate>
  iunlockput(ip);
    800059ca:	8526                	mv	a0,s1
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	424080e7          	jalr	1060(ra) # 80003df0 <iunlockput>
  end_op();
    800059d4:	fffff097          	auipc	ra,0xfffff
    800059d8:	bfe080e7          	jalr	-1026(ra) # 800045d2 <end_op>
  return -1;
    800059dc:	57fd                	li	a5,-1
    800059de:	64f2                	ld	s1,280(sp)
    800059e0:	6952                	ld	s2,272(sp)
}
    800059e2:	853e                	mv	a0,a5
    800059e4:	70b2                	ld	ra,296(sp)
    800059e6:	7412                	ld	s0,288(sp)
    800059e8:	6155                	add	sp,sp,304
    800059ea:	8082                	ret

00000000800059ec <sys_unlink>:
{
    800059ec:	7151                	add	sp,sp,-240
    800059ee:	f586                	sd	ra,232(sp)
    800059f0:	f1a2                	sd	s0,224(sp)
    800059f2:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059f4:	08000613          	li	a2,128
    800059f8:	f3040593          	add	a1,s0,-208
    800059fc:	4501                	li	a0,0
    800059fe:	ffffd097          	auipc	ra,0xffffd
    80005a02:	552080e7          	jalr	1362(ra) # 80002f50 <argstr>
    80005a06:	1a054a63          	bltz	a0,80005bba <sys_unlink+0x1ce>
    80005a0a:	eda6                	sd	s1,216(sp)
  begin_op();
    80005a0c:	fffff097          	auipc	ra,0xfffff
    80005a10:	b4c080e7          	jalr	-1204(ra) # 80004558 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a14:	fb040593          	add	a1,s0,-80
    80005a18:	f3040513          	add	a0,s0,-208
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	95a080e7          	jalr	-1702(ra) # 80004376 <nameiparent>
    80005a24:	84aa                	mv	s1,a0
    80005a26:	cd71                	beqz	a0,80005b02 <sys_unlink+0x116>
  ilock(dp);
    80005a28:	ffffe097          	auipc	ra,0xffffe
    80005a2c:	162080e7          	jalr	354(ra) # 80003b8a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a30:	00003597          	auipc	a1,0x3
    80005a34:	d0058593          	add	a1,a1,-768 # 80008730 <__func__.1+0x728>
    80005a38:	fb040513          	add	a0,s0,-80
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	640080e7          	jalr	1600(ra) # 8000407c <namecmp>
    80005a44:	14050c63          	beqz	a0,80005b9c <sys_unlink+0x1b0>
    80005a48:	00003597          	auipc	a1,0x3
    80005a4c:	cf058593          	add	a1,a1,-784 # 80008738 <__func__.1+0x730>
    80005a50:	fb040513          	add	a0,s0,-80
    80005a54:	ffffe097          	auipc	ra,0xffffe
    80005a58:	628080e7          	jalr	1576(ra) # 8000407c <namecmp>
    80005a5c:	14050063          	beqz	a0,80005b9c <sys_unlink+0x1b0>
    80005a60:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a62:	f2c40613          	add	a2,s0,-212
    80005a66:	fb040593          	add	a1,s0,-80
    80005a6a:	8526                	mv	a0,s1
    80005a6c:	ffffe097          	auipc	ra,0xffffe
    80005a70:	62a080e7          	jalr	1578(ra) # 80004096 <dirlookup>
    80005a74:	892a                	mv	s2,a0
    80005a76:	12050263          	beqz	a0,80005b9a <sys_unlink+0x1ae>
  ilock(ip);
    80005a7a:	ffffe097          	auipc	ra,0xffffe
    80005a7e:	110080e7          	jalr	272(ra) # 80003b8a <ilock>
  if(ip->nlink < 1)
    80005a82:	04a91783          	lh	a5,74(s2)
    80005a86:	08f05563          	blez	a5,80005b10 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a8a:	04491703          	lh	a4,68(s2)
    80005a8e:	4785                	li	a5,1
    80005a90:	08f70963          	beq	a4,a5,80005b22 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005a94:	4641                	li	a2,16
    80005a96:	4581                	li	a1,0
    80005a98:	fc040513          	add	a0,s0,-64
    80005a9c:	ffffb097          	auipc	ra,0xffffb
    80005aa0:	360080e7          	jalr	864(ra) # 80000dfc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005aa4:	4741                	li	a4,16
    80005aa6:	f2c42683          	lw	a3,-212(s0)
    80005aaa:	fc040613          	add	a2,s0,-64
    80005aae:	4581                	li	a1,0
    80005ab0:	8526                	mv	a0,s1
    80005ab2:	ffffe097          	auipc	ra,0xffffe
    80005ab6:	4a0080e7          	jalr	1184(ra) # 80003f52 <writei>
    80005aba:	47c1                	li	a5,16
    80005abc:	0af51b63          	bne	a0,a5,80005b72 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005ac0:	04491703          	lh	a4,68(s2)
    80005ac4:	4785                	li	a5,1
    80005ac6:	0af70f63          	beq	a4,a5,80005b84 <sys_unlink+0x198>
  iunlockput(dp);
    80005aca:	8526                	mv	a0,s1
    80005acc:	ffffe097          	auipc	ra,0xffffe
    80005ad0:	324080e7          	jalr	804(ra) # 80003df0 <iunlockput>
  ip->nlink--;
    80005ad4:	04a95783          	lhu	a5,74(s2)
    80005ad8:	37fd                	addw	a5,a5,-1
    80005ada:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005ade:	854a                	mv	a0,s2
    80005ae0:	ffffe097          	auipc	ra,0xffffe
    80005ae4:	fde080e7          	jalr	-34(ra) # 80003abe <iupdate>
  iunlockput(ip);
    80005ae8:	854a                	mv	a0,s2
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	306080e7          	jalr	774(ra) # 80003df0 <iunlockput>
  end_op();
    80005af2:	fffff097          	auipc	ra,0xfffff
    80005af6:	ae0080e7          	jalr	-1312(ra) # 800045d2 <end_op>
  return 0;
    80005afa:	4501                	li	a0,0
    80005afc:	64ee                	ld	s1,216(sp)
    80005afe:	694e                	ld	s2,208(sp)
    80005b00:	a84d                	j	80005bb2 <sys_unlink+0x1c6>
    end_op();
    80005b02:	fffff097          	auipc	ra,0xfffff
    80005b06:	ad0080e7          	jalr	-1328(ra) # 800045d2 <end_op>
    return -1;
    80005b0a:	557d                	li	a0,-1
    80005b0c:	64ee                	ld	s1,216(sp)
    80005b0e:	a055                	j	80005bb2 <sys_unlink+0x1c6>
    80005b10:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005b12:	00003517          	auipc	a0,0x3
    80005b16:	c2e50513          	add	a0,a0,-978 # 80008740 <__func__.1+0x738>
    80005b1a:	ffffb097          	auipc	ra,0xffffb
    80005b1e:	a46080e7          	jalr	-1466(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b22:	04c92703          	lw	a4,76(s2)
    80005b26:	02000793          	li	a5,32
    80005b2a:	f6e7f5e3          	bgeu	a5,a4,80005a94 <sys_unlink+0xa8>
    80005b2e:	e5ce                	sd	s3,200(sp)
    80005b30:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b34:	4741                	li	a4,16
    80005b36:	86ce                	mv	a3,s3
    80005b38:	f1840613          	add	a2,s0,-232
    80005b3c:	4581                	li	a1,0
    80005b3e:	854a                	mv	a0,s2
    80005b40:	ffffe097          	auipc	ra,0xffffe
    80005b44:	302080e7          	jalr	770(ra) # 80003e42 <readi>
    80005b48:	47c1                	li	a5,16
    80005b4a:	00f51c63          	bne	a0,a5,80005b62 <sys_unlink+0x176>
    if(de.inum != 0)
    80005b4e:	f1845783          	lhu	a5,-232(s0)
    80005b52:	e7b5                	bnez	a5,80005bbe <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b54:	29c1                	addw	s3,s3,16
    80005b56:	04c92783          	lw	a5,76(s2)
    80005b5a:	fcf9ede3          	bltu	s3,a5,80005b34 <sys_unlink+0x148>
    80005b5e:	69ae                	ld	s3,200(sp)
    80005b60:	bf15                	j	80005a94 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80005b62:	00003517          	auipc	a0,0x3
    80005b66:	bf650513          	add	a0,a0,-1034 # 80008758 <__func__.1+0x750>
    80005b6a:	ffffb097          	auipc	ra,0xffffb
    80005b6e:	9f6080e7          	jalr	-1546(ra) # 80000560 <panic>
    80005b72:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005b74:	00003517          	auipc	a0,0x3
    80005b78:	bfc50513          	add	a0,a0,-1028 # 80008770 <__func__.1+0x768>
    80005b7c:	ffffb097          	auipc	ra,0xffffb
    80005b80:	9e4080e7          	jalr	-1564(ra) # 80000560 <panic>
    dp->nlink--;
    80005b84:	04a4d783          	lhu	a5,74(s1)
    80005b88:	37fd                	addw	a5,a5,-1
    80005b8a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b8e:	8526                	mv	a0,s1
    80005b90:	ffffe097          	auipc	ra,0xffffe
    80005b94:	f2e080e7          	jalr	-210(ra) # 80003abe <iupdate>
    80005b98:	bf0d                	j	80005aca <sys_unlink+0xde>
    80005b9a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005b9c:	8526                	mv	a0,s1
    80005b9e:	ffffe097          	auipc	ra,0xffffe
    80005ba2:	252080e7          	jalr	594(ra) # 80003df0 <iunlockput>
  end_op();
    80005ba6:	fffff097          	auipc	ra,0xfffff
    80005baa:	a2c080e7          	jalr	-1492(ra) # 800045d2 <end_op>
  return -1;
    80005bae:	557d                	li	a0,-1
    80005bb0:	64ee                	ld	s1,216(sp)
}
    80005bb2:	70ae                	ld	ra,232(sp)
    80005bb4:	740e                	ld	s0,224(sp)
    80005bb6:	616d                	add	sp,sp,240
    80005bb8:	8082                	ret
    return -1;
    80005bba:	557d                	li	a0,-1
    80005bbc:	bfdd                	j	80005bb2 <sys_unlink+0x1c6>
    iunlockput(ip);
    80005bbe:	854a                	mv	a0,s2
    80005bc0:	ffffe097          	auipc	ra,0xffffe
    80005bc4:	230080e7          	jalr	560(ra) # 80003df0 <iunlockput>
    goto bad;
    80005bc8:	694e                	ld	s2,208(sp)
    80005bca:	69ae                	ld	s3,200(sp)
    80005bcc:	bfc1                	j	80005b9c <sys_unlink+0x1b0>

0000000080005bce <sys_open>:

uint64
sys_open(void)
{
    80005bce:	7131                	add	sp,sp,-192
    80005bd0:	fd06                	sd	ra,184(sp)
    80005bd2:	f922                	sd	s0,176(sp)
    80005bd4:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005bd6:	f4c40593          	add	a1,s0,-180
    80005bda:	4505                	li	a0,1
    80005bdc:	ffffd097          	auipc	ra,0xffffd
    80005be0:	334080e7          	jalr	820(ra) # 80002f10 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005be4:	08000613          	li	a2,128
    80005be8:	f5040593          	add	a1,s0,-176
    80005bec:	4501                	li	a0,0
    80005bee:	ffffd097          	auipc	ra,0xffffd
    80005bf2:	362080e7          	jalr	866(ra) # 80002f50 <argstr>
    80005bf6:	87aa                	mv	a5,a0
    return -1;
    80005bf8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bfa:	0a07ce63          	bltz	a5,80005cb6 <sys_open+0xe8>
    80005bfe:	f526                	sd	s1,168(sp)

  begin_op();
    80005c00:	fffff097          	auipc	ra,0xfffff
    80005c04:	958080e7          	jalr	-1704(ra) # 80004558 <begin_op>

  if(omode & O_CREATE){
    80005c08:	f4c42783          	lw	a5,-180(s0)
    80005c0c:	2007f793          	and	a5,a5,512
    80005c10:	cfd5                	beqz	a5,80005ccc <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c12:	4681                	li	a3,0
    80005c14:	4601                	li	a2,0
    80005c16:	4589                	li	a1,2
    80005c18:	f5040513          	add	a0,s0,-176
    80005c1c:	00000097          	auipc	ra,0x0
    80005c20:	95c080e7          	jalr	-1700(ra) # 80005578 <create>
    80005c24:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c26:	cd41                	beqz	a0,80005cbe <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c28:	04449703          	lh	a4,68(s1)
    80005c2c:	478d                	li	a5,3
    80005c2e:	00f71763          	bne	a4,a5,80005c3c <sys_open+0x6e>
    80005c32:	0464d703          	lhu	a4,70(s1)
    80005c36:	47a5                	li	a5,9
    80005c38:	0ee7e163          	bltu	a5,a4,80005d1a <sys_open+0x14c>
    80005c3c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c3e:	fffff097          	auipc	ra,0xfffff
    80005c42:	d28080e7          	jalr	-728(ra) # 80004966 <filealloc>
    80005c46:	892a                	mv	s2,a0
    80005c48:	c97d                	beqz	a0,80005d3e <sys_open+0x170>
    80005c4a:	ed4e                	sd	s3,152(sp)
    80005c4c:	00000097          	auipc	ra,0x0
    80005c50:	8ea080e7          	jalr	-1814(ra) # 80005536 <fdalloc>
    80005c54:	89aa                	mv	s3,a0
    80005c56:	0c054e63          	bltz	a0,80005d32 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c5a:	04449703          	lh	a4,68(s1)
    80005c5e:	478d                	li	a5,3
    80005c60:	0ef70c63          	beq	a4,a5,80005d58 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c64:	4789                	li	a5,2
    80005c66:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005c6a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005c6e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005c72:	f4c42783          	lw	a5,-180(s0)
    80005c76:	0017c713          	xor	a4,a5,1
    80005c7a:	8b05                	and	a4,a4,1
    80005c7c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c80:	0037f713          	and	a4,a5,3
    80005c84:	00e03733          	snez	a4,a4
    80005c88:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c8c:	4007f793          	and	a5,a5,1024
    80005c90:	c791                	beqz	a5,80005c9c <sys_open+0xce>
    80005c92:	04449703          	lh	a4,68(s1)
    80005c96:	4789                	li	a5,2
    80005c98:	0cf70763          	beq	a4,a5,80005d66 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005c9c:	8526                	mv	a0,s1
    80005c9e:	ffffe097          	auipc	ra,0xffffe
    80005ca2:	fb2080e7          	jalr	-78(ra) # 80003c50 <iunlock>
  end_op();
    80005ca6:	fffff097          	auipc	ra,0xfffff
    80005caa:	92c080e7          	jalr	-1748(ra) # 800045d2 <end_op>

  return fd;
    80005cae:	854e                	mv	a0,s3
    80005cb0:	74aa                	ld	s1,168(sp)
    80005cb2:	790a                	ld	s2,160(sp)
    80005cb4:	69ea                	ld	s3,152(sp)
}
    80005cb6:	70ea                	ld	ra,184(sp)
    80005cb8:	744a                	ld	s0,176(sp)
    80005cba:	6129                	add	sp,sp,192
    80005cbc:	8082                	ret
      end_op();
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	914080e7          	jalr	-1772(ra) # 800045d2 <end_op>
      return -1;
    80005cc6:	557d                	li	a0,-1
    80005cc8:	74aa                	ld	s1,168(sp)
    80005cca:	b7f5                	j	80005cb6 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005ccc:	f5040513          	add	a0,s0,-176
    80005cd0:	ffffe097          	auipc	ra,0xffffe
    80005cd4:	688080e7          	jalr	1672(ra) # 80004358 <namei>
    80005cd8:	84aa                	mv	s1,a0
    80005cda:	c90d                	beqz	a0,80005d0c <sys_open+0x13e>
    ilock(ip);
    80005cdc:	ffffe097          	auipc	ra,0xffffe
    80005ce0:	eae080e7          	jalr	-338(ra) # 80003b8a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ce4:	04449703          	lh	a4,68(s1)
    80005ce8:	4785                	li	a5,1
    80005cea:	f2f71fe3          	bne	a4,a5,80005c28 <sys_open+0x5a>
    80005cee:	f4c42783          	lw	a5,-180(s0)
    80005cf2:	d7a9                	beqz	a5,80005c3c <sys_open+0x6e>
      iunlockput(ip);
    80005cf4:	8526                	mv	a0,s1
    80005cf6:	ffffe097          	auipc	ra,0xffffe
    80005cfa:	0fa080e7          	jalr	250(ra) # 80003df0 <iunlockput>
      end_op();
    80005cfe:	fffff097          	auipc	ra,0xfffff
    80005d02:	8d4080e7          	jalr	-1836(ra) # 800045d2 <end_op>
      return -1;
    80005d06:	557d                	li	a0,-1
    80005d08:	74aa                	ld	s1,168(sp)
    80005d0a:	b775                	j	80005cb6 <sys_open+0xe8>
      end_op();
    80005d0c:	fffff097          	auipc	ra,0xfffff
    80005d10:	8c6080e7          	jalr	-1850(ra) # 800045d2 <end_op>
      return -1;
    80005d14:	557d                	li	a0,-1
    80005d16:	74aa                	ld	s1,168(sp)
    80005d18:	bf79                	j	80005cb6 <sys_open+0xe8>
    iunlockput(ip);
    80005d1a:	8526                	mv	a0,s1
    80005d1c:	ffffe097          	auipc	ra,0xffffe
    80005d20:	0d4080e7          	jalr	212(ra) # 80003df0 <iunlockput>
    end_op();
    80005d24:	fffff097          	auipc	ra,0xfffff
    80005d28:	8ae080e7          	jalr	-1874(ra) # 800045d2 <end_op>
    return -1;
    80005d2c:	557d                	li	a0,-1
    80005d2e:	74aa                	ld	s1,168(sp)
    80005d30:	b759                	j	80005cb6 <sys_open+0xe8>
      fileclose(f);
    80005d32:	854a                	mv	a0,s2
    80005d34:	fffff097          	auipc	ra,0xfffff
    80005d38:	cee080e7          	jalr	-786(ra) # 80004a22 <fileclose>
    80005d3c:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005d3e:	8526                	mv	a0,s1
    80005d40:	ffffe097          	auipc	ra,0xffffe
    80005d44:	0b0080e7          	jalr	176(ra) # 80003df0 <iunlockput>
    end_op();
    80005d48:	fffff097          	auipc	ra,0xfffff
    80005d4c:	88a080e7          	jalr	-1910(ra) # 800045d2 <end_op>
    return -1;
    80005d50:	557d                	li	a0,-1
    80005d52:	74aa                	ld	s1,168(sp)
    80005d54:	790a                	ld	s2,160(sp)
    80005d56:	b785                	j	80005cb6 <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005d58:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005d5c:	04649783          	lh	a5,70(s1)
    80005d60:	02f91223          	sh	a5,36(s2)
    80005d64:	b729                	j	80005c6e <sys_open+0xa0>
    itrunc(ip);
    80005d66:	8526                	mv	a0,s1
    80005d68:	ffffe097          	auipc	ra,0xffffe
    80005d6c:	f34080e7          	jalr	-204(ra) # 80003c9c <itrunc>
    80005d70:	b735                	j	80005c9c <sys_open+0xce>

0000000080005d72 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d72:	7175                	add	sp,sp,-144
    80005d74:	e506                	sd	ra,136(sp)
    80005d76:	e122                	sd	s0,128(sp)
    80005d78:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d7a:	ffffe097          	auipc	ra,0xffffe
    80005d7e:	7de080e7          	jalr	2014(ra) # 80004558 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d82:	08000613          	li	a2,128
    80005d86:	f7040593          	add	a1,s0,-144
    80005d8a:	4501                	li	a0,0
    80005d8c:	ffffd097          	auipc	ra,0xffffd
    80005d90:	1c4080e7          	jalr	452(ra) # 80002f50 <argstr>
    80005d94:	02054963          	bltz	a0,80005dc6 <sys_mkdir+0x54>
    80005d98:	4681                	li	a3,0
    80005d9a:	4601                	li	a2,0
    80005d9c:	4585                	li	a1,1
    80005d9e:	f7040513          	add	a0,s0,-144
    80005da2:	fffff097          	auipc	ra,0xfffff
    80005da6:	7d6080e7          	jalr	2006(ra) # 80005578 <create>
    80005daa:	cd11                	beqz	a0,80005dc6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dac:	ffffe097          	auipc	ra,0xffffe
    80005db0:	044080e7          	jalr	68(ra) # 80003df0 <iunlockput>
  end_op();
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	81e080e7          	jalr	-2018(ra) # 800045d2 <end_op>
  return 0;
    80005dbc:	4501                	li	a0,0
}
    80005dbe:	60aa                	ld	ra,136(sp)
    80005dc0:	640a                	ld	s0,128(sp)
    80005dc2:	6149                	add	sp,sp,144
    80005dc4:	8082                	ret
    end_op();
    80005dc6:	fffff097          	auipc	ra,0xfffff
    80005dca:	80c080e7          	jalr	-2036(ra) # 800045d2 <end_op>
    return -1;
    80005dce:	557d                	li	a0,-1
    80005dd0:	b7fd                	j	80005dbe <sys_mkdir+0x4c>

0000000080005dd2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005dd2:	7135                	add	sp,sp,-160
    80005dd4:	ed06                	sd	ra,152(sp)
    80005dd6:	e922                	sd	s0,144(sp)
    80005dd8:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005dda:	ffffe097          	auipc	ra,0xffffe
    80005dde:	77e080e7          	jalr	1918(ra) # 80004558 <begin_op>
  argint(1, &major);
    80005de2:	f6c40593          	add	a1,s0,-148
    80005de6:	4505                	li	a0,1
    80005de8:	ffffd097          	auipc	ra,0xffffd
    80005dec:	128080e7          	jalr	296(ra) # 80002f10 <argint>
  argint(2, &minor);
    80005df0:	f6840593          	add	a1,s0,-152
    80005df4:	4509                	li	a0,2
    80005df6:	ffffd097          	auipc	ra,0xffffd
    80005dfa:	11a080e7          	jalr	282(ra) # 80002f10 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dfe:	08000613          	li	a2,128
    80005e02:	f7040593          	add	a1,s0,-144
    80005e06:	4501                	li	a0,0
    80005e08:	ffffd097          	auipc	ra,0xffffd
    80005e0c:	148080e7          	jalr	328(ra) # 80002f50 <argstr>
    80005e10:	02054b63          	bltz	a0,80005e46 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e14:	f6841683          	lh	a3,-152(s0)
    80005e18:	f6c41603          	lh	a2,-148(s0)
    80005e1c:	458d                	li	a1,3
    80005e1e:	f7040513          	add	a0,s0,-144
    80005e22:	fffff097          	auipc	ra,0xfffff
    80005e26:	756080e7          	jalr	1878(ra) # 80005578 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e2a:	cd11                	beqz	a0,80005e46 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e2c:	ffffe097          	auipc	ra,0xffffe
    80005e30:	fc4080e7          	jalr	-60(ra) # 80003df0 <iunlockput>
  end_op();
    80005e34:	ffffe097          	auipc	ra,0xffffe
    80005e38:	79e080e7          	jalr	1950(ra) # 800045d2 <end_op>
  return 0;
    80005e3c:	4501                	li	a0,0
}
    80005e3e:	60ea                	ld	ra,152(sp)
    80005e40:	644a                	ld	s0,144(sp)
    80005e42:	610d                	add	sp,sp,160
    80005e44:	8082                	ret
    end_op();
    80005e46:	ffffe097          	auipc	ra,0xffffe
    80005e4a:	78c080e7          	jalr	1932(ra) # 800045d2 <end_op>
    return -1;
    80005e4e:	557d                	li	a0,-1
    80005e50:	b7fd                	j	80005e3e <sys_mknod+0x6c>

0000000080005e52 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e52:	7135                	add	sp,sp,-160
    80005e54:	ed06                	sd	ra,152(sp)
    80005e56:	e922                	sd	s0,144(sp)
    80005e58:	e14a                	sd	s2,128(sp)
    80005e5a:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e5c:	ffffc097          	auipc	ra,0xffffc
    80005e60:	daa080e7          	jalr	-598(ra) # 80001c06 <myproc>
    80005e64:	892a                	mv	s2,a0
  
  begin_op();
    80005e66:	ffffe097          	auipc	ra,0xffffe
    80005e6a:	6f2080e7          	jalr	1778(ra) # 80004558 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e6e:	08000613          	li	a2,128
    80005e72:	f6040593          	add	a1,s0,-160
    80005e76:	4501                	li	a0,0
    80005e78:	ffffd097          	auipc	ra,0xffffd
    80005e7c:	0d8080e7          	jalr	216(ra) # 80002f50 <argstr>
    80005e80:	04054d63          	bltz	a0,80005eda <sys_chdir+0x88>
    80005e84:	e526                	sd	s1,136(sp)
    80005e86:	f6040513          	add	a0,s0,-160
    80005e8a:	ffffe097          	auipc	ra,0xffffe
    80005e8e:	4ce080e7          	jalr	1230(ra) # 80004358 <namei>
    80005e92:	84aa                	mv	s1,a0
    80005e94:	c131                	beqz	a0,80005ed8 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e96:	ffffe097          	auipc	ra,0xffffe
    80005e9a:	cf4080e7          	jalr	-780(ra) # 80003b8a <ilock>
  if(ip->type != T_DIR){
    80005e9e:	04449703          	lh	a4,68(s1)
    80005ea2:	4785                	li	a5,1
    80005ea4:	04f71163          	bne	a4,a5,80005ee6 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ea8:	8526                	mv	a0,s1
    80005eaa:	ffffe097          	auipc	ra,0xffffe
    80005eae:	da6080e7          	jalr	-602(ra) # 80003c50 <iunlock>
  iput(p->cwd);
    80005eb2:	15093503          	ld	a0,336(s2)
    80005eb6:	ffffe097          	auipc	ra,0xffffe
    80005eba:	e92080e7          	jalr	-366(ra) # 80003d48 <iput>
  end_op();
    80005ebe:	ffffe097          	auipc	ra,0xffffe
    80005ec2:	714080e7          	jalr	1812(ra) # 800045d2 <end_op>
  p->cwd = ip;
    80005ec6:	14993823          	sd	s1,336(s2)
  return 0;
    80005eca:	4501                	li	a0,0
    80005ecc:	64aa                	ld	s1,136(sp)
}
    80005ece:	60ea                	ld	ra,152(sp)
    80005ed0:	644a                	ld	s0,144(sp)
    80005ed2:	690a                	ld	s2,128(sp)
    80005ed4:	610d                	add	sp,sp,160
    80005ed6:	8082                	ret
    80005ed8:	64aa                	ld	s1,136(sp)
    end_op();
    80005eda:	ffffe097          	auipc	ra,0xffffe
    80005ede:	6f8080e7          	jalr	1784(ra) # 800045d2 <end_op>
    return -1;
    80005ee2:	557d                	li	a0,-1
    80005ee4:	b7ed                	j	80005ece <sys_chdir+0x7c>
    iunlockput(ip);
    80005ee6:	8526                	mv	a0,s1
    80005ee8:	ffffe097          	auipc	ra,0xffffe
    80005eec:	f08080e7          	jalr	-248(ra) # 80003df0 <iunlockput>
    end_op();
    80005ef0:	ffffe097          	auipc	ra,0xffffe
    80005ef4:	6e2080e7          	jalr	1762(ra) # 800045d2 <end_op>
    return -1;
    80005ef8:	557d                	li	a0,-1
    80005efa:	64aa                	ld	s1,136(sp)
    80005efc:	bfc9                	j	80005ece <sys_chdir+0x7c>

0000000080005efe <sys_exec>:

uint64
sys_exec(void)
{
    80005efe:	7121                	add	sp,sp,-448
    80005f00:	ff06                	sd	ra,440(sp)
    80005f02:	fb22                	sd	s0,432(sp)
    80005f04:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005f06:	e4840593          	add	a1,s0,-440
    80005f0a:	4505                	li	a0,1
    80005f0c:	ffffd097          	auipc	ra,0xffffd
    80005f10:	024080e7          	jalr	36(ra) # 80002f30 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005f14:	08000613          	li	a2,128
    80005f18:	f5040593          	add	a1,s0,-176
    80005f1c:	4501                	li	a0,0
    80005f1e:	ffffd097          	auipc	ra,0xffffd
    80005f22:	032080e7          	jalr	50(ra) # 80002f50 <argstr>
    80005f26:	87aa                	mv	a5,a0
    return -1;
    80005f28:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005f2a:	0e07c263          	bltz	a5,8000600e <sys_exec+0x110>
    80005f2e:	f726                	sd	s1,424(sp)
    80005f30:	f34a                	sd	s2,416(sp)
    80005f32:	ef4e                	sd	s3,408(sp)
    80005f34:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005f36:	10000613          	li	a2,256
    80005f3a:	4581                	li	a1,0
    80005f3c:	e5040513          	add	a0,s0,-432
    80005f40:	ffffb097          	auipc	ra,0xffffb
    80005f44:	ebc080e7          	jalr	-324(ra) # 80000dfc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f48:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005f4c:	89a6                	mv	s3,s1
    80005f4e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f50:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f54:	00391513          	sll	a0,s2,0x3
    80005f58:	e4040593          	add	a1,s0,-448
    80005f5c:	e4843783          	ld	a5,-440(s0)
    80005f60:	953e                	add	a0,a0,a5
    80005f62:	ffffd097          	auipc	ra,0xffffd
    80005f66:	f10080e7          	jalr	-240(ra) # 80002e72 <fetchaddr>
    80005f6a:	02054a63          	bltz	a0,80005f9e <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005f6e:	e4043783          	ld	a5,-448(s0)
    80005f72:	c7b9                	beqz	a5,80005fc0 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f74:	ffffb097          	auipc	ra,0xffffb
    80005f78:	c50080e7          	jalr	-944(ra) # 80000bc4 <kalloc>
    80005f7c:	85aa                	mv	a1,a0
    80005f7e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f82:	cd11                	beqz	a0,80005f9e <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f84:	6605                	lui	a2,0x1
    80005f86:	e4043503          	ld	a0,-448(s0)
    80005f8a:	ffffd097          	auipc	ra,0xffffd
    80005f8e:	f3a080e7          	jalr	-198(ra) # 80002ec4 <fetchstr>
    80005f92:	00054663          	bltz	a0,80005f9e <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005f96:	0905                	add	s2,s2,1
    80005f98:	09a1                	add	s3,s3,8
    80005f9a:	fb491de3          	bne	s2,s4,80005f54 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f9e:	f5040913          	add	s2,s0,-176
    80005fa2:	6088                	ld	a0,0(s1)
    80005fa4:	c125                	beqz	a0,80006004 <sys_exec+0x106>
    kfree(argv[i]);
    80005fa6:	ffffb097          	auipc	ra,0xffffb
    80005faa:	ab6080e7          	jalr	-1354(ra) # 80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fae:	04a1                	add	s1,s1,8
    80005fb0:	ff2499e3          	bne	s1,s2,80005fa2 <sys_exec+0xa4>
  return -1;
    80005fb4:	557d                	li	a0,-1
    80005fb6:	74ba                	ld	s1,424(sp)
    80005fb8:	791a                	ld	s2,416(sp)
    80005fba:	69fa                	ld	s3,408(sp)
    80005fbc:	6a5a                	ld	s4,400(sp)
    80005fbe:	a881                	j	8000600e <sys_exec+0x110>
      argv[i] = 0;
    80005fc0:	0009079b          	sext.w	a5,s2
    80005fc4:	078e                	sll	a5,a5,0x3
    80005fc6:	fd078793          	add	a5,a5,-48
    80005fca:	97a2                	add	a5,a5,s0
    80005fcc:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005fd0:	e5040593          	add	a1,s0,-432
    80005fd4:	f5040513          	add	a0,s0,-176
    80005fd8:	fffff097          	auipc	ra,0xfffff
    80005fdc:	120080e7          	jalr	288(ra) # 800050f8 <exec>
    80005fe0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fe2:	f5040993          	add	s3,s0,-176
    80005fe6:	6088                	ld	a0,0(s1)
    80005fe8:	c901                	beqz	a0,80005ff8 <sys_exec+0xfa>
    kfree(argv[i]);
    80005fea:	ffffb097          	auipc	ra,0xffffb
    80005fee:	a72080e7          	jalr	-1422(ra) # 80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ff2:	04a1                	add	s1,s1,8
    80005ff4:	ff3499e3          	bne	s1,s3,80005fe6 <sys_exec+0xe8>
  return ret;
    80005ff8:	854a                	mv	a0,s2
    80005ffa:	74ba                	ld	s1,424(sp)
    80005ffc:	791a                	ld	s2,416(sp)
    80005ffe:	69fa                	ld	s3,408(sp)
    80006000:	6a5a                	ld	s4,400(sp)
    80006002:	a031                	j	8000600e <sys_exec+0x110>
  return -1;
    80006004:	557d                	li	a0,-1
    80006006:	74ba                	ld	s1,424(sp)
    80006008:	791a                	ld	s2,416(sp)
    8000600a:	69fa                	ld	s3,408(sp)
    8000600c:	6a5a                	ld	s4,400(sp)
}
    8000600e:	70fa                	ld	ra,440(sp)
    80006010:	745a                	ld	s0,432(sp)
    80006012:	6139                	add	sp,sp,448
    80006014:	8082                	ret

0000000080006016 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006016:	7139                	add	sp,sp,-64
    80006018:	fc06                	sd	ra,56(sp)
    8000601a:	f822                	sd	s0,48(sp)
    8000601c:	f426                	sd	s1,40(sp)
    8000601e:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006020:	ffffc097          	auipc	ra,0xffffc
    80006024:	be6080e7          	jalr	-1050(ra) # 80001c06 <myproc>
    80006028:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000602a:	fd840593          	add	a1,s0,-40
    8000602e:	4501                	li	a0,0
    80006030:	ffffd097          	auipc	ra,0xffffd
    80006034:	f00080e7          	jalr	-256(ra) # 80002f30 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006038:	fc840593          	add	a1,s0,-56
    8000603c:	fd040513          	add	a0,s0,-48
    80006040:	fffff097          	auipc	ra,0xfffff
    80006044:	d50080e7          	jalr	-688(ra) # 80004d90 <pipealloc>
    return -1;
    80006048:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000604a:	0c054463          	bltz	a0,80006112 <sys_pipe+0xfc>
  fd0 = -1;
    8000604e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006052:	fd043503          	ld	a0,-48(s0)
    80006056:	fffff097          	auipc	ra,0xfffff
    8000605a:	4e0080e7          	jalr	1248(ra) # 80005536 <fdalloc>
    8000605e:	fca42223          	sw	a0,-60(s0)
    80006062:	08054b63          	bltz	a0,800060f8 <sys_pipe+0xe2>
    80006066:	fc843503          	ld	a0,-56(s0)
    8000606a:	fffff097          	auipc	ra,0xfffff
    8000606e:	4cc080e7          	jalr	1228(ra) # 80005536 <fdalloc>
    80006072:	fca42023          	sw	a0,-64(s0)
    80006076:	06054863          	bltz	a0,800060e6 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000607a:	4691                	li	a3,4
    8000607c:	fc440613          	add	a2,s0,-60
    80006080:	fd843583          	ld	a1,-40(s0)
    80006084:	68a8                	ld	a0,80(s1)
    80006086:	ffffb097          	auipc	ra,0xffffb
    8000608a:	724080e7          	jalr	1828(ra) # 800017aa <copyout>
    8000608e:	02054063          	bltz	a0,800060ae <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006092:	4691                	li	a3,4
    80006094:	fc040613          	add	a2,s0,-64
    80006098:	fd843583          	ld	a1,-40(s0)
    8000609c:	0591                	add	a1,a1,4
    8000609e:	68a8                	ld	a0,80(s1)
    800060a0:	ffffb097          	auipc	ra,0xffffb
    800060a4:	70a080e7          	jalr	1802(ra) # 800017aa <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800060a8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060aa:	06055463          	bgez	a0,80006112 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800060ae:	fc442783          	lw	a5,-60(s0)
    800060b2:	07e9                	add	a5,a5,26
    800060b4:	078e                	sll	a5,a5,0x3
    800060b6:	97a6                	add	a5,a5,s1
    800060b8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800060bc:	fc042783          	lw	a5,-64(s0)
    800060c0:	07e9                	add	a5,a5,26
    800060c2:	078e                	sll	a5,a5,0x3
    800060c4:	94be                	add	s1,s1,a5
    800060c6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800060ca:	fd043503          	ld	a0,-48(s0)
    800060ce:	fffff097          	auipc	ra,0xfffff
    800060d2:	954080e7          	jalr	-1708(ra) # 80004a22 <fileclose>
    fileclose(wf);
    800060d6:	fc843503          	ld	a0,-56(s0)
    800060da:	fffff097          	auipc	ra,0xfffff
    800060de:	948080e7          	jalr	-1720(ra) # 80004a22 <fileclose>
    return -1;
    800060e2:	57fd                	li	a5,-1
    800060e4:	a03d                	j	80006112 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800060e6:	fc442783          	lw	a5,-60(s0)
    800060ea:	0007c763          	bltz	a5,800060f8 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800060ee:	07e9                	add	a5,a5,26
    800060f0:	078e                	sll	a5,a5,0x3
    800060f2:	97a6                	add	a5,a5,s1
    800060f4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800060f8:	fd043503          	ld	a0,-48(s0)
    800060fc:	fffff097          	auipc	ra,0xfffff
    80006100:	926080e7          	jalr	-1754(ra) # 80004a22 <fileclose>
    fileclose(wf);
    80006104:	fc843503          	ld	a0,-56(s0)
    80006108:	fffff097          	auipc	ra,0xfffff
    8000610c:	91a080e7          	jalr	-1766(ra) # 80004a22 <fileclose>
    return -1;
    80006110:	57fd                	li	a5,-1
}
    80006112:	853e                	mv	a0,a5
    80006114:	70e2                	ld	ra,56(sp)
    80006116:	7442                	ld	s0,48(sp)
    80006118:	74a2                	ld	s1,40(sp)
    8000611a:	6121                	add	sp,sp,64
    8000611c:	8082                	ret
	...

0000000080006120 <kernelvec>:
    80006120:	7111                	add	sp,sp,-256
    80006122:	e006                	sd	ra,0(sp)
    80006124:	e40a                	sd	sp,8(sp)
    80006126:	e80e                	sd	gp,16(sp)
    80006128:	ec12                	sd	tp,24(sp)
    8000612a:	f016                	sd	t0,32(sp)
    8000612c:	f41a                	sd	t1,40(sp)
    8000612e:	f81e                	sd	t2,48(sp)
    80006130:	fc22                	sd	s0,56(sp)
    80006132:	e0a6                	sd	s1,64(sp)
    80006134:	e4aa                	sd	a0,72(sp)
    80006136:	e8ae                	sd	a1,80(sp)
    80006138:	ecb2                	sd	a2,88(sp)
    8000613a:	f0b6                	sd	a3,96(sp)
    8000613c:	f4ba                	sd	a4,104(sp)
    8000613e:	f8be                	sd	a5,112(sp)
    80006140:	fcc2                	sd	a6,120(sp)
    80006142:	e146                	sd	a7,128(sp)
    80006144:	e54a                	sd	s2,136(sp)
    80006146:	e94e                	sd	s3,144(sp)
    80006148:	ed52                	sd	s4,152(sp)
    8000614a:	f156                	sd	s5,160(sp)
    8000614c:	f55a                	sd	s6,168(sp)
    8000614e:	f95e                	sd	s7,176(sp)
    80006150:	fd62                	sd	s8,184(sp)
    80006152:	e1e6                	sd	s9,192(sp)
    80006154:	e5ea                	sd	s10,200(sp)
    80006156:	e9ee                	sd	s11,208(sp)
    80006158:	edf2                	sd	t3,216(sp)
    8000615a:	f1f6                	sd	t4,224(sp)
    8000615c:	f5fa                	sd	t5,232(sp)
    8000615e:	f9fe                	sd	t6,240(sp)
    80006160:	bdffc0ef          	jal	80002d3e <kerneltrap>
    80006164:	6082                	ld	ra,0(sp)
    80006166:	6122                	ld	sp,8(sp)
    80006168:	61c2                	ld	gp,16(sp)
    8000616a:	7282                	ld	t0,32(sp)
    8000616c:	7322                	ld	t1,40(sp)
    8000616e:	73c2                	ld	t2,48(sp)
    80006170:	7462                	ld	s0,56(sp)
    80006172:	6486                	ld	s1,64(sp)
    80006174:	6526                	ld	a0,72(sp)
    80006176:	65c6                	ld	a1,80(sp)
    80006178:	6666                	ld	a2,88(sp)
    8000617a:	7686                	ld	a3,96(sp)
    8000617c:	7726                	ld	a4,104(sp)
    8000617e:	77c6                	ld	a5,112(sp)
    80006180:	7866                	ld	a6,120(sp)
    80006182:	688a                	ld	a7,128(sp)
    80006184:	692a                	ld	s2,136(sp)
    80006186:	69ca                	ld	s3,144(sp)
    80006188:	6a6a                	ld	s4,152(sp)
    8000618a:	7a8a                	ld	s5,160(sp)
    8000618c:	7b2a                	ld	s6,168(sp)
    8000618e:	7bca                	ld	s7,176(sp)
    80006190:	7c6a                	ld	s8,184(sp)
    80006192:	6c8e                	ld	s9,192(sp)
    80006194:	6d2e                	ld	s10,200(sp)
    80006196:	6dce                	ld	s11,208(sp)
    80006198:	6e6e                	ld	t3,216(sp)
    8000619a:	7e8e                	ld	t4,224(sp)
    8000619c:	7f2e                	ld	t5,232(sp)
    8000619e:	7fce                	ld	t6,240(sp)
    800061a0:	6111                	add	sp,sp,256
    800061a2:	10200073          	sret
    800061a6:	00000013          	nop
    800061aa:	00000013          	nop
    800061ae:	0001                	nop

00000000800061b0 <timervec>:
    800061b0:	34051573          	csrrw	a0,mscratch,a0
    800061b4:	e10c                	sd	a1,0(a0)
    800061b6:	e510                	sd	a2,8(a0)
    800061b8:	e914                	sd	a3,16(a0)
    800061ba:	6d0c                	ld	a1,24(a0)
    800061bc:	7110                	ld	a2,32(a0)
    800061be:	6194                	ld	a3,0(a1)
    800061c0:	96b2                	add	a3,a3,a2
    800061c2:	e194                	sd	a3,0(a1)
    800061c4:	4589                	li	a1,2
    800061c6:	14459073          	csrw	sip,a1
    800061ca:	6914                	ld	a3,16(a0)
    800061cc:	6510                	ld	a2,8(a0)
    800061ce:	610c                	ld	a1,0(a0)
    800061d0:	34051573          	csrrw	a0,mscratch,a0
    800061d4:	30200073          	mret
	...

00000000800061da <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800061da:	1141                	add	sp,sp,-16
    800061dc:	e422                	sd	s0,8(sp)
    800061de:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800061e0:	0c0007b7          	lui	a5,0xc000
    800061e4:	4705                	li	a4,1
    800061e6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800061e8:	0c0007b7          	lui	a5,0xc000
    800061ec:	c3d8                	sw	a4,4(a5)
}
    800061ee:	6422                	ld	s0,8(sp)
    800061f0:	0141                	add	sp,sp,16
    800061f2:	8082                	ret

00000000800061f4 <plicinithart>:

void
plicinithart(void)
{
    800061f4:	1141                	add	sp,sp,-16
    800061f6:	e406                	sd	ra,8(sp)
    800061f8:	e022                	sd	s0,0(sp)
    800061fa:	0800                	add	s0,sp,16
  int hart = cpuid();
    800061fc:	ffffc097          	auipc	ra,0xffffc
    80006200:	9de080e7          	jalr	-1570(ra) # 80001bda <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006204:	0085171b          	sllw	a4,a0,0x8
    80006208:	0c0027b7          	lui	a5,0xc002
    8000620c:	97ba                	add	a5,a5,a4
    8000620e:	40200713          	li	a4,1026
    80006212:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006216:	00d5151b          	sllw	a0,a0,0xd
    8000621a:	0c2017b7          	lui	a5,0xc201
    8000621e:	97aa                	add	a5,a5,a0
    80006220:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006224:	60a2                	ld	ra,8(sp)
    80006226:	6402                	ld	s0,0(sp)
    80006228:	0141                	add	sp,sp,16
    8000622a:	8082                	ret

000000008000622c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000622c:	1141                	add	sp,sp,-16
    8000622e:	e406                	sd	ra,8(sp)
    80006230:	e022                	sd	s0,0(sp)
    80006232:	0800                	add	s0,sp,16
  int hart = cpuid();
    80006234:	ffffc097          	auipc	ra,0xffffc
    80006238:	9a6080e7          	jalr	-1626(ra) # 80001bda <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000623c:	00d5151b          	sllw	a0,a0,0xd
    80006240:	0c2017b7          	lui	a5,0xc201
    80006244:	97aa                	add	a5,a5,a0
  return irq;
}
    80006246:	43c8                	lw	a0,4(a5)
    80006248:	60a2                	ld	ra,8(sp)
    8000624a:	6402                	ld	s0,0(sp)
    8000624c:	0141                	add	sp,sp,16
    8000624e:	8082                	ret

0000000080006250 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006250:	1101                	add	sp,sp,-32
    80006252:	ec06                	sd	ra,24(sp)
    80006254:	e822                	sd	s0,16(sp)
    80006256:	e426                	sd	s1,8(sp)
    80006258:	1000                	add	s0,sp,32
    8000625a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000625c:	ffffc097          	auipc	ra,0xffffc
    80006260:	97e080e7          	jalr	-1666(ra) # 80001bda <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006264:	00d5151b          	sllw	a0,a0,0xd
    80006268:	0c2017b7          	lui	a5,0xc201
    8000626c:	97aa                	add	a5,a5,a0
    8000626e:	c3c4                	sw	s1,4(a5)
}
    80006270:	60e2                	ld	ra,24(sp)
    80006272:	6442                	ld	s0,16(sp)
    80006274:	64a2                	ld	s1,8(sp)
    80006276:	6105                	add	sp,sp,32
    80006278:	8082                	ret

000000008000627a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000627a:	1141                	add	sp,sp,-16
    8000627c:	e406                	sd	ra,8(sp)
    8000627e:	e022                	sd	s0,0(sp)
    80006280:	0800                	add	s0,sp,16
  if(i >= NUM)
    80006282:	479d                	li	a5,7
    80006284:	04a7cc63          	blt	a5,a0,800062dc <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006288:	0001c797          	auipc	a5,0x1c
    8000628c:	b4878793          	add	a5,a5,-1208 # 80021dd0 <disk>
    80006290:	97aa                	add	a5,a5,a0
    80006292:	0187c783          	lbu	a5,24(a5)
    80006296:	ebb9                	bnez	a5,800062ec <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006298:	00451693          	sll	a3,a0,0x4
    8000629c:	0001c797          	auipc	a5,0x1c
    800062a0:	b3478793          	add	a5,a5,-1228 # 80021dd0 <disk>
    800062a4:	6398                	ld	a4,0(a5)
    800062a6:	9736                	add	a4,a4,a3
    800062a8:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800062ac:	6398                	ld	a4,0(a5)
    800062ae:	9736                	add	a4,a4,a3
    800062b0:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800062b4:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800062b8:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800062bc:	97aa                	add	a5,a5,a0
    800062be:	4705                	li	a4,1
    800062c0:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800062c4:	0001c517          	auipc	a0,0x1c
    800062c8:	b2450513          	add	a0,a0,-1244 # 80021de8 <disk+0x18>
    800062cc:	ffffc097          	auipc	ra,0xffffc
    800062d0:	150080e7          	jalr	336(ra) # 8000241c <wakeup>
}
    800062d4:	60a2                	ld	ra,8(sp)
    800062d6:	6402                	ld	s0,0(sp)
    800062d8:	0141                	add	sp,sp,16
    800062da:	8082                	ret
    panic("free_desc 1");
    800062dc:	00002517          	auipc	a0,0x2
    800062e0:	4a450513          	add	a0,a0,1188 # 80008780 <__func__.1+0x778>
    800062e4:	ffffa097          	auipc	ra,0xffffa
    800062e8:	27c080e7          	jalr	636(ra) # 80000560 <panic>
    panic("free_desc 2");
    800062ec:	00002517          	auipc	a0,0x2
    800062f0:	4a450513          	add	a0,a0,1188 # 80008790 <__func__.1+0x788>
    800062f4:	ffffa097          	auipc	ra,0xffffa
    800062f8:	26c080e7          	jalr	620(ra) # 80000560 <panic>

00000000800062fc <virtio_disk_init>:
{
    800062fc:	1101                	add	sp,sp,-32
    800062fe:	ec06                	sd	ra,24(sp)
    80006300:	e822                	sd	s0,16(sp)
    80006302:	e426                	sd	s1,8(sp)
    80006304:	e04a                	sd	s2,0(sp)
    80006306:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006308:	00002597          	auipc	a1,0x2
    8000630c:	49858593          	add	a1,a1,1176 # 800087a0 <__func__.1+0x798>
    80006310:	0001c517          	auipc	a0,0x1c
    80006314:	be850513          	add	a0,a0,-1048 # 80021ef8 <disk+0x128>
    80006318:	ffffb097          	auipc	ra,0xffffb
    8000631c:	958080e7          	jalr	-1704(ra) # 80000c70 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006320:	100017b7          	lui	a5,0x10001
    80006324:	4398                	lw	a4,0(a5)
    80006326:	2701                	sext.w	a4,a4
    80006328:	747277b7          	lui	a5,0x74727
    8000632c:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006330:	18f71c63          	bne	a4,a5,800064c8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006334:	100017b7          	lui	a5,0x10001
    80006338:	0791                	add	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    8000633a:	439c                	lw	a5,0(a5)
    8000633c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000633e:	4709                	li	a4,2
    80006340:	18e79463          	bne	a5,a4,800064c8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006344:	100017b7          	lui	a5,0x10001
    80006348:	07a1                	add	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    8000634a:	439c                	lw	a5,0(a5)
    8000634c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000634e:	16e79d63          	bne	a5,a4,800064c8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006352:	100017b7          	lui	a5,0x10001
    80006356:	47d8                	lw	a4,12(a5)
    80006358:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000635a:	554d47b7          	lui	a5,0x554d4
    8000635e:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006362:	16f71363          	bne	a4,a5,800064c8 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006366:	100017b7          	lui	a5,0x10001
    8000636a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000636e:	4705                	li	a4,1
    80006370:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006372:	470d                	li	a4,3
    80006374:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006376:	10001737          	lui	a4,0x10001
    8000637a:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000637c:	c7ffe737          	lui	a4,0xc7ffe
    80006380:	75f70713          	add	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc84f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006384:	8ef9                	and	a3,a3,a4
    80006386:	10001737          	lui	a4,0x10001
    8000638a:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000638c:	472d                	li	a4,11
    8000638e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006390:	07078793          	add	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006394:	439c                	lw	a5,0(a5)
    80006396:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000639a:	8ba1                	and	a5,a5,8
    8000639c:	12078e63          	beqz	a5,800064d8 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800063a0:	100017b7          	lui	a5,0x10001
    800063a4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800063a8:	100017b7          	lui	a5,0x10001
    800063ac:	04478793          	add	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800063b0:	439c                	lw	a5,0(a5)
    800063b2:	2781                	sext.w	a5,a5
    800063b4:	12079a63          	bnez	a5,800064e8 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800063b8:	100017b7          	lui	a5,0x10001
    800063bc:	03478793          	add	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800063c0:	439c                	lw	a5,0(a5)
    800063c2:	2781                	sext.w	a5,a5
  if(max == 0)
    800063c4:	12078a63          	beqz	a5,800064f8 <virtio_disk_init+0x1fc>
  if(max < NUM)
    800063c8:	471d                	li	a4,7
    800063ca:	12f77f63          	bgeu	a4,a5,80006508 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    800063ce:	ffffa097          	auipc	ra,0xffffa
    800063d2:	7f6080e7          	jalr	2038(ra) # 80000bc4 <kalloc>
    800063d6:	0001c497          	auipc	s1,0x1c
    800063da:	9fa48493          	add	s1,s1,-1542 # 80021dd0 <disk>
    800063de:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800063e0:	ffffa097          	auipc	ra,0xffffa
    800063e4:	7e4080e7          	jalr	2020(ra) # 80000bc4 <kalloc>
    800063e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800063ea:	ffffa097          	auipc	ra,0xffffa
    800063ee:	7da080e7          	jalr	2010(ra) # 80000bc4 <kalloc>
    800063f2:	87aa                	mv	a5,a0
    800063f4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800063f6:	6088                	ld	a0,0(s1)
    800063f8:	12050063          	beqz	a0,80006518 <virtio_disk_init+0x21c>
    800063fc:	0001c717          	auipc	a4,0x1c
    80006400:	9dc73703          	ld	a4,-1572(a4) # 80021dd8 <disk+0x8>
    80006404:	10070a63          	beqz	a4,80006518 <virtio_disk_init+0x21c>
    80006408:	10078863          	beqz	a5,80006518 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    8000640c:	6605                	lui	a2,0x1
    8000640e:	4581                	li	a1,0
    80006410:	ffffb097          	auipc	ra,0xffffb
    80006414:	9ec080e7          	jalr	-1556(ra) # 80000dfc <memset>
  memset(disk.avail, 0, PGSIZE);
    80006418:	0001c497          	auipc	s1,0x1c
    8000641c:	9b848493          	add	s1,s1,-1608 # 80021dd0 <disk>
    80006420:	6605                	lui	a2,0x1
    80006422:	4581                	li	a1,0
    80006424:	6488                	ld	a0,8(s1)
    80006426:	ffffb097          	auipc	ra,0xffffb
    8000642a:	9d6080e7          	jalr	-1578(ra) # 80000dfc <memset>
  memset(disk.used, 0, PGSIZE);
    8000642e:	6605                	lui	a2,0x1
    80006430:	4581                	li	a1,0
    80006432:	6888                	ld	a0,16(s1)
    80006434:	ffffb097          	auipc	ra,0xffffb
    80006438:	9c8080e7          	jalr	-1592(ra) # 80000dfc <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000643c:	100017b7          	lui	a5,0x10001
    80006440:	4721                	li	a4,8
    80006442:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006444:	4098                	lw	a4,0(s1)
    80006446:	100017b7          	lui	a5,0x10001
    8000644a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000644e:	40d8                	lw	a4,4(s1)
    80006450:	100017b7          	lui	a5,0x10001
    80006454:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006458:	649c                	ld	a5,8(s1)
    8000645a:	0007869b          	sext.w	a3,a5
    8000645e:	10001737          	lui	a4,0x10001
    80006462:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006466:	9781                	sra	a5,a5,0x20
    80006468:	10001737          	lui	a4,0x10001
    8000646c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006470:	689c                	ld	a5,16(s1)
    80006472:	0007869b          	sext.w	a3,a5
    80006476:	10001737          	lui	a4,0x10001
    8000647a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000647e:	9781                	sra	a5,a5,0x20
    80006480:	10001737          	lui	a4,0x10001
    80006484:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006488:	10001737          	lui	a4,0x10001
    8000648c:	4785                	li	a5,1
    8000648e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006490:	00f48c23          	sb	a5,24(s1)
    80006494:	00f48ca3          	sb	a5,25(s1)
    80006498:	00f48d23          	sb	a5,26(s1)
    8000649c:	00f48da3          	sb	a5,27(s1)
    800064a0:	00f48e23          	sb	a5,28(s1)
    800064a4:	00f48ea3          	sb	a5,29(s1)
    800064a8:	00f48f23          	sb	a5,30(s1)
    800064ac:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800064b0:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800064b4:	100017b7          	lui	a5,0x10001
    800064b8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800064bc:	60e2                	ld	ra,24(sp)
    800064be:	6442                	ld	s0,16(sp)
    800064c0:	64a2                	ld	s1,8(sp)
    800064c2:	6902                	ld	s2,0(sp)
    800064c4:	6105                	add	sp,sp,32
    800064c6:	8082                	ret
    panic("could not find virtio disk");
    800064c8:	00002517          	auipc	a0,0x2
    800064cc:	2e850513          	add	a0,a0,744 # 800087b0 <__func__.1+0x7a8>
    800064d0:	ffffa097          	auipc	ra,0xffffa
    800064d4:	090080e7          	jalr	144(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    800064d8:	00002517          	auipc	a0,0x2
    800064dc:	2f850513          	add	a0,a0,760 # 800087d0 <__func__.1+0x7c8>
    800064e0:	ffffa097          	auipc	ra,0xffffa
    800064e4:	080080e7          	jalr	128(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    800064e8:	00002517          	auipc	a0,0x2
    800064ec:	30850513          	add	a0,a0,776 # 800087f0 <__func__.1+0x7e8>
    800064f0:	ffffa097          	auipc	ra,0xffffa
    800064f4:	070080e7          	jalr	112(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    800064f8:	00002517          	auipc	a0,0x2
    800064fc:	31850513          	add	a0,a0,792 # 80008810 <__func__.1+0x808>
    80006500:	ffffa097          	auipc	ra,0xffffa
    80006504:	060080e7          	jalr	96(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006508:	00002517          	auipc	a0,0x2
    8000650c:	32850513          	add	a0,a0,808 # 80008830 <__func__.1+0x828>
    80006510:	ffffa097          	auipc	ra,0xffffa
    80006514:	050080e7          	jalr	80(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006518:	00002517          	auipc	a0,0x2
    8000651c:	33850513          	add	a0,a0,824 # 80008850 <__func__.1+0x848>
    80006520:	ffffa097          	auipc	ra,0xffffa
    80006524:	040080e7          	jalr	64(ra) # 80000560 <panic>

0000000080006528 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006528:	7159                	add	sp,sp,-112
    8000652a:	f486                	sd	ra,104(sp)
    8000652c:	f0a2                	sd	s0,96(sp)
    8000652e:	eca6                	sd	s1,88(sp)
    80006530:	e8ca                	sd	s2,80(sp)
    80006532:	e4ce                	sd	s3,72(sp)
    80006534:	e0d2                	sd	s4,64(sp)
    80006536:	fc56                	sd	s5,56(sp)
    80006538:	f85a                	sd	s6,48(sp)
    8000653a:	f45e                	sd	s7,40(sp)
    8000653c:	f062                	sd	s8,32(sp)
    8000653e:	ec66                	sd	s9,24(sp)
    80006540:	1880                	add	s0,sp,112
    80006542:	8a2a                	mv	s4,a0
    80006544:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006546:	00c52c83          	lw	s9,12(a0)
    8000654a:	001c9c9b          	sllw	s9,s9,0x1
    8000654e:	1c82                	sll	s9,s9,0x20
    80006550:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006554:	0001c517          	auipc	a0,0x1c
    80006558:	9a450513          	add	a0,a0,-1628 # 80021ef8 <disk+0x128>
    8000655c:	ffffa097          	auipc	ra,0xffffa
    80006560:	7a4080e7          	jalr	1956(ra) # 80000d00 <acquire>
  for(int i = 0; i < 3; i++){
    80006564:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006566:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006568:	0001cb17          	auipc	s6,0x1c
    8000656c:	868b0b13          	add	s6,s6,-1944 # 80021dd0 <disk>
  for(int i = 0; i < 3; i++){
    80006570:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006572:	0001cc17          	auipc	s8,0x1c
    80006576:	986c0c13          	add	s8,s8,-1658 # 80021ef8 <disk+0x128>
    8000657a:	a0ad                	j	800065e4 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    8000657c:	00fb0733          	add	a4,s6,a5
    80006580:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006584:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006586:	0207c563          	bltz	a5,800065b0 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000658a:	2905                	addw	s2,s2,1
    8000658c:	0611                	add	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000658e:	05590f63          	beq	s2,s5,800065ec <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006592:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006594:	0001c717          	auipc	a4,0x1c
    80006598:	83c70713          	add	a4,a4,-1988 # 80021dd0 <disk>
    8000659c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000659e:	01874683          	lbu	a3,24(a4)
    800065a2:	fee9                	bnez	a3,8000657c <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800065a4:	2785                	addw	a5,a5,1
    800065a6:	0705                	add	a4,a4,1
    800065a8:	fe979be3          	bne	a5,s1,8000659e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800065ac:	57fd                	li	a5,-1
    800065ae:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800065b0:	03205163          	blez	s2,800065d2 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    800065b4:	f9042503          	lw	a0,-112(s0)
    800065b8:	00000097          	auipc	ra,0x0
    800065bc:	cc2080e7          	jalr	-830(ra) # 8000627a <free_desc>
      for(int j = 0; j < i; j++)
    800065c0:	4785                	li	a5,1
    800065c2:	0127d863          	bge	a5,s2,800065d2 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    800065c6:	f9442503          	lw	a0,-108(s0)
    800065ca:	00000097          	auipc	ra,0x0
    800065ce:	cb0080e7          	jalr	-848(ra) # 8000627a <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065d2:	85e2                	mv	a1,s8
    800065d4:	0001c517          	auipc	a0,0x1c
    800065d8:	81450513          	add	a0,a0,-2028 # 80021de8 <disk+0x18>
    800065dc:	ffffc097          	auipc	ra,0xffffc
    800065e0:	ddc080e7          	jalr	-548(ra) # 800023b8 <sleep>
  for(int i = 0; i < 3; i++){
    800065e4:	f9040613          	add	a2,s0,-112
    800065e8:	894e                	mv	s2,s3
    800065ea:	b765                	j	80006592 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065ec:	f9042503          	lw	a0,-112(s0)
    800065f0:	00451693          	sll	a3,a0,0x4

  if(write)
    800065f4:	0001b797          	auipc	a5,0x1b
    800065f8:	7dc78793          	add	a5,a5,2012 # 80021dd0 <disk>
    800065fc:	00a50713          	add	a4,a0,10
    80006600:	0712                	sll	a4,a4,0x4
    80006602:	973e                	add	a4,a4,a5
    80006604:	01703633          	snez	a2,s7
    80006608:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000660a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000660e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006612:	6398                	ld	a4,0(a5)
    80006614:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006616:	0a868613          	add	a2,a3,168
    8000661a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000661c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000661e:	6390                	ld	a2,0(a5)
    80006620:	00d605b3          	add	a1,a2,a3
    80006624:	4741                	li	a4,16
    80006626:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006628:	4805                	li	a6,1
    8000662a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000662e:	f9442703          	lw	a4,-108(s0)
    80006632:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006636:	0712                	sll	a4,a4,0x4
    80006638:	963a                	add	a2,a2,a4
    8000663a:	058a0593          	add	a1,s4,88
    8000663e:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006640:	0007b883          	ld	a7,0(a5)
    80006644:	9746                	add	a4,a4,a7
    80006646:	40000613          	li	a2,1024
    8000664a:	c710                	sw	a2,8(a4)
  if(write)
    8000664c:	001bb613          	seqz	a2,s7
    80006650:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006654:	00166613          	or	a2,a2,1
    80006658:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000665c:	f9842583          	lw	a1,-104(s0)
    80006660:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006664:	00250613          	add	a2,a0,2
    80006668:	0612                	sll	a2,a2,0x4
    8000666a:	963e                	add	a2,a2,a5
    8000666c:	577d                	li	a4,-1
    8000666e:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006672:	0592                	sll	a1,a1,0x4
    80006674:	98ae                	add	a7,a7,a1
    80006676:	03068713          	add	a4,a3,48
    8000667a:	973e                	add	a4,a4,a5
    8000667c:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006680:	6398                	ld	a4,0(a5)
    80006682:	972e                	add	a4,a4,a1
    80006684:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006688:	4689                	li	a3,2
    8000668a:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    8000668e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006692:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006696:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000669a:	6794                	ld	a3,8(a5)
    8000669c:	0026d703          	lhu	a4,2(a3)
    800066a0:	8b1d                	and	a4,a4,7
    800066a2:	0706                	sll	a4,a4,0x1
    800066a4:	96ba                	add	a3,a3,a4
    800066a6:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800066aa:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800066ae:	6798                	ld	a4,8(a5)
    800066b0:	00275783          	lhu	a5,2(a4)
    800066b4:	2785                	addw	a5,a5,1
    800066b6:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800066ba:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800066be:	100017b7          	lui	a5,0x10001
    800066c2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800066c6:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800066ca:	0001c917          	auipc	s2,0x1c
    800066ce:	82e90913          	add	s2,s2,-2002 # 80021ef8 <disk+0x128>
  while(b->disk == 1) {
    800066d2:	4485                	li	s1,1
    800066d4:	01079c63          	bne	a5,a6,800066ec <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800066d8:	85ca                	mv	a1,s2
    800066da:	8552                	mv	a0,s4
    800066dc:	ffffc097          	auipc	ra,0xffffc
    800066e0:	cdc080e7          	jalr	-804(ra) # 800023b8 <sleep>
  while(b->disk == 1) {
    800066e4:	004a2783          	lw	a5,4(s4)
    800066e8:	fe9788e3          	beq	a5,s1,800066d8 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800066ec:	f9042903          	lw	s2,-112(s0)
    800066f0:	00290713          	add	a4,s2,2
    800066f4:	0712                	sll	a4,a4,0x4
    800066f6:	0001b797          	auipc	a5,0x1b
    800066fa:	6da78793          	add	a5,a5,1754 # 80021dd0 <disk>
    800066fe:	97ba                	add	a5,a5,a4
    80006700:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006704:	0001b997          	auipc	s3,0x1b
    80006708:	6cc98993          	add	s3,s3,1740 # 80021dd0 <disk>
    8000670c:	00491713          	sll	a4,s2,0x4
    80006710:	0009b783          	ld	a5,0(s3)
    80006714:	97ba                	add	a5,a5,a4
    80006716:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000671a:	854a                	mv	a0,s2
    8000671c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006720:	00000097          	auipc	ra,0x0
    80006724:	b5a080e7          	jalr	-1190(ra) # 8000627a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006728:	8885                	and	s1,s1,1
    8000672a:	f0ed                	bnez	s1,8000670c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000672c:	0001b517          	auipc	a0,0x1b
    80006730:	7cc50513          	add	a0,a0,1996 # 80021ef8 <disk+0x128>
    80006734:	ffffa097          	auipc	ra,0xffffa
    80006738:	680080e7          	jalr	1664(ra) # 80000db4 <release>
}
    8000673c:	70a6                	ld	ra,104(sp)
    8000673e:	7406                	ld	s0,96(sp)
    80006740:	64e6                	ld	s1,88(sp)
    80006742:	6946                	ld	s2,80(sp)
    80006744:	69a6                	ld	s3,72(sp)
    80006746:	6a06                	ld	s4,64(sp)
    80006748:	7ae2                	ld	s5,56(sp)
    8000674a:	7b42                	ld	s6,48(sp)
    8000674c:	7ba2                	ld	s7,40(sp)
    8000674e:	7c02                	ld	s8,32(sp)
    80006750:	6ce2                	ld	s9,24(sp)
    80006752:	6165                	add	sp,sp,112
    80006754:	8082                	ret

0000000080006756 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006756:	1101                	add	sp,sp,-32
    80006758:	ec06                	sd	ra,24(sp)
    8000675a:	e822                	sd	s0,16(sp)
    8000675c:	e426                	sd	s1,8(sp)
    8000675e:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006760:	0001b497          	auipc	s1,0x1b
    80006764:	67048493          	add	s1,s1,1648 # 80021dd0 <disk>
    80006768:	0001b517          	auipc	a0,0x1b
    8000676c:	79050513          	add	a0,a0,1936 # 80021ef8 <disk+0x128>
    80006770:	ffffa097          	auipc	ra,0xffffa
    80006774:	590080e7          	jalr	1424(ra) # 80000d00 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006778:	100017b7          	lui	a5,0x10001
    8000677c:	53b8                	lw	a4,96(a5)
    8000677e:	8b0d                	and	a4,a4,3
    80006780:	100017b7          	lui	a5,0x10001
    80006784:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006786:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000678a:	689c                	ld	a5,16(s1)
    8000678c:	0204d703          	lhu	a4,32(s1)
    80006790:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006794:	04f70863          	beq	a4,a5,800067e4 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006798:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000679c:	6898                	ld	a4,16(s1)
    8000679e:	0204d783          	lhu	a5,32(s1)
    800067a2:	8b9d                	and	a5,a5,7
    800067a4:	078e                	sll	a5,a5,0x3
    800067a6:	97ba                	add	a5,a5,a4
    800067a8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800067aa:	00278713          	add	a4,a5,2
    800067ae:	0712                	sll	a4,a4,0x4
    800067b0:	9726                	add	a4,a4,s1
    800067b2:	01074703          	lbu	a4,16(a4)
    800067b6:	e721                	bnez	a4,800067fe <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800067b8:	0789                	add	a5,a5,2
    800067ba:	0792                	sll	a5,a5,0x4
    800067bc:	97a6                	add	a5,a5,s1
    800067be:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800067c0:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800067c4:	ffffc097          	auipc	ra,0xffffc
    800067c8:	c58080e7          	jalr	-936(ra) # 8000241c <wakeup>

    disk.used_idx += 1;
    800067cc:	0204d783          	lhu	a5,32(s1)
    800067d0:	2785                	addw	a5,a5,1
    800067d2:	17c2                	sll	a5,a5,0x30
    800067d4:	93c1                	srl	a5,a5,0x30
    800067d6:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800067da:	6898                	ld	a4,16(s1)
    800067dc:	00275703          	lhu	a4,2(a4)
    800067e0:	faf71ce3          	bne	a4,a5,80006798 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    800067e4:	0001b517          	auipc	a0,0x1b
    800067e8:	71450513          	add	a0,a0,1812 # 80021ef8 <disk+0x128>
    800067ec:	ffffa097          	auipc	ra,0xffffa
    800067f0:	5c8080e7          	jalr	1480(ra) # 80000db4 <release>
}
    800067f4:	60e2                	ld	ra,24(sp)
    800067f6:	6442                	ld	s0,16(sp)
    800067f8:	64a2                	ld	s1,8(sp)
    800067fa:	6105                	add	sp,sp,32
    800067fc:	8082                	ret
      panic("virtio_disk_intr status");
    800067fe:	00002517          	auipc	a0,0x2
    80006802:	06a50513          	add	a0,a0,106 # 80008868 <__func__.1+0x860>
    80006806:	ffffa097          	auipc	ra,0xffffa
    8000680a:	d5a080e7          	jalr	-678(ra) # 80000560 <panic>
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
