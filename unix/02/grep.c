#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef struct {
    char *data;
    size_t len;
    size_t cap;
} Buffer;

void append_char(Buffer *buffer, char ch);
int read_line(FILE *file, Buffer *buffer);
void grep(FILE *file, Buffer *buffer, const char *filename, const char *find_substr, int is_inverse_match);
void usage(const char*);
int is_inverse_match_specified(int argc, char *const *argv);
int is_opt(const char *supposed_opt);
int read_pattern(char *const *argv);

int main(int argc,  char *const *argv) {
    int option;

    const int is_inverse_match = is_inverse_match_specified(argc, argv);
    const int print_file_name = is_inverse_match ? argc > 4 : argc > 3;
    int pattern_index = read_pattern(argv);
    int count_files = 0;
    Buffer buffer = {0};

    if (pattern_index == -1) {
        usage(argv[0]);
    }

    const char *pattern = argv[pattern_index];

    for (int i = pattern_index + 1; argv[i] != NULL; i++) {
        const char *filename = argv[i];

        if (is_opt(filename)) {
            continue;
        }

        count_files++;
        FILE * file = fopen(filename, "r");

        if (file == NULL) {
            perror(filename);
            continue;
        }

        grep(
            file,
            &buffer,
            print_file_name ? filename : NULL,
            pattern,
            is_inverse_match);

        fclose(file);
    }

    if (count_files == 0) {
        grep(stdin, &buffer, NULL, pattern, is_inverse_match);
    }

    if (buffer.len > 0) {
        free(buffer.data);
    }

    return 0;
}

void grep(FILE *file, Buffer *buffer, const char *filename, const char *pattern, int is_inverse_match) {
    for(;;) {
        const int last_char = read_line(file, buffer);

        if (buffer->len > 0) {
            const int print_line = (is_inverse_match && strstr(buffer->data, pattern) == NULL) ||
                (!is_inverse_match && strstr(buffer->data, pattern) != NULL);

            if (print_line) {
                if (filename != NULL) {
                    printf("%s: ", filename);
                }
                printf("%s", buffer->data);
            }
        }

        if (last_char == EOF) {
            break;
        }
    }
}

int read_line(FILE *file, Buffer *buffer) {
    int ch;
    buffer->len = 0;

    while ((ch = getc(file)) != EOF) {
        append_char(buffer, ch);
        if (ch == '\n') {
            break;
        }
    }

    return ch;
}

void append_char(Buffer *buffer, char ch) {
    if (buffer->data == NULL) {
        size_t init_capacity = 2;
        buffer->data = malloc(sizeof(char)*init_capacity);
        buffer->cap = init_capacity;
        buffer->len = 0;
    } else if (buffer->len + 1 >= buffer->cap){
        buffer->cap *= 2;
        buffer->data = realloc(buffer->data, sizeof(char)*buffer->cap);
    }

    if (buffer->data == NULL) {
        fprintf(stderr, "not enough memory");
        exit(EXIT_FAILURE);
    }

    buffer->data[buffer->len] = ch;
    buffer->len += 1;
    buffer->data[buffer->len] = 0;
}

void usage(const char* current_filename) {
    printf("usage: %s <pattern> [-v] [file...]", current_filename);
    exit(EXIT_FAILURE);
}

int is_inverse_match_specified(int argc, char *const *argv) {
    int option;
    int count_opts = 0;
    while ((option = getopt(argc, argv, "v")) != -1) {
        switch(option) {
            case 'v': count_opts++;
            default:
                exit(EXIT_FAILURE);
        }
    }

    if (count_opts > 1) {
        fprintf(stderr, "-v repeated\n");
        exit(EXIT_FAILURE);
    }

    return count_opts;
}

int is_opt(const char *supposed_opt) {
    return strcmp("-v", supposed_opt) == 0;
}

int read_pattern(char *const *argv) {
    for (int i = 1; argv[i]; i++) {
        if (!is_opt(argv[i])) {
            return i;
        } 
    }

    return -1; 
}
