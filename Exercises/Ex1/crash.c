#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

typedef struct
{
    int x;
    int y;
    int z;
} Point;

Point *init(int elems)
{
    int size = elems * sizeof(Point);

    // FIXED: Using anonymous memory mapping. The /dev/zero version might work on some
    // systems, but is not the clean way.
    // allocating memory using syscalls directly
    Point *array = mmap(0, size, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);

    if ((Point *)-1 == array)
    {
        printf("Could not map memory: %s\n", strerror(errno));
        return NULL;
    }

    // FIXED: Not touching any unallocated memory
    for (int i = 0; i < size; ++i)
    {
        array[i].x = i;
        array[i].y = -i;
        array[i].z = i * i;
    }

    return array;
}

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        fprintf(stderr, "Usage: crash hello [NUM ELEMS]\n");
        return 1; // FIXED: If we detect an error that we cannot fix we should
                  // terminate the program. In the main function we can
                  // just return a non-zero value to indicate that the
                  // program did not complete successfully.
    }

    // FIXED: strcmp returns 0 if they match - we only want
    // to jump into the condition if they do not match,
    // so we need to remove the inversion here
    if (strcmp(argv[1], "hello"))
    {
        fprintf(stderr, "Second argument must be hello\n");
        return 1; // FIXED: Early return on error (see above)
    }

    char *p;
    errno = 0;
    int elems = strtol(argv[2], &p, 10);
    // FIXED: We need to check if the conversion was successful or not - otherwise elems will be 0
    if (*p != '\0' || errno != 0)
    {
        printf("The second argument needs to be a number\n");
        return 1;
    }

    Point *points = init(elems);
    // FIXED: we cannot directly cast the
    // integer in the second position
    // as it is passed as a string
    // We need to use the strol function
    // used on line 38 to parse the string.
    for (int i = 0; i < elems; i++)
    {
        printf("Point(%d, %d, %d)\n", points[i].x, points[i].y, points[i].z);
    }
    return 0;
}
