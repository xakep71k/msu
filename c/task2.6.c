#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef enum { ADD, DEL, FIND, STOP } Action;
typedef struct {
    unsigned int value;
    Action action;
}Do;

struct Tree_;
typedef struct Tree_ {
    unsigned int value;
    struct Tree_ *left, *right;
} Tree;

void error(const char *msg);
Do nextAction();
Tree *add(Tree *tree, unsigned int value);
Tree *del(Tree *tree, unsigned int value);
Tree *find(Tree *tree, unsigned int value);

int main() {
    Tree *tree = NULL, *found;
    Do action;
    while((action = nextAction()).action != STOP) {
        switch(action.action) {
            case DEL:
                tree = del(tree, action.value);
                break;
            case ADD:
                tree = add(tree, action.value);
                break;
            case FIND:
                found = find(tree, action.value);
                printf("%u ", action.value);
                if(found != NULL) {
                    puts("yes");
                } else {
                    puts("no");
                }
                break;
            default:
                error("BUG: action not found");
        }
    }
    return EXIT_SUCCESS;
}

Tree *add(Tree *tree, unsigned int value) {
    if(tree == NULL) {
        tree = calloc(1, sizeof(Tree));
        tree->value = value;
        return tree;
    }

    if(value > tree->value) {
        tree->right = add(tree->right, value);
    } else if(value < tree->value) {
        tree->left = add(tree->left, value);
    }

    return tree;
}

Tree *find2Del(Tree *tree) {
    Tree *replace;

    if(tree == NULL) {
        return tree;
    }

    if(tree->left == NULL) {
        return tree;
    }

    if(tree->left->left == NULL) {
        replace = tree->left;
        tree->left = NULL;
        return replace;
    }

    return find2Del(tree->left);
}

Tree *del(Tree *tree, unsigned int value) {
    Tree *replace;

    if(tree == NULL) {
        return tree;
    }

    if(value > tree->value) {
        tree->right = del(tree->right, value);
    } else if(value < tree->value) {
        tree->left = del(tree->left, value);
    } else if(value == tree->value) {
        replace = find2Del(tree->right);

        if(replace != NULL) {
            if(tree->right != replace) {
                replace->right = tree->right;
            }

            replace->left = tree->left;
        }
        free(tree);
        tree = replace;
    }

    return tree;
}

Tree *find(Tree *tree, unsigned int value) {
    if(tree == NULL) {
        return tree;
    }

    if(value > tree->value) {
        return find(tree->right, value);
    } else if(value < tree->value) {
        return find(tree->left, value);
    }
    return tree;
}

Do createDo(const char *line) {
    int i;
    Do action;

    switch(line[0]) {
        case '?':
            action.action = FIND;
            break;
        case '+':
            action.action = ADD;
            break;
        case '-':
            action.action = DEL;
            break;
        default:
            error("not supported action");
    }

    line++;
    for(i = 0; line[i]; ++i) {
        if(!isdigit(line[i]) && line[i] != '\n' && line[i] != '\r') {
            error("wrong number");
        }
    }
    action.value = strtoul(line, 0L, 10);
    return action;
}

Do nextAction() {
    static char buf[4096];
    const size_t bufSize = sizeof(buf) * sizeof(char);
    size_t len;
    char *line;
    Do action;

    line = fgets(buf, bufSize, stdin);
    if(line == NULL) {
        action.action = STOP;
    } else {
        len = strlen(line);
        if(len == 1) {
            error("line empty");
        }
        if(len == bufSize - 1) {
            error("line too long");
        }
        action = createDo(line);
    }
    return action;
}

void error(const char* msg) {
    fprintf(stderr, "%s\n", msg);
    exit(EXIT_FAILURE);
}
