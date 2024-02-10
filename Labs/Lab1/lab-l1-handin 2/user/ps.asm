
user/_ps:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/syscall.h"
#include "kernel/types.h"
#include "user/user.h"


int main(int argc, char *argv[]) {
   0:	1141                	add	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	add	s0,sp,16
    ps();
   8:	00000097          	auipc	ra,0x0
   c:	338080e7          	jalr	824(ra) # 340 <ps>
    return 0;
}
  10:	4501                	li	a0,0
  12:	60a2                	ld	ra,8(sp)
  14:	6402                	ld	s0,0(sp)
  16:	0141                	add	sp,sp,16
  18:	8082                	ret

000000000000001a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  1a:	1141                	add	sp,sp,-16
  1c:	e406                	sd	ra,8(sp)
  1e:	e022                	sd	s0,0(sp)
  20:	0800                	add	s0,sp,16
  extern int main();
  main();
  22:	00000097          	auipc	ra,0x0
  26:	fde080e7          	jalr	-34(ra) # 0 <main>
  exit(0);
  2a:	4501                	li	a0,0
  2c:	00000097          	auipc	ra,0x0
  30:	274080e7          	jalr	628(ra) # 2a0 <exit>

0000000000000034 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  34:	1141                	add	sp,sp,-16
  36:	e422                	sd	s0,8(sp)
  38:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  3a:	87aa                	mv	a5,a0
  3c:	0585                	add	a1,a1,1
  3e:	0785                	add	a5,a5,1
  40:	fff5c703          	lbu	a4,-1(a1)
  44:	fee78fa3          	sb	a4,-1(a5)
  48:	fb75                	bnez	a4,3c <strcpy+0x8>
    ;
  return os;
}
  4a:	6422                	ld	s0,8(sp)
  4c:	0141                	add	sp,sp,16
  4e:	8082                	ret

0000000000000050 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  50:	1141                	add	sp,sp,-16
  52:	e422                	sd	s0,8(sp)
  54:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  56:	00054783          	lbu	a5,0(a0)
  5a:	cb91                	beqz	a5,6e <strcmp+0x1e>
  5c:	0005c703          	lbu	a4,0(a1)
  60:	00f71763          	bne	a4,a5,6e <strcmp+0x1e>
    p++, q++;
  64:	0505                	add	a0,a0,1
  66:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  68:	00054783          	lbu	a5,0(a0)
  6c:	fbe5                	bnez	a5,5c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  6e:	0005c503          	lbu	a0,0(a1)
}
  72:	40a7853b          	subw	a0,a5,a0
  76:	6422                	ld	s0,8(sp)
  78:	0141                	add	sp,sp,16
  7a:	8082                	ret

000000000000007c <strlen>:

uint
strlen(const char *s)
{
  7c:	1141                	add	sp,sp,-16
  7e:	e422                	sd	s0,8(sp)
  80:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  82:	00054783          	lbu	a5,0(a0)
  86:	cf91                	beqz	a5,a2 <strlen+0x26>
  88:	0505                	add	a0,a0,1
  8a:	87aa                	mv	a5,a0
  8c:	86be                	mv	a3,a5
  8e:	0785                	add	a5,a5,1
  90:	fff7c703          	lbu	a4,-1(a5)
  94:	ff65                	bnez	a4,8c <strlen+0x10>
  96:	40a6853b          	subw	a0,a3,a0
  9a:	2505                	addw	a0,a0,1
    ;
  return n;
}
  9c:	6422                	ld	s0,8(sp)
  9e:	0141                	add	sp,sp,16
  a0:	8082                	ret
  for(n = 0; s[n]; n++)
  a2:	4501                	li	a0,0
  a4:	bfe5                	j	9c <strlen+0x20>

00000000000000a6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a6:	1141                	add	sp,sp,-16
  a8:	e422                	sd	s0,8(sp)
  aa:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ac:	ca19                	beqz	a2,c2 <memset+0x1c>
  ae:	87aa                	mv	a5,a0
  b0:	1602                	sll	a2,a2,0x20
  b2:	9201                	srl	a2,a2,0x20
  b4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  b8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  bc:	0785                	add	a5,a5,1
  be:	fee79de3          	bne	a5,a4,b8 <memset+0x12>
  }
  return dst;
}
  c2:	6422                	ld	s0,8(sp)
  c4:	0141                	add	sp,sp,16
  c6:	8082                	ret

00000000000000c8 <strchr>:

char*
strchr(const char *s, char c)
{
  c8:	1141                	add	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	add	s0,sp,16
  for(; *s; s++)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	cb99                	beqz	a5,e8 <strchr+0x20>
    if(*s == c)
  d4:	00f58763          	beq	a1,a5,e2 <strchr+0x1a>
  for(; *s; s++)
  d8:	0505                	add	a0,a0,1
  da:	00054783          	lbu	a5,0(a0)
  de:	fbfd                	bnez	a5,d4 <strchr+0xc>
      return (char*)s;
  return 0;
  e0:	4501                	li	a0,0
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	add	sp,sp,16
  e6:	8082                	ret
  return 0;
  e8:	4501                	li	a0,0
  ea:	bfe5                	j	e2 <strchr+0x1a>

00000000000000ec <gets>:

char*
gets(char *buf, int max)
{
  ec:	711d                	add	sp,sp,-96
  ee:	ec86                	sd	ra,88(sp)
  f0:	e8a2                	sd	s0,80(sp)
  f2:	e4a6                	sd	s1,72(sp)
  f4:	e0ca                	sd	s2,64(sp)
  f6:	fc4e                	sd	s3,56(sp)
  f8:	f852                	sd	s4,48(sp)
  fa:	f456                	sd	s5,40(sp)
  fc:	f05a                	sd	s6,32(sp)
  fe:	ec5e                	sd	s7,24(sp)
 100:	1080                	add	s0,sp,96
 102:	8baa                	mv	s7,a0
 104:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 106:	892a                	mv	s2,a0
 108:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 10a:	4aa9                	li	s5,10
 10c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 10e:	89a6                	mv	s3,s1
 110:	2485                	addw	s1,s1,1
 112:	0344d863          	bge	s1,s4,142 <gets+0x56>
    cc = read(0, &c, 1);
 116:	4605                	li	a2,1
 118:	faf40593          	add	a1,s0,-81
 11c:	4501                	li	a0,0
 11e:	00000097          	auipc	ra,0x0
 122:	19a080e7          	jalr	410(ra) # 2b8 <read>
    if(cc < 1)
 126:	00a05e63          	blez	a0,142 <gets+0x56>
    buf[i++] = c;
 12a:	faf44783          	lbu	a5,-81(s0)
 12e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 132:	01578763          	beq	a5,s5,140 <gets+0x54>
 136:	0905                	add	s2,s2,1
 138:	fd679be3          	bne	a5,s6,10e <gets+0x22>
    buf[i++] = c;
 13c:	89a6                	mv	s3,s1
 13e:	a011                	j	142 <gets+0x56>
 140:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 142:	99de                	add	s3,s3,s7
 144:	00098023          	sb	zero,0(s3)
  return buf;
}
 148:	855e                	mv	a0,s7
 14a:	60e6                	ld	ra,88(sp)
 14c:	6446                	ld	s0,80(sp)
 14e:	64a6                	ld	s1,72(sp)
 150:	6906                	ld	s2,64(sp)
 152:	79e2                	ld	s3,56(sp)
 154:	7a42                	ld	s4,48(sp)
 156:	7aa2                	ld	s5,40(sp)
 158:	7b02                	ld	s6,32(sp)
 15a:	6be2                	ld	s7,24(sp)
 15c:	6125                	add	sp,sp,96
 15e:	8082                	ret

0000000000000160 <stat>:

int
stat(const char *n, struct stat *st)
{
 160:	1101                	add	sp,sp,-32
 162:	ec06                	sd	ra,24(sp)
 164:	e822                	sd	s0,16(sp)
 166:	e04a                	sd	s2,0(sp)
 168:	1000                	add	s0,sp,32
 16a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 16c:	4581                	li	a1,0
 16e:	00000097          	auipc	ra,0x0
 172:	172080e7          	jalr	370(ra) # 2e0 <open>
  if(fd < 0)
 176:	02054663          	bltz	a0,1a2 <stat+0x42>
 17a:	e426                	sd	s1,8(sp)
 17c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 17e:	85ca                	mv	a1,s2
 180:	00000097          	auipc	ra,0x0
 184:	178080e7          	jalr	376(ra) # 2f8 <fstat>
 188:	892a                	mv	s2,a0
  close(fd);
 18a:	8526                	mv	a0,s1
 18c:	00000097          	auipc	ra,0x0
 190:	13c080e7          	jalr	316(ra) # 2c8 <close>
  return r;
 194:	64a2                	ld	s1,8(sp)
}
 196:	854a                	mv	a0,s2
 198:	60e2                	ld	ra,24(sp)
 19a:	6442                	ld	s0,16(sp)
 19c:	6902                	ld	s2,0(sp)
 19e:	6105                	add	sp,sp,32
 1a0:	8082                	ret
    return -1;
 1a2:	597d                	li	s2,-1
 1a4:	bfcd                	j	196 <stat+0x36>

00000000000001a6 <atoi>:

int
atoi(const char *s)
{
 1a6:	1141                	add	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ac:	00054683          	lbu	a3,0(a0)
 1b0:	fd06879b          	addw	a5,a3,-48
 1b4:	0ff7f793          	zext.b	a5,a5
 1b8:	4625                	li	a2,9
 1ba:	02f66863          	bltu	a2,a5,1ea <atoi+0x44>
 1be:	872a                	mv	a4,a0
  n = 0;
 1c0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1c2:	0705                	add	a4,a4,1
 1c4:	0025179b          	sllw	a5,a0,0x2
 1c8:	9fa9                	addw	a5,a5,a0
 1ca:	0017979b          	sllw	a5,a5,0x1
 1ce:	9fb5                	addw	a5,a5,a3
 1d0:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d4:	00074683          	lbu	a3,0(a4)
 1d8:	fd06879b          	addw	a5,a3,-48
 1dc:	0ff7f793          	zext.b	a5,a5
 1e0:	fef671e3          	bgeu	a2,a5,1c2 <atoi+0x1c>
  return n;
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	add	sp,sp,16
 1e8:	8082                	ret
  n = 0;
 1ea:	4501                	li	a0,0
 1ec:	bfe5                	j	1e4 <atoi+0x3e>

00000000000001ee <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1ee:	1141                	add	sp,sp,-16
 1f0:	e422                	sd	s0,8(sp)
 1f2:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f4:	02b57463          	bgeu	a0,a1,21c <memmove+0x2e>
    while(n-- > 0)
 1f8:	00c05f63          	blez	a2,216 <memmove+0x28>
 1fc:	1602                	sll	a2,a2,0x20
 1fe:	9201                	srl	a2,a2,0x20
 200:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 204:	872a                	mv	a4,a0
      *dst++ = *src++;
 206:	0585                	add	a1,a1,1
 208:	0705                	add	a4,a4,1
 20a:	fff5c683          	lbu	a3,-1(a1)
 20e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 212:	fef71ae3          	bne	a4,a5,206 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 216:	6422                	ld	s0,8(sp)
 218:	0141                	add	sp,sp,16
 21a:	8082                	ret
    dst += n;
 21c:	00c50733          	add	a4,a0,a2
    src += n;
 220:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 222:	fec05ae3          	blez	a2,216 <memmove+0x28>
 226:	fff6079b          	addw	a5,a2,-1
 22a:	1782                	sll	a5,a5,0x20
 22c:	9381                	srl	a5,a5,0x20
 22e:	fff7c793          	not	a5,a5
 232:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 234:	15fd                	add	a1,a1,-1
 236:	177d                	add	a4,a4,-1
 238:	0005c683          	lbu	a3,0(a1)
 23c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 240:	fee79ae3          	bne	a5,a4,234 <memmove+0x46>
 244:	bfc9                	j	216 <memmove+0x28>

0000000000000246 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 246:	1141                	add	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 24c:	ca05                	beqz	a2,27c <memcmp+0x36>
 24e:	fff6069b          	addw	a3,a2,-1
 252:	1682                	sll	a3,a3,0x20
 254:	9281                	srl	a3,a3,0x20
 256:	0685                	add	a3,a3,1
 258:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 25a:	00054783          	lbu	a5,0(a0)
 25e:	0005c703          	lbu	a4,0(a1)
 262:	00e79863          	bne	a5,a4,272 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 266:	0505                	add	a0,a0,1
    p2++;
 268:	0585                	add	a1,a1,1
  while (n-- > 0) {
 26a:	fed518e3          	bne	a0,a3,25a <memcmp+0x14>
  }
  return 0;
 26e:	4501                	li	a0,0
 270:	a019                	j	276 <memcmp+0x30>
      return *p1 - *p2;
 272:	40e7853b          	subw	a0,a5,a4
}
 276:	6422                	ld	s0,8(sp)
 278:	0141                	add	sp,sp,16
 27a:	8082                	ret
  return 0;
 27c:	4501                	li	a0,0
 27e:	bfe5                	j	276 <memcmp+0x30>

0000000000000280 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 280:	1141                	add	sp,sp,-16
 282:	e406                	sd	ra,8(sp)
 284:	e022                	sd	s0,0(sp)
 286:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 288:	00000097          	auipc	ra,0x0
 28c:	f66080e7          	jalr	-154(ra) # 1ee <memmove>
}
 290:	60a2                	ld	ra,8(sp)
 292:	6402                	ld	s0,0(sp)
 294:	0141                	add	sp,sp,16
 296:	8082                	ret

0000000000000298 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 298:	4885                	li	a7,1
 ecall
 29a:	00000073          	ecall
 ret
 29e:	8082                	ret

00000000000002a0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2a0:	4889                	li	a7,2
 ecall
 2a2:	00000073          	ecall
 ret
 2a6:	8082                	ret

00000000000002a8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2a8:	488d                	li	a7,3
 ecall
 2aa:	00000073          	ecall
 ret
 2ae:	8082                	ret

00000000000002b0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2b0:	4891                	li	a7,4
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <read>:
.global read
read:
 li a7, SYS_read
 2b8:	4895                	li	a7,5
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <write>:
.global write
write:
 li a7, SYS_write
 2c0:	48c1                	li	a7,16
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <close>:
.global close
close:
 li a7, SYS_close
 2c8:	48d5                	li	a7,21
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2d0:	4899                	li	a7,6
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2d8:	489d                	li	a7,7
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <open>:
.global open
open:
 li a7, SYS_open
 2e0:	48bd                	li	a7,15
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2e8:	48c5                	li	a7,17
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2f0:	48c9                	li	a7,18
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2f8:	48a1                	li	a7,8
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <link>:
.global link
link:
 li a7, SYS_link
 300:	48cd                	li	a7,19
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 308:	48d1                	li	a7,20
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 310:	48a5                	li	a7,9
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <dup>:
.global dup
dup:
 li a7, SYS_dup
 318:	48a9                	li	a7,10
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 320:	48ad                	li	a7,11
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 328:	48b1                	li	a7,12
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 330:	48b5                	li	a7,13
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 338:	48b9                	li	a7,14
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <ps>:
.global ps
ps:
 li a7, SYS_ps
 340:	48d9                	li	a7,22
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 348:	1101                	add	sp,sp,-32
 34a:	ec06                	sd	ra,24(sp)
 34c:	e822                	sd	s0,16(sp)
 34e:	1000                	add	s0,sp,32
 350:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 354:	4605                	li	a2,1
 356:	fef40593          	add	a1,s0,-17
 35a:	00000097          	auipc	ra,0x0
 35e:	f66080e7          	jalr	-154(ra) # 2c0 <write>
}
 362:	60e2                	ld	ra,24(sp)
 364:	6442                	ld	s0,16(sp)
 366:	6105                	add	sp,sp,32
 368:	8082                	ret

000000000000036a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 36a:	7139                	add	sp,sp,-64
 36c:	fc06                	sd	ra,56(sp)
 36e:	f822                	sd	s0,48(sp)
 370:	f426                	sd	s1,40(sp)
 372:	0080                	add	s0,sp,64
 374:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 376:	c299                	beqz	a3,37c <printint+0x12>
 378:	0805cb63          	bltz	a1,40e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 37c:	2581                	sext.w	a1,a1
  neg = 0;
 37e:	4881                	li	a7,0
 380:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 384:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 386:	2601                	sext.w	a2,a2
 388:	00000517          	auipc	a0,0x0
 38c:	4a850513          	add	a0,a0,1192 # 830 <digits>
 390:	883a                	mv	a6,a4
 392:	2705                	addw	a4,a4,1
 394:	02c5f7bb          	remuw	a5,a1,a2
 398:	1782                	sll	a5,a5,0x20
 39a:	9381                	srl	a5,a5,0x20
 39c:	97aa                	add	a5,a5,a0
 39e:	0007c783          	lbu	a5,0(a5)
 3a2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3a6:	0005879b          	sext.w	a5,a1
 3aa:	02c5d5bb          	divuw	a1,a1,a2
 3ae:	0685                	add	a3,a3,1
 3b0:	fec7f0e3          	bgeu	a5,a2,390 <printint+0x26>
  if(neg)
 3b4:	00088c63          	beqz	a7,3cc <printint+0x62>
    buf[i++] = '-';
 3b8:	fd070793          	add	a5,a4,-48
 3bc:	00878733          	add	a4,a5,s0
 3c0:	02d00793          	li	a5,45
 3c4:	fef70823          	sb	a5,-16(a4)
 3c8:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 3cc:	02e05c63          	blez	a4,404 <printint+0x9a>
 3d0:	f04a                	sd	s2,32(sp)
 3d2:	ec4e                	sd	s3,24(sp)
 3d4:	fc040793          	add	a5,s0,-64
 3d8:	00e78933          	add	s2,a5,a4
 3dc:	fff78993          	add	s3,a5,-1
 3e0:	99ba                	add	s3,s3,a4
 3e2:	377d                	addw	a4,a4,-1
 3e4:	1702                	sll	a4,a4,0x20
 3e6:	9301                	srl	a4,a4,0x20
 3e8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3ec:	fff94583          	lbu	a1,-1(s2)
 3f0:	8526                	mv	a0,s1
 3f2:	00000097          	auipc	ra,0x0
 3f6:	f56080e7          	jalr	-170(ra) # 348 <putc>
  while(--i >= 0)
 3fa:	197d                	add	s2,s2,-1
 3fc:	ff3918e3          	bne	s2,s3,3ec <printint+0x82>
 400:	7902                	ld	s2,32(sp)
 402:	69e2                	ld	s3,24(sp)
}
 404:	70e2                	ld	ra,56(sp)
 406:	7442                	ld	s0,48(sp)
 408:	74a2                	ld	s1,40(sp)
 40a:	6121                	add	sp,sp,64
 40c:	8082                	ret
    x = -xx;
 40e:	40b005bb          	negw	a1,a1
    neg = 1;
 412:	4885                	li	a7,1
    x = -xx;
 414:	b7b5                	j	380 <printint+0x16>

0000000000000416 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 416:	715d                	add	sp,sp,-80
 418:	e486                	sd	ra,72(sp)
 41a:	e0a2                	sd	s0,64(sp)
 41c:	f84a                	sd	s2,48(sp)
 41e:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 420:	0005c903          	lbu	s2,0(a1)
 424:	1a090a63          	beqz	s2,5d8 <vprintf+0x1c2>
 428:	fc26                	sd	s1,56(sp)
 42a:	f44e                	sd	s3,40(sp)
 42c:	f052                	sd	s4,32(sp)
 42e:	ec56                	sd	s5,24(sp)
 430:	e85a                	sd	s6,16(sp)
 432:	e45e                	sd	s7,8(sp)
 434:	8aaa                	mv	s5,a0
 436:	8bb2                	mv	s7,a2
 438:	00158493          	add	s1,a1,1
  state = 0;
 43c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 43e:	02500a13          	li	s4,37
 442:	4b55                	li	s6,21
 444:	a839                	j	462 <vprintf+0x4c>
        putc(fd, c);
 446:	85ca                	mv	a1,s2
 448:	8556                	mv	a0,s5
 44a:	00000097          	auipc	ra,0x0
 44e:	efe080e7          	jalr	-258(ra) # 348 <putc>
 452:	a019                	j	458 <vprintf+0x42>
    } else if(state == '%'){
 454:	01498d63          	beq	s3,s4,46e <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 458:	0485                	add	s1,s1,1
 45a:	fff4c903          	lbu	s2,-1(s1)
 45e:	16090763          	beqz	s2,5cc <vprintf+0x1b6>
    if(state == 0){
 462:	fe0999e3          	bnez	s3,454 <vprintf+0x3e>
      if(c == '%'){
 466:	ff4910e3          	bne	s2,s4,446 <vprintf+0x30>
        state = '%';
 46a:	89d2                	mv	s3,s4
 46c:	b7f5                	j	458 <vprintf+0x42>
      if(c == 'd'){
 46e:	13490463          	beq	s2,s4,596 <vprintf+0x180>
 472:	f9d9079b          	addw	a5,s2,-99
 476:	0ff7f793          	zext.b	a5,a5
 47a:	12fb6763          	bltu	s6,a5,5a8 <vprintf+0x192>
 47e:	f9d9079b          	addw	a5,s2,-99
 482:	0ff7f713          	zext.b	a4,a5
 486:	12eb6163          	bltu	s6,a4,5a8 <vprintf+0x192>
 48a:	00271793          	sll	a5,a4,0x2
 48e:	00000717          	auipc	a4,0x0
 492:	34a70713          	add	a4,a4,842 # 7d8 <malloc+0x110>
 496:	97ba                	add	a5,a5,a4
 498:	439c                	lw	a5,0(a5)
 49a:	97ba                	add	a5,a5,a4
 49c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 49e:	008b8913          	add	s2,s7,8
 4a2:	4685                	li	a3,1
 4a4:	4629                	li	a2,10
 4a6:	000ba583          	lw	a1,0(s7)
 4aa:	8556                	mv	a0,s5
 4ac:	00000097          	auipc	ra,0x0
 4b0:	ebe080e7          	jalr	-322(ra) # 36a <printint>
 4b4:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4b6:	4981                	li	s3,0
 4b8:	b745                	j	458 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4ba:	008b8913          	add	s2,s7,8
 4be:	4681                	li	a3,0
 4c0:	4629                	li	a2,10
 4c2:	000ba583          	lw	a1,0(s7)
 4c6:	8556                	mv	a0,s5
 4c8:	00000097          	auipc	ra,0x0
 4cc:	ea2080e7          	jalr	-350(ra) # 36a <printint>
 4d0:	8bca                	mv	s7,s2
      state = 0;
 4d2:	4981                	li	s3,0
 4d4:	b751                	j	458 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 4d6:	008b8913          	add	s2,s7,8
 4da:	4681                	li	a3,0
 4dc:	4641                	li	a2,16
 4de:	000ba583          	lw	a1,0(s7)
 4e2:	8556                	mv	a0,s5
 4e4:	00000097          	auipc	ra,0x0
 4e8:	e86080e7          	jalr	-378(ra) # 36a <printint>
 4ec:	8bca                	mv	s7,s2
      state = 0;
 4ee:	4981                	li	s3,0
 4f0:	b7a5                	j	458 <vprintf+0x42>
 4f2:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 4f4:	008b8c13          	add	s8,s7,8
 4f8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 4fc:	03000593          	li	a1,48
 500:	8556                	mv	a0,s5
 502:	00000097          	auipc	ra,0x0
 506:	e46080e7          	jalr	-442(ra) # 348 <putc>
  putc(fd, 'x');
 50a:	07800593          	li	a1,120
 50e:	8556                	mv	a0,s5
 510:	00000097          	auipc	ra,0x0
 514:	e38080e7          	jalr	-456(ra) # 348 <putc>
 518:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 51a:	00000b97          	auipc	s7,0x0
 51e:	316b8b93          	add	s7,s7,790 # 830 <digits>
 522:	03c9d793          	srl	a5,s3,0x3c
 526:	97de                	add	a5,a5,s7
 528:	0007c583          	lbu	a1,0(a5)
 52c:	8556                	mv	a0,s5
 52e:	00000097          	auipc	ra,0x0
 532:	e1a080e7          	jalr	-486(ra) # 348 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 536:	0992                	sll	s3,s3,0x4
 538:	397d                	addw	s2,s2,-1
 53a:	fe0914e3          	bnez	s2,522 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 53e:	8be2                	mv	s7,s8
      state = 0;
 540:	4981                	li	s3,0
 542:	6c02                	ld	s8,0(sp)
 544:	bf11                	j	458 <vprintf+0x42>
        s = va_arg(ap, char*);
 546:	008b8993          	add	s3,s7,8
 54a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 54e:	02090163          	beqz	s2,570 <vprintf+0x15a>
        while(*s != 0){
 552:	00094583          	lbu	a1,0(s2)
 556:	c9a5                	beqz	a1,5c6 <vprintf+0x1b0>
          putc(fd, *s);
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	dee080e7          	jalr	-530(ra) # 348 <putc>
          s++;
 562:	0905                	add	s2,s2,1
        while(*s != 0){
 564:	00094583          	lbu	a1,0(s2)
 568:	f9e5                	bnez	a1,558 <vprintf+0x142>
        s = va_arg(ap, char*);
 56a:	8bce                	mv	s7,s3
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b5ed                	j	458 <vprintf+0x42>
          s = "(null)";
 570:	00000917          	auipc	s2,0x0
 574:	26090913          	add	s2,s2,608 # 7d0 <malloc+0x108>
        while(*s != 0){
 578:	02800593          	li	a1,40
 57c:	bff1                	j	558 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 57e:	008b8913          	add	s2,s7,8
 582:	000bc583          	lbu	a1,0(s7)
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	dc0080e7          	jalr	-576(ra) # 348 <putc>
 590:	8bca                	mv	s7,s2
      state = 0;
 592:	4981                	li	s3,0
 594:	b5d1                	j	458 <vprintf+0x42>
        putc(fd, c);
 596:	02500593          	li	a1,37
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	dac080e7          	jalr	-596(ra) # 348 <putc>
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	bd4d                	j	458 <vprintf+0x42>
        putc(fd, '%');
 5a8:	02500593          	li	a1,37
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	d9a080e7          	jalr	-614(ra) # 348 <putc>
        putc(fd, c);
 5b6:	85ca                	mv	a1,s2
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	d8e080e7          	jalr	-626(ra) # 348 <putc>
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	bd51                	j	458 <vprintf+0x42>
        s = va_arg(ap, char*);
 5c6:	8bce                	mv	s7,s3
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	b579                	j	458 <vprintf+0x42>
 5cc:	74e2                	ld	s1,56(sp)
 5ce:	79a2                	ld	s3,40(sp)
 5d0:	7a02                	ld	s4,32(sp)
 5d2:	6ae2                	ld	s5,24(sp)
 5d4:	6b42                	ld	s6,16(sp)
 5d6:	6ba2                	ld	s7,8(sp)
    }
  }
}
 5d8:	60a6                	ld	ra,72(sp)
 5da:	6406                	ld	s0,64(sp)
 5dc:	7942                	ld	s2,48(sp)
 5de:	6161                	add	sp,sp,80
 5e0:	8082                	ret

00000000000005e2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5e2:	715d                	add	sp,sp,-80
 5e4:	ec06                	sd	ra,24(sp)
 5e6:	e822                	sd	s0,16(sp)
 5e8:	1000                	add	s0,sp,32
 5ea:	e010                	sd	a2,0(s0)
 5ec:	e414                	sd	a3,8(s0)
 5ee:	e818                	sd	a4,16(s0)
 5f0:	ec1c                	sd	a5,24(s0)
 5f2:	03043023          	sd	a6,32(s0)
 5f6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 5fa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 5fe:	8622                	mv	a2,s0
 600:	00000097          	auipc	ra,0x0
 604:	e16080e7          	jalr	-490(ra) # 416 <vprintf>
}
 608:	60e2                	ld	ra,24(sp)
 60a:	6442                	ld	s0,16(sp)
 60c:	6161                	add	sp,sp,80
 60e:	8082                	ret

0000000000000610 <printf>:

void
printf(const char *fmt, ...)
{
 610:	711d                	add	sp,sp,-96
 612:	ec06                	sd	ra,24(sp)
 614:	e822                	sd	s0,16(sp)
 616:	1000                	add	s0,sp,32
 618:	e40c                	sd	a1,8(s0)
 61a:	e810                	sd	a2,16(s0)
 61c:	ec14                	sd	a3,24(s0)
 61e:	f018                	sd	a4,32(s0)
 620:	f41c                	sd	a5,40(s0)
 622:	03043823          	sd	a6,48(s0)
 626:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 62a:	00840613          	add	a2,s0,8
 62e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 632:	85aa                	mv	a1,a0
 634:	4505                	li	a0,1
 636:	00000097          	auipc	ra,0x0
 63a:	de0080e7          	jalr	-544(ra) # 416 <vprintf>
}
 63e:	60e2                	ld	ra,24(sp)
 640:	6442                	ld	s0,16(sp)
 642:	6125                	add	sp,sp,96
 644:	8082                	ret

0000000000000646 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 646:	1141                	add	sp,sp,-16
 648:	e422                	sd	s0,8(sp)
 64a:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 64c:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 650:	00001797          	auipc	a5,0x1
 654:	9b07b783          	ld	a5,-1616(a5) # 1000 <freep>
 658:	a02d                	j	682 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 65a:	4618                	lw	a4,8(a2)
 65c:	9f2d                	addw	a4,a4,a1
 65e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 662:	6398                	ld	a4,0(a5)
 664:	6310                	ld	a2,0(a4)
 666:	a83d                	j	6a4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 668:	ff852703          	lw	a4,-8(a0)
 66c:	9f31                	addw	a4,a4,a2
 66e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 670:	ff053683          	ld	a3,-16(a0)
 674:	a091                	j	6b8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 676:	6398                	ld	a4,0(a5)
 678:	00e7e463          	bltu	a5,a4,680 <free+0x3a>
 67c:	00e6ea63          	bltu	a3,a4,690 <free+0x4a>
{
 680:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 682:	fed7fae3          	bgeu	a5,a3,676 <free+0x30>
 686:	6398                	ld	a4,0(a5)
 688:	00e6e463          	bltu	a3,a4,690 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 68c:	fee7eae3          	bltu	a5,a4,680 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 690:	ff852583          	lw	a1,-8(a0)
 694:	6390                	ld	a2,0(a5)
 696:	02059813          	sll	a6,a1,0x20
 69a:	01c85713          	srl	a4,a6,0x1c
 69e:	9736                	add	a4,a4,a3
 6a0:	fae60de3          	beq	a2,a4,65a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6a4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6a8:	4790                	lw	a2,8(a5)
 6aa:	02061593          	sll	a1,a2,0x20
 6ae:	01c5d713          	srl	a4,a1,0x1c
 6b2:	973e                	add	a4,a4,a5
 6b4:	fae68ae3          	beq	a3,a4,668 <free+0x22>
    p->s.ptr = bp->s.ptr;
 6b8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6ba:	00001717          	auipc	a4,0x1
 6be:	94f73323          	sd	a5,-1722(a4) # 1000 <freep>
}
 6c2:	6422                	ld	s0,8(sp)
 6c4:	0141                	add	sp,sp,16
 6c6:	8082                	ret

00000000000006c8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6c8:	7139                	add	sp,sp,-64
 6ca:	fc06                	sd	ra,56(sp)
 6cc:	f822                	sd	s0,48(sp)
 6ce:	f426                	sd	s1,40(sp)
 6d0:	ec4e                	sd	s3,24(sp)
 6d2:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6d4:	02051493          	sll	s1,a0,0x20
 6d8:	9081                	srl	s1,s1,0x20
 6da:	04bd                	add	s1,s1,15
 6dc:	8091                	srl	s1,s1,0x4
 6de:	0014899b          	addw	s3,s1,1
 6e2:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 6e4:	00001517          	auipc	a0,0x1
 6e8:	91c53503          	ld	a0,-1764(a0) # 1000 <freep>
 6ec:	c915                	beqz	a0,720 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 6f0:	4798                	lw	a4,8(a5)
 6f2:	08977e63          	bgeu	a4,s1,78e <malloc+0xc6>
 6f6:	f04a                	sd	s2,32(sp)
 6f8:	e852                	sd	s4,16(sp)
 6fa:	e456                	sd	s5,8(sp)
 6fc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 6fe:	8a4e                	mv	s4,s3
 700:	0009871b          	sext.w	a4,s3
 704:	6685                	lui	a3,0x1
 706:	00d77363          	bgeu	a4,a3,70c <malloc+0x44>
 70a:	6a05                	lui	s4,0x1
 70c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 710:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 714:	00001917          	auipc	s2,0x1
 718:	8ec90913          	add	s2,s2,-1812 # 1000 <freep>
  if(p == (char*)-1)
 71c:	5afd                	li	s5,-1
 71e:	a091                	j	762 <malloc+0x9a>
 720:	f04a                	sd	s2,32(sp)
 722:	e852                	sd	s4,16(sp)
 724:	e456                	sd	s5,8(sp)
 726:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 728:	00001797          	auipc	a5,0x1
 72c:	8e878793          	add	a5,a5,-1816 # 1010 <base>
 730:	00001717          	auipc	a4,0x1
 734:	8cf73823          	sd	a5,-1840(a4) # 1000 <freep>
 738:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 73a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 73e:	b7c1                	j	6fe <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 740:	6398                	ld	a4,0(a5)
 742:	e118                	sd	a4,0(a0)
 744:	a08d                	j	7a6 <malloc+0xde>
  hp->s.size = nu;
 746:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 74a:	0541                	add	a0,a0,16
 74c:	00000097          	auipc	ra,0x0
 750:	efa080e7          	jalr	-262(ra) # 646 <free>
  return freep;
 754:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 758:	c13d                	beqz	a0,7be <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 75a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 75c:	4798                	lw	a4,8(a5)
 75e:	02977463          	bgeu	a4,s1,786 <malloc+0xbe>
    if(p == freep)
 762:	00093703          	ld	a4,0(s2)
 766:	853e                	mv	a0,a5
 768:	fef719e3          	bne	a4,a5,75a <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 76c:	8552                	mv	a0,s4
 76e:	00000097          	auipc	ra,0x0
 772:	bba080e7          	jalr	-1094(ra) # 328 <sbrk>
  if(p == (char*)-1)
 776:	fd5518e3          	bne	a0,s5,746 <malloc+0x7e>
        return 0;
 77a:	4501                	li	a0,0
 77c:	7902                	ld	s2,32(sp)
 77e:	6a42                	ld	s4,16(sp)
 780:	6aa2                	ld	s5,8(sp)
 782:	6b02                	ld	s6,0(sp)
 784:	a03d                	j	7b2 <malloc+0xea>
 786:	7902                	ld	s2,32(sp)
 788:	6a42                	ld	s4,16(sp)
 78a:	6aa2                	ld	s5,8(sp)
 78c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 78e:	fae489e3          	beq	s1,a4,740 <malloc+0x78>
        p->s.size -= nunits;
 792:	4137073b          	subw	a4,a4,s3
 796:	c798                	sw	a4,8(a5)
        p += p->s.size;
 798:	02071693          	sll	a3,a4,0x20
 79c:	01c6d713          	srl	a4,a3,0x1c
 7a0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7a2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7a6:	00001717          	auipc	a4,0x1
 7aa:	84a73d23          	sd	a0,-1958(a4) # 1000 <freep>
      return (void*)(p + 1);
 7ae:	01078513          	add	a0,a5,16
  }
}
 7b2:	70e2                	ld	ra,56(sp)
 7b4:	7442                	ld	s0,48(sp)
 7b6:	74a2                	ld	s1,40(sp)
 7b8:	69e2                	ld	s3,24(sp)
 7ba:	6121                	add	sp,sp,64
 7bc:	8082                	ret
 7be:	7902                	ld	s2,32(sp)
 7c0:	6a42                	ld	s4,16(sp)
 7c2:	6aa2                	ld	s5,8(sp)
 7c4:	6b02                	ld	s6,0(sp)
 7c6:	b7f5                	j	7b2 <malloc+0xea>
