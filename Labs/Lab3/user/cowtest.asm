
user/_cowtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <testcase4>:

int global_array[16777216] = {0};
int global_var = 0;

void testcase4()
{
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	add	s0,sp,32
    int pid;

    printf("\n----- Test case 4 -----\n");
   c:	00001517          	auipc	a0,0x1
  10:	d7450513          	add	a0,a0,-652 # d80 <malloc+0x10a>
  14:	00001097          	auipc	ra,0x1
  18:	baa080e7          	jalr	-1110(ra) # bbe <printf>
    printf("[prnt] v1 --> ");
  1c:	00001517          	auipc	a0,0x1
  20:	d8450513          	add	a0,a0,-636 # da0 <malloc+0x12a>
  24:	00001097          	auipc	ra,0x1
  28:	b9a080e7          	jalr	-1126(ra) # bbe <printf>
    print_free_frame_cnt();
  2c:	00001097          	auipc	ra,0x1
  30:	8c2080e7          	jalr	-1854(ra) # 8ee <pfreepages>

    if ((pid = fork()) == 0)
  34:	00000097          	auipc	ra,0x0
  38:	7f2080e7          	jalr	2034(ra) # 826 <fork>
  3c:	c161                	beqz	a0,fc <testcase4+0xfc>
  3e:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
  40:	00001517          	auipc	a0,0x1
  44:	e8050513          	add	a0,a0,-384 # ec0 <malloc+0x24a>
  48:	00001097          	auipc	ra,0x1
  4c:	b76080e7          	jalr	-1162(ra) # bbe <printf>
        print_free_frame_cnt();
  50:	00001097          	auipc	ra,0x1
  54:	89e080e7          	jalr	-1890(ra) # 8ee <pfreepages>

        global_array[0] = 111;
  58:	00002917          	auipc	s2,0x2
  5c:	fb890913          	add	s2,s2,-72 # 2010 <global_array>
  60:	06f00793          	li	a5,111
  64:	00f92023          	sw	a5,0(s2)
        printf("[prnt] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
  68:	06f00593          	li	a1,111
  6c:	00001517          	auipc	a0,0x1
  70:	e6450513          	add	a0,a0,-412 # ed0 <malloc+0x25a>
  74:	00001097          	auipc	ra,0x1
  78:	b4a080e7          	jalr	-1206(ra) # bbe <printf>

        printf("[prnt] v3 --> ");
  7c:	00001517          	auipc	a0,0x1
  80:	e9c50513          	add	a0,a0,-356 # f18 <malloc+0x2a2>
  84:	00001097          	auipc	ra,0x1
  88:	b3a080e7          	jalr	-1222(ra) # bbe <printf>
        print_free_frame_cnt();
  8c:	00001097          	auipc	ra,0x1
  90:	862080e7          	jalr	-1950(ra) # 8ee <pfreepages>
        printf("[prnt] pa3 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
  94:	4581                	li	a1,0
  96:	854a                	mv	a0,s2
  98:	00001097          	auipc	ra,0x1
  9c:	84e080e7          	jalr	-1970(ra) # 8e6 <va2pa>
  a0:	85aa                	mv	a1,a0
  a2:	00001517          	auipc	a0,0x1
  a6:	e8650513          	add	a0,a0,-378 # f28 <malloc+0x2b2>
  aa:	00001097          	auipc	ra,0x1
  ae:	b14080e7          	jalr	-1260(ra) # bbe <printf>
    }

    if (wait(0) != pid)
  b2:	4501                	li	a0,0
  b4:	00000097          	auipc	ra,0x0
  b8:	782080e7          	jalr	1922(ra) # 836 <wait>
  bc:	12951763          	bne	a0,s1,1ea <testcase4+0x1ea>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] global_array[0] --> %d\n", global_array[0]);
  c0:	00002597          	auipc	a1,0x2
  c4:	f505a583          	lw	a1,-176(a1) # 2010 <global_array>
  c8:	00001517          	auipc	a0,0x1
  cc:	e8850513          	add	a0,a0,-376 # f50 <malloc+0x2da>
  d0:	00001097          	auipc	ra,0x1
  d4:	aee080e7          	jalr	-1298(ra) # bbe <printf>

    printf("[prnt] v7 --> ");
  d8:	00001517          	auipc	a0,0x1
  dc:	e9850513          	add	a0,a0,-360 # f70 <malloc+0x2fa>
  e0:	00001097          	auipc	ra,0x1
  e4:	ade080e7          	jalr	-1314(ra) # bbe <printf>
    print_free_frame_cnt();
  e8:	00001097          	auipc	ra,0x1
  ec:	806080e7          	jalr	-2042(ra) # 8ee <pfreepages>
}
  f0:	60e2                	ld	ra,24(sp)
  f2:	6442                	ld	s0,16(sp)
  f4:	64a2                	ld	s1,8(sp)
  f6:	6902                	ld	s2,0(sp)
  f8:	6105                	add	sp,sp,32
  fa:	8082                	ret
        sleep(50);
  fc:	03200513          	li	a0,50
 100:	00000097          	auipc	ra,0x0
 104:	7be080e7          	jalr	1982(ra) # 8be <sleep>
        printf("[chld] pa1 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 108:	00002497          	auipc	s1,0x2
 10c:	f0848493          	add	s1,s1,-248 # 2010 <global_array>
 110:	4581                	li	a1,0
 112:	8526                	mv	a0,s1
 114:	00000097          	auipc	ra,0x0
 118:	7d2080e7          	jalr	2002(ra) # 8e6 <va2pa>
 11c:	85aa                	mv	a1,a0
 11e:	00001517          	auipc	a0,0x1
 122:	c9250513          	add	a0,a0,-878 # db0 <malloc+0x13a>
 126:	00001097          	auipc	ra,0x1
 12a:	a98080e7          	jalr	-1384(ra) # bbe <printf>
        printf("[chld] v4 --> ");
 12e:	00001517          	auipc	a0,0x1
 132:	c9a50513          	add	a0,a0,-870 # dc8 <malloc+0x152>
 136:	00001097          	auipc	ra,0x1
 13a:	a88080e7          	jalr	-1400(ra) # bbe <printf>
        print_free_frame_cnt();
 13e:	00000097          	auipc	ra,0x0
 142:	7b0080e7          	jalr	1968(ra) # 8ee <pfreepages>
        global_array[0] = 222;
 146:	0de00793          	li	a5,222
 14a:	c09c                	sw	a5,0(s1)
        printf("[chld] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 14c:	0de00593          	li	a1,222
 150:	00001517          	auipc	a0,0x1
 154:	c8850513          	add	a0,a0,-888 # dd8 <malloc+0x162>
 158:	00001097          	auipc	ra,0x1
 15c:	a66080e7          	jalr	-1434(ra) # bbe <printf>
        printf("[chld] pa2 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 160:	4581                	li	a1,0
 162:	8526                	mv	a0,s1
 164:	00000097          	auipc	ra,0x0
 168:	782080e7          	jalr	1922(ra) # 8e6 <va2pa>
 16c:	85aa                	mv	a1,a0
 16e:	00001517          	auipc	a0,0x1
 172:	cb250513          	add	a0,a0,-846 # e20 <malloc+0x1aa>
 176:	00001097          	auipc	ra,0x1
 17a:	a48080e7          	jalr	-1464(ra) # bbe <printf>
        printf("[chld] v5 --> ");
 17e:	00001517          	auipc	a0,0x1
 182:	cba50513          	add	a0,a0,-838 # e38 <malloc+0x1c2>
 186:	00001097          	auipc	ra,0x1
 18a:	a38080e7          	jalr	-1480(ra) # bbe <printf>
        print_free_frame_cnt();
 18e:	00000097          	auipc	ra,0x0
 192:	760080e7          	jalr	1888(ra) # 8ee <pfreepages>
        global_array[2047] = 333;
 196:	14d00793          	li	a5,333
 19a:	00004717          	auipc	a4,0x4
 19e:	e6f72923          	sw	a5,-398(a4) # 400c <global_array+0x1ffc>
        printf("[chld] modified two elements in the 2nd page, global_array[2047]=%d\n", global_array[2047]);
 1a2:	14d00593          	li	a1,333
 1a6:	00001517          	auipc	a0,0x1
 1aa:	ca250513          	add	a0,a0,-862 # e48 <malloc+0x1d2>
 1ae:	00001097          	auipc	ra,0x1
 1b2:	a10080e7          	jalr	-1520(ra) # bbe <printf>
        printf("[chld] v6 --> ");
 1b6:	00001517          	auipc	a0,0x1
 1ba:	cda50513          	add	a0,a0,-806 # e90 <malloc+0x21a>
 1be:	00001097          	auipc	ra,0x1
 1c2:	a00080e7          	jalr	-1536(ra) # bbe <printf>
        print_free_frame_cnt();
 1c6:	00000097          	auipc	ra,0x0
 1ca:	728080e7          	jalr	1832(ra) # 8ee <pfreepages>
        printf("[chld] global_array[0] --> %d\n", global_array[0]);
 1ce:	408c                	lw	a1,0(s1)
 1d0:	00001517          	auipc	a0,0x1
 1d4:	cd050513          	add	a0,a0,-816 # ea0 <malloc+0x22a>
 1d8:	00001097          	auipc	ra,0x1
 1dc:	9e6080e7          	jalr	-1562(ra) # bbe <printf>
        exit(0);
 1e0:	4501                	li	a0,0
 1e2:	00000097          	auipc	ra,0x0
 1e6:	64c080e7          	jalr	1612(ra) # 82e <exit>
        printf("wait() error!");
 1ea:	00001517          	auipc	a0,0x1
 1ee:	d5650513          	add	a0,a0,-682 # f40 <malloc+0x2ca>
 1f2:	00001097          	auipc	ra,0x1
 1f6:	9cc080e7          	jalr	-1588(ra) # bbe <printf>
        exit(1);
 1fa:	4505                	li	a0,1
 1fc:	00000097          	auipc	ra,0x0
 200:	632080e7          	jalr	1586(ra) # 82e <exit>

0000000000000204 <testcase3>:

void testcase3()
{
 204:	1101                	add	sp,sp,-32
 206:	ec06                	sd	ra,24(sp)
 208:	e822                	sd	s0,16(sp)
 20a:	e426                	sd	s1,8(sp)
 20c:	1000                	add	s0,sp,32
    int pid;

    printf("\n----- Test case 3 -----\n");
 20e:	00001517          	auipc	a0,0x1
 212:	d7250513          	add	a0,a0,-654 # f80 <malloc+0x30a>
 216:	00001097          	auipc	ra,0x1
 21a:	9a8080e7          	jalr	-1624(ra) # bbe <printf>
    printf("[prnt] v1 --> ");
 21e:	00001517          	auipc	a0,0x1
 222:	b8250513          	add	a0,a0,-1150 # da0 <malloc+0x12a>
 226:	00001097          	auipc	ra,0x1
 22a:	998080e7          	jalr	-1640(ra) # bbe <printf>
    print_free_frame_cnt();
 22e:	00000097          	auipc	ra,0x0
 232:	6c0080e7          	jalr	1728(ra) # 8ee <pfreepages>

    if ((pid = fork()) == 0)
 236:	00000097          	auipc	ra,0x0
 23a:	5f0080e7          	jalr	1520(ra) # 826 <fork>
 23e:	cd35                	beqz	a0,2ba <testcase3+0xb6>
 240:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 242:	00001517          	auipc	a0,0x1
 246:	c7e50513          	add	a0,a0,-898 # ec0 <malloc+0x24a>
 24a:	00001097          	auipc	ra,0x1
 24e:	974080e7          	jalr	-1676(ra) # bbe <printf>
        print_free_frame_cnt();
 252:	00000097          	auipc	ra,0x0
 256:	69c080e7          	jalr	1692(ra) # 8ee <pfreepages>

        printf("[prnt] read global_var, global_var=%d\n", global_var);
 25a:	00002597          	auipc	a1,0x2
 25e:	da65a583          	lw	a1,-602(a1) # 2000 <global_var>
 262:	00001517          	auipc	a0,0x1
 266:	d6e50513          	add	a0,a0,-658 # fd0 <malloc+0x35a>
 26a:	00001097          	auipc	ra,0x1
 26e:	954080e7          	jalr	-1708(ra) # bbe <printf>

        printf("[prnt] v3 --> ");
 272:	00001517          	auipc	a0,0x1
 276:	ca650513          	add	a0,a0,-858 # f18 <malloc+0x2a2>
 27a:	00001097          	auipc	ra,0x1
 27e:	944080e7          	jalr	-1724(ra) # bbe <printf>
        print_free_frame_cnt();
 282:	00000097          	auipc	ra,0x0
 286:	66c080e7          	jalr	1644(ra) # 8ee <pfreepages>
    }

    if (wait(0) != pid)
 28a:	4501                	li	a0,0
 28c:	00000097          	auipc	ra,0x0
 290:	5aa080e7          	jalr	1450(ra) # 836 <wait>
 294:	08951663          	bne	a0,s1,320 <testcase3+0x11c>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v6 --> ");
 298:	00001517          	auipc	a0,0x1
 29c:	d6050513          	add	a0,a0,-672 # ff8 <malloc+0x382>
 2a0:	00001097          	auipc	ra,0x1
 2a4:	91e080e7          	jalr	-1762(ra) # bbe <printf>
    print_free_frame_cnt();
 2a8:	00000097          	auipc	ra,0x0
 2ac:	646080e7          	jalr	1606(ra) # 8ee <pfreepages>
}
 2b0:	60e2                	ld	ra,24(sp)
 2b2:	6442                	ld	s0,16(sp)
 2b4:	64a2                	ld	s1,8(sp)
 2b6:	6105                	add	sp,sp,32
 2b8:	8082                	ret
        sleep(50);
 2ba:	03200513          	li	a0,50
 2be:	00000097          	auipc	ra,0x0
 2c2:	600080e7          	jalr	1536(ra) # 8be <sleep>
        printf("[chld] v4 --> ");
 2c6:	00001517          	auipc	a0,0x1
 2ca:	b0250513          	add	a0,a0,-1278 # dc8 <malloc+0x152>
 2ce:	00001097          	auipc	ra,0x1
 2d2:	8f0080e7          	jalr	-1808(ra) # bbe <printf>
        print_free_frame_cnt();
 2d6:	00000097          	auipc	ra,0x0
 2da:	618080e7          	jalr	1560(ra) # 8ee <pfreepages>
        global_var = 100;
 2de:	06400793          	li	a5,100
 2e2:	00002717          	auipc	a4,0x2
 2e6:	d0f72f23          	sw	a5,-738(a4) # 2000 <global_var>
        printf("[chld] modified global_var, global_var=%d\n", global_var);
 2ea:	06400593          	li	a1,100
 2ee:	00001517          	auipc	a0,0x1
 2f2:	cb250513          	add	a0,a0,-846 # fa0 <malloc+0x32a>
 2f6:	00001097          	auipc	ra,0x1
 2fa:	8c8080e7          	jalr	-1848(ra) # bbe <printf>
        printf("[chld] v5 --> ");
 2fe:	00001517          	auipc	a0,0x1
 302:	b3a50513          	add	a0,a0,-1222 # e38 <malloc+0x1c2>
 306:	00001097          	auipc	ra,0x1
 30a:	8b8080e7          	jalr	-1864(ra) # bbe <printf>
        print_free_frame_cnt();
 30e:	00000097          	auipc	ra,0x0
 312:	5e0080e7          	jalr	1504(ra) # 8ee <pfreepages>
        exit(0);
 316:	4501                	li	a0,0
 318:	00000097          	auipc	ra,0x0
 31c:	516080e7          	jalr	1302(ra) # 82e <exit>
        printf("wait() error!");
 320:	00001517          	auipc	a0,0x1
 324:	c2050513          	add	a0,a0,-992 # f40 <malloc+0x2ca>
 328:	00001097          	auipc	ra,0x1
 32c:	896080e7          	jalr	-1898(ra) # bbe <printf>
        exit(1);
 330:	4505                	li	a0,1
 332:	00000097          	auipc	ra,0x0
 336:	4fc080e7          	jalr	1276(ra) # 82e <exit>

000000000000033a <testcase2>:

void testcase2()
{
 33a:	1101                	add	sp,sp,-32
 33c:	ec06                	sd	ra,24(sp)
 33e:	e822                	sd	s0,16(sp)
 340:	e426                	sd	s1,8(sp)
 342:	1000                	add	s0,sp,32
    int pid;

    printf("\n----- Test case 2 -----\n");
 344:	00001517          	auipc	a0,0x1
 348:	cc450513          	add	a0,a0,-828 # 1008 <malloc+0x392>
 34c:	00001097          	auipc	ra,0x1
 350:	872080e7          	jalr	-1934(ra) # bbe <printf>
    printf("[prnt] v1 --> ");
 354:	00001517          	auipc	a0,0x1
 358:	a4c50513          	add	a0,a0,-1460 # da0 <malloc+0x12a>
 35c:	00001097          	auipc	ra,0x1
 360:	862080e7          	jalr	-1950(ra) # bbe <printf>
    print_free_frame_cnt();
 364:	00000097          	auipc	ra,0x0
 368:	58a080e7          	jalr	1418(ra) # 8ee <pfreepages>

    if ((pid = fork()) == 0)
 36c:	00000097          	auipc	ra,0x0
 370:	4ba080e7          	jalr	1210(ra) # 826 <fork>
 374:	c531                	beqz	a0,3c0 <testcase2+0x86>
 376:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 378:	00001517          	auipc	a0,0x1
 37c:	b4850513          	add	a0,a0,-1208 # ec0 <malloc+0x24a>
 380:	00001097          	auipc	ra,0x1
 384:	83e080e7          	jalr	-1986(ra) # bbe <printf>
        print_free_frame_cnt();
 388:	00000097          	auipc	ra,0x0
 38c:	566080e7          	jalr	1382(ra) # 8ee <pfreepages>
    }

    if (wait(0) != pid)
 390:	4501                	li	a0,0
 392:	00000097          	auipc	ra,0x0
 396:	4a4080e7          	jalr	1188(ra) # 836 <wait>
 39a:	08951263          	bne	a0,s1,41e <testcase2+0xe4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v5 --> ");
 39e:	00001517          	auipc	a0,0x1
 3a2:	cc250513          	add	a0,a0,-830 # 1060 <malloc+0x3ea>
 3a6:	00001097          	auipc	ra,0x1
 3aa:	818080e7          	jalr	-2024(ra) # bbe <printf>
    print_free_frame_cnt();
 3ae:	00000097          	auipc	ra,0x0
 3b2:	540080e7          	jalr	1344(ra) # 8ee <pfreepages>
}
 3b6:	60e2                	ld	ra,24(sp)
 3b8:	6442                	ld	s0,16(sp)
 3ba:	64a2                	ld	s1,8(sp)
 3bc:	6105                	add	sp,sp,32
 3be:	8082                	ret
        sleep(50);
 3c0:	03200513          	li	a0,50
 3c4:	00000097          	auipc	ra,0x0
 3c8:	4fa080e7          	jalr	1274(ra) # 8be <sleep>
        printf("[chld] v3 --> ");
 3cc:	00001517          	auipc	a0,0x1
 3d0:	c5c50513          	add	a0,a0,-932 # 1028 <malloc+0x3b2>
 3d4:	00000097          	auipc	ra,0x0
 3d8:	7ea080e7          	jalr	2026(ra) # bbe <printf>
        print_free_frame_cnt();
 3dc:	00000097          	auipc	ra,0x0
 3e0:	512080e7          	jalr	1298(ra) # 8ee <pfreepages>
        printf("[chld] read global_var, global_var=%d\n", global_var);
 3e4:	00002597          	auipc	a1,0x2
 3e8:	c1c5a583          	lw	a1,-996(a1) # 2000 <global_var>
 3ec:	00001517          	auipc	a0,0x1
 3f0:	c4c50513          	add	a0,a0,-948 # 1038 <malloc+0x3c2>
 3f4:	00000097          	auipc	ra,0x0
 3f8:	7ca080e7          	jalr	1994(ra) # bbe <printf>
        printf("[chld] v4 --> ");
 3fc:	00001517          	auipc	a0,0x1
 400:	9cc50513          	add	a0,a0,-1588 # dc8 <malloc+0x152>
 404:	00000097          	auipc	ra,0x0
 408:	7ba080e7          	jalr	1978(ra) # bbe <printf>
        print_free_frame_cnt();
 40c:	00000097          	auipc	ra,0x0
 410:	4e2080e7          	jalr	1250(ra) # 8ee <pfreepages>
        exit(0);
 414:	4501                	li	a0,0
 416:	00000097          	auipc	ra,0x0
 41a:	418080e7          	jalr	1048(ra) # 82e <exit>
        printf("wait() error!");
 41e:	00001517          	auipc	a0,0x1
 422:	b2250513          	add	a0,a0,-1246 # f40 <malloc+0x2ca>
 426:	00000097          	auipc	ra,0x0
 42a:	798080e7          	jalr	1944(ra) # bbe <printf>
        exit(1);
 42e:	4505                	li	a0,1
 430:	00000097          	auipc	ra,0x0
 434:	3fe080e7          	jalr	1022(ra) # 82e <exit>

0000000000000438 <testcase1>:

void testcase1()
{
 438:	1101                	add	sp,sp,-32
 43a:	ec06                	sd	ra,24(sp)
 43c:	e822                	sd	s0,16(sp)
 43e:	e426                	sd	s1,8(sp)
 440:	1000                	add	s0,sp,32
    int pid;

    printf("\n----- Test case 1 -----\n");
 442:	00001517          	auipc	a0,0x1
 446:	c2e50513          	add	a0,a0,-978 # 1070 <malloc+0x3fa>
 44a:	00000097          	auipc	ra,0x0
 44e:	774080e7          	jalr	1908(ra) # bbe <printf>
    printf("[prnt] v1 --> ");
 452:	00001517          	auipc	a0,0x1
 456:	94e50513          	add	a0,a0,-1714 # da0 <malloc+0x12a>
 45a:	00000097          	auipc	ra,0x0
 45e:	764080e7          	jalr	1892(ra) # bbe <printf>
    print_free_frame_cnt();
 462:	00000097          	auipc	ra,0x0
 466:	48c080e7          	jalr	1164(ra) # 8ee <pfreepages>

    if ((pid = fork()) == 0)
 46a:	00000097          	auipc	ra,0x0
 46e:	3bc080e7          	jalr	956(ra) # 826 <fork>
 472:	c531                	beqz	a0,4be <testcase1+0x86>
 474:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v3 --> ");
 476:	00001517          	auipc	a0,0x1
 47a:	aa250513          	add	a0,a0,-1374 # f18 <malloc+0x2a2>
 47e:	00000097          	auipc	ra,0x0
 482:	740080e7          	jalr	1856(ra) # bbe <printf>
        print_free_frame_cnt();
 486:	00000097          	auipc	ra,0x0
 48a:	468080e7          	jalr	1128(ra) # 8ee <pfreepages>
    }

    if (wait(0) != pid)
 48e:	4501                	li	a0,0
 490:	00000097          	auipc	ra,0x0
 494:	3a6080e7          	jalr	934(ra) # 836 <wait>
 498:	04951a63          	bne	a0,s1,4ec <testcase1+0xb4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v4 --> ");
 49c:	00001517          	auipc	a0,0x1
 4a0:	c0450513          	add	a0,a0,-1020 # 10a0 <malloc+0x42a>
 4a4:	00000097          	auipc	ra,0x0
 4a8:	71a080e7          	jalr	1818(ra) # bbe <printf>
    print_free_frame_cnt();
 4ac:	00000097          	auipc	ra,0x0
 4b0:	442080e7          	jalr	1090(ra) # 8ee <pfreepages>
}
 4b4:	60e2                	ld	ra,24(sp)
 4b6:	6442                	ld	s0,16(sp)
 4b8:	64a2                	ld	s1,8(sp)
 4ba:	6105                	add	sp,sp,32
 4bc:	8082                	ret
        sleep(50);
 4be:	03200513          	li	a0,50
 4c2:	00000097          	auipc	ra,0x0
 4c6:	3fc080e7          	jalr	1020(ra) # 8be <sleep>
        printf("[chld] v2 --> ");
 4ca:	00001517          	auipc	a0,0x1
 4ce:	bc650513          	add	a0,a0,-1082 # 1090 <malloc+0x41a>
 4d2:	00000097          	auipc	ra,0x0
 4d6:	6ec080e7          	jalr	1772(ra) # bbe <printf>
        print_free_frame_cnt();
 4da:	00000097          	auipc	ra,0x0
 4de:	414080e7          	jalr	1044(ra) # 8ee <pfreepages>
        exit(0);
 4e2:	4501                	li	a0,0
 4e4:	00000097          	auipc	ra,0x0
 4e8:	34a080e7          	jalr	842(ra) # 82e <exit>
        printf("wait() error!");
 4ec:	00001517          	auipc	a0,0x1
 4f0:	a5450513          	add	a0,a0,-1452 # f40 <malloc+0x2ca>
 4f4:	00000097          	auipc	ra,0x0
 4f8:	6ca080e7          	jalr	1738(ra) # bbe <printf>
        exit(1);
 4fc:	4505                	li	a0,1
 4fe:	00000097          	auipc	ra,0x0
 502:	330080e7          	jalr	816(ra) # 82e <exit>

0000000000000506 <main>:

int main(int argc, char *argv[])
{
 506:	1101                	add	sp,sp,-32
 508:	ec06                	sd	ra,24(sp)
 50a:	e822                	sd	s0,16(sp)
 50c:	e426                	sd	s1,8(sp)
 50e:	1000                	add	s0,sp,32
 510:	84ae                	mv	s1,a1
    if (argc < 2)
 512:	4785                	li	a5,1
 514:	02a7d763          	bge	a5,a0,542 <main+0x3c>
    {
        printf("Usage: cowtest test_id");
    }
    switch (atoi(argv[1]))
 518:	6488                	ld	a0,8(s1)
 51a:	00000097          	auipc	ra,0x0
 51e:	21a080e7          	jalr	538(ra) # 734 <atoi>
 522:	478d                	li	a5,3
 524:	06f50263          	beq	a0,a5,588 <main+0x82>
 528:	02a7c663          	blt	a5,a0,554 <main+0x4e>
 52c:	4785                	li	a5,1
 52e:	02f50b63          	beq	a0,a5,564 <main+0x5e>
 532:	4789                	li	a5,2
 534:	04f51f63          	bne	a0,a5,592 <main+0x8c>
    case 1:
        testcase1();
        break;

    case 2:
        testcase2();
 538:	00000097          	auipc	ra,0x0
 53c:	e02080e7          	jalr	-510(ra) # 33a <testcase2>
        break;
 540:	a035                	j	56c <main+0x66>
        printf("Usage: cowtest test_id");
 542:	00001517          	auipc	a0,0x1
 546:	b6e50513          	add	a0,a0,-1170 # 10b0 <malloc+0x43a>
 54a:	00000097          	auipc	ra,0x0
 54e:	674080e7          	jalr	1652(ra) # bbe <printf>
 552:	b7d9                	j	518 <main+0x12>
    switch (atoi(argv[1]))
 554:	4791                	li	a5,4
 556:	02f51e63          	bne	a0,a5,592 <main+0x8c>
    case 3:
        testcase3();
        break;

    case 4:
        testcase4();
 55a:	00000097          	auipc	ra,0x0
 55e:	aa6080e7          	jalr	-1370(ra) # 0 <testcase4>
        break;
 562:	a029                	j	56c <main+0x66>
        testcase1();
 564:	00000097          	auipc	ra,0x0
 568:	ed4080e7          	jalr	-300(ra) # 438 <testcase1>

    default:
        printf("Error: No test with index %s\n", argv[1]);
        return 1;
    }
    printf("=======================\n\n");
 56c:	00001517          	auipc	a0,0x1
 570:	b7c50513          	add	a0,a0,-1156 # 10e8 <malloc+0x472>
 574:	00000097          	auipc	ra,0x0
 578:	64a080e7          	jalr	1610(ra) # bbe <printf>
    return 0;
 57c:	4501                	li	a0,0
 57e:	60e2                	ld	ra,24(sp)
 580:	6442                	ld	s0,16(sp)
 582:	64a2                	ld	s1,8(sp)
 584:	6105                	add	sp,sp,32
 586:	8082                	ret
        testcase3();
 588:	00000097          	auipc	ra,0x0
 58c:	c7c080e7          	jalr	-900(ra) # 204 <testcase3>
        break;
 590:	bff1                	j	56c <main+0x66>
        printf("Error: No test with index %s\n", argv[1]);
 592:	648c                	ld	a1,8(s1)
 594:	00001517          	auipc	a0,0x1
 598:	b3450513          	add	a0,a0,-1228 # 10c8 <malloc+0x452>
 59c:	00000097          	auipc	ra,0x0
 5a0:	622080e7          	jalr	1570(ra) # bbe <printf>
        return 1;
 5a4:	4505                	li	a0,1
 5a6:	bfe1                	j	57e <main+0x78>

00000000000005a8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 5a8:	1141                	add	sp,sp,-16
 5aa:	e406                	sd	ra,8(sp)
 5ac:	e022                	sd	s0,0(sp)
 5ae:	0800                	add	s0,sp,16
  extern int main();
  main();
 5b0:	00000097          	auipc	ra,0x0
 5b4:	f56080e7          	jalr	-170(ra) # 506 <main>
  exit(0);
 5b8:	4501                	li	a0,0
 5ba:	00000097          	auipc	ra,0x0
 5be:	274080e7          	jalr	628(ra) # 82e <exit>

00000000000005c2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 5c2:	1141                	add	sp,sp,-16
 5c4:	e422                	sd	s0,8(sp)
 5c6:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 5c8:	87aa                	mv	a5,a0
 5ca:	0585                	add	a1,a1,1
 5cc:	0785                	add	a5,a5,1
 5ce:	fff5c703          	lbu	a4,-1(a1)
 5d2:	fee78fa3          	sb	a4,-1(a5)
 5d6:	fb75                	bnez	a4,5ca <strcpy+0x8>
    ;
  return os;
}
 5d8:	6422                	ld	s0,8(sp)
 5da:	0141                	add	sp,sp,16
 5dc:	8082                	ret

00000000000005de <strcmp>:

int
strcmp(const char *p, const char *q)
{
 5de:	1141                	add	sp,sp,-16
 5e0:	e422                	sd	s0,8(sp)
 5e2:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 5e4:	00054783          	lbu	a5,0(a0)
 5e8:	cb91                	beqz	a5,5fc <strcmp+0x1e>
 5ea:	0005c703          	lbu	a4,0(a1)
 5ee:	00f71763          	bne	a4,a5,5fc <strcmp+0x1e>
    p++, q++;
 5f2:	0505                	add	a0,a0,1
 5f4:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 5f6:	00054783          	lbu	a5,0(a0)
 5fa:	fbe5                	bnez	a5,5ea <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 5fc:	0005c503          	lbu	a0,0(a1)
}
 600:	40a7853b          	subw	a0,a5,a0
 604:	6422                	ld	s0,8(sp)
 606:	0141                	add	sp,sp,16
 608:	8082                	ret

000000000000060a <strlen>:

uint
strlen(const char *s)
{
 60a:	1141                	add	sp,sp,-16
 60c:	e422                	sd	s0,8(sp)
 60e:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 610:	00054783          	lbu	a5,0(a0)
 614:	cf91                	beqz	a5,630 <strlen+0x26>
 616:	0505                	add	a0,a0,1
 618:	87aa                	mv	a5,a0
 61a:	86be                	mv	a3,a5
 61c:	0785                	add	a5,a5,1
 61e:	fff7c703          	lbu	a4,-1(a5)
 622:	ff65                	bnez	a4,61a <strlen+0x10>
 624:	40a6853b          	subw	a0,a3,a0
 628:	2505                	addw	a0,a0,1
    ;
  return n;
}
 62a:	6422                	ld	s0,8(sp)
 62c:	0141                	add	sp,sp,16
 62e:	8082                	ret
  for(n = 0; s[n]; n++)
 630:	4501                	li	a0,0
 632:	bfe5                	j	62a <strlen+0x20>

0000000000000634 <memset>:

void*
memset(void *dst, int c, uint n)
{
 634:	1141                	add	sp,sp,-16
 636:	e422                	sd	s0,8(sp)
 638:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 63a:	ca19                	beqz	a2,650 <memset+0x1c>
 63c:	87aa                	mv	a5,a0
 63e:	1602                	sll	a2,a2,0x20
 640:	9201                	srl	a2,a2,0x20
 642:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 646:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 64a:	0785                	add	a5,a5,1
 64c:	fee79de3          	bne	a5,a4,646 <memset+0x12>
  }
  return dst;
}
 650:	6422                	ld	s0,8(sp)
 652:	0141                	add	sp,sp,16
 654:	8082                	ret

0000000000000656 <strchr>:

char*
strchr(const char *s, char c)
{
 656:	1141                	add	sp,sp,-16
 658:	e422                	sd	s0,8(sp)
 65a:	0800                	add	s0,sp,16
  for(; *s; s++)
 65c:	00054783          	lbu	a5,0(a0)
 660:	cb99                	beqz	a5,676 <strchr+0x20>
    if(*s == c)
 662:	00f58763          	beq	a1,a5,670 <strchr+0x1a>
  for(; *s; s++)
 666:	0505                	add	a0,a0,1
 668:	00054783          	lbu	a5,0(a0)
 66c:	fbfd                	bnez	a5,662 <strchr+0xc>
      return (char*)s;
  return 0;
 66e:	4501                	li	a0,0
}
 670:	6422                	ld	s0,8(sp)
 672:	0141                	add	sp,sp,16
 674:	8082                	ret
  return 0;
 676:	4501                	li	a0,0
 678:	bfe5                	j	670 <strchr+0x1a>

000000000000067a <gets>:

char*
gets(char *buf, int max)
{
 67a:	711d                	add	sp,sp,-96
 67c:	ec86                	sd	ra,88(sp)
 67e:	e8a2                	sd	s0,80(sp)
 680:	e4a6                	sd	s1,72(sp)
 682:	e0ca                	sd	s2,64(sp)
 684:	fc4e                	sd	s3,56(sp)
 686:	f852                	sd	s4,48(sp)
 688:	f456                	sd	s5,40(sp)
 68a:	f05a                	sd	s6,32(sp)
 68c:	ec5e                	sd	s7,24(sp)
 68e:	1080                	add	s0,sp,96
 690:	8baa                	mv	s7,a0
 692:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 694:	892a                	mv	s2,a0
 696:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 698:	4aa9                	li	s5,10
 69a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 69c:	89a6                	mv	s3,s1
 69e:	2485                	addw	s1,s1,1
 6a0:	0344d863          	bge	s1,s4,6d0 <gets+0x56>
    cc = read(0, &c, 1);
 6a4:	4605                	li	a2,1
 6a6:	faf40593          	add	a1,s0,-81
 6aa:	4501                	li	a0,0
 6ac:	00000097          	auipc	ra,0x0
 6b0:	19a080e7          	jalr	410(ra) # 846 <read>
    if(cc < 1)
 6b4:	00a05e63          	blez	a0,6d0 <gets+0x56>
    buf[i++] = c;
 6b8:	faf44783          	lbu	a5,-81(s0)
 6bc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 6c0:	01578763          	beq	a5,s5,6ce <gets+0x54>
 6c4:	0905                	add	s2,s2,1
 6c6:	fd679be3          	bne	a5,s6,69c <gets+0x22>
    buf[i++] = c;
 6ca:	89a6                	mv	s3,s1
 6cc:	a011                	j	6d0 <gets+0x56>
 6ce:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 6d0:	99de                	add	s3,s3,s7
 6d2:	00098023          	sb	zero,0(s3)
  return buf;
}
 6d6:	855e                	mv	a0,s7
 6d8:	60e6                	ld	ra,88(sp)
 6da:	6446                	ld	s0,80(sp)
 6dc:	64a6                	ld	s1,72(sp)
 6de:	6906                	ld	s2,64(sp)
 6e0:	79e2                	ld	s3,56(sp)
 6e2:	7a42                	ld	s4,48(sp)
 6e4:	7aa2                	ld	s5,40(sp)
 6e6:	7b02                	ld	s6,32(sp)
 6e8:	6be2                	ld	s7,24(sp)
 6ea:	6125                	add	sp,sp,96
 6ec:	8082                	ret

00000000000006ee <stat>:

int
stat(const char *n, struct stat *st)
{
 6ee:	1101                	add	sp,sp,-32
 6f0:	ec06                	sd	ra,24(sp)
 6f2:	e822                	sd	s0,16(sp)
 6f4:	e04a                	sd	s2,0(sp)
 6f6:	1000                	add	s0,sp,32
 6f8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6fa:	4581                	li	a1,0
 6fc:	00000097          	auipc	ra,0x0
 700:	172080e7          	jalr	370(ra) # 86e <open>
  if(fd < 0)
 704:	02054663          	bltz	a0,730 <stat+0x42>
 708:	e426                	sd	s1,8(sp)
 70a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 70c:	85ca                	mv	a1,s2
 70e:	00000097          	auipc	ra,0x0
 712:	178080e7          	jalr	376(ra) # 886 <fstat>
 716:	892a                	mv	s2,a0
  close(fd);
 718:	8526                	mv	a0,s1
 71a:	00000097          	auipc	ra,0x0
 71e:	13c080e7          	jalr	316(ra) # 856 <close>
  return r;
 722:	64a2                	ld	s1,8(sp)
}
 724:	854a                	mv	a0,s2
 726:	60e2                	ld	ra,24(sp)
 728:	6442                	ld	s0,16(sp)
 72a:	6902                	ld	s2,0(sp)
 72c:	6105                	add	sp,sp,32
 72e:	8082                	ret
    return -1;
 730:	597d                	li	s2,-1
 732:	bfcd                	j	724 <stat+0x36>

0000000000000734 <atoi>:

int
atoi(const char *s)
{
 734:	1141                	add	sp,sp,-16
 736:	e422                	sd	s0,8(sp)
 738:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 73a:	00054683          	lbu	a3,0(a0)
 73e:	fd06879b          	addw	a5,a3,-48
 742:	0ff7f793          	zext.b	a5,a5
 746:	4625                	li	a2,9
 748:	02f66863          	bltu	a2,a5,778 <atoi+0x44>
 74c:	872a                	mv	a4,a0
  n = 0;
 74e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 750:	0705                	add	a4,a4,1
 752:	0025179b          	sllw	a5,a0,0x2
 756:	9fa9                	addw	a5,a5,a0
 758:	0017979b          	sllw	a5,a5,0x1
 75c:	9fb5                	addw	a5,a5,a3
 75e:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 762:	00074683          	lbu	a3,0(a4)
 766:	fd06879b          	addw	a5,a3,-48
 76a:	0ff7f793          	zext.b	a5,a5
 76e:	fef671e3          	bgeu	a2,a5,750 <atoi+0x1c>
  return n;
}
 772:	6422                	ld	s0,8(sp)
 774:	0141                	add	sp,sp,16
 776:	8082                	ret
  n = 0;
 778:	4501                	li	a0,0
 77a:	bfe5                	j	772 <atoi+0x3e>

000000000000077c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 77c:	1141                	add	sp,sp,-16
 77e:	e422                	sd	s0,8(sp)
 780:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 782:	02b57463          	bgeu	a0,a1,7aa <memmove+0x2e>
    while(n-- > 0)
 786:	00c05f63          	blez	a2,7a4 <memmove+0x28>
 78a:	1602                	sll	a2,a2,0x20
 78c:	9201                	srl	a2,a2,0x20
 78e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 792:	872a                	mv	a4,a0
      *dst++ = *src++;
 794:	0585                	add	a1,a1,1
 796:	0705                	add	a4,a4,1
 798:	fff5c683          	lbu	a3,-1(a1)
 79c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 7a0:	fef71ae3          	bne	a4,a5,794 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 7a4:	6422                	ld	s0,8(sp)
 7a6:	0141                	add	sp,sp,16
 7a8:	8082                	ret
    dst += n;
 7aa:	00c50733          	add	a4,a0,a2
    src += n;
 7ae:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 7b0:	fec05ae3          	blez	a2,7a4 <memmove+0x28>
 7b4:	fff6079b          	addw	a5,a2,-1
 7b8:	1782                	sll	a5,a5,0x20
 7ba:	9381                	srl	a5,a5,0x20
 7bc:	fff7c793          	not	a5,a5
 7c0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 7c2:	15fd                	add	a1,a1,-1
 7c4:	177d                	add	a4,a4,-1
 7c6:	0005c683          	lbu	a3,0(a1)
 7ca:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 7ce:	fee79ae3          	bne	a5,a4,7c2 <memmove+0x46>
 7d2:	bfc9                	j	7a4 <memmove+0x28>

00000000000007d4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 7d4:	1141                	add	sp,sp,-16
 7d6:	e422                	sd	s0,8(sp)
 7d8:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 7da:	ca05                	beqz	a2,80a <memcmp+0x36>
 7dc:	fff6069b          	addw	a3,a2,-1
 7e0:	1682                	sll	a3,a3,0x20
 7e2:	9281                	srl	a3,a3,0x20
 7e4:	0685                	add	a3,a3,1
 7e6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 7e8:	00054783          	lbu	a5,0(a0)
 7ec:	0005c703          	lbu	a4,0(a1)
 7f0:	00e79863          	bne	a5,a4,800 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 7f4:	0505                	add	a0,a0,1
    p2++;
 7f6:	0585                	add	a1,a1,1
  while (n-- > 0) {
 7f8:	fed518e3          	bne	a0,a3,7e8 <memcmp+0x14>
  }
  return 0;
 7fc:	4501                	li	a0,0
 7fe:	a019                	j	804 <memcmp+0x30>
      return *p1 - *p2;
 800:	40e7853b          	subw	a0,a5,a4
}
 804:	6422                	ld	s0,8(sp)
 806:	0141                	add	sp,sp,16
 808:	8082                	ret
  return 0;
 80a:	4501                	li	a0,0
 80c:	bfe5                	j	804 <memcmp+0x30>

000000000000080e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 80e:	1141                	add	sp,sp,-16
 810:	e406                	sd	ra,8(sp)
 812:	e022                	sd	s0,0(sp)
 814:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 816:	00000097          	auipc	ra,0x0
 81a:	f66080e7          	jalr	-154(ra) # 77c <memmove>
}
 81e:	60a2                	ld	ra,8(sp)
 820:	6402                	ld	s0,0(sp)
 822:	0141                	add	sp,sp,16
 824:	8082                	ret

0000000000000826 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 826:	4885                	li	a7,1
 ecall
 828:	00000073          	ecall
 ret
 82c:	8082                	ret

000000000000082e <exit>:
.global exit
exit:
 li a7, SYS_exit
 82e:	4889                	li	a7,2
 ecall
 830:	00000073          	ecall
 ret
 834:	8082                	ret

0000000000000836 <wait>:
.global wait
wait:
 li a7, SYS_wait
 836:	488d                	li	a7,3
 ecall
 838:	00000073          	ecall
 ret
 83c:	8082                	ret

000000000000083e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 83e:	4891                	li	a7,4
 ecall
 840:	00000073          	ecall
 ret
 844:	8082                	ret

0000000000000846 <read>:
.global read
read:
 li a7, SYS_read
 846:	4895                	li	a7,5
 ecall
 848:	00000073          	ecall
 ret
 84c:	8082                	ret

000000000000084e <write>:
.global write
write:
 li a7, SYS_write
 84e:	48c1                	li	a7,16
 ecall
 850:	00000073          	ecall
 ret
 854:	8082                	ret

0000000000000856 <close>:
.global close
close:
 li a7, SYS_close
 856:	48d5                	li	a7,21
 ecall
 858:	00000073          	ecall
 ret
 85c:	8082                	ret

000000000000085e <kill>:
.global kill
kill:
 li a7, SYS_kill
 85e:	4899                	li	a7,6
 ecall
 860:	00000073          	ecall
 ret
 864:	8082                	ret

0000000000000866 <exec>:
.global exec
exec:
 li a7, SYS_exec
 866:	489d                	li	a7,7
 ecall
 868:	00000073          	ecall
 ret
 86c:	8082                	ret

000000000000086e <open>:
.global open
open:
 li a7, SYS_open
 86e:	48bd                	li	a7,15
 ecall
 870:	00000073          	ecall
 ret
 874:	8082                	ret

0000000000000876 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 876:	48c5                	li	a7,17
 ecall
 878:	00000073          	ecall
 ret
 87c:	8082                	ret

000000000000087e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 87e:	48c9                	li	a7,18
 ecall
 880:	00000073          	ecall
 ret
 884:	8082                	ret

0000000000000886 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 886:	48a1                	li	a7,8
 ecall
 888:	00000073          	ecall
 ret
 88c:	8082                	ret

000000000000088e <link>:
.global link
link:
 li a7, SYS_link
 88e:	48cd                	li	a7,19
 ecall
 890:	00000073          	ecall
 ret
 894:	8082                	ret

0000000000000896 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 896:	48d1                	li	a7,20
 ecall
 898:	00000073          	ecall
 ret
 89c:	8082                	ret

000000000000089e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 89e:	48a5                	li	a7,9
 ecall
 8a0:	00000073          	ecall
 ret
 8a4:	8082                	ret

00000000000008a6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 8a6:	48a9                	li	a7,10
 ecall
 8a8:	00000073          	ecall
 ret
 8ac:	8082                	ret

00000000000008ae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 8ae:	48ad                	li	a7,11
 ecall
 8b0:	00000073          	ecall
 ret
 8b4:	8082                	ret

00000000000008b6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 8b6:	48b1                	li	a7,12
 ecall
 8b8:	00000073          	ecall
 ret
 8bc:	8082                	ret

00000000000008be <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 8be:	48b5                	li	a7,13
 ecall
 8c0:	00000073          	ecall
 ret
 8c4:	8082                	ret

00000000000008c6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 8c6:	48b9                	li	a7,14
 ecall
 8c8:	00000073          	ecall
 ret
 8cc:	8082                	ret

00000000000008ce <ps>:
.global ps
ps:
 li a7, SYS_ps
 8ce:	48d9                	li	a7,22
 ecall
 8d0:	00000073          	ecall
 ret
 8d4:	8082                	ret

00000000000008d6 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 8d6:	48dd                	li	a7,23
 ecall
 8d8:	00000073          	ecall
 ret
 8dc:	8082                	ret

00000000000008de <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 8de:	48e1                	li	a7,24
 ecall
 8e0:	00000073          	ecall
 ret
 8e4:	8082                	ret

00000000000008e6 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 8e6:	48e9                	li	a7,26
 ecall
 8e8:	00000073          	ecall
 ret
 8ec:	8082                	ret

00000000000008ee <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 8ee:	48e5                	li	a7,25
 ecall
 8f0:	00000073          	ecall
 ret
 8f4:	8082                	ret

00000000000008f6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 8f6:	1101                	add	sp,sp,-32
 8f8:	ec06                	sd	ra,24(sp)
 8fa:	e822                	sd	s0,16(sp)
 8fc:	1000                	add	s0,sp,32
 8fe:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 902:	4605                	li	a2,1
 904:	fef40593          	add	a1,s0,-17
 908:	00000097          	auipc	ra,0x0
 90c:	f46080e7          	jalr	-186(ra) # 84e <write>
}
 910:	60e2                	ld	ra,24(sp)
 912:	6442                	ld	s0,16(sp)
 914:	6105                	add	sp,sp,32
 916:	8082                	ret

0000000000000918 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 918:	7139                	add	sp,sp,-64
 91a:	fc06                	sd	ra,56(sp)
 91c:	f822                	sd	s0,48(sp)
 91e:	f426                	sd	s1,40(sp)
 920:	0080                	add	s0,sp,64
 922:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 924:	c299                	beqz	a3,92a <printint+0x12>
 926:	0805cb63          	bltz	a1,9bc <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 92a:	2581                	sext.w	a1,a1
  neg = 0;
 92c:	4881                	li	a7,0
 92e:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 932:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 934:	2601                	sext.w	a2,a2
 936:	00001517          	auipc	a0,0x1
 93a:	83250513          	add	a0,a0,-1998 # 1168 <digits>
 93e:	883a                	mv	a6,a4
 940:	2705                	addw	a4,a4,1
 942:	02c5f7bb          	remuw	a5,a1,a2
 946:	1782                	sll	a5,a5,0x20
 948:	9381                	srl	a5,a5,0x20
 94a:	97aa                	add	a5,a5,a0
 94c:	0007c783          	lbu	a5,0(a5)
 950:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 954:	0005879b          	sext.w	a5,a1
 958:	02c5d5bb          	divuw	a1,a1,a2
 95c:	0685                	add	a3,a3,1
 95e:	fec7f0e3          	bgeu	a5,a2,93e <printint+0x26>
  if(neg)
 962:	00088c63          	beqz	a7,97a <printint+0x62>
    buf[i++] = '-';
 966:	fd070793          	add	a5,a4,-48
 96a:	00878733          	add	a4,a5,s0
 96e:	02d00793          	li	a5,45
 972:	fef70823          	sb	a5,-16(a4)
 976:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 97a:	02e05c63          	blez	a4,9b2 <printint+0x9a>
 97e:	f04a                	sd	s2,32(sp)
 980:	ec4e                	sd	s3,24(sp)
 982:	fc040793          	add	a5,s0,-64
 986:	00e78933          	add	s2,a5,a4
 98a:	fff78993          	add	s3,a5,-1
 98e:	99ba                	add	s3,s3,a4
 990:	377d                	addw	a4,a4,-1
 992:	1702                	sll	a4,a4,0x20
 994:	9301                	srl	a4,a4,0x20
 996:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 99a:	fff94583          	lbu	a1,-1(s2)
 99e:	8526                	mv	a0,s1
 9a0:	00000097          	auipc	ra,0x0
 9a4:	f56080e7          	jalr	-170(ra) # 8f6 <putc>
  while(--i >= 0)
 9a8:	197d                	add	s2,s2,-1
 9aa:	ff3918e3          	bne	s2,s3,99a <printint+0x82>
 9ae:	7902                	ld	s2,32(sp)
 9b0:	69e2                	ld	s3,24(sp)
}
 9b2:	70e2                	ld	ra,56(sp)
 9b4:	7442                	ld	s0,48(sp)
 9b6:	74a2                	ld	s1,40(sp)
 9b8:	6121                	add	sp,sp,64
 9ba:	8082                	ret
    x = -xx;
 9bc:	40b005bb          	negw	a1,a1
    neg = 1;
 9c0:	4885                	li	a7,1
    x = -xx;
 9c2:	b7b5                	j	92e <printint+0x16>

00000000000009c4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 9c4:	715d                	add	sp,sp,-80
 9c6:	e486                	sd	ra,72(sp)
 9c8:	e0a2                	sd	s0,64(sp)
 9ca:	f84a                	sd	s2,48(sp)
 9cc:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 9ce:	0005c903          	lbu	s2,0(a1)
 9d2:	1a090a63          	beqz	s2,b86 <vprintf+0x1c2>
 9d6:	fc26                	sd	s1,56(sp)
 9d8:	f44e                	sd	s3,40(sp)
 9da:	f052                	sd	s4,32(sp)
 9dc:	ec56                	sd	s5,24(sp)
 9de:	e85a                	sd	s6,16(sp)
 9e0:	e45e                	sd	s7,8(sp)
 9e2:	8aaa                	mv	s5,a0
 9e4:	8bb2                	mv	s7,a2
 9e6:	00158493          	add	s1,a1,1
  state = 0;
 9ea:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 9ec:	02500a13          	li	s4,37
 9f0:	4b55                	li	s6,21
 9f2:	a839                	j	a10 <vprintf+0x4c>
        putc(fd, c);
 9f4:	85ca                	mv	a1,s2
 9f6:	8556                	mv	a0,s5
 9f8:	00000097          	auipc	ra,0x0
 9fc:	efe080e7          	jalr	-258(ra) # 8f6 <putc>
 a00:	a019                	j	a06 <vprintf+0x42>
    } else if(state == '%'){
 a02:	01498d63          	beq	s3,s4,a1c <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 a06:	0485                	add	s1,s1,1
 a08:	fff4c903          	lbu	s2,-1(s1)
 a0c:	16090763          	beqz	s2,b7a <vprintf+0x1b6>
    if(state == 0){
 a10:	fe0999e3          	bnez	s3,a02 <vprintf+0x3e>
      if(c == '%'){
 a14:	ff4910e3          	bne	s2,s4,9f4 <vprintf+0x30>
        state = '%';
 a18:	89d2                	mv	s3,s4
 a1a:	b7f5                	j	a06 <vprintf+0x42>
      if(c == 'd'){
 a1c:	13490463          	beq	s2,s4,b44 <vprintf+0x180>
 a20:	f9d9079b          	addw	a5,s2,-99
 a24:	0ff7f793          	zext.b	a5,a5
 a28:	12fb6763          	bltu	s6,a5,b56 <vprintf+0x192>
 a2c:	f9d9079b          	addw	a5,s2,-99
 a30:	0ff7f713          	zext.b	a4,a5
 a34:	12eb6163          	bltu	s6,a4,b56 <vprintf+0x192>
 a38:	00271793          	sll	a5,a4,0x2
 a3c:	00000717          	auipc	a4,0x0
 a40:	6d470713          	add	a4,a4,1748 # 1110 <malloc+0x49a>
 a44:	97ba                	add	a5,a5,a4
 a46:	439c                	lw	a5,0(a5)
 a48:	97ba                	add	a5,a5,a4
 a4a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 a4c:	008b8913          	add	s2,s7,8
 a50:	4685                	li	a3,1
 a52:	4629                	li	a2,10
 a54:	000ba583          	lw	a1,0(s7)
 a58:	8556                	mv	a0,s5
 a5a:	00000097          	auipc	ra,0x0
 a5e:	ebe080e7          	jalr	-322(ra) # 918 <printint>
 a62:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 a64:	4981                	li	s3,0
 a66:	b745                	j	a06 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a68:	008b8913          	add	s2,s7,8
 a6c:	4681                	li	a3,0
 a6e:	4629                	li	a2,10
 a70:	000ba583          	lw	a1,0(s7)
 a74:	8556                	mv	a0,s5
 a76:	00000097          	auipc	ra,0x0
 a7a:	ea2080e7          	jalr	-350(ra) # 918 <printint>
 a7e:	8bca                	mv	s7,s2
      state = 0;
 a80:	4981                	li	s3,0
 a82:	b751                	j	a06 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 a84:	008b8913          	add	s2,s7,8
 a88:	4681                	li	a3,0
 a8a:	4641                	li	a2,16
 a8c:	000ba583          	lw	a1,0(s7)
 a90:	8556                	mv	a0,s5
 a92:	00000097          	auipc	ra,0x0
 a96:	e86080e7          	jalr	-378(ra) # 918 <printint>
 a9a:	8bca                	mv	s7,s2
      state = 0;
 a9c:	4981                	li	s3,0
 a9e:	b7a5                	j	a06 <vprintf+0x42>
 aa0:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 aa2:	008b8c13          	add	s8,s7,8
 aa6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 aaa:	03000593          	li	a1,48
 aae:	8556                	mv	a0,s5
 ab0:	00000097          	auipc	ra,0x0
 ab4:	e46080e7          	jalr	-442(ra) # 8f6 <putc>
  putc(fd, 'x');
 ab8:	07800593          	li	a1,120
 abc:	8556                	mv	a0,s5
 abe:	00000097          	auipc	ra,0x0
 ac2:	e38080e7          	jalr	-456(ra) # 8f6 <putc>
 ac6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ac8:	00000b97          	auipc	s7,0x0
 acc:	6a0b8b93          	add	s7,s7,1696 # 1168 <digits>
 ad0:	03c9d793          	srl	a5,s3,0x3c
 ad4:	97de                	add	a5,a5,s7
 ad6:	0007c583          	lbu	a1,0(a5)
 ada:	8556                	mv	a0,s5
 adc:	00000097          	auipc	ra,0x0
 ae0:	e1a080e7          	jalr	-486(ra) # 8f6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 ae4:	0992                	sll	s3,s3,0x4
 ae6:	397d                	addw	s2,s2,-1
 ae8:	fe0914e3          	bnez	s2,ad0 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 aec:	8be2                	mv	s7,s8
      state = 0;
 aee:	4981                	li	s3,0
 af0:	6c02                	ld	s8,0(sp)
 af2:	bf11                	j	a06 <vprintf+0x42>
        s = va_arg(ap, char*);
 af4:	008b8993          	add	s3,s7,8
 af8:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 afc:	02090163          	beqz	s2,b1e <vprintf+0x15a>
        while(*s != 0){
 b00:	00094583          	lbu	a1,0(s2)
 b04:	c9a5                	beqz	a1,b74 <vprintf+0x1b0>
          putc(fd, *s);
 b06:	8556                	mv	a0,s5
 b08:	00000097          	auipc	ra,0x0
 b0c:	dee080e7          	jalr	-530(ra) # 8f6 <putc>
          s++;
 b10:	0905                	add	s2,s2,1
        while(*s != 0){
 b12:	00094583          	lbu	a1,0(s2)
 b16:	f9e5                	bnez	a1,b06 <vprintf+0x142>
        s = va_arg(ap, char*);
 b18:	8bce                	mv	s7,s3
      state = 0;
 b1a:	4981                	li	s3,0
 b1c:	b5ed                	j	a06 <vprintf+0x42>
          s = "(null)";
 b1e:	00000917          	auipc	s2,0x0
 b22:	5ea90913          	add	s2,s2,1514 # 1108 <malloc+0x492>
        while(*s != 0){
 b26:	02800593          	li	a1,40
 b2a:	bff1                	j	b06 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 b2c:	008b8913          	add	s2,s7,8
 b30:	000bc583          	lbu	a1,0(s7)
 b34:	8556                	mv	a0,s5
 b36:	00000097          	auipc	ra,0x0
 b3a:	dc0080e7          	jalr	-576(ra) # 8f6 <putc>
 b3e:	8bca                	mv	s7,s2
      state = 0;
 b40:	4981                	li	s3,0
 b42:	b5d1                	j	a06 <vprintf+0x42>
        putc(fd, c);
 b44:	02500593          	li	a1,37
 b48:	8556                	mv	a0,s5
 b4a:	00000097          	auipc	ra,0x0
 b4e:	dac080e7          	jalr	-596(ra) # 8f6 <putc>
      state = 0;
 b52:	4981                	li	s3,0
 b54:	bd4d                	j	a06 <vprintf+0x42>
        putc(fd, '%');
 b56:	02500593          	li	a1,37
 b5a:	8556                	mv	a0,s5
 b5c:	00000097          	auipc	ra,0x0
 b60:	d9a080e7          	jalr	-614(ra) # 8f6 <putc>
        putc(fd, c);
 b64:	85ca                	mv	a1,s2
 b66:	8556                	mv	a0,s5
 b68:	00000097          	auipc	ra,0x0
 b6c:	d8e080e7          	jalr	-626(ra) # 8f6 <putc>
      state = 0;
 b70:	4981                	li	s3,0
 b72:	bd51                	j	a06 <vprintf+0x42>
        s = va_arg(ap, char*);
 b74:	8bce                	mv	s7,s3
      state = 0;
 b76:	4981                	li	s3,0
 b78:	b579                	j	a06 <vprintf+0x42>
 b7a:	74e2                	ld	s1,56(sp)
 b7c:	79a2                	ld	s3,40(sp)
 b7e:	7a02                	ld	s4,32(sp)
 b80:	6ae2                	ld	s5,24(sp)
 b82:	6b42                	ld	s6,16(sp)
 b84:	6ba2                	ld	s7,8(sp)
    }
  }
}
 b86:	60a6                	ld	ra,72(sp)
 b88:	6406                	ld	s0,64(sp)
 b8a:	7942                	ld	s2,48(sp)
 b8c:	6161                	add	sp,sp,80
 b8e:	8082                	ret

0000000000000b90 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b90:	715d                	add	sp,sp,-80
 b92:	ec06                	sd	ra,24(sp)
 b94:	e822                	sd	s0,16(sp)
 b96:	1000                	add	s0,sp,32
 b98:	e010                	sd	a2,0(s0)
 b9a:	e414                	sd	a3,8(s0)
 b9c:	e818                	sd	a4,16(s0)
 b9e:	ec1c                	sd	a5,24(s0)
 ba0:	03043023          	sd	a6,32(s0)
 ba4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 ba8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 bac:	8622                	mv	a2,s0
 bae:	00000097          	auipc	ra,0x0
 bb2:	e16080e7          	jalr	-490(ra) # 9c4 <vprintf>
}
 bb6:	60e2                	ld	ra,24(sp)
 bb8:	6442                	ld	s0,16(sp)
 bba:	6161                	add	sp,sp,80
 bbc:	8082                	ret

0000000000000bbe <printf>:

void
printf(const char *fmt, ...)
{
 bbe:	711d                	add	sp,sp,-96
 bc0:	ec06                	sd	ra,24(sp)
 bc2:	e822                	sd	s0,16(sp)
 bc4:	1000                	add	s0,sp,32
 bc6:	e40c                	sd	a1,8(s0)
 bc8:	e810                	sd	a2,16(s0)
 bca:	ec14                	sd	a3,24(s0)
 bcc:	f018                	sd	a4,32(s0)
 bce:	f41c                	sd	a5,40(s0)
 bd0:	03043823          	sd	a6,48(s0)
 bd4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 bd8:	00840613          	add	a2,s0,8
 bdc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 be0:	85aa                	mv	a1,a0
 be2:	4505                	li	a0,1
 be4:	00000097          	auipc	ra,0x0
 be8:	de0080e7          	jalr	-544(ra) # 9c4 <vprintf>
}
 bec:	60e2                	ld	ra,24(sp)
 bee:	6442                	ld	s0,16(sp)
 bf0:	6125                	add	sp,sp,96
 bf2:	8082                	ret

0000000000000bf4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 bf4:	1141                	add	sp,sp,-16
 bf6:	e422                	sd	s0,8(sp)
 bf8:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 bfa:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bfe:	00001797          	auipc	a5,0x1
 c02:	40a7b783          	ld	a5,1034(a5) # 2008 <freep>
 c06:	a02d                	j	c30 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 c08:	4618                	lw	a4,8(a2)
 c0a:	9f2d                	addw	a4,a4,a1
 c0c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 c10:	6398                	ld	a4,0(a5)
 c12:	6310                	ld	a2,0(a4)
 c14:	a83d                	j	c52 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 c16:	ff852703          	lw	a4,-8(a0)
 c1a:	9f31                	addw	a4,a4,a2
 c1c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 c1e:	ff053683          	ld	a3,-16(a0)
 c22:	a091                	j	c66 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c24:	6398                	ld	a4,0(a5)
 c26:	00e7e463          	bltu	a5,a4,c2e <free+0x3a>
 c2a:	00e6ea63          	bltu	a3,a4,c3e <free+0x4a>
{
 c2e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c30:	fed7fae3          	bgeu	a5,a3,c24 <free+0x30>
 c34:	6398                	ld	a4,0(a5)
 c36:	00e6e463          	bltu	a3,a4,c3e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c3a:	fee7eae3          	bltu	a5,a4,c2e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 c3e:	ff852583          	lw	a1,-8(a0)
 c42:	6390                	ld	a2,0(a5)
 c44:	02059813          	sll	a6,a1,0x20
 c48:	01c85713          	srl	a4,a6,0x1c
 c4c:	9736                	add	a4,a4,a3
 c4e:	fae60de3          	beq	a2,a4,c08 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 c52:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 c56:	4790                	lw	a2,8(a5)
 c58:	02061593          	sll	a1,a2,0x20
 c5c:	01c5d713          	srl	a4,a1,0x1c
 c60:	973e                	add	a4,a4,a5
 c62:	fae68ae3          	beq	a3,a4,c16 <free+0x22>
    p->s.ptr = bp->s.ptr;
 c66:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 c68:	00001717          	auipc	a4,0x1
 c6c:	3af73023          	sd	a5,928(a4) # 2008 <freep>
}
 c70:	6422                	ld	s0,8(sp)
 c72:	0141                	add	sp,sp,16
 c74:	8082                	ret

0000000000000c76 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 c76:	7139                	add	sp,sp,-64
 c78:	fc06                	sd	ra,56(sp)
 c7a:	f822                	sd	s0,48(sp)
 c7c:	f426                	sd	s1,40(sp)
 c7e:	ec4e                	sd	s3,24(sp)
 c80:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c82:	02051493          	sll	s1,a0,0x20
 c86:	9081                	srl	s1,s1,0x20
 c88:	04bd                	add	s1,s1,15
 c8a:	8091                	srl	s1,s1,0x4
 c8c:	0014899b          	addw	s3,s1,1
 c90:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 c92:	00001517          	auipc	a0,0x1
 c96:	37653503          	ld	a0,886(a0) # 2008 <freep>
 c9a:	c915                	beqz	a0,cce <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c9c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c9e:	4798                	lw	a4,8(a5)
 ca0:	08977e63          	bgeu	a4,s1,d3c <malloc+0xc6>
 ca4:	f04a                	sd	s2,32(sp)
 ca6:	e852                	sd	s4,16(sp)
 ca8:	e456                	sd	s5,8(sp)
 caa:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 cac:	8a4e                	mv	s4,s3
 cae:	0009871b          	sext.w	a4,s3
 cb2:	6685                	lui	a3,0x1
 cb4:	00d77363          	bgeu	a4,a3,cba <malloc+0x44>
 cb8:	6a05                	lui	s4,0x1
 cba:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 cbe:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 cc2:	00001917          	auipc	s2,0x1
 cc6:	34690913          	add	s2,s2,838 # 2008 <freep>
  if(p == (char*)-1)
 cca:	5afd                	li	s5,-1
 ccc:	a091                	j	d10 <malloc+0x9a>
 cce:	f04a                	sd	s2,32(sp)
 cd0:	e852                	sd	s4,16(sp)
 cd2:	e456                	sd	s5,8(sp)
 cd4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 cd6:	04001797          	auipc	a5,0x4001
 cda:	33a78793          	add	a5,a5,826 # 4002010 <base>
 cde:	00001717          	auipc	a4,0x1
 ce2:	32f73523          	sd	a5,810(a4) # 2008 <freep>
 ce6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ce8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 cec:	b7c1                	j	cac <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 cee:	6398                	ld	a4,0(a5)
 cf0:	e118                	sd	a4,0(a0)
 cf2:	a08d                	j	d54 <malloc+0xde>
  hp->s.size = nu;
 cf4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 cf8:	0541                	add	a0,a0,16
 cfa:	00000097          	auipc	ra,0x0
 cfe:	efa080e7          	jalr	-262(ra) # bf4 <free>
  return freep;
 d02:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 d06:	c13d                	beqz	a0,d6c <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d08:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d0a:	4798                	lw	a4,8(a5)
 d0c:	02977463          	bgeu	a4,s1,d34 <malloc+0xbe>
    if(p == freep)
 d10:	00093703          	ld	a4,0(s2)
 d14:	853e                	mv	a0,a5
 d16:	fef719e3          	bne	a4,a5,d08 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 d1a:	8552                	mv	a0,s4
 d1c:	00000097          	auipc	ra,0x0
 d20:	b9a080e7          	jalr	-1126(ra) # 8b6 <sbrk>
  if(p == (char*)-1)
 d24:	fd5518e3          	bne	a0,s5,cf4 <malloc+0x7e>
        return 0;
 d28:	4501                	li	a0,0
 d2a:	7902                	ld	s2,32(sp)
 d2c:	6a42                	ld	s4,16(sp)
 d2e:	6aa2                	ld	s5,8(sp)
 d30:	6b02                	ld	s6,0(sp)
 d32:	a03d                	j	d60 <malloc+0xea>
 d34:	7902                	ld	s2,32(sp)
 d36:	6a42                	ld	s4,16(sp)
 d38:	6aa2                	ld	s5,8(sp)
 d3a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 d3c:	fae489e3          	beq	s1,a4,cee <malloc+0x78>
        p->s.size -= nunits;
 d40:	4137073b          	subw	a4,a4,s3
 d44:	c798                	sw	a4,8(a5)
        p += p->s.size;
 d46:	02071693          	sll	a3,a4,0x20
 d4a:	01c6d713          	srl	a4,a3,0x1c
 d4e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 d50:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 d54:	00001717          	auipc	a4,0x1
 d58:	2aa73a23          	sd	a0,692(a4) # 2008 <freep>
      return (void*)(p + 1);
 d5c:	01078513          	add	a0,a5,16
  }
}
 d60:	70e2                	ld	ra,56(sp)
 d62:	7442                	ld	s0,48(sp)
 d64:	74a2                	ld	s1,40(sp)
 d66:	69e2                	ld	s3,24(sp)
 d68:	6121                	add	sp,sp,64
 d6a:	8082                	ret
 d6c:	7902                	ld	s2,32(sp)
 d6e:	6a42                	ld	s4,16(sp)
 d70:	6aa2                	ld	s5,8(sp)
 d72:	6b02                	ld	s6,0(sp)
 d74:	b7f5                	j	d60 <malloc+0xea>
