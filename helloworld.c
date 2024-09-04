// gcc helloworld.c -o helloworld -z execstack
int main() {
    unsigned char shellcode[] = "jPTYX4SPXk9MHc49149hJGaaX5EB19PXHc1149hell0hell0hell0hell0hell0hell0hell0XXXXXXXHcqH1qHjPX4Q1AHHcyHHcqH1qHHcqL1qLHcqP1qPHcqT1qTHcqHh9V99X5q3UU1AHhXXpcX57tP41ALh8A82X5W3TV1APhEEEEX5dOEE1ATXYYXXXYYTTYH31jYX4IPZjPX4QPXfuckjPTYX4SPXk9MHc49149hJGaaX5EBaaPXHc1149jAX4APHc9jdX4X";
    (*(void(*)()) shellcode)();
}
