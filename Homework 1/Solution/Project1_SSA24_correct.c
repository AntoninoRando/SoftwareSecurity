#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <ctype.h>
#include <cstdio>

void func1(const char *src) {
    if (!src) return; 

    // Limit in case of non null-terminated src
    size_t n = strnlen(src, 1024);
    char *dst = (char *)malloc(n + 1);

    if (!dst) return;
    snprintf(dst, n + 1, "%s", src);
    free(dst);
}

void func2(int fd) {
    size_t len;
    ssize_t ret = read(fd, &len, sizeof(len));
    if (ret != sizeof(len)) return;
    if (len == 0 || len > 1024)  return;
    
    char *buf = (char *)malloc(len + 1);
    if (!buf) return;

    ret = read(fd, buf, len);
    if (ret != (ssize_t)len) {
        free(buf);
        return;
    }

    buf[len] = '\0';
    free(buf);
}

int func3() {
    size_t buffer_size = 1024;
    char *buffer = (char *)malloc(buffer_size);
    if (!buffer) return -1;

    printf("Please enter your user ID: ");
    if (!fgets(buffer, buffer_size, stdin)) { free(buffer); return -2; }

    size_t len = strnlen(buffer, buffer_size);

    // Aware of trailing new-lines
    if (len > 0 && buffer[len - 1] == '\n') {
        buffer[len - 1] = '\0';
    }

    // Validate that the first character is a letter
    if (buffer[0] == '\0' || !isalpha((unsigned char)buffer[0])) {
        // Use a dynamic buffer to avoid fixed-size issues
        size_t err_len = len + 21; // " is not a valid ID" + 1 (null terminator)
        char *errormsg = (char *)malloc(err_len);
        if (!errormsg) {
            fprintf(stderr, "Memory allocation failed.\n");
            free(buffer);
            return -3;
        }

        snprintf(errormsg, err_len, "%s is not a valid ID", buffer);
        fprintf(stderr, "%s\n", errormsg);
        free(errormsg);
    }

    free(buffer);
    return 0;
}

void func4(const char *foo) {
    if (!foo) return;

    size_t len = strnlen(foo, 9);
    char *buffer = (char *)malloc(10);
    if (!buffer) return;

    snprintf(buffer, len, "%s", foo);
    free(buffer);
}

main()
{
    int y = 10;
    int a[10];

    func4("fooooooooooooooooooooooooooooooooooooooooooooooooooo");

    // Use error code instead of try and catch
    
    int i = func3();
    if (i == -1) fprintf(stderr, "...");
    if (i == -2) fprintf(stderr, "...");
    if (i == -3) fprintf(stderr, "...");
    
    fprintf(aFile, "%s", "hello world");

    while (y > 0)
    {
        y = y - 1;
        a[y] = y;
    }

    return 0;
}