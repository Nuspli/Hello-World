# Hello World

```txt
A
S imple
C ool
I nsanely
I nteresting

Hello, World! program for x86_64 linux
```

## Building

The assembly file is not meant to be built and run by itself, it is the disassembly/source code for this string:

```txt
jPTYX4SPXk9MHc49149hJGaaX5EB19PXHc1149hell0hell0hell0hell0hell0hell0hell0XXXXXXXHcqH1qHjPX4Q1AHHcyHHcqH1qHHcqL1qLHcqP1qPHcqT1qTHcqHh9V99X5q3UU1AHhXXpcX57tP41ALh8A82X5W3TV1APhEEEEX5dOEE1ATXYYXXXYYTTYH31jYX4IPZjPX4QPXfuckjPTYX4SPXk9MHc49149hJGaaX5EBaaPXHc1149jAX4APHc9jdX4X
```

If you take this string and execute it **on the stack** like the C program does, it will print "Hello, World!". For this to work, the stack must be executable.

```bash
gcc helloword.c -o helloword -z execstack
```

To verify that the string is actually what I claim it to be:

```
gcc -nostdlib -static -Wl,-N helloworld.s -o elf
objcopy --dump-section .text=raw elf
cat raw
```

## About

This is the result of my exploration of printable, and specifically alphanumeric shellcode.
While the code is not optimal in any way and maybe not very clear, this project is just to demonstrate what is possible and push my shellcoding skills. Somebody might find it interesting too.
As a bonus, the string "Hello, World!\n" is not directly present in the assembled code.

> Please don't try to use this as a start for your own project. I'm sure there are a hundred better ways of implementing something like this.
