#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct {
    char *data;
    size_t len;
    size_t cap;
} Buffer;

void strings(Buffer *buffer, FILE *file);

int main(int argc, char **argv) {
    Buffer buffer;

    for (int i = 1; argv[i]; i++) {
        const char *filename = argv[1];
        FILE *file = fopen(filename, "r");

        if (file == NULL) {
            perror(filename);
            continue;
        }

        strings(&buffer, file);

        fclose(file);
    }

    if (argc == 1) {
        strings(&buffer, stdin);
    }

    return EXIT_SUCCESS;
}

int read_line(FILE *file, Buffer *buffer);

void strings(Buffer *buffer, FILE *file) {
    for (;;) {
        int ch = read_line(file, buffer);
        if (buffer->len >= 4) {
            puts(buffer->data);
        }

        if (ch == EOF){
            break;
        }
    }
}

void append_char(Buffer *buffer, char ch);

int read_line(FILE *file, Buffer *buffer) {
    int ch;
    buffer->len = 0;

    while ((ch = getc(file)) != EOF) {
        if (ch == '\n') {
            break;
        }

        if (ch > 32 && ch < 128) {
            append_char(buffer, ch);
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