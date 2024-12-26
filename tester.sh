#!/bin/bash

gcc -nostdlib -static -Wl,-N $1 -o shellcode-elf
objcopy --dump-section .text=shellcode-raw shellcode-elf

shellcode=$(objdump -d ./shellcode-elf|grep '[0-9a-f]:'| \
grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s \
' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|\
paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g')

printf "// gcc main.c -o main -z execstack\n" > main.c
printf "int main() {\n" >> main.c
printf "    unsigned char shellcode[] = " >> main.c
echo -e "$shellcode;" >> main.c
printf "    (*(void(*)()) shellcode)();\n" >> main.c
printf "}\n" >> main.c

echo "$shellcode"
echo -e "$shellcode"

gcc main.c -o main -z execstack
./main