
user/_vatopa:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user.h"
#include "stddef.h"

int main(int argc, char *argv[]) {
   0:	7179                	add	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	add	s0,sp,48
    if (argc != 3 && argc != 2) {
   8:	ffe5071b          	addw	a4,a0,-2
   c:	4785                	li	a5,1
   e:	02e7f263          	bgeu	a5,a4,32 <main+0x32>
  12:	ec26                	sd	s1,24(sp)
  14:	e84a                	sd	s2,16(sp)
  16:	e44e                	sd	s3,8(sp)
        printf("Usage: vatopa virtual_address [pid]\n");
  18:	00001517          	auipc	a0,0x1
  1c:	89850513          	add	a0,a0,-1896 # 8b0 <malloc+0x104>
  20:	00000097          	auipc	ra,0x0
  24:	6d4080e7          	jalr	1748(ra) # 6f4 <printf>
        exit(1);
  28:	4505                	li	a0,1
  2a:	00000097          	auipc	ra,0x0
  2e:	33a080e7          	jalr	826(ra) # 364 <exit>
  32:	ec26                	sd	s1,24(sp)
  34:	e84a                	sd	s2,16(sp)
  36:	e44e                	sd	s3,8(sp)
  38:	84aa                	mv	s1,a0
  3a:	892e                	mv	s2,a1
    }

    uint64 va = atoi(argv[1]);
  3c:	6588                	ld	a0,8(a1)
  3e:	00000097          	auipc	ra,0x0
  42:	22c080e7          	jalr	556(ra) # 26a <atoi>
  46:	89aa                	mv	s3,a0
    uint64 pa = 0;
    int pid = (argc == 3) ? atoi(argv[2]) : getpid(); 
  48:	478d                	li	a5,3
  4a:	04f48463          	beq	s1,a5,92 <main+0x92>
  4e:	00000097          	auipc	ra,0x0
  52:	396080e7          	jalr	918(ra) # 3e4 <getpid>
  56:	84aa                	mv	s1,a0

    pa = va2pa(va, pid);
  58:	85a6                	mv	a1,s1
  5a:	854e                	mv	a0,s3
  5c:	00000097          	auipc	ra,0x0
  60:	3c0080e7          	jalr	960(ra) # 41c <va2pa>

    if (pa == (uint64)-1) {
  64:	57fd                	li	a5,-1
  66:	02f50e63          	beq	a0,a5,a2 <main+0xa2>
        printf("0x%x\n", va);
    } else if (pa == (uint64)-2) {
  6a:	57f9                	li	a5,-2
  6c:	04f50563          	beq	a0,a5,b6 <main+0xb6>
        printf("No process found with PID %d\n", pid);
    } else if (pa == (uint64)-3) {
  70:	57f5                	li	a5,-3
  72:	04f50c63          	beq	a0,a5,ca <main+0xca>
        printf("0x0\n", va);
    } else {
        printf("0x%x\n", pa);
  76:	85aa                	mv	a1,a0
  78:	00001517          	auipc	a0,0x1
  7c:	86050513          	add	a0,a0,-1952 # 8d8 <malloc+0x12c>
  80:	00000097          	auipc	ra,0x0
  84:	674080e7          	jalr	1652(ra) # 6f4 <printf>
    }

    exit(0);
  88:	4501                	li	a0,0
  8a:	00000097          	auipc	ra,0x0
  8e:	2da080e7          	jalr	730(ra) # 364 <exit>
    int pid = (argc == 3) ? atoi(argv[2]) : getpid(); 
  92:	01093503          	ld	a0,16(s2)
  96:	00000097          	auipc	ra,0x0
  9a:	1d4080e7          	jalr	468(ra) # 26a <atoi>
  9e:	84aa                	mv	s1,a0
  a0:	bf65                	j	58 <main+0x58>
        printf("0x%x\n", va);
  a2:	85ce                	mv	a1,s3
  a4:	00001517          	auipc	a0,0x1
  a8:	83450513          	add	a0,a0,-1996 # 8d8 <malloc+0x12c>
  ac:	00000097          	auipc	ra,0x0
  b0:	648080e7          	jalr	1608(ra) # 6f4 <printf>
  b4:	bfd1                	j	88 <main+0x88>
        printf("No process found with PID %d\n", pid);
  b6:	85a6                	mv	a1,s1
  b8:	00001517          	auipc	a0,0x1
  bc:	82850513          	add	a0,a0,-2008 # 8e0 <malloc+0x134>
  c0:	00000097          	auipc	ra,0x0
  c4:	634080e7          	jalr	1588(ra) # 6f4 <printf>
  c8:	b7c1                	j	88 <main+0x88>
        printf("0x0\n", va);
  ca:	85ce                	mv	a1,s3
  cc:	00001517          	auipc	a0,0x1
  d0:	83450513          	add	a0,a0,-1996 # 900 <malloc+0x154>
  d4:	00000097          	auipc	ra,0x0
  d8:	620080e7          	jalr	1568(ra) # 6f4 <printf>
  dc:	b775                	j	88 <main+0x88>

00000000000000de <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  de:	1141                	add	sp,sp,-16
  e0:	e406                	sd	ra,8(sp)
  e2:	e022                	sd	s0,0(sp)
  e4:	0800                	add	s0,sp,16
  extern int main();
  main();
  e6:	00000097          	auipc	ra,0x0
  ea:	f1a080e7          	jalr	-230(ra) # 0 <main>
  exit(0);
  ee:	4501                	li	a0,0
  f0:	00000097          	auipc	ra,0x0
  f4:	274080e7          	jalr	628(ra) # 364 <exit>

00000000000000f8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  f8:	1141                	add	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  fe:	87aa                	mv	a5,a0
 100:	0585                	add	a1,a1,1
 102:	0785                	add	a5,a5,1
 104:	fff5c703          	lbu	a4,-1(a1)
 108:	fee78fa3          	sb	a4,-1(a5)
 10c:	fb75                	bnez	a4,100 <strcpy+0x8>
    ;
  return os;
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	add	sp,sp,16
 112:	8082                	ret

0000000000000114 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 114:	1141                	add	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cb91                	beqz	a5,132 <strcmp+0x1e>
 120:	0005c703          	lbu	a4,0(a1)
 124:	00f71763          	bne	a4,a5,132 <strcmp+0x1e>
    p++, q++;
 128:	0505                	add	a0,a0,1
 12a:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 12c:	00054783          	lbu	a5,0(a0)
 130:	fbe5                	bnez	a5,120 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 132:	0005c503          	lbu	a0,0(a1)
}
 136:	40a7853b          	subw	a0,a5,a0
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	add	sp,sp,16
 13e:	8082                	ret

0000000000000140 <strlen>:

uint
strlen(const char *s)
{
 140:	1141                	add	sp,sp,-16
 142:	e422                	sd	s0,8(sp)
 144:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 146:	00054783          	lbu	a5,0(a0)
 14a:	cf91                	beqz	a5,166 <strlen+0x26>
 14c:	0505                	add	a0,a0,1
 14e:	87aa                	mv	a5,a0
 150:	86be                	mv	a3,a5
 152:	0785                	add	a5,a5,1
 154:	fff7c703          	lbu	a4,-1(a5)
 158:	ff65                	bnez	a4,150 <strlen+0x10>
 15a:	40a6853b          	subw	a0,a3,a0
 15e:	2505                	addw	a0,a0,1
    ;
  return n;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	add	sp,sp,16
 164:	8082                	ret
  for(n = 0; s[n]; n++)
 166:	4501                	li	a0,0
 168:	bfe5                	j	160 <strlen+0x20>

000000000000016a <memset>:

void*
memset(void *dst, int c, uint n)
{
 16a:	1141                	add	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 170:	ca19                	beqz	a2,186 <memset+0x1c>
 172:	87aa                	mv	a5,a0
 174:	1602                	sll	a2,a2,0x20
 176:	9201                	srl	a2,a2,0x20
 178:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 17c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 180:	0785                	add	a5,a5,1
 182:	fee79de3          	bne	a5,a4,17c <memset+0x12>
  }
  return dst;
}
 186:	6422                	ld	s0,8(sp)
 188:	0141                	add	sp,sp,16
 18a:	8082                	ret

000000000000018c <strchr>:

char*
strchr(const char *s, char c)
{
 18c:	1141                	add	sp,sp,-16
 18e:	e422                	sd	s0,8(sp)
 190:	0800                	add	s0,sp,16
  for(; *s; s++)
 192:	00054783          	lbu	a5,0(a0)
 196:	cb99                	beqz	a5,1ac <strchr+0x20>
    if(*s == c)
 198:	00f58763          	beq	a1,a5,1a6 <strchr+0x1a>
  for(; *s; s++)
 19c:	0505                	add	a0,a0,1
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	fbfd                	bnez	a5,198 <strchr+0xc>
      return (char*)s;
  return 0;
 1a4:	4501                	li	a0,0
}
 1a6:	6422                	ld	s0,8(sp)
 1a8:	0141                	add	sp,sp,16
 1aa:	8082                	ret
  return 0;
 1ac:	4501                	li	a0,0
 1ae:	bfe5                	j	1a6 <strchr+0x1a>

00000000000001b0 <gets>:

char*
gets(char *buf, int max)
{
 1b0:	711d                	add	sp,sp,-96
 1b2:	ec86                	sd	ra,88(sp)
 1b4:	e8a2                	sd	s0,80(sp)
 1b6:	e4a6                	sd	s1,72(sp)
 1b8:	e0ca                	sd	s2,64(sp)
 1ba:	fc4e                	sd	s3,56(sp)
 1bc:	f852                	sd	s4,48(sp)
 1be:	f456                	sd	s5,40(sp)
 1c0:	f05a                	sd	s6,32(sp)
 1c2:	ec5e                	sd	s7,24(sp)
 1c4:	1080                	add	s0,sp,96
 1c6:	8baa                	mv	s7,a0
 1c8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ca:	892a                	mv	s2,a0
 1cc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ce:	4aa9                	li	s5,10
 1d0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d2:	89a6                	mv	s3,s1
 1d4:	2485                	addw	s1,s1,1
 1d6:	0344d863          	bge	s1,s4,206 <gets+0x56>
    cc = read(0, &c, 1);
 1da:	4605                	li	a2,1
 1dc:	faf40593          	add	a1,s0,-81
 1e0:	4501                	li	a0,0
 1e2:	00000097          	auipc	ra,0x0
 1e6:	19a080e7          	jalr	410(ra) # 37c <read>
    if(cc < 1)
 1ea:	00a05e63          	blez	a0,206 <gets+0x56>
    buf[i++] = c;
 1ee:	faf44783          	lbu	a5,-81(s0)
 1f2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f6:	01578763          	beq	a5,s5,204 <gets+0x54>
 1fa:	0905                	add	s2,s2,1
 1fc:	fd679be3          	bne	a5,s6,1d2 <gets+0x22>
    buf[i++] = c;
 200:	89a6                	mv	s3,s1
 202:	a011                	j	206 <gets+0x56>
 204:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 206:	99de                	add	s3,s3,s7
 208:	00098023          	sb	zero,0(s3)
  return buf;
}
 20c:	855e                	mv	a0,s7
 20e:	60e6                	ld	ra,88(sp)
 210:	6446                	ld	s0,80(sp)
 212:	64a6                	ld	s1,72(sp)
 214:	6906                	ld	s2,64(sp)
 216:	79e2                	ld	s3,56(sp)
 218:	7a42                	ld	s4,48(sp)
 21a:	7aa2                	ld	s5,40(sp)
 21c:	7b02                	ld	s6,32(sp)
 21e:	6be2                	ld	s7,24(sp)
 220:	6125                	add	sp,sp,96
 222:	8082                	ret

0000000000000224 <stat>:

int
stat(const char *n, struct stat *st)
{
 224:	1101                	add	sp,sp,-32
 226:	ec06                	sd	ra,24(sp)
 228:	e822                	sd	s0,16(sp)
 22a:	e04a                	sd	s2,0(sp)
 22c:	1000                	add	s0,sp,32
 22e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 230:	4581                	li	a1,0
 232:	00000097          	auipc	ra,0x0
 236:	172080e7          	jalr	370(ra) # 3a4 <open>
  if(fd < 0)
 23a:	02054663          	bltz	a0,266 <stat+0x42>
 23e:	e426                	sd	s1,8(sp)
 240:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 242:	85ca                	mv	a1,s2
 244:	00000097          	auipc	ra,0x0
 248:	178080e7          	jalr	376(ra) # 3bc <fstat>
 24c:	892a                	mv	s2,a0
  close(fd);
 24e:	8526                	mv	a0,s1
 250:	00000097          	auipc	ra,0x0
 254:	13c080e7          	jalr	316(ra) # 38c <close>
  return r;
 258:	64a2                	ld	s1,8(sp)
}
 25a:	854a                	mv	a0,s2
 25c:	60e2                	ld	ra,24(sp)
 25e:	6442                	ld	s0,16(sp)
 260:	6902                	ld	s2,0(sp)
 262:	6105                	add	sp,sp,32
 264:	8082                	ret
    return -1;
 266:	597d                	li	s2,-1
 268:	bfcd                	j	25a <stat+0x36>

000000000000026a <atoi>:

int
atoi(const char *s)
{
 26a:	1141                	add	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 270:	00054683          	lbu	a3,0(a0)
 274:	fd06879b          	addw	a5,a3,-48
 278:	0ff7f793          	zext.b	a5,a5
 27c:	4625                	li	a2,9
 27e:	02f66863          	bltu	a2,a5,2ae <atoi+0x44>
 282:	872a                	mv	a4,a0
  n = 0;
 284:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 286:	0705                	add	a4,a4,1
 288:	0025179b          	sllw	a5,a0,0x2
 28c:	9fa9                	addw	a5,a5,a0
 28e:	0017979b          	sllw	a5,a5,0x1
 292:	9fb5                	addw	a5,a5,a3
 294:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 298:	00074683          	lbu	a3,0(a4)
 29c:	fd06879b          	addw	a5,a3,-48
 2a0:	0ff7f793          	zext.b	a5,a5
 2a4:	fef671e3          	bgeu	a2,a5,286 <atoi+0x1c>
  return n;
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	add	sp,sp,16
 2ac:	8082                	ret
  n = 0;
 2ae:	4501                	li	a0,0
 2b0:	bfe5                	j	2a8 <atoi+0x3e>

00000000000002b2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b2:	1141                	add	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b8:	02b57463          	bgeu	a0,a1,2e0 <memmove+0x2e>
    while(n-- > 0)
 2bc:	00c05f63          	blez	a2,2da <memmove+0x28>
 2c0:	1602                	sll	a2,a2,0x20
 2c2:	9201                	srl	a2,a2,0x20
 2c4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ca:	0585                	add	a1,a1,1
 2cc:	0705                	add	a4,a4,1
 2ce:	fff5c683          	lbu	a3,-1(a1)
 2d2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d6:	fef71ae3          	bne	a4,a5,2ca <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	add	sp,sp,16
 2de:	8082                	ret
    dst += n;
 2e0:	00c50733          	add	a4,a0,a2
    src += n;
 2e4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e6:	fec05ae3          	blez	a2,2da <memmove+0x28>
 2ea:	fff6079b          	addw	a5,a2,-1
 2ee:	1782                	sll	a5,a5,0x20
 2f0:	9381                	srl	a5,a5,0x20
 2f2:	fff7c793          	not	a5,a5
 2f6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f8:	15fd                	add	a1,a1,-1
 2fa:	177d                	add	a4,a4,-1
 2fc:	0005c683          	lbu	a3,0(a1)
 300:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 304:	fee79ae3          	bne	a5,a4,2f8 <memmove+0x46>
 308:	bfc9                	j	2da <memmove+0x28>

000000000000030a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 30a:	1141                	add	sp,sp,-16
 30c:	e422                	sd	s0,8(sp)
 30e:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 310:	ca05                	beqz	a2,340 <memcmp+0x36>
 312:	fff6069b          	addw	a3,a2,-1
 316:	1682                	sll	a3,a3,0x20
 318:	9281                	srl	a3,a3,0x20
 31a:	0685                	add	a3,a3,1
 31c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 31e:	00054783          	lbu	a5,0(a0)
 322:	0005c703          	lbu	a4,0(a1)
 326:	00e79863          	bne	a5,a4,336 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 32a:	0505                	add	a0,a0,1
    p2++;
 32c:	0585                	add	a1,a1,1
  while (n-- > 0) {
 32e:	fed518e3          	bne	a0,a3,31e <memcmp+0x14>
  }
  return 0;
 332:	4501                	li	a0,0
 334:	a019                	j	33a <memcmp+0x30>
      return *p1 - *p2;
 336:	40e7853b          	subw	a0,a5,a4
}
 33a:	6422                	ld	s0,8(sp)
 33c:	0141                	add	sp,sp,16
 33e:	8082                	ret
  return 0;
 340:	4501                	li	a0,0
 342:	bfe5                	j	33a <memcmp+0x30>

0000000000000344 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 344:	1141                	add	sp,sp,-16
 346:	e406                	sd	ra,8(sp)
 348:	e022                	sd	s0,0(sp)
 34a:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 34c:	00000097          	auipc	ra,0x0
 350:	f66080e7          	jalr	-154(ra) # 2b2 <memmove>
}
 354:	60a2                	ld	ra,8(sp)
 356:	6402                	ld	s0,0(sp)
 358:	0141                	add	sp,sp,16
 35a:	8082                	ret

000000000000035c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 35c:	4885                	li	a7,1
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <exit>:
.global exit
exit:
 li a7, SYS_exit
 364:	4889                	li	a7,2
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <wait>:
.global wait
wait:
 li a7, SYS_wait
 36c:	488d                	li	a7,3
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 374:	4891                	li	a7,4
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <read>:
.global read
read:
 li a7, SYS_read
 37c:	4895                	li	a7,5
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <write>:
.global write
write:
 li a7, SYS_write
 384:	48c1                	li	a7,16
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <close>:
.global close
close:
 li a7, SYS_close
 38c:	48d5                	li	a7,21
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <kill>:
.global kill
kill:
 li a7, SYS_kill
 394:	4899                	li	a7,6
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <exec>:
.global exec
exec:
 li a7, SYS_exec
 39c:	489d                	li	a7,7
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <open>:
.global open
open:
 li a7, SYS_open
 3a4:	48bd                	li	a7,15
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ac:	48c5                	li	a7,17
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b4:	48c9                	li	a7,18
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3bc:	48a1                	li	a7,8
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <link>:
.global link
link:
 li a7, SYS_link
 3c4:	48cd                	li	a7,19
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3cc:	48d1                	li	a7,20
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d4:	48a5                	li	a7,9
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3dc:	48a9                	li	a7,10
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e4:	48ad                	li	a7,11
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3ec:	48b1                	li	a7,12
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3f4:	48b5                	li	a7,13
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3fc:	48b9                	li	a7,14
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <ps>:
.global ps
ps:
 li a7, SYS_ps
 404:	48d9                	li	a7,22
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 40c:	48dd                	li	a7,23
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 414:	48e1                	li	a7,24
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 41c:	48e9                	li	a7,26
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 424:	48e5                	li	a7,25
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 42c:	1101                	add	sp,sp,-32
 42e:	ec06                	sd	ra,24(sp)
 430:	e822                	sd	s0,16(sp)
 432:	1000                	add	s0,sp,32
 434:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 438:	4605                	li	a2,1
 43a:	fef40593          	add	a1,s0,-17
 43e:	00000097          	auipc	ra,0x0
 442:	f46080e7          	jalr	-186(ra) # 384 <write>
}
 446:	60e2                	ld	ra,24(sp)
 448:	6442                	ld	s0,16(sp)
 44a:	6105                	add	sp,sp,32
 44c:	8082                	ret

000000000000044e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 44e:	7139                	add	sp,sp,-64
 450:	fc06                	sd	ra,56(sp)
 452:	f822                	sd	s0,48(sp)
 454:	f426                	sd	s1,40(sp)
 456:	0080                	add	s0,sp,64
 458:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 45a:	c299                	beqz	a3,460 <printint+0x12>
 45c:	0805cb63          	bltz	a1,4f2 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 460:	2581                	sext.w	a1,a1
  neg = 0;
 462:	4881                	li	a7,0
 464:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 468:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 46a:	2601                	sext.w	a2,a2
 46c:	00000517          	auipc	a0,0x0
 470:	4fc50513          	add	a0,a0,1276 # 968 <digits>
 474:	883a                	mv	a6,a4
 476:	2705                	addw	a4,a4,1
 478:	02c5f7bb          	remuw	a5,a1,a2
 47c:	1782                	sll	a5,a5,0x20
 47e:	9381                	srl	a5,a5,0x20
 480:	97aa                	add	a5,a5,a0
 482:	0007c783          	lbu	a5,0(a5)
 486:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 48a:	0005879b          	sext.w	a5,a1
 48e:	02c5d5bb          	divuw	a1,a1,a2
 492:	0685                	add	a3,a3,1
 494:	fec7f0e3          	bgeu	a5,a2,474 <printint+0x26>
  if(neg)
 498:	00088c63          	beqz	a7,4b0 <printint+0x62>
    buf[i++] = '-';
 49c:	fd070793          	add	a5,a4,-48
 4a0:	00878733          	add	a4,a5,s0
 4a4:	02d00793          	li	a5,45
 4a8:	fef70823          	sb	a5,-16(a4)
 4ac:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 4b0:	02e05c63          	blez	a4,4e8 <printint+0x9a>
 4b4:	f04a                	sd	s2,32(sp)
 4b6:	ec4e                	sd	s3,24(sp)
 4b8:	fc040793          	add	a5,s0,-64
 4bc:	00e78933          	add	s2,a5,a4
 4c0:	fff78993          	add	s3,a5,-1
 4c4:	99ba                	add	s3,s3,a4
 4c6:	377d                	addw	a4,a4,-1
 4c8:	1702                	sll	a4,a4,0x20
 4ca:	9301                	srl	a4,a4,0x20
 4cc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4d0:	fff94583          	lbu	a1,-1(s2)
 4d4:	8526                	mv	a0,s1
 4d6:	00000097          	auipc	ra,0x0
 4da:	f56080e7          	jalr	-170(ra) # 42c <putc>
  while(--i >= 0)
 4de:	197d                	add	s2,s2,-1
 4e0:	ff3918e3          	bne	s2,s3,4d0 <printint+0x82>
 4e4:	7902                	ld	s2,32(sp)
 4e6:	69e2                	ld	s3,24(sp)
}
 4e8:	70e2                	ld	ra,56(sp)
 4ea:	7442                	ld	s0,48(sp)
 4ec:	74a2                	ld	s1,40(sp)
 4ee:	6121                	add	sp,sp,64
 4f0:	8082                	ret
    x = -xx;
 4f2:	40b005bb          	negw	a1,a1
    neg = 1;
 4f6:	4885                	li	a7,1
    x = -xx;
 4f8:	b7b5                	j	464 <printint+0x16>

00000000000004fa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4fa:	715d                	add	sp,sp,-80
 4fc:	e486                	sd	ra,72(sp)
 4fe:	e0a2                	sd	s0,64(sp)
 500:	f84a                	sd	s2,48(sp)
 502:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 504:	0005c903          	lbu	s2,0(a1)
 508:	1a090a63          	beqz	s2,6bc <vprintf+0x1c2>
 50c:	fc26                	sd	s1,56(sp)
 50e:	f44e                	sd	s3,40(sp)
 510:	f052                	sd	s4,32(sp)
 512:	ec56                	sd	s5,24(sp)
 514:	e85a                	sd	s6,16(sp)
 516:	e45e                	sd	s7,8(sp)
 518:	8aaa                	mv	s5,a0
 51a:	8bb2                	mv	s7,a2
 51c:	00158493          	add	s1,a1,1
  state = 0;
 520:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 522:	02500a13          	li	s4,37
 526:	4b55                	li	s6,21
 528:	a839                	j	546 <vprintf+0x4c>
        putc(fd, c);
 52a:	85ca                	mv	a1,s2
 52c:	8556                	mv	a0,s5
 52e:	00000097          	auipc	ra,0x0
 532:	efe080e7          	jalr	-258(ra) # 42c <putc>
 536:	a019                	j	53c <vprintf+0x42>
    } else if(state == '%'){
 538:	01498d63          	beq	s3,s4,552 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 53c:	0485                	add	s1,s1,1
 53e:	fff4c903          	lbu	s2,-1(s1)
 542:	16090763          	beqz	s2,6b0 <vprintf+0x1b6>
    if(state == 0){
 546:	fe0999e3          	bnez	s3,538 <vprintf+0x3e>
      if(c == '%'){
 54a:	ff4910e3          	bne	s2,s4,52a <vprintf+0x30>
        state = '%';
 54e:	89d2                	mv	s3,s4
 550:	b7f5                	j	53c <vprintf+0x42>
      if(c == 'd'){
 552:	13490463          	beq	s2,s4,67a <vprintf+0x180>
 556:	f9d9079b          	addw	a5,s2,-99
 55a:	0ff7f793          	zext.b	a5,a5
 55e:	12fb6763          	bltu	s6,a5,68c <vprintf+0x192>
 562:	f9d9079b          	addw	a5,s2,-99
 566:	0ff7f713          	zext.b	a4,a5
 56a:	12eb6163          	bltu	s6,a4,68c <vprintf+0x192>
 56e:	00271793          	sll	a5,a4,0x2
 572:	00000717          	auipc	a4,0x0
 576:	39e70713          	add	a4,a4,926 # 910 <malloc+0x164>
 57a:	97ba                	add	a5,a5,a4
 57c:	439c                	lw	a5,0(a5)
 57e:	97ba                	add	a5,a5,a4
 580:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 582:	008b8913          	add	s2,s7,8
 586:	4685                	li	a3,1
 588:	4629                	li	a2,10
 58a:	000ba583          	lw	a1,0(s7)
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	ebe080e7          	jalr	-322(ra) # 44e <printint>
 598:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 59a:	4981                	li	s3,0
 59c:	b745                	j	53c <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 59e:	008b8913          	add	s2,s7,8
 5a2:	4681                	li	a3,0
 5a4:	4629                	li	a2,10
 5a6:	000ba583          	lw	a1,0(s7)
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	ea2080e7          	jalr	-350(ra) # 44e <printint>
 5b4:	8bca                	mv	s7,s2
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b751                	j	53c <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5ba:	008b8913          	add	s2,s7,8
 5be:	4681                	li	a3,0
 5c0:	4641                	li	a2,16
 5c2:	000ba583          	lw	a1,0(s7)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e86080e7          	jalr	-378(ra) # 44e <printint>
 5d0:	8bca                	mv	s7,s2
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b7a5                	j	53c <vprintf+0x42>
 5d6:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5d8:	008b8c13          	add	s8,s7,8
 5dc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5e0:	03000593          	li	a1,48
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	e46080e7          	jalr	-442(ra) # 42c <putc>
  putc(fd, 'x');
 5ee:	07800593          	li	a1,120
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e38080e7          	jalr	-456(ra) # 42c <putc>
 5fc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5fe:	00000b97          	auipc	s7,0x0
 602:	36ab8b93          	add	s7,s7,874 # 968 <digits>
 606:	03c9d793          	srl	a5,s3,0x3c
 60a:	97de                	add	a5,a5,s7
 60c:	0007c583          	lbu	a1,0(a5)
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	e1a080e7          	jalr	-486(ra) # 42c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 61a:	0992                	sll	s3,s3,0x4
 61c:	397d                	addw	s2,s2,-1
 61e:	fe0914e3          	bnez	s2,606 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 622:	8be2                	mv	s7,s8
      state = 0;
 624:	4981                	li	s3,0
 626:	6c02                	ld	s8,0(sp)
 628:	bf11                	j	53c <vprintf+0x42>
        s = va_arg(ap, char*);
 62a:	008b8993          	add	s3,s7,8
 62e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 632:	02090163          	beqz	s2,654 <vprintf+0x15a>
        while(*s != 0){
 636:	00094583          	lbu	a1,0(s2)
 63a:	c9a5                	beqz	a1,6aa <vprintf+0x1b0>
          putc(fd, *s);
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	dee080e7          	jalr	-530(ra) # 42c <putc>
          s++;
 646:	0905                	add	s2,s2,1
        while(*s != 0){
 648:	00094583          	lbu	a1,0(s2)
 64c:	f9e5                	bnez	a1,63c <vprintf+0x142>
        s = va_arg(ap, char*);
 64e:	8bce                	mv	s7,s3
      state = 0;
 650:	4981                	li	s3,0
 652:	b5ed                	j	53c <vprintf+0x42>
          s = "(null)";
 654:	00000917          	auipc	s2,0x0
 658:	2b490913          	add	s2,s2,692 # 908 <malloc+0x15c>
        while(*s != 0){
 65c:	02800593          	li	a1,40
 660:	bff1                	j	63c <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 662:	008b8913          	add	s2,s7,8
 666:	000bc583          	lbu	a1,0(s7)
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	dc0080e7          	jalr	-576(ra) # 42c <putc>
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
 678:	b5d1                	j	53c <vprintf+0x42>
        putc(fd, c);
 67a:	02500593          	li	a1,37
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	dac080e7          	jalr	-596(ra) # 42c <putc>
      state = 0;
 688:	4981                	li	s3,0
 68a:	bd4d                	j	53c <vprintf+0x42>
        putc(fd, '%');
 68c:	02500593          	li	a1,37
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	d9a080e7          	jalr	-614(ra) # 42c <putc>
        putc(fd, c);
 69a:	85ca                	mv	a1,s2
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	d8e080e7          	jalr	-626(ra) # 42c <putc>
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bd51                	j	53c <vprintf+0x42>
        s = va_arg(ap, char*);
 6aa:	8bce                	mv	s7,s3
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	b579                	j	53c <vprintf+0x42>
 6b0:	74e2                	ld	s1,56(sp)
 6b2:	79a2                	ld	s3,40(sp)
 6b4:	7a02                	ld	s4,32(sp)
 6b6:	6ae2                	ld	s5,24(sp)
 6b8:	6b42                	ld	s6,16(sp)
 6ba:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6bc:	60a6                	ld	ra,72(sp)
 6be:	6406                	ld	s0,64(sp)
 6c0:	7942                	ld	s2,48(sp)
 6c2:	6161                	add	sp,sp,80
 6c4:	8082                	ret

00000000000006c6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6c6:	715d                	add	sp,sp,-80
 6c8:	ec06                	sd	ra,24(sp)
 6ca:	e822                	sd	s0,16(sp)
 6cc:	1000                	add	s0,sp,32
 6ce:	e010                	sd	a2,0(s0)
 6d0:	e414                	sd	a3,8(s0)
 6d2:	e818                	sd	a4,16(s0)
 6d4:	ec1c                	sd	a5,24(s0)
 6d6:	03043023          	sd	a6,32(s0)
 6da:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6de:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6e2:	8622                	mv	a2,s0
 6e4:	00000097          	auipc	ra,0x0
 6e8:	e16080e7          	jalr	-490(ra) # 4fa <vprintf>
}
 6ec:	60e2                	ld	ra,24(sp)
 6ee:	6442                	ld	s0,16(sp)
 6f0:	6161                	add	sp,sp,80
 6f2:	8082                	ret

00000000000006f4 <printf>:

void
printf(const char *fmt, ...)
{
 6f4:	711d                	add	sp,sp,-96
 6f6:	ec06                	sd	ra,24(sp)
 6f8:	e822                	sd	s0,16(sp)
 6fa:	1000                	add	s0,sp,32
 6fc:	e40c                	sd	a1,8(s0)
 6fe:	e810                	sd	a2,16(s0)
 700:	ec14                	sd	a3,24(s0)
 702:	f018                	sd	a4,32(s0)
 704:	f41c                	sd	a5,40(s0)
 706:	03043823          	sd	a6,48(s0)
 70a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 70e:	00840613          	add	a2,s0,8
 712:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 716:	85aa                	mv	a1,a0
 718:	4505                	li	a0,1
 71a:	00000097          	auipc	ra,0x0
 71e:	de0080e7          	jalr	-544(ra) # 4fa <vprintf>
}
 722:	60e2                	ld	ra,24(sp)
 724:	6442                	ld	s0,16(sp)
 726:	6125                	add	sp,sp,96
 728:	8082                	ret

000000000000072a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 72a:	1141                	add	sp,sp,-16
 72c:	e422                	sd	s0,8(sp)
 72e:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 730:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 734:	00001797          	auipc	a5,0x1
 738:	8cc7b783          	ld	a5,-1844(a5) # 1000 <freep>
 73c:	a02d                	j	766 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 73e:	4618                	lw	a4,8(a2)
 740:	9f2d                	addw	a4,a4,a1
 742:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 746:	6398                	ld	a4,0(a5)
 748:	6310                	ld	a2,0(a4)
 74a:	a83d                	j	788 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 74c:	ff852703          	lw	a4,-8(a0)
 750:	9f31                	addw	a4,a4,a2
 752:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 754:	ff053683          	ld	a3,-16(a0)
 758:	a091                	j	79c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75a:	6398                	ld	a4,0(a5)
 75c:	00e7e463          	bltu	a5,a4,764 <free+0x3a>
 760:	00e6ea63          	bltu	a3,a4,774 <free+0x4a>
{
 764:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 766:	fed7fae3          	bgeu	a5,a3,75a <free+0x30>
 76a:	6398                	ld	a4,0(a5)
 76c:	00e6e463          	bltu	a3,a4,774 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 770:	fee7eae3          	bltu	a5,a4,764 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 774:	ff852583          	lw	a1,-8(a0)
 778:	6390                	ld	a2,0(a5)
 77a:	02059813          	sll	a6,a1,0x20
 77e:	01c85713          	srl	a4,a6,0x1c
 782:	9736                	add	a4,a4,a3
 784:	fae60de3          	beq	a2,a4,73e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 788:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 78c:	4790                	lw	a2,8(a5)
 78e:	02061593          	sll	a1,a2,0x20
 792:	01c5d713          	srl	a4,a1,0x1c
 796:	973e                	add	a4,a4,a5
 798:	fae68ae3          	beq	a3,a4,74c <free+0x22>
    p->s.ptr = bp->s.ptr;
 79c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 79e:	00001717          	auipc	a4,0x1
 7a2:	86f73123          	sd	a5,-1950(a4) # 1000 <freep>
}
 7a6:	6422                	ld	s0,8(sp)
 7a8:	0141                	add	sp,sp,16
 7aa:	8082                	ret

00000000000007ac <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ac:	7139                	add	sp,sp,-64
 7ae:	fc06                	sd	ra,56(sp)
 7b0:	f822                	sd	s0,48(sp)
 7b2:	f426                	sd	s1,40(sp)
 7b4:	ec4e                	sd	s3,24(sp)
 7b6:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b8:	02051493          	sll	s1,a0,0x20
 7bc:	9081                	srl	s1,s1,0x20
 7be:	04bd                	add	s1,s1,15
 7c0:	8091                	srl	s1,s1,0x4
 7c2:	0014899b          	addw	s3,s1,1
 7c6:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7c8:	00001517          	auipc	a0,0x1
 7cc:	83853503          	ld	a0,-1992(a0) # 1000 <freep>
 7d0:	c915                	beqz	a0,804 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d4:	4798                	lw	a4,8(a5)
 7d6:	08977e63          	bgeu	a4,s1,872 <malloc+0xc6>
 7da:	f04a                	sd	s2,32(sp)
 7dc:	e852                	sd	s4,16(sp)
 7de:	e456                	sd	s5,8(sp)
 7e0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7e2:	8a4e                	mv	s4,s3
 7e4:	0009871b          	sext.w	a4,s3
 7e8:	6685                	lui	a3,0x1
 7ea:	00d77363          	bgeu	a4,a3,7f0 <malloc+0x44>
 7ee:	6a05                	lui	s4,0x1
 7f0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7f4:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7f8:	00001917          	auipc	s2,0x1
 7fc:	80890913          	add	s2,s2,-2040 # 1000 <freep>
  if(p == (char*)-1)
 800:	5afd                	li	s5,-1
 802:	a091                	j	846 <malloc+0x9a>
 804:	f04a                	sd	s2,32(sp)
 806:	e852                	sd	s4,16(sp)
 808:	e456                	sd	s5,8(sp)
 80a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 80c:	00001797          	auipc	a5,0x1
 810:	80478793          	add	a5,a5,-2044 # 1010 <base>
 814:	00000717          	auipc	a4,0x0
 818:	7ef73623          	sd	a5,2028(a4) # 1000 <freep>
 81c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 81e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 822:	b7c1                	j	7e2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 824:	6398                	ld	a4,0(a5)
 826:	e118                	sd	a4,0(a0)
 828:	a08d                	j	88a <malloc+0xde>
  hp->s.size = nu;
 82a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 82e:	0541                	add	a0,a0,16
 830:	00000097          	auipc	ra,0x0
 834:	efa080e7          	jalr	-262(ra) # 72a <free>
  return freep;
 838:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 83c:	c13d                	beqz	a0,8a2 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 840:	4798                	lw	a4,8(a5)
 842:	02977463          	bgeu	a4,s1,86a <malloc+0xbe>
    if(p == freep)
 846:	00093703          	ld	a4,0(s2)
 84a:	853e                	mv	a0,a5
 84c:	fef719e3          	bne	a4,a5,83e <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 850:	8552                	mv	a0,s4
 852:	00000097          	auipc	ra,0x0
 856:	b9a080e7          	jalr	-1126(ra) # 3ec <sbrk>
  if(p == (char*)-1)
 85a:	fd5518e3          	bne	a0,s5,82a <malloc+0x7e>
        return 0;
 85e:	4501                	li	a0,0
 860:	7902                	ld	s2,32(sp)
 862:	6a42                	ld	s4,16(sp)
 864:	6aa2                	ld	s5,8(sp)
 866:	6b02                	ld	s6,0(sp)
 868:	a03d                	j	896 <malloc+0xea>
 86a:	7902                	ld	s2,32(sp)
 86c:	6a42                	ld	s4,16(sp)
 86e:	6aa2                	ld	s5,8(sp)
 870:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 872:	fae489e3          	beq	s1,a4,824 <malloc+0x78>
        p->s.size -= nunits;
 876:	4137073b          	subw	a4,a4,s3
 87a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 87c:	02071693          	sll	a3,a4,0x20
 880:	01c6d713          	srl	a4,a3,0x1c
 884:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 886:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 88a:	00000717          	auipc	a4,0x0
 88e:	76a73b23          	sd	a0,1910(a4) # 1000 <freep>
      return (void*)(p + 1);
 892:	01078513          	add	a0,a5,16
  }
}
 896:	70e2                	ld	ra,56(sp)
 898:	7442                	ld	s0,48(sp)
 89a:	74a2                	ld	s1,40(sp)
 89c:	69e2                	ld	s3,24(sp)
 89e:	6121                	add	sp,sp,64
 8a0:	8082                	ret
 8a2:	7902                	ld	s2,32(sp)
 8a4:	6a42                	ld	s4,16(sp)
 8a6:	6aa2                	ld	s5,8(sp)
 8a8:	6b02                	ld	s6,0(sp)
 8aa:	b7f5                	j	896 <malloc+0xea>
