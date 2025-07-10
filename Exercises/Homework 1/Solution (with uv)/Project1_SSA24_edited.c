#include <stdlib.h>
#include <string.h>
#include <stdio.h>

void func1(char *src)
{
    // ERROR: strlen(src) counts the number of characters in src up to the null
    // terminator. But src may be not null-terminated, thus this may keep
    // counting until it reaches the first memory byte whose value is 0,
    // resulting in memory access violation.
    //
    // The length of dst is the length of src + 1 for the null terminator.
    char dst[(strlen(src) + 1) * sizeof(char)];

    // Copy in dest the string src up to the maximum amount of characters in
    // src + 1 (sizeof(char)) for the null terminator
    strncpy(dst, src, strlen(src) + sizeof(char)); // sizeof(char) = 1

    // ERROR: The strlen(dst) counts the number of characters in dst up to the
    // null terminator. But dst is currently not null-terminated, thus this may
    // result in a memory access violation.
    dst[strlen(dst)] = 0; // 0 = '\0'
}

void func2(int fd)
{
    char *buf;
    size_t len;
    read(fd, &len, sizeof(len));
    // ERROR: After reading, we should compare if all characters have been read
    // or not.

    // ERROR: Uses the variable len without checking if the read was successful.
    // Since len was not initialized, using it after an error will cause an
    // error.
    if (len > 1024)
        return;
    
    buf = malloc(len + 1);
    read(fd, buf, len);
    // ERROR: After reading, we should check if the read was successful.

    buf[len] = '\0';
}

void func3()
{
    char buffer[1024];
    printf("Please enter your user id :");
    fgets(buffer, 1024, stdin); // ERROR: possible string format vulnerability.

    // ERROR: The isalpha function requires the #include <ctype.h>
    if (!isalpha(buffer[0]))
    {
        // WARNING: Size of errormsg is choosen exactly to fit the string
        // " is not  a valid ID" plus 1024. It's easy to change the string below
        // without remembering to change this amount, thus a dynamic size
        // would be better.
        char errormsg[1044];
        strncpy(errormsg, buffer, 1024);
        strcat(errormsg, " is not  a valid ID");
    }
}

void func4(char *foo)
{
    // ERROR: assumes that the foo string is long only ten character (null
    // terminator included), and no check is done on foo length. This means
    // that the strcpy below may result in a buffer overflow.
    char *buffer = (char *)malloc(10 * sizeof(char));
    strcpy(buffer, foo); // ERROR: What if foo is not null terminated?
    // ERROR: Does not add the null terminator to buffer.
}

main()
{
    int y = 10;
    int a[10];

    func4("fooooooooooooooooooooooooooooooooooooooooooooooooooo");

    {
        try
        {
            func3();
        }
        catch (char *message)
        {
            fprintf(stderr, message);
        };
        // ERROR: Un-existing variable aFile.
        fprintf(aFile, "%s", "hello world") // ERROR: Missing semicolon ;

        // ERROR: Loop iterates 11 times, 1 ahead of the length of the array a,
        // thus causing a memory access violation with the array.
        while (y >= 0)
        {
            // ERROR: y starts at 10, but last valid index of a is 9. The
            // instruction y = y - 1 should be put before.
            a[y] = y;
            y = y - 1;
        }
        return 0;
    }
// ERROR: Missing bracket }