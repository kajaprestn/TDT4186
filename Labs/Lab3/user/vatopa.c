#include "kernel/types.h"
#include "user.h"
#include "stddef.h"

int main(int argc, char *argv[]) {
    if (argc != 3 && argc != 2) {
        printf("Usage: vatopa virtual_address [pid]\n");
        exit(1);
    }

    uint64 va = atoi(argv[1]);
    uint64 pa = 0;
    int pid = (argc == 3) ? atoi(argv[2]) : getpid(); 

    pa = va2pa(va, pid);

    if (pa == (uint64)-1) {
        printf("0x%x\n", va);
    } else if (pa == (uint64)-2) {
        printf("No process found with PID %d\n", pid);
    } else if (pa == (uint64)-3) {
        printf("0x0\n", va);
    } else {
        printf("0x%x\n", pa);
    }

    exit(0);
}
