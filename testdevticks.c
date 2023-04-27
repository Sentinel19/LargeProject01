#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
    int fd = open("dev/ticks", O_RDONLY);
    if(0 > fd) {
        printf(2, "Error: Cannot open dticks\n");
    }
    else {
        char buffer[512] = {'\0'};
        int count = read(fd, buffer, 512);
        read(fd, buffer, 512);
        printf(1, "Read <%s>\n", buffer);
        printf(1, "Characters: %d\n", count);

        close(fd);
        fd = -1;
    }
    exit();
}