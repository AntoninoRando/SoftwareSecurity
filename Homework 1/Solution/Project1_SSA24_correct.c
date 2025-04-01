#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

void func1(const char *src) {
    size_t len = strlen(src);
    char *dst = malloc(len + 1);
    if (dst) {
        strncpy(dst, src, len);
        dst[len] = '\0';
        free(dst);
    }
}

void func2(int fd) {
    char *buf;
    size_t len;
    if (read(fd, &len, sizeof(len)) != sizeof(len) || len > 1024)
        return;
    buf = malloc(len + 1);
    if (buf) {
        if (read(fd, buf, len) == len) {
            buf[len] = '\0';
        }
        free(buf);
    }
}

void func3() {
    char buffer[1024];
    printf("Please enter your user id:");
    if (fgets(buffer, sizeof(buffer), stdin)) {
        if (!isalpha(buffer[0])) {
            char errormsg[1044];
            snprintf(errormsg, sizeof(errormsg), "%s is not a valid ID", buffer);
        }
    }
}

void func4(const char *foo) {
    char *buffer = (char *)malloc(11);
    if (buffer) {
        strncpy(buffer, foo, 10);
        buffer[10] = '\0';
        free(buffer);
    }
}

int main() {
    func4("safe_input");
    func3();
    return 0;
}