
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 b7 10 80       	mov    $0x8010b7c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 f6 2c 10 80       	mov    $0x80102cf6,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 c0 b7 10 80       	push   $0x8010b7c0
80100046:	e8 d4 3f 00 00       	call   8010401f <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 10 ff 10 80    	mov    0x8010ff10,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb bc fe 10 80    	cmp    $0x8010febc,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 c0 b7 10 80       	push   $0x8010b7c0
8010007c:	e8 07 40 00 00       	call   80104088 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 5f 3d 00 00       	call   80103deb <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 0c ff 10 80    	mov    0x8010ff0c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb bc fe 10 80    	cmp    $0x8010febc,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 c0 b7 10 80       	push   $0x8010b7c0
801000ca:	e8 b9 3f 00 00       	call   80104088 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 11 3d 00 00       	call   80103deb <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 80 70 10 80       	push   $0x80107080
801000ef:	e8 68 02 00 00       	call   8010035c <panic>

801000f4 <binit>:
{
801000f4:	f3 0f 1e fb          	endbr32 
801000f8:	55                   	push   %ebp
801000f9:	89 e5                	mov    %esp,%ebp
801000fb:	53                   	push   %ebx
801000fc:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000ff:	68 91 70 10 80       	push   $0x80107091
80100104:	68 c0 b7 10 80       	push   $0x8010b7c0
80100109:	e8 c1 3d 00 00       	call   80103ecf <initlock>
  bcache.head.prev = &bcache.head;
8010010e:	c7 05 0c ff 10 80 bc 	movl   $0x8010febc,0x8010ff0c
80100115:	fe 10 80 
  bcache.head.next = &bcache.head;
80100118:	c7 05 10 ff 10 80 bc 	movl   $0x8010febc,0x8010ff10
8010011f:	fe 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100122:	83 c4 10             	add    $0x10,%esp
80100125:	bb f4 b7 10 80       	mov    $0x8010b7f4,%ebx
8010012a:	eb 37                	jmp    80100163 <binit+0x6f>
    b->next = bcache.head.next;
8010012c:	a1 10 ff 10 80       	mov    0x8010ff10,%eax
80100131:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100134:	c7 43 50 bc fe 10 80 	movl   $0x8010febc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
8010013b:	83 ec 08             	sub    $0x8,%esp
8010013e:	68 98 70 10 80       	push   $0x80107098
80100143:	8d 43 0c             	lea    0xc(%ebx),%eax
80100146:	50                   	push   %eax
80100147:	e8 68 3c 00 00       	call   80103db4 <initsleeplock>
    bcache.head.next->prev = b;
8010014c:	a1 10 ff 10 80       	mov    0x8010ff10,%eax
80100151:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100154:	89 1d 10 ff 10 80    	mov    %ebx,0x8010ff10
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010015a:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
80100160:	83 c4 10             	add    $0x10,%esp
80100163:	81 fb bc fe 10 80    	cmp    $0x8010febc,%ebx
80100169:	72 c1                	jb     8010012c <binit+0x38>
}
8010016b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016e:	c9                   	leave  
8010016f:	c3                   	ret    

80100170 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100170:	f3 0f 1e fb          	endbr32 
80100174:	55                   	push   %ebp
80100175:	89 e5                	mov    %esp,%ebp
80100177:	53                   	push   %ebx
80100178:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
8010017b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010017e:	8b 45 08             	mov    0x8(%ebp),%eax
80100181:	e8 ae fe ff ff       	call   80100034 <bget>
80100186:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100188:	f6 00 02             	testb  $0x2,(%eax)
8010018b:	74 07                	je     80100194 <bread+0x24>
    iderw(b);
  }
  return b;
}
8010018d:	89 d8                	mov    %ebx,%eax
8010018f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100192:	c9                   	leave  
80100193:	c3                   	ret    
    iderw(b);
80100194:	83 ec 0c             	sub    $0xc,%esp
80100197:	50                   	push   %eax
80100198:	e8 7e 1e 00 00       	call   8010201b <iderw>
8010019d:	83 c4 10             	add    $0x10,%esp
  return b;
801001a0:	eb eb                	jmp    8010018d <bread+0x1d>

801001a2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001a2:	f3 0f 1e fb          	endbr32 
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	53                   	push   %ebx
801001aa:	83 ec 10             	sub    $0x10,%esp
801001ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001b0:	8d 43 0c             	lea    0xc(%ebx),%eax
801001b3:	50                   	push   %eax
801001b4:	e8 c4 3c 00 00       	call   80103e7d <holdingsleep>
801001b9:	83 c4 10             	add    $0x10,%esp
801001bc:	85 c0                	test   %eax,%eax
801001be:	74 14                	je     801001d4 <bwrite+0x32>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001c0:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001c3:	83 ec 0c             	sub    $0xc,%esp
801001c6:	53                   	push   %ebx
801001c7:	e8 4f 1e 00 00       	call   8010201b <iderw>
}
801001cc:	83 c4 10             	add    $0x10,%esp
801001cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001d2:	c9                   	leave  
801001d3:	c3                   	ret    
    panic("bwrite");
801001d4:	83 ec 0c             	sub    $0xc,%esp
801001d7:	68 9f 70 10 80       	push   $0x8010709f
801001dc:	e8 7b 01 00 00       	call   8010035c <panic>

801001e1 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001e1:	f3 0f 1e fb          	endbr32 
801001e5:	55                   	push   %ebp
801001e6:	89 e5                	mov    %esp,%ebp
801001e8:	56                   	push   %esi
801001e9:	53                   	push   %ebx
801001ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001ed:	8d 73 0c             	lea    0xc(%ebx),%esi
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 84 3c 00 00       	call   80103e7d <holdingsleep>
801001f9:	83 c4 10             	add    $0x10,%esp
801001fc:	85 c0                	test   %eax,%eax
801001fe:	74 6b                	je     8010026b <brelse+0x8a>
    panic("brelse");

  releasesleep(&b->lock);
80100200:	83 ec 0c             	sub    $0xc,%esp
80100203:	56                   	push   %esi
80100204:	e8 35 3c 00 00       	call   80103e3e <releasesleep>

  acquire(&bcache.lock);
80100209:	c7 04 24 c0 b7 10 80 	movl   $0x8010b7c0,(%esp)
80100210:	e8 0a 3e 00 00       	call   8010401f <acquire>
  b->refcnt--;
80100215:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100218:	83 e8 01             	sub    $0x1,%eax
8010021b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010021e:	83 c4 10             	add    $0x10,%esp
80100221:	85 c0                	test   %eax,%eax
80100223:	75 2f                	jne    80100254 <brelse+0x73>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100225:	8b 43 54             	mov    0x54(%ebx),%eax
80100228:	8b 53 50             	mov    0x50(%ebx),%edx
8010022b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010022e:	8b 43 50             	mov    0x50(%ebx),%eax
80100231:	8b 53 54             	mov    0x54(%ebx),%edx
80100234:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100237:	a1 10 ff 10 80       	mov    0x8010ff10,%eax
8010023c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010023f:	c7 43 50 bc fe 10 80 	movl   $0x8010febc,0x50(%ebx)
    bcache.head.next->prev = b;
80100246:	a1 10 ff 10 80       	mov    0x8010ff10,%eax
8010024b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010024e:	89 1d 10 ff 10 80    	mov    %ebx,0x8010ff10
  }
  
  release(&bcache.lock);
80100254:	83 ec 0c             	sub    $0xc,%esp
80100257:	68 c0 b7 10 80       	push   $0x8010b7c0
8010025c:	e8 27 3e 00 00       	call   80104088 <release>
}
80100261:	83 c4 10             	add    $0x10,%esp
80100264:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100267:	5b                   	pop    %ebx
80100268:	5e                   	pop    %esi
80100269:	5d                   	pop    %ebp
8010026a:	c3                   	ret    
    panic("brelse");
8010026b:	83 ec 0c             	sub    $0xc,%esp
8010026e:	68 a6 70 10 80       	push   $0x801070a6
80100273:	e8 e4 00 00 00       	call   8010035c <panic>

80100278 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100278:	f3 0f 1e fb          	endbr32 
8010027c:	55                   	push   %ebp
8010027d:	89 e5                	mov    %esp,%ebp
8010027f:	57                   	push   %edi
80100280:	56                   	push   %esi
80100281:	53                   	push   %ebx
80100282:	83 ec 28             	sub    $0x28,%esp
80100285:	8b 7d 08             	mov    0x8(%ebp),%edi
80100288:	8b 75 0c             	mov    0xc(%ebp),%esi
8010028b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010028e:	57                   	push   %edi
8010028f:	e8 52 15 00 00       	call   801017e6 <iunlock>
  target = n;
80100294:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100297:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010029e:	e8 7c 3d 00 00       	call   8010401f <acquire>
  while(n > 0){
801002a3:	83 c4 10             	add    $0x10,%esp
801002a6:	85 db                	test   %ebx,%ebx
801002a8:	0f 8e 8f 00 00 00    	jle    8010033d <consoleread+0xc5>
    while(input.r == input.w){
801002ae:	a1 a0 01 11 80       	mov    0x801101a0,%eax
801002b3:	3b 05 a4 01 11 80    	cmp    0x801101a4,%eax
801002b9:	75 47                	jne    80100302 <consoleread+0x8a>
      if(myproc()->killed){
801002bb:	e8 e2 32 00 00       	call   801035a2 <myproc>
801002c0:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002c4:	75 17                	jne    801002dd <consoleread+0x65>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002c6:	83 ec 08             	sub    $0x8,%esp
801002c9:	68 20 a5 10 80       	push   $0x8010a520
801002ce:	68 a0 01 11 80       	push   $0x801101a0
801002d3:	e8 d7 37 00 00       	call   80103aaf <sleep>
801002d8:	83 c4 10             	add    $0x10,%esp
801002db:	eb d1                	jmp    801002ae <consoleread+0x36>
        release(&cons.lock);
801002dd:	83 ec 0c             	sub    $0xc,%esp
801002e0:	68 20 a5 10 80       	push   $0x8010a520
801002e5:	e8 9e 3d 00 00       	call   80104088 <release>
        ilock(ip);
801002ea:	89 3c 24             	mov    %edi,(%esp)
801002ed:	e8 13 14 00 00       	call   80101705 <ilock>
        return -1;
801002f2:	83 c4 10             	add    $0x10,%esp
801002f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002fd:	5b                   	pop    %ebx
801002fe:	5e                   	pop    %esi
801002ff:	5f                   	pop    %edi
80100300:	5d                   	pop    %ebp
80100301:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
80100302:	8d 50 01             	lea    0x1(%eax),%edx
80100305:	89 15 a0 01 11 80    	mov    %edx,0x801101a0
8010030b:	89 c2                	mov    %eax,%edx
8010030d:	83 e2 7f             	and    $0x7f,%edx
80100310:	0f b6 92 20 01 11 80 	movzbl -0x7feefee0(%edx),%edx
80100317:	0f be ca             	movsbl %dl,%ecx
    if(c == C('D')){  // EOF
8010031a:	80 fa 04             	cmp    $0x4,%dl
8010031d:	74 14                	je     80100333 <consoleread+0xbb>
    *dst++ = c;
8010031f:	8d 46 01             	lea    0x1(%esi),%eax
80100322:	88 16                	mov    %dl,(%esi)
    --n;
80100324:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100327:	83 f9 0a             	cmp    $0xa,%ecx
8010032a:	74 11                	je     8010033d <consoleread+0xc5>
    *dst++ = c;
8010032c:	89 c6                	mov    %eax,%esi
8010032e:	e9 73 ff ff ff       	jmp    801002a6 <consoleread+0x2e>
      if(n < target){
80100333:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100336:	73 05                	jae    8010033d <consoleread+0xc5>
        input.r--;
80100338:	a3 a0 01 11 80       	mov    %eax,0x801101a0
  release(&cons.lock);
8010033d:	83 ec 0c             	sub    $0xc,%esp
80100340:	68 20 a5 10 80       	push   $0x8010a520
80100345:	e8 3e 3d 00 00       	call   80104088 <release>
  ilock(ip);
8010034a:	89 3c 24             	mov    %edi,(%esp)
8010034d:	e8 b3 13 00 00       	call   80101705 <ilock>
  return target - n;
80100352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100355:	29 d8                	sub    %ebx,%eax
80100357:	83 c4 10             	add    $0x10,%esp
8010035a:	eb 9e                	jmp    801002fa <consoleread+0x82>

8010035c <panic>:
{
8010035c:	f3 0f 1e fb          	endbr32 
80100360:	55                   	push   %ebp
80100361:	89 e5                	mov    %esp,%ebp
80100363:	53                   	push   %ebx
80100364:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100367:	fa                   	cli    
  cons.locking = 0;
80100368:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
8010036f:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
80100372:	e8 6a 22 00 00       	call   801025e1 <lapicid>
80100377:	83 ec 08             	sub    $0x8,%esp
8010037a:	50                   	push   %eax
8010037b:	68 ad 70 10 80       	push   $0x801070ad
80100380:	e8 a4 02 00 00       	call   80100629 <cprintf>
  cprintf(s);
80100385:	83 c4 04             	add    $0x4,%esp
80100388:	ff 75 08             	pushl  0x8(%ebp)
8010038b:	e8 99 02 00 00       	call   80100629 <cprintf>
  cprintf("\n");
80100390:	c7 04 24 af 7a 10 80 	movl   $0x80107aaf,(%esp)
80100397:	e8 8d 02 00 00       	call   80100629 <cprintf>
  getcallerpcs(&s, pcs);
8010039c:	83 c4 08             	add    $0x8,%esp
8010039f:	8d 45 d0             	lea    -0x30(%ebp),%eax
801003a2:	50                   	push   %eax
801003a3:	8d 45 08             	lea    0x8(%ebp),%eax
801003a6:	50                   	push   %eax
801003a7:	e8 42 3b 00 00       	call   80103eee <getcallerpcs>
  for(i=0; i<10; i++)
801003ac:	83 c4 10             	add    $0x10,%esp
801003af:	bb 00 00 00 00       	mov    $0x0,%ebx
801003b4:	eb 17                	jmp    801003cd <panic+0x71>
    cprintf(" %p", pcs[i]);
801003b6:	83 ec 08             	sub    $0x8,%esp
801003b9:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003bd:	68 c1 70 10 80       	push   $0x801070c1
801003c2:	e8 62 02 00 00       	call   80100629 <cprintf>
  for(i=0; i<10; i++)
801003c7:	83 c3 01             	add    $0x1,%ebx
801003ca:	83 c4 10             	add    $0x10,%esp
801003cd:	83 fb 09             	cmp    $0x9,%ebx
801003d0:	7e e4                	jle    801003b6 <panic+0x5a>
  panicked = 1; // freeze other CPU
801003d2:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
801003d9:	00 00 00 
  for(;;)
801003dc:	eb fe                	jmp    801003dc <panic+0x80>

801003de <cgaputc>:
{
801003de:	55                   	push   %ebp
801003df:	89 e5                	mov    %esp,%ebp
801003e1:	57                   	push   %edi
801003e2:	56                   	push   %esi
801003e3:	53                   	push   %ebx
801003e4:	83 ec 0c             	sub    $0xc,%esp
801003e7:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003e9:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003ee:	b8 0e 00 00 00       	mov    $0xe,%eax
801003f3:	89 ca                	mov    %ecx,%edx
801003f5:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f6:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003fb:	89 da                	mov    %ebx,%edx
801003fd:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003fe:	0f b6 f8             	movzbl %al,%edi
80100401:	c1 e7 08             	shl    $0x8,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100404:	b8 0f 00 00 00       	mov    $0xf,%eax
80100409:	89 ca                	mov    %ecx,%edx
8010040b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010040c:	89 da                	mov    %ebx,%edx
8010040e:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
8010040f:	0f b6 c8             	movzbl %al,%ecx
80100412:	09 f9                	or     %edi,%ecx
  if(c == '\n')
80100414:	83 fe 0a             	cmp    $0xa,%esi
80100417:	74 66                	je     8010047f <cgaputc+0xa1>
  else if(c == BACKSPACE){
80100419:	81 fe 00 01 00 00    	cmp    $0x100,%esi
8010041f:	74 7f                	je     801004a0 <cgaputc+0xc2>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100421:	89 f0                	mov    %esi,%eax
80100423:	0f b6 f0             	movzbl %al,%esi
80100426:	8d 59 01             	lea    0x1(%ecx),%ebx
80100429:	66 81 ce 00 07       	or     $0x700,%si
8010042e:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100435:	80 
  if(pos < 0 || pos > 25*80)
80100436:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
8010043c:	77 6f                	ja     801004ad <cgaputc+0xcf>
  if((pos/80) >= 24){  // Scroll up.
8010043e:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100444:	7f 74                	jg     801004ba <cgaputc+0xdc>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100446:	be d4 03 00 00       	mov    $0x3d4,%esi
8010044b:	b8 0e 00 00 00       	mov    $0xe,%eax
80100450:	89 f2                	mov    %esi,%edx
80100452:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
80100453:	89 d8                	mov    %ebx,%eax
80100455:	c1 f8 08             	sar    $0x8,%eax
80100458:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
8010045d:	89 ca                	mov    %ecx,%edx
8010045f:	ee                   	out    %al,(%dx)
80100460:	b8 0f 00 00 00       	mov    $0xf,%eax
80100465:	89 f2                	mov    %esi,%edx
80100467:	ee                   	out    %al,(%dx)
80100468:	89 d8                	mov    %ebx,%eax
8010046a:	89 ca                	mov    %ecx,%edx
8010046c:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
8010046d:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100474:	80 20 07 
}
80100477:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010047a:	5b                   	pop    %ebx
8010047b:	5e                   	pop    %esi
8010047c:	5f                   	pop    %edi
8010047d:	5d                   	pop    %ebp
8010047e:	c3                   	ret    
    pos += 80 - pos%80;
8010047f:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100484:	89 c8                	mov    %ecx,%eax
80100486:	f7 ea                	imul   %edx
80100488:	c1 fa 05             	sar    $0x5,%edx
8010048b:	8d 04 92             	lea    (%edx,%edx,4),%eax
8010048e:	c1 e0 04             	shl    $0x4,%eax
80100491:	89 ca                	mov    %ecx,%edx
80100493:	29 c2                	sub    %eax,%edx
80100495:	bb 50 00 00 00       	mov    $0x50,%ebx
8010049a:	29 d3                	sub    %edx,%ebx
8010049c:	01 cb                	add    %ecx,%ebx
8010049e:	eb 96                	jmp    80100436 <cgaputc+0x58>
    if(pos > 0) --pos;
801004a0:	85 c9                	test   %ecx,%ecx
801004a2:	7e 05                	jle    801004a9 <cgaputc+0xcb>
801004a4:	8d 59 ff             	lea    -0x1(%ecx),%ebx
801004a7:	eb 8d                	jmp    80100436 <cgaputc+0x58>
  pos |= inb(CRTPORT+1);
801004a9:	89 cb                	mov    %ecx,%ebx
801004ab:	eb 89                	jmp    80100436 <cgaputc+0x58>
    panic("pos under/overflow");
801004ad:	83 ec 0c             	sub    $0xc,%esp
801004b0:	68 c5 70 10 80       	push   $0x801070c5
801004b5:	e8 a2 fe ff ff       	call   8010035c <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004ba:	83 ec 04             	sub    $0x4,%esp
801004bd:	68 60 0e 00 00       	push   $0xe60
801004c2:	68 a0 80 0b 80       	push   $0x800b80a0
801004c7:	68 00 80 0b 80       	push   $0x800b8000
801004cc:	e8 82 3c 00 00       	call   80104153 <memmove>
    pos -= 80;
801004d1:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004d4:	b8 80 07 00 00       	mov    $0x780,%eax
801004d9:	29 d8                	sub    %ebx,%eax
801004db:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004e2:	83 c4 0c             	add    $0xc,%esp
801004e5:	01 c0                	add    %eax,%eax
801004e7:	50                   	push   %eax
801004e8:	6a 00                	push   $0x0
801004ea:	52                   	push   %edx
801004eb:	e8 e3 3b 00 00       	call   801040d3 <memset>
801004f0:	83 c4 10             	add    $0x10,%esp
801004f3:	e9 4e ff ff ff       	jmp    80100446 <cgaputc+0x68>

801004f8 <consputc>:
  if(panicked){
801004f8:	83 3d 58 a5 10 80 00 	cmpl   $0x0,0x8010a558
801004ff:	74 03                	je     80100504 <consputc+0xc>
  asm volatile("cli");
80100501:	fa                   	cli    
    for(;;)
80100502:	eb fe                	jmp    80100502 <consputc+0xa>
{
80100504:	55                   	push   %ebp
80100505:	89 e5                	mov    %esp,%ebp
80100507:	53                   	push   %ebx
80100508:	83 ec 04             	sub    $0x4,%esp
8010050b:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
8010050d:	3d 00 01 00 00       	cmp    $0x100,%eax
80100512:	74 18                	je     8010052c <consputc+0x34>
    uartputc(c);
80100514:	83 ec 0c             	sub    $0xc,%esp
80100517:	50                   	push   %eax
80100518:	e8 1c 51 00 00       	call   80105639 <uartputc>
8010051d:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100520:	89 d8                	mov    %ebx,%eax
80100522:	e8 b7 fe ff ff       	call   801003de <cgaputc>
}
80100527:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010052a:	c9                   	leave  
8010052b:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010052c:	83 ec 0c             	sub    $0xc,%esp
8010052f:	6a 08                	push   $0x8
80100531:	e8 03 51 00 00       	call   80105639 <uartputc>
80100536:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010053d:	e8 f7 50 00 00       	call   80105639 <uartputc>
80100542:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100549:	e8 eb 50 00 00       	call   80105639 <uartputc>
8010054e:	83 c4 10             	add    $0x10,%esp
80100551:	eb cd                	jmp    80100520 <consputc+0x28>

80100553 <printint>:
{
80100553:	55                   	push   %ebp
80100554:	89 e5                	mov    %esp,%ebp
80100556:	57                   	push   %edi
80100557:	56                   	push   %esi
80100558:	53                   	push   %ebx
80100559:	83 ec 2c             	sub    $0x2c,%esp
8010055c:	89 d6                	mov    %edx,%esi
8010055e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  if(sign && (sign = xx < 0))
80100561:	85 c9                	test   %ecx,%ecx
80100563:	74 0c                	je     80100571 <printint+0x1e>
80100565:	89 c7                	mov    %eax,%edi
80100567:	c1 ef 1f             	shr    $0x1f,%edi
8010056a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
8010056d:	85 c0                	test   %eax,%eax
8010056f:	78 38                	js     801005a9 <printint+0x56>
    x = xx;
80100571:	89 c1                	mov    %eax,%ecx
  i = 0;
80100573:	bb 00 00 00 00       	mov    $0x0,%ebx
    buf[i++] = digits[x % base];
80100578:	89 c8                	mov    %ecx,%eax
8010057a:	ba 00 00 00 00       	mov    $0x0,%edx
8010057f:	f7 f6                	div    %esi
80100581:	89 df                	mov    %ebx,%edi
80100583:	83 c3 01             	add    $0x1,%ebx
80100586:	0f b6 92 f0 70 10 80 	movzbl -0x7fef8f10(%edx),%edx
8010058d:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
80100591:	89 ca                	mov    %ecx,%edx
80100593:	89 c1                	mov    %eax,%ecx
80100595:	39 d6                	cmp    %edx,%esi
80100597:	76 df                	jbe    80100578 <printint+0x25>
  if(sign)
80100599:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010059d:	74 1a                	je     801005b9 <printint+0x66>
    buf[i++] = '-';
8010059f:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
801005a4:	8d 5f 02             	lea    0x2(%edi),%ebx
801005a7:	eb 10                	jmp    801005b9 <printint+0x66>
    x = -xx;
801005a9:	f7 d8                	neg    %eax
801005ab:	89 c1                	mov    %eax,%ecx
801005ad:	eb c4                	jmp    80100573 <printint+0x20>
    consputc(buf[i]);
801005af:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
801005b4:	e8 3f ff ff ff       	call   801004f8 <consputc>
  while(--i >= 0)
801005b9:	83 eb 01             	sub    $0x1,%ebx
801005bc:	79 f1                	jns    801005af <printint+0x5c>
}
801005be:	83 c4 2c             	add    $0x2c,%esp
801005c1:	5b                   	pop    %ebx
801005c2:	5e                   	pop    %esi
801005c3:	5f                   	pop    %edi
801005c4:	5d                   	pop    %ebp
801005c5:	c3                   	ret    

801005c6 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005c6:	f3 0f 1e fb          	endbr32 
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	57                   	push   %edi
801005ce:	56                   	push   %esi
801005cf:	53                   	push   %ebx
801005d0:	83 ec 18             	sub    $0x18,%esp
801005d3:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005d6:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005d9:	ff 75 08             	pushl  0x8(%ebp)
801005dc:	e8 05 12 00 00       	call   801017e6 <iunlock>
  acquire(&cons.lock);
801005e1:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005e8:	e8 32 3a 00 00       	call   8010401f <acquire>
  for(i = 0; i < n; i++)
801005ed:	83 c4 10             	add    $0x10,%esp
801005f0:	bb 00 00 00 00       	mov    $0x0,%ebx
801005f5:	39 f3                	cmp    %esi,%ebx
801005f7:	7d 0e                	jge    80100607 <consolewrite+0x41>
    consputc(buf[i] & 0xff);
801005f9:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005fd:	e8 f6 fe ff ff       	call   801004f8 <consputc>
  for(i = 0; i < n; i++)
80100602:	83 c3 01             	add    $0x1,%ebx
80100605:	eb ee                	jmp    801005f5 <consolewrite+0x2f>
  release(&cons.lock);
80100607:	83 ec 0c             	sub    $0xc,%esp
8010060a:	68 20 a5 10 80       	push   $0x8010a520
8010060f:	e8 74 3a 00 00       	call   80104088 <release>
  ilock(ip);
80100614:	83 c4 04             	add    $0x4,%esp
80100617:	ff 75 08             	pushl  0x8(%ebp)
8010061a:	e8 e6 10 00 00       	call   80101705 <ilock>

  return n;
}
8010061f:	89 f0                	mov    %esi,%eax
80100621:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100624:	5b                   	pop    %ebx
80100625:	5e                   	pop    %esi
80100626:	5f                   	pop    %edi
80100627:	5d                   	pop    %ebp
80100628:	c3                   	ret    

80100629 <cprintf>:
{
80100629:	f3 0f 1e fb          	endbr32 
8010062d:	55                   	push   %ebp
8010062e:	89 e5                	mov    %esp,%ebp
80100630:	57                   	push   %edi
80100631:	56                   	push   %esi
80100632:	53                   	push   %ebx
80100633:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100636:	a1 54 a5 10 80       	mov    0x8010a554,%eax
8010063b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(locking)
8010063e:	85 c0                	test   %eax,%eax
80100640:	75 10                	jne    80100652 <cprintf+0x29>
  if (fmt == 0)
80100642:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100646:	74 1c                	je     80100664 <cprintf+0x3b>
  argp = (uint*)(void*)(&fmt + 1);
80100648:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010064b:	be 00 00 00 00       	mov    $0x0,%esi
80100650:	eb 27                	jmp    80100679 <cprintf+0x50>
    acquire(&cons.lock);
80100652:	83 ec 0c             	sub    $0xc,%esp
80100655:	68 20 a5 10 80       	push   $0x8010a520
8010065a:	e8 c0 39 00 00       	call   8010401f <acquire>
8010065f:	83 c4 10             	add    $0x10,%esp
80100662:	eb de                	jmp    80100642 <cprintf+0x19>
    panic("null fmt");
80100664:	83 ec 0c             	sub    $0xc,%esp
80100667:	68 df 70 10 80       	push   $0x801070df
8010066c:	e8 eb fc ff ff       	call   8010035c <panic>
      consputc(c);
80100671:	e8 82 fe ff ff       	call   801004f8 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100676:	83 c6 01             	add    $0x1,%esi
80100679:	8b 55 08             	mov    0x8(%ebp),%edx
8010067c:	0f b6 04 32          	movzbl (%edx,%esi,1),%eax
80100680:	85 c0                	test   %eax,%eax
80100682:	0f 84 b1 00 00 00    	je     80100739 <cprintf+0x110>
    if(c != '%'){
80100688:	83 f8 25             	cmp    $0x25,%eax
8010068b:	75 e4                	jne    80100671 <cprintf+0x48>
    c = fmt[++i] & 0xff;
8010068d:	83 c6 01             	add    $0x1,%esi
80100690:	0f b6 1c 32          	movzbl (%edx,%esi,1),%ebx
    if(c == 0)
80100694:	85 db                	test   %ebx,%ebx
80100696:	0f 84 9d 00 00 00    	je     80100739 <cprintf+0x110>
    switch(c){
8010069c:	83 fb 70             	cmp    $0x70,%ebx
8010069f:	74 2e                	je     801006cf <cprintf+0xa6>
801006a1:	7f 22                	jg     801006c5 <cprintf+0x9c>
801006a3:	83 fb 25             	cmp    $0x25,%ebx
801006a6:	74 6c                	je     80100714 <cprintf+0xeb>
801006a8:	83 fb 64             	cmp    $0x64,%ebx
801006ab:	75 76                	jne    80100723 <cprintf+0xfa>
      printint(*argp++, 10, 1);
801006ad:	8d 5f 04             	lea    0x4(%edi),%ebx
801006b0:	8b 07                	mov    (%edi),%eax
801006b2:	b9 01 00 00 00       	mov    $0x1,%ecx
801006b7:	ba 0a 00 00 00       	mov    $0xa,%edx
801006bc:	e8 92 fe ff ff       	call   80100553 <printint>
801006c1:	89 df                	mov    %ebx,%edi
      break;
801006c3:	eb b1                	jmp    80100676 <cprintf+0x4d>
    switch(c){
801006c5:	83 fb 73             	cmp    $0x73,%ebx
801006c8:	74 1d                	je     801006e7 <cprintf+0xbe>
801006ca:	83 fb 78             	cmp    $0x78,%ebx
801006cd:	75 54                	jne    80100723 <cprintf+0xfa>
      printint(*argp++, 16, 0);
801006cf:	8d 5f 04             	lea    0x4(%edi),%ebx
801006d2:	8b 07                	mov    (%edi),%eax
801006d4:	b9 00 00 00 00       	mov    $0x0,%ecx
801006d9:	ba 10 00 00 00       	mov    $0x10,%edx
801006de:	e8 70 fe ff ff       	call   80100553 <printint>
801006e3:	89 df                	mov    %ebx,%edi
      break;
801006e5:	eb 8f                	jmp    80100676 <cprintf+0x4d>
      if((s = (char*)*argp++) == 0)
801006e7:	8d 47 04             	lea    0x4(%edi),%eax
801006ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801006ed:	8b 1f                	mov    (%edi),%ebx
801006ef:	85 db                	test   %ebx,%ebx
801006f1:	75 05                	jne    801006f8 <cprintf+0xcf>
        s = "(null)";
801006f3:	bb d8 70 10 80       	mov    $0x801070d8,%ebx
      for(; *s; s++)
801006f8:	0f b6 03             	movzbl (%ebx),%eax
801006fb:	84 c0                	test   %al,%al
801006fd:	74 0d                	je     8010070c <cprintf+0xe3>
        consputc(*s);
801006ff:	0f be c0             	movsbl %al,%eax
80100702:	e8 f1 fd ff ff       	call   801004f8 <consputc>
      for(; *s; s++)
80100707:	83 c3 01             	add    $0x1,%ebx
8010070a:	eb ec                	jmp    801006f8 <cprintf+0xcf>
      if((s = (char*)*argp++) == 0)
8010070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010070f:	e9 62 ff ff ff       	jmp    80100676 <cprintf+0x4d>
      consputc('%');
80100714:	b8 25 00 00 00       	mov    $0x25,%eax
80100719:	e8 da fd ff ff       	call   801004f8 <consputc>
      break;
8010071e:	e9 53 ff ff ff       	jmp    80100676 <cprintf+0x4d>
      consputc('%');
80100723:	b8 25 00 00 00       	mov    $0x25,%eax
80100728:	e8 cb fd ff ff       	call   801004f8 <consputc>
      consputc(c);
8010072d:	89 d8                	mov    %ebx,%eax
8010072f:	e8 c4 fd ff ff       	call   801004f8 <consputc>
      break;
80100734:	e9 3d ff ff ff       	jmp    80100676 <cprintf+0x4d>
  if(locking)
80100739:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010073d:	75 08                	jne    80100747 <cprintf+0x11e>
}
8010073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100742:	5b                   	pop    %ebx
80100743:	5e                   	pop    %esi
80100744:	5f                   	pop    %edi
80100745:	5d                   	pop    %ebp
80100746:	c3                   	ret    
    release(&cons.lock);
80100747:	83 ec 0c             	sub    $0xc,%esp
8010074a:	68 20 a5 10 80       	push   $0x8010a520
8010074f:	e8 34 39 00 00       	call   80104088 <release>
80100754:	83 c4 10             	add    $0x10,%esp
}
80100757:	eb e6                	jmp    8010073f <cprintf+0x116>

80100759 <consoleintr>:
{
80100759:	f3 0f 1e fb          	endbr32 
8010075d:	55                   	push   %ebp
8010075e:	89 e5                	mov    %esp,%ebp
80100760:	57                   	push   %edi
80100761:	56                   	push   %esi
80100762:	53                   	push   %ebx
80100763:	83 ec 18             	sub    $0x18,%esp
80100766:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
80100769:	68 20 a5 10 80       	push   $0x8010a520
8010076e:	e8 ac 38 00 00       	call   8010401f <acquire>
  while((c = getc()) >= 0){
80100773:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
80100776:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
8010077b:	eb 13                	jmp    80100790 <consoleintr+0x37>
    switch(c){
8010077d:	83 ff 08             	cmp    $0x8,%edi
80100780:	0f 84 d9 00 00 00    	je     8010085f <consoleintr+0x106>
80100786:	83 ff 10             	cmp    $0x10,%edi
80100789:	75 25                	jne    801007b0 <consoleintr+0x57>
8010078b:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100790:	ff d3                	call   *%ebx
80100792:	89 c7                	mov    %eax,%edi
80100794:	85 c0                	test   %eax,%eax
80100796:	0f 88 f5 00 00 00    	js     80100891 <consoleintr+0x138>
    switch(c){
8010079c:	83 ff 15             	cmp    $0x15,%edi
8010079f:	0f 84 93 00 00 00    	je     80100838 <consoleintr+0xdf>
801007a5:	7e d6                	jle    8010077d <consoleintr+0x24>
801007a7:	83 ff 7f             	cmp    $0x7f,%edi
801007aa:	0f 84 af 00 00 00    	je     8010085f <consoleintr+0x106>
      if(c != 0 && input.e-input.r < INPUT_BUF){
801007b0:	85 ff                	test   %edi,%edi
801007b2:	74 dc                	je     80100790 <consoleintr+0x37>
801007b4:	a1 a8 01 11 80       	mov    0x801101a8,%eax
801007b9:	89 c2                	mov    %eax,%edx
801007bb:	2b 15 a0 01 11 80    	sub    0x801101a0,%edx
801007c1:	83 fa 7f             	cmp    $0x7f,%edx
801007c4:	77 ca                	ja     80100790 <consoleintr+0x37>
        c = (c == '\r') ? '\n' : c;
801007c6:	83 ff 0d             	cmp    $0xd,%edi
801007c9:	0f 84 b8 00 00 00    	je     80100887 <consoleintr+0x12e>
        input.buf[input.e++ % INPUT_BUF] = c;
801007cf:	8d 50 01             	lea    0x1(%eax),%edx
801007d2:	89 15 a8 01 11 80    	mov    %edx,0x801101a8
801007d8:	83 e0 7f             	and    $0x7f,%eax
801007db:	89 f9                	mov    %edi,%ecx
801007dd:	88 88 20 01 11 80    	mov    %cl,-0x7feefee0(%eax)
        consputc(c);
801007e3:	89 f8                	mov    %edi,%eax
801007e5:	e8 0e fd ff ff       	call   801004f8 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007ea:	83 ff 0a             	cmp    $0xa,%edi
801007ed:	0f 94 c2             	sete   %dl
801007f0:	83 ff 04             	cmp    $0x4,%edi
801007f3:	0f 94 c0             	sete   %al
801007f6:	08 c2                	or     %al,%dl
801007f8:	75 10                	jne    8010080a <consoleintr+0xb1>
801007fa:	a1 a0 01 11 80       	mov    0x801101a0,%eax
801007ff:	83 e8 80             	sub    $0xffffff80,%eax
80100802:	39 05 a8 01 11 80    	cmp    %eax,0x801101a8
80100808:	75 86                	jne    80100790 <consoleintr+0x37>
          input.w = input.e;
8010080a:	a1 a8 01 11 80       	mov    0x801101a8,%eax
8010080f:	a3 a4 01 11 80       	mov    %eax,0x801101a4
          wakeup(&input.r);
80100814:	83 ec 0c             	sub    $0xc,%esp
80100817:	68 a0 01 11 80       	push   $0x801101a0
8010081c:	e8 fe 33 00 00       	call   80103c1f <wakeup>
80100821:	83 c4 10             	add    $0x10,%esp
80100824:	e9 67 ff ff ff       	jmp    80100790 <consoleintr+0x37>
        input.e--;
80100829:	a3 a8 01 11 80       	mov    %eax,0x801101a8
        consputc(BACKSPACE);
8010082e:	b8 00 01 00 00       	mov    $0x100,%eax
80100833:	e8 c0 fc ff ff       	call   801004f8 <consputc>
      while(input.e != input.w &&
80100838:	a1 a8 01 11 80       	mov    0x801101a8,%eax
8010083d:	3b 05 a4 01 11 80    	cmp    0x801101a4,%eax
80100843:	0f 84 47 ff ff ff    	je     80100790 <consoleintr+0x37>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100849:	83 e8 01             	sub    $0x1,%eax
8010084c:	89 c2                	mov    %eax,%edx
8010084e:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100851:	80 ba 20 01 11 80 0a 	cmpb   $0xa,-0x7feefee0(%edx)
80100858:	75 cf                	jne    80100829 <consoleintr+0xd0>
8010085a:	e9 31 ff ff ff       	jmp    80100790 <consoleintr+0x37>
      if(input.e != input.w){
8010085f:	a1 a8 01 11 80       	mov    0x801101a8,%eax
80100864:	3b 05 a4 01 11 80    	cmp    0x801101a4,%eax
8010086a:	0f 84 20 ff ff ff    	je     80100790 <consoleintr+0x37>
        input.e--;
80100870:	83 e8 01             	sub    $0x1,%eax
80100873:	a3 a8 01 11 80       	mov    %eax,0x801101a8
        consputc(BACKSPACE);
80100878:	b8 00 01 00 00       	mov    $0x100,%eax
8010087d:	e8 76 fc ff ff       	call   801004f8 <consputc>
80100882:	e9 09 ff ff ff       	jmp    80100790 <consoleintr+0x37>
        c = (c == '\r') ? '\n' : c;
80100887:	bf 0a 00 00 00       	mov    $0xa,%edi
8010088c:	e9 3e ff ff ff       	jmp    801007cf <consoleintr+0x76>
  release(&cons.lock);
80100891:	83 ec 0c             	sub    $0xc,%esp
80100894:	68 20 a5 10 80       	push   $0x8010a520
80100899:	e8 ea 37 00 00       	call   80104088 <release>
  if(doprocdump) {
8010089e:	83 c4 10             	add    $0x10,%esp
801008a1:	85 f6                	test   %esi,%esi
801008a3:	75 08                	jne    801008ad <consoleintr+0x154>
}
801008a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801008a8:	5b                   	pop    %ebx
801008a9:	5e                   	pop    %esi
801008aa:	5f                   	pop    %edi
801008ab:	5d                   	pop    %ebp
801008ac:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
801008ad:	e8 14 34 00 00       	call   80103cc6 <procdump>
}
801008b2:	eb f1                	jmp    801008a5 <consoleintr+0x14c>

801008b4 <consoleinit>:

void
consoleinit(void)
{
801008b4:	f3 0f 1e fb          	endbr32 
801008b8:	55                   	push   %ebp
801008b9:	89 e5                	mov    %esp,%ebp
801008bb:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
801008be:	68 e8 70 10 80       	push   $0x801070e8
801008c3:	68 20 a5 10 80       	push   $0x8010a520
801008c8:	e8 02 36 00 00       	call   80103ecf <initlock>

  devsw[CONSOLE].write = consolewrite;
801008cd:	c7 05 6c 0b 11 80 c6 	movl   $0x801005c6,0x80110b6c
801008d4:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008d7:	c7 05 68 0b 11 80 78 	movl   $0x80100278,0x80110b68
801008de:	02 10 80 
  cons.locking = 1;
801008e1:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
801008e8:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008eb:	83 c4 08             	add    $0x8,%esp
801008ee:	6a 00                	push   $0x0
801008f0:	6a 01                	push   $0x1
801008f2:	e8 96 18 00 00       	call   8010218d <ioapicenable>
}
801008f7:	83 c4 10             	add    $0x10,%esp
801008fa:	c9                   	leave  
801008fb:	c3                   	ret    

801008fc <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008fc:	f3 0f 1e fb          	endbr32 
80100900:	55                   	push   %ebp
80100901:	89 e5                	mov    %esp,%ebp
80100903:	57                   	push   %edi
80100904:	56                   	push   %esi
80100905:	53                   	push   %ebx
80100906:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
8010090c:	e8 91 2c 00 00       	call   801035a2 <myproc>
80100911:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100917:	e8 fb 20 00 00       	call   80102a17 <begin_op>

  if((ip = namei(path)) == 0){
8010091c:	83 ec 0c             	sub    $0xc,%esp
8010091f:	ff 75 08             	pushl  0x8(%ebp)
80100922:	e8 ba 14 00 00       	call   80101de1 <namei>
80100927:	83 c4 10             	add    $0x10,%esp
8010092a:	85 c0                	test   %eax,%eax
8010092c:	74 56                	je     80100984 <exec+0x88>
8010092e:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100930:	83 ec 0c             	sub    $0xc,%esp
80100933:	50                   	push   %eax
80100934:	e8 cc 0d 00 00       	call   80101705 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100939:	6a 34                	push   $0x34
8010093b:	6a 00                	push   $0x0
8010093d:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100943:	50                   	push   %eax
80100944:	53                   	push   %ebx
80100945:	e8 f4 0f 00 00       	call   8010193e <readi>
8010094a:	83 c4 20             	add    $0x20,%esp
8010094d:	83 f8 34             	cmp    $0x34,%eax
80100950:	75 0c                	jne    8010095e <exec+0x62>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100952:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100959:	45 4c 46 
8010095c:	74 42                	je     801009a0 <exec+0xa4>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
8010095e:	85 db                	test   %ebx,%ebx
80100960:	0f 84 c9 02 00 00    	je     80100c2f <exec+0x333>
    iunlockput(ip);
80100966:	83 ec 0c             	sub    $0xc,%esp
80100969:	53                   	push   %ebx
8010096a:	e8 73 0f 00 00       	call   801018e2 <iunlockput>
    end_op();
8010096f:	e8 21 21 00 00       	call   80102a95 <end_op>
80100974:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100977:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010097c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010097f:	5b                   	pop    %ebx
80100980:	5e                   	pop    %esi
80100981:	5f                   	pop    %edi
80100982:	5d                   	pop    %ebp
80100983:	c3                   	ret    
    end_op();
80100984:	e8 0c 21 00 00       	call   80102a95 <end_op>
    cprintf("exec: fail\n");
80100989:	83 ec 0c             	sub    $0xc,%esp
8010098c:	68 01 71 10 80       	push   $0x80107101
80100991:	e8 93 fc ff ff       	call   80100629 <cprintf>
    return -1;
80100996:	83 c4 10             	add    $0x10,%esp
80100999:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010099e:	eb dc                	jmp    8010097c <exec+0x80>
  if((pgdir = setupkvm()) == 0)
801009a0:	e8 3a 5f 00 00       	call   801068df <setupkvm>
801009a5:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009ab:	85 c0                	test   %eax,%eax
801009ad:	0f 84 09 01 00 00    	je     80100abc <exec+0x1c0>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801009b3:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
801009b9:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801009be:	be 00 00 00 00       	mov    $0x0,%esi
801009c3:	eb 0c                	jmp    801009d1 <exec+0xd5>
801009c5:	83 c6 01             	add    $0x1,%esi
801009c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
801009ce:	83 c0 20             	add    $0x20,%eax
801009d1:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009d8:	39 f2                	cmp    %esi,%edx
801009da:	0f 8e 98 00 00 00    	jle    80100a78 <exec+0x17c>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009e0:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
801009e6:	6a 20                	push   $0x20
801009e8:	50                   	push   %eax
801009e9:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009ef:	50                   	push   %eax
801009f0:	53                   	push   %ebx
801009f1:	e8 48 0f 00 00       	call   8010193e <readi>
801009f6:	83 c4 10             	add    $0x10,%esp
801009f9:	83 f8 20             	cmp    $0x20,%eax
801009fc:	0f 85 ba 00 00 00    	jne    80100abc <exec+0x1c0>
    if(ph.type != ELF_PROG_LOAD)
80100a02:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100a09:	75 ba                	jne    801009c5 <exec+0xc9>
    if(ph.memsz < ph.filesz)
80100a0b:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100a11:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100a17:	0f 82 9f 00 00 00    	jb     80100abc <exec+0x1c0>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100a1d:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100a23:	0f 82 93 00 00 00    	jb     80100abc <exec+0x1c0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100a29:	83 ec 04             	sub    $0x4,%esp
80100a2c:	50                   	push   %eax
80100a2d:	57                   	push   %edi
80100a2e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100a34:	e8 16 5d 00 00       	call   8010674f <allocuvm>
80100a39:	89 c7                	mov    %eax,%edi
80100a3b:	83 c4 10             	add    $0x10,%esp
80100a3e:	85 c0                	test   %eax,%eax
80100a40:	74 7a                	je     80100abc <exec+0x1c0>
    if(ph.vaddr % PGSIZE != 0)
80100a42:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a48:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a4d:	75 6d                	jne    80100abc <exec+0x1c0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a4f:	83 ec 0c             	sub    $0xc,%esp
80100a52:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a58:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a5e:	53                   	push   %ebx
80100a5f:	50                   	push   %eax
80100a60:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100a66:	e8 87 5b 00 00       	call   801065f2 <loaduvm>
80100a6b:	83 c4 20             	add    $0x20,%esp
80100a6e:	85 c0                	test   %eax,%eax
80100a70:	0f 89 4f ff ff ff    	jns    801009c5 <exec+0xc9>
80100a76:	eb 44                	jmp    80100abc <exec+0x1c0>
  iunlockput(ip);
80100a78:	83 ec 0c             	sub    $0xc,%esp
80100a7b:	53                   	push   %ebx
80100a7c:	e8 61 0e 00 00       	call   801018e2 <iunlockput>
  end_op();
80100a81:	e8 0f 20 00 00       	call   80102a95 <end_op>
  sz = PGROUNDUP(sz);
80100a86:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a91:	83 c4 0c             	add    $0xc,%esp
80100a94:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a9a:	52                   	push   %edx
80100a9b:	50                   	push   %eax
80100a9c:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100aa2:	57                   	push   %edi
80100aa3:	e8 a7 5c 00 00       	call   8010674f <allocuvm>
80100aa8:	89 c6                	mov    %eax,%esi
80100aaa:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100ab0:	83 c4 10             	add    $0x10,%esp
80100ab3:	85 c0                	test   %eax,%eax
80100ab5:	75 24                	jne    80100adb <exec+0x1df>
  ip = 0;
80100ab7:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100abc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ac2:	85 c0                	test   %eax,%eax
80100ac4:	0f 84 94 fe ff ff    	je     8010095e <exec+0x62>
    freevm(pgdir);
80100aca:	83 ec 0c             	sub    $0xc,%esp
80100acd:	50                   	push   %eax
80100ace:	e8 84 5d 00 00       	call   80106857 <freevm>
80100ad3:	83 c4 10             	add    $0x10,%esp
80100ad6:	e9 83 fe ff ff       	jmp    8010095e <exec+0x62>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100adb:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ae1:	83 ec 08             	sub    $0x8,%esp
80100ae4:	50                   	push   %eax
80100ae5:	57                   	push   %edi
80100ae6:	e8 81 5e 00 00       	call   8010696c <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100aeb:	83 c4 10             	add    $0x10,%esp
80100aee:	bf 00 00 00 00       	mov    $0x0,%edi
80100af3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100af6:	8d 1c b8             	lea    (%eax,%edi,4),%ebx
80100af9:	8b 03                	mov    (%ebx),%eax
80100afb:	85 c0                	test   %eax,%eax
80100afd:	74 4d                	je     80100b4c <exec+0x250>
    if(argc >= MAXARG)
80100aff:	83 ff 1f             	cmp    $0x1f,%edi
80100b02:	0f 87 13 01 00 00    	ja     80100c1b <exec+0x31f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100b08:	83 ec 0c             	sub    $0xc,%esp
80100b0b:	50                   	push   %eax
80100b0c:	e8 83 37 00 00       	call   80104294 <strlen>
80100b11:	29 c6                	sub    %eax,%esi
80100b13:	83 ee 01             	sub    $0x1,%esi
80100b16:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100b19:	83 c4 04             	add    $0x4,%esp
80100b1c:	ff 33                	pushl  (%ebx)
80100b1e:	e8 71 37 00 00       	call   80104294 <strlen>
80100b23:	83 c0 01             	add    $0x1,%eax
80100b26:	50                   	push   %eax
80100b27:	ff 33                	pushl  (%ebx)
80100b29:	56                   	push   %esi
80100b2a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100b30:	e8 d3 5f 00 00       	call   80106b08 <copyout>
80100b35:	83 c4 20             	add    $0x20,%esp
80100b38:	85 c0                	test   %eax,%eax
80100b3a:	0f 88 e5 00 00 00    	js     80100c25 <exec+0x329>
    ustack[3+argc] = sp;
80100b40:	89 b4 bd 64 ff ff ff 	mov    %esi,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100b47:	83 c7 01             	add    $0x1,%edi
80100b4a:	eb a7                	jmp    80100af3 <exec+0x1f7>
80100b4c:	89 f1                	mov    %esi,%ecx
80100b4e:	89 c3                	mov    %eax,%ebx
  ustack[3+argc] = 0;
80100b50:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100b57:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b5b:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b62:	ff ff ff 
  ustack[1] = argc;
80100b65:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b6b:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100b72:	89 f2                	mov    %esi,%edx
80100b74:	29 c2                	sub    %eax,%edx
80100b76:	89 95 60 ff ff ff    	mov    %edx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b7c:	8d 04 bd 10 00 00 00 	lea    0x10(,%edi,4),%eax
80100b83:	29 c1                	sub    %eax,%ecx
80100b85:	89 ce                	mov    %ecx,%esi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b87:	50                   	push   %eax
80100b88:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b8e:	50                   	push   %eax
80100b8f:	51                   	push   %ecx
80100b90:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100b96:	e8 6d 5f 00 00       	call   80106b08 <copyout>
80100b9b:	83 c4 10             	add    $0x10,%esp
80100b9e:	85 c0                	test   %eax,%eax
80100ba0:	0f 88 16 ff ff ff    	js     80100abc <exec+0x1c0>
  for(last=s=path; *s; s++)
80100ba6:	8b 55 08             	mov    0x8(%ebp),%edx
80100ba9:	89 d0                	mov    %edx,%eax
80100bab:	eb 03                	jmp    80100bb0 <exec+0x2b4>
80100bad:	83 c0 01             	add    $0x1,%eax
80100bb0:	0f b6 08             	movzbl (%eax),%ecx
80100bb3:	84 c9                	test   %cl,%cl
80100bb5:	74 0a                	je     80100bc1 <exec+0x2c5>
    if(*s == '/')
80100bb7:	80 f9 2f             	cmp    $0x2f,%cl
80100bba:	75 f1                	jne    80100bad <exec+0x2b1>
      last = s+1;
80100bbc:	8d 50 01             	lea    0x1(%eax),%edx
80100bbf:	eb ec                	jmp    80100bad <exec+0x2b1>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100bc1:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100bc7:	89 f8                	mov    %edi,%eax
80100bc9:	83 c0 6c             	add    $0x6c,%eax
80100bcc:	83 ec 04             	sub    $0x4,%esp
80100bcf:	6a 10                	push   $0x10
80100bd1:	52                   	push   %edx
80100bd2:	50                   	push   %eax
80100bd3:	e8 7b 36 00 00       	call   80104253 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100bd8:	8b 5f 04             	mov    0x4(%edi),%ebx
  curproc->pgdir = pgdir;
80100bdb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100be1:	89 4f 04             	mov    %ecx,0x4(%edi)
  curproc->sz = sz;
80100be4:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100bea:	89 0f                	mov    %ecx,(%edi)
  curproc->tf->eip = elf.entry;  // main
80100bec:	8b 47 18             	mov    0x18(%edi),%eax
80100bef:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bf5:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bf8:	8b 47 18             	mov    0x18(%edi),%eax
80100bfb:	89 70 44             	mov    %esi,0x44(%eax)
  switchuvm(curproc);
80100bfe:	89 3c 24             	mov    %edi,(%esp)
80100c01:	e8 37 58 00 00       	call   8010643d <switchuvm>
  freevm(oldpgdir);
80100c06:	89 1c 24             	mov    %ebx,(%esp)
80100c09:	e8 49 5c 00 00       	call   80106857 <freevm>
  return 0;
80100c0e:	83 c4 10             	add    $0x10,%esp
80100c11:	b8 00 00 00 00       	mov    $0x0,%eax
80100c16:	e9 61 fd ff ff       	jmp    8010097c <exec+0x80>
  ip = 0;
80100c1b:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c20:	e9 97 fe ff ff       	jmp    80100abc <exec+0x1c0>
80100c25:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c2a:	e9 8d fe ff ff       	jmp    80100abc <exec+0x1c0>
  return -1;
80100c2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c34:	e9 43 fd ff ff       	jmp    8010097c <exec+0x80>

80100c39 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c39:	f3 0f 1e fb          	endbr32 
80100c3d:	55                   	push   %ebp
80100c3e:	89 e5                	mov    %esp,%ebp
80100c40:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c43:	68 0d 71 10 80       	push   $0x8010710d
80100c48:	68 c0 01 11 80       	push   $0x801101c0
80100c4d:	e8 7d 32 00 00       	call   80103ecf <initlock>
}
80100c52:	83 c4 10             	add    $0x10,%esp
80100c55:	c9                   	leave  
80100c56:	c3                   	ret    

80100c57 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c57:	f3 0f 1e fb          	endbr32 
80100c5b:	55                   	push   %ebp
80100c5c:	89 e5                	mov    %esp,%ebp
80100c5e:	53                   	push   %ebx
80100c5f:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c62:	68 c0 01 11 80       	push   $0x801101c0
80100c67:	e8 b3 33 00 00       	call   8010401f <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c6c:	83 c4 10             	add    $0x10,%esp
80100c6f:	bb f4 01 11 80       	mov    $0x801101f4,%ebx
80100c74:	eb 03                	jmp    80100c79 <filealloc+0x22>
80100c76:	83 c3 18             	add    $0x18,%ebx
80100c79:	81 fb 54 0b 11 80    	cmp    $0x80110b54,%ebx
80100c7f:	73 24                	jae    80100ca5 <filealloc+0x4e>
    if(f->ref == 0){
80100c81:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c85:	75 ef                	jne    80100c76 <filealloc+0x1f>
      f->ref = 1;
80100c87:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c8e:	83 ec 0c             	sub    $0xc,%esp
80100c91:	68 c0 01 11 80       	push   $0x801101c0
80100c96:	e8 ed 33 00 00       	call   80104088 <release>
      return f;
80100c9b:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c9e:	89 d8                	mov    %ebx,%eax
80100ca0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ca3:	c9                   	leave  
80100ca4:	c3                   	ret    
  release(&ftable.lock);
80100ca5:	83 ec 0c             	sub    $0xc,%esp
80100ca8:	68 c0 01 11 80       	push   $0x801101c0
80100cad:	e8 d6 33 00 00       	call   80104088 <release>
  return 0;
80100cb2:	83 c4 10             	add    $0x10,%esp
80100cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
80100cba:	eb e2                	jmp    80100c9e <filealloc+0x47>

80100cbc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100cbc:	f3 0f 1e fb          	endbr32 
80100cc0:	55                   	push   %ebp
80100cc1:	89 e5                	mov    %esp,%ebp
80100cc3:	53                   	push   %ebx
80100cc4:	83 ec 10             	sub    $0x10,%esp
80100cc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100cca:	68 c0 01 11 80       	push   $0x801101c0
80100ccf:	e8 4b 33 00 00       	call   8010401f <acquire>
  if(f->ref < 1)
80100cd4:	8b 43 04             	mov    0x4(%ebx),%eax
80100cd7:	83 c4 10             	add    $0x10,%esp
80100cda:	85 c0                	test   %eax,%eax
80100cdc:	7e 1a                	jle    80100cf8 <filedup+0x3c>
    panic("filedup");
  f->ref++;
80100cde:	83 c0 01             	add    $0x1,%eax
80100ce1:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100ce4:	83 ec 0c             	sub    $0xc,%esp
80100ce7:	68 c0 01 11 80       	push   $0x801101c0
80100cec:	e8 97 33 00 00       	call   80104088 <release>
  return f;
}
80100cf1:	89 d8                	mov    %ebx,%eax
80100cf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cf6:	c9                   	leave  
80100cf7:	c3                   	ret    
    panic("filedup");
80100cf8:	83 ec 0c             	sub    $0xc,%esp
80100cfb:	68 14 71 10 80       	push   $0x80107114
80100d00:	e8 57 f6 ff ff       	call   8010035c <panic>

80100d05 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100d05:	f3 0f 1e fb          	endbr32 
80100d09:	55                   	push   %ebp
80100d0a:	89 e5                	mov    %esp,%ebp
80100d0c:	53                   	push   %ebx
80100d0d:	83 ec 30             	sub    $0x30,%esp
80100d10:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100d13:	68 c0 01 11 80       	push   $0x801101c0
80100d18:	e8 02 33 00 00       	call   8010401f <acquire>
  if(f->ref < 1)
80100d1d:	8b 43 04             	mov    0x4(%ebx),%eax
80100d20:	83 c4 10             	add    $0x10,%esp
80100d23:	85 c0                	test   %eax,%eax
80100d25:	7e 65                	jle    80100d8c <fileclose+0x87>
    panic("fileclose");
  if(--f->ref > 0){
80100d27:	83 e8 01             	sub    $0x1,%eax
80100d2a:	89 43 04             	mov    %eax,0x4(%ebx)
80100d2d:	85 c0                	test   %eax,%eax
80100d2f:	7f 68                	jg     80100d99 <fileclose+0x94>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100d31:	8b 03                	mov    (%ebx),%eax
80100d33:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d36:	8b 43 08             	mov    0x8(%ebx),%eax
80100d39:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d3c:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d42:	8b 43 10             	mov    0x10(%ebx),%eax
80100d45:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d48:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d4f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d55:	83 ec 0c             	sub    $0xc,%esp
80100d58:	68 c0 01 11 80       	push   $0x801101c0
80100d5d:	e8 26 33 00 00       	call   80104088 <release>

  if(ff.type == FD_PIPE)
80100d62:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d65:	83 c4 10             	add    $0x10,%esp
80100d68:	83 f8 01             	cmp    $0x1,%eax
80100d6b:	74 41                	je     80100dae <fileclose+0xa9>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100d6d:	83 f8 02             	cmp    $0x2,%eax
80100d70:	75 37                	jne    80100da9 <fileclose+0xa4>
    begin_op();
80100d72:	e8 a0 1c 00 00       	call   80102a17 <begin_op>
    iput(ff.ip);
80100d77:	83 ec 0c             	sub    $0xc,%esp
80100d7a:	ff 75 f0             	pushl  -0x10(%ebp)
80100d7d:	e8 ad 0a 00 00       	call   8010182f <iput>
    end_op();
80100d82:	e8 0e 1d 00 00       	call   80102a95 <end_op>
80100d87:	83 c4 10             	add    $0x10,%esp
80100d8a:	eb 1d                	jmp    80100da9 <fileclose+0xa4>
    panic("fileclose");
80100d8c:	83 ec 0c             	sub    $0xc,%esp
80100d8f:	68 1c 71 10 80       	push   $0x8010711c
80100d94:	e8 c3 f5 ff ff       	call   8010035c <panic>
    release(&ftable.lock);
80100d99:	83 ec 0c             	sub    $0xc,%esp
80100d9c:	68 c0 01 11 80       	push   $0x801101c0
80100da1:	e8 e2 32 00 00       	call   80104088 <release>
    return;
80100da6:	83 c4 10             	add    $0x10,%esp
  }
}
80100da9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dac:	c9                   	leave  
80100dad:	c3                   	ret    
    pipeclose(ff.pipe, ff.writable);
80100dae:	83 ec 08             	sub    $0x8,%esp
80100db1:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100db5:	50                   	push   %eax
80100db6:	ff 75 ec             	pushl  -0x14(%ebp)
80100db9:	e8 33 23 00 00       	call   801030f1 <pipeclose>
80100dbe:	83 c4 10             	add    $0x10,%esp
80100dc1:	eb e6                	jmp    80100da9 <fileclose+0xa4>

80100dc3 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100dc3:	f3 0f 1e fb          	endbr32 
80100dc7:	55                   	push   %ebp
80100dc8:	89 e5                	mov    %esp,%ebp
80100dca:	53                   	push   %ebx
80100dcb:	83 ec 04             	sub    $0x4,%esp
80100dce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100dd1:	83 3b 02             	cmpl   $0x2,(%ebx)
80100dd4:	75 31                	jne    80100e07 <filestat+0x44>
    ilock(f->ip);
80100dd6:	83 ec 0c             	sub    $0xc,%esp
80100dd9:	ff 73 10             	pushl  0x10(%ebx)
80100ddc:	e8 24 09 00 00       	call   80101705 <ilock>
    stati(f->ip, st);
80100de1:	83 c4 08             	add    $0x8,%esp
80100de4:	ff 75 0c             	pushl  0xc(%ebp)
80100de7:	ff 73 10             	pushl  0x10(%ebx)
80100dea:	e8 17 0b 00 00       	call   80101906 <stati>
    iunlock(f->ip);
80100def:	83 c4 04             	add    $0x4,%esp
80100df2:	ff 73 10             	pushl  0x10(%ebx)
80100df5:	e8 ec 09 00 00       	call   801017e6 <iunlock>
    return 0;
80100dfa:	83 c4 10             	add    $0x10,%esp
80100dfd:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100e02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e05:	c9                   	leave  
80100e06:	c3                   	ret    
  return -1;
80100e07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e0c:	eb f4                	jmp    80100e02 <filestat+0x3f>

80100e0e <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100e0e:	f3 0f 1e fb          	endbr32 
80100e12:	55                   	push   %ebp
80100e13:	89 e5                	mov    %esp,%ebp
80100e15:	56                   	push   %esi
80100e16:	53                   	push   %ebx
80100e17:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100e1a:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100e1e:	74 70                	je     80100e90 <fileread+0x82>
    return -1;
  if(f->type == FD_PIPE)
80100e20:	8b 03                	mov    (%ebx),%eax
80100e22:	83 f8 01             	cmp    $0x1,%eax
80100e25:	74 44                	je     80100e6b <fileread+0x5d>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e27:	83 f8 02             	cmp    $0x2,%eax
80100e2a:	75 57                	jne    80100e83 <fileread+0x75>
    ilock(f->ip);
80100e2c:	83 ec 0c             	sub    $0xc,%esp
80100e2f:	ff 73 10             	pushl  0x10(%ebx)
80100e32:	e8 ce 08 00 00       	call   80101705 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100e37:	ff 75 10             	pushl  0x10(%ebp)
80100e3a:	ff 73 14             	pushl  0x14(%ebx)
80100e3d:	ff 75 0c             	pushl  0xc(%ebp)
80100e40:	ff 73 10             	pushl  0x10(%ebx)
80100e43:	e8 f6 0a 00 00       	call   8010193e <readi>
80100e48:	89 c6                	mov    %eax,%esi
80100e4a:	83 c4 20             	add    $0x20,%esp
80100e4d:	85 c0                	test   %eax,%eax
80100e4f:	7e 03                	jle    80100e54 <fileread+0x46>
      f->off += r;
80100e51:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e54:	83 ec 0c             	sub    $0xc,%esp
80100e57:	ff 73 10             	pushl  0x10(%ebx)
80100e5a:	e8 87 09 00 00       	call   801017e6 <iunlock>
    return r;
80100e5f:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e62:	89 f0                	mov    %esi,%eax
80100e64:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e67:	5b                   	pop    %ebx
80100e68:	5e                   	pop    %esi
80100e69:	5d                   	pop    %ebp
80100e6a:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e6b:	83 ec 04             	sub    $0x4,%esp
80100e6e:	ff 75 10             	pushl  0x10(%ebp)
80100e71:	ff 75 0c             	pushl  0xc(%ebp)
80100e74:	ff 73 0c             	pushl  0xc(%ebx)
80100e77:	e8 cf 23 00 00       	call   8010324b <piperead>
80100e7c:	89 c6                	mov    %eax,%esi
80100e7e:	83 c4 10             	add    $0x10,%esp
80100e81:	eb df                	jmp    80100e62 <fileread+0x54>
  panic("fileread");
80100e83:	83 ec 0c             	sub    $0xc,%esp
80100e86:	68 26 71 10 80       	push   $0x80107126
80100e8b:	e8 cc f4 ff ff       	call   8010035c <panic>
    return -1;
80100e90:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e95:	eb cb                	jmp    80100e62 <fileread+0x54>

80100e97 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e97:	f3 0f 1e fb          	endbr32 
80100e9b:	55                   	push   %ebp
80100e9c:	89 e5                	mov    %esp,%ebp
80100e9e:	57                   	push   %edi
80100e9f:	56                   	push   %esi
80100ea0:	53                   	push   %ebx
80100ea1:	83 ec 1c             	sub    $0x1c,%esp
80100ea4:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;

  if(f->writable == 0)
80100ea7:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
80100eab:	0f 84 cc 00 00 00    	je     80100f7d <filewrite+0xe6>
    return -1;
  if(f->type == FD_PIPE)
80100eb1:	8b 06                	mov    (%esi),%eax
80100eb3:	83 f8 01             	cmp    $0x1,%eax
80100eb6:	74 10                	je     80100ec8 <filewrite+0x31>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100eb8:	83 f8 02             	cmp    $0x2,%eax
80100ebb:	0f 85 af 00 00 00    	jne    80100f70 <filewrite+0xd9>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100ec1:	bf 00 00 00 00       	mov    $0x0,%edi
80100ec6:	eb 67                	jmp    80100f2f <filewrite+0x98>
    return pipewrite(f->pipe, addr, n);
80100ec8:	83 ec 04             	sub    $0x4,%esp
80100ecb:	ff 75 10             	pushl  0x10(%ebp)
80100ece:	ff 75 0c             	pushl  0xc(%ebp)
80100ed1:	ff 76 0c             	pushl  0xc(%esi)
80100ed4:	e8 a8 22 00 00       	call   80103181 <pipewrite>
80100ed9:	83 c4 10             	add    $0x10,%esp
80100edc:	e9 82 00 00 00       	jmp    80100f63 <filewrite+0xcc>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ee1:	e8 31 1b 00 00       	call   80102a17 <begin_op>
      ilock(f->ip);
80100ee6:	83 ec 0c             	sub    $0xc,%esp
80100ee9:	ff 76 10             	pushl  0x10(%esi)
80100eec:	e8 14 08 00 00       	call   80101705 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100ef1:	ff 75 e4             	pushl  -0x1c(%ebp)
80100ef4:	ff 76 14             	pushl  0x14(%esi)
80100ef7:	89 f8                	mov    %edi,%eax
80100ef9:	03 45 0c             	add    0xc(%ebp),%eax
80100efc:	50                   	push   %eax
80100efd:	ff 76 10             	pushl  0x10(%esi)
80100f00:	e8 43 0b 00 00       	call   80101a48 <writei>
80100f05:	89 c3                	mov    %eax,%ebx
80100f07:	83 c4 20             	add    $0x20,%esp
80100f0a:	85 c0                	test   %eax,%eax
80100f0c:	7e 03                	jle    80100f11 <filewrite+0x7a>
        f->off += r;
80100f0e:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
80100f11:	83 ec 0c             	sub    $0xc,%esp
80100f14:	ff 76 10             	pushl  0x10(%esi)
80100f17:	e8 ca 08 00 00       	call   801017e6 <iunlock>
      end_op();
80100f1c:	e8 74 1b 00 00       	call   80102a95 <end_op>

      if(r < 0)
80100f21:	83 c4 10             	add    $0x10,%esp
80100f24:	85 db                	test   %ebx,%ebx
80100f26:	78 31                	js     80100f59 <filewrite+0xc2>
        break;
      if(r != n1)
80100f28:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
80100f2b:	75 1f                	jne    80100f4c <filewrite+0xb5>
        panic("short filewrite");
      i += r;
80100f2d:	01 df                	add    %ebx,%edi
    while(i < n){
80100f2f:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f32:	7d 25                	jge    80100f59 <filewrite+0xc2>
      int n1 = n - i;
80100f34:	8b 45 10             	mov    0x10(%ebp),%eax
80100f37:	29 f8                	sub    %edi,%eax
80100f39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100f3c:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f41:	7e 9e                	jle    80100ee1 <filewrite+0x4a>
        n1 = max;
80100f43:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f4a:	eb 95                	jmp    80100ee1 <filewrite+0x4a>
        panic("short filewrite");
80100f4c:	83 ec 0c             	sub    $0xc,%esp
80100f4f:	68 2f 71 10 80       	push   $0x8010712f
80100f54:	e8 03 f4 ff ff       	call   8010035c <panic>
    }
    return i == n ? n : -1;
80100f59:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f5c:	74 0d                	je     80100f6b <filewrite+0xd4>
80100f5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80100f63:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f66:	5b                   	pop    %ebx
80100f67:	5e                   	pop    %esi
80100f68:	5f                   	pop    %edi
80100f69:	5d                   	pop    %ebp
80100f6a:	c3                   	ret    
    return i == n ? n : -1;
80100f6b:	8b 45 10             	mov    0x10(%ebp),%eax
80100f6e:	eb f3                	jmp    80100f63 <filewrite+0xcc>
  panic("filewrite");
80100f70:	83 ec 0c             	sub    $0xc,%esp
80100f73:	68 35 71 10 80       	push   $0x80107135
80100f78:	e8 df f3 ff ff       	call   8010035c <panic>
    return -1;
80100f7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f82:	eb df                	jmp    80100f63 <filewrite+0xcc>

80100f84 <filelock>:

int filelock(struct file* fp) { 
80100f84:	f3 0f 1e fb          	endbr32 
80100f88:	55                   	push   %ebp
80100f89:	89 e5                	mov    %esp,%ebp
80100f8b:	83 ec 08             	sub    $0x8,%esp
  if(fp->ip == 0 || fp->ip->ref < 1) {
80100f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80100f91:	8b 40 10             	mov    0x10(%eax),%eax
80100f94:	85 c0                	test   %eax,%eax
80100f96:	74 19                	je     80100fb1 <filelock+0x2d>
80100f98:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
80100f9c:	7e 1a                	jle    80100fb8 <filelock+0x34>
    return -1;
  }

  fsemaphore_lock(fp->ip);
80100f9e:	83 ec 0c             	sub    $0xc,%esp
80100fa1:	50                   	push   %eax
80100fa2:	e8 e0 06 00 00       	call   80101687 <fsemaphore_lock>
  return 0;
80100fa7:	83 c4 10             	add    $0x10,%esp
80100faa:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100faf:	c9                   	leave  
80100fb0:	c3                   	ret    
    return -1;
80100fb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100fb6:	eb f7                	jmp    80100faf <filelock+0x2b>
80100fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100fbd:	eb f0                	jmp    80100faf <filelock+0x2b>

80100fbf <fileunlock>:

int fileunlock(struct file* fp)
{
80100fbf:	f3 0f 1e fb          	endbr32 
80100fc3:	55                   	push   %ebp
80100fc4:	89 e5                	mov    %esp,%ebp
80100fc6:	53                   	push   %ebx
80100fc7:	83 ec 04             	sub    $0x4,%esp
80100fca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int status = -1;

  if(fp->ip != 0 && holdingsleep(&fp->ip->flock) && !(fp->ip->ref < 1)) {
80100fcd:	8b 43 10             	mov    0x10(%ebx),%eax
80100fd0:	85 c0                	test   %eax,%eax
80100fd2:	74 32                	je     80101006 <fileunlock+0x47>
80100fd4:	83 ec 0c             	sub    $0xc,%esp
80100fd7:	83 c0 0c             	add    $0xc,%eax
80100fda:	50                   	push   %eax
80100fdb:	e8 9d 2e 00 00       	call   80103e7d <holdingsleep>
80100fe0:	83 c4 10             	add    $0x10,%esp
80100fe3:	85 c0                	test   %eax,%eax
80100fe5:	74 26                	je     8010100d <fileunlock+0x4e>
80100fe7:	8b 43 10             	mov    0x10(%ebx),%eax
80100fea:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
80100fee:	7e 24                	jle    80101014 <fileunlock+0x55>
    fsemaphore_unlock(fp->ip);
80100ff0:	83 ec 0c             	sub    $0xc,%esp
80100ff3:	50                   	push   %eax
80100ff4:	e8 c3 06 00 00       	call   801016bc <fsemaphore_unlock>
80100ff9:	83 c4 10             	add    $0x10,%esp
    status = 0;
80100ffc:	b8 00 00 00 00       	mov    $0x0,%eax
  }

  return status;
}
80101001:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101004:	c9                   	leave  
80101005:	c3                   	ret    
  int status = -1;
80101006:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010100b:	eb f4                	jmp    80101001 <fileunlock+0x42>
8010100d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101012:	eb ed                	jmp    80101001 <fileunlock+0x42>
80101014:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return status;
80101019:	eb e6                	jmp    80101001 <fileunlock+0x42>

8010101b <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010101b:	55                   	push   %ebp
8010101c:	89 e5                	mov    %esp,%ebp
8010101e:	57                   	push   %edi
8010101f:	56                   	push   %esi
80101020:	53                   	push   %ebx
80101021:	83 ec 0c             	sub    $0xc,%esp
80101024:	89 d6                	mov    %edx,%esi
  char *s;
  int len;

  while(*path == '/')
80101026:	0f b6 10             	movzbl (%eax),%edx
80101029:	80 fa 2f             	cmp    $0x2f,%dl
8010102c:	75 05                	jne    80101033 <skipelem+0x18>
    path++;
8010102e:	83 c0 01             	add    $0x1,%eax
80101031:	eb f3                	jmp    80101026 <skipelem+0xb>
  if(*path == 0)
80101033:	84 d2                	test   %dl,%dl
80101035:	74 59                	je     80101090 <skipelem+0x75>
80101037:	89 c3                	mov    %eax,%ebx
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101039:	0f b6 13             	movzbl (%ebx),%edx
8010103c:	80 fa 2f             	cmp    $0x2f,%dl
8010103f:	0f 95 c1             	setne  %cl
80101042:	84 d2                	test   %dl,%dl
80101044:	0f 95 c2             	setne  %dl
80101047:	84 d1                	test   %dl,%cl
80101049:	74 05                	je     80101050 <skipelem+0x35>
    path++;
8010104b:	83 c3 01             	add    $0x1,%ebx
8010104e:	eb e9                	jmp    80101039 <skipelem+0x1e>
  len = path - s;
80101050:	89 df                	mov    %ebx,%edi
80101052:	29 c7                	sub    %eax,%edi
  if(len >= DIRSIZ)
80101054:	83 ff 0d             	cmp    $0xd,%edi
80101057:	7e 11                	jle    8010106a <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80101059:	83 ec 04             	sub    $0x4,%esp
8010105c:	6a 0e                	push   $0xe
8010105e:	50                   	push   %eax
8010105f:	56                   	push   %esi
80101060:	e8 ee 30 00 00       	call   80104153 <memmove>
80101065:	83 c4 10             	add    $0x10,%esp
80101068:	eb 17                	jmp    80101081 <skipelem+0x66>
  else {
    memmove(name, s, len);
8010106a:	83 ec 04             	sub    $0x4,%esp
8010106d:	57                   	push   %edi
8010106e:	50                   	push   %eax
8010106f:	56                   	push   %esi
80101070:	e8 de 30 00 00       	call   80104153 <memmove>
    name[len] = 0;
80101075:	c6 04 3e 00          	movb   $0x0,(%esi,%edi,1)
80101079:	83 c4 10             	add    $0x10,%esp
8010107c:	eb 03                	jmp    80101081 <skipelem+0x66>
  }
  while(*path == '/')
    path++;
8010107e:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101081:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101084:	74 f8                	je     8010107e <skipelem+0x63>
  return path;
}
80101086:	89 d8                	mov    %ebx,%eax
80101088:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010108b:	5b                   	pop    %ebx
8010108c:	5e                   	pop    %esi
8010108d:	5f                   	pop    %edi
8010108e:	5d                   	pop    %ebp
8010108f:	c3                   	ret    
    return 0;
80101090:	bb 00 00 00 00       	mov    $0x0,%ebx
80101095:	eb ef                	jmp    80101086 <skipelem+0x6b>

80101097 <bzero>:
{
80101097:	55                   	push   %ebp
80101098:	89 e5                	mov    %esp,%ebp
8010109a:	53                   	push   %ebx
8010109b:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
8010109e:	52                   	push   %edx
8010109f:	50                   	push   %eax
801010a0:	e8 cb f0 ff ff       	call   80100170 <bread>
801010a5:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
801010a7:	8d 40 5c             	lea    0x5c(%eax),%eax
801010aa:	83 c4 0c             	add    $0xc,%esp
801010ad:	68 00 02 00 00       	push   $0x200
801010b2:	6a 00                	push   $0x0
801010b4:	50                   	push   %eax
801010b5:	e8 19 30 00 00       	call   801040d3 <memset>
  log_write(bp);
801010ba:	89 1c 24             	mov    %ebx,(%esp)
801010bd:	e8 86 1a 00 00       	call   80102b48 <log_write>
  brelse(bp);
801010c2:	89 1c 24             	mov    %ebx,(%esp)
801010c5:	e8 17 f1 ff ff       	call   801001e1 <brelse>
}
801010ca:	83 c4 10             	add    $0x10,%esp
801010cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801010d0:	c9                   	leave  
801010d1:	c3                   	ret    

801010d2 <bfree>:
{
801010d2:	55                   	push   %ebp
801010d3:	89 e5                	mov    %esp,%ebp
801010d5:	57                   	push   %edi
801010d6:	56                   	push   %esi
801010d7:	53                   	push   %ebx
801010d8:	83 ec 14             	sub    $0x14,%esp
801010db:	89 c3                	mov    %eax,%ebx
801010dd:	89 d6                	mov    %edx,%esi
  bp = bread(dev, BBLOCK(b, sb));
801010df:	89 d0                	mov    %edx,%eax
801010e1:	c1 e8 0c             	shr    $0xc,%eax
801010e4:	03 05 d8 0b 11 80    	add    0x80110bd8,%eax
801010ea:	50                   	push   %eax
801010eb:	53                   	push   %ebx
801010ec:	e8 7f f0 ff ff       	call   80100170 <bread>
801010f1:	89 c3                	mov    %eax,%ebx
  bi = b % BPB;
801010f3:	89 f7                	mov    %esi,%edi
801010f5:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
  m = 1 << (bi % 8);
801010fb:	89 f1                	mov    %esi,%ecx
801010fd:	83 e1 07             	and    $0x7,%ecx
80101100:	b8 01 00 00 00       	mov    $0x1,%eax
80101105:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101107:	83 c4 10             	add    $0x10,%esp
8010110a:	c1 ff 03             	sar    $0x3,%edi
8010110d:	0f b6 54 3b 5c       	movzbl 0x5c(%ebx,%edi,1),%edx
80101112:	0f b6 ca             	movzbl %dl,%ecx
80101115:	85 c1                	test   %eax,%ecx
80101117:	74 24                	je     8010113d <bfree+0x6b>
  bp->data[bi/8] &= ~m;
80101119:	f7 d0                	not    %eax
8010111b:	21 d0                	and    %edx,%eax
8010111d:	88 44 3b 5c          	mov    %al,0x5c(%ebx,%edi,1)
  log_write(bp);
80101121:	83 ec 0c             	sub    $0xc,%esp
80101124:	53                   	push   %ebx
80101125:	e8 1e 1a 00 00       	call   80102b48 <log_write>
  brelse(bp);
8010112a:	89 1c 24             	mov    %ebx,(%esp)
8010112d:	e8 af f0 ff ff       	call   801001e1 <brelse>
}
80101132:	83 c4 10             	add    $0x10,%esp
80101135:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101138:	5b                   	pop    %ebx
80101139:	5e                   	pop    %esi
8010113a:	5f                   	pop    %edi
8010113b:	5d                   	pop    %ebp
8010113c:	c3                   	ret    
    panic("freeing free block");
8010113d:	83 ec 0c             	sub    $0xc,%esp
80101140:	68 3f 71 10 80       	push   $0x8010713f
80101145:	e8 12 f2 ff ff       	call   8010035c <panic>

8010114a <balloc>:
{
8010114a:	55                   	push   %ebp
8010114b:	89 e5                	mov    %esp,%ebp
8010114d:	57                   	push   %edi
8010114e:	56                   	push   %esi
8010114f:	53                   	push   %ebx
80101150:	83 ec 1c             	sub    $0x1c,%esp
80101153:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101156:	be 00 00 00 00       	mov    $0x0,%esi
8010115b:	eb 14                	jmp    80101171 <balloc+0x27>
    brelse(bp);
8010115d:	83 ec 0c             	sub    $0xc,%esp
80101160:	ff 75 e4             	pushl  -0x1c(%ebp)
80101163:	e8 79 f0 ff ff       	call   801001e1 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101168:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010116e:	83 c4 10             	add    $0x10,%esp
80101171:	39 35 c0 0b 11 80    	cmp    %esi,0x80110bc0
80101177:	76 75                	jbe    801011ee <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
80101179:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
8010117f:	85 f6                	test   %esi,%esi
80101181:	0f 49 c6             	cmovns %esi,%eax
80101184:	c1 f8 0c             	sar    $0xc,%eax
80101187:	83 ec 08             	sub    $0x8,%esp
8010118a:	03 05 d8 0b 11 80    	add    0x80110bd8,%eax
80101190:	50                   	push   %eax
80101191:	ff 75 d8             	pushl  -0x28(%ebp)
80101194:	e8 d7 ef ff ff       	call   80100170 <bread>
80101199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010119c:	83 c4 10             	add    $0x10,%esp
8010119f:	b8 00 00 00 00       	mov    $0x0,%eax
801011a4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801011a9:	7f b2                	jg     8010115d <balloc+0x13>
801011ab:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
801011ae:	89 5d e0             	mov    %ebx,-0x20(%ebp)
801011b1:	3b 1d c0 0b 11 80    	cmp    0x80110bc0,%ebx
801011b7:	73 a4                	jae    8010115d <balloc+0x13>
      m = 1 << (bi % 8);
801011b9:	99                   	cltd   
801011ba:	c1 ea 1d             	shr    $0x1d,%edx
801011bd:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
801011c0:	83 e1 07             	and    $0x7,%ecx
801011c3:	29 d1                	sub    %edx,%ecx
801011c5:	ba 01 00 00 00       	mov    $0x1,%edx
801011ca:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801011cc:	8d 48 07             	lea    0x7(%eax),%ecx
801011cf:	85 c0                	test   %eax,%eax
801011d1:	0f 49 c8             	cmovns %eax,%ecx
801011d4:	c1 f9 03             	sar    $0x3,%ecx
801011d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
801011da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801011dd:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
801011e2:	0f b6 f9             	movzbl %cl,%edi
801011e5:	85 d7                	test   %edx,%edi
801011e7:	74 12                	je     801011fb <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801011e9:	83 c0 01             	add    $0x1,%eax
801011ec:	eb b6                	jmp    801011a4 <balloc+0x5a>
  panic("balloc: out of blocks");
801011ee:	83 ec 0c             	sub    $0xc,%esp
801011f1:	68 52 71 10 80       	push   $0x80107152
801011f6:	e8 61 f1 ff ff       	call   8010035c <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
801011fb:	09 ca                	or     %ecx,%edx
801011fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101200:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101203:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
80101207:	83 ec 0c             	sub    $0xc,%esp
8010120a:	89 c6                	mov    %eax,%esi
8010120c:	50                   	push   %eax
8010120d:	e8 36 19 00 00       	call   80102b48 <log_write>
        brelse(bp);
80101212:	89 34 24             	mov    %esi,(%esp)
80101215:	e8 c7 ef ff ff       	call   801001e1 <brelse>
        bzero(dev, b + bi);
8010121a:	89 da                	mov    %ebx,%edx
8010121c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010121f:	e8 73 fe ff ff       	call   80101097 <bzero>
}
80101224:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101227:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010122a:	5b                   	pop    %ebx
8010122b:	5e                   	pop    %esi
8010122c:	5f                   	pop    %edi
8010122d:	5d                   	pop    %ebp
8010122e:	c3                   	ret    

8010122f <bmap>:
{
8010122f:	55                   	push   %ebp
80101230:	89 e5                	mov    %esp,%ebp
80101232:	57                   	push   %edi
80101233:	56                   	push   %esi
80101234:	53                   	push   %ebx
80101235:	83 ec 1c             	sub    $0x1c,%esp
80101238:	89 c3                	mov    %eax,%ebx
8010123a:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
8010123c:	83 fa 0b             	cmp    $0xb,%edx
8010123f:	76 49                	jbe    8010128a <bmap+0x5b>
  bn -= NDIRECT;
80101241:	8d 72 f4             	lea    -0xc(%edx),%esi
  if(bn < NINDIRECT){
80101244:	83 fe 7f             	cmp    $0x7f,%esi
80101247:	0f 87 85 00 00 00    	ja     801012d2 <bmap+0xa3>
    if((addr = ip->addrs[NDIRECT]) == 0)
8010124d:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
80101253:	85 c0                	test   %eax,%eax
80101255:	74 50                	je     801012a7 <bmap+0x78>
    bp = bread(ip->dev, addr);
80101257:	83 ec 08             	sub    $0x8,%esp
8010125a:	50                   	push   %eax
8010125b:	ff 33                	pushl  (%ebx)
8010125d:	e8 0e ef ff ff       	call   80100170 <bread>
80101262:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101264:	8d 44 b0 5c          	lea    0x5c(%eax,%esi,4),%eax
80101268:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010126b:	8b 30                	mov    (%eax),%esi
8010126d:	83 c4 10             	add    $0x10,%esp
80101270:	85 f6                	test   %esi,%esi
80101272:	74 42                	je     801012b6 <bmap+0x87>
    brelse(bp);
80101274:	83 ec 0c             	sub    $0xc,%esp
80101277:	57                   	push   %edi
80101278:	e8 64 ef ff ff       	call   801001e1 <brelse>
    return addr;
8010127d:	83 c4 10             	add    $0x10,%esp
}
80101280:	89 f0                	mov    %esi,%eax
80101282:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101285:	5b                   	pop    %ebx
80101286:	5e                   	pop    %esi
80101287:	5f                   	pop    %edi
80101288:	5d                   	pop    %ebp
80101289:	c3                   	ret    
    if((addr = ip->addrs[bn]) == 0)
8010128a:	8b b4 90 9c 00 00 00 	mov    0x9c(%eax,%edx,4),%esi
80101291:	85 f6                	test   %esi,%esi
80101293:	75 eb                	jne    80101280 <bmap+0x51>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101295:	8b 00                	mov    (%eax),%eax
80101297:	e8 ae fe ff ff       	call   8010114a <balloc>
8010129c:	89 c6                	mov    %eax,%esi
8010129e:	89 84 bb 9c 00 00 00 	mov    %eax,0x9c(%ebx,%edi,4)
    return addr;
801012a5:	eb d9                	jmp    80101280 <bmap+0x51>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801012a7:	8b 03                	mov    (%ebx),%eax
801012a9:	e8 9c fe ff ff       	call   8010114a <balloc>
801012ae:	89 83 cc 00 00 00    	mov    %eax,0xcc(%ebx)
801012b4:	eb a1                	jmp    80101257 <bmap+0x28>
      a[bn] = addr = balloc(ip->dev);
801012b6:	8b 03                	mov    (%ebx),%eax
801012b8:	e8 8d fe ff ff       	call   8010114a <balloc>
801012bd:	89 c6                	mov    %eax,%esi
801012bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801012c2:	89 30                	mov    %esi,(%eax)
      log_write(bp);
801012c4:	83 ec 0c             	sub    $0xc,%esp
801012c7:	57                   	push   %edi
801012c8:	e8 7b 18 00 00       	call   80102b48 <log_write>
801012cd:	83 c4 10             	add    $0x10,%esp
801012d0:	eb a2                	jmp    80101274 <bmap+0x45>
  panic("bmap: out of range");
801012d2:	83 ec 0c             	sub    $0xc,%esp
801012d5:	68 68 71 10 80       	push   $0x80107168
801012da:	e8 7d f0 ff ff       	call   8010035c <panic>

801012df <iget>:
{
801012df:	55                   	push   %ebp
801012e0:	89 e5                	mov    %esp,%ebp
801012e2:	57                   	push   %edi
801012e3:	56                   	push   %esi
801012e4:	53                   	push   %ebx
801012e5:	83 ec 28             	sub    $0x28,%esp
801012e8:	89 c7                	mov    %eax,%edi
801012ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
801012ed:	68 e0 0b 11 80       	push   $0x80110be0
801012f2:	e8 28 2d 00 00       	call   8010401f <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801012f7:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801012fa:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801012ff:	bb 14 0c 11 80       	mov    $0x80110c14,%ebx
80101304:	eb 0a                	jmp    80101310 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101306:	85 f6                	test   %esi,%esi
80101308:	74 3b                	je     80101345 <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010130a:	81 c3 d0 00 00 00    	add    $0xd0,%ebx
80101310:	81 fb b4 34 11 80    	cmp    $0x801134b4,%ebx
80101316:	73 35                	jae    8010134d <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101318:	8b 43 08             	mov    0x8(%ebx),%eax
8010131b:	85 c0                	test   %eax,%eax
8010131d:	7e e7                	jle    80101306 <iget+0x27>
8010131f:	39 3b                	cmp    %edi,(%ebx)
80101321:	75 e3                	jne    80101306 <iget+0x27>
80101323:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101326:	39 4b 04             	cmp    %ecx,0x4(%ebx)
80101329:	75 db                	jne    80101306 <iget+0x27>
      ip->ref++;
8010132b:	83 c0 01             	add    $0x1,%eax
8010132e:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101331:	83 ec 0c             	sub    $0xc,%esp
80101334:	68 e0 0b 11 80       	push   $0x80110be0
80101339:	e8 4a 2d 00 00       	call   80104088 <release>
      return ip;
8010133e:	83 c4 10             	add    $0x10,%esp
80101341:	89 de                	mov    %ebx,%esi
80101343:	eb 35                	jmp    8010137a <iget+0x9b>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101345:	85 c0                	test   %eax,%eax
80101347:	75 c1                	jne    8010130a <iget+0x2b>
      empty = ip;
80101349:	89 de                	mov    %ebx,%esi
8010134b:	eb bd                	jmp    8010130a <iget+0x2b>
  if(empty == 0)
8010134d:	85 f6                	test   %esi,%esi
8010134f:	74 33                	je     80101384 <iget+0xa5>
  ip->dev = dev;
80101351:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
80101353:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101356:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101359:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101360:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101367:	00 00 00 
  release(&icache.lock);
8010136a:	83 ec 0c             	sub    $0xc,%esp
8010136d:	68 e0 0b 11 80       	push   $0x80110be0
80101372:	e8 11 2d 00 00       	call   80104088 <release>
  return ip;
80101377:	83 c4 10             	add    $0x10,%esp
}
8010137a:	89 f0                	mov    %esi,%eax
8010137c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010137f:	5b                   	pop    %ebx
80101380:	5e                   	pop    %esi
80101381:	5f                   	pop    %edi
80101382:	5d                   	pop    %ebp
80101383:	c3                   	ret    
    panic("iget: no inodes");
80101384:	83 ec 0c             	sub    $0xc,%esp
80101387:	68 7b 71 10 80       	push   $0x8010717b
8010138c:	e8 cb ef ff ff       	call   8010035c <panic>

80101391 <readsb>:
{
80101391:	f3 0f 1e fb          	endbr32 
80101395:	55                   	push   %ebp
80101396:	89 e5                	mov    %esp,%ebp
80101398:	53                   	push   %ebx
80101399:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
8010139c:	6a 01                	push   $0x1
8010139e:	ff 75 08             	pushl  0x8(%ebp)
801013a1:	e8 ca ed ff ff       	call   80100170 <bread>
801013a6:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801013a8:	8d 40 5c             	lea    0x5c(%eax),%eax
801013ab:	83 c4 0c             	add    $0xc,%esp
801013ae:	6a 1c                	push   $0x1c
801013b0:	50                   	push   %eax
801013b1:	ff 75 0c             	pushl  0xc(%ebp)
801013b4:	e8 9a 2d 00 00       	call   80104153 <memmove>
  brelse(bp);
801013b9:	89 1c 24             	mov    %ebx,(%esp)
801013bc:	e8 20 ee ff ff       	call   801001e1 <brelse>
}
801013c1:	83 c4 10             	add    $0x10,%esp
801013c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013c7:	c9                   	leave  
801013c8:	c3                   	ret    

801013c9 <iinit>:
{
801013c9:	f3 0f 1e fb          	endbr32 
801013cd:	55                   	push   %ebp
801013ce:	89 e5                	mov    %esp,%ebp
801013d0:	53                   	push   %ebx
801013d1:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801013d4:	68 8b 71 10 80       	push   $0x8010718b
801013d9:	68 e0 0b 11 80       	push   $0x80110be0
801013de:	e8 ec 2a 00 00       	call   80103ecf <initlock>
  for(i = 0; i < NINODE; i++) {
801013e3:	83 c4 10             	add    $0x10,%esp
801013e6:	bb 00 00 00 00       	mov    $0x0,%ebx
801013eb:	83 fb 31             	cmp    $0x31,%ebx
801013ee:	7f 21                	jg     80101411 <iinit+0x48>
    initsleeplock(&icache.inode[i].lock, "inode");
801013f0:	83 ec 08             	sub    $0x8,%esp
801013f3:	68 92 71 10 80       	push   $0x80107192
801013f8:	69 c3 d0 00 00 00    	imul   $0xd0,%ebx,%eax
801013fe:	05 60 0c 11 80       	add    $0x80110c60,%eax
80101403:	50                   	push   %eax
80101404:	e8 ab 29 00 00       	call   80103db4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101409:	83 c3 01             	add    $0x1,%ebx
8010140c:	83 c4 10             	add    $0x10,%esp
8010140f:	eb da                	jmp    801013eb <iinit+0x22>
  readsb(dev, &sb);
80101411:	83 ec 08             	sub    $0x8,%esp
80101414:	68 c0 0b 11 80       	push   $0x80110bc0
80101419:	ff 75 08             	pushl  0x8(%ebp)
8010141c:	e8 70 ff ff ff       	call   80101391 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101421:	ff 35 d8 0b 11 80    	pushl  0x80110bd8
80101427:	ff 35 d4 0b 11 80    	pushl  0x80110bd4
8010142d:	ff 35 d0 0b 11 80    	pushl  0x80110bd0
80101433:	ff 35 cc 0b 11 80    	pushl  0x80110bcc
80101439:	ff 35 c8 0b 11 80    	pushl  0x80110bc8
8010143f:	ff 35 c4 0b 11 80    	pushl  0x80110bc4
80101445:	ff 35 c0 0b 11 80    	pushl  0x80110bc0
8010144b:	68 04 72 10 80       	push   $0x80107204
80101450:	e8 d4 f1 ff ff       	call   80100629 <cprintf>
}
80101455:	83 c4 30             	add    $0x30,%esp
80101458:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010145b:	c9                   	leave  
8010145c:	c3                   	ret    

8010145d <ialloc>:
{
8010145d:	f3 0f 1e fb          	endbr32 
80101461:	55                   	push   %ebp
80101462:	89 e5                	mov    %esp,%ebp
80101464:	57                   	push   %edi
80101465:	56                   	push   %esi
80101466:	53                   	push   %ebx
80101467:	83 ec 1c             	sub    $0x1c,%esp
8010146a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010146d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101470:	bb 01 00 00 00       	mov    $0x1,%ebx
80101475:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101478:	39 1d c8 0b 11 80    	cmp    %ebx,0x80110bc8
8010147e:	76 76                	jbe    801014f6 <ialloc+0x99>
    bp = bread(dev, IBLOCK(inum, sb));
80101480:	89 d8                	mov    %ebx,%eax
80101482:	c1 e8 03             	shr    $0x3,%eax
80101485:	83 ec 08             	sub    $0x8,%esp
80101488:	03 05 d4 0b 11 80    	add    0x80110bd4,%eax
8010148e:	50                   	push   %eax
8010148f:	ff 75 08             	pushl  0x8(%ebp)
80101492:	e8 d9 ec ff ff       	call   80100170 <bread>
80101497:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
80101499:	89 d8                	mov    %ebx,%eax
8010149b:	83 e0 07             	and    $0x7,%eax
8010149e:	c1 e0 06             	shl    $0x6,%eax
801014a1:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801014a5:	83 c4 10             	add    $0x10,%esp
801014a8:	66 83 3f 00          	cmpw   $0x0,(%edi)
801014ac:	74 11                	je     801014bf <ialloc+0x62>
    brelse(bp);
801014ae:	83 ec 0c             	sub    $0xc,%esp
801014b1:	56                   	push   %esi
801014b2:	e8 2a ed ff ff       	call   801001e1 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801014b7:	83 c3 01             	add    $0x1,%ebx
801014ba:	83 c4 10             	add    $0x10,%esp
801014bd:	eb b6                	jmp    80101475 <ialloc+0x18>
      memset(dip, 0, sizeof(*dip));
801014bf:	83 ec 04             	sub    $0x4,%esp
801014c2:	6a 40                	push   $0x40
801014c4:	6a 00                	push   $0x0
801014c6:	57                   	push   %edi
801014c7:	e8 07 2c 00 00       	call   801040d3 <memset>
      dip->type = type;
801014cc:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801014d0:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801014d3:	89 34 24             	mov    %esi,(%esp)
801014d6:	e8 6d 16 00 00       	call   80102b48 <log_write>
      brelse(bp);
801014db:	89 34 24             	mov    %esi,(%esp)
801014de:	e8 fe ec ff ff       	call   801001e1 <brelse>
      return iget(dev, inum);
801014e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801014e6:	8b 45 08             	mov    0x8(%ebp),%eax
801014e9:	e8 f1 fd ff ff       	call   801012df <iget>
}
801014ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014f1:	5b                   	pop    %ebx
801014f2:	5e                   	pop    %esi
801014f3:	5f                   	pop    %edi
801014f4:	5d                   	pop    %ebp
801014f5:	c3                   	ret    
  panic("ialloc: no inodes");
801014f6:	83 ec 0c             	sub    $0xc,%esp
801014f9:	68 98 71 10 80       	push   $0x80107198
801014fe:	e8 59 ee ff ff       	call   8010035c <panic>

80101503 <iupdate>:
{
80101503:	f3 0f 1e fb          	endbr32 
80101507:	55                   	push   %ebp
80101508:	89 e5                	mov    %esp,%ebp
8010150a:	56                   	push   %esi
8010150b:	53                   	push   %ebx
8010150c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010150f:	8b 43 04             	mov    0x4(%ebx),%eax
80101512:	c1 e8 03             	shr    $0x3,%eax
80101515:	83 ec 08             	sub    $0x8,%esp
80101518:	03 05 d4 0b 11 80    	add    0x80110bd4,%eax
8010151e:	50                   	push   %eax
8010151f:	ff 33                	pushl  (%ebx)
80101521:	e8 4a ec ff ff       	call   80100170 <bread>
80101526:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101528:	8b 43 04             	mov    0x4(%ebx),%eax
8010152b:	83 e0 07             	and    $0x7,%eax
8010152e:	c1 e0 06             	shl    $0x6,%eax
80101531:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101535:	0f b7 93 90 00 00 00 	movzwl 0x90(%ebx),%edx
8010153c:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010153f:	0f b7 93 92 00 00 00 	movzwl 0x92(%ebx),%edx
80101546:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010154a:	0f b7 93 94 00 00 00 	movzwl 0x94(%ebx),%edx
80101551:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101555:	0f b7 93 96 00 00 00 	movzwl 0x96(%ebx),%edx
8010155c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101560:	8b 93 98 00 00 00    	mov    0x98(%ebx),%edx
80101566:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101569:	81 c3 9c 00 00 00    	add    $0x9c,%ebx
8010156f:	83 c0 0c             	add    $0xc,%eax
80101572:	83 c4 0c             	add    $0xc,%esp
80101575:	6a 34                	push   $0x34
80101577:	53                   	push   %ebx
80101578:	50                   	push   %eax
80101579:	e8 d5 2b 00 00       	call   80104153 <memmove>
  log_write(bp);
8010157e:	89 34 24             	mov    %esi,(%esp)
80101581:	e8 c2 15 00 00       	call   80102b48 <log_write>
  brelse(bp);
80101586:	89 34 24             	mov    %esi,(%esp)
80101589:	e8 53 ec ff ff       	call   801001e1 <brelse>
}
8010158e:	83 c4 10             	add    $0x10,%esp
80101591:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101594:	5b                   	pop    %ebx
80101595:	5e                   	pop    %esi
80101596:	5d                   	pop    %ebp
80101597:	c3                   	ret    

80101598 <itrunc>:
{
80101598:	55                   	push   %ebp
80101599:	89 e5                	mov    %esp,%ebp
8010159b:	57                   	push   %edi
8010159c:	56                   	push   %esi
8010159d:	53                   	push   %ebx
8010159e:	83 ec 1c             	sub    $0x1c,%esp
801015a1:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
801015a3:	bb 00 00 00 00       	mov    $0x0,%ebx
801015a8:	eb 03                	jmp    801015ad <itrunc+0x15>
801015aa:	83 c3 01             	add    $0x1,%ebx
801015ad:	83 fb 0b             	cmp    $0xb,%ebx
801015b0:	7f 1f                	jg     801015d1 <itrunc+0x39>
    if(ip->addrs[i]){
801015b2:	8b 94 9e 9c 00 00 00 	mov    0x9c(%esi,%ebx,4),%edx
801015b9:	85 d2                	test   %edx,%edx
801015bb:	74 ed                	je     801015aa <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801015bd:	8b 06                	mov    (%esi),%eax
801015bf:	e8 0e fb ff ff       	call   801010d2 <bfree>
      ip->addrs[i] = 0;
801015c4:	c7 84 9e 9c 00 00 00 	movl   $0x0,0x9c(%esi,%ebx,4)
801015cb:	00 00 00 00 
801015cf:	eb d9                	jmp    801015aa <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801015d1:	8b 86 cc 00 00 00    	mov    0xcc(%esi),%eax
801015d7:	85 c0                	test   %eax,%eax
801015d9:	75 1e                	jne    801015f9 <itrunc+0x61>
  ip->size = 0;
801015db:	c7 86 98 00 00 00 00 	movl   $0x0,0x98(%esi)
801015e2:	00 00 00 
  iupdate(ip);
801015e5:	83 ec 0c             	sub    $0xc,%esp
801015e8:	56                   	push   %esi
801015e9:	e8 15 ff ff ff       	call   80101503 <iupdate>
}
801015ee:	83 c4 10             	add    $0x10,%esp
801015f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801015f4:	5b                   	pop    %ebx
801015f5:	5e                   	pop    %esi
801015f6:	5f                   	pop    %edi
801015f7:	5d                   	pop    %ebp
801015f8:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801015f9:	83 ec 08             	sub    $0x8,%esp
801015fc:	50                   	push   %eax
801015fd:	ff 36                	pushl  (%esi)
801015ff:	e8 6c eb ff ff       	call   80100170 <bread>
80101604:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101607:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
8010160a:	83 c4 10             	add    $0x10,%esp
8010160d:	bb 00 00 00 00       	mov    $0x0,%ebx
80101612:	eb 0a                	jmp    8010161e <itrunc+0x86>
        bfree(ip->dev, a[j]);
80101614:	8b 06                	mov    (%esi),%eax
80101616:	e8 b7 fa ff ff       	call   801010d2 <bfree>
    for(j = 0; j < NINDIRECT; j++){
8010161b:	83 c3 01             	add    $0x1,%ebx
8010161e:	83 fb 7f             	cmp    $0x7f,%ebx
80101621:	77 09                	ja     8010162c <itrunc+0x94>
      if(a[j])
80101623:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
80101626:	85 d2                	test   %edx,%edx
80101628:	74 f1                	je     8010161b <itrunc+0x83>
8010162a:	eb e8                	jmp    80101614 <itrunc+0x7c>
    brelse(bp);
8010162c:	83 ec 0c             	sub    $0xc,%esp
8010162f:	ff 75 e4             	pushl  -0x1c(%ebp)
80101632:	e8 aa eb ff ff       	call   801001e1 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101637:	8b 06                	mov    (%esi),%eax
80101639:	8b 96 cc 00 00 00    	mov    0xcc(%esi),%edx
8010163f:	e8 8e fa ff ff       	call   801010d2 <bfree>
    ip->addrs[NDIRECT] = 0;
80101644:	c7 86 cc 00 00 00 00 	movl   $0x0,0xcc(%esi)
8010164b:	00 00 00 
8010164e:	83 c4 10             	add    $0x10,%esp
80101651:	eb 88                	jmp    801015db <itrunc+0x43>

80101653 <idup>:
{
80101653:	f3 0f 1e fb          	endbr32 
80101657:	55                   	push   %ebp
80101658:	89 e5                	mov    %esp,%ebp
8010165a:	53                   	push   %ebx
8010165b:	83 ec 10             	sub    $0x10,%esp
8010165e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
80101661:	68 e0 0b 11 80       	push   $0x80110be0
80101666:	e8 b4 29 00 00       	call   8010401f <acquire>
  ip->ref++;
8010166b:	8b 43 08             	mov    0x8(%ebx),%eax
8010166e:	83 c0 01             	add    $0x1,%eax
80101671:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
80101674:	c7 04 24 e0 0b 11 80 	movl   $0x80110be0,(%esp)
8010167b:	e8 08 2a 00 00       	call   80104088 <release>
}
80101680:	89 d8                	mov    %ebx,%eax
80101682:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101685:	c9                   	leave  
80101686:	c3                   	ret    

80101687 <fsemaphore_lock>:
{
80101687:	f3 0f 1e fb          	endbr32 
8010168b:	55                   	push   %ebp
8010168c:	89 e5                	mov    %esp,%ebp
8010168e:	83 ec 08             	sub    $0x8,%esp
80101691:	8b 45 08             	mov    0x8(%ebp),%eax
  if(ip == 0 || ip->ref < 1)
80101694:	85 c0                	test   %eax,%eax
80101696:	74 17                	je     801016af <fsemaphore_lock+0x28>
80101698:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
8010169c:	7e 11                	jle    801016af <fsemaphore_lock+0x28>
  acquiresleep(&ip->flock);
8010169e:	83 ec 0c             	sub    $0xc,%esp
801016a1:	83 c0 0c             	add    $0xc,%eax
801016a4:	50                   	push   %eax
801016a5:	e8 41 27 00 00       	call   80103deb <acquiresleep>
}
801016aa:	83 c4 10             	add    $0x10,%esp
801016ad:	c9                   	leave  
801016ae:	c3                   	ret    
    panic("flock");
801016af:	83 ec 0c             	sub    $0xc,%esp
801016b2:	68 aa 71 10 80       	push   $0x801071aa
801016b7:	e8 a0 ec ff ff       	call   8010035c <panic>

801016bc <fsemaphore_unlock>:
{
801016bc:	f3 0f 1e fb          	endbr32 
801016c0:	55                   	push   %ebp
801016c1:	89 e5                	mov    %esp,%ebp
801016c3:	56                   	push   %esi
801016c4:	53                   	push   %ebx
801016c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->flock) || ip->ref < 1)
801016c8:	85 db                	test   %ebx,%ebx
801016ca:	74 2c                	je     801016f8 <fsemaphore_unlock+0x3c>
801016cc:	8d 73 0c             	lea    0xc(%ebx),%esi
801016cf:	83 ec 0c             	sub    $0xc,%esp
801016d2:	56                   	push   %esi
801016d3:	e8 a5 27 00 00       	call   80103e7d <holdingsleep>
801016d8:	83 c4 10             	add    $0x10,%esp
801016db:	85 c0                	test   %eax,%eax
801016dd:	74 19                	je     801016f8 <fsemaphore_unlock+0x3c>
801016df:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
801016e3:	7e 13                	jle    801016f8 <fsemaphore_unlock+0x3c>
  releasesleep(&ip->flock);
801016e5:	83 ec 0c             	sub    $0xc,%esp
801016e8:	56                   	push   %esi
801016e9:	e8 50 27 00 00       	call   80103e3e <releasesleep>
}
801016ee:	83 c4 10             	add    $0x10,%esp
801016f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801016f4:	5b                   	pop    %ebx
801016f5:	5e                   	pop    %esi
801016f6:	5d                   	pop    %ebp
801016f7:	c3                   	ret    
    panic("funlock");
801016f8:	83 ec 0c             	sub    $0xc,%esp
801016fb:	68 b0 71 10 80       	push   $0x801071b0
80101700:	e8 57 ec ff ff       	call   8010035c <panic>

80101705 <ilock>:
{
80101705:	f3 0f 1e fb          	endbr32 
80101709:	55                   	push   %ebp
8010170a:	89 e5                	mov    %esp,%ebp
8010170c:	56                   	push   %esi
8010170d:	53                   	push   %ebx
8010170e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101711:	85 db                	test   %ebx,%ebx
80101713:	74 25                	je     8010173a <ilock+0x35>
80101715:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101719:	7e 1f                	jle    8010173a <ilock+0x35>
  acquiresleep(&ip->lock);
8010171b:	83 ec 0c             	sub    $0xc,%esp
8010171e:	8d 43 4c             	lea    0x4c(%ebx),%eax
80101721:	50                   	push   %eax
80101722:	e8 c4 26 00 00       	call   80103deb <acquiresleep>
  if(ip->valid == 0){
80101727:	83 c4 10             	add    $0x10,%esp
8010172a:	83 bb 8c 00 00 00 00 	cmpl   $0x0,0x8c(%ebx)
80101731:	74 14                	je     80101747 <ilock+0x42>
}
80101733:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101736:	5b                   	pop    %ebx
80101737:	5e                   	pop    %esi
80101738:	5d                   	pop    %ebp
80101739:	c3                   	ret    
    panic("ilock");
8010173a:	83 ec 0c             	sub    $0xc,%esp
8010173d:	68 b8 71 10 80       	push   $0x801071b8
80101742:	e8 15 ec ff ff       	call   8010035c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101747:	8b 43 04             	mov    0x4(%ebx),%eax
8010174a:	c1 e8 03             	shr    $0x3,%eax
8010174d:	83 ec 08             	sub    $0x8,%esp
80101750:	03 05 d4 0b 11 80    	add    0x80110bd4,%eax
80101756:	50                   	push   %eax
80101757:	ff 33                	pushl  (%ebx)
80101759:	e8 12 ea ff ff       	call   80100170 <bread>
8010175e:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101760:	8b 43 04             	mov    0x4(%ebx),%eax
80101763:	83 e0 07             	and    $0x7,%eax
80101766:	c1 e0 06             	shl    $0x6,%eax
80101769:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
8010176d:	0f b7 10             	movzwl (%eax),%edx
80101770:	66 89 93 90 00 00 00 	mov    %dx,0x90(%ebx)
    ip->major = dip->major;
80101777:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010177b:	66 89 93 92 00 00 00 	mov    %dx,0x92(%ebx)
    ip->minor = dip->minor;
80101782:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101786:	66 89 93 94 00 00 00 	mov    %dx,0x94(%ebx)
    ip->nlink = dip->nlink;
8010178d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101791:	66 89 93 96 00 00 00 	mov    %dx,0x96(%ebx)
    ip->size = dip->size;
80101798:	8b 50 08             	mov    0x8(%eax),%edx
8010179b:	89 93 98 00 00 00    	mov    %edx,0x98(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801017a1:	83 c0 0c             	add    $0xc,%eax
801017a4:	8d 93 9c 00 00 00    	lea    0x9c(%ebx),%edx
801017aa:	83 c4 0c             	add    $0xc,%esp
801017ad:	6a 34                	push   $0x34
801017af:	50                   	push   %eax
801017b0:	52                   	push   %edx
801017b1:	e8 9d 29 00 00       	call   80104153 <memmove>
    brelse(bp);
801017b6:	89 34 24             	mov    %esi,(%esp)
801017b9:	e8 23 ea ff ff       	call   801001e1 <brelse>
    ip->valid = 1;
801017be:	c7 83 8c 00 00 00 01 	movl   $0x1,0x8c(%ebx)
801017c5:	00 00 00 
    if(ip->type == 0)
801017c8:	83 c4 10             	add    $0x10,%esp
801017cb:	66 83 bb 90 00 00 00 	cmpw   $0x0,0x90(%ebx)
801017d2:	00 
801017d3:	0f 85 5a ff ff ff    	jne    80101733 <ilock+0x2e>
      panic("ilock: no type");
801017d9:	83 ec 0c             	sub    $0xc,%esp
801017dc:	68 be 71 10 80       	push   $0x801071be
801017e1:	e8 76 eb ff ff       	call   8010035c <panic>

801017e6 <iunlock>:
{
801017e6:	f3 0f 1e fb          	endbr32 
801017ea:	55                   	push   %ebp
801017eb:	89 e5                	mov    %esp,%ebp
801017ed:	56                   	push   %esi
801017ee:	53                   	push   %ebx
801017ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801017f2:	85 db                	test   %ebx,%ebx
801017f4:	74 2c                	je     80101822 <iunlock+0x3c>
801017f6:	8d 73 4c             	lea    0x4c(%ebx),%esi
801017f9:	83 ec 0c             	sub    $0xc,%esp
801017fc:	56                   	push   %esi
801017fd:	e8 7b 26 00 00       	call   80103e7d <holdingsleep>
80101802:	83 c4 10             	add    $0x10,%esp
80101805:	85 c0                	test   %eax,%eax
80101807:	74 19                	je     80101822 <iunlock+0x3c>
80101809:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010180d:	7e 13                	jle    80101822 <iunlock+0x3c>
  releasesleep(&ip->lock);
8010180f:	83 ec 0c             	sub    $0xc,%esp
80101812:	56                   	push   %esi
80101813:	e8 26 26 00 00       	call   80103e3e <releasesleep>
}
80101818:	83 c4 10             	add    $0x10,%esp
8010181b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010181e:	5b                   	pop    %ebx
8010181f:	5e                   	pop    %esi
80101820:	5d                   	pop    %ebp
80101821:	c3                   	ret    
    panic("iunlock");
80101822:	83 ec 0c             	sub    $0xc,%esp
80101825:	68 cd 71 10 80       	push   $0x801071cd
8010182a:	e8 2d eb ff ff       	call   8010035c <panic>

8010182f <iput>:
{
8010182f:	f3 0f 1e fb          	endbr32 
80101833:	55                   	push   %ebp
80101834:	89 e5                	mov    %esp,%ebp
80101836:	57                   	push   %edi
80101837:	56                   	push   %esi
80101838:	53                   	push   %ebx
80101839:	83 ec 18             	sub    $0x18,%esp
8010183c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
8010183f:	8d 73 4c             	lea    0x4c(%ebx),%esi
80101842:	56                   	push   %esi
80101843:	e8 a3 25 00 00       	call   80103deb <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101848:	83 c4 10             	add    $0x10,%esp
8010184b:	83 bb 8c 00 00 00 00 	cmpl   $0x0,0x8c(%ebx)
80101852:	74 0a                	je     8010185e <iput+0x2f>
80101854:	66 83 bb 96 00 00 00 	cmpw   $0x0,0x96(%ebx)
8010185b:	00 
8010185c:	74 35                	je     80101893 <iput+0x64>
  releasesleep(&ip->lock);
8010185e:	83 ec 0c             	sub    $0xc,%esp
80101861:	56                   	push   %esi
80101862:	e8 d7 25 00 00       	call   80103e3e <releasesleep>
  acquire(&icache.lock);
80101867:	c7 04 24 e0 0b 11 80 	movl   $0x80110be0,(%esp)
8010186e:	e8 ac 27 00 00       	call   8010401f <acquire>
  ip->ref--;
80101873:	8b 43 08             	mov    0x8(%ebx),%eax
80101876:	83 e8 01             	sub    $0x1,%eax
80101879:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010187c:	c7 04 24 e0 0b 11 80 	movl   $0x80110be0,(%esp)
80101883:	e8 00 28 00 00       	call   80104088 <release>
}
80101888:	83 c4 10             	add    $0x10,%esp
8010188b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010188e:	5b                   	pop    %ebx
8010188f:	5e                   	pop    %esi
80101890:	5f                   	pop    %edi
80101891:	5d                   	pop    %ebp
80101892:	c3                   	ret    
    acquire(&icache.lock);
80101893:	83 ec 0c             	sub    $0xc,%esp
80101896:	68 e0 0b 11 80       	push   $0x80110be0
8010189b:	e8 7f 27 00 00       	call   8010401f <acquire>
    int r = ip->ref;
801018a0:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801018a3:	c7 04 24 e0 0b 11 80 	movl   $0x80110be0,(%esp)
801018aa:	e8 d9 27 00 00       	call   80104088 <release>
    if(r == 1){
801018af:	83 c4 10             	add    $0x10,%esp
801018b2:	83 ff 01             	cmp    $0x1,%edi
801018b5:	75 a7                	jne    8010185e <iput+0x2f>
      itrunc(ip);
801018b7:	89 d8                	mov    %ebx,%eax
801018b9:	e8 da fc ff ff       	call   80101598 <itrunc>
      ip->type = 0;
801018be:	66 c7 83 90 00 00 00 	movw   $0x0,0x90(%ebx)
801018c5:	00 00 
      iupdate(ip);
801018c7:	83 ec 0c             	sub    $0xc,%esp
801018ca:	53                   	push   %ebx
801018cb:	e8 33 fc ff ff       	call   80101503 <iupdate>
      ip->valid = 0;
801018d0:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
801018d7:	00 00 00 
801018da:	83 c4 10             	add    $0x10,%esp
801018dd:	e9 7c ff ff ff       	jmp    8010185e <iput+0x2f>

801018e2 <iunlockput>:
{
801018e2:	f3 0f 1e fb          	endbr32 
801018e6:	55                   	push   %ebp
801018e7:	89 e5                	mov    %esp,%ebp
801018e9:	53                   	push   %ebx
801018ea:	83 ec 10             	sub    $0x10,%esp
801018ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
801018f0:	53                   	push   %ebx
801018f1:	e8 f0 fe ff ff       	call   801017e6 <iunlock>
  iput(ip);
801018f6:	89 1c 24             	mov    %ebx,(%esp)
801018f9:	e8 31 ff ff ff       	call   8010182f <iput>
}
801018fe:	83 c4 10             	add    $0x10,%esp
80101901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101904:	c9                   	leave  
80101905:	c3                   	ret    

80101906 <stati>:
{
80101906:	f3 0f 1e fb          	endbr32 
8010190a:	55                   	push   %ebp
8010190b:	89 e5                	mov    %esp,%ebp
8010190d:	8b 55 08             	mov    0x8(%ebp),%edx
80101910:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101913:	8b 0a                	mov    (%edx),%ecx
80101915:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101918:	8b 4a 04             	mov    0x4(%edx),%ecx
8010191b:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
8010191e:	0f b7 8a 90 00 00 00 	movzwl 0x90(%edx),%ecx
80101925:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101928:	0f b7 8a 96 00 00 00 	movzwl 0x96(%edx),%ecx
8010192f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101933:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80101939:	89 50 10             	mov    %edx,0x10(%eax)
}
8010193c:	5d                   	pop    %ebp
8010193d:	c3                   	ret    

8010193e <readi>:
{
8010193e:	f3 0f 1e fb          	endbr32 
80101942:	55                   	push   %ebp
80101943:	89 e5                	mov    %esp,%ebp
80101945:	57                   	push   %edi
80101946:	56                   	push   %esi
80101947:	53                   	push   %ebx
80101948:	83 ec 1c             	sub    $0x1c,%esp
8010194b:	8b 75 10             	mov    0x10(%ebp),%esi
  if(ip->type == T_DEV){
8010194e:	8b 45 08             	mov    0x8(%ebp),%eax
80101951:	66 83 b8 90 00 00 00 	cmpw   $0x3,0x90(%eax)
80101958:	03 
80101959:	74 2f                	je     8010198a <readi+0x4c>
  if(off > ip->size || off + n < off)
8010195b:	8b 45 08             	mov    0x8(%ebp),%eax
8010195e:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80101964:	39 f0                	cmp    %esi,%eax
80101966:	0f 82 ce 00 00 00    	jb     80101a3a <readi+0xfc>
8010196c:	89 f2                	mov    %esi,%edx
8010196e:	03 55 14             	add    0x14(%ebp),%edx
80101971:	0f 82 ca 00 00 00    	jb     80101a41 <readi+0x103>
  if(off + n > ip->size)
80101977:	39 d0                	cmp    %edx,%eax
80101979:	73 05                	jae    80101980 <readi+0x42>
    n = ip->size - off;
8010197b:	29 f0                	sub    %esi,%eax
8010197d:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101980:	bf 00 00 00 00       	mov    $0x0,%edi
80101985:	e9 92 00 00 00       	jmp    80101a1c <readi+0xde>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010198a:	0f b7 80 92 00 00 00 	movzwl 0x92(%eax),%eax
80101991:	66 83 f8 09          	cmp    $0x9,%ax
80101995:	0f 87 91 00 00 00    	ja     80101a2c <readi+0xee>
8010199b:	98                   	cwtl   
8010199c:	8b 04 c5 60 0b 11 80 	mov    -0x7feef4a0(,%eax,8),%eax
801019a3:	85 c0                	test   %eax,%eax
801019a5:	0f 84 88 00 00 00    	je     80101a33 <readi+0xf5>
    return devsw[ip->major].read(ip, dst, n);
801019ab:	83 ec 04             	sub    $0x4,%esp
801019ae:	ff 75 14             	pushl  0x14(%ebp)
801019b1:	ff 75 0c             	pushl  0xc(%ebp)
801019b4:	ff 75 08             	pushl  0x8(%ebp)
801019b7:	ff d0                	call   *%eax
801019b9:	83 c4 10             	add    $0x10,%esp
801019bc:	eb 66                	jmp    80101a24 <readi+0xe6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801019be:	89 f2                	mov    %esi,%edx
801019c0:	c1 ea 09             	shr    $0x9,%edx
801019c3:	8b 45 08             	mov    0x8(%ebp),%eax
801019c6:	e8 64 f8 ff ff       	call   8010122f <bmap>
801019cb:	83 ec 08             	sub    $0x8,%esp
801019ce:	50                   	push   %eax
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	ff 30                	pushl  (%eax)
801019d4:	e8 97 e7 ff ff       	call   80100170 <bread>
801019d9:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
801019db:	89 f0                	mov    %esi,%eax
801019dd:	25 ff 01 00 00       	and    $0x1ff,%eax
801019e2:	bb 00 02 00 00       	mov    $0x200,%ebx
801019e7:	29 c3                	sub    %eax,%ebx
801019e9:	8b 55 14             	mov    0x14(%ebp),%edx
801019ec:	29 fa                	sub    %edi,%edx
801019ee:	83 c4 0c             	add    $0xc,%esp
801019f1:	39 d3                	cmp    %edx,%ebx
801019f3:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
801019f6:	53                   	push   %ebx
801019f7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
801019fa:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
801019fe:	50                   	push   %eax
801019ff:	ff 75 0c             	pushl  0xc(%ebp)
80101a02:	e8 4c 27 00 00       	call   80104153 <memmove>
    brelse(bp);
80101a07:	83 c4 04             	add    $0x4,%esp
80101a0a:	ff 75 e4             	pushl  -0x1c(%ebp)
80101a0d:	e8 cf e7 ff ff       	call   801001e1 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101a12:	01 df                	add    %ebx,%edi
80101a14:	01 de                	add    %ebx,%esi
80101a16:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101a19:	83 c4 10             	add    $0x10,%esp
80101a1c:	39 7d 14             	cmp    %edi,0x14(%ebp)
80101a1f:	77 9d                	ja     801019be <readi+0x80>
  return n;
80101a21:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101a24:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a27:	5b                   	pop    %ebx
80101a28:	5e                   	pop    %esi
80101a29:	5f                   	pop    %edi
80101a2a:	5d                   	pop    %ebp
80101a2b:	c3                   	ret    
      return -1;
80101a2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101a31:	eb f1                	jmp    80101a24 <readi+0xe6>
80101a33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101a38:	eb ea                	jmp    80101a24 <readi+0xe6>
    return -1;
80101a3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101a3f:	eb e3                	jmp    80101a24 <readi+0xe6>
80101a41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101a46:	eb dc                	jmp    80101a24 <readi+0xe6>

80101a48 <writei>:
{
80101a48:	f3 0f 1e fb          	endbr32 
80101a4c:	55                   	push   %ebp
80101a4d:	89 e5                	mov    %esp,%ebp
80101a4f:	57                   	push   %edi
80101a50:	56                   	push   %esi
80101a51:	53                   	push   %ebx
80101a52:	83 ec 1c             	sub    $0x1c,%esp
80101a55:	8b 75 10             	mov    0x10(%ebp),%esi
  if(ip->type == T_DEV){
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	66 83 b8 90 00 00 00 	cmpw   $0x3,0x90(%eax)
80101a62:	03 
80101a63:	0f 84 9e 00 00 00    	je     80101b07 <writei+0xbf>
  if(off > ip->size || off + n < off)
80101a69:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6c:	39 b0 98 00 00 00    	cmp    %esi,0x98(%eax)
80101a72:	0f 82 f9 00 00 00    	jb     80101b71 <writei+0x129>
80101a78:	89 f0                	mov    %esi,%eax
80101a7a:	03 45 14             	add    0x14(%ebp),%eax
80101a7d:	0f 82 f5 00 00 00    	jb     80101b78 <writei+0x130>
  if(off + n > MAXFILE*BSIZE)
80101a83:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101a88:	0f 87 f1 00 00 00    	ja     80101b7f <writei+0x137>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101a8e:	bf 00 00 00 00       	mov    $0x0,%edi
80101a93:	3b 7d 14             	cmp    0x14(%ebp),%edi
80101a96:	0f 83 97 00 00 00    	jae    80101b33 <writei+0xeb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101a9c:	89 f2                	mov    %esi,%edx
80101a9e:	c1 ea 09             	shr    $0x9,%edx
80101aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa4:	e8 86 f7 ff ff       	call   8010122f <bmap>
80101aa9:	83 ec 08             	sub    $0x8,%esp
80101aac:	50                   	push   %eax
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	ff 30                	pushl  (%eax)
80101ab2:	e8 b9 e6 ff ff       	call   80100170 <bread>
80101ab7:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
80101ab9:	89 f0                	mov    %esi,%eax
80101abb:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ac0:	bb 00 02 00 00       	mov    $0x200,%ebx
80101ac5:	29 c3                	sub    %eax,%ebx
80101ac7:	8b 55 14             	mov    0x14(%ebp),%edx
80101aca:	29 fa                	sub    %edi,%edx
80101acc:	83 c4 0c             	add    $0xc,%esp
80101acf:	39 d3                	cmp    %edx,%ebx
80101ad1:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101ad4:	53                   	push   %ebx
80101ad5:	ff 75 0c             	pushl  0xc(%ebp)
80101ad8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101adb:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101adf:	50                   	push   %eax
80101ae0:	e8 6e 26 00 00       	call   80104153 <memmove>
    log_write(bp);
80101ae5:	83 c4 04             	add    $0x4,%esp
80101ae8:	ff 75 e4             	pushl  -0x1c(%ebp)
80101aeb:	e8 58 10 00 00       	call   80102b48 <log_write>
    brelse(bp);
80101af0:	83 c4 04             	add    $0x4,%esp
80101af3:	ff 75 e4             	pushl  -0x1c(%ebp)
80101af6:	e8 e6 e6 ff ff       	call   801001e1 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101afb:	01 df                	add    %ebx,%edi
80101afd:	01 de                	add    %ebx,%esi
80101aff:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101b02:	83 c4 10             	add    $0x10,%esp
80101b05:	eb 8c                	jmp    80101a93 <writei+0x4b>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101b07:	0f b7 80 92 00 00 00 	movzwl 0x92(%eax),%eax
80101b0e:	66 83 f8 09          	cmp    $0x9,%ax
80101b12:	77 4f                	ja     80101b63 <writei+0x11b>
80101b14:	98                   	cwtl   
80101b15:	8b 04 c5 64 0b 11 80 	mov    -0x7feef49c(,%eax,8),%eax
80101b1c:	85 c0                	test   %eax,%eax
80101b1e:	74 4a                	je     80101b6a <writei+0x122>
    return devsw[ip->major].write(ip, src, n);
80101b20:	83 ec 04             	sub    $0x4,%esp
80101b23:	ff 75 14             	pushl  0x14(%ebp)
80101b26:	ff 75 0c             	pushl  0xc(%ebp)
80101b29:	ff 75 08             	pushl  0x8(%ebp)
80101b2c:	ff d0                	call   *%eax
80101b2e:	83 c4 10             	add    $0x10,%esp
80101b31:	eb 14                	jmp    80101b47 <writei+0xff>
  if(n > 0 && off > ip->size){
80101b33:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80101b37:	74 0b                	je     80101b44 <writei+0xfc>
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	39 b0 98 00 00 00    	cmp    %esi,0x98(%eax)
80101b42:	72 0b                	jb     80101b4f <writei+0x107>
  return n;
80101b44:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101b47:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b4a:	5b                   	pop    %ebx
80101b4b:	5e                   	pop    %esi
80101b4c:	5f                   	pop    %edi
80101b4d:	5d                   	pop    %ebp
80101b4e:	c3                   	ret    
    ip->size = off;
80101b4f:	89 b0 98 00 00 00    	mov    %esi,0x98(%eax)
    iupdate(ip);
80101b55:	83 ec 0c             	sub    $0xc,%esp
80101b58:	50                   	push   %eax
80101b59:	e8 a5 f9 ff ff       	call   80101503 <iupdate>
80101b5e:	83 c4 10             	add    $0x10,%esp
80101b61:	eb e1                	jmp    80101b44 <writei+0xfc>
      return -1;
80101b63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b68:	eb dd                	jmp    80101b47 <writei+0xff>
80101b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b6f:	eb d6                	jmp    80101b47 <writei+0xff>
    return -1;
80101b71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b76:	eb cf                	jmp    80101b47 <writei+0xff>
80101b78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b7d:	eb c8                	jmp    80101b47 <writei+0xff>
    return -1;
80101b7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b84:	eb c1                	jmp    80101b47 <writei+0xff>

80101b86 <namecmp>:
{
80101b86:	f3 0f 1e fb          	endbr32 
80101b8a:	55                   	push   %ebp
80101b8b:	89 e5                	mov    %esp,%ebp
80101b8d:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101b90:	6a 0e                	push   $0xe
80101b92:	ff 75 0c             	pushl  0xc(%ebp)
80101b95:	ff 75 08             	pushl  0x8(%ebp)
80101b98:	e8 28 26 00 00       	call   801041c5 <strncmp>
}
80101b9d:	c9                   	leave  
80101b9e:	c3                   	ret    

80101b9f <dirlookup>:
{
80101b9f:	f3 0f 1e fb          	endbr32 
80101ba3:	55                   	push   %ebp
80101ba4:	89 e5                	mov    %esp,%ebp
80101ba6:	57                   	push   %edi
80101ba7:	56                   	push   %esi
80101ba8:	53                   	push   %ebx
80101ba9:	83 ec 1c             	sub    $0x1c,%esp
80101bac:	8b 75 08             	mov    0x8(%ebp),%esi
80101baf:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
80101bb2:	66 83 be 90 00 00 00 	cmpw   $0x1,0x90(%esi)
80101bb9:	01 
80101bba:	75 07                	jne    80101bc3 <dirlookup+0x24>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101bbc:	bb 00 00 00 00       	mov    $0x0,%ebx
80101bc1:	eb 1d                	jmp    80101be0 <dirlookup+0x41>
    panic("dirlookup not DIR");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 d5 71 10 80       	push   $0x801071d5
80101bcb:	e8 8c e7 ff ff       	call   8010035c <panic>
      panic("dirlookup read");
80101bd0:	83 ec 0c             	sub    $0xc,%esp
80101bd3:	68 e7 71 10 80       	push   $0x801071e7
80101bd8:	e8 7f e7 ff ff       	call   8010035c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101bdd:	83 c3 10             	add    $0x10,%ebx
80101be0:	39 9e 98 00 00 00    	cmp    %ebx,0x98(%esi)
80101be6:	76 48                	jbe    80101c30 <dirlookup+0x91>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101be8:	6a 10                	push   $0x10
80101bea:	53                   	push   %ebx
80101beb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101bee:	50                   	push   %eax
80101bef:	56                   	push   %esi
80101bf0:	e8 49 fd ff ff       	call   8010193e <readi>
80101bf5:	83 c4 10             	add    $0x10,%esp
80101bf8:	83 f8 10             	cmp    $0x10,%eax
80101bfb:	75 d3                	jne    80101bd0 <dirlookup+0x31>
    if(de.inum == 0)
80101bfd:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101c02:	74 d9                	je     80101bdd <dirlookup+0x3e>
    if(namecmp(name, de.name) == 0){
80101c04:	83 ec 08             	sub    $0x8,%esp
80101c07:	8d 45 da             	lea    -0x26(%ebp),%eax
80101c0a:	50                   	push   %eax
80101c0b:	57                   	push   %edi
80101c0c:	e8 75 ff ff ff       	call   80101b86 <namecmp>
80101c11:	83 c4 10             	add    $0x10,%esp
80101c14:	85 c0                	test   %eax,%eax
80101c16:	75 c5                	jne    80101bdd <dirlookup+0x3e>
      if(poff)
80101c18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101c1c:	74 05                	je     80101c23 <dirlookup+0x84>
        *poff = off;
80101c1e:	8b 45 10             	mov    0x10(%ebp),%eax
80101c21:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101c23:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101c27:	8b 06                	mov    (%esi),%eax
80101c29:	e8 b1 f6 ff ff       	call   801012df <iget>
80101c2e:	eb 05                	jmp    80101c35 <dirlookup+0x96>
  return 0;
80101c30:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c38:	5b                   	pop    %ebx
80101c39:	5e                   	pop    %esi
80101c3a:	5f                   	pop    %edi
80101c3b:	5d                   	pop    %ebp
80101c3c:	c3                   	ret    

80101c3d <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101c3d:	55                   	push   %ebp
80101c3e:	89 e5                	mov    %esp,%ebp
80101c40:	57                   	push   %edi
80101c41:	56                   	push   %esi
80101c42:	53                   	push   %ebx
80101c43:	83 ec 1c             	sub    $0x1c,%esp
80101c46:	89 c3                	mov    %eax,%ebx
80101c48:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101c4b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101c4e:	80 38 2f             	cmpb   $0x2f,(%eax)
80101c51:	74 17                	je     80101c6a <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101c53:	e8 4a 19 00 00       	call   801035a2 <myproc>
80101c58:	83 ec 0c             	sub    $0xc,%esp
80101c5b:	ff 70 68             	pushl  0x68(%eax)
80101c5e:	e8 f0 f9 ff ff       	call   80101653 <idup>
80101c63:	89 c6                	mov    %eax,%esi
80101c65:	83 c4 10             	add    $0x10,%esp
80101c68:	eb 53                	jmp    80101cbd <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101c6a:	ba 01 00 00 00       	mov    $0x1,%edx
80101c6f:	b8 01 00 00 00       	mov    $0x1,%eax
80101c74:	e8 66 f6 ff ff       	call   801012df <iget>
80101c79:	89 c6                	mov    %eax,%esi
80101c7b:	eb 40                	jmp    80101cbd <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101c7d:	83 ec 0c             	sub    $0xc,%esp
80101c80:	56                   	push   %esi
80101c81:	e8 5c fc ff ff       	call   801018e2 <iunlockput>
      return 0;
80101c86:	83 c4 10             	add    $0x10,%esp
80101c89:	be 00 00 00 00       	mov    $0x0,%esi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101c8e:	89 f0                	mov    %esi,%eax
80101c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c93:	5b                   	pop    %ebx
80101c94:	5e                   	pop    %esi
80101c95:	5f                   	pop    %edi
80101c96:	5d                   	pop    %ebp
80101c97:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101c98:	83 ec 04             	sub    $0x4,%esp
80101c9b:	6a 00                	push   $0x0
80101c9d:	ff 75 e4             	pushl  -0x1c(%ebp)
80101ca0:	56                   	push   %esi
80101ca1:	e8 f9 fe ff ff       	call   80101b9f <dirlookup>
80101ca6:	89 c7                	mov    %eax,%edi
80101ca8:	83 c4 10             	add    $0x10,%esp
80101cab:	85 c0                	test   %eax,%eax
80101cad:	74 4d                	je     80101cfc <namex+0xbf>
    iunlockput(ip);
80101caf:	83 ec 0c             	sub    $0xc,%esp
80101cb2:	56                   	push   %esi
80101cb3:	e8 2a fc ff ff       	call   801018e2 <iunlockput>
80101cb8:	83 c4 10             	add    $0x10,%esp
    ip = next;
80101cbb:	89 fe                	mov    %edi,%esi
  while((path = skipelem(path, name)) != 0){
80101cbd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101cc0:	89 d8                	mov    %ebx,%eax
80101cc2:	e8 54 f3 ff ff       	call   8010101b <skipelem>
80101cc7:	89 c3                	mov    %eax,%ebx
80101cc9:	85 c0                	test   %eax,%eax
80101ccb:	74 3f                	je     80101d0c <namex+0xcf>
    ilock(ip);
80101ccd:	83 ec 0c             	sub    $0xc,%esp
80101cd0:	56                   	push   %esi
80101cd1:	e8 2f fa ff ff       	call   80101705 <ilock>
    if(ip->type != T_DIR){
80101cd6:	83 c4 10             	add    $0x10,%esp
80101cd9:	66 83 be 90 00 00 00 	cmpw   $0x1,0x90(%esi)
80101ce0:	01 
80101ce1:	75 9a                	jne    80101c7d <namex+0x40>
    if(nameiparent && *path == '\0'){
80101ce3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101ce7:	74 af                	je     80101c98 <namex+0x5b>
80101ce9:	80 3b 00             	cmpb   $0x0,(%ebx)
80101cec:	75 aa                	jne    80101c98 <namex+0x5b>
      iunlock(ip);
80101cee:	83 ec 0c             	sub    $0xc,%esp
80101cf1:	56                   	push   %esi
80101cf2:	e8 ef fa ff ff       	call   801017e6 <iunlock>
      return ip;
80101cf7:	83 c4 10             	add    $0x10,%esp
80101cfa:	eb 92                	jmp    80101c8e <namex+0x51>
      iunlockput(ip);
80101cfc:	83 ec 0c             	sub    $0xc,%esp
80101cff:	56                   	push   %esi
80101d00:	e8 dd fb ff ff       	call   801018e2 <iunlockput>
      return 0;
80101d05:	83 c4 10             	add    $0x10,%esp
80101d08:	89 fe                	mov    %edi,%esi
80101d0a:	eb 82                	jmp    80101c8e <namex+0x51>
  if(nameiparent){
80101d0c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101d10:	0f 84 78 ff ff ff    	je     80101c8e <namex+0x51>
    iput(ip);
80101d16:	83 ec 0c             	sub    $0xc,%esp
80101d19:	56                   	push   %esi
80101d1a:	e8 10 fb ff ff       	call   8010182f <iput>
    return 0;
80101d1f:	83 c4 10             	add    $0x10,%esp
80101d22:	89 de                	mov    %ebx,%esi
80101d24:	e9 65 ff ff ff       	jmp    80101c8e <namex+0x51>

80101d29 <dirlink>:
{
80101d29:	f3 0f 1e fb          	endbr32 
80101d2d:	55                   	push   %ebp
80101d2e:	89 e5                	mov    %esp,%ebp
80101d30:	57                   	push   %edi
80101d31:	56                   	push   %esi
80101d32:	53                   	push   %ebx
80101d33:	83 ec 20             	sub    $0x20,%esp
80101d36:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101d39:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101d3c:	6a 00                	push   $0x0
80101d3e:	57                   	push   %edi
80101d3f:	53                   	push   %ebx
80101d40:	e8 5a fe ff ff       	call   80101b9f <dirlookup>
80101d45:	83 c4 10             	add    $0x10,%esp
80101d48:	85 c0                	test   %eax,%eax
80101d4a:	75 07                	jne    80101d53 <dirlink+0x2a>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101d4c:	b8 00 00 00 00       	mov    $0x0,%eax
80101d51:	eb 23                	jmp    80101d76 <dirlink+0x4d>
    iput(ip);
80101d53:	83 ec 0c             	sub    $0xc,%esp
80101d56:	50                   	push   %eax
80101d57:	e8 d3 fa ff ff       	call   8010182f <iput>
    return -1;
80101d5c:	83 c4 10             	add    $0x10,%esp
80101d5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101d64:	eb 66                	jmp    80101dcc <dirlink+0xa3>
      panic("dirlink read");
80101d66:	83 ec 0c             	sub    $0xc,%esp
80101d69:	68 f6 71 10 80       	push   $0x801071f6
80101d6e:	e8 e9 e5 ff ff       	call   8010035c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101d73:	8d 46 10             	lea    0x10(%esi),%eax
80101d76:	89 c6                	mov    %eax,%esi
80101d78:	39 83 98 00 00 00    	cmp    %eax,0x98(%ebx)
80101d7e:	76 1c                	jbe    80101d9c <dirlink+0x73>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101d80:	6a 10                	push   $0x10
80101d82:	50                   	push   %eax
80101d83:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101d86:	50                   	push   %eax
80101d87:	53                   	push   %ebx
80101d88:	e8 b1 fb ff ff       	call   8010193e <readi>
80101d8d:	83 c4 10             	add    $0x10,%esp
80101d90:	83 f8 10             	cmp    $0x10,%eax
80101d93:	75 d1                	jne    80101d66 <dirlink+0x3d>
    if(de.inum == 0)
80101d95:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101d9a:	75 d7                	jne    80101d73 <dirlink+0x4a>
  strncpy(de.name, name, DIRSIZ);
80101d9c:	83 ec 04             	sub    $0x4,%esp
80101d9f:	6a 0e                	push   $0xe
80101da1:	57                   	push   %edi
80101da2:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101da5:	8d 45 da             	lea    -0x26(%ebp),%eax
80101da8:	50                   	push   %eax
80101da9:	e8 58 24 00 00       	call   80104206 <strncpy>
  de.inum = inum;
80101dae:	8b 45 10             	mov    0x10(%ebp),%eax
80101db1:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101db5:	6a 10                	push   $0x10
80101db7:	56                   	push   %esi
80101db8:	57                   	push   %edi
80101db9:	53                   	push   %ebx
80101dba:	e8 89 fc ff ff       	call   80101a48 <writei>
80101dbf:	83 c4 20             	add    $0x20,%esp
80101dc2:	83 f8 10             	cmp    $0x10,%eax
80101dc5:	75 0d                	jne    80101dd4 <dirlink+0xab>
  return 0;
80101dc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101dcf:	5b                   	pop    %ebx
80101dd0:	5e                   	pop    %esi
80101dd1:	5f                   	pop    %edi
80101dd2:	5d                   	pop    %ebp
80101dd3:	c3                   	ret    
    panic("dirlink");
80101dd4:	83 ec 0c             	sub    $0xc,%esp
80101dd7:	68 a8 78 10 80       	push   $0x801078a8
80101ddc:	e8 7b e5 ff ff       	call   8010035c <panic>

80101de1 <namei>:

struct inode*
namei(char *path)
{
80101de1:	f3 0f 1e fb          	endbr32 
80101de5:	55                   	push   %ebp
80101de6:	89 e5                	mov    %esp,%ebp
80101de8:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101deb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101dee:	ba 00 00 00 00       	mov    $0x0,%edx
80101df3:	8b 45 08             	mov    0x8(%ebp),%eax
80101df6:	e8 42 fe ff ff       	call   80101c3d <namex>
}
80101dfb:	c9                   	leave  
80101dfc:	c3                   	ret    

80101dfd <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101dfd:	f3 0f 1e fb          	endbr32 
80101e01:	55                   	push   %ebp
80101e02:	89 e5                	mov    %esp,%ebp
80101e04:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101e07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101e0a:	ba 01 00 00 00       	mov    $0x1,%edx
80101e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e12:	e8 26 fe ff ff       	call   80101c3d <namex>
}
80101e17:	c9                   	leave  
80101e18:	c3                   	ret    

80101e19 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101e19:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101e1b:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101e20:	ec                   	in     (%dx),%al
80101e21:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101e23:	83 e0 c0             	and    $0xffffffc0,%eax
80101e26:	3c 40                	cmp    $0x40,%al
80101e28:	75 f1                	jne    80101e1b <idewait+0x2>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101e2a:	85 c9                	test   %ecx,%ecx
80101e2c:	74 0a                	je     80101e38 <idewait+0x1f>
80101e2e:	f6 c2 21             	test   $0x21,%dl
80101e31:	75 08                	jne    80101e3b <idewait+0x22>
    return -1;
  return 0;
80101e33:	b9 00 00 00 00       	mov    $0x0,%ecx
}
80101e38:	89 c8                	mov    %ecx,%eax
80101e3a:	c3                   	ret    
    return -1;
80101e3b:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
80101e40:	eb f6                	jmp    80101e38 <idewait+0x1f>

80101e42 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101e42:	55                   	push   %ebp
80101e43:	89 e5                	mov    %esp,%ebp
80101e45:	56                   	push   %esi
80101e46:	53                   	push   %ebx
  if(b == 0)
80101e47:	85 c0                	test   %eax,%eax
80101e49:	0f 84 91 00 00 00    	je     80101ee0 <idestart+0x9e>
80101e4f:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101e51:	8b 58 08             	mov    0x8(%eax),%ebx
80101e54:	81 fb cf 07 00 00    	cmp    $0x7cf,%ebx
80101e5a:	0f 87 8d 00 00 00    	ja     80101eed <idestart+0xab>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101e60:	b8 00 00 00 00       	mov    $0x0,%eax
80101e65:	e8 af ff ff ff       	call   80101e19 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101e6a:	b8 00 00 00 00       	mov    $0x0,%eax
80101e6f:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101e74:	ee                   	out    %al,(%dx)
80101e75:	b8 01 00 00 00       	mov    $0x1,%eax
80101e7a:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101e7f:	ee                   	out    %al,(%dx)
80101e80:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101e85:	89 d8                	mov    %ebx,%eax
80101e87:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101e88:	89 d8                	mov    %ebx,%eax
80101e8a:	c1 f8 08             	sar    $0x8,%eax
80101e8d:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101e92:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101e93:	89 d8                	mov    %ebx,%eax
80101e95:	c1 f8 10             	sar    $0x10,%eax
80101e98:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101e9d:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101e9e:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101ea2:	c1 e0 04             	shl    $0x4,%eax
80101ea5:	83 e0 10             	and    $0x10,%eax
80101ea8:	c1 fb 18             	sar    $0x18,%ebx
80101eab:	83 e3 0f             	and    $0xf,%ebx
80101eae:	09 d8                	or     %ebx,%eax
80101eb0:	83 c8 e0             	or     $0xffffffe0,%eax
80101eb3:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101eb8:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101eb9:	f6 06 04             	testb  $0x4,(%esi)
80101ebc:	74 3c                	je     80101efa <idestart+0xb8>
80101ebe:	b8 30 00 00 00       	mov    $0x30,%eax
80101ec3:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ec8:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101ec9:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101ecc:	b9 80 00 00 00       	mov    $0x80,%ecx
80101ed1:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101ed6:	fc                   	cld    
80101ed7:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101ed9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101edc:	5b                   	pop    %ebx
80101edd:	5e                   	pop    %esi
80101ede:	5d                   	pop    %ebp
80101edf:	c3                   	ret    
    panic("idestart");
80101ee0:	83 ec 0c             	sub    $0xc,%esp
80101ee3:	68 57 72 10 80       	push   $0x80107257
80101ee8:	e8 6f e4 ff ff       	call   8010035c <panic>
    panic("incorrect blockno");
80101eed:	83 ec 0c             	sub    $0xc,%esp
80101ef0:	68 60 72 10 80       	push   $0x80107260
80101ef5:	e8 62 e4 ff ff       	call   8010035c <panic>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101efa:	b8 20 00 00 00       	mov    $0x20,%eax
80101eff:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101f04:	ee                   	out    %al,(%dx)
}
80101f05:	eb d2                	jmp    80101ed9 <idestart+0x97>

80101f07 <ideinit>:
{
80101f07:	f3 0f 1e fb          	endbr32 
80101f0b:	55                   	push   %ebp
80101f0c:	89 e5                	mov    %esp,%ebp
80101f0e:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101f11:	68 72 72 10 80       	push   $0x80107272
80101f16:	68 80 a5 10 80       	push   $0x8010a580
80101f1b:	e8 af 1f 00 00       	call   80103ecf <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101f20:	83 c4 08             	add    $0x8,%esp
80101f23:	a1 80 3b 11 80       	mov    0x80113b80,%eax
80101f28:	83 e8 01             	sub    $0x1,%eax
80101f2b:	50                   	push   %eax
80101f2c:	6a 0e                	push   $0xe
80101f2e:	e8 5a 02 00 00       	call   8010218d <ioapicenable>
  idewait(0);
80101f33:	b8 00 00 00 00       	mov    $0x0,%eax
80101f38:	e8 dc fe ff ff       	call   80101e19 <idewait>
80101f3d:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101f42:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101f47:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101f48:	83 c4 10             	add    $0x10,%esp
80101f4b:	b9 00 00 00 00       	mov    $0x0,%ecx
80101f50:	eb 03                	jmp    80101f55 <ideinit+0x4e>
80101f52:	83 c1 01             	add    $0x1,%ecx
80101f55:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101f5b:	7f 14                	jg     80101f71 <ideinit+0x6a>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101f5d:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101f62:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101f63:	84 c0                	test   %al,%al
80101f65:	74 eb                	je     80101f52 <ideinit+0x4b>
      havedisk1 = 1;
80101f67:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101f6e:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101f71:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101f76:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101f7b:	ee                   	out    %al,(%dx)
}
80101f7c:	c9                   	leave  
80101f7d:	c3                   	ret    

80101f7e <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101f7e:	f3 0f 1e fb          	endbr32 
80101f82:	55                   	push   %ebp
80101f83:	89 e5                	mov    %esp,%ebp
80101f85:	57                   	push   %edi
80101f86:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101f87:	83 ec 0c             	sub    $0xc,%esp
80101f8a:	68 80 a5 10 80       	push   $0x8010a580
80101f8f:	e8 8b 20 00 00       	call   8010401f <acquire>

  if((b = idequeue) == 0){
80101f94:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101f9a:	83 c4 10             	add    $0x10,%esp
80101f9d:	85 db                	test   %ebx,%ebx
80101f9f:	74 48                	je     80101fe9 <ideintr+0x6b>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101fa1:	8b 43 58             	mov    0x58(%ebx),%eax
80101fa4:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101fa9:	f6 03 04             	testb  $0x4,(%ebx)
80101fac:	74 4d                	je     80101ffb <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101fae:	8b 03                	mov    (%ebx),%eax
80101fb0:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101fb3:	83 e0 fb             	and    $0xfffffffb,%eax
80101fb6:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101fb8:	83 ec 0c             	sub    $0xc,%esp
80101fbb:	53                   	push   %ebx
80101fbc:	e8 5e 1c 00 00       	call   80103c1f <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101fc1:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101fc6:	83 c4 10             	add    $0x10,%esp
80101fc9:	85 c0                	test   %eax,%eax
80101fcb:	74 05                	je     80101fd2 <ideintr+0x54>
    idestart(idequeue);
80101fcd:	e8 70 fe ff ff       	call   80101e42 <idestart>

  release(&idelock);
80101fd2:	83 ec 0c             	sub    $0xc,%esp
80101fd5:	68 80 a5 10 80       	push   $0x8010a580
80101fda:	e8 a9 20 00 00       	call   80104088 <release>
80101fdf:	83 c4 10             	add    $0x10,%esp
}
80101fe2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101fe5:	5b                   	pop    %ebx
80101fe6:	5f                   	pop    %edi
80101fe7:	5d                   	pop    %ebp
80101fe8:	c3                   	ret    
    release(&idelock);
80101fe9:	83 ec 0c             	sub    $0xc,%esp
80101fec:	68 80 a5 10 80       	push   $0x8010a580
80101ff1:	e8 92 20 00 00       	call   80104088 <release>
    return;
80101ff6:	83 c4 10             	add    $0x10,%esp
80101ff9:	eb e7                	jmp    80101fe2 <ideintr+0x64>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101ffb:	b8 01 00 00 00       	mov    $0x1,%eax
80102000:	e8 14 fe ff ff       	call   80101e19 <idewait>
80102005:	85 c0                	test   %eax,%eax
80102007:	78 a5                	js     80101fae <ideintr+0x30>
    insl(0x1f0, b->data, BSIZE/4);
80102009:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
8010200c:	b9 80 00 00 00       	mov    $0x80,%ecx
80102011:	ba f0 01 00 00       	mov    $0x1f0,%edx
80102016:	fc                   	cld    
80102017:	f3 6d                	rep insl (%dx),%es:(%edi)
}
80102019:	eb 93                	jmp    80101fae <ideintr+0x30>

8010201b <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010201b:	f3 0f 1e fb          	endbr32 
8010201f:	55                   	push   %ebp
80102020:	89 e5                	mov    %esp,%ebp
80102022:	53                   	push   %ebx
80102023:	83 ec 10             	sub    $0x10,%esp
80102026:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102029:	8d 43 0c             	lea    0xc(%ebx),%eax
8010202c:	50                   	push   %eax
8010202d:	e8 4b 1e 00 00       	call   80103e7d <holdingsleep>
80102032:	83 c4 10             	add    $0x10,%esp
80102035:	85 c0                	test   %eax,%eax
80102037:	74 37                	je     80102070 <iderw+0x55>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102039:	8b 03                	mov    (%ebx),%eax
8010203b:	83 e0 06             	and    $0x6,%eax
8010203e:	83 f8 02             	cmp    $0x2,%eax
80102041:	74 3a                	je     8010207d <iderw+0x62>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80102043:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80102047:	74 09                	je     80102052 <iderw+0x37>
80102049:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80102050:	74 38                	je     8010208a <iderw+0x6f>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102052:	83 ec 0c             	sub    $0xc,%esp
80102055:	68 80 a5 10 80       	push   $0x8010a580
8010205a:	e8 c0 1f 00 00       	call   8010401f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
8010205f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102066:	83 c4 10             	add    $0x10,%esp
80102069:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
8010206e:	eb 2a                	jmp    8010209a <iderw+0x7f>
    panic("iderw: buf not locked");
80102070:	83 ec 0c             	sub    $0xc,%esp
80102073:	68 76 72 10 80       	push   $0x80107276
80102078:	e8 df e2 ff ff       	call   8010035c <panic>
    panic("iderw: nothing to do");
8010207d:	83 ec 0c             	sub    $0xc,%esp
80102080:	68 8c 72 10 80       	push   $0x8010728c
80102085:	e8 d2 e2 ff ff       	call   8010035c <panic>
    panic("iderw: ide disk 1 not present");
8010208a:	83 ec 0c             	sub    $0xc,%esp
8010208d:	68 a1 72 10 80       	push   $0x801072a1
80102092:	e8 c5 e2 ff ff       	call   8010035c <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102097:	8d 50 58             	lea    0x58(%eax),%edx
8010209a:	8b 02                	mov    (%edx),%eax
8010209c:	85 c0                	test   %eax,%eax
8010209e:	75 f7                	jne    80102097 <iderw+0x7c>
    ;
  *pp = b;
801020a0:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
801020a2:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
801020a8:	75 1a                	jne    801020c4 <iderw+0xa9>
    idestart(b);
801020aa:	89 d8                	mov    %ebx,%eax
801020ac:	e8 91 fd ff ff       	call   80101e42 <idestart>
801020b1:	eb 11                	jmp    801020c4 <iderw+0xa9>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
801020b3:	83 ec 08             	sub    $0x8,%esp
801020b6:	68 80 a5 10 80       	push   $0x8010a580
801020bb:	53                   	push   %ebx
801020bc:	e8 ee 19 00 00       	call   80103aaf <sleep>
801020c1:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801020c4:	8b 03                	mov    (%ebx),%eax
801020c6:	83 e0 06             	and    $0x6,%eax
801020c9:	83 f8 02             	cmp    $0x2,%eax
801020cc:	75 e5                	jne    801020b3 <iderw+0x98>
  }


  release(&idelock);
801020ce:	83 ec 0c             	sub    $0xc,%esp
801020d1:	68 80 a5 10 80       	push   $0x8010a580
801020d6:	e8 ad 1f 00 00       	call   80104088 <release>
}
801020db:	83 c4 10             	add    $0x10,%esp
801020de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020e1:	c9                   	leave  
801020e2:	c3                   	ret    

801020e3 <ioapicread>:
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
801020e3:	8b 15 b4 34 11 80    	mov    0x801134b4,%edx
801020e9:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
801020eb:	a1 b4 34 11 80       	mov    0x801134b4,%eax
801020f0:	8b 40 10             	mov    0x10(%eax),%eax
}
801020f3:	c3                   	ret    

801020f4 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
801020f4:	8b 0d b4 34 11 80    	mov    0x801134b4,%ecx
801020fa:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801020fc:	a1 b4 34 11 80       	mov    0x801134b4,%eax
80102101:	89 50 10             	mov    %edx,0x10(%eax)
}
80102104:	c3                   	ret    

80102105 <ioapicinit>:

void
ioapicinit(void)
{
80102105:	f3 0f 1e fb          	endbr32 
80102109:	55                   	push   %ebp
8010210a:	89 e5                	mov    %esp,%ebp
8010210c:	57                   	push   %edi
8010210d:	56                   	push   %esi
8010210e:	53                   	push   %ebx
8010210f:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102112:	c7 05 b4 34 11 80 00 	movl   $0xfec00000,0x801134b4
80102119:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010211c:	b8 01 00 00 00       	mov    $0x1,%eax
80102121:	e8 bd ff ff ff       	call   801020e3 <ioapicread>
80102126:	c1 e8 10             	shr    $0x10,%eax
80102129:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
8010212c:	b8 00 00 00 00       	mov    $0x0,%eax
80102131:	e8 ad ff ff ff       	call   801020e3 <ioapicread>
80102136:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102139:	0f b6 15 e0 35 11 80 	movzbl 0x801135e0,%edx
80102140:	39 c2                	cmp    %eax,%edx
80102142:	75 2f                	jne    80102173 <ioapicinit+0x6e>
{
80102144:	bb 00 00 00 00       	mov    $0x0,%ebx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102149:	39 fb                	cmp    %edi,%ebx
8010214b:	7f 38                	jg     80102185 <ioapicinit+0x80>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010214d:	8d 53 20             	lea    0x20(%ebx),%edx
80102150:	81 ca 00 00 01 00    	or     $0x10000,%edx
80102156:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
8010215a:	89 f0                	mov    %esi,%eax
8010215c:	e8 93 ff ff ff       	call   801020f4 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102161:	8d 46 01             	lea    0x1(%esi),%eax
80102164:	ba 00 00 00 00       	mov    $0x0,%edx
80102169:	e8 86 ff ff ff       	call   801020f4 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
8010216e:	83 c3 01             	add    $0x1,%ebx
80102171:	eb d6                	jmp    80102149 <ioapicinit+0x44>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102173:	83 ec 0c             	sub    $0xc,%esp
80102176:	68 c0 72 10 80       	push   $0x801072c0
8010217b:	e8 a9 e4 ff ff       	call   80100629 <cprintf>
80102180:	83 c4 10             	add    $0x10,%esp
80102183:	eb bf                	jmp    80102144 <ioapicinit+0x3f>
  }
}
80102185:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102188:	5b                   	pop    %ebx
80102189:	5e                   	pop    %esi
8010218a:	5f                   	pop    %edi
8010218b:	5d                   	pop    %ebp
8010218c:	c3                   	ret    

8010218d <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010218d:	f3 0f 1e fb          	endbr32 
80102191:	55                   	push   %ebp
80102192:	89 e5                	mov    %esp,%ebp
80102194:	53                   	push   %ebx
80102195:	83 ec 04             	sub    $0x4,%esp
80102198:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010219b:	8d 50 20             	lea    0x20(%eax),%edx
8010219e:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
801021a2:	89 d8                	mov    %ebx,%eax
801021a4:	e8 4b ff ff ff       	call   801020f4 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801021a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801021ac:	c1 e2 18             	shl    $0x18,%edx
801021af:	8d 43 01             	lea    0x1(%ebx),%eax
801021b2:	e8 3d ff ff ff       	call   801020f4 <ioapicwrite>
}
801021b7:	83 c4 04             	add    $0x4,%esp
801021ba:	5b                   	pop    %ebx
801021bb:	5d                   	pop    %ebp
801021bc:	c3                   	ret    

801021bd <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801021bd:	f3 0f 1e fb          	endbr32 
801021c1:	55                   	push   %ebp
801021c2:	89 e5                	mov    %esp,%ebp
801021c4:	53                   	push   %ebx
801021c5:	83 ec 04             	sub    $0x4,%esp
801021c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801021cb:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
801021d1:	75 61                	jne    80102234 <kfree+0x77>
801021d3:	81 fb 28 66 11 80    	cmp    $0x80116628,%ebx
801021d9:	72 59                	jb     80102234 <kfree+0x77>

// Convert kernel virtual address to physical address
static inline uint V2P(void *a) {
    // define panic() here because memlayout.h is included before defs.h
    extern void panic(char*) __attribute__((noreturn));
    if (a < (void*) KERNBASE)
801021db:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
801021e1:	76 44                	jbe    80102227 <kfree+0x6a>
        panic("V2P on address < KERNBASE "
              "(not a kernel virtual address; consider walking page "
              "table to determine physical address of a user virtual address)");
    return (uint)a - KERNBASE;
801021e3:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801021e9:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801021ee:	77 44                	ja     80102234 <kfree+0x77>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801021f0:	83 ec 04             	sub    $0x4,%esp
801021f3:	68 00 10 00 00       	push   $0x1000
801021f8:	6a 01                	push   $0x1
801021fa:	53                   	push   %ebx
801021fb:	e8 d3 1e 00 00       	call   801040d3 <memset>

  if(kmem.use_lock)
80102200:	83 c4 10             	add    $0x10,%esp
80102203:	83 3d f4 34 11 80 00 	cmpl   $0x0,0x801134f4
8010220a:	75 35                	jne    80102241 <kfree+0x84>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
8010220c:	a1 f8 34 11 80       	mov    0x801134f8,%eax
80102211:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80102213:	89 1d f8 34 11 80    	mov    %ebx,0x801134f8
  if(kmem.use_lock)
80102219:	83 3d f4 34 11 80 00 	cmpl   $0x0,0x801134f4
80102220:	75 31                	jne    80102253 <kfree+0x96>
    release(&kmem.lock);
}
80102222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102225:	c9                   	leave  
80102226:	c3                   	ret    
        panic("V2P on address < KERNBASE "
80102227:	83 ec 0c             	sub    $0xc,%esp
8010222a:	68 f4 72 10 80       	push   $0x801072f4
8010222f:	e8 28 e1 ff ff       	call   8010035c <panic>
    panic("kfree");
80102234:	83 ec 0c             	sub    $0xc,%esp
80102237:	68 82 73 10 80       	push   $0x80107382
8010223c:	e8 1b e1 ff ff       	call   8010035c <panic>
    acquire(&kmem.lock);
80102241:	83 ec 0c             	sub    $0xc,%esp
80102244:	68 c0 34 11 80       	push   $0x801134c0
80102249:	e8 d1 1d 00 00       	call   8010401f <acquire>
8010224e:	83 c4 10             	add    $0x10,%esp
80102251:	eb b9                	jmp    8010220c <kfree+0x4f>
    release(&kmem.lock);
80102253:	83 ec 0c             	sub    $0xc,%esp
80102256:	68 c0 34 11 80       	push   $0x801134c0
8010225b:	e8 28 1e 00 00       	call   80104088 <release>
80102260:	83 c4 10             	add    $0x10,%esp
}
80102263:	eb bd                	jmp    80102222 <kfree+0x65>

80102265 <freerange>:
{
80102265:	f3 0f 1e fb          	endbr32 
80102269:	55                   	push   %ebp
8010226a:	89 e5                	mov    %esp,%ebp
8010226c:	56                   	push   %esi
8010226d:	53                   	push   %ebx
8010226e:	8b 45 08             	mov    0x8(%ebp),%eax
80102271:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if (vend < vstart) panic("freerange");
80102274:	39 c3                	cmp    %eax,%ebx
80102276:	72 0c                	jb     80102284 <freerange+0x1f>
  p = (char*)PGROUNDUP((uint)vstart);
80102278:	05 ff 0f 00 00       	add    $0xfff,%eax
8010227d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102282:	eb 1b                	jmp    8010229f <freerange+0x3a>
  if (vend < vstart) panic("freerange");
80102284:	83 ec 0c             	sub    $0xc,%esp
80102287:	68 88 73 10 80       	push   $0x80107388
8010228c:	e8 cb e0 ff ff       	call   8010035c <panic>
    kfree(p);
80102291:	83 ec 0c             	sub    $0xc,%esp
80102294:	50                   	push   %eax
80102295:	e8 23 ff ff ff       	call   801021bd <kfree>
8010229a:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010229d:	89 f0                	mov    %esi,%eax
8010229f:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
801022a5:	39 de                	cmp    %ebx,%esi
801022a7:	76 e8                	jbe    80102291 <freerange+0x2c>
}
801022a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801022ac:	5b                   	pop    %ebx
801022ad:	5e                   	pop    %esi
801022ae:	5d                   	pop    %ebp
801022af:	c3                   	ret    

801022b0 <kinit1>:
{
801022b0:	f3 0f 1e fb          	endbr32 
801022b4:	55                   	push   %ebp
801022b5:	89 e5                	mov    %esp,%ebp
801022b7:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
801022ba:	68 92 73 10 80       	push   $0x80107392
801022bf:	68 c0 34 11 80       	push   $0x801134c0
801022c4:	e8 06 1c 00 00       	call   80103ecf <initlock>
  kmem.use_lock = 0;
801022c9:	c7 05 f4 34 11 80 00 	movl   $0x0,0x801134f4
801022d0:	00 00 00 
  freerange(vstart, vend);
801022d3:	83 c4 08             	add    $0x8,%esp
801022d6:	ff 75 0c             	pushl  0xc(%ebp)
801022d9:	ff 75 08             	pushl  0x8(%ebp)
801022dc:	e8 84 ff ff ff       	call   80102265 <freerange>
}
801022e1:	83 c4 10             	add    $0x10,%esp
801022e4:	c9                   	leave  
801022e5:	c3                   	ret    

801022e6 <kinit2>:
{
801022e6:	f3 0f 1e fb          	endbr32 
801022ea:	55                   	push   %ebp
801022eb:	89 e5                	mov    %esp,%ebp
801022ed:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801022f0:	ff 75 0c             	pushl  0xc(%ebp)
801022f3:	ff 75 08             	pushl  0x8(%ebp)
801022f6:	e8 6a ff ff ff       	call   80102265 <freerange>
  kmem.use_lock = 1;
801022fb:	c7 05 f4 34 11 80 01 	movl   $0x1,0x801134f4
80102302:	00 00 00 
}
80102305:	83 c4 10             	add    $0x10,%esp
80102308:	c9                   	leave  
80102309:	c3                   	ret    

8010230a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010230a:	f3 0f 1e fb          	endbr32 
8010230e:	55                   	push   %ebp
8010230f:	89 e5                	mov    %esp,%ebp
80102311:	53                   	push   %ebx
80102312:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
80102315:	83 3d f4 34 11 80 00 	cmpl   $0x0,0x801134f4
8010231c:	75 21                	jne    8010233f <kalloc+0x35>
    acquire(&kmem.lock);
  r = kmem.freelist;
8010231e:	8b 1d f8 34 11 80    	mov    0x801134f8,%ebx
  if(r)
80102324:	85 db                	test   %ebx,%ebx
80102326:	74 07                	je     8010232f <kalloc+0x25>
    kmem.freelist = r->next;
80102328:	8b 03                	mov    (%ebx),%eax
8010232a:	a3 f8 34 11 80       	mov    %eax,0x801134f8
  if(kmem.use_lock)
8010232f:	83 3d f4 34 11 80 00 	cmpl   $0x0,0x801134f4
80102336:	75 19                	jne    80102351 <kalloc+0x47>
    release(&kmem.lock);
  return (char*)r;
}
80102338:	89 d8                	mov    %ebx,%eax
8010233a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010233d:	c9                   	leave  
8010233e:	c3                   	ret    
    acquire(&kmem.lock);
8010233f:	83 ec 0c             	sub    $0xc,%esp
80102342:	68 c0 34 11 80       	push   $0x801134c0
80102347:	e8 d3 1c 00 00       	call   8010401f <acquire>
8010234c:	83 c4 10             	add    $0x10,%esp
8010234f:	eb cd                	jmp    8010231e <kalloc+0x14>
    release(&kmem.lock);
80102351:	83 ec 0c             	sub    $0xc,%esp
80102354:	68 c0 34 11 80       	push   $0x801134c0
80102359:	e8 2a 1d 00 00       	call   80104088 <release>
8010235e:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102361:	eb d5                	jmp    80102338 <kalloc+0x2e>

80102363 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102363:	f3 0f 1e fb          	endbr32 
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102367:	ba 64 00 00 00       	mov    $0x64,%edx
8010236c:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
8010236d:	a8 01                	test   $0x1,%al
8010236f:	0f 84 ad 00 00 00    	je     80102422 <kbdgetc+0xbf>
80102375:	ba 60 00 00 00       	mov    $0x60,%edx
8010237a:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
8010237b:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
8010237e:	3c e0                	cmp    $0xe0,%al
80102380:	74 5b                	je     801023dd <kbdgetc+0x7a>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102382:	84 c0                	test   %al,%al
80102384:	78 64                	js     801023ea <kbdgetc+0x87>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102386:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
8010238c:	f6 c1 40             	test   $0x40,%cl
8010238f:	74 0f                	je     801023a0 <kbdgetc+0x3d>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102391:	83 c8 80             	or     $0xffffff80,%eax
80102394:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102397:	83 e1 bf             	and    $0xffffffbf,%ecx
8010239a:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  }

  shift |= shiftcode[data];
801023a0:	0f b6 8a c0 74 10 80 	movzbl -0x7fef8b40(%edx),%ecx
801023a7:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
801023ad:	0f b6 82 c0 73 10 80 	movzbl -0x7fef8c40(%edx),%eax
801023b4:	31 c1                	xor    %eax,%ecx
801023b6:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
801023bc:	89 c8                	mov    %ecx,%eax
801023be:	83 e0 03             	and    $0x3,%eax
801023c1:	8b 04 85 a0 73 10 80 	mov    -0x7fef8c60(,%eax,4),%eax
801023c8:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
801023cc:	f6 c1 08             	test   $0x8,%cl
801023cf:	74 56                	je     80102427 <kbdgetc+0xc4>
    if('a' <= c && c <= 'z')
801023d1:	8d 50 9f             	lea    -0x61(%eax),%edx
801023d4:	83 fa 19             	cmp    $0x19,%edx
801023d7:	77 3d                	ja     80102416 <kbdgetc+0xb3>
      c += 'A' - 'a';
801023d9:	83 e8 20             	sub    $0x20,%eax
801023dc:	c3                   	ret    
    shift |= E0ESC;
801023dd:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
801023e4:	b8 00 00 00 00       	mov    $0x0,%eax
801023e9:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801023ea:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
801023f0:	f6 c1 40             	test   $0x40,%cl
801023f3:	75 05                	jne    801023fa <kbdgetc+0x97>
801023f5:	89 c2                	mov    %eax,%edx
801023f7:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801023fa:	0f b6 82 c0 74 10 80 	movzbl -0x7fef8b40(%edx),%eax
80102401:	83 c8 40             	or     $0x40,%eax
80102404:	0f b6 c0             	movzbl %al,%eax
80102407:	f7 d0                	not    %eax
80102409:	21 c8                	and    %ecx,%eax
8010240b:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
80102410:	b8 00 00 00 00       	mov    $0x0,%eax
80102415:	c3                   	ret    
    else if('A' <= c && c <= 'Z')
80102416:	8d 50 bf             	lea    -0x41(%eax),%edx
80102419:	83 fa 19             	cmp    $0x19,%edx
8010241c:	77 09                	ja     80102427 <kbdgetc+0xc4>
      c += 'a' - 'A';
8010241e:	83 c0 20             	add    $0x20,%eax
  }
  return c;
80102421:	c3                   	ret    
    return -1;
80102422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102427:	c3                   	ret    

80102428 <kbdintr>:

void
kbdintr(void)
{
80102428:	f3 0f 1e fb          	endbr32 
8010242c:	55                   	push   %ebp
8010242d:	89 e5                	mov    %esp,%ebp
8010242f:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102432:	68 63 23 10 80       	push   $0x80102363
80102437:	e8 1d e3 ff ff       	call   80100759 <consoleintr>
}
8010243c:	83 c4 10             	add    $0x10,%esp
8010243f:	c9                   	leave  
80102440:	c3                   	ret    

80102441 <shutdown>:
#include "types.h"
#include "x86.h"

void
shutdown(void)
{
80102441:	f3 0f 1e fb          	endbr32 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102445:	b8 00 00 00 00       	mov    $0x0,%eax
8010244a:	ba 01 05 00 00       	mov    $0x501,%edx
8010244f:	ee                   	out    %al,(%dx)
  /*
     This only works in QEMU and assumes QEMU was run 
     with -device isa-debug-exit
   */
  outb(0x501, 0x0);
}
80102450:	c3                   	ret    

80102451 <lapicw>:

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102451:	8b 0d fc 34 11 80    	mov    0x801134fc,%ecx
80102457:	8d 04 81             	lea    (%ecx,%eax,4),%eax
8010245a:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010245c:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80102461:	8b 40 20             	mov    0x20(%eax),%eax
}
80102464:	c3                   	ret    

80102465 <cmos_read>:
80102465:	ba 70 00 00 00       	mov    $0x70,%edx
8010246a:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010246b:	ba 71 00 00 00       	mov    $0x71,%edx
80102470:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102471:	0f b6 c0             	movzbl %al,%eax
}
80102474:	c3                   	ret    

80102475 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80102475:	55                   	push   %ebp
80102476:	89 e5                	mov    %esp,%ebp
80102478:	53                   	push   %ebx
80102479:	83 ec 04             	sub    $0x4,%esp
8010247c:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
8010247e:	b8 00 00 00 00       	mov    $0x0,%eax
80102483:	e8 dd ff ff ff       	call   80102465 <cmos_read>
80102488:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
8010248a:	b8 02 00 00 00       	mov    $0x2,%eax
8010248f:	e8 d1 ff ff ff       	call   80102465 <cmos_read>
80102494:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
80102497:	b8 04 00 00 00       	mov    $0x4,%eax
8010249c:	e8 c4 ff ff ff       	call   80102465 <cmos_read>
801024a1:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801024a4:	b8 07 00 00 00       	mov    $0x7,%eax
801024a9:	e8 b7 ff ff ff       	call   80102465 <cmos_read>
801024ae:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801024b1:	b8 08 00 00 00       	mov    $0x8,%eax
801024b6:	e8 aa ff ff ff       	call   80102465 <cmos_read>
801024bb:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801024be:	b8 09 00 00 00       	mov    $0x9,%eax
801024c3:	e8 9d ff ff ff       	call   80102465 <cmos_read>
801024c8:	89 43 14             	mov    %eax,0x14(%ebx)
}
801024cb:	83 c4 04             	add    $0x4,%esp
801024ce:	5b                   	pop    %ebx
801024cf:	5d                   	pop    %ebp
801024d0:	c3                   	ret    

801024d1 <lapicinit>:
{
801024d1:	f3 0f 1e fb          	endbr32 
  if(!lapic)
801024d5:	83 3d fc 34 11 80 00 	cmpl   $0x0,0x801134fc
801024dc:	0f 84 fe 00 00 00    	je     801025e0 <lapicinit+0x10f>
{
801024e2:	55                   	push   %ebp
801024e3:	89 e5                	mov    %esp,%ebp
801024e5:	83 ec 08             	sub    $0x8,%esp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801024e8:	ba 3f 01 00 00       	mov    $0x13f,%edx
801024ed:	b8 3c 00 00 00       	mov    $0x3c,%eax
801024f2:	e8 5a ff ff ff       	call   80102451 <lapicw>
  lapicw(TDCR, X1);
801024f7:	ba 0b 00 00 00       	mov    $0xb,%edx
801024fc:	b8 f8 00 00 00       	mov    $0xf8,%eax
80102501:	e8 4b ff ff ff       	call   80102451 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102506:	ba 20 00 02 00       	mov    $0x20020,%edx
8010250b:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102510:	e8 3c ff ff ff       	call   80102451 <lapicw>
  lapicw(TICR, 10000000);
80102515:	ba 80 96 98 00       	mov    $0x989680,%edx
8010251a:	b8 e0 00 00 00       	mov    $0xe0,%eax
8010251f:	e8 2d ff ff ff       	call   80102451 <lapicw>
  lapicw(LINT0, MASKED);
80102524:	ba 00 00 01 00       	mov    $0x10000,%edx
80102529:	b8 d4 00 00 00       	mov    $0xd4,%eax
8010252e:	e8 1e ff ff ff       	call   80102451 <lapicw>
  lapicw(LINT1, MASKED);
80102533:	ba 00 00 01 00       	mov    $0x10000,%edx
80102538:	b8 d8 00 00 00       	mov    $0xd8,%eax
8010253d:	e8 0f ff ff ff       	call   80102451 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102542:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80102547:	8b 40 30             	mov    0x30(%eax),%eax
8010254a:	c1 e8 10             	shr    $0x10,%eax
8010254d:	a8 fc                	test   $0xfc,%al
8010254f:	75 7b                	jne    801025cc <lapicinit+0xfb>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102551:	ba 33 00 00 00       	mov    $0x33,%edx
80102556:	b8 dc 00 00 00       	mov    $0xdc,%eax
8010255b:	e8 f1 fe ff ff       	call   80102451 <lapicw>
  lapicw(ESR, 0);
80102560:	ba 00 00 00 00       	mov    $0x0,%edx
80102565:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010256a:	e8 e2 fe ff ff       	call   80102451 <lapicw>
  lapicw(ESR, 0);
8010256f:	ba 00 00 00 00       	mov    $0x0,%edx
80102574:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102579:	e8 d3 fe ff ff       	call   80102451 <lapicw>
  lapicw(EOI, 0);
8010257e:	ba 00 00 00 00       	mov    $0x0,%edx
80102583:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102588:	e8 c4 fe ff ff       	call   80102451 <lapicw>
  lapicw(ICRHI, 0);
8010258d:	ba 00 00 00 00       	mov    $0x0,%edx
80102592:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102597:	e8 b5 fe ff ff       	call   80102451 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010259c:	ba 00 85 08 00       	mov    $0x88500,%edx
801025a1:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025a6:	e8 a6 fe ff ff       	call   80102451 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801025ab:	a1 fc 34 11 80       	mov    0x801134fc,%eax
801025b0:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801025b6:	f6 c4 10             	test   $0x10,%ah
801025b9:	75 f0                	jne    801025ab <lapicinit+0xda>
  lapicw(TPR, 0);
801025bb:	ba 00 00 00 00       	mov    $0x0,%edx
801025c0:	b8 20 00 00 00       	mov    $0x20,%eax
801025c5:	e8 87 fe ff ff       	call   80102451 <lapicw>
}
801025ca:	c9                   	leave  
801025cb:	c3                   	ret    
    lapicw(PCINT, MASKED);
801025cc:	ba 00 00 01 00       	mov    $0x10000,%edx
801025d1:	b8 d0 00 00 00       	mov    $0xd0,%eax
801025d6:	e8 76 fe ff ff       	call   80102451 <lapicw>
801025db:	e9 71 ff ff ff       	jmp    80102551 <lapicinit+0x80>
801025e0:	c3                   	ret    

801025e1 <lapicid>:
{
801025e1:	f3 0f 1e fb          	endbr32 
  if (!lapic)
801025e5:	a1 fc 34 11 80       	mov    0x801134fc,%eax
801025ea:	85 c0                	test   %eax,%eax
801025ec:	74 07                	je     801025f5 <lapicid+0x14>
  return lapic[ID] >> 24;
801025ee:	8b 40 20             	mov    0x20(%eax),%eax
801025f1:	c1 e8 18             	shr    $0x18,%eax
801025f4:	c3                   	ret    
    return 0;
801025f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025fa:	c3                   	ret    

801025fb <lapiceoi>:
{
801025fb:	f3 0f 1e fb          	endbr32 
  if(lapic)
801025ff:	83 3d fc 34 11 80 00 	cmpl   $0x0,0x801134fc
80102606:	74 17                	je     8010261f <lapiceoi+0x24>
{
80102608:	55                   	push   %ebp
80102609:	89 e5                	mov    %esp,%ebp
8010260b:	83 ec 08             	sub    $0x8,%esp
    lapicw(EOI, 0);
8010260e:	ba 00 00 00 00       	mov    $0x0,%edx
80102613:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102618:	e8 34 fe ff ff       	call   80102451 <lapicw>
}
8010261d:	c9                   	leave  
8010261e:	c3                   	ret    
8010261f:	c3                   	ret    

80102620 <microdelay>:
{
80102620:	f3 0f 1e fb          	endbr32 
}
80102624:	c3                   	ret    

80102625 <lapicstartap>:
{
80102625:	f3 0f 1e fb          	endbr32 
80102629:	55                   	push   %ebp
8010262a:	89 e5                	mov    %esp,%ebp
8010262c:	57                   	push   %edi
8010262d:	56                   	push   %esi
8010262e:	53                   	push   %ebx
8010262f:	83 ec 0c             	sub    $0xc,%esp
80102632:	8b 75 08             	mov    0x8(%ebp),%esi
80102635:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102638:	b8 0f 00 00 00       	mov    $0xf,%eax
8010263d:	ba 70 00 00 00       	mov    $0x70,%edx
80102642:	ee                   	out    %al,(%dx)
80102643:	b8 0a 00 00 00       	mov    $0xa,%eax
80102648:	ba 71 00 00 00       	mov    $0x71,%edx
8010264d:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
8010264e:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102655:	00 00 
  wrv[1] = addr >> 4;
80102657:	89 f8                	mov    %edi,%eax
80102659:	c1 e8 04             	shr    $0x4,%eax
8010265c:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102662:	c1 e6 18             	shl    $0x18,%esi
80102665:	89 f2                	mov    %esi,%edx
80102667:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010266c:	e8 e0 fd ff ff       	call   80102451 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102671:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102676:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010267b:	e8 d1 fd ff ff       	call   80102451 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102680:	ba 00 85 00 00       	mov    $0x8500,%edx
80102685:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010268a:	e8 c2 fd ff ff       	call   80102451 <lapicw>
  for(i = 0; i < 2; i++){
8010268f:	bb 00 00 00 00       	mov    $0x0,%ebx
80102694:	eb 21                	jmp    801026b7 <lapicstartap+0x92>
    lapicw(ICRHI, apicid<<24);
80102696:	89 f2                	mov    %esi,%edx
80102698:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010269d:	e8 af fd ff ff       	call   80102451 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801026a2:	89 fa                	mov    %edi,%edx
801026a4:	c1 ea 0c             	shr    $0xc,%edx
801026a7:	80 ce 06             	or     $0x6,%dh
801026aa:	b8 c0 00 00 00       	mov    $0xc0,%eax
801026af:	e8 9d fd ff ff       	call   80102451 <lapicw>
  for(i = 0; i < 2; i++){
801026b4:	83 c3 01             	add    $0x1,%ebx
801026b7:	83 fb 01             	cmp    $0x1,%ebx
801026ba:	7e da                	jle    80102696 <lapicstartap+0x71>
}
801026bc:	83 c4 0c             	add    $0xc,%esp
801026bf:	5b                   	pop    %ebx
801026c0:	5e                   	pop    %esi
801026c1:	5f                   	pop    %edi
801026c2:	5d                   	pop    %ebp
801026c3:	c3                   	ret    

801026c4 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801026c4:	f3 0f 1e fb          	endbr32 
801026c8:	55                   	push   %ebp
801026c9:	89 e5                	mov    %esp,%ebp
801026cb:	57                   	push   %edi
801026cc:	56                   	push   %esi
801026cd:	53                   	push   %ebx
801026ce:	83 ec 3c             	sub    $0x3c,%esp
801026d1:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801026d4:	b8 0b 00 00 00       	mov    $0xb,%eax
801026d9:	e8 87 fd ff ff       	call   80102465 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801026de:	83 e0 04             	and    $0x4,%eax
801026e1:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801026e3:	8d 45 d0             	lea    -0x30(%ebp),%eax
801026e6:	e8 8a fd ff ff       	call   80102475 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801026eb:	b8 0a 00 00 00       	mov    $0xa,%eax
801026f0:	e8 70 fd ff ff       	call   80102465 <cmos_read>
801026f5:	a8 80                	test   $0x80,%al
801026f7:	75 ea                	jne    801026e3 <cmostime+0x1f>
        continue;
    fill_rtcdate(&t2);
801026f9:	8d 5d b8             	lea    -0x48(%ebp),%ebx
801026fc:	89 d8                	mov    %ebx,%eax
801026fe:	e8 72 fd ff ff       	call   80102475 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102703:	83 ec 04             	sub    $0x4,%esp
80102706:	6a 18                	push   $0x18
80102708:	53                   	push   %ebx
80102709:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010270c:	50                   	push   %eax
8010270d:	e8 08 1a 00 00       	call   8010411a <memcmp>
80102712:	83 c4 10             	add    $0x10,%esp
80102715:	85 c0                	test   %eax,%eax
80102717:	75 ca                	jne    801026e3 <cmostime+0x1f>
      break;
  }

  // convert
  if(bcd) {
80102719:	85 ff                	test   %edi,%edi
8010271b:	75 78                	jne    80102795 <cmostime+0xd1>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010271d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102720:	89 c2                	mov    %eax,%edx
80102722:	c1 ea 04             	shr    $0x4,%edx
80102725:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102728:	83 e0 0f             	and    $0xf,%eax
8010272b:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010272e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102731:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102734:	89 c2                	mov    %eax,%edx
80102736:	c1 ea 04             	shr    $0x4,%edx
80102739:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010273c:	83 e0 0f             	and    $0xf,%eax
8010273f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102742:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102745:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102748:	89 c2                	mov    %eax,%edx
8010274a:	c1 ea 04             	shr    $0x4,%edx
8010274d:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102750:	83 e0 0f             	and    $0xf,%eax
80102753:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102756:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102759:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010275c:	89 c2                	mov    %eax,%edx
8010275e:	c1 ea 04             	shr    $0x4,%edx
80102761:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102764:	83 e0 0f             	and    $0xf,%eax
80102767:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010276a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
8010276d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102770:	89 c2                	mov    %eax,%edx
80102772:	c1 ea 04             	shr    $0x4,%edx
80102775:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102778:	83 e0 0f             	and    $0xf,%eax
8010277b:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010277e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
80102781:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102784:	89 c2                	mov    %eax,%edx
80102786:	c1 ea 04             	shr    $0x4,%edx
80102789:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010278c:	83 e0 0f             	and    $0xf,%eax
8010278f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102792:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102795:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102798:	89 06                	mov    %eax,(%esi)
8010279a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010279d:	89 46 04             	mov    %eax,0x4(%esi)
801027a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801027a3:	89 46 08             	mov    %eax,0x8(%esi)
801027a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801027a9:	89 46 0c             	mov    %eax,0xc(%esi)
801027ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801027af:	89 46 10             	mov    %eax,0x10(%esi)
801027b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801027b5:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
801027b8:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
801027bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801027c2:	5b                   	pop    %ebx
801027c3:	5e                   	pop    %esi
801027c4:	5f                   	pop    %edi
801027c5:	5d                   	pop    %ebp
801027c6:	c3                   	ret    

801027c7 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801027c7:	55                   	push   %ebp
801027c8:	89 e5                	mov    %esp,%ebp
801027ca:	53                   	push   %ebx
801027cb:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801027ce:	ff 35 34 35 11 80    	pushl  0x80113534
801027d4:	ff 35 44 35 11 80    	pushl  0x80113544
801027da:	e8 91 d9 ff ff       	call   80100170 <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801027df:	8b 58 5c             	mov    0x5c(%eax),%ebx
801027e2:	89 1d 48 35 11 80    	mov    %ebx,0x80113548
  for (i = 0; i < log.lh.n; i++) {
801027e8:	83 c4 10             	add    $0x10,%esp
801027eb:	ba 00 00 00 00       	mov    $0x0,%edx
801027f0:	39 d3                	cmp    %edx,%ebx
801027f2:	7e 10                	jle    80102804 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
801027f4:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801027f8:	89 0c 95 4c 35 11 80 	mov    %ecx,-0x7feecab4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801027ff:	83 c2 01             	add    $0x1,%edx
80102802:	eb ec                	jmp    801027f0 <read_head+0x29>
  }
  brelse(buf);
80102804:	83 ec 0c             	sub    $0xc,%esp
80102807:	50                   	push   %eax
80102808:	e8 d4 d9 ff ff       	call   801001e1 <brelse>
}
8010280d:	83 c4 10             	add    $0x10,%esp
80102810:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102813:	c9                   	leave  
80102814:	c3                   	ret    

80102815 <install_trans>:
{
80102815:	55                   	push   %ebp
80102816:	89 e5                	mov    %esp,%ebp
80102818:	57                   	push   %edi
80102819:	56                   	push   %esi
8010281a:	53                   	push   %ebx
8010281b:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010281e:	be 00 00 00 00       	mov    $0x0,%esi
80102823:	39 35 48 35 11 80    	cmp    %esi,0x80113548
80102829:	7e 68                	jle    80102893 <install_trans+0x7e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010282b:	89 f0                	mov    %esi,%eax
8010282d:	03 05 34 35 11 80    	add    0x80113534,%eax
80102833:	83 c0 01             	add    $0x1,%eax
80102836:	83 ec 08             	sub    $0x8,%esp
80102839:	50                   	push   %eax
8010283a:	ff 35 44 35 11 80    	pushl  0x80113544
80102840:	e8 2b d9 ff ff       	call   80100170 <bread>
80102845:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102847:	83 c4 08             	add    $0x8,%esp
8010284a:	ff 34 b5 4c 35 11 80 	pushl  -0x7feecab4(,%esi,4)
80102851:	ff 35 44 35 11 80    	pushl  0x80113544
80102857:	e8 14 d9 ff ff       	call   80100170 <bread>
8010285c:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010285e:	8d 57 5c             	lea    0x5c(%edi),%edx
80102861:	8d 40 5c             	lea    0x5c(%eax),%eax
80102864:	83 c4 0c             	add    $0xc,%esp
80102867:	68 00 02 00 00       	push   $0x200
8010286c:	52                   	push   %edx
8010286d:	50                   	push   %eax
8010286e:	e8 e0 18 00 00       	call   80104153 <memmove>
    bwrite(dbuf);  // write dst to disk
80102873:	89 1c 24             	mov    %ebx,(%esp)
80102876:	e8 27 d9 ff ff       	call   801001a2 <bwrite>
    brelse(lbuf);
8010287b:	89 3c 24             	mov    %edi,(%esp)
8010287e:	e8 5e d9 ff ff       	call   801001e1 <brelse>
    brelse(dbuf);
80102883:	89 1c 24             	mov    %ebx,(%esp)
80102886:	e8 56 d9 ff ff       	call   801001e1 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010288b:	83 c6 01             	add    $0x1,%esi
8010288e:	83 c4 10             	add    $0x10,%esp
80102891:	eb 90                	jmp    80102823 <install_trans+0xe>
}
80102893:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102896:	5b                   	pop    %ebx
80102897:	5e                   	pop    %esi
80102898:	5f                   	pop    %edi
80102899:	5d                   	pop    %ebp
8010289a:	c3                   	ret    

8010289b <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010289b:	55                   	push   %ebp
8010289c:	89 e5                	mov    %esp,%ebp
8010289e:	53                   	push   %ebx
8010289f:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801028a2:	ff 35 34 35 11 80    	pushl  0x80113534
801028a8:	ff 35 44 35 11 80    	pushl  0x80113544
801028ae:	e8 bd d8 ff ff       	call   80100170 <bread>
801028b3:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801028b5:	8b 0d 48 35 11 80    	mov    0x80113548,%ecx
801028bb:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
801028be:	83 c4 10             	add    $0x10,%esp
801028c1:	b8 00 00 00 00       	mov    $0x0,%eax
801028c6:	39 c1                	cmp    %eax,%ecx
801028c8:	7e 10                	jle    801028da <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
801028ca:	8b 14 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%edx
801028d1:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801028d5:	83 c0 01             	add    $0x1,%eax
801028d8:	eb ec                	jmp    801028c6 <write_head+0x2b>
  }
  bwrite(buf);
801028da:	83 ec 0c             	sub    $0xc,%esp
801028dd:	53                   	push   %ebx
801028de:	e8 bf d8 ff ff       	call   801001a2 <bwrite>
  brelse(buf);
801028e3:	89 1c 24             	mov    %ebx,(%esp)
801028e6:	e8 f6 d8 ff ff       	call   801001e1 <brelse>
}
801028eb:	83 c4 10             	add    $0x10,%esp
801028ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028f1:	c9                   	leave  
801028f2:	c3                   	ret    

801028f3 <recover_from_log>:

static void
recover_from_log(void)
{
801028f3:	55                   	push   %ebp
801028f4:	89 e5                	mov    %esp,%ebp
801028f6:	83 ec 08             	sub    $0x8,%esp
  read_head();
801028f9:	e8 c9 fe ff ff       	call   801027c7 <read_head>
  install_trans(); // if committed, copy from log to disk
801028fe:	e8 12 ff ff ff       	call   80102815 <install_trans>
  log.lh.n = 0;
80102903:	c7 05 48 35 11 80 00 	movl   $0x0,0x80113548
8010290a:	00 00 00 
  write_head(); // clear the log
8010290d:	e8 89 ff ff ff       	call   8010289b <write_head>
}
80102912:	c9                   	leave  
80102913:	c3                   	ret    

80102914 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102914:	55                   	push   %ebp
80102915:	89 e5                	mov    %esp,%ebp
80102917:	57                   	push   %edi
80102918:	56                   	push   %esi
80102919:	53                   	push   %ebx
8010291a:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010291d:	be 00 00 00 00       	mov    $0x0,%esi
80102922:	39 35 48 35 11 80    	cmp    %esi,0x80113548
80102928:	7e 68                	jle    80102992 <write_log+0x7e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010292a:	89 f0                	mov    %esi,%eax
8010292c:	03 05 34 35 11 80    	add    0x80113534,%eax
80102932:	83 c0 01             	add    $0x1,%eax
80102935:	83 ec 08             	sub    $0x8,%esp
80102938:	50                   	push   %eax
80102939:	ff 35 44 35 11 80    	pushl  0x80113544
8010293f:	e8 2c d8 ff ff       	call   80100170 <bread>
80102944:	89 c3                	mov    %eax,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102946:	83 c4 08             	add    $0x8,%esp
80102949:	ff 34 b5 4c 35 11 80 	pushl  -0x7feecab4(,%esi,4)
80102950:	ff 35 44 35 11 80    	pushl  0x80113544
80102956:	e8 15 d8 ff ff       	call   80100170 <bread>
8010295b:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
8010295d:	8d 50 5c             	lea    0x5c(%eax),%edx
80102960:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102963:	83 c4 0c             	add    $0xc,%esp
80102966:	68 00 02 00 00       	push   $0x200
8010296b:	52                   	push   %edx
8010296c:	50                   	push   %eax
8010296d:	e8 e1 17 00 00       	call   80104153 <memmove>
    bwrite(to);  // write the log
80102972:	89 1c 24             	mov    %ebx,(%esp)
80102975:	e8 28 d8 ff ff       	call   801001a2 <bwrite>
    brelse(from);
8010297a:	89 3c 24             	mov    %edi,(%esp)
8010297d:	e8 5f d8 ff ff       	call   801001e1 <brelse>
    brelse(to);
80102982:	89 1c 24             	mov    %ebx,(%esp)
80102985:	e8 57 d8 ff ff       	call   801001e1 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010298a:	83 c6 01             	add    $0x1,%esi
8010298d:	83 c4 10             	add    $0x10,%esp
80102990:	eb 90                	jmp    80102922 <write_log+0xe>
  }
}
80102992:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102995:	5b                   	pop    %ebx
80102996:	5e                   	pop    %esi
80102997:	5f                   	pop    %edi
80102998:	5d                   	pop    %ebp
80102999:	c3                   	ret    

8010299a <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
8010299a:	83 3d 48 35 11 80 00 	cmpl   $0x0,0x80113548
801029a1:	7f 01                	jg     801029a4 <commit+0xa>
801029a3:	c3                   	ret    
{
801029a4:	55                   	push   %ebp
801029a5:	89 e5                	mov    %esp,%ebp
801029a7:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
801029aa:	e8 65 ff ff ff       	call   80102914 <write_log>
    write_head();    // Write header to disk -- the real commit
801029af:	e8 e7 fe ff ff       	call   8010289b <write_head>
    install_trans(); // Now install writes to home locations
801029b4:	e8 5c fe ff ff       	call   80102815 <install_trans>
    log.lh.n = 0;
801029b9:	c7 05 48 35 11 80 00 	movl   $0x0,0x80113548
801029c0:	00 00 00 
    write_head();    // Erase the transaction from the log
801029c3:	e8 d3 fe ff ff       	call   8010289b <write_head>
  }
}
801029c8:	c9                   	leave  
801029c9:	c3                   	ret    

801029ca <initlog>:
{
801029ca:	f3 0f 1e fb          	endbr32 
801029ce:	55                   	push   %ebp
801029cf:	89 e5                	mov    %esp,%ebp
801029d1:	53                   	push   %ebx
801029d2:	83 ec 2c             	sub    $0x2c,%esp
801029d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801029d8:	68 c0 75 10 80       	push   $0x801075c0
801029dd:	68 00 35 11 80       	push   $0x80113500
801029e2:	e8 e8 14 00 00       	call   80103ecf <initlock>
  readsb(dev, &sb);
801029e7:	83 c4 08             	add    $0x8,%esp
801029ea:	8d 45 dc             	lea    -0x24(%ebp),%eax
801029ed:	50                   	push   %eax
801029ee:	53                   	push   %ebx
801029ef:	e8 9d e9 ff ff       	call   80101391 <readsb>
  log.start = sb.logstart;
801029f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029f7:	a3 34 35 11 80       	mov    %eax,0x80113534
  log.size = sb.nlog;
801029fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801029ff:	a3 38 35 11 80       	mov    %eax,0x80113538
  log.dev = dev;
80102a04:	89 1d 44 35 11 80    	mov    %ebx,0x80113544
  recover_from_log();
80102a0a:	e8 e4 fe ff ff       	call   801028f3 <recover_from_log>
}
80102a0f:	83 c4 10             	add    $0x10,%esp
80102a12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a15:	c9                   	leave  
80102a16:	c3                   	ret    

80102a17 <begin_op>:
{
80102a17:	f3 0f 1e fb          	endbr32 
80102a1b:	55                   	push   %ebp
80102a1c:	89 e5                	mov    %esp,%ebp
80102a1e:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102a21:	68 00 35 11 80       	push   $0x80113500
80102a26:	e8 f4 15 00 00       	call   8010401f <acquire>
80102a2b:	83 c4 10             	add    $0x10,%esp
80102a2e:	eb 15                	jmp    80102a45 <begin_op+0x2e>
      sleep(&log, &log.lock);
80102a30:	83 ec 08             	sub    $0x8,%esp
80102a33:	68 00 35 11 80       	push   $0x80113500
80102a38:	68 00 35 11 80       	push   $0x80113500
80102a3d:	e8 6d 10 00 00       	call   80103aaf <sleep>
80102a42:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102a45:	83 3d 40 35 11 80 00 	cmpl   $0x0,0x80113540
80102a4c:	75 e2                	jne    80102a30 <begin_op+0x19>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102a4e:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80102a53:	83 c0 01             	add    $0x1,%eax
80102a56:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102a59:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102a5c:	03 15 48 35 11 80    	add    0x80113548,%edx
80102a62:	83 fa 1e             	cmp    $0x1e,%edx
80102a65:	7e 17                	jle    80102a7e <begin_op+0x67>
      sleep(&log, &log.lock);
80102a67:	83 ec 08             	sub    $0x8,%esp
80102a6a:	68 00 35 11 80       	push   $0x80113500
80102a6f:	68 00 35 11 80       	push   $0x80113500
80102a74:	e8 36 10 00 00       	call   80103aaf <sleep>
80102a79:	83 c4 10             	add    $0x10,%esp
80102a7c:	eb c7                	jmp    80102a45 <begin_op+0x2e>
      log.outstanding += 1;
80102a7e:	a3 3c 35 11 80       	mov    %eax,0x8011353c
      release(&log.lock);
80102a83:	83 ec 0c             	sub    $0xc,%esp
80102a86:	68 00 35 11 80       	push   $0x80113500
80102a8b:	e8 f8 15 00 00       	call   80104088 <release>
}
80102a90:	83 c4 10             	add    $0x10,%esp
80102a93:	c9                   	leave  
80102a94:	c3                   	ret    

80102a95 <end_op>:
{
80102a95:	f3 0f 1e fb          	endbr32 
80102a99:	55                   	push   %ebp
80102a9a:	89 e5                	mov    %esp,%ebp
80102a9c:	53                   	push   %ebx
80102a9d:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102aa0:	68 00 35 11 80       	push   $0x80113500
80102aa5:	e8 75 15 00 00       	call   8010401f <acquire>
  log.outstanding -= 1;
80102aaa:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80102aaf:	83 e8 01             	sub    $0x1,%eax
80102ab2:	a3 3c 35 11 80       	mov    %eax,0x8011353c
  if(log.committing)
80102ab7:	8b 1d 40 35 11 80    	mov    0x80113540,%ebx
80102abd:	83 c4 10             	add    $0x10,%esp
80102ac0:	85 db                	test   %ebx,%ebx
80102ac2:	75 2c                	jne    80102af0 <end_op+0x5b>
  if(log.outstanding == 0){
80102ac4:	85 c0                	test   %eax,%eax
80102ac6:	75 35                	jne    80102afd <end_op+0x68>
    log.committing = 1;
80102ac8:	c7 05 40 35 11 80 01 	movl   $0x1,0x80113540
80102acf:	00 00 00 
    do_commit = 1;
80102ad2:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102ad7:	83 ec 0c             	sub    $0xc,%esp
80102ada:	68 00 35 11 80       	push   $0x80113500
80102adf:	e8 a4 15 00 00       	call   80104088 <release>
  if(do_commit){
80102ae4:	83 c4 10             	add    $0x10,%esp
80102ae7:	85 db                	test   %ebx,%ebx
80102ae9:	75 24                	jne    80102b0f <end_op+0x7a>
}
80102aeb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102aee:	c9                   	leave  
80102aef:	c3                   	ret    
    panic("log.committing");
80102af0:	83 ec 0c             	sub    $0xc,%esp
80102af3:	68 c4 75 10 80       	push   $0x801075c4
80102af8:	e8 5f d8 ff ff       	call   8010035c <panic>
    wakeup(&log);
80102afd:	83 ec 0c             	sub    $0xc,%esp
80102b00:	68 00 35 11 80       	push   $0x80113500
80102b05:	e8 15 11 00 00       	call   80103c1f <wakeup>
80102b0a:	83 c4 10             	add    $0x10,%esp
80102b0d:	eb c8                	jmp    80102ad7 <end_op+0x42>
    commit();
80102b0f:	e8 86 fe ff ff       	call   8010299a <commit>
    acquire(&log.lock);
80102b14:	83 ec 0c             	sub    $0xc,%esp
80102b17:	68 00 35 11 80       	push   $0x80113500
80102b1c:	e8 fe 14 00 00       	call   8010401f <acquire>
    log.committing = 0;
80102b21:	c7 05 40 35 11 80 00 	movl   $0x0,0x80113540
80102b28:	00 00 00 
    wakeup(&log);
80102b2b:	c7 04 24 00 35 11 80 	movl   $0x80113500,(%esp)
80102b32:	e8 e8 10 00 00       	call   80103c1f <wakeup>
    release(&log.lock);
80102b37:	c7 04 24 00 35 11 80 	movl   $0x80113500,(%esp)
80102b3e:	e8 45 15 00 00       	call   80104088 <release>
80102b43:	83 c4 10             	add    $0x10,%esp
}
80102b46:	eb a3                	jmp    80102aeb <end_op+0x56>

80102b48 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102b48:	f3 0f 1e fb          	endbr32 
80102b4c:	55                   	push   %ebp
80102b4d:	89 e5                	mov    %esp,%ebp
80102b4f:	53                   	push   %ebx
80102b50:	83 ec 04             	sub    $0x4,%esp
80102b53:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102b56:	8b 15 48 35 11 80    	mov    0x80113548,%edx
80102b5c:	83 fa 1d             	cmp    $0x1d,%edx
80102b5f:	7f 45                	jg     80102ba6 <log_write+0x5e>
80102b61:	a1 38 35 11 80       	mov    0x80113538,%eax
80102b66:	83 e8 01             	sub    $0x1,%eax
80102b69:	39 c2                	cmp    %eax,%edx
80102b6b:	7d 39                	jge    80102ba6 <log_write+0x5e>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102b6d:	83 3d 3c 35 11 80 00 	cmpl   $0x0,0x8011353c
80102b74:	7e 3d                	jle    80102bb3 <log_write+0x6b>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102b76:	83 ec 0c             	sub    $0xc,%esp
80102b79:	68 00 35 11 80       	push   $0x80113500
80102b7e:	e8 9c 14 00 00       	call   8010401f <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102b83:	83 c4 10             	add    $0x10,%esp
80102b86:	b8 00 00 00 00       	mov    $0x0,%eax
80102b8b:	8b 15 48 35 11 80    	mov    0x80113548,%edx
80102b91:	39 c2                	cmp    %eax,%edx
80102b93:	7e 2b                	jle    80102bc0 <log_write+0x78>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102b95:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102b98:	39 0c 85 4c 35 11 80 	cmp    %ecx,-0x7feecab4(,%eax,4)
80102b9f:	74 1f                	je     80102bc0 <log_write+0x78>
  for (i = 0; i < log.lh.n; i++) {
80102ba1:	83 c0 01             	add    $0x1,%eax
80102ba4:	eb e5                	jmp    80102b8b <log_write+0x43>
    panic("too big a transaction");
80102ba6:	83 ec 0c             	sub    $0xc,%esp
80102ba9:	68 d3 75 10 80       	push   $0x801075d3
80102bae:	e8 a9 d7 ff ff       	call   8010035c <panic>
    panic("log_write outside of trans");
80102bb3:	83 ec 0c             	sub    $0xc,%esp
80102bb6:	68 e9 75 10 80       	push   $0x801075e9
80102bbb:	e8 9c d7 ff ff       	call   8010035c <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102bc0:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102bc3:	89 0c 85 4c 35 11 80 	mov    %ecx,-0x7feecab4(,%eax,4)
  if (i == log.lh.n)
80102bca:	39 c2                	cmp    %eax,%edx
80102bcc:	74 18                	je     80102be6 <log_write+0x9e>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102bce:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102bd1:	83 ec 0c             	sub    $0xc,%esp
80102bd4:	68 00 35 11 80       	push   $0x80113500
80102bd9:	e8 aa 14 00 00       	call   80104088 <release>
}
80102bde:	83 c4 10             	add    $0x10,%esp
80102be1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102be4:	c9                   	leave  
80102be5:	c3                   	ret    
    log.lh.n++;
80102be6:	83 c2 01             	add    $0x1,%edx
80102be9:	89 15 48 35 11 80    	mov    %edx,0x80113548
80102bef:	eb dd                	jmp    80102bce <log_write+0x86>

80102bf1 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102bf1:	55                   	push   %ebp
80102bf2:	89 e5                	mov    %esp,%ebp
80102bf4:	53                   	push   %ebx
80102bf5:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102bf8:	68 8a 00 00 00       	push   $0x8a
80102bfd:	68 8c a4 10 80       	push   $0x8010a48c
80102c02:	68 00 70 00 80       	push   $0x80007000
80102c07:	e8 47 15 00 00       	call   80104153 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102c0c:	83 c4 10             	add    $0x10,%esp
80102c0f:	bb 00 36 11 80       	mov    $0x80113600,%ebx
80102c14:	eb 13                	jmp    80102c29 <startothers+0x38>
80102c16:	83 ec 0c             	sub    $0xc,%esp
80102c19:	68 f4 72 10 80       	push   $0x801072f4
80102c1e:	e8 39 d7 ff ff       	call   8010035c <panic>
80102c23:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102c29:	69 05 80 3b 11 80 b0 	imul   $0xb0,0x80113b80,%eax
80102c30:	00 00 00 
80102c33:	05 00 36 11 80       	add    $0x80113600,%eax
80102c38:	39 d8                	cmp    %ebx,%eax
80102c3a:	76 58                	jbe    80102c94 <startothers+0xa3>
    if(c == mycpu())  // We've started already.
80102c3c:	e8 e2 08 00 00       	call   80103523 <mycpu>
80102c41:	39 c3                	cmp    %eax,%ebx
80102c43:	74 de                	je     80102c23 <startothers+0x32>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102c45:	e8 c0 f6 ff ff       	call   8010230a <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102c4a:	05 00 10 00 00       	add    $0x1000,%eax
80102c4f:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102c54:	c7 05 f8 6f 00 80 d8 	movl   $0x80102cd8,0x80006ff8
80102c5b:	2c 10 80 
    if (a < (void*) KERNBASE)
80102c5e:	b8 00 90 10 80       	mov    $0x80109000,%eax
80102c63:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80102c68:	76 ac                	jbe    80102c16 <startothers+0x25>
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102c6a:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102c71:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102c74:	83 ec 08             	sub    $0x8,%esp
80102c77:	68 00 70 00 00       	push   $0x7000
80102c7c:	0f b6 03             	movzbl (%ebx),%eax
80102c7f:	50                   	push   %eax
80102c80:	e8 a0 f9 ff ff       	call   80102625 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102c85:	83 c4 10             	add    $0x10,%esp
80102c88:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102c8e:	85 c0                	test   %eax,%eax
80102c90:	74 f6                	je     80102c88 <startothers+0x97>
80102c92:	eb 8f                	jmp    80102c23 <startothers+0x32>
      ;
  }
}
80102c94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102c97:	c9                   	leave  
80102c98:	c3                   	ret    

80102c99 <mpmain>:
{
80102c99:	55                   	push   %ebp
80102c9a:	89 e5                	mov    %esp,%ebp
80102c9c:	53                   	push   %ebx
80102c9d:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102ca0:	e8 de 08 00 00       	call   80103583 <cpuid>
80102ca5:	89 c3                	mov    %eax,%ebx
80102ca7:	e8 d7 08 00 00       	call   80103583 <cpuid>
80102cac:	83 ec 04             	sub    $0x4,%esp
80102caf:	53                   	push   %ebx
80102cb0:	50                   	push   %eax
80102cb1:	68 04 76 10 80       	push   $0x80107604
80102cb6:	e8 6e d9 ff ff       	call   80100629 <cprintf>
  idtinit();       // load idt register
80102cbb:	e8 0a 27 00 00       	call   801053ca <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102cc0:	e8 5e 08 00 00       	call   80103523 <mycpu>
80102cc5:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102cc7:	b8 01 00 00 00       	mov    $0x1,%eax
80102ccc:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102cd3:	e8 7c 0b 00 00       	call   80103854 <scheduler>

80102cd8 <mpenter>:
{
80102cd8:	f3 0f 1e fb          	endbr32 
80102cdc:	55                   	push   %ebp
80102cdd:	89 e5                	mov    %esp,%ebp
80102cdf:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102ce2:	e8 2d 37 00 00       	call   80106414 <switchkvm>
  seginit();
80102ce7:	e8 d8 35 00 00       	call   801062c4 <seginit>
  lapicinit();
80102cec:	e8 e0 f7 ff ff       	call   801024d1 <lapicinit>
  mpmain();
80102cf1:	e8 a3 ff ff ff       	call   80102c99 <mpmain>

80102cf6 <main>:
{
80102cf6:	f3 0f 1e fb          	endbr32 
80102cfa:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102cfe:	83 e4 f0             	and    $0xfffffff0,%esp
80102d01:	ff 71 fc             	pushl  -0x4(%ecx)
80102d04:	55                   	push   %ebp
80102d05:	89 e5                	mov    %esp,%ebp
80102d07:	51                   	push   %ecx
80102d08:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102d0b:	68 00 00 40 80       	push   $0x80400000
80102d10:	68 28 66 11 80       	push   $0x80116628
80102d15:	e8 96 f5 ff ff       	call   801022b0 <kinit1>
  kvmalloc();      // kernel page table
80102d1a:	e8 32 3c 00 00       	call   80106951 <kvmalloc>
  mpinit();        // detect other processors
80102d1f:	e8 ef 01 00 00       	call   80102f13 <mpinit>
  lapicinit();     // interrupt controller
80102d24:	e8 a8 f7 ff ff       	call   801024d1 <lapicinit>
  seginit();       // segment descriptors
80102d29:	e8 96 35 00 00       	call   801062c4 <seginit>
  picinit();       // disable pic
80102d2e:	e8 ba 02 00 00       	call   80102fed <picinit>
  ioapicinit();    // another interrupt controller
80102d33:	e8 cd f3 ff ff       	call   80102105 <ioapicinit>
  consoleinit();   // console hardware
80102d38:	e8 77 db ff ff       	call   801008b4 <consoleinit>
  uartinit();      // serial port
80102d3d:	e8 40 29 00 00       	call   80105682 <uartinit>
  pinit();         // process table
80102d42:	e8 be 07 00 00       	call   80103505 <pinit>
  tvinit();        // trap vectors
80102d47:	e8 c9 25 00 00       	call   80105315 <tvinit>
  binit();         // buffer cache
80102d4c:	e8 a3 d3 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102d51:	e8 e3 de ff ff       	call   80100c39 <fileinit>
  ideinit();       // disk 
80102d56:	e8 ac f1 ff ff       	call   80101f07 <ideinit>
  helloinit();
80102d5b:	e8 78 3e 00 00       	call   80106bd8 <helloinit>
  zeroinit();
80102d60:	e8 d4 3e 00 00       	call   80106c39 <zeroinit>
  nullinit();
80102d65:	e8 f6 3e 00 00       	call   80106c60 <nullinit>
  ticksinit();
80102d6a:	e8 f9 42 00 00       	call   80107068 <ticksinit>
  startothers();   // start other processors
80102d6f:	e8 7d fe ff ff       	call   80102bf1 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102d74:	83 c4 08             	add    $0x8,%esp
80102d77:	68 00 00 00 8e       	push   $0x8e000000
80102d7c:	68 00 00 40 80       	push   $0x80400000
80102d81:	e8 60 f5 ff ff       	call   801022e6 <kinit2>
  userinit();      // first user process
80102d86:	e8 3f 08 00 00       	call   801035ca <userinit>
  mpmain();        // finish this processor's setup
80102d8b:	e8 09 ff ff ff       	call   80102c99 <mpmain>

80102d90 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102d90:	55                   	push   %ebp
80102d91:	89 e5                	mov    %esp,%ebp
80102d93:	56                   	push   %esi
80102d94:	53                   	push   %ebx
80102d95:	89 c6                	mov    %eax,%esi
  int i, sum;

  sum = 0;
80102d97:	b8 00 00 00 00       	mov    $0x0,%eax
  for(i=0; i<len; i++)
80102d9c:	b9 00 00 00 00       	mov    $0x0,%ecx
80102da1:	39 d1                	cmp    %edx,%ecx
80102da3:	7d 0b                	jge    80102db0 <sum+0x20>
    sum += addr[i];
80102da5:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
80102da9:	01 d8                	add    %ebx,%eax
  for(i=0; i<len; i++)
80102dab:	83 c1 01             	add    $0x1,%ecx
80102dae:	eb f1                	jmp    80102da1 <sum+0x11>
  return sum;
}
80102db0:	5b                   	pop    %ebx
80102db1:	5e                   	pop    %esi
80102db2:	5d                   	pop    %ebp
80102db3:	c3                   	ret    

80102db4 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102db4:	55                   	push   %ebp
80102db5:	89 e5                	mov    %esp,%ebp
80102db7:	56                   	push   %esi
80102db8:	53                   	push   %ebx
}

// Convert physical address to kernel virtual address
static inline void *P2V(uint a) {
    extern void panic(char*) __attribute__((noreturn));
    if (a > KERNBASE)
80102db9:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80102dbe:	77 0b                	ja     80102dcb <mpsearch1+0x17>
        panic("P2V on address > KERNBASE");
    return (char*)a + KERNBASE;
80102dc0:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
80102dc6:	8d 34 13             	lea    (%ebx,%edx,1),%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102dc9:	eb 10                	jmp    80102ddb <mpsearch1+0x27>
        panic("P2V on address > KERNBASE");
80102dcb:	83 ec 0c             	sub    $0xc,%esp
80102dce:	68 18 76 10 80       	push   $0x80107618
80102dd3:	e8 84 d5 ff ff       	call   8010035c <panic>
80102dd8:	83 c3 10             	add    $0x10,%ebx
80102ddb:	39 f3                	cmp    %esi,%ebx
80102ddd:	73 29                	jae    80102e08 <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102ddf:	83 ec 04             	sub    $0x4,%esp
80102de2:	6a 04                	push   $0x4
80102de4:	68 32 76 10 80       	push   $0x80107632
80102de9:	53                   	push   %ebx
80102dea:	e8 2b 13 00 00       	call   8010411a <memcmp>
80102def:	83 c4 10             	add    $0x10,%esp
80102df2:	85 c0                	test   %eax,%eax
80102df4:	75 e2                	jne    80102dd8 <mpsearch1+0x24>
80102df6:	ba 10 00 00 00       	mov    $0x10,%edx
80102dfb:	89 d8                	mov    %ebx,%eax
80102dfd:	e8 8e ff ff ff       	call   80102d90 <sum>
80102e02:	84 c0                	test   %al,%al
80102e04:	75 d2                	jne    80102dd8 <mpsearch1+0x24>
80102e06:	eb 05                	jmp    80102e0d <mpsearch1+0x59>
      return (struct mp*)p;
  return 0;
80102e08:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102e0d:	89 d8                	mov    %ebx,%eax
80102e0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102e12:	5b                   	pop    %ebx
80102e13:	5e                   	pop    %esi
80102e14:	5d                   	pop    %ebp
80102e15:	c3                   	ret    

80102e16 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102e16:	55                   	push   %ebp
80102e17:	89 e5                	mov    %esp,%ebp
80102e19:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102e1c:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102e23:	c1 e0 08             	shl    $0x8,%eax
80102e26:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102e2d:	09 d0                	or     %edx,%eax
80102e2f:	c1 e0 04             	shl    $0x4,%eax
80102e32:	74 1f                	je     80102e53 <mpsearch+0x3d>
    if((mp = mpsearch1(p, 1024)))
80102e34:	ba 00 04 00 00       	mov    $0x400,%edx
80102e39:	e8 76 ff ff ff       	call   80102db4 <mpsearch1>
80102e3e:	85 c0                	test   %eax,%eax
80102e40:	75 0f                	jne    80102e51 <mpsearch+0x3b>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102e42:	ba 00 00 01 00       	mov    $0x10000,%edx
80102e47:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102e4c:	e8 63 ff ff ff       	call   80102db4 <mpsearch1>
}
80102e51:	c9                   	leave  
80102e52:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102e53:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102e5a:	c1 e0 08             	shl    $0x8,%eax
80102e5d:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102e64:	09 d0                	or     %edx,%eax
80102e66:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102e69:	2d 00 04 00 00       	sub    $0x400,%eax
80102e6e:	ba 00 04 00 00       	mov    $0x400,%edx
80102e73:	e8 3c ff ff ff       	call   80102db4 <mpsearch1>
80102e78:	85 c0                	test   %eax,%eax
80102e7a:	75 d5                	jne    80102e51 <mpsearch+0x3b>
80102e7c:	eb c4                	jmp    80102e42 <mpsearch+0x2c>

80102e7e <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102e7e:	55                   	push   %ebp
80102e7f:	89 e5                	mov    %esp,%ebp
80102e81:	57                   	push   %edi
80102e82:	56                   	push   %esi
80102e83:	53                   	push   %ebx
80102e84:	83 ec 0c             	sub    $0xc,%esp
80102e87:	89 c7                	mov    %eax,%edi
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102e89:	e8 88 ff ff ff       	call   80102e16 <mpsearch>
80102e8e:	89 c6                	mov    %eax,%esi
80102e90:	85 c0                	test   %eax,%eax
80102e92:	74 66                	je     80102efa <mpconfig+0x7c>
80102e94:	8b 58 04             	mov    0x4(%eax),%ebx
80102e97:	85 db                	test   %ebx,%ebx
80102e99:	74 48                	je     80102ee3 <mpconfig+0x65>
    if (a > KERNBASE)
80102e9b:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80102ea1:	77 4a                	ja     80102eed <mpconfig+0x6f>
    return (char*)a + KERNBASE;
80102ea3:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
80102ea9:	83 ec 04             	sub    $0x4,%esp
80102eac:	6a 04                	push   $0x4
80102eae:	68 37 76 10 80       	push   $0x80107637
80102eb3:	53                   	push   %ebx
80102eb4:	e8 61 12 00 00       	call   8010411a <memcmp>
80102eb9:	83 c4 10             	add    $0x10,%esp
80102ebc:	85 c0                	test   %eax,%eax
80102ebe:	75 3e                	jne    80102efe <mpconfig+0x80>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102ec0:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
80102ec4:	3c 01                	cmp    $0x1,%al
80102ec6:	0f 95 c2             	setne  %dl
80102ec9:	3c 04                	cmp    $0x4,%al
80102ecb:	0f 95 c0             	setne  %al
80102ece:	84 c2                	test   %al,%dl
80102ed0:	75 33                	jne    80102f05 <mpconfig+0x87>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102ed2:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
80102ed6:	89 d8                	mov    %ebx,%eax
80102ed8:	e8 b3 fe ff ff       	call   80102d90 <sum>
80102edd:	84 c0                	test   %al,%al
80102edf:	75 2b                	jne    80102f0c <mpconfig+0x8e>
    return 0;
  *pmp = mp;
80102ee1:	89 37                	mov    %esi,(%edi)
  return conf;
}
80102ee3:	89 d8                	mov    %ebx,%eax
80102ee5:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102ee8:	5b                   	pop    %ebx
80102ee9:	5e                   	pop    %esi
80102eea:	5f                   	pop    %edi
80102eeb:	5d                   	pop    %ebp
80102eec:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80102eed:	83 ec 0c             	sub    $0xc,%esp
80102ef0:	68 18 76 10 80       	push   $0x80107618
80102ef5:	e8 62 d4 ff ff       	call   8010035c <panic>
    return 0;
80102efa:	89 c3                	mov    %eax,%ebx
80102efc:	eb e5                	jmp    80102ee3 <mpconfig+0x65>
    return 0;
80102efe:	bb 00 00 00 00       	mov    $0x0,%ebx
80102f03:	eb de                	jmp    80102ee3 <mpconfig+0x65>
    return 0;
80102f05:	bb 00 00 00 00       	mov    $0x0,%ebx
80102f0a:	eb d7                	jmp    80102ee3 <mpconfig+0x65>
    return 0;
80102f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
80102f11:	eb d0                	jmp    80102ee3 <mpconfig+0x65>

80102f13 <mpinit>:

void
mpinit(void)
{
80102f13:	f3 0f 1e fb          	endbr32 
80102f17:	55                   	push   %ebp
80102f18:	89 e5                	mov    %esp,%ebp
80102f1a:	57                   	push   %edi
80102f1b:	56                   	push   %esi
80102f1c:	53                   	push   %ebx
80102f1d:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102f20:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102f23:	e8 56 ff ff ff       	call   80102e7e <mpconfig>
80102f28:	85 c0                	test   %eax,%eax
80102f2a:	74 19                	je     80102f45 <mpinit+0x32>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102f2c:	8b 50 24             	mov    0x24(%eax),%edx
80102f2f:	89 15 fc 34 11 80    	mov    %edx,0x801134fc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102f35:	8d 50 2c             	lea    0x2c(%eax),%edx
80102f38:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102f3c:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102f3e:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102f43:	eb 20                	jmp    80102f65 <mpinit+0x52>
    panic("Expect to run on an SMP");
80102f45:	83 ec 0c             	sub    $0xc,%esp
80102f48:	68 3c 76 10 80       	push   $0x8010763c
80102f4d:	e8 0a d4 ff ff       	call   8010035c <panic>
    switch(*p){
80102f52:	bb 00 00 00 00       	mov    $0x0,%ebx
80102f57:	eb 0c                	jmp    80102f65 <mpinit+0x52>
80102f59:	83 e8 03             	sub    $0x3,%eax
80102f5c:	3c 01                	cmp    $0x1,%al
80102f5e:	76 1a                	jbe    80102f7a <mpinit+0x67>
80102f60:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102f65:	39 ca                	cmp    %ecx,%edx
80102f67:	73 4d                	jae    80102fb6 <mpinit+0xa3>
    switch(*p){
80102f69:	0f b6 02             	movzbl (%edx),%eax
80102f6c:	3c 02                	cmp    $0x2,%al
80102f6e:	74 38                	je     80102fa8 <mpinit+0x95>
80102f70:	77 e7                	ja     80102f59 <mpinit+0x46>
80102f72:	84 c0                	test   %al,%al
80102f74:	74 09                	je     80102f7f <mpinit+0x6c>
80102f76:	3c 01                	cmp    $0x1,%al
80102f78:	75 d8                	jne    80102f52 <mpinit+0x3f>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102f7a:	83 c2 08             	add    $0x8,%edx
      continue;
80102f7d:	eb e6                	jmp    80102f65 <mpinit+0x52>
      if(ncpu < NCPU) {
80102f7f:	8b 35 80 3b 11 80    	mov    0x80113b80,%esi
80102f85:	83 fe 07             	cmp    $0x7,%esi
80102f88:	7f 19                	jg     80102fa3 <mpinit+0x90>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102f8a:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102f8e:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102f94:	88 87 00 36 11 80    	mov    %al,-0x7feeca00(%edi)
        ncpu++;
80102f9a:	83 c6 01             	add    $0x1,%esi
80102f9d:	89 35 80 3b 11 80    	mov    %esi,0x80113b80
      p += sizeof(struct mpproc);
80102fa3:	83 c2 14             	add    $0x14,%edx
      continue;
80102fa6:	eb bd                	jmp    80102f65 <mpinit+0x52>
      ioapicid = ioapic->apicno;
80102fa8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102fac:	a2 e0 35 11 80       	mov    %al,0x801135e0
      p += sizeof(struct mpioapic);
80102fb1:	83 c2 08             	add    $0x8,%edx
      continue;
80102fb4:	eb af                	jmp    80102f65 <mpinit+0x52>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102fb6:	85 db                	test   %ebx,%ebx
80102fb8:	74 26                	je     80102fe0 <mpinit+0xcd>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102fba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102fbd:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102fc1:	74 15                	je     80102fd8 <mpinit+0xc5>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fc3:	b8 70 00 00 00       	mov    $0x70,%eax
80102fc8:	ba 22 00 00 00       	mov    $0x22,%edx
80102fcd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102fce:	ba 23 00 00 00       	mov    $0x23,%edx
80102fd3:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102fd4:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fd7:	ee                   	out    %al,(%dx)
  }
}
80102fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102fdb:	5b                   	pop    %ebx
80102fdc:	5e                   	pop    %esi
80102fdd:	5f                   	pop    %edi
80102fde:	5d                   	pop    %ebp
80102fdf:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102fe0:	83 ec 0c             	sub    $0xc,%esp
80102fe3:	68 54 76 10 80       	push   $0x80107654
80102fe8:	e8 6f d3 ff ff       	call   8010035c <panic>

80102fed <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102fed:	f3 0f 1e fb          	endbr32 
80102ff1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ff6:	ba 21 00 00 00       	mov    $0x21,%edx
80102ffb:	ee                   	out    %al,(%dx)
80102ffc:	ba a1 00 00 00       	mov    $0xa1,%edx
80103001:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103002:	c3                   	ret    

80103003 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103003:	f3 0f 1e fb          	endbr32 
80103007:	55                   	push   %ebp
80103008:	89 e5                	mov    %esp,%ebp
8010300a:	57                   	push   %edi
8010300b:	56                   	push   %esi
8010300c:	53                   	push   %ebx
8010300d:	83 ec 0c             	sub    $0xc,%esp
80103010:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103013:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80103016:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010301c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103022:	e8 30 dc ff ff       	call   80100c57 <filealloc>
80103027:	89 03                	mov    %eax,(%ebx)
80103029:	85 c0                	test   %eax,%eax
8010302b:	0f 84 88 00 00 00    	je     801030b9 <pipealloc+0xb6>
80103031:	e8 21 dc ff ff       	call   80100c57 <filealloc>
80103036:	89 06                	mov    %eax,(%esi)
80103038:	85 c0                	test   %eax,%eax
8010303a:	74 7d                	je     801030b9 <pipealloc+0xb6>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010303c:	e8 c9 f2 ff ff       	call   8010230a <kalloc>
80103041:	89 c7                	mov    %eax,%edi
80103043:	85 c0                	test   %eax,%eax
80103045:	74 72                	je     801030b9 <pipealloc+0xb6>
    goto bad;
  p->readopen = 1;
80103047:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010304e:	00 00 00 
  p->writeopen = 1;
80103051:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103058:	00 00 00 
  p->nwrite = 0;
8010305b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103062:	00 00 00 
  p->nread = 0;
80103065:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010306c:	00 00 00 
  initlock(&p->lock, "pipe");
8010306f:	83 ec 08             	sub    $0x8,%esp
80103072:	68 73 76 10 80       	push   $0x80107673
80103077:	50                   	push   %eax
80103078:	e8 52 0e 00 00       	call   80103ecf <initlock>
  (*f0)->type = FD_PIPE;
8010307d:	8b 03                	mov    (%ebx),%eax
8010307f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103085:	8b 03                	mov    (%ebx),%eax
80103087:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010308b:	8b 03                	mov    (%ebx),%eax
8010308d:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103091:	8b 03                	mov    (%ebx),%eax
80103093:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103096:	8b 06                	mov    (%esi),%eax
80103098:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010309e:	8b 06                	mov    (%esi),%eax
801030a0:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801030a4:	8b 06                	mov    (%esi),%eax
801030a6:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801030aa:	8b 06                	mov    (%esi),%eax
801030ac:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
801030af:	83 c4 10             	add    $0x10,%esp
801030b2:	b8 00 00 00 00       	mov    $0x0,%eax
801030b7:	eb 29                	jmp    801030e2 <pipealloc+0xdf>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
801030b9:	8b 03                	mov    (%ebx),%eax
801030bb:	85 c0                	test   %eax,%eax
801030bd:	74 0c                	je     801030cb <pipealloc+0xc8>
    fileclose(*f0);
801030bf:	83 ec 0c             	sub    $0xc,%esp
801030c2:	50                   	push   %eax
801030c3:	e8 3d dc ff ff       	call   80100d05 <fileclose>
801030c8:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801030cb:	8b 06                	mov    (%esi),%eax
801030cd:	85 c0                	test   %eax,%eax
801030cf:	74 19                	je     801030ea <pipealloc+0xe7>
    fileclose(*f1);
801030d1:	83 ec 0c             	sub    $0xc,%esp
801030d4:	50                   	push   %eax
801030d5:	e8 2b dc ff ff       	call   80100d05 <fileclose>
801030da:	83 c4 10             	add    $0x10,%esp
  return -1;
801030dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801030e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030e5:	5b                   	pop    %ebx
801030e6:	5e                   	pop    %esi
801030e7:	5f                   	pop    %edi
801030e8:	5d                   	pop    %ebp
801030e9:	c3                   	ret    
  return -1;
801030ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801030ef:	eb f1                	jmp    801030e2 <pipealloc+0xdf>

801030f1 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801030f1:	f3 0f 1e fb          	endbr32 
801030f5:	55                   	push   %ebp
801030f6:	89 e5                	mov    %esp,%ebp
801030f8:	53                   	push   %ebx
801030f9:	83 ec 10             	sub    $0x10,%esp
801030fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
801030ff:	53                   	push   %ebx
80103100:	e8 1a 0f 00 00       	call   8010401f <acquire>
  if(writable){
80103105:	83 c4 10             	add    $0x10,%esp
80103108:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010310c:	74 3f                	je     8010314d <pipeclose+0x5c>
    p->writeopen = 0;
8010310e:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80103115:	00 00 00 
    wakeup(&p->nread);
80103118:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010311e:	83 ec 0c             	sub    $0xc,%esp
80103121:	50                   	push   %eax
80103122:	e8 f8 0a 00 00       	call   80103c1f <wakeup>
80103127:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010312a:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103131:	75 09                	jne    8010313c <pipeclose+0x4b>
80103133:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
8010313a:	74 2f                	je     8010316b <pipeclose+0x7a>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010313c:	83 ec 0c             	sub    $0xc,%esp
8010313f:	53                   	push   %ebx
80103140:	e8 43 0f 00 00       	call   80104088 <release>
80103145:	83 c4 10             	add    $0x10,%esp
}
80103148:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010314b:	c9                   	leave  
8010314c:	c3                   	ret    
    p->readopen = 0;
8010314d:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103154:	00 00 00 
    wakeup(&p->nwrite);
80103157:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010315d:	83 ec 0c             	sub    $0xc,%esp
80103160:	50                   	push   %eax
80103161:	e8 b9 0a 00 00       	call   80103c1f <wakeup>
80103166:	83 c4 10             	add    $0x10,%esp
80103169:	eb bf                	jmp    8010312a <pipeclose+0x39>
    release(&p->lock);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	53                   	push   %ebx
8010316f:	e8 14 0f 00 00       	call   80104088 <release>
    kfree((char*)p);
80103174:	89 1c 24             	mov    %ebx,(%esp)
80103177:	e8 41 f0 ff ff       	call   801021bd <kfree>
8010317c:	83 c4 10             	add    $0x10,%esp
8010317f:	eb c7                	jmp    80103148 <pipeclose+0x57>

80103181 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103181:	f3 0f 1e fb          	endbr32 
80103185:	55                   	push   %ebp
80103186:	89 e5                	mov    %esp,%ebp
80103188:	57                   	push   %edi
80103189:	56                   	push   %esi
8010318a:	53                   	push   %ebx
8010318b:	83 ec 18             	sub    $0x18,%esp
8010318e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103191:	89 de                	mov    %ebx,%esi
80103193:	53                   	push   %ebx
80103194:	e8 86 0e 00 00       	call   8010401f <acquire>
  for(i = 0; i < n; i++){
80103199:	83 c4 10             	add    $0x10,%esp
8010319c:	bf 00 00 00 00       	mov    $0x0,%edi
801031a1:	3b 7d 10             	cmp    0x10(%ebp),%edi
801031a4:	7c 41                	jl     801031e7 <pipewrite+0x66>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801031a6:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801031ac:	83 ec 0c             	sub    $0xc,%esp
801031af:	50                   	push   %eax
801031b0:	e8 6a 0a 00 00       	call   80103c1f <wakeup>
  release(&p->lock);
801031b5:	89 1c 24             	mov    %ebx,(%esp)
801031b8:	e8 cb 0e 00 00       	call   80104088 <release>
  return n;
801031bd:	83 c4 10             	add    $0x10,%esp
801031c0:	8b 45 10             	mov    0x10(%ebp),%eax
801031c3:	eb 5c                	jmp    80103221 <pipewrite+0xa0>
      wakeup(&p->nread);
801031c5:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801031cb:	83 ec 0c             	sub    $0xc,%esp
801031ce:	50                   	push   %eax
801031cf:	e8 4b 0a 00 00       	call   80103c1f <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801031d4:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801031da:	83 c4 08             	add    $0x8,%esp
801031dd:	56                   	push   %esi
801031de:	50                   	push   %eax
801031df:	e8 cb 08 00 00       	call   80103aaf <sleep>
801031e4:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801031e7:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
801031ed:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801031f3:	05 00 02 00 00       	add    $0x200,%eax
801031f8:	39 c2                	cmp    %eax,%edx
801031fa:	75 2d                	jne    80103229 <pipewrite+0xa8>
      if(p->readopen == 0 || myproc()->killed){
801031fc:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103203:	74 0b                	je     80103210 <pipewrite+0x8f>
80103205:	e8 98 03 00 00       	call   801035a2 <myproc>
8010320a:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010320e:	74 b5                	je     801031c5 <pipewrite+0x44>
        release(&p->lock);
80103210:	83 ec 0c             	sub    $0xc,%esp
80103213:	53                   	push   %ebx
80103214:	e8 6f 0e 00 00       	call   80104088 <release>
        return -1;
80103219:	83 c4 10             	add    $0x10,%esp
8010321c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103221:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103224:	5b                   	pop    %ebx
80103225:	5e                   	pop    %esi
80103226:	5f                   	pop    %edi
80103227:	5d                   	pop    %ebp
80103228:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103229:	8d 42 01             	lea    0x1(%edx),%eax
8010322c:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80103232:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103238:	8b 45 0c             	mov    0xc(%ebp),%eax
8010323b:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
8010323f:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103243:	83 c7 01             	add    $0x1,%edi
80103246:	e9 56 ff ff ff       	jmp    801031a1 <pipewrite+0x20>

8010324b <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010324b:	f3 0f 1e fb          	endbr32 
8010324f:	55                   	push   %ebp
80103250:	89 e5                	mov    %esp,%ebp
80103252:	57                   	push   %edi
80103253:	56                   	push   %esi
80103254:	53                   	push   %ebx
80103255:	83 ec 18             	sub    $0x18,%esp
80103258:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010325b:	89 df                	mov    %ebx,%edi
8010325d:	53                   	push   %ebx
8010325e:	e8 bc 0d 00 00       	call   8010401f <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103263:	83 c4 10             	add    $0x10,%esp
80103266:	eb 13                	jmp    8010327b <piperead+0x30>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103268:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010326e:	83 ec 08             	sub    $0x8,%esp
80103271:	57                   	push   %edi
80103272:	50                   	push   %eax
80103273:	e8 37 08 00 00       	call   80103aaf <sleep>
80103278:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010327b:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103281:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80103287:	75 28                	jne    801032b1 <piperead+0x66>
80103289:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
8010328f:	85 f6                	test   %esi,%esi
80103291:	74 23                	je     801032b6 <piperead+0x6b>
    if(myproc()->killed){
80103293:	e8 0a 03 00 00       	call   801035a2 <myproc>
80103298:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010329c:	74 ca                	je     80103268 <piperead+0x1d>
      release(&p->lock);
8010329e:	83 ec 0c             	sub    $0xc,%esp
801032a1:	53                   	push   %ebx
801032a2:	e8 e1 0d 00 00       	call   80104088 <release>
      return -1;
801032a7:	83 c4 10             	add    $0x10,%esp
801032aa:	be ff ff ff ff       	mov    $0xffffffff,%esi
801032af:	eb 50                	jmp    80103301 <piperead+0xb6>
801032b1:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801032b6:	3b 75 10             	cmp    0x10(%ebp),%esi
801032b9:	7d 2c                	jge    801032e7 <piperead+0x9c>
    if(p->nread == p->nwrite)
801032bb:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801032c1:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
801032c7:	74 1e                	je     801032e7 <piperead+0x9c>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801032c9:	8d 50 01             	lea    0x1(%eax),%edx
801032cc:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
801032d2:	25 ff 01 00 00       	and    $0x1ff,%eax
801032d7:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
801032dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801032df:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801032e2:	83 c6 01             	add    $0x1,%esi
801032e5:	eb cf                	jmp    801032b6 <piperead+0x6b>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801032e7:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801032ed:	83 ec 0c             	sub    $0xc,%esp
801032f0:	50                   	push   %eax
801032f1:	e8 29 09 00 00       	call   80103c1f <wakeup>
  release(&p->lock);
801032f6:	89 1c 24             	mov    %ebx,(%esp)
801032f9:	e8 8a 0d 00 00       	call   80104088 <release>
  return i;
801032fe:	83 c4 10             	add    $0x10,%esp
}
80103301:	89 f0                	mov    %esi,%eax
80103303:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103306:	5b                   	pop    %ebx
80103307:	5e                   	pop    %esi
80103308:	5f                   	pop    %edi
80103309:	5d                   	pop    %ebp
8010330a:	c3                   	ret    

8010330b <wakeup1>:
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010330b:	ba d4 3b 11 80       	mov    $0x80113bd4,%edx
80103310:	eb 0d                	jmp    8010331f <wakeup1+0x14>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
80103312:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103319:	81 c2 88 00 00 00    	add    $0x88,%edx
8010331f:	81 fa d4 5d 11 80    	cmp    $0x80115dd4,%edx
80103325:	73 0d                	jae    80103334 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
80103327:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010332b:	75 ec                	jne    80103319 <wakeup1+0xe>
8010332d:	39 42 20             	cmp    %eax,0x20(%edx)
80103330:	75 e7                	jne    80103319 <wakeup1+0xe>
80103332:	eb de                	jmp    80103312 <wakeup1+0x7>
}
80103334:	c3                   	ret    

80103335 <allocproc>:
{
80103335:	55                   	push   %ebp
80103336:	89 e5                	mov    %esp,%ebp
80103338:	53                   	push   %ebx
80103339:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
8010333c:	68 a0 3b 11 80       	push   $0x80113ba0
80103341:	e8 d9 0c 00 00       	call   8010401f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103346:	83 c4 10             	add    $0x10,%esp
80103349:	bb d4 3b 11 80       	mov    $0x80113bd4,%ebx
8010334e:	81 fb d4 5d 11 80    	cmp    $0x80115dd4,%ebx
80103354:	0f 83 88 00 00 00    	jae    801033e2 <allocproc+0xad>
    p->priority = 0;
8010335a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
80103361:	00 00 00 
    if(p->state == UNUSED)
80103364:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103368:	74 08                	je     80103372 <allocproc+0x3d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010336a:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103370:	eb dc                	jmp    8010334e <allocproc+0x19>
  p->state = EMBRYO;
80103372:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103379:	a1 04 a0 10 80       	mov    0x8010a004,%eax
8010337e:	8d 50 01             	lea    0x1(%eax),%edx
80103381:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80103387:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
8010338a:	83 ec 0c             	sub    $0xc,%esp
8010338d:	68 a0 3b 11 80       	push   $0x80113ba0
80103392:	e8 f1 0c 00 00       	call   80104088 <release>
  if((p->kstack = kalloc()) == 0){
80103397:	e8 6e ef ff ff       	call   8010230a <kalloc>
8010339c:	89 43 08             	mov    %eax,0x8(%ebx)
8010339f:	83 c4 10             	add    $0x10,%esp
801033a2:	85 c0                	test   %eax,%eax
801033a4:	74 53                	je     801033f9 <allocproc+0xc4>
  sp -= sizeof *p->tf;
801033a6:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801033ac:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801033af:	c7 80 b0 0f 00 00 0a 	movl   $0x8010530a,0xfb0(%eax)
801033b6:	53 10 80 
  sp -= sizeof *p->context;
801033b9:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
801033be:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801033c1:	83 ec 04             	sub    $0x4,%esp
801033c4:	6a 14                	push   $0x14
801033c6:	6a 00                	push   $0x0
801033c8:	50                   	push   %eax
801033c9:	e8 05 0d 00 00       	call   801040d3 <memset>
  p->context->eip = (uint)forkret;
801033ce:	8b 43 1c             	mov    0x1c(%ebx),%eax
801033d1:	c7 40 10 04 34 10 80 	movl   $0x80103404,0x10(%eax)
  return p;
801033d8:	83 c4 10             	add    $0x10,%esp
}
801033db:	89 d8                	mov    %ebx,%eax
801033dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801033e0:	c9                   	leave  
801033e1:	c3                   	ret    
  release(&ptable.lock);
801033e2:	83 ec 0c             	sub    $0xc,%esp
801033e5:	68 a0 3b 11 80       	push   $0x80113ba0
801033ea:	e8 99 0c 00 00       	call   80104088 <release>
  return 0;
801033ef:	83 c4 10             	add    $0x10,%esp
801033f2:	bb 00 00 00 00       	mov    $0x0,%ebx
801033f7:	eb e2                	jmp    801033db <allocproc+0xa6>
    p->state = UNUSED;
801033f9:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103400:	89 c3                	mov    %eax,%ebx
80103402:	eb d7                	jmp    801033db <allocproc+0xa6>

80103404 <forkret>:
{
80103404:	f3 0f 1e fb          	endbr32 
80103408:	55                   	push   %ebp
80103409:	89 e5                	mov    %esp,%ebp
8010340b:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
8010340e:	68 a0 3b 11 80       	push   $0x80113ba0
80103413:	e8 70 0c 00 00       	call   80104088 <release>
  if (first) {
80103418:	83 c4 10             	add    $0x10,%esp
8010341b:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103422:	75 02                	jne    80103426 <forkret+0x22>
}
80103424:	c9                   	leave  
80103425:	c3                   	ret    
    first = 0;
80103426:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
8010342d:	00 00 00 
    iinit(ROOTDEV);
80103430:	83 ec 0c             	sub    $0xc,%esp
80103433:	6a 01                	push   $0x1
80103435:	e8 8f df ff ff       	call   801013c9 <iinit>
    initlog(ROOTDEV);
8010343a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103441:	e8 84 f5 ff ff       	call   801029ca <initlog>
80103446:	83 c4 10             	add    $0x10,%esp
}
80103449:	eb d9                	jmp    80103424 <forkret+0x20>

8010344b <proc_ps>:
{
8010344b:	f3 0f 1e fb          	endbr32 
8010344f:	55                   	push   %ebp
80103450:	89 e5                	mov    %esp,%ebp
80103452:	57                   	push   %edi
80103453:	56                   	push   %esi
80103454:	53                   	push   %ebx
80103455:	83 ec 28             	sub    $0x28,%esp
  int currentTicks = ticks;
80103458:	a1 20 66 11 80       	mov    0x80116620,%eax
8010345d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  acquire(&ptable.lock);
80103460:	68 a0 3b 11 80       	push   $0x80113ba0
80103465:	e8 b5 0b 00 00       	call   8010401f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010346a:	83 c4 10             	add    $0x10,%esp
  int procInfoArrayIndex = 0;
8010346d:	bf 00 00 00 00       	mov    $0x0,%edi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103472:	bb d4 3b 11 80       	mov    $0x80113bd4,%ebx
80103477:	eb 11                	jmp    8010348a <proc_ps+0x3f>
      int cpuPercent = 0;
80103479:	ba 00 00 00 00       	mov    $0x0,%edx
      arrayOfProcInfo[procInfoArrayIndex].cpuPercent = cpuPercent;
8010347e:	89 56 08             	mov    %edx,0x8(%esi)
      ++procInfoArrayIndex;
80103481:	83 c7 01             	add    $0x1,%edi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103484:	81 c3 88 00 00 00    	add    $0x88,%ebx
8010348a:	81 fb d4 5d 11 80    	cmp    $0x80115dd4,%ebx
80103490:	73 5c                	jae    801034ee <proc_ps+0xa3>
    if(p->state != UNUSED) {
80103492:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103496:	74 ec                	je     80103484 <proc_ps+0x39>
      safestrcpy(arrayOfProcInfo[procInfoArrayIndex].name, p->name,   
80103498:	8d 53 6c             	lea    0x6c(%ebx),%edx
8010349b:	6b f7 1c             	imul   $0x1c,%edi,%esi
8010349e:	03 75 0c             	add    0xc(%ebp),%esi
801034a1:	8d 46 0c             	lea    0xc(%esi),%eax
801034a4:	83 ec 04             	sub    $0x4,%esp
801034a7:	6a 10                	push   $0x10
801034a9:	52                   	push   %edx
801034aa:	50                   	push   %eax
801034ab:	e8 a3 0d 00 00       	call   80104253 <safestrcpy>
      arrayOfProcInfo[procInfoArrayIndex].pid = p->pid;
801034b0:	8b 43 10             	mov    0x10(%ebx),%eax
801034b3:	89 46 04             	mov    %eax,0x4(%esi)
      arrayOfProcInfo[procInfoArrayIndex].state = p->state;
801034b6:	8b 43 0c             	mov    0xc(%ebx),%eax
801034b9:	89 06                	mov    %eax,(%esi)
      int elapsedTicks = currentTicks - p->ticksAtStart;
801034bb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801034be:	2b 4b 7c             	sub    0x7c(%ebx),%ecx
      if(elapsedTicks > 0 && 1 < p->ticksScheduled) {
801034c1:	83 c4 10             	add    $0x10,%esp
801034c4:	85 c9                	test   %ecx,%ecx
801034c6:	7e b1                	jle    80103479 <proc_ps+0x2e>
801034c8:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
801034ce:	83 f8 01             	cmp    $0x1,%eax
801034d1:	7e 14                	jle    801034e7 <proc_ps+0x9c>
        cpuPercent = (p->ticksScheduled * 100) / elapsedTicks;
801034d3:	6b c0 64             	imul   $0x64,%eax,%eax
801034d6:	99                   	cltd   
801034d7:	f7 f9                	idiv   %ecx
801034d9:	89 c2                	mov    %eax,%edx
        if(100 < cpuPercent) {
801034db:	83 f8 64             	cmp    $0x64,%eax
801034de:	7e 9e                	jle    8010347e <proc_ps+0x33>
          cpuPercent = 100;
801034e0:	ba 64 00 00 00       	mov    $0x64,%edx
801034e5:	eb 97                	jmp    8010347e <proc_ps+0x33>
      int cpuPercent = 0;
801034e7:	ba 00 00 00 00       	mov    $0x0,%edx
801034ec:	eb 90                	jmp    8010347e <proc_ps+0x33>
  release(&ptable.lock);
801034ee:	83 ec 0c             	sub    $0xc,%esp
801034f1:	68 a0 3b 11 80       	push   $0x80113ba0
801034f6:	e8 8d 0b 00 00       	call   80104088 <release>
}
801034fb:	89 f8                	mov    %edi,%eax
801034fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103500:	5b                   	pop    %ebx
80103501:	5e                   	pop    %esi
80103502:	5f                   	pop    %edi
80103503:	5d                   	pop    %ebp
80103504:	c3                   	ret    

80103505 <pinit>:
{
80103505:	f3 0f 1e fb          	endbr32 
80103509:	55                   	push   %ebp
8010350a:	89 e5                	mov    %esp,%ebp
8010350c:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
8010350f:	68 78 76 10 80       	push   $0x80107678
80103514:	68 a0 3b 11 80       	push   $0x80113ba0
80103519:	e8 b1 09 00 00       	call   80103ecf <initlock>
}
8010351e:	83 c4 10             	add    $0x10,%esp
80103521:	c9                   	leave  
80103522:	c3                   	ret    

80103523 <mycpu>:
{
80103523:	f3 0f 1e fb          	endbr32 
80103527:	55                   	push   %ebp
80103528:	89 e5                	mov    %esp,%ebp
8010352a:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010352d:	9c                   	pushf  
8010352e:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010352f:	f6 c4 02             	test   $0x2,%ah
80103532:	75 28                	jne    8010355c <mycpu+0x39>
  apicid = lapicid();
80103534:	e8 a8 f0 ff ff       	call   801025e1 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103539:	ba 00 00 00 00       	mov    $0x0,%edx
8010353e:	39 15 80 3b 11 80    	cmp    %edx,0x80113b80
80103544:	7e 30                	jle    80103576 <mycpu+0x53>
    if (cpus[i].apicid == apicid)
80103546:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
8010354c:	0f b6 89 00 36 11 80 	movzbl -0x7feeca00(%ecx),%ecx
80103553:	39 c1                	cmp    %eax,%ecx
80103555:	74 12                	je     80103569 <mycpu+0x46>
  for (i = 0; i < ncpu; ++i) {
80103557:	83 c2 01             	add    $0x1,%edx
8010355a:	eb e2                	jmp    8010353e <mycpu+0x1b>
    panic("mycpu called with interrupts enabled\n");
8010355c:	83 ec 0c             	sub    $0xc,%esp
8010355f:	68 5c 77 10 80       	push   $0x8010775c
80103564:	e8 f3 cd ff ff       	call   8010035c <panic>
      return &cpus[i];
80103569:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
8010356f:	05 00 36 11 80       	add    $0x80113600,%eax
}
80103574:	c9                   	leave  
80103575:	c3                   	ret    
  panic("unknown apicid\n");
80103576:	83 ec 0c             	sub    $0xc,%esp
80103579:	68 7f 76 10 80       	push   $0x8010767f
8010357e:	e8 d9 cd ff ff       	call   8010035c <panic>

80103583 <cpuid>:
cpuid() {
80103583:	f3 0f 1e fb          	endbr32 
80103587:	55                   	push   %ebp
80103588:	89 e5                	mov    %esp,%ebp
8010358a:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010358d:	e8 91 ff ff ff       	call   80103523 <mycpu>
80103592:	2d 00 36 11 80       	sub    $0x80113600,%eax
80103597:	c1 f8 04             	sar    $0x4,%eax
8010359a:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801035a0:	c9                   	leave  
801035a1:	c3                   	ret    

801035a2 <myproc>:
myproc(void) {
801035a2:	f3 0f 1e fb          	endbr32 
801035a6:	55                   	push   %ebp
801035a7:	89 e5                	mov    %esp,%ebp
801035a9:	53                   	push   %ebx
801035aa:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801035ad:	e8 84 09 00 00       	call   80103f36 <pushcli>
  c = mycpu();
801035b2:	e8 6c ff ff ff       	call   80103523 <mycpu>
  p = c->proc;
801035b7:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801035bd:	e8 b5 09 00 00       	call   80103f77 <popcli>
}
801035c2:	89 d8                	mov    %ebx,%eax
801035c4:	83 c4 04             	add    $0x4,%esp
801035c7:	5b                   	pop    %ebx
801035c8:	5d                   	pop    %ebp
801035c9:	c3                   	ret    

801035ca <userinit>:
{
801035ca:	f3 0f 1e fb          	endbr32 
801035ce:	55                   	push   %ebp
801035cf:	89 e5                	mov    %esp,%ebp
801035d1:	53                   	push   %ebx
801035d2:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801035d5:	e8 5b fd ff ff       	call   80103335 <allocproc>
801035da:	89 c3                	mov    %eax,%ebx
  initproc = p;
801035dc:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
801035e1:	e8 f9 32 00 00       	call   801068df <setupkvm>
801035e6:	89 43 04             	mov    %eax,0x4(%ebx)
801035e9:	85 c0                	test   %eax,%eax
801035eb:	0f 84 ca 00 00 00    	je     801036bb <userinit+0xf1>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801035f1:	83 ec 04             	sub    $0x4,%esp
801035f4:	68 2c 00 00 00       	push   $0x2c
801035f9:	68 60 a4 10 80       	push   $0x8010a460
801035fe:	50                   	push   %eax
801035ff:	e8 69 2f 00 00       	call   8010656d <inituvm>
  p->sz = PGSIZE;
80103604:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010360a:	8b 43 18             	mov    0x18(%ebx),%eax
8010360d:	83 c4 0c             	add    $0xc,%esp
80103610:	6a 4c                	push   $0x4c
80103612:	6a 00                	push   $0x0
80103614:	50                   	push   %eax
80103615:	e8 b9 0a 00 00       	call   801040d3 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010361a:	8b 43 18             	mov    0x18(%ebx),%eax
8010361d:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103623:	8b 43 18             	mov    0x18(%ebx),%eax
80103626:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010362c:	8b 43 18             	mov    0x18(%ebx),%eax
8010362f:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103633:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103637:	8b 43 18             	mov    0x18(%ebx),%eax
8010363a:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010363e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103642:	8b 43 18             	mov    0x18(%ebx),%eax
80103645:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010364c:	8b 43 18             	mov    0x18(%ebx),%eax
8010364f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103656:	8b 43 18             	mov    0x18(%ebx),%eax
80103659:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103660:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103663:	83 c4 0c             	add    $0xc,%esp
80103666:	6a 10                	push   $0x10
80103668:	68 a8 76 10 80       	push   $0x801076a8
8010366d:	50                   	push   %eax
8010366e:	e8 e0 0b 00 00       	call   80104253 <safestrcpy>
  p->cwd = namei("/");
80103673:	c7 04 24 b1 76 10 80 	movl   $0x801076b1,(%esp)
8010367a:	e8 62 e7 ff ff       	call   80101de1 <namei>
8010367f:	89 43 68             	mov    %eax,0x68(%ebx)
  p->ticksAtStart = ticks;
80103682:	a1 20 66 11 80       	mov    0x80116620,%eax
80103687:	89 43 7c             	mov    %eax,0x7c(%ebx)
  p->ticksScheduled = 0;
8010368a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
80103691:	00 00 00 
  acquire(&ptable.lock);
80103694:	c7 04 24 a0 3b 11 80 	movl   $0x80113ba0,(%esp)
8010369b:	e8 7f 09 00 00       	call   8010401f <acquire>
  p->state = RUNNABLE;
801036a0:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
801036a7:	c7 04 24 a0 3b 11 80 	movl   $0x80113ba0,(%esp)
801036ae:	e8 d5 09 00 00       	call   80104088 <release>
}
801036b3:	83 c4 10             	add    $0x10,%esp
801036b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801036b9:	c9                   	leave  
801036ba:	c3                   	ret    
    panic("userinit: out of memory?");
801036bb:	83 ec 0c             	sub    $0xc,%esp
801036be:	68 8f 76 10 80       	push   $0x8010768f
801036c3:	e8 94 cc ff ff       	call   8010035c <panic>

801036c8 <growproc>:
{
801036c8:	f3 0f 1e fb          	endbr32 
801036cc:	55                   	push   %ebp
801036cd:	89 e5                	mov    %esp,%ebp
801036cf:	56                   	push   %esi
801036d0:	53                   	push   %ebx
801036d1:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801036d4:	e8 c9 fe ff ff       	call   801035a2 <myproc>
801036d9:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801036db:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801036dd:	85 f6                	test   %esi,%esi
801036df:	7f 1c                	jg     801036fd <growproc+0x35>
  } else if(n < 0){
801036e1:	78 37                	js     8010371a <growproc+0x52>
  curproc->sz = sz;
801036e3:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801036e5:	83 ec 0c             	sub    $0xc,%esp
801036e8:	53                   	push   %ebx
801036e9:	e8 4f 2d 00 00       	call   8010643d <switchuvm>
  return 0;
801036ee:	83 c4 10             	add    $0x10,%esp
801036f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801036f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801036f9:	5b                   	pop    %ebx
801036fa:	5e                   	pop    %esi
801036fb:	5d                   	pop    %ebp
801036fc:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801036fd:	83 ec 04             	sub    $0x4,%esp
80103700:	01 c6                	add    %eax,%esi
80103702:	56                   	push   %esi
80103703:	50                   	push   %eax
80103704:	ff 73 04             	pushl  0x4(%ebx)
80103707:	e8 43 30 00 00       	call   8010674f <allocuvm>
8010370c:	83 c4 10             	add    $0x10,%esp
8010370f:	85 c0                	test   %eax,%eax
80103711:	75 d0                	jne    801036e3 <growproc+0x1b>
      return -1;
80103713:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103718:	eb dc                	jmp    801036f6 <growproc+0x2e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010371a:	83 ec 04             	sub    $0x4,%esp
8010371d:	01 c6                	add    %eax,%esi
8010371f:	56                   	push   %esi
80103720:	50                   	push   %eax
80103721:	ff 73 04             	pushl  0x4(%ebx)
80103724:	e8 7c 2f 00 00       	call   801066a5 <deallocuvm>
80103729:	83 c4 10             	add    $0x10,%esp
8010372c:	85 c0                	test   %eax,%eax
8010372e:	75 b3                	jne    801036e3 <growproc+0x1b>
      return -1;
80103730:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103735:	eb bf                	jmp    801036f6 <growproc+0x2e>

80103737 <fork>:
{
80103737:	f3 0f 1e fb          	endbr32 
8010373b:	55                   	push   %ebp
8010373c:	89 e5                	mov    %esp,%ebp
8010373e:	57                   	push   %edi
8010373f:	56                   	push   %esi
80103740:	53                   	push   %ebx
80103741:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103744:	e8 59 fe ff ff       	call   801035a2 <myproc>
80103749:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
8010374b:	e8 e5 fb ff ff       	call   80103335 <allocproc>
80103750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103753:	85 c0                	test   %eax,%eax
80103755:	0f 84 f2 00 00 00    	je     8010384d <fork+0x116>
8010375b:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010375d:	83 ec 08             	sub    $0x8,%esp
80103760:	ff 33                	pushl  (%ebx)
80103762:	ff 73 04             	pushl  0x4(%ebx)
80103765:	e8 32 32 00 00       	call   8010699c <copyuvm>
8010376a:	89 47 04             	mov    %eax,0x4(%edi)
8010376d:	83 c4 10             	add    $0x10,%esp
80103770:	85 c0                	test   %eax,%eax
80103772:	74 2a                	je     8010379e <fork+0x67>
  np->sz = curproc->sz;
80103774:	8b 03                	mov    (%ebx),%eax
80103776:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103779:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
8010377b:	89 c8                	mov    %ecx,%eax
8010377d:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103780:	8b 73 18             	mov    0x18(%ebx),%esi
80103783:	8b 79 18             	mov    0x18(%ecx),%edi
80103786:	b9 13 00 00 00       	mov    $0x13,%ecx
8010378b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
8010378d:	8b 40 18             	mov    0x18(%eax),%eax
80103790:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103797:	be 00 00 00 00       	mov    $0x0,%esi
8010379c:	eb 3c                	jmp    801037da <fork+0xa3>
    kfree(np->kstack);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801037a4:	ff 77 08             	pushl  0x8(%edi)
801037a7:	e8 11 ea ff ff       	call   801021bd <kfree>
    np->kstack = 0;
801037ac:	c7 47 08 00 00 00 00 	movl   $0x0,0x8(%edi)
    np->state = UNUSED;
801037b3:	c7 47 0c 00 00 00 00 	movl   $0x0,0xc(%edi)
    return -1;
801037ba:	83 c4 10             	add    $0x10,%esp
801037bd:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801037c2:	eb 7f                	jmp    80103843 <fork+0x10c>
      np->ofile[i] = filedup(curproc->ofile[i]);
801037c4:	83 ec 0c             	sub    $0xc,%esp
801037c7:	50                   	push   %eax
801037c8:	e8 ef d4 ff ff       	call   80100cbc <filedup>
801037cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801037d0:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
801037d4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NOFILE; i++)
801037d7:	83 c6 01             	add    $0x1,%esi
801037da:	83 fe 0f             	cmp    $0xf,%esi
801037dd:	7f 0a                	jg     801037e9 <fork+0xb2>
    if(curproc->ofile[i])
801037df:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801037e3:	85 c0                	test   %eax,%eax
801037e5:	75 dd                	jne    801037c4 <fork+0x8d>
801037e7:	eb ee                	jmp    801037d7 <fork+0xa0>
  np->cwd = idup(curproc->cwd);
801037e9:	83 ec 0c             	sub    $0xc,%esp
801037ec:	ff 73 68             	pushl  0x68(%ebx)
801037ef:	e8 5f de ff ff       	call   80101653 <idup>
801037f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801037f7:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801037fa:	83 c3 6c             	add    $0x6c,%ebx
801037fd:	8d 47 6c             	lea    0x6c(%edi),%eax
80103800:	83 c4 0c             	add    $0xc,%esp
80103803:	6a 10                	push   $0x10
80103805:	53                   	push   %ebx
80103806:	50                   	push   %eax
80103807:	e8 47 0a 00 00       	call   80104253 <safestrcpy>
  pid = np->pid;
8010380c:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010380f:	c7 04 24 a0 3b 11 80 	movl   $0x80113ba0,(%esp)
80103816:	e8 04 08 00 00       	call   8010401f <acquire>
  np->state = RUNNABLE;
8010381b:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  np->ticksAtStart = ticks;
80103822:	a1 20 66 11 80       	mov    0x80116620,%eax
80103827:	89 47 7c             	mov    %eax,0x7c(%edi)
  np->ticksScheduled = 0;
8010382a:	c7 87 80 00 00 00 00 	movl   $0x0,0x80(%edi)
80103831:	00 00 00 
  release(&ptable.lock);
80103834:	c7 04 24 a0 3b 11 80 	movl   $0x80113ba0,(%esp)
8010383b:	e8 48 08 00 00       	call   80104088 <release>
  return pid;
80103840:	83 c4 10             	add    $0x10,%esp
}
80103843:	89 d8                	mov    %ebx,%eax
80103845:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103848:	5b                   	pop    %ebx
80103849:	5e                   	pop    %esi
8010384a:	5f                   	pop    %edi
8010384b:	5d                   	pop    %ebp
8010384c:	c3                   	ret    
    return -1;
8010384d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103852:	eb ef                	jmp    80103843 <fork+0x10c>

80103854 <scheduler>:
{
80103854:	f3 0f 1e fb          	endbr32 
80103858:	55                   	push   %ebp
80103859:	89 e5                	mov    %esp,%ebp
8010385b:	57                   	push   %edi
8010385c:	56                   	push   %esi
8010385d:	53                   	push   %ebx
8010385e:	83 ec 1c             	sub    $0x1c,%esp
  struct cpu *c = mycpu();
80103861:	e8 bd fc ff ff       	call   80103523 <mycpu>
80103866:	89 c7                	mov    %eax,%edi
  c->proc = 0;
80103868:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010386f:	00 00 00 
  int lowestPriority = 0x77777777;
80103872:	c7 45 e4 77 77 77 77 	movl   $0x77777777,-0x1c(%ebp)
80103879:	eb 6b                	jmp    801038e6 <scheduler+0x92>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010387b:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103881:	81 fb d4 5d 11 80    	cmp    $0x80115dd4,%ebx
80103887:	73 4d                	jae    801038d6 <scheduler+0x82>
      if(p->state != RUNNABLE || p->priority > lowestPriority){
80103889:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
8010388d:	75 ec                	jne    8010387b <scheduler+0x27>
8010388f:	8b b3 84 00 00 00    	mov    0x84(%ebx),%esi
80103895:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
80103898:	7f e1                	jg     8010387b <scheduler+0x27>
      c->proc = p;
8010389a:	89 9f ac 00 00 00    	mov    %ebx,0xac(%edi)
      switchuvm(p);
801038a0:	83 ec 0c             	sub    $0xc,%esp
801038a3:	53                   	push   %ebx
801038a4:	e8 94 2b 00 00       	call   8010643d <switchuvm>
      p->state = RUNNING;
801038a9:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
801038b0:	83 c4 08             	add    $0x8,%esp
801038b3:	ff 73 1c             	pushl  0x1c(%ebx)
801038b6:	8d 47 04             	lea    0x4(%edi),%eax
801038b9:	50                   	push   %eax
801038ba:	e8 f1 09 00 00       	call   801042b0 <swtch>
      switchkvm();
801038bf:	e8 50 2b 00 00       	call   80106414 <switchkvm>
      c->proc = 0;
801038c4:	c7 87 ac 00 00 00 00 	movl   $0x0,0xac(%edi)
801038cb:	00 00 00 
801038ce:	83 c4 10             	add    $0x10,%esp
        lowestPriority = p->priority;
801038d1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
801038d4:	eb a5                	jmp    8010387b <scheduler+0x27>
    release(&ptable.lock);
801038d6:	83 ec 0c             	sub    $0xc,%esp
801038d9:	68 a0 3b 11 80       	push   $0x80113ba0
801038de:	e8 a5 07 00 00       	call   80104088 <release>
    sti();
801038e3:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
801038e6:	fb                   	sti    
    acquire(&ptable.lock);
801038e7:	83 ec 0c             	sub    $0xc,%esp
801038ea:	68 a0 3b 11 80       	push   $0x80113ba0
801038ef:	e8 2b 07 00 00       	call   8010401f <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038f4:	83 c4 10             	add    $0x10,%esp
801038f7:	bb d4 3b 11 80       	mov    $0x80113bd4,%ebx
801038fc:	eb 83                	jmp    80103881 <scheduler+0x2d>

801038fe <sched>:
{
801038fe:	f3 0f 1e fb          	endbr32 
80103902:	55                   	push   %ebp
80103903:	89 e5                	mov    %esp,%ebp
80103905:	56                   	push   %esi
80103906:	53                   	push   %ebx
  struct proc *p = myproc();
80103907:	e8 96 fc ff ff       	call   801035a2 <myproc>
8010390c:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010390e:	83 ec 0c             	sub    $0xc,%esp
80103911:	68 a0 3b 11 80       	push   $0x80113ba0
80103916:	e8 c0 06 00 00       	call   80103fdb <holding>
8010391b:	83 c4 10             	add    $0x10,%esp
8010391e:	85 c0                	test   %eax,%eax
80103920:	74 56                	je     80103978 <sched+0x7a>
  if(mycpu()->ncli != 1)
80103922:	e8 fc fb ff ff       	call   80103523 <mycpu>
80103927:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010392e:	75 55                	jne    80103985 <sched+0x87>
  if(p->state == RUNNING)
80103930:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103934:	74 5c                	je     80103992 <sched+0x94>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103936:	9c                   	pushf  
80103937:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103938:	f6 c4 02             	test   $0x2,%ah
8010393b:	75 62                	jne    8010399f <sched+0xa1>
  intena = mycpu()->intena;
8010393d:	e8 e1 fb ff ff       	call   80103523 <mycpu>
80103942:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  p->ticksScheduled += 1;
80103948:	83 83 80 00 00 00 01 	addl   $0x1,0x80(%ebx)
  swtch(&p->context, mycpu()->scheduler);
8010394f:	e8 cf fb ff ff       	call   80103523 <mycpu>
80103954:	83 ec 08             	sub    $0x8,%esp
80103957:	ff 70 04             	pushl  0x4(%eax)
8010395a:	83 c3 1c             	add    $0x1c,%ebx
8010395d:	53                   	push   %ebx
8010395e:	e8 4d 09 00 00       	call   801042b0 <swtch>
  mycpu()->intena = intena;
80103963:	e8 bb fb ff ff       	call   80103523 <mycpu>
80103968:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010396e:	83 c4 10             	add    $0x10,%esp
80103971:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103974:	5b                   	pop    %ebx
80103975:	5e                   	pop    %esi
80103976:	5d                   	pop    %ebp
80103977:	c3                   	ret    
    panic("sched ptable.lock");
80103978:	83 ec 0c             	sub    $0xc,%esp
8010397b:	68 b3 76 10 80       	push   $0x801076b3
80103980:	e8 d7 c9 ff ff       	call   8010035c <panic>
    panic("sched locks");
80103985:	83 ec 0c             	sub    $0xc,%esp
80103988:	68 c5 76 10 80       	push   $0x801076c5
8010398d:	e8 ca c9 ff ff       	call   8010035c <panic>
    panic("sched running");
80103992:	83 ec 0c             	sub    $0xc,%esp
80103995:	68 d1 76 10 80       	push   $0x801076d1
8010399a:	e8 bd c9 ff ff       	call   8010035c <panic>
    panic("sched interruptible");
8010399f:	83 ec 0c             	sub    $0xc,%esp
801039a2:	68 df 76 10 80       	push   $0x801076df
801039a7:	e8 b0 c9 ff ff       	call   8010035c <panic>

801039ac <exit>:
{
801039ac:	f3 0f 1e fb          	endbr32 
801039b0:	55                   	push   %ebp
801039b1:	89 e5                	mov    %esp,%ebp
801039b3:	56                   	push   %esi
801039b4:	53                   	push   %ebx
  struct proc *curproc = myproc();
801039b5:	e8 e8 fb ff ff       	call   801035a2 <myproc>
  if(curproc == initproc)
801039ba:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
801039c0:	74 09                	je     801039cb <exit+0x1f>
801039c2:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801039c4:	bb 00 00 00 00       	mov    $0x0,%ebx
801039c9:	eb 24                	jmp    801039ef <exit+0x43>
    panic("init exiting");
801039cb:	83 ec 0c             	sub    $0xc,%esp
801039ce:	68 f3 76 10 80       	push   $0x801076f3
801039d3:	e8 84 c9 ff ff       	call   8010035c <panic>
      fileclose(curproc->ofile[fd]);
801039d8:	83 ec 0c             	sub    $0xc,%esp
801039db:	50                   	push   %eax
801039dc:	e8 24 d3 ff ff       	call   80100d05 <fileclose>
      curproc->ofile[fd] = 0;
801039e1:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
801039e8:	00 
801039e9:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
801039ec:	83 c3 01             	add    $0x1,%ebx
801039ef:	83 fb 0f             	cmp    $0xf,%ebx
801039f2:	7f 0a                	jg     801039fe <exit+0x52>
    if(curproc->ofile[fd]){
801039f4:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801039f8:	85 c0                	test   %eax,%eax
801039fa:	75 dc                	jne    801039d8 <exit+0x2c>
801039fc:	eb ee                	jmp    801039ec <exit+0x40>
  begin_op();
801039fe:	e8 14 f0 ff ff       	call   80102a17 <begin_op>
  iput(curproc->cwd);
80103a03:	83 ec 0c             	sub    $0xc,%esp
80103a06:	ff 76 68             	pushl  0x68(%esi)
80103a09:	e8 21 de ff ff       	call   8010182f <iput>
  end_op();
80103a0e:	e8 82 f0 ff ff       	call   80102a95 <end_op>
  curproc->cwd = 0;
80103a13:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103a1a:	c7 04 24 a0 3b 11 80 	movl   $0x80113ba0,(%esp)
80103a21:	e8 f9 05 00 00       	call   8010401f <acquire>
  wakeup1(curproc->parent);
80103a26:	8b 46 14             	mov    0x14(%esi),%eax
80103a29:	e8 dd f8 ff ff       	call   8010330b <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a2e:	83 c4 10             	add    $0x10,%esp
80103a31:	bb d4 3b 11 80       	mov    $0x80113bd4,%ebx
80103a36:	eb 06                	jmp    80103a3e <exit+0x92>
80103a38:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103a3e:	81 fb d4 5d 11 80    	cmp    $0x80115dd4,%ebx
80103a44:	73 1a                	jae    80103a60 <exit+0xb4>
    if(p->parent == curproc){
80103a46:	39 73 14             	cmp    %esi,0x14(%ebx)
80103a49:	75 ed                	jne    80103a38 <exit+0x8c>
      p->parent = initproc;
80103a4b:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
80103a50:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103a53:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103a57:	75 df                	jne    80103a38 <exit+0x8c>
        wakeup1(initproc);
80103a59:	e8 ad f8 ff ff       	call   8010330b <wakeup1>
80103a5e:	eb d8                	jmp    80103a38 <exit+0x8c>
  curproc->state = ZOMBIE;
80103a60:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103a67:	e8 92 fe ff ff       	call   801038fe <sched>
  panic("zombie exit");
80103a6c:	83 ec 0c             	sub    $0xc,%esp
80103a6f:	68 00 77 10 80       	push   $0x80107700
80103a74:	e8 e3 c8 ff ff       	call   8010035c <panic>

80103a79 <yield>:
{
80103a79:	f3 0f 1e fb          	endbr32 
80103a7d:	55                   	push   %ebp
80103a7e:	89 e5                	mov    %esp,%ebp
80103a80:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103a83:	68 a0 3b 11 80       	push   $0x80113ba0
80103a88:	e8 92 05 00 00       	call   8010401f <acquire>
  myproc()->state = RUNNABLE;
80103a8d:	e8 10 fb ff ff       	call   801035a2 <myproc>
80103a92:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103a99:	e8 60 fe ff ff       	call   801038fe <sched>
  release(&ptable.lock);
80103a9e:	c7 04 24 a0 3b 11 80 	movl   $0x80113ba0,(%esp)
80103aa5:	e8 de 05 00 00       	call   80104088 <release>
}
80103aaa:	83 c4 10             	add    $0x10,%esp
80103aad:	c9                   	leave  
80103aae:	c3                   	ret    

80103aaf <sleep>:
{
80103aaf:	f3 0f 1e fb          	endbr32 
80103ab3:	55                   	push   %ebp
80103ab4:	89 e5                	mov    %esp,%ebp
80103ab6:	56                   	push   %esi
80103ab7:	53                   	push   %ebx
80103ab8:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
80103abb:	e8 e2 fa ff ff       	call   801035a2 <myproc>
  if(p == 0)
80103ac0:	85 c0                	test   %eax,%eax
80103ac2:	74 66                	je     80103b2a <sleep+0x7b>
80103ac4:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
80103ac6:	85 f6                	test   %esi,%esi
80103ac8:	74 6d                	je     80103b37 <sleep+0x88>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103aca:	81 fe a0 3b 11 80    	cmp    $0x80113ba0,%esi
80103ad0:	74 18                	je     80103aea <sleep+0x3b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103ad2:	83 ec 0c             	sub    $0xc,%esp
80103ad5:	68 a0 3b 11 80       	push   $0x80113ba0
80103ada:	e8 40 05 00 00       	call   8010401f <acquire>
    release(lk);
80103adf:	89 34 24             	mov    %esi,(%esp)
80103ae2:	e8 a1 05 00 00       	call   80104088 <release>
80103ae7:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103aea:	8b 45 08             	mov    0x8(%ebp),%eax
80103aed:	89 43 20             	mov    %eax,0x20(%ebx)
  p->state = SLEEPING;
80103af0:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80103af7:	e8 02 fe ff ff       	call   801038fe <sched>
  p->chan = 0;
80103afc:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103b03:	81 fe a0 3b 11 80    	cmp    $0x80113ba0,%esi
80103b09:	74 18                	je     80103b23 <sleep+0x74>
    release(&ptable.lock);
80103b0b:	83 ec 0c             	sub    $0xc,%esp
80103b0e:	68 a0 3b 11 80       	push   $0x80113ba0
80103b13:	e8 70 05 00 00       	call   80104088 <release>
    acquire(lk);
80103b18:	89 34 24             	mov    %esi,(%esp)
80103b1b:	e8 ff 04 00 00       	call   8010401f <acquire>
80103b20:	83 c4 10             	add    $0x10,%esp
}
80103b23:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b26:	5b                   	pop    %ebx
80103b27:	5e                   	pop    %esi
80103b28:	5d                   	pop    %ebp
80103b29:	c3                   	ret    
    panic("sleep");
80103b2a:	83 ec 0c             	sub    $0xc,%esp
80103b2d:	68 0c 77 10 80       	push   $0x8010770c
80103b32:	e8 25 c8 ff ff       	call   8010035c <panic>
    panic("sleep without lk");
80103b37:	83 ec 0c             	sub    $0xc,%esp
80103b3a:	68 12 77 10 80       	push   $0x80107712
80103b3f:	e8 18 c8 ff ff       	call   8010035c <panic>

80103b44 <wait>:
{
80103b44:	f3 0f 1e fb          	endbr32 
80103b48:	55                   	push   %ebp
80103b49:	89 e5                	mov    %esp,%ebp
80103b4b:	56                   	push   %esi
80103b4c:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103b4d:	e8 50 fa ff ff       	call   801035a2 <myproc>
80103b52:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103b54:	83 ec 0c             	sub    $0xc,%esp
80103b57:	68 a0 3b 11 80       	push   $0x80113ba0
80103b5c:	e8 be 04 00 00       	call   8010401f <acquire>
80103b61:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103b64:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b69:	bb d4 3b 11 80       	mov    $0x80113bd4,%ebx
80103b6e:	eb 5e                	jmp    80103bce <wait+0x8a>
        pid = p->pid;
80103b70:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103b73:	83 ec 0c             	sub    $0xc,%esp
80103b76:	ff 73 08             	pushl  0x8(%ebx)
80103b79:	e8 3f e6 ff ff       	call   801021bd <kfree>
        p->kstack = 0;
80103b7e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103b85:	83 c4 04             	add    $0x4,%esp
80103b88:	ff 73 04             	pushl  0x4(%ebx)
80103b8b:	e8 c7 2c 00 00       	call   80106857 <freevm>
        p->pid = 0;
80103b90:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103b97:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103b9e:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103ba2:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103ba9:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103bb0:	c7 04 24 a0 3b 11 80 	movl   $0x80113ba0,(%esp)
80103bb7:	e8 cc 04 00 00       	call   80104088 <release>
        return pid;
80103bbc:	83 c4 10             	add    $0x10,%esp
}
80103bbf:	89 f0                	mov    %esi,%eax
80103bc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bc4:	5b                   	pop    %ebx
80103bc5:	5e                   	pop    %esi
80103bc6:	5d                   	pop    %ebp
80103bc7:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103bc8:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103bce:	81 fb d4 5d 11 80    	cmp    $0x80115dd4,%ebx
80103bd4:	73 12                	jae    80103be8 <wait+0xa4>
      if(p->parent != curproc)
80103bd6:	39 73 14             	cmp    %esi,0x14(%ebx)
80103bd9:	75 ed                	jne    80103bc8 <wait+0x84>
      if(p->state == ZOMBIE){
80103bdb:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103bdf:	74 8f                	je     80103b70 <wait+0x2c>
      havekids = 1;
80103be1:	b8 01 00 00 00       	mov    $0x1,%eax
80103be6:	eb e0                	jmp    80103bc8 <wait+0x84>
    if(!havekids || curproc->killed){
80103be8:	85 c0                	test   %eax,%eax
80103bea:	74 06                	je     80103bf2 <wait+0xae>
80103bec:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103bf0:	74 17                	je     80103c09 <wait+0xc5>
      release(&ptable.lock);
80103bf2:	83 ec 0c             	sub    $0xc,%esp
80103bf5:	68 a0 3b 11 80       	push   $0x80113ba0
80103bfa:	e8 89 04 00 00       	call   80104088 <release>
      return -1;
80103bff:	83 c4 10             	add    $0x10,%esp
80103c02:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103c07:	eb b6                	jmp    80103bbf <wait+0x7b>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103c09:	83 ec 08             	sub    $0x8,%esp
80103c0c:	68 a0 3b 11 80       	push   $0x80113ba0
80103c11:	56                   	push   %esi
80103c12:	e8 98 fe ff ff       	call   80103aaf <sleep>
    havekids = 0;
80103c17:	83 c4 10             	add    $0x10,%esp
80103c1a:	e9 45 ff ff ff       	jmp    80103b64 <wait+0x20>

80103c1f <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103c1f:	f3 0f 1e fb          	endbr32 
80103c23:	55                   	push   %ebp
80103c24:	89 e5                	mov    %esp,%ebp
80103c26:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103c29:	68 a0 3b 11 80       	push   $0x80113ba0
80103c2e:	e8 ec 03 00 00       	call   8010401f <acquire>
  wakeup1(chan);
80103c33:	8b 45 08             	mov    0x8(%ebp),%eax
80103c36:	e8 d0 f6 ff ff       	call   8010330b <wakeup1>
  release(&ptable.lock);
80103c3b:	c7 04 24 a0 3b 11 80 	movl   $0x80113ba0,(%esp)
80103c42:	e8 41 04 00 00       	call   80104088 <release>
}
80103c47:	83 c4 10             	add    $0x10,%esp
80103c4a:	c9                   	leave  
80103c4b:	c3                   	ret    

80103c4c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103c4c:	f3 0f 1e fb          	endbr32 
80103c50:	55                   	push   %ebp
80103c51:	89 e5                	mov    %esp,%ebp
80103c53:	53                   	push   %ebx
80103c54:	83 ec 10             	sub    $0x10,%esp
80103c57:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103c5a:	68 a0 3b 11 80       	push   $0x80113ba0
80103c5f:	e8 bb 03 00 00       	call   8010401f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103c64:	83 c4 10             	add    $0x10,%esp
80103c67:	b8 d4 3b 11 80       	mov    $0x80113bd4,%eax
80103c6c:	3d d4 5d 11 80       	cmp    $0x80115dd4,%eax
80103c71:	73 3c                	jae    80103caf <kill+0x63>
    if(p->pid == pid){
80103c73:	39 58 10             	cmp    %ebx,0x10(%eax)
80103c76:	74 07                	je     80103c7f <kill+0x33>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103c78:	05 88 00 00 00       	add    $0x88,%eax
80103c7d:	eb ed                	jmp    80103c6c <kill+0x20>
      p->killed = 1;
80103c7f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103c86:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103c8a:	74 1a                	je     80103ca6 <kill+0x5a>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103c8c:	83 ec 0c             	sub    $0xc,%esp
80103c8f:	68 a0 3b 11 80       	push   $0x80113ba0
80103c94:	e8 ef 03 00 00       	call   80104088 <release>
      return 0;
80103c99:	83 c4 10             	add    $0x10,%esp
80103c9c:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103ca1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ca4:	c9                   	leave  
80103ca5:	c3                   	ret    
        p->state = RUNNABLE;
80103ca6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103cad:	eb dd                	jmp    80103c8c <kill+0x40>
  release(&ptable.lock);
80103caf:	83 ec 0c             	sub    $0xc,%esp
80103cb2:	68 a0 3b 11 80       	push   $0x80113ba0
80103cb7:	e8 cc 03 00 00       	call   80104088 <release>
  return -1;
80103cbc:	83 c4 10             	add    $0x10,%esp
80103cbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cc4:	eb db                	jmp    80103ca1 <kill+0x55>

80103cc6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103cc6:	f3 0f 1e fb          	endbr32 
80103cca:	55                   	push   %ebp
80103ccb:	89 e5                	mov    %esp,%ebp
80103ccd:	56                   	push   %esi
80103cce:	53                   	push   %ebx
80103ccf:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  const char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103cd2:	bb d4 3b 11 80       	mov    $0x80113bd4,%ebx
80103cd7:	eb 36                	jmp    80103d0f <procdump+0x49>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103cd9:	b8 23 77 10 80       	mov    $0x80107723,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103cde:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103ce1:	52                   	push   %edx
80103ce2:	50                   	push   %eax
80103ce3:	ff 73 10             	pushl  0x10(%ebx)
80103ce6:	68 27 77 10 80       	push   $0x80107727
80103ceb:	e8 39 c9 ff ff       	call   80100629 <cprintf>
    if(p->state == SLEEPING){
80103cf0:	83 c4 10             	add    $0x10,%esp
80103cf3:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103cf7:	74 3c                	je     80103d35 <procdump+0x6f>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103cf9:	83 ec 0c             	sub    $0xc,%esp
80103cfc:	68 af 7a 10 80       	push   $0x80107aaf
80103d01:	e8 23 c9 ff ff       	call   80100629 <cprintf>
80103d06:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103d09:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103d0f:	81 fb d4 5d 11 80    	cmp    $0x80115dd4,%ebx
80103d15:	73 61                	jae    80103d78 <procdump+0xb2>
    if(p->state == UNUSED)
80103d17:	8b 43 0c             	mov    0xc(%ebx),%eax
80103d1a:	85 c0                	test   %eax,%eax
80103d1c:	74 eb                	je     80103d09 <procdump+0x43>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103d1e:	83 f8 05             	cmp    $0x5,%eax
80103d21:	77 b6                	ja     80103cd9 <procdump+0x13>
80103d23:	8b 04 85 84 77 10 80 	mov    -0x7fef887c(,%eax,4),%eax
80103d2a:	85 c0                	test   %eax,%eax
80103d2c:	75 b0                	jne    80103cde <procdump+0x18>
      state = "???";
80103d2e:	b8 23 77 10 80       	mov    $0x80107723,%eax
80103d33:	eb a9                	jmp    80103cde <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103d35:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103d38:	8b 40 0c             	mov    0xc(%eax),%eax
80103d3b:	83 c0 08             	add    $0x8,%eax
80103d3e:	83 ec 08             	sub    $0x8,%esp
80103d41:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103d44:	52                   	push   %edx
80103d45:	50                   	push   %eax
80103d46:	e8 a3 01 00 00       	call   80103eee <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103d4b:	83 c4 10             	add    $0x10,%esp
80103d4e:	be 00 00 00 00       	mov    $0x0,%esi
80103d53:	eb 14                	jmp    80103d69 <procdump+0xa3>
        cprintf(" %p", pc[i]);
80103d55:	83 ec 08             	sub    $0x8,%esp
80103d58:	50                   	push   %eax
80103d59:	68 c1 70 10 80       	push   $0x801070c1
80103d5e:	e8 c6 c8 ff ff       	call   80100629 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103d63:	83 c6 01             	add    $0x1,%esi
80103d66:	83 c4 10             	add    $0x10,%esp
80103d69:	83 fe 09             	cmp    $0x9,%esi
80103d6c:	7f 8b                	jg     80103cf9 <procdump+0x33>
80103d6e:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103d72:	85 c0                	test   %eax,%eax
80103d74:	75 df                	jne    80103d55 <procdump+0x8f>
80103d76:	eb 81                	jmp    80103cf9 <procdump+0x33>
  }
}
80103d78:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103d7b:	5b                   	pop    %ebx
80103d7c:	5e                   	pop    %esi
80103d7d:	5d                   	pop    %ebp
80103d7e:	c3                   	ret    

80103d7f <proc_nice>:

int proc_nice(int PID, int priority){
80103d7f:	f3 0f 1e fb          	endbr32 
80103d83:	55                   	push   %ebp
80103d84:	89 e5                	mov    %esp,%ebp
80103d86:	8b 55 08             	mov    0x8(%ebp),%edx
80103d89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  struct proc* p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103d8c:	b8 d4 3b 11 80       	mov    $0x80113bd4,%eax
80103d91:	eb 05                	jmp    80103d98 <proc_nice+0x19>
80103d93:	05 88 00 00 00       	add    $0x88,%eax
80103d98:	3d d4 5d 11 80       	cmp    $0x80115dd4,%eax
80103d9d:	73 0d                	jae    80103dac <proc_nice+0x2d>
    if(p->pid == PID){
80103d9f:	39 50 10             	cmp    %edx,0x10(%eax)
80103da2:	75 ef                	jne    80103d93 <proc_nice+0x14>
      p->priority = priority;
80103da4:	89 88 84 00 00 00    	mov    %ecx,0x84(%eax)
80103daa:	eb e7                	jmp    80103d93 <proc_nice+0x14>
    }
  }
  return p->priority;
80103dac:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
80103db2:	5d                   	pop    %ebp
80103db3:	c3                   	ret    

80103db4 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103db4:	f3 0f 1e fb          	endbr32 
80103db8:	55                   	push   %ebp
80103db9:	89 e5                	mov    %esp,%ebp
80103dbb:	53                   	push   %ebx
80103dbc:	83 ec 0c             	sub    $0xc,%esp
80103dbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103dc2:	68 9c 77 10 80       	push   $0x8010779c
80103dc7:	8d 43 04             	lea    0x4(%ebx),%eax
80103dca:	50                   	push   %eax
80103dcb:	e8 ff 00 00 00       	call   80103ecf <initlock>
  lk->name = name;
80103dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dd3:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103dd6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103ddc:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103de3:	83 c4 10             	add    $0x10,%esp
80103de6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103de9:	c9                   	leave  
80103dea:	c3                   	ret    

80103deb <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103deb:	f3 0f 1e fb          	endbr32 
80103def:	55                   	push   %ebp
80103df0:	89 e5                	mov    %esp,%ebp
80103df2:	56                   	push   %esi
80103df3:	53                   	push   %ebx
80103df4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103df7:	8d 73 04             	lea    0x4(%ebx),%esi
80103dfa:	83 ec 0c             	sub    $0xc,%esp
80103dfd:	56                   	push   %esi
80103dfe:	e8 1c 02 00 00       	call   8010401f <acquire>
  while (lk->locked) {
80103e03:	83 c4 10             	add    $0x10,%esp
80103e06:	83 3b 00             	cmpl   $0x0,(%ebx)
80103e09:	74 0f                	je     80103e1a <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80103e0b:	83 ec 08             	sub    $0x8,%esp
80103e0e:	56                   	push   %esi
80103e0f:	53                   	push   %ebx
80103e10:	e8 9a fc ff ff       	call   80103aaf <sleep>
80103e15:	83 c4 10             	add    $0x10,%esp
80103e18:	eb ec                	jmp    80103e06 <acquiresleep+0x1b>
  }
  lk->locked = 1;
80103e1a:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103e20:	e8 7d f7 ff ff       	call   801035a2 <myproc>
80103e25:	8b 40 10             	mov    0x10(%eax),%eax
80103e28:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103e2b:	83 ec 0c             	sub    $0xc,%esp
80103e2e:	56                   	push   %esi
80103e2f:	e8 54 02 00 00       	call   80104088 <release>
}
80103e34:	83 c4 10             	add    $0x10,%esp
80103e37:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103e3a:	5b                   	pop    %ebx
80103e3b:	5e                   	pop    %esi
80103e3c:	5d                   	pop    %ebp
80103e3d:	c3                   	ret    

80103e3e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103e3e:	f3 0f 1e fb          	endbr32 
80103e42:	55                   	push   %ebp
80103e43:	89 e5                	mov    %esp,%ebp
80103e45:	56                   	push   %esi
80103e46:	53                   	push   %ebx
80103e47:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103e4a:	8d 73 04             	lea    0x4(%ebx),%esi
80103e4d:	83 ec 0c             	sub    $0xc,%esp
80103e50:	56                   	push   %esi
80103e51:	e8 c9 01 00 00       	call   8010401f <acquire>
  lk->locked = 0;
80103e56:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103e5c:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103e63:	89 1c 24             	mov    %ebx,(%esp)
80103e66:	e8 b4 fd ff ff       	call   80103c1f <wakeup>
  release(&lk->lk);
80103e6b:	89 34 24             	mov    %esi,(%esp)
80103e6e:	e8 15 02 00 00       	call   80104088 <release>
}
80103e73:	83 c4 10             	add    $0x10,%esp
80103e76:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103e79:	5b                   	pop    %ebx
80103e7a:	5e                   	pop    %esi
80103e7b:	5d                   	pop    %ebp
80103e7c:	c3                   	ret    

80103e7d <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103e7d:	f3 0f 1e fb          	endbr32 
80103e81:	55                   	push   %ebp
80103e82:	89 e5                	mov    %esp,%ebp
80103e84:	56                   	push   %esi
80103e85:	53                   	push   %ebx
80103e86:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103e89:	8d 73 04             	lea    0x4(%ebx),%esi
80103e8c:	83 ec 0c             	sub    $0xc,%esp
80103e8f:	56                   	push   %esi
80103e90:	e8 8a 01 00 00       	call   8010401f <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103e95:	83 c4 10             	add    $0x10,%esp
80103e98:	83 3b 00             	cmpl   $0x0,(%ebx)
80103e9b:	75 17                	jne    80103eb4 <holdingsleep+0x37>
80103e9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103ea2:	83 ec 0c             	sub    $0xc,%esp
80103ea5:	56                   	push   %esi
80103ea6:	e8 dd 01 00 00       	call   80104088 <release>
  return r;
}
80103eab:	89 d8                	mov    %ebx,%eax
80103ead:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103eb0:	5b                   	pop    %ebx
80103eb1:	5e                   	pop    %esi
80103eb2:	5d                   	pop    %ebp
80103eb3:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103eb4:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103eb7:	e8 e6 f6 ff ff       	call   801035a2 <myproc>
80103ebc:	3b 58 10             	cmp    0x10(%eax),%ebx
80103ebf:	74 07                	je     80103ec8 <holdingsleep+0x4b>
80103ec1:	bb 00 00 00 00       	mov    $0x0,%ebx
80103ec6:	eb da                	jmp    80103ea2 <holdingsleep+0x25>
80103ec8:	bb 01 00 00 00       	mov    $0x1,%ebx
80103ecd:	eb d3                	jmp    80103ea2 <holdingsleep+0x25>

80103ecf <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103ecf:	f3 0f 1e fb          	endbr32 
80103ed3:	55                   	push   %ebp
80103ed4:	89 e5                	mov    %esp,%ebp
80103ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103ed9:	8b 55 0c             	mov    0xc(%ebp),%edx
80103edc:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103edf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103ee5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103eec:	5d                   	pop    %ebp
80103eed:	c3                   	ret    

80103eee <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103eee:	f3 0f 1e fb          	endbr32 
80103ef2:	55                   	push   %ebp
80103ef3:	89 e5                	mov    %esp,%ebp
80103ef5:	53                   	push   %ebx
80103ef6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80103efc:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103eff:	b8 00 00 00 00       	mov    $0x0,%eax
80103f04:	83 f8 09             	cmp    $0x9,%eax
80103f07:	7f 25                	jg     80103f2e <getcallerpcs+0x40>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103f09:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103f0f:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103f15:	77 17                	ja     80103f2e <getcallerpcs+0x40>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103f17:	8b 5a 04             	mov    0x4(%edx),%ebx
80103f1a:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103f1d:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103f1f:	83 c0 01             	add    $0x1,%eax
80103f22:	eb e0                	jmp    80103f04 <getcallerpcs+0x16>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103f24:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103f2b:	83 c0 01             	add    $0x1,%eax
80103f2e:	83 f8 09             	cmp    $0x9,%eax
80103f31:	7e f1                	jle    80103f24 <getcallerpcs+0x36>
}
80103f33:	5b                   	pop    %ebx
80103f34:	5d                   	pop    %ebp
80103f35:	c3                   	ret    

80103f36 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103f36:	f3 0f 1e fb          	endbr32 
80103f3a:	55                   	push   %ebp
80103f3b:	89 e5                	mov    %esp,%ebp
80103f3d:	53                   	push   %ebx
80103f3e:	83 ec 04             	sub    $0x4,%esp
80103f41:	9c                   	pushf  
80103f42:	5b                   	pop    %ebx
  asm volatile("cli");
80103f43:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103f44:	e8 da f5 ff ff       	call   80103523 <mycpu>
80103f49:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103f50:	74 12                	je     80103f64 <pushcli+0x2e>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103f52:	e8 cc f5 ff ff       	call   80103523 <mycpu>
80103f57:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103f5e:	83 c4 04             	add    $0x4,%esp
80103f61:	5b                   	pop    %ebx
80103f62:	5d                   	pop    %ebp
80103f63:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103f64:	e8 ba f5 ff ff       	call   80103523 <mycpu>
80103f69:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103f6f:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103f75:	eb db                	jmp    80103f52 <pushcli+0x1c>

80103f77 <popcli>:

void
popcli(void)
{
80103f77:	f3 0f 1e fb          	endbr32 
80103f7b:	55                   	push   %ebp
80103f7c:	89 e5                	mov    %esp,%ebp
80103f7e:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103f81:	9c                   	pushf  
80103f82:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103f83:	f6 c4 02             	test   $0x2,%ah
80103f86:	75 28                	jne    80103fb0 <popcli+0x39>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103f88:	e8 96 f5 ff ff       	call   80103523 <mycpu>
80103f8d:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103f93:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103f96:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103f9c:	85 d2                	test   %edx,%edx
80103f9e:	78 1d                	js     80103fbd <popcli+0x46>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103fa0:	e8 7e f5 ff ff       	call   80103523 <mycpu>
80103fa5:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103fac:	74 1c                	je     80103fca <popcli+0x53>
    sti();
}
80103fae:	c9                   	leave  
80103faf:	c3                   	ret    
    panic("popcli - interruptible");
80103fb0:	83 ec 0c             	sub    $0xc,%esp
80103fb3:	68 a7 77 10 80       	push   $0x801077a7
80103fb8:	e8 9f c3 ff ff       	call   8010035c <panic>
    panic("popcli");
80103fbd:	83 ec 0c             	sub    $0xc,%esp
80103fc0:	68 be 77 10 80       	push   $0x801077be
80103fc5:	e8 92 c3 ff ff       	call   8010035c <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103fca:	e8 54 f5 ff ff       	call   80103523 <mycpu>
80103fcf:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103fd6:	74 d6                	je     80103fae <popcli+0x37>
  asm volatile("sti");
80103fd8:	fb                   	sti    
}
80103fd9:	eb d3                	jmp    80103fae <popcli+0x37>

80103fdb <holding>:
{
80103fdb:	f3 0f 1e fb          	endbr32 
80103fdf:	55                   	push   %ebp
80103fe0:	89 e5                	mov    %esp,%ebp
80103fe2:	53                   	push   %ebx
80103fe3:	83 ec 04             	sub    $0x4,%esp
80103fe6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103fe9:	e8 48 ff ff ff       	call   80103f36 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103fee:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ff1:	75 12                	jne    80104005 <holding+0x2a>
80103ff3:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103ff8:	e8 7a ff ff ff       	call   80103f77 <popcli>
}
80103ffd:	89 d8                	mov    %ebx,%eax
80103fff:	83 c4 04             	add    $0x4,%esp
80104002:	5b                   	pop    %ebx
80104003:	5d                   	pop    %ebp
80104004:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80104005:	8b 5b 08             	mov    0x8(%ebx),%ebx
80104008:	e8 16 f5 ff ff       	call   80103523 <mycpu>
8010400d:	39 c3                	cmp    %eax,%ebx
8010400f:	74 07                	je     80104018 <holding+0x3d>
80104011:	bb 00 00 00 00       	mov    $0x0,%ebx
80104016:	eb e0                	jmp    80103ff8 <holding+0x1d>
80104018:	bb 01 00 00 00       	mov    $0x1,%ebx
8010401d:	eb d9                	jmp    80103ff8 <holding+0x1d>

8010401f <acquire>:
{
8010401f:	f3 0f 1e fb          	endbr32 
80104023:	55                   	push   %ebp
80104024:	89 e5                	mov    %esp,%ebp
80104026:	53                   	push   %ebx
80104027:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010402a:	e8 07 ff ff ff       	call   80103f36 <pushcli>
  if(holding(lk))
8010402f:	83 ec 0c             	sub    $0xc,%esp
80104032:	ff 75 08             	pushl  0x8(%ebp)
80104035:	e8 a1 ff ff ff       	call   80103fdb <holding>
8010403a:	83 c4 10             	add    $0x10,%esp
8010403d:	85 c0                	test   %eax,%eax
8010403f:	75 3a                	jne    8010407b <acquire+0x5c>
  while(xchg(&lk->locked, 1) != 0)
80104041:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80104044:	b8 01 00 00 00       	mov    $0x1,%eax
80104049:	f0 87 02             	lock xchg %eax,(%edx)
8010404c:	85 c0                	test   %eax,%eax
8010404e:	75 f1                	jne    80104041 <acquire+0x22>
  __sync_synchronize();
80104050:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104055:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104058:	e8 c6 f4 ff ff       	call   80103523 <mycpu>
8010405d:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104060:	8b 45 08             	mov    0x8(%ebp),%eax
80104063:	83 c0 0c             	add    $0xc,%eax
80104066:	83 ec 08             	sub    $0x8,%esp
80104069:	50                   	push   %eax
8010406a:	8d 45 08             	lea    0x8(%ebp),%eax
8010406d:	50                   	push   %eax
8010406e:	e8 7b fe ff ff       	call   80103eee <getcallerpcs>
}
80104073:	83 c4 10             	add    $0x10,%esp
80104076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104079:	c9                   	leave  
8010407a:	c3                   	ret    
    panic("acquire");
8010407b:	83 ec 0c             	sub    $0xc,%esp
8010407e:	68 c5 77 10 80       	push   $0x801077c5
80104083:	e8 d4 c2 ff ff       	call   8010035c <panic>

80104088 <release>:
{
80104088:	f3 0f 1e fb          	endbr32 
8010408c:	55                   	push   %ebp
8010408d:	89 e5                	mov    %esp,%ebp
8010408f:	53                   	push   %ebx
80104090:	83 ec 10             	sub    $0x10,%esp
80104093:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80104096:	53                   	push   %ebx
80104097:	e8 3f ff ff ff       	call   80103fdb <holding>
8010409c:	83 c4 10             	add    $0x10,%esp
8010409f:	85 c0                	test   %eax,%eax
801040a1:	74 23                	je     801040c6 <release+0x3e>
  lk->pcs[0] = 0;
801040a3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
801040aa:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
801040b1:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801040b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
801040bc:	e8 b6 fe ff ff       	call   80103f77 <popcli>
}
801040c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040c4:	c9                   	leave  
801040c5:	c3                   	ret    
    panic("release");
801040c6:	83 ec 0c             	sub    $0xc,%esp
801040c9:	68 cd 77 10 80       	push   $0x801077cd
801040ce:	e8 89 c2 ff ff       	call   8010035c <panic>

801040d3 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801040d3:	f3 0f 1e fb          	endbr32 
801040d7:	55                   	push   %ebp
801040d8:	89 e5                	mov    %esp,%ebp
801040da:	57                   	push   %edi
801040db:	53                   	push   %ebx
801040dc:	8b 55 08             	mov    0x8(%ebp),%edx
801040df:	8b 45 0c             	mov    0xc(%ebp),%eax
801040e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
801040e5:	f6 c2 03             	test   $0x3,%dl
801040e8:	75 25                	jne    8010410f <memset+0x3c>
801040ea:	f6 c1 03             	test   $0x3,%cl
801040ed:	75 20                	jne    8010410f <memset+0x3c>
    c &= 0xFF;
801040ef:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801040f2:	c1 e9 02             	shr    $0x2,%ecx
801040f5:	c1 e0 18             	shl    $0x18,%eax
801040f8:	89 fb                	mov    %edi,%ebx
801040fa:	c1 e3 10             	shl    $0x10,%ebx
801040fd:	09 d8                	or     %ebx,%eax
801040ff:	89 fb                	mov    %edi,%ebx
80104101:	c1 e3 08             	shl    $0x8,%ebx
80104104:	09 d8                	or     %ebx,%eax
80104106:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104108:	89 d7                	mov    %edx,%edi
8010410a:	fc                   	cld    
8010410b:	f3 ab                	rep stos %eax,%es:(%edi)
}
8010410d:	eb 05                	jmp    80104114 <memset+0x41>
  asm volatile("cld; rep stosb" :
8010410f:	89 d7                	mov    %edx,%edi
80104111:	fc                   	cld    
80104112:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80104114:	89 d0                	mov    %edx,%eax
80104116:	5b                   	pop    %ebx
80104117:	5f                   	pop    %edi
80104118:	5d                   	pop    %ebp
80104119:	c3                   	ret    

8010411a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010411a:	f3 0f 1e fb          	endbr32 
8010411e:	55                   	push   %ebp
8010411f:	89 e5                	mov    %esp,%ebp
80104121:	56                   	push   %esi
80104122:	53                   	push   %ebx
80104123:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104126:	8b 55 0c             	mov    0xc(%ebp),%edx
80104129:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010412c:	8d 70 ff             	lea    -0x1(%eax),%esi
8010412f:	85 c0                	test   %eax,%eax
80104131:	74 1c                	je     8010414f <memcmp+0x35>
    if(*s1 != *s2)
80104133:	0f b6 01             	movzbl (%ecx),%eax
80104136:	0f b6 1a             	movzbl (%edx),%ebx
80104139:	38 d8                	cmp    %bl,%al
8010413b:	75 0a                	jne    80104147 <memcmp+0x2d>
      return *s1 - *s2;
    s1++, s2++;
8010413d:	83 c1 01             	add    $0x1,%ecx
80104140:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104143:	89 f0                	mov    %esi,%eax
80104145:	eb e5                	jmp    8010412c <memcmp+0x12>
      return *s1 - *s2;
80104147:	0f b6 c0             	movzbl %al,%eax
8010414a:	0f b6 db             	movzbl %bl,%ebx
8010414d:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
8010414f:	5b                   	pop    %ebx
80104150:	5e                   	pop    %esi
80104151:	5d                   	pop    %ebp
80104152:	c3                   	ret    

80104153 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104153:	f3 0f 1e fb          	endbr32 
80104157:	55                   	push   %ebp
80104158:	89 e5                	mov    %esp,%ebp
8010415a:	56                   	push   %esi
8010415b:	53                   	push   %ebx
8010415c:	8b 75 08             	mov    0x8(%ebp),%esi
8010415f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104162:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104165:	39 f2                	cmp    %esi,%edx
80104167:	73 3a                	jae    801041a3 <memmove+0x50>
80104169:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
8010416c:	39 f1                	cmp    %esi,%ecx
8010416e:	76 37                	jbe    801041a7 <memmove+0x54>
    s += n;
    d += n;
80104170:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
80104173:	8d 58 ff             	lea    -0x1(%eax),%ebx
80104176:	85 c0                	test   %eax,%eax
80104178:	74 23                	je     8010419d <memmove+0x4a>
      *--d = *--s;
8010417a:	83 e9 01             	sub    $0x1,%ecx
8010417d:	83 ea 01             	sub    $0x1,%edx
80104180:	0f b6 01             	movzbl (%ecx),%eax
80104183:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
80104185:	89 d8                	mov    %ebx,%eax
80104187:	eb ea                	jmp    80104173 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104189:	0f b6 02             	movzbl (%edx),%eax
8010418c:	88 01                	mov    %al,(%ecx)
8010418e:	8d 49 01             	lea    0x1(%ecx),%ecx
80104191:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
80104194:	89 d8                	mov    %ebx,%eax
80104196:	8d 58 ff             	lea    -0x1(%eax),%ebx
80104199:	85 c0                	test   %eax,%eax
8010419b:	75 ec                	jne    80104189 <memmove+0x36>

  return dst;
}
8010419d:	89 f0                	mov    %esi,%eax
8010419f:	5b                   	pop    %ebx
801041a0:	5e                   	pop    %esi
801041a1:	5d                   	pop    %ebp
801041a2:	c3                   	ret    
801041a3:	89 f1                	mov    %esi,%ecx
801041a5:	eb ef                	jmp    80104196 <memmove+0x43>
801041a7:	89 f1                	mov    %esi,%ecx
801041a9:	eb eb                	jmp    80104196 <memmove+0x43>

801041ab <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801041ab:	f3 0f 1e fb          	endbr32 
801041af:	55                   	push   %ebp
801041b0:	89 e5                	mov    %esp,%ebp
801041b2:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801041b5:	ff 75 10             	pushl  0x10(%ebp)
801041b8:	ff 75 0c             	pushl  0xc(%ebp)
801041bb:	ff 75 08             	pushl  0x8(%ebp)
801041be:	e8 90 ff ff ff       	call   80104153 <memmove>
}
801041c3:	c9                   	leave  
801041c4:	c3                   	ret    

801041c5 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801041c5:	f3 0f 1e fb          	endbr32 
801041c9:	55                   	push   %ebp
801041ca:	89 e5                	mov    %esp,%ebp
801041cc:	53                   	push   %ebx
801041cd:	8b 55 08             	mov    0x8(%ebp),%edx
801041d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801041d3:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
801041d6:	eb 09                	jmp    801041e1 <strncmp+0x1c>
    n--, p++, q++;
801041d8:	83 e8 01             	sub    $0x1,%eax
801041db:	83 c2 01             	add    $0x1,%edx
801041de:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
801041e1:	85 c0                	test   %eax,%eax
801041e3:	74 0b                	je     801041f0 <strncmp+0x2b>
801041e5:	0f b6 1a             	movzbl (%edx),%ebx
801041e8:	84 db                	test   %bl,%bl
801041ea:	74 04                	je     801041f0 <strncmp+0x2b>
801041ec:	3a 19                	cmp    (%ecx),%bl
801041ee:	74 e8                	je     801041d8 <strncmp+0x13>
  if(n == 0)
801041f0:	85 c0                	test   %eax,%eax
801041f2:	74 0b                	je     801041ff <strncmp+0x3a>
    return 0;
  return (uchar)*p - (uchar)*q;
801041f4:	0f b6 02             	movzbl (%edx),%eax
801041f7:	0f b6 11             	movzbl (%ecx),%edx
801041fa:	29 d0                	sub    %edx,%eax
}
801041fc:	5b                   	pop    %ebx
801041fd:	5d                   	pop    %ebp
801041fe:	c3                   	ret    
    return 0;
801041ff:	b8 00 00 00 00       	mov    $0x0,%eax
80104204:	eb f6                	jmp    801041fc <strncmp+0x37>

80104206 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104206:	f3 0f 1e fb          	endbr32 
8010420a:	55                   	push   %ebp
8010420b:	89 e5                	mov    %esp,%ebp
8010420d:	57                   	push   %edi
8010420e:	56                   	push   %esi
8010420f:	53                   	push   %ebx
80104210:	8b 7d 08             	mov    0x8(%ebp),%edi
80104213:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104216:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104219:	89 fa                	mov    %edi,%edx
8010421b:	eb 04                	jmp    80104221 <strncpy+0x1b>
8010421d:	89 f1                	mov    %esi,%ecx
8010421f:	89 da                	mov    %ebx,%edx
80104221:	89 c3                	mov    %eax,%ebx
80104223:	83 e8 01             	sub    $0x1,%eax
80104226:	85 db                	test   %ebx,%ebx
80104228:	7e 1b                	jle    80104245 <strncpy+0x3f>
8010422a:	8d 71 01             	lea    0x1(%ecx),%esi
8010422d:	8d 5a 01             	lea    0x1(%edx),%ebx
80104230:	0f b6 09             	movzbl (%ecx),%ecx
80104233:	88 0a                	mov    %cl,(%edx)
80104235:	84 c9                	test   %cl,%cl
80104237:	75 e4                	jne    8010421d <strncpy+0x17>
80104239:	89 da                	mov    %ebx,%edx
8010423b:	eb 08                	jmp    80104245 <strncpy+0x3f>
    ;
  while(n-- > 0)
    *s++ = 0;
8010423d:	c6 02 00             	movb   $0x0,(%edx)
  while(n-- > 0)
80104240:	89 c8                	mov    %ecx,%eax
    *s++ = 0;
80104242:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
80104245:	8d 48 ff             	lea    -0x1(%eax),%ecx
80104248:	85 c0                	test   %eax,%eax
8010424a:	7f f1                	jg     8010423d <strncpy+0x37>
  return os;
}
8010424c:	89 f8                	mov    %edi,%eax
8010424e:	5b                   	pop    %ebx
8010424f:	5e                   	pop    %esi
80104250:	5f                   	pop    %edi
80104251:	5d                   	pop    %ebp
80104252:	c3                   	ret    

80104253 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104253:	f3 0f 1e fb          	endbr32 
80104257:	55                   	push   %ebp
80104258:	89 e5                	mov    %esp,%ebp
8010425a:	57                   	push   %edi
8010425b:	56                   	push   %esi
8010425c:	53                   	push   %ebx
8010425d:	8b 7d 08             	mov    0x8(%ebp),%edi
80104260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104263:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80104266:	85 c0                	test   %eax,%eax
80104268:	7e 23                	jle    8010428d <safestrcpy+0x3a>
8010426a:	89 fa                	mov    %edi,%edx
8010426c:	eb 04                	jmp    80104272 <safestrcpy+0x1f>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
8010426e:	89 f1                	mov    %esi,%ecx
80104270:	89 da                	mov    %ebx,%edx
80104272:	83 e8 01             	sub    $0x1,%eax
80104275:	85 c0                	test   %eax,%eax
80104277:	7e 11                	jle    8010428a <safestrcpy+0x37>
80104279:	8d 71 01             	lea    0x1(%ecx),%esi
8010427c:	8d 5a 01             	lea    0x1(%edx),%ebx
8010427f:	0f b6 09             	movzbl (%ecx),%ecx
80104282:	88 0a                	mov    %cl,(%edx)
80104284:	84 c9                	test   %cl,%cl
80104286:	75 e6                	jne    8010426e <safestrcpy+0x1b>
80104288:	89 da                	mov    %ebx,%edx
    ;
  *s = 0;
8010428a:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
8010428d:	89 f8                	mov    %edi,%eax
8010428f:	5b                   	pop    %ebx
80104290:	5e                   	pop    %esi
80104291:	5f                   	pop    %edi
80104292:	5d                   	pop    %ebp
80104293:	c3                   	ret    

80104294 <strlen>:

int
strlen(const char *s)
{
80104294:	f3 0f 1e fb          	endbr32 
80104298:	55                   	push   %ebp
80104299:	89 e5                	mov    %esp,%ebp
8010429b:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
8010429e:	b8 00 00 00 00       	mov    $0x0,%eax
801042a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801042a7:	74 05                	je     801042ae <strlen+0x1a>
801042a9:	83 c0 01             	add    $0x1,%eax
801042ac:	eb f5                	jmp    801042a3 <strlen+0xf>
    ;
  return n;
}
801042ae:	5d                   	pop    %ebp
801042af:	c3                   	ret    

801042b0 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801042b0:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801042b4:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801042b8:	55                   	push   %ebp
  pushl %ebx
801042b9:	53                   	push   %ebx
  pushl %esi
801042ba:	56                   	push   %esi
  pushl %edi
801042bb:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801042bc:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801042be:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801042c0:	5f                   	pop    %edi
  popl %esi
801042c1:	5e                   	pop    %esi
  popl %ebx
801042c2:	5b                   	pop    %ebx
  popl %ebp
801042c3:	5d                   	pop    %ebp
  ret
801042c4:	c3                   	ret    

801042c5 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801042c5:	f3 0f 1e fb          	endbr32 
801042c9:	55                   	push   %ebp
801042ca:	89 e5                	mov    %esp,%ebp
801042cc:	53                   	push   %ebx
801042cd:	83 ec 04             	sub    $0x4,%esp
801042d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801042d3:	e8 ca f2 ff ff       	call   801035a2 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801042d8:	8b 00                	mov    (%eax),%eax
801042da:	39 d8                	cmp    %ebx,%eax
801042dc:	76 19                	jbe    801042f7 <fetchint+0x32>
801042de:	8d 53 04             	lea    0x4(%ebx),%edx
801042e1:	39 d0                	cmp    %edx,%eax
801042e3:	72 19                	jb     801042fe <fetchint+0x39>
    return -1;
  *ip = *(int*)(addr);
801042e5:	8b 13                	mov    (%ebx),%edx
801042e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801042ea:	89 10                	mov    %edx,(%eax)
  return 0;
801042ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042f1:	83 c4 04             	add    $0x4,%esp
801042f4:	5b                   	pop    %ebx
801042f5:	5d                   	pop    %ebp
801042f6:	c3                   	ret    
    return -1;
801042f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042fc:	eb f3                	jmp    801042f1 <fetchint+0x2c>
801042fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104303:	eb ec                	jmp    801042f1 <fetchint+0x2c>

80104305 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104305:	f3 0f 1e fb          	endbr32 
80104309:	55                   	push   %ebp
8010430a:	89 e5                	mov    %esp,%ebp
8010430c:	53                   	push   %ebx
8010430d:	83 ec 04             	sub    $0x4,%esp
80104310:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104313:	e8 8a f2 ff ff       	call   801035a2 <myproc>

  if(addr >= curproc->sz)
80104318:	39 18                	cmp    %ebx,(%eax)
8010431a:	76 26                	jbe    80104342 <fetchstr+0x3d>
    return -1;
  *pp = (char*)addr;
8010431c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010431f:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104321:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104323:	89 d8                	mov    %ebx,%eax
80104325:	39 d0                	cmp    %edx,%eax
80104327:	73 0e                	jae    80104337 <fetchstr+0x32>
    if(*s == 0)
80104329:	80 38 00             	cmpb   $0x0,(%eax)
8010432c:	74 05                	je     80104333 <fetchstr+0x2e>
  for(s = *pp; s < ep; s++){
8010432e:	83 c0 01             	add    $0x1,%eax
80104331:	eb f2                	jmp    80104325 <fetchstr+0x20>
      return s - *pp;
80104333:	29 d8                	sub    %ebx,%eax
80104335:	eb 05                	jmp    8010433c <fetchstr+0x37>
  }
  return -1;
80104337:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010433c:	83 c4 04             	add    $0x4,%esp
8010433f:	5b                   	pop    %ebx
80104340:	5d                   	pop    %ebp
80104341:	c3                   	ret    
    return -1;
80104342:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104347:	eb f3                	jmp    8010433c <fetchstr+0x37>

80104349 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104349:	f3 0f 1e fb          	endbr32 
8010434d:	55                   	push   %ebp
8010434e:	89 e5                	mov    %esp,%ebp
80104350:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104353:	e8 4a f2 ff ff       	call   801035a2 <myproc>
80104358:	8b 50 18             	mov    0x18(%eax),%edx
8010435b:	8b 45 08             	mov    0x8(%ebp),%eax
8010435e:	c1 e0 02             	shl    $0x2,%eax
80104361:	03 42 44             	add    0x44(%edx),%eax
80104364:	83 ec 08             	sub    $0x8,%esp
80104367:	ff 75 0c             	pushl  0xc(%ebp)
8010436a:	83 c0 04             	add    $0x4,%eax
8010436d:	50                   	push   %eax
8010436e:	e8 52 ff ff ff       	call   801042c5 <fetchint>
}
80104373:	c9                   	leave  
80104374:	c3                   	ret    

80104375 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104375:	f3 0f 1e fb          	endbr32 
80104379:	55                   	push   %ebp
8010437a:	89 e5                	mov    %esp,%ebp
8010437c:	56                   	push   %esi
8010437d:	53                   	push   %ebx
8010437e:	83 ec 10             	sub    $0x10,%esp
80104381:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104384:	e8 19 f2 ff ff       	call   801035a2 <myproc>
80104389:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
8010438b:	83 ec 08             	sub    $0x8,%esp
8010438e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104391:	50                   	push   %eax
80104392:	ff 75 08             	pushl  0x8(%ebp)
80104395:	e8 af ff ff ff       	call   80104349 <argint>
8010439a:	83 c4 10             	add    $0x10,%esp
8010439d:	85 c0                	test   %eax,%eax
8010439f:	78 24                	js     801043c5 <argptr+0x50>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801043a1:	85 db                	test   %ebx,%ebx
801043a3:	78 27                	js     801043cc <argptr+0x57>
801043a5:	8b 16                	mov    (%esi),%edx
801043a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043aa:	39 c2                	cmp    %eax,%edx
801043ac:	76 25                	jbe    801043d3 <argptr+0x5e>
801043ae:	01 c3                	add    %eax,%ebx
801043b0:	39 da                	cmp    %ebx,%edx
801043b2:	72 26                	jb     801043da <argptr+0x65>
    return -1;
  *pp = (char*)i;
801043b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801043b7:	89 02                	mov    %eax,(%edx)
  return 0;
801043b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043be:	8d 65 f8             	lea    -0x8(%ebp),%esp
801043c1:	5b                   	pop    %ebx
801043c2:	5e                   	pop    %esi
801043c3:	5d                   	pop    %ebp
801043c4:	c3                   	ret    
    return -1;
801043c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043ca:	eb f2                	jmp    801043be <argptr+0x49>
    return -1;
801043cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043d1:	eb eb                	jmp    801043be <argptr+0x49>
801043d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043d8:	eb e4                	jmp    801043be <argptr+0x49>
801043da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043df:	eb dd                	jmp    801043be <argptr+0x49>

801043e1 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801043e1:	f3 0f 1e fb          	endbr32 
801043e5:	55                   	push   %ebp
801043e6:	89 e5                	mov    %esp,%ebp
801043e8:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801043eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801043ee:	50                   	push   %eax
801043ef:	ff 75 08             	pushl  0x8(%ebp)
801043f2:	e8 52 ff ff ff       	call   80104349 <argint>
801043f7:	83 c4 10             	add    $0x10,%esp
801043fa:	85 c0                	test   %eax,%eax
801043fc:	78 13                	js     80104411 <argstr+0x30>
    return -1;
  return fetchstr(addr, pp);
801043fe:	83 ec 08             	sub    $0x8,%esp
80104401:	ff 75 0c             	pushl  0xc(%ebp)
80104404:	ff 75 f4             	pushl  -0xc(%ebp)
80104407:	e8 f9 fe ff ff       	call   80104305 <fetchstr>
8010440c:	83 c4 10             	add    $0x10,%esp
}
8010440f:	c9                   	leave  
80104410:	c3                   	ret    
    return -1;
80104411:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104416:	eb f7                	jmp    8010440f <argstr+0x2e>

80104418 <syscall>:
[SYS_funlock] sys_funlock,
};

void
syscall(void)
{
80104418:	f3 0f 1e fb          	endbr32 
8010441c:	55                   	push   %ebp
8010441d:	89 e5                	mov    %esp,%ebp
8010441f:	53                   	push   %ebx
80104420:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104423:	e8 7a f1 ff ff       	call   801035a2 <myproc>
80104428:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010442a:	8b 40 18             	mov    0x18(%eax),%eax
8010442d:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104430:	8d 50 ff             	lea    -0x1(%eax),%edx
80104433:	83 fa 1a             	cmp    $0x1a,%edx
80104436:	77 17                	ja     8010444f <syscall+0x37>
80104438:	8b 14 85 00 78 10 80 	mov    -0x7fef8800(,%eax,4),%edx
8010443f:	85 d2                	test   %edx,%edx
80104441:	74 0c                	je     8010444f <syscall+0x37>
    curproc->tf->eax = syscalls[num]();
80104443:	ff d2                	call   *%edx
80104445:	89 c2                	mov    %eax,%edx
80104447:	8b 43 18             	mov    0x18(%ebx),%eax
8010444a:	89 50 1c             	mov    %edx,0x1c(%eax)
8010444d:	eb 1f                	jmp    8010446e <syscall+0x56>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010444f:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104452:	50                   	push   %eax
80104453:	52                   	push   %edx
80104454:	ff 73 10             	pushl  0x10(%ebx)
80104457:	68 d5 77 10 80       	push   $0x801077d5
8010445c:	e8 c8 c1 ff ff       	call   80100629 <cprintf>
    curproc->tf->eax = -1;
80104461:	8b 43 18             	mov    0x18(%ebx),%eax
80104464:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010446b:	83 c4 10             	add    $0x10,%esp
  }
}
8010446e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104471:	c9                   	leave  
80104472:	c3                   	ret    

80104473 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104473:	55                   	push   %ebp
80104474:	89 e5                	mov    %esp,%ebp
80104476:	56                   	push   %esi
80104477:	53                   	push   %ebx
80104478:	83 ec 18             	sub    $0x18,%esp
8010447b:	89 d6                	mov    %edx,%esi
8010447d:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010447f:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104482:	52                   	push   %edx
80104483:	50                   	push   %eax
80104484:	e8 c0 fe ff ff       	call   80104349 <argint>
80104489:	83 c4 10             	add    $0x10,%esp
8010448c:	85 c0                	test   %eax,%eax
8010448e:	78 35                	js     801044c5 <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104490:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104494:	77 28                	ja     801044be <argfd+0x4b>
80104496:	e8 07 f1 ff ff       	call   801035a2 <myproc>
8010449b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010449e:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
801044a2:	85 c0                	test   %eax,%eax
801044a4:	74 18                	je     801044be <argfd+0x4b>
    return -1;
  if(pfd)
801044a6:	85 f6                	test   %esi,%esi
801044a8:	74 02                	je     801044ac <argfd+0x39>
    *pfd = fd;
801044aa:	89 16                	mov    %edx,(%esi)
  if(pf)
801044ac:	85 db                	test   %ebx,%ebx
801044ae:	74 1c                	je     801044cc <argfd+0x59>
    *pf = f;
801044b0:	89 03                	mov    %eax,(%ebx)
  return 0;
801044b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801044b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801044ba:	5b                   	pop    %ebx
801044bb:	5e                   	pop    %esi
801044bc:	5d                   	pop    %ebp
801044bd:	c3                   	ret    
    return -1;
801044be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044c3:	eb f2                	jmp    801044b7 <argfd+0x44>
    return -1;
801044c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ca:	eb eb                	jmp    801044b7 <argfd+0x44>
  return 0;
801044cc:	b8 00 00 00 00       	mov    $0x0,%eax
801044d1:	eb e4                	jmp    801044b7 <argfd+0x44>

801044d3 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801044d3:	55                   	push   %ebp
801044d4:	89 e5                	mov    %esp,%ebp
801044d6:	53                   	push   %ebx
801044d7:	83 ec 04             	sub    $0x4,%esp
801044da:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801044dc:	e8 c1 f0 ff ff       	call   801035a2 <myproc>
801044e1:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
801044e3:	b8 00 00 00 00       	mov    $0x0,%eax
801044e8:	83 f8 0f             	cmp    $0xf,%eax
801044eb:	7f 12                	jg     801044ff <fdalloc+0x2c>
    if(curproc->ofile[fd] == 0){
801044ed:	83 7c 82 28 00       	cmpl   $0x0,0x28(%edx,%eax,4)
801044f2:	74 05                	je     801044f9 <fdalloc+0x26>
  for(fd = 0; fd < NOFILE; fd++){
801044f4:	83 c0 01             	add    $0x1,%eax
801044f7:	eb ef                	jmp    801044e8 <fdalloc+0x15>
      curproc->ofile[fd] = f;
801044f9:	89 5c 82 28          	mov    %ebx,0x28(%edx,%eax,4)
      return fd;
801044fd:	eb 05                	jmp    80104504 <fdalloc+0x31>
    }
  }
  return -1;
801044ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104504:	83 c4 04             	add    $0x4,%esp
80104507:	5b                   	pop    %ebx
80104508:	5d                   	pop    %ebp
80104509:	c3                   	ret    

8010450a <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010450a:	55                   	push   %ebp
8010450b:	89 e5                	mov    %esp,%ebp
8010450d:	56                   	push   %esi
8010450e:	53                   	push   %ebx
8010450f:	83 ec 10             	sub    $0x10,%esp
80104512:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104514:	b8 20 00 00 00       	mov    $0x20,%eax
80104519:	89 c6                	mov    %eax,%esi
8010451b:	39 83 98 00 00 00    	cmp    %eax,0x98(%ebx)
80104521:	76 2e                	jbe    80104551 <isdirempty+0x47>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104523:	6a 10                	push   $0x10
80104525:	50                   	push   %eax
80104526:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104529:	50                   	push   %eax
8010452a:	53                   	push   %ebx
8010452b:	e8 0e d4 ff ff       	call   8010193e <readi>
80104530:	83 c4 10             	add    $0x10,%esp
80104533:	83 f8 10             	cmp    $0x10,%eax
80104536:	75 0c                	jne    80104544 <isdirempty+0x3a>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104538:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010453d:	75 1e                	jne    8010455d <isdirempty+0x53>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010453f:	8d 46 10             	lea    0x10(%esi),%eax
80104542:	eb d5                	jmp    80104519 <isdirempty+0xf>
      panic("isdirempty: readi");
80104544:	83 ec 0c             	sub    $0xc,%esp
80104547:	68 70 78 10 80       	push   $0x80107870
8010454c:	e8 0b be ff ff       	call   8010035c <panic>
      return 0;
  }
  return 1;
80104551:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104556:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104559:	5b                   	pop    %ebx
8010455a:	5e                   	pop    %esi
8010455b:	5d                   	pop    %ebp
8010455c:	c3                   	ret    
      return 0;
8010455d:	b8 00 00 00 00       	mov    $0x0,%eax
80104562:	eb f2                	jmp    80104556 <isdirempty+0x4c>

80104564 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104564:	55                   	push   %ebp
80104565:	89 e5                	mov    %esp,%ebp
80104567:	57                   	push   %edi
80104568:	56                   	push   %esi
80104569:	53                   	push   %ebx
8010456a:	83 ec 34             	sub    $0x34,%esp
8010456d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104570:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104573:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104576:	8d 55 da             	lea    -0x26(%ebp),%edx
80104579:	52                   	push   %edx
8010457a:	50                   	push   %eax
8010457b:	e8 7d d8 ff ff       	call   80101dfd <nameiparent>
80104580:	89 c6                	mov    %eax,%esi
80104582:	83 c4 10             	add    $0x10,%esp
80104585:	85 c0                	test   %eax,%eax
80104587:	0f 84 45 01 00 00    	je     801046d2 <create+0x16e>
    return 0;
  ilock(dp);
8010458d:	83 ec 0c             	sub    $0xc,%esp
80104590:	50                   	push   %eax
80104591:	e8 6f d1 ff ff       	call   80101705 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104596:	83 c4 0c             	add    $0xc,%esp
80104599:	6a 00                	push   $0x0
8010459b:	8d 45 da             	lea    -0x26(%ebp),%eax
8010459e:	50                   	push   %eax
8010459f:	56                   	push   %esi
801045a0:	e8 fa d5 ff ff       	call   80101b9f <dirlookup>
801045a5:	89 c3                	mov    %eax,%ebx
801045a7:	83 c4 10             	add    $0x10,%esp
801045aa:	85 c0                	test   %eax,%eax
801045ac:	74 40                	je     801045ee <create+0x8a>
    iunlockput(dp);
801045ae:	83 ec 0c             	sub    $0xc,%esp
801045b1:	56                   	push   %esi
801045b2:	e8 2b d3 ff ff       	call   801018e2 <iunlockput>
    ilock(ip);
801045b7:	89 1c 24             	mov    %ebx,(%esp)
801045ba:	e8 46 d1 ff ff       	call   80101705 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801045bf:	83 c4 10             	add    $0x10,%esp
801045c2:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801045c7:	75 0a                	jne    801045d3 <create+0x6f>
801045c9:	66 83 bb 90 00 00 00 	cmpw   $0x2,0x90(%ebx)
801045d0:	02 
801045d1:	74 11                	je     801045e4 <create+0x80>
      return ip;
    iunlockput(ip);
801045d3:	83 ec 0c             	sub    $0xc,%esp
801045d6:	53                   	push   %ebx
801045d7:	e8 06 d3 ff ff       	call   801018e2 <iunlockput>
    return 0;
801045dc:	83 c4 10             	add    $0x10,%esp
801045df:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801045e4:	89 d8                	mov    %ebx,%eax
801045e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801045e9:	5b                   	pop    %ebx
801045ea:	5e                   	pop    %esi
801045eb:	5f                   	pop    %edi
801045ec:	5d                   	pop    %ebp
801045ed:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
801045ee:	83 ec 08             	sub    $0x8,%esp
801045f1:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
801045f5:	50                   	push   %eax
801045f6:	ff 36                	pushl  (%esi)
801045f8:	e8 60 ce ff ff       	call   8010145d <ialloc>
801045fd:	89 c3                	mov    %eax,%ebx
801045ff:	83 c4 10             	add    $0x10,%esp
80104602:	85 c0                	test   %eax,%eax
80104604:	74 5b                	je     80104661 <create+0xfd>
  ilock(ip);
80104606:	83 ec 0c             	sub    $0xc,%esp
80104609:	50                   	push   %eax
8010460a:	e8 f6 d0 ff ff       	call   80101705 <ilock>
  ip->major = major;
8010460f:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104613:	66 89 83 92 00 00 00 	mov    %ax,0x92(%ebx)
  ip->minor = minor;
8010461a:	66 89 bb 94 00 00 00 	mov    %di,0x94(%ebx)
  ip->nlink = 1;
80104621:	66 c7 83 96 00 00 00 	movw   $0x1,0x96(%ebx)
80104628:	01 00 
  iupdate(ip);
8010462a:	89 1c 24             	mov    %ebx,(%esp)
8010462d:	e8 d1 ce ff ff       	call   80101503 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104632:	83 c4 10             	add    $0x10,%esp
80104635:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010463a:	74 32                	je     8010466e <create+0x10a>
  if(dirlink(dp, name, ip->inum) < 0)
8010463c:	83 ec 04             	sub    $0x4,%esp
8010463f:	ff 73 04             	pushl  0x4(%ebx)
80104642:	8d 45 da             	lea    -0x26(%ebp),%eax
80104645:	50                   	push   %eax
80104646:	56                   	push   %esi
80104647:	e8 dd d6 ff ff       	call   80101d29 <dirlink>
8010464c:	83 c4 10             	add    $0x10,%esp
8010464f:	85 c0                	test   %eax,%eax
80104651:	78 72                	js     801046c5 <create+0x161>
  iunlockput(dp);
80104653:	83 ec 0c             	sub    $0xc,%esp
80104656:	56                   	push   %esi
80104657:	e8 86 d2 ff ff       	call   801018e2 <iunlockput>
  return ip;
8010465c:	83 c4 10             	add    $0x10,%esp
8010465f:	eb 83                	jmp    801045e4 <create+0x80>
    panic("create: ialloc");
80104661:	83 ec 0c             	sub    $0xc,%esp
80104664:	68 82 78 10 80       	push   $0x80107882
80104669:	e8 ee bc ff ff       	call   8010035c <panic>
    dp->nlink++;  // for ".."
8010466e:	0f b7 86 96 00 00 00 	movzwl 0x96(%esi),%eax
80104675:	83 c0 01             	add    $0x1,%eax
80104678:	66 89 86 96 00 00 00 	mov    %ax,0x96(%esi)
    iupdate(dp);
8010467f:	83 ec 0c             	sub    $0xc,%esp
80104682:	56                   	push   %esi
80104683:	e8 7b ce ff ff       	call   80101503 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104688:	83 c4 0c             	add    $0xc,%esp
8010468b:	ff 73 04             	pushl  0x4(%ebx)
8010468e:	68 92 78 10 80       	push   $0x80107892
80104693:	53                   	push   %ebx
80104694:	e8 90 d6 ff ff       	call   80101d29 <dirlink>
80104699:	83 c4 10             	add    $0x10,%esp
8010469c:	85 c0                	test   %eax,%eax
8010469e:	78 18                	js     801046b8 <create+0x154>
801046a0:	83 ec 04             	sub    $0x4,%esp
801046a3:	ff 76 04             	pushl  0x4(%esi)
801046a6:	68 91 78 10 80       	push   $0x80107891
801046ab:	53                   	push   %ebx
801046ac:	e8 78 d6 ff ff       	call   80101d29 <dirlink>
801046b1:	83 c4 10             	add    $0x10,%esp
801046b4:	85 c0                	test   %eax,%eax
801046b6:	79 84                	jns    8010463c <create+0xd8>
      panic("create dots");
801046b8:	83 ec 0c             	sub    $0xc,%esp
801046bb:	68 94 78 10 80       	push   $0x80107894
801046c0:	e8 97 bc ff ff       	call   8010035c <panic>
    panic("create: dirlink");
801046c5:	83 ec 0c             	sub    $0xc,%esp
801046c8:	68 a0 78 10 80       	push   $0x801078a0
801046cd:	e8 8a bc ff ff       	call   8010035c <panic>
    return 0;
801046d2:	89 c3                	mov    %eax,%ebx
801046d4:	e9 0b ff ff ff       	jmp    801045e4 <create+0x80>

801046d9 <sys_dup>:
{
801046d9:	f3 0f 1e fb          	endbr32 
801046dd:	55                   	push   %ebp
801046de:	89 e5                	mov    %esp,%ebp
801046e0:	53                   	push   %ebx
801046e1:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801046e4:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801046e7:	ba 00 00 00 00       	mov    $0x0,%edx
801046ec:	b8 00 00 00 00       	mov    $0x0,%eax
801046f1:	e8 7d fd ff ff       	call   80104473 <argfd>
801046f6:	85 c0                	test   %eax,%eax
801046f8:	78 23                	js     8010471d <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
801046fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fd:	e8 d1 fd ff ff       	call   801044d3 <fdalloc>
80104702:	89 c3                	mov    %eax,%ebx
80104704:	85 c0                	test   %eax,%eax
80104706:	78 1c                	js     80104724 <sys_dup+0x4b>
  filedup(f);
80104708:	83 ec 0c             	sub    $0xc,%esp
8010470b:	ff 75 f4             	pushl  -0xc(%ebp)
8010470e:	e8 a9 c5 ff ff       	call   80100cbc <filedup>
  return fd;
80104713:	83 c4 10             	add    $0x10,%esp
}
80104716:	89 d8                	mov    %ebx,%eax
80104718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010471b:	c9                   	leave  
8010471c:	c3                   	ret    
    return -1;
8010471d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104722:	eb f2                	jmp    80104716 <sys_dup+0x3d>
    return -1;
80104724:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104729:	eb eb                	jmp    80104716 <sys_dup+0x3d>

8010472b <sys_read>:
{
8010472b:	f3 0f 1e fb          	endbr32 
8010472f:	55                   	push   %ebp
80104730:	89 e5                	mov    %esp,%ebp
80104732:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104735:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104738:	ba 00 00 00 00       	mov    $0x0,%edx
8010473d:	b8 00 00 00 00       	mov    $0x0,%eax
80104742:	e8 2c fd ff ff       	call   80104473 <argfd>
80104747:	85 c0                	test   %eax,%eax
80104749:	78 43                	js     8010478e <sys_read+0x63>
8010474b:	83 ec 08             	sub    $0x8,%esp
8010474e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104751:	50                   	push   %eax
80104752:	6a 02                	push   $0x2
80104754:	e8 f0 fb ff ff       	call   80104349 <argint>
80104759:	83 c4 10             	add    $0x10,%esp
8010475c:	85 c0                	test   %eax,%eax
8010475e:	78 2e                	js     8010478e <sys_read+0x63>
80104760:	83 ec 04             	sub    $0x4,%esp
80104763:	ff 75 f0             	pushl  -0x10(%ebp)
80104766:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104769:	50                   	push   %eax
8010476a:	6a 01                	push   $0x1
8010476c:	e8 04 fc ff ff       	call   80104375 <argptr>
80104771:	83 c4 10             	add    $0x10,%esp
80104774:	85 c0                	test   %eax,%eax
80104776:	78 16                	js     8010478e <sys_read+0x63>
  return fileread(f, p, n);
80104778:	83 ec 04             	sub    $0x4,%esp
8010477b:	ff 75 f0             	pushl  -0x10(%ebp)
8010477e:	ff 75 ec             	pushl  -0x14(%ebp)
80104781:	ff 75 f4             	pushl  -0xc(%ebp)
80104784:	e8 85 c6 ff ff       	call   80100e0e <fileread>
80104789:	83 c4 10             	add    $0x10,%esp
}
8010478c:	c9                   	leave  
8010478d:	c3                   	ret    
    return -1;
8010478e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104793:	eb f7                	jmp    8010478c <sys_read+0x61>

80104795 <sys_write>:
{
80104795:	f3 0f 1e fb          	endbr32 
80104799:	55                   	push   %ebp
8010479a:	89 e5                	mov    %esp,%ebp
8010479c:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010479f:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801047a2:	ba 00 00 00 00       	mov    $0x0,%edx
801047a7:	b8 00 00 00 00       	mov    $0x0,%eax
801047ac:	e8 c2 fc ff ff       	call   80104473 <argfd>
801047b1:	85 c0                	test   %eax,%eax
801047b3:	78 43                	js     801047f8 <sys_write+0x63>
801047b5:	83 ec 08             	sub    $0x8,%esp
801047b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801047bb:	50                   	push   %eax
801047bc:	6a 02                	push   $0x2
801047be:	e8 86 fb ff ff       	call   80104349 <argint>
801047c3:	83 c4 10             	add    $0x10,%esp
801047c6:	85 c0                	test   %eax,%eax
801047c8:	78 2e                	js     801047f8 <sys_write+0x63>
801047ca:	83 ec 04             	sub    $0x4,%esp
801047cd:	ff 75 f0             	pushl  -0x10(%ebp)
801047d0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801047d3:	50                   	push   %eax
801047d4:	6a 01                	push   $0x1
801047d6:	e8 9a fb ff ff       	call   80104375 <argptr>
801047db:	83 c4 10             	add    $0x10,%esp
801047de:	85 c0                	test   %eax,%eax
801047e0:	78 16                	js     801047f8 <sys_write+0x63>
  return filewrite(f, p, n);
801047e2:	83 ec 04             	sub    $0x4,%esp
801047e5:	ff 75 f0             	pushl  -0x10(%ebp)
801047e8:	ff 75 ec             	pushl  -0x14(%ebp)
801047eb:	ff 75 f4             	pushl  -0xc(%ebp)
801047ee:	e8 a4 c6 ff ff       	call   80100e97 <filewrite>
801047f3:	83 c4 10             	add    $0x10,%esp
}
801047f6:	c9                   	leave  
801047f7:	c3                   	ret    
    return -1;
801047f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047fd:	eb f7                	jmp    801047f6 <sys_write+0x61>

801047ff <sys_flock>:
sys_flock(void) {
801047ff:	f3 0f 1e fb          	endbr32 
80104803:	55                   	push   %ebp
80104804:	89 e5                	mov    %esp,%ebp
80104806:	83 ec 18             	sub    $0x18,%esp
   if(argfd(0, 0, &fp) >= 0) {
80104809:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010480c:	ba 00 00 00 00       	mov    $0x0,%edx
80104811:	b8 00 00 00 00       	mov    $0x0,%eax
80104816:	e8 58 fc ff ff       	call   80104473 <argfd>
8010481b:	85 c0                	test   %eax,%eax
8010481d:	78 10                	js     8010482f <sys_flock+0x30>
     return filelock(fp);
8010481f:	83 ec 0c             	sub    $0xc,%esp
80104822:	ff 75 f4             	pushl  -0xc(%ebp)
80104825:	e8 5a c7 ff ff       	call   80100f84 <filelock>
8010482a:	83 c4 10             	add    $0x10,%esp
}
8010482d:	c9                   	leave  
8010482e:	c3                   	ret    
   return -1;
8010482f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104834:	eb f7                	jmp    8010482d <sys_flock+0x2e>

80104836 <sys_funlock>:
sys_funlock(void) {
80104836:	f3 0f 1e fb          	endbr32 
8010483a:	55                   	push   %ebp
8010483b:	89 e5                	mov    %esp,%ebp
8010483d:	83 ec 18             	sub    $0x18,%esp
   if(argfd(0, 0, &fp) >= 0) {
80104840:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104843:	ba 00 00 00 00       	mov    $0x0,%edx
80104848:	b8 00 00 00 00       	mov    $0x0,%eax
8010484d:	e8 21 fc ff ff       	call   80104473 <argfd>
80104852:	85 c0                	test   %eax,%eax
80104854:	78 10                	js     80104866 <sys_funlock+0x30>
     return fileunlock(fp);
80104856:	83 ec 0c             	sub    $0xc,%esp
80104859:	ff 75 f4             	pushl  -0xc(%ebp)
8010485c:	e8 5e c7 ff ff       	call   80100fbf <fileunlock>
80104861:	83 c4 10             	add    $0x10,%esp
}
80104864:	c9                   	leave  
80104865:	c3                   	ret    
   return -1;
80104866:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010486b:	eb f7                	jmp    80104864 <sys_funlock+0x2e>

8010486d <sys_close>:
{
8010486d:	f3 0f 1e fb          	endbr32 
80104871:	55                   	push   %ebp
80104872:	89 e5                	mov    %esp,%ebp
80104874:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104877:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010487a:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010487d:	b8 00 00 00 00       	mov    $0x0,%eax
80104882:	e8 ec fb ff ff       	call   80104473 <argfd>
80104887:	85 c0                	test   %eax,%eax
80104889:	78 25                	js     801048b0 <sys_close+0x43>
  myproc()->ofile[fd] = 0;
8010488b:	e8 12 ed ff ff       	call   801035a2 <myproc>
80104890:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104893:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010489a:	00 
  fileclose(f);
8010489b:	83 ec 0c             	sub    $0xc,%esp
8010489e:	ff 75 f0             	pushl  -0x10(%ebp)
801048a1:	e8 5f c4 ff ff       	call   80100d05 <fileclose>
  return 0;
801048a6:	83 c4 10             	add    $0x10,%esp
801048a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048ae:	c9                   	leave  
801048af:	c3                   	ret    
    return -1;
801048b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048b5:	eb f7                	jmp    801048ae <sys_close+0x41>

801048b7 <sys_fstat>:
{
801048b7:	f3 0f 1e fb          	endbr32 
801048bb:	55                   	push   %ebp
801048bc:	89 e5                	mov    %esp,%ebp
801048be:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801048c1:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801048c4:	ba 00 00 00 00       	mov    $0x0,%edx
801048c9:	b8 00 00 00 00       	mov    $0x0,%eax
801048ce:	e8 a0 fb ff ff       	call   80104473 <argfd>
801048d3:	85 c0                	test   %eax,%eax
801048d5:	78 2a                	js     80104901 <sys_fstat+0x4a>
801048d7:	83 ec 04             	sub    $0x4,%esp
801048da:	6a 14                	push   $0x14
801048dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801048df:	50                   	push   %eax
801048e0:	6a 01                	push   $0x1
801048e2:	e8 8e fa ff ff       	call   80104375 <argptr>
801048e7:	83 c4 10             	add    $0x10,%esp
801048ea:	85 c0                	test   %eax,%eax
801048ec:	78 13                	js     80104901 <sys_fstat+0x4a>
  return filestat(f, st);
801048ee:	83 ec 08             	sub    $0x8,%esp
801048f1:	ff 75 f0             	pushl  -0x10(%ebp)
801048f4:	ff 75 f4             	pushl  -0xc(%ebp)
801048f7:	e8 c7 c4 ff ff       	call   80100dc3 <filestat>
801048fc:	83 c4 10             	add    $0x10,%esp
}
801048ff:	c9                   	leave  
80104900:	c3                   	ret    
    return -1;
80104901:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104906:	eb f7                	jmp    801048ff <sys_fstat+0x48>

80104908 <sys_link>:
{
80104908:	f3 0f 1e fb          	endbr32 
8010490c:	55                   	push   %ebp
8010490d:	89 e5                	mov    %esp,%ebp
8010490f:	56                   	push   %esi
80104910:	53                   	push   %ebx
80104911:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104914:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104917:	50                   	push   %eax
80104918:	6a 00                	push   $0x0
8010491a:	e8 c2 fa ff ff       	call   801043e1 <argstr>
8010491f:	83 c4 10             	add    $0x10,%esp
80104922:	85 c0                	test   %eax,%eax
80104924:	0f 88 dc 00 00 00    	js     80104a06 <sys_link+0xfe>
8010492a:	83 ec 08             	sub    $0x8,%esp
8010492d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104930:	50                   	push   %eax
80104931:	6a 01                	push   $0x1
80104933:	e8 a9 fa ff ff       	call   801043e1 <argstr>
80104938:	83 c4 10             	add    $0x10,%esp
8010493b:	85 c0                	test   %eax,%eax
8010493d:	0f 88 c3 00 00 00    	js     80104a06 <sys_link+0xfe>
  begin_op();
80104943:	e8 cf e0 ff ff       	call   80102a17 <begin_op>
  if((ip = namei(old)) == 0){
80104948:	83 ec 0c             	sub    $0xc,%esp
8010494b:	ff 75 e0             	pushl  -0x20(%ebp)
8010494e:	e8 8e d4 ff ff       	call   80101de1 <namei>
80104953:	89 c3                	mov    %eax,%ebx
80104955:	83 c4 10             	add    $0x10,%esp
80104958:	85 c0                	test   %eax,%eax
8010495a:	0f 84 ad 00 00 00    	je     80104a0d <sys_link+0x105>
  ilock(ip);
80104960:	83 ec 0c             	sub    $0xc,%esp
80104963:	50                   	push   %eax
80104964:	e8 9c cd ff ff       	call   80101705 <ilock>
  if(ip->type == T_DIR){
80104969:	83 c4 10             	add    $0x10,%esp
8010496c:	66 83 bb 90 00 00 00 	cmpw   $0x1,0x90(%ebx)
80104973:	01 
80104974:	0f 84 9f 00 00 00    	je     80104a19 <sys_link+0x111>
  ip->nlink++;
8010497a:	0f b7 83 96 00 00 00 	movzwl 0x96(%ebx),%eax
80104981:	83 c0 01             	add    $0x1,%eax
80104984:	66 89 83 96 00 00 00 	mov    %ax,0x96(%ebx)
  iupdate(ip);
8010498b:	83 ec 0c             	sub    $0xc,%esp
8010498e:	53                   	push   %ebx
8010498f:	e8 6f cb ff ff       	call   80101503 <iupdate>
  iunlock(ip);
80104994:	89 1c 24             	mov    %ebx,(%esp)
80104997:	e8 4a ce ff ff       	call   801017e6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
8010499c:	83 c4 08             	add    $0x8,%esp
8010499f:	8d 45 ea             	lea    -0x16(%ebp),%eax
801049a2:	50                   	push   %eax
801049a3:	ff 75 e4             	pushl  -0x1c(%ebp)
801049a6:	e8 52 d4 ff ff       	call   80101dfd <nameiparent>
801049ab:	89 c6                	mov    %eax,%esi
801049ad:	83 c4 10             	add    $0x10,%esp
801049b0:	85 c0                	test   %eax,%eax
801049b2:	0f 84 85 00 00 00    	je     80104a3d <sys_link+0x135>
  ilock(dp);
801049b8:	83 ec 0c             	sub    $0xc,%esp
801049bb:	50                   	push   %eax
801049bc:	e8 44 cd ff ff       	call   80101705 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801049c1:	83 c4 10             	add    $0x10,%esp
801049c4:	8b 03                	mov    (%ebx),%eax
801049c6:	39 06                	cmp    %eax,(%esi)
801049c8:	75 67                	jne    80104a31 <sys_link+0x129>
801049ca:	83 ec 04             	sub    $0x4,%esp
801049cd:	ff 73 04             	pushl  0x4(%ebx)
801049d0:	8d 45 ea             	lea    -0x16(%ebp),%eax
801049d3:	50                   	push   %eax
801049d4:	56                   	push   %esi
801049d5:	e8 4f d3 ff ff       	call   80101d29 <dirlink>
801049da:	83 c4 10             	add    $0x10,%esp
801049dd:	85 c0                	test   %eax,%eax
801049df:	78 50                	js     80104a31 <sys_link+0x129>
  iunlockput(dp);
801049e1:	83 ec 0c             	sub    $0xc,%esp
801049e4:	56                   	push   %esi
801049e5:	e8 f8 ce ff ff       	call   801018e2 <iunlockput>
  iput(ip);
801049ea:	89 1c 24             	mov    %ebx,(%esp)
801049ed:	e8 3d ce ff ff       	call   8010182f <iput>
  end_op();
801049f2:	e8 9e e0 ff ff       	call   80102a95 <end_op>
  return 0;
801049f7:	83 c4 10             	add    $0x10,%esp
801049fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a02:	5b                   	pop    %ebx
80104a03:	5e                   	pop    %esi
80104a04:	5d                   	pop    %ebp
80104a05:	c3                   	ret    
    return -1;
80104a06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a0b:	eb f2                	jmp    801049ff <sys_link+0xf7>
    end_op();
80104a0d:	e8 83 e0 ff ff       	call   80102a95 <end_op>
    return -1;
80104a12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a17:	eb e6                	jmp    801049ff <sys_link+0xf7>
    iunlockput(ip);
80104a19:	83 ec 0c             	sub    $0xc,%esp
80104a1c:	53                   	push   %ebx
80104a1d:	e8 c0 ce ff ff       	call   801018e2 <iunlockput>
    end_op();
80104a22:	e8 6e e0 ff ff       	call   80102a95 <end_op>
    return -1;
80104a27:	83 c4 10             	add    $0x10,%esp
80104a2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a2f:	eb ce                	jmp    801049ff <sys_link+0xf7>
    iunlockput(dp);
80104a31:	83 ec 0c             	sub    $0xc,%esp
80104a34:	56                   	push   %esi
80104a35:	e8 a8 ce ff ff       	call   801018e2 <iunlockput>
    goto bad;
80104a3a:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104a3d:	83 ec 0c             	sub    $0xc,%esp
80104a40:	53                   	push   %ebx
80104a41:	e8 bf cc ff ff       	call   80101705 <ilock>
  ip->nlink--;
80104a46:	0f b7 83 96 00 00 00 	movzwl 0x96(%ebx),%eax
80104a4d:	83 e8 01             	sub    $0x1,%eax
80104a50:	66 89 83 96 00 00 00 	mov    %ax,0x96(%ebx)
  iupdate(ip);
80104a57:	89 1c 24             	mov    %ebx,(%esp)
80104a5a:	e8 a4 ca ff ff       	call   80101503 <iupdate>
  iunlockput(ip);
80104a5f:	89 1c 24             	mov    %ebx,(%esp)
80104a62:	e8 7b ce ff ff       	call   801018e2 <iunlockput>
  end_op();
80104a67:	e8 29 e0 ff ff       	call   80102a95 <end_op>
  return -1;
80104a6c:	83 c4 10             	add    $0x10,%esp
80104a6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a74:	eb 89                	jmp    801049ff <sys_link+0xf7>

80104a76 <sys_unlink>:
{
80104a76:	f3 0f 1e fb          	endbr32 
80104a7a:	55                   	push   %ebp
80104a7b:	89 e5                	mov    %esp,%ebp
80104a7d:	57                   	push   %edi
80104a7e:	56                   	push   %esi
80104a7f:	53                   	push   %ebx
80104a80:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104a83:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104a86:	50                   	push   %eax
80104a87:	6a 00                	push   $0x0
80104a89:	e8 53 f9 ff ff       	call   801043e1 <argstr>
80104a8e:	83 c4 10             	add    $0x10,%esp
80104a91:	85 c0                	test   %eax,%eax
80104a93:	0f 88 98 01 00 00    	js     80104c31 <sys_unlink+0x1bb>
  begin_op();
80104a99:	e8 79 df ff ff       	call   80102a17 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104a9e:	83 ec 08             	sub    $0x8,%esp
80104aa1:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104aa4:	50                   	push   %eax
80104aa5:	ff 75 c4             	pushl  -0x3c(%ebp)
80104aa8:	e8 50 d3 ff ff       	call   80101dfd <nameiparent>
80104aad:	89 c6                	mov    %eax,%esi
80104aaf:	83 c4 10             	add    $0x10,%esp
80104ab2:	85 c0                	test   %eax,%eax
80104ab4:	0f 84 fc 00 00 00    	je     80104bb6 <sys_unlink+0x140>
  ilock(dp);
80104aba:	83 ec 0c             	sub    $0xc,%esp
80104abd:	50                   	push   %eax
80104abe:	e8 42 cc ff ff       	call   80101705 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104ac3:	83 c4 08             	add    $0x8,%esp
80104ac6:	68 92 78 10 80       	push   $0x80107892
80104acb:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104ace:	50                   	push   %eax
80104acf:	e8 b2 d0 ff ff       	call   80101b86 <namecmp>
80104ad4:	83 c4 10             	add    $0x10,%esp
80104ad7:	85 c0                	test   %eax,%eax
80104ad9:	0f 84 0b 01 00 00    	je     80104bea <sys_unlink+0x174>
80104adf:	83 ec 08             	sub    $0x8,%esp
80104ae2:	68 91 78 10 80       	push   $0x80107891
80104ae7:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104aea:	50                   	push   %eax
80104aeb:	e8 96 d0 ff ff       	call   80101b86 <namecmp>
80104af0:	83 c4 10             	add    $0x10,%esp
80104af3:	85 c0                	test   %eax,%eax
80104af5:	0f 84 ef 00 00 00    	je     80104bea <sys_unlink+0x174>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104afb:	83 ec 04             	sub    $0x4,%esp
80104afe:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104b01:	50                   	push   %eax
80104b02:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104b05:	50                   	push   %eax
80104b06:	56                   	push   %esi
80104b07:	e8 93 d0 ff ff       	call   80101b9f <dirlookup>
80104b0c:	89 c3                	mov    %eax,%ebx
80104b0e:	83 c4 10             	add    $0x10,%esp
80104b11:	85 c0                	test   %eax,%eax
80104b13:	0f 84 d1 00 00 00    	je     80104bea <sys_unlink+0x174>
  ilock(ip);
80104b19:	83 ec 0c             	sub    $0xc,%esp
80104b1c:	50                   	push   %eax
80104b1d:	e8 e3 cb ff ff       	call   80101705 <ilock>
  if(ip->nlink < 1)
80104b22:	83 c4 10             	add    $0x10,%esp
80104b25:	66 83 bb 96 00 00 00 	cmpw   $0x0,0x96(%ebx)
80104b2c:	00 
80104b2d:	0f 8e 8f 00 00 00    	jle    80104bc2 <sys_unlink+0x14c>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104b33:	66 83 bb 90 00 00 00 	cmpw   $0x1,0x90(%ebx)
80104b3a:	01 
80104b3b:	0f 84 8e 00 00 00    	je     80104bcf <sys_unlink+0x159>
  memset(&de, 0, sizeof(de));
80104b41:	83 ec 04             	sub    $0x4,%esp
80104b44:	6a 10                	push   $0x10
80104b46:	6a 00                	push   $0x0
80104b48:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104b4b:	57                   	push   %edi
80104b4c:	e8 82 f5 ff ff       	call   801040d3 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104b51:	6a 10                	push   $0x10
80104b53:	ff 75 c0             	pushl  -0x40(%ebp)
80104b56:	57                   	push   %edi
80104b57:	56                   	push   %esi
80104b58:	e8 eb ce ff ff       	call   80101a48 <writei>
80104b5d:	83 c4 20             	add    $0x20,%esp
80104b60:	83 f8 10             	cmp    $0x10,%eax
80104b63:	0f 85 99 00 00 00    	jne    80104c02 <sys_unlink+0x18c>
  if(ip->type == T_DIR){
80104b69:	66 83 bb 90 00 00 00 	cmpw   $0x1,0x90(%ebx)
80104b70:	01 
80104b71:	0f 84 98 00 00 00    	je     80104c0f <sys_unlink+0x199>
  iunlockput(dp);
80104b77:	83 ec 0c             	sub    $0xc,%esp
80104b7a:	56                   	push   %esi
80104b7b:	e8 62 cd ff ff       	call   801018e2 <iunlockput>
  ip->nlink--;
80104b80:	0f b7 83 96 00 00 00 	movzwl 0x96(%ebx),%eax
80104b87:	83 e8 01             	sub    $0x1,%eax
80104b8a:	66 89 83 96 00 00 00 	mov    %ax,0x96(%ebx)
  iupdate(ip);
80104b91:	89 1c 24             	mov    %ebx,(%esp)
80104b94:	e8 6a c9 ff ff       	call   80101503 <iupdate>
  iunlockput(ip);
80104b99:	89 1c 24             	mov    %ebx,(%esp)
80104b9c:	e8 41 cd ff ff       	call   801018e2 <iunlockput>
  end_op();
80104ba1:	e8 ef de ff ff       	call   80102a95 <end_op>
  return 0;
80104ba6:	83 c4 10             	add    $0x10,%esp
80104ba9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104bb1:	5b                   	pop    %ebx
80104bb2:	5e                   	pop    %esi
80104bb3:	5f                   	pop    %edi
80104bb4:	5d                   	pop    %ebp
80104bb5:	c3                   	ret    
    end_op();
80104bb6:	e8 da de ff ff       	call   80102a95 <end_op>
    return -1;
80104bbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bc0:	eb ec                	jmp    80104bae <sys_unlink+0x138>
    panic("unlink: nlink < 1");
80104bc2:	83 ec 0c             	sub    $0xc,%esp
80104bc5:	68 b0 78 10 80       	push   $0x801078b0
80104bca:	e8 8d b7 ff ff       	call   8010035c <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104bcf:	89 d8                	mov    %ebx,%eax
80104bd1:	e8 34 f9 ff ff       	call   8010450a <isdirempty>
80104bd6:	85 c0                	test   %eax,%eax
80104bd8:	0f 85 63 ff ff ff    	jne    80104b41 <sys_unlink+0xcb>
    iunlockput(ip);
80104bde:	83 ec 0c             	sub    $0xc,%esp
80104be1:	53                   	push   %ebx
80104be2:	e8 fb cc ff ff       	call   801018e2 <iunlockput>
    goto bad;
80104be7:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104bea:	83 ec 0c             	sub    $0xc,%esp
80104bed:	56                   	push   %esi
80104bee:	e8 ef cc ff ff       	call   801018e2 <iunlockput>
  end_op();
80104bf3:	e8 9d de ff ff       	call   80102a95 <end_op>
  return -1;
80104bf8:	83 c4 10             	add    $0x10,%esp
80104bfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c00:	eb ac                	jmp    80104bae <sys_unlink+0x138>
    panic("unlink: writei");
80104c02:	83 ec 0c             	sub    $0xc,%esp
80104c05:	68 c2 78 10 80       	push   $0x801078c2
80104c0a:	e8 4d b7 ff ff       	call   8010035c <panic>
    dp->nlink--;
80104c0f:	0f b7 86 96 00 00 00 	movzwl 0x96(%esi),%eax
80104c16:	83 e8 01             	sub    $0x1,%eax
80104c19:	66 89 86 96 00 00 00 	mov    %ax,0x96(%esi)
    iupdate(dp);
80104c20:	83 ec 0c             	sub    $0xc,%esp
80104c23:	56                   	push   %esi
80104c24:	e8 da c8 ff ff       	call   80101503 <iupdate>
80104c29:	83 c4 10             	add    $0x10,%esp
80104c2c:	e9 46 ff ff ff       	jmp    80104b77 <sys_unlink+0x101>
    return -1;
80104c31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c36:	e9 73 ff ff ff       	jmp    80104bae <sys_unlink+0x138>

80104c3b <sys_open>:

int
sys_open(void)
{
80104c3b:	f3 0f 1e fb          	endbr32 
80104c3f:	55                   	push   %ebp
80104c40:	89 e5                	mov    %esp,%ebp
80104c42:	57                   	push   %edi
80104c43:	56                   	push   %esi
80104c44:	53                   	push   %ebx
80104c45:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104c48:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104c4b:	50                   	push   %eax
80104c4c:	6a 00                	push   $0x0
80104c4e:	e8 8e f7 ff ff       	call   801043e1 <argstr>
80104c53:	83 c4 10             	add    $0x10,%esp
80104c56:	85 c0                	test   %eax,%eax
80104c58:	0f 88 a0 00 00 00    	js     80104cfe <sys_open+0xc3>
80104c5e:	83 ec 08             	sub    $0x8,%esp
80104c61:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104c64:	50                   	push   %eax
80104c65:	6a 01                	push   $0x1
80104c67:	e8 dd f6 ff ff       	call   80104349 <argint>
80104c6c:	83 c4 10             	add    $0x10,%esp
80104c6f:	85 c0                	test   %eax,%eax
80104c71:	0f 88 87 00 00 00    	js     80104cfe <sys_open+0xc3>
    return -1;

  begin_op();
80104c77:	e8 9b dd ff ff       	call   80102a17 <begin_op>

  if(omode & O_CREATE){
80104c7c:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104c80:	0f 84 8b 00 00 00    	je     80104d11 <sys_open+0xd6>
    ip = create(path, T_FILE, 0, 0);
80104c86:	83 ec 0c             	sub    $0xc,%esp
80104c89:	6a 00                	push   $0x0
80104c8b:	b9 00 00 00 00       	mov    $0x0,%ecx
80104c90:	ba 02 00 00 00       	mov    $0x2,%edx
80104c95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104c98:	e8 c7 f8 ff ff       	call   80104564 <create>
80104c9d:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104c9f:	83 c4 10             	add    $0x10,%esp
80104ca2:	85 c0                	test   %eax,%eax
80104ca4:	74 5f                	je     80104d05 <sys_open+0xca>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104ca6:	e8 ac bf ff ff       	call   80100c57 <filealloc>
80104cab:	89 c3                	mov    %eax,%ebx
80104cad:	85 c0                	test   %eax,%eax
80104caf:	0f 84 b8 00 00 00    	je     80104d6d <sys_open+0x132>
80104cb5:	e8 19 f8 ff ff       	call   801044d3 <fdalloc>
80104cba:	89 c7                	mov    %eax,%edi
80104cbc:	85 c0                	test   %eax,%eax
80104cbe:	0f 88 a9 00 00 00    	js     80104d6d <sys_open+0x132>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104cc4:	83 ec 0c             	sub    $0xc,%esp
80104cc7:	56                   	push   %esi
80104cc8:	e8 19 cb ff ff       	call   801017e6 <iunlock>
  end_op();
80104ccd:	e8 c3 dd ff ff       	call   80102a95 <end_op>

  f->type = FD_INODE;
80104cd2:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104cd8:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104cdb:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104ce2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ce5:	83 c4 10             	add    $0x10,%esp
80104ce8:	a8 01                	test   $0x1,%al
80104cea:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104cee:	a8 03                	test   $0x3,%al
80104cf0:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104cf4:	89 f8                	mov    %edi,%eax
80104cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104cf9:	5b                   	pop    %ebx
80104cfa:	5e                   	pop    %esi
80104cfb:	5f                   	pop    %edi
80104cfc:	5d                   	pop    %ebp
80104cfd:	c3                   	ret    
    return -1;
80104cfe:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104d03:	eb ef                	jmp    80104cf4 <sys_open+0xb9>
      end_op();
80104d05:	e8 8b dd ff ff       	call   80102a95 <end_op>
      return -1;
80104d0a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104d0f:	eb e3                	jmp    80104cf4 <sys_open+0xb9>
    if((ip = namei(path)) == 0){
80104d11:	83 ec 0c             	sub    $0xc,%esp
80104d14:	ff 75 e4             	pushl  -0x1c(%ebp)
80104d17:	e8 c5 d0 ff ff       	call   80101de1 <namei>
80104d1c:	89 c6                	mov    %eax,%esi
80104d1e:	83 c4 10             	add    $0x10,%esp
80104d21:	85 c0                	test   %eax,%eax
80104d23:	74 3c                	je     80104d61 <sys_open+0x126>
    ilock(ip);
80104d25:	83 ec 0c             	sub    $0xc,%esp
80104d28:	50                   	push   %eax
80104d29:	e8 d7 c9 ff ff       	call   80101705 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104d2e:	83 c4 10             	add    $0x10,%esp
80104d31:	66 83 be 90 00 00 00 	cmpw   $0x1,0x90(%esi)
80104d38:	01 
80104d39:	0f 85 67 ff ff ff    	jne    80104ca6 <sys_open+0x6b>
80104d3f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104d43:	0f 84 5d ff ff ff    	je     80104ca6 <sys_open+0x6b>
      iunlockput(ip);
80104d49:	83 ec 0c             	sub    $0xc,%esp
80104d4c:	56                   	push   %esi
80104d4d:	e8 90 cb ff ff       	call   801018e2 <iunlockput>
      end_op();
80104d52:	e8 3e dd ff ff       	call   80102a95 <end_op>
      return -1;
80104d57:	83 c4 10             	add    $0x10,%esp
80104d5a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104d5f:	eb 93                	jmp    80104cf4 <sys_open+0xb9>
      end_op();
80104d61:	e8 2f dd ff ff       	call   80102a95 <end_op>
      return -1;
80104d66:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104d6b:	eb 87                	jmp    80104cf4 <sys_open+0xb9>
    if(f)
80104d6d:	85 db                	test   %ebx,%ebx
80104d6f:	74 0c                	je     80104d7d <sys_open+0x142>
      fileclose(f);
80104d71:	83 ec 0c             	sub    $0xc,%esp
80104d74:	53                   	push   %ebx
80104d75:	e8 8b bf ff ff       	call   80100d05 <fileclose>
80104d7a:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104d7d:	83 ec 0c             	sub    $0xc,%esp
80104d80:	56                   	push   %esi
80104d81:	e8 5c cb ff ff       	call   801018e2 <iunlockput>
    end_op();
80104d86:	e8 0a dd ff ff       	call   80102a95 <end_op>
    return -1;
80104d8b:	83 c4 10             	add    $0x10,%esp
80104d8e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104d93:	e9 5c ff ff ff       	jmp    80104cf4 <sys_open+0xb9>

80104d98 <sys_mkdir>:

int
sys_mkdir(void)
{
80104d98:	f3 0f 1e fb          	endbr32 
80104d9c:	55                   	push   %ebp
80104d9d:	89 e5                	mov    %esp,%ebp
80104d9f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104da2:	e8 70 dc ff ff       	call   80102a17 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104da7:	83 ec 08             	sub    $0x8,%esp
80104daa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dad:	50                   	push   %eax
80104dae:	6a 00                	push   $0x0
80104db0:	e8 2c f6 ff ff       	call   801043e1 <argstr>
80104db5:	83 c4 10             	add    $0x10,%esp
80104db8:	85 c0                	test   %eax,%eax
80104dba:	78 36                	js     80104df2 <sys_mkdir+0x5a>
80104dbc:	83 ec 0c             	sub    $0xc,%esp
80104dbf:	6a 00                	push   $0x0
80104dc1:	b9 00 00 00 00       	mov    $0x0,%ecx
80104dc6:	ba 01 00 00 00       	mov    $0x1,%edx
80104dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dce:	e8 91 f7 ff ff       	call   80104564 <create>
80104dd3:	83 c4 10             	add    $0x10,%esp
80104dd6:	85 c0                	test   %eax,%eax
80104dd8:	74 18                	je     80104df2 <sys_mkdir+0x5a>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104dda:	83 ec 0c             	sub    $0xc,%esp
80104ddd:	50                   	push   %eax
80104dde:	e8 ff ca ff ff       	call   801018e2 <iunlockput>
  end_op();
80104de3:	e8 ad dc ff ff       	call   80102a95 <end_op>
  return 0;
80104de8:	83 c4 10             	add    $0x10,%esp
80104deb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104df0:	c9                   	leave  
80104df1:	c3                   	ret    
    end_op();
80104df2:	e8 9e dc ff ff       	call   80102a95 <end_op>
    return -1;
80104df7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dfc:	eb f2                	jmp    80104df0 <sys_mkdir+0x58>

80104dfe <sys_mknod>:

int
sys_mknod(void)
{
80104dfe:	f3 0f 1e fb          	endbr32 
80104e02:	55                   	push   %ebp
80104e03:	89 e5                	mov    %esp,%ebp
80104e05:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104e08:	e8 0a dc ff ff       	call   80102a17 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104e0d:	83 ec 08             	sub    $0x8,%esp
80104e10:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e13:	50                   	push   %eax
80104e14:	6a 00                	push   $0x0
80104e16:	e8 c6 f5 ff ff       	call   801043e1 <argstr>
80104e1b:	83 c4 10             	add    $0x10,%esp
80104e1e:	85 c0                	test   %eax,%eax
80104e20:	78 62                	js     80104e84 <sys_mknod+0x86>
     argint(1, &major) < 0 ||
80104e22:	83 ec 08             	sub    $0x8,%esp
80104e25:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e28:	50                   	push   %eax
80104e29:	6a 01                	push   $0x1
80104e2b:	e8 19 f5 ff ff       	call   80104349 <argint>
  if((argstr(0, &path)) < 0 ||
80104e30:	83 c4 10             	add    $0x10,%esp
80104e33:	85 c0                	test   %eax,%eax
80104e35:	78 4d                	js     80104e84 <sys_mknod+0x86>
     argint(2, &minor) < 0 ||
80104e37:	83 ec 08             	sub    $0x8,%esp
80104e3a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104e3d:	50                   	push   %eax
80104e3e:	6a 02                	push   $0x2
80104e40:	e8 04 f5 ff ff       	call   80104349 <argint>
     argint(1, &major) < 0 ||
80104e45:	83 c4 10             	add    $0x10,%esp
80104e48:	85 c0                	test   %eax,%eax
80104e4a:	78 38                	js     80104e84 <sys_mknod+0x86>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104e4c:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80104e50:	83 ec 0c             	sub    $0xc,%esp
80104e53:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104e57:	50                   	push   %eax
80104e58:	ba 03 00 00 00       	mov    $0x3,%edx
80104e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e60:	e8 ff f6 ff ff       	call   80104564 <create>
     argint(2, &minor) < 0 ||
80104e65:	83 c4 10             	add    $0x10,%esp
80104e68:	85 c0                	test   %eax,%eax
80104e6a:	74 18                	je     80104e84 <sys_mknod+0x86>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104e6c:	83 ec 0c             	sub    $0xc,%esp
80104e6f:	50                   	push   %eax
80104e70:	e8 6d ca ff ff       	call   801018e2 <iunlockput>
  end_op();
80104e75:	e8 1b dc ff ff       	call   80102a95 <end_op>
  return 0;
80104e7a:	83 c4 10             	add    $0x10,%esp
80104e7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e82:	c9                   	leave  
80104e83:	c3                   	ret    
    end_op();
80104e84:	e8 0c dc ff ff       	call   80102a95 <end_op>
    return -1;
80104e89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e8e:	eb f2                	jmp    80104e82 <sys_mknod+0x84>

80104e90 <sys_chdir>:

int
sys_chdir(void)
{
80104e90:	f3 0f 1e fb          	endbr32 
80104e94:	55                   	push   %ebp
80104e95:	89 e5                	mov    %esp,%ebp
80104e97:	56                   	push   %esi
80104e98:	53                   	push   %ebx
80104e99:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104e9c:	e8 01 e7 ff ff       	call   801035a2 <myproc>
80104ea1:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104ea3:	e8 6f db ff ff       	call   80102a17 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104ea8:	83 ec 08             	sub    $0x8,%esp
80104eab:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104eae:	50                   	push   %eax
80104eaf:	6a 00                	push   $0x0
80104eb1:	e8 2b f5 ff ff       	call   801043e1 <argstr>
80104eb6:	83 c4 10             	add    $0x10,%esp
80104eb9:	85 c0                	test   %eax,%eax
80104ebb:	78 55                	js     80104f12 <sys_chdir+0x82>
80104ebd:	83 ec 0c             	sub    $0xc,%esp
80104ec0:	ff 75 f4             	pushl  -0xc(%ebp)
80104ec3:	e8 19 cf ff ff       	call   80101de1 <namei>
80104ec8:	89 c3                	mov    %eax,%ebx
80104eca:	83 c4 10             	add    $0x10,%esp
80104ecd:	85 c0                	test   %eax,%eax
80104ecf:	74 41                	je     80104f12 <sys_chdir+0x82>
    end_op();
    return -1;
  }
  ilock(ip);
80104ed1:	83 ec 0c             	sub    $0xc,%esp
80104ed4:	50                   	push   %eax
80104ed5:	e8 2b c8 ff ff       	call   80101705 <ilock>
  if(ip->type != T_DIR){
80104eda:	83 c4 10             	add    $0x10,%esp
80104edd:	66 83 bb 90 00 00 00 	cmpw   $0x1,0x90(%ebx)
80104ee4:	01 
80104ee5:	75 37                	jne    80104f1e <sys_chdir+0x8e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104ee7:	83 ec 0c             	sub    $0xc,%esp
80104eea:	53                   	push   %ebx
80104eeb:	e8 f6 c8 ff ff       	call   801017e6 <iunlock>
  iput(curproc->cwd);
80104ef0:	83 c4 04             	add    $0x4,%esp
80104ef3:	ff 76 68             	pushl  0x68(%esi)
80104ef6:	e8 34 c9 ff ff       	call   8010182f <iput>
  end_op();
80104efb:	e8 95 db ff ff       	call   80102a95 <end_op>
  curproc->cwd = ip;
80104f00:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104f03:	83 c4 10             	add    $0x10,%esp
80104f06:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104f0e:	5b                   	pop    %ebx
80104f0f:	5e                   	pop    %esi
80104f10:	5d                   	pop    %ebp
80104f11:	c3                   	ret    
    end_op();
80104f12:	e8 7e db ff ff       	call   80102a95 <end_op>
    return -1;
80104f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f1c:	eb ed                	jmp    80104f0b <sys_chdir+0x7b>
    iunlockput(ip);
80104f1e:	83 ec 0c             	sub    $0xc,%esp
80104f21:	53                   	push   %ebx
80104f22:	e8 bb c9 ff ff       	call   801018e2 <iunlockput>
    end_op();
80104f27:	e8 69 db ff ff       	call   80102a95 <end_op>
    return -1;
80104f2c:	83 c4 10             	add    $0x10,%esp
80104f2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f34:	eb d5                	jmp    80104f0b <sys_chdir+0x7b>

80104f36 <sys_exec>:

int
sys_exec(void)
{
80104f36:	f3 0f 1e fb          	endbr32 
80104f3a:	55                   	push   %ebp
80104f3b:	89 e5                	mov    %esp,%ebp
80104f3d:	53                   	push   %ebx
80104f3e:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104f44:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f47:	50                   	push   %eax
80104f48:	6a 00                	push   $0x0
80104f4a:	e8 92 f4 ff ff       	call   801043e1 <argstr>
80104f4f:	83 c4 10             	add    $0x10,%esp
80104f52:	85 c0                	test   %eax,%eax
80104f54:	78 38                	js     80104f8e <sys_exec+0x58>
80104f56:	83 ec 08             	sub    $0x8,%esp
80104f59:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104f5f:	50                   	push   %eax
80104f60:	6a 01                	push   $0x1
80104f62:	e8 e2 f3 ff ff       	call   80104349 <argint>
80104f67:	83 c4 10             	add    $0x10,%esp
80104f6a:	85 c0                	test   %eax,%eax
80104f6c:	78 20                	js     80104f8e <sys_exec+0x58>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104f6e:	83 ec 04             	sub    $0x4,%esp
80104f71:	68 80 00 00 00       	push   $0x80
80104f76:	6a 00                	push   $0x0
80104f78:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104f7e:	50                   	push   %eax
80104f7f:	e8 4f f1 ff ff       	call   801040d3 <memset>
80104f84:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104f87:	bb 00 00 00 00       	mov    $0x0,%ebx
80104f8c:	eb 2c                	jmp    80104fba <sys_exec+0x84>
    return -1;
80104f8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f93:	eb 78                	jmp    8010500d <sys_exec+0xd7>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104f95:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104f9c:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104fa0:	83 ec 08             	sub    $0x8,%esp
80104fa3:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104fa9:	50                   	push   %eax
80104faa:	ff 75 f4             	pushl  -0xc(%ebp)
80104fad:	e8 4a b9 ff ff       	call   801008fc <exec>
80104fb2:	83 c4 10             	add    $0x10,%esp
80104fb5:	eb 56                	jmp    8010500d <sys_exec+0xd7>
  for(i=0;; i++){
80104fb7:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104fba:	83 fb 1f             	cmp    $0x1f,%ebx
80104fbd:	77 49                	ja     80105008 <sys_exec+0xd2>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104fbf:	83 ec 08             	sub    $0x8,%esp
80104fc2:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104fc8:	50                   	push   %eax
80104fc9:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104fcf:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104fd2:	50                   	push   %eax
80104fd3:	e8 ed f2 ff ff       	call   801042c5 <fetchint>
80104fd8:	83 c4 10             	add    $0x10,%esp
80104fdb:	85 c0                	test   %eax,%eax
80104fdd:	78 33                	js     80105012 <sys_exec+0xdc>
    if(uarg == 0){
80104fdf:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104fe5:	85 c0                	test   %eax,%eax
80104fe7:	74 ac                	je     80104f95 <sys_exec+0x5f>
    if(fetchstr(uarg, &argv[i]) < 0)
80104fe9:	83 ec 08             	sub    $0x8,%esp
80104fec:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104ff3:	52                   	push   %edx
80104ff4:	50                   	push   %eax
80104ff5:	e8 0b f3 ff ff       	call   80104305 <fetchstr>
80104ffa:	83 c4 10             	add    $0x10,%esp
80104ffd:	85 c0                	test   %eax,%eax
80104fff:	79 b6                	jns    80104fb7 <sys_exec+0x81>
      return -1;
80105001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105006:	eb 05                	jmp    8010500d <sys_exec+0xd7>
      return -1;
80105008:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010500d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105010:	c9                   	leave  
80105011:	c3                   	ret    
      return -1;
80105012:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105017:	eb f4                	jmp    8010500d <sys_exec+0xd7>

80105019 <sys_pipe>:

int
sys_pipe(void)
{
80105019:	f3 0f 1e fb          	endbr32 
8010501d:	55                   	push   %ebp
8010501e:	89 e5                	mov    %esp,%ebp
80105020:	53                   	push   %ebx
80105021:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105024:	6a 08                	push   $0x8
80105026:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105029:	50                   	push   %eax
8010502a:	6a 00                	push   $0x0
8010502c:	e8 44 f3 ff ff       	call   80104375 <argptr>
80105031:	83 c4 10             	add    $0x10,%esp
80105034:	85 c0                	test   %eax,%eax
80105036:	78 79                	js     801050b1 <sys_pipe+0x98>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105038:	83 ec 08             	sub    $0x8,%esp
8010503b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010503e:	50                   	push   %eax
8010503f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105042:	50                   	push   %eax
80105043:	e8 bb df ff ff       	call   80103003 <pipealloc>
80105048:	83 c4 10             	add    $0x10,%esp
8010504b:	85 c0                	test   %eax,%eax
8010504d:	78 69                	js     801050b8 <sys_pipe+0x9f>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010504f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105052:	e8 7c f4 ff ff       	call   801044d3 <fdalloc>
80105057:	89 c3                	mov    %eax,%ebx
80105059:	85 c0                	test   %eax,%eax
8010505b:	78 21                	js     8010507e <sys_pipe+0x65>
8010505d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105060:	e8 6e f4 ff ff       	call   801044d3 <fdalloc>
80105065:	85 c0                	test   %eax,%eax
80105067:	78 15                	js     8010507e <sys_pipe+0x65>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80105069:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010506c:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
8010506e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105071:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80105074:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010507c:	c9                   	leave  
8010507d:	c3                   	ret    
    if(fd0 >= 0)
8010507e:	85 db                	test   %ebx,%ebx
80105080:	79 20                	jns    801050a2 <sys_pipe+0x89>
    fileclose(rf);
80105082:	83 ec 0c             	sub    $0xc,%esp
80105085:	ff 75 f0             	pushl  -0x10(%ebp)
80105088:	e8 78 bc ff ff       	call   80100d05 <fileclose>
    fileclose(wf);
8010508d:	83 c4 04             	add    $0x4,%esp
80105090:	ff 75 ec             	pushl  -0x14(%ebp)
80105093:	e8 6d bc ff ff       	call   80100d05 <fileclose>
    return -1;
80105098:	83 c4 10             	add    $0x10,%esp
8010509b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050a0:	eb d7                	jmp    80105079 <sys_pipe+0x60>
      myproc()->ofile[fd0] = 0;
801050a2:	e8 fb e4 ff ff       	call   801035a2 <myproc>
801050a7:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
801050ae:	00 
801050af:	eb d1                	jmp    80105082 <sys_pipe+0x69>
    return -1;
801050b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050b6:	eb c1                	jmp    80105079 <sys_pipe+0x60>
    return -1;
801050b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050bd:	eb ba                	jmp    80105079 <sys_pipe+0x60>

801050bf <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801050bf:	f3 0f 1e fb          	endbr32 
801050c3:	55                   	push   %ebp
801050c4:	89 e5                	mov    %esp,%ebp
801050c6:	83 ec 08             	sub    $0x8,%esp
  return fork();
801050c9:	e8 69 e6 ff ff       	call   80103737 <fork>
}
801050ce:	c9                   	leave  
801050cf:	c3                   	ret    

801050d0 <sys_exit>:

int
sys_exit(void)
{
801050d0:	f3 0f 1e fb          	endbr32 
801050d4:	55                   	push   %ebp
801050d5:	89 e5                	mov    %esp,%ebp
801050d7:	83 ec 08             	sub    $0x8,%esp
  exit();
801050da:	e8 cd e8 ff ff       	call   801039ac <exit>
  return 0;  // not reached
}
801050df:	b8 00 00 00 00       	mov    $0x0,%eax
801050e4:	c9                   	leave  
801050e5:	c3                   	ret    

801050e6 <sys_wait>:

int
sys_wait(void)
{
801050e6:	f3 0f 1e fb          	endbr32 
801050ea:	55                   	push   %ebp
801050eb:	89 e5                	mov    %esp,%ebp
801050ed:	83 ec 08             	sub    $0x8,%esp
  return wait();
801050f0:	e8 4f ea ff ff       	call   80103b44 <wait>
}
801050f5:	c9                   	leave  
801050f6:	c3                   	ret    

801050f7 <sys_kill>:

int
sys_kill(void)
{
801050f7:	f3 0f 1e fb          	endbr32 
801050fb:	55                   	push   %ebp
801050fc:	89 e5                	mov    %esp,%ebp
801050fe:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105101:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105104:	50                   	push   %eax
80105105:	6a 00                	push   $0x0
80105107:	e8 3d f2 ff ff       	call   80104349 <argint>
8010510c:	83 c4 10             	add    $0x10,%esp
8010510f:	85 c0                	test   %eax,%eax
80105111:	78 10                	js     80105123 <sys_kill+0x2c>
    return -1;
  return kill(pid);
80105113:	83 ec 0c             	sub    $0xc,%esp
80105116:	ff 75 f4             	pushl  -0xc(%ebp)
80105119:	e8 2e eb ff ff       	call   80103c4c <kill>
8010511e:	83 c4 10             	add    $0x10,%esp
}
80105121:	c9                   	leave  
80105122:	c3                   	ret    
    return -1;
80105123:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105128:	eb f7                	jmp    80105121 <sys_kill+0x2a>

8010512a <sys_getpid>:

int
sys_getpid(void)
{
8010512a:	f3 0f 1e fb          	endbr32 
8010512e:	55                   	push   %ebp
8010512f:	89 e5                	mov    %esp,%ebp
80105131:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105134:	e8 69 e4 ff ff       	call   801035a2 <myproc>
80105139:	8b 40 10             	mov    0x10(%eax),%eax
}
8010513c:	c9                   	leave  
8010513d:	c3                   	ret    

8010513e <sys_sbrk>:

int
sys_sbrk(void)
{
8010513e:	f3 0f 1e fb          	endbr32 
80105142:	55                   	push   %ebp
80105143:	89 e5                	mov    %esp,%ebp
80105145:	53                   	push   %ebx
80105146:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105149:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010514c:	50                   	push   %eax
8010514d:	6a 00                	push   $0x0
8010514f:	e8 f5 f1 ff ff       	call   80104349 <argint>
80105154:	83 c4 10             	add    $0x10,%esp
80105157:	85 c0                	test   %eax,%eax
80105159:	78 20                	js     8010517b <sys_sbrk+0x3d>
    return -1;
  addr = myproc()->sz;
8010515b:	e8 42 e4 ff ff       	call   801035a2 <myproc>
80105160:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105162:	83 ec 0c             	sub    $0xc,%esp
80105165:	ff 75 f4             	pushl  -0xc(%ebp)
80105168:	e8 5b e5 ff ff       	call   801036c8 <growproc>
8010516d:	83 c4 10             	add    $0x10,%esp
80105170:	85 c0                	test   %eax,%eax
80105172:	78 0e                	js     80105182 <sys_sbrk+0x44>
    return -1;
  return addr;
}
80105174:	89 d8                	mov    %ebx,%eax
80105176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105179:	c9                   	leave  
8010517a:	c3                   	ret    
    return -1;
8010517b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105180:	eb f2                	jmp    80105174 <sys_sbrk+0x36>
    return -1;
80105182:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105187:	eb eb                	jmp    80105174 <sys_sbrk+0x36>

80105189 <sys_sleep>:

int
sys_sleep(void)
{
80105189:	f3 0f 1e fb          	endbr32 
8010518d:	55                   	push   %ebp
8010518e:	89 e5                	mov    %esp,%ebp
80105190:	53                   	push   %ebx
80105191:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105194:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105197:	50                   	push   %eax
80105198:	6a 00                	push   $0x0
8010519a:	e8 aa f1 ff ff       	call   80104349 <argint>
8010519f:	83 c4 10             	add    $0x10,%esp
801051a2:	85 c0                	test   %eax,%eax
801051a4:	78 75                	js     8010521b <sys_sleep+0x92>
    return -1;
  acquire(&tickslock);
801051a6:	83 ec 0c             	sub    $0xc,%esp
801051a9:	68 e0 5d 11 80       	push   $0x80115de0
801051ae:	e8 6c ee ff ff       	call   8010401f <acquire>
  ticks0 = ticks;
801051b3:	8b 1d 20 66 11 80    	mov    0x80116620,%ebx
  while(ticks - ticks0 < n){
801051b9:	83 c4 10             	add    $0x10,%esp
801051bc:	a1 20 66 11 80       	mov    0x80116620,%eax
801051c1:	29 d8                	sub    %ebx,%eax
801051c3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801051c6:	73 39                	jae    80105201 <sys_sleep+0x78>
    if(myproc()->killed){
801051c8:	e8 d5 e3 ff ff       	call   801035a2 <myproc>
801051cd:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801051d1:	75 17                	jne    801051ea <sys_sleep+0x61>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
801051d3:	83 ec 08             	sub    $0x8,%esp
801051d6:	68 e0 5d 11 80       	push   $0x80115de0
801051db:	68 20 66 11 80       	push   $0x80116620
801051e0:	e8 ca e8 ff ff       	call   80103aaf <sleep>
801051e5:	83 c4 10             	add    $0x10,%esp
801051e8:	eb d2                	jmp    801051bc <sys_sleep+0x33>
      release(&tickslock);
801051ea:	83 ec 0c             	sub    $0xc,%esp
801051ed:	68 e0 5d 11 80       	push   $0x80115de0
801051f2:	e8 91 ee ff ff       	call   80104088 <release>
      return -1;
801051f7:	83 c4 10             	add    $0x10,%esp
801051fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ff:	eb 15                	jmp    80105216 <sys_sleep+0x8d>
  }
  release(&tickslock);
80105201:	83 ec 0c             	sub    $0xc,%esp
80105204:	68 e0 5d 11 80       	push   $0x80115de0
80105209:	e8 7a ee ff ff       	call   80104088 <release>
  return 0;
8010520e:	83 c4 10             	add    $0x10,%esp
80105211:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105219:	c9                   	leave  
8010521a:	c3                   	ret    
    return -1;
8010521b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105220:	eb f4                	jmp    80105216 <sys_sleep+0x8d>

80105222 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105222:	f3 0f 1e fb          	endbr32 
80105226:	55                   	push   %ebp
80105227:	89 e5                	mov    %esp,%ebp
80105229:	53                   	push   %ebx
8010522a:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
8010522d:	68 e0 5d 11 80       	push   $0x80115de0
80105232:	e8 e8 ed ff ff       	call   8010401f <acquire>
  xticks = ticks;
80105237:	8b 1d 20 66 11 80    	mov    0x80116620,%ebx
  release(&tickslock);
8010523d:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80105244:	e8 3f ee ff ff       	call   80104088 <release>
  return xticks;
}
80105249:	89 d8                	mov    %ebx,%eax
8010524b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010524e:	c9                   	leave  
8010524f:	c3                   	ret    

80105250 <sys_yield>:

int
sys_yield(void)
{
80105250:	f3 0f 1e fb          	endbr32 
80105254:	55                   	push   %ebp
80105255:	89 e5                	mov    %esp,%ebp
80105257:	83 ec 08             	sub    $0x8,%esp
  yield();
8010525a:	e8 1a e8 ff ff       	call   80103a79 <yield>
  return 0;
}
8010525f:	b8 00 00 00 00       	mov    $0x0,%eax
80105264:	c9                   	leave  
80105265:	c3                   	ret    

80105266 <sys_shutdown>:

int sys_shutdown(void)
{
80105266:	f3 0f 1e fb          	endbr32 
8010526a:	55                   	push   %ebp
8010526b:	89 e5                	mov    %esp,%ebp
8010526d:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80105270:	e8 cc d1 ff ff       	call   80102441 <shutdown>
  return 0;
}
80105275:	b8 00 00 00 00       	mov    $0x0,%eax
8010527a:	c9                   	leave  
8010527b:	c3                   	ret    

8010527c <sys_ps>:
/// arg0 elements.
/// @return The number of struct procInfo structures stored in arg1.
/// This number may be less than arg0, and if it is, elements
/// at indexes >= arg0 may contain uninitialized memory.
int sys_ps(void)
{
8010527c:	f3 0f 1e fb          	endbr32 
80105280:	55                   	push   %ebp
80105281:	89 e5                	mov    %esp,%ebp
80105283:	83 ec 20             	sub    $0x20,%esp
  int numberOfProcs;
  struct procInfo* procInfoArray;

  if(argint(0, &numberOfProcs) < 0){
80105286:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105289:	50                   	push   %eax
8010528a:	6a 00                	push   $0x0
8010528c:	e8 b8 f0 ff ff       	call   80104349 <argint>
80105291:	83 c4 10             	add    $0x10,%esp
80105294:	85 c0                	test   %eax,%eax
80105296:	78 2a                	js     801052c2 <sys_ps+0x46>
    return -1;
  }
  if(argptr(1, (char **)&procInfoArray,  sizeof(struct procInfo *)) < 0){
80105298:	83 ec 04             	sub    $0x4,%esp
8010529b:	6a 04                	push   $0x4
8010529d:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052a0:	50                   	push   %eax
801052a1:	6a 01                	push   $0x1
801052a3:	e8 cd f0 ff ff       	call   80104375 <argptr>
801052a8:	83 c4 10             	add    $0x10,%esp
801052ab:	85 c0                	test   %eax,%eax
801052ad:	78 1a                	js     801052c9 <sys_ps+0x4d>
    return -1;
  }
  return proc_ps(numberOfProcs, procInfoArray);
801052af:	83 ec 08             	sub    $0x8,%esp
801052b2:	ff 75 f0             	pushl  -0x10(%ebp)
801052b5:	ff 75 f4             	pushl  -0xc(%ebp)
801052b8:	e8 8e e1 ff ff       	call   8010344b <proc_ps>
801052bd:	83 c4 10             	add    $0x10,%esp
}
801052c0:	c9                   	leave  
801052c1:	c3                   	ret    
    return -1;
801052c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052c7:	eb f7                	jmp    801052c0 <sys_ps+0x44>
    return -1;
801052c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ce:	eb f0                	jmp    801052c0 <sys_ps+0x44>

801052d0 <sys_nice>:

// nice system call for Large Project 00
int sys_nice(struct proc* p){
801052d0:	f3 0f 1e fb          	endbr32 
801052d4:	55                   	push   %ebp
801052d5:	89 e5                	mov    %esp,%ebp
801052d7:	83 ec 10             	sub    $0x10,%esp
801052da:	8b 45 08             	mov    0x8(%ebp),%eax
  int pid = p->pid;
  int priority = p->priority;
  proc_nice(pid, priority);
801052dd:	ff b0 84 00 00 00    	pushl  0x84(%eax)
801052e3:	ff 70 10             	pushl  0x10(%eax)
801052e6:	e8 94 ea ff ff       	call   80103d7f <proc_nice>
  return 0;
801052eb:	b8 00 00 00 00       	mov    $0x0,%eax
801052f0:	c9                   	leave  
801052f1:	c3                   	ret    

801052f2 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801052f2:	1e                   	push   %ds
  pushl %es
801052f3:	06                   	push   %es
  pushl %fs
801052f4:	0f a0                	push   %fs
  pushl %gs
801052f6:	0f a8                	push   %gs
  pushal
801052f8:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801052f9:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801052fd:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801052ff:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105301:	54                   	push   %esp
  call trap
80105302:	e8 eb 00 00 00       	call   801053f2 <trap>
  addl $4, %esp
80105307:	83 c4 04             	add    $0x4,%esp

8010530a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010530a:	61                   	popa   
  popl %gs
8010530b:	0f a9                	pop    %gs
  popl %fs
8010530d:	0f a1                	pop    %fs
  popl %es
8010530f:	07                   	pop    %es
  popl %ds
80105310:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105311:	83 c4 08             	add    $0x8,%esp
  iret
80105314:	cf                   	iret   

80105315 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105315:	f3 0f 1e fb          	endbr32 
80105319:	55                   	push   %ebp
8010531a:	89 e5                	mov    %esp,%ebp
8010531c:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
8010531f:	b8 00 00 00 00       	mov    $0x0,%eax
80105324:	3d ff 00 00 00       	cmp    $0xff,%eax
80105329:	7f 4c                	jg     80105377 <tvinit+0x62>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010532b:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80105332:	66 89 0c c5 20 5e 11 	mov    %cx,-0x7feea1e0(,%eax,8)
80105339:	80 
8010533a:	66 c7 04 c5 22 5e 11 	movw   $0x8,-0x7feea1de(,%eax,8)
80105341:	80 08 00 
80105344:	c6 04 c5 24 5e 11 80 	movb   $0x0,-0x7feea1dc(,%eax,8)
8010534b:	00 
8010534c:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
80105353:	80 
80105354:	83 e2 f0             	and    $0xfffffff0,%edx
80105357:	83 ca 0e             	or     $0xe,%edx
8010535a:	83 e2 8f             	and    $0xffffff8f,%edx
8010535d:	83 ca 80             	or     $0xffffff80,%edx
80105360:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
80105367:	c1 e9 10             	shr    $0x10,%ecx
8010536a:	66 89 0c c5 26 5e 11 	mov    %cx,-0x7feea1da(,%eax,8)
80105371:	80 
  for(i = 0; i < 256; i++)
80105372:	83 c0 01             	add    $0x1,%eax
80105375:	eb ad                	jmp    80105324 <tvinit+0xf>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105377:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
8010537d:	66 89 15 20 60 11 80 	mov    %dx,0x80116020
80105384:	66 c7 05 22 60 11 80 	movw   $0x8,0x80116022
8010538b:	08 00 
8010538d:	c6 05 24 60 11 80 00 	movb   $0x0,0x80116024
80105394:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
8010539b:	83 c8 0f             	or     $0xf,%eax
8010539e:	83 e0 ef             	and    $0xffffffef,%eax
801053a1:	83 c8 e0             	or     $0xffffffe0,%eax
801053a4:	a2 25 60 11 80       	mov    %al,0x80116025
801053a9:	c1 ea 10             	shr    $0x10,%edx
801053ac:	66 89 15 26 60 11 80 	mov    %dx,0x80116026

  initlock(&tickslock, "time");
801053b3:	83 ec 08             	sub    $0x8,%esp
801053b6:	68 d1 78 10 80       	push   $0x801078d1
801053bb:	68 e0 5d 11 80       	push   $0x80115de0
801053c0:	e8 0a eb ff ff       	call   80103ecf <initlock>
}
801053c5:	83 c4 10             	add    $0x10,%esp
801053c8:	c9                   	leave  
801053c9:	c3                   	ret    

801053ca <idtinit>:

void
idtinit(void)
{
801053ca:	f3 0f 1e fb          	endbr32 
801053ce:	55                   	push   %ebp
801053cf:	89 e5                	mov    %esp,%ebp
801053d1:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801053d4:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
801053da:	b8 20 5e 11 80       	mov    $0x80115e20,%eax
801053df:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801053e3:	c1 e8 10             	shr    $0x10,%eax
801053e6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801053ea:	8d 45 fa             	lea    -0x6(%ebp),%eax
801053ed:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
801053f0:	c9                   	leave  
801053f1:	c3                   	ret    

801053f2 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801053f2:	f3 0f 1e fb          	endbr32 
801053f6:	55                   	push   %ebp
801053f7:	89 e5                	mov    %esp,%ebp
801053f9:	57                   	push   %edi
801053fa:	56                   	push   %esi
801053fb:	53                   	push   %ebx
801053fc:	83 ec 1c             	sub    $0x1c,%esp
801053ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105402:	8b 43 30             	mov    0x30(%ebx),%eax
80105405:	83 f8 40             	cmp    $0x40,%eax
80105408:	74 14                	je     8010541e <trap+0x2c>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
8010540a:	83 e8 20             	sub    $0x20,%eax
8010540d:	83 f8 1f             	cmp    $0x1f,%eax
80105410:	0f 87 3b 01 00 00    	ja     80105551 <trap+0x15f>
80105416:	3e ff 24 85 78 79 10 	notrack jmp *-0x7fef8688(,%eax,4)
8010541d:	80 
    if(myproc()->killed)
8010541e:	e8 7f e1 ff ff       	call   801035a2 <myproc>
80105423:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105427:	75 1f                	jne    80105448 <trap+0x56>
    myproc()->tf = tf;
80105429:	e8 74 e1 ff ff       	call   801035a2 <myproc>
8010542e:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105431:	e8 e2 ef ff ff       	call   80104418 <syscall>
    if(myproc()->killed)
80105436:	e8 67 e1 ff ff       	call   801035a2 <myproc>
8010543b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010543f:	74 7e                	je     801054bf <trap+0xcd>
      exit();
80105441:	e8 66 e5 ff ff       	call   801039ac <exit>
    return;
80105446:	eb 77                	jmp    801054bf <trap+0xcd>
      exit();
80105448:	e8 5f e5 ff ff       	call   801039ac <exit>
8010544d:	eb da                	jmp    80105429 <trap+0x37>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010544f:	e8 2f e1 ff ff       	call   80103583 <cpuid>
80105454:	85 c0                	test   %eax,%eax
80105456:	74 6f                	je     801054c7 <trap+0xd5>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105458:	e8 9e d1 ff ff       	call   801025fb <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010545d:	e8 40 e1 ff ff       	call   801035a2 <myproc>
80105462:	85 c0                	test   %eax,%eax
80105464:	74 1c                	je     80105482 <trap+0x90>
80105466:	e8 37 e1 ff ff       	call   801035a2 <myproc>
8010546b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010546f:	74 11                	je     80105482 <trap+0x90>
80105471:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105475:	83 e0 03             	and    $0x3,%eax
80105478:	66 83 f8 03          	cmp    $0x3,%ax
8010547c:	0f 84 62 01 00 00    	je     801055e4 <trap+0x1f2>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105482:	e8 1b e1 ff ff       	call   801035a2 <myproc>
80105487:	85 c0                	test   %eax,%eax
80105489:	74 0f                	je     8010549a <trap+0xa8>
8010548b:	e8 12 e1 ff ff       	call   801035a2 <myproc>
80105490:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105494:	0f 84 54 01 00 00    	je     801055ee <trap+0x1fc>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010549a:	e8 03 e1 ff ff       	call   801035a2 <myproc>
8010549f:	85 c0                	test   %eax,%eax
801054a1:	74 1c                	je     801054bf <trap+0xcd>
801054a3:	e8 fa e0 ff ff       	call   801035a2 <myproc>
801054a8:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801054ac:	74 11                	je     801054bf <trap+0xcd>
801054ae:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801054b2:	83 e0 03             	and    $0x3,%eax
801054b5:	66 83 f8 03          	cmp    $0x3,%ax
801054b9:	0f 84 43 01 00 00    	je     80105602 <trap+0x210>
    exit();
}
801054bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801054c2:	5b                   	pop    %ebx
801054c3:	5e                   	pop    %esi
801054c4:	5f                   	pop    %edi
801054c5:	5d                   	pop    %ebp
801054c6:	c3                   	ret    
      acquire(&tickslock);
801054c7:	83 ec 0c             	sub    $0xc,%esp
801054ca:	68 e0 5d 11 80       	push   $0x80115de0
801054cf:	e8 4b eb ff ff       	call   8010401f <acquire>
      ticks++;
801054d4:	83 05 20 66 11 80 01 	addl   $0x1,0x80116620
      wakeup(&ticks);
801054db:	c7 04 24 20 66 11 80 	movl   $0x80116620,(%esp)
801054e2:	e8 38 e7 ff ff       	call   80103c1f <wakeup>
      release(&tickslock);
801054e7:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
801054ee:	e8 95 eb ff ff       	call   80104088 <release>
801054f3:	83 c4 10             	add    $0x10,%esp
801054f6:	e9 5d ff ff ff       	jmp    80105458 <trap+0x66>
    ideintr();
801054fb:	e8 7e ca ff ff       	call   80101f7e <ideintr>
    lapiceoi();
80105500:	e8 f6 d0 ff ff       	call   801025fb <lapiceoi>
    break;
80105505:	e9 53 ff ff ff       	jmp    8010545d <trap+0x6b>
    kbdintr();
8010550a:	e8 19 cf ff ff       	call   80102428 <kbdintr>
    lapiceoi();
8010550f:	e8 e7 d0 ff ff       	call   801025fb <lapiceoi>
    break;
80105514:	e9 44 ff ff ff       	jmp    8010545d <trap+0x6b>
    uartintr();
80105519:	e8 0a 02 00 00       	call   80105728 <uartintr>
    lapiceoi();
8010551e:	e8 d8 d0 ff ff       	call   801025fb <lapiceoi>
    break;
80105523:	e9 35 ff ff ff       	jmp    8010545d <trap+0x6b>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105528:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
8010552b:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010552f:	e8 4f e0 ff ff       	call   80103583 <cpuid>
80105534:	57                   	push   %edi
80105535:	0f b7 f6             	movzwl %si,%esi
80105538:	56                   	push   %esi
80105539:	50                   	push   %eax
8010553a:	68 dc 78 10 80       	push   $0x801078dc
8010553f:	e8 e5 b0 ff ff       	call   80100629 <cprintf>
    lapiceoi();
80105544:	e8 b2 d0 ff ff       	call   801025fb <lapiceoi>
    break;
80105549:	83 c4 10             	add    $0x10,%esp
8010554c:	e9 0c ff ff ff       	jmp    8010545d <trap+0x6b>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105551:	e8 4c e0 ff ff       	call   801035a2 <myproc>
80105556:	85 c0                	test   %eax,%eax
80105558:	74 5f                	je     801055b9 <trap+0x1c7>
8010555a:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010555e:	74 59                	je     801055b9 <trap+0x1c7>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105560:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105563:	8b 43 38             	mov    0x38(%ebx),%eax
80105566:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105569:	e8 15 e0 ff ff       	call   80103583 <cpuid>
8010556e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105571:	8b 53 34             	mov    0x34(%ebx),%edx
80105574:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105577:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
8010557a:	e8 23 e0 ff ff       	call   801035a2 <myproc>
8010557f:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105582:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105585:	e8 18 e0 ff ff       	call   801035a2 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010558a:	57                   	push   %edi
8010558b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010558e:	ff 75 e0             	pushl  -0x20(%ebp)
80105591:	ff 75 dc             	pushl  -0x24(%ebp)
80105594:	56                   	push   %esi
80105595:	ff 75 d8             	pushl  -0x28(%ebp)
80105598:	ff 70 10             	pushl  0x10(%eax)
8010559b:	68 34 79 10 80       	push   $0x80107934
801055a0:	e8 84 b0 ff ff       	call   80100629 <cprintf>
    myproc()->killed = 1;
801055a5:	83 c4 20             	add    $0x20,%esp
801055a8:	e8 f5 df ff ff       	call   801035a2 <myproc>
801055ad:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801055b4:	e9 a4 fe ff ff       	jmp    8010545d <trap+0x6b>
801055b9:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801055bc:	8b 73 38             	mov    0x38(%ebx),%esi
801055bf:	e8 bf df ff ff       	call   80103583 <cpuid>
801055c4:	83 ec 0c             	sub    $0xc,%esp
801055c7:	57                   	push   %edi
801055c8:	56                   	push   %esi
801055c9:	50                   	push   %eax
801055ca:	ff 73 30             	pushl  0x30(%ebx)
801055cd:	68 00 79 10 80       	push   $0x80107900
801055d2:	e8 52 b0 ff ff       	call   80100629 <cprintf>
      panic("trap");
801055d7:	83 c4 14             	add    $0x14,%esp
801055da:	68 d6 78 10 80       	push   $0x801078d6
801055df:	e8 78 ad ff ff       	call   8010035c <panic>
    exit();
801055e4:	e8 c3 e3 ff ff       	call   801039ac <exit>
801055e9:	e9 94 fe ff ff       	jmp    80105482 <trap+0x90>
  if(myproc() && myproc()->state == RUNNING &&
801055ee:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801055f2:	0f 85 a2 fe ff ff    	jne    8010549a <trap+0xa8>
    yield();
801055f8:	e8 7c e4 ff ff       	call   80103a79 <yield>
801055fd:	e9 98 fe ff ff       	jmp    8010549a <trap+0xa8>
    exit();
80105602:	e8 a5 e3 ff ff       	call   801039ac <exit>
80105607:	e9 b3 fe ff ff       	jmp    801054bf <trap+0xcd>

8010560c <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
8010560c:	f3 0f 1e fb          	endbr32 
  if(!uart)
80105610:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105617:	74 14                	je     8010562d <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105619:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010561e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010561f:	a8 01                	test   $0x1,%al
80105621:	74 10                	je     80105633 <uartgetc+0x27>
80105623:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105628:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105629:	0f b6 c0             	movzbl %al,%eax
8010562c:	c3                   	ret    
    return -1;
8010562d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105632:	c3                   	ret    
    return -1;
80105633:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105638:	c3                   	ret    

80105639 <uartputc>:
{
80105639:	f3 0f 1e fb          	endbr32 
  if(!uart)
8010563d:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105644:	74 3b                	je     80105681 <uartputc+0x48>
{
80105646:	55                   	push   %ebp
80105647:	89 e5                	mov    %esp,%ebp
80105649:	53                   	push   %ebx
8010564a:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010564d:	bb 00 00 00 00       	mov    $0x0,%ebx
80105652:	83 fb 7f             	cmp    $0x7f,%ebx
80105655:	7f 1c                	jg     80105673 <uartputc+0x3a>
80105657:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010565c:	ec                   	in     (%dx),%al
8010565d:	a8 20                	test   $0x20,%al
8010565f:	75 12                	jne    80105673 <uartputc+0x3a>
    microdelay(10);
80105661:	83 ec 0c             	sub    $0xc,%esp
80105664:	6a 0a                	push   $0xa
80105666:	e8 b5 cf ff ff       	call   80102620 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010566b:	83 c3 01             	add    $0x1,%ebx
8010566e:	83 c4 10             	add    $0x10,%esp
80105671:	eb df                	jmp    80105652 <uartputc+0x19>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105673:	8b 45 08             	mov    0x8(%ebp),%eax
80105676:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010567b:	ee                   	out    %al,(%dx)
}
8010567c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010567f:	c9                   	leave  
80105680:	c3                   	ret    
80105681:	c3                   	ret    

80105682 <uartinit>:
{
80105682:	f3 0f 1e fb          	endbr32 
80105686:	55                   	push   %ebp
80105687:	89 e5                	mov    %esp,%ebp
80105689:	56                   	push   %esi
8010568a:	53                   	push   %ebx
8010568b:	b9 00 00 00 00       	mov    $0x0,%ecx
80105690:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105695:	89 c8                	mov    %ecx,%eax
80105697:	ee                   	out    %al,(%dx)
80105698:	be fb 03 00 00       	mov    $0x3fb,%esi
8010569d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801056a2:	89 f2                	mov    %esi,%edx
801056a4:	ee                   	out    %al,(%dx)
801056a5:	b8 0c 00 00 00       	mov    $0xc,%eax
801056aa:	ba f8 03 00 00       	mov    $0x3f8,%edx
801056af:	ee                   	out    %al,(%dx)
801056b0:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801056b5:	89 c8                	mov    %ecx,%eax
801056b7:	89 da                	mov    %ebx,%edx
801056b9:	ee                   	out    %al,(%dx)
801056ba:	b8 03 00 00 00       	mov    $0x3,%eax
801056bf:	89 f2                	mov    %esi,%edx
801056c1:	ee                   	out    %al,(%dx)
801056c2:	ba fc 03 00 00       	mov    $0x3fc,%edx
801056c7:	89 c8                	mov    %ecx,%eax
801056c9:	ee                   	out    %al,(%dx)
801056ca:	b8 01 00 00 00       	mov    $0x1,%eax
801056cf:	89 da                	mov    %ebx,%edx
801056d1:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801056d2:	ba fd 03 00 00       	mov    $0x3fd,%edx
801056d7:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801056d8:	3c ff                	cmp    $0xff,%al
801056da:	74 45                	je     80105721 <uartinit+0x9f>
  uart = 1;
801056dc:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
801056e3:	00 00 00 
801056e6:	ba fa 03 00 00       	mov    $0x3fa,%edx
801056eb:	ec                   	in     (%dx),%al
801056ec:	ba f8 03 00 00       	mov    $0x3f8,%edx
801056f1:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801056f2:	83 ec 08             	sub    $0x8,%esp
801056f5:	6a 00                	push   $0x0
801056f7:	6a 04                	push   $0x4
801056f9:	e8 8f ca ff ff       	call   8010218d <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801056fe:	83 c4 10             	add    $0x10,%esp
80105701:	bb f8 79 10 80       	mov    $0x801079f8,%ebx
80105706:	eb 12                	jmp    8010571a <uartinit+0x98>
    uartputc(*p);
80105708:	83 ec 0c             	sub    $0xc,%esp
8010570b:	0f be c0             	movsbl %al,%eax
8010570e:	50                   	push   %eax
8010570f:	e8 25 ff ff ff       	call   80105639 <uartputc>
  for(p="xv6...\n"; *p; p++)
80105714:	83 c3 01             	add    $0x1,%ebx
80105717:	83 c4 10             	add    $0x10,%esp
8010571a:	0f b6 03             	movzbl (%ebx),%eax
8010571d:	84 c0                	test   %al,%al
8010571f:	75 e7                	jne    80105708 <uartinit+0x86>
}
80105721:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105724:	5b                   	pop    %ebx
80105725:	5e                   	pop    %esi
80105726:	5d                   	pop    %ebp
80105727:	c3                   	ret    

80105728 <uartintr>:

void
uartintr(void)
{
80105728:	f3 0f 1e fb          	endbr32 
8010572c:	55                   	push   %ebp
8010572d:	89 e5                	mov    %esp,%ebp
8010572f:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105732:	68 0c 56 10 80       	push   $0x8010560c
80105737:	e8 1d b0 ff ff       	call   80100759 <consoleintr>
}
8010573c:	83 c4 10             	add    $0x10,%esp
8010573f:	c9                   	leave  
80105740:	c3                   	ret    

80105741 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105741:	6a 00                	push   $0x0
  pushl $0
80105743:	6a 00                	push   $0x0
  jmp alltraps
80105745:	e9 a8 fb ff ff       	jmp    801052f2 <alltraps>

8010574a <vector1>:
.globl vector1
vector1:
  pushl $0
8010574a:	6a 00                	push   $0x0
  pushl $1
8010574c:	6a 01                	push   $0x1
  jmp alltraps
8010574e:	e9 9f fb ff ff       	jmp    801052f2 <alltraps>

80105753 <vector2>:
.globl vector2
vector2:
  pushl $0
80105753:	6a 00                	push   $0x0
  pushl $2
80105755:	6a 02                	push   $0x2
  jmp alltraps
80105757:	e9 96 fb ff ff       	jmp    801052f2 <alltraps>

8010575c <vector3>:
.globl vector3
vector3:
  pushl $0
8010575c:	6a 00                	push   $0x0
  pushl $3
8010575e:	6a 03                	push   $0x3
  jmp alltraps
80105760:	e9 8d fb ff ff       	jmp    801052f2 <alltraps>

80105765 <vector4>:
.globl vector4
vector4:
  pushl $0
80105765:	6a 00                	push   $0x0
  pushl $4
80105767:	6a 04                	push   $0x4
  jmp alltraps
80105769:	e9 84 fb ff ff       	jmp    801052f2 <alltraps>

8010576e <vector5>:
.globl vector5
vector5:
  pushl $0
8010576e:	6a 00                	push   $0x0
  pushl $5
80105770:	6a 05                	push   $0x5
  jmp alltraps
80105772:	e9 7b fb ff ff       	jmp    801052f2 <alltraps>

80105777 <vector6>:
.globl vector6
vector6:
  pushl $0
80105777:	6a 00                	push   $0x0
  pushl $6
80105779:	6a 06                	push   $0x6
  jmp alltraps
8010577b:	e9 72 fb ff ff       	jmp    801052f2 <alltraps>

80105780 <vector7>:
.globl vector7
vector7:
  pushl $0
80105780:	6a 00                	push   $0x0
  pushl $7
80105782:	6a 07                	push   $0x7
  jmp alltraps
80105784:	e9 69 fb ff ff       	jmp    801052f2 <alltraps>

80105789 <vector8>:
.globl vector8
vector8:
  pushl $8
80105789:	6a 08                	push   $0x8
  jmp alltraps
8010578b:	e9 62 fb ff ff       	jmp    801052f2 <alltraps>

80105790 <vector9>:
.globl vector9
vector9:
  pushl $0
80105790:	6a 00                	push   $0x0
  pushl $9
80105792:	6a 09                	push   $0x9
  jmp alltraps
80105794:	e9 59 fb ff ff       	jmp    801052f2 <alltraps>

80105799 <vector10>:
.globl vector10
vector10:
  pushl $10
80105799:	6a 0a                	push   $0xa
  jmp alltraps
8010579b:	e9 52 fb ff ff       	jmp    801052f2 <alltraps>

801057a0 <vector11>:
.globl vector11
vector11:
  pushl $11
801057a0:	6a 0b                	push   $0xb
  jmp alltraps
801057a2:	e9 4b fb ff ff       	jmp    801052f2 <alltraps>

801057a7 <vector12>:
.globl vector12
vector12:
  pushl $12
801057a7:	6a 0c                	push   $0xc
  jmp alltraps
801057a9:	e9 44 fb ff ff       	jmp    801052f2 <alltraps>

801057ae <vector13>:
.globl vector13
vector13:
  pushl $13
801057ae:	6a 0d                	push   $0xd
  jmp alltraps
801057b0:	e9 3d fb ff ff       	jmp    801052f2 <alltraps>

801057b5 <vector14>:
.globl vector14
vector14:
  pushl $14
801057b5:	6a 0e                	push   $0xe
  jmp alltraps
801057b7:	e9 36 fb ff ff       	jmp    801052f2 <alltraps>

801057bc <vector15>:
.globl vector15
vector15:
  pushl $0
801057bc:	6a 00                	push   $0x0
  pushl $15
801057be:	6a 0f                	push   $0xf
  jmp alltraps
801057c0:	e9 2d fb ff ff       	jmp    801052f2 <alltraps>

801057c5 <vector16>:
.globl vector16
vector16:
  pushl $0
801057c5:	6a 00                	push   $0x0
  pushl $16
801057c7:	6a 10                	push   $0x10
  jmp alltraps
801057c9:	e9 24 fb ff ff       	jmp    801052f2 <alltraps>

801057ce <vector17>:
.globl vector17
vector17:
  pushl $17
801057ce:	6a 11                	push   $0x11
  jmp alltraps
801057d0:	e9 1d fb ff ff       	jmp    801052f2 <alltraps>

801057d5 <vector18>:
.globl vector18
vector18:
  pushl $0
801057d5:	6a 00                	push   $0x0
  pushl $18
801057d7:	6a 12                	push   $0x12
  jmp alltraps
801057d9:	e9 14 fb ff ff       	jmp    801052f2 <alltraps>

801057de <vector19>:
.globl vector19
vector19:
  pushl $0
801057de:	6a 00                	push   $0x0
  pushl $19
801057e0:	6a 13                	push   $0x13
  jmp alltraps
801057e2:	e9 0b fb ff ff       	jmp    801052f2 <alltraps>

801057e7 <vector20>:
.globl vector20
vector20:
  pushl $0
801057e7:	6a 00                	push   $0x0
  pushl $20
801057e9:	6a 14                	push   $0x14
  jmp alltraps
801057eb:	e9 02 fb ff ff       	jmp    801052f2 <alltraps>

801057f0 <vector21>:
.globl vector21
vector21:
  pushl $0
801057f0:	6a 00                	push   $0x0
  pushl $21
801057f2:	6a 15                	push   $0x15
  jmp alltraps
801057f4:	e9 f9 fa ff ff       	jmp    801052f2 <alltraps>

801057f9 <vector22>:
.globl vector22
vector22:
  pushl $0
801057f9:	6a 00                	push   $0x0
  pushl $22
801057fb:	6a 16                	push   $0x16
  jmp alltraps
801057fd:	e9 f0 fa ff ff       	jmp    801052f2 <alltraps>

80105802 <vector23>:
.globl vector23
vector23:
  pushl $0
80105802:	6a 00                	push   $0x0
  pushl $23
80105804:	6a 17                	push   $0x17
  jmp alltraps
80105806:	e9 e7 fa ff ff       	jmp    801052f2 <alltraps>

8010580b <vector24>:
.globl vector24
vector24:
  pushl $0
8010580b:	6a 00                	push   $0x0
  pushl $24
8010580d:	6a 18                	push   $0x18
  jmp alltraps
8010580f:	e9 de fa ff ff       	jmp    801052f2 <alltraps>

80105814 <vector25>:
.globl vector25
vector25:
  pushl $0
80105814:	6a 00                	push   $0x0
  pushl $25
80105816:	6a 19                	push   $0x19
  jmp alltraps
80105818:	e9 d5 fa ff ff       	jmp    801052f2 <alltraps>

8010581d <vector26>:
.globl vector26
vector26:
  pushl $0
8010581d:	6a 00                	push   $0x0
  pushl $26
8010581f:	6a 1a                	push   $0x1a
  jmp alltraps
80105821:	e9 cc fa ff ff       	jmp    801052f2 <alltraps>

80105826 <vector27>:
.globl vector27
vector27:
  pushl $0
80105826:	6a 00                	push   $0x0
  pushl $27
80105828:	6a 1b                	push   $0x1b
  jmp alltraps
8010582a:	e9 c3 fa ff ff       	jmp    801052f2 <alltraps>

8010582f <vector28>:
.globl vector28
vector28:
  pushl $0
8010582f:	6a 00                	push   $0x0
  pushl $28
80105831:	6a 1c                	push   $0x1c
  jmp alltraps
80105833:	e9 ba fa ff ff       	jmp    801052f2 <alltraps>

80105838 <vector29>:
.globl vector29
vector29:
  pushl $0
80105838:	6a 00                	push   $0x0
  pushl $29
8010583a:	6a 1d                	push   $0x1d
  jmp alltraps
8010583c:	e9 b1 fa ff ff       	jmp    801052f2 <alltraps>

80105841 <vector30>:
.globl vector30
vector30:
  pushl $0
80105841:	6a 00                	push   $0x0
  pushl $30
80105843:	6a 1e                	push   $0x1e
  jmp alltraps
80105845:	e9 a8 fa ff ff       	jmp    801052f2 <alltraps>

8010584a <vector31>:
.globl vector31
vector31:
  pushl $0
8010584a:	6a 00                	push   $0x0
  pushl $31
8010584c:	6a 1f                	push   $0x1f
  jmp alltraps
8010584e:	e9 9f fa ff ff       	jmp    801052f2 <alltraps>

80105853 <vector32>:
.globl vector32
vector32:
  pushl $0
80105853:	6a 00                	push   $0x0
  pushl $32
80105855:	6a 20                	push   $0x20
  jmp alltraps
80105857:	e9 96 fa ff ff       	jmp    801052f2 <alltraps>

8010585c <vector33>:
.globl vector33
vector33:
  pushl $0
8010585c:	6a 00                	push   $0x0
  pushl $33
8010585e:	6a 21                	push   $0x21
  jmp alltraps
80105860:	e9 8d fa ff ff       	jmp    801052f2 <alltraps>

80105865 <vector34>:
.globl vector34
vector34:
  pushl $0
80105865:	6a 00                	push   $0x0
  pushl $34
80105867:	6a 22                	push   $0x22
  jmp alltraps
80105869:	e9 84 fa ff ff       	jmp    801052f2 <alltraps>

8010586e <vector35>:
.globl vector35
vector35:
  pushl $0
8010586e:	6a 00                	push   $0x0
  pushl $35
80105870:	6a 23                	push   $0x23
  jmp alltraps
80105872:	e9 7b fa ff ff       	jmp    801052f2 <alltraps>

80105877 <vector36>:
.globl vector36
vector36:
  pushl $0
80105877:	6a 00                	push   $0x0
  pushl $36
80105879:	6a 24                	push   $0x24
  jmp alltraps
8010587b:	e9 72 fa ff ff       	jmp    801052f2 <alltraps>

80105880 <vector37>:
.globl vector37
vector37:
  pushl $0
80105880:	6a 00                	push   $0x0
  pushl $37
80105882:	6a 25                	push   $0x25
  jmp alltraps
80105884:	e9 69 fa ff ff       	jmp    801052f2 <alltraps>

80105889 <vector38>:
.globl vector38
vector38:
  pushl $0
80105889:	6a 00                	push   $0x0
  pushl $38
8010588b:	6a 26                	push   $0x26
  jmp alltraps
8010588d:	e9 60 fa ff ff       	jmp    801052f2 <alltraps>

80105892 <vector39>:
.globl vector39
vector39:
  pushl $0
80105892:	6a 00                	push   $0x0
  pushl $39
80105894:	6a 27                	push   $0x27
  jmp alltraps
80105896:	e9 57 fa ff ff       	jmp    801052f2 <alltraps>

8010589b <vector40>:
.globl vector40
vector40:
  pushl $0
8010589b:	6a 00                	push   $0x0
  pushl $40
8010589d:	6a 28                	push   $0x28
  jmp alltraps
8010589f:	e9 4e fa ff ff       	jmp    801052f2 <alltraps>

801058a4 <vector41>:
.globl vector41
vector41:
  pushl $0
801058a4:	6a 00                	push   $0x0
  pushl $41
801058a6:	6a 29                	push   $0x29
  jmp alltraps
801058a8:	e9 45 fa ff ff       	jmp    801052f2 <alltraps>

801058ad <vector42>:
.globl vector42
vector42:
  pushl $0
801058ad:	6a 00                	push   $0x0
  pushl $42
801058af:	6a 2a                	push   $0x2a
  jmp alltraps
801058b1:	e9 3c fa ff ff       	jmp    801052f2 <alltraps>

801058b6 <vector43>:
.globl vector43
vector43:
  pushl $0
801058b6:	6a 00                	push   $0x0
  pushl $43
801058b8:	6a 2b                	push   $0x2b
  jmp alltraps
801058ba:	e9 33 fa ff ff       	jmp    801052f2 <alltraps>

801058bf <vector44>:
.globl vector44
vector44:
  pushl $0
801058bf:	6a 00                	push   $0x0
  pushl $44
801058c1:	6a 2c                	push   $0x2c
  jmp alltraps
801058c3:	e9 2a fa ff ff       	jmp    801052f2 <alltraps>

801058c8 <vector45>:
.globl vector45
vector45:
  pushl $0
801058c8:	6a 00                	push   $0x0
  pushl $45
801058ca:	6a 2d                	push   $0x2d
  jmp alltraps
801058cc:	e9 21 fa ff ff       	jmp    801052f2 <alltraps>

801058d1 <vector46>:
.globl vector46
vector46:
  pushl $0
801058d1:	6a 00                	push   $0x0
  pushl $46
801058d3:	6a 2e                	push   $0x2e
  jmp alltraps
801058d5:	e9 18 fa ff ff       	jmp    801052f2 <alltraps>

801058da <vector47>:
.globl vector47
vector47:
  pushl $0
801058da:	6a 00                	push   $0x0
  pushl $47
801058dc:	6a 2f                	push   $0x2f
  jmp alltraps
801058de:	e9 0f fa ff ff       	jmp    801052f2 <alltraps>

801058e3 <vector48>:
.globl vector48
vector48:
  pushl $0
801058e3:	6a 00                	push   $0x0
  pushl $48
801058e5:	6a 30                	push   $0x30
  jmp alltraps
801058e7:	e9 06 fa ff ff       	jmp    801052f2 <alltraps>

801058ec <vector49>:
.globl vector49
vector49:
  pushl $0
801058ec:	6a 00                	push   $0x0
  pushl $49
801058ee:	6a 31                	push   $0x31
  jmp alltraps
801058f0:	e9 fd f9 ff ff       	jmp    801052f2 <alltraps>

801058f5 <vector50>:
.globl vector50
vector50:
  pushl $0
801058f5:	6a 00                	push   $0x0
  pushl $50
801058f7:	6a 32                	push   $0x32
  jmp alltraps
801058f9:	e9 f4 f9 ff ff       	jmp    801052f2 <alltraps>

801058fe <vector51>:
.globl vector51
vector51:
  pushl $0
801058fe:	6a 00                	push   $0x0
  pushl $51
80105900:	6a 33                	push   $0x33
  jmp alltraps
80105902:	e9 eb f9 ff ff       	jmp    801052f2 <alltraps>

80105907 <vector52>:
.globl vector52
vector52:
  pushl $0
80105907:	6a 00                	push   $0x0
  pushl $52
80105909:	6a 34                	push   $0x34
  jmp alltraps
8010590b:	e9 e2 f9 ff ff       	jmp    801052f2 <alltraps>

80105910 <vector53>:
.globl vector53
vector53:
  pushl $0
80105910:	6a 00                	push   $0x0
  pushl $53
80105912:	6a 35                	push   $0x35
  jmp alltraps
80105914:	e9 d9 f9 ff ff       	jmp    801052f2 <alltraps>

80105919 <vector54>:
.globl vector54
vector54:
  pushl $0
80105919:	6a 00                	push   $0x0
  pushl $54
8010591b:	6a 36                	push   $0x36
  jmp alltraps
8010591d:	e9 d0 f9 ff ff       	jmp    801052f2 <alltraps>

80105922 <vector55>:
.globl vector55
vector55:
  pushl $0
80105922:	6a 00                	push   $0x0
  pushl $55
80105924:	6a 37                	push   $0x37
  jmp alltraps
80105926:	e9 c7 f9 ff ff       	jmp    801052f2 <alltraps>

8010592b <vector56>:
.globl vector56
vector56:
  pushl $0
8010592b:	6a 00                	push   $0x0
  pushl $56
8010592d:	6a 38                	push   $0x38
  jmp alltraps
8010592f:	e9 be f9 ff ff       	jmp    801052f2 <alltraps>

80105934 <vector57>:
.globl vector57
vector57:
  pushl $0
80105934:	6a 00                	push   $0x0
  pushl $57
80105936:	6a 39                	push   $0x39
  jmp alltraps
80105938:	e9 b5 f9 ff ff       	jmp    801052f2 <alltraps>

8010593d <vector58>:
.globl vector58
vector58:
  pushl $0
8010593d:	6a 00                	push   $0x0
  pushl $58
8010593f:	6a 3a                	push   $0x3a
  jmp alltraps
80105941:	e9 ac f9 ff ff       	jmp    801052f2 <alltraps>

80105946 <vector59>:
.globl vector59
vector59:
  pushl $0
80105946:	6a 00                	push   $0x0
  pushl $59
80105948:	6a 3b                	push   $0x3b
  jmp alltraps
8010594a:	e9 a3 f9 ff ff       	jmp    801052f2 <alltraps>

8010594f <vector60>:
.globl vector60
vector60:
  pushl $0
8010594f:	6a 00                	push   $0x0
  pushl $60
80105951:	6a 3c                	push   $0x3c
  jmp alltraps
80105953:	e9 9a f9 ff ff       	jmp    801052f2 <alltraps>

80105958 <vector61>:
.globl vector61
vector61:
  pushl $0
80105958:	6a 00                	push   $0x0
  pushl $61
8010595a:	6a 3d                	push   $0x3d
  jmp alltraps
8010595c:	e9 91 f9 ff ff       	jmp    801052f2 <alltraps>

80105961 <vector62>:
.globl vector62
vector62:
  pushl $0
80105961:	6a 00                	push   $0x0
  pushl $62
80105963:	6a 3e                	push   $0x3e
  jmp alltraps
80105965:	e9 88 f9 ff ff       	jmp    801052f2 <alltraps>

8010596a <vector63>:
.globl vector63
vector63:
  pushl $0
8010596a:	6a 00                	push   $0x0
  pushl $63
8010596c:	6a 3f                	push   $0x3f
  jmp alltraps
8010596e:	e9 7f f9 ff ff       	jmp    801052f2 <alltraps>

80105973 <vector64>:
.globl vector64
vector64:
  pushl $0
80105973:	6a 00                	push   $0x0
  pushl $64
80105975:	6a 40                	push   $0x40
  jmp alltraps
80105977:	e9 76 f9 ff ff       	jmp    801052f2 <alltraps>

8010597c <vector65>:
.globl vector65
vector65:
  pushl $0
8010597c:	6a 00                	push   $0x0
  pushl $65
8010597e:	6a 41                	push   $0x41
  jmp alltraps
80105980:	e9 6d f9 ff ff       	jmp    801052f2 <alltraps>

80105985 <vector66>:
.globl vector66
vector66:
  pushl $0
80105985:	6a 00                	push   $0x0
  pushl $66
80105987:	6a 42                	push   $0x42
  jmp alltraps
80105989:	e9 64 f9 ff ff       	jmp    801052f2 <alltraps>

8010598e <vector67>:
.globl vector67
vector67:
  pushl $0
8010598e:	6a 00                	push   $0x0
  pushl $67
80105990:	6a 43                	push   $0x43
  jmp alltraps
80105992:	e9 5b f9 ff ff       	jmp    801052f2 <alltraps>

80105997 <vector68>:
.globl vector68
vector68:
  pushl $0
80105997:	6a 00                	push   $0x0
  pushl $68
80105999:	6a 44                	push   $0x44
  jmp alltraps
8010599b:	e9 52 f9 ff ff       	jmp    801052f2 <alltraps>

801059a0 <vector69>:
.globl vector69
vector69:
  pushl $0
801059a0:	6a 00                	push   $0x0
  pushl $69
801059a2:	6a 45                	push   $0x45
  jmp alltraps
801059a4:	e9 49 f9 ff ff       	jmp    801052f2 <alltraps>

801059a9 <vector70>:
.globl vector70
vector70:
  pushl $0
801059a9:	6a 00                	push   $0x0
  pushl $70
801059ab:	6a 46                	push   $0x46
  jmp alltraps
801059ad:	e9 40 f9 ff ff       	jmp    801052f2 <alltraps>

801059b2 <vector71>:
.globl vector71
vector71:
  pushl $0
801059b2:	6a 00                	push   $0x0
  pushl $71
801059b4:	6a 47                	push   $0x47
  jmp alltraps
801059b6:	e9 37 f9 ff ff       	jmp    801052f2 <alltraps>

801059bb <vector72>:
.globl vector72
vector72:
  pushl $0
801059bb:	6a 00                	push   $0x0
  pushl $72
801059bd:	6a 48                	push   $0x48
  jmp alltraps
801059bf:	e9 2e f9 ff ff       	jmp    801052f2 <alltraps>

801059c4 <vector73>:
.globl vector73
vector73:
  pushl $0
801059c4:	6a 00                	push   $0x0
  pushl $73
801059c6:	6a 49                	push   $0x49
  jmp alltraps
801059c8:	e9 25 f9 ff ff       	jmp    801052f2 <alltraps>

801059cd <vector74>:
.globl vector74
vector74:
  pushl $0
801059cd:	6a 00                	push   $0x0
  pushl $74
801059cf:	6a 4a                	push   $0x4a
  jmp alltraps
801059d1:	e9 1c f9 ff ff       	jmp    801052f2 <alltraps>

801059d6 <vector75>:
.globl vector75
vector75:
  pushl $0
801059d6:	6a 00                	push   $0x0
  pushl $75
801059d8:	6a 4b                	push   $0x4b
  jmp alltraps
801059da:	e9 13 f9 ff ff       	jmp    801052f2 <alltraps>

801059df <vector76>:
.globl vector76
vector76:
  pushl $0
801059df:	6a 00                	push   $0x0
  pushl $76
801059e1:	6a 4c                	push   $0x4c
  jmp alltraps
801059e3:	e9 0a f9 ff ff       	jmp    801052f2 <alltraps>

801059e8 <vector77>:
.globl vector77
vector77:
  pushl $0
801059e8:	6a 00                	push   $0x0
  pushl $77
801059ea:	6a 4d                	push   $0x4d
  jmp alltraps
801059ec:	e9 01 f9 ff ff       	jmp    801052f2 <alltraps>

801059f1 <vector78>:
.globl vector78
vector78:
  pushl $0
801059f1:	6a 00                	push   $0x0
  pushl $78
801059f3:	6a 4e                	push   $0x4e
  jmp alltraps
801059f5:	e9 f8 f8 ff ff       	jmp    801052f2 <alltraps>

801059fa <vector79>:
.globl vector79
vector79:
  pushl $0
801059fa:	6a 00                	push   $0x0
  pushl $79
801059fc:	6a 4f                	push   $0x4f
  jmp alltraps
801059fe:	e9 ef f8 ff ff       	jmp    801052f2 <alltraps>

80105a03 <vector80>:
.globl vector80
vector80:
  pushl $0
80105a03:	6a 00                	push   $0x0
  pushl $80
80105a05:	6a 50                	push   $0x50
  jmp alltraps
80105a07:	e9 e6 f8 ff ff       	jmp    801052f2 <alltraps>

80105a0c <vector81>:
.globl vector81
vector81:
  pushl $0
80105a0c:	6a 00                	push   $0x0
  pushl $81
80105a0e:	6a 51                	push   $0x51
  jmp alltraps
80105a10:	e9 dd f8 ff ff       	jmp    801052f2 <alltraps>

80105a15 <vector82>:
.globl vector82
vector82:
  pushl $0
80105a15:	6a 00                	push   $0x0
  pushl $82
80105a17:	6a 52                	push   $0x52
  jmp alltraps
80105a19:	e9 d4 f8 ff ff       	jmp    801052f2 <alltraps>

80105a1e <vector83>:
.globl vector83
vector83:
  pushl $0
80105a1e:	6a 00                	push   $0x0
  pushl $83
80105a20:	6a 53                	push   $0x53
  jmp alltraps
80105a22:	e9 cb f8 ff ff       	jmp    801052f2 <alltraps>

80105a27 <vector84>:
.globl vector84
vector84:
  pushl $0
80105a27:	6a 00                	push   $0x0
  pushl $84
80105a29:	6a 54                	push   $0x54
  jmp alltraps
80105a2b:	e9 c2 f8 ff ff       	jmp    801052f2 <alltraps>

80105a30 <vector85>:
.globl vector85
vector85:
  pushl $0
80105a30:	6a 00                	push   $0x0
  pushl $85
80105a32:	6a 55                	push   $0x55
  jmp alltraps
80105a34:	e9 b9 f8 ff ff       	jmp    801052f2 <alltraps>

80105a39 <vector86>:
.globl vector86
vector86:
  pushl $0
80105a39:	6a 00                	push   $0x0
  pushl $86
80105a3b:	6a 56                	push   $0x56
  jmp alltraps
80105a3d:	e9 b0 f8 ff ff       	jmp    801052f2 <alltraps>

80105a42 <vector87>:
.globl vector87
vector87:
  pushl $0
80105a42:	6a 00                	push   $0x0
  pushl $87
80105a44:	6a 57                	push   $0x57
  jmp alltraps
80105a46:	e9 a7 f8 ff ff       	jmp    801052f2 <alltraps>

80105a4b <vector88>:
.globl vector88
vector88:
  pushl $0
80105a4b:	6a 00                	push   $0x0
  pushl $88
80105a4d:	6a 58                	push   $0x58
  jmp alltraps
80105a4f:	e9 9e f8 ff ff       	jmp    801052f2 <alltraps>

80105a54 <vector89>:
.globl vector89
vector89:
  pushl $0
80105a54:	6a 00                	push   $0x0
  pushl $89
80105a56:	6a 59                	push   $0x59
  jmp alltraps
80105a58:	e9 95 f8 ff ff       	jmp    801052f2 <alltraps>

80105a5d <vector90>:
.globl vector90
vector90:
  pushl $0
80105a5d:	6a 00                	push   $0x0
  pushl $90
80105a5f:	6a 5a                	push   $0x5a
  jmp alltraps
80105a61:	e9 8c f8 ff ff       	jmp    801052f2 <alltraps>

80105a66 <vector91>:
.globl vector91
vector91:
  pushl $0
80105a66:	6a 00                	push   $0x0
  pushl $91
80105a68:	6a 5b                	push   $0x5b
  jmp alltraps
80105a6a:	e9 83 f8 ff ff       	jmp    801052f2 <alltraps>

80105a6f <vector92>:
.globl vector92
vector92:
  pushl $0
80105a6f:	6a 00                	push   $0x0
  pushl $92
80105a71:	6a 5c                	push   $0x5c
  jmp alltraps
80105a73:	e9 7a f8 ff ff       	jmp    801052f2 <alltraps>

80105a78 <vector93>:
.globl vector93
vector93:
  pushl $0
80105a78:	6a 00                	push   $0x0
  pushl $93
80105a7a:	6a 5d                	push   $0x5d
  jmp alltraps
80105a7c:	e9 71 f8 ff ff       	jmp    801052f2 <alltraps>

80105a81 <vector94>:
.globl vector94
vector94:
  pushl $0
80105a81:	6a 00                	push   $0x0
  pushl $94
80105a83:	6a 5e                	push   $0x5e
  jmp alltraps
80105a85:	e9 68 f8 ff ff       	jmp    801052f2 <alltraps>

80105a8a <vector95>:
.globl vector95
vector95:
  pushl $0
80105a8a:	6a 00                	push   $0x0
  pushl $95
80105a8c:	6a 5f                	push   $0x5f
  jmp alltraps
80105a8e:	e9 5f f8 ff ff       	jmp    801052f2 <alltraps>

80105a93 <vector96>:
.globl vector96
vector96:
  pushl $0
80105a93:	6a 00                	push   $0x0
  pushl $96
80105a95:	6a 60                	push   $0x60
  jmp alltraps
80105a97:	e9 56 f8 ff ff       	jmp    801052f2 <alltraps>

80105a9c <vector97>:
.globl vector97
vector97:
  pushl $0
80105a9c:	6a 00                	push   $0x0
  pushl $97
80105a9e:	6a 61                	push   $0x61
  jmp alltraps
80105aa0:	e9 4d f8 ff ff       	jmp    801052f2 <alltraps>

80105aa5 <vector98>:
.globl vector98
vector98:
  pushl $0
80105aa5:	6a 00                	push   $0x0
  pushl $98
80105aa7:	6a 62                	push   $0x62
  jmp alltraps
80105aa9:	e9 44 f8 ff ff       	jmp    801052f2 <alltraps>

80105aae <vector99>:
.globl vector99
vector99:
  pushl $0
80105aae:	6a 00                	push   $0x0
  pushl $99
80105ab0:	6a 63                	push   $0x63
  jmp alltraps
80105ab2:	e9 3b f8 ff ff       	jmp    801052f2 <alltraps>

80105ab7 <vector100>:
.globl vector100
vector100:
  pushl $0
80105ab7:	6a 00                	push   $0x0
  pushl $100
80105ab9:	6a 64                	push   $0x64
  jmp alltraps
80105abb:	e9 32 f8 ff ff       	jmp    801052f2 <alltraps>

80105ac0 <vector101>:
.globl vector101
vector101:
  pushl $0
80105ac0:	6a 00                	push   $0x0
  pushl $101
80105ac2:	6a 65                	push   $0x65
  jmp alltraps
80105ac4:	e9 29 f8 ff ff       	jmp    801052f2 <alltraps>

80105ac9 <vector102>:
.globl vector102
vector102:
  pushl $0
80105ac9:	6a 00                	push   $0x0
  pushl $102
80105acb:	6a 66                	push   $0x66
  jmp alltraps
80105acd:	e9 20 f8 ff ff       	jmp    801052f2 <alltraps>

80105ad2 <vector103>:
.globl vector103
vector103:
  pushl $0
80105ad2:	6a 00                	push   $0x0
  pushl $103
80105ad4:	6a 67                	push   $0x67
  jmp alltraps
80105ad6:	e9 17 f8 ff ff       	jmp    801052f2 <alltraps>

80105adb <vector104>:
.globl vector104
vector104:
  pushl $0
80105adb:	6a 00                	push   $0x0
  pushl $104
80105add:	6a 68                	push   $0x68
  jmp alltraps
80105adf:	e9 0e f8 ff ff       	jmp    801052f2 <alltraps>

80105ae4 <vector105>:
.globl vector105
vector105:
  pushl $0
80105ae4:	6a 00                	push   $0x0
  pushl $105
80105ae6:	6a 69                	push   $0x69
  jmp alltraps
80105ae8:	e9 05 f8 ff ff       	jmp    801052f2 <alltraps>

80105aed <vector106>:
.globl vector106
vector106:
  pushl $0
80105aed:	6a 00                	push   $0x0
  pushl $106
80105aef:	6a 6a                	push   $0x6a
  jmp alltraps
80105af1:	e9 fc f7 ff ff       	jmp    801052f2 <alltraps>

80105af6 <vector107>:
.globl vector107
vector107:
  pushl $0
80105af6:	6a 00                	push   $0x0
  pushl $107
80105af8:	6a 6b                	push   $0x6b
  jmp alltraps
80105afa:	e9 f3 f7 ff ff       	jmp    801052f2 <alltraps>

80105aff <vector108>:
.globl vector108
vector108:
  pushl $0
80105aff:	6a 00                	push   $0x0
  pushl $108
80105b01:	6a 6c                	push   $0x6c
  jmp alltraps
80105b03:	e9 ea f7 ff ff       	jmp    801052f2 <alltraps>

80105b08 <vector109>:
.globl vector109
vector109:
  pushl $0
80105b08:	6a 00                	push   $0x0
  pushl $109
80105b0a:	6a 6d                	push   $0x6d
  jmp alltraps
80105b0c:	e9 e1 f7 ff ff       	jmp    801052f2 <alltraps>

80105b11 <vector110>:
.globl vector110
vector110:
  pushl $0
80105b11:	6a 00                	push   $0x0
  pushl $110
80105b13:	6a 6e                	push   $0x6e
  jmp alltraps
80105b15:	e9 d8 f7 ff ff       	jmp    801052f2 <alltraps>

80105b1a <vector111>:
.globl vector111
vector111:
  pushl $0
80105b1a:	6a 00                	push   $0x0
  pushl $111
80105b1c:	6a 6f                	push   $0x6f
  jmp alltraps
80105b1e:	e9 cf f7 ff ff       	jmp    801052f2 <alltraps>

80105b23 <vector112>:
.globl vector112
vector112:
  pushl $0
80105b23:	6a 00                	push   $0x0
  pushl $112
80105b25:	6a 70                	push   $0x70
  jmp alltraps
80105b27:	e9 c6 f7 ff ff       	jmp    801052f2 <alltraps>

80105b2c <vector113>:
.globl vector113
vector113:
  pushl $0
80105b2c:	6a 00                	push   $0x0
  pushl $113
80105b2e:	6a 71                	push   $0x71
  jmp alltraps
80105b30:	e9 bd f7 ff ff       	jmp    801052f2 <alltraps>

80105b35 <vector114>:
.globl vector114
vector114:
  pushl $0
80105b35:	6a 00                	push   $0x0
  pushl $114
80105b37:	6a 72                	push   $0x72
  jmp alltraps
80105b39:	e9 b4 f7 ff ff       	jmp    801052f2 <alltraps>

80105b3e <vector115>:
.globl vector115
vector115:
  pushl $0
80105b3e:	6a 00                	push   $0x0
  pushl $115
80105b40:	6a 73                	push   $0x73
  jmp alltraps
80105b42:	e9 ab f7 ff ff       	jmp    801052f2 <alltraps>

80105b47 <vector116>:
.globl vector116
vector116:
  pushl $0
80105b47:	6a 00                	push   $0x0
  pushl $116
80105b49:	6a 74                	push   $0x74
  jmp alltraps
80105b4b:	e9 a2 f7 ff ff       	jmp    801052f2 <alltraps>

80105b50 <vector117>:
.globl vector117
vector117:
  pushl $0
80105b50:	6a 00                	push   $0x0
  pushl $117
80105b52:	6a 75                	push   $0x75
  jmp alltraps
80105b54:	e9 99 f7 ff ff       	jmp    801052f2 <alltraps>

80105b59 <vector118>:
.globl vector118
vector118:
  pushl $0
80105b59:	6a 00                	push   $0x0
  pushl $118
80105b5b:	6a 76                	push   $0x76
  jmp alltraps
80105b5d:	e9 90 f7 ff ff       	jmp    801052f2 <alltraps>

80105b62 <vector119>:
.globl vector119
vector119:
  pushl $0
80105b62:	6a 00                	push   $0x0
  pushl $119
80105b64:	6a 77                	push   $0x77
  jmp alltraps
80105b66:	e9 87 f7 ff ff       	jmp    801052f2 <alltraps>

80105b6b <vector120>:
.globl vector120
vector120:
  pushl $0
80105b6b:	6a 00                	push   $0x0
  pushl $120
80105b6d:	6a 78                	push   $0x78
  jmp alltraps
80105b6f:	e9 7e f7 ff ff       	jmp    801052f2 <alltraps>

80105b74 <vector121>:
.globl vector121
vector121:
  pushl $0
80105b74:	6a 00                	push   $0x0
  pushl $121
80105b76:	6a 79                	push   $0x79
  jmp alltraps
80105b78:	e9 75 f7 ff ff       	jmp    801052f2 <alltraps>

80105b7d <vector122>:
.globl vector122
vector122:
  pushl $0
80105b7d:	6a 00                	push   $0x0
  pushl $122
80105b7f:	6a 7a                	push   $0x7a
  jmp alltraps
80105b81:	e9 6c f7 ff ff       	jmp    801052f2 <alltraps>

80105b86 <vector123>:
.globl vector123
vector123:
  pushl $0
80105b86:	6a 00                	push   $0x0
  pushl $123
80105b88:	6a 7b                	push   $0x7b
  jmp alltraps
80105b8a:	e9 63 f7 ff ff       	jmp    801052f2 <alltraps>

80105b8f <vector124>:
.globl vector124
vector124:
  pushl $0
80105b8f:	6a 00                	push   $0x0
  pushl $124
80105b91:	6a 7c                	push   $0x7c
  jmp alltraps
80105b93:	e9 5a f7 ff ff       	jmp    801052f2 <alltraps>

80105b98 <vector125>:
.globl vector125
vector125:
  pushl $0
80105b98:	6a 00                	push   $0x0
  pushl $125
80105b9a:	6a 7d                	push   $0x7d
  jmp alltraps
80105b9c:	e9 51 f7 ff ff       	jmp    801052f2 <alltraps>

80105ba1 <vector126>:
.globl vector126
vector126:
  pushl $0
80105ba1:	6a 00                	push   $0x0
  pushl $126
80105ba3:	6a 7e                	push   $0x7e
  jmp alltraps
80105ba5:	e9 48 f7 ff ff       	jmp    801052f2 <alltraps>

80105baa <vector127>:
.globl vector127
vector127:
  pushl $0
80105baa:	6a 00                	push   $0x0
  pushl $127
80105bac:	6a 7f                	push   $0x7f
  jmp alltraps
80105bae:	e9 3f f7 ff ff       	jmp    801052f2 <alltraps>

80105bb3 <vector128>:
.globl vector128
vector128:
  pushl $0
80105bb3:	6a 00                	push   $0x0
  pushl $128
80105bb5:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105bba:	e9 33 f7 ff ff       	jmp    801052f2 <alltraps>

80105bbf <vector129>:
.globl vector129
vector129:
  pushl $0
80105bbf:	6a 00                	push   $0x0
  pushl $129
80105bc1:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105bc6:	e9 27 f7 ff ff       	jmp    801052f2 <alltraps>

80105bcb <vector130>:
.globl vector130
vector130:
  pushl $0
80105bcb:	6a 00                	push   $0x0
  pushl $130
80105bcd:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105bd2:	e9 1b f7 ff ff       	jmp    801052f2 <alltraps>

80105bd7 <vector131>:
.globl vector131
vector131:
  pushl $0
80105bd7:	6a 00                	push   $0x0
  pushl $131
80105bd9:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105bde:	e9 0f f7 ff ff       	jmp    801052f2 <alltraps>

80105be3 <vector132>:
.globl vector132
vector132:
  pushl $0
80105be3:	6a 00                	push   $0x0
  pushl $132
80105be5:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105bea:	e9 03 f7 ff ff       	jmp    801052f2 <alltraps>

80105bef <vector133>:
.globl vector133
vector133:
  pushl $0
80105bef:	6a 00                	push   $0x0
  pushl $133
80105bf1:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105bf6:	e9 f7 f6 ff ff       	jmp    801052f2 <alltraps>

80105bfb <vector134>:
.globl vector134
vector134:
  pushl $0
80105bfb:	6a 00                	push   $0x0
  pushl $134
80105bfd:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105c02:	e9 eb f6 ff ff       	jmp    801052f2 <alltraps>

80105c07 <vector135>:
.globl vector135
vector135:
  pushl $0
80105c07:	6a 00                	push   $0x0
  pushl $135
80105c09:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105c0e:	e9 df f6 ff ff       	jmp    801052f2 <alltraps>

80105c13 <vector136>:
.globl vector136
vector136:
  pushl $0
80105c13:	6a 00                	push   $0x0
  pushl $136
80105c15:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105c1a:	e9 d3 f6 ff ff       	jmp    801052f2 <alltraps>

80105c1f <vector137>:
.globl vector137
vector137:
  pushl $0
80105c1f:	6a 00                	push   $0x0
  pushl $137
80105c21:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105c26:	e9 c7 f6 ff ff       	jmp    801052f2 <alltraps>

80105c2b <vector138>:
.globl vector138
vector138:
  pushl $0
80105c2b:	6a 00                	push   $0x0
  pushl $138
80105c2d:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105c32:	e9 bb f6 ff ff       	jmp    801052f2 <alltraps>

80105c37 <vector139>:
.globl vector139
vector139:
  pushl $0
80105c37:	6a 00                	push   $0x0
  pushl $139
80105c39:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105c3e:	e9 af f6 ff ff       	jmp    801052f2 <alltraps>

80105c43 <vector140>:
.globl vector140
vector140:
  pushl $0
80105c43:	6a 00                	push   $0x0
  pushl $140
80105c45:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105c4a:	e9 a3 f6 ff ff       	jmp    801052f2 <alltraps>

80105c4f <vector141>:
.globl vector141
vector141:
  pushl $0
80105c4f:	6a 00                	push   $0x0
  pushl $141
80105c51:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105c56:	e9 97 f6 ff ff       	jmp    801052f2 <alltraps>

80105c5b <vector142>:
.globl vector142
vector142:
  pushl $0
80105c5b:	6a 00                	push   $0x0
  pushl $142
80105c5d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105c62:	e9 8b f6 ff ff       	jmp    801052f2 <alltraps>

80105c67 <vector143>:
.globl vector143
vector143:
  pushl $0
80105c67:	6a 00                	push   $0x0
  pushl $143
80105c69:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105c6e:	e9 7f f6 ff ff       	jmp    801052f2 <alltraps>

80105c73 <vector144>:
.globl vector144
vector144:
  pushl $0
80105c73:	6a 00                	push   $0x0
  pushl $144
80105c75:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105c7a:	e9 73 f6 ff ff       	jmp    801052f2 <alltraps>

80105c7f <vector145>:
.globl vector145
vector145:
  pushl $0
80105c7f:	6a 00                	push   $0x0
  pushl $145
80105c81:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105c86:	e9 67 f6 ff ff       	jmp    801052f2 <alltraps>

80105c8b <vector146>:
.globl vector146
vector146:
  pushl $0
80105c8b:	6a 00                	push   $0x0
  pushl $146
80105c8d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105c92:	e9 5b f6 ff ff       	jmp    801052f2 <alltraps>

80105c97 <vector147>:
.globl vector147
vector147:
  pushl $0
80105c97:	6a 00                	push   $0x0
  pushl $147
80105c99:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105c9e:	e9 4f f6 ff ff       	jmp    801052f2 <alltraps>

80105ca3 <vector148>:
.globl vector148
vector148:
  pushl $0
80105ca3:	6a 00                	push   $0x0
  pushl $148
80105ca5:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105caa:	e9 43 f6 ff ff       	jmp    801052f2 <alltraps>

80105caf <vector149>:
.globl vector149
vector149:
  pushl $0
80105caf:	6a 00                	push   $0x0
  pushl $149
80105cb1:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105cb6:	e9 37 f6 ff ff       	jmp    801052f2 <alltraps>

80105cbb <vector150>:
.globl vector150
vector150:
  pushl $0
80105cbb:	6a 00                	push   $0x0
  pushl $150
80105cbd:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105cc2:	e9 2b f6 ff ff       	jmp    801052f2 <alltraps>

80105cc7 <vector151>:
.globl vector151
vector151:
  pushl $0
80105cc7:	6a 00                	push   $0x0
  pushl $151
80105cc9:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105cce:	e9 1f f6 ff ff       	jmp    801052f2 <alltraps>

80105cd3 <vector152>:
.globl vector152
vector152:
  pushl $0
80105cd3:	6a 00                	push   $0x0
  pushl $152
80105cd5:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105cda:	e9 13 f6 ff ff       	jmp    801052f2 <alltraps>

80105cdf <vector153>:
.globl vector153
vector153:
  pushl $0
80105cdf:	6a 00                	push   $0x0
  pushl $153
80105ce1:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105ce6:	e9 07 f6 ff ff       	jmp    801052f2 <alltraps>

80105ceb <vector154>:
.globl vector154
vector154:
  pushl $0
80105ceb:	6a 00                	push   $0x0
  pushl $154
80105ced:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105cf2:	e9 fb f5 ff ff       	jmp    801052f2 <alltraps>

80105cf7 <vector155>:
.globl vector155
vector155:
  pushl $0
80105cf7:	6a 00                	push   $0x0
  pushl $155
80105cf9:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105cfe:	e9 ef f5 ff ff       	jmp    801052f2 <alltraps>

80105d03 <vector156>:
.globl vector156
vector156:
  pushl $0
80105d03:	6a 00                	push   $0x0
  pushl $156
80105d05:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105d0a:	e9 e3 f5 ff ff       	jmp    801052f2 <alltraps>

80105d0f <vector157>:
.globl vector157
vector157:
  pushl $0
80105d0f:	6a 00                	push   $0x0
  pushl $157
80105d11:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105d16:	e9 d7 f5 ff ff       	jmp    801052f2 <alltraps>

80105d1b <vector158>:
.globl vector158
vector158:
  pushl $0
80105d1b:	6a 00                	push   $0x0
  pushl $158
80105d1d:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105d22:	e9 cb f5 ff ff       	jmp    801052f2 <alltraps>

80105d27 <vector159>:
.globl vector159
vector159:
  pushl $0
80105d27:	6a 00                	push   $0x0
  pushl $159
80105d29:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105d2e:	e9 bf f5 ff ff       	jmp    801052f2 <alltraps>

80105d33 <vector160>:
.globl vector160
vector160:
  pushl $0
80105d33:	6a 00                	push   $0x0
  pushl $160
80105d35:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105d3a:	e9 b3 f5 ff ff       	jmp    801052f2 <alltraps>

80105d3f <vector161>:
.globl vector161
vector161:
  pushl $0
80105d3f:	6a 00                	push   $0x0
  pushl $161
80105d41:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105d46:	e9 a7 f5 ff ff       	jmp    801052f2 <alltraps>

80105d4b <vector162>:
.globl vector162
vector162:
  pushl $0
80105d4b:	6a 00                	push   $0x0
  pushl $162
80105d4d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105d52:	e9 9b f5 ff ff       	jmp    801052f2 <alltraps>

80105d57 <vector163>:
.globl vector163
vector163:
  pushl $0
80105d57:	6a 00                	push   $0x0
  pushl $163
80105d59:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105d5e:	e9 8f f5 ff ff       	jmp    801052f2 <alltraps>

80105d63 <vector164>:
.globl vector164
vector164:
  pushl $0
80105d63:	6a 00                	push   $0x0
  pushl $164
80105d65:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105d6a:	e9 83 f5 ff ff       	jmp    801052f2 <alltraps>

80105d6f <vector165>:
.globl vector165
vector165:
  pushl $0
80105d6f:	6a 00                	push   $0x0
  pushl $165
80105d71:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105d76:	e9 77 f5 ff ff       	jmp    801052f2 <alltraps>

80105d7b <vector166>:
.globl vector166
vector166:
  pushl $0
80105d7b:	6a 00                	push   $0x0
  pushl $166
80105d7d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105d82:	e9 6b f5 ff ff       	jmp    801052f2 <alltraps>

80105d87 <vector167>:
.globl vector167
vector167:
  pushl $0
80105d87:	6a 00                	push   $0x0
  pushl $167
80105d89:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105d8e:	e9 5f f5 ff ff       	jmp    801052f2 <alltraps>

80105d93 <vector168>:
.globl vector168
vector168:
  pushl $0
80105d93:	6a 00                	push   $0x0
  pushl $168
80105d95:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105d9a:	e9 53 f5 ff ff       	jmp    801052f2 <alltraps>

80105d9f <vector169>:
.globl vector169
vector169:
  pushl $0
80105d9f:	6a 00                	push   $0x0
  pushl $169
80105da1:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105da6:	e9 47 f5 ff ff       	jmp    801052f2 <alltraps>

80105dab <vector170>:
.globl vector170
vector170:
  pushl $0
80105dab:	6a 00                	push   $0x0
  pushl $170
80105dad:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105db2:	e9 3b f5 ff ff       	jmp    801052f2 <alltraps>

80105db7 <vector171>:
.globl vector171
vector171:
  pushl $0
80105db7:	6a 00                	push   $0x0
  pushl $171
80105db9:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105dbe:	e9 2f f5 ff ff       	jmp    801052f2 <alltraps>

80105dc3 <vector172>:
.globl vector172
vector172:
  pushl $0
80105dc3:	6a 00                	push   $0x0
  pushl $172
80105dc5:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105dca:	e9 23 f5 ff ff       	jmp    801052f2 <alltraps>

80105dcf <vector173>:
.globl vector173
vector173:
  pushl $0
80105dcf:	6a 00                	push   $0x0
  pushl $173
80105dd1:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105dd6:	e9 17 f5 ff ff       	jmp    801052f2 <alltraps>

80105ddb <vector174>:
.globl vector174
vector174:
  pushl $0
80105ddb:	6a 00                	push   $0x0
  pushl $174
80105ddd:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105de2:	e9 0b f5 ff ff       	jmp    801052f2 <alltraps>

80105de7 <vector175>:
.globl vector175
vector175:
  pushl $0
80105de7:	6a 00                	push   $0x0
  pushl $175
80105de9:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105dee:	e9 ff f4 ff ff       	jmp    801052f2 <alltraps>

80105df3 <vector176>:
.globl vector176
vector176:
  pushl $0
80105df3:	6a 00                	push   $0x0
  pushl $176
80105df5:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105dfa:	e9 f3 f4 ff ff       	jmp    801052f2 <alltraps>

80105dff <vector177>:
.globl vector177
vector177:
  pushl $0
80105dff:	6a 00                	push   $0x0
  pushl $177
80105e01:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105e06:	e9 e7 f4 ff ff       	jmp    801052f2 <alltraps>

80105e0b <vector178>:
.globl vector178
vector178:
  pushl $0
80105e0b:	6a 00                	push   $0x0
  pushl $178
80105e0d:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105e12:	e9 db f4 ff ff       	jmp    801052f2 <alltraps>

80105e17 <vector179>:
.globl vector179
vector179:
  pushl $0
80105e17:	6a 00                	push   $0x0
  pushl $179
80105e19:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105e1e:	e9 cf f4 ff ff       	jmp    801052f2 <alltraps>

80105e23 <vector180>:
.globl vector180
vector180:
  pushl $0
80105e23:	6a 00                	push   $0x0
  pushl $180
80105e25:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105e2a:	e9 c3 f4 ff ff       	jmp    801052f2 <alltraps>

80105e2f <vector181>:
.globl vector181
vector181:
  pushl $0
80105e2f:	6a 00                	push   $0x0
  pushl $181
80105e31:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105e36:	e9 b7 f4 ff ff       	jmp    801052f2 <alltraps>

80105e3b <vector182>:
.globl vector182
vector182:
  pushl $0
80105e3b:	6a 00                	push   $0x0
  pushl $182
80105e3d:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105e42:	e9 ab f4 ff ff       	jmp    801052f2 <alltraps>

80105e47 <vector183>:
.globl vector183
vector183:
  pushl $0
80105e47:	6a 00                	push   $0x0
  pushl $183
80105e49:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105e4e:	e9 9f f4 ff ff       	jmp    801052f2 <alltraps>

80105e53 <vector184>:
.globl vector184
vector184:
  pushl $0
80105e53:	6a 00                	push   $0x0
  pushl $184
80105e55:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105e5a:	e9 93 f4 ff ff       	jmp    801052f2 <alltraps>

80105e5f <vector185>:
.globl vector185
vector185:
  pushl $0
80105e5f:	6a 00                	push   $0x0
  pushl $185
80105e61:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105e66:	e9 87 f4 ff ff       	jmp    801052f2 <alltraps>

80105e6b <vector186>:
.globl vector186
vector186:
  pushl $0
80105e6b:	6a 00                	push   $0x0
  pushl $186
80105e6d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105e72:	e9 7b f4 ff ff       	jmp    801052f2 <alltraps>

80105e77 <vector187>:
.globl vector187
vector187:
  pushl $0
80105e77:	6a 00                	push   $0x0
  pushl $187
80105e79:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105e7e:	e9 6f f4 ff ff       	jmp    801052f2 <alltraps>

80105e83 <vector188>:
.globl vector188
vector188:
  pushl $0
80105e83:	6a 00                	push   $0x0
  pushl $188
80105e85:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105e8a:	e9 63 f4 ff ff       	jmp    801052f2 <alltraps>

80105e8f <vector189>:
.globl vector189
vector189:
  pushl $0
80105e8f:	6a 00                	push   $0x0
  pushl $189
80105e91:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105e96:	e9 57 f4 ff ff       	jmp    801052f2 <alltraps>

80105e9b <vector190>:
.globl vector190
vector190:
  pushl $0
80105e9b:	6a 00                	push   $0x0
  pushl $190
80105e9d:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105ea2:	e9 4b f4 ff ff       	jmp    801052f2 <alltraps>

80105ea7 <vector191>:
.globl vector191
vector191:
  pushl $0
80105ea7:	6a 00                	push   $0x0
  pushl $191
80105ea9:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105eae:	e9 3f f4 ff ff       	jmp    801052f2 <alltraps>

80105eb3 <vector192>:
.globl vector192
vector192:
  pushl $0
80105eb3:	6a 00                	push   $0x0
  pushl $192
80105eb5:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105eba:	e9 33 f4 ff ff       	jmp    801052f2 <alltraps>

80105ebf <vector193>:
.globl vector193
vector193:
  pushl $0
80105ebf:	6a 00                	push   $0x0
  pushl $193
80105ec1:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105ec6:	e9 27 f4 ff ff       	jmp    801052f2 <alltraps>

80105ecb <vector194>:
.globl vector194
vector194:
  pushl $0
80105ecb:	6a 00                	push   $0x0
  pushl $194
80105ecd:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105ed2:	e9 1b f4 ff ff       	jmp    801052f2 <alltraps>

80105ed7 <vector195>:
.globl vector195
vector195:
  pushl $0
80105ed7:	6a 00                	push   $0x0
  pushl $195
80105ed9:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105ede:	e9 0f f4 ff ff       	jmp    801052f2 <alltraps>

80105ee3 <vector196>:
.globl vector196
vector196:
  pushl $0
80105ee3:	6a 00                	push   $0x0
  pushl $196
80105ee5:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105eea:	e9 03 f4 ff ff       	jmp    801052f2 <alltraps>

80105eef <vector197>:
.globl vector197
vector197:
  pushl $0
80105eef:	6a 00                	push   $0x0
  pushl $197
80105ef1:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105ef6:	e9 f7 f3 ff ff       	jmp    801052f2 <alltraps>

80105efb <vector198>:
.globl vector198
vector198:
  pushl $0
80105efb:	6a 00                	push   $0x0
  pushl $198
80105efd:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105f02:	e9 eb f3 ff ff       	jmp    801052f2 <alltraps>

80105f07 <vector199>:
.globl vector199
vector199:
  pushl $0
80105f07:	6a 00                	push   $0x0
  pushl $199
80105f09:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105f0e:	e9 df f3 ff ff       	jmp    801052f2 <alltraps>

80105f13 <vector200>:
.globl vector200
vector200:
  pushl $0
80105f13:	6a 00                	push   $0x0
  pushl $200
80105f15:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105f1a:	e9 d3 f3 ff ff       	jmp    801052f2 <alltraps>

80105f1f <vector201>:
.globl vector201
vector201:
  pushl $0
80105f1f:	6a 00                	push   $0x0
  pushl $201
80105f21:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105f26:	e9 c7 f3 ff ff       	jmp    801052f2 <alltraps>

80105f2b <vector202>:
.globl vector202
vector202:
  pushl $0
80105f2b:	6a 00                	push   $0x0
  pushl $202
80105f2d:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105f32:	e9 bb f3 ff ff       	jmp    801052f2 <alltraps>

80105f37 <vector203>:
.globl vector203
vector203:
  pushl $0
80105f37:	6a 00                	push   $0x0
  pushl $203
80105f39:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105f3e:	e9 af f3 ff ff       	jmp    801052f2 <alltraps>

80105f43 <vector204>:
.globl vector204
vector204:
  pushl $0
80105f43:	6a 00                	push   $0x0
  pushl $204
80105f45:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105f4a:	e9 a3 f3 ff ff       	jmp    801052f2 <alltraps>

80105f4f <vector205>:
.globl vector205
vector205:
  pushl $0
80105f4f:	6a 00                	push   $0x0
  pushl $205
80105f51:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105f56:	e9 97 f3 ff ff       	jmp    801052f2 <alltraps>

80105f5b <vector206>:
.globl vector206
vector206:
  pushl $0
80105f5b:	6a 00                	push   $0x0
  pushl $206
80105f5d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105f62:	e9 8b f3 ff ff       	jmp    801052f2 <alltraps>

80105f67 <vector207>:
.globl vector207
vector207:
  pushl $0
80105f67:	6a 00                	push   $0x0
  pushl $207
80105f69:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105f6e:	e9 7f f3 ff ff       	jmp    801052f2 <alltraps>

80105f73 <vector208>:
.globl vector208
vector208:
  pushl $0
80105f73:	6a 00                	push   $0x0
  pushl $208
80105f75:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105f7a:	e9 73 f3 ff ff       	jmp    801052f2 <alltraps>

80105f7f <vector209>:
.globl vector209
vector209:
  pushl $0
80105f7f:	6a 00                	push   $0x0
  pushl $209
80105f81:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105f86:	e9 67 f3 ff ff       	jmp    801052f2 <alltraps>

80105f8b <vector210>:
.globl vector210
vector210:
  pushl $0
80105f8b:	6a 00                	push   $0x0
  pushl $210
80105f8d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105f92:	e9 5b f3 ff ff       	jmp    801052f2 <alltraps>

80105f97 <vector211>:
.globl vector211
vector211:
  pushl $0
80105f97:	6a 00                	push   $0x0
  pushl $211
80105f99:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105f9e:	e9 4f f3 ff ff       	jmp    801052f2 <alltraps>

80105fa3 <vector212>:
.globl vector212
vector212:
  pushl $0
80105fa3:	6a 00                	push   $0x0
  pushl $212
80105fa5:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105faa:	e9 43 f3 ff ff       	jmp    801052f2 <alltraps>

80105faf <vector213>:
.globl vector213
vector213:
  pushl $0
80105faf:	6a 00                	push   $0x0
  pushl $213
80105fb1:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105fb6:	e9 37 f3 ff ff       	jmp    801052f2 <alltraps>

80105fbb <vector214>:
.globl vector214
vector214:
  pushl $0
80105fbb:	6a 00                	push   $0x0
  pushl $214
80105fbd:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105fc2:	e9 2b f3 ff ff       	jmp    801052f2 <alltraps>

80105fc7 <vector215>:
.globl vector215
vector215:
  pushl $0
80105fc7:	6a 00                	push   $0x0
  pushl $215
80105fc9:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105fce:	e9 1f f3 ff ff       	jmp    801052f2 <alltraps>

80105fd3 <vector216>:
.globl vector216
vector216:
  pushl $0
80105fd3:	6a 00                	push   $0x0
  pushl $216
80105fd5:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105fda:	e9 13 f3 ff ff       	jmp    801052f2 <alltraps>

80105fdf <vector217>:
.globl vector217
vector217:
  pushl $0
80105fdf:	6a 00                	push   $0x0
  pushl $217
80105fe1:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105fe6:	e9 07 f3 ff ff       	jmp    801052f2 <alltraps>

80105feb <vector218>:
.globl vector218
vector218:
  pushl $0
80105feb:	6a 00                	push   $0x0
  pushl $218
80105fed:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105ff2:	e9 fb f2 ff ff       	jmp    801052f2 <alltraps>

80105ff7 <vector219>:
.globl vector219
vector219:
  pushl $0
80105ff7:	6a 00                	push   $0x0
  pushl $219
80105ff9:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105ffe:	e9 ef f2 ff ff       	jmp    801052f2 <alltraps>

80106003 <vector220>:
.globl vector220
vector220:
  pushl $0
80106003:	6a 00                	push   $0x0
  pushl $220
80106005:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010600a:	e9 e3 f2 ff ff       	jmp    801052f2 <alltraps>

8010600f <vector221>:
.globl vector221
vector221:
  pushl $0
8010600f:	6a 00                	push   $0x0
  pushl $221
80106011:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106016:	e9 d7 f2 ff ff       	jmp    801052f2 <alltraps>

8010601b <vector222>:
.globl vector222
vector222:
  pushl $0
8010601b:	6a 00                	push   $0x0
  pushl $222
8010601d:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106022:	e9 cb f2 ff ff       	jmp    801052f2 <alltraps>

80106027 <vector223>:
.globl vector223
vector223:
  pushl $0
80106027:	6a 00                	push   $0x0
  pushl $223
80106029:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010602e:	e9 bf f2 ff ff       	jmp    801052f2 <alltraps>

80106033 <vector224>:
.globl vector224
vector224:
  pushl $0
80106033:	6a 00                	push   $0x0
  pushl $224
80106035:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010603a:	e9 b3 f2 ff ff       	jmp    801052f2 <alltraps>

8010603f <vector225>:
.globl vector225
vector225:
  pushl $0
8010603f:	6a 00                	push   $0x0
  pushl $225
80106041:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106046:	e9 a7 f2 ff ff       	jmp    801052f2 <alltraps>

8010604b <vector226>:
.globl vector226
vector226:
  pushl $0
8010604b:	6a 00                	push   $0x0
  pushl $226
8010604d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106052:	e9 9b f2 ff ff       	jmp    801052f2 <alltraps>

80106057 <vector227>:
.globl vector227
vector227:
  pushl $0
80106057:	6a 00                	push   $0x0
  pushl $227
80106059:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010605e:	e9 8f f2 ff ff       	jmp    801052f2 <alltraps>

80106063 <vector228>:
.globl vector228
vector228:
  pushl $0
80106063:	6a 00                	push   $0x0
  pushl $228
80106065:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010606a:	e9 83 f2 ff ff       	jmp    801052f2 <alltraps>

8010606f <vector229>:
.globl vector229
vector229:
  pushl $0
8010606f:	6a 00                	push   $0x0
  pushl $229
80106071:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106076:	e9 77 f2 ff ff       	jmp    801052f2 <alltraps>

8010607b <vector230>:
.globl vector230
vector230:
  pushl $0
8010607b:	6a 00                	push   $0x0
  pushl $230
8010607d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106082:	e9 6b f2 ff ff       	jmp    801052f2 <alltraps>

80106087 <vector231>:
.globl vector231
vector231:
  pushl $0
80106087:	6a 00                	push   $0x0
  pushl $231
80106089:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010608e:	e9 5f f2 ff ff       	jmp    801052f2 <alltraps>

80106093 <vector232>:
.globl vector232
vector232:
  pushl $0
80106093:	6a 00                	push   $0x0
  pushl $232
80106095:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010609a:	e9 53 f2 ff ff       	jmp    801052f2 <alltraps>

8010609f <vector233>:
.globl vector233
vector233:
  pushl $0
8010609f:	6a 00                	push   $0x0
  pushl $233
801060a1:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801060a6:	e9 47 f2 ff ff       	jmp    801052f2 <alltraps>

801060ab <vector234>:
.globl vector234
vector234:
  pushl $0
801060ab:	6a 00                	push   $0x0
  pushl $234
801060ad:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801060b2:	e9 3b f2 ff ff       	jmp    801052f2 <alltraps>

801060b7 <vector235>:
.globl vector235
vector235:
  pushl $0
801060b7:	6a 00                	push   $0x0
  pushl $235
801060b9:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801060be:	e9 2f f2 ff ff       	jmp    801052f2 <alltraps>

801060c3 <vector236>:
.globl vector236
vector236:
  pushl $0
801060c3:	6a 00                	push   $0x0
  pushl $236
801060c5:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801060ca:	e9 23 f2 ff ff       	jmp    801052f2 <alltraps>

801060cf <vector237>:
.globl vector237
vector237:
  pushl $0
801060cf:	6a 00                	push   $0x0
  pushl $237
801060d1:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801060d6:	e9 17 f2 ff ff       	jmp    801052f2 <alltraps>

801060db <vector238>:
.globl vector238
vector238:
  pushl $0
801060db:	6a 00                	push   $0x0
  pushl $238
801060dd:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801060e2:	e9 0b f2 ff ff       	jmp    801052f2 <alltraps>

801060e7 <vector239>:
.globl vector239
vector239:
  pushl $0
801060e7:	6a 00                	push   $0x0
  pushl $239
801060e9:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801060ee:	e9 ff f1 ff ff       	jmp    801052f2 <alltraps>

801060f3 <vector240>:
.globl vector240
vector240:
  pushl $0
801060f3:	6a 00                	push   $0x0
  pushl $240
801060f5:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801060fa:	e9 f3 f1 ff ff       	jmp    801052f2 <alltraps>

801060ff <vector241>:
.globl vector241
vector241:
  pushl $0
801060ff:	6a 00                	push   $0x0
  pushl $241
80106101:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106106:	e9 e7 f1 ff ff       	jmp    801052f2 <alltraps>

8010610b <vector242>:
.globl vector242
vector242:
  pushl $0
8010610b:	6a 00                	push   $0x0
  pushl $242
8010610d:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106112:	e9 db f1 ff ff       	jmp    801052f2 <alltraps>

80106117 <vector243>:
.globl vector243
vector243:
  pushl $0
80106117:	6a 00                	push   $0x0
  pushl $243
80106119:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010611e:	e9 cf f1 ff ff       	jmp    801052f2 <alltraps>

80106123 <vector244>:
.globl vector244
vector244:
  pushl $0
80106123:	6a 00                	push   $0x0
  pushl $244
80106125:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010612a:	e9 c3 f1 ff ff       	jmp    801052f2 <alltraps>

8010612f <vector245>:
.globl vector245
vector245:
  pushl $0
8010612f:	6a 00                	push   $0x0
  pushl $245
80106131:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106136:	e9 b7 f1 ff ff       	jmp    801052f2 <alltraps>

8010613b <vector246>:
.globl vector246
vector246:
  pushl $0
8010613b:	6a 00                	push   $0x0
  pushl $246
8010613d:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106142:	e9 ab f1 ff ff       	jmp    801052f2 <alltraps>

80106147 <vector247>:
.globl vector247
vector247:
  pushl $0
80106147:	6a 00                	push   $0x0
  pushl $247
80106149:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010614e:	e9 9f f1 ff ff       	jmp    801052f2 <alltraps>

80106153 <vector248>:
.globl vector248
vector248:
  pushl $0
80106153:	6a 00                	push   $0x0
  pushl $248
80106155:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010615a:	e9 93 f1 ff ff       	jmp    801052f2 <alltraps>

8010615f <vector249>:
.globl vector249
vector249:
  pushl $0
8010615f:	6a 00                	push   $0x0
  pushl $249
80106161:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106166:	e9 87 f1 ff ff       	jmp    801052f2 <alltraps>

8010616b <vector250>:
.globl vector250
vector250:
  pushl $0
8010616b:	6a 00                	push   $0x0
  pushl $250
8010616d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106172:	e9 7b f1 ff ff       	jmp    801052f2 <alltraps>

80106177 <vector251>:
.globl vector251
vector251:
  pushl $0
80106177:	6a 00                	push   $0x0
  pushl $251
80106179:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010617e:	e9 6f f1 ff ff       	jmp    801052f2 <alltraps>

80106183 <vector252>:
.globl vector252
vector252:
  pushl $0
80106183:	6a 00                	push   $0x0
  pushl $252
80106185:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010618a:	e9 63 f1 ff ff       	jmp    801052f2 <alltraps>

8010618f <vector253>:
.globl vector253
vector253:
  pushl $0
8010618f:	6a 00                	push   $0x0
  pushl $253
80106191:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106196:	e9 57 f1 ff ff       	jmp    801052f2 <alltraps>

8010619b <vector254>:
.globl vector254
vector254:
  pushl $0
8010619b:	6a 00                	push   $0x0
  pushl $254
8010619d:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801061a2:	e9 4b f1 ff ff       	jmp    801052f2 <alltraps>

801061a7 <vector255>:
.globl vector255
vector255:
  pushl $0
801061a7:	6a 00                	push   $0x0
  pushl $255
801061a9:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801061ae:	e9 3f f1 ff ff       	jmp    801052f2 <alltraps>

801061b3 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801061b3:	55                   	push   %ebp
801061b4:	89 e5                	mov    %esp,%ebp
801061b6:	57                   	push   %edi
801061b7:	56                   	push   %esi
801061b8:	53                   	push   %ebx
801061b9:	83 ec 0c             	sub    $0xc,%esp
801061bc:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801061be:	c1 ea 16             	shr    $0x16,%edx
801061c1:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
801061c4:	8b 37                	mov    (%edi),%esi
801061c6:	f7 c6 01 00 00 00    	test   $0x1,%esi
801061cc:	74 35                	je     80106203 <walkpgdir+0x50>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
801061ce:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    if (a > KERNBASE)
801061d4:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
801061da:	77 1a                	ja     801061f6 <walkpgdir+0x43>
    return (char*)a + KERNBASE;
801061dc:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
801061e2:	c1 eb 0c             	shr    $0xc,%ebx
801061e5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
801061eb:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
801061ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061f1:	5b                   	pop    %ebx
801061f2:	5e                   	pop    %esi
801061f3:	5f                   	pop    %edi
801061f4:	5d                   	pop    %ebp
801061f5:	c3                   	ret    
        panic("P2V on address > KERNBASE");
801061f6:	83 ec 0c             	sub    $0xc,%esp
801061f9:	68 18 76 10 80       	push   $0x80107618
801061fe:	e8 59 a1 ff ff       	call   8010035c <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106203:	85 c9                	test   %ecx,%ecx
80106205:	74 33                	je     8010623a <walkpgdir+0x87>
80106207:	e8 fe c0 ff ff       	call   8010230a <kalloc>
8010620c:	89 c6                	mov    %eax,%esi
8010620e:	85 c0                	test   %eax,%eax
80106210:	74 28                	je     8010623a <walkpgdir+0x87>
    memset(pgtab, 0, PGSIZE);
80106212:	83 ec 04             	sub    $0x4,%esp
80106215:	68 00 10 00 00       	push   $0x1000
8010621a:	6a 00                	push   $0x0
8010621c:	50                   	push   %eax
8010621d:	e8 b1 de ff ff       	call   801040d3 <memset>
    if (a < (void*) KERNBASE)
80106222:	83 c4 10             	add    $0x10,%esp
80106225:	81 fe ff ff ff 7f    	cmp    $0x7fffffff,%esi
8010622b:	76 14                	jbe    80106241 <walkpgdir+0x8e>
    return (uint)a - KERNBASE;
8010622d:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106233:	83 c8 07             	or     $0x7,%eax
80106236:	89 07                	mov    %eax,(%edi)
80106238:	eb a8                	jmp    801061e2 <walkpgdir+0x2f>
      return 0;
8010623a:	b8 00 00 00 00       	mov    $0x0,%eax
8010623f:	eb ad                	jmp    801061ee <walkpgdir+0x3b>
        panic("V2P on address < KERNBASE "
80106241:	83 ec 0c             	sub    $0xc,%esp
80106244:	68 f4 72 10 80       	push   $0x801072f4
80106249:	e8 0e a1 ff ff       	call   8010035c <panic>

8010624e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010624e:	55                   	push   %ebp
8010624f:	89 e5                	mov    %esp,%ebp
80106251:	57                   	push   %edi
80106252:	56                   	push   %esi
80106253:	53                   	push   %ebx
80106254:	83 ec 1c             	sub    $0x1c,%esp
80106257:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010625a:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010625d:	89 d3                	mov    %edx,%ebx
8010625f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106265:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80106269:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010626f:	b9 01 00 00 00       	mov    $0x1,%ecx
80106274:	89 da                	mov    %ebx,%edx
80106276:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106279:	e8 35 ff ff ff       	call   801061b3 <walkpgdir>
8010627e:	85 c0                	test   %eax,%eax
80106280:	74 2e                	je     801062b0 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80106282:	f6 00 01             	testb  $0x1,(%eax)
80106285:	75 1c                	jne    801062a3 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80106287:	89 f2                	mov    %esi,%edx
80106289:	0b 55 0c             	or     0xc(%ebp),%edx
8010628c:	83 ca 01             	or     $0x1,%edx
8010628f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80106291:	39 fb                	cmp    %edi,%ebx
80106293:	74 28                	je     801062bd <mappages+0x6f>
      break;
    a += PGSIZE;
80106295:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
8010629b:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801062a1:	eb cc                	jmp    8010626f <mappages+0x21>
      panic("remap");
801062a3:	83 ec 0c             	sub    $0xc,%esp
801062a6:	68 00 7a 10 80       	push   $0x80107a00
801062ab:	e8 ac a0 ff ff       	call   8010035c <panic>
      return -1;
801062b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801062b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062b8:	5b                   	pop    %ebx
801062b9:	5e                   	pop    %esi
801062ba:	5f                   	pop    %edi
801062bb:	5d                   	pop    %ebp
801062bc:	c3                   	ret    
  return 0;
801062bd:	b8 00 00 00 00       	mov    $0x0,%eax
801062c2:	eb f1                	jmp    801062b5 <mappages+0x67>

801062c4 <seginit>:
{
801062c4:	f3 0f 1e fb          	endbr32 
801062c8:	55                   	push   %ebp
801062c9:	89 e5                	mov    %esp,%ebp
801062cb:	53                   	push   %ebx
801062cc:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
801062cf:	e8 af d2 ff ff       	call   80103583 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801062d4:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801062da:	66 c7 80 78 36 11 80 	movw   $0xffff,-0x7feec988(%eax)
801062e1:	ff ff 
801062e3:	66 c7 80 7a 36 11 80 	movw   $0x0,-0x7feec986(%eax)
801062ea:	00 00 
801062ec:	c6 80 7c 36 11 80 00 	movb   $0x0,-0x7feec984(%eax)
801062f3:	0f b6 88 7d 36 11 80 	movzbl -0x7feec983(%eax),%ecx
801062fa:	83 e1 f0             	and    $0xfffffff0,%ecx
801062fd:	83 c9 1a             	or     $0x1a,%ecx
80106300:	83 e1 9f             	and    $0xffffff9f,%ecx
80106303:	83 c9 80             	or     $0xffffff80,%ecx
80106306:	88 88 7d 36 11 80    	mov    %cl,-0x7feec983(%eax)
8010630c:	0f b6 88 7e 36 11 80 	movzbl -0x7feec982(%eax),%ecx
80106313:	83 c9 0f             	or     $0xf,%ecx
80106316:	83 e1 cf             	and    $0xffffffcf,%ecx
80106319:	83 c9 c0             	or     $0xffffffc0,%ecx
8010631c:	88 88 7e 36 11 80    	mov    %cl,-0x7feec982(%eax)
80106322:	c6 80 7f 36 11 80 00 	movb   $0x0,-0x7feec981(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106329:	66 c7 80 80 36 11 80 	movw   $0xffff,-0x7feec980(%eax)
80106330:	ff ff 
80106332:	66 c7 80 82 36 11 80 	movw   $0x0,-0x7feec97e(%eax)
80106339:	00 00 
8010633b:	c6 80 84 36 11 80 00 	movb   $0x0,-0x7feec97c(%eax)
80106342:	0f b6 88 85 36 11 80 	movzbl -0x7feec97b(%eax),%ecx
80106349:	83 e1 f0             	and    $0xfffffff0,%ecx
8010634c:	83 c9 12             	or     $0x12,%ecx
8010634f:	83 e1 9f             	and    $0xffffff9f,%ecx
80106352:	83 c9 80             	or     $0xffffff80,%ecx
80106355:	88 88 85 36 11 80    	mov    %cl,-0x7feec97b(%eax)
8010635b:	0f b6 88 86 36 11 80 	movzbl -0x7feec97a(%eax),%ecx
80106362:	83 c9 0f             	or     $0xf,%ecx
80106365:	83 e1 cf             	and    $0xffffffcf,%ecx
80106368:	83 c9 c0             	or     $0xffffffc0,%ecx
8010636b:	88 88 86 36 11 80    	mov    %cl,-0x7feec97a(%eax)
80106371:	c6 80 87 36 11 80 00 	movb   $0x0,-0x7feec979(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106378:	66 c7 80 88 36 11 80 	movw   $0xffff,-0x7feec978(%eax)
8010637f:	ff ff 
80106381:	66 c7 80 8a 36 11 80 	movw   $0x0,-0x7feec976(%eax)
80106388:	00 00 
8010638a:	c6 80 8c 36 11 80 00 	movb   $0x0,-0x7feec974(%eax)
80106391:	c6 80 8d 36 11 80 fa 	movb   $0xfa,-0x7feec973(%eax)
80106398:	0f b6 88 8e 36 11 80 	movzbl -0x7feec972(%eax),%ecx
8010639f:	83 c9 0f             	or     $0xf,%ecx
801063a2:	83 e1 cf             	and    $0xffffffcf,%ecx
801063a5:	83 c9 c0             	or     $0xffffffc0,%ecx
801063a8:	88 88 8e 36 11 80    	mov    %cl,-0x7feec972(%eax)
801063ae:	c6 80 8f 36 11 80 00 	movb   $0x0,-0x7feec971(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801063b5:	66 c7 80 90 36 11 80 	movw   $0xffff,-0x7feec970(%eax)
801063bc:	ff ff 
801063be:	66 c7 80 92 36 11 80 	movw   $0x0,-0x7feec96e(%eax)
801063c5:	00 00 
801063c7:	c6 80 94 36 11 80 00 	movb   $0x0,-0x7feec96c(%eax)
801063ce:	c6 80 95 36 11 80 f2 	movb   $0xf2,-0x7feec96b(%eax)
801063d5:	0f b6 88 96 36 11 80 	movzbl -0x7feec96a(%eax),%ecx
801063dc:	83 c9 0f             	or     $0xf,%ecx
801063df:	83 e1 cf             	and    $0xffffffcf,%ecx
801063e2:	83 c9 c0             	or     $0xffffffc0,%ecx
801063e5:	88 88 96 36 11 80    	mov    %cl,-0x7feec96a(%eax)
801063eb:	c6 80 97 36 11 80 00 	movb   $0x0,-0x7feec969(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801063f2:	05 70 36 11 80       	add    $0x80113670,%eax
  pd[0] = size-1;
801063f7:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
801063fd:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106401:	c1 e8 10             	shr    $0x10,%eax
80106404:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106408:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010640b:	0f 01 10             	lgdtl  (%eax)
}
8010640e:	83 c4 14             	add    $0x14,%esp
80106411:	5b                   	pop    %ebx
80106412:	5d                   	pop    %ebp
80106413:	c3                   	ret    

80106414 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80106414:	f3 0f 1e fb          	endbr32 
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106418:	a1 24 66 11 80       	mov    0x80116624,%eax
    if (a < (void*) KERNBASE)
8010641d:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80106422:	76 09                	jbe    8010642d <switchkvm+0x19>
    return (uint)a - KERNBASE;
80106424:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106429:	0f 22 d8             	mov    %eax,%cr3
8010642c:	c3                   	ret    
{
8010642d:	55                   	push   %ebp
8010642e:	89 e5                	mov    %esp,%ebp
80106430:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
80106433:	68 f4 72 10 80       	push   $0x801072f4
80106438:	e8 1f 9f ff ff       	call   8010035c <panic>

8010643d <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010643d:	f3 0f 1e fb          	endbr32 
80106441:	55                   	push   %ebp
80106442:	89 e5                	mov    %esp,%ebp
80106444:	57                   	push   %edi
80106445:	56                   	push   %esi
80106446:	53                   	push   %ebx
80106447:	83 ec 1c             	sub    $0x1c,%esp
8010644a:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
8010644d:	85 f6                	test   %esi,%esi
8010644f:	0f 84 e4 00 00 00    	je     80106539 <switchuvm+0xfc>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106455:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80106459:	0f 84 e7 00 00 00    	je     80106546 <switchuvm+0x109>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
8010645f:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80106463:	0f 84 ea 00 00 00    	je     80106553 <switchuvm+0x116>
    panic("switchuvm: no pgdir");

  pushcli();
80106469:	e8 c8 da ff ff       	call   80103f36 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010646e:	e8 b0 d0 ff ff       	call   80103523 <mycpu>
80106473:	89 c3                	mov    %eax,%ebx
80106475:	e8 a9 d0 ff ff       	call   80103523 <mycpu>
8010647a:	8d 78 08             	lea    0x8(%eax),%edi
8010647d:	e8 a1 d0 ff ff       	call   80103523 <mycpu>
80106482:	83 c0 08             	add    $0x8,%eax
80106485:	c1 e8 10             	shr    $0x10,%eax
80106488:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010648b:	e8 93 d0 ff ff       	call   80103523 <mycpu>
80106490:	83 c0 08             	add    $0x8,%eax
80106493:	c1 e8 18             	shr    $0x18,%eax
80106496:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010649d:	67 00 
8010649f:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801064a6:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
801064aa:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801064b0:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
801064b7:	83 e2 f0             	and    $0xfffffff0,%edx
801064ba:	83 ca 19             	or     $0x19,%edx
801064bd:	83 e2 9f             	and    $0xffffff9f,%edx
801064c0:	83 ca 80             	or     $0xffffff80,%edx
801064c3:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801064c9:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
801064d0:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801064d6:	e8 48 d0 ff ff       	call   80103523 <mycpu>
801064db:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801064e2:	83 e2 ef             	and    $0xffffffef,%edx
801064e5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801064eb:	e8 33 d0 ff ff       	call   80103523 <mycpu>
801064f0:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801064f6:	8b 5e 08             	mov    0x8(%esi),%ebx
801064f9:	e8 25 d0 ff ff       	call   80103523 <mycpu>
801064fe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106504:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106507:	e8 17 d0 ff ff       	call   80103523 <mycpu>
8010650c:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106512:	b8 28 00 00 00       	mov    $0x28,%eax
80106517:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010651a:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
8010651d:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80106522:	76 3c                	jbe    80106560 <switchuvm+0x123>
    return (uint)a - KERNBASE;
80106524:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106529:	0f 22 d8             	mov    %eax,%cr3
  popcli();
8010652c:	e8 46 da ff ff       	call   80103f77 <popcli>
}
80106531:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106534:	5b                   	pop    %ebx
80106535:	5e                   	pop    %esi
80106536:	5f                   	pop    %edi
80106537:	5d                   	pop    %ebp
80106538:	c3                   	ret    
    panic("switchuvm: no process");
80106539:	83 ec 0c             	sub    $0xc,%esp
8010653c:	68 06 7a 10 80       	push   $0x80107a06
80106541:	e8 16 9e ff ff       	call   8010035c <panic>
    panic("switchuvm: no kstack");
80106546:	83 ec 0c             	sub    $0xc,%esp
80106549:	68 1c 7a 10 80       	push   $0x80107a1c
8010654e:	e8 09 9e ff ff       	call   8010035c <panic>
    panic("switchuvm: no pgdir");
80106553:	83 ec 0c             	sub    $0xc,%esp
80106556:	68 31 7a 10 80       	push   $0x80107a31
8010655b:	e8 fc 9d ff ff       	call   8010035c <panic>
        panic("V2P on address < KERNBASE "
80106560:	83 ec 0c             	sub    $0xc,%esp
80106563:	68 f4 72 10 80       	push   $0x801072f4
80106568:	e8 ef 9d ff ff       	call   8010035c <panic>

8010656d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010656d:	f3 0f 1e fb          	endbr32 
80106571:	55                   	push   %ebp
80106572:	89 e5                	mov    %esp,%ebp
80106574:	56                   	push   %esi
80106575:	53                   	push   %ebx
80106576:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80106579:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010657f:	77 57                	ja     801065d8 <inituvm+0x6b>
    panic("inituvm: more than a page");
  mem = kalloc();
80106581:	e8 84 bd ff ff       	call   8010230a <kalloc>
80106586:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106588:	83 ec 04             	sub    $0x4,%esp
8010658b:	68 00 10 00 00       	push   $0x1000
80106590:	6a 00                	push   $0x0
80106592:	50                   	push   %eax
80106593:	e8 3b db ff ff       	call   801040d3 <memset>
    if (a < (void*) KERNBASE)
80106598:	83 c4 10             	add    $0x10,%esp
8010659b:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
801065a1:	76 42                	jbe    801065e5 <inituvm+0x78>
    return (uint)a - KERNBASE;
801065a3:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801065a9:	83 ec 08             	sub    $0x8,%esp
801065ac:	6a 06                	push   $0x6
801065ae:	50                   	push   %eax
801065af:	b9 00 10 00 00       	mov    $0x1000,%ecx
801065b4:	ba 00 00 00 00       	mov    $0x0,%edx
801065b9:	8b 45 08             	mov    0x8(%ebp),%eax
801065bc:	e8 8d fc ff ff       	call   8010624e <mappages>
  memmove(mem, init, sz);
801065c1:	83 c4 0c             	add    $0xc,%esp
801065c4:	56                   	push   %esi
801065c5:	ff 75 0c             	pushl  0xc(%ebp)
801065c8:	53                   	push   %ebx
801065c9:	e8 85 db ff ff       	call   80104153 <memmove>
}
801065ce:	83 c4 10             	add    $0x10,%esp
801065d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801065d4:	5b                   	pop    %ebx
801065d5:	5e                   	pop    %esi
801065d6:	5d                   	pop    %ebp
801065d7:	c3                   	ret    
    panic("inituvm: more than a page");
801065d8:	83 ec 0c             	sub    $0xc,%esp
801065db:	68 45 7a 10 80       	push   $0x80107a45
801065e0:	e8 77 9d ff ff       	call   8010035c <panic>
        panic("V2P on address < KERNBASE "
801065e5:	83 ec 0c             	sub    $0xc,%esp
801065e8:	68 f4 72 10 80       	push   $0x801072f4
801065ed:	e8 6a 9d ff ff       	call   8010035c <panic>

801065f2 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801065f2:	f3 0f 1e fb          	endbr32 
801065f6:	55                   	push   %ebp
801065f7:	89 e5                	mov    %esp,%ebp
801065f9:	57                   	push   %edi
801065fa:	56                   	push   %esi
801065fb:	53                   	push   %ebx
801065fc:	83 ec 0c             	sub    $0xc,%esp
801065ff:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106602:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80106605:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
8010660b:	74 43                	je     80106650 <loaduvm+0x5e>
    panic("loaduvm: addr must be page aligned");
8010660d:	83 ec 0c             	sub    $0xc,%esp
80106610:	68 00 7b 10 80       	push   $0x80107b00
80106615:	e8 42 9d ff ff       	call   8010035c <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
8010661a:	83 ec 0c             	sub    $0xc,%esp
8010661d:	68 5f 7a 10 80       	push   $0x80107a5f
80106622:	e8 35 9d ff ff       	call   8010035c <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106627:	89 da                	mov    %ebx,%edx
80106629:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
8010662c:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106631:	77 51                	ja     80106684 <loaduvm+0x92>
    return (char*)a + KERNBASE;
80106633:	05 00 00 00 80       	add    $0x80000000,%eax
80106638:	56                   	push   %esi
80106639:	52                   	push   %edx
8010663a:	50                   	push   %eax
8010663b:	ff 75 10             	pushl  0x10(%ebp)
8010663e:	e8 fb b2 ff ff       	call   8010193e <readi>
80106643:	83 c4 10             	add    $0x10,%esp
80106646:	39 f0                	cmp    %esi,%eax
80106648:	75 54                	jne    8010669e <loaduvm+0xac>
  for(i = 0; i < sz; i += PGSIZE){
8010664a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106650:	39 fb                	cmp    %edi,%ebx
80106652:	73 3d                	jae    80106691 <loaduvm+0x9f>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106654:	89 da                	mov    %ebx,%edx
80106656:	03 55 0c             	add    0xc(%ebp),%edx
80106659:	b9 00 00 00 00       	mov    $0x0,%ecx
8010665e:	8b 45 08             	mov    0x8(%ebp),%eax
80106661:	e8 4d fb ff ff       	call   801061b3 <walkpgdir>
80106666:	85 c0                	test   %eax,%eax
80106668:	74 b0                	je     8010661a <loaduvm+0x28>
    pa = PTE_ADDR(*pte);
8010666a:	8b 00                	mov    (%eax),%eax
8010666c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106671:	89 fe                	mov    %edi,%esi
80106673:	29 de                	sub    %ebx,%esi
80106675:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010667b:	76 aa                	jbe    80106627 <loaduvm+0x35>
      n = PGSIZE;
8010667d:	be 00 10 00 00       	mov    $0x1000,%esi
80106682:	eb a3                	jmp    80106627 <loaduvm+0x35>
        panic("P2V on address > KERNBASE");
80106684:	83 ec 0c             	sub    $0xc,%esp
80106687:	68 18 76 10 80       	push   $0x80107618
8010668c:	e8 cb 9c ff ff       	call   8010035c <panic>
      return -1;
  }
  return 0;
80106691:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106696:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106699:	5b                   	pop    %ebx
8010669a:	5e                   	pop    %esi
8010669b:	5f                   	pop    %edi
8010669c:	5d                   	pop    %ebp
8010669d:	c3                   	ret    
      return -1;
8010669e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a3:	eb f1                	jmp    80106696 <loaduvm+0xa4>

801066a5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801066a5:	f3 0f 1e fb          	endbr32 
801066a9:	55                   	push   %ebp
801066aa:	89 e5                	mov    %esp,%ebp
801066ac:	57                   	push   %edi
801066ad:	56                   	push   %esi
801066ae:	53                   	push   %ebx
801066af:	83 ec 0c             	sub    $0xc,%esp
801066b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801066b5:	39 7d 10             	cmp    %edi,0x10(%ebp)
801066b8:	73 11                	jae    801066cb <deallocuvm+0x26>
    return oldsz;

  a = PGROUNDUP(newsz);
801066ba:	8b 45 10             	mov    0x10(%ebp),%eax
801066bd:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801066c3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801066c9:	eb 19                	jmp    801066e4 <deallocuvm+0x3f>
    return oldsz;
801066cb:	89 f8                	mov    %edi,%eax
801066cd:	eb 78                	jmp    80106747 <deallocuvm+0xa2>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801066cf:	c1 eb 16             	shr    $0x16,%ebx
801066d2:	83 c3 01             	add    $0x1,%ebx
801066d5:	c1 e3 16             	shl    $0x16,%ebx
801066d8:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801066de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801066e4:	39 fb                	cmp    %edi,%ebx
801066e6:	73 5c                	jae    80106744 <deallocuvm+0x9f>
    pte = walkpgdir(pgdir, (char*)a, 0);
801066e8:	b9 00 00 00 00       	mov    $0x0,%ecx
801066ed:	89 da                	mov    %ebx,%edx
801066ef:	8b 45 08             	mov    0x8(%ebp),%eax
801066f2:	e8 bc fa ff ff       	call   801061b3 <walkpgdir>
801066f7:	89 c6                	mov    %eax,%esi
    if(!pte)
801066f9:	85 c0                	test   %eax,%eax
801066fb:	74 d2                	je     801066cf <deallocuvm+0x2a>
    else if((*pte & PTE_P) != 0){
801066fd:	8b 00                	mov    (%eax),%eax
801066ff:	a8 01                	test   $0x1,%al
80106701:	74 db                	je     801066de <deallocuvm+0x39>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106703:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106708:	74 20                	je     8010672a <deallocuvm+0x85>
    if (a > KERNBASE)
8010670a:	3d 00 00 00 80       	cmp    $0x80000000,%eax
8010670f:	77 26                	ja     80106737 <deallocuvm+0x92>
    return (char*)a + KERNBASE;
80106711:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106716:	83 ec 0c             	sub    $0xc,%esp
80106719:	50                   	push   %eax
8010671a:	e8 9e ba ff ff       	call   801021bd <kfree>
      *pte = 0;
8010671f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106725:	83 c4 10             	add    $0x10,%esp
80106728:	eb b4                	jmp    801066de <deallocuvm+0x39>
        panic("kfree");
8010672a:	83 ec 0c             	sub    $0xc,%esp
8010672d:	68 82 73 10 80       	push   $0x80107382
80106732:	e8 25 9c ff ff       	call   8010035c <panic>
        panic("P2V on address > KERNBASE");
80106737:	83 ec 0c             	sub    $0xc,%esp
8010673a:	68 18 76 10 80       	push   $0x80107618
8010673f:	e8 18 9c ff ff       	call   8010035c <panic>
    }
  }
  return newsz;
80106744:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106747:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010674a:	5b                   	pop    %ebx
8010674b:	5e                   	pop    %esi
8010674c:	5f                   	pop    %edi
8010674d:	5d                   	pop    %ebp
8010674e:	c3                   	ret    

8010674f <allocuvm>:
{
8010674f:	f3 0f 1e fb          	endbr32 
80106753:	55                   	push   %ebp
80106754:	89 e5                	mov    %esp,%ebp
80106756:	57                   	push   %edi
80106757:	56                   	push   %esi
80106758:	53                   	push   %ebx
80106759:	83 ec 1c             	sub    $0x1c,%esp
8010675c:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
8010675f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106762:	85 ff                	test   %edi,%edi
80106764:	0f 88 db 00 00 00    	js     80106845 <allocuvm+0xf6>
  if(newsz < oldsz)
8010676a:	3b 7d 0c             	cmp    0xc(%ebp),%edi
8010676d:	72 11                	jb     80106780 <allocuvm+0x31>
  a = PGROUNDUP(oldsz);
8010676f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106772:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106778:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
8010677e:	eb 49                	jmp    801067c9 <allocuvm+0x7a>
    return oldsz;
80106780:	8b 45 0c             	mov    0xc(%ebp),%eax
80106783:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106786:	e9 c1 00 00 00       	jmp    8010684c <allocuvm+0xfd>
      cprintf("allocuvm out of memory\n");
8010678b:	83 ec 0c             	sub    $0xc,%esp
8010678e:	68 7d 7a 10 80       	push   $0x80107a7d
80106793:	e8 91 9e ff ff       	call   80100629 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106798:	83 c4 0c             	add    $0xc,%esp
8010679b:	ff 75 0c             	pushl  0xc(%ebp)
8010679e:	57                   	push   %edi
8010679f:	ff 75 08             	pushl  0x8(%ebp)
801067a2:	e8 fe fe ff ff       	call   801066a5 <deallocuvm>
      return 0;
801067a7:	83 c4 10             	add    $0x10,%esp
801067aa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801067b1:	e9 96 00 00 00       	jmp    8010684c <allocuvm+0xfd>
        panic("V2P on address < KERNBASE "
801067b6:	83 ec 0c             	sub    $0xc,%esp
801067b9:	68 f4 72 10 80       	push   $0x801072f4
801067be:	e8 99 9b ff ff       	call   8010035c <panic>
  for(; a < newsz; a += PGSIZE){
801067c3:	81 c6 00 10 00 00    	add    $0x1000,%esi
801067c9:	39 fe                	cmp    %edi,%esi
801067cb:	73 7f                	jae    8010684c <allocuvm+0xfd>
    mem = kalloc();
801067cd:	e8 38 bb ff ff       	call   8010230a <kalloc>
801067d2:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
801067d4:	85 c0                	test   %eax,%eax
801067d6:	74 b3                	je     8010678b <allocuvm+0x3c>
    memset(mem, 0, PGSIZE);
801067d8:	83 ec 04             	sub    $0x4,%esp
801067db:	68 00 10 00 00       	push   $0x1000
801067e0:	6a 00                	push   $0x0
801067e2:	50                   	push   %eax
801067e3:	e8 eb d8 ff ff       	call   801040d3 <memset>
    if (a < (void*) KERNBASE)
801067e8:	83 c4 10             	add    $0x10,%esp
801067eb:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
801067f1:	76 c3                	jbe    801067b6 <allocuvm+0x67>
    return (uint)a - KERNBASE;
801067f3:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801067f9:	83 ec 08             	sub    $0x8,%esp
801067fc:	6a 06                	push   $0x6
801067fe:	50                   	push   %eax
801067ff:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106804:	89 f2                	mov    %esi,%edx
80106806:	8b 45 08             	mov    0x8(%ebp),%eax
80106809:	e8 40 fa ff ff       	call   8010624e <mappages>
8010680e:	83 c4 10             	add    $0x10,%esp
80106811:	85 c0                	test   %eax,%eax
80106813:	79 ae                	jns    801067c3 <allocuvm+0x74>
      cprintf("allocuvm out of memory (2)\n");
80106815:	83 ec 0c             	sub    $0xc,%esp
80106818:	68 95 7a 10 80       	push   $0x80107a95
8010681d:	e8 07 9e ff ff       	call   80100629 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106822:	83 c4 0c             	add    $0xc,%esp
80106825:	ff 75 0c             	pushl  0xc(%ebp)
80106828:	57                   	push   %edi
80106829:	ff 75 08             	pushl  0x8(%ebp)
8010682c:	e8 74 fe ff ff       	call   801066a5 <deallocuvm>
      kfree(mem);
80106831:	89 1c 24             	mov    %ebx,(%esp)
80106834:	e8 84 b9 ff ff       	call   801021bd <kfree>
      return 0;
80106839:	83 c4 10             	add    $0x10,%esp
8010683c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106843:	eb 07                	jmp    8010684c <allocuvm+0xfd>
    return 0;
80106845:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
8010684c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010684f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106852:	5b                   	pop    %ebx
80106853:	5e                   	pop    %esi
80106854:	5f                   	pop    %edi
80106855:	5d                   	pop    %ebp
80106856:	c3                   	ret    

80106857 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106857:	f3 0f 1e fb          	endbr32 
8010685b:	55                   	push   %ebp
8010685c:	89 e5                	mov    %esp,%ebp
8010685e:	56                   	push   %esi
8010685f:	53                   	push   %ebx
80106860:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106863:	85 f6                	test   %esi,%esi
80106865:	74 1a                	je     80106881 <freevm+0x2a>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106867:	83 ec 04             	sub    $0x4,%esp
8010686a:	6a 00                	push   $0x0
8010686c:	68 00 00 00 80       	push   $0x80000000
80106871:	56                   	push   %esi
80106872:	e8 2e fe ff ff       	call   801066a5 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106877:	83 c4 10             	add    $0x10,%esp
8010687a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010687f:	eb 1d                	jmp    8010689e <freevm+0x47>
    panic("freevm: no pgdir");
80106881:	83 ec 0c             	sub    $0xc,%esp
80106884:	68 b1 7a 10 80       	push   $0x80107ab1
80106889:	e8 ce 9a ff ff       	call   8010035c <panic>
        panic("P2V on address > KERNBASE");
8010688e:	83 ec 0c             	sub    $0xc,%esp
80106891:	68 18 76 10 80       	push   $0x80107618
80106896:	e8 c1 9a ff ff       	call   8010035c <panic>
  for(i = 0; i < NPDENTRIES; i++){
8010689b:	83 c3 01             	add    $0x1,%ebx
8010689e:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801068a4:	77 26                	ja     801068cc <freevm+0x75>
    if(pgdir[i] & PTE_P){
801068a6:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801068a9:	a8 01                	test   $0x1,%al
801068ab:	74 ee                	je     8010689b <freevm+0x44>
801068ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
801068b2:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801068b7:	77 d5                	ja     8010688e <freevm+0x37>
    return (char*)a + KERNBASE;
801068b9:	05 00 00 00 80       	add    $0x80000000,%eax
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
801068be:	83 ec 0c             	sub    $0xc,%esp
801068c1:	50                   	push   %eax
801068c2:	e8 f6 b8 ff ff       	call   801021bd <kfree>
801068c7:	83 c4 10             	add    $0x10,%esp
801068ca:	eb cf                	jmp    8010689b <freevm+0x44>
    }
  }
  kfree((char*)pgdir);
801068cc:	83 ec 0c             	sub    $0xc,%esp
801068cf:	56                   	push   %esi
801068d0:	e8 e8 b8 ff ff       	call   801021bd <kfree>
}
801068d5:	83 c4 10             	add    $0x10,%esp
801068d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801068db:	5b                   	pop    %ebx
801068dc:	5e                   	pop    %esi
801068dd:	5d                   	pop    %ebp
801068de:	c3                   	ret    

801068df <setupkvm>:
{
801068df:	f3 0f 1e fb          	endbr32 
801068e3:	55                   	push   %ebp
801068e4:	89 e5                	mov    %esp,%ebp
801068e6:	56                   	push   %esi
801068e7:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801068e8:	e8 1d ba ff ff       	call   8010230a <kalloc>
801068ed:	89 c6                	mov    %eax,%esi
801068ef:	85 c0                	test   %eax,%eax
801068f1:	74 55                	je     80106948 <setupkvm+0x69>
  memset(pgdir, 0, PGSIZE);
801068f3:	83 ec 04             	sub    $0x4,%esp
801068f6:	68 00 10 00 00       	push   $0x1000
801068fb:	6a 00                	push   $0x0
801068fd:	50                   	push   %eax
801068fe:	e8 d0 d7 ff ff       	call   801040d3 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106903:	83 c4 10             	add    $0x10,%esp
80106906:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
8010690b:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106911:	73 35                	jae    80106948 <setupkvm+0x69>
                (uint)k->phys_start, k->perm) < 0) {
80106913:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106916:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106919:	29 c1                	sub    %eax,%ecx
8010691b:	83 ec 08             	sub    $0x8,%esp
8010691e:	ff 73 0c             	pushl  0xc(%ebx)
80106921:	50                   	push   %eax
80106922:	8b 13                	mov    (%ebx),%edx
80106924:	89 f0                	mov    %esi,%eax
80106926:	e8 23 f9 ff ff       	call   8010624e <mappages>
8010692b:	83 c4 10             	add    $0x10,%esp
8010692e:	85 c0                	test   %eax,%eax
80106930:	78 05                	js     80106937 <setupkvm+0x58>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106932:	83 c3 10             	add    $0x10,%ebx
80106935:	eb d4                	jmp    8010690b <setupkvm+0x2c>
      freevm(pgdir);
80106937:	83 ec 0c             	sub    $0xc,%esp
8010693a:	56                   	push   %esi
8010693b:	e8 17 ff ff ff       	call   80106857 <freevm>
      return 0;
80106940:	83 c4 10             	add    $0x10,%esp
80106943:	be 00 00 00 00       	mov    $0x0,%esi
}
80106948:	89 f0                	mov    %esi,%eax
8010694a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010694d:	5b                   	pop    %ebx
8010694e:	5e                   	pop    %esi
8010694f:	5d                   	pop    %ebp
80106950:	c3                   	ret    

80106951 <kvmalloc>:
{
80106951:	f3 0f 1e fb          	endbr32 
80106955:	55                   	push   %ebp
80106956:	89 e5                	mov    %esp,%ebp
80106958:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010695b:	e8 7f ff ff ff       	call   801068df <setupkvm>
80106960:	a3 24 66 11 80       	mov    %eax,0x80116624
  switchkvm();
80106965:	e8 aa fa ff ff       	call   80106414 <switchkvm>
}
8010696a:	c9                   	leave  
8010696b:	c3                   	ret    

8010696c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010696c:	f3 0f 1e fb          	endbr32 
80106970:	55                   	push   %ebp
80106971:	89 e5                	mov    %esp,%ebp
80106973:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106976:	b9 00 00 00 00       	mov    $0x0,%ecx
8010697b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010697e:	8b 45 08             	mov    0x8(%ebp),%eax
80106981:	e8 2d f8 ff ff       	call   801061b3 <walkpgdir>
  if(pte == 0)
80106986:	85 c0                	test   %eax,%eax
80106988:	74 05                	je     8010698f <clearpteu+0x23>
    panic("clearpteu");
  *pte &= ~PTE_U;
8010698a:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010698d:	c9                   	leave  
8010698e:	c3                   	ret    
    panic("clearpteu");
8010698f:	83 ec 0c             	sub    $0xc,%esp
80106992:	68 c2 7a 10 80       	push   $0x80107ac2
80106997:	e8 c0 99 ff ff       	call   8010035c <panic>

8010699c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010699c:	f3 0f 1e fb          	endbr32 
801069a0:	55                   	push   %ebp
801069a1:	89 e5                	mov    %esp,%ebp
801069a3:	57                   	push   %edi
801069a4:	56                   	push   %esi
801069a5:	53                   	push   %ebx
801069a6:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801069a9:	e8 31 ff ff ff       	call   801068df <setupkvm>
801069ae:	89 45 dc             	mov    %eax,-0x24(%ebp)
801069b1:	85 c0                	test   %eax,%eax
801069b3:	0f 84 f2 00 00 00    	je     80106aab <copyuvm+0x10f>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801069b9:	bf 00 00 00 00       	mov    $0x0,%edi
801069be:	eb 3a                	jmp    801069fa <copyuvm+0x5e>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
801069c0:	83 ec 0c             	sub    $0xc,%esp
801069c3:	68 cc 7a 10 80       	push   $0x80107acc
801069c8:	e8 8f 99 ff ff       	call   8010035c <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
801069cd:	83 ec 0c             	sub    $0xc,%esp
801069d0:	68 e6 7a 10 80       	push   $0x80107ae6
801069d5:	e8 82 99 ff ff       	call   8010035c <panic>
        panic("P2V on address > KERNBASE");
801069da:	83 ec 0c             	sub    $0xc,%esp
801069dd:	68 18 76 10 80       	push   $0x80107618
801069e2:	e8 75 99 ff ff       	call   8010035c <panic>
        panic("V2P on address < KERNBASE "
801069e7:	83 ec 0c             	sub    $0xc,%esp
801069ea:	68 f4 72 10 80       	push   $0x801072f4
801069ef:	e8 68 99 ff ff       	call   8010035c <panic>
  for(i = 0; i < sz; i += PGSIZE){
801069f4:	81 c7 00 10 00 00    	add    $0x1000,%edi
801069fa:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801069fd:	0f 83 a8 00 00 00    	jae    80106aab <copyuvm+0x10f>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106a03:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106a06:	b9 00 00 00 00       	mov    $0x0,%ecx
80106a0b:	89 fa                	mov    %edi,%edx
80106a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a10:	e8 9e f7 ff ff       	call   801061b3 <walkpgdir>
80106a15:	85 c0                	test   %eax,%eax
80106a17:	74 a7                	je     801069c0 <copyuvm+0x24>
    if(!(*pte & PTE_P))
80106a19:	8b 00                	mov    (%eax),%eax
80106a1b:	a8 01                	test   $0x1,%al
80106a1d:	74 ae                	je     801069cd <copyuvm+0x31>
80106a1f:	89 c6                	mov    %eax,%esi
80106a21:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
80106a27:	25 ff 0f 00 00       	and    $0xfff,%eax
80106a2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
80106a2f:	e8 d6 b8 ff ff       	call   8010230a <kalloc>
80106a34:	89 c3                	mov    %eax,%ebx
80106a36:	85 c0                	test   %eax,%eax
80106a38:	74 5c                	je     80106a96 <copyuvm+0xfa>
    if (a > KERNBASE)
80106a3a:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80106a40:	77 98                	ja     801069da <copyuvm+0x3e>
    return (char*)a + KERNBASE;
80106a42:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106a48:	83 ec 04             	sub    $0x4,%esp
80106a4b:	68 00 10 00 00       	push   $0x1000
80106a50:	56                   	push   %esi
80106a51:	50                   	push   %eax
80106a52:	e8 fc d6 ff ff       	call   80104153 <memmove>
    if (a < (void*) KERNBASE)
80106a57:	83 c4 10             	add    $0x10,%esp
80106a5a:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106a60:	76 85                	jbe    801069e7 <copyuvm+0x4b>
    return (uint)a - KERNBASE;
80106a62:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106a68:	83 ec 08             	sub    $0x8,%esp
80106a6b:	ff 75 e0             	pushl  -0x20(%ebp)
80106a6e:	50                   	push   %eax
80106a6f:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106a74:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106a77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a7a:	e8 cf f7 ff ff       	call   8010624e <mappages>
80106a7f:	83 c4 10             	add    $0x10,%esp
80106a82:	85 c0                	test   %eax,%eax
80106a84:	0f 89 6a ff ff ff    	jns    801069f4 <copyuvm+0x58>
      kfree(mem);
80106a8a:	83 ec 0c             	sub    $0xc,%esp
80106a8d:	53                   	push   %ebx
80106a8e:	e8 2a b7 ff ff       	call   801021bd <kfree>
      goto bad;
80106a93:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106a96:	83 ec 0c             	sub    $0xc,%esp
80106a99:	ff 75 dc             	pushl  -0x24(%ebp)
80106a9c:	e8 b6 fd ff ff       	call   80106857 <freevm>
  return 0;
80106aa1:	83 c4 10             	add    $0x10,%esp
80106aa4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106aab:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106aae:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ab1:	5b                   	pop    %ebx
80106ab2:	5e                   	pop    %esi
80106ab3:	5f                   	pop    %edi
80106ab4:	5d                   	pop    %ebp
80106ab5:	c3                   	ret    

80106ab6 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106ab6:	f3 0f 1e fb          	endbr32 
80106aba:	55                   	push   %ebp
80106abb:	89 e5                	mov    %esp,%ebp
80106abd:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106ac0:	b9 00 00 00 00       	mov    $0x0,%ecx
80106ac5:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80106acb:	e8 e3 f6 ff ff       	call   801061b3 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106ad0:	8b 00                	mov    (%eax),%eax
80106ad2:	a8 01                	test   $0x1,%al
80106ad4:	74 24                	je     80106afa <uva2ka+0x44>
    return 0;
  if((*pte & PTE_U) == 0)
80106ad6:	a8 04                	test   $0x4,%al
80106ad8:	74 27                	je     80106b01 <uva2ka+0x4b>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80106ada:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
80106adf:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106ae4:	77 07                	ja     80106aed <uva2ka+0x37>
    return (char*)a + KERNBASE;
80106ae6:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80106aeb:	c9                   	leave  
80106aec:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80106aed:	83 ec 0c             	sub    $0xc,%esp
80106af0:	68 18 76 10 80       	push   $0x80107618
80106af5:	e8 62 98 ff ff       	call   8010035c <panic>
    return 0;
80106afa:	b8 00 00 00 00       	mov    $0x0,%eax
80106aff:	eb ea                	jmp    80106aeb <uva2ka+0x35>
    return 0;
80106b01:	b8 00 00 00 00       	mov    $0x0,%eax
80106b06:	eb e3                	jmp    80106aeb <uva2ka+0x35>

80106b08 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106b08:	f3 0f 1e fb          	endbr32 
80106b0c:	55                   	push   %ebp
80106b0d:	89 e5                	mov    %esp,%ebp
80106b0f:	57                   	push   %edi
80106b10:	56                   	push   %esi
80106b11:	53                   	push   %ebx
80106b12:	83 ec 0c             	sub    $0xc,%esp
80106b15:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106b18:	eb 25                	jmp    80106b3f <copyout+0x37>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
80106b1d:	29 f2                	sub    %esi,%edx
80106b1f:	01 d0                	add    %edx,%eax
80106b21:	83 ec 04             	sub    $0x4,%esp
80106b24:	53                   	push   %ebx
80106b25:	ff 75 10             	pushl  0x10(%ebp)
80106b28:	50                   	push   %eax
80106b29:	e8 25 d6 ff ff       	call   80104153 <memmove>
    len -= n;
80106b2e:	29 df                	sub    %ebx,%edi
    buf += n;
80106b30:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106b33:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106b39:	89 45 0c             	mov    %eax,0xc(%ebp)
80106b3c:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106b3f:	85 ff                	test   %edi,%edi
80106b41:	74 2f                	je     80106b72 <copyout+0x6a>
    va0 = (uint)PGROUNDDOWN(va);
80106b43:	8b 75 0c             	mov    0xc(%ebp),%esi
80106b46:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106b4c:	83 ec 08             	sub    $0x8,%esp
80106b4f:	56                   	push   %esi
80106b50:	ff 75 08             	pushl  0x8(%ebp)
80106b53:	e8 5e ff ff ff       	call   80106ab6 <uva2ka>
    if(pa0 == 0)
80106b58:	83 c4 10             	add    $0x10,%esp
80106b5b:	85 c0                	test   %eax,%eax
80106b5d:	74 20                	je     80106b7f <copyout+0x77>
    n = PGSIZE - (va - va0);
80106b5f:	89 f3                	mov    %esi,%ebx
80106b61:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106b64:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106b6a:	39 df                	cmp    %ebx,%edi
80106b6c:	73 ac                	jae    80106b1a <copyout+0x12>
      n = len;
80106b6e:	89 fb                	mov    %edi,%ebx
80106b70:	eb a8                	jmp    80106b1a <copyout+0x12>
  }
  return 0;
80106b72:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b7a:	5b                   	pop    %ebx
80106b7b:	5e                   	pop    %esi
80106b7c:	5f                   	pop    %edi
80106b7d:	5d                   	pop    %ebp
80106b7e:	c3                   	ret    
      return -1;
80106b7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b84:	eb f1                	jmp    80106b77 <copyout+0x6f>

80106b86 <s_cnputs>:
//#include "proc.h"
//#include "x86.h"

// Copy into outbuffer at most n characters of string.
static int s_cnputs(char *outbuffer, int n, const char* string)
{
80106b86:	55                   	push   %ebp
80106b87:	89 e5                	mov    %esp,%ebp
80106b89:	56                   	push   %esi
80106b8a:	53                   	push   %ebx
80106b8b:	89 c6                	mov    %eax,%esi
    int count = 0;
80106b8d:	b8 00 00 00 00       	mov    $0x0,%eax

    for(; count < n && '\0' != string[count]; ++count)  {
80106b92:	39 d0                	cmp    %edx,%eax
80106b94:	7d 10                	jge    80106ba6 <s_cnputs+0x20>
80106b96:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
80106b9a:	84 db                	test   %bl,%bl
80106b9c:	74 08                	je     80106ba6 <s_cnputs+0x20>
        outbuffer[count] = string[count];
80106b9e:	88 1c 06             	mov    %bl,(%esi,%eax,1)
    for(; count < n && '\0' != string[count]; ++count)  {
80106ba1:	83 c0 01             	add    $0x1,%eax
80106ba4:	eb ec                	jmp    80106b92 <s_cnputs+0xc>
    }
    if(count < n) {
80106ba6:	39 d0                	cmp    %edx,%eax
80106ba8:	7d 04                	jge    80106bae <s_cnputs+0x28>
        outbuffer[count] = '\0';
80106baa:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
    }
    return count;
}
80106bae:	5b                   	pop    %ebx
80106baf:	5e                   	pop    %esi
80106bb0:	5d                   	pop    %ebp
80106bb1:	c3                   	ret    

80106bb2 <helloread>:

int
helloread(struct inode *ip, char *dst, int n)
{
80106bb2:	f3 0f 1e fb          	endbr32 
80106bb6:	55                   	push   %ebp
80106bb7:	89 e5                	mov    %esp,%ebp
80106bb9:	83 ec 08             	sub    $0x8,%esp
    return s_cnputs(dst, n, "Hello, World!");
80106bbc:	b9 23 7b 10 80       	mov    $0x80107b23,%ecx
80106bc1:	8b 55 10             	mov    0x10(%ebp),%edx
80106bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bc7:	e8 ba ff ff ff       	call   80106b86 <s_cnputs>
}
80106bcc:	c9                   	leave  
80106bcd:	c3                   	ret    

80106bce <hellowrite>:

int
hellowrite(struct inode *ip, char *buf, int n)
{
80106bce:	f3 0f 1e fb          	endbr32 
    return 0;
}
80106bd2:	b8 00 00 00 00       	mov    $0x0,%eax
80106bd7:	c3                   	ret    

80106bd8 <helloinit>:

void
helloinit(void)
{
80106bd8:	f3 0f 1e fb          	endbr32 
  devsw[HELLO].write = hellowrite;
80106bdc:	c7 05 9c 0b 11 80 ce 	movl   $0x80106bce,0x80110b9c
80106be3:	6b 10 80 
  devsw[HELLO].read = helloread;
80106be6:	c7 05 98 0b 11 80 b2 	movl   $0x80106bb2,0x80110b98
80106bed:	6b 10 80 
80106bf0:	c3                   	ret    

80106bf1 <s_cnputs>:
#include "fs.h"
#include "file.h"


static int s_cnputs(char *outbuffer, int n, const char* string)
{
80106bf1:	55                   	push   %ebp
80106bf2:	89 e5                	mov    %esp,%ebp
80106bf4:	56                   	push   %esi
80106bf5:	53                   	push   %ebx
80106bf6:	89 c6                	mov    %eax,%esi
    int count = 0;
80106bf8:	b8 00 00 00 00       	mov    $0x0,%eax

    for(; count < n && '\0' != string[count]; ++count)  {
80106bfd:	39 d0                	cmp    %edx,%eax
80106bff:	7d 10                	jge    80106c11 <s_cnputs+0x20>
80106c01:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
80106c05:	84 db                	test   %bl,%bl
80106c07:	74 08                	je     80106c11 <s_cnputs+0x20>
        outbuffer[count] = string[count];
80106c09:	88 1c 06             	mov    %bl,(%esi,%eax,1)
    for(; count < n && '\0' != string[count]; ++count)  {
80106c0c:	83 c0 01             	add    $0x1,%eax
80106c0f:	eb ec                	jmp    80106bfd <s_cnputs+0xc>
    }
    if(count < n) {
80106c11:	39 d0                	cmp    %edx,%eax
80106c13:	7d 04                	jge    80106c19 <s_cnputs+0x28>
        outbuffer[count] = '\0';
80106c15:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
    }
    return count;
}
80106c19:	5b                   	pop    %ebx
80106c1a:	5e                   	pop    %esi
80106c1b:	5d                   	pop    %ebp
80106c1c:	c3                   	ret    

80106c1d <zeroread>:

int
zeroread(struct inode *ip, char *dst, int n)
{
80106c1d:	f3 0f 1e fb          	endbr32 
80106c21:	55                   	push   %ebp
80106c22:	89 e5                	mov    %esp,%ebp
80106c24:	83 ec 08             	sub    $0x8,%esp
    return s_cnputs(dst, n, "0");
80106c27:	b9 31 7b 10 80       	mov    $0x80107b31,%ecx
80106c2c:	8b 55 10             	mov    0x10(%ebp),%edx
80106c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c32:	e8 ba ff ff ff       	call   80106bf1 <s_cnputs>
}
80106c37:	c9                   	leave  
80106c38:	c3                   	ret    

80106c39 <zeroinit>:

void
zeroinit(void)
{
80106c39:	f3 0f 1e fb          	endbr32 
  devsw[ZERO].read = zeroread;
80106c3d:	c7 05 70 0b 11 80 1d 	movl   $0x80106c1d,0x80110b70
80106c44:	6c 10 80 
80106c47:	c3                   	ret    

80106c48 <nullread>:
#include "file.h"


int
nullread(struct inode *ip, char *dst, int n)
{
80106c48:	f3 0f 1e fb          	endbr32 
80106c4c:	55                   	push   %ebp
80106c4d:	89 e5                	mov    %esp,%ebp
    return n;
}
80106c4f:	8b 45 10             	mov    0x10(%ebp),%eax
80106c52:	5d                   	pop    %ebp
80106c53:	c3                   	ret    

80106c54 <nullwrite>:

int
nullwrite(struct inode *ip, char *dst, int n)
{
80106c54:	f3 0f 1e fb          	endbr32 
80106c58:	55                   	push   %ebp
80106c59:	89 e5                	mov    %esp,%ebp
    return n;
}
80106c5b:	8b 45 10             	mov    0x10(%ebp),%eax
80106c5e:	5d                   	pop    %ebp
80106c5f:	c3                   	ret    

80106c60 <nullinit>:

void
nullinit(void)
{
80106c60:	f3 0f 1e fb          	endbr32 
  devsw[NULL].read = nullread;
80106c64:	c7 05 78 0b 11 80 48 	movl   $0x80106c48,0x80110b78
80106c6b:	6c 10 80 
  devsw[NULL].write = nullwrite;
80106c6e:	c7 05 7c 0b 11 80 54 	movl   $0x80106c54,0x80110b7c
80106c75:	6c 10 80 

80106c78:	c3                   	ret    

80106c79 <s_sputc>:


typedef void (*putFunction_t)(int fd, char *outbuffer, uint length, uint index, char c);

void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
80106c79:	f3 0f 1e fb          	endbr32 
80106c7d:	55                   	push   %ebp
80106c7e:	89 e5                	mov    %esp,%ebp
80106c80:	8b 45 14             	mov    0x14(%ebp),%eax
80106c83:	8b 55 18             	mov    0x18(%ebp),%edx
  if(index < length)
80106c86:	3b 45 10             	cmp    0x10(%ebp),%eax
80106c89:	73 06                	jae    80106c91 <s_sputc+0x18>
  {
    outbuffer[index] = c;
80106c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106c8e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  }
}
80106c91:	5d                   	pop    %ebp
80106c92:	c3                   	ret    

80106c93 <s_getReverse>:

static uint 
s_getReverse(char *outbuf, uint length, int x, int base, int sgn)
{
80106c93:	55                   	push   %ebp
80106c94:	89 e5                	mov    %esp,%ebp
80106c96:	57                   	push   %edi
80106c97:	56                   	push   %esi
80106c98:	53                   	push   %ebx
80106c99:	83 ec 08             	sub    $0x8,%esp
80106c9c:	89 c7                	mov    %eax,%edi
80106c9e:	89 55 f0             	mov    %edx,-0x10(%ebp)
  static char digs[] = "0123456789ABCDEF";
  int i, n;
  uint a;

  n = 0;
  if(sgn && x < 0){
80106ca1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106ca5:	0f 95 c2             	setne  %dl
80106ca8:	89 c8                	mov    %ecx,%eax
80106caa:	c1 e8 1f             	shr    $0x1f,%eax
80106cad:	84 c2                	test   %al,%dl
80106caf:	74 34                	je     80106ce5 <s_getReverse+0x52>
    n = 1;
    a = -x;
80106cb1:	89 c8                	mov    %ecx,%eax
80106cb3:	f7 d8                	neg    %eax
    n = 1;
80106cb5:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  } else {
    a = x;
  }

  i = 0;
80106cbc:	be 00 00 00 00       	mov    $0x0,%esi
  while(i + 1 < length && x != 0) {
80106cc1:	8d 5e 01             	lea    0x1(%esi),%ebx
80106cc4:	89 da                	mov    %ebx,%edx
80106cc6:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
80106cc9:	73 25                	jae    80106cf0 <s_getReverse+0x5d>
80106ccb:	85 c9                	test   %ecx,%ecx
80106ccd:	74 21                	je     80106cf0 <s_getReverse+0x5d>
    outbuf[i++] = digs[a % base];
80106ccf:	ba 00 00 00 00       	mov    $0x0,%edx
80106cd4:	f7 75 08             	divl   0x8(%ebp)
80106cd7:	0f b6 92 38 7b 10 80 	movzbl -0x7fef84c8(%edx),%edx
80106cde:	88 14 37             	mov    %dl,(%edi,%esi,1)
80106ce1:	89 de                	mov    %ebx,%esi
80106ce3:	eb dc                	jmp    80106cc1 <s_getReverse+0x2e>
    a = x;
80106ce5:	89 c8                	mov    %ecx,%eax
  n = 0;
80106ce7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80106cee:	eb cc                	jmp    80106cbc <s_getReverse+0x29>
    a /= base;
  }

  if(0 == x && i + 1 < length) {
80106cf0:	85 c9                	test   %ecx,%ecx
80106cf2:	75 0b                	jne    80106cff <s_getReverse+0x6c>
80106cf4:	3b 55 f0             	cmp    -0x10(%ebp),%edx
80106cf7:	73 06                	jae    80106cff <s_getReverse+0x6c>
    outbuf[i++] = digs[0];   
80106cf9:	c6 04 37 30          	movb   $0x30,(%edi,%esi,1)
80106cfd:	89 de                	mov    %ebx,%esi
  }

  if(n && i < length) {
80106cff:	89 f2                	mov    %esi,%edx
80106d01:	3b 75 f0             	cmp    -0x10(%ebp),%esi
80106d04:	0f 92 c0             	setb   %al
80106d07:	84 45 ec             	test   %al,-0x14(%ebp)
80106d0a:	74 07                	je     80106d13 <s_getReverse+0x80>
    outbuf[i++] = '-';
80106d0c:	83 c6 01             	add    $0x1,%esi
80106d0f:	c6 04 17 2d          	movb   $0x2d,(%edi,%edx,1)
  }

  return i;
}
80106d13:	89 f0                	mov    %esi,%eax
80106d15:	83 c4 08             	add    $0x8,%esp
80106d18:	5b                   	pop    %ebx
80106d19:	5e                   	pop    %esi
80106d1a:	5f                   	pop    %edi
80106d1b:	5d                   	pop    %ebp
80106d1c:	c3                   	ret    

80106d1d <s_min>:
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
80106d1d:	39 c2                	cmp    %eax,%edx
80106d1f:	0f 46 c2             	cmovbe %edx,%eax
}
80106d22:	c3                   	ret    

80106d23 <s_cnputs>:

  return count;
}

static int s_cnputs(char *outbuffer, int n, const char* string)
{
80106d23:	55                   	push   %ebp
80106d24:	89 e5                	mov    %esp,%ebp
80106d26:	56                   	push   %esi
80106d27:	53                   	push   %ebx
80106d28:	89 c6                	mov    %eax,%esi
    int itr = 0;
80106d2a:	b8 00 00 00 00       	mov    $0x0,%eax

    for(; itr < n && '\0' != string[itr]; ++itr)  {
80106d2f:	39 d0                	cmp    %edx,%eax
80106d31:	7d 10                	jge    80106d43 <s_cnputs+0x20>
80106d33:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
80106d37:	84 db                	test   %bl,%bl
80106d39:	74 08                	je     80106d43 <s_cnputs+0x20>
        outbuffer[itr] = string[itr];
80106d3b:	88 1c 06             	mov    %bl,(%esi,%eax,1)
    for(; itr < n && '\0' != string[itr]; ++itr)  {
80106d3e:	83 c0 01             	add    $0x1,%eax
80106d41:	eb ec                	jmp    80106d2f <s_cnputs+0xc>
    }
    if(itr < n) {
80106d43:	39 d0                	cmp    %edx,%eax
80106d45:	7d 04                	jge    80106d4b <s_cnputs+0x28>
        outbuffer[itr] = '\0';
80106d47:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
    }
    itr++;
80106d4b:	83 c0 01             	add    $0x1,%eax
    return itr;
}
80106d4e:	5b                   	pop    %ebx
80106d4f:	5e                   	pop    %esi
80106d50:	5d                   	pop    %ebp
80106d51:	c3                   	ret    

80106d52 <s_printint>:
{
80106d52:	55                   	push   %ebp
80106d53:	89 e5                	mov    %esp,%ebp
80106d55:	57                   	push   %edi
80106d56:	56                   	push   %esi
80106d57:	53                   	push   %ebx
80106d58:	83 ec 2c             	sub    $0x2c,%esp
80106d5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106d5e:	89 55 d0             	mov    %edx,-0x30(%ebp)
80106d61:	89 4d cc             	mov    %ecx,-0x34(%ebp)
80106d64:	8b 7d 08             	mov    0x8(%ebp),%edi
  s_getReverse(localBuffer, localBufferLength, xx, base, sgn);
80106d67:	ff 75 14             	pushl  0x14(%ebp)
80106d6a:	ff 75 10             	pushl  0x10(%ebp)
80106d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106d70:	ba 10 00 00 00       	mov    $0x10,%edx
80106d75:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106d78:	e8 16 ff ff ff       	call   80106c93 <s_getReverse>
80106d7d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int i = result;
80106d80:	89 c3                	mov    %eax,%ebx
  while(--i >= 0 && j < length) 
80106d82:	83 c4 08             	add    $0x8,%esp
  int j = 0;
80106d85:	be 00 00 00 00       	mov    $0x0,%esi
  while(--i >= 0 && j < length) 
80106d8a:	83 eb 01             	sub    $0x1,%ebx
80106d8d:	78 22                	js     80106db1 <s_printint+0x5f>
80106d8f:	39 fe                	cmp    %edi,%esi
80106d91:	73 1e                	jae    80106db1 <s_printint+0x5f>
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
80106d93:	83 ec 0c             	sub    $0xc,%esp
80106d96:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
80106d9b:	50                   	push   %eax
80106d9c:	56                   	push   %esi
80106d9d:	57                   	push   %edi
80106d9e:	ff 75 cc             	pushl  -0x34(%ebp)
80106da1:	ff 75 d0             	pushl  -0x30(%ebp)
80106da4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80106da7:	ff d0                	call   *%eax
    j++;
80106da9:	83 c6 01             	add    $0x1,%esi
80106dac:	83 c4 20             	add    $0x20,%esp
80106daf:	eb d9                	jmp    80106d8a <s_printint+0x38>
}
80106db1:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106db4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106db7:	5b                   	pop    %ebx
80106db8:	5e                   	pop    %esi
80106db9:	5f                   	pop    %edi
80106dba:	5d                   	pop    %ebp
80106dbb:	c3                   	ret    

80106dbc <s_printf>:
{
80106dbc:	55                   	push   %ebp
80106dbd:	89 e5                	mov    %esp,%ebp
80106dbf:	57                   	push   %edi
80106dc0:	56                   	push   %esi
80106dc1:	53                   	push   %ebx
80106dc2:	83 ec 2c             	sub    $0x2c,%esp
80106dc5:	89 45 d8             	mov    %eax,-0x28(%ebp)
80106dc8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80106dcb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  const int length = n -1;
80106dce:	8b 45 08             	mov    0x8(%ebp),%eax
80106dd1:	8d 78 ff             	lea    -0x1(%eax),%edi
  state = 0;
80106dd4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(i = 0; fmt[i] && outindex < length; i++) {
80106ddb:	bb 00 00 00 00       	mov    $0x0,%ebx
80106de0:	89 f8                	mov    %edi,%eax
80106de2:	89 df                	mov    %ebx,%edi
80106de4:	89 c6                	mov    %eax,%esi
80106de6:	eb 20                	jmp    80106e08 <s_printf+0x4c>
        putcFunction(fd, outbuffer, length, outindex++, c);
80106de8:	8d 43 01             	lea    0x1(%ebx),%eax
80106deb:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106dee:	83 ec 0c             	sub    $0xc,%esp
80106df1:	51                   	push   %ecx
80106df2:	53                   	push   %ebx
80106df3:	56                   	push   %esi
80106df4:	ff 75 d0             	pushl  -0x30(%ebp)
80106df7:	ff 75 d4             	pushl  -0x2c(%ebp)
80106dfa:	8b 55 d8             	mov    -0x28(%ebp),%edx
80106dfd:	ff d2                	call   *%edx
80106dff:	83 c4 20             	add    $0x20,%esp
80106e02:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  for(i = 0; fmt[i] && outindex < length; i++) {
80106e05:	83 c7 01             	add    $0x1,%edi
80106e08:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e0b:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80106e0f:	84 c0                	test   %al,%al
80106e11:	0f 84 cd 01 00 00    	je     80106fe4 <s_printf+0x228>
80106e17:	89 75 e0             	mov    %esi,-0x20(%ebp)
80106e1a:	39 de                	cmp    %ebx,%esi
80106e1c:	0f 86 c2 01 00 00    	jbe    80106fe4 <s_printf+0x228>
    c = fmt[i] & 0xff;
80106e22:	0f be c8             	movsbl %al,%ecx
80106e25:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80106e28:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
80106e2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106e2f:	75 0a                	jne    80106e3b <s_printf+0x7f>
      if(c == '%') {
80106e31:	83 f8 25             	cmp    $0x25,%eax
80106e34:	75 b2                	jne    80106de8 <s_printf+0x2c>
        state = '%';
80106e36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106e39:	eb ca                	jmp    80106e05 <s_printf+0x49>
    } else if(state == '%'){
80106e3b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80106e3f:	75 c4                	jne    80106e05 <s_printf+0x49>
      if(c == 'd'){
80106e41:	83 f8 64             	cmp    $0x64,%eax
80106e44:	74 6e                	je     80106eb4 <s_printf+0xf8>
      } else if(c == 'x' || c == 'p'){
80106e46:	83 f8 78             	cmp    $0x78,%eax
80106e49:	0f 94 c1             	sete   %cl
80106e4c:	83 f8 70             	cmp    $0x70,%eax
80106e4f:	0f 94 c2             	sete   %dl
80106e52:	08 d1                	or     %dl,%cl
80106e54:	0f 85 8e 00 00 00    	jne    80106ee8 <s_printf+0x12c>
      } else if(c == 's'){
80106e5a:	83 f8 73             	cmp    $0x73,%eax
80106e5d:	0f 84 b9 00 00 00    	je     80106f1c <s_printf+0x160>
      } else if(c == 'c'){
80106e63:	83 f8 63             	cmp    $0x63,%eax
80106e66:	0f 84 1a 01 00 00    	je     80106f86 <s_printf+0x1ca>
      } else if(c == '%'){
80106e6c:	83 f8 25             	cmp    $0x25,%eax
80106e6f:	0f 84 44 01 00 00    	je     80106fb9 <s_printf+0x1fd>
        putcFunction(fd, outbuffer, length, outindex++, '%');
80106e75:	8d 43 01             	lea    0x1(%ebx),%eax
80106e78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106e7b:	83 ec 0c             	sub    $0xc,%esp
80106e7e:	6a 25                	push   $0x25
80106e80:	53                   	push   %ebx
80106e81:	56                   	push   %esi
80106e82:	ff 75 d0             	pushl  -0x30(%ebp)
80106e85:	ff 75 d4             	pushl  -0x2c(%ebp)
80106e88:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106e8b:	ff d0                	call   *%eax
        putcFunction(fd, outbuffer, length, outindex++, c);
80106e8d:	83 c3 02             	add    $0x2,%ebx
80106e90:	83 c4 14             	add    $0x14,%esp
80106e93:	ff 75 dc             	pushl  -0x24(%ebp)
80106e96:	ff 75 e4             	pushl  -0x1c(%ebp)
80106e99:	56                   	push   %esi
80106e9a:	ff 75 d0             	pushl  -0x30(%ebp)
80106e9d:	ff 75 d4             	pushl  -0x2c(%ebp)
80106ea0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106ea3:	ff d0                	call   *%eax
80106ea5:	83 c4 20             	add    $0x20,%esp
      state = 0;
80106ea8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106eaf:	e9 51 ff ff ff       	jmp    80106e05 <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
80106eb4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106eb7:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
80106eba:	6a 01                	push   $0x1
80106ebc:	6a 0a                	push   $0xa
80106ebe:	8b 45 10             	mov    0x10(%ebp),%eax
80106ec1:	ff 30                	pushl  (%eax)
80106ec3:	89 f0                	mov    %esi,%eax
80106ec5:	29 d8                	sub    %ebx,%eax
80106ec7:	50                   	push   %eax
80106ec8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106ecb:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106ece:	e8 7f fe ff ff       	call   80106d52 <s_printint>
80106ed3:	01 c3                	add    %eax,%ebx
        ap++;
80106ed5:	83 45 10 04          	addl   $0x4,0x10(%ebp)
80106ed9:	83 c4 10             	add    $0x10,%esp
      state = 0;
80106edc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106ee3:	e9 1d ff ff ff       	jmp    80106e05 <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
80106ee8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106eeb:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
80106eee:	6a 00                	push   $0x0
80106ef0:	6a 10                	push   $0x10
80106ef2:	8b 45 10             	mov    0x10(%ebp),%eax
80106ef5:	ff 30                	pushl  (%eax)
80106ef7:	89 f0                	mov    %esi,%eax
80106ef9:	29 d8                	sub    %ebx,%eax
80106efb:	50                   	push   %eax
80106efc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106eff:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106f02:	e8 4b fe ff ff       	call   80106d52 <s_printint>
80106f07:	01 c3                	add    %eax,%ebx
        ap++;
80106f09:	83 45 10 04          	addl   $0x4,0x10(%ebp)
80106f0d:	83 c4 10             	add    $0x10,%esp
      state = 0;
80106f10:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106f17:	e9 e9 fe ff ff       	jmp    80106e05 <s_printf+0x49>
        s = (char*)*ap;
80106f1c:	8b 45 10             	mov    0x10(%ebp),%eax
80106f1f:	8b 00                	mov    (%eax),%eax
        ap++;
80106f21:	83 45 10 04          	addl   $0x4,0x10(%ebp)
        if(s == 0)
80106f25:	85 c0                	test   %eax,%eax
80106f27:	75 4e                	jne    80106f77 <s_printf+0x1bb>
          s = "(null)";
80106f29:	b8 d8 70 10 80       	mov    $0x801070d8,%eax
80106f2e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106f31:	89 da                	mov    %ebx,%edx
80106f33:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80106f36:	89 75 e0             	mov    %esi,-0x20(%ebp)
80106f39:	89 c6                	mov    %eax,%esi
80106f3b:	eb 1f                	jmp    80106f5c <s_printf+0x1a0>
          putcFunction(fd, outbuffer, length, outindex++, *s);
80106f3d:	8d 7a 01             	lea    0x1(%edx),%edi
80106f40:	83 ec 0c             	sub    $0xc,%esp
80106f43:	0f be c0             	movsbl %al,%eax
80106f46:	50                   	push   %eax
80106f47:	52                   	push   %edx
80106f48:	53                   	push   %ebx
80106f49:	ff 75 d0             	pushl  -0x30(%ebp)
80106f4c:	ff 75 d4             	pushl  -0x2c(%ebp)
80106f4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106f52:	ff d0                	call   *%eax
          s++;
80106f54:	83 c6 01             	add    $0x1,%esi
80106f57:	83 c4 20             	add    $0x20,%esp
          putcFunction(fd, outbuffer, length, outindex++, *s);
80106f5a:	89 fa                	mov    %edi,%edx
        while(*s != 0){
80106f5c:	0f b6 06             	movzbl (%esi),%eax
80106f5f:	84 c0                	test   %al,%al
80106f61:	75 da                	jne    80106f3d <s_printf+0x181>
80106f63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80106f66:	89 d3                	mov    %edx,%ebx
80106f68:	8b 75 e0             	mov    -0x20(%ebp),%esi
      state = 0;
80106f6b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106f72:	e9 8e fe ff ff       	jmp    80106e05 <s_printf+0x49>
80106f77:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106f7a:	89 da                	mov    %ebx,%edx
80106f7c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80106f7f:	89 75 e0             	mov    %esi,-0x20(%ebp)
80106f82:	89 c6                	mov    %eax,%esi
80106f84:	eb d6                	jmp    80106f5c <s_printf+0x1a0>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
80106f86:	8d 43 01             	lea    0x1(%ebx),%eax
80106f89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106f8c:	83 ec 0c             	sub    $0xc,%esp
80106f8f:	8b 55 10             	mov    0x10(%ebp),%edx
80106f92:	0f be 02             	movsbl (%edx),%eax
80106f95:	50                   	push   %eax
80106f96:	53                   	push   %ebx
80106f97:	56                   	push   %esi
80106f98:	ff 75 d0             	pushl  -0x30(%ebp)
80106f9b:	ff 75 d4             	pushl  -0x2c(%ebp)
80106f9e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80106fa1:	ff d2                	call   *%edx
        ap++;
80106fa3:	83 45 10 04          	addl   $0x4,0x10(%ebp)
80106fa7:	83 c4 20             	add    $0x20,%esp
        putcFunction(fd, outbuffer, length, outindex++, *ap);
80106faa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
80106fad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106fb4:	e9 4c fe ff ff       	jmp    80106e05 <s_printf+0x49>
        putcFunction(fd, outbuffer, length, outindex++, c);
80106fb9:	8d 43 01             	lea    0x1(%ebx),%eax
80106fbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106fbf:	83 ec 0c             	sub    $0xc,%esp
80106fc2:	ff 75 dc             	pushl  -0x24(%ebp)
80106fc5:	53                   	push   %ebx
80106fc6:	56                   	push   %esi
80106fc7:	ff 75 d0             	pushl  -0x30(%ebp)
80106fca:	ff 75 d4             	pushl  -0x2c(%ebp)
80106fcd:	8b 55 d8             	mov    -0x28(%ebp),%edx
80106fd0:	ff d2                	call   *%edx
80106fd2:	83 c4 20             	add    $0x20,%esp
80106fd5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
80106fd8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106fdf:	e9 21 fe ff ff       	jmp    80106e05 <s_printf+0x49>
  return s_min(length, outindex);
80106fe4:	89 da                	mov    %ebx,%edx
80106fe6:	89 f0                	mov    %esi,%eax
80106fe8:	e8 30 fd ff ff       	call   80106d1d <s_min>
}
80106fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ff0:	5b                   	pop    %ebx
80106ff1:	5e                   	pop    %esi
80106ff2:	5f                   	pop    %edi
80106ff3:	5d                   	pop    %ebp
80106ff4:	c3                   	ret    

80106ff5 <snprintf>:
{
80106ff5:	f3 0f 1e fb          	endbr32 
80106ff9:	55                   	push   %ebp
80106ffa:	89 e5                	mov    %esp,%ebp
80106ffc:	56                   	push   %esi
80106ffd:	53                   	push   %ebx
80106ffe:	8b 75 08             	mov    0x8(%ebp),%esi
80107001:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
80107004:	83 ec 04             	sub    $0x4,%esp
80107007:	8d 45 14             	lea    0x14(%ebp),%eax
8010700a:	50                   	push   %eax
8010700b:	ff 75 10             	pushl  0x10(%ebp)
8010700e:	53                   	push   %ebx
8010700f:	89 f1                	mov    %esi,%ecx
80107011:	ba ff ff ff ff       	mov    $0xffffffff,%edx
80107016:	b8 79 6c 10 80       	mov    $0x80106c79,%eax
8010701b:	e8 9c fd ff ff       	call   80106dbc <s_printf>
  if(count < n) {
80107020:	83 c4 10             	add    $0x10,%esp
80107023:	39 c3                	cmp    %eax,%ebx
80107025:	76 04                	jbe    8010702b <snprintf+0x36>
    outbuffer[count] = 0;
80107027:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
}
8010702b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010702e:	5b                   	pop    %ebx
8010702f:	5e                   	pop    %esi
80107030:	5d                   	pop    %ebp
80107031:	c3                   	ret    

80107032 <ticksread>:

int
ticksread(struct inode *ip, char *dst, int n)
{
80107032:	f3 0f 1e fb          	endbr32 
80107036:	55                   	push   %ebp
80107037:	89 e5                	mov    %esp,%ebp
80107039:	83 ec 08             	sub    $0x8,%esp
    static char buf[bufferSize];
    int t = ticks;

    snprintf(buf, bufferSize, "%d\0", t);
8010703c:	ff 35 20 66 11 80    	pushl  0x80116620
80107042:	68 34 7b 10 80       	push   $0x80107b34
80107047:	68 00 02 00 00       	push   $0x200
8010704c:	68 c0 a5 10 80       	push   $0x8010a5c0
80107051:	e8 9f ff ff ff       	call   80106ff5 <snprintf>
    return s_cnputs(dst, n, buf);
80107056:	b9 c0 a5 10 80       	mov    $0x8010a5c0,%ecx
8010705b:	8b 55 10             	mov    0x10(%ebp),%edx
8010705e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107061:	e8 bd fc ff ff       	call   80106d23 <s_cnputs>
}
80107066:	c9                   	leave  
80107067:	c3                   	ret    

80107068 <ticksinit>:

void
ticksinit(void)
{
80107068:	f3 0f 1e fb          	endbr32 
  devsw[TICKS].read = ticksread;
8010706c:	c7 05 80 0b 11 80 32 	movl   $0x80107032,0x80110b80
80107073:	70 10 80 
}
80107076:	c3                   	ret    
