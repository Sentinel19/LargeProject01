#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
    int fd = open("dev/zero", O_RDONLY);
    if(0 > fd) {
        printf(2, "Error: Cannot open dzero\n");
    }
    else {
        char buffer[512] = {'\0'};
        read(fd, buffer, 512);
        printf(1, "Read <%s>\n", buffer);
        close(fd);
        fd = -1;
    }
    exit();
}