#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

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

struct Words read_words();
void print_words(struct Words words);
void free_words(struct Words words);
int compare_words(const void* a, const void* b);

int main() {
    struct Words words = read_words();
    qsort(words.data, words.len, sizeof(struct Word), compare_words);
    print_words(words);
    free_words(words);
}

struct Word create_empty_word();
void append_char(struct Word *w, char ch);
void append_word(struct Words *ww, struct Word w);
int is_word_empty(struct Word word);

struct Words read_words() {
    int ch;
    struct Word word = create_empty_word();
    struct Words words = {0};

    for (;;) {
        ch = getchar();

        if (ch == EOF) {
            if (!is_word_empty(word)) {
                append_word(&words, word);
            }
            break;
        } else if (isspace(ch)) {
            if (!is_word_empty(word)) {
                append_word(&words, word);
                word = create_empty_word();
            }
        } else if (ch == ';') {
            if (!is_word_empty(word)) {
                append_word(&words, word);
                word = create_empty_word();
            }
            append_char(&word, ch);
            append_word(&words, word);
            word = create_empty_word();
        } else if (ch == '|' || ch == '&'){
            if (!is_word_empty(word)) {
                append_word(&words, word);
                word = create_empty_word();
            }

            const int prev_ch = ch;
            append_char(&word, ch);

            ch = getchar();
            if (prev_ch == ch) {
                append_char(&word, prev_ch);
            } else {
                ungetc(ch, stdin);
            }

            append_word(&words, word);
            word = create_empty_word();
        } else if (ch == '"' || ch == '\'') {
            const int quot = ch;
            while ((ch = getchar()) != EOF) {
                if (quot == ch) {
                    break;
                }
                append_char(&word, ch);
            }

            if (ch != quot) {
                fprintf(stderr, "%c not closed", quot);
                exit(1);
            }
        } else {
            append_char(&word, ch);
        }
    }

    return words;
}

int is_word_empty(struct Word word) {
    return word.data == NULL;
}

struct Word create_empty_word() {
    struct Word w = {0};
    return w;
}

void append_char(struct Word *w, char ch) {
    if (w->data == NULL) {
        size_t init_capacity = 2;
        w->data = malloc(sizeof(char)*init_capacity);
        w->cap = init_capacity;
        w->len = 0;
    } else if (w->len + 1 >= w->cap){
        w->cap *= 2;
        w->data = realloc(w->data, sizeof(char)*w->cap);
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
        size_t init_capacity = 1;
        ww->data = malloc(sizeof(struct Word)*init_capacity);
        ww->cap = init_capacity;
        ww->len = 0;
    } else if (ww->len >= ww->cap){
        ww->cap *= 2;
        ww->data = realloc(ww->data, sizeof(struct Word)*ww->cap);
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

int compare_words(const void* a, const void* b) {
    const struct Word* word1 = a;
    const struct Word* word2 = b;
    return strcmp(word1->data, word2->data);
}
