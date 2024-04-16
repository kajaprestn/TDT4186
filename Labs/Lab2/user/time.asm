
user/_time:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	add	s0,sp,32
    if (argc < 2)
   8:	4785                	li	a5,1
   a:	02a7dd63          	bge	a5,a0,44 <main+0x44>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	84ae                	mv	s1,a1
        printf("Time took 0 ticks\n");
        printf("Usage: time [exec] [arg1 arg2 ...]\n");
        exit(1);
    }

    int startticks = uptime();
  14:	00000097          	auipc	ra,0x0
  18:	3c2080e7          	jalr	962(ra) # 3d6 <uptime>
  1c:	892a                	mv	s2,a0

    // we now start the program in a separate process:
    int uutPid = fork();
  1e:	00000097          	auipc	ra,0x0
  22:	318080e7          	jalr	792(ra) # 336 <fork>

    // check if fork worked:
    if (uutPid < 0)
  26:	04054663          	bltz	a0,72 <main+0x72>
    {
        printf("fork failed... couldn't start %s", argv[1]);
        exit(1);
    }

    if (uutPid == 0)
  2a:	e135                	bnez	a0,8e <main+0x8e>
    {
        // we are the unit under test part of the program - execute the program immediately
        exec(argv[1], argv + 1); // pass rest of the command line to the executable as args
  2c:	00848593          	add	a1,s1,8
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	344080e7          	jalr	836(ra) # 376 <exec>
        // wait for the uut to finish
        wait(0);
        int endticks = uptime();
        printf("Executing %s took %d ticks\n", argv[1], endticks - startticks);
    }
    exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	302080e7          	jalr	770(ra) # 33e <exit>
  44:	e426                	sd	s1,8(sp)
  46:	e04a                	sd	s2,0(sp)
        printf("Time took 0 ticks\n");
  48:	00001517          	auipc	a0,0x1
  4c:	83850513          	add	a0,a0,-1992 # 880 <malloc+0x102>
  50:	00000097          	auipc	ra,0x0
  54:	676080e7          	jalr	1654(ra) # 6c6 <printf>
        printf("Usage: time [exec] [arg1 arg2 ...]\n");
  58:	00001517          	auipc	a0,0x1
  5c:	84050513          	add	a0,a0,-1984 # 898 <malloc+0x11a>
  60:	00000097          	auipc	ra,0x0
  64:	666080e7          	jalr	1638(ra) # 6c6 <printf>
        exit(1);
  68:	4505                	li	a0,1
  6a:	00000097          	auipc	ra,0x0
  6e:	2d4080e7          	jalr	724(ra) # 33e <exit>
        printf("fork failed... couldn't start %s", argv[1]);
  72:	648c                	ld	a1,8(s1)
  74:	00001517          	auipc	a0,0x1
  78:	84c50513          	add	a0,a0,-1972 # 8c0 <malloc+0x142>
  7c:	00000097          	auipc	ra,0x0
  80:	64a080e7          	jalr	1610(ra) # 6c6 <printf>
        exit(1);
  84:	4505                	li	a0,1
  86:	00000097          	auipc	ra,0x0
  8a:	2b8080e7          	jalr	696(ra) # 33e <exit>
        wait(0);
  8e:	4501                	li	a0,0
  90:	00000097          	auipc	ra,0x0
  94:	2b6080e7          	jalr	694(ra) # 346 <wait>
        int endticks = uptime();
  98:	00000097          	auipc	ra,0x0
  9c:	33e080e7          	jalr	830(ra) # 3d6 <uptime>
        printf("Executing %s took %d ticks\n", argv[1], endticks - startticks);
  a0:	4125063b          	subw	a2,a0,s2
  a4:	648c                	ld	a1,8(s1)
  a6:	00001517          	auipc	a0,0x1
  aa:	84250513          	add	a0,a0,-1982 # 8e8 <malloc+0x16a>
  ae:	00000097          	auipc	ra,0x0
  b2:	618080e7          	jalr	1560(ra) # 6c6 <printf>
  b6:	b751                	j	3a <main+0x3a>

00000000000000b8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  b8:	1141                	add	sp,sp,-16
  ba:	e406                	sd	ra,8(sp)
  bc:	e022                	sd	s0,0(sp)
  be:	0800                	add	s0,sp,16
  extern int main();
  main();
  c0:	00000097          	auipc	ra,0x0
  c4:	f40080e7          	jalr	-192(ra) # 0 <main>
  exit(0);
  c8:	4501                	li	a0,0
  ca:	00000097          	auipc	ra,0x0
  ce:	274080e7          	jalr	628(ra) # 33e <exit>

00000000000000d2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d2:	1141                	add	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d8:	87aa                	mv	a5,a0
  da:	0585                	add	a1,a1,1
  dc:	0785                	add	a5,a5,1
  de:	fff5c703          	lbu	a4,-1(a1)
  e2:	fee78fa3          	sb	a4,-1(a5)
  e6:	fb75                	bnez	a4,da <strcpy+0x8>
    ;
  return os;
}
  e8:	6422                	ld	s0,8(sp)
  ea:	0141                	add	sp,sp,16
  ec:	8082                	ret

00000000000000ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ee:	1141                	add	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	cb91                	beqz	a5,10c <strcmp+0x1e>
  fa:	0005c703          	lbu	a4,0(a1)
  fe:	00f71763          	bne	a4,a5,10c <strcmp+0x1e>
    p++, q++;
 102:	0505                	add	a0,a0,1
 104:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 106:	00054783          	lbu	a5,0(a0)
 10a:	fbe5                	bnez	a5,fa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 10c:	0005c503          	lbu	a0,0(a1)
}
 110:	40a7853b          	subw	a0,a5,a0
 114:	6422                	ld	s0,8(sp)
 116:	0141                	add	sp,sp,16
 118:	8082                	ret

000000000000011a <strlen>:

uint
strlen(const char *s)
{
 11a:	1141                	add	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 120:	00054783          	lbu	a5,0(a0)
 124:	cf91                	beqz	a5,140 <strlen+0x26>
 126:	0505                	add	a0,a0,1
 128:	87aa                	mv	a5,a0
 12a:	86be                	mv	a3,a5
 12c:	0785                	add	a5,a5,1
 12e:	fff7c703          	lbu	a4,-1(a5)
 132:	ff65                	bnez	a4,12a <strlen+0x10>
 134:	40a6853b          	subw	a0,a3,a0
 138:	2505                	addw	a0,a0,1
    ;
  return n;
}
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	add	sp,sp,16
 13e:	8082                	ret
  for(n = 0; s[n]; n++)
 140:	4501                	li	a0,0
 142:	bfe5                	j	13a <strlen+0x20>

0000000000000144 <memset>:

void*
memset(void *dst, int c, uint n)
{
 144:	1141                	add	sp,sp,-16
 146:	e422                	sd	s0,8(sp)
 148:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14a:	ca19                	beqz	a2,160 <memset+0x1c>
 14c:	87aa                	mv	a5,a0
 14e:	1602                	sll	a2,a2,0x20
 150:	9201                	srl	a2,a2,0x20
 152:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 156:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15a:	0785                	add	a5,a5,1
 15c:	fee79de3          	bne	a5,a4,156 <memset+0x12>
  }
  return dst;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	add	sp,sp,16
 164:	8082                	ret

0000000000000166 <strchr>:

char*
strchr(const char *s, char c)
{
 166:	1141                	add	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	add	s0,sp,16
  for(; *s; s++)
 16c:	00054783          	lbu	a5,0(a0)
 170:	cb99                	beqz	a5,186 <strchr+0x20>
    if(*s == c)
 172:	00f58763          	beq	a1,a5,180 <strchr+0x1a>
  for(; *s; s++)
 176:	0505                	add	a0,a0,1
 178:	00054783          	lbu	a5,0(a0)
 17c:	fbfd                	bnez	a5,172 <strchr+0xc>
      return (char*)s;
  return 0;
 17e:	4501                	li	a0,0
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	add	sp,sp,16
 184:	8082                	ret
  return 0;
 186:	4501                	li	a0,0
 188:	bfe5                	j	180 <strchr+0x1a>

000000000000018a <gets>:

char*
gets(char *buf, int max)
{
 18a:	711d                	add	sp,sp,-96
 18c:	ec86                	sd	ra,88(sp)
 18e:	e8a2                	sd	s0,80(sp)
 190:	e4a6                	sd	s1,72(sp)
 192:	e0ca                	sd	s2,64(sp)
 194:	fc4e                	sd	s3,56(sp)
 196:	f852                	sd	s4,48(sp)
 198:	f456                	sd	s5,40(sp)
 19a:	f05a                	sd	s6,32(sp)
 19c:	ec5e                	sd	s7,24(sp)
 19e:	1080                	add	s0,sp,96
 1a0:	8baa                	mv	s7,a0
 1a2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a4:	892a                	mv	s2,a0
 1a6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a8:	4aa9                	li	s5,10
 1aa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ac:	89a6                	mv	s3,s1
 1ae:	2485                	addw	s1,s1,1
 1b0:	0344d863          	bge	s1,s4,1e0 <gets+0x56>
    cc = read(0, &c, 1);
 1b4:	4605                	li	a2,1
 1b6:	faf40593          	add	a1,s0,-81
 1ba:	4501                	li	a0,0
 1bc:	00000097          	auipc	ra,0x0
 1c0:	19a080e7          	jalr	410(ra) # 356 <read>
    if(cc < 1)
 1c4:	00a05e63          	blez	a0,1e0 <gets+0x56>
    buf[i++] = c;
 1c8:	faf44783          	lbu	a5,-81(s0)
 1cc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d0:	01578763          	beq	a5,s5,1de <gets+0x54>
 1d4:	0905                	add	s2,s2,1
 1d6:	fd679be3          	bne	a5,s6,1ac <gets+0x22>
    buf[i++] = c;
 1da:	89a6                	mv	s3,s1
 1dc:	a011                	j	1e0 <gets+0x56>
 1de:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e0:	99de                	add	s3,s3,s7
 1e2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e6:	855e                	mv	a0,s7
 1e8:	60e6                	ld	ra,88(sp)
 1ea:	6446                	ld	s0,80(sp)
 1ec:	64a6                	ld	s1,72(sp)
 1ee:	6906                	ld	s2,64(sp)
 1f0:	79e2                	ld	s3,56(sp)
 1f2:	7a42                	ld	s4,48(sp)
 1f4:	7aa2                	ld	s5,40(sp)
 1f6:	7b02                	ld	s6,32(sp)
 1f8:	6be2                	ld	s7,24(sp)
 1fa:	6125                	add	sp,sp,96
 1fc:	8082                	ret

00000000000001fe <stat>:

int
stat(const char *n, struct stat *st)
{
 1fe:	1101                	add	sp,sp,-32
 200:	ec06                	sd	ra,24(sp)
 202:	e822                	sd	s0,16(sp)
 204:	e04a                	sd	s2,0(sp)
 206:	1000                	add	s0,sp,32
 208:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20a:	4581                	li	a1,0
 20c:	00000097          	auipc	ra,0x0
 210:	172080e7          	jalr	370(ra) # 37e <open>
  if(fd < 0)
 214:	02054663          	bltz	a0,240 <stat+0x42>
 218:	e426                	sd	s1,8(sp)
 21a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 21c:	85ca                	mv	a1,s2
 21e:	00000097          	auipc	ra,0x0
 222:	178080e7          	jalr	376(ra) # 396 <fstat>
 226:	892a                	mv	s2,a0
  close(fd);
 228:	8526                	mv	a0,s1
 22a:	00000097          	auipc	ra,0x0
 22e:	13c080e7          	jalr	316(ra) # 366 <close>
  return r;
 232:	64a2                	ld	s1,8(sp)
}
 234:	854a                	mv	a0,s2
 236:	60e2                	ld	ra,24(sp)
 238:	6442                	ld	s0,16(sp)
 23a:	6902                	ld	s2,0(sp)
 23c:	6105                	add	sp,sp,32
 23e:	8082                	ret
    return -1;
 240:	597d                	li	s2,-1
 242:	bfcd                	j	234 <stat+0x36>

0000000000000244 <atoi>:

int
atoi(const char *s)
{
 244:	1141                	add	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24a:	00054683          	lbu	a3,0(a0)
 24e:	fd06879b          	addw	a5,a3,-48
 252:	0ff7f793          	zext.b	a5,a5
 256:	4625                	li	a2,9
 258:	02f66863          	bltu	a2,a5,288 <atoi+0x44>
 25c:	872a                	mv	a4,a0
  n = 0;
 25e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 260:	0705                	add	a4,a4,1
 262:	0025179b          	sllw	a5,a0,0x2
 266:	9fa9                	addw	a5,a5,a0
 268:	0017979b          	sllw	a5,a5,0x1
 26c:	9fb5                	addw	a5,a5,a3
 26e:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 272:	00074683          	lbu	a3,0(a4)
 276:	fd06879b          	addw	a5,a3,-48
 27a:	0ff7f793          	zext.b	a5,a5
 27e:	fef671e3          	bgeu	a2,a5,260 <atoi+0x1c>
  return n;
}
 282:	6422                	ld	s0,8(sp)
 284:	0141                	add	sp,sp,16
 286:	8082                	ret
  n = 0;
 288:	4501                	li	a0,0
 28a:	bfe5                	j	282 <atoi+0x3e>

000000000000028c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28c:	1141                	add	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 292:	02b57463          	bgeu	a0,a1,2ba <memmove+0x2e>
    while(n-- > 0)
 296:	00c05f63          	blez	a2,2b4 <memmove+0x28>
 29a:	1602                	sll	a2,a2,0x20
 29c:	9201                	srl	a2,a2,0x20
 29e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2a2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a4:	0585                	add	a1,a1,1
 2a6:	0705                	add	a4,a4,1
 2a8:	fff5c683          	lbu	a3,-1(a1)
 2ac:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b0:	fef71ae3          	bne	a4,a5,2a4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	add	sp,sp,16
 2b8:	8082                	ret
    dst += n;
 2ba:	00c50733          	add	a4,a0,a2
    src += n;
 2be:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c0:	fec05ae3          	blez	a2,2b4 <memmove+0x28>
 2c4:	fff6079b          	addw	a5,a2,-1
 2c8:	1782                	sll	a5,a5,0x20
 2ca:	9381                	srl	a5,a5,0x20
 2cc:	fff7c793          	not	a5,a5
 2d0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d2:	15fd                	add	a1,a1,-1
 2d4:	177d                	add	a4,a4,-1
 2d6:	0005c683          	lbu	a3,0(a1)
 2da:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2de:	fee79ae3          	bne	a5,a4,2d2 <memmove+0x46>
 2e2:	bfc9                	j	2b4 <memmove+0x28>

00000000000002e4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e4:	1141                	add	sp,sp,-16
 2e6:	e422                	sd	s0,8(sp)
 2e8:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ea:	ca05                	beqz	a2,31a <memcmp+0x36>
 2ec:	fff6069b          	addw	a3,a2,-1
 2f0:	1682                	sll	a3,a3,0x20
 2f2:	9281                	srl	a3,a3,0x20
 2f4:	0685                	add	a3,a3,1
 2f6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	0005c703          	lbu	a4,0(a1)
 300:	00e79863          	bne	a5,a4,310 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 304:	0505                	add	a0,a0,1
    p2++;
 306:	0585                	add	a1,a1,1
  while (n-- > 0) {
 308:	fed518e3          	bne	a0,a3,2f8 <memcmp+0x14>
  }
  return 0;
 30c:	4501                	li	a0,0
 30e:	a019                	j	314 <memcmp+0x30>
      return *p1 - *p2;
 310:	40e7853b          	subw	a0,a5,a4
}
 314:	6422                	ld	s0,8(sp)
 316:	0141                	add	sp,sp,16
 318:	8082                	ret
  return 0;
 31a:	4501                	li	a0,0
 31c:	bfe5                	j	314 <memcmp+0x30>

000000000000031e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 31e:	1141                	add	sp,sp,-16
 320:	e406                	sd	ra,8(sp)
 322:	e022                	sd	s0,0(sp)
 324:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 326:	00000097          	auipc	ra,0x0
 32a:	f66080e7          	jalr	-154(ra) # 28c <memmove>
}
 32e:	60a2                	ld	ra,8(sp)
 330:	6402                	ld	s0,0(sp)
 332:	0141                	add	sp,sp,16
 334:	8082                	ret

0000000000000336 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 336:	4885                	li	a7,1
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <exit>:
.global exit
exit:
 li a7, SYS_exit
 33e:	4889                	li	a7,2
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <wait>:
.global wait
wait:
 li a7, SYS_wait
 346:	488d                	li	a7,3
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 34e:	4891                	li	a7,4
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <read>:
.global read
read:
 li a7, SYS_read
 356:	4895                	li	a7,5
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <write>:
.global write
write:
 li a7, SYS_write
 35e:	48c1                	li	a7,16
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <close>:
.global close
close:
 li a7, SYS_close
 366:	48d5                	li	a7,21
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <kill>:
.global kill
kill:
 li a7, SYS_kill
 36e:	4899                	li	a7,6
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <exec>:
.global exec
exec:
 li a7, SYS_exec
 376:	489d                	li	a7,7
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <open>:
.global open
open:
 li a7, SYS_open
 37e:	48bd                	li	a7,15
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 386:	48c5                	li	a7,17
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 38e:	48c9                	li	a7,18
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 396:	48a1                	li	a7,8
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <link>:
.global link
link:
 li a7, SYS_link
 39e:	48cd                	li	a7,19
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a6:	48d1                	li	a7,20
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ae:	48a5                	li	a7,9
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b6:	48a9                	li	a7,10
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3be:	48ad                	li	a7,11
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3c6:	48b1                	li	a7,12
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ce:	48b5                	li	a7,13
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d6:	48b9                	li	a7,14
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <ps>:
.global ps
ps:
 li a7, SYS_ps
 3de:	48d9                	li	a7,22
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 3e6:	48dd                	li	a7,23
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 3ee:	48e1                	li	a7,24
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <yield>:
.global yield
yield:
 li a7, SYS_yield
 3f6:	48e5                	li	a7,25
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3fe:	1101                	add	sp,sp,-32
 400:	ec06                	sd	ra,24(sp)
 402:	e822                	sd	s0,16(sp)
 404:	1000                	add	s0,sp,32
 406:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 40a:	4605                	li	a2,1
 40c:	fef40593          	add	a1,s0,-17
 410:	00000097          	auipc	ra,0x0
 414:	f4e080e7          	jalr	-178(ra) # 35e <write>
}
 418:	60e2                	ld	ra,24(sp)
 41a:	6442                	ld	s0,16(sp)
 41c:	6105                	add	sp,sp,32
 41e:	8082                	ret

0000000000000420 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 420:	7139                	add	sp,sp,-64
 422:	fc06                	sd	ra,56(sp)
 424:	f822                	sd	s0,48(sp)
 426:	f426                	sd	s1,40(sp)
 428:	0080                	add	s0,sp,64
 42a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 42c:	c299                	beqz	a3,432 <printint+0x12>
 42e:	0805cb63          	bltz	a1,4c4 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 432:	2581                	sext.w	a1,a1
  neg = 0;
 434:	4881                	li	a7,0
 436:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 43a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 43c:	2601                	sext.w	a2,a2
 43e:	00000517          	auipc	a0,0x0
 442:	52a50513          	add	a0,a0,1322 # 968 <digits>
 446:	883a                	mv	a6,a4
 448:	2705                	addw	a4,a4,1
 44a:	02c5f7bb          	remuw	a5,a1,a2
 44e:	1782                	sll	a5,a5,0x20
 450:	9381                	srl	a5,a5,0x20
 452:	97aa                	add	a5,a5,a0
 454:	0007c783          	lbu	a5,0(a5)
 458:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 45c:	0005879b          	sext.w	a5,a1
 460:	02c5d5bb          	divuw	a1,a1,a2
 464:	0685                	add	a3,a3,1
 466:	fec7f0e3          	bgeu	a5,a2,446 <printint+0x26>
  if(neg)
 46a:	00088c63          	beqz	a7,482 <printint+0x62>
    buf[i++] = '-';
 46e:	fd070793          	add	a5,a4,-48
 472:	00878733          	add	a4,a5,s0
 476:	02d00793          	li	a5,45
 47a:	fef70823          	sb	a5,-16(a4)
 47e:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 482:	02e05c63          	blez	a4,4ba <printint+0x9a>
 486:	f04a                	sd	s2,32(sp)
 488:	ec4e                	sd	s3,24(sp)
 48a:	fc040793          	add	a5,s0,-64
 48e:	00e78933          	add	s2,a5,a4
 492:	fff78993          	add	s3,a5,-1
 496:	99ba                	add	s3,s3,a4
 498:	377d                	addw	a4,a4,-1
 49a:	1702                	sll	a4,a4,0x20
 49c:	9301                	srl	a4,a4,0x20
 49e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4a2:	fff94583          	lbu	a1,-1(s2)
 4a6:	8526                	mv	a0,s1
 4a8:	00000097          	auipc	ra,0x0
 4ac:	f56080e7          	jalr	-170(ra) # 3fe <putc>
  while(--i >= 0)
 4b0:	197d                	add	s2,s2,-1
 4b2:	ff3918e3          	bne	s2,s3,4a2 <printint+0x82>
 4b6:	7902                	ld	s2,32(sp)
 4b8:	69e2                	ld	s3,24(sp)
}
 4ba:	70e2                	ld	ra,56(sp)
 4bc:	7442                	ld	s0,48(sp)
 4be:	74a2                	ld	s1,40(sp)
 4c0:	6121                	add	sp,sp,64
 4c2:	8082                	ret
    x = -xx;
 4c4:	40b005bb          	negw	a1,a1
    neg = 1;
 4c8:	4885                	li	a7,1
    x = -xx;
 4ca:	b7b5                	j	436 <printint+0x16>

00000000000004cc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4cc:	715d                	add	sp,sp,-80
 4ce:	e486                	sd	ra,72(sp)
 4d0:	e0a2                	sd	s0,64(sp)
 4d2:	f84a                	sd	s2,48(sp)
 4d4:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4d6:	0005c903          	lbu	s2,0(a1)
 4da:	1a090a63          	beqz	s2,68e <vprintf+0x1c2>
 4de:	fc26                	sd	s1,56(sp)
 4e0:	f44e                	sd	s3,40(sp)
 4e2:	f052                	sd	s4,32(sp)
 4e4:	ec56                	sd	s5,24(sp)
 4e6:	e85a                	sd	s6,16(sp)
 4e8:	e45e                	sd	s7,8(sp)
 4ea:	8aaa                	mv	s5,a0
 4ec:	8bb2                	mv	s7,a2
 4ee:	00158493          	add	s1,a1,1
  state = 0;
 4f2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4f4:	02500a13          	li	s4,37
 4f8:	4b55                	li	s6,21
 4fa:	a839                	j	518 <vprintf+0x4c>
        putc(fd, c);
 4fc:	85ca                	mv	a1,s2
 4fe:	8556                	mv	a0,s5
 500:	00000097          	auipc	ra,0x0
 504:	efe080e7          	jalr	-258(ra) # 3fe <putc>
 508:	a019                	j	50e <vprintf+0x42>
    } else if(state == '%'){
 50a:	01498d63          	beq	s3,s4,524 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 50e:	0485                	add	s1,s1,1
 510:	fff4c903          	lbu	s2,-1(s1)
 514:	16090763          	beqz	s2,682 <vprintf+0x1b6>
    if(state == 0){
 518:	fe0999e3          	bnez	s3,50a <vprintf+0x3e>
      if(c == '%'){
 51c:	ff4910e3          	bne	s2,s4,4fc <vprintf+0x30>
        state = '%';
 520:	89d2                	mv	s3,s4
 522:	b7f5                	j	50e <vprintf+0x42>
      if(c == 'd'){
 524:	13490463          	beq	s2,s4,64c <vprintf+0x180>
 528:	f9d9079b          	addw	a5,s2,-99
 52c:	0ff7f793          	zext.b	a5,a5
 530:	12fb6763          	bltu	s6,a5,65e <vprintf+0x192>
 534:	f9d9079b          	addw	a5,s2,-99
 538:	0ff7f713          	zext.b	a4,a5
 53c:	12eb6163          	bltu	s6,a4,65e <vprintf+0x192>
 540:	00271793          	sll	a5,a4,0x2
 544:	00000717          	auipc	a4,0x0
 548:	3cc70713          	add	a4,a4,972 # 910 <malloc+0x192>
 54c:	97ba                	add	a5,a5,a4
 54e:	439c                	lw	a5,0(a5)
 550:	97ba                	add	a5,a5,a4
 552:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 554:	008b8913          	add	s2,s7,8
 558:	4685                	li	a3,1
 55a:	4629                	li	a2,10
 55c:	000ba583          	lw	a1,0(s7)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	ebe080e7          	jalr	-322(ra) # 420 <printint>
 56a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b745                	j	50e <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 570:	008b8913          	add	s2,s7,8
 574:	4681                	li	a3,0
 576:	4629                	li	a2,10
 578:	000ba583          	lw	a1,0(s7)
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	ea2080e7          	jalr	-350(ra) # 420 <printint>
 586:	8bca                	mv	s7,s2
      state = 0;
 588:	4981                	li	s3,0
 58a:	b751                	j	50e <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 58c:	008b8913          	add	s2,s7,8
 590:	4681                	li	a3,0
 592:	4641                	li	a2,16
 594:	000ba583          	lw	a1,0(s7)
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	e86080e7          	jalr	-378(ra) # 420 <printint>
 5a2:	8bca                	mv	s7,s2
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	b7a5                	j	50e <vprintf+0x42>
 5a8:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5aa:	008b8c13          	add	s8,s7,8
 5ae:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5b2:	03000593          	li	a1,48
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	e46080e7          	jalr	-442(ra) # 3fe <putc>
  putc(fd, 'x');
 5c0:	07800593          	li	a1,120
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	e38080e7          	jalr	-456(ra) # 3fe <putc>
 5ce:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d0:	00000b97          	auipc	s7,0x0
 5d4:	398b8b93          	add	s7,s7,920 # 968 <digits>
 5d8:	03c9d793          	srl	a5,s3,0x3c
 5dc:	97de                	add	a5,a5,s7
 5de:	0007c583          	lbu	a1,0(a5)
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	e1a080e7          	jalr	-486(ra) # 3fe <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5ec:	0992                	sll	s3,s3,0x4
 5ee:	397d                	addw	s2,s2,-1
 5f0:	fe0914e3          	bnez	s2,5d8 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5f4:	8be2                	mv	s7,s8
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	6c02                	ld	s8,0(sp)
 5fa:	bf11                	j	50e <vprintf+0x42>
        s = va_arg(ap, char*);
 5fc:	008b8993          	add	s3,s7,8
 600:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 604:	02090163          	beqz	s2,626 <vprintf+0x15a>
        while(*s != 0){
 608:	00094583          	lbu	a1,0(s2)
 60c:	c9a5                	beqz	a1,67c <vprintf+0x1b0>
          putc(fd, *s);
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	dee080e7          	jalr	-530(ra) # 3fe <putc>
          s++;
 618:	0905                	add	s2,s2,1
        while(*s != 0){
 61a:	00094583          	lbu	a1,0(s2)
 61e:	f9e5                	bnez	a1,60e <vprintf+0x142>
        s = va_arg(ap, char*);
 620:	8bce                	mv	s7,s3
      state = 0;
 622:	4981                	li	s3,0
 624:	b5ed                	j	50e <vprintf+0x42>
          s = "(null)";
 626:	00000917          	auipc	s2,0x0
 62a:	2e290913          	add	s2,s2,738 # 908 <malloc+0x18a>
        while(*s != 0){
 62e:	02800593          	li	a1,40
 632:	bff1                	j	60e <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 634:	008b8913          	add	s2,s7,8
 638:	000bc583          	lbu	a1,0(s7)
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	dc0080e7          	jalr	-576(ra) # 3fe <putc>
 646:	8bca                	mv	s7,s2
      state = 0;
 648:	4981                	li	s3,0
 64a:	b5d1                	j	50e <vprintf+0x42>
        putc(fd, c);
 64c:	02500593          	li	a1,37
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	dac080e7          	jalr	-596(ra) # 3fe <putc>
      state = 0;
 65a:	4981                	li	s3,0
 65c:	bd4d                	j	50e <vprintf+0x42>
        putc(fd, '%');
 65e:	02500593          	li	a1,37
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	d9a080e7          	jalr	-614(ra) # 3fe <putc>
        putc(fd, c);
 66c:	85ca                	mv	a1,s2
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	d8e080e7          	jalr	-626(ra) # 3fe <putc>
      state = 0;
 678:	4981                	li	s3,0
 67a:	bd51                	j	50e <vprintf+0x42>
        s = va_arg(ap, char*);
 67c:	8bce                	mv	s7,s3
      state = 0;
 67e:	4981                	li	s3,0
 680:	b579                	j	50e <vprintf+0x42>
 682:	74e2                	ld	s1,56(sp)
 684:	79a2                	ld	s3,40(sp)
 686:	7a02                	ld	s4,32(sp)
 688:	6ae2                	ld	s5,24(sp)
 68a:	6b42                	ld	s6,16(sp)
 68c:	6ba2                	ld	s7,8(sp)
    }
  }
}
 68e:	60a6                	ld	ra,72(sp)
 690:	6406                	ld	s0,64(sp)
 692:	7942                	ld	s2,48(sp)
 694:	6161                	add	sp,sp,80
 696:	8082                	ret

0000000000000698 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 698:	715d                	add	sp,sp,-80
 69a:	ec06                	sd	ra,24(sp)
 69c:	e822                	sd	s0,16(sp)
 69e:	1000                	add	s0,sp,32
 6a0:	e010                	sd	a2,0(s0)
 6a2:	e414                	sd	a3,8(s0)
 6a4:	e818                	sd	a4,16(s0)
 6a6:	ec1c                	sd	a5,24(s0)
 6a8:	03043023          	sd	a6,32(s0)
 6ac:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6b0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6b4:	8622                	mv	a2,s0
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e16080e7          	jalr	-490(ra) # 4cc <vprintf>
}
 6be:	60e2                	ld	ra,24(sp)
 6c0:	6442                	ld	s0,16(sp)
 6c2:	6161                	add	sp,sp,80
 6c4:	8082                	ret

00000000000006c6 <printf>:

void
printf(const char *fmt, ...)
{
 6c6:	711d                	add	sp,sp,-96
 6c8:	ec06                	sd	ra,24(sp)
 6ca:	e822                	sd	s0,16(sp)
 6cc:	1000                	add	s0,sp,32
 6ce:	e40c                	sd	a1,8(s0)
 6d0:	e810                	sd	a2,16(s0)
 6d2:	ec14                	sd	a3,24(s0)
 6d4:	f018                	sd	a4,32(s0)
 6d6:	f41c                	sd	a5,40(s0)
 6d8:	03043823          	sd	a6,48(s0)
 6dc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6e0:	00840613          	add	a2,s0,8
 6e4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6e8:	85aa                	mv	a1,a0
 6ea:	4505                	li	a0,1
 6ec:	00000097          	auipc	ra,0x0
 6f0:	de0080e7          	jalr	-544(ra) # 4cc <vprintf>
}
 6f4:	60e2                	ld	ra,24(sp)
 6f6:	6442                	ld	s0,16(sp)
 6f8:	6125                	add	sp,sp,96
 6fa:	8082                	ret

00000000000006fc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6fc:	1141                	add	sp,sp,-16
 6fe:	e422                	sd	s0,8(sp)
 700:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 702:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 706:	00001797          	auipc	a5,0x1
 70a:	8fa7b783          	ld	a5,-1798(a5) # 1000 <freep>
 70e:	a02d                	j	738 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 710:	4618                	lw	a4,8(a2)
 712:	9f2d                	addw	a4,a4,a1
 714:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 718:	6398                	ld	a4,0(a5)
 71a:	6310                	ld	a2,0(a4)
 71c:	a83d                	j	75a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 71e:	ff852703          	lw	a4,-8(a0)
 722:	9f31                	addw	a4,a4,a2
 724:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 726:	ff053683          	ld	a3,-16(a0)
 72a:	a091                	j	76e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 72c:	6398                	ld	a4,0(a5)
 72e:	00e7e463          	bltu	a5,a4,736 <free+0x3a>
 732:	00e6ea63          	bltu	a3,a4,746 <free+0x4a>
{
 736:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 738:	fed7fae3          	bgeu	a5,a3,72c <free+0x30>
 73c:	6398                	ld	a4,0(a5)
 73e:	00e6e463          	bltu	a3,a4,746 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 742:	fee7eae3          	bltu	a5,a4,736 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 746:	ff852583          	lw	a1,-8(a0)
 74a:	6390                	ld	a2,0(a5)
 74c:	02059813          	sll	a6,a1,0x20
 750:	01c85713          	srl	a4,a6,0x1c
 754:	9736                	add	a4,a4,a3
 756:	fae60de3          	beq	a2,a4,710 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 75a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 75e:	4790                	lw	a2,8(a5)
 760:	02061593          	sll	a1,a2,0x20
 764:	01c5d713          	srl	a4,a1,0x1c
 768:	973e                	add	a4,a4,a5
 76a:	fae68ae3          	beq	a3,a4,71e <free+0x22>
    p->s.ptr = bp->s.ptr;
 76e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 770:	00001717          	auipc	a4,0x1
 774:	88f73823          	sd	a5,-1904(a4) # 1000 <freep>
}
 778:	6422                	ld	s0,8(sp)
 77a:	0141                	add	sp,sp,16
 77c:	8082                	ret

000000000000077e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 77e:	7139                	add	sp,sp,-64
 780:	fc06                	sd	ra,56(sp)
 782:	f822                	sd	s0,48(sp)
 784:	f426                	sd	s1,40(sp)
 786:	ec4e                	sd	s3,24(sp)
 788:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 78a:	02051493          	sll	s1,a0,0x20
 78e:	9081                	srl	s1,s1,0x20
 790:	04bd                	add	s1,s1,15
 792:	8091                	srl	s1,s1,0x4
 794:	0014899b          	addw	s3,s1,1
 798:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 79a:	00001517          	auipc	a0,0x1
 79e:	86653503          	ld	a0,-1946(a0) # 1000 <freep>
 7a2:	c915                	beqz	a0,7d6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a6:	4798                	lw	a4,8(a5)
 7a8:	08977e63          	bgeu	a4,s1,844 <malloc+0xc6>
 7ac:	f04a                	sd	s2,32(sp)
 7ae:	e852                	sd	s4,16(sp)
 7b0:	e456                	sd	s5,8(sp)
 7b2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7b4:	8a4e                	mv	s4,s3
 7b6:	0009871b          	sext.w	a4,s3
 7ba:	6685                	lui	a3,0x1
 7bc:	00d77363          	bgeu	a4,a3,7c2 <malloc+0x44>
 7c0:	6a05                	lui	s4,0x1
 7c2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7c6:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7ca:	00001917          	auipc	s2,0x1
 7ce:	83690913          	add	s2,s2,-1994 # 1000 <freep>
  if(p == (char*)-1)
 7d2:	5afd                	li	s5,-1
 7d4:	a091                	j	818 <malloc+0x9a>
 7d6:	f04a                	sd	s2,32(sp)
 7d8:	e852                	sd	s4,16(sp)
 7da:	e456                	sd	s5,8(sp)
 7dc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7de:	00001797          	auipc	a5,0x1
 7e2:	83278793          	add	a5,a5,-1998 # 1010 <base>
 7e6:	00001717          	auipc	a4,0x1
 7ea:	80f73d23          	sd	a5,-2022(a4) # 1000 <freep>
 7ee:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7f0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7f4:	b7c1                	j	7b4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7f6:	6398                	ld	a4,0(a5)
 7f8:	e118                	sd	a4,0(a0)
 7fa:	a08d                	j	85c <malloc+0xde>
  hp->s.size = nu;
 7fc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 800:	0541                	add	a0,a0,16
 802:	00000097          	auipc	ra,0x0
 806:	efa080e7          	jalr	-262(ra) # 6fc <free>
  return freep;
 80a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 80e:	c13d                	beqz	a0,874 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 810:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 812:	4798                	lw	a4,8(a5)
 814:	02977463          	bgeu	a4,s1,83c <malloc+0xbe>
    if(p == freep)
 818:	00093703          	ld	a4,0(s2)
 81c:	853e                	mv	a0,a5
 81e:	fef719e3          	bne	a4,a5,810 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 822:	8552                	mv	a0,s4
 824:	00000097          	auipc	ra,0x0
 828:	ba2080e7          	jalr	-1118(ra) # 3c6 <sbrk>
  if(p == (char*)-1)
 82c:	fd5518e3          	bne	a0,s5,7fc <malloc+0x7e>
        return 0;
 830:	4501                	li	a0,0
 832:	7902                	ld	s2,32(sp)
 834:	6a42                	ld	s4,16(sp)
 836:	6aa2                	ld	s5,8(sp)
 838:	6b02                	ld	s6,0(sp)
 83a:	a03d                	j	868 <malloc+0xea>
 83c:	7902                	ld	s2,32(sp)
 83e:	6a42                	ld	s4,16(sp)
 840:	6aa2                	ld	s5,8(sp)
 842:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 844:	fae489e3          	beq	s1,a4,7f6 <malloc+0x78>
        p->s.size -= nunits;
 848:	4137073b          	subw	a4,a4,s3
 84c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 84e:	02071693          	sll	a3,a4,0x20
 852:	01c6d713          	srl	a4,a3,0x1c
 856:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 858:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 85c:	00000717          	auipc	a4,0x0
 860:	7aa73223          	sd	a0,1956(a4) # 1000 <freep>
      return (void*)(p + 1);
 864:	01078513          	add	a0,a5,16
  }
}
 868:	70e2                	ld	ra,56(sp)
 86a:	7442                	ld	s0,48(sp)
 86c:	74a2                	ld	s1,40(sp)
 86e:	69e2                	ld	s3,24(sp)
 870:	6121                	add	sp,sp,64
 872:	8082                	ret
 874:	7902                	ld	s2,32(sp)
 876:	6a42                	ld	s4,16(sp)
 878:	6aa2                	ld	s5,8(sp)
 87a:	6b02                	ld	s6,0(sp)
 87c:	b7f5                	j	868 <malloc+0xea>
