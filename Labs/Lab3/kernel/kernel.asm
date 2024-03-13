
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	b9010113          	add	sp,sp,-1136 # 80008b90 <stack0>
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
    80000054:	a0070713          	add	a4,a4,-1536 # 80008a50 <timer_scratch>
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
    80000066:	1ae78793          	add	a5,a5,430 # 80006210 <timervec>
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
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc93f>
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
    80000190:	a0450513          	add	a0,a0,-1532 # 80010b90 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	b6c080e7          	jalr	-1172(ra) # 80000d00 <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	9f448493          	add	s1,s1,-1548 # 80010b90 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a4:	00011917          	auipc	s2,0x11
    800001a8:	a8490913          	add	s2,s2,-1404 # 80010c28 <cons+0x98>
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
    800001ec:	9a870713          	add	a4,a4,-1624 # 80010b90 <cons>
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
    8000023a:	95a50513          	add	a0,a0,-1702 # 80010b90 <cons>
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
    80000268:	9cf72223          	sw	a5,-1596(a4) # 80010c28 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
    release(&cons.lock);
    8000027a:	00011517          	auipc	a0,0x11
    8000027e:	91650513          	add	a0,a0,-1770 # 80010b90 <cons>
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
    800002e6:	8ae50513          	add	a0,a0,-1874 # 80010b90 <cons>
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
    80000314:	88050513          	add	a0,a0,-1920 # 80010b90 <cons>
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
    80000336:	85e70713          	add	a4,a4,-1954 # 80010b90 <cons>
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
    80000360:	83478793          	add	a5,a5,-1996 # 80010b90 <cons>
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
    8000038e:	89e7a783          	lw	a5,-1890(a5) # 80010c28 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
        while (cons.e != cons.w &&
    800003a0:	00010717          	auipc	a4,0x10
    800003a4:	7f070713          	add	a4,a4,2032 # 80010b90 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003b0:	00010497          	auipc	s1,0x10
    800003b4:	7e048493          	add	s1,s1,2016 # 80010b90 <cons>
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
    800003fa:	79a70713          	add	a4,a4,1946 # 80010b90 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
            cons.e--;
    8000040a:	37fd                	addw	a5,a5,-1
    8000040c:	00011717          	auipc	a4,0x11
    80000410:	82f72223          	sw	a5,-2012(a4) # 80010c30 <cons+0xa0>
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
    80000436:	75e78793          	add	a5,a5,1886 # 80010b90 <cons>
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
    8000045a:	7cc7ab23          	sw	a2,2006(a5) # 80010c2c <cons+0x9c>
                wakeup(&cons.r);
    8000045e:	00010517          	auipc	a0,0x10
    80000462:	7ca50513          	add	a0,a0,1994 # 80010c28 <cons+0x98>
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
    80000484:	71050513          	add	a0,a0,1808 # 80010b90 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	7e8080e7          	jalr	2024(ra) # 80000c70 <initlock>

    uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	366080e7          	jalr	870(ra) # 800007f6 <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000498:	00021797          	auipc	a5,0x21
    8000049c:	89078793          	add	a5,a5,-1904 # 80020d28 <devsw>
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
    800004da:	36a60613          	add	a2,a2,874 # 80008840 <digits>
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
    80000582:	6c07a923          	sw	zero,1746(a5) # 80010c50 <pr+0x18>
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
    800005b6:	44f72723          	sw	a5,1102(a4) # 80008a00 <panicked>
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
    800005e0:	674d2d03          	lw	s10,1652(s10) # 80010c50 <pr+0x18>
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
    8000061e:	226a8a93          	add	s5,s5,550 # 80008840 <digits>
        switch (c)
    80000622:	07300c13          	li	s8,115
    80000626:	06400d93          	li	s11,100
    8000062a:	a0b1                	j	80000676 <printf+0xba>
        acquire(&pr.lock);
    8000062c:	00010517          	auipc	a0,0x10
    80000630:	60c50513          	add	a0,a0,1548 # 80010c38 <pr>
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
    800007b6:	48650513          	add	a0,a0,1158 # 80010c38 <pr>
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
    800007d2:	46a48493          	add	s1,s1,1130 # 80010c38 <pr>
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
    8000083e:	41e50513          	add	a0,a0,1054 # 80010c58 <uart_tx_lock>
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
    8000086a:	19a7a783          	lw	a5,410(a5) # 80008a00 <panicked>
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
    800008a4:	1687b783          	ld	a5,360(a5) # 80008a08 <uart_tx_r>
    800008a8:	00008717          	auipc	a4,0x8
    800008ac:	16873703          	ld	a4,360(a4) # 80008a10 <uart_tx_w>
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
    800008d2:	38aa8a93          	add	s5,s5,906 # 80010c58 <uart_tx_lock>
    uart_tx_r += 1;
    800008d6:	00008497          	auipc	s1,0x8
    800008da:	13248493          	add	s1,s1,306 # 80008a08 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008de:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e2:	00008997          	auipc	s3,0x8
    800008e6:	12e98993          	add	s3,s3,302 # 80008a10 <uart_tx_w>
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
    80000946:	31650513          	add	a0,a0,790 # 80010c58 <uart_tx_lock>
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	3b6080e7          	jalr	950(ra) # 80000d00 <acquire>
  if(panicked){
    80000952:	00008797          	auipc	a5,0x8
    80000956:	0ae7a783          	lw	a5,174(a5) # 80008a00 <panicked>
    8000095a:	e7c9                	bnez	a5,800009e4 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000095c:	00008717          	auipc	a4,0x8
    80000960:	0b473703          	ld	a4,180(a4) # 80008a10 <uart_tx_w>
    80000964:	00008797          	auipc	a5,0x8
    80000968:	0a47b783          	ld	a5,164(a5) # 80008a08 <uart_tx_r>
    8000096c:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000970:	00010997          	auipc	s3,0x10
    80000974:	2e898993          	add	s3,s3,744 # 80010c58 <uart_tx_lock>
    80000978:	00008497          	auipc	s1,0x8
    8000097c:	09048493          	add	s1,s1,144 # 80008a08 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000980:	00008917          	auipc	s2,0x8
    80000984:	09090913          	add	s2,s2,144 # 80008a10 <uart_tx_w>
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
    800009aa:	2b248493          	add	s1,s1,690 # 80010c58 <uart_tx_lock>
    800009ae:	01f77793          	and	a5,a4,31
    800009b2:	97a6                	add	a5,a5,s1
    800009b4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009b8:	0705                	add	a4,a4,1
    800009ba:	00008797          	auipc	a5,0x8
    800009be:	04e7bb23          	sd	a4,86(a5) # 80008a10 <uart_tx_w>
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
    80000a32:	22a48493          	add	s1,s1,554 # 80010c58 <uart_tx_lock>
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
    80000a6e:	fb67b783          	ld	a5,-74(a5) # 80008a20 <MAX_PAGES>
    80000a72:	c799                	beqz	a5,80000a80 <kfree+0x24>
        assert(FREE_PAGES < MAX_PAGES);
    80000a74:	00008717          	auipc	a4,0x8
    80000a78:	fa473703          	ld	a4,-92(a4) # 80008a18 <FREE_PAGES>
    80000a7c:	06f77663          	bgeu	a4,a5,80000ae8 <kfree+0x8c>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a80:	03449793          	sll	a5,s1,0x34
    80000a84:	efc1                	bnez	a5,80000b1c <kfree+0xc0>
    80000a86:	00021797          	auipc	a5,0x21
    80000a8a:	43a78793          	add	a5,a5,1082 # 80021ec0 <end>
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
    80000aac:	1e890913          	add	s2,s2,488 # 80010c90 <kmem>
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
    80000ac8:	f5470713          	add	a4,a4,-172 # 80008a18 <FREE_PAGES>
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
    80000b8c:	10850513          	add	a0,a0,264 # 80010c90 <kmem>
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	0e0080e7          	jalr	224(ra) # 80000c70 <initlock>
    freerange(end, (void *)PHYSTOP);
    80000b98:	45c5                	li	a1,17
    80000b9a:	05ee                	sll	a1,a1,0x1b
    80000b9c:	00021517          	auipc	a0,0x21
    80000ba0:	32450513          	add	a0,a0,804 # 80021ec0 <end>
    80000ba4:	00000097          	auipc	ra,0x0
    80000ba8:	f88080e7          	jalr	-120(ra) # 80000b2c <freerange>
    MAX_PAGES = FREE_PAGES;
    80000bac:	00008797          	auipc	a5,0x8
    80000bb0:	e6c7b783          	ld	a5,-404(a5) # 80008a18 <FREE_PAGES>
    80000bb4:	00008717          	auipc	a4,0x8
    80000bb8:	e6f73623          	sd	a5,-404(a4) # 80008a20 <MAX_PAGES>
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
    80000bd2:	e4a7b783          	ld	a5,-438(a5) # 80008a18 <FREE_PAGES>
    80000bd6:	cbb1                	beqz	a5,80000c2a <kalloc+0x66>
    struct run *r;

    acquire(&kmem.lock);
    80000bd8:	00010497          	auipc	s1,0x10
    80000bdc:	0b848493          	add	s1,s1,184 # 80010c90 <kmem>
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
    80000bf4:	0a050513          	add	a0,a0,160 # 80010c90 <kmem>
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
    80000c14:	e0870713          	add	a4,a4,-504 # 80008a18 <FREE_PAGES>
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
    80000c62:	03250513          	add	a0,a0,50 # 80010c90 <kmem>
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
    80000fae:	a7e70713          	add	a4,a4,-1410 # 80008a28 <started>
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
    80000fec:	26c080e7          	jalr	620(ra) # 80006254 <plicinithart>
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
    8000106c:	1d2080e7          	jalr	466(ra) # 8000623a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001070:	00005097          	auipc	ra,0x5
    80001074:	1e4080e7          	jalr	484(ra) # 80006254 <plicinithart>
    binit();         // buffer cache
    80001078:	00002097          	auipc	ra,0x2
    8000107c:	2a8080e7          	jalr	680(ra) # 80003320 <binit>
    iinit();         // inode table
    80001080:	00003097          	auipc	ra,0x3
    80001084:	95e080e7          	jalr	-1698(ra) # 800039de <iinit>
    fileinit();      // file table
    80001088:	00004097          	auipc	ra,0x4
    8000108c:	90e080e7          	jalr	-1778(ra) # 80004996 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001090:	00005097          	auipc	ra,0x5
    80001094:	2cc080e7          	jalr	716(ra) # 8000635c <virtio_disk_init>
    userinit();      // first user process
    80001098:	00001097          	auipc	ra,0x1
    8000109c:	e46080e7          	jalr	-442(ra) # 80001ede <userinit>
    __sync_synchronize();
    800010a0:	0ff0000f          	fence
    started = 1;
    800010a4:	4785                	li	a5,1
    800010a6:	00008717          	auipc	a4,0x8
    800010aa:	98f72123          	sw	a5,-1662(a4) # 80008a28 <started>
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
    800010be:	9767b783          	ld	a5,-1674(a5) # 80008a30 <kernel_pagetable>
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
    80001138:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd137>
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
    8000137a:	6aa7bd23          	sd	a0,1722(a5) # 80008a30 <kernel_pagetable>
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
    80001954:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd140>
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
    800019a0:	314a8a93          	add	s5,s5,788 # 80010cb0 <cpus>
    800019a4:	00779713          	sll	a4,a5,0x7
    800019a8:	00ea86b3          	add	a3,s5,a4
    800019ac:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffdd140>
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
    800019ba:	fd2c0c13          	add	s8,s8,-46 # 80008988 <sched_pointer>
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
    800019d6:	70e48493          	add	s1,s1,1806 # 800110e0 <proc>
            if (p->state == RUNNABLE)
    800019da:	498d                	li	s3,3
                p->state = RUNNING;
    800019dc:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    800019de:	00015a17          	auipc	s4,0x15
    800019e2:	102a0a13          	add	s4,s4,258 # 80016ae0 <tickslock>
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
    80001a6a:	67a48493          	add	s1,s1,1658 # 800110e0 <proc>
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
    80001a96:	04ea8a93          	add	s5,s5,78 # 80016ae0 <tickslock>
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
    80001b14:	5a050513          	add	a0,a0,1440 # 800110b0 <pid_lock>
    80001b18:	fffff097          	auipc	ra,0xfffff
    80001b1c:	158080e7          	jalr	344(ra) # 80000c70 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001b20:	00006597          	auipc	a1,0x6
    80001b24:	6e858593          	add	a1,a1,1768 # 80008208 <__func__.1+0x200>
    80001b28:	0000f517          	auipc	a0,0xf
    80001b2c:	5a050513          	add	a0,a0,1440 # 800110c8 <wait_lock>
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	140080e7          	jalr	320(ra) # 80000c70 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b38:	0000f497          	auipc	s1,0xf
    80001b3c:	5a848493          	add	s1,s1,1448 # 800110e0 <proc>
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
    80001b70:	f74a0a13          	add	s4,s4,-140 # 80016ae0 <tickslock>
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
    80001bfa:	0ba50513          	add	a0,a0,186 # 80010cb0 <cpus>
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
    80001c22:	09270713          	add	a4,a4,146 # 80010cb0 <cpus>
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
    80001c5a:	d2a7a783          	lw	a5,-726(a5) # 80008980 <first.1>
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
    80001c74:	d007a823          	sw	zero,-752(a5) # 80008980 <first.1>
        fsinit(ROOTDEV);
    80001c78:	4505                	li	a0,1
    80001c7a:	00002097          	auipc	ra,0x2
    80001c7e:	ce4080e7          	jalr	-796(ra) # 8000395e <fsinit>
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
    80001c94:	42090913          	add	s2,s2,1056 # 800110b0 <pid_lock>
    80001c98:	854a                	mv	a0,s2
    80001c9a:	fffff097          	auipc	ra,0xfffff
    80001c9e:	066080e7          	jalr	102(ra) # 80000d00 <acquire>
    pid = nextpid;
    80001ca2:	00007797          	auipc	a5,0x7
    80001ca6:	cee78793          	add	a5,a5,-786 # 80008990 <nextpid>
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
    80001e20:	2c448493          	add	s1,s1,708 # 800110e0 <proc>
    80001e24:	00015917          	auipc	s2,0x15
    80001e28:	cbc90913          	add	s2,s2,-836 # 80016ae0 <tickslock>
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
    80001ef6:	b4a7b323          	sd	a0,-1210(a5) # 80008a38 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001efa:	03400613          	li	a2,52
    80001efe:	00007597          	auipc	a1,0x7
    80001f02:	aa258593          	add	a1,a1,-1374 # 800089a0 <initcode>
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
    80001f40:	474080e7          	jalr	1140(ra) # 800043b0 <namei>
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
    80002026:	0be78793          	add	a5,a5,190 # 800110e0 <proc>
    8000202a:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    8000202c:	00015797          	auipc	a5,0x15
    80002030:	ab478793          	add	a5,a5,-1356 # 80016ae0 <tickslock>
        return result;
    80002034:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    80002036:	06f4fc63          	bgeu	s1,a5,800020ae <ps+0xf2>
    acquire(&wait_lock);
    8000203a:	0000f517          	auipc	a0,0xf
    8000203e:	08e50513          	add	a0,a0,142 # 800110c8 <wait_lock>
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	cbe080e7          	jalr	-834(ra) # 80000d00 <acquire>
        if (localCount == count)
    8000204a:	014a8913          	add	s2,s5,20
    uint8 localCount = 0;
    8000204e:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80002050:	00015c17          	auipc	s8,0x15
    80002054:	a90c0c13          	add	s8,s8,-1392 # 80016ae0 <tickslock>
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
    80002076:	05650513          	add	a0,a0,86 # 800110c8 <wait_lock>
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
    80002146:	f8650513          	add	a0,a0,-122 # 800110c8 <wait_lock>
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
    80002206:	00003097          	auipc	ra,0x3
    8000220a:	822080e7          	jalr	-2014(ra) # 80004a28 <filedup>
    8000220e:	00a93023          	sd	a0,0(s2)
    80002212:	b7e5                	j	800021fa <fork+0xa6>
    np->cwd = idup(p->cwd);
    80002214:	150ab503          	ld	a0,336(s5)
    80002218:	00002097          	auipc	ra,0x2
    8000221c:	98c080e7          	jalr	-1652(ra) # 80003ba4 <idup>
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
    80002248:	e8448493          	add	s1,s1,-380 # 800110c8 <wait_lock>
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
    800022a4:	6e848493          	add	s1,s1,1768 # 80008988 <sched_pointer>
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
    800022da:	9da70713          	add	a4,a4,-1574 # 80010cb0 <cpus>
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
    800022fe:	9b690913          	add	s2,s2,-1610 # 80010cb0 <cpus>
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
    80002434:	cb048493          	add	s1,s1,-848 # 800110e0 <proc>
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
    80002440:	6a490913          	add	s2,s2,1700 # 80016ae0 <tickslock>
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
    800024a8:	c3c48493          	add	s1,s1,-964 # 800110e0 <proc>
            pp->parent = initproc;
    800024ac:	00006a17          	auipc	s4,0x6
    800024b0:	58ca0a13          	add	s4,s4,1420 # 80008a38 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024b4:	00014997          	auipc	s3,0x14
    800024b8:	62c98993          	add	s3,s3,1580 # 80016ae0 <tickslock>
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
    8000250c:	5307b783          	ld	a5,1328(a5) # 80008a38 <initproc>
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
    80002530:	54e080e7          	jalr	1358(ra) # 80004a7a <fileclose>
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
    80002548:	06c080e7          	jalr	108(ra) # 800045b0 <begin_op>
    iput(p->cwd);
    8000254c:	1509b503          	ld	a0,336(s3)
    80002550:	00002097          	auipc	ra,0x2
    80002554:	850080e7          	jalr	-1968(ra) # 80003da0 <iput>
    end_op();
    80002558:	00002097          	auipc	ra,0x2
    8000255c:	0d2080e7          	jalr	210(ra) # 8000462a <end_op>
    p->cwd = 0;
    80002560:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002564:	0000f497          	auipc	s1,0xf
    80002568:	b6448493          	add	s1,s1,-1180 # 800110c8 <wait_lock>
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
    800025d6:	b0e48493          	add	s1,s1,-1266 # 800110e0 <proc>
    800025da:	00014997          	auipc	s3,0x14
    800025de:	50698993          	add	s3,s3,1286 # 80016ae0 <tickslock>
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
    800026ba:	a1250513          	add	a0,a0,-1518 # 800110c8 <wait_lock>
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
    800026d0:	41498993          	add	s3,s3,1044 # 80016ae0 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    800026d4:	0000fc17          	auipc	s8,0xf
    800026d8:	9f4c0c13          	add	s8,s8,-1548 # 800110c8 <wait_lock>
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
    80002716:	9b650513          	add	a0,a0,-1610 # 800110c8 <wait_lock>
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
    8000274a:	98250513          	add	a0,a0,-1662 # 800110c8 <wait_lock>
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
    800027a6:	93e48493          	add	s1,s1,-1730 # 800110e0 <proc>
    800027aa:	bf65                	j	80002762 <wait+0xd0>
            release(&wait_lock);
    800027ac:	0000f517          	auipc	a0,0xf
    800027b0:	91c50513          	add	a0,a0,-1764 # 800110c8 <wait_lock>
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
    80002896:	9a648493          	add	s1,s1,-1626 # 80011238 <proc+0x158>
    8000289a:	00014917          	auipc	s2,0x14
    8000289e:	39e90913          	add	s2,s2,926 # 80016c38 <bcache+0x140>
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
    800028c0:	f9cb8b93          	add	s7,s7,-100 # 80008858 <states.0>
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
    80002948:	0a473703          	ld	a4,164(a4) # 800089e8 <available_schedulers+0x10>
    8000294c:	00006797          	auipc	a5,0x6
    80002950:	03c7b783          	ld	a5,60(a5) # 80008988 <sched_pointer>
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
    8000296c:	08862603          	lw	a2,136(a2) # 800089f0 <available_schedulers+0x18>
    80002970:	00006597          	auipc	a1,0x6
    80002974:	06858593          	add	a1,a1,104 # 800089d8 <available_schedulers>
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
    800029c0:	02c7b783          	ld	a5,44(a5) # 800089e8 <available_schedulers+0x10>
    800029c4:	00006717          	auipc	a4,0x6
    800029c8:	fcf73223          	sd	a5,-60(a4) # 80008988 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    800029cc:	00006597          	auipc	a1,0x6
    800029d0:	00c58593          	add	a1,a1,12 # 800089d8 <available_schedulers>
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
    80002a7c:	06850513          	add	a0,a0,104 # 80016ae0 <tickslock>
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
    80002a9a:	6ea78793          	add	a5,a5,1770 # 80006180 <kernelvec>
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
    80002b4c:	f9848493          	add	s1,s1,-104 # 80016ae0 <tickslock>
    80002b50:	8526                	mv	a0,s1
    80002b52:	ffffe097          	auipc	ra,0xffffe
    80002b56:	1ae080e7          	jalr	430(ra) # 80000d00 <acquire>
  ticks++;
    80002b5a:	00006517          	auipc	a0,0x6
    80002b5e:	ee650513          	add	a0,a0,-282 # 80008a40 <ticks>
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
    80002bba:	6d6080e7          	jalr	1750(ra) # 8000628c <plic_claim>
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
    80002be2:	bd8080e7          	jalr	-1064(ra) # 800067b6 <virtio_disk_intr>
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
    80002c00:	6b4080e7          	jalr	1716(ra) # 800062b0 <plic_complete>
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
    80002c48:	53c78793          	add	a5,a5,1340 # 80006180 <kernelvec>
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
    80002e2a:	a6270713          	add	a4,a4,-1438 # 80008888 <states.0+0x30>
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
    80002fba:	8ea78793          	add	a5,a5,-1814 # 800088a0 <syscalls>
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
    800030da:	a0a50513          	add	a0,a0,-1526 # 80016ae0 <tickslock>
    800030de:	ffffe097          	auipc	ra,0xffffe
    800030e2:	c22080e7          	jalr	-990(ra) # 80000d00 <acquire>
    ticks0 = ticks;
    800030e6:	00006917          	auipc	s2,0x6
    800030ea:	95a92903          	lw	s2,-1702(s2) # 80008a40 <ticks>
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
    800030fc:	9e898993          	add	s3,s3,-1560 # 80016ae0 <tickslock>
    80003100:	00006497          	auipc	s1,0x6
    80003104:	94048493          	add	s1,s1,-1728 # 80008a40 <ticks>
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
    8000313c:	9a850513          	add	a0,a0,-1624 # 80016ae0 <tickslock>
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
    80003158:	98c50513          	add	a0,a0,-1652 # 80016ae0 <tickslock>
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
    800031a4:	94050513          	add	a0,a0,-1728 # 80016ae0 <tickslock>
    800031a8:	ffffe097          	auipc	ra,0xffffe
    800031ac:	b58080e7          	jalr	-1192(ra) # 80000d00 <acquire>
    xticks = ticks;
    800031b0:	00006497          	auipc	s1,0x6
    800031b4:	8904a483          	lw	s1,-1904(s1) # 80008a40 <ticks>
    release(&tickslock);
    800031b8:	00014517          	auipc	a0,0x14
    800031bc:	92850513          	add	a0,a0,-1752 # 80016ae0 <tickslock>
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

uint64 sys_va2pa(void) {
    80003268:	1101                	add	sp,sp,-32
    8000326a:	ec06                	sd	ra,24(sp)
    8000326c:	e822                	sd	s0,16(sp)
    8000326e:	1000                	add	s0,sp,32
    uint64 vaddr;
    int pid;

    argaddr(0, &vaddr);
    80003270:	fe840593          	add	a1,s0,-24
    80003274:	4501                	li	a0,0
    80003276:	00000097          	auipc	ra,0x0
    8000327a:	cba080e7          	jalr	-838(ra) # 80002f30 <argaddr>
    argint(1, &pid);
    8000327e:	fe440593          	add	a1,s0,-28
    80003282:	4505                	li	a0,1
    80003284:	00000097          	auipc	ra,0x0
    80003288:	c8c080e7          	jalr	-884(ra) # 80002f10 <argint>
    
    if(pid <= 0) {
    8000328c:	fe442783          	lw	a5,-28(s0)
    80003290:	02f05563          	blez	a5,800032ba <sys_va2pa+0x52>

    struct proc* p;
    extern struct proc proc[];

    for(p = proc; p < &proc[NPROC]; p++){
        if(p->pid == pid){
    80003294:	fe442683          	lw	a3,-28(s0)
    for(p = proc; p < &proc[NPROC]; p++){
    80003298:	0000e797          	auipc	a5,0xe
    8000329c:	e4878793          	add	a5,a5,-440 # 800110e0 <proc>
    800032a0:	00014617          	auipc	a2,0x14
    800032a4:	84060613          	add	a2,a2,-1984 # 80016ae0 <tickslock>
        if(p->pid == pid){
    800032a8:	5b98                	lw	a4,48(a5)
    800032aa:	02d70063          	beq	a4,a3,800032ca <sys_va2pa+0x62>
    for(p = proc; p < &proc[NPROC]; p++){
    800032ae:	16878793          	add	a5,a5,360
    800032b2:	fec79be3          	bne	a5,a2,800032a8 <sys_va2pa+0x40>
            break;
        }
    }

    if(p == &proc[NPROC] || p == NULL) {
        return -2; 
    800032b6:	5579                	li	a0,-2
    800032b8:	a03d                	j	800032e6 <sys_va2pa+0x7e>
        pid = myproc()->pid;
    800032ba:	fffff097          	auipc	ra,0xfffff
    800032be:	94c080e7          	jalr	-1716(ra) # 80001c06 <myproc>
    800032c2:	591c                	lw	a5,48(a0)
    800032c4:	fef42223          	sw	a5,-28(s0)
    800032c8:	b7f1                	j	80003294 <sys_va2pa+0x2c>
    if(p == &proc[NPROC] || p == NULL) {
    800032ca:	00014717          	auipc	a4,0x14
    800032ce:	81670713          	add	a4,a4,-2026 # 80016ae0 <tickslock>
    800032d2:	00e78e63          	beq	a5,a4,800032ee <sys_va2pa+0x86>
    }

    uint64 paddr = walkaddr(p->pagetable, vaddr);
    800032d6:	fe843583          	ld	a1,-24(s0)
    800032da:	6ba8                	ld	a0,80(a5)
    800032dc:	ffffe097          	auipc	ra,0xffffe
    800032e0:	ea2080e7          	jalr	-350(ra) # 8000117e <walkaddr>
    if(paddr == 0) {
    800032e4:	c519                	beqz	a0,800032f2 <sys_va2pa+0x8a>
        return -3; 
    }

    return paddr;
}
    800032e6:	60e2                	ld	ra,24(sp)
    800032e8:	6442                	ld	s0,16(sp)
    800032ea:	6105                	add	sp,sp,32
    800032ec:	8082                	ret
        return -2; 
    800032ee:	5579                	li	a0,-2
    800032f0:	bfdd                	j	800032e6 <sys_va2pa+0x7e>
        return -3; 
    800032f2:	5575                	li	a0,-3
    800032f4:	bfcd                	j	800032e6 <sys_va2pa+0x7e>

00000000800032f6 <sys_pfreepages>:


uint64 sys_pfreepages(void)
{
    800032f6:	1141                	add	sp,sp,-16
    800032f8:	e406                	sd	ra,8(sp)
    800032fa:	e022                	sd	s0,0(sp)
    800032fc:	0800                	add	s0,sp,16
    printf("%d\n", FREE_PAGES);
    800032fe:	00005597          	auipc	a1,0x5
    80003302:	71a5b583          	ld	a1,1818(a1) # 80008a18 <FREE_PAGES>
    80003306:	00005517          	auipc	a0,0x5
    8000330a:	1f250513          	add	a0,a0,498 # 800084f8 <__func__.1+0x4f0>
    8000330e:	ffffd097          	auipc	ra,0xffffd
    80003312:	2ae080e7          	jalr	686(ra) # 800005bc <printf>
    return 0;
    80003316:	4501                	li	a0,0
    80003318:	60a2                	ld	ra,8(sp)
    8000331a:	6402                	ld	s0,0(sp)
    8000331c:	0141                	add	sp,sp,16
    8000331e:	8082                	ret

0000000080003320 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003320:	7179                	add	sp,sp,-48
    80003322:	f406                	sd	ra,40(sp)
    80003324:	f022                	sd	s0,32(sp)
    80003326:	ec26                	sd	s1,24(sp)
    80003328:	e84a                	sd	s2,16(sp)
    8000332a:	e44e                	sd	s3,8(sp)
    8000332c:	e052                	sd	s4,0(sp)
    8000332e:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003330:	00005597          	auipc	a1,0x5
    80003334:	1d058593          	add	a1,a1,464 # 80008500 <__func__.1+0x4f8>
    80003338:	00013517          	auipc	a0,0x13
    8000333c:	7c050513          	add	a0,a0,1984 # 80016af8 <bcache>
    80003340:	ffffe097          	auipc	ra,0xffffe
    80003344:	930080e7          	jalr	-1744(ra) # 80000c70 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003348:	0001b797          	auipc	a5,0x1b
    8000334c:	7b078793          	add	a5,a5,1968 # 8001eaf8 <bcache+0x8000>
    80003350:	0001c717          	auipc	a4,0x1c
    80003354:	a1070713          	add	a4,a4,-1520 # 8001ed60 <bcache+0x8268>
    80003358:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000335c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003360:	00013497          	auipc	s1,0x13
    80003364:	7b048493          	add	s1,s1,1968 # 80016b10 <bcache+0x18>
    b->next = bcache.head.next;
    80003368:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000336a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000336c:	00005a17          	auipc	s4,0x5
    80003370:	19ca0a13          	add	s4,s4,412 # 80008508 <__func__.1+0x500>
    b->next = bcache.head.next;
    80003374:	2b893783          	ld	a5,696(s2)
    80003378:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000337a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000337e:	85d2                	mv	a1,s4
    80003380:	01048513          	add	a0,s1,16
    80003384:	00001097          	auipc	ra,0x1
    80003388:	4e8080e7          	jalr	1256(ra) # 8000486c <initsleeplock>
    bcache.head.next->prev = b;
    8000338c:	2b893783          	ld	a5,696(s2)
    80003390:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003392:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003396:	45848493          	add	s1,s1,1112
    8000339a:	fd349de3          	bne	s1,s3,80003374 <binit+0x54>
  }
}
    8000339e:	70a2                	ld	ra,40(sp)
    800033a0:	7402                	ld	s0,32(sp)
    800033a2:	64e2                	ld	s1,24(sp)
    800033a4:	6942                	ld	s2,16(sp)
    800033a6:	69a2                	ld	s3,8(sp)
    800033a8:	6a02                	ld	s4,0(sp)
    800033aa:	6145                	add	sp,sp,48
    800033ac:	8082                	ret

00000000800033ae <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033ae:	7179                	add	sp,sp,-48
    800033b0:	f406                	sd	ra,40(sp)
    800033b2:	f022                	sd	s0,32(sp)
    800033b4:	ec26                	sd	s1,24(sp)
    800033b6:	e84a                	sd	s2,16(sp)
    800033b8:	e44e                	sd	s3,8(sp)
    800033ba:	1800                	add	s0,sp,48
    800033bc:	892a                	mv	s2,a0
    800033be:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800033c0:	00013517          	auipc	a0,0x13
    800033c4:	73850513          	add	a0,a0,1848 # 80016af8 <bcache>
    800033c8:	ffffe097          	auipc	ra,0xffffe
    800033cc:	938080e7          	jalr	-1736(ra) # 80000d00 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033d0:	0001c497          	auipc	s1,0x1c
    800033d4:	9e04b483          	ld	s1,-1568(s1) # 8001edb0 <bcache+0x82b8>
    800033d8:	0001c797          	auipc	a5,0x1c
    800033dc:	98878793          	add	a5,a5,-1656 # 8001ed60 <bcache+0x8268>
    800033e0:	02f48f63          	beq	s1,a5,8000341e <bread+0x70>
    800033e4:	873e                	mv	a4,a5
    800033e6:	a021                	j	800033ee <bread+0x40>
    800033e8:	68a4                	ld	s1,80(s1)
    800033ea:	02e48a63          	beq	s1,a4,8000341e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800033ee:	449c                	lw	a5,8(s1)
    800033f0:	ff279ce3          	bne	a5,s2,800033e8 <bread+0x3a>
    800033f4:	44dc                	lw	a5,12(s1)
    800033f6:	ff3799e3          	bne	a5,s3,800033e8 <bread+0x3a>
      b->refcnt++;
    800033fa:	40bc                	lw	a5,64(s1)
    800033fc:	2785                	addw	a5,a5,1
    800033fe:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003400:	00013517          	auipc	a0,0x13
    80003404:	6f850513          	add	a0,a0,1784 # 80016af8 <bcache>
    80003408:	ffffe097          	auipc	ra,0xffffe
    8000340c:	9ac080e7          	jalr	-1620(ra) # 80000db4 <release>
      acquiresleep(&b->lock);
    80003410:	01048513          	add	a0,s1,16
    80003414:	00001097          	auipc	ra,0x1
    80003418:	492080e7          	jalr	1170(ra) # 800048a6 <acquiresleep>
      return b;
    8000341c:	a8b9                	j	8000347a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000341e:	0001c497          	auipc	s1,0x1c
    80003422:	98a4b483          	ld	s1,-1654(s1) # 8001eda8 <bcache+0x82b0>
    80003426:	0001c797          	auipc	a5,0x1c
    8000342a:	93a78793          	add	a5,a5,-1734 # 8001ed60 <bcache+0x8268>
    8000342e:	00f48863          	beq	s1,a5,8000343e <bread+0x90>
    80003432:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003434:	40bc                	lw	a5,64(s1)
    80003436:	cf81                	beqz	a5,8000344e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003438:	64a4                	ld	s1,72(s1)
    8000343a:	fee49de3          	bne	s1,a4,80003434 <bread+0x86>
  panic("bget: no buffers");
    8000343e:	00005517          	auipc	a0,0x5
    80003442:	0d250513          	add	a0,a0,210 # 80008510 <__func__.1+0x508>
    80003446:	ffffd097          	auipc	ra,0xffffd
    8000344a:	11a080e7          	jalr	282(ra) # 80000560 <panic>
      b->dev = dev;
    8000344e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003452:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003456:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000345a:	4785                	li	a5,1
    8000345c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000345e:	00013517          	auipc	a0,0x13
    80003462:	69a50513          	add	a0,a0,1690 # 80016af8 <bcache>
    80003466:	ffffe097          	auipc	ra,0xffffe
    8000346a:	94e080e7          	jalr	-1714(ra) # 80000db4 <release>
      acquiresleep(&b->lock);
    8000346e:	01048513          	add	a0,s1,16
    80003472:	00001097          	auipc	ra,0x1
    80003476:	434080e7          	jalr	1076(ra) # 800048a6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000347a:	409c                	lw	a5,0(s1)
    8000347c:	cb89                	beqz	a5,8000348e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000347e:	8526                	mv	a0,s1
    80003480:	70a2                	ld	ra,40(sp)
    80003482:	7402                	ld	s0,32(sp)
    80003484:	64e2                	ld	s1,24(sp)
    80003486:	6942                	ld	s2,16(sp)
    80003488:	69a2                	ld	s3,8(sp)
    8000348a:	6145                	add	sp,sp,48
    8000348c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000348e:	4581                	li	a1,0
    80003490:	8526                	mv	a0,s1
    80003492:	00003097          	auipc	ra,0x3
    80003496:	0f6080e7          	jalr	246(ra) # 80006588 <virtio_disk_rw>
    b->valid = 1;
    8000349a:	4785                	li	a5,1
    8000349c:	c09c                	sw	a5,0(s1)
  return b;
    8000349e:	b7c5                	j	8000347e <bread+0xd0>

00000000800034a0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034a0:	1101                	add	sp,sp,-32
    800034a2:	ec06                	sd	ra,24(sp)
    800034a4:	e822                	sd	s0,16(sp)
    800034a6:	e426                	sd	s1,8(sp)
    800034a8:	1000                	add	s0,sp,32
    800034aa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034ac:	0541                	add	a0,a0,16
    800034ae:	00001097          	auipc	ra,0x1
    800034b2:	492080e7          	jalr	1170(ra) # 80004940 <holdingsleep>
    800034b6:	cd01                	beqz	a0,800034ce <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800034b8:	4585                	li	a1,1
    800034ba:	8526                	mv	a0,s1
    800034bc:	00003097          	auipc	ra,0x3
    800034c0:	0cc080e7          	jalr	204(ra) # 80006588 <virtio_disk_rw>
}
    800034c4:	60e2                	ld	ra,24(sp)
    800034c6:	6442                	ld	s0,16(sp)
    800034c8:	64a2                	ld	s1,8(sp)
    800034ca:	6105                	add	sp,sp,32
    800034cc:	8082                	ret
    panic("bwrite");
    800034ce:	00005517          	auipc	a0,0x5
    800034d2:	05a50513          	add	a0,a0,90 # 80008528 <__func__.1+0x520>
    800034d6:	ffffd097          	auipc	ra,0xffffd
    800034da:	08a080e7          	jalr	138(ra) # 80000560 <panic>

00000000800034de <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800034de:	1101                	add	sp,sp,-32
    800034e0:	ec06                	sd	ra,24(sp)
    800034e2:	e822                	sd	s0,16(sp)
    800034e4:	e426                	sd	s1,8(sp)
    800034e6:	e04a                	sd	s2,0(sp)
    800034e8:	1000                	add	s0,sp,32
    800034ea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034ec:	01050913          	add	s2,a0,16
    800034f0:	854a                	mv	a0,s2
    800034f2:	00001097          	auipc	ra,0x1
    800034f6:	44e080e7          	jalr	1102(ra) # 80004940 <holdingsleep>
    800034fa:	c925                	beqz	a0,8000356a <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800034fc:	854a                	mv	a0,s2
    800034fe:	00001097          	auipc	ra,0x1
    80003502:	3fe080e7          	jalr	1022(ra) # 800048fc <releasesleep>

  acquire(&bcache.lock);
    80003506:	00013517          	auipc	a0,0x13
    8000350a:	5f250513          	add	a0,a0,1522 # 80016af8 <bcache>
    8000350e:	ffffd097          	auipc	ra,0xffffd
    80003512:	7f2080e7          	jalr	2034(ra) # 80000d00 <acquire>
  b->refcnt--;
    80003516:	40bc                	lw	a5,64(s1)
    80003518:	37fd                	addw	a5,a5,-1
    8000351a:	0007871b          	sext.w	a4,a5
    8000351e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003520:	e71d                	bnez	a4,8000354e <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003522:	68b8                	ld	a4,80(s1)
    80003524:	64bc                	ld	a5,72(s1)
    80003526:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003528:	68b8                	ld	a4,80(s1)
    8000352a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000352c:	0001b797          	auipc	a5,0x1b
    80003530:	5cc78793          	add	a5,a5,1484 # 8001eaf8 <bcache+0x8000>
    80003534:	2b87b703          	ld	a4,696(a5)
    80003538:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000353a:	0001c717          	auipc	a4,0x1c
    8000353e:	82670713          	add	a4,a4,-2010 # 8001ed60 <bcache+0x8268>
    80003542:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003544:	2b87b703          	ld	a4,696(a5)
    80003548:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000354a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000354e:	00013517          	auipc	a0,0x13
    80003552:	5aa50513          	add	a0,a0,1450 # 80016af8 <bcache>
    80003556:	ffffe097          	auipc	ra,0xffffe
    8000355a:	85e080e7          	jalr	-1954(ra) # 80000db4 <release>
}
    8000355e:	60e2                	ld	ra,24(sp)
    80003560:	6442                	ld	s0,16(sp)
    80003562:	64a2                	ld	s1,8(sp)
    80003564:	6902                	ld	s2,0(sp)
    80003566:	6105                	add	sp,sp,32
    80003568:	8082                	ret
    panic("brelse");
    8000356a:	00005517          	auipc	a0,0x5
    8000356e:	fc650513          	add	a0,a0,-58 # 80008530 <__func__.1+0x528>
    80003572:	ffffd097          	auipc	ra,0xffffd
    80003576:	fee080e7          	jalr	-18(ra) # 80000560 <panic>

000000008000357a <bpin>:

void
bpin(struct buf *b) {
    8000357a:	1101                	add	sp,sp,-32
    8000357c:	ec06                	sd	ra,24(sp)
    8000357e:	e822                	sd	s0,16(sp)
    80003580:	e426                	sd	s1,8(sp)
    80003582:	1000                	add	s0,sp,32
    80003584:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003586:	00013517          	auipc	a0,0x13
    8000358a:	57250513          	add	a0,a0,1394 # 80016af8 <bcache>
    8000358e:	ffffd097          	auipc	ra,0xffffd
    80003592:	772080e7          	jalr	1906(ra) # 80000d00 <acquire>
  b->refcnt++;
    80003596:	40bc                	lw	a5,64(s1)
    80003598:	2785                	addw	a5,a5,1
    8000359a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000359c:	00013517          	auipc	a0,0x13
    800035a0:	55c50513          	add	a0,a0,1372 # 80016af8 <bcache>
    800035a4:	ffffe097          	auipc	ra,0xffffe
    800035a8:	810080e7          	jalr	-2032(ra) # 80000db4 <release>
}
    800035ac:	60e2                	ld	ra,24(sp)
    800035ae:	6442                	ld	s0,16(sp)
    800035b0:	64a2                	ld	s1,8(sp)
    800035b2:	6105                	add	sp,sp,32
    800035b4:	8082                	ret

00000000800035b6 <bunpin>:

void
bunpin(struct buf *b) {
    800035b6:	1101                	add	sp,sp,-32
    800035b8:	ec06                	sd	ra,24(sp)
    800035ba:	e822                	sd	s0,16(sp)
    800035bc:	e426                	sd	s1,8(sp)
    800035be:	1000                	add	s0,sp,32
    800035c0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035c2:	00013517          	auipc	a0,0x13
    800035c6:	53650513          	add	a0,a0,1334 # 80016af8 <bcache>
    800035ca:	ffffd097          	auipc	ra,0xffffd
    800035ce:	736080e7          	jalr	1846(ra) # 80000d00 <acquire>
  b->refcnt--;
    800035d2:	40bc                	lw	a5,64(s1)
    800035d4:	37fd                	addw	a5,a5,-1
    800035d6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035d8:	00013517          	auipc	a0,0x13
    800035dc:	52050513          	add	a0,a0,1312 # 80016af8 <bcache>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	7d4080e7          	jalr	2004(ra) # 80000db4 <release>
}
    800035e8:	60e2                	ld	ra,24(sp)
    800035ea:	6442                	ld	s0,16(sp)
    800035ec:	64a2                	ld	s1,8(sp)
    800035ee:	6105                	add	sp,sp,32
    800035f0:	8082                	ret

00000000800035f2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800035f2:	1101                	add	sp,sp,-32
    800035f4:	ec06                	sd	ra,24(sp)
    800035f6:	e822                	sd	s0,16(sp)
    800035f8:	e426                	sd	s1,8(sp)
    800035fa:	e04a                	sd	s2,0(sp)
    800035fc:	1000                	add	s0,sp,32
    800035fe:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003600:	00d5d59b          	srlw	a1,a1,0xd
    80003604:	0001c797          	auipc	a5,0x1c
    80003608:	bd07a783          	lw	a5,-1072(a5) # 8001f1d4 <sb+0x1c>
    8000360c:	9dbd                	addw	a1,a1,a5
    8000360e:	00000097          	auipc	ra,0x0
    80003612:	da0080e7          	jalr	-608(ra) # 800033ae <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003616:	0074f713          	and	a4,s1,7
    8000361a:	4785                	li	a5,1
    8000361c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003620:	14ce                	sll	s1,s1,0x33
    80003622:	90d9                	srl	s1,s1,0x36
    80003624:	00950733          	add	a4,a0,s1
    80003628:	05874703          	lbu	a4,88(a4)
    8000362c:	00e7f6b3          	and	a3,a5,a4
    80003630:	c69d                	beqz	a3,8000365e <bfree+0x6c>
    80003632:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003634:	94aa                	add	s1,s1,a0
    80003636:	fff7c793          	not	a5,a5
    8000363a:	8f7d                	and	a4,a4,a5
    8000363c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003640:	00001097          	auipc	ra,0x1
    80003644:	148080e7          	jalr	328(ra) # 80004788 <log_write>
  brelse(bp);
    80003648:	854a                	mv	a0,s2
    8000364a:	00000097          	auipc	ra,0x0
    8000364e:	e94080e7          	jalr	-364(ra) # 800034de <brelse>
}
    80003652:	60e2                	ld	ra,24(sp)
    80003654:	6442                	ld	s0,16(sp)
    80003656:	64a2                	ld	s1,8(sp)
    80003658:	6902                	ld	s2,0(sp)
    8000365a:	6105                	add	sp,sp,32
    8000365c:	8082                	ret
    panic("freeing free block");
    8000365e:	00005517          	auipc	a0,0x5
    80003662:	eda50513          	add	a0,a0,-294 # 80008538 <__func__.1+0x530>
    80003666:	ffffd097          	auipc	ra,0xffffd
    8000366a:	efa080e7          	jalr	-262(ra) # 80000560 <panic>

000000008000366e <balloc>:
{
    8000366e:	711d                	add	sp,sp,-96
    80003670:	ec86                	sd	ra,88(sp)
    80003672:	e8a2                	sd	s0,80(sp)
    80003674:	e4a6                	sd	s1,72(sp)
    80003676:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003678:	0001c797          	auipc	a5,0x1c
    8000367c:	b447a783          	lw	a5,-1212(a5) # 8001f1bc <sb+0x4>
    80003680:	10078f63          	beqz	a5,8000379e <balloc+0x130>
    80003684:	e0ca                	sd	s2,64(sp)
    80003686:	fc4e                	sd	s3,56(sp)
    80003688:	f852                	sd	s4,48(sp)
    8000368a:	f456                	sd	s5,40(sp)
    8000368c:	f05a                	sd	s6,32(sp)
    8000368e:	ec5e                	sd	s7,24(sp)
    80003690:	e862                	sd	s8,16(sp)
    80003692:	e466                	sd	s9,8(sp)
    80003694:	8baa                	mv	s7,a0
    80003696:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003698:	0001cb17          	auipc	s6,0x1c
    8000369c:	b20b0b13          	add	s6,s6,-1248 # 8001f1b8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036a0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036a2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036a4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036a6:	6c89                	lui	s9,0x2
    800036a8:	a061                	j	80003730 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036aa:	97ca                	add	a5,a5,s2
    800036ac:	8e55                	or	a2,a2,a3
    800036ae:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800036b2:	854a                	mv	a0,s2
    800036b4:	00001097          	auipc	ra,0x1
    800036b8:	0d4080e7          	jalr	212(ra) # 80004788 <log_write>
        brelse(bp);
    800036bc:	854a                	mv	a0,s2
    800036be:	00000097          	auipc	ra,0x0
    800036c2:	e20080e7          	jalr	-480(ra) # 800034de <brelse>
  bp = bread(dev, bno);
    800036c6:	85a6                	mv	a1,s1
    800036c8:	855e                	mv	a0,s7
    800036ca:	00000097          	auipc	ra,0x0
    800036ce:	ce4080e7          	jalr	-796(ra) # 800033ae <bread>
    800036d2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800036d4:	40000613          	li	a2,1024
    800036d8:	4581                	li	a1,0
    800036da:	05850513          	add	a0,a0,88
    800036de:	ffffd097          	auipc	ra,0xffffd
    800036e2:	71e080e7          	jalr	1822(ra) # 80000dfc <memset>
  log_write(bp);
    800036e6:	854a                	mv	a0,s2
    800036e8:	00001097          	auipc	ra,0x1
    800036ec:	0a0080e7          	jalr	160(ra) # 80004788 <log_write>
  brelse(bp);
    800036f0:	854a                	mv	a0,s2
    800036f2:	00000097          	auipc	ra,0x0
    800036f6:	dec080e7          	jalr	-532(ra) # 800034de <brelse>
}
    800036fa:	6906                	ld	s2,64(sp)
    800036fc:	79e2                	ld	s3,56(sp)
    800036fe:	7a42                	ld	s4,48(sp)
    80003700:	7aa2                	ld	s5,40(sp)
    80003702:	7b02                	ld	s6,32(sp)
    80003704:	6be2                	ld	s7,24(sp)
    80003706:	6c42                	ld	s8,16(sp)
    80003708:	6ca2                	ld	s9,8(sp)
}
    8000370a:	8526                	mv	a0,s1
    8000370c:	60e6                	ld	ra,88(sp)
    8000370e:	6446                	ld	s0,80(sp)
    80003710:	64a6                	ld	s1,72(sp)
    80003712:	6125                	add	sp,sp,96
    80003714:	8082                	ret
    brelse(bp);
    80003716:	854a                	mv	a0,s2
    80003718:	00000097          	auipc	ra,0x0
    8000371c:	dc6080e7          	jalr	-570(ra) # 800034de <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003720:	015c87bb          	addw	a5,s9,s5
    80003724:	00078a9b          	sext.w	s5,a5
    80003728:	004b2703          	lw	a4,4(s6)
    8000372c:	06eaf163          	bgeu	s5,a4,8000378e <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003730:	41fad79b          	sraw	a5,s5,0x1f
    80003734:	0137d79b          	srlw	a5,a5,0x13
    80003738:	015787bb          	addw	a5,a5,s5
    8000373c:	40d7d79b          	sraw	a5,a5,0xd
    80003740:	01cb2583          	lw	a1,28(s6)
    80003744:	9dbd                	addw	a1,a1,a5
    80003746:	855e                	mv	a0,s7
    80003748:	00000097          	auipc	ra,0x0
    8000374c:	c66080e7          	jalr	-922(ra) # 800033ae <bread>
    80003750:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003752:	004b2503          	lw	a0,4(s6)
    80003756:	000a849b          	sext.w	s1,s5
    8000375a:	8762                	mv	a4,s8
    8000375c:	faa4fde3          	bgeu	s1,a0,80003716 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003760:	00777693          	and	a3,a4,7
    80003764:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003768:	41f7579b          	sraw	a5,a4,0x1f
    8000376c:	01d7d79b          	srlw	a5,a5,0x1d
    80003770:	9fb9                	addw	a5,a5,a4
    80003772:	4037d79b          	sraw	a5,a5,0x3
    80003776:	00f90633          	add	a2,s2,a5
    8000377a:	05864603          	lbu	a2,88(a2)
    8000377e:	00c6f5b3          	and	a1,a3,a2
    80003782:	d585                	beqz	a1,800036aa <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003784:	2705                	addw	a4,a4,1
    80003786:	2485                	addw	s1,s1,1
    80003788:	fd471ae3          	bne	a4,s4,8000375c <balloc+0xee>
    8000378c:	b769                	j	80003716 <balloc+0xa8>
    8000378e:	6906                	ld	s2,64(sp)
    80003790:	79e2                	ld	s3,56(sp)
    80003792:	7a42                	ld	s4,48(sp)
    80003794:	7aa2                	ld	s5,40(sp)
    80003796:	7b02                	ld	s6,32(sp)
    80003798:	6be2                	ld	s7,24(sp)
    8000379a:	6c42                	ld	s8,16(sp)
    8000379c:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000379e:	00005517          	auipc	a0,0x5
    800037a2:	db250513          	add	a0,a0,-590 # 80008550 <__func__.1+0x548>
    800037a6:	ffffd097          	auipc	ra,0xffffd
    800037aa:	e16080e7          	jalr	-490(ra) # 800005bc <printf>
  return 0;
    800037ae:	4481                	li	s1,0
    800037b0:	bfa9                	j	8000370a <balloc+0x9c>

00000000800037b2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037b2:	7179                	add	sp,sp,-48
    800037b4:	f406                	sd	ra,40(sp)
    800037b6:	f022                	sd	s0,32(sp)
    800037b8:	ec26                	sd	s1,24(sp)
    800037ba:	e84a                	sd	s2,16(sp)
    800037bc:	e44e                	sd	s3,8(sp)
    800037be:	1800                	add	s0,sp,48
    800037c0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800037c2:	47ad                	li	a5,11
    800037c4:	02b7e863          	bltu	a5,a1,800037f4 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800037c8:	02059793          	sll	a5,a1,0x20
    800037cc:	01e7d593          	srl	a1,a5,0x1e
    800037d0:	00b504b3          	add	s1,a0,a1
    800037d4:	0504a903          	lw	s2,80(s1)
    800037d8:	08091263          	bnez	s2,8000385c <bmap+0xaa>
      addr = balloc(ip->dev);
    800037dc:	4108                	lw	a0,0(a0)
    800037de:	00000097          	auipc	ra,0x0
    800037e2:	e90080e7          	jalr	-368(ra) # 8000366e <balloc>
    800037e6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037ea:	06090963          	beqz	s2,8000385c <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    800037ee:	0524a823          	sw	s2,80(s1)
    800037f2:	a0ad                	j	8000385c <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    800037f4:	ff45849b          	addw	s1,a1,-12
    800037f8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800037fc:	0ff00793          	li	a5,255
    80003800:	08e7e863          	bltu	a5,a4,80003890 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003804:	08052903          	lw	s2,128(a0)
    80003808:	00091f63          	bnez	s2,80003826 <bmap+0x74>
      addr = balloc(ip->dev);
    8000380c:	4108                	lw	a0,0(a0)
    8000380e:	00000097          	auipc	ra,0x0
    80003812:	e60080e7          	jalr	-416(ra) # 8000366e <balloc>
    80003816:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000381a:	04090163          	beqz	s2,8000385c <bmap+0xaa>
    8000381e:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003820:	0929a023          	sw	s2,128(s3)
    80003824:	a011                	j	80003828 <bmap+0x76>
    80003826:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003828:	85ca                	mv	a1,s2
    8000382a:	0009a503          	lw	a0,0(s3)
    8000382e:	00000097          	auipc	ra,0x0
    80003832:	b80080e7          	jalr	-1152(ra) # 800033ae <bread>
    80003836:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003838:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    8000383c:	02049713          	sll	a4,s1,0x20
    80003840:	01e75593          	srl	a1,a4,0x1e
    80003844:	00b784b3          	add	s1,a5,a1
    80003848:	0004a903          	lw	s2,0(s1)
    8000384c:	02090063          	beqz	s2,8000386c <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003850:	8552                	mv	a0,s4
    80003852:	00000097          	auipc	ra,0x0
    80003856:	c8c080e7          	jalr	-884(ra) # 800034de <brelse>
    return addr;
    8000385a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000385c:	854a                	mv	a0,s2
    8000385e:	70a2                	ld	ra,40(sp)
    80003860:	7402                	ld	s0,32(sp)
    80003862:	64e2                	ld	s1,24(sp)
    80003864:	6942                	ld	s2,16(sp)
    80003866:	69a2                	ld	s3,8(sp)
    80003868:	6145                	add	sp,sp,48
    8000386a:	8082                	ret
      addr = balloc(ip->dev);
    8000386c:	0009a503          	lw	a0,0(s3)
    80003870:	00000097          	auipc	ra,0x0
    80003874:	dfe080e7          	jalr	-514(ra) # 8000366e <balloc>
    80003878:	0005091b          	sext.w	s2,a0
      if(addr){
    8000387c:	fc090ae3          	beqz	s2,80003850 <bmap+0x9e>
        a[bn] = addr;
    80003880:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003884:	8552                	mv	a0,s4
    80003886:	00001097          	auipc	ra,0x1
    8000388a:	f02080e7          	jalr	-254(ra) # 80004788 <log_write>
    8000388e:	b7c9                	j	80003850 <bmap+0x9e>
    80003890:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003892:	00005517          	auipc	a0,0x5
    80003896:	cd650513          	add	a0,a0,-810 # 80008568 <__func__.1+0x560>
    8000389a:	ffffd097          	auipc	ra,0xffffd
    8000389e:	cc6080e7          	jalr	-826(ra) # 80000560 <panic>

00000000800038a2 <iget>:
{
    800038a2:	7179                	add	sp,sp,-48
    800038a4:	f406                	sd	ra,40(sp)
    800038a6:	f022                	sd	s0,32(sp)
    800038a8:	ec26                	sd	s1,24(sp)
    800038aa:	e84a                	sd	s2,16(sp)
    800038ac:	e44e                	sd	s3,8(sp)
    800038ae:	e052                	sd	s4,0(sp)
    800038b0:	1800                	add	s0,sp,48
    800038b2:	89aa                	mv	s3,a0
    800038b4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038b6:	0001c517          	auipc	a0,0x1c
    800038ba:	92250513          	add	a0,a0,-1758 # 8001f1d8 <itable>
    800038be:	ffffd097          	auipc	ra,0xffffd
    800038c2:	442080e7          	jalr	1090(ra) # 80000d00 <acquire>
  empty = 0;
    800038c6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038c8:	0001c497          	auipc	s1,0x1c
    800038cc:	92848493          	add	s1,s1,-1752 # 8001f1f0 <itable+0x18>
    800038d0:	0001d697          	auipc	a3,0x1d
    800038d4:	3b068693          	add	a3,a3,944 # 80020c80 <log>
    800038d8:	a039                	j	800038e6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038da:	02090b63          	beqz	s2,80003910 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038de:	08848493          	add	s1,s1,136
    800038e2:	02d48a63          	beq	s1,a3,80003916 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800038e6:	449c                	lw	a5,8(s1)
    800038e8:	fef059e3          	blez	a5,800038da <iget+0x38>
    800038ec:	4098                	lw	a4,0(s1)
    800038ee:	ff3716e3          	bne	a4,s3,800038da <iget+0x38>
    800038f2:	40d8                	lw	a4,4(s1)
    800038f4:	ff4713e3          	bne	a4,s4,800038da <iget+0x38>
      ip->ref++;
    800038f8:	2785                	addw	a5,a5,1
    800038fa:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800038fc:	0001c517          	auipc	a0,0x1c
    80003900:	8dc50513          	add	a0,a0,-1828 # 8001f1d8 <itable>
    80003904:	ffffd097          	auipc	ra,0xffffd
    80003908:	4b0080e7          	jalr	1200(ra) # 80000db4 <release>
      return ip;
    8000390c:	8926                	mv	s2,s1
    8000390e:	a03d                	j	8000393c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003910:	f7f9                	bnez	a5,800038de <iget+0x3c>
      empty = ip;
    80003912:	8926                	mv	s2,s1
    80003914:	b7e9                	j	800038de <iget+0x3c>
  if(empty == 0)
    80003916:	02090c63          	beqz	s2,8000394e <iget+0xac>
  ip->dev = dev;
    8000391a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000391e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003922:	4785                	li	a5,1
    80003924:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003928:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000392c:	0001c517          	auipc	a0,0x1c
    80003930:	8ac50513          	add	a0,a0,-1876 # 8001f1d8 <itable>
    80003934:	ffffd097          	auipc	ra,0xffffd
    80003938:	480080e7          	jalr	1152(ra) # 80000db4 <release>
}
    8000393c:	854a                	mv	a0,s2
    8000393e:	70a2                	ld	ra,40(sp)
    80003940:	7402                	ld	s0,32(sp)
    80003942:	64e2                	ld	s1,24(sp)
    80003944:	6942                	ld	s2,16(sp)
    80003946:	69a2                	ld	s3,8(sp)
    80003948:	6a02                	ld	s4,0(sp)
    8000394a:	6145                	add	sp,sp,48
    8000394c:	8082                	ret
    panic("iget: no inodes");
    8000394e:	00005517          	auipc	a0,0x5
    80003952:	c3250513          	add	a0,a0,-974 # 80008580 <__func__.1+0x578>
    80003956:	ffffd097          	auipc	ra,0xffffd
    8000395a:	c0a080e7          	jalr	-1014(ra) # 80000560 <panic>

000000008000395e <fsinit>:
fsinit(int dev) {
    8000395e:	7179                	add	sp,sp,-48
    80003960:	f406                	sd	ra,40(sp)
    80003962:	f022                	sd	s0,32(sp)
    80003964:	ec26                	sd	s1,24(sp)
    80003966:	e84a                	sd	s2,16(sp)
    80003968:	e44e                	sd	s3,8(sp)
    8000396a:	1800                	add	s0,sp,48
    8000396c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000396e:	4585                	li	a1,1
    80003970:	00000097          	auipc	ra,0x0
    80003974:	a3e080e7          	jalr	-1474(ra) # 800033ae <bread>
    80003978:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000397a:	0001c997          	auipc	s3,0x1c
    8000397e:	83e98993          	add	s3,s3,-1986 # 8001f1b8 <sb>
    80003982:	02000613          	li	a2,32
    80003986:	05850593          	add	a1,a0,88
    8000398a:	854e                	mv	a0,s3
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	4cc080e7          	jalr	1228(ra) # 80000e58 <memmove>
  brelse(bp);
    80003994:	8526                	mv	a0,s1
    80003996:	00000097          	auipc	ra,0x0
    8000399a:	b48080e7          	jalr	-1208(ra) # 800034de <brelse>
  if(sb.magic != FSMAGIC)
    8000399e:	0009a703          	lw	a4,0(s3)
    800039a2:	102037b7          	lui	a5,0x10203
    800039a6:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039aa:	02f71263          	bne	a4,a5,800039ce <fsinit+0x70>
  initlog(dev, &sb);
    800039ae:	0001c597          	auipc	a1,0x1c
    800039b2:	80a58593          	add	a1,a1,-2038 # 8001f1b8 <sb>
    800039b6:	854a                	mv	a0,s2
    800039b8:	00001097          	auipc	ra,0x1
    800039bc:	b60080e7          	jalr	-1184(ra) # 80004518 <initlog>
}
    800039c0:	70a2                	ld	ra,40(sp)
    800039c2:	7402                	ld	s0,32(sp)
    800039c4:	64e2                	ld	s1,24(sp)
    800039c6:	6942                	ld	s2,16(sp)
    800039c8:	69a2                	ld	s3,8(sp)
    800039ca:	6145                	add	sp,sp,48
    800039cc:	8082                	ret
    panic("invalid file system");
    800039ce:	00005517          	auipc	a0,0x5
    800039d2:	bc250513          	add	a0,a0,-1086 # 80008590 <__func__.1+0x588>
    800039d6:	ffffd097          	auipc	ra,0xffffd
    800039da:	b8a080e7          	jalr	-1142(ra) # 80000560 <panic>

00000000800039de <iinit>:
{
    800039de:	7179                	add	sp,sp,-48
    800039e0:	f406                	sd	ra,40(sp)
    800039e2:	f022                	sd	s0,32(sp)
    800039e4:	ec26                	sd	s1,24(sp)
    800039e6:	e84a                	sd	s2,16(sp)
    800039e8:	e44e                	sd	s3,8(sp)
    800039ea:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    800039ec:	00005597          	auipc	a1,0x5
    800039f0:	bbc58593          	add	a1,a1,-1092 # 800085a8 <__func__.1+0x5a0>
    800039f4:	0001b517          	auipc	a0,0x1b
    800039f8:	7e450513          	add	a0,a0,2020 # 8001f1d8 <itable>
    800039fc:	ffffd097          	auipc	ra,0xffffd
    80003a00:	274080e7          	jalr	628(ra) # 80000c70 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a04:	0001b497          	auipc	s1,0x1b
    80003a08:	7fc48493          	add	s1,s1,2044 # 8001f200 <itable+0x28>
    80003a0c:	0001d997          	auipc	s3,0x1d
    80003a10:	28498993          	add	s3,s3,644 # 80020c90 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a14:	00005917          	auipc	s2,0x5
    80003a18:	b9c90913          	add	s2,s2,-1124 # 800085b0 <__func__.1+0x5a8>
    80003a1c:	85ca                	mv	a1,s2
    80003a1e:	8526                	mv	a0,s1
    80003a20:	00001097          	auipc	ra,0x1
    80003a24:	e4c080e7          	jalr	-436(ra) # 8000486c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a28:	08848493          	add	s1,s1,136
    80003a2c:	ff3498e3          	bne	s1,s3,80003a1c <iinit+0x3e>
}
    80003a30:	70a2                	ld	ra,40(sp)
    80003a32:	7402                	ld	s0,32(sp)
    80003a34:	64e2                	ld	s1,24(sp)
    80003a36:	6942                	ld	s2,16(sp)
    80003a38:	69a2                	ld	s3,8(sp)
    80003a3a:	6145                	add	sp,sp,48
    80003a3c:	8082                	ret

0000000080003a3e <ialloc>:
{
    80003a3e:	7139                	add	sp,sp,-64
    80003a40:	fc06                	sd	ra,56(sp)
    80003a42:	f822                	sd	s0,48(sp)
    80003a44:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a46:	0001b717          	auipc	a4,0x1b
    80003a4a:	77e72703          	lw	a4,1918(a4) # 8001f1c4 <sb+0xc>
    80003a4e:	4785                	li	a5,1
    80003a50:	06e7f463          	bgeu	a5,a4,80003ab8 <ialloc+0x7a>
    80003a54:	f426                	sd	s1,40(sp)
    80003a56:	f04a                	sd	s2,32(sp)
    80003a58:	ec4e                	sd	s3,24(sp)
    80003a5a:	e852                	sd	s4,16(sp)
    80003a5c:	e456                	sd	s5,8(sp)
    80003a5e:	e05a                	sd	s6,0(sp)
    80003a60:	8aaa                	mv	s5,a0
    80003a62:	8b2e                	mv	s6,a1
    80003a64:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a66:	0001ba17          	auipc	s4,0x1b
    80003a6a:	752a0a13          	add	s4,s4,1874 # 8001f1b8 <sb>
    80003a6e:	00495593          	srl	a1,s2,0x4
    80003a72:	018a2783          	lw	a5,24(s4)
    80003a76:	9dbd                	addw	a1,a1,a5
    80003a78:	8556                	mv	a0,s5
    80003a7a:	00000097          	auipc	ra,0x0
    80003a7e:	934080e7          	jalr	-1740(ra) # 800033ae <bread>
    80003a82:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a84:	05850993          	add	s3,a0,88
    80003a88:	00f97793          	and	a5,s2,15
    80003a8c:	079a                	sll	a5,a5,0x6
    80003a8e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a90:	00099783          	lh	a5,0(s3)
    80003a94:	cf9d                	beqz	a5,80003ad2 <ialloc+0x94>
    brelse(bp);
    80003a96:	00000097          	auipc	ra,0x0
    80003a9a:	a48080e7          	jalr	-1464(ra) # 800034de <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a9e:	0905                	add	s2,s2,1
    80003aa0:	00ca2703          	lw	a4,12(s4)
    80003aa4:	0009079b          	sext.w	a5,s2
    80003aa8:	fce7e3e3          	bltu	a5,a4,80003a6e <ialloc+0x30>
    80003aac:	74a2                	ld	s1,40(sp)
    80003aae:	7902                	ld	s2,32(sp)
    80003ab0:	69e2                	ld	s3,24(sp)
    80003ab2:	6a42                	ld	s4,16(sp)
    80003ab4:	6aa2                	ld	s5,8(sp)
    80003ab6:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003ab8:	00005517          	auipc	a0,0x5
    80003abc:	b0050513          	add	a0,a0,-1280 # 800085b8 <__func__.1+0x5b0>
    80003ac0:	ffffd097          	auipc	ra,0xffffd
    80003ac4:	afc080e7          	jalr	-1284(ra) # 800005bc <printf>
  return 0;
    80003ac8:	4501                	li	a0,0
}
    80003aca:	70e2                	ld	ra,56(sp)
    80003acc:	7442                	ld	s0,48(sp)
    80003ace:	6121                	add	sp,sp,64
    80003ad0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003ad2:	04000613          	li	a2,64
    80003ad6:	4581                	li	a1,0
    80003ad8:	854e                	mv	a0,s3
    80003ada:	ffffd097          	auipc	ra,0xffffd
    80003ade:	322080e7          	jalr	802(ra) # 80000dfc <memset>
      dip->type = type;
    80003ae2:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003ae6:	8526                	mv	a0,s1
    80003ae8:	00001097          	auipc	ra,0x1
    80003aec:	ca0080e7          	jalr	-864(ra) # 80004788 <log_write>
      brelse(bp);
    80003af0:	8526                	mv	a0,s1
    80003af2:	00000097          	auipc	ra,0x0
    80003af6:	9ec080e7          	jalr	-1556(ra) # 800034de <brelse>
      return iget(dev, inum);
    80003afa:	0009059b          	sext.w	a1,s2
    80003afe:	8556                	mv	a0,s5
    80003b00:	00000097          	auipc	ra,0x0
    80003b04:	da2080e7          	jalr	-606(ra) # 800038a2 <iget>
    80003b08:	74a2                	ld	s1,40(sp)
    80003b0a:	7902                	ld	s2,32(sp)
    80003b0c:	69e2                	ld	s3,24(sp)
    80003b0e:	6a42                	ld	s4,16(sp)
    80003b10:	6aa2                	ld	s5,8(sp)
    80003b12:	6b02                	ld	s6,0(sp)
    80003b14:	bf5d                	j	80003aca <ialloc+0x8c>

0000000080003b16 <iupdate>:
{
    80003b16:	1101                	add	sp,sp,-32
    80003b18:	ec06                	sd	ra,24(sp)
    80003b1a:	e822                	sd	s0,16(sp)
    80003b1c:	e426                	sd	s1,8(sp)
    80003b1e:	e04a                	sd	s2,0(sp)
    80003b20:	1000                	add	s0,sp,32
    80003b22:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b24:	415c                	lw	a5,4(a0)
    80003b26:	0047d79b          	srlw	a5,a5,0x4
    80003b2a:	0001b597          	auipc	a1,0x1b
    80003b2e:	6a65a583          	lw	a1,1702(a1) # 8001f1d0 <sb+0x18>
    80003b32:	9dbd                	addw	a1,a1,a5
    80003b34:	4108                	lw	a0,0(a0)
    80003b36:	00000097          	auipc	ra,0x0
    80003b3a:	878080e7          	jalr	-1928(ra) # 800033ae <bread>
    80003b3e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b40:	05850793          	add	a5,a0,88
    80003b44:	40d8                	lw	a4,4(s1)
    80003b46:	8b3d                	and	a4,a4,15
    80003b48:	071a                	sll	a4,a4,0x6
    80003b4a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003b4c:	04449703          	lh	a4,68(s1)
    80003b50:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003b54:	04649703          	lh	a4,70(s1)
    80003b58:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003b5c:	04849703          	lh	a4,72(s1)
    80003b60:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003b64:	04a49703          	lh	a4,74(s1)
    80003b68:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003b6c:	44f8                	lw	a4,76(s1)
    80003b6e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b70:	03400613          	li	a2,52
    80003b74:	05048593          	add	a1,s1,80
    80003b78:	00c78513          	add	a0,a5,12
    80003b7c:	ffffd097          	auipc	ra,0xffffd
    80003b80:	2dc080e7          	jalr	732(ra) # 80000e58 <memmove>
  log_write(bp);
    80003b84:	854a                	mv	a0,s2
    80003b86:	00001097          	auipc	ra,0x1
    80003b8a:	c02080e7          	jalr	-1022(ra) # 80004788 <log_write>
  brelse(bp);
    80003b8e:	854a                	mv	a0,s2
    80003b90:	00000097          	auipc	ra,0x0
    80003b94:	94e080e7          	jalr	-1714(ra) # 800034de <brelse>
}
    80003b98:	60e2                	ld	ra,24(sp)
    80003b9a:	6442                	ld	s0,16(sp)
    80003b9c:	64a2                	ld	s1,8(sp)
    80003b9e:	6902                	ld	s2,0(sp)
    80003ba0:	6105                	add	sp,sp,32
    80003ba2:	8082                	ret

0000000080003ba4 <idup>:
{
    80003ba4:	1101                	add	sp,sp,-32
    80003ba6:	ec06                	sd	ra,24(sp)
    80003ba8:	e822                	sd	s0,16(sp)
    80003baa:	e426                	sd	s1,8(sp)
    80003bac:	1000                	add	s0,sp,32
    80003bae:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003bb0:	0001b517          	auipc	a0,0x1b
    80003bb4:	62850513          	add	a0,a0,1576 # 8001f1d8 <itable>
    80003bb8:	ffffd097          	auipc	ra,0xffffd
    80003bbc:	148080e7          	jalr	328(ra) # 80000d00 <acquire>
  ip->ref++;
    80003bc0:	449c                	lw	a5,8(s1)
    80003bc2:	2785                	addw	a5,a5,1
    80003bc4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bc6:	0001b517          	auipc	a0,0x1b
    80003bca:	61250513          	add	a0,a0,1554 # 8001f1d8 <itable>
    80003bce:	ffffd097          	auipc	ra,0xffffd
    80003bd2:	1e6080e7          	jalr	486(ra) # 80000db4 <release>
}
    80003bd6:	8526                	mv	a0,s1
    80003bd8:	60e2                	ld	ra,24(sp)
    80003bda:	6442                	ld	s0,16(sp)
    80003bdc:	64a2                	ld	s1,8(sp)
    80003bde:	6105                	add	sp,sp,32
    80003be0:	8082                	ret

0000000080003be2 <ilock>:
{
    80003be2:	1101                	add	sp,sp,-32
    80003be4:	ec06                	sd	ra,24(sp)
    80003be6:	e822                	sd	s0,16(sp)
    80003be8:	e426                	sd	s1,8(sp)
    80003bea:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003bec:	c10d                	beqz	a0,80003c0e <ilock+0x2c>
    80003bee:	84aa                	mv	s1,a0
    80003bf0:	451c                	lw	a5,8(a0)
    80003bf2:	00f05e63          	blez	a5,80003c0e <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003bf6:	0541                	add	a0,a0,16
    80003bf8:	00001097          	auipc	ra,0x1
    80003bfc:	cae080e7          	jalr	-850(ra) # 800048a6 <acquiresleep>
  if(ip->valid == 0){
    80003c00:	40bc                	lw	a5,64(s1)
    80003c02:	cf99                	beqz	a5,80003c20 <ilock+0x3e>
}
    80003c04:	60e2                	ld	ra,24(sp)
    80003c06:	6442                	ld	s0,16(sp)
    80003c08:	64a2                	ld	s1,8(sp)
    80003c0a:	6105                	add	sp,sp,32
    80003c0c:	8082                	ret
    80003c0e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003c10:	00005517          	auipc	a0,0x5
    80003c14:	9c050513          	add	a0,a0,-1600 # 800085d0 <__func__.1+0x5c8>
    80003c18:	ffffd097          	auipc	ra,0xffffd
    80003c1c:	948080e7          	jalr	-1720(ra) # 80000560 <panic>
    80003c20:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c22:	40dc                	lw	a5,4(s1)
    80003c24:	0047d79b          	srlw	a5,a5,0x4
    80003c28:	0001b597          	auipc	a1,0x1b
    80003c2c:	5a85a583          	lw	a1,1448(a1) # 8001f1d0 <sb+0x18>
    80003c30:	9dbd                	addw	a1,a1,a5
    80003c32:	4088                	lw	a0,0(s1)
    80003c34:	fffff097          	auipc	ra,0xfffff
    80003c38:	77a080e7          	jalr	1914(ra) # 800033ae <bread>
    80003c3c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c3e:	05850593          	add	a1,a0,88
    80003c42:	40dc                	lw	a5,4(s1)
    80003c44:	8bbd                	and	a5,a5,15
    80003c46:	079a                	sll	a5,a5,0x6
    80003c48:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c4a:	00059783          	lh	a5,0(a1)
    80003c4e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c52:	00259783          	lh	a5,2(a1)
    80003c56:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c5a:	00459783          	lh	a5,4(a1)
    80003c5e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c62:	00659783          	lh	a5,6(a1)
    80003c66:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c6a:	459c                	lw	a5,8(a1)
    80003c6c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c6e:	03400613          	li	a2,52
    80003c72:	05b1                	add	a1,a1,12
    80003c74:	05048513          	add	a0,s1,80
    80003c78:	ffffd097          	auipc	ra,0xffffd
    80003c7c:	1e0080e7          	jalr	480(ra) # 80000e58 <memmove>
    brelse(bp);
    80003c80:	854a                	mv	a0,s2
    80003c82:	00000097          	auipc	ra,0x0
    80003c86:	85c080e7          	jalr	-1956(ra) # 800034de <brelse>
    ip->valid = 1;
    80003c8a:	4785                	li	a5,1
    80003c8c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c8e:	04449783          	lh	a5,68(s1)
    80003c92:	c399                	beqz	a5,80003c98 <ilock+0xb6>
    80003c94:	6902                	ld	s2,0(sp)
    80003c96:	b7bd                	j	80003c04 <ilock+0x22>
      panic("ilock: no type");
    80003c98:	00005517          	auipc	a0,0x5
    80003c9c:	94050513          	add	a0,a0,-1728 # 800085d8 <__func__.1+0x5d0>
    80003ca0:	ffffd097          	auipc	ra,0xffffd
    80003ca4:	8c0080e7          	jalr	-1856(ra) # 80000560 <panic>

0000000080003ca8 <iunlock>:
{
    80003ca8:	1101                	add	sp,sp,-32
    80003caa:	ec06                	sd	ra,24(sp)
    80003cac:	e822                	sd	s0,16(sp)
    80003cae:	e426                	sd	s1,8(sp)
    80003cb0:	e04a                	sd	s2,0(sp)
    80003cb2:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003cb4:	c905                	beqz	a0,80003ce4 <iunlock+0x3c>
    80003cb6:	84aa                	mv	s1,a0
    80003cb8:	01050913          	add	s2,a0,16
    80003cbc:	854a                	mv	a0,s2
    80003cbe:	00001097          	auipc	ra,0x1
    80003cc2:	c82080e7          	jalr	-894(ra) # 80004940 <holdingsleep>
    80003cc6:	cd19                	beqz	a0,80003ce4 <iunlock+0x3c>
    80003cc8:	449c                	lw	a5,8(s1)
    80003cca:	00f05d63          	blez	a5,80003ce4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003cce:	854a                	mv	a0,s2
    80003cd0:	00001097          	auipc	ra,0x1
    80003cd4:	c2c080e7          	jalr	-980(ra) # 800048fc <releasesleep>
}
    80003cd8:	60e2                	ld	ra,24(sp)
    80003cda:	6442                	ld	s0,16(sp)
    80003cdc:	64a2                	ld	s1,8(sp)
    80003cde:	6902                	ld	s2,0(sp)
    80003ce0:	6105                	add	sp,sp,32
    80003ce2:	8082                	ret
    panic("iunlock");
    80003ce4:	00005517          	auipc	a0,0x5
    80003ce8:	90450513          	add	a0,a0,-1788 # 800085e8 <__func__.1+0x5e0>
    80003cec:	ffffd097          	auipc	ra,0xffffd
    80003cf0:	874080e7          	jalr	-1932(ra) # 80000560 <panic>

0000000080003cf4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003cf4:	7179                	add	sp,sp,-48
    80003cf6:	f406                	sd	ra,40(sp)
    80003cf8:	f022                	sd	s0,32(sp)
    80003cfa:	ec26                	sd	s1,24(sp)
    80003cfc:	e84a                	sd	s2,16(sp)
    80003cfe:	e44e                	sd	s3,8(sp)
    80003d00:	1800                	add	s0,sp,48
    80003d02:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d04:	05050493          	add	s1,a0,80
    80003d08:	08050913          	add	s2,a0,128
    80003d0c:	a021                	j	80003d14 <itrunc+0x20>
    80003d0e:	0491                	add	s1,s1,4
    80003d10:	01248d63          	beq	s1,s2,80003d2a <itrunc+0x36>
    if(ip->addrs[i]){
    80003d14:	408c                	lw	a1,0(s1)
    80003d16:	dde5                	beqz	a1,80003d0e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003d18:	0009a503          	lw	a0,0(s3)
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	8d6080e7          	jalr	-1834(ra) # 800035f2 <bfree>
      ip->addrs[i] = 0;
    80003d24:	0004a023          	sw	zero,0(s1)
    80003d28:	b7dd                	j	80003d0e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d2a:	0809a583          	lw	a1,128(s3)
    80003d2e:	ed99                	bnez	a1,80003d4c <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d30:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d34:	854e                	mv	a0,s3
    80003d36:	00000097          	auipc	ra,0x0
    80003d3a:	de0080e7          	jalr	-544(ra) # 80003b16 <iupdate>
}
    80003d3e:	70a2                	ld	ra,40(sp)
    80003d40:	7402                	ld	s0,32(sp)
    80003d42:	64e2                	ld	s1,24(sp)
    80003d44:	6942                	ld	s2,16(sp)
    80003d46:	69a2                	ld	s3,8(sp)
    80003d48:	6145                	add	sp,sp,48
    80003d4a:	8082                	ret
    80003d4c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d4e:	0009a503          	lw	a0,0(s3)
    80003d52:	fffff097          	auipc	ra,0xfffff
    80003d56:	65c080e7          	jalr	1628(ra) # 800033ae <bread>
    80003d5a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d5c:	05850493          	add	s1,a0,88
    80003d60:	45850913          	add	s2,a0,1112
    80003d64:	a021                	j	80003d6c <itrunc+0x78>
    80003d66:	0491                	add	s1,s1,4
    80003d68:	01248b63          	beq	s1,s2,80003d7e <itrunc+0x8a>
      if(a[j])
    80003d6c:	408c                	lw	a1,0(s1)
    80003d6e:	dde5                	beqz	a1,80003d66 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003d70:	0009a503          	lw	a0,0(s3)
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	87e080e7          	jalr	-1922(ra) # 800035f2 <bfree>
    80003d7c:	b7ed                	j	80003d66 <itrunc+0x72>
    brelse(bp);
    80003d7e:	8552                	mv	a0,s4
    80003d80:	fffff097          	auipc	ra,0xfffff
    80003d84:	75e080e7          	jalr	1886(ra) # 800034de <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d88:	0809a583          	lw	a1,128(s3)
    80003d8c:	0009a503          	lw	a0,0(s3)
    80003d90:	00000097          	auipc	ra,0x0
    80003d94:	862080e7          	jalr	-1950(ra) # 800035f2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d98:	0809a023          	sw	zero,128(s3)
    80003d9c:	6a02                	ld	s4,0(sp)
    80003d9e:	bf49                	j	80003d30 <itrunc+0x3c>

0000000080003da0 <iput>:
{
    80003da0:	1101                	add	sp,sp,-32
    80003da2:	ec06                	sd	ra,24(sp)
    80003da4:	e822                	sd	s0,16(sp)
    80003da6:	e426                	sd	s1,8(sp)
    80003da8:	1000                	add	s0,sp,32
    80003daa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003dac:	0001b517          	auipc	a0,0x1b
    80003db0:	42c50513          	add	a0,a0,1068 # 8001f1d8 <itable>
    80003db4:	ffffd097          	auipc	ra,0xffffd
    80003db8:	f4c080e7          	jalr	-180(ra) # 80000d00 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dbc:	4498                	lw	a4,8(s1)
    80003dbe:	4785                	li	a5,1
    80003dc0:	02f70263          	beq	a4,a5,80003de4 <iput+0x44>
  ip->ref--;
    80003dc4:	449c                	lw	a5,8(s1)
    80003dc6:	37fd                	addw	a5,a5,-1
    80003dc8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dca:	0001b517          	auipc	a0,0x1b
    80003dce:	40e50513          	add	a0,a0,1038 # 8001f1d8 <itable>
    80003dd2:	ffffd097          	auipc	ra,0xffffd
    80003dd6:	fe2080e7          	jalr	-30(ra) # 80000db4 <release>
}
    80003dda:	60e2                	ld	ra,24(sp)
    80003ddc:	6442                	ld	s0,16(sp)
    80003dde:	64a2                	ld	s1,8(sp)
    80003de0:	6105                	add	sp,sp,32
    80003de2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003de4:	40bc                	lw	a5,64(s1)
    80003de6:	dff9                	beqz	a5,80003dc4 <iput+0x24>
    80003de8:	04a49783          	lh	a5,74(s1)
    80003dec:	ffe1                	bnez	a5,80003dc4 <iput+0x24>
    80003dee:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003df0:	01048913          	add	s2,s1,16
    80003df4:	854a                	mv	a0,s2
    80003df6:	00001097          	auipc	ra,0x1
    80003dfa:	ab0080e7          	jalr	-1360(ra) # 800048a6 <acquiresleep>
    release(&itable.lock);
    80003dfe:	0001b517          	auipc	a0,0x1b
    80003e02:	3da50513          	add	a0,a0,986 # 8001f1d8 <itable>
    80003e06:	ffffd097          	auipc	ra,0xffffd
    80003e0a:	fae080e7          	jalr	-82(ra) # 80000db4 <release>
    itrunc(ip);
    80003e0e:	8526                	mv	a0,s1
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	ee4080e7          	jalr	-284(ra) # 80003cf4 <itrunc>
    ip->type = 0;
    80003e18:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e1c:	8526                	mv	a0,s1
    80003e1e:	00000097          	auipc	ra,0x0
    80003e22:	cf8080e7          	jalr	-776(ra) # 80003b16 <iupdate>
    ip->valid = 0;
    80003e26:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e2a:	854a                	mv	a0,s2
    80003e2c:	00001097          	auipc	ra,0x1
    80003e30:	ad0080e7          	jalr	-1328(ra) # 800048fc <releasesleep>
    acquire(&itable.lock);
    80003e34:	0001b517          	auipc	a0,0x1b
    80003e38:	3a450513          	add	a0,a0,932 # 8001f1d8 <itable>
    80003e3c:	ffffd097          	auipc	ra,0xffffd
    80003e40:	ec4080e7          	jalr	-316(ra) # 80000d00 <acquire>
    80003e44:	6902                	ld	s2,0(sp)
    80003e46:	bfbd                	j	80003dc4 <iput+0x24>

0000000080003e48 <iunlockput>:
{
    80003e48:	1101                	add	sp,sp,-32
    80003e4a:	ec06                	sd	ra,24(sp)
    80003e4c:	e822                	sd	s0,16(sp)
    80003e4e:	e426                	sd	s1,8(sp)
    80003e50:	1000                	add	s0,sp,32
    80003e52:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e54:	00000097          	auipc	ra,0x0
    80003e58:	e54080e7          	jalr	-428(ra) # 80003ca8 <iunlock>
  iput(ip);
    80003e5c:	8526                	mv	a0,s1
    80003e5e:	00000097          	auipc	ra,0x0
    80003e62:	f42080e7          	jalr	-190(ra) # 80003da0 <iput>
}
    80003e66:	60e2                	ld	ra,24(sp)
    80003e68:	6442                	ld	s0,16(sp)
    80003e6a:	64a2                	ld	s1,8(sp)
    80003e6c:	6105                	add	sp,sp,32
    80003e6e:	8082                	ret

0000000080003e70 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e70:	1141                	add	sp,sp,-16
    80003e72:	e422                	sd	s0,8(sp)
    80003e74:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003e76:	411c                	lw	a5,0(a0)
    80003e78:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e7a:	415c                	lw	a5,4(a0)
    80003e7c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e7e:	04451783          	lh	a5,68(a0)
    80003e82:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e86:	04a51783          	lh	a5,74(a0)
    80003e8a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e8e:	04c56783          	lwu	a5,76(a0)
    80003e92:	e99c                	sd	a5,16(a1)
}
    80003e94:	6422                	ld	s0,8(sp)
    80003e96:	0141                	add	sp,sp,16
    80003e98:	8082                	ret

0000000080003e9a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e9a:	457c                	lw	a5,76(a0)
    80003e9c:	10d7e563          	bltu	a5,a3,80003fa6 <readi+0x10c>
{
    80003ea0:	7159                	add	sp,sp,-112
    80003ea2:	f486                	sd	ra,104(sp)
    80003ea4:	f0a2                	sd	s0,96(sp)
    80003ea6:	eca6                	sd	s1,88(sp)
    80003ea8:	e0d2                	sd	s4,64(sp)
    80003eaa:	fc56                	sd	s5,56(sp)
    80003eac:	f85a                	sd	s6,48(sp)
    80003eae:	f45e                	sd	s7,40(sp)
    80003eb0:	1880                	add	s0,sp,112
    80003eb2:	8b2a                	mv	s6,a0
    80003eb4:	8bae                	mv	s7,a1
    80003eb6:	8a32                	mv	s4,a2
    80003eb8:	84b6                	mv	s1,a3
    80003eba:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ebc:	9f35                	addw	a4,a4,a3
    return 0;
    80003ebe:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ec0:	0cd76a63          	bltu	a4,a3,80003f94 <readi+0xfa>
    80003ec4:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003ec6:	00e7f463          	bgeu	a5,a4,80003ece <readi+0x34>
    n = ip->size - off;
    80003eca:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ece:	0a0a8963          	beqz	s5,80003f80 <readi+0xe6>
    80003ed2:	e8ca                	sd	s2,80(sp)
    80003ed4:	f062                	sd	s8,32(sp)
    80003ed6:	ec66                	sd	s9,24(sp)
    80003ed8:	e86a                	sd	s10,16(sp)
    80003eda:	e46e                	sd	s11,8(sp)
    80003edc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ede:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ee2:	5c7d                	li	s8,-1
    80003ee4:	a82d                	j	80003f1e <readi+0x84>
    80003ee6:	020d1d93          	sll	s11,s10,0x20
    80003eea:	020ddd93          	srl	s11,s11,0x20
    80003eee:	05890613          	add	a2,s2,88
    80003ef2:	86ee                	mv	a3,s11
    80003ef4:	963a                	add	a2,a2,a4
    80003ef6:	85d2                	mv	a1,s4
    80003ef8:	855e                	mv	a0,s7
    80003efa:	fffff097          	auipc	ra,0xfffff
    80003efe:	8c6080e7          	jalr	-1850(ra) # 800027c0 <either_copyout>
    80003f02:	05850d63          	beq	a0,s8,80003f5c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f06:	854a                	mv	a0,s2
    80003f08:	fffff097          	auipc	ra,0xfffff
    80003f0c:	5d6080e7          	jalr	1494(ra) # 800034de <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f10:	013d09bb          	addw	s3,s10,s3
    80003f14:	009d04bb          	addw	s1,s10,s1
    80003f18:	9a6e                	add	s4,s4,s11
    80003f1a:	0559fd63          	bgeu	s3,s5,80003f74 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003f1e:	00a4d59b          	srlw	a1,s1,0xa
    80003f22:	855a                	mv	a0,s6
    80003f24:	00000097          	auipc	ra,0x0
    80003f28:	88e080e7          	jalr	-1906(ra) # 800037b2 <bmap>
    80003f2c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f30:	c9b1                	beqz	a1,80003f84 <readi+0xea>
    bp = bread(ip->dev, addr);
    80003f32:	000b2503          	lw	a0,0(s6)
    80003f36:	fffff097          	auipc	ra,0xfffff
    80003f3a:	478080e7          	jalr	1144(ra) # 800033ae <bread>
    80003f3e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f40:	3ff4f713          	and	a4,s1,1023
    80003f44:	40ec87bb          	subw	a5,s9,a4
    80003f48:	413a86bb          	subw	a3,s5,s3
    80003f4c:	8d3e                	mv	s10,a5
    80003f4e:	2781                	sext.w	a5,a5
    80003f50:	0006861b          	sext.w	a2,a3
    80003f54:	f8f679e3          	bgeu	a2,a5,80003ee6 <readi+0x4c>
    80003f58:	8d36                	mv	s10,a3
    80003f5a:	b771                	j	80003ee6 <readi+0x4c>
      brelse(bp);
    80003f5c:	854a                	mv	a0,s2
    80003f5e:	fffff097          	auipc	ra,0xfffff
    80003f62:	580080e7          	jalr	1408(ra) # 800034de <brelse>
      tot = -1;
    80003f66:	59fd                	li	s3,-1
      break;
    80003f68:	6946                	ld	s2,80(sp)
    80003f6a:	7c02                	ld	s8,32(sp)
    80003f6c:	6ce2                	ld	s9,24(sp)
    80003f6e:	6d42                	ld	s10,16(sp)
    80003f70:	6da2                	ld	s11,8(sp)
    80003f72:	a831                	j	80003f8e <readi+0xf4>
    80003f74:	6946                	ld	s2,80(sp)
    80003f76:	7c02                	ld	s8,32(sp)
    80003f78:	6ce2                	ld	s9,24(sp)
    80003f7a:	6d42                	ld	s10,16(sp)
    80003f7c:	6da2                	ld	s11,8(sp)
    80003f7e:	a801                	j	80003f8e <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f80:	89d6                	mv	s3,s5
    80003f82:	a031                	j	80003f8e <readi+0xf4>
    80003f84:	6946                	ld	s2,80(sp)
    80003f86:	7c02                	ld	s8,32(sp)
    80003f88:	6ce2                	ld	s9,24(sp)
    80003f8a:	6d42                	ld	s10,16(sp)
    80003f8c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003f8e:	0009851b          	sext.w	a0,s3
    80003f92:	69a6                	ld	s3,72(sp)
}
    80003f94:	70a6                	ld	ra,104(sp)
    80003f96:	7406                	ld	s0,96(sp)
    80003f98:	64e6                	ld	s1,88(sp)
    80003f9a:	6a06                	ld	s4,64(sp)
    80003f9c:	7ae2                	ld	s5,56(sp)
    80003f9e:	7b42                	ld	s6,48(sp)
    80003fa0:	7ba2                	ld	s7,40(sp)
    80003fa2:	6165                	add	sp,sp,112
    80003fa4:	8082                	ret
    return 0;
    80003fa6:	4501                	li	a0,0
}
    80003fa8:	8082                	ret

0000000080003faa <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003faa:	457c                	lw	a5,76(a0)
    80003fac:	10d7ee63          	bltu	a5,a3,800040c8 <writei+0x11e>
{
    80003fb0:	7159                	add	sp,sp,-112
    80003fb2:	f486                	sd	ra,104(sp)
    80003fb4:	f0a2                	sd	s0,96(sp)
    80003fb6:	e8ca                	sd	s2,80(sp)
    80003fb8:	e0d2                	sd	s4,64(sp)
    80003fba:	fc56                	sd	s5,56(sp)
    80003fbc:	f85a                	sd	s6,48(sp)
    80003fbe:	f45e                	sd	s7,40(sp)
    80003fc0:	1880                	add	s0,sp,112
    80003fc2:	8aaa                	mv	s5,a0
    80003fc4:	8bae                	mv	s7,a1
    80003fc6:	8a32                	mv	s4,a2
    80003fc8:	8936                	mv	s2,a3
    80003fca:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fcc:	00e687bb          	addw	a5,a3,a4
    80003fd0:	0ed7ee63          	bltu	a5,a3,800040cc <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003fd4:	00043737          	lui	a4,0x43
    80003fd8:	0ef76c63          	bltu	a4,a5,800040d0 <writei+0x126>
    80003fdc:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fde:	0c0b0d63          	beqz	s6,800040b8 <writei+0x10e>
    80003fe2:	eca6                	sd	s1,88(sp)
    80003fe4:	f062                	sd	s8,32(sp)
    80003fe6:	ec66                	sd	s9,24(sp)
    80003fe8:	e86a                	sd	s10,16(sp)
    80003fea:	e46e                	sd	s11,8(sp)
    80003fec:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fee:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ff2:	5c7d                	li	s8,-1
    80003ff4:	a091                	j	80004038 <writei+0x8e>
    80003ff6:	020d1d93          	sll	s11,s10,0x20
    80003ffa:	020ddd93          	srl	s11,s11,0x20
    80003ffe:	05848513          	add	a0,s1,88
    80004002:	86ee                	mv	a3,s11
    80004004:	8652                	mv	a2,s4
    80004006:	85de                	mv	a1,s7
    80004008:	953a                	add	a0,a0,a4
    8000400a:	fffff097          	auipc	ra,0xfffff
    8000400e:	80c080e7          	jalr	-2036(ra) # 80002816 <either_copyin>
    80004012:	07850263          	beq	a0,s8,80004076 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004016:	8526                	mv	a0,s1
    80004018:	00000097          	auipc	ra,0x0
    8000401c:	770080e7          	jalr	1904(ra) # 80004788 <log_write>
    brelse(bp);
    80004020:	8526                	mv	a0,s1
    80004022:	fffff097          	auipc	ra,0xfffff
    80004026:	4bc080e7          	jalr	1212(ra) # 800034de <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000402a:	013d09bb          	addw	s3,s10,s3
    8000402e:	012d093b          	addw	s2,s10,s2
    80004032:	9a6e                	add	s4,s4,s11
    80004034:	0569f663          	bgeu	s3,s6,80004080 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004038:	00a9559b          	srlw	a1,s2,0xa
    8000403c:	8556                	mv	a0,s5
    8000403e:	fffff097          	auipc	ra,0xfffff
    80004042:	774080e7          	jalr	1908(ra) # 800037b2 <bmap>
    80004046:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000404a:	c99d                	beqz	a1,80004080 <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000404c:	000aa503          	lw	a0,0(s5)
    80004050:	fffff097          	auipc	ra,0xfffff
    80004054:	35e080e7          	jalr	862(ra) # 800033ae <bread>
    80004058:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000405a:	3ff97713          	and	a4,s2,1023
    8000405e:	40ec87bb          	subw	a5,s9,a4
    80004062:	413b06bb          	subw	a3,s6,s3
    80004066:	8d3e                	mv	s10,a5
    80004068:	2781                	sext.w	a5,a5
    8000406a:	0006861b          	sext.w	a2,a3
    8000406e:	f8f674e3          	bgeu	a2,a5,80003ff6 <writei+0x4c>
    80004072:	8d36                	mv	s10,a3
    80004074:	b749                	j	80003ff6 <writei+0x4c>
      brelse(bp);
    80004076:	8526                	mv	a0,s1
    80004078:	fffff097          	auipc	ra,0xfffff
    8000407c:	466080e7          	jalr	1126(ra) # 800034de <brelse>
  }

  if(off > ip->size)
    80004080:	04caa783          	lw	a5,76(s5)
    80004084:	0327fc63          	bgeu	a5,s2,800040bc <writei+0x112>
    ip->size = off;
    80004088:	052aa623          	sw	s2,76(s5)
    8000408c:	64e6                	ld	s1,88(sp)
    8000408e:	7c02                	ld	s8,32(sp)
    80004090:	6ce2                	ld	s9,24(sp)
    80004092:	6d42                	ld	s10,16(sp)
    80004094:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004096:	8556                	mv	a0,s5
    80004098:	00000097          	auipc	ra,0x0
    8000409c:	a7e080e7          	jalr	-1410(ra) # 80003b16 <iupdate>

  return tot;
    800040a0:	0009851b          	sext.w	a0,s3
    800040a4:	69a6                	ld	s3,72(sp)
}
    800040a6:	70a6                	ld	ra,104(sp)
    800040a8:	7406                	ld	s0,96(sp)
    800040aa:	6946                	ld	s2,80(sp)
    800040ac:	6a06                	ld	s4,64(sp)
    800040ae:	7ae2                	ld	s5,56(sp)
    800040b0:	7b42                	ld	s6,48(sp)
    800040b2:	7ba2                	ld	s7,40(sp)
    800040b4:	6165                	add	sp,sp,112
    800040b6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040b8:	89da                	mv	s3,s6
    800040ba:	bff1                	j	80004096 <writei+0xec>
    800040bc:	64e6                	ld	s1,88(sp)
    800040be:	7c02                	ld	s8,32(sp)
    800040c0:	6ce2                	ld	s9,24(sp)
    800040c2:	6d42                	ld	s10,16(sp)
    800040c4:	6da2                	ld	s11,8(sp)
    800040c6:	bfc1                	j	80004096 <writei+0xec>
    return -1;
    800040c8:	557d                	li	a0,-1
}
    800040ca:	8082                	ret
    return -1;
    800040cc:	557d                	li	a0,-1
    800040ce:	bfe1                	j	800040a6 <writei+0xfc>
    return -1;
    800040d0:	557d                	li	a0,-1
    800040d2:	bfd1                	j	800040a6 <writei+0xfc>

00000000800040d4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040d4:	1141                	add	sp,sp,-16
    800040d6:	e406                	sd	ra,8(sp)
    800040d8:	e022                	sd	s0,0(sp)
    800040da:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040dc:	4639                	li	a2,14
    800040de:	ffffd097          	auipc	ra,0xffffd
    800040e2:	dee080e7          	jalr	-530(ra) # 80000ecc <strncmp>
}
    800040e6:	60a2                	ld	ra,8(sp)
    800040e8:	6402                	ld	s0,0(sp)
    800040ea:	0141                	add	sp,sp,16
    800040ec:	8082                	ret

00000000800040ee <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040ee:	7139                	add	sp,sp,-64
    800040f0:	fc06                	sd	ra,56(sp)
    800040f2:	f822                	sd	s0,48(sp)
    800040f4:	f426                	sd	s1,40(sp)
    800040f6:	f04a                	sd	s2,32(sp)
    800040f8:	ec4e                	sd	s3,24(sp)
    800040fa:	e852                	sd	s4,16(sp)
    800040fc:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040fe:	04451703          	lh	a4,68(a0)
    80004102:	4785                	li	a5,1
    80004104:	00f71a63          	bne	a4,a5,80004118 <dirlookup+0x2a>
    80004108:	892a                	mv	s2,a0
    8000410a:	89ae                	mv	s3,a1
    8000410c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000410e:	457c                	lw	a5,76(a0)
    80004110:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004112:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004114:	e79d                	bnez	a5,80004142 <dirlookup+0x54>
    80004116:	a8a5                	j	8000418e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004118:	00004517          	auipc	a0,0x4
    8000411c:	4d850513          	add	a0,a0,1240 # 800085f0 <__func__.1+0x5e8>
    80004120:	ffffc097          	auipc	ra,0xffffc
    80004124:	440080e7          	jalr	1088(ra) # 80000560 <panic>
      panic("dirlookup read");
    80004128:	00004517          	auipc	a0,0x4
    8000412c:	4e050513          	add	a0,a0,1248 # 80008608 <__func__.1+0x600>
    80004130:	ffffc097          	auipc	ra,0xffffc
    80004134:	430080e7          	jalr	1072(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004138:	24c1                	addw	s1,s1,16
    8000413a:	04c92783          	lw	a5,76(s2)
    8000413e:	04f4f763          	bgeu	s1,a5,8000418c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004142:	4741                	li	a4,16
    80004144:	86a6                	mv	a3,s1
    80004146:	fc040613          	add	a2,s0,-64
    8000414a:	4581                	li	a1,0
    8000414c:	854a                	mv	a0,s2
    8000414e:	00000097          	auipc	ra,0x0
    80004152:	d4c080e7          	jalr	-692(ra) # 80003e9a <readi>
    80004156:	47c1                	li	a5,16
    80004158:	fcf518e3          	bne	a0,a5,80004128 <dirlookup+0x3a>
    if(de.inum == 0)
    8000415c:	fc045783          	lhu	a5,-64(s0)
    80004160:	dfe1                	beqz	a5,80004138 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004162:	fc240593          	add	a1,s0,-62
    80004166:	854e                	mv	a0,s3
    80004168:	00000097          	auipc	ra,0x0
    8000416c:	f6c080e7          	jalr	-148(ra) # 800040d4 <namecmp>
    80004170:	f561                	bnez	a0,80004138 <dirlookup+0x4a>
      if(poff)
    80004172:	000a0463          	beqz	s4,8000417a <dirlookup+0x8c>
        *poff = off;
    80004176:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000417a:	fc045583          	lhu	a1,-64(s0)
    8000417e:	00092503          	lw	a0,0(s2)
    80004182:	fffff097          	auipc	ra,0xfffff
    80004186:	720080e7          	jalr	1824(ra) # 800038a2 <iget>
    8000418a:	a011                	j	8000418e <dirlookup+0xa0>
  return 0;
    8000418c:	4501                	li	a0,0
}
    8000418e:	70e2                	ld	ra,56(sp)
    80004190:	7442                	ld	s0,48(sp)
    80004192:	74a2                	ld	s1,40(sp)
    80004194:	7902                	ld	s2,32(sp)
    80004196:	69e2                	ld	s3,24(sp)
    80004198:	6a42                	ld	s4,16(sp)
    8000419a:	6121                	add	sp,sp,64
    8000419c:	8082                	ret

000000008000419e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000419e:	711d                	add	sp,sp,-96
    800041a0:	ec86                	sd	ra,88(sp)
    800041a2:	e8a2                	sd	s0,80(sp)
    800041a4:	e4a6                	sd	s1,72(sp)
    800041a6:	e0ca                	sd	s2,64(sp)
    800041a8:	fc4e                	sd	s3,56(sp)
    800041aa:	f852                	sd	s4,48(sp)
    800041ac:	f456                	sd	s5,40(sp)
    800041ae:	f05a                	sd	s6,32(sp)
    800041b0:	ec5e                	sd	s7,24(sp)
    800041b2:	e862                	sd	s8,16(sp)
    800041b4:	e466                	sd	s9,8(sp)
    800041b6:	1080                	add	s0,sp,96
    800041b8:	84aa                	mv	s1,a0
    800041ba:	8b2e                	mv	s6,a1
    800041bc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041be:	00054703          	lbu	a4,0(a0)
    800041c2:	02f00793          	li	a5,47
    800041c6:	02f70263          	beq	a4,a5,800041ea <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800041ca:	ffffe097          	auipc	ra,0xffffe
    800041ce:	a3c080e7          	jalr	-1476(ra) # 80001c06 <myproc>
    800041d2:	15053503          	ld	a0,336(a0)
    800041d6:	00000097          	auipc	ra,0x0
    800041da:	9ce080e7          	jalr	-1586(ra) # 80003ba4 <idup>
    800041de:	8a2a                	mv	s4,a0
  while(*path == '/')
    800041e0:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800041e4:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041e6:	4b85                	li	s7,1
    800041e8:	a875                	j	800042a4 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    800041ea:	4585                	li	a1,1
    800041ec:	4505                	li	a0,1
    800041ee:	fffff097          	auipc	ra,0xfffff
    800041f2:	6b4080e7          	jalr	1716(ra) # 800038a2 <iget>
    800041f6:	8a2a                	mv	s4,a0
    800041f8:	b7e5                	j	800041e0 <namex+0x42>
      iunlockput(ip);
    800041fa:	8552                	mv	a0,s4
    800041fc:	00000097          	auipc	ra,0x0
    80004200:	c4c080e7          	jalr	-948(ra) # 80003e48 <iunlockput>
      return 0;
    80004204:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004206:	8552                	mv	a0,s4
    80004208:	60e6                	ld	ra,88(sp)
    8000420a:	6446                	ld	s0,80(sp)
    8000420c:	64a6                	ld	s1,72(sp)
    8000420e:	6906                	ld	s2,64(sp)
    80004210:	79e2                	ld	s3,56(sp)
    80004212:	7a42                	ld	s4,48(sp)
    80004214:	7aa2                	ld	s5,40(sp)
    80004216:	7b02                	ld	s6,32(sp)
    80004218:	6be2                	ld	s7,24(sp)
    8000421a:	6c42                	ld	s8,16(sp)
    8000421c:	6ca2                	ld	s9,8(sp)
    8000421e:	6125                	add	sp,sp,96
    80004220:	8082                	ret
      iunlock(ip);
    80004222:	8552                	mv	a0,s4
    80004224:	00000097          	auipc	ra,0x0
    80004228:	a84080e7          	jalr	-1404(ra) # 80003ca8 <iunlock>
      return ip;
    8000422c:	bfe9                	j	80004206 <namex+0x68>
      iunlockput(ip);
    8000422e:	8552                	mv	a0,s4
    80004230:	00000097          	auipc	ra,0x0
    80004234:	c18080e7          	jalr	-1000(ra) # 80003e48 <iunlockput>
      return 0;
    80004238:	8a4e                	mv	s4,s3
    8000423a:	b7f1                	j	80004206 <namex+0x68>
  len = path - s;
    8000423c:	40998633          	sub	a2,s3,s1
    80004240:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004244:	099c5863          	bge	s8,s9,800042d4 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80004248:	4639                	li	a2,14
    8000424a:	85a6                	mv	a1,s1
    8000424c:	8556                	mv	a0,s5
    8000424e:	ffffd097          	auipc	ra,0xffffd
    80004252:	c0a080e7          	jalr	-1014(ra) # 80000e58 <memmove>
    80004256:	84ce                	mv	s1,s3
  while(*path == '/')
    80004258:	0004c783          	lbu	a5,0(s1)
    8000425c:	01279763          	bne	a5,s2,8000426a <namex+0xcc>
    path++;
    80004260:	0485                	add	s1,s1,1
  while(*path == '/')
    80004262:	0004c783          	lbu	a5,0(s1)
    80004266:	ff278de3          	beq	a5,s2,80004260 <namex+0xc2>
    ilock(ip);
    8000426a:	8552                	mv	a0,s4
    8000426c:	00000097          	auipc	ra,0x0
    80004270:	976080e7          	jalr	-1674(ra) # 80003be2 <ilock>
    if(ip->type != T_DIR){
    80004274:	044a1783          	lh	a5,68(s4)
    80004278:	f97791e3          	bne	a5,s7,800041fa <namex+0x5c>
    if(nameiparent && *path == '\0'){
    8000427c:	000b0563          	beqz	s6,80004286 <namex+0xe8>
    80004280:	0004c783          	lbu	a5,0(s1)
    80004284:	dfd9                	beqz	a5,80004222 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004286:	4601                	li	a2,0
    80004288:	85d6                	mv	a1,s5
    8000428a:	8552                	mv	a0,s4
    8000428c:	00000097          	auipc	ra,0x0
    80004290:	e62080e7          	jalr	-414(ra) # 800040ee <dirlookup>
    80004294:	89aa                	mv	s3,a0
    80004296:	dd41                	beqz	a0,8000422e <namex+0x90>
    iunlockput(ip);
    80004298:	8552                	mv	a0,s4
    8000429a:	00000097          	auipc	ra,0x0
    8000429e:	bae080e7          	jalr	-1106(ra) # 80003e48 <iunlockput>
    ip = next;
    800042a2:	8a4e                	mv	s4,s3
  while(*path == '/')
    800042a4:	0004c783          	lbu	a5,0(s1)
    800042a8:	01279763          	bne	a5,s2,800042b6 <namex+0x118>
    path++;
    800042ac:	0485                	add	s1,s1,1
  while(*path == '/')
    800042ae:	0004c783          	lbu	a5,0(s1)
    800042b2:	ff278de3          	beq	a5,s2,800042ac <namex+0x10e>
  if(*path == 0)
    800042b6:	cb9d                	beqz	a5,800042ec <namex+0x14e>
  while(*path != '/' && *path != 0)
    800042b8:	0004c783          	lbu	a5,0(s1)
    800042bc:	89a6                	mv	s3,s1
  len = path - s;
    800042be:	4c81                	li	s9,0
    800042c0:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800042c2:	01278963          	beq	a5,s2,800042d4 <namex+0x136>
    800042c6:	dbbd                	beqz	a5,8000423c <namex+0x9e>
    path++;
    800042c8:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    800042ca:	0009c783          	lbu	a5,0(s3)
    800042ce:	ff279ce3          	bne	a5,s2,800042c6 <namex+0x128>
    800042d2:	b7ad                	j	8000423c <namex+0x9e>
    memmove(name, s, len);
    800042d4:	2601                	sext.w	a2,a2
    800042d6:	85a6                	mv	a1,s1
    800042d8:	8556                	mv	a0,s5
    800042da:	ffffd097          	auipc	ra,0xffffd
    800042de:	b7e080e7          	jalr	-1154(ra) # 80000e58 <memmove>
    name[len] = 0;
    800042e2:	9cd6                	add	s9,s9,s5
    800042e4:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800042e8:	84ce                	mv	s1,s3
    800042ea:	b7bd                	j	80004258 <namex+0xba>
  if(nameiparent){
    800042ec:	f00b0de3          	beqz	s6,80004206 <namex+0x68>
    iput(ip);
    800042f0:	8552                	mv	a0,s4
    800042f2:	00000097          	auipc	ra,0x0
    800042f6:	aae080e7          	jalr	-1362(ra) # 80003da0 <iput>
    return 0;
    800042fa:	4a01                	li	s4,0
    800042fc:	b729                	j	80004206 <namex+0x68>

00000000800042fe <dirlink>:
{
    800042fe:	7139                	add	sp,sp,-64
    80004300:	fc06                	sd	ra,56(sp)
    80004302:	f822                	sd	s0,48(sp)
    80004304:	f04a                	sd	s2,32(sp)
    80004306:	ec4e                	sd	s3,24(sp)
    80004308:	e852                	sd	s4,16(sp)
    8000430a:	0080                	add	s0,sp,64
    8000430c:	892a                	mv	s2,a0
    8000430e:	8a2e                	mv	s4,a1
    80004310:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004312:	4601                	li	a2,0
    80004314:	00000097          	auipc	ra,0x0
    80004318:	dda080e7          	jalr	-550(ra) # 800040ee <dirlookup>
    8000431c:	ed25                	bnez	a0,80004394 <dirlink+0x96>
    8000431e:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004320:	04c92483          	lw	s1,76(s2)
    80004324:	c49d                	beqz	s1,80004352 <dirlink+0x54>
    80004326:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004328:	4741                	li	a4,16
    8000432a:	86a6                	mv	a3,s1
    8000432c:	fc040613          	add	a2,s0,-64
    80004330:	4581                	li	a1,0
    80004332:	854a                	mv	a0,s2
    80004334:	00000097          	auipc	ra,0x0
    80004338:	b66080e7          	jalr	-1178(ra) # 80003e9a <readi>
    8000433c:	47c1                	li	a5,16
    8000433e:	06f51163          	bne	a0,a5,800043a0 <dirlink+0xa2>
    if(de.inum == 0)
    80004342:	fc045783          	lhu	a5,-64(s0)
    80004346:	c791                	beqz	a5,80004352 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004348:	24c1                	addw	s1,s1,16
    8000434a:	04c92783          	lw	a5,76(s2)
    8000434e:	fcf4ede3          	bltu	s1,a5,80004328 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004352:	4639                	li	a2,14
    80004354:	85d2                	mv	a1,s4
    80004356:	fc240513          	add	a0,s0,-62
    8000435a:	ffffd097          	auipc	ra,0xffffd
    8000435e:	ba8080e7          	jalr	-1112(ra) # 80000f02 <strncpy>
  de.inum = inum;
    80004362:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004366:	4741                	li	a4,16
    80004368:	86a6                	mv	a3,s1
    8000436a:	fc040613          	add	a2,s0,-64
    8000436e:	4581                	li	a1,0
    80004370:	854a                	mv	a0,s2
    80004372:	00000097          	auipc	ra,0x0
    80004376:	c38080e7          	jalr	-968(ra) # 80003faa <writei>
    8000437a:	1541                	add	a0,a0,-16
    8000437c:	00a03533          	snez	a0,a0
    80004380:	40a00533          	neg	a0,a0
    80004384:	74a2                	ld	s1,40(sp)
}
    80004386:	70e2                	ld	ra,56(sp)
    80004388:	7442                	ld	s0,48(sp)
    8000438a:	7902                	ld	s2,32(sp)
    8000438c:	69e2                	ld	s3,24(sp)
    8000438e:	6a42                	ld	s4,16(sp)
    80004390:	6121                	add	sp,sp,64
    80004392:	8082                	ret
    iput(ip);
    80004394:	00000097          	auipc	ra,0x0
    80004398:	a0c080e7          	jalr	-1524(ra) # 80003da0 <iput>
    return -1;
    8000439c:	557d                	li	a0,-1
    8000439e:	b7e5                	j	80004386 <dirlink+0x88>
      panic("dirlink read");
    800043a0:	00004517          	auipc	a0,0x4
    800043a4:	27850513          	add	a0,a0,632 # 80008618 <__func__.1+0x610>
    800043a8:	ffffc097          	auipc	ra,0xffffc
    800043ac:	1b8080e7          	jalr	440(ra) # 80000560 <panic>

00000000800043b0 <namei>:

struct inode*
namei(char *path)
{
    800043b0:	1101                	add	sp,sp,-32
    800043b2:	ec06                	sd	ra,24(sp)
    800043b4:	e822                	sd	s0,16(sp)
    800043b6:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043b8:	fe040613          	add	a2,s0,-32
    800043bc:	4581                	li	a1,0
    800043be:	00000097          	auipc	ra,0x0
    800043c2:	de0080e7          	jalr	-544(ra) # 8000419e <namex>
}
    800043c6:	60e2                	ld	ra,24(sp)
    800043c8:	6442                	ld	s0,16(sp)
    800043ca:	6105                	add	sp,sp,32
    800043cc:	8082                	ret

00000000800043ce <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043ce:	1141                	add	sp,sp,-16
    800043d0:	e406                	sd	ra,8(sp)
    800043d2:	e022                	sd	s0,0(sp)
    800043d4:	0800                	add	s0,sp,16
    800043d6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043d8:	4585                	li	a1,1
    800043da:	00000097          	auipc	ra,0x0
    800043de:	dc4080e7          	jalr	-572(ra) # 8000419e <namex>
}
    800043e2:	60a2                	ld	ra,8(sp)
    800043e4:	6402                	ld	s0,0(sp)
    800043e6:	0141                	add	sp,sp,16
    800043e8:	8082                	ret

00000000800043ea <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043ea:	1101                	add	sp,sp,-32
    800043ec:	ec06                	sd	ra,24(sp)
    800043ee:	e822                	sd	s0,16(sp)
    800043f0:	e426                	sd	s1,8(sp)
    800043f2:	e04a                	sd	s2,0(sp)
    800043f4:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800043f6:	0001d917          	auipc	s2,0x1d
    800043fa:	88a90913          	add	s2,s2,-1910 # 80020c80 <log>
    800043fe:	01892583          	lw	a1,24(s2)
    80004402:	02892503          	lw	a0,40(s2)
    80004406:	fffff097          	auipc	ra,0xfffff
    8000440a:	fa8080e7          	jalr	-88(ra) # 800033ae <bread>
    8000440e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004410:	02c92603          	lw	a2,44(s2)
    80004414:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004416:	00c05f63          	blez	a2,80004434 <write_head+0x4a>
    8000441a:	0001d717          	auipc	a4,0x1d
    8000441e:	89670713          	add	a4,a4,-1898 # 80020cb0 <log+0x30>
    80004422:	87aa                	mv	a5,a0
    80004424:	060a                	sll	a2,a2,0x2
    80004426:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004428:	4314                	lw	a3,0(a4)
    8000442a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000442c:	0711                	add	a4,a4,4
    8000442e:	0791                	add	a5,a5,4
    80004430:	fec79ce3          	bne	a5,a2,80004428 <write_head+0x3e>
  }
  bwrite(buf);
    80004434:	8526                	mv	a0,s1
    80004436:	fffff097          	auipc	ra,0xfffff
    8000443a:	06a080e7          	jalr	106(ra) # 800034a0 <bwrite>
  brelse(buf);
    8000443e:	8526                	mv	a0,s1
    80004440:	fffff097          	auipc	ra,0xfffff
    80004444:	09e080e7          	jalr	158(ra) # 800034de <brelse>
}
    80004448:	60e2                	ld	ra,24(sp)
    8000444a:	6442                	ld	s0,16(sp)
    8000444c:	64a2                	ld	s1,8(sp)
    8000444e:	6902                	ld	s2,0(sp)
    80004450:	6105                	add	sp,sp,32
    80004452:	8082                	ret

0000000080004454 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004454:	0001d797          	auipc	a5,0x1d
    80004458:	8587a783          	lw	a5,-1960(a5) # 80020cac <log+0x2c>
    8000445c:	0af05d63          	blez	a5,80004516 <install_trans+0xc2>
{
    80004460:	7139                	add	sp,sp,-64
    80004462:	fc06                	sd	ra,56(sp)
    80004464:	f822                	sd	s0,48(sp)
    80004466:	f426                	sd	s1,40(sp)
    80004468:	f04a                	sd	s2,32(sp)
    8000446a:	ec4e                	sd	s3,24(sp)
    8000446c:	e852                	sd	s4,16(sp)
    8000446e:	e456                	sd	s5,8(sp)
    80004470:	e05a                	sd	s6,0(sp)
    80004472:	0080                	add	s0,sp,64
    80004474:	8b2a                	mv	s6,a0
    80004476:	0001da97          	auipc	s5,0x1d
    8000447a:	83aa8a93          	add	s5,s5,-1990 # 80020cb0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000447e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004480:	0001d997          	auipc	s3,0x1d
    80004484:	80098993          	add	s3,s3,-2048 # 80020c80 <log>
    80004488:	a00d                	j	800044aa <install_trans+0x56>
    brelse(lbuf);
    8000448a:	854a                	mv	a0,s2
    8000448c:	fffff097          	auipc	ra,0xfffff
    80004490:	052080e7          	jalr	82(ra) # 800034de <brelse>
    brelse(dbuf);
    80004494:	8526                	mv	a0,s1
    80004496:	fffff097          	auipc	ra,0xfffff
    8000449a:	048080e7          	jalr	72(ra) # 800034de <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000449e:	2a05                	addw	s4,s4,1
    800044a0:	0a91                	add	s5,s5,4
    800044a2:	02c9a783          	lw	a5,44(s3)
    800044a6:	04fa5e63          	bge	s4,a5,80004502 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044aa:	0189a583          	lw	a1,24(s3)
    800044ae:	014585bb          	addw	a1,a1,s4
    800044b2:	2585                	addw	a1,a1,1
    800044b4:	0289a503          	lw	a0,40(s3)
    800044b8:	fffff097          	auipc	ra,0xfffff
    800044bc:	ef6080e7          	jalr	-266(ra) # 800033ae <bread>
    800044c0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044c2:	000aa583          	lw	a1,0(s5)
    800044c6:	0289a503          	lw	a0,40(s3)
    800044ca:	fffff097          	auipc	ra,0xfffff
    800044ce:	ee4080e7          	jalr	-284(ra) # 800033ae <bread>
    800044d2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044d4:	40000613          	li	a2,1024
    800044d8:	05890593          	add	a1,s2,88
    800044dc:	05850513          	add	a0,a0,88
    800044e0:	ffffd097          	auipc	ra,0xffffd
    800044e4:	978080e7          	jalr	-1672(ra) # 80000e58 <memmove>
    bwrite(dbuf);  // write dst to disk
    800044e8:	8526                	mv	a0,s1
    800044ea:	fffff097          	auipc	ra,0xfffff
    800044ee:	fb6080e7          	jalr	-74(ra) # 800034a0 <bwrite>
    if(recovering == 0)
    800044f2:	f80b1ce3          	bnez	s6,8000448a <install_trans+0x36>
      bunpin(dbuf);
    800044f6:	8526                	mv	a0,s1
    800044f8:	fffff097          	auipc	ra,0xfffff
    800044fc:	0be080e7          	jalr	190(ra) # 800035b6 <bunpin>
    80004500:	b769                	j	8000448a <install_trans+0x36>
}
    80004502:	70e2                	ld	ra,56(sp)
    80004504:	7442                	ld	s0,48(sp)
    80004506:	74a2                	ld	s1,40(sp)
    80004508:	7902                	ld	s2,32(sp)
    8000450a:	69e2                	ld	s3,24(sp)
    8000450c:	6a42                	ld	s4,16(sp)
    8000450e:	6aa2                	ld	s5,8(sp)
    80004510:	6b02                	ld	s6,0(sp)
    80004512:	6121                	add	sp,sp,64
    80004514:	8082                	ret
    80004516:	8082                	ret

0000000080004518 <initlog>:
{
    80004518:	7179                	add	sp,sp,-48
    8000451a:	f406                	sd	ra,40(sp)
    8000451c:	f022                	sd	s0,32(sp)
    8000451e:	ec26                	sd	s1,24(sp)
    80004520:	e84a                	sd	s2,16(sp)
    80004522:	e44e                	sd	s3,8(sp)
    80004524:	1800                	add	s0,sp,48
    80004526:	892a                	mv	s2,a0
    80004528:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000452a:	0001c497          	auipc	s1,0x1c
    8000452e:	75648493          	add	s1,s1,1878 # 80020c80 <log>
    80004532:	00004597          	auipc	a1,0x4
    80004536:	0f658593          	add	a1,a1,246 # 80008628 <__func__.1+0x620>
    8000453a:	8526                	mv	a0,s1
    8000453c:	ffffc097          	auipc	ra,0xffffc
    80004540:	734080e7          	jalr	1844(ra) # 80000c70 <initlock>
  log.start = sb->logstart;
    80004544:	0149a583          	lw	a1,20(s3)
    80004548:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000454a:	0109a783          	lw	a5,16(s3)
    8000454e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004550:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004554:	854a                	mv	a0,s2
    80004556:	fffff097          	auipc	ra,0xfffff
    8000455a:	e58080e7          	jalr	-424(ra) # 800033ae <bread>
  log.lh.n = lh->n;
    8000455e:	4d30                	lw	a2,88(a0)
    80004560:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004562:	00c05f63          	blez	a2,80004580 <initlog+0x68>
    80004566:	87aa                	mv	a5,a0
    80004568:	0001c717          	auipc	a4,0x1c
    8000456c:	74870713          	add	a4,a4,1864 # 80020cb0 <log+0x30>
    80004570:	060a                	sll	a2,a2,0x2
    80004572:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004574:	4ff4                	lw	a3,92(a5)
    80004576:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004578:	0791                	add	a5,a5,4
    8000457a:	0711                	add	a4,a4,4
    8000457c:	fec79ce3          	bne	a5,a2,80004574 <initlog+0x5c>
  brelse(buf);
    80004580:	fffff097          	auipc	ra,0xfffff
    80004584:	f5e080e7          	jalr	-162(ra) # 800034de <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004588:	4505                	li	a0,1
    8000458a:	00000097          	auipc	ra,0x0
    8000458e:	eca080e7          	jalr	-310(ra) # 80004454 <install_trans>
  log.lh.n = 0;
    80004592:	0001c797          	auipc	a5,0x1c
    80004596:	7007ad23          	sw	zero,1818(a5) # 80020cac <log+0x2c>
  write_head(); // clear the log
    8000459a:	00000097          	auipc	ra,0x0
    8000459e:	e50080e7          	jalr	-432(ra) # 800043ea <write_head>
}
    800045a2:	70a2                	ld	ra,40(sp)
    800045a4:	7402                	ld	s0,32(sp)
    800045a6:	64e2                	ld	s1,24(sp)
    800045a8:	6942                	ld	s2,16(sp)
    800045aa:	69a2                	ld	s3,8(sp)
    800045ac:	6145                	add	sp,sp,48
    800045ae:	8082                	ret

00000000800045b0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045b0:	1101                	add	sp,sp,-32
    800045b2:	ec06                	sd	ra,24(sp)
    800045b4:	e822                	sd	s0,16(sp)
    800045b6:	e426                	sd	s1,8(sp)
    800045b8:	e04a                	sd	s2,0(sp)
    800045ba:	1000                	add	s0,sp,32
  acquire(&log.lock);
    800045bc:	0001c517          	auipc	a0,0x1c
    800045c0:	6c450513          	add	a0,a0,1732 # 80020c80 <log>
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	73c080e7          	jalr	1852(ra) # 80000d00 <acquire>
  while(1){
    if(log.committing){
    800045cc:	0001c497          	auipc	s1,0x1c
    800045d0:	6b448493          	add	s1,s1,1716 # 80020c80 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045d4:	4979                	li	s2,30
    800045d6:	a039                	j	800045e4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800045d8:	85a6                	mv	a1,s1
    800045da:	8526                	mv	a0,s1
    800045dc:	ffffe097          	auipc	ra,0xffffe
    800045e0:	ddc080e7          	jalr	-548(ra) # 800023b8 <sleep>
    if(log.committing){
    800045e4:	50dc                	lw	a5,36(s1)
    800045e6:	fbed                	bnez	a5,800045d8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045e8:	5098                	lw	a4,32(s1)
    800045ea:	2705                	addw	a4,a4,1
    800045ec:	0027179b          	sllw	a5,a4,0x2
    800045f0:	9fb9                	addw	a5,a5,a4
    800045f2:	0017979b          	sllw	a5,a5,0x1
    800045f6:	54d4                	lw	a3,44(s1)
    800045f8:	9fb5                	addw	a5,a5,a3
    800045fa:	00f95963          	bge	s2,a5,8000460c <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800045fe:	85a6                	mv	a1,s1
    80004600:	8526                	mv	a0,s1
    80004602:	ffffe097          	auipc	ra,0xffffe
    80004606:	db6080e7          	jalr	-586(ra) # 800023b8 <sleep>
    8000460a:	bfe9                	j	800045e4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000460c:	0001c517          	auipc	a0,0x1c
    80004610:	67450513          	add	a0,a0,1652 # 80020c80 <log>
    80004614:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004616:	ffffc097          	auipc	ra,0xffffc
    8000461a:	79e080e7          	jalr	1950(ra) # 80000db4 <release>
      break;
    }
  }
}
    8000461e:	60e2                	ld	ra,24(sp)
    80004620:	6442                	ld	s0,16(sp)
    80004622:	64a2                	ld	s1,8(sp)
    80004624:	6902                	ld	s2,0(sp)
    80004626:	6105                	add	sp,sp,32
    80004628:	8082                	ret

000000008000462a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000462a:	7139                	add	sp,sp,-64
    8000462c:	fc06                	sd	ra,56(sp)
    8000462e:	f822                	sd	s0,48(sp)
    80004630:	f426                	sd	s1,40(sp)
    80004632:	f04a                	sd	s2,32(sp)
    80004634:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004636:	0001c497          	auipc	s1,0x1c
    8000463a:	64a48493          	add	s1,s1,1610 # 80020c80 <log>
    8000463e:	8526                	mv	a0,s1
    80004640:	ffffc097          	auipc	ra,0xffffc
    80004644:	6c0080e7          	jalr	1728(ra) # 80000d00 <acquire>
  log.outstanding -= 1;
    80004648:	509c                	lw	a5,32(s1)
    8000464a:	37fd                	addw	a5,a5,-1
    8000464c:	0007891b          	sext.w	s2,a5
    80004650:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004652:	50dc                	lw	a5,36(s1)
    80004654:	e7b9                	bnez	a5,800046a2 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    80004656:	06091163          	bnez	s2,800046b8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000465a:	0001c497          	auipc	s1,0x1c
    8000465e:	62648493          	add	s1,s1,1574 # 80020c80 <log>
    80004662:	4785                	li	a5,1
    80004664:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004666:	8526                	mv	a0,s1
    80004668:	ffffc097          	auipc	ra,0xffffc
    8000466c:	74c080e7          	jalr	1868(ra) # 80000db4 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004670:	54dc                	lw	a5,44(s1)
    80004672:	06f04763          	bgtz	a5,800046e0 <end_op+0xb6>
    acquire(&log.lock);
    80004676:	0001c497          	auipc	s1,0x1c
    8000467a:	60a48493          	add	s1,s1,1546 # 80020c80 <log>
    8000467e:	8526                	mv	a0,s1
    80004680:	ffffc097          	auipc	ra,0xffffc
    80004684:	680080e7          	jalr	1664(ra) # 80000d00 <acquire>
    log.committing = 0;
    80004688:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000468c:	8526                	mv	a0,s1
    8000468e:	ffffe097          	auipc	ra,0xffffe
    80004692:	d8e080e7          	jalr	-626(ra) # 8000241c <wakeup>
    release(&log.lock);
    80004696:	8526                	mv	a0,s1
    80004698:	ffffc097          	auipc	ra,0xffffc
    8000469c:	71c080e7          	jalr	1820(ra) # 80000db4 <release>
}
    800046a0:	a815                	j	800046d4 <end_op+0xaa>
    800046a2:	ec4e                	sd	s3,24(sp)
    800046a4:	e852                	sd	s4,16(sp)
    800046a6:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800046a8:	00004517          	auipc	a0,0x4
    800046ac:	f8850513          	add	a0,a0,-120 # 80008630 <__func__.1+0x628>
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	eb0080e7          	jalr	-336(ra) # 80000560 <panic>
    wakeup(&log);
    800046b8:	0001c497          	auipc	s1,0x1c
    800046bc:	5c848493          	add	s1,s1,1480 # 80020c80 <log>
    800046c0:	8526                	mv	a0,s1
    800046c2:	ffffe097          	auipc	ra,0xffffe
    800046c6:	d5a080e7          	jalr	-678(ra) # 8000241c <wakeup>
  release(&log.lock);
    800046ca:	8526                	mv	a0,s1
    800046cc:	ffffc097          	auipc	ra,0xffffc
    800046d0:	6e8080e7          	jalr	1768(ra) # 80000db4 <release>
}
    800046d4:	70e2                	ld	ra,56(sp)
    800046d6:	7442                	ld	s0,48(sp)
    800046d8:	74a2                	ld	s1,40(sp)
    800046da:	7902                	ld	s2,32(sp)
    800046dc:	6121                	add	sp,sp,64
    800046de:	8082                	ret
    800046e0:	ec4e                	sd	s3,24(sp)
    800046e2:	e852                	sd	s4,16(sp)
    800046e4:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800046e6:	0001ca97          	auipc	s5,0x1c
    800046ea:	5caa8a93          	add	s5,s5,1482 # 80020cb0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046ee:	0001ca17          	auipc	s4,0x1c
    800046f2:	592a0a13          	add	s4,s4,1426 # 80020c80 <log>
    800046f6:	018a2583          	lw	a1,24(s4)
    800046fa:	012585bb          	addw	a1,a1,s2
    800046fe:	2585                	addw	a1,a1,1
    80004700:	028a2503          	lw	a0,40(s4)
    80004704:	fffff097          	auipc	ra,0xfffff
    80004708:	caa080e7          	jalr	-854(ra) # 800033ae <bread>
    8000470c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000470e:	000aa583          	lw	a1,0(s5)
    80004712:	028a2503          	lw	a0,40(s4)
    80004716:	fffff097          	auipc	ra,0xfffff
    8000471a:	c98080e7          	jalr	-872(ra) # 800033ae <bread>
    8000471e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004720:	40000613          	li	a2,1024
    80004724:	05850593          	add	a1,a0,88
    80004728:	05848513          	add	a0,s1,88
    8000472c:	ffffc097          	auipc	ra,0xffffc
    80004730:	72c080e7          	jalr	1836(ra) # 80000e58 <memmove>
    bwrite(to);  // write the log
    80004734:	8526                	mv	a0,s1
    80004736:	fffff097          	auipc	ra,0xfffff
    8000473a:	d6a080e7          	jalr	-662(ra) # 800034a0 <bwrite>
    brelse(from);
    8000473e:	854e                	mv	a0,s3
    80004740:	fffff097          	auipc	ra,0xfffff
    80004744:	d9e080e7          	jalr	-610(ra) # 800034de <brelse>
    brelse(to);
    80004748:	8526                	mv	a0,s1
    8000474a:	fffff097          	auipc	ra,0xfffff
    8000474e:	d94080e7          	jalr	-620(ra) # 800034de <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004752:	2905                	addw	s2,s2,1
    80004754:	0a91                	add	s5,s5,4
    80004756:	02ca2783          	lw	a5,44(s4)
    8000475a:	f8f94ee3          	blt	s2,a5,800046f6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000475e:	00000097          	auipc	ra,0x0
    80004762:	c8c080e7          	jalr	-884(ra) # 800043ea <write_head>
    install_trans(0); // Now install writes to home locations
    80004766:	4501                	li	a0,0
    80004768:	00000097          	auipc	ra,0x0
    8000476c:	cec080e7          	jalr	-788(ra) # 80004454 <install_trans>
    log.lh.n = 0;
    80004770:	0001c797          	auipc	a5,0x1c
    80004774:	5207ae23          	sw	zero,1340(a5) # 80020cac <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004778:	00000097          	auipc	ra,0x0
    8000477c:	c72080e7          	jalr	-910(ra) # 800043ea <write_head>
    80004780:	69e2                	ld	s3,24(sp)
    80004782:	6a42                	ld	s4,16(sp)
    80004784:	6aa2                	ld	s5,8(sp)
    80004786:	bdc5                	j	80004676 <end_op+0x4c>

0000000080004788 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004788:	1101                	add	sp,sp,-32
    8000478a:	ec06                	sd	ra,24(sp)
    8000478c:	e822                	sd	s0,16(sp)
    8000478e:	e426                	sd	s1,8(sp)
    80004790:	e04a                	sd	s2,0(sp)
    80004792:	1000                	add	s0,sp,32
    80004794:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004796:	0001c917          	auipc	s2,0x1c
    8000479a:	4ea90913          	add	s2,s2,1258 # 80020c80 <log>
    8000479e:	854a                	mv	a0,s2
    800047a0:	ffffc097          	auipc	ra,0xffffc
    800047a4:	560080e7          	jalr	1376(ra) # 80000d00 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047a8:	02c92603          	lw	a2,44(s2)
    800047ac:	47f5                	li	a5,29
    800047ae:	06c7c563          	blt	a5,a2,80004818 <log_write+0x90>
    800047b2:	0001c797          	auipc	a5,0x1c
    800047b6:	4ea7a783          	lw	a5,1258(a5) # 80020c9c <log+0x1c>
    800047ba:	37fd                	addw	a5,a5,-1
    800047bc:	04f65e63          	bge	a2,a5,80004818 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047c0:	0001c797          	auipc	a5,0x1c
    800047c4:	4e07a783          	lw	a5,1248(a5) # 80020ca0 <log+0x20>
    800047c8:	06f05063          	blez	a5,80004828 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047cc:	4781                	li	a5,0
    800047ce:	06c05563          	blez	a2,80004838 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047d2:	44cc                	lw	a1,12(s1)
    800047d4:	0001c717          	auipc	a4,0x1c
    800047d8:	4dc70713          	add	a4,a4,1244 # 80020cb0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800047dc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047de:	4314                	lw	a3,0(a4)
    800047e0:	04b68c63          	beq	a3,a1,80004838 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800047e4:	2785                	addw	a5,a5,1
    800047e6:	0711                	add	a4,a4,4
    800047e8:	fef61be3          	bne	a2,a5,800047de <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800047ec:	0621                	add	a2,a2,8
    800047ee:	060a                	sll	a2,a2,0x2
    800047f0:	0001c797          	auipc	a5,0x1c
    800047f4:	49078793          	add	a5,a5,1168 # 80020c80 <log>
    800047f8:	97b2                	add	a5,a5,a2
    800047fa:	44d8                	lw	a4,12(s1)
    800047fc:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800047fe:	8526                	mv	a0,s1
    80004800:	fffff097          	auipc	ra,0xfffff
    80004804:	d7a080e7          	jalr	-646(ra) # 8000357a <bpin>
    log.lh.n++;
    80004808:	0001c717          	auipc	a4,0x1c
    8000480c:	47870713          	add	a4,a4,1144 # 80020c80 <log>
    80004810:	575c                	lw	a5,44(a4)
    80004812:	2785                	addw	a5,a5,1
    80004814:	d75c                	sw	a5,44(a4)
    80004816:	a82d                	j	80004850 <log_write+0xc8>
    panic("too big a transaction");
    80004818:	00004517          	auipc	a0,0x4
    8000481c:	e2850513          	add	a0,a0,-472 # 80008640 <__func__.1+0x638>
    80004820:	ffffc097          	auipc	ra,0xffffc
    80004824:	d40080e7          	jalr	-704(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004828:	00004517          	auipc	a0,0x4
    8000482c:	e3050513          	add	a0,a0,-464 # 80008658 <__func__.1+0x650>
    80004830:	ffffc097          	auipc	ra,0xffffc
    80004834:	d30080e7          	jalr	-720(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004838:	00878693          	add	a3,a5,8
    8000483c:	068a                	sll	a3,a3,0x2
    8000483e:	0001c717          	auipc	a4,0x1c
    80004842:	44270713          	add	a4,a4,1090 # 80020c80 <log>
    80004846:	9736                	add	a4,a4,a3
    80004848:	44d4                	lw	a3,12(s1)
    8000484a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000484c:	faf609e3          	beq	a2,a5,800047fe <log_write+0x76>
  }
  release(&log.lock);
    80004850:	0001c517          	auipc	a0,0x1c
    80004854:	43050513          	add	a0,a0,1072 # 80020c80 <log>
    80004858:	ffffc097          	auipc	ra,0xffffc
    8000485c:	55c080e7          	jalr	1372(ra) # 80000db4 <release>
}
    80004860:	60e2                	ld	ra,24(sp)
    80004862:	6442                	ld	s0,16(sp)
    80004864:	64a2                	ld	s1,8(sp)
    80004866:	6902                	ld	s2,0(sp)
    80004868:	6105                	add	sp,sp,32
    8000486a:	8082                	ret

000000008000486c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000486c:	1101                	add	sp,sp,-32
    8000486e:	ec06                	sd	ra,24(sp)
    80004870:	e822                	sd	s0,16(sp)
    80004872:	e426                	sd	s1,8(sp)
    80004874:	e04a                	sd	s2,0(sp)
    80004876:	1000                	add	s0,sp,32
    80004878:	84aa                	mv	s1,a0
    8000487a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000487c:	00004597          	auipc	a1,0x4
    80004880:	dfc58593          	add	a1,a1,-516 # 80008678 <__func__.1+0x670>
    80004884:	0521                	add	a0,a0,8
    80004886:	ffffc097          	auipc	ra,0xffffc
    8000488a:	3ea080e7          	jalr	1002(ra) # 80000c70 <initlock>
  lk->name = name;
    8000488e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004892:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004896:	0204a423          	sw	zero,40(s1)
}
    8000489a:	60e2                	ld	ra,24(sp)
    8000489c:	6442                	ld	s0,16(sp)
    8000489e:	64a2                	ld	s1,8(sp)
    800048a0:	6902                	ld	s2,0(sp)
    800048a2:	6105                	add	sp,sp,32
    800048a4:	8082                	ret

00000000800048a6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048a6:	1101                	add	sp,sp,-32
    800048a8:	ec06                	sd	ra,24(sp)
    800048aa:	e822                	sd	s0,16(sp)
    800048ac:	e426                	sd	s1,8(sp)
    800048ae:	e04a                	sd	s2,0(sp)
    800048b0:	1000                	add	s0,sp,32
    800048b2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048b4:	00850913          	add	s2,a0,8
    800048b8:	854a                	mv	a0,s2
    800048ba:	ffffc097          	auipc	ra,0xffffc
    800048be:	446080e7          	jalr	1094(ra) # 80000d00 <acquire>
  while (lk->locked) {
    800048c2:	409c                	lw	a5,0(s1)
    800048c4:	cb89                	beqz	a5,800048d6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800048c6:	85ca                	mv	a1,s2
    800048c8:	8526                	mv	a0,s1
    800048ca:	ffffe097          	auipc	ra,0xffffe
    800048ce:	aee080e7          	jalr	-1298(ra) # 800023b8 <sleep>
  while (lk->locked) {
    800048d2:	409c                	lw	a5,0(s1)
    800048d4:	fbed                	bnez	a5,800048c6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800048d6:	4785                	li	a5,1
    800048d8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800048da:	ffffd097          	auipc	ra,0xffffd
    800048de:	32c080e7          	jalr	812(ra) # 80001c06 <myproc>
    800048e2:	591c                	lw	a5,48(a0)
    800048e4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800048e6:	854a                	mv	a0,s2
    800048e8:	ffffc097          	auipc	ra,0xffffc
    800048ec:	4cc080e7          	jalr	1228(ra) # 80000db4 <release>
}
    800048f0:	60e2                	ld	ra,24(sp)
    800048f2:	6442                	ld	s0,16(sp)
    800048f4:	64a2                	ld	s1,8(sp)
    800048f6:	6902                	ld	s2,0(sp)
    800048f8:	6105                	add	sp,sp,32
    800048fa:	8082                	ret

00000000800048fc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800048fc:	1101                	add	sp,sp,-32
    800048fe:	ec06                	sd	ra,24(sp)
    80004900:	e822                	sd	s0,16(sp)
    80004902:	e426                	sd	s1,8(sp)
    80004904:	e04a                	sd	s2,0(sp)
    80004906:	1000                	add	s0,sp,32
    80004908:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000490a:	00850913          	add	s2,a0,8
    8000490e:	854a                	mv	a0,s2
    80004910:	ffffc097          	auipc	ra,0xffffc
    80004914:	3f0080e7          	jalr	1008(ra) # 80000d00 <acquire>
  lk->locked = 0;
    80004918:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000491c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004920:	8526                	mv	a0,s1
    80004922:	ffffe097          	auipc	ra,0xffffe
    80004926:	afa080e7          	jalr	-1286(ra) # 8000241c <wakeup>
  release(&lk->lk);
    8000492a:	854a                	mv	a0,s2
    8000492c:	ffffc097          	auipc	ra,0xffffc
    80004930:	488080e7          	jalr	1160(ra) # 80000db4 <release>
}
    80004934:	60e2                	ld	ra,24(sp)
    80004936:	6442                	ld	s0,16(sp)
    80004938:	64a2                	ld	s1,8(sp)
    8000493a:	6902                	ld	s2,0(sp)
    8000493c:	6105                	add	sp,sp,32
    8000493e:	8082                	ret

0000000080004940 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004940:	7179                	add	sp,sp,-48
    80004942:	f406                	sd	ra,40(sp)
    80004944:	f022                	sd	s0,32(sp)
    80004946:	ec26                	sd	s1,24(sp)
    80004948:	e84a                	sd	s2,16(sp)
    8000494a:	1800                	add	s0,sp,48
    8000494c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000494e:	00850913          	add	s2,a0,8
    80004952:	854a                	mv	a0,s2
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	3ac080e7          	jalr	940(ra) # 80000d00 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000495c:	409c                	lw	a5,0(s1)
    8000495e:	ef91                	bnez	a5,8000497a <holdingsleep+0x3a>
    80004960:	4481                	li	s1,0
  release(&lk->lk);
    80004962:	854a                	mv	a0,s2
    80004964:	ffffc097          	auipc	ra,0xffffc
    80004968:	450080e7          	jalr	1104(ra) # 80000db4 <release>
  return r;
}
    8000496c:	8526                	mv	a0,s1
    8000496e:	70a2                	ld	ra,40(sp)
    80004970:	7402                	ld	s0,32(sp)
    80004972:	64e2                	ld	s1,24(sp)
    80004974:	6942                	ld	s2,16(sp)
    80004976:	6145                	add	sp,sp,48
    80004978:	8082                	ret
    8000497a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000497c:	0284a983          	lw	s3,40(s1)
    80004980:	ffffd097          	auipc	ra,0xffffd
    80004984:	286080e7          	jalr	646(ra) # 80001c06 <myproc>
    80004988:	5904                	lw	s1,48(a0)
    8000498a:	413484b3          	sub	s1,s1,s3
    8000498e:	0014b493          	seqz	s1,s1
    80004992:	69a2                	ld	s3,8(sp)
    80004994:	b7f9                	j	80004962 <holdingsleep+0x22>

0000000080004996 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004996:	1141                	add	sp,sp,-16
    80004998:	e406                	sd	ra,8(sp)
    8000499a:	e022                	sd	s0,0(sp)
    8000499c:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000499e:	00004597          	auipc	a1,0x4
    800049a2:	cea58593          	add	a1,a1,-790 # 80008688 <__func__.1+0x680>
    800049a6:	0001c517          	auipc	a0,0x1c
    800049aa:	42250513          	add	a0,a0,1058 # 80020dc8 <ftable>
    800049ae:	ffffc097          	auipc	ra,0xffffc
    800049b2:	2c2080e7          	jalr	706(ra) # 80000c70 <initlock>
}
    800049b6:	60a2                	ld	ra,8(sp)
    800049b8:	6402                	ld	s0,0(sp)
    800049ba:	0141                	add	sp,sp,16
    800049bc:	8082                	ret

00000000800049be <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800049be:	1101                	add	sp,sp,-32
    800049c0:	ec06                	sd	ra,24(sp)
    800049c2:	e822                	sd	s0,16(sp)
    800049c4:	e426                	sd	s1,8(sp)
    800049c6:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049c8:	0001c517          	auipc	a0,0x1c
    800049cc:	40050513          	add	a0,a0,1024 # 80020dc8 <ftable>
    800049d0:	ffffc097          	auipc	ra,0xffffc
    800049d4:	330080e7          	jalr	816(ra) # 80000d00 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049d8:	0001c497          	auipc	s1,0x1c
    800049dc:	40848493          	add	s1,s1,1032 # 80020de0 <ftable+0x18>
    800049e0:	0001d717          	auipc	a4,0x1d
    800049e4:	3a070713          	add	a4,a4,928 # 80021d80 <disk>
    if(f->ref == 0){
    800049e8:	40dc                	lw	a5,4(s1)
    800049ea:	cf99                	beqz	a5,80004a08 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049ec:	02848493          	add	s1,s1,40
    800049f0:	fee49ce3          	bne	s1,a4,800049e8 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800049f4:	0001c517          	auipc	a0,0x1c
    800049f8:	3d450513          	add	a0,a0,980 # 80020dc8 <ftable>
    800049fc:	ffffc097          	auipc	ra,0xffffc
    80004a00:	3b8080e7          	jalr	952(ra) # 80000db4 <release>
  return 0;
    80004a04:	4481                	li	s1,0
    80004a06:	a819                	j	80004a1c <filealloc+0x5e>
      f->ref = 1;
    80004a08:	4785                	li	a5,1
    80004a0a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a0c:	0001c517          	auipc	a0,0x1c
    80004a10:	3bc50513          	add	a0,a0,956 # 80020dc8 <ftable>
    80004a14:	ffffc097          	auipc	ra,0xffffc
    80004a18:	3a0080e7          	jalr	928(ra) # 80000db4 <release>
}
    80004a1c:	8526                	mv	a0,s1
    80004a1e:	60e2                	ld	ra,24(sp)
    80004a20:	6442                	ld	s0,16(sp)
    80004a22:	64a2                	ld	s1,8(sp)
    80004a24:	6105                	add	sp,sp,32
    80004a26:	8082                	ret

0000000080004a28 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a28:	1101                	add	sp,sp,-32
    80004a2a:	ec06                	sd	ra,24(sp)
    80004a2c:	e822                	sd	s0,16(sp)
    80004a2e:	e426                	sd	s1,8(sp)
    80004a30:	1000                	add	s0,sp,32
    80004a32:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a34:	0001c517          	auipc	a0,0x1c
    80004a38:	39450513          	add	a0,a0,916 # 80020dc8 <ftable>
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	2c4080e7          	jalr	708(ra) # 80000d00 <acquire>
  if(f->ref < 1)
    80004a44:	40dc                	lw	a5,4(s1)
    80004a46:	02f05263          	blez	a5,80004a6a <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a4a:	2785                	addw	a5,a5,1
    80004a4c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a4e:	0001c517          	auipc	a0,0x1c
    80004a52:	37a50513          	add	a0,a0,890 # 80020dc8 <ftable>
    80004a56:	ffffc097          	auipc	ra,0xffffc
    80004a5a:	35e080e7          	jalr	862(ra) # 80000db4 <release>
  return f;
}
    80004a5e:	8526                	mv	a0,s1
    80004a60:	60e2                	ld	ra,24(sp)
    80004a62:	6442                	ld	s0,16(sp)
    80004a64:	64a2                	ld	s1,8(sp)
    80004a66:	6105                	add	sp,sp,32
    80004a68:	8082                	ret
    panic("filedup");
    80004a6a:	00004517          	auipc	a0,0x4
    80004a6e:	c2650513          	add	a0,a0,-986 # 80008690 <__func__.1+0x688>
    80004a72:	ffffc097          	auipc	ra,0xffffc
    80004a76:	aee080e7          	jalr	-1298(ra) # 80000560 <panic>

0000000080004a7a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a7a:	7139                	add	sp,sp,-64
    80004a7c:	fc06                	sd	ra,56(sp)
    80004a7e:	f822                	sd	s0,48(sp)
    80004a80:	f426                	sd	s1,40(sp)
    80004a82:	0080                	add	s0,sp,64
    80004a84:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a86:	0001c517          	auipc	a0,0x1c
    80004a8a:	34250513          	add	a0,a0,834 # 80020dc8 <ftable>
    80004a8e:	ffffc097          	auipc	ra,0xffffc
    80004a92:	272080e7          	jalr	626(ra) # 80000d00 <acquire>
  if(f->ref < 1)
    80004a96:	40dc                	lw	a5,4(s1)
    80004a98:	04f05c63          	blez	a5,80004af0 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004a9c:	37fd                	addw	a5,a5,-1
    80004a9e:	0007871b          	sext.w	a4,a5
    80004aa2:	c0dc                	sw	a5,4(s1)
    80004aa4:	06e04263          	bgtz	a4,80004b08 <fileclose+0x8e>
    80004aa8:	f04a                	sd	s2,32(sp)
    80004aaa:	ec4e                	sd	s3,24(sp)
    80004aac:	e852                	sd	s4,16(sp)
    80004aae:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004ab0:	0004a903          	lw	s2,0(s1)
    80004ab4:	0094ca83          	lbu	s5,9(s1)
    80004ab8:	0104ba03          	ld	s4,16(s1)
    80004abc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004ac0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ac4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ac8:	0001c517          	auipc	a0,0x1c
    80004acc:	30050513          	add	a0,a0,768 # 80020dc8 <ftable>
    80004ad0:	ffffc097          	auipc	ra,0xffffc
    80004ad4:	2e4080e7          	jalr	740(ra) # 80000db4 <release>

  if(ff.type == FD_PIPE){
    80004ad8:	4785                	li	a5,1
    80004ada:	04f90463          	beq	s2,a5,80004b22 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004ade:	3979                	addw	s2,s2,-2
    80004ae0:	4785                	li	a5,1
    80004ae2:	0527fb63          	bgeu	a5,s2,80004b38 <fileclose+0xbe>
    80004ae6:	7902                	ld	s2,32(sp)
    80004ae8:	69e2                	ld	s3,24(sp)
    80004aea:	6a42                	ld	s4,16(sp)
    80004aec:	6aa2                	ld	s5,8(sp)
    80004aee:	a02d                	j	80004b18 <fileclose+0x9e>
    80004af0:	f04a                	sd	s2,32(sp)
    80004af2:	ec4e                	sd	s3,24(sp)
    80004af4:	e852                	sd	s4,16(sp)
    80004af6:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004af8:	00004517          	auipc	a0,0x4
    80004afc:	ba050513          	add	a0,a0,-1120 # 80008698 <__func__.1+0x690>
    80004b00:	ffffc097          	auipc	ra,0xffffc
    80004b04:	a60080e7          	jalr	-1440(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004b08:	0001c517          	auipc	a0,0x1c
    80004b0c:	2c050513          	add	a0,a0,704 # 80020dc8 <ftable>
    80004b10:	ffffc097          	auipc	ra,0xffffc
    80004b14:	2a4080e7          	jalr	676(ra) # 80000db4 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004b18:	70e2                	ld	ra,56(sp)
    80004b1a:	7442                	ld	s0,48(sp)
    80004b1c:	74a2                	ld	s1,40(sp)
    80004b1e:	6121                	add	sp,sp,64
    80004b20:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b22:	85d6                	mv	a1,s5
    80004b24:	8552                	mv	a0,s4
    80004b26:	00000097          	auipc	ra,0x0
    80004b2a:	3a2080e7          	jalr	930(ra) # 80004ec8 <pipeclose>
    80004b2e:	7902                	ld	s2,32(sp)
    80004b30:	69e2                	ld	s3,24(sp)
    80004b32:	6a42                	ld	s4,16(sp)
    80004b34:	6aa2                	ld	s5,8(sp)
    80004b36:	b7cd                	j	80004b18 <fileclose+0x9e>
    begin_op();
    80004b38:	00000097          	auipc	ra,0x0
    80004b3c:	a78080e7          	jalr	-1416(ra) # 800045b0 <begin_op>
    iput(ff.ip);
    80004b40:	854e                	mv	a0,s3
    80004b42:	fffff097          	auipc	ra,0xfffff
    80004b46:	25e080e7          	jalr	606(ra) # 80003da0 <iput>
    end_op();
    80004b4a:	00000097          	auipc	ra,0x0
    80004b4e:	ae0080e7          	jalr	-1312(ra) # 8000462a <end_op>
    80004b52:	7902                	ld	s2,32(sp)
    80004b54:	69e2                	ld	s3,24(sp)
    80004b56:	6a42                	ld	s4,16(sp)
    80004b58:	6aa2                	ld	s5,8(sp)
    80004b5a:	bf7d                	j	80004b18 <fileclose+0x9e>

0000000080004b5c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b5c:	715d                	add	sp,sp,-80
    80004b5e:	e486                	sd	ra,72(sp)
    80004b60:	e0a2                	sd	s0,64(sp)
    80004b62:	fc26                	sd	s1,56(sp)
    80004b64:	f44e                	sd	s3,40(sp)
    80004b66:	0880                	add	s0,sp,80
    80004b68:	84aa                	mv	s1,a0
    80004b6a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b6c:	ffffd097          	auipc	ra,0xffffd
    80004b70:	09a080e7          	jalr	154(ra) # 80001c06 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b74:	409c                	lw	a5,0(s1)
    80004b76:	37f9                	addw	a5,a5,-2
    80004b78:	4705                	li	a4,1
    80004b7a:	04f76863          	bltu	a4,a5,80004bca <filestat+0x6e>
    80004b7e:	f84a                	sd	s2,48(sp)
    80004b80:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b82:	6c88                	ld	a0,24(s1)
    80004b84:	fffff097          	auipc	ra,0xfffff
    80004b88:	05e080e7          	jalr	94(ra) # 80003be2 <ilock>
    stati(f->ip, &st);
    80004b8c:	fb840593          	add	a1,s0,-72
    80004b90:	6c88                	ld	a0,24(s1)
    80004b92:	fffff097          	auipc	ra,0xfffff
    80004b96:	2de080e7          	jalr	734(ra) # 80003e70 <stati>
    iunlock(f->ip);
    80004b9a:	6c88                	ld	a0,24(s1)
    80004b9c:	fffff097          	auipc	ra,0xfffff
    80004ba0:	10c080e7          	jalr	268(ra) # 80003ca8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004ba4:	46e1                	li	a3,24
    80004ba6:	fb840613          	add	a2,s0,-72
    80004baa:	85ce                	mv	a1,s3
    80004bac:	05093503          	ld	a0,80(s2)
    80004bb0:	ffffd097          	auipc	ra,0xffffd
    80004bb4:	bfa080e7          	jalr	-1030(ra) # 800017aa <copyout>
    80004bb8:	41f5551b          	sraw	a0,a0,0x1f
    80004bbc:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004bbe:	60a6                	ld	ra,72(sp)
    80004bc0:	6406                	ld	s0,64(sp)
    80004bc2:	74e2                	ld	s1,56(sp)
    80004bc4:	79a2                	ld	s3,40(sp)
    80004bc6:	6161                	add	sp,sp,80
    80004bc8:	8082                	ret
  return -1;
    80004bca:	557d                	li	a0,-1
    80004bcc:	bfcd                	j	80004bbe <filestat+0x62>

0000000080004bce <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004bce:	7179                	add	sp,sp,-48
    80004bd0:	f406                	sd	ra,40(sp)
    80004bd2:	f022                	sd	s0,32(sp)
    80004bd4:	e84a                	sd	s2,16(sp)
    80004bd6:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004bd8:	00854783          	lbu	a5,8(a0)
    80004bdc:	cbc5                	beqz	a5,80004c8c <fileread+0xbe>
    80004bde:	ec26                	sd	s1,24(sp)
    80004be0:	e44e                	sd	s3,8(sp)
    80004be2:	84aa                	mv	s1,a0
    80004be4:	89ae                	mv	s3,a1
    80004be6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004be8:	411c                	lw	a5,0(a0)
    80004bea:	4705                	li	a4,1
    80004bec:	04e78963          	beq	a5,a4,80004c3e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bf0:	470d                	li	a4,3
    80004bf2:	04e78f63          	beq	a5,a4,80004c50 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bf6:	4709                	li	a4,2
    80004bf8:	08e79263          	bne	a5,a4,80004c7c <fileread+0xae>
    ilock(f->ip);
    80004bfc:	6d08                	ld	a0,24(a0)
    80004bfe:	fffff097          	auipc	ra,0xfffff
    80004c02:	fe4080e7          	jalr	-28(ra) # 80003be2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c06:	874a                	mv	a4,s2
    80004c08:	5094                	lw	a3,32(s1)
    80004c0a:	864e                	mv	a2,s3
    80004c0c:	4585                	li	a1,1
    80004c0e:	6c88                	ld	a0,24(s1)
    80004c10:	fffff097          	auipc	ra,0xfffff
    80004c14:	28a080e7          	jalr	650(ra) # 80003e9a <readi>
    80004c18:	892a                	mv	s2,a0
    80004c1a:	00a05563          	blez	a0,80004c24 <fileread+0x56>
      f->off += r;
    80004c1e:	509c                	lw	a5,32(s1)
    80004c20:	9fa9                	addw	a5,a5,a0
    80004c22:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c24:	6c88                	ld	a0,24(s1)
    80004c26:	fffff097          	auipc	ra,0xfffff
    80004c2a:	082080e7          	jalr	130(ra) # 80003ca8 <iunlock>
    80004c2e:	64e2                	ld	s1,24(sp)
    80004c30:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004c32:	854a                	mv	a0,s2
    80004c34:	70a2                	ld	ra,40(sp)
    80004c36:	7402                	ld	s0,32(sp)
    80004c38:	6942                	ld	s2,16(sp)
    80004c3a:	6145                	add	sp,sp,48
    80004c3c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c3e:	6908                	ld	a0,16(a0)
    80004c40:	00000097          	auipc	ra,0x0
    80004c44:	400080e7          	jalr	1024(ra) # 80005040 <piperead>
    80004c48:	892a                	mv	s2,a0
    80004c4a:	64e2                	ld	s1,24(sp)
    80004c4c:	69a2                	ld	s3,8(sp)
    80004c4e:	b7d5                	j	80004c32 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c50:	02451783          	lh	a5,36(a0)
    80004c54:	03079693          	sll	a3,a5,0x30
    80004c58:	92c1                	srl	a3,a3,0x30
    80004c5a:	4725                	li	a4,9
    80004c5c:	02d76a63          	bltu	a4,a3,80004c90 <fileread+0xc2>
    80004c60:	0792                	sll	a5,a5,0x4
    80004c62:	0001c717          	auipc	a4,0x1c
    80004c66:	0c670713          	add	a4,a4,198 # 80020d28 <devsw>
    80004c6a:	97ba                	add	a5,a5,a4
    80004c6c:	639c                	ld	a5,0(a5)
    80004c6e:	c78d                	beqz	a5,80004c98 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004c70:	4505                	li	a0,1
    80004c72:	9782                	jalr	a5
    80004c74:	892a                	mv	s2,a0
    80004c76:	64e2                	ld	s1,24(sp)
    80004c78:	69a2                	ld	s3,8(sp)
    80004c7a:	bf65                	j	80004c32 <fileread+0x64>
    panic("fileread");
    80004c7c:	00004517          	auipc	a0,0x4
    80004c80:	a2c50513          	add	a0,a0,-1492 # 800086a8 <__func__.1+0x6a0>
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	8dc080e7          	jalr	-1828(ra) # 80000560 <panic>
    return -1;
    80004c8c:	597d                	li	s2,-1
    80004c8e:	b755                	j	80004c32 <fileread+0x64>
      return -1;
    80004c90:	597d                	li	s2,-1
    80004c92:	64e2                	ld	s1,24(sp)
    80004c94:	69a2                	ld	s3,8(sp)
    80004c96:	bf71                	j	80004c32 <fileread+0x64>
    80004c98:	597d                	li	s2,-1
    80004c9a:	64e2                	ld	s1,24(sp)
    80004c9c:	69a2                	ld	s3,8(sp)
    80004c9e:	bf51                	j	80004c32 <fileread+0x64>

0000000080004ca0 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004ca0:	00954783          	lbu	a5,9(a0)
    80004ca4:	12078963          	beqz	a5,80004dd6 <filewrite+0x136>
{
    80004ca8:	715d                	add	sp,sp,-80
    80004caa:	e486                	sd	ra,72(sp)
    80004cac:	e0a2                	sd	s0,64(sp)
    80004cae:	f84a                	sd	s2,48(sp)
    80004cb0:	f052                	sd	s4,32(sp)
    80004cb2:	e85a                	sd	s6,16(sp)
    80004cb4:	0880                	add	s0,sp,80
    80004cb6:	892a                	mv	s2,a0
    80004cb8:	8b2e                	mv	s6,a1
    80004cba:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cbc:	411c                	lw	a5,0(a0)
    80004cbe:	4705                	li	a4,1
    80004cc0:	02e78763          	beq	a5,a4,80004cee <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cc4:	470d                	li	a4,3
    80004cc6:	02e78a63          	beq	a5,a4,80004cfa <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cca:	4709                	li	a4,2
    80004ccc:	0ee79863          	bne	a5,a4,80004dbc <filewrite+0x11c>
    80004cd0:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004cd2:	0cc05463          	blez	a2,80004d9a <filewrite+0xfa>
    80004cd6:	fc26                	sd	s1,56(sp)
    80004cd8:	ec56                	sd	s5,24(sp)
    80004cda:	e45e                	sd	s7,8(sp)
    80004cdc:	e062                	sd	s8,0(sp)
    int i = 0;
    80004cde:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004ce0:	6b85                	lui	s7,0x1
    80004ce2:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004ce6:	6c05                	lui	s8,0x1
    80004ce8:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004cec:	a851                	j	80004d80 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004cee:	6908                	ld	a0,16(a0)
    80004cf0:	00000097          	auipc	ra,0x0
    80004cf4:	248080e7          	jalr	584(ra) # 80004f38 <pipewrite>
    80004cf8:	a85d                	j	80004dae <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cfa:	02451783          	lh	a5,36(a0)
    80004cfe:	03079693          	sll	a3,a5,0x30
    80004d02:	92c1                	srl	a3,a3,0x30
    80004d04:	4725                	li	a4,9
    80004d06:	0cd76a63          	bltu	a4,a3,80004dda <filewrite+0x13a>
    80004d0a:	0792                	sll	a5,a5,0x4
    80004d0c:	0001c717          	auipc	a4,0x1c
    80004d10:	01c70713          	add	a4,a4,28 # 80020d28 <devsw>
    80004d14:	97ba                	add	a5,a5,a4
    80004d16:	679c                	ld	a5,8(a5)
    80004d18:	c3f9                	beqz	a5,80004dde <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004d1a:	4505                	li	a0,1
    80004d1c:	9782                	jalr	a5
    80004d1e:	a841                	j	80004dae <filewrite+0x10e>
      if(n1 > max)
    80004d20:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004d24:	00000097          	auipc	ra,0x0
    80004d28:	88c080e7          	jalr	-1908(ra) # 800045b0 <begin_op>
      ilock(f->ip);
    80004d2c:	01893503          	ld	a0,24(s2)
    80004d30:	fffff097          	auipc	ra,0xfffff
    80004d34:	eb2080e7          	jalr	-334(ra) # 80003be2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d38:	8756                	mv	a4,s5
    80004d3a:	02092683          	lw	a3,32(s2)
    80004d3e:	01698633          	add	a2,s3,s6
    80004d42:	4585                	li	a1,1
    80004d44:	01893503          	ld	a0,24(s2)
    80004d48:	fffff097          	auipc	ra,0xfffff
    80004d4c:	262080e7          	jalr	610(ra) # 80003faa <writei>
    80004d50:	84aa                	mv	s1,a0
    80004d52:	00a05763          	blez	a0,80004d60 <filewrite+0xc0>
        f->off += r;
    80004d56:	02092783          	lw	a5,32(s2)
    80004d5a:	9fa9                	addw	a5,a5,a0
    80004d5c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d60:	01893503          	ld	a0,24(s2)
    80004d64:	fffff097          	auipc	ra,0xfffff
    80004d68:	f44080e7          	jalr	-188(ra) # 80003ca8 <iunlock>
      end_op();
    80004d6c:	00000097          	auipc	ra,0x0
    80004d70:	8be080e7          	jalr	-1858(ra) # 8000462a <end_op>

      if(r != n1){
    80004d74:	029a9563          	bne	s5,s1,80004d9e <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004d78:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d7c:	0149da63          	bge	s3,s4,80004d90 <filewrite+0xf0>
      int n1 = n - i;
    80004d80:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004d84:	0004879b          	sext.w	a5,s1
    80004d88:	f8fbdce3          	bge	s7,a5,80004d20 <filewrite+0x80>
    80004d8c:	84e2                	mv	s1,s8
    80004d8e:	bf49                	j	80004d20 <filewrite+0x80>
    80004d90:	74e2                	ld	s1,56(sp)
    80004d92:	6ae2                	ld	s5,24(sp)
    80004d94:	6ba2                	ld	s7,8(sp)
    80004d96:	6c02                	ld	s8,0(sp)
    80004d98:	a039                	j	80004da6 <filewrite+0x106>
    int i = 0;
    80004d9a:	4981                	li	s3,0
    80004d9c:	a029                	j	80004da6 <filewrite+0x106>
    80004d9e:	74e2                	ld	s1,56(sp)
    80004da0:	6ae2                	ld	s5,24(sp)
    80004da2:	6ba2                	ld	s7,8(sp)
    80004da4:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004da6:	033a1e63          	bne	s4,s3,80004de2 <filewrite+0x142>
    80004daa:	8552                	mv	a0,s4
    80004dac:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004dae:	60a6                	ld	ra,72(sp)
    80004db0:	6406                	ld	s0,64(sp)
    80004db2:	7942                	ld	s2,48(sp)
    80004db4:	7a02                	ld	s4,32(sp)
    80004db6:	6b42                	ld	s6,16(sp)
    80004db8:	6161                	add	sp,sp,80
    80004dba:	8082                	ret
    80004dbc:	fc26                	sd	s1,56(sp)
    80004dbe:	f44e                	sd	s3,40(sp)
    80004dc0:	ec56                	sd	s5,24(sp)
    80004dc2:	e45e                	sd	s7,8(sp)
    80004dc4:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004dc6:	00004517          	auipc	a0,0x4
    80004dca:	8f250513          	add	a0,a0,-1806 # 800086b8 <__func__.1+0x6b0>
    80004dce:	ffffb097          	auipc	ra,0xffffb
    80004dd2:	792080e7          	jalr	1938(ra) # 80000560 <panic>
    return -1;
    80004dd6:	557d                	li	a0,-1
}
    80004dd8:	8082                	ret
      return -1;
    80004dda:	557d                	li	a0,-1
    80004ddc:	bfc9                	j	80004dae <filewrite+0x10e>
    80004dde:	557d                	li	a0,-1
    80004de0:	b7f9                	j	80004dae <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004de2:	557d                	li	a0,-1
    80004de4:	79a2                	ld	s3,40(sp)
    80004de6:	b7e1                	j	80004dae <filewrite+0x10e>

0000000080004de8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004de8:	7179                	add	sp,sp,-48
    80004dea:	f406                	sd	ra,40(sp)
    80004dec:	f022                	sd	s0,32(sp)
    80004dee:	ec26                	sd	s1,24(sp)
    80004df0:	e052                	sd	s4,0(sp)
    80004df2:	1800                	add	s0,sp,48
    80004df4:	84aa                	mv	s1,a0
    80004df6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004df8:	0005b023          	sd	zero,0(a1)
    80004dfc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e00:	00000097          	auipc	ra,0x0
    80004e04:	bbe080e7          	jalr	-1090(ra) # 800049be <filealloc>
    80004e08:	e088                	sd	a0,0(s1)
    80004e0a:	cd49                	beqz	a0,80004ea4 <pipealloc+0xbc>
    80004e0c:	00000097          	auipc	ra,0x0
    80004e10:	bb2080e7          	jalr	-1102(ra) # 800049be <filealloc>
    80004e14:	00aa3023          	sd	a0,0(s4)
    80004e18:	c141                	beqz	a0,80004e98 <pipealloc+0xb0>
    80004e1a:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e1c:	ffffc097          	auipc	ra,0xffffc
    80004e20:	da8080e7          	jalr	-600(ra) # 80000bc4 <kalloc>
    80004e24:	892a                	mv	s2,a0
    80004e26:	c13d                	beqz	a0,80004e8c <pipealloc+0xa4>
    80004e28:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004e2a:	4985                	li	s3,1
    80004e2c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e30:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e34:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e38:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e3c:	00004597          	auipc	a1,0x4
    80004e40:	88c58593          	add	a1,a1,-1908 # 800086c8 <__func__.1+0x6c0>
    80004e44:	ffffc097          	auipc	ra,0xffffc
    80004e48:	e2c080e7          	jalr	-468(ra) # 80000c70 <initlock>
  (*f0)->type = FD_PIPE;
    80004e4c:	609c                	ld	a5,0(s1)
    80004e4e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e52:	609c                	ld	a5,0(s1)
    80004e54:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e58:	609c                	ld	a5,0(s1)
    80004e5a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e5e:	609c                	ld	a5,0(s1)
    80004e60:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e64:	000a3783          	ld	a5,0(s4)
    80004e68:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e6c:	000a3783          	ld	a5,0(s4)
    80004e70:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e74:	000a3783          	ld	a5,0(s4)
    80004e78:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e7c:	000a3783          	ld	a5,0(s4)
    80004e80:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e84:	4501                	li	a0,0
    80004e86:	6942                	ld	s2,16(sp)
    80004e88:	69a2                	ld	s3,8(sp)
    80004e8a:	a03d                	j	80004eb8 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e8c:	6088                	ld	a0,0(s1)
    80004e8e:	c119                	beqz	a0,80004e94 <pipealloc+0xac>
    80004e90:	6942                	ld	s2,16(sp)
    80004e92:	a029                	j	80004e9c <pipealloc+0xb4>
    80004e94:	6942                	ld	s2,16(sp)
    80004e96:	a039                	j	80004ea4 <pipealloc+0xbc>
    80004e98:	6088                	ld	a0,0(s1)
    80004e9a:	c50d                	beqz	a0,80004ec4 <pipealloc+0xdc>
    fileclose(*f0);
    80004e9c:	00000097          	auipc	ra,0x0
    80004ea0:	bde080e7          	jalr	-1058(ra) # 80004a7a <fileclose>
  if(*f1)
    80004ea4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ea8:	557d                	li	a0,-1
  if(*f1)
    80004eaa:	c799                	beqz	a5,80004eb8 <pipealloc+0xd0>
    fileclose(*f1);
    80004eac:	853e                	mv	a0,a5
    80004eae:	00000097          	auipc	ra,0x0
    80004eb2:	bcc080e7          	jalr	-1076(ra) # 80004a7a <fileclose>
  return -1;
    80004eb6:	557d                	li	a0,-1
}
    80004eb8:	70a2                	ld	ra,40(sp)
    80004eba:	7402                	ld	s0,32(sp)
    80004ebc:	64e2                	ld	s1,24(sp)
    80004ebe:	6a02                	ld	s4,0(sp)
    80004ec0:	6145                	add	sp,sp,48
    80004ec2:	8082                	ret
  return -1;
    80004ec4:	557d                	li	a0,-1
    80004ec6:	bfcd                	j	80004eb8 <pipealloc+0xd0>

0000000080004ec8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ec8:	1101                	add	sp,sp,-32
    80004eca:	ec06                	sd	ra,24(sp)
    80004ecc:	e822                	sd	s0,16(sp)
    80004ece:	e426                	sd	s1,8(sp)
    80004ed0:	e04a                	sd	s2,0(sp)
    80004ed2:	1000                	add	s0,sp,32
    80004ed4:	84aa                	mv	s1,a0
    80004ed6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ed8:	ffffc097          	auipc	ra,0xffffc
    80004edc:	e28080e7          	jalr	-472(ra) # 80000d00 <acquire>
  if(writable){
    80004ee0:	02090d63          	beqz	s2,80004f1a <pipeclose+0x52>
    pi->writeopen = 0;
    80004ee4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ee8:	21848513          	add	a0,s1,536
    80004eec:	ffffd097          	auipc	ra,0xffffd
    80004ef0:	530080e7          	jalr	1328(ra) # 8000241c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ef4:	2204b783          	ld	a5,544(s1)
    80004ef8:	eb95                	bnez	a5,80004f2c <pipeclose+0x64>
    release(&pi->lock);
    80004efa:	8526                	mv	a0,s1
    80004efc:	ffffc097          	auipc	ra,0xffffc
    80004f00:	eb8080e7          	jalr	-328(ra) # 80000db4 <release>
    kfree((char*)pi);
    80004f04:	8526                	mv	a0,s1
    80004f06:	ffffc097          	auipc	ra,0xffffc
    80004f0a:	b56080e7          	jalr	-1194(ra) # 80000a5c <kfree>
  } else
    release(&pi->lock);
}
    80004f0e:	60e2                	ld	ra,24(sp)
    80004f10:	6442                	ld	s0,16(sp)
    80004f12:	64a2                	ld	s1,8(sp)
    80004f14:	6902                	ld	s2,0(sp)
    80004f16:	6105                	add	sp,sp,32
    80004f18:	8082                	ret
    pi->readopen = 0;
    80004f1a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f1e:	21c48513          	add	a0,s1,540
    80004f22:	ffffd097          	auipc	ra,0xffffd
    80004f26:	4fa080e7          	jalr	1274(ra) # 8000241c <wakeup>
    80004f2a:	b7e9                	j	80004ef4 <pipeclose+0x2c>
    release(&pi->lock);
    80004f2c:	8526                	mv	a0,s1
    80004f2e:	ffffc097          	auipc	ra,0xffffc
    80004f32:	e86080e7          	jalr	-378(ra) # 80000db4 <release>
}
    80004f36:	bfe1                	j	80004f0e <pipeclose+0x46>

0000000080004f38 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f38:	711d                	add	sp,sp,-96
    80004f3a:	ec86                	sd	ra,88(sp)
    80004f3c:	e8a2                	sd	s0,80(sp)
    80004f3e:	e4a6                	sd	s1,72(sp)
    80004f40:	e0ca                	sd	s2,64(sp)
    80004f42:	fc4e                	sd	s3,56(sp)
    80004f44:	f852                	sd	s4,48(sp)
    80004f46:	f456                	sd	s5,40(sp)
    80004f48:	1080                	add	s0,sp,96
    80004f4a:	84aa                	mv	s1,a0
    80004f4c:	8aae                	mv	s5,a1
    80004f4e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f50:	ffffd097          	auipc	ra,0xffffd
    80004f54:	cb6080e7          	jalr	-842(ra) # 80001c06 <myproc>
    80004f58:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f5a:	8526                	mv	a0,s1
    80004f5c:	ffffc097          	auipc	ra,0xffffc
    80004f60:	da4080e7          	jalr	-604(ra) # 80000d00 <acquire>
  while(i < n){
    80004f64:	0d405863          	blez	s4,80005034 <pipewrite+0xfc>
    80004f68:	f05a                	sd	s6,32(sp)
    80004f6a:	ec5e                	sd	s7,24(sp)
    80004f6c:	e862                	sd	s8,16(sp)
  int i = 0;
    80004f6e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f70:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f72:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f76:	21c48b93          	add	s7,s1,540
    80004f7a:	a089                	j	80004fbc <pipewrite+0x84>
      release(&pi->lock);
    80004f7c:	8526                	mv	a0,s1
    80004f7e:	ffffc097          	auipc	ra,0xffffc
    80004f82:	e36080e7          	jalr	-458(ra) # 80000db4 <release>
      return -1;
    80004f86:	597d                	li	s2,-1
    80004f88:	7b02                	ld	s6,32(sp)
    80004f8a:	6be2                	ld	s7,24(sp)
    80004f8c:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f8e:	854a                	mv	a0,s2
    80004f90:	60e6                	ld	ra,88(sp)
    80004f92:	6446                	ld	s0,80(sp)
    80004f94:	64a6                	ld	s1,72(sp)
    80004f96:	6906                	ld	s2,64(sp)
    80004f98:	79e2                	ld	s3,56(sp)
    80004f9a:	7a42                	ld	s4,48(sp)
    80004f9c:	7aa2                	ld	s5,40(sp)
    80004f9e:	6125                	add	sp,sp,96
    80004fa0:	8082                	ret
      wakeup(&pi->nread);
    80004fa2:	8562                	mv	a0,s8
    80004fa4:	ffffd097          	auipc	ra,0xffffd
    80004fa8:	478080e7          	jalr	1144(ra) # 8000241c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004fac:	85a6                	mv	a1,s1
    80004fae:	855e                	mv	a0,s7
    80004fb0:	ffffd097          	auipc	ra,0xffffd
    80004fb4:	408080e7          	jalr	1032(ra) # 800023b8 <sleep>
  while(i < n){
    80004fb8:	05495f63          	bge	s2,s4,80005016 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80004fbc:	2204a783          	lw	a5,544(s1)
    80004fc0:	dfd5                	beqz	a5,80004f7c <pipewrite+0x44>
    80004fc2:	854e                	mv	a0,s3
    80004fc4:	ffffd097          	auipc	ra,0xffffd
    80004fc8:	69c080e7          	jalr	1692(ra) # 80002660 <killed>
    80004fcc:	f945                	bnez	a0,80004f7c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004fce:	2184a783          	lw	a5,536(s1)
    80004fd2:	21c4a703          	lw	a4,540(s1)
    80004fd6:	2007879b          	addw	a5,a5,512
    80004fda:	fcf704e3          	beq	a4,a5,80004fa2 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fde:	4685                	li	a3,1
    80004fe0:	01590633          	add	a2,s2,s5
    80004fe4:	faf40593          	add	a1,s0,-81
    80004fe8:	0509b503          	ld	a0,80(s3)
    80004fec:	ffffd097          	auipc	ra,0xffffd
    80004ff0:	84a080e7          	jalr	-1974(ra) # 80001836 <copyin>
    80004ff4:	05650263          	beq	a0,s6,80005038 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ff8:	21c4a783          	lw	a5,540(s1)
    80004ffc:	0017871b          	addw	a4,a5,1
    80005000:	20e4ae23          	sw	a4,540(s1)
    80005004:	1ff7f793          	and	a5,a5,511
    80005008:	97a6                	add	a5,a5,s1
    8000500a:	faf44703          	lbu	a4,-81(s0)
    8000500e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005012:	2905                	addw	s2,s2,1
    80005014:	b755                	j	80004fb8 <pipewrite+0x80>
    80005016:	7b02                	ld	s6,32(sp)
    80005018:	6be2                	ld	s7,24(sp)
    8000501a:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000501c:	21848513          	add	a0,s1,536
    80005020:	ffffd097          	auipc	ra,0xffffd
    80005024:	3fc080e7          	jalr	1020(ra) # 8000241c <wakeup>
  release(&pi->lock);
    80005028:	8526                	mv	a0,s1
    8000502a:	ffffc097          	auipc	ra,0xffffc
    8000502e:	d8a080e7          	jalr	-630(ra) # 80000db4 <release>
  return i;
    80005032:	bfb1                	j	80004f8e <pipewrite+0x56>
  int i = 0;
    80005034:	4901                	li	s2,0
    80005036:	b7dd                	j	8000501c <pipewrite+0xe4>
    80005038:	7b02                	ld	s6,32(sp)
    8000503a:	6be2                	ld	s7,24(sp)
    8000503c:	6c42                	ld	s8,16(sp)
    8000503e:	bff9                	j	8000501c <pipewrite+0xe4>

0000000080005040 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005040:	715d                	add	sp,sp,-80
    80005042:	e486                	sd	ra,72(sp)
    80005044:	e0a2                	sd	s0,64(sp)
    80005046:	fc26                	sd	s1,56(sp)
    80005048:	f84a                	sd	s2,48(sp)
    8000504a:	f44e                	sd	s3,40(sp)
    8000504c:	f052                	sd	s4,32(sp)
    8000504e:	ec56                	sd	s5,24(sp)
    80005050:	0880                	add	s0,sp,80
    80005052:	84aa                	mv	s1,a0
    80005054:	892e                	mv	s2,a1
    80005056:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005058:	ffffd097          	auipc	ra,0xffffd
    8000505c:	bae080e7          	jalr	-1106(ra) # 80001c06 <myproc>
    80005060:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005062:	8526                	mv	a0,s1
    80005064:	ffffc097          	auipc	ra,0xffffc
    80005068:	c9c080e7          	jalr	-868(ra) # 80000d00 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000506c:	2184a703          	lw	a4,536(s1)
    80005070:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005074:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005078:	02f71963          	bne	a4,a5,800050aa <piperead+0x6a>
    8000507c:	2244a783          	lw	a5,548(s1)
    80005080:	cf95                	beqz	a5,800050bc <piperead+0x7c>
    if(killed(pr)){
    80005082:	8552                	mv	a0,s4
    80005084:	ffffd097          	auipc	ra,0xffffd
    80005088:	5dc080e7          	jalr	1500(ra) # 80002660 <killed>
    8000508c:	e10d                	bnez	a0,800050ae <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000508e:	85a6                	mv	a1,s1
    80005090:	854e                	mv	a0,s3
    80005092:	ffffd097          	auipc	ra,0xffffd
    80005096:	326080e7          	jalr	806(ra) # 800023b8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000509a:	2184a703          	lw	a4,536(s1)
    8000509e:	21c4a783          	lw	a5,540(s1)
    800050a2:	fcf70de3          	beq	a4,a5,8000507c <piperead+0x3c>
    800050a6:	e85a                	sd	s6,16(sp)
    800050a8:	a819                	j	800050be <piperead+0x7e>
    800050aa:	e85a                	sd	s6,16(sp)
    800050ac:	a809                	j	800050be <piperead+0x7e>
      release(&pi->lock);
    800050ae:	8526                	mv	a0,s1
    800050b0:	ffffc097          	auipc	ra,0xffffc
    800050b4:	d04080e7          	jalr	-764(ra) # 80000db4 <release>
      return -1;
    800050b8:	59fd                	li	s3,-1
    800050ba:	a0a5                	j	80005122 <piperead+0xe2>
    800050bc:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050be:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050c0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050c2:	05505463          	blez	s5,8000510a <piperead+0xca>
    if(pi->nread == pi->nwrite)
    800050c6:	2184a783          	lw	a5,536(s1)
    800050ca:	21c4a703          	lw	a4,540(s1)
    800050ce:	02f70e63          	beq	a4,a5,8000510a <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800050d2:	0017871b          	addw	a4,a5,1
    800050d6:	20e4ac23          	sw	a4,536(s1)
    800050da:	1ff7f793          	and	a5,a5,511
    800050de:	97a6                	add	a5,a5,s1
    800050e0:	0187c783          	lbu	a5,24(a5)
    800050e4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050e8:	4685                	li	a3,1
    800050ea:	fbf40613          	add	a2,s0,-65
    800050ee:	85ca                	mv	a1,s2
    800050f0:	050a3503          	ld	a0,80(s4)
    800050f4:	ffffc097          	auipc	ra,0xffffc
    800050f8:	6b6080e7          	jalr	1718(ra) # 800017aa <copyout>
    800050fc:	01650763          	beq	a0,s6,8000510a <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005100:	2985                	addw	s3,s3,1
    80005102:	0905                	add	s2,s2,1
    80005104:	fd3a91e3          	bne	s5,s3,800050c6 <piperead+0x86>
    80005108:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000510a:	21c48513          	add	a0,s1,540
    8000510e:	ffffd097          	auipc	ra,0xffffd
    80005112:	30e080e7          	jalr	782(ra) # 8000241c <wakeup>
  release(&pi->lock);
    80005116:	8526                	mv	a0,s1
    80005118:	ffffc097          	auipc	ra,0xffffc
    8000511c:	c9c080e7          	jalr	-868(ra) # 80000db4 <release>
    80005120:	6b42                	ld	s6,16(sp)
  return i;
}
    80005122:	854e                	mv	a0,s3
    80005124:	60a6                	ld	ra,72(sp)
    80005126:	6406                	ld	s0,64(sp)
    80005128:	74e2                	ld	s1,56(sp)
    8000512a:	7942                	ld	s2,48(sp)
    8000512c:	79a2                	ld	s3,40(sp)
    8000512e:	7a02                	ld	s4,32(sp)
    80005130:	6ae2                	ld	s5,24(sp)
    80005132:	6161                	add	sp,sp,80
    80005134:	8082                	ret

0000000080005136 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005136:	1141                	add	sp,sp,-16
    80005138:	e422                	sd	s0,8(sp)
    8000513a:	0800                	add	s0,sp,16
    8000513c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000513e:	8905                	and	a0,a0,1
    80005140:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005142:	8b89                	and	a5,a5,2
    80005144:	c399                	beqz	a5,8000514a <flags2perm+0x14>
      perm |= PTE_W;
    80005146:	00456513          	or	a0,a0,4
    return perm;
}
    8000514a:	6422                	ld	s0,8(sp)
    8000514c:	0141                	add	sp,sp,16
    8000514e:	8082                	ret

0000000080005150 <exec>:

int
exec(char *path, char **argv)
{
    80005150:	df010113          	add	sp,sp,-528
    80005154:	20113423          	sd	ra,520(sp)
    80005158:	20813023          	sd	s0,512(sp)
    8000515c:	ffa6                	sd	s1,504(sp)
    8000515e:	fbca                	sd	s2,496(sp)
    80005160:	0c00                	add	s0,sp,528
    80005162:	892a                	mv	s2,a0
    80005164:	dea43c23          	sd	a0,-520(s0)
    80005168:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000516c:	ffffd097          	auipc	ra,0xffffd
    80005170:	a9a080e7          	jalr	-1382(ra) # 80001c06 <myproc>
    80005174:	84aa                	mv	s1,a0

  begin_op();
    80005176:	fffff097          	auipc	ra,0xfffff
    8000517a:	43a080e7          	jalr	1082(ra) # 800045b0 <begin_op>

  if((ip = namei(path)) == 0){
    8000517e:	854a                	mv	a0,s2
    80005180:	fffff097          	auipc	ra,0xfffff
    80005184:	230080e7          	jalr	560(ra) # 800043b0 <namei>
    80005188:	c135                	beqz	a0,800051ec <exec+0x9c>
    8000518a:	f3d2                	sd	s4,480(sp)
    8000518c:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000518e:	fffff097          	auipc	ra,0xfffff
    80005192:	a54080e7          	jalr	-1452(ra) # 80003be2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005196:	04000713          	li	a4,64
    8000519a:	4681                	li	a3,0
    8000519c:	e5040613          	add	a2,s0,-432
    800051a0:	4581                	li	a1,0
    800051a2:	8552                	mv	a0,s4
    800051a4:	fffff097          	auipc	ra,0xfffff
    800051a8:	cf6080e7          	jalr	-778(ra) # 80003e9a <readi>
    800051ac:	04000793          	li	a5,64
    800051b0:	00f51a63          	bne	a0,a5,800051c4 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800051b4:	e5042703          	lw	a4,-432(s0)
    800051b8:	464c47b7          	lui	a5,0x464c4
    800051bc:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051c0:	02f70c63          	beq	a4,a5,800051f8 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051c4:	8552                	mv	a0,s4
    800051c6:	fffff097          	auipc	ra,0xfffff
    800051ca:	c82080e7          	jalr	-894(ra) # 80003e48 <iunlockput>
    end_op();
    800051ce:	fffff097          	auipc	ra,0xfffff
    800051d2:	45c080e7          	jalr	1116(ra) # 8000462a <end_op>
  }
  return -1;
    800051d6:	557d                	li	a0,-1
    800051d8:	7a1e                	ld	s4,480(sp)
}
    800051da:	20813083          	ld	ra,520(sp)
    800051de:	20013403          	ld	s0,512(sp)
    800051e2:	74fe                	ld	s1,504(sp)
    800051e4:	795e                	ld	s2,496(sp)
    800051e6:	21010113          	add	sp,sp,528
    800051ea:	8082                	ret
    end_op();
    800051ec:	fffff097          	auipc	ra,0xfffff
    800051f0:	43e080e7          	jalr	1086(ra) # 8000462a <end_op>
    return -1;
    800051f4:	557d                	li	a0,-1
    800051f6:	b7d5                	j	800051da <exec+0x8a>
    800051f8:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800051fa:	8526                	mv	a0,s1
    800051fc:	ffffd097          	auipc	ra,0xffffd
    80005200:	ace080e7          	jalr	-1330(ra) # 80001cca <proc_pagetable>
    80005204:	8b2a                	mv	s6,a0
    80005206:	30050f63          	beqz	a0,80005524 <exec+0x3d4>
    8000520a:	f7ce                	sd	s3,488(sp)
    8000520c:	efd6                	sd	s5,472(sp)
    8000520e:	e7de                	sd	s7,456(sp)
    80005210:	e3e2                	sd	s8,448(sp)
    80005212:	ff66                	sd	s9,440(sp)
    80005214:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005216:	e7042d03          	lw	s10,-400(s0)
    8000521a:	e8845783          	lhu	a5,-376(s0)
    8000521e:	14078d63          	beqz	a5,80005378 <exec+0x228>
    80005222:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005224:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005226:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005228:	6c85                	lui	s9,0x1
    8000522a:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000522e:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005232:	6a85                	lui	s5,0x1
    80005234:	a0b5                	j	800052a0 <exec+0x150>
      panic("loadseg: address should exist");
    80005236:	00003517          	auipc	a0,0x3
    8000523a:	49a50513          	add	a0,a0,1178 # 800086d0 <__func__.1+0x6c8>
    8000523e:	ffffb097          	auipc	ra,0xffffb
    80005242:	322080e7          	jalr	802(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80005246:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005248:	8726                	mv	a4,s1
    8000524a:	012c06bb          	addw	a3,s8,s2
    8000524e:	4581                	li	a1,0
    80005250:	8552                	mv	a0,s4
    80005252:	fffff097          	auipc	ra,0xfffff
    80005256:	c48080e7          	jalr	-952(ra) # 80003e9a <readi>
    8000525a:	2501                	sext.w	a0,a0
    8000525c:	28a49863          	bne	s1,a0,800054ec <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    80005260:	012a893b          	addw	s2,s5,s2
    80005264:	03397563          	bgeu	s2,s3,8000528e <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80005268:	02091593          	sll	a1,s2,0x20
    8000526c:	9181                	srl	a1,a1,0x20
    8000526e:	95de                	add	a1,a1,s7
    80005270:	855a                	mv	a0,s6
    80005272:	ffffc097          	auipc	ra,0xffffc
    80005276:	f0c080e7          	jalr	-244(ra) # 8000117e <walkaddr>
    8000527a:	862a                	mv	a2,a0
    if(pa == 0)
    8000527c:	dd4d                	beqz	a0,80005236 <exec+0xe6>
    if(sz - i < PGSIZE)
    8000527e:	412984bb          	subw	s1,s3,s2
    80005282:	0004879b          	sext.w	a5,s1
    80005286:	fcfcf0e3          	bgeu	s9,a5,80005246 <exec+0xf6>
    8000528a:	84d6                	mv	s1,s5
    8000528c:	bf6d                	j	80005246 <exec+0xf6>
    sz = sz1;
    8000528e:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005292:	2d85                	addw	s11,s11,1
    80005294:	038d0d1b          	addw	s10,s10,56
    80005298:	e8845783          	lhu	a5,-376(s0)
    8000529c:	08fdd663          	bge	s11,a5,80005328 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052a0:	2d01                	sext.w	s10,s10
    800052a2:	03800713          	li	a4,56
    800052a6:	86ea                	mv	a3,s10
    800052a8:	e1840613          	add	a2,s0,-488
    800052ac:	4581                	li	a1,0
    800052ae:	8552                	mv	a0,s4
    800052b0:	fffff097          	auipc	ra,0xfffff
    800052b4:	bea080e7          	jalr	-1046(ra) # 80003e9a <readi>
    800052b8:	03800793          	li	a5,56
    800052bc:	20f51063          	bne	a0,a5,800054bc <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    800052c0:	e1842783          	lw	a5,-488(s0)
    800052c4:	4705                	li	a4,1
    800052c6:	fce796e3          	bne	a5,a4,80005292 <exec+0x142>
    if(ph.memsz < ph.filesz)
    800052ca:	e4043483          	ld	s1,-448(s0)
    800052ce:	e3843783          	ld	a5,-456(s0)
    800052d2:	1ef4e963          	bltu	s1,a5,800054c4 <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800052d6:	e2843783          	ld	a5,-472(s0)
    800052da:	94be                	add	s1,s1,a5
    800052dc:	1ef4e863          	bltu	s1,a5,800054cc <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    800052e0:	df043703          	ld	a4,-528(s0)
    800052e4:	8ff9                	and	a5,a5,a4
    800052e6:	1e079763          	bnez	a5,800054d4 <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800052ea:	e1c42503          	lw	a0,-484(s0)
    800052ee:	00000097          	auipc	ra,0x0
    800052f2:	e48080e7          	jalr	-440(ra) # 80005136 <flags2perm>
    800052f6:	86aa                	mv	a3,a0
    800052f8:	8626                	mv	a2,s1
    800052fa:	85ca                	mv	a1,s2
    800052fc:	855a                	mv	a0,s6
    800052fe:	ffffc097          	auipc	ra,0xffffc
    80005302:	244080e7          	jalr	580(ra) # 80001542 <uvmalloc>
    80005306:	e0a43423          	sd	a0,-504(s0)
    8000530a:	1c050963          	beqz	a0,800054dc <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000530e:	e2843b83          	ld	s7,-472(s0)
    80005312:	e2042c03          	lw	s8,-480(s0)
    80005316:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000531a:	00098463          	beqz	s3,80005322 <exec+0x1d2>
    8000531e:	4901                	li	s2,0
    80005320:	b7a1                	j	80005268 <exec+0x118>
    sz = sz1;
    80005322:	e0843903          	ld	s2,-504(s0)
    80005326:	b7b5                	j	80005292 <exec+0x142>
    80005328:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000532a:	8552                	mv	a0,s4
    8000532c:	fffff097          	auipc	ra,0xfffff
    80005330:	b1c080e7          	jalr	-1252(ra) # 80003e48 <iunlockput>
  end_op();
    80005334:	fffff097          	auipc	ra,0xfffff
    80005338:	2f6080e7          	jalr	758(ra) # 8000462a <end_op>
  p = myproc();
    8000533c:	ffffd097          	auipc	ra,0xffffd
    80005340:	8ca080e7          	jalr	-1846(ra) # 80001c06 <myproc>
    80005344:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005346:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000534a:	6985                	lui	s3,0x1
    8000534c:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000534e:	99ca                	add	s3,s3,s2
    80005350:	77fd                	lui	a5,0xfffff
    80005352:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005356:	4691                	li	a3,4
    80005358:	6609                	lui	a2,0x2
    8000535a:	964e                	add	a2,a2,s3
    8000535c:	85ce                	mv	a1,s3
    8000535e:	855a                	mv	a0,s6
    80005360:	ffffc097          	auipc	ra,0xffffc
    80005364:	1e2080e7          	jalr	482(ra) # 80001542 <uvmalloc>
    80005368:	892a                	mv	s2,a0
    8000536a:	e0a43423          	sd	a0,-504(s0)
    8000536e:	e519                	bnez	a0,8000537c <exec+0x22c>
  if(pagetable)
    80005370:	e1343423          	sd	s3,-504(s0)
    80005374:	4a01                	li	s4,0
    80005376:	aaa5                	j	800054ee <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005378:	4901                	li	s2,0
    8000537a:	bf45                	j	8000532a <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000537c:	75f9                	lui	a1,0xffffe
    8000537e:	95aa                	add	a1,a1,a0
    80005380:	855a                	mv	a0,s6
    80005382:	ffffc097          	auipc	ra,0xffffc
    80005386:	3f6080e7          	jalr	1014(ra) # 80001778 <uvmclear>
  stackbase = sp - PGSIZE;
    8000538a:	7bfd                	lui	s7,0xfffff
    8000538c:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000538e:	e0043783          	ld	a5,-512(s0)
    80005392:	6388                	ld	a0,0(a5)
    80005394:	c52d                	beqz	a0,800053fe <exec+0x2ae>
    80005396:	e9040993          	add	s3,s0,-368
    8000539a:	f9040c13          	add	s8,s0,-112
    8000539e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800053a0:	ffffc097          	auipc	ra,0xffffc
    800053a4:	bd0080e7          	jalr	-1072(ra) # 80000f70 <strlen>
    800053a8:	0015079b          	addw	a5,a0,1
    800053ac:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800053b0:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    800053b4:	13796863          	bltu	s2,s7,800054e4 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053b8:	e0043d03          	ld	s10,-512(s0)
    800053bc:	000d3a03          	ld	s4,0(s10)
    800053c0:	8552                	mv	a0,s4
    800053c2:	ffffc097          	auipc	ra,0xffffc
    800053c6:	bae080e7          	jalr	-1106(ra) # 80000f70 <strlen>
    800053ca:	0015069b          	addw	a3,a0,1
    800053ce:	8652                	mv	a2,s4
    800053d0:	85ca                	mv	a1,s2
    800053d2:	855a                	mv	a0,s6
    800053d4:	ffffc097          	auipc	ra,0xffffc
    800053d8:	3d6080e7          	jalr	982(ra) # 800017aa <copyout>
    800053dc:	10054663          	bltz	a0,800054e8 <exec+0x398>
    ustack[argc] = sp;
    800053e0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800053e4:	0485                	add	s1,s1,1
    800053e6:	008d0793          	add	a5,s10,8
    800053ea:	e0f43023          	sd	a5,-512(s0)
    800053ee:	008d3503          	ld	a0,8(s10)
    800053f2:	c909                	beqz	a0,80005404 <exec+0x2b4>
    if(argc >= MAXARG)
    800053f4:	09a1                	add	s3,s3,8
    800053f6:	fb8995e3          	bne	s3,s8,800053a0 <exec+0x250>
  ip = 0;
    800053fa:	4a01                	li	s4,0
    800053fc:	a8cd                	j	800054ee <exec+0x39e>
  sp = sz;
    800053fe:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005402:	4481                	li	s1,0
  ustack[argc] = 0;
    80005404:	00349793          	sll	a5,s1,0x3
    80005408:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd0d0>
    8000540c:	97a2                	add	a5,a5,s0
    8000540e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005412:	00148693          	add	a3,s1,1
    80005416:	068e                	sll	a3,a3,0x3
    80005418:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000541c:	ff097913          	and	s2,s2,-16
  sz = sz1;
    80005420:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005424:	f57966e3          	bltu	s2,s7,80005370 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005428:	e9040613          	add	a2,s0,-368
    8000542c:	85ca                	mv	a1,s2
    8000542e:	855a                	mv	a0,s6
    80005430:	ffffc097          	auipc	ra,0xffffc
    80005434:	37a080e7          	jalr	890(ra) # 800017aa <copyout>
    80005438:	0e054863          	bltz	a0,80005528 <exec+0x3d8>
  p->trapframe->a1 = sp;
    8000543c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005440:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005444:	df843783          	ld	a5,-520(s0)
    80005448:	0007c703          	lbu	a4,0(a5)
    8000544c:	cf11                	beqz	a4,80005468 <exec+0x318>
    8000544e:	0785                	add	a5,a5,1
    if(*s == '/')
    80005450:	02f00693          	li	a3,47
    80005454:	a039                	j	80005462 <exec+0x312>
      last = s+1;
    80005456:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000545a:	0785                	add	a5,a5,1
    8000545c:	fff7c703          	lbu	a4,-1(a5)
    80005460:	c701                	beqz	a4,80005468 <exec+0x318>
    if(*s == '/')
    80005462:	fed71ce3          	bne	a4,a3,8000545a <exec+0x30a>
    80005466:	bfc5                	j	80005456 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    80005468:	4641                	li	a2,16
    8000546a:	df843583          	ld	a1,-520(s0)
    8000546e:	158a8513          	add	a0,s5,344
    80005472:	ffffc097          	auipc	ra,0xffffc
    80005476:	acc080e7          	jalr	-1332(ra) # 80000f3e <safestrcpy>
  oldpagetable = p->pagetable;
    8000547a:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000547e:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005482:	e0843783          	ld	a5,-504(s0)
    80005486:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000548a:	058ab783          	ld	a5,88(s5)
    8000548e:	e6843703          	ld	a4,-408(s0)
    80005492:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005494:	058ab783          	ld	a5,88(s5)
    80005498:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000549c:	85e6                	mv	a1,s9
    8000549e:	ffffd097          	auipc	ra,0xffffd
    800054a2:	8c8080e7          	jalr	-1848(ra) # 80001d66 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054a6:	0004851b          	sext.w	a0,s1
    800054aa:	79be                	ld	s3,488(sp)
    800054ac:	7a1e                	ld	s4,480(sp)
    800054ae:	6afe                	ld	s5,472(sp)
    800054b0:	6b5e                	ld	s6,464(sp)
    800054b2:	6bbe                	ld	s7,456(sp)
    800054b4:	6c1e                	ld	s8,448(sp)
    800054b6:	7cfa                	ld	s9,440(sp)
    800054b8:	7d5a                	ld	s10,432(sp)
    800054ba:	b305                	j	800051da <exec+0x8a>
    800054bc:	e1243423          	sd	s2,-504(s0)
    800054c0:	7dba                	ld	s11,424(sp)
    800054c2:	a035                	j	800054ee <exec+0x39e>
    800054c4:	e1243423          	sd	s2,-504(s0)
    800054c8:	7dba                	ld	s11,424(sp)
    800054ca:	a015                	j	800054ee <exec+0x39e>
    800054cc:	e1243423          	sd	s2,-504(s0)
    800054d0:	7dba                	ld	s11,424(sp)
    800054d2:	a831                	j	800054ee <exec+0x39e>
    800054d4:	e1243423          	sd	s2,-504(s0)
    800054d8:	7dba                	ld	s11,424(sp)
    800054da:	a811                	j	800054ee <exec+0x39e>
    800054dc:	e1243423          	sd	s2,-504(s0)
    800054e0:	7dba                	ld	s11,424(sp)
    800054e2:	a031                	j	800054ee <exec+0x39e>
  ip = 0;
    800054e4:	4a01                	li	s4,0
    800054e6:	a021                	j	800054ee <exec+0x39e>
    800054e8:	4a01                	li	s4,0
  if(pagetable)
    800054ea:	a011                	j	800054ee <exec+0x39e>
    800054ec:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800054ee:	e0843583          	ld	a1,-504(s0)
    800054f2:	855a                	mv	a0,s6
    800054f4:	ffffd097          	auipc	ra,0xffffd
    800054f8:	872080e7          	jalr	-1934(ra) # 80001d66 <proc_freepagetable>
  return -1;
    800054fc:	557d                	li	a0,-1
  if(ip){
    800054fe:	000a1b63          	bnez	s4,80005514 <exec+0x3c4>
    80005502:	79be                	ld	s3,488(sp)
    80005504:	7a1e                	ld	s4,480(sp)
    80005506:	6afe                	ld	s5,472(sp)
    80005508:	6b5e                	ld	s6,464(sp)
    8000550a:	6bbe                	ld	s7,456(sp)
    8000550c:	6c1e                	ld	s8,448(sp)
    8000550e:	7cfa                	ld	s9,440(sp)
    80005510:	7d5a                	ld	s10,432(sp)
    80005512:	b1e1                	j	800051da <exec+0x8a>
    80005514:	79be                	ld	s3,488(sp)
    80005516:	6afe                	ld	s5,472(sp)
    80005518:	6b5e                	ld	s6,464(sp)
    8000551a:	6bbe                	ld	s7,456(sp)
    8000551c:	6c1e                	ld	s8,448(sp)
    8000551e:	7cfa                	ld	s9,440(sp)
    80005520:	7d5a                	ld	s10,432(sp)
    80005522:	b14d                	j	800051c4 <exec+0x74>
    80005524:	6b5e                	ld	s6,464(sp)
    80005526:	b979                	j	800051c4 <exec+0x74>
  sz = sz1;
    80005528:	e0843983          	ld	s3,-504(s0)
    8000552c:	b591                	j	80005370 <exec+0x220>

000000008000552e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000552e:	7179                	add	sp,sp,-48
    80005530:	f406                	sd	ra,40(sp)
    80005532:	f022                	sd	s0,32(sp)
    80005534:	ec26                	sd	s1,24(sp)
    80005536:	e84a                	sd	s2,16(sp)
    80005538:	1800                	add	s0,sp,48
    8000553a:	892e                	mv	s2,a1
    8000553c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000553e:	fdc40593          	add	a1,s0,-36
    80005542:	ffffe097          	auipc	ra,0xffffe
    80005546:	9ce080e7          	jalr	-1586(ra) # 80002f10 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000554a:	fdc42703          	lw	a4,-36(s0)
    8000554e:	47bd                	li	a5,15
    80005550:	02e7eb63          	bltu	a5,a4,80005586 <argfd+0x58>
    80005554:	ffffc097          	auipc	ra,0xffffc
    80005558:	6b2080e7          	jalr	1714(ra) # 80001c06 <myproc>
    8000555c:	fdc42703          	lw	a4,-36(s0)
    80005560:	01a70793          	add	a5,a4,26
    80005564:	078e                	sll	a5,a5,0x3
    80005566:	953e                	add	a0,a0,a5
    80005568:	611c                	ld	a5,0(a0)
    8000556a:	c385                	beqz	a5,8000558a <argfd+0x5c>
    return -1;
  if(pfd)
    8000556c:	00090463          	beqz	s2,80005574 <argfd+0x46>
    *pfd = fd;
    80005570:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005574:	4501                	li	a0,0
  if(pf)
    80005576:	c091                	beqz	s1,8000557a <argfd+0x4c>
    *pf = f;
    80005578:	e09c                	sd	a5,0(s1)
}
    8000557a:	70a2                	ld	ra,40(sp)
    8000557c:	7402                	ld	s0,32(sp)
    8000557e:	64e2                	ld	s1,24(sp)
    80005580:	6942                	ld	s2,16(sp)
    80005582:	6145                	add	sp,sp,48
    80005584:	8082                	ret
    return -1;
    80005586:	557d                	li	a0,-1
    80005588:	bfcd                	j	8000557a <argfd+0x4c>
    8000558a:	557d                	li	a0,-1
    8000558c:	b7fd                	j	8000557a <argfd+0x4c>

000000008000558e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000558e:	1101                	add	sp,sp,-32
    80005590:	ec06                	sd	ra,24(sp)
    80005592:	e822                	sd	s0,16(sp)
    80005594:	e426                	sd	s1,8(sp)
    80005596:	1000                	add	s0,sp,32
    80005598:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000559a:	ffffc097          	auipc	ra,0xffffc
    8000559e:	66c080e7          	jalr	1644(ra) # 80001c06 <myproc>
    800055a2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800055a4:	0d050793          	add	a5,a0,208
    800055a8:	4501                	li	a0,0
    800055aa:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800055ac:	6398                	ld	a4,0(a5)
    800055ae:	cb19                	beqz	a4,800055c4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800055b0:	2505                	addw	a0,a0,1
    800055b2:	07a1                	add	a5,a5,8
    800055b4:	fed51ce3          	bne	a0,a3,800055ac <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800055b8:	557d                	li	a0,-1
}
    800055ba:	60e2                	ld	ra,24(sp)
    800055bc:	6442                	ld	s0,16(sp)
    800055be:	64a2                	ld	s1,8(sp)
    800055c0:	6105                	add	sp,sp,32
    800055c2:	8082                	ret
      p->ofile[fd] = f;
    800055c4:	01a50793          	add	a5,a0,26
    800055c8:	078e                	sll	a5,a5,0x3
    800055ca:	963e                	add	a2,a2,a5
    800055cc:	e204                	sd	s1,0(a2)
      return fd;
    800055ce:	b7f5                	j	800055ba <fdalloc+0x2c>

00000000800055d0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055d0:	715d                	add	sp,sp,-80
    800055d2:	e486                	sd	ra,72(sp)
    800055d4:	e0a2                	sd	s0,64(sp)
    800055d6:	fc26                	sd	s1,56(sp)
    800055d8:	f84a                	sd	s2,48(sp)
    800055da:	f44e                	sd	s3,40(sp)
    800055dc:	ec56                	sd	s5,24(sp)
    800055de:	e85a                	sd	s6,16(sp)
    800055e0:	0880                	add	s0,sp,80
    800055e2:	8b2e                	mv	s6,a1
    800055e4:	89b2                	mv	s3,a2
    800055e6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800055e8:	fb040593          	add	a1,s0,-80
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	de2080e7          	jalr	-542(ra) # 800043ce <nameiparent>
    800055f4:	84aa                	mv	s1,a0
    800055f6:	14050e63          	beqz	a0,80005752 <create+0x182>
    return 0;

  ilock(dp);
    800055fa:	ffffe097          	auipc	ra,0xffffe
    800055fe:	5e8080e7          	jalr	1512(ra) # 80003be2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005602:	4601                	li	a2,0
    80005604:	fb040593          	add	a1,s0,-80
    80005608:	8526                	mv	a0,s1
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	ae4080e7          	jalr	-1308(ra) # 800040ee <dirlookup>
    80005612:	8aaa                	mv	s5,a0
    80005614:	c539                	beqz	a0,80005662 <create+0x92>
    iunlockput(dp);
    80005616:	8526                	mv	a0,s1
    80005618:	fffff097          	auipc	ra,0xfffff
    8000561c:	830080e7          	jalr	-2000(ra) # 80003e48 <iunlockput>
    ilock(ip);
    80005620:	8556                	mv	a0,s5
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	5c0080e7          	jalr	1472(ra) # 80003be2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000562a:	4789                	li	a5,2
    8000562c:	02fb1463          	bne	s6,a5,80005654 <create+0x84>
    80005630:	044ad783          	lhu	a5,68(s5)
    80005634:	37f9                	addw	a5,a5,-2
    80005636:	17c2                	sll	a5,a5,0x30
    80005638:	93c1                	srl	a5,a5,0x30
    8000563a:	4705                	li	a4,1
    8000563c:	00f76c63          	bltu	a4,a5,80005654 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005640:	8556                	mv	a0,s5
    80005642:	60a6                	ld	ra,72(sp)
    80005644:	6406                	ld	s0,64(sp)
    80005646:	74e2                	ld	s1,56(sp)
    80005648:	7942                	ld	s2,48(sp)
    8000564a:	79a2                	ld	s3,40(sp)
    8000564c:	6ae2                	ld	s5,24(sp)
    8000564e:	6b42                	ld	s6,16(sp)
    80005650:	6161                	add	sp,sp,80
    80005652:	8082                	ret
    iunlockput(ip);
    80005654:	8556                	mv	a0,s5
    80005656:	ffffe097          	auipc	ra,0xffffe
    8000565a:	7f2080e7          	jalr	2034(ra) # 80003e48 <iunlockput>
    return 0;
    8000565e:	4a81                	li	s5,0
    80005660:	b7c5                	j	80005640 <create+0x70>
    80005662:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005664:	85da                	mv	a1,s6
    80005666:	4088                	lw	a0,0(s1)
    80005668:	ffffe097          	auipc	ra,0xffffe
    8000566c:	3d6080e7          	jalr	982(ra) # 80003a3e <ialloc>
    80005670:	8a2a                	mv	s4,a0
    80005672:	c531                	beqz	a0,800056be <create+0xee>
  ilock(ip);
    80005674:	ffffe097          	auipc	ra,0xffffe
    80005678:	56e080e7          	jalr	1390(ra) # 80003be2 <ilock>
  ip->major = major;
    8000567c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005680:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005684:	4905                	li	s2,1
    80005686:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000568a:	8552                	mv	a0,s4
    8000568c:	ffffe097          	auipc	ra,0xffffe
    80005690:	48a080e7          	jalr	1162(ra) # 80003b16 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005694:	032b0d63          	beq	s6,s2,800056ce <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005698:	004a2603          	lw	a2,4(s4)
    8000569c:	fb040593          	add	a1,s0,-80
    800056a0:	8526                	mv	a0,s1
    800056a2:	fffff097          	auipc	ra,0xfffff
    800056a6:	c5c080e7          	jalr	-932(ra) # 800042fe <dirlink>
    800056aa:	08054163          	bltz	a0,8000572c <create+0x15c>
  iunlockput(dp);
    800056ae:	8526                	mv	a0,s1
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	798080e7          	jalr	1944(ra) # 80003e48 <iunlockput>
  return ip;
    800056b8:	8ad2                	mv	s5,s4
    800056ba:	7a02                	ld	s4,32(sp)
    800056bc:	b751                	j	80005640 <create+0x70>
    iunlockput(dp);
    800056be:	8526                	mv	a0,s1
    800056c0:	ffffe097          	auipc	ra,0xffffe
    800056c4:	788080e7          	jalr	1928(ra) # 80003e48 <iunlockput>
    return 0;
    800056c8:	8ad2                	mv	s5,s4
    800056ca:	7a02                	ld	s4,32(sp)
    800056cc:	bf95                	j	80005640 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056ce:	004a2603          	lw	a2,4(s4)
    800056d2:	00003597          	auipc	a1,0x3
    800056d6:	01e58593          	add	a1,a1,30 # 800086f0 <__func__.1+0x6e8>
    800056da:	8552                	mv	a0,s4
    800056dc:	fffff097          	auipc	ra,0xfffff
    800056e0:	c22080e7          	jalr	-990(ra) # 800042fe <dirlink>
    800056e4:	04054463          	bltz	a0,8000572c <create+0x15c>
    800056e8:	40d0                	lw	a2,4(s1)
    800056ea:	00003597          	auipc	a1,0x3
    800056ee:	00e58593          	add	a1,a1,14 # 800086f8 <__func__.1+0x6f0>
    800056f2:	8552                	mv	a0,s4
    800056f4:	fffff097          	auipc	ra,0xfffff
    800056f8:	c0a080e7          	jalr	-1014(ra) # 800042fe <dirlink>
    800056fc:	02054863          	bltz	a0,8000572c <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005700:	004a2603          	lw	a2,4(s4)
    80005704:	fb040593          	add	a1,s0,-80
    80005708:	8526                	mv	a0,s1
    8000570a:	fffff097          	auipc	ra,0xfffff
    8000570e:	bf4080e7          	jalr	-1036(ra) # 800042fe <dirlink>
    80005712:	00054d63          	bltz	a0,8000572c <create+0x15c>
    dp->nlink++;  // for ".."
    80005716:	04a4d783          	lhu	a5,74(s1)
    8000571a:	2785                	addw	a5,a5,1
    8000571c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005720:	8526                	mv	a0,s1
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	3f4080e7          	jalr	1012(ra) # 80003b16 <iupdate>
    8000572a:	b751                	j	800056ae <create+0xde>
  ip->nlink = 0;
    8000572c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005730:	8552                	mv	a0,s4
    80005732:	ffffe097          	auipc	ra,0xffffe
    80005736:	3e4080e7          	jalr	996(ra) # 80003b16 <iupdate>
  iunlockput(ip);
    8000573a:	8552                	mv	a0,s4
    8000573c:	ffffe097          	auipc	ra,0xffffe
    80005740:	70c080e7          	jalr	1804(ra) # 80003e48 <iunlockput>
  iunlockput(dp);
    80005744:	8526                	mv	a0,s1
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	702080e7          	jalr	1794(ra) # 80003e48 <iunlockput>
  return 0;
    8000574e:	7a02                	ld	s4,32(sp)
    80005750:	bdc5                	j	80005640 <create+0x70>
    return 0;
    80005752:	8aaa                	mv	s5,a0
    80005754:	b5f5                	j	80005640 <create+0x70>

0000000080005756 <sys_dup>:
{
    80005756:	7179                	add	sp,sp,-48
    80005758:	f406                	sd	ra,40(sp)
    8000575a:	f022                	sd	s0,32(sp)
    8000575c:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000575e:	fd840613          	add	a2,s0,-40
    80005762:	4581                	li	a1,0
    80005764:	4501                	li	a0,0
    80005766:	00000097          	auipc	ra,0x0
    8000576a:	dc8080e7          	jalr	-568(ra) # 8000552e <argfd>
    return -1;
    8000576e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005770:	02054763          	bltz	a0,8000579e <sys_dup+0x48>
    80005774:	ec26                	sd	s1,24(sp)
    80005776:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005778:	fd843903          	ld	s2,-40(s0)
    8000577c:	854a                	mv	a0,s2
    8000577e:	00000097          	auipc	ra,0x0
    80005782:	e10080e7          	jalr	-496(ra) # 8000558e <fdalloc>
    80005786:	84aa                	mv	s1,a0
    return -1;
    80005788:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000578a:	00054f63          	bltz	a0,800057a8 <sys_dup+0x52>
  filedup(f);
    8000578e:	854a                	mv	a0,s2
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	298080e7          	jalr	664(ra) # 80004a28 <filedup>
  return fd;
    80005798:	87a6                	mv	a5,s1
    8000579a:	64e2                	ld	s1,24(sp)
    8000579c:	6942                	ld	s2,16(sp)
}
    8000579e:	853e                	mv	a0,a5
    800057a0:	70a2                	ld	ra,40(sp)
    800057a2:	7402                	ld	s0,32(sp)
    800057a4:	6145                	add	sp,sp,48
    800057a6:	8082                	ret
    800057a8:	64e2                	ld	s1,24(sp)
    800057aa:	6942                	ld	s2,16(sp)
    800057ac:	bfcd                	j	8000579e <sys_dup+0x48>

00000000800057ae <sys_read>:
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
    800057de:	d54080e7          	jalr	-684(ra) # 8000552e <argfd>
    800057e2:	87aa                	mv	a5,a0
    return -1;
    800057e4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057e6:	0007cc63          	bltz	a5,800057fe <sys_read+0x50>
  return fileread(f, p, n);
    800057ea:	fe442603          	lw	a2,-28(s0)
    800057ee:	fd843583          	ld	a1,-40(s0)
    800057f2:	fe843503          	ld	a0,-24(s0)
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	3d8080e7          	jalr	984(ra) # 80004bce <fileread>
}
    800057fe:	70a2                	ld	ra,40(sp)
    80005800:	7402                	ld	s0,32(sp)
    80005802:	6145                	add	sp,sp,48
    80005804:	8082                	ret

0000000080005806 <sys_write>:
{
    80005806:	7179                	add	sp,sp,-48
    80005808:	f406                	sd	ra,40(sp)
    8000580a:	f022                	sd	s0,32(sp)
    8000580c:	1800                	add	s0,sp,48
  argaddr(1, &p);
    8000580e:	fd840593          	add	a1,s0,-40
    80005812:	4505                	li	a0,1
    80005814:	ffffd097          	auipc	ra,0xffffd
    80005818:	71c080e7          	jalr	1820(ra) # 80002f30 <argaddr>
  argint(2, &n);
    8000581c:	fe440593          	add	a1,s0,-28
    80005820:	4509                	li	a0,2
    80005822:	ffffd097          	auipc	ra,0xffffd
    80005826:	6ee080e7          	jalr	1774(ra) # 80002f10 <argint>
  if(argfd(0, 0, &f) < 0)
    8000582a:	fe840613          	add	a2,s0,-24
    8000582e:	4581                	li	a1,0
    80005830:	4501                	li	a0,0
    80005832:	00000097          	auipc	ra,0x0
    80005836:	cfc080e7          	jalr	-772(ra) # 8000552e <argfd>
    8000583a:	87aa                	mv	a5,a0
    return -1;
    8000583c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000583e:	0007cc63          	bltz	a5,80005856 <sys_write+0x50>
  return filewrite(f, p, n);
    80005842:	fe442603          	lw	a2,-28(s0)
    80005846:	fd843583          	ld	a1,-40(s0)
    8000584a:	fe843503          	ld	a0,-24(s0)
    8000584e:	fffff097          	auipc	ra,0xfffff
    80005852:	452080e7          	jalr	1106(ra) # 80004ca0 <filewrite>
}
    80005856:	70a2                	ld	ra,40(sp)
    80005858:	7402                	ld	s0,32(sp)
    8000585a:	6145                	add	sp,sp,48
    8000585c:	8082                	ret

000000008000585e <sys_close>:
{
    8000585e:	1101                	add	sp,sp,-32
    80005860:	ec06                	sd	ra,24(sp)
    80005862:	e822                	sd	s0,16(sp)
    80005864:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005866:	fe040613          	add	a2,s0,-32
    8000586a:	fec40593          	add	a1,s0,-20
    8000586e:	4501                	li	a0,0
    80005870:	00000097          	auipc	ra,0x0
    80005874:	cbe080e7          	jalr	-834(ra) # 8000552e <argfd>
    return -1;
    80005878:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000587a:	02054463          	bltz	a0,800058a2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000587e:	ffffc097          	auipc	ra,0xffffc
    80005882:	388080e7          	jalr	904(ra) # 80001c06 <myproc>
    80005886:	fec42783          	lw	a5,-20(s0)
    8000588a:	07e9                	add	a5,a5,26
    8000588c:	078e                	sll	a5,a5,0x3
    8000588e:	953e                	add	a0,a0,a5
    80005890:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005894:	fe043503          	ld	a0,-32(s0)
    80005898:	fffff097          	auipc	ra,0xfffff
    8000589c:	1e2080e7          	jalr	482(ra) # 80004a7a <fileclose>
  return 0;
    800058a0:	4781                	li	a5,0
}
    800058a2:	853e                	mv	a0,a5
    800058a4:	60e2                	ld	ra,24(sp)
    800058a6:	6442                	ld	s0,16(sp)
    800058a8:	6105                	add	sp,sp,32
    800058aa:	8082                	ret

00000000800058ac <sys_fstat>:
{
    800058ac:	1101                	add	sp,sp,-32
    800058ae:	ec06                	sd	ra,24(sp)
    800058b0:	e822                	sd	s0,16(sp)
    800058b2:	1000                	add	s0,sp,32
  argaddr(1, &st);
    800058b4:	fe040593          	add	a1,s0,-32
    800058b8:	4505                	li	a0,1
    800058ba:	ffffd097          	auipc	ra,0xffffd
    800058be:	676080e7          	jalr	1654(ra) # 80002f30 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800058c2:	fe840613          	add	a2,s0,-24
    800058c6:	4581                	li	a1,0
    800058c8:	4501                	li	a0,0
    800058ca:	00000097          	auipc	ra,0x0
    800058ce:	c64080e7          	jalr	-924(ra) # 8000552e <argfd>
    800058d2:	87aa                	mv	a5,a0
    return -1;
    800058d4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058d6:	0007ca63          	bltz	a5,800058ea <sys_fstat+0x3e>
  return filestat(f, st);
    800058da:	fe043583          	ld	a1,-32(s0)
    800058de:	fe843503          	ld	a0,-24(s0)
    800058e2:	fffff097          	auipc	ra,0xfffff
    800058e6:	27a080e7          	jalr	634(ra) # 80004b5c <filestat>
}
    800058ea:	60e2                	ld	ra,24(sp)
    800058ec:	6442                	ld	s0,16(sp)
    800058ee:	6105                	add	sp,sp,32
    800058f0:	8082                	ret

00000000800058f2 <sys_link>:
{
    800058f2:	7169                	add	sp,sp,-304
    800058f4:	f606                	sd	ra,296(sp)
    800058f6:	f222                	sd	s0,288(sp)
    800058f8:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058fa:	08000613          	li	a2,128
    800058fe:	ed040593          	add	a1,s0,-304
    80005902:	4501                	li	a0,0
    80005904:	ffffd097          	auipc	ra,0xffffd
    80005908:	64c080e7          	jalr	1612(ra) # 80002f50 <argstr>
    return -1;
    8000590c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000590e:	12054663          	bltz	a0,80005a3a <sys_link+0x148>
    80005912:	08000613          	li	a2,128
    80005916:	f5040593          	add	a1,s0,-176
    8000591a:	4505                	li	a0,1
    8000591c:	ffffd097          	auipc	ra,0xffffd
    80005920:	634080e7          	jalr	1588(ra) # 80002f50 <argstr>
    return -1;
    80005924:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005926:	10054a63          	bltz	a0,80005a3a <sys_link+0x148>
    8000592a:	ee26                	sd	s1,280(sp)
  begin_op();
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	c84080e7          	jalr	-892(ra) # 800045b0 <begin_op>
  if((ip = namei(old)) == 0){
    80005934:	ed040513          	add	a0,s0,-304
    80005938:	fffff097          	auipc	ra,0xfffff
    8000593c:	a78080e7          	jalr	-1416(ra) # 800043b0 <namei>
    80005940:	84aa                	mv	s1,a0
    80005942:	c949                	beqz	a0,800059d4 <sys_link+0xe2>
  ilock(ip);
    80005944:	ffffe097          	auipc	ra,0xffffe
    80005948:	29e080e7          	jalr	670(ra) # 80003be2 <ilock>
  if(ip->type == T_DIR){
    8000594c:	04449703          	lh	a4,68(s1)
    80005950:	4785                	li	a5,1
    80005952:	08f70863          	beq	a4,a5,800059e2 <sys_link+0xf0>
    80005956:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005958:	04a4d783          	lhu	a5,74(s1)
    8000595c:	2785                	addw	a5,a5,1
    8000595e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005962:	8526                	mv	a0,s1
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	1b2080e7          	jalr	434(ra) # 80003b16 <iupdate>
  iunlock(ip);
    8000596c:	8526                	mv	a0,s1
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	33a080e7          	jalr	826(ra) # 80003ca8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005976:	fd040593          	add	a1,s0,-48
    8000597a:	f5040513          	add	a0,s0,-176
    8000597e:	fffff097          	auipc	ra,0xfffff
    80005982:	a50080e7          	jalr	-1456(ra) # 800043ce <nameiparent>
    80005986:	892a                	mv	s2,a0
    80005988:	cd35                	beqz	a0,80005a04 <sys_link+0x112>
  ilock(dp);
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	258080e7          	jalr	600(ra) # 80003be2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005992:	00092703          	lw	a4,0(s2)
    80005996:	409c                	lw	a5,0(s1)
    80005998:	06f71163          	bne	a4,a5,800059fa <sys_link+0x108>
    8000599c:	40d0                	lw	a2,4(s1)
    8000599e:	fd040593          	add	a1,s0,-48
    800059a2:	854a                	mv	a0,s2
    800059a4:	fffff097          	auipc	ra,0xfffff
    800059a8:	95a080e7          	jalr	-1702(ra) # 800042fe <dirlink>
    800059ac:	04054763          	bltz	a0,800059fa <sys_link+0x108>
  iunlockput(dp);
    800059b0:	854a                	mv	a0,s2
    800059b2:	ffffe097          	auipc	ra,0xffffe
    800059b6:	496080e7          	jalr	1174(ra) # 80003e48 <iunlockput>
  iput(ip);
    800059ba:	8526                	mv	a0,s1
    800059bc:	ffffe097          	auipc	ra,0xffffe
    800059c0:	3e4080e7          	jalr	996(ra) # 80003da0 <iput>
  end_op();
    800059c4:	fffff097          	auipc	ra,0xfffff
    800059c8:	c66080e7          	jalr	-922(ra) # 8000462a <end_op>
  return 0;
    800059cc:	4781                	li	a5,0
    800059ce:	64f2                	ld	s1,280(sp)
    800059d0:	6952                	ld	s2,272(sp)
    800059d2:	a0a5                	j	80005a3a <sys_link+0x148>
    end_op();
    800059d4:	fffff097          	auipc	ra,0xfffff
    800059d8:	c56080e7          	jalr	-938(ra) # 8000462a <end_op>
    return -1;
    800059dc:	57fd                	li	a5,-1
    800059de:	64f2                	ld	s1,280(sp)
    800059e0:	a8a9                	j	80005a3a <sys_link+0x148>
    iunlockput(ip);
    800059e2:	8526                	mv	a0,s1
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	464080e7          	jalr	1124(ra) # 80003e48 <iunlockput>
    end_op();
    800059ec:	fffff097          	auipc	ra,0xfffff
    800059f0:	c3e080e7          	jalr	-962(ra) # 8000462a <end_op>
    return -1;
    800059f4:	57fd                	li	a5,-1
    800059f6:	64f2                	ld	s1,280(sp)
    800059f8:	a089                	j	80005a3a <sys_link+0x148>
    iunlockput(dp);
    800059fa:	854a                	mv	a0,s2
    800059fc:	ffffe097          	auipc	ra,0xffffe
    80005a00:	44c080e7          	jalr	1100(ra) # 80003e48 <iunlockput>
  ilock(ip);
    80005a04:	8526                	mv	a0,s1
    80005a06:	ffffe097          	auipc	ra,0xffffe
    80005a0a:	1dc080e7          	jalr	476(ra) # 80003be2 <ilock>
  ip->nlink--;
    80005a0e:	04a4d783          	lhu	a5,74(s1)
    80005a12:	37fd                	addw	a5,a5,-1
    80005a14:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a18:	8526                	mv	a0,s1
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	0fc080e7          	jalr	252(ra) # 80003b16 <iupdate>
  iunlockput(ip);
    80005a22:	8526                	mv	a0,s1
    80005a24:	ffffe097          	auipc	ra,0xffffe
    80005a28:	424080e7          	jalr	1060(ra) # 80003e48 <iunlockput>
  end_op();
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	bfe080e7          	jalr	-1026(ra) # 8000462a <end_op>
  return -1;
    80005a34:	57fd                	li	a5,-1
    80005a36:	64f2                	ld	s1,280(sp)
    80005a38:	6952                	ld	s2,272(sp)
}
    80005a3a:	853e                	mv	a0,a5
    80005a3c:	70b2                	ld	ra,296(sp)
    80005a3e:	7412                	ld	s0,288(sp)
    80005a40:	6155                	add	sp,sp,304
    80005a42:	8082                	ret

0000000080005a44 <sys_unlink>:
{
    80005a44:	7151                	add	sp,sp,-240
    80005a46:	f586                	sd	ra,232(sp)
    80005a48:	f1a2                	sd	s0,224(sp)
    80005a4a:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a4c:	08000613          	li	a2,128
    80005a50:	f3040593          	add	a1,s0,-208
    80005a54:	4501                	li	a0,0
    80005a56:	ffffd097          	auipc	ra,0xffffd
    80005a5a:	4fa080e7          	jalr	1274(ra) # 80002f50 <argstr>
    80005a5e:	1a054a63          	bltz	a0,80005c12 <sys_unlink+0x1ce>
    80005a62:	eda6                	sd	s1,216(sp)
  begin_op();
    80005a64:	fffff097          	auipc	ra,0xfffff
    80005a68:	b4c080e7          	jalr	-1204(ra) # 800045b0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a6c:	fb040593          	add	a1,s0,-80
    80005a70:	f3040513          	add	a0,s0,-208
    80005a74:	fffff097          	auipc	ra,0xfffff
    80005a78:	95a080e7          	jalr	-1702(ra) # 800043ce <nameiparent>
    80005a7c:	84aa                	mv	s1,a0
    80005a7e:	cd71                	beqz	a0,80005b5a <sys_unlink+0x116>
  ilock(dp);
    80005a80:	ffffe097          	auipc	ra,0xffffe
    80005a84:	162080e7          	jalr	354(ra) # 80003be2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a88:	00003597          	auipc	a1,0x3
    80005a8c:	c6858593          	add	a1,a1,-920 # 800086f0 <__func__.1+0x6e8>
    80005a90:	fb040513          	add	a0,s0,-80
    80005a94:	ffffe097          	auipc	ra,0xffffe
    80005a98:	640080e7          	jalr	1600(ra) # 800040d4 <namecmp>
    80005a9c:	14050c63          	beqz	a0,80005bf4 <sys_unlink+0x1b0>
    80005aa0:	00003597          	auipc	a1,0x3
    80005aa4:	c5858593          	add	a1,a1,-936 # 800086f8 <__func__.1+0x6f0>
    80005aa8:	fb040513          	add	a0,s0,-80
    80005aac:	ffffe097          	auipc	ra,0xffffe
    80005ab0:	628080e7          	jalr	1576(ra) # 800040d4 <namecmp>
    80005ab4:	14050063          	beqz	a0,80005bf4 <sys_unlink+0x1b0>
    80005ab8:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005aba:	f2c40613          	add	a2,s0,-212
    80005abe:	fb040593          	add	a1,s0,-80
    80005ac2:	8526                	mv	a0,s1
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	62a080e7          	jalr	1578(ra) # 800040ee <dirlookup>
    80005acc:	892a                	mv	s2,a0
    80005ace:	12050263          	beqz	a0,80005bf2 <sys_unlink+0x1ae>
  ilock(ip);
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	110080e7          	jalr	272(ra) # 80003be2 <ilock>
  if(ip->nlink < 1)
    80005ada:	04a91783          	lh	a5,74(s2)
    80005ade:	08f05563          	blez	a5,80005b68 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005ae2:	04491703          	lh	a4,68(s2)
    80005ae6:	4785                	li	a5,1
    80005ae8:	08f70963          	beq	a4,a5,80005b7a <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005aec:	4641                	li	a2,16
    80005aee:	4581                	li	a1,0
    80005af0:	fc040513          	add	a0,s0,-64
    80005af4:	ffffb097          	auipc	ra,0xffffb
    80005af8:	308080e7          	jalr	776(ra) # 80000dfc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005afc:	4741                	li	a4,16
    80005afe:	f2c42683          	lw	a3,-212(s0)
    80005b02:	fc040613          	add	a2,s0,-64
    80005b06:	4581                	li	a1,0
    80005b08:	8526                	mv	a0,s1
    80005b0a:	ffffe097          	auipc	ra,0xffffe
    80005b0e:	4a0080e7          	jalr	1184(ra) # 80003faa <writei>
    80005b12:	47c1                	li	a5,16
    80005b14:	0af51b63          	bne	a0,a5,80005bca <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005b18:	04491703          	lh	a4,68(s2)
    80005b1c:	4785                	li	a5,1
    80005b1e:	0af70f63          	beq	a4,a5,80005bdc <sys_unlink+0x198>
  iunlockput(dp);
    80005b22:	8526                	mv	a0,s1
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	324080e7          	jalr	804(ra) # 80003e48 <iunlockput>
  ip->nlink--;
    80005b2c:	04a95783          	lhu	a5,74(s2)
    80005b30:	37fd                	addw	a5,a5,-1
    80005b32:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b36:	854a                	mv	a0,s2
    80005b38:	ffffe097          	auipc	ra,0xffffe
    80005b3c:	fde080e7          	jalr	-34(ra) # 80003b16 <iupdate>
  iunlockput(ip);
    80005b40:	854a                	mv	a0,s2
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	306080e7          	jalr	774(ra) # 80003e48 <iunlockput>
  end_op();
    80005b4a:	fffff097          	auipc	ra,0xfffff
    80005b4e:	ae0080e7          	jalr	-1312(ra) # 8000462a <end_op>
  return 0;
    80005b52:	4501                	li	a0,0
    80005b54:	64ee                	ld	s1,216(sp)
    80005b56:	694e                	ld	s2,208(sp)
    80005b58:	a84d                	j	80005c0a <sys_unlink+0x1c6>
    end_op();
    80005b5a:	fffff097          	auipc	ra,0xfffff
    80005b5e:	ad0080e7          	jalr	-1328(ra) # 8000462a <end_op>
    return -1;
    80005b62:	557d                	li	a0,-1
    80005b64:	64ee                	ld	s1,216(sp)
    80005b66:	a055                	j	80005c0a <sys_unlink+0x1c6>
    80005b68:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005b6a:	00003517          	auipc	a0,0x3
    80005b6e:	b9650513          	add	a0,a0,-1130 # 80008700 <__func__.1+0x6f8>
    80005b72:	ffffb097          	auipc	ra,0xffffb
    80005b76:	9ee080e7          	jalr	-1554(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b7a:	04c92703          	lw	a4,76(s2)
    80005b7e:	02000793          	li	a5,32
    80005b82:	f6e7f5e3          	bgeu	a5,a4,80005aec <sys_unlink+0xa8>
    80005b86:	e5ce                	sd	s3,200(sp)
    80005b88:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b8c:	4741                	li	a4,16
    80005b8e:	86ce                	mv	a3,s3
    80005b90:	f1840613          	add	a2,s0,-232
    80005b94:	4581                	li	a1,0
    80005b96:	854a                	mv	a0,s2
    80005b98:	ffffe097          	auipc	ra,0xffffe
    80005b9c:	302080e7          	jalr	770(ra) # 80003e9a <readi>
    80005ba0:	47c1                	li	a5,16
    80005ba2:	00f51c63          	bne	a0,a5,80005bba <sys_unlink+0x176>
    if(de.inum != 0)
    80005ba6:	f1845783          	lhu	a5,-232(s0)
    80005baa:	e7b5                	bnez	a5,80005c16 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bac:	29c1                	addw	s3,s3,16
    80005bae:	04c92783          	lw	a5,76(s2)
    80005bb2:	fcf9ede3          	bltu	s3,a5,80005b8c <sys_unlink+0x148>
    80005bb6:	69ae                	ld	s3,200(sp)
    80005bb8:	bf15                	j	80005aec <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80005bba:	00003517          	auipc	a0,0x3
    80005bbe:	b5e50513          	add	a0,a0,-1186 # 80008718 <__func__.1+0x710>
    80005bc2:	ffffb097          	auipc	ra,0xffffb
    80005bc6:	99e080e7          	jalr	-1634(ra) # 80000560 <panic>
    80005bca:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005bcc:	00003517          	auipc	a0,0x3
    80005bd0:	b6450513          	add	a0,a0,-1180 # 80008730 <__func__.1+0x728>
    80005bd4:	ffffb097          	auipc	ra,0xffffb
    80005bd8:	98c080e7          	jalr	-1652(ra) # 80000560 <panic>
    dp->nlink--;
    80005bdc:	04a4d783          	lhu	a5,74(s1)
    80005be0:	37fd                	addw	a5,a5,-1
    80005be2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005be6:	8526                	mv	a0,s1
    80005be8:	ffffe097          	auipc	ra,0xffffe
    80005bec:	f2e080e7          	jalr	-210(ra) # 80003b16 <iupdate>
    80005bf0:	bf0d                	j	80005b22 <sys_unlink+0xde>
    80005bf2:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005bf4:	8526                	mv	a0,s1
    80005bf6:	ffffe097          	auipc	ra,0xffffe
    80005bfa:	252080e7          	jalr	594(ra) # 80003e48 <iunlockput>
  end_op();
    80005bfe:	fffff097          	auipc	ra,0xfffff
    80005c02:	a2c080e7          	jalr	-1492(ra) # 8000462a <end_op>
  return -1;
    80005c06:	557d                	li	a0,-1
    80005c08:	64ee                	ld	s1,216(sp)
}
    80005c0a:	70ae                	ld	ra,232(sp)
    80005c0c:	740e                	ld	s0,224(sp)
    80005c0e:	616d                	add	sp,sp,240
    80005c10:	8082                	ret
    return -1;
    80005c12:	557d                	li	a0,-1
    80005c14:	bfdd                	j	80005c0a <sys_unlink+0x1c6>
    iunlockput(ip);
    80005c16:	854a                	mv	a0,s2
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	230080e7          	jalr	560(ra) # 80003e48 <iunlockput>
    goto bad;
    80005c20:	694e                	ld	s2,208(sp)
    80005c22:	69ae                	ld	s3,200(sp)
    80005c24:	bfc1                	j	80005bf4 <sys_unlink+0x1b0>

0000000080005c26 <sys_open>:

uint64
sys_open(void)
{
    80005c26:	7131                	add	sp,sp,-192
    80005c28:	fd06                	sd	ra,184(sp)
    80005c2a:	f922                	sd	s0,176(sp)
    80005c2c:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005c2e:	f4c40593          	add	a1,s0,-180
    80005c32:	4505                	li	a0,1
    80005c34:	ffffd097          	auipc	ra,0xffffd
    80005c38:	2dc080e7          	jalr	732(ra) # 80002f10 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c3c:	08000613          	li	a2,128
    80005c40:	f5040593          	add	a1,s0,-176
    80005c44:	4501                	li	a0,0
    80005c46:	ffffd097          	auipc	ra,0xffffd
    80005c4a:	30a080e7          	jalr	778(ra) # 80002f50 <argstr>
    80005c4e:	87aa                	mv	a5,a0
    return -1;
    80005c50:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c52:	0a07ce63          	bltz	a5,80005d0e <sys_open+0xe8>
    80005c56:	f526                	sd	s1,168(sp)

  begin_op();
    80005c58:	fffff097          	auipc	ra,0xfffff
    80005c5c:	958080e7          	jalr	-1704(ra) # 800045b0 <begin_op>

  if(omode & O_CREATE){
    80005c60:	f4c42783          	lw	a5,-180(s0)
    80005c64:	2007f793          	and	a5,a5,512
    80005c68:	cfd5                	beqz	a5,80005d24 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c6a:	4681                	li	a3,0
    80005c6c:	4601                	li	a2,0
    80005c6e:	4589                	li	a1,2
    80005c70:	f5040513          	add	a0,s0,-176
    80005c74:	00000097          	auipc	ra,0x0
    80005c78:	95c080e7          	jalr	-1700(ra) # 800055d0 <create>
    80005c7c:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c7e:	cd41                	beqz	a0,80005d16 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c80:	04449703          	lh	a4,68(s1)
    80005c84:	478d                	li	a5,3
    80005c86:	00f71763          	bne	a4,a5,80005c94 <sys_open+0x6e>
    80005c8a:	0464d703          	lhu	a4,70(s1)
    80005c8e:	47a5                	li	a5,9
    80005c90:	0ee7e163          	bltu	a5,a4,80005d72 <sys_open+0x14c>
    80005c94:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c96:	fffff097          	auipc	ra,0xfffff
    80005c9a:	d28080e7          	jalr	-728(ra) # 800049be <filealloc>
    80005c9e:	892a                	mv	s2,a0
    80005ca0:	c97d                	beqz	a0,80005d96 <sys_open+0x170>
    80005ca2:	ed4e                	sd	s3,152(sp)
    80005ca4:	00000097          	auipc	ra,0x0
    80005ca8:	8ea080e7          	jalr	-1814(ra) # 8000558e <fdalloc>
    80005cac:	89aa                	mv	s3,a0
    80005cae:	0c054e63          	bltz	a0,80005d8a <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005cb2:	04449703          	lh	a4,68(s1)
    80005cb6:	478d                	li	a5,3
    80005cb8:	0ef70c63          	beq	a4,a5,80005db0 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005cbc:	4789                	li	a5,2
    80005cbe:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005cc2:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005cc6:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005cca:	f4c42783          	lw	a5,-180(s0)
    80005cce:	0017c713          	xor	a4,a5,1
    80005cd2:	8b05                	and	a4,a4,1
    80005cd4:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005cd8:	0037f713          	and	a4,a5,3
    80005cdc:	00e03733          	snez	a4,a4
    80005ce0:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005ce4:	4007f793          	and	a5,a5,1024
    80005ce8:	c791                	beqz	a5,80005cf4 <sys_open+0xce>
    80005cea:	04449703          	lh	a4,68(s1)
    80005cee:	4789                	li	a5,2
    80005cf0:	0cf70763          	beq	a4,a5,80005dbe <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005cf4:	8526                	mv	a0,s1
    80005cf6:	ffffe097          	auipc	ra,0xffffe
    80005cfa:	fb2080e7          	jalr	-78(ra) # 80003ca8 <iunlock>
  end_op();
    80005cfe:	fffff097          	auipc	ra,0xfffff
    80005d02:	92c080e7          	jalr	-1748(ra) # 8000462a <end_op>

  return fd;
    80005d06:	854e                	mv	a0,s3
    80005d08:	74aa                	ld	s1,168(sp)
    80005d0a:	790a                	ld	s2,160(sp)
    80005d0c:	69ea                	ld	s3,152(sp)
}
    80005d0e:	70ea                	ld	ra,184(sp)
    80005d10:	744a                	ld	s0,176(sp)
    80005d12:	6129                	add	sp,sp,192
    80005d14:	8082                	ret
      end_op();
    80005d16:	fffff097          	auipc	ra,0xfffff
    80005d1a:	914080e7          	jalr	-1772(ra) # 8000462a <end_op>
      return -1;
    80005d1e:	557d                	li	a0,-1
    80005d20:	74aa                	ld	s1,168(sp)
    80005d22:	b7f5                	j	80005d0e <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005d24:	f5040513          	add	a0,s0,-176
    80005d28:	ffffe097          	auipc	ra,0xffffe
    80005d2c:	688080e7          	jalr	1672(ra) # 800043b0 <namei>
    80005d30:	84aa                	mv	s1,a0
    80005d32:	c90d                	beqz	a0,80005d64 <sys_open+0x13e>
    ilock(ip);
    80005d34:	ffffe097          	auipc	ra,0xffffe
    80005d38:	eae080e7          	jalr	-338(ra) # 80003be2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d3c:	04449703          	lh	a4,68(s1)
    80005d40:	4785                	li	a5,1
    80005d42:	f2f71fe3          	bne	a4,a5,80005c80 <sys_open+0x5a>
    80005d46:	f4c42783          	lw	a5,-180(s0)
    80005d4a:	d7a9                	beqz	a5,80005c94 <sys_open+0x6e>
      iunlockput(ip);
    80005d4c:	8526                	mv	a0,s1
    80005d4e:	ffffe097          	auipc	ra,0xffffe
    80005d52:	0fa080e7          	jalr	250(ra) # 80003e48 <iunlockput>
      end_op();
    80005d56:	fffff097          	auipc	ra,0xfffff
    80005d5a:	8d4080e7          	jalr	-1836(ra) # 8000462a <end_op>
      return -1;
    80005d5e:	557d                	li	a0,-1
    80005d60:	74aa                	ld	s1,168(sp)
    80005d62:	b775                	j	80005d0e <sys_open+0xe8>
      end_op();
    80005d64:	fffff097          	auipc	ra,0xfffff
    80005d68:	8c6080e7          	jalr	-1850(ra) # 8000462a <end_op>
      return -1;
    80005d6c:	557d                	li	a0,-1
    80005d6e:	74aa                	ld	s1,168(sp)
    80005d70:	bf79                	j	80005d0e <sys_open+0xe8>
    iunlockput(ip);
    80005d72:	8526                	mv	a0,s1
    80005d74:	ffffe097          	auipc	ra,0xffffe
    80005d78:	0d4080e7          	jalr	212(ra) # 80003e48 <iunlockput>
    end_op();
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	8ae080e7          	jalr	-1874(ra) # 8000462a <end_op>
    return -1;
    80005d84:	557d                	li	a0,-1
    80005d86:	74aa                	ld	s1,168(sp)
    80005d88:	b759                	j	80005d0e <sys_open+0xe8>
      fileclose(f);
    80005d8a:	854a                	mv	a0,s2
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	cee080e7          	jalr	-786(ra) # 80004a7a <fileclose>
    80005d94:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005d96:	8526                	mv	a0,s1
    80005d98:	ffffe097          	auipc	ra,0xffffe
    80005d9c:	0b0080e7          	jalr	176(ra) # 80003e48 <iunlockput>
    end_op();
    80005da0:	fffff097          	auipc	ra,0xfffff
    80005da4:	88a080e7          	jalr	-1910(ra) # 8000462a <end_op>
    return -1;
    80005da8:	557d                	li	a0,-1
    80005daa:	74aa                	ld	s1,168(sp)
    80005dac:	790a                	ld	s2,160(sp)
    80005dae:	b785                	j	80005d0e <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005db0:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005db4:	04649783          	lh	a5,70(s1)
    80005db8:	02f91223          	sh	a5,36(s2)
    80005dbc:	b729                	j	80005cc6 <sys_open+0xa0>
    itrunc(ip);
    80005dbe:	8526                	mv	a0,s1
    80005dc0:	ffffe097          	auipc	ra,0xffffe
    80005dc4:	f34080e7          	jalr	-204(ra) # 80003cf4 <itrunc>
    80005dc8:	b735                	j	80005cf4 <sys_open+0xce>

0000000080005dca <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005dca:	7175                	add	sp,sp,-144
    80005dcc:	e506                	sd	ra,136(sp)
    80005dce:	e122                	sd	s0,128(sp)
    80005dd0:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005dd2:	ffffe097          	auipc	ra,0xffffe
    80005dd6:	7de080e7          	jalr	2014(ra) # 800045b0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005dda:	08000613          	li	a2,128
    80005dde:	f7040593          	add	a1,s0,-144
    80005de2:	4501                	li	a0,0
    80005de4:	ffffd097          	auipc	ra,0xffffd
    80005de8:	16c080e7          	jalr	364(ra) # 80002f50 <argstr>
    80005dec:	02054963          	bltz	a0,80005e1e <sys_mkdir+0x54>
    80005df0:	4681                	li	a3,0
    80005df2:	4601                	li	a2,0
    80005df4:	4585                	li	a1,1
    80005df6:	f7040513          	add	a0,s0,-144
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	7d6080e7          	jalr	2006(ra) # 800055d0 <create>
    80005e02:	cd11                	beqz	a0,80005e1e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e04:	ffffe097          	auipc	ra,0xffffe
    80005e08:	044080e7          	jalr	68(ra) # 80003e48 <iunlockput>
  end_op();
    80005e0c:	fffff097          	auipc	ra,0xfffff
    80005e10:	81e080e7          	jalr	-2018(ra) # 8000462a <end_op>
  return 0;
    80005e14:	4501                	li	a0,0
}
    80005e16:	60aa                	ld	ra,136(sp)
    80005e18:	640a                	ld	s0,128(sp)
    80005e1a:	6149                	add	sp,sp,144
    80005e1c:	8082                	ret
    end_op();
    80005e1e:	fffff097          	auipc	ra,0xfffff
    80005e22:	80c080e7          	jalr	-2036(ra) # 8000462a <end_op>
    return -1;
    80005e26:	557d                	li	a0,-1
    80005e28:	b7fd                	j	80005e16 <sys_mkdir+0x4c>

0000000080005e2a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e2a:	7135                	add	sp,sp,-160
    80005e2c:	ed06                	sd	ra,152(sp)
    80005e2e:	e922                	sd	s0,144(sp)
    80005e30:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e32:	ffffe097          	auipc	ra,0xffffe
    80005e36:	77e080e7          	jalr	1918(ra) # 800045b0 <begin_op>
  argint(1, &major);
    80005e3a:	f6c40593          	add	a1,s0,-148
    80005e3e:	4505                	li	a0,1
    80005e40:	ffffd097          	auipc	ra,0xffffd
    80005e44:	0d0080e7          	jalr	208(ra) # 80002f10 <argint>
  argint(2, &minor);
    80005e48:	f6840593          	add	a1,s0,-152
    80005e4c:	4509                	li	a0,2
    80005e4e:	ffffd097          	auipc	ra,0xffffd
    80005e52:	0c2080e7          	jalr	194(ra) # 80002f10 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e56:	08000613          	li	a2,128
    80005e5a:	f7040593          	add	a1,s0,-144
    80005e5e:	4501                	li	a0,0
    80005e60:	ffffd097          	auipc	ra,0xffffd
    80005e64:	0f0080e7          	jalr	240(ra) # 80002f50 <argstr>
    80005e68:	02054b63          	bltz	a0,80005e9e <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e6c:	f6841683          	lh	a3,-152(s0)
    80005e70:	f6c41603          	lh	a2,-148(s0)
    80005e74:	458d                	li	a1,3
    80005e76:	f7040513          	add	a0,s0,-144
    80005e7a:	fffff097          	auipc	ra,0xfffff
    80005e7e:	756080e7          	jalr	1878(ra) # 800055d0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e82:	cd11                	beqz	a0,80005e9e <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e84:	ffffe097          	auipc	ra,0xffffe
    80005e88:	fc4080e7          	jalr	-60(ra) # 80003e48 <iunlockput>
  end_op();
    80005e8c:	ffffe097          	auipc	ra,0xffffe
    80005e90:	79e080e7          	jalr	1950(ra) # 8000462a <end_op>
  return 0;
    80005e94:	4501                	li	a0,0
}
    80005e96:	60ea                	ld	ra,152(sp)
    80005e98:	644a                	ld	s0,144(sp)
    80005e9a:	610d                	add	sp,sp,160
    80005e9c:	8082                	ret
    end_op();
    80005e9e:	ffffe097          	auipc	ra,0xffffe
    80005ea2:	78c080e7          	jalr	1932(ra) # 8000462a <end_op>
    return -1;
    80005ea6:	557d                	li	a0,-1
    80005ea8:	b7fd                	j	80005e96 <sys_mknod+0x6c>

0000000080005eaa <sys_chdir>:

uint64
sys_chdir(void)
{
    80005eaa:	7135                	add	sp,sp,-160
    80005eac:	ed06                	sd	ra,152(sp)
    80005eae:	e922                	sd	s0,144(sp)
    80005eb0:	e14a                	sd	s2,128(sp)
    80005eb2:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005eb4:	ffffc097          	auipc	ra,0xffffc
    80005eb8:	d52080e7          	jalr	-686(ra) # 80001c06 <myproc>
    80005ebc:	892a                	mv	s2,a0
  
  begin_op();
    80005ebe:	ffffe097          	auipc	ra,0xffffe
    80005ec2:	6f2080e7          	jalr	1778(ra) # 800045b0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ec6:	08000613          	li	a2,128
    80005eca:	f6040593          	add	a1,s0,-160
    80005ece:	4501                	li	a0,0
    80005ed0:	ffffd097          	auipc	ra,0xffffd
    80005ed4:	080080e7          	jalr	128(ra) # 80002f50 <argstr>
    80005ed8:	04054d63          	bltz	a0,80005f32 <sys_chdir+0x88>
    80005edc:	e526                	sd	s1,136(sp)
    80005ede:	f6040513          	add	a0,s0,-160
    80005ee2:	ffffe097          	auipc	ra,0xffffe
    80005ee6:	4ce080e7          	jalr	1230(ra) # 800043b0 <namei>
    80005eea:	84aa                	mv	s1,a0
    80005eec:	c131                	beqz	a0,80005f30 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005eee:	ffffe097          	auipc	ra,0xffffe
    80005ef2:	cf4080e7          	jalr	-780(ra) # 80003be2 <ilock>
  if(ip->type != T_DIR){
    80005ef6:	04449703          	lh	a4,68(s1)
    80005efa:	4785                	li	a5,1
    80005efc:	04f71163          	bne	a4,a5,80005f3e <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f00:	8526                	mv	a0,s1
    80005f02:	ffffe097          	auipc	ra,0xffffe
    80005f06:	da6080e7          	jalr	-602(ra) # 80003ca8 <iunlock>
  iput(p->cwd);
    80005f0a:	15093503          	ld	a0,336(s2)
    80005f0e:	ffffe097          	auipc	ra,0xffffe
    80005f12:	e92080e7          	jalr	-366(ra) # 80003da0 <iput>
  end_op();
    80005f16:	ffffe097          	auipc	ra,0xffffe
    80005f1a:	714080e7          	jalr	1812(ra) # 8000462a <end_op>
  p->cwd = ip;
    80005f1e:	14993823          	sd	s1,336(s2)
  return 0;
    80005f22:	4501                	li	a0,0
    80005f24:	64aa                	ld	s1,136(sp)
}
    80005f26:	60ea                	ld	ra,152(sp)
    80005f28:	644a                	ld	s0,144(sp)
    80005f2a:	690a                	ld	s2,128(sp)
    80005f2c:	610d                	add	sp,sp,160
    80005f2e:	8082                	ret
    80005f30:	64aa                	ld	s1,136(sp)
    end_op();
    80005f32:	ffffe097          	auipc	ra,0xffffe
    80005f36:	6f8080e7          	jalr	1784(ra) # 8000462a <end_op>
    return -1;
    80005f3a:	557d                	li	a0,-1
    80005f3c:	b7ed                	j	80005f26 <sys_chdir+0x7c>
    iunlockput(ip);
    80005f3e:	8526                	mv	a0,s1
    80005f40:	ffffe097          	auipc	ra,0xffffe
    80005f44:	f08080e7          	jalr	-248(ra) # 80003e48 <iunlockput>
    end_op();
    80005f48:	ffffe097          	auipc	ra,0xffffe
    80005f4c:	6e2080e7          	jalr	1762(ra) # 8000462a <end_op>
    return -1;
    80005f50:	557d                	li	a0,-1
    80005f52:	64aa                	ld	s1,136(sp)
    80005f54:	bfc9                	j	80005f26 <sys_chdir+0x7c>

0000000080005f56 <sys_exec>:

uint64
sys_exec(void)
{
    80005f56:	7121                	add	sp,sp,-448
    80005f58:	ff06                	sd	ra,440(sp)
    80005f5a:	fb22                	sd	s0,432(sp)
    80005f5c:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005f5e:	e4840593          	add	a1,s0,-440
    80005f62:	4505                	li	a0,1
    80005f64:	ffffd097          	auipc	ra,0xffffd
    80005f68:	fcc080e7          	jalr	-52(ra) # 80002f30 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005f6c:	08000613          	li	a2,128
    80005f70:	f5040593          	add	a1,s0,-176
    80005f74:	4501                	li	a0,0
    80005f76:	ffffd097          	auipc	ra,0xffffd
    80005f7a:	fda080e7          	jalr	-38(ra) # 80002f50 <argstr>
    80005f7e:	87aa                	mv	a5,a0
    return -1;
    80005f80:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005f82:	0e07c263          	bltz	a5,80006066 <sys_exec+0x110>
    80005f86:	f726                	sd	s1,424(sp)
    80005f88:	f34a                	sd	s2,416(sp)
    80005f8a:	ef4e                	sd	s3,408(sp)
    80005f8c:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005f8e:	10000613          	li	a2,256
    80005f92:	4581                	li	a1,0
    80005f94:	e5040513          	add	a0,s0,-432
    80005f98:	ffffb097          	auipc	ra,0xffffb
    80005f9c:	e64080e7          	jalr	-412(ra) # 80000dfc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005fa0:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005fa4:	89a6                	mv	s3,s1
    80005fa6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005fa8:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005fac:	00391513          	sll	a0,s2,0x3
    80005fb0:	e4040593          	add	a1,s0,-448
    80005fb4:	e4843783          	ld	a5,-440(s0)
    80005fb8:	953e                	add	a0,a0,a5
    80005fba:	ffffd097          	auipc	ra,0xffffd
    80005fbe:	eb8080e7          	jalr	-328(ra) # 80002e72 <fetchaddr>
    80005fc2:	02054a63          	bltz	a0,80005ff6 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005fc6:	e4043783          	ld	a5,-448(s0)
    80005fca:	c7b9                	beqz	a5,80006018 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005fcc:	ffffb097          	auipc	ra,0xffffb
    80005fd0:	bf8080e7          	jalr	-1032(ra) # 80000bc4 <kalloc>
    80005fd4:	85aa                	mv	a1,a0
    80005fd6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005fda:	cd11                	beqz	a0,80005ff6 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005fdc:	6605                	lui	a2,0x1
    80005fde:	e4043503          	ld	a0,-448(s0)
    80005fe2:	ffffd097          	auipc	ra,0xffffd
    80005fe6:	ee2080e7          	jalr	-286(ra) # 80002ec4 <fetchstr>
    80005fea:	00054663          	bltz	a0,80005ff6 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005fee:	0905                	add	s2,s2,1
    80005ff0:	09a1                	add	s3,s3,8
    80005ff2:	fb491de3          	bne	s2,s4,80005fac <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ff6:	f5040913          	add	s2,s0,-176
    80005ffa:	6088                	ld	a0,0(s1)
    80005ffc:	c125                	beqz	a0,8000605c <sys_exec+0x106>
    kfree(argv[i]);
    80005ffe:	ffffb097          	auipc	ra,0xffffb
    80006002:	a5e080e7          	jalr	-1442(ra) # 80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006006:	04a1                	add	s1,s1,8
    80006008:	ff2499e3          	bne	s1,s2,80005ffa <sys_exec+0xa4>
  return -1;
    8000600c:	557d                	li	a0,-1
    8000600e:	74ba                	ld	s1,424(sp)
    80006010:	791a                	ld	s2,416(sp)
    80006012:	69fa                	ld	s3,408(sp)
    80006014:	6a5a                	ld	s4,400(sp)
    80006016:	a881                	j	80006066 <sys_exec+0x110>
      argv[i] = 0;
    80006018:	0009079b          	sext.w	a5,s2
    8000601c:	078e                	sll	a5,a5,0x3
    8000601e:	fd078793          	add	a5,a5,-48
    80006022:	97a2                	add	a5,a5,s0
    80006024:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80006028:	e5040593          	add	a1,s0,-432
    8000602c:	f5040513          	add	a0,s0,-176
    80006030:	fffff097          	auipc	ra,0xfffff
    80006034:	120080e7          	jalr	288(ra) # 80005150 <exec>
    80006038:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000603a:	f5040993          	add	s3,s0,-176
    8000603e:	6088                	ld	a0,0(s1)
    80006040:	c901                	beqz	a0,80006050 <sys_exec+0xfa>
    kfree(argv[i]);
    80006042:	ffffb097          	auipc	ra,0xffffb
    80006046:	a1a080e7          	jalr	-1510(ra) # 80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000604a:	04a1                	add	s1,s1,8
    8000604c:	ff3499e3          	bne	s1,s3,8000603e <sys_exec+0xe8>
  return ret;
    80006050:	854a                	mv	a0,s2
    80006052:	74ba                	ld	s1,424(sp)
    80006054:	791a                	ld	s2,416(sp)
    80006056:	69fa                	ld	s3,408(sp)
    80006058:	6a5a                	ld	s4,400(sp)
    8000605a:	a031                	j	80006066 <sys_exec+0x110>
  return -1;
    8000605c:	557d                	li	a0,-1
    8000605e:	74ba                	ld	s1,424(sp)
    80006060:	791a                	ld	s2,416(sp)
    80006062:	69fa                	ld	s3,408(sp)
    80006064:	6a5a                	ld	s4,400(sp)
}
    80006066:	70fa                	ld	ra,440(sp)
    80006068:	745a                	ld	s0,432(sp)
    8000606a:	6139                	add	sp,sp,448
    8000606c:	8082                	ret

000000008000606e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000606e:	7139                	add	sp,sp,-64
    80006070:	fc06                	sd	ra,56(sp)
    80006072:	f822                	sd	s0,48(sp)
    80006074:	f426                	sd	s1,40(sp)
    80006076:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006078:	ffffc097          	auipc	ra,0xffffc
    8000607c:	b8e080e7          	jalr	-1138(ra) # 80001c06 <myproc>
    80006080:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006082:	fd840593          	add	a1,s0,-40
    80006086:	4501                	li	a0,0
    80006088:	ffffd097          	auipc	ra,0xffffd
    8000608c:	ea8080e7          	jalr	-344(ra) # 80002f30 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006090:	fc840593          	add	a1,s0,-56
    80006094:	fd040513          	add	a0,s0,-48
    80006098:	fffff097          	auipc	ra,0xfffff
    8000609c:	d50080e7          	jalr	-688(ra) # 80004de8 <pipealloc>
    return -1;
    800060a0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800060a2:	0c054463          	bltz	a0,8000616a <sys_pipe+0xfc>
  fd0 = -1;
    800060a6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800060aa:	fd043503          	ld	a0,-48(s0)
    800060ae:	fffff097          	auipc	ra,0xfffff
    800060b2:	4e0080e7          	jalr	1248(ra) # 8000558e <fdalloc>
    800060b6:	fca42223          	sw	a0,-60(s0)
    800060ba:	08054b63          	bltz	a0,80006150 <sys_pipe+0xe2>
    800060be:	fc843503          	ld	a0,-56(s0)
    800060c2:	fffff097          	auipc	ra,0xfffff
    800060c6:	4cc080e7          	jalr	1228(ra) # 8000558e <fdalloc>
    800060ca:	fca42023          	sw	a0,-64(s0)
    800060ce:	06054863          	bltz	a0,8000613e <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060d2:	4691                	li	a3,4
    800060d4:	fc440613          	add	a2,s0,-60
    800060d8:	fd843583          	ld	a1,-40(s0)
    800060dc:	68a8                	ld	a0,80(s1)
    800060de:	ffffb097          	auipc	ra,0xffffb
    800060e2:	6cc080e7          	jalr	1740(ra) # 800017aa <copyout>
    800060e6:	02054063          	bltz	a0,80006106 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800060ea:	4691                	li	a3,4
    800060ec:	fc040613          	add	a2,s0,-64
    800060f0:	fd843583          	ld	a1,-40(s0)
    800060f4:	0591                	add	a1,a1,4
    800060f6:	68a8                	ld	a0,80(s1)
    800060f8:	ffffb097          	auipc	ra,0xffffb
    800060fc:	6b2080e7          	jalr	1714(ra) # 800017aa <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006100:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006102:	06055463          	bgez	a0,8000616a <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006106:	fc442783          	lw	a5,-60(s0)
    8000610a:	07e9                	add	a5,a5,26
    8000610c:	078e                	sll	a5,a5,0x3
    8000610e:	97a6                	add	a5,a5,s1
    80006110:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006114:	fc042783          	lw	a5,-64(s0)
    80006118:	07e9                	add	a5,a5,26
    8000611a:	078e                	sll	a5,a5,0x3
    8000611c:	94be                	add	s1,s1,a5
    8000611e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006122:	fd043503          	ld	a0,-48(s0)
    80006126:	fffff097          	auipc	ra,0xfffff
    8000612a:	954080e7          	jalr	-1708(ra) # 80004a7a <fileclose>
    fileclose(wf);
    8000612e:	fc843503          	ld	a0,-56(s0)
    80006132:	fffff097          	auipc	ra,0xfffff
    80006136:	948080e7          	jalr	-1720(ra) # 80004a7a <fileclose>
    return -1;
    8000613a:	57fd                	li	a5,-1
    8000613c:	a03d                	j	8000616a <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000613e:	fc442783          	lw	a5,-60(s0)
    80006142:	0007c763          	bltz	a5,80006150 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006146:	07e9                	add	a5,a5,26
    80006148:	078e                	sll	a5,a5,0x3
    8000614a:	97a6                	add	a5,a5,s1
    8000614c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006150:	fd043503          	ld	a0,-48(s0)
    80006154:	fffff097          	auipc	ra,0xfffff
    80006158:	926080e7          	jalr	-1754(ra) # 80004a7a <fileclose>
    fileclose(wf);
    8000615c:	fc843503          	ld	a0,-56(s0)
    80006160:	fffff097          	auipc	ra,0xfffff
    80006164:	91a080e7          	jalr	-1766(ra) # 80004a7a <fileclose>
    return -1;
    80006168:	57fd                	li	a5,-1
}
    8000616a:	853e                	mv	a0,a5
    8000616c:	70e2                	ld	ra,56(sp)
    8000616e:	7442                	ld	s0,48(sp)
    80006170:	74a2                	ld	s1,40(sp)
    80006172:	6121                	add	sp,sp,64
    80006174:	8082                	ret
	...

0000000080006180 <kernelvec>:
    80006180:	7111                	add	sp,sp,-256
    80006182:	e006                	sd	ra,0(sp)
    80006184:	e40a                	sd	sp,8(sp)
    80006186:	e80e                	sd	gp,16(sp)
    80006188:	ec12                	sd	tp,24(sp)
    8000618a:	f016                	sd	t0,32(sp)
    8000618c:	f41a                	sd	t1,40(sp)
    8000618e:	f81e                	sd	t2,48(sp)
    80006190:	fc22                	sd	s0,56(sp)
    80006192:	e0a6                	sd	s1,64(sp)
    80006194:	e4aa                	sd	a0,72(sp)
    80006196:	e8ae                	sd	a1,80(sp)
    80006198:	ecb2                	sd	a2,88(sp)
    8000619a:	f0b6                	sd	a3,96(sp)
    8000619c:	f4ba                	sd	a4,104(sp)
    8000619e:	f8be                	sd	a5,112(sp)
    800061a0:	fcc2                	sd	a6,120(sp)
    800061a2:	e146                	sd	a7,128(sp)
    800061a4:	e54a                	sd	s2,136(sp)
    800061a6:	e94e                	sd	s3,144(sp)
    800061a8:	ed52                	sd	s4,152(sp)
    800061aa:	f156                	sd	s5,160(sp)
    800061ac:	f55a                	sd	s6,168(sp)
    800061ae:	f95e                	sd	s7,176(sp)
    800061b0:	fd62                	sd	s8,184(sp)
    800061b2:	e1e6                	sd	s9,192(sp)
    800061b4:	e5ea                	sd	s10,200(sp)
    800061b6:	e9ee                	sd	s11,208(sp)
    800061b8:	edf2                	sd	t3,216(sp)
    800061ba:	f1f6                	sd	t4,224(sp)
    800061bc:	f5fa                	sd	t5,232(sp)
    800061be:	f9fe                	sd	t6,240(sp)
    800061c0:	b7ffc0ef          	jal	80002d3e <kerneltrap>
    800061c4:	6082                	ld	ra,0(sp)
    800061c6:	6122                	ld	sp,8(sp)
    800061c8:	61c2                	ld	gp,16(sp)
    800061ca:	7282                	ld	t0,32(sp)
    800061cc:	7322                	ld	t1,40(sp)
    800061ce:	73c2                	ld	t2,48(sp)
    800061d0:	7462                	ld	s0,56(sp)
    800061d2:	6486                	ld	s1,64(sp)
    800061d4:	6526                	ld	a0,72(sp)
    800061d6:	65c6                	ld	a1,80(sp)
    800061d8:	6666                	ld	a2,88(sp)
    800061da:	7686                	ld	a3,96(sp)
    800061dc:	7726                	ld	a4,104(sp)
    800061de:	77c6                	ld	a5,112(sp)
    800061e0:	7866                	ld	a6,120(sp)
    800061e2:	688a                	ld	a7,128(sp)
    800061e4:	692a                	ld	s2,136(sp)
    800061e6:	69ca                	ld	s3,144(sp)
    800061e8:	6a6a                	ld	s4,152(sp)
    800061ea:	7a8a                	ld	s5,160(sp)
    800061ec:	7b2a                	ld	s6,168(sp)
    800061ee:	7bca                	ld	s7,176(sp)
    800061f0:	7c6a                	ld	s8,184(sp)
    800061f2:	6c8e                	ld	s9,192(sp)
    800061f4:	6d2e                	ld	s10,200(sp)
    800061f6:	6dce                	ld	s11,208(sp)
    800061f8:	6e6e                	ld	t3,216(sp)
    800061fa:	7e8e                	ld	t4,224(sp)
    800061fc:	7f2e                	ld	t5,232(sp)
    800061fe:	7fce                	ld	t6,240(sp)
    80006200:	6111                	add	sp,sp,256
    80006202:	10200073          	sret
    80006206:	00000013          	nop
    8000620a:	00000013          	nop
    8000620e:	0001                	nop

0000000080006210 <timervec>:
    80006210:	34051573          	csrrw	a0,mscratch,a0
    80006214:	e10c                	sd	a1,0(a0)
    80006216:	e510                	sd	a2,8(a0)
    80006218:	e914                	sd	a3,16(a0)
    8000621a:	6d0c                	ld	a1,24(a0)
    8000621c:	7110                	ld	a2,32(a0)
    8000621e:	6194                	ld	a3,0(a1)
    80006220:	96b2                	add	a3,a3,a2
    80006222:	e194                	sd	a3,0(a1)
    80006224:	4589                	li	a1,2
    80006226:	14459073          	csrw	sip,a1
    8000622a:	6914                	ld	a3,16(a0)
    8000622c:	6510                	ld	a2,8(a0)
    8000622e:	610c                	ld	a1,0(a0)
    80006230:	34051573          	csrrw	a0,mscratch,a0
    80006234:	30200073          	mret
	...

000000008000623a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000623a:	1141                	add	sp,sp,-16
    8000623c:	e422                	sd	s0,8(sp)
    8000623e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006240:	0c0007b7          	lui	a5,0xc000
    80006244:	4705                	li	a4,1
    80006246:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006248:	0c0007b7          	lui	a5,0xc000
    8000624c:	c3d8                	sw	a4,4(a5)
}
    8000624e:	6422                	ld	s0,8(sp)
    80006250:	0141                	add	sp,sp,16
    80006252:	8082                	ret

0000000080006254 <plicinithart>:

void
plicinithart(void)
{
    80006254:	1141                	add	sp,sp,-16
    80006256:	e406                	sd	ra,8(sp)
    80006258:	e022                	sd	s0,0(sp)
    8000625a:	0800                	add	s0,sp,16
  int hart = cpuid();
    8000625c:	ffffc097          	auipc	ra,0xffffc
    80006260:	97e080e7          	jalr	-1666(ra) # 80001bda <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006264:	0085171b          	sllw	a4,a0,0x8
    80006268:	0c0027b7          	lui	a5,0xc002
    8000626c:	97ba                	add	a5,a5,a4
    8000626e:	40200713          	li	a4,1026
    80006272:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006276:	00d5151b          	sllw	a0,a0,0xd
    8000627a:	0c2017b7          	lui	a5,0xc201
    8000627e:	97aa                	add	a5,a5,a0
    80006280:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006284:	60a2                	ld	ra,8(sp)
    80006286:	6402                	ld	s0,0(sp)
    80006288:	0141                	add	sp,sp,16
    8000628a:	8082                	ret

000000008000628c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000628c:	1141                	add	sp,sp,-16
    8000628e:	e406                	sd	ra,8(sp)
    80006290:	e022                	sd	s0,0(sp)
    80006292:	0800                	add	s0,sp,16
  int hart = cpuid();
    80006294:	ffffc097          	auipc	ra,0xffffc
    80006298:	946080e7          	jalr	-1722(ra) # 80001bda <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000629c:	00d5151b          	sllw	a0,a0,0xd
    800062a0:	0c2017b7          	lui	a5,0xc201
    800062a4:	97aa                	add	a5,a5,a0
  return irq;
}
    800062a6:	43c8                	lw	a0,4(a5)
    800062a8:	60a2                	ld	ra,8(sp)
    800062aa:	6402                	ld	s0,0(sp)
    800062ac:	0141                	add	sp,sp,16
    800062ae:	8082                	ret

00000000800062b0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800062b0:	1101                	add	sp,sp,-32
    800062b2:	ec06                	sd	ra,24(sp)
    800062b4:	e822                	sd	s0,16(sp)
    800062b6:	e426                	sd	s1,8(sp)
    800062b8:	1000                	add	s0,sp,32
    800062ba:	84aa                	mv	s1,a0
  int hart = cpuid();
    800062bc:	ffffc097          	auipc	ra,0xffffc
    800062c0:	91e080e7          	jalr	-1762(ra) # 80001bda <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800062c4:	00d5151b          	sllw	a0,a0,0xd
    800062c8:	0c2017b7          	lui	a5,0xc201
    800062cc:	97aa                	add	a5,a5,a0
    800062ce:	c3c4                	sw	s1,4(a5)
}
    800062d0:	60e2                	ld	ra,24(sp)
    800062d2:	6442                	ld	s0,16(sp)
    800062d4:	64a2                	ld	s1,8(sp)
    800062d6:	6105                	add	sp,sp,32
    800062d8:	8082                	ret

00000000800062da <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062da:	1141                	add	sp,sp,-16
    800062dc:	e406                	sd	ra,8(sp)
    800062de:	e022                	sd	s0,0(sp)
    800062e0:	0800                	add	s0,sp,16
  if(i >= NUM)
    800062e2:	479d                	li	a5,7
    800062e4:	04a7cc63          	blt	a5,a0,8000633c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800062e8:	0001c797          	auipc	a5,0x1c
    800062ec:	a9878793          	add	a5,a5,-1384 # 80021d80 <disk>
    800062f0:	97aa                	add	a5,a5,a0
    800062f2:	0187c783          	lbu	a5,24(a5)
    800062f6:	ebb9                	bnez	a5,8000634c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800062f8:	00451693          	sll	a3,a0,0x4
    800062fc:	0001c797          	auipc	a5,0x1c
    80006300:	a8478793          	add	a5,a5,-1404 # 80021d80 <disk>
    80006304:	6398                	ld	a4,0(a5)
    80006306:	9736                	add	a4,a4,a3
    80006308:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000630c:	6398                	ld	a4,0(a5)
    8000630e:	9736                	add	a4,a4,a3
    80006310:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006314:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006318:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000631c:	97aa                	add	a5,a5,a0
    8000631e:	4705                	li	a4,1
    80006320:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006324:	0001c517          	auipc	a0,0x1c
    80006328:	a7450513          	add	a0,a0,-1420 # 80021d98 <disk+0x18>
    8000632c:	ffffc097          	auipc	ra,0xffffc
    80006330:	0f0080e7          	jalr	240(ra) # 8000241c <wakeup>
}
    80006334:	60a2                	ld	ra,8(sp)
    80006336:	6402                	ld	s0,0(sp)
    80006338:	0141                	add	sp,sp,16
    8000633a:	8082                	ret
    panic("free_desc 1");
    8000633c:	00002517          	auipc	a0,0x2
    80006340:	40450513          	add	a0,a0,1028 # 80008740 <__func__.1+0x738>
    80006344:	ffffa097          	auipc	ra,0xffffa
    80006348:	21c080e7          	jalr	540(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000634c:	00002517          	auipc	a0,0x2
    80006350:	40450513          	add	a0,a0,1028 # 80008750 <__func__.1+0x748>
    80006354:	ffffa097          	auipc	ra,0xffffa
    80006358:	20c080e7          	jalr	524(ra) # 80000560 <panic>

000000008000635c <virtio_disk_init>:
{
    8000635c:	1101                	add	sp,sp,-32
    8000635e:	ec06                	sd	ra,24(sp)
    80006360:	e822                	sd	s0,16(sp)
    80006362:	e426                	sd	s1,8(sp)
    80006364:	e04a                	sd	s2,0(sp)
    80006366:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006368:	00002597          	auipc	a1,0x2
    8000636c:	3f858593          	add	a1,a1,1016 # 80008760 <__func__.1+0x758>
    80006370:	0001c517          	auipc	a0,0x1c
    80006374:	b3850513          	add	a0,a0,-1224 # 80021ea8 <disk+0x128>
    80006378:	ffffb097          	auipc	ra,0xffffb
    8000637c:	8f8080e7          	jalr	-1800(ra) # 80000c70 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006380:	100017b7          	lui	a5,0x10001
    80006384:	4398                	lw	a4,0(a5)
    80006386:	2701                	sext.w	a4,a4
    80006388:	747277b7          	lui	a5,0x74727
    8000638c:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006390:	18f71c63          	bne	a4,a5,80006528 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006394:	100017b7          	lui	a5,0x10001
    80006398:	0791                	add	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    8000639a:	439c                	lw	a5,0(a5)
    8000639c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000639e:	4709                	li	a4,2
    800063a0:	18e79463          	bne	a5,a4,80006528 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063a4:	100017b7          	lui	a5,0x10001
    800063a8:	07a1                	add	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800063aa:	439c                	lw	a5,0(a5)
    800063ac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063ae:	16e79d63          	bne	a5,a4,80006528 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800063b2:	100017b7          	lui	a5,0x10001
    800063b6:	47d8                	lw	a4,12(a5)
    800063b8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063ba:	554d47b7          	lui	a5,0x554d4
    800063be:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063c2:	16f71363          	bne	a4,a5,80006528 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063c6:	100017b7          	lui	a5,0x10001
    800063ca:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063ce:	4705                	li	a4,1
    800063d0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063d2:	470d                	li	a4,3
    800063d4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063d6:	10001737          	lui	a4,0x10001
    800063da:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063dc:	c7ffe737          	lui	a4,0xc7ffe
    800063e0:	75f70713          	add	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc89f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063e4:	8ef9                	and	a3,a3,a4
    800063e6:	10001737          	lui	a4,0x10001
    800063ea:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063ec:	472d                	li	a4,11
    800063ee:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063f0:	07078793          	add	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800063f4:	439c                	lw	a5,0(a5)
    800063f6:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800063fa:	8ba1                	and	a5,a5,8
    800063fc:	12078e63          	beqz	a5,80006538 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006400:	100017b7          	lui	a5,0x10001
    80006404:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006408:	100017b7          	lui	a5,0x10001
    8000640c:	04478793          	add	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006410:	439c                	lw	a5,0(a5)
    80006412:	2781                	sext.w	a5,a5
    80006414:	12079a63          	bnez	a5,80006548 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006418:	100017b7          	lui	a5,0x10001
    8000641c:	03478793          	add	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006420:	439c                	lw	a5,0(a5)
    80006422:	2781                	sext.w	a5,a5
  if(max == 0)
    80006424:	12078a63          	beqz	a5,80006558 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006428:	471d                	li	a4,7
    8000642a:	12f77f63          	bgeu	a4,a5,80006568 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000642e:	ffffa097          	auipc	ra,0xffffa
    80006432:	796080e7          	jalr	1942(ra) # 80000bc4 <kalloc>
    80006436:	0001c497          	auipc	s1,0x1c
    8000643a:	94a48493          	add	s1,s1,-1718 # 80021d80 <disk>
    8000643e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006440:	ffffa097          	auipc	ra,0xffffa
    80006444:	784080e7          	jalr	1924(ra) # 80000bc4 <kalloc>
    80006448:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000644a:	ffffa097          	auipc	ra,0xffffa
    8000644e:	77a080e7          	jalr	1914(ra) # 80000bc4 <kalloc>
    80006452:	87aa                	mv	a5,a0
    80006454:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006456:	6088                	ld	a0,0(s1)
    80006458:	12050063          	beqz	a0,80006578 <virtio_disk_init+0x21c>
    8000645c:	0001c717          	auipc	a4,0x1c
    80006460:	92c73703          	ld	a4,-1748(a4) # 80021d88 <disk+0x8>
    80006464:	10070a63          	beqz	a4,80006578 <virtio_disk_init+0x21c>
    80006468:	10078863          	beqz	a5,80006578 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    8000646c:	6605                	lui	a2,0x1
    8000646e:	4581                	li	a1,0
    80006470:	ffffb097          	auipc	ra,0xffffb
    80006474:	98c080e7          	jalr	-1652(ra) # 80000dfc <memset>
  memset(disk.avail, 0, PGSIZE);
    80006478:	0001c497          	auipc	s1,0x1c
    8000647c:	90848493          	add	s1,s1,-1784 # 80021d80 <disk>
    80006480:	6605                	lui	a2,0x1
    80006482:	4581                	li	a1,0
    80006484:	6488                	ld	a0,8(s1)
    80006486:	ffffb097          	auipc	ra,0xffffb
    8000648a:	976080e7          	jalr	-1674(ra) # 80000dfc <memset>
  memset(disk.used, 0, PGSIZE);
    8000648e:	6605                	lui	a2,0x1
    80006490:	4581                	li	a1,0
    80006492:	6888                	ld	a0,16(s1)
    80006494:	ffffb097          	auipc	ra,0xffffb
    80006498:	968080e7          	jalr	-1688(ra) # 80000dfc <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000649c:	100017b7          	lui	a5,0x10001
    800064a0:	4721                	li	a4,8
    800064a2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800064a4:	4098                	lw	a4,0(s1)
    800064a6:	100017b7          	lui	a5,0x10001
    800064aa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800064ae:	40d8                	lw	a4,4(s1)
    800064b0:	100017b7          	lui	a5,0x10001
    800064b4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800064b8:	649c                	ld	a5,8(s1)
    800064ba:	0007869b          	sext.w	a3,a5
    800064be:	10001737          	lui	a4,0x10001
    800064c2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800064c6:	9781                	sra	a5,a5,0x20
    800064c8:	10001737          	lui	a4,0x10001
    800064cc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800064d0:	689c                	ld	a5,16(s1)
    800064d2:	0007869b          	sext.w	a3,a5
    800064d6:	10001737          	lui	a4,0x10001
    800064da:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800064de:	9781                	sra	a5,a5,0x20
    800064e0:	10001737          	lui	a4,0x10001
    800064e4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800064e8:	10001737          	lui	a4,0x10001
    800064ec:	4785                	li	a5,1
    800064ee:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800064f0:	00f48c23          	sb	a5,24(s1)
    800064f4:	00f48ca3          	sb	a5,25(s1)
    800064f8:	00f48d23          	sb	a5,26(s1)
    800064fc:	00f48da3          	sb	a5,27(s1)
    80006500:	00f48e23          	sb	a5,28(s1)
    80006504:	00f48ea3          	sb	a5,29(s1)
    80006508:	00f48f23          	sb	a5,30(s1)
    8000650c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006510:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006514:	100017b7          	lui	a5,0x10001
    80006518:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000651c:	60e2                	ld	ra,24(sp)
    8000651e:	6442                	ld	s0,16(sp)
    80006520:	64a2                	ld	s1,8(sp)
    80006522:	6902                	ld	s2,0(sp)
    80006524:	6105                	add	sp,sp,32
    80006526:	8082                	ret
    panic("could not find virtio disk");
    80006528:	00002517          	auipc	a0,0x2
    8000652c:	24850513          	add	a0,a0,584 # 80008770 <__func__.1+0x768>
    80006530:	ffffa097          	auipc	ra,0xffffa
    80006534:	030080e7          	jalr	48(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006538:	00002517          	auipc	a0,0x2
    8000653c:	25850513          	add	a0,a0,600 # 80008790 <__func__.1+0x788>
    80006540:	ffffa097          	auipc	ra,0xffffa
    80006544:	020080e7          	jalr	32(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006548:	00002517          	auipc	a0,0x2
    8000654c:	26850513          	add	a0,a0,616 # 800087b0 <__func__.1+0x7a8>
    80006550:	ffffa097          	auipc	ra,0xffffa
    80006554:	010080e7          	jalr	16(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006558:	00002517          	auipc	a0,0x2
    8000655c:	27850513          	add	a0,a0,632 # 800087d0 <__func__.1+0x7c8>
    80006560:	ffffa097          	auipc	ra,0xffffa
    80006564:	000080e7          	jalr	ra # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006568:	00002517          	auipc	a0,0x2
    8000656c:	28850513          	add	a0,a0,648 # 800087f0 <__func__.1+0x7e8>
    80006570:	ffffa097          	auipc	ra,0xffffa
    80006574:	ff0080e7          	jalr	-16(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006578:	00002517          	auipc	a0,0x2
    8000657c:	29850513          	add	a0,a0,664 # 80008810 <__func__.1+0x808>
    80006580:	ffffa097          	auipc	ra,0xffffa
    80006584:	fe0080e7          	jalr	-32(ra) # 80000560 <panic>

0000000080006588 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006588:	7159                	add	sp,sp,-112
    8000658a:	f486                	sd	ra,104(sp)
    8000658c:	f0a2                	sd	s0,96(sp)
    8000658e:	eca6                	sd	s1,88(sp)
    80006590:	e8ca                	sd	s2,80(sp)
    80006592:	e4ce                	sd	s3,72(sp)
    80006594:	e0d2                	sd	s4,64(sp)
    80006596:	fc56                	sd	s5,56(sp)
    80006598:	f85a                	sd	s6,48(sp)
    8000659a:	f45e                	sd	s7,40(sp)
    8000659c:	f062                	sd	s8,32(sp)
    8000659e:	ec66                	sd	s9,24(sp)
    800065a0:	1880                	add	s0,sp,112
    800065a2:	8a2a                	mv	s4,a0
    800065a4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800065a6:	00c52c83          	lw	s9,12(a0)
    800065aa:	001c9c9b          	sllw	s9,s9,0x1
    800065ae:	1c82                	sll	s9,s9,0x20
    800065b0:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800065b4:	0001c517          	auipc	a0,0x1c
    800065b8:	8f450513          	add	a0,a0,-1804 # 80021ea8 <disk+0x128>
    800065bc:	ffffa097          	auipc	ra,0xffffa
    800065c0:	744080e7          	jalr	1860(ra) # 80000d00 <acquire>
  for(int i = 0; i < 3; i++){
    800065c4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800065c6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800065c8:	0001bb17          	auipc	s6,0x1b
    800065cc:	7b8b0b13          	add	s6,s6,1976 # 80021d80 <disk>
  for(int i = 0; i < 3; i++){
    800065d0:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065d2:	0001cc17          	auipc	s8,0x1c
    800065d6:	8d6c0c13          	add	s8,s8,-1834 # 80021ea8 <disk+0x128>
    800065da:	a0ad                	j	80006644 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800065dc:	00fb0733          	add	a4,s6,a5
    800065e0:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800065e4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800065e6:	0207c563          	bltz	a5,80006610 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800065ea:	2905                	addw	s2,s2,1
    800065ec:	0611                	add	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800065ee:	05590f63          	beq	s2,s5,8000664c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    800065f2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800065f4:	0001b717          	auipc	a4,0x1b
    800065f8:	78c70713          	add	a4,a4,1932 # 80021d80 <disk>
    800065fc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800065fe:	01874683          	lbu	a3,24(a4)
    80006602:	fee9                	bnez	a3,800065dc <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006604:	2785                	addw	a5,a5,1
    80006606:	0705                	add	a4,a4,1
    80006608:	fe979be3          	bne	a5,s1,800065fe <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000660c:	57fd                	li	a5,-1
    8000660e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006610:	03205163          	blez	s2,80006632 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006614:	f9042503          	lw	a0,-112(s0)
    80006618:	00000097          	auipc	ra,0x0
    8000661c:	cc2080e7          	jalr	-830(ra) # 800062da <free_desc>
      for(int j = 0; j < i; j++)
    80006620:	4785                	li	a5,1
    80006622:	0127d863          	bge	a5,s2,80006632 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006626:	f9442503          	lw	a0,-108(s0)
    8000662a:	00000097          	auipc	ra,0x0
    8000662e:	cb0080e7          	jalr	-848(ra) # 800062da <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006632:	85e2                	mv	a1,s8
    80006634:	0001b517          	auipc	a0,0x1b
    80006638:	76450513          	add	a0,a0,1892 # 80021d98 <disk+0x18>
    8000663c:	ffffc097          	auipc	ra,0xffffc
    80006640:	d7c080e7          	jalr	-644(ra) # 800023b8 <sleep>
  for(int i = 0; i < 3; i++){
    80006644:	f9040613          	add	a2,s0,-112
    80006648:	894e                	mv	s2,s3
    8000664a:	b765                	j	800065f2 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000664c:	f9042503          	lw	a0,-112(s0)
    80006650:	00451693          	sll	a3,a0,0x4

  if(write)
    80006654:	0001b797          	auipc	a5,0x1b
    80006658:	72c78793          	add	a5,a5,1836 # 80021d80 <disk>
    8000665c:	00a50713          	add	a4,a0,10
    80006660:	0712                	sll	a4,a4,0x4
    80006662:	973e                	add	a4,a4,a5
    80006664:	01703633          	snez	a2,s7
    80006668:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000666a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000666e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006672:	6398                	ld	a4,0(a5)
    80006674:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006676:	0a868613          	add	a2,a3,168
    8000667a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000667c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000667e:	6390                	ld	a2,0(a5)
    80006680:	00d605b3          	add	a1,a2,a3
    80006684:	4741                	li	a4,16
    80006686:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006688:	4805                	li	a6,1
    8000668a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000668e:	f9442703          	lw	a4,-108(s0)
    80006692:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006696:	0712                	sll	a4,a4,0x4
    80006698:	963a                	add	a2,a2,a4
    8000669a:	058a0593          	add	a1,s4,88
    8000669e:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800066a0:	0007b883          	ld	a7,0(a5)
    800066a4:	9746                	add	a4,a4,a7
    800066a6:	40000613          	li	a2,1024
    800066aa:	c710                	sw	a2,8(a4)
  if(write)
    800066ac:	001bb613          	seqz	a2,s7
    800066b0:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800066b4:	00166613          	or	a2,a2,1
    800066b8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800066bc:	f9842583          	lw	a1,-104(s0)
    800066c0:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800066c4:	00250613          	add	a2,a0,2
    800066c8:	0612                	sll	a2,a2,0x4
    800066ca:	963e                	add	a2,a2,a5
    800066cc:	577d                	li	a4,-1
    800066ce:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800066d2:	0592                	sll	a1,a1,0x4
    800066d4:	98ae                	add	a7,a7,a1
    800066d6:	03068713          	add	a4,a3,48
    800066da:	973e                	add	a4,a4,a5
    800066dc:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800066e0:	6398                	ld	a4,0(a5)
    800066e2:	972e                	add	a4,a4,a1
    800066e4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066e8:	4689                	li	a3,2
    800066ea:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800066ee:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800066f2:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800066f6:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800066fa:	6794                	ld	a3,8(a5)
    800066fc:	0026d703          	lhu	a4,2(a3)
    80006700:	8b1d                	and	a4,a4,7
    80006702:	0706                	sll	a4,a4,0x1
    80006704:	96ba                	add	a3,a3,a4
    80006706:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000670a:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000670e:	6798                	ld	a4,8(a5)
    80006710:	00275783          	lhu	a5,2(a4)
    80006714:	2785                	addw	a5,a5,1
    80006716:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000671a:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000671e:	100017b7          	lui	a5,0x10001
    80006722:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006726:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000672a:	0001b917          	auipc	s2,0x1b
    8000672e:	77e90913          	add	s2,s2,1918 # 80021ea8 <disk+0x128>
  while(b->disk == 1) {
    80006732:	4485                	li	s1,1
    80006734:	01079c63          	bne	a5,a6,8000674c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006738:	85ca                	mv	a1,s2
    8000673a:	8552                	mv	a0,s4
    8000673c:	ffffc097          	auipc	ra,0xffffc
    80006740:	c7c080e7          	jalr	-900(ra) # 800023b8 <sleep>
  while(b->disk == 1) {
    80006744:	004a2783          	lw	a5,4(s4)
    80006748:	fe9788e3          	beq	a5,s1,80006738 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000674c:	f9042903          	lw	s2,-112(s0)
    80006750:	00290713          	add	a4,s2,2
    80006754:	0712                	sll	a4,a4,0x4
    80006756:	0001b797          	auipc	a5,0x1b
    8000675a:	62a78793          	add	a5,a5,1578 # 80021d80 <disk>
    8000675e:	97ba                	add	a5,a5,a4
    80006760:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006764:	0001b997          	auipc	s3,0x1b
    80006768:	61c98993          	add	s3,s3,1564 # 80021d80 <disk>
    8000676c:	00491713          	sll	a4,s2,0x4
    80006770:	0009b783          	ld	a5,0(s3)
    80006774:	97ba                	add	a5,a5,a4
    80006776:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000677a:	854a                	mv	a0,s2
    8000677c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006780:	00000097          	auipc	ra,0x0
    80006784:	b5a080e7          	jalr	-1190(ra) # 800062da <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006788:	8885                	and	s1,s1,1
    8000678a:	f0ed                	bnez	s1,8000676c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000678c:	0001b517          	auipc	a0,0x1b
    80006790:	71c50513          	add	a0,a0,1820 # 80021ea8 <disk+0x128>
    80006794:	ffffa097          	auipc	ra,0xffffa
    80006798:	620080e7          	jalr	1568(ra) # 80000db4 <release>
}
    8000679c:	70a6                	ld	ra,104(sp)
    8000679e:	7406                	ld	s0,96(sp)
    800067a0:	64e6                	ld	s1,88(sp)
    800067a2:	6946                	ld	s2,80(sp)
    800067a4:	69a6                	ld	s3,72(sp)
    800067a6:	6a06                	ld	s4,64(sp)
    800067a8:	7ae2                	ld	s5,56(sp)
    800067aa:	7b42                	ld	s6,48(sp)
    800067ac:	7ba2                	ld	s7,40(sp)
    800067ae:	7c02                	ld	s8,32(sp)
    800067b0:	6ce2                	ld	s9,24(sp)
    800067b2:	6165                	add	sp,sp,112
    800067b4:	8082                	ret

00000000800067b6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800067b6:	1101                	add	sp,sp,-32
    800067b8:	ec06                	sd	ra,24(sp)
    800067ba:	e822                	sd	s0,16(sp)
    800067bc:	e426                	sd	s1,8(sp)
    800067be:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067c0:	0001b497          	auipc	s1,0x1b
    800067c4:	5c048493          	add	s1,s1,1472 # 80021d80 <disk>
    800067c8:	0001b517          	auipc	a0,0x1b
    800067cc:	6e050513          	add	a0,a0,1760 # 80021ea8 <disk+0x128>
    800067d0:	ffffa097          	auipc	ra,0xffffa
    800067d4:	530080e7          	jalr	1328(ra) # 80000d00 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800067d8:	100017b7          	lui	a5,0x10001
    800067dc:	53b8                	lw	a4,96(a5)
    800067de:	8b0d                	and	a4,a4,3
    800067e0:	100017b7          	lui	a5,0x10001
    800067e4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800067e6:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800067ea:	689c                	ld	a5,16(s1)
    800067ec:	0204d703          	lhu	a4,32(s1)
    800067f0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800067f4:	04f70863          	beq	a4,a5,80006844 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    800067f8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067fc:	6898                	ld	a4,16(s1)
    800067fe:	0204d783          	lhu	a5,32(s1)
    80006802:	8b9d                	and	a5,a5,7
    80006804:	078e                	sll	a5,a5,0x3
    80006806:	97ba                	add	a5,a5,a4
    80006808:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000680a:	00278713          	add	a4,a5,2
    8000680e:	0712                	sll	a4,a4,0x4
    80006810:	9726                	add	a4,a4,s1
    80006812:	01074703          	lbu	a4,16(a4)
    80006816:	e721                	bnez	a4,8000685e <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006818:	0789                	add	a5,a5,2
    8000681a:	0792                	sll	a5,a5,0x4
    8000681c:	97a6                	add	a5,a5,s1
    8000681e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006820:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006824:	ffffc097          	auipc	ra,0xffffc
    80006828:	bf8080e7          	jalr	-1032(ra) # 8000241c <wakeup>

    disk.used_idx += 1;
    8000682c:	0204d783          	lhu	a5,32(s1)
    80006830:	2785                	addw	a5,a5,1
    80006832:	17c2                	sll	a5,a5,0x30
    80006834:	93c1                	srl	a5,a5,0x30
    80006836:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000683a:	6898                	ld	a4,16(s1)
    8000683c:	00275703          	lhu	a4,2(a4)
    80006840:	faf71ce3          	bne	a4,a5,800067f8 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006844:	0001b517          	auipc	a0,0x1b
    80006848:	66450513          	add	a0,a0,1636 # 80021ea8 <disk+0x128>
    8000684c:	ffffa097          	auipc	ra,0xffffa
    80006850:	568080e7          	jalr	1384(ra) # 80000db4 <release>
}
    80006854:	60e2                	ld	ra,24(sp)
    80006856:	6442                	ld	s0,16(sp)
    80006858:	64a2                	ld	s1,8(sp)
    8000685a:	6105                	add	sp,sp,32
    8000685c:	8082                	ret
      panic("virtio_disk_intr status");
    8000685e:	00002517          	auipc	a0,0x2
    80006862:	fca50513          	add	a0,a0,-54 # 80008828 <__func__.1+0x820>
    80006866:	ffffa097          	auipc	ra,0xffffa
    8000686a:	cfa080e7          	jalr	-774(ra) # 80000560 <panic>
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
