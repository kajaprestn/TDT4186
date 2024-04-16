#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <dirent.h>
#include <errno.h>
#include <sys/stat.h>

int main(int argc, char *argv[])
{
    char *path;
    if (argc > 1)
    {
        path = argv[1];
    }
    else
    {
        char buf[1024]; // there are better ways to find that constant...
        path = buf;
        getcwd(path, 1024); // this call could fail - in practice we should check for success
    }

    if (access(path, F_OK) == -1)
    {
        fprintf(stderr, "Path %s does not exist\n", path);
        return -1;
    }

    if (access(path, R_OK) == -1)
    {
        fprintf(stderr, "You don't have access to %s\n", path);
        return -1;
    }

    struct stat stats;
    stat(path, &stats);

    if (!S_ISDIR(stats.st_mode))
    {
        fprintf(stderr, "The path does not point to a directory but to a file. Cannot handle files.\n");
        return -1;
    }

    DIR *d;
    struct dirent *dir;
    d = opendir(path);

    while ((dir = readdir(d)) != NULL)
    {
        printf("%s\n", dir->d_name);
    }

    closedir(d);

    return 0;
}
