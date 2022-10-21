#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>

static int sig_received = 0;

void sig_handler(int sig) {
    ++sig_received;
}

struct sigaction create_saction(void (*handler) (int)) {
    struct sigaction psa;
    sigemptyset(&(psa.sa_mask));
    psa.sa_flags = 0;
    psa.sa_handler = handler;
    return psa;
}

void wait_siganl() {
    while(sig_received == 0) pause();
    --sig_received;
}

int main(void)
{
    struct sigaction alarm = create_saction(sig_handler);
    sigaction(SIGUSR1, &alarm, NULL);

    int pid1 = fork();
    if (pid1 > 0) {
        // parent
        int pid2 = fork();
        if (pid2 > 0) {
            // parent
            for (;;) {
                kill(pid1, SIGUSR1);
                wait_siganl();
                kill(pid2, SIGUSR1);
                wait_siganl();
            }
        } else {
            // child - pid2   
            const char *data = "1 ";
            size_t len = strlen(data);

            for (;;) {
                wait_siganl();
                write(1, data, len);
                kill(getppid(), SIGUSR1);
            }
        }
    } else {
        // child - pid1
        const char *data = "0 ";
        size_t len = strlen(data);

        for (;;) {
            wait_siganl();
            write(1, data, len);
            kill(getppid(), SIGUSR1);
        }
    }

    return 0;
}