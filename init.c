// init: The initial user-level program

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

char *argv[] = { "sh", 0 };

int
main(void)
{
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  dup(0);  // stderr

  mkdir("dev");

  if(open("dev/hello", O_RDONLY) < 0){
    mknod("dev/hello", 7, 1);
  }

  if(open("dev/zero", O_RDONLY) < 0){
    mknod("dev/zero", 2, 1);
    open("dev/zero", O_RDONLY);
  }

  if(open("dev/null", O_WRONLY) < 0){
    mknod("dev/null", 3, 1);
    open("dev/null", O_WRONLY);
  }

  if(open("dev/ticks", O_RDONLY) < 0){
    mknod("dev/ticks", 4, 1);
    open("dev/ticks", O_RDONLY);
  }

  for(;;){
    printf(1, "init: starting sh\n");
    pid = fork();
    if(pid < 0){
      printf(1, "init: fork failed\n");
      exit();
    }
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  }
}
