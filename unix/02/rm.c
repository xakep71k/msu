#include <stdio.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

void rm(const char *filename);
char *join_path(const char *s1, const char *s2);

int main(int argc, char **argv) {
    for (int i = 1; argv[i] != NULL; i++) {
        if (strlen(argv[i]) == 0) {
            fprintf(stderr, "path %d is empty\n", i);
            continue;
        }
        rm(argv[i]);
    }
    return 0;
}

void rm(const char *filename) {
    struct stat statbuf;
    if (stat(filename, &statbuf) == -1) {
        if (ENOENT == errno) {
            return;
        }
        perror(filename);
        return;
    }

    if ((statbuf.st_mode & S_IFMT) == S_IFDIR) {
        DIR *folder = opendir(filename);
        if(folder == NULL) {
            perror(filename);
            return;
        }

        struct dirent *dir;
        while ((dir = readdir(folder)) != NULL) {
            if (strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0) {
                continue;
            }

            char *newpath = join_path(filename, dir->d_name);

            if (dir->d_type == DT_DIR) {
                rm(newpath);
            } else {
                if (unlink(newpath) == -1) {
                   perror(filename);
                }
            }


            free(newpath);
        }

        closedir(folder);

        if(rmdir(filename) == -1) {
            perror(filename);
        }

        return;
    } 

    if (unlink(filename) == -1) {
        perror(filename);
    }
}

char *join_str(const char *s1, const char *s2) {
    char *s = malloc(sizeof(char)*(strlen(s1)+strlen(s1)+1));
    return strcat(strcpy(s, s1), s2);
}

char *join_path(const char *s1, const char *s2) {
    const int has_slash = s1[strlen(s1)-1] == '/';
    char *alloc_s = join_str(s1, "/");
    const char *s = has_slash ? s1 : alloc_s;
    char *path = join_str(s, s2);
    free(alloc_s);
    return path;
}
