
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINES 10

typedef struct {
    char *data;
    size_t len;
    size_t cap;
} Buffer;

void tail(FILE *file);
int read_line(FILE *file, Buffer *buffer);


int main(int argc, char **argv){
    for (int i = 1; argv[i]; i++) {
        const char *filename = argv[1];
        FILE *file = fopen(filename, "r");

        if (file == NULL) {
            perror(filename);
            continue;
        }

        tail(file);
        fclose(file);
    }

    if (argc == 1) {
        tail(stdin);
    }
}

void tail(FILE *file) {
    Buffer buffers[MAX_LINES] = {0};
    size_t count = 0;
    for (int i = 0 ; 1; i++) {
        const int index_line = count % MAX_LINES;
        Buffer *buffer = &buffers[index_line];
        size_t old_len = buffer->len;

        if (read_line(file, buffer) == EOF) {
            if (buffer->len > 0) {
                count++;
            } else {
                buffer->len = old_len;
            }
            break;
        }
        count++;
    }

    for (int i = count; i < count + MAX_LINES; i++) {
        const int index_line = i % MAX_LINES;
        const Buffer *buffer = &buffers[index_line];

        if (buffer->len > 0) {
            printf("%s", buffer->data);
        }
    }
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

int read_line(FILE *file, Buffer *buffer) {
    int ch;
    const size_t old_len =  buffer->len;
    buffer->len = 0;

    while ((ch = getc(file)) != EOF) {
        append_char(buffer, ch);
        if (ch == '\n') {
            break;
        }
    }

    return ch;
}