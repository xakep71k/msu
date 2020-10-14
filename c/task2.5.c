/*
 * удалить слова совпадающие с последним словом
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string.h>

#define STR_INDIR(x) #x
#define STR(x) STR_INDIR(x)
#define MAX_BUF_SIZE 4096

struct StrList_;

typedef struct StrList_ {
    char *value;
    struct StrList_ *next;
} StrList;

StrList *createList();
StrList *deleteItemsEqual2Latest(StrList *list);
void printStrList(StrList *list);

int main() {
    StrList *list = createList();
    if(list != NULL) {
        list = deleteItemsEqual2Latest(list);
        printStrList(list);
    }
    return EXIT_SUCCESS;
}

void error(const char* msg) {
    fprintf(stderr, "%s\n", msg);
    exit(EXIT_FAILURE);
}

StrList *createItem(const char* str) {
    StrList *list;

    list = (StrList*)calloc(1, sizeof(StrList));
    if(list == NULL) {
        error("out of memory");
    }

    list->value = strdup(str);
    if(list->value == NULL) {
        error("out of memory");
    }

    return list;
}

StrList *createList(FILE* stream) {
    static char buf[MAX_BUF_SIZE];
    int len;
    StrList *head = NULL, *next = NULL;

    while(EOF != scanf("%"STR(MAX_BUF_SIZE)"s%n", buf, &len)) {
        if(len == MAX_BUF_SIZE) {
            error("cannot read so big string");
        }
        if(head == NULL) {
            head = createItem(buf);
            next = head;
        } else {
            next->next = createItem(buf);
            next = next->next;
        }
    }
    return head;
}

void printStrList(StrList *list) {
    while(list) {
        puts(list->value);
        list = list->next;
    }
}

StrList *findLatestItem(StrList *list) {
    if(list) {
        while(list->next) {
            list = list->next;
        }
    }
    return list;
}

StrList *freeItem(StrList *list) {
    StrList *next;
    if(list) {
        next = list->next;
        if(list->value) {
            free(list->value);
        }
        free(list);
        list = next;
    }
    return list;
}

StrList *deleteItemsEqual2Latest(StrList *list) {
    StrList *latest, *newList = NULL, *next = NULL;

    if(list == NULL) {
        return NULL;
    }

    latest = findLatestItem(list);
    while(list != latest) {
        if(strcmp(list->value, latest->value) == 0) {
            list = freeItem(list);
        } else {
            if(newList == NULL) {
                newList = list;
                next = newList;
            } else {
                next->next = list;
                next = next->next;
            }
            list = list->next;
        }
    }

    if(newList == NULL) {
        newList = latest;
    } else {
        next->next = latest;
    }

    return newList;
}
