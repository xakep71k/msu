#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <pwd.h>

void usage(const char *program_name);
void find(const char *in_directory, const char *find_name, uid_t uid);

int main(int argc, char **argv) {
    if (argc != 4) {
        usage(argv[0]);
    }
    const char *in_directory = argv[1];
    struct stat statbuf;
    
    if (stat(in_directory, &statbuf) == -1) {
        perror(in_directory);
        return EXIT_FAILURE;
    }

    if ((statbuf.st_mode & S_IFMT) != S_IFDIR) {
        usage(argv[0]);
    }

    const char *find_name = argv[2];
    const char *user = argv[3];

    struct passwd *pw = getpwnam(user);

    if (pw == NULL) {
        fprintf(stderr, "%s: user not found", user);
        return EXIT_FAILURE;
    }

    find(in_directory, find_name, pw->pw_uid);

    return EXIT_SUCCESS;
}

char *join_path(const char *s1, const char *s2);

void find(const char *in_directory, const char *find_name, uid_t uid) {
    DIR *folder = opendir(in_directory);
    if(folder == NULL) {
        perror(in_directory);
        return;
    }

    struct dirent *dir;
    while ((dir = readdir(folder)) != NULL) {
        char *newpath = join_path(in_directory, dir->d_name);

        if (strcmp(find_name, dir->d_name) == 0) {
            struct stat statbuf;
            if (stat(newpath, &statbuf) == -1) {
                perror(newpath);
            } else if (statbuf.st_uid == uid){
                puts(newpath);
            }
        }

        if (strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0) {
            continue;
        }

        if (dir->d_type == DT_DIR) {
            find(newpath, find_name, uid);
        }

        free(newpath);
    }
} 

void usage(const char *program_name) {
    printf("usage: %s <directory> <filename> <user>\n", program_name);
    exit(EXIT_FAILURE);
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