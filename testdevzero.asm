
_testdevzero:     file format elf32-i386


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
  12:	53                   	push   %ebx
  13:	51                   	push   %ecx
  14:	81 ec 14 02 00 00    	sub    $0x214,%esp
    int fd = open("dev/zero", O_RDONLY);
  1a:	6a 00                	push   $0x0
  1c:	68 48 05 00 00       	push   $0x548
  21:	e8 b6 00 00 00       	call   dc <open>
    if(0 > fd) {
  26:	83 c4 10             	add    $0x10,%esp
  29:	85 c0                	test   %eax,%eax
  2b:	78 53                	js     80 <main+0x80>
  2d:	89 c3                	mov    %eax,%ebx
        printf(2, "Error: Cannot open dzero\n");
    }
    else {
        char buffer[512] = {'\0'};
  2f:	c7 85 e8 fd ff ff 00 	movl   $0x0,-0x218(%ebp)
  36:	00 00 00 
  39:	8d bd ec fd ff ff    	lea    -0x214(%ebp),%edi
  3f:	b9 7f 00 00 00       	mov    $0x7f,%ecx
  44:	b8 00 00 00 00       	mov    $0x0,%eax
  49:	f3 ab                	rep stos %eax,%es:(%edi)
        read(fd, buffer, 512);
  4b:	83 ec 04             	sub    $0x4,%esp
  4e:	68 00 02 00 00       	push   $0x200
  53:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
  59:	57                   	push   %edi
  5a:	53                   	push   %ebx
  5b:	e8 54 00 00 00       	call   b4 <read>
        printf(1, "Read <%s>\n", buffer);
  60:	83 c4 0c             	add    $0xc,%esp
  63:	57                   	push   %edi
  64:	68 6b 05 00 00       	push   $0x56b
  69:	6a 01                	push   $0x1
  6b:	e8 ab 04 00 00       	call   51b <printf>
        close(fd);
  70:	89 1c 24             	mov    %ebx,(%esp)
  73:	e8 4c 00 00 00       	call   c4 <close>
        fd = -1;
  78:	83 c4 10             	add    $0x10,%esp
    }
    exit();
  7b:	e8 1c 00 00 00       	call   9c <exit>
        printf(2, "Error: Cannot open dzero\n");
  80:	83 ec 08             	sub    $0x8,%esp
  83:	68 51 05 00 00       	push   $0x551
  88:	6a 02                	push   $0x2
  8a:	e8 8c 04 00 00       	call   51b <printf>
  8f:	83 c4 10             	add    $0x10,%esp
  92:	eb e7                	jmp    7b <main+0x7b>

00000094 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  94:	b8 01 00 00 00       	mov    $0x1,%eax
  99:	cd 40                	int    $0x40
  9b:	c3                   	ret    

0000009c <exit>:
SYSCALL(exit)
  9c:	b8 02 00 00 00       	mov    $0x2,%eax
  a1:	cd 40                	int    $0x40
  a3:	c3                   	ret    

000000a4 <wait>:
SYSCALL(wait)
  a4:	b8 03 00 00 00       	mov    $0x3,%eax
  a9:	cd 40                	int    $0x40
  ab:	c3                   	ret    

000000ac <pipe>:
SYSCALL(pipe)
  ac:	b8 04 00 00 00       	mov    $0x4,%eax
  b1:	cd 40                	int    $0x40
  b3:	c3                   	ret    

000000b4 <read>:
SYSCALL(read)
  b4:	b8 05 00 00 00       	mov    $0x5,%eax
  b9:	cd 40                	int    $0x40
  bb:	c3                   	ret    

000000bc <write>:
SYSCALL(write)
  bc:	b8 10 00 00 00       	mov    $0x10,%eax
  c1:	cd 40                	int    $0x40
  c3:	c3                   	ret    

000000c4 <close>:
SYSCALL(close)
  c4:	b8 15 00 00 00       	mov    $0x15,%eax
  c9:	cd 40                	int    $0x40
  cb:	c3                   	ret    

000000cc <kill>:
SYSCALL(kill)
  cc:	b8 06 00 00 00       	mov    $0x6,%eax
  d1:	cd 40                	int    $0x40
  d3:	c3                   	ret    

000000d4 <exec>:
SYSCALL(exec)
  d4:	b8 07 00 00 00       	mov    $0x7,%eax
  d9:	cd 40                	int    $0x40
  db:	c3                   	ret    

000000dc <open>:
SYSCALL(open)
  dc:	b8 0f 00 00 00       	mov    $0xf,%eax
  e1:	cd 40                	int    $0x40
  e3:	c3                   	ret    

000000e4 <mknod>:
SYSCALL(mknod)
  e4:	b8 11 00 00 00       	mov    $0x11,%eax
  e9:	cd 40                	int    $0x40
  eb:	c3                   	ret    

000000ec <unlink>:
SYSCALL(unlink)
  ec:	b8 12 00 00 00       	mov    $0x12,%eax
  f1:	cd 40                	int    $0x40
  f3:	c3                   	ret    

000000f4 <fstat>:
SYSCALL(fstat)
  f4:	b8 08 00 00 00       	mov    $0x8,%eax
  f9:	cd 40                	int    $0x40
  fb:	c3                   	ret    

000000fc <link>:
SYSCALL(link)
  fc:	b8 13 00 00 00       	mov    $0x13,%eax
 101:	cd 40                	int    $0x40
 103:	c3                   	ret    

00000104 <mkdir>:
SYSCALL(mkdir)
 104:	b8 14 00 00 00       	mov    $0x14,%eax
 109:	cd 40                	int    $0x40
 10b:	c3                   	ret    

0000010c <chdir>:
SYSCALL(chdir)
 10c:	b8 09 00 00 00       	mov    $0x9,%eax
 111:	cd 40                	int    $0x40
 113:	c3                   	ret    

00000114 <dup>:
SYSCALL(dup)
 114:	b8 0a 00 00 00       	mov    $0xa,%eax
 119:	cd 40                	int    $0x40
 11b:	c3                   	ret    

0000011c <getpid>:
SYSCALL(getpid)
 11c:	b8 0b 00 00 00       	mov    $0xb,%eax
 121:	cd 40                	int    $0x40
 123:	c3                   	ret    

00000124 <sbrk>:
SYSCALL(sbrk)
 124:	b8 0c 00 00 00       	mov    $0xc,%eax
 129:	cd 40                	int    $0x40
 12b:	c3                   	ret    

0000012c <sleep>:
SYSCALL(sleep)
 12c:	b8 0d 00 00 00       	mov    $0xd,%eax
 131:	cd 40                	int    $0x40
 133:	c3                   	ret    

00000134 <uptime>:
SYSCALL(uptime)
 134:	b8 0e 00 00 00       	mov    $0xe,%eax
 139:	cd 40                	int    $0x40
 13b:	c3                   	ret    

0000013c <yield>:
SYSCALL(yield)
 13c:	b8 16 00 00 00       	mov    $0x16,%eax
 141:	cd 40                	int    $0x40
 143:	c3                   	ret    

00000144 <shutdown>:
SYSCALL(shutdown)
 144:	b8 17 00 00 00       	mov    $0x17,%eax
 149:	cd 40                	int    $0x40
 14b:	c3                   	ret    

0000014c <ps>:
SYSCALL(ps)
 14c:	b8 18 00 00 00       	mov    $0x18,%eax
 151:	cd 40                	int    $0x40
 153:	c3                   	ret    

00000154 <nice>:
SYSCALL(nice)
 154:	b8 1b 00 00 00       	mov    $0x1b,%eax
 159:	cd 40                	int    $0x40
 15b:	c3                   	ret    

0000015c <flock>:
SYSCALL(flock)
 15c:	b8 19 00 00 00       	mov    $0x19,%eax
 161:	cd 40                	int    $0x40
 163:	c3                   	ret    

00000164 <funlock>:
SYSCALL(funlock)
 164:	b8 1a 00 00 00       	mov    $0x1a,%eax
 169:	cd 40                	int    $0x40
 16b:	c3                   	ret    

0000016c <s_sputc>:
  write(fd, &c, 1);
}

// store c at index within outbuffer if index is less than length
void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
 16c:	f3 0f 1e fb          	endbr32 
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	8b 45 14             	mov    0x14(%ebp),%eax
 176:	8b 55 18             	mov    0x18(%ebp),%edx
  if(index < length)
 179:	3b 45 10             	cmp    0x10(%ebp),%eax
 17c:	73 06                	jae    184 <s_sputc+0x18>
  {
    outbuffer[index] = c;
 17e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 181:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  }
}
 184:	5d                   	pop    %ebp
 185:	c3                   	ret    

00000186 <s_getReverseDigits>:
// "most significant digit on teh left" representation. At most length
// characters are written to outbuf.
// \return the number of characters written to outbuf
static uint 
s_getReverseDigits(char *outbuf, uint length, int xx, int base, int sgn)
{
 186:	55                   	push   %ebp
 187:	89 e5                	mov    %esp,%ebp
 189:	57                   	push   %edi
 18a:	56                   	push   %esi
 18b:	53                   	push   %ebx
 18c:	83 ec 08             	sub    $0x8,%esp
 18f:	89 c6                	mov    %eax,%esi
 191:	89 d3                	mov    %edx,%ebx
 193:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  static char digits[] = "0123456789ABCDEF";
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 196:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 19a:	0f 95 c2             	setne  %dl
 19d:	89 c8                	mov    %ecx,%eax
 19f:	c1 e8 1f             	shr    $0x1f,%eax
 1a2:	84 c2                	test   %al,%dl
 1a4:	74 33                	je     1d9 <s_getReverseDigits+0x53>
    neg = 1;
    x = -xx;
 1a6:	89 c8                	mov    %ecx,%eax
 1a8:	f7 d8                	neg    %eax
    neg = 1;
 1aa:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 1b1:	bf 00 00 00 00       	mov    $0x0,%edi
  while(i + 1 < length && x != 0) {
 1b6:	8d 4f 01             	lea    0x1(%edi),%ecx
 1b9:	89 ca                	mov    %ecx,%edx
 1bb:	39 d9                	cmp    %ebx,%ecx
 1bd:	73 26                	jae    1e5 <s_getReverseDigits+0x5f>
 1bf:	85 c0                	test   %eax,%eax
 1c1:	74 22                	je     1e5 <s_getReverseDigits+0x5f>
    outbuf[i++] = digits[x % base];
 1c3:	ba 00 00 00 00       	mov    $0x0,%edx
 1c8:	f7 75 08             	divl   0x8(%ebp)
 1cb:	0f b6 92 80 05 00 00 	movzbl 0x580(%edx),%edx
 1d2:	88 14 3e             	mov    %dl,(%esi,%edi,1)
 1d5:	89 cf                	mov    %ecx,%edi
 1d7:	eb dd                	jmp    1b6 <s_getReverseDigits+0x30>
    x = xx;
 1d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  neg = 0;
 1dc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 1e3:	eb cc                	jmp    1b1 <s_getReverseDigits+0x2b>
    x /= base;
  }

  if(0 == xx && i + 1 < length) {
 1e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1e9:	75 0a                	jne    1f5 <s_getReverseDigits+0x6f>
 1eb:	39 da                	cmp    %ebx,%edx
 1ed:	73 06                	jae    1f5 <s_getReverseDigits+0x6f>
    outbuf[i++] = digits[0];   
 1ef:	c6 04 3e 30          	movb   $0x30,(%esi,%edi,1)
 1f3:	89 cf                	mov    %ecx,%edi
  }

  if(neg && i < length) {
 1f5:	89 fa                	mov    %edi,%edx
 1f7:	39 df                	cmp    %ebx,%edi
 1f9:	0f 92 c0             	setb   %al
 1fc:	84 45 ec             	test   %al,-0x14(%ebp)
 1ff:	74 07                	je     208 <s_getReverseDigits+0x82>
    outbuf[i++] = '-';
 201:	83 c7 01             	add    $0x1,%edi
 204:	c6 04 16 2d          	movb   $0x2d,(%esi,%edx,1)
  }

  return i;
}
 208:	89 f8                	mov    %edi,%eax
 20a:	83 c4 08             	add    $0x8,%esp
 20d:	5b                   	pop    %ebx
 20e:	5e                   	pop    %esi
 20f:	5f                   	pop    %edi
 210:	5d                   	pop    %ebp
 211:	c3                   	ret    

00000212 <s_min>:
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
 212:	39 c2                	cmp    %eax,%edx
 214:	0f 46 c2             	cmovbe %edx,%eax
}
 217:	c3                   	ret    

00000218 <s_printint>:
{
 218:	55                   	push   %ebp
 219:	89 e5                	mov    %esp,%ebp
 21b:	57                   	push   %edi
 21c:	56                   	push   %esi
 21d:	53                   	push   %ebx
 21e:	83 ec 2c             	sub    $0x2c,%esp
 221:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 224:	89 55 d0             	mov    %edx,-0x30(%ebp)
 227:	89 4d cc             	mov    %ecx,-0x34(%ebp)
 22a:	8b 7d 08             	mov    0x8(%ebp),%edi
  s_getReverseDigits(localBuffer, localBufferLength, xx, base, sgn);
 22d:	ff 75 14             	pushl  0x14(%ebp)
 230:	ff 75 10             	pushl  0x10(%ebp)
 233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 236:	ba 10 00 00 00       	mov    $0x10,%edx
 23b:	8d 45 d8             	lea    -0x28(%ebp),%eax
 23e:	e8 43 ff ff ff       	call   186 <s_getReverseDigits>
 243:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int i = result;
 246:	89 c3                	mov    %eax,%ebx
  while(--i >= 0 && j < length) 
 248:	83 c4 08             	add    $0x8,%esp
  int j = 0;
 24b:	be 00 00 00 00       	mov    $0x0,%esi
  while(--i >= 0 && j < length) 
 250:	83 eb 01             	sub    $0x1,%ebx
 253:	78 22                	js     277 <s_printint+0x5f>
 255:	39 fe                	cmp    %edi,%esi
 257:	73 1e                	jae    277 <s_printint+0x5f>
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
 259:	83 ec 0c             	sub    $0xc,%esp
 25c:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
 261:	50                   	push   %eax
 262:	56                   	push   %esi
 263:	57                   	push   %edi
 264:	ff 75 cc             	pushl  -0x34(%ebp)
 267:	ff 75 d0             	pushl  -0x30(%ebp)
 26a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 26d:	ff d0                	call   *%eax
    j++;
 26f:	83 c6 01             	add    $0x1,%esi
 272:	83 c4 20             	add    $0x20,%esp
 275:	eb d9                	jmp    250 <s_printint+0x38>
}
 277:	8b 45 c8             	mov    -0x38(%ebp),%eax
 27a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 27d:	5b                   	pop    %ebx
 27e:	5e                   	pop    %esi
 27f:	5f                   	pop    %edi
 280:	5d                   	pop    %ebp
 281:	c3                   	ret    

00000282 <s_printf>:

static 
int s_printf(putFunction_t putcFunction, int fd, char *outbuffer, int n, const char *fmt, uint* ap)
{
 282:	55                   	push   %ebp
 283:	89 e5                	mov    %esp,%ebp
 285:	57                   	push   %edi
 286:	56                   	push   %esi
 287:	53                   	push   %ebx
 288:	83 ec 2c             	sub    $0x2c,%esp
 28b:	89 45 d8             	mov    %eax,-0x28(%ebp)
 28e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 291:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  char *s;
  int c, i, state;
  uint outindex = 0;
  const int length = n -1; // leave room for nul termination
 294:	8b 45 08             	mov    0x8(%ebp),%eax
 297:	8d 78 ff             	lea    -0x1(%eax),%edi

  state = 0;
 29a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(i = 0; fmt[i] && outindex < length; i++) {
 2a1:	bb 00 00 00 00       	mov    $0x0,%ebx
 2a6:	89 f8                	mov    %edi,%eax
 2a8:	89 df                	mov    %ebx,%edi
 2aa:	89 c6                	mov    %eax,%esi
 2ac:	eb 20                	jmp    2ce <s_printf+0x4c>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%') {
        state = '%';
      } else {
        putcFunction(fd, outbuffer, length, outindex++, c);
 2ae:	8d 43 01             	lea    0x1(%ebx),%eax
 2b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
 2b4:	83 ec 0c             	sub    $0xc,%esp
 2b7:	51                   	push   %ecx
 2b8:	53                   	push   %ebx
 2b9:	56                   	push   %esi
 2ba:	ff 75 d0             	pushl  -0x30(%ebp)
 2bd:	ff 75 d4             	pushl  -0x2c(%ebp)
 2c0:	8b 55 d8             	mov    -0x28(%ebp),%edx
 2c3:	ff d2                	call   *%edx
 2c5:	83 c4 20             	add    $0x20,%esp
 2c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  for(i = 0; fmt[i] && outindex < length; i++) {
 2cb:	83 c7 01             	add    $0x1,%edi
 2ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d1:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
 2d5:	84 c0                	test   %al,%al
 2d7:	0f 84 cd 01 00 00    	je     4aa <s_printf+0x228>
 2dd:	89 75 e0             	mov    %esi,-0x20(%ebp)
 2e0:	39 de                	cmp    %ebx,%esi
 2e2:	0f 86 c2 01 00 00    	jbe    4aa <s_printf+0x228>
    c = fmt[i] & 0xff;
 2e8:	0f be c8             	movsbl %al,%ecx
 2eb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
 2ee:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 2f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 2f5:	75 0a                	jne    301 <s_printf+0x7f>
      if(c == '%') {
 2f7:	83 f8 25             	cmp    $0x25,%eax
 2fa:	75 b2                	jne    2ae <s_printf+0x2c>
        state = '%';
 2fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 2ff:	eb ca                	jmp    2cb <s_printf+0x49>
      }
    } else if(state == '%'){
 301:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 305:	75 c4                	jne    2cb <s_printf+0x49>
      if(c == 'd'){
 307:	83 f8 64             	cmp    $0x64,%eax
 30a:	74 6e                	je     37a <s_printf+0xf8>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 30c:	83 f8 78             	cmp    $0x78,%eax
 30f:	0f 94 c1             	sete   %cl
 312:	83 f8 70             	cmp    $0x70,%eax
 315:	0f 94 c2             	sete   %dl
 318:	08 d1                	or     %dl,%cl
 31a:	0f 85 8e 00 00 00    	jne    3ae <s_printf+0x12c>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 320:	83 f8 73             	cmp    $0x73,%eax
 323:	0f 84 b9 00 00 00    	je     3e2 <s_printf+0x160>
          s = "(null)";
        while(*s != 0){
          putcFunction(fd, outbuffer, length, outindex++, *s);
          s++;
        }
      } else if(c == 'c'){
 329:	83 f8 63             	cmp    $0x63,%eax
 32c:	0f 84 1a 01 00 00    	je     44c <s_printf+0x1ca>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
        ap++;
      } else if(c == '%'){
 332:	83 f8 25             	cmp    $0x25,%eax
 335:	0f 84 44 01 00 00    	je     47f <s_printf+0x1fd>
        putcFunction(fd, outbuffer, length, outindex++, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putcFunction(fd, outbuffer, length, outindex++, '%');
 33b:	8d 43 01             	lea    0x1(%ebx),%eax
 33e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 341:	83 ec 0c             	sub    $0xc,%esp
 344:	6a 25                	push   $0x25
 346:	53                   	push   %ebx
 347:	56                   	push   %esi
 348:	ff 75 d0             	pushl  -0x30(%ebp)
 34b:	ff 75 d4             	pushl  -0x2c(%ebp)
 34e:	8b 45 d8             	mov    -0x28(%ebp),%eax
 351:	ff d0                	call   *%eax
        putcFunction(fd, outbuffer, length, outindex++, c);
 353:	83 c3 02             	add    $0x2,%ebx
 356:	83 c4 14             	add    $0x14,%esp
 359:	ff 75 dc             	pushl  -0x24(%ebp)
 35c:	ff 75 e4             	pushl  -0x1c(%ebp)
 35f:	56                   	push   %esi
 360:	ff 75 d0             	pushl  -0x30(%ebp)
 363:	ff 75 d4             	pushl  -0x2c(%ebp)
 366:	8b 45 d8             	mov    -0x28(%ebp),%eax
 369:	ff d0                	call   *%eax
 36b:	83 c4 20             	add    $0x20,%esp
      }
      state = 0;
 36e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 375:	e9 51 ff ff ff       	jmp    2cb <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
 37a:	8b 45 d0             	mov    -0x30(%ebp),%eax
 37d:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 380:	6a 01                	push   $0x1
 382:	6a 0a                	push   $0xa
 384:	8b 45 10             	mov    0x10(%ebp),%eax
 387:	ff 30                	pushl  (%eax)
 389:	89 f0                	mov    %esi,%eax
 38b:	29 d8                	sub    %ebx,%eax
 38d:	50                   	push   %eax
 38e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 391:	8b 45 d8             	mov    -0x28(%ebp),%eax
 394:	e8 7f fe ff ff       	call   218 <s_printint>
 399:	01 c3                	add    %eax,%ebx
        ap++;
 39b:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 39f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3a2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 3a9:	e9 1d ff ff ff       	jmp    2cb <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
 3ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3b1:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 3b4:	6a 00                	push   $0x0
 3b6:	6a 10                	push   $0x10
 3b8:	8b 45 10             	mov    0x10(%ebp),%eax
 3bb:	ff 30                	pushl  (%eax)
 3bd:	89 f0                	mov    %esi,%eax
 3bf:	29 d8                	sub    %ebx,%eax
 3c1:	50                   	push   %eax
 3c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 3c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
 3c8:	e8 4b fe ff ff       	call   218 <s_printint>
 3cd:	01 c3                	add    %eax,%ebx
        ap++;
 3cf:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 3d3:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 3dd:	e9 e9 fe ff ff       	jmp    2cb <s_printf+0x49>
        s = (char*)*ap;
 3e2:	8b 45 10             	mov    0x10(%ebp),%eax
 3e5:	8b 00                	mov    (%eax),%eax
        ap++;
 3e7:	83 45 10 04          	addl   $0x4,0x10(%ebp)
        if(s == 0)
 3eb:	85 c0                	test   %eax,%eax
 3ed:	75 4e                	jne    43d <s_printf+0x1bb>
          s = "(null)";
 3ef:	b8 76 05 00 00       	mov    $0x576,%eax
 3f4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3f7:	89 da                	mov    %ebx,%edx
 3f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 3fc:	89 75 e0             	mov    %esi,-0x20(%ebp)
 3ff:	89 c6                	mov    %eax,%esi
 401:	eb 1f                	jmp    422 <s_printf+0x1a0>
          putcFunction(fd, outbuffer, length, outindex++, *s);
 403:	8d 7a 01             	lea    0x1(%edx),%edi
 406:	83 ec 0c             	sub    $0xc,%esp
 409:	0f be c0             	movsbl %al,%eax
 40c:	50                   	push   %eax
 40d:	52                   	push   %edx
 40e:	53                   	push   %ebx
 40f:	ff 75 d0             	pushl  -0x30(%ebp)
 412:	ff 75 d4             	pushl  -0x2c(%ebp)
 415:	8b 45 d8             	mov    -0x28(%ebp),%eax
 418:	ff d0                	call   *%eax
          s++;
 41a:	83 c6 01             	add    $0x1,%esi
 41d:	83 c4 20             	add    $0x20,%esp
          putcFunction(fd, outbuffer, length, outindex++, *s);
 420:	89 fa                	mov    %edi,%edx
        while(*s != 0){
 422:	0f b6 06             	movzbl (%esi),%eax
 425:	84 c0                	test   %al,%al
 427:	75 da                	jne    403 <s_printf+0x181>
 429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 42c:	89 d3                	mov    %edx,%ebx
 42e:	8b 75 e0             	mov    -0x20(%ebp),%esi
      state = 0;
 431:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 438:	e9 8e fe ff ff       	jmp    2cb <s_printf+0x49>
 43d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 440:	89 da                	mov    %ebx,%edx
 442:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 445:	89 75 e0             	mov    %esi,-0x20(%ebp)
 448:	89 c6                	mov    %eax,%esi
 44a:	eb d6                	jmp    422 <s_printf+0x1a0>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 44c:	8d 43 01             	lea    0x1(%ebx),%eax
 44f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 452:	83 ec 0c             	sub    $0xc,%esp
 455:	8b 55 10             	mov    0x10(%ebp),%edx
 458:	0f be 02             	movsbl (%edx),%eax
 45b:	50                   	push   %eax
 45c:	53                   	push   %ebx
 45d:	56                   	push   %esi
 45e:	ff 75 d0             	pushl  -0x30(%ebp)
 461:	ff 75 d4             	pushl  -0x2c(%ebp)
 464:	8b 55 d8             	mov    -0x28(%ebp),%edx
 467:	ff d2                	call   *%edx
        ap++;
 469:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 46d:	83 c4 20             	add    $0x20,%esp
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 470:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 473:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 47a:	e9 4c fe ff ff       	jmp    2cb <s_printf+0x49>
        putcFunction(fd, outbuffer, length, outindex++, c);
 47f:	8d 43 01             	lea    0x1(%ebx),%eax
 482:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 485:	83 ec 0c             	sub    $0xc,%esp
 488:	ff 75 dc             	pushl  -0x24(%ebp)
 48b:	53                   	push   %ebx
 48c:	56                   	push   %esi
 48d:	ff 75 d0             	pushl  -0x30(%ebp)
 490:	ff 75 d4             	pushl  -0x2c(%ebp)
 493:	8b 55 d8             	mov    -0x28(%ebp),%edx
 496:	ff d2                	call   *%edx
 498:	83 c4 20             	add    $0x20,%esp
 49b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 49e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 4a5:	e9 21 fe ff ff       	jmp    2cb <s_printf+0x49>
    }
  }
  
  return s_min(length, outindex);
 4aa:	89 da                	mov    %ebx,%edx
 4ac:	89 f0                	mov    %esi,%eax
 4ae:	e8 5f fd ff ff       	call   212 <s_min>
}
 4b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4b6:	5b                   	pop    %ebx
 4b7:	5e                   	pop    %esi
 4b8:	5f                   	pop    %edi
 4b9:	5d                   	pop    %ebp
 4ba:	c3                   	ret    

000004bb <s_putc>:
{
 4bb:	f3 0f 1e fb          	endbr32 
 4bf:	55                   	push   %ebp
 4c0:	89 e5                	mov    %esp,%ebp
 4c2:	83 ec 1c             	sub    $0x1c,%esp
 4c5:	8b 45 18             	mov    0x18(%ebp),%eax
 4c8:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4cb:	6a 01                	push   $0x1
 4cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4d0:	50                   	push   %eax
 4d1:	ff 75 08             	pushl  0x8(%ebp)
 4d4:	e8 e3 fb ff ff       	call   bc <write>
}
 4d9:	83 c4 10             	add    $0x10,%esp
 4dc:	c9                   	leave  
 4dd:	c3                   	ret    

000004de <snprintf>:
// Print into outbuffer at most n characters. Only understands %d, %x, %p, %s.
// If n is greater than 0, a terminating nul is always stored in outbuffer.
// \return the number of characters written to outbuffer not counting the
// terminating nul.
int snprintf(char *outbuffer, int n, const char *fmt, ...)
{
 4de:	f3 0f 1e fb          	endbr32 
 4e2:	55                   	push   %ebp
 4e3:	89 e5                	mov    %esp,%ebp
 4e5:	56                   	push   %esi
 4e6:	53                   	push   %ebx
 4e7:	8b 75 08             	mov    0x8(%ebp),%esi
 4ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint* ap = (uint*)(void*)&fmt + 1;
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
 4ed:	83 ec 04             	sub    $0x4,%esp
 4f0:	8d 45 14             	lea    0x14(%ebp),%eax
 4f3:	50                   	push   %eax
 4f4:	ff 75 10             	pushl  0x10(%ebp)
 4f7:	53                   	push   %ebx
 4f8:	89 f1                	mov    %esi,%ecx
 4fa:	ba ff ff ff ff       	mov    $0xffffffff,%edx
 4ff:	b8 6c 01 00 00       	mov    $0x16c,%eax
 504:	e8 79 fd ff ff       	call   282 <s_printf>
  if(count < n) {
 509:	83 c4 10             	add    $0x10,%esp
 50c:	39 c3                	cmp    %eax,%ebx
 50e:	76 04                	jbe    514 <snprintf+0x36>
    outbuffer[count] = 0; // Assure nul termination
 510:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
  } 

  return count;
}
 514:	8d 65 f8             	lea    -0x8(%ebp),%esp
 517:	5b                   	pop    %ebx
 518:	5e                   	pop    %esi
 519:	5d                   	pop    %ebp
 51a:	c3                   	ret    

0000051b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 51b:	f3 0f 1e fb          	endbr32 
 51f:	55                   	push   %ebp
 520:	89 e5                	mov    %esp,%ebp
 522:	83 ec 0c             	sub    $0xc,%esp
  static const uint veryLarge = 1<<30;
  uint* ap = (uint*)(void*)&fmt + 1;
  s_printf(s_putc, fd, 0, veryLarge, fmt, ap);
 525:	8d 45 10             	lea    0x10(%ebp),%eax
 528:	50                   	push   %eax
 529:	ff 75 0c             	pushl  0xc(%ebp)
 52c:	68 00 00 00 40       	push   $0x40000000
 531:	b9 00 00 00 00       	mov    $0x0,%ecx
 536:	8b 55 08             	mov    0x8(%ebp),%edx
 539:	b8 bb 04 00 00       	mov    $0x4bb,%eax
 53e:	e8 3f fd ff ff       	call   282 <s_printf>
}
 543:	83 c4 10             	add    $0x10,%esp
 546:	c9                   	leave  
 547:	c3                   	ret    
