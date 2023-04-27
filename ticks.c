#include "types.h"
#include "defs.h"
#include "param.h"
#include "traps.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h"

#define bufferSize (512)


typedef void (*putFunction_t)(int fd, char *outbuffer, uint length, uint index, char c);

void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
  if(index < length)
  {
    outbuffer[index] = c;
  }
}

static uint 
s_getReverse(char *outbuf, uint length, int x, int base, int sgn)
{
  static char digs[] = "0123456789ABCDEF";
  int i, n;
  uint a;

  n = 0;
  if(sgn && x < 0){
    n = 1;
    a = -x;
  } else {
    a = x;
  }

  i = 0;
  while(i + 1 < length && x != 0) {
    outbuf[i++] = digs[a % base];
    a /= base;
  }

  if(0 == x && i + 1 < length) {
    outbuf[i++] = digs[0];   
  }

  if(n && i < length) {
    outbuf[i++] = '-';
  }

  return i;
}

static uint 
s_printint(putFunction_t putcFunction, 
  int fd, char *outbuf, uint length, int xx, int base, int sgn)
{
  static const uint localBufferLength = 16; 
  char localBuffer[localBufferLength];

  uint result = 
  s_getReverse(localBuffer, localBufferLength, xx, base, sgn);


  int j = 0;
  int i = result;
  while(--i >= 0 && j < length) 
  {
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
    j++;
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
}

static 
int s_printf(putFunction_t putcFunction, int fd, char *outbuffer, int n, const char *fmt, uint* ap)
{
  char *s;
  int c, i, state;
  uint outindex = 0;
  const int length = n -1;

  state = 0;
  for(i = 0; fmt[i] && outindex < length; i++) {
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%') {
        state = '%';
      } else {
        putcFunction(fd, outbuffer, length, outindex++, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
          putcFunction(fd, outbuffer, length, outindex++, *s);
          s++;
        }
      } else if(c == 'c'){
        putcFunction(fd, outbuffer, length, outindex++, *ap);
        ap++;
      } else if(c == '%'){
        putcFunction(fd, outbuffer, length, outindex++, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putcFunction(fd, outbuffer, length, outindex++, '%');
        putcFunction(fd, outbuffer, length, outindex++, c);
      }
      state = 0;
    }
  }
  
  return s_min(length, outindex);
}


int snprintf(char *outbuffer, int n, const char *fmt, ...)
{
  uint* ap = (uint*)(void*)&fmt + 1;
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
  if(count < n) {
    outbuffer[count] = 0;
  } 

  return count;
}

static int s_cnputs(char *outbuffer, int n, const char* string)
{
    int itr = 0;

    for(; itr < n && '\0' != string[itr]; ++itr)  {
        outbuffer[itr] = string[itr];
    }
    if(itr < n) {
        outbuffer[itr] = '\0';
    }
    itr++;
    return itr;
}

int
ticksread(struct inode *ip, char *dst, int n)
{
    static char buf[bufferSize];
    int t = ticks;

    snprintf(buf, bufferSize, "%d\0", t);
    return s_cnputs(dst, n, buf);
}

void
ticksinit(void)
{
  devsw[TICKS].read = ticksread;
}

