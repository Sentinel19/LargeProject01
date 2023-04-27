#include "types.h"
#include "defs.h"
#include "param.h"
#include "traps.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h"


static int s_cnputs(char *outbuffer, int n, const char* string)
{
    int count = 0;

    for(; count < n && '\0' != string[count]; ++count)  {
        outbuffer[count] = string[count];
    }
    if(count < n) {
        outbuffer[count] = '\0';
    }
    return count;
}

int
zeroread(struct inode *ip, char *dst, int n)
{
    return s_cnputs(dst, n, "0");
}

void
zeroinit(void)
{
  devsw[ZERO].read = zeroread;
}