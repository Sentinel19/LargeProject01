
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	53                   	push   %ebx
  12:	51                   	push   %ecx
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
  13:	83 ec 08             	sub    $0x8,%esp
  16:	6a 02                	push   $0x2
  18:	68 a8 06 00 00       	push   $0x6a8
  1d:	e8 18 02 00 00       	call   23a <open>
  22:	83 c4 10             	add    $0x10,%esp
  25:	85 c0                	test   %eax,%eax
  27:	0f 88 d2 00 00 00    	js     ff <main+0xff>
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  2d:	83 ec 0c             	sub    $0xc,%esp
  30:	6a 00                	push   $0x0
  32:	e8 3b 02 00 00       	call   272 <dup>
  dup(0);  // stderr
  37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  3e:	e8 2f 02 00 00       	call   272 <dup>

  mkdir("dev");
  43:	c7 04 24 b0 06 00 00 	movl   $0x6b0,(%esp)
  4a:	e8 13 02 00 00       	call   262 <mkdir>

  if(open("dev/hello", O_RDONLY) < 0){
  4f:	83 c4 08             	add    $0x8,%esp
  52:	6a 00                	push   $0x0
  54:	68 b4 06 00 00       	push   $0x6b4
  59:	e8 dc 01 00 00       	call   23a <open>
  5e:	83 c4 10             	add    $0x10,%esp
  61:	85 c0                	test   %eax,%eax
  63:	0f 88 be 00 00 00    	js     127 <main+0x127>
    mknod("dev/hello", 7, 1);
  }

  if(open("dev/zero", O_RDONLY) < 0){
  69:	83 ec 08             	sub    $0x8,%esp
  6c:	6a 00                	push   $0x0
  6e:	68 be 06 00 00       	push   $0x6be
  73:	e8 c2 01 00 00       	call   23a <open>
  78:	83 c4 10             	add    $0x10,%esp
  7b:	85 c0                	test   %eax,%eax
  7d:	0f 88 bd 00 00 00    	js     140 <main+0x140>
    mknod("dev/zero", 2, 1);
    open("dev/zero", O_RDONLY);
  }

  if(open("dev/null", O_WRONLY) < 0){
  83:	83 ec 08             	sub    $0x8,%esp
  86:	6a 01                	push   $0x1
  88:	68 c7 06 00 00       	push   $0x6c7
  8d:	e8 a8 01 00 00       	call   23a <open>
  92:	83 c4 10             	add    $0x10,%esp
  95:	85 c0                	test   %eax,%eax
  97:	0f 88 cb 00 00 00    	js     168 <main+0x168>
    mknod("dev/null", 3, 1);
    open("dev/null", O_WRONLY);
  }

  if(open("dev/ticks", O_RDONLY) < 0){
  9d:	83 ec 08             	sub    $0x8,%esp
  a0:	6a 00                	push   $0x0
  a2:	68 d0 06 00 00       	push   $0x6d0
  a7:	e8 8e 01 00 00       	call   23a <open>
  ac:	83 c4 10             	add    $0x10,%esp
  af:	85 c0                	test   %eax,%eax
  b1:	0f 88 d9 00 00 00    	js     190 <main+0x190>
    mknod("dev/ticks", 4, 1);
    open("dev/ticks", O_RDONLY);
  }

  for(;;){
    printf(1, "init: starting sh\n");
  b7:	83 ec 08             	sub    $0x8,%esp
  ba:	68 da 06 00 00       	push   $0x6da
  bf:	6a 01                	push   $0x1
  c1:	e8 b3 05 00 00       	call   679 <printf>
    pid = fork();
  c6:	e8 27 01 00 00       	call   1f2 <fork>
  cb:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
  cd:	83 c4 10             	add    $0x10,%esp
  d0:	85 c0                	test   %eax,%eax
  d2:	0f 88 e0 00 00 00    	js     1b8 <main+0x1b8>
      printf(1, "init: fork failed\n");
      exit();
    }
    if(pid == 0){
  d8:	0f 84 ee 00 00 00    	je     1cc <main+0x1cc>
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  de:	e8 1f 01 00 00       	call   202 <wait>
  e3:	85 c0                	test   %eax,%eax
  e5:	78 d0                	js     b7 <main+0xb7>
  e7:	39 c3                	cmp    %eax,%ebx
  e9:	74 cc                	je     b7 <main+0xb7>
      printf(1, "zombie!\n");
  eb:	83 ec 08             	sub    $0x8,%esp
  ee:	68 19 07 00 00       	push   $0x719
  f3:	6a 01                	push   $0x1
  f5:	e8 7f 05 00 00       	call   679 <printf>
  fa:	83 c4 10             	add    $0x10,%esp
  fd:	eb df                	jmp    de <main+0xde>
    mknod("console", 1, 1);
  ff:	83 ec 04             	sub    $0x4,%esp
 102:	6a 01                	push   $0x1
 104:	6a 01                	push   $0x1
 106:	68 a8 06 00 00       	push   $0x6a8
 10b:	e8 32 01 00 00       	call   242 <mknod>
    open("console", O_RDWR);
 110:	83 c4 08             	add    $0x8,%esp
 113:	6a 02                	push   $0x2
 115:	68 a8 06 00 00       	push   $0x6a8
 11a:	e8 1b 01 00 00       	call   23a <open>
 11f:	83 c4 10             	add    $0x10,%esp
 122:	e9 06 ff ff ff       	jmp    2d <main+0x2d>
    mknod("dev/hello", 7, 1);
 127:	83 ec 04             	sub    $0x4,%esp
 12a:	6a 01                	push   $0x1
 12c:	6a 07                	push   $0x7
 12e:	68 b4 06 00 00       	push   $0x6b4
 133:	e8 0a 01 00 00       	call   242 <mknod>
 138:	83 c4 10             	add    $0x10,%esp
 13b:	e9 29 ff ff ff       	jmp    69 <main+0x69>
    mknod("dev/zero", 2, 1);
 140:	83 ec 04             	sub    $0x4,%esp
 143:	6a 01                	push   $0x1
 145:	6a 02                	push   $0x2
 147:	68 be 06 00 00       	push   $0x6be
 14c:	e8 f1 00 00 00       	call   242 <mknod>
    open("dev/zero", O_RDONLY);
 151:	83 c4 08             	add    $0x8,%esp
 154:	6a 00                	push   $0x0
 156:	68 be 06 00 00       	push   $0x6be
 15b:	e8 da 00 00 00       	call   23a <open>
 160:	83 c4 10             	add    $0x10,%esp
 163:	e9 1b ff ff ff       	jmp    83 <main+0x83>
    mknod("dev/null", 3, 1);
 168:	83 ec 04             	sub    $0x4,%esp
 16b:	6a 01                	push   $0x1
 16d:	6a 03                	push   $0x3
 16f:	68 c7 06 00 00       	push   $0x6c7
 174:	e8 c9 00 00 00       	call   242 <mknod>
    open("dev/null", O_WRONLY);
 179:	83 c4 08             	add    $0x8,%esp
 17c:	6a 01                	push   $0x1
 17e:	68 c7 06 00 00       	push   $0x6c7
 183:	e8 b2 00 00 00       	call   23a <open>
 188:	83 c4 10             	add    $0x10,%esp
 18b:	e9 0d ff ff ff       	jmp    9d <main+0x9d>
    mknod("dev/ticks", 4, 1);
 190:	83 ec 04             	sub    $0x4,%esp
 193:	6a 01                	push   $0x1
 195:	6a 04                	push   $0x4
 197:	68 d0 06 00 00       	push   $0x6d0
 19c:	e8 a1 00 00 00       	call   242 <mknod>
    open("dev/ticks", O_RDONLY);
 1a1:	83 c4 08             	add    $0x8,%esp
 1a4:	6a 00                	push   $0x0
 1a6:	68 d0 06 00 00       	push   $0x6d0
 1ab:	e8 8a 00 00 00       	call   23a <open>
 1b0:	83 c4 10             	add    $0x10,%esp
 1b3:	e9 ff fe ff ff       	jmp    b7 <main+0xb7>
      printf(1, "init: fork failed\n");
 1b8:	83 ec 08             	sub    $0x8,%esp
 1bb:	68 ed 06 00 00       	push   $0x6ed
 1c0:	6a 01                	push   $0x1
 1c2:	e8 b2 04 00 00       	call   679 <printf>
      exit();
 1c7:	e8 2e 00 00 00       	call   1fa <exit>
      exec("sh", argv);
 1cc:	83 ec 08             	sub    $0x8,%esp
 1cf:	68 40 07 00 00       	push   $0x740
 1d4:	68 00 07 00 00       	push   $0x700
 1d9:	e8 54 00 00 00       	call   232 <exec>
      printf(1, "init: exec sh failed\n");
 1de:	83 c4 08             	add    $0x8,%esp
 1e1:	68 03 07 00 00       	push   $0x703
 1e6:	6a 01                	push   $0x1
 1e8:	e8 8c 04 00 00       	call   679 <printf>
      exit();
 1ed:	e8 08 00 00 00       	call   1fa <exit>

000001f2 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1f2:	b8 01 00 00 00       	mov    $0x1,%eax
 1f7:	cd 40                	int    $0x40
 1f9:	c3                   	ret    

000001fa <exit>:
SYSCALL(exit)
 1fa:	b8 02 00 00 00       	mov    $0x2,%eax
 1ff:	cd 40                	int    $0x40
 201:	c3                   	ret    

00000202 <wait>:
SYSCALL(wait)
 202:	b8 03 00 00 00       	mov    $0x3,%eax
 207:	cd 40                	int    $0x40
 209:	c3                   	ret    

0000020a <pipe>:
SYSCALL(pipe)
 20a:	b8 04 00 00 00       	mov    $0x4,%eax
 20f:	cd 40                	int    $0x40
 211:	c3                   	ret    

00000212 <read>:
SYSCALL(read)
 212:	b8 05 00 00 00       	mov    $0x5,%eax
 217:	cd 40                	int    $0x40
 219:	c3                   	ret    

0000021a <write>:
SYSCALL(write)
 21a:	b8 10 00 00 00       	mov    $0x10,%eax
 21f:	cd 40                	int    $0x40
 221:	c3                   	ret    

00000222 <close>:
SYSCALL(close)
 222:	b8 15 00 00 00       	mov    $0x15,%eax
 227:	cd 40                	int    $0x40
 229:	c3                   	ret    

0000022a <kill>:
SYSCALL(kill)
 22a:	b8 06 00 00 00       	mov    $0x6,%eax
 22f:	cd 40                	int    $0x40
 231:	c3                   	ret    

00000232 <exec>:
SYSCALL(exec)
 232:	b8 07 00 00 00       	mov    $0x7,%eax
 237:	cd 40                	int    $0x40
 239:	c3                   	ret    

0000023a <open>:
SYSCALL(open)
 23a:	b8 0f 00 00 00       	mov    $0xf,%eax
 23f:	cd 40                	int    $0x40
 241:	c3                   	ret    

00000242 <mknod>:
SYSCALL(mknod)
 242:	b8 11 00 00 00       	mov    $0x11,%eax
 247:	cd 40                	int    $0x40
 249:	c3                   	ret    

0000024a <unlink>:
SYSCALL(unlink)
 24a:	b8 12 00 00 00       	mov    $0x12,%eax
 24f:	cd 40                	int    $0x40
 251:	c3                   	ret    

00000252 <fstat>:
SYSCALL(fstat)
 252:	b8 08 00 00 00       	mov    $0x8,%eax
 257:	cd 40                	int    $0x40
 259:	c3                   	ret    

0000025a <link>:
SYSCALL(link)
 25a:	b8 13 00 00 00       	mov    $0x13,%eax
 25f:	cd 40                	int    $0x40
 261:	c3                   	ret    

00000262 <mkdir>:
SYSCALL(mkdir)
 262:	b8 14 00 00 00       	mov    $0x14,%eax
 267:	cd 40                	int    $0x40
 269:	c3                   	ret    

0000026a <chdir>:
SYSCALL(chdir)
 26a:	b8 09 00 00 00       	mov    $0x9,%eax
 26f:	cd 40                	int    $0x40
 271:	c3                   	ret    

00000272 <dup>:
SYSCALL(dup)
 272:	b8 0a 00 00 00       	mov    $0xa,%eax
 277:	cd 40                	int    $0x40
 279:	c3                   	ret    

0000027a <getpid>:
SYSCALL(getpid)
 27a:	b8 0b 00 00 00       	mov    $0xb,%eax
 27f:	cd 40                	int    $0x40
 281:	c3                   	ret    

00000282 <sbrk>:
SYSCALL(sbrk)
 282:	b8 0c 00 00 00       	mov    $0xc,%eax
 287:	cd 40                	int    $0x40
 289:	c3                   	ret    

0000028a <sleep>:
SYSCALL(sleep)
 28a:	b8 0d 00 00 00       	mov    $0xd,%eax
 28f:	cd 40                	int    $0x40
 291:	c3                   	ret    

00000292 <uptime>:
SYSCALL(uptime)
 292:	b8 0e 00 00 00       	mov    $0xe,%eax
 297:	cd 40                	int    $0x40
 299:	c3                   	ret    

0000029a <yield>:
SYSCALL(yield)
 29a:	b8 16 00 00 00       	mov    $0x16,%eax
 29f:	cd 40                	int    $0x40
 2a1:	c3                   	ret    

000002a2 <shutdown>:
SYSCALL(shutdown)
 2a2:	b8 17 00 00 00       	mov    $0x17,%eax
 2a7:	cd 40                	int    $0x40
 2a9:	c3                   	ret    

000002aa <ps>:
SYSCALL(ps)
 2aa:	b8 18 00 00 00       	mov    $0x18,%eax
 2af:	cd 40                	int    $0x40
 2b1:	c3                   	ret    

000002b2 <nice>:
SYSCALL(nice)
 2b2:	b8 1b 00 00 00       	mov    $0x1b,%eax
 2b7:	cd 40                	int    $0x40
 2b9:	c3                   	ret    

000002ba <flock>:
SYSCALL(flock)
 2ba:	b8 19 00 00 00       	mov    $0x19,%eax
 2bf:	cd 40                	int    $0x40
 2c1:	c3                   	ret    

000002c2 <funlock>:
SYSCALL(funlock)
 2c2:	b8 1a 00 00 00       	mov    $0x1a,%eax
 2c7:	cd 40                	int    $0x40
 2c9:	c3                   	ret    

000002ca <s_sputc>:
  write(fd, &c, 1);
}

// store c at index within outbuffer if index is less than length
void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
 2ca:	f3 0f 1e fb          	endbr32 
 2ce:	55                   	push   %ebp
 2cf:	89 e5                	mov    %esp,%ebp
 2d1:	8b 45 14             	mov    0x14(%ebp),%eax
 2d4:	8b 55 18             	mov    0x18(%ebp),%edx
  if(index < length)
 2d7:	3b 45 10             	cmp    0x10(%ebp),%eax
 2da:	73 06                	jae    2e2 <s_sputc+0x18>
  {
    outbuffer[index] = c;
 2dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 2df:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  }
}
 2e2:	5d                   	pop    %ebp
 2e3:	c3                   	ret    

000002e4 <s_getReverseDigits>:
// "most significant digit on teh left" representation. At most length
// characters are written to outbuf.
// \return the number of characters written to outbuf
static uint 
s_getReverseDigits(char *outbuf, uint length, int xx, int base, int sgn)
{
 2e4:	55                   	push   %ebp
 2e5:	89 e5                	mov    %esp,%ebp
 2e7:	57                   	push   %edi
 2e8:	56                   	push   %esi
 2e9:	53                   	push   %ebx
 2ea:	83 ec 08             	sub    $0x8,%esp
 2ed:	89 c6                	mov    %eax,%esi
 2ef:	89 d3                	mov    %edx,%ebx
 2f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  static char digits[] = "0123456789ABCDEF";
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 2f8:	0f 95 c2             	setne  %dl
 2fb:	89 c8                	mov    %ecx,%eax
 2fd:	c1 e8 1f             	shr    $0x1f,%eax
 300:	84 c2                	test   %al,%dl
 302:	74 33                	je     337 <s_getReverseDigits+0x53>
    neg = 1;
    x = -xx;
 304:	89 c8                	mov    %ecx,%eax
 306:	f7 d8                	neg    %eax
    neg = 1;
 308:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 30f:	bf 00 00 00 00       	mov    $0x0,%edi
  while(i + 1 < length && x != 0) {
 314:	8d 4f 01             	lea    0x1(%edi),%ecx
 317:	89 ca                	mov    %ecx,%edx
 319:	39 d9                	cmp    %ebx,%ecx
 31b:	73 26                	jae    343 <s_getReverseDigits+0x5f>
 31d:	85 c0                	test   %eax,%eax
 31f:	74 22                	je     343 <s_getReverseDigits+0x5f>
    outbuf[i++] = digits[x % base];
 321:	ba 00 00 00 00       	mov    $0x0,%edx
 326:	f7 75 08             	divl   0x8(%ebp)
 329:	0f b6 92 2c 07 00 00 	movzbl 0x72c(%edx),%edx
 330:	88 14 3e             	mov    %dl,(%esi,%edi,1)
 333:	89 cf                	mov    %ecx,%edi
 335:	eb dd                	jmp    314 <s_getReverseDigits+0x30>
    x = xx;
 337:	8b 45 f0             	mov    -0x10(%ebp),%eax
  neg = 0;
 33a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 341:	eb cc                	jmp    30f <s_getReverseDigits+0x2b>
    x /= base;
  }

  if(0 == xx && i + 1 < length) {
 343:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 347:	75 0a                	jne    353 <s_getReverseDigits+0x6f>
 349:	39 da                	cmp    %ebx,%edx
 34b:	73 06                	jae    353 <s_getReverseDigits+0x6f>
    outbuf[i++] = digits[0];   
 34d:	c6 04 3e 30          	movb   $0x30,(%esi,%edi,1)
 351:	89 cf                	mov    %ecx,%edi
  }

  if(neg && i < length) {
 353:	89 fa                	mov    %edi,%edx
 355:	39 df                	cmp    %ebx,%edi
 357:	0f 92 c0             	setb   %al
 35a:	84 45 ec             	test   %al,-0x14(%ebp)
 35d:	74 07                	je     366 <s_getReverseDigits+0x82>
    outbuf[i++] = '-';
 35f:	83 c7 01             	add    $0x1,%edi
 362:	c6 04 16 2d          	movb   $0x2d,(%esi,%edx,1)
  }

  return i;
}
 366:	89 f8                	mov    %edi,%eax
 368:	83 c4 08             	add    $0x8,%esp
 36b:	5b                   	pop    %ebx
 36c:	5e                   	pop    %esi
 36d:	5f                   	pop    %edi
 36e:	5d                   	pop    %ebp
 36f:	c3                   	ret    

00000370 <s_min>:
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
 370:	39 c2                	cmp    %eax,%edx
 372:	0f 46 c2             	cmovbe %edx,%eax
}
 375:	c3                   	ret    

00000376 <s_printint>:
{
 376:	55                   	push   %ebp
 377:	89 e5                	mov    %esp,%ebp
 379:	57                   	push   %edi
 37a:	56                   	push   %esi
 37b:	53                   	push   %ebx
 37c:	83 ec 2c             	sub    $0x2c,%esp
 37f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 382:	89 55 d0             	mov    %edx,-0x30(%ebp)
 385:	89 4d cc             	mov    %ecx,-0x34(%ebp)
 388:	8b 7d 08             	mov    0x8(%ebp),%edi
  s_getReverseDigits(localBuffer, localBufferLength, xx, base, sgn);
 38b:	ff 75 14             	pushl  0x14(%ebp)
 38e:	ff 75 10             	pushl  0x10(%ebp)
 391:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 394:	ba 10 00 00 00       	mov    $0x10,%edx
 399:	8d 45 d8             	lea    -0x28(%ebp),%eax
 39c:	e8 43 ff ff ff       	call   2e4 <s_getReverseDigits>
 3a1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int i = result;
 3a4:	89 c3                	mov    %eax,%ebx
  while(--i >= 0 && j < length) 
 3a6:	83 c4 08             	add    $0x8,%esp
  int j = 0;
 3a9:	be 00 00 00 00       	mov    $0x0,%esi
  while(--i >= 0 && j < length) 
 3ae:	83 eb 01             	sub    $0x1,%ebx
 3b1:	78 22                	js     3d5 <s_printint+0x5f>
 3b3:	39 fe                	cmp    %edi,%esi
 3b5:	73 1e                	jae    3d5 <s_printint+0x5f>
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
 3b7:	83 ec 0c             	sub    $0xc,%esp
 3ba:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
 3bf:	50                   	push   %eax
 3c0:	56                   	push   %esi
 3c1:	57                   	push   %edi
 3c2:	ff 75 cc             	pushl  -0x34(%ebp)
 3c5:	ff 75 d0             	pushl  -0x30(%ebp)
 3c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 3cb:	ff d0                	call   *%eax
    j++;
 3cd:	83 c6 01             	add    $0x1,%esi
 3d0:	83 c4 20             	add    $0x20,%esp
 3d3:	eb d9                	jmp    3ae <s_printint+0x38>
}
 3d5:	8b 45 c8             	mov    -0x38(%ebp),%eax
 3d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3db:	5b                   	pop    %ebx
 3dc:	5e                   	pop    %esi
 3dd:	5f                   	pop    %edi
 3de:	5d                   	pop    %ebp
 3df:	c3                   	ret    

000003e0 <s_printf>:

static 
int s_printf(putFunction_t putcFunction, int fd, char *outbuffer, int n, const char *fmt, uint* ap)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	57                   	push   %edi
 3e4:	56                   	push   %esi
 3e5:	53                   	push   %ebx
 3e6:	83 ec 2c             	sub    $0x2c,%esp
 3e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
 3ec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 3ef:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  char *s;
  int c, i, state;
  uint outindex = 0;
  const int length = n -1; // leave room for nul termination
 3f2:	8b 45 08             	mov    0x8(%ebp),%eax
 3f5:	8d 78 ff             	lea    -0x1(%eax),%edi

  state = 0;
 3f8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(i = 0; fmt[i] && outindex < length; i++) {
 3ff:	bb 00 00 00 00       	mov    $0x0,%ebx
 404:	89 f8                	mov    %edi,%eax
 406:	89 df                	mov    %ebx,%edi
 408:	89 c6                	mov    %eax,%esi
 40a:	eb 20                	jmp    42c <s_printf+0x4c>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%') {
        state = '%';
      } else {
        putcFunction(fd, outbuffer, length, outindex++, c);
 40c:	8d 43 01             	lea    0x1(%ebx),%eax
 40f:	89 45 e0             	mov    %eax,-0x20(%ebp)
 412:	83 ec 0c             	sub    $0xc,%esp
 415:	51                   	push   %ecx
 416:	53                   	push   %ebx
 417:	56                   	push   %esi
 418:	ff 75 d0             	pushl  -0x30(%ebp)
 41b:	ff 75 d4             	pushl  -0x2c(%ebp)
 41e:	8b 55 d8             	mov    -0x28(%ebp),%edx
 421:	ff d2                	call   *%edx
 423:	83 c4 20             	add    $0x20,%esp
 426:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  for(i = 0; fmt[i] && outindex < length; i++) {
 429:	83 c7 01             	add    $0x1,%edi
 42c:	8b 45 0c             	mov    0xc(%ebp),%eax
 42f:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
 433:	84 c0                	test   %al,%al
 435:	0f 84 cd 01 00 00    	je     608 <s_printf+0x228>
 43b:	89 75 e0             	mov    %esi,-0x20(%ebp)
 43e:	39 de                	cmp    %ebx,%esi
 440:	0f 86 c2 01 00 00    	jbe    608 <s_printf+0x228>
    c = fmt[i] & 0xff;
 446:	0f be c8             	movsbl %al,%ecx
 449:	89 4d dc             	mov    %ecx,-0x24(%ebp)
 44c:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 44f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 453:	75 0a                	jne    45f <s_printf+0x7f>
      if(c == '%') {
 455:	83 f8 25             	cmp    $0x25,%eax
 458:	75 b2                	jne    40c <s_printf+0x2c>
        state = '%';
 45a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 45d:	eb ca                	jmp    429 <s_printf+0x49>
      }
    } else if(state == '%'){
 45f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 463:	75 c4                	jne    429 <s_printf+0x49>
      if(c == 'd'){
 465:	83 f8 64             	cmp    $0x64,%eax
 468:	74 6e                	je     4d8 <s_printf+0xf8>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 46a:	83 f8 78             	cmp    $0x78,%eax
 46d:	0f 94 c1             	sete   %cl
 470:	83 f8 70             	cmp    $0x70,%eax
 473:	0f 94 c2             	sete   %dl
 476:	08 d1                	or     %dl,%cl
 478:	0f 85 8e 00 00 00    	jne    50c <s_printf+0x12c>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 47e:	83 f8 73             	cmp    $0x73,%eax
 481:	0f 84 b9 00 00 00    	je     540 <s_printf+0x160>
          s = "(null)";
        while(*s != 0){
          putcFunction(fd, outbuffer, length, outindex++, *s);
          s++;
        }
      } else if(c == 'c'){
 487:	83 f8 63             	cmp    $0x63,%eax
 48a:	0f 84 1a 01 00 00    	je     5aa <s_printf+0x1ca>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
        ap++;
      } else if(c == '%'){
 490:	83 f8 25             	cmp    $0x25,%eax
 493:	0f 84 44 01 00 00    	je     5dd <s_printf+0x1fd>
        putcFunction(fd, outbuffer, length, outindex++, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putcFunction(fd, outbuffer, length, outindex++, '%');
 499:	8d 43 01             	lea    0x1(%ebx),%eax
 49c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 49f:	83 ec 0c             	sub    $0xc,%esp
 4a2:	6a 25                	push   $0x25
 4a4:	53                   	push   %ebx
 4a5:	56                   	push   %esi
 4a6:	ff 75 d0             	pushl  -0x30(%ebp)
 4a9:	ff 75 d4             	pushl  -0x2c(%ebp)
 4ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
 4af:	ff d0                	call   *%eax
        putcFunction(fd, outbuffer, length, outindex++, c);
 4b1:	83 c3 02             	add    $0x2,%ebx
 4b4:	83 c4 14             	add    $0x14,%esp
 4b7:	ff 75 dc             	pushl  -0x24(%ebp)
 4ba:	ff 75 e4             	pushl  -0x1c(%ebp)
 4bd:	56                   	push   %esi
 4be:	ff 75 d0             	pushl  -0x30(%ebp)
 4c1:	ff 75 d4             	pushl  -0x2c(%ebp)
 4c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
 4c7:	ff d0                	call   *%eax
 4c9:	83 c4 20             	add    $0x20,%esp
      }
      state = 0;
 4cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 4d3:	e9 51 ff ff ff       	jmp    429 <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
 4d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
 4db:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 4de:	6a 01                	push   $0x1
 4e0:	6a 0a                	push   $0xa
 4e2:	8b 45 10             	mov    0x10(%ebp),%eax
 4e5:	ff 30                	pushl  (%eax)
 4e7:	89 f0                	mov    %esi,%eax
 4e9:	29 d8                	sub    %ebx,%eax
 4eb:	50                   	push   %eax
 4ec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 4ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
 4f2:	e8 7f fe ff ff       	call   376 <s_printint>
 4f7:	01 c3                	add    %eax,%ebx
        ap++;
 4f9:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 4fd:	83 c4 10             	add    $0x10,%esp
      state = 0;
 500:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 507:	e9 1d ff ff ff       	jmp    429 <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
 50c:	8b 45 d0             	mov    -0x30(%ebp),%eax
 50f:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 512:	6a 00                	push   $0x0
 514:	6a 10                	push   $0x10
 516:	8b 45 10             	mov    0x10(%ebp),%eax
 519:	ff 30                	pushl  (%eax)
 51b:	89 f0                	mov    %esi,%eax
 51d:	29 d8                	sub    %ebx,%eax
 51f:	50                   	push   %eax
 520:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 523:	8b 45 d8             	mov    -0x28(%ebp),%eax
 526:	e8 4b fe ff ff       	call   376 <s_printint>
 52b:	01 c3                	add    %eax,%ebx
        ap++;
 52d:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 531:	83 c4 10             	add    $0x10,%esp
      state = 0;
 534:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 53b:	e9 e9 fe ff ff       	jmp    429 <s_printf+0x49>
        s = (char*)*ap;
 540:	8b 45 10             	mov    0x10(%ebp),%eax
 543:	8b 00                	mov    (%eax),%eax
        ap++;
 545:	83 45 10 04          	addl   $0x4,0x10(%ebp)
        if(s == 0)
 549:	85 c0                	test   %eax,%eax
 54b:	75 4e                	jne    59b <s_printf+0x1bb>
          s = "(null)";
 54d:	b8 22 07 00 00       	mov    $0x722,%eax
 552:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 555:	89 da                	mov    %ebx,%edx
 557:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 55a:	89 75 e0             	mov    %esi,-0x20(%ebp)
 55d:	89 c6                	mov    %eax,%esi
 55f:	eb 1f                	jmp    580 <s_printf+0x1a0>
          putcFunction(fd, outbuffer, length, outindex++, *s);
 561:	8d 7a 01             	lea    0x1(%edx),%edi
 564:	83 ec 0c             	sub    $0xc,%esp
 567:	0f be c0             	movsbl %al,%eax
 56a:	50                   	push   %eax
 56b:	52                   	push   %edx
 56c:	53                   	push   %ebx
 56d:	ff 75 d0             	pushl  -0x30(%ebp)
 570:	ff 75 d4             	pushl  -0x2c(%ebp)
 573:	8b 45 d8             	mov    -0x28(%ebp),%eax
 576:	ff d0                	call   *%eax
          s++;
 578:	83 c6 01             	add    $0x1,%esi
 57b:	83 c4 20             	add    $0x20,%esp
          putcFunction(fd, outbuffer, length, outindex++, *s);
 57e:	89 fa                	mov    %edi,%edx
        while(*s != 0){
 580:	0f b6 06             	movzbl (%esi),%eax
 583:	84 c0                	test   %al,%al
 585:	75 da                	jne    561 <s_printf+0x181>
 587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 58a:	89 d3                	mov    %edx,%ebx
 58c:	8b 75 e0             	mov    -0x20(%ebp),%esi
      state = 0;
 58f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 596:	e9 8e fe ff ff       	jmp    429 <s_printf+0x49>
 59b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 59e:	89 da                	mov    %ebx,%edx
 5a0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 5a3:	89 75 e0             	mov    %esi,-0x20(%ebp)
 5a6:	89 c6                	mov    %eax,%esi
 5a8:	eb d6                	jmp    580 <s_printf+0x1a0>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 5aa:	8d 43 01             	lea    0x1(%ebx),%eax
 5ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 5b0:	83 ec 0c             	sub    $0xc,%esp
 5b3:	8b 55 10             	mov    0x10(%ebp),%edx
 5b6:	0f be 02             	movsbl (%edx),%eax
 5b9:	50                   	push   %eax
 5ba:	53                   	push   %ebx
 5bb:	56                   	push   %esi
 5bc:	ff 75 d0             	pushl  -0x30(%ebp)
 5bf:	ff 75 d4             	pushl  -0x2c(%ebp)
 5c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
 5c5:	ff d2                	call   *%edx
        ap++;
 5c7:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 5cb:	83 c4 20             	add    $0x20,%esp
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 5ce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 5d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 5d8:	e9 4c fe ff ff       	jmp    429 <s_printf+0x49>
        putcFunction(fd, outbuffer, length, outindex++, c);
 5dd:	8d 43 01             	lea    0x1(%ebx),%eax
 5e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 5e3:	83 ec 0c             	sub    $0xc,%esp
 5e6:	ff 75 dc             	pushl  -0x24(%ebp)
 5e9:	53                   	push   %ebx
 5ea:	56                   	push   %esi
 5eb:	ff 75 d0             	pushl  -0x30(%ebp)
 5ee:	ff 75 d4             	pushl  -0x2c(%ebp)
 5f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
 5f4:	ff d2                	call   *%edx
 5f6:	83 c4 20             	add    $0x20,%esp
 5f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 5fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 603:	e9 21 fe ff ff       	jmp    429 <s_printf+0x49>
    }
  }
  
  return s_min(length, outindex);
 608:	89 da                	mov    %ebx,%edx
 60a:	89 f0                	mov    %esi,%eax
 60c:	e8 5f fd ff ff       	call   370 <s_min>
}
 611:	8d 65 f4             	lea    -0xc(%ebp),%esp
 614:	5b                   	pop    %ebx
 615:	5e                   	pop    %esi
 616:	5f                   	pop    %edi
 617:	5d                   	pop    %ebp
 618:	c3                   	ret    

00000619 <s_putc>:
{
 619:	f3 0f 1e fb          	endbr32 
 61d:	55                   	push   %ebp
 61e:	89 e5                	mov    %esp,%ebp
 620:	83 ec 1c             	sub    $0x1c,%esp
 623:	8b 45 18             	mov    0x18(%ebp),%eax
 626:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 629:	6a 01                	push   $0x1
 62b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 62e:	50                   	push   %eax
 62f:	ff 75 08             	pushl  0x8(%ebp)
 632:	e8 e3 fb ff ff       	call   21a <write>
}
 637:	83 c4 10             	add    $0x10,%esp
 63a:	c9                   	leave  
 63b:	c3                   	ret    

0000063c <snprintf>:
// Print into outbuffer at most n characters. Only understands %d, %x, %p, %s.
// If n is greater than 0, a terminating nul is always stored in outbuffer.
// \return the number of characters written to outbuffer not counting the
// terminating nul.
int snprintf(char *outbuffer, int n, const char *fmt, ...)
{
 63c:	f3 0f 1e fb          	endbr32 
 640:	55                   	push   %ebp
 641:	89 e5                	mov    %esp,%ebp
 643:	56                   	push   %esi
 644:	53                   	push   %ebx
 645:	8b 75 08             	mov    0x8(%ebp),%esi
 648:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint* ap = (uint*)(void*)&fmt + 1;
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
 64b:	83 ec 04             	sub    $0x4,%esp
 64e:	8d 45 14             	lea    0x14(%ebp),%eax
 651:	50                   	push   %eax
 652:	ff 75 10             	pushl  0x10(%ebp)
 655:	53                   	push   %ebx
 656:	89 f1                	mov    %esi,%ecx
 658:	ba ff ff ff ff       	mov    $0xffffffff,%edx
 65d:	b8 ca 02 00 00       	mov    $0x2ca,%eax
 662:	e8 79 fd ff ff       	call   3e0 <s_printf>
  if(count < n) {
 667:	83 c4 10             	add    $0x10,%esp
 66a:	39 c3                	cmp    %eax,%ebx
 66c:	76 04                	jbe    672 <snprintf+0x36>
    outbuffer[count] = 0; // Assure nul termination
 66e:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
  } 

  return count;
}
 672:	8d 65 f8             	lea    -0x8(%ebp),%esp
 675:	5b                   	pop    %ebx
 676:	5e                   	pop    %esi
 677:	5d                   	pop    %ebp
 678:	c3                   	ret    

00000679 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 679:	f3 0f 1e fb          	endbr32 
 67d:	55                   	push   %ebp
 67e:	89 e5                	mov    %esp,%ebp
 680:	83 ec 0c             	sub    $0xc,%esp
  static const uint veryLarge = 1<<30;
  uint* ap = (uint*)(void*)&fmt + 1;
  s_printf(s_putc, fd, 0, veryLarge, fmt, ap);
 683:	8d 45 10             	lea    0x10(%ebp),%eax
 686:	50                   	push   %eax
 687:	ff 75 0c             	pushl  0xc(%ebp)
 68a:	68 00 00 00 40       	push   $0x40000000
 68f:	b9 00 00 00 00       	mov    $0x0,%ecx
 694:	8b 55 08             	mov    0x8(%ebp),%edx
 697:	b8 19 06 00 00       	mov    $0x619,%eax
 69c:	e8 3f fd ff ff       	call   3e0 <s_printf>
}
 6a1:	83 c4 10             	add    $0x10,%esp
 6a4:	c9                   	leave  
 6a5:	c3                   	ret    
