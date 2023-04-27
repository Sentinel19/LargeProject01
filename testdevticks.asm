
_testdevticks:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	57                   	push   %edi
  12:	56                   	push   %esi
  13:	53                   	push   %ebx
  14:	51                   	push   %ecx
  15:	81 ec 10 02 00 00    	sub    $0x210,%esp
    int fd = open("dev/ticks", O_RDONLY);
  1b:	6a 00                	push   $0x0
  1d:	68 6c 05 00 00       	push   $0x56c
  22:	e8 d7 00 00 00       	call   fe <open>
    if(0 > fd) {
  27:	83 c4 10             	add    $0x10,%esp
  2a:	85 c0                	test   %eax,%eax
  2c:	78 74                	js     a2 <main+0xa2>
  2e:	89 c3                	mov    %eax,%ebx
        printf(2, "Error: Cannot open dticks\n");
    }
    else {
        char buffer[512] = {'\0'};
  30:	c7 85 e8 fd ff ff 00 	movl   $0x0,-0x218(%ebp)
  37:	00 00 00 
  3a:	8d bd ec fd ff ff    	lea    -0x214(%ebp),%edi
  40:	b9 7f 00 00 00       	mov    $0x7f,%ecx
  45:	b8 00 00 00 00       	mov    $0x0,%eax
  4a:	f3 ab                	rep stos %eax,%es:(%edi)
        int count = read(fd, buffer, 512);
  4c:	83 ec 04             	sub    $0x4,%esp
  4f:	68 00 02 00 00       	push   $0x200
  54:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
  5a:	57                   	push   %edi
  5b:	53                   	push   %ebx
  5c:	e8 75 00 00 00       	call   d6 <read>
  61:	89 c6                	mov    %eax,%esi
        read(fd, buffer, 512);
  63:	83 c4 0c             	add    $0xc,%esp
  66:	68 00 02 00 00       	push   $0x200
  6b:	57                   	push   %edi
  6c:	53                   	push   %ebx
  6d:	e8 64 00 00 00       	call   d6 <read>
        printf(1, "Read <%s>\n", buffer);
  72:	83 c4 0c             	add    $0xc,%esp
  75:	57                   	push   %edi
  76:	68 91 05 00 00       	push   $0x591
  7b:	6a 01                	push   $0x1
  7d:	e8 bb 04 00 00       	call   53d <printf>
        printf(1, "Characters: %d\n", count);
  82:	83 c4 0c             	add    $0xc,%esp
  85:	56                   	push   %esi
  86:	68 9c 05 00 00       	push   $0x59c
  8b:	6a 01                	push   $0x1
  8d:	e8 ab 04 00 00       	call   53d <printf>

        close(fd);
  92:	89 1c 24             	mov    %ebx,(%esp)
  95:	e8 4c 00 00 00       	call   e6 <close>
        fd = -1;
  9a:	83 c4 10             	add    $0x10,%esp
    }
    exit();
  9d:	e8 1c 00 00 00       	call   be <exit>
        printf(2, "Error: Cannot open dticks\n");
  a2:	83 ec 08             	sub    $0x8,%esp
  a5:	68 76 05 00 00       	push   $0x576
  aa:	6a 02                	push   $0x2
  ac:	e8 8c 04 00 00       	call   53d <printf>
  b1:	83 c4 10             	add    $0x10,%esp
  b4:	eb e7                	jmp    9d <main+0x9d>

000000b6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  b6:	b8 01 00 00 00       	mov    $0x1,%eax
  bb:	cd 40                	int    $0x40
  bd:	c3                   	ret    

000000be <exit>:
SYSCALL(exit)
  be:	b8 02 00 00 00       	mov    $0x2,%eax
  c3:	cd 40                	int    $0x40
  c5:	c3                   	ret    

000000c6 <wait>:
SYSCALL(wait)
  c6:	b8 03 00 00 00       	mov    $0x3,%eax
  cb:	cd 40                	int    $0x40
  cd:	c3                   	ret    

000000ce <pipe>:
SYSCALL(pipe)
  ce:	b8 04 00 00 00       	mov    $0x4,%eax
  d3:	cd 40                	int    $0x40
  d5:	c3                   	ret    

000000d6 <read>:
SYSCALL(read)
  d6:	b8 05 00 00 00       	mov    $0x5,%eax
  db:	cd 40                	int    $0x40
  dd:	c3                   	ret    

000000de <write>:
SYSCALL(write)
  de:	b8 10 00 00 00       	mov    $0x10,%eax
  e3:	cd 40                	int    $0x40
  e5:	c3                   	ret    

000000e6 <close>:
SYSCALL(close)
  e6:	b8 15 00 00 00       	mov    $0x15,%eax
  eb:	cd 40                	int    $0x40
  ed:	c3                   	ret    

000000ee <kill>:
SYSCALL(kill)
  ee:	b8 06 00 00 00       	mov    $0x6,%eax
  f3:	cd 40                	int    $0x40
  f5:	c3                   	ret    

000000f6 <exec>:
SYSCALL(exec)
  f6:	b8 07 00 00 00       	mov    $0x7,%eax
  fb:	cd 40                	int    $0x40
  fd:	c3                   	ret    

000000fe <open>:
SYSCALL(open)
  fe:	b8 0f 00 00 00       	mov    $0xf,%eax
 103:	cd 40                	int    $0x40
 105:	c3                   	ret    

00000106 <mknod>:
SYSCALL(mknod)
 106:	b8 11 00 00 00       	mov    $0x11,%eax
 10b:	cd 40                	int    $0x40
 10d:	c3                   	ret    

0000010e <unlink>:
SYSCALL(unlink)
 10e:	b8 12 00 00 00       	mov    $0x12,%eax
 113:	cd 40                	int    $0x40
 115:	c3                   	ret    

00000116 <fstat>:
SYSCALL(fstat)
 116:	b8 08 00 00 00       	mov    $0x8,%eax
 11b:	cd 40                	int    $0x40
 11d:	c3                   	ret    

0000011e <link>:
SYSCALL(link)
 11e:	b8 13 00 00 00       	mov    $0x13,%eax
 123:	cd 40                	int    $0x40
 125:	c3                   	ret    

00000126 <mkdir>:
SYSCALL(mkdir)
 126:	b8 14 00 00 00       	mov    $0x14,%eax
 12b:	cd 40                	int    $0x40
 12d:	c3                   	ret    

0000012e <chdir>:
SYSCALL(chdir)
 12e:	b8 09 00 00 00       	mov    $0x9,%eax
 133:	cd 40                	int    $0x40
 135:	c3                   	ret    

00000136 <dup>:
SYSCALL(dup)
 136:	b8 0a 00 00 00       	mov    $0xa,%eax
 13b:	cd 40                	int    $0x40
 13d:	c3                   	ret    

0000013e <getpid>:
SYSCALL(getpid)
 13e:	b8 0b 00 00 00       	mov    $0xb,%eax
 143:	cd 40                	int    $0x40
 145:	c3                   	ret    

00000146 <sbrk>:
SYSCALL(sbrk)
 146:	b8 0c 00 00 00       	mov    $0xc,%eax
 14b:	cd 40                	int    $0x40
 14d:	c3                   	ret    

0000014e <sleep>:
SYSCALL(sleep)
 14e:	b8 0d 00 00 00       	mov    $0xd,%eax
 153:	cd 40                	int    $0x40
 155:	c3                   	ret    

00000156 <uptime>:
SYSCALL(uptime)
 156:	b8 0e 00 00 00       	mov    $0xe,%eax
 15b:	cd 40                	int    $0x40
 15d:	c3                   	ret    

0000015e <yield>:
SYSCALL(yield)
 15e:	b8 16 00 00 00       	mov    $0x16,%eax
 163:	cd 40                	int    $0x40
 165:	c3                   	ret    

00000166 <shutdown>:
SYSCALL(shutdown)
 166:	b8 17 00 00 00       	mov    $0x17,%eax
 16b:	cd 40                	int    $0x40
 16d:	c3                   	ret    

0000016e <ps>:
SYSCALL(ps)
 16e:	b8 18 00 00 00       	mov    $0x18,%eax
 173:	cd 40                	int    $0x40
 175:	c3                   	ret    

00000176 <nice>:
SYSCALL(nice)
 176:	b8 1b 00 00 00       	mov    $0x1b,%eax
 17b:	cd 40                	int    $0x40
 17d:	c3                   	ret    

0000017e <flock>:
SYSCALL(flock)
 17e:	b8 19 00 00 00       	mov    $0x19,%eax
 183:	cd 40                	int    $0x40
 185:	c3                   	ret    

00000186 <funlock>:
SYSCALL(funlock)
 186:	b8 1a 00 00 00       	mov    $0x1a,%eax
 18b:	cd 40                	int    $0x40
 18d:	c3                   	ret    

0000018e <s_sputc>:
  write(fd, &c, 1);
}

// store c at index within outbuffer if index is less than length
void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
 18e:	f3 0f 1e fb          	endbr32 
 192:	55                   	push   %ebp
 193:	89 e5                	mov    %esp,%ebp
 195:	8b 45 14             	mov    0x14(%ebp),%eax
 198:	8b 55 18             	mov    0x18(%ebp),%edx
  if(index < length)
 19b:	3b 45 10             	cmp    0x10(%ebp),%eax
 19e:	73 06                	jae    1a6 <s_sputc+0x18>
  {
    outbuffer[index] = c;
 1a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 1a3:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  }
}
 1a6:	5d                   	pop    %ebp
 1a7:	c3                   	ret    

000001a8 <s_getReverseDigits>:
// "most significant digit on teh left" representation. At most length
// characters are written to outbuf.
// \return the number of characters written to outbuf
static uint 
s_getReverseDigits(char *outbuf, uint length, int xx, int base, int sgn)
{
 1a8:	55                   	push   %ebp
 1a9:	89 e5                	mov    %esp,%ebp
 1ab:	57                   	push   %edi
 1ac:	56                   	push   %esi
 1ad:	53                   	push   %ebx
 1ae:	83 ec 08             	sub    $0x8,%esp
 1b1:	89 c6                	mov    %eax,%esi
 1b3:	89 d3                	mov    %edx,%ebx
 1b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  static char digits[] = "0123456789ABCDEF";
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 1bc:	0f 95 c2             	setne  %dl
 1bf:	89 c8                	mov    %ecx,%eax
 1c1:	c1 e8 1f             	shr    $0x1f,%eax
 1c4:	84 c2                	test   %al,%dl
 1c6:	74 33                	je     1fb <s_getReverseDigits+0x53>
    neg = 1;
    x = -xx;
 1c8:	89 c8                	mov    %ecx,%eax
 1ca:	f7 d8                	neg    %eax
    neg = 1;
 1cc:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 1d3:	bf 00 00 00 00       	mov    $0x0,%edi
  while(i + 1 < length && x != 0) {
 1d8:	8d 4f 01             	lea    0x1(%edi),%ecx
 1db:	89 ca                	mov    %ecx,%edx
 1dd:	39 d9                	cmp    %ebx,%ecx
 1df:	73 26                	jae    207 <s_getReverseDigits+0x5f>
 1e1:	85 c0                	test   %eax,%eax
 1e3:	74 22                	je     207 <s_getReverseDigits+0x5f>
    outbuf[i++] = digits[x % base];
 1e5:	ba 00 00 00 00       	mov    $0x0,%edx
 1ea:	f7 75 08             	divl   0x8(%ebp)
 1ed:	0f b6 92 b4 05 00 00 	movzbl 0x5b4(%edx),%edx
 1f4:	88 14 3e             	mov    %dl,(%esi,%edi,1)
 1f7:	89 cf                	mov    %ecx,%edi
 1f9:	eb dd                	jmp    1d8 <s_getReverseDigits+0x30>
    x = xx;
 1fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  neg = 0;
 1fe:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 205:	eb cc                	jmp    1d3 <s_getReverseDigits+0x2b>
    x /= base;
  }

  if(0 == xx && i + 1 < length) {
 207:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 20b:	75 0a                	jne    217 <s_getReverseDigits+0x6f>
 20d:	39 da                	cmp    %ebx,%edx
 20f:	73 06                	jae    217 <s_getReverseDigits+0x6f>
    outbuf[i++] = digits[0];   
 211:	c6 04 3e 30          	movb   $0x30,(%esi,%edi,1)
 215:	89 cf                	mov    %ecx,%edi
  }

  if(neg && i < length) {
 217:	89 fa                	mov    %edi,%edx
 219:	39 df                	cmp    %ebx,%edi
 21b:	0f 92 c0             	setb   %al
 21e:	84 45 ec             	test   %al,-0x14(%ebp)
 221:	74 07                	je     22a <s_getReverseDigits+0x82>
    outbuf[i++] = '-';
 223:	83 c7 01             	add    $0x1,%edi
 226:	c6 04 16 2d          	movb   $0x2d,(%esi,%edx,1)
  }

  return i;
}
 22a:	89 f8                	mov    %edi,%eax
 22c:	83 c4 08             	add    $0x8,%esp
 22f:	5b                   	pop    %ebx
 230:	5e                   	pop    %esi
 231:	5f                   	pop    %edi
 232:	5d                   	pop    %ebp
 233:	c3                   	ret    

00000234 <s_min>:
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
 234:	39 c2                	cmp    %eax,%edx
 236:	0f 46 c2             	cmovbe %edx,%eax
}
 239:	c3                   	ret    

0000023a <s_printint>:
{
 23a:	55                   	push   %ebp
 23b:	89 e5                	mov    %esp,%ebp
 23d:	57                   	push   %edi
 23e:	56                   	push   %esi
 23f:	53                   	push   %ebx
 240:	83 ec 2c             	sub    $0x2c,%esp
 243:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 246:	89 55 d0             	mov    %edx,-0x30(%ebp)
 249:	89 4d cc             	mov    %ecx,-0x34(%ebp)
 24c:	8b 7d 08             	mov    0x8(%ebp),%edi
  s_getReverseDigits(localBuffer, localBufferLength, xx, base, sgn);
 24f:	ff 75 14             	pushl  0x14(%ebp)
 252:	ff 75 10             	pushl  0x10(%ebp)
 255:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 258:	ba 10 00 00 00       	mov    $0x10,%edx
 25d:	8d 45 d8             	lea    -0x28(%ebp),%eax
 260:	e8 43 ff ff ff       	call   1a8 <s_getReverseDigits>
 265:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int i = result;
 268:	89 c3                	mov    %eax,%ebx
  while(--i >= 0 && j < length) 
 26a:	83 c4 08             	add    $0x8,%esp
  int j = 0;
 26d:	be 00 00 00 00       	mov    $0x0,%esi
  while(--i >= 0 && j < length) 
 272:	83 eb 01             	sub    $0x1,%ebx
 275:	78 22                	js     299 <s_printint+0x5f>
 277:	39 fe                	cmp    %edi,%esi
 279:	73 1e                	jae    299 <s_printint+0x5f>
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
 27b:	83 ec 0c             	sub    $0xc,%esp
 27e:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
 283:	50                   	push   %eax
 284:	56                   	push   %esi
 285:	57                   	push   %edi
 286:	ff 75 cc             	pushl  -0x34(%ebp)
 289:	ff 75 d0             	pushl  -0x30(%ebp)
 28c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 28f:	ff d0                	call   *%eax
    j++;
 291:	83 c6 01             	add    $0x1,%esi
 294:	83 c4 20             	add    $0x20,%esp
 297:	eb d9                	jmp    272 <s_printint+0x38>
}
 299:	8b 45 c8             	mov    -0x38(%ebp),%eax
 29c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 29f:	5b                   	pop    %ebx
 2a0:	5e                   	pop    %esi
 2a1:	5f                   	pop    %edi
 2a2:	5d                   	pop    %ebp
 2a3:	c3                   	ret    

000002a4 <s_printf>:

static 
int s_printf(putFunction_t putcFunction, int fd, char *outbuffer, int n, const char *fmt, uint* ap)
{
 2a4:	55                   	push   %ebp
 2a5:	89 e5                	mov    %esp,%ebp
 2a7:	57                   	push   %edi
 2a8:	56                   	push   %esi
 2a9:	53                   	push   %ebx
 2aa:	83 ec 2c             	sub    $0x2c,%esp
 2ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
 2b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 2b3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  char *s;
  int c, i, state;
  uint outindex = 0;
  const int length = n -1; // leave room for nul termination
 2b6:	8b 45 08             	mov    0x8(%ebp),%eax
 2b9:	8d 78 ff             	lea    -0x1(%eax),%edi

  state = 0;
 2bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(i = 0; fmt[i] && outindex < length; i++) {
 2c3:	bb 00 00 00 00       	mov    $0x0,%ebx
 2c8:	89 f8                	mov    %edi,%eax
 2ca:	89 df                	mov    %ebx,%edi
 2cc:	89 c6                	mov    %eax,%esi
 2ce:	eb 20                	jmp    2f0 <s_printf+0x4c>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%') {
        state = '%';
      } else {
        putcFunction(fd, outbuffer, length, outindex++, c);
 2d0:	8d 43 01             	lea    0x1(%ebx),%eax
 2d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
 2d6:	83 ec 0c             	sub    $0xc,%esp
 2d9:	51                   	push   %ecx
 2da:	53                   	push   %ebx
 2db:	56                   	push   %esi
 2dc:	ff 75 d0             	pushl  -0x30(%ebp)
 2df:	ff 75 d4             	pushl  -0x2c(%ebp)
 2e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
 2e5:	ff d2                	call   *%edx
 2e7:	83 c4 20             	add    $0x20,%esp
 2ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  for(i = 0; fmt[i] && outindex < length; i++) {
 2ed:	83 c7 01             	add    $0x1,%edi
 2f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f3:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
 2f7:	84 c0                	test   %al,%al
 2f9:	0f 84 cd 01 00 00    	je     4cc <s_printf+0x228>
 2ff:	89 75 e0             	mov    %esi,-0x20(%ebp)
 302:	39 de                	cmp    %ebx,%esi
 304:	0f 86 c2 01 00 00    	jbe    4cc <s_printf+0x228>
    c = fmt[i] & 0xff;
 30a:	0f be c8             	movsbl %al,%ecx
 30d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
 310:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 313:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 317:	75 0a                	jne    323 <s_printf+0x7f>
      if(c == '%') {
 319:	83 f8 25             	cmp    $0x25,%eax
 31c:	75 b2                	jne    2d0 <s_printf+0x2c>
        state = '%';
 31e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 321:	eb ca                	jmp    2ed <s_printf+0x49>
      }
    } else if(state == '%'){
 323:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 327:	75 c4                	jne    2ed <s_printf+0x49>
      if(c == 'd'){
 329:	83 f8 64             	cmp    $0x64,%eax
 32c:	74 6e                	je     39c <s_printf+0xf8>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 32e:	83 f8 78             	cmp    $0x78,%eax
 331:	0f 94 c1             	sete   %cl
 334:	83 f8 70             	cmp    $0x70,%eax
 337:	0f 94 c2             	sete   %dl
 33a:	08 d1                	or     %dl,%cl
 33c:	0f 85 8e 00 00 00    	jne    3d0 <s_printf+0x12c>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 342:	83 f8 73             	cmp    $0x73,%eax
 345:	0f 84 b9 00 00 00    	je     404 <s_printf+0x160>
          s = "(null)";
        while(*s != 0){
          putcFunction(fd, outbuffer, length, outindex++, *s);
          s++;
        }
      } else if(c == 'c'){
 34b:	83 f8 63             	cmp    $0x63,%eax
 34e:	0f 84 1a 01 00 00    	je     46e <s_printf+0x1ca>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
        ap++;
      } else if(c == '%'){
 354:	83 f8 25             	cmp    $0x25,%eax
 357:	0f 84 44 01 00 00    	je     4a1 <s_printf+0x1fd>
        putcFunction(fd, outbuffer, length, outindex++, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putcFunction(fd, outbuffer, length, outindex++, '%');
 35d:	8d 43 01             	lea    0x1(%ebx),%eax
 360:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 363:	83 ec 0c             	sub    $0xc,%esp
 366:	6a 25                	push   $0x25
 368:	53                   	push   %ebx
 369:	56                   	push   %esi
 36a:	ff 75 d0             	pushl  -0x30(%ebp)
 36d:	ff 75 d4             	pushl  -0x2c(%ebp)
 370:	8b 45 d8             	mov    -0x28(%ebp),%eax
 373:	ff d0                	call   *%eax
        putcFunction(fd, outbuffer, length, outindex++, c);
 375:	83 c3 02             	add    $0x2,%ebx
 378:	83 c4 14             	add    $0x14,%esp
 37b:	ff 75 dc             	pushl  -0x24(%ebp)
 37e:	ff 75 e4             	pushl  -0x1c(%ebp)
 381:	56                   	push   %esi
 382:	ff 75 d0             	pushl  -0x30(%ebp)
 385:	ff 75 d4             	pushl  -0x2c(%ebp)
 388:	8b 45 d8             	mov    -0x28(%ebp),%eax
 38b:	ff d0                	call   *%eax
 38d:	83 c4 20             	add    $0x20,%esp
      }
      state = 0;
 390:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 397:	e9 51 ff ff ff       	jmp    2ed <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
 39c:	8b 45 d0             	mov    -0x30(%ebp),%eax
 39f:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 3a2:	6a 01                	push   $0x1
 3a4:	6a 0a                	push   $0xa
 3a6:	8b 45 10             	mov    0x10(%ebp),%eax
 3a9:	ff 30                	pushl  (%eax)
 3ab:	89 f0                	mov    %esi,%eax
 3ad:	29 d8                	sub    %ebx,%eax
 3af:	50                   	push   %eax
 3b0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 3b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
 3b6:	e8 7f fe ff ff       	call   23a <s_printint>
 3bb:	01 c3                	add    %eax,%ebx
        ap++;
 3bd:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 3c1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 3cb:	e9 1d ff ff ff       	jmp    2ed <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
 3d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3d3:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 3d6:	6a 00                	push   $0x0
 3d8:	6a 10                	push   $0x10
 3da:	8b 45 10             	mov    0x10(%ebp),%eax
 3dd:	ff 30                	pushl  (%eax)
 3df:	89 f0                	mov    %esi,%eax
 3e1:	29 d8                	sub    %ebx,%eax
 3e3:	50                   	push   %eax
 3e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 3e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
 3ea:	e8 4b fe ff ff       	call   23a <s_printint>
 3ef:	01 c3                	add    %eax,%ebx
        ap++;
 3f1:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 3f5:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3f8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 3ff:	e9 e9 fe ff ff       	jmp    2ed <s_printf+0x49>
        s = (char*)*ap;
 404:	8b 45 10             	mov    0x10(%ebp),%eax
 407:	8b 00                	mov    (%eax),%eax
        ap++;
 409:	83 45 10 04          	addl   $0x4,0x10(%ebp)
        if(s == 0)
 40d:	85 c0                	test   %eax,%eax
 40f:	75 4e                	jne    45f <s_printf+0x1bb>
          s = "(null)";
 411:	b8 ac 05 00 00       	mov    $0x5ac,%eax
 416:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 419:	89 da                	mov    %ebx,%edx
 41b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 41e:	89 75 e0             	mov    %esi,-0x20(%ebp)
 421:	89 c6                	mov    %eax,%esi
 423:	eb 1f                	jmp    444 <s_printf+0x1a0>
          putcFunction(fd, outbuffer, length, outindex++, *s);
 425:	8d 7a 01             	lea    0x1(%edx),%edi
 428:	83 ec 0c             	sub    $0xc,%esp
 42b:	0f be c0             	movsbl %al,%eax
 42e:	50                   	push   %eax
 42f:	52                   	push   %edx
 430:	53                   	push   %ebx
 431:	ff 75 d0             	pushl  -0x30(%ebp)
 434:	ff 75 d4             	pushl  -0x2c(%ebp)
 437:	8b 45 d8             	mov    -0x28(%ebp),%eax
 43a:	ff d0                	call   *%eax
          s++;
 43c:	83 c6 01             	add    $0x1,%esi
 43f:	83 c4 20             	add    $0x20,%esp
          putcFunction(fd, outbuffer, length, outindex++, *s);
 442:	89 fa                	mov    %edi,%edx
        while(*s != 0){
 444:	0f b6 06             	movzbl (%esi),%eax
 447:	84 c0                	test   %al,%al
 449:	75 da                	jne    425 <s_printf+0x181>
 44b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 44e:	89 d3                	mov    %edx,%ebx
 450:	8b 75 e0             	mov    -0x20(%ebp),%esi
      state = 0;
 453:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 45a:	e9 8e fe ff ff       	jmp    2ed <s_printf+0x49>
 45f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 462:	89 da                	mov    %ebx,%edx
 464:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 467:	89 75 e0             	mov    %esi,-0x20(%ebp)
 46a:	89 c6                	mov    %eax,%esi
 46c:	eb d6                	jmp    444 <s_printf+0x1a0>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 46e:	8d 43 01             	lea    0x1(%ebx),%eax
 471:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 474:	83 ec 0c             	sub    $0xc,%esp
 477:	8b 55 10             	mov    0x10(%ebp),%edx
 47a:	0f be 02             	movsbl (%edx),%eax
 47d:	50                   	push   %eax
 47e:	53                   	push   %ebx
 47f:	56                   	push   %esi
 480:	ff 75 d0             	pushl  -0x30(%ebp)
 483:	ff 75 d4             	pushl  -0x2c(%ebp)
 486:	8b 55 d8             	mov    -0x28(%ebp),%edx
 489:	ff d2                	call   *%edx
        ap++;
 48b:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 48f:	83 c4 20             	add    $0x20,%esp
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 492:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 495:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 49c:	e9 4c fe ff ff       	jmp    2ed <s_printf+0x49>
        putcFunction(fd, outbuffer, length, outindex++, c);
 4a1:	8d 43 01             	lea    0x1(%ebx),%eax
 4a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 4a7:	83 ec 0c             	sub    $0xc,%esp
 4aa:	ff 75 dc             	pushl  -0x24(%ebp)
 4ad:	53                   	push   %ebx
 4ae:	56                   	push   %esi
 4af:	ff 75 d0             	pushl  -0x30(%ebp)
 4b2:	ff 75 d4             	pushl  -0x2c(%ebp)
 4b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
 4b8:	ff d2                	call   *%edx
 4ba:	83 c4 20             	add    $0x20,%esp
 4bd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 4c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 4c7:	e9 21 fe ff ff       	jmp    2ed <s_printf+0x49>
    }
  }
  
  return s_min(length, outindex);
 4cc:	89 da                	mov    %ebx,%edx
 4ce:	89 f0                	mov    %esi,%eax
 4d0:	e8 5f fd ff ff       	call   234 <s_min>
}
 4d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4d8:	5b                   	pop    %ebx
 4d9:	5e                   	pop    %esi
 4da:	5f                   	pop    %edi
 4db:	5d                   	pop    %ebp
 4dc:	c3                   	ret    

000004dd <s_putc>:
{
 4dd:	f3 0f 1e fb          	endbr32 
 4e1:	55                   	push   %ebp
 4e2:	89 e5                	mov    %esp,%ebp
 4e4:	83 ec 1c             	sub    $0x1c,%esp
 4e7:	8b 45 18             	mov    0x18(%ebp),%eax
 4ea:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4ed:	6a 01                	push   $0x1
 4ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4f2:	50                   	push   %eax
 4f3:	ff 75 08             	pushl  0x8(%ebp)
 4f6:	e8 e3 fb ff ff       	call   de <write>
}
 4fb:	83 c4 10             	add    $0x10,%esp
 4fe:	c9                   	leave  
 4ff:	c3                   	ret    

00000500 <snprintf>:
// Print into outbuffer at most n characters. Only understands %d, %x, %p, %s.
// If n is greater than 0, a terminating nul is always stored in outbuffer.
// \return the number of characters written to outbuffer not counting the
// terminating nul.
int snprintf(char *outbuffer, int n, const char *fmt, ...)
{
 500:	f3 0f 1e fb          	endbr32 
 504:	55                   	push   %ebp
 505:	89 e5                	mov    %esp,%ebp
 507:	56                   	push   %esi
 508:	53                   	push   %ebx
 509:	8b 75 08             	mov    0x8(%ebp),%esi
 50c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint* ap = (uint*)(void*)&fmt + 1;
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
 50f:	83 ec 04             	sub    $0x4,%esp
 512:	8d 45 14             	lea    0x14(%ebp),%eax
 515:	50                   	push   %eax
 516:	ff 75 10             	pushl  0x10(%ebp)
 519:	53                   	push   %ebx
 51a:	89 f1                	mov    %esi,%ecx
 51c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
 521:	b8 8e 01 00 00       	mov    $0x18e,%eax
 526:	e8 79 fd ff ff       	call   2a4 <s_printf>
  if(count < n) {
 52b:	83 c4 10             	add    $0x10,%esp
 52e:	39 c3                	cmp    %eax,%ebx
 530:	76 04                	jbe    536 <snprintf+0x36>
    outbuffer[count] = 0; // Assure nul termination
 532:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
  } 

  return count;
}
 536:	8d 65 f8             	lea    -0x8(%ebp),%esp
 539:	5b                   	pop    %ebx
 53a:	5e                   	pop    %esi
 53b:	5d                   	pop    %ebp
 53c:	c3                   	ret    

0000053d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 53d:	f3 0f 1e fb          	endbr32 
 541:	55                   	push   %ebp
 542:	89 e5                	mov    %esp,%ebp
 544:	83 ec 0c             	sub    $0xc,%esp
  static const uint veryLarge = 1<<30;
  uint* ap = (uint*)(void*)&fmt + 1;
  s_printf(s_putc, fd, 0, veryLarge, fmt, ap);
 547:	8d 45 10             	lea    0x10(%ebp),%eax
 54a:	50                   	push   %eax
 54b:	ff 75 0c             	pushl  0xc(%ebp)
 54e:	68 00 00 00 40       	push   $0x40000000
 553:	b9 00 00 00 00       	mov    $0x0,%ecx
 558:	8b 55 08             	mov    0x8(%ebp),%edx
 55b:	b8 dd 04 00 00       	mov    $0x4dd,%eax
 560:	e8 3f fd ff ff       	call   2a4 <s_printf>
}
 565:	83 c4 10             	add    $0x10,%esp
 568:	c9                   	leave  
 569:	c3                   	ret    
