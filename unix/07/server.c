#include <stdlib.h>
#include <stdio.h>
#include <netdb.h>
#include <netinet/in.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/poll.h>
#include <sys/socket.h>
#include <errno.h>
#include <arpa/inet.h>

#define ECHO_PORT 2002
#define MAX_LINE 1024
#define MAX_CLIENTS 200

typedef struct
{
    char *data;
    size_t len;
    size_t cap;
} Buffer;

typedef struct
{
    uint16_t port;
    int timeout;
} Options;

int read_line(int fd, Buffer *buffer);
void nulled_pollfd(struct pollfd *fd);
Options read_opts(int argc, char **argv);

int main(int argc, char *argv[])
{
    int sockfd, newsockfd, clilen;
    struct sockaddr_in serv_addr;
    struct pollfd fds[MAX_CLIENTS] = {0};
    int nfds = 1;

    Options opts = read_opts(argc, argv);
    printf("port %d, timeout %d\n", opts.port, opts.timeout);

    sockfd = socket(AF_INET, SOCK_STREAM, 0);

    if (sockfd < 0)
    {
        perror("ERROR opening socket");
        exit(1);
    }

    bzero((char *)&serv_addr, sizeof(serv_addr));

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(opts.port);

    const int enable = 1;
    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int)) < 0)
    {
        perror("setsockopt(SO_REUSEADDR) failed");
        exit(1);
    }

    /*************************************************************/
    /* Set socket to be nonblocking. All of the sockets for      */
    /* the incoming connections will also be nonblocking since   */
    /* they will inherit that state from the listening socket.   */
    /*************************************************************/
    if (ioctl(sockfd, FIONBIO, (char *)&enable))
    {
        perror("setsockopt() failed");
        close(sockfd);
        exit(1);
    }

    for (int i = 0; i < MAX_CLIENTS; i++)
    {
        nulled_pollfd(&fds[i]);
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

    fds[0].fd = sockfd;
    fds[0].events = POLLIN;

    Buffer buffer = {0};
    int correct_nfds = 0;

    for (;;)
    {
        int res = poll(fds, nfds, opts.timeout);
        if (res < 0)
        {
            perror("ERROR poll failed");
            exit(1);
        }

        if (res == 0)
        {
            puts("timeout occurred, exiting");
            exit(1);
        }

        for (int i = 0; i < nfds; i++)
        {
            if (fds[i].revents == 0)
            {
                continue;
            }

            if (fds[i].revents != POLLIN)
            {
                fprintf(stderr, " Error! revents = %d\n", fds[i].revents);
                exit(1);
            }

            if (fds[i].fd == sockfd)
            {
                struct sockaddr_in cli_addr;
                puts("LOG: listen socket ready");
                int newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, &clilen);

                if (newsockfd < 0)
                {
                    perror("ERROR accept()");
                    continue;
                }

                int inserted = 0;
                for (int j = 1; j < MAX_CLIENTS; j++)
                {
                    if (fds[j].fd == -1)
                    {
                        fds[j].fd = newsockfd;
                        fds[j].events = POLLIN;
                        inserted = j;
                        break;
                    }
                }

                if (!inserted)
                {
                    fprintf(stderr, "client queue is full, client rejected\n");
                    close(newsockfd);
                }
                else
                {
                    if (inserted >= nfds)
                    {
                        nfds++;
                    }

                    puts("LOG: client connected");
                }
                break;
            }

            buffer.len = 0;
            int rc = 0;
            if ((rc = read_line(fds[i].fd, &buffer)) <= 0)
            {
                if (rc < 0)
                {
                    perror("ERROR read_line()");
                }
                nulled_pollfd(&fds[i]);
                puts("LOG: client exited1");
                break;
            }

            if (strcmp(buffer.data, "quit\n") == 0)
            {
                nulled_pollfd(&fds[i]);
                puts("LOG: client exited2");
                break;
            }

            printf("LOG: received from client: %s", buffer.data);
            for (int j = 1; j < nfds; j++)
            {
                if (fds[j].fd == -1)
                {
                    continue;
                }

                if (write(fds[j].fd, buffer.data, buffer.len) < 0)
                {
                    perror("cannot write data to client");
                    nulled_pollfd(&fds[j]);
                    puts("LOG: client exited3");
                }
            }
        }

        int current_size = nfds;
        for (int i = 0; i < nfds; i++)
        {
            if (fds[i].fd == -1)
            {
                continue;
            }

            current_size = i;
        }

        current_size++;
        printf("LOG: current size was %d, become %d\n", nfds, current_size);
        nfds = current_size;
    }
}

Options read_opts(int argc, char **argv)
{
    Options opts;
    opts.timeout = -1;
    opts.port = ECHO_PORT;

    int option;
    while ((option = getopt(argc, argv, "p:w:")) != -1) {
        switch(option) {
            case 'p':
            {
                opts.port = (uint16_t) atoi(optarg);
                break;
            }
            case 'w':
            {
                opts.timeout = atoi(optarg) * 1000;
                break;
            }
            default:
                printf("wrong opt %c\n", option);
                exit(EXIT_FAILURE);
        }
    }

    return opts;
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

int read_line(int fd, Buffer *buffer)
{
    char ch;
    buffer->len = 0;

    for (;;)
    {
        char ch;
        ssize_t size = read(fd, &ch, sizeof(ch));
        if (size <= 0)
        {
            return size;
        }

        append_char(buffer, ch);
        if (ch == '\n')
        {
            return buffer->len;
        }
    }

    return ch;
}

void processing_client(int sock)
{
    Buffer buffer = {0};

    while (read_line(sock, &buffer) != EOF)
    {
        if (strcmp(buffer.data, "quit\n") == 0)
        {
            break;
        }

        if (write(sock, buffer.data, buffer.len) != buffer.len)
        {
            perror("ERROR on write to client");
            break;
        }

        buffer.len = 0;
    }

    if (buffer.data != NULL)
    {
        free(buffer.data);
    }

    return;
}

void nulled_pollfd(struct pollfd *fd)
{
    fd->events = 0;
    fd->fd = -1;
    fd->revents = 0;
}
