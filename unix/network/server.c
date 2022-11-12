#include <stdlib.h>
#include <stdio.h>
#include <netdb.h>
#include <netinet/in.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#define ECHO_PORT (2002)
#define MAX_LINE (1024)

void *thread_processing(void *);

typedef struct
{
    char *data;
    size_t len;
    size_t cap;
} Buffer;

int main(int argc, char *argv[])
{
    int sockfd, newsockfd, clilen;
    struct sockaddr_in serv_addr, cli_addr;

    sockfd = socket(AF_INET, SOCK_STREAM, 0);

    if (sockfd < 0)
    {
        perror("ERROR opening socket");
        exit(1);
    }

    bzero((char *)&serv_addr, sizeof(serv_addr));

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(ECHO_PORT);

    const int enable = 1;
    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int)) < 0)
    {
        perror("setsockopt(SO_REUSEADDR) failed");
        exit(1);
    }

    if (bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    {
        perror("ERROR on binding");
        exit(1);
    }

    if (listen(sockfd, 5) < 0)
    {
        perror("ERROR listing socket");
        exit(1);
    }

    pthread_t thread_id;

    clilen = sizeof(cli_addr);

    while (1)
    {
        newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, &clilen);
        puts("client connected");

        if (newsockfd < 0)
        {
            perror("ERROR on accept");
            continue;
        }

        if (pthread_create(&thread_id, NULL, thread_processing, (void *)&newsockfd) < 0)
        {
            perror("could not create thread");
            return 1;
        }
    }
}

void append_char(Buffer *buffer, char ch)
{
    if (buffer->data == NULL)
    {
        size_t init_capacity = 2;
        buffer->data = malloc(sizeof(char) * init_capacity);
        buffer->cap = init_capacity;
        buffer->len = 0;
    }
    else if (buffer->len + 1 >= buffer->cap)
    {
        buffer->cap *= 2;
        buffer->data = realloc(buffer->data, sizeof(char) * buffer->cap);
    }

    if (buffer->data == NULL)
    {
        fprintf(stderr, "not enough memory");
        exit(EXIT_FAILURE);
    }

    buffer->data[buffer->len] = ch;
    buffer->len += 1;
    buffer->data[buffer->len] = 0;
}

int read_line(FILE *file, Buffer *buffer)
{
    int ch;
    buffer->len = 0;

    while ((ch = getc(file)) != EOF)
    {
        append_char(buffer, ch);
        if (ch == '\n')
        {
            break;
        }
    }

    return ch;
}

void processing_client(FILE *fp)
{
    Buffer buffer = {0};
    while (read_line(fp, &buffer) != EOF)
    {
        if (strcmp(buffer.data, "quit\n") == 0)
        {
            break;
        }

        if (fwrite(buffer.data, sizeof(buffer.data), buffer.len, fp) != buffer.len)
        {
            perror("ERROR on write to client");
            break;
        }

        fflush(fp);

        buffer.len = 0;
    }

    if (buffer.data != NULL)
    {
        free(buffer.data);
    }

    return;
}

void *thread_processing(void *arg)
{
    int sock = *(int *)arg;
    FILE *fp = fdopen(sock, "r+");
    if (fp != NULL)
    {
        processing_client(fp);
        fclose(fp);
    }
    else
    {
        perror("fdopen failed");
    }
    puts("client exited");
}