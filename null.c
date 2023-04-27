#include "types.h"
#include "defs.h"
#include "param.h"
#include "traps.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h"


int
nullread(struct inode *ip, char *dst, int n)
{
    return n;
}

int
nullwrite(struct inode *ip, char *dst, int n)
{
    return n;
}

void
nullinit(void)
{
  devsw[NULL].read = nullread;
  devsw[NULL].write = nullwrite;

}