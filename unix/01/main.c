#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

struct Word {
    char *data;
    size_t len;
    size_t cap;
};

struct Words {
    struct Word *data;
    size_t len;
    size_t cap;
};

struct Word create_empty_word() {
    struct Word w = {0};
    return w;
}

void append_char(struct Word *w, char ch) {
    if (w->data == NULL) {
        size_t init_capacity = 2;
        w->data = malloc(sizeof(char)*init_capacity);
        w->cap = init_capacity;
    } else if (w->len + 1 >= w->cap){
        w->data = realloc(w->data, w->cap*2);
    }

    if (w->data == NULL) {
        fprintf(stderr, "not enough memory");
        exit(1);
    }

    w->data[w->len] = ch;
    w->len += 1;
    w->data[w->len] = 0;
}

void append_word(struct Words *ww, struct Word w) {
    if (ww->data == NULL) {
        size_t init_capacity = 2;
        ww->data = malloc(sizeof(struct Word)*init_capacity);
        ww->cap = init_capacity;
    } else if (ww->len >= ww->cap){
        ww->data = realloc(ww->data, ww->cap*2);
    }

    if (ww->data == NULL) {
        fprintf(stderr, "not enough memory");
        exit(1);
    }

    ww->data[ww->len] = w;
    ww->len += 1;
}

void print_words(struct Words words) {
    for (int i = 0; i < words.len; i++) {
        printf("\"%s\"\n", words.data[i].data);
    }
}

void free_words(struct Words words) {
    if (words.data == NULL) {
        return;
    }

    for (int i = 0; i < words.len; i++) {
        free(words.data[i].data);
    }

    free(words.data);
}

struct Words read_words() {
    int ch;
    struct Word word = create_empty_word();
    struct Words words = {0};

    for (;;) {
        ch = getchar();

        if (ch == EOF) {
            if (word.data != NULL) {
                append_word(&words, word);
            }
            break;
        } else if (isspace(ch)) {
            if (word.data != NULL) {
                append_word(&words, word);
                word = create_empty_word();
            }
        } else {
            append_char(&word, ch);
        }
    }

    return words;
}

int main() {
    struct Words words = read_words();
    print_words(words);
    free_words(words);
}
