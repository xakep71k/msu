#include <stdlib.h>
#include <stdio.h>
#include <netdb.h>
#include <netinet/in.h>
#include <string.h>
#include <unistd.h>

#define ECHO_PORT (2002)
#define MAX_LINE (1024)

void doprocessing(int sock);

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

        pid_t pid = fork();

        if (pid < 0)
        {
            perror("ERROR on fork");
            exit(1);
        }

        if (pid == 0)
        {
            close(sockfd);
            doprocessing(newsockfd);
            puts("client exited");
            exit(0);
        }
        else
        {
            close(newsockfd);
        }
    }
}

void doprocessing(int sock)
{
    char buffer[MAX_LINE] = {0};

    for (;;)
    {
        ssize_t size = read(sock, buffer, MAX_LINE - 1);
        if (size < 0)
        {
            perror("ERROR on read from client");
            return;
        }

        if (strcmp(buffer, "quit\n") == 0)
        {
            return;
        }

        if (write(sock, buffer, size) < 0)
        {
            perror("ERROR on write to client");
            return;
        }
    }
}