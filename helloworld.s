.intel_syntax noprefix
.global _start
_start:

    # write(1, "Hello, World!\n\0\0", 16)
    # registers: rax = 1, rdi = 1, rsi = pointer to string, rdx = 16

    push 0x50
    push rsp
    pop rcx                             # rcx will be used to address data on the stack because [rsp] assembles to $
    pop rax
    xor al, 0x53                        # rax = 0x3
    push rax
    pop rax                             # rcx = pointer to 0x3
    imul edi, DWORD PTR [rcx], 0x4d     # edi = 0x4d * 0x3 = e7 (231)
                                        # since you need a syscall and 0x050f is not alphanumeric, you need to write it to a memory location
                                        # that lays ahead of execution, right after all registers are set up for the syscall. in this case that
                                        # offset is rcx+e7. you can figure it out either by calculating it from the length of the instructions
                                        # or by trial and error. (which is probably faster)

    movsxd rsi, DWORD PTR [rcx+rdi]     # zero out memory at [rcx+rdi] (place for the syscall) by xoring with itself
    xor DWORD PTR [rcx+rdi], esi

    push 0x6161474a
    pop rax
    xor eax, 0x39314245                 # 0x6161474a ^ 0x39314245 = 0x5850050f = syscall and push rax pop rax (in reverse)
                                        # the push rax pop rax is needed because after the syscall you need to keep executing the rest
                                        # of the code. if it was just 0x0000050f, this would result in the following instructions breaking
    push rax
    pop rax                             # make rcx point to 0x5850050f
    movsxd rsi, DWORD PTR [rcx]
    xor DWORD PTR [rcx+rdi], esi        # write 0x5850050f to [rcx+rdi]

    push 0x306c6c65                     # 42 bytes of padding
    push 0x306c6c65                     # these are needed to not overwrite upcoming instructions when placing the string on the stack
    push 0x306c6c65                     # at an offset that is alphanumeric (0x48-0x54). you can only go up to 0x57 for [rcx+0x??]
    push 0x306c6c65                     # which would make writing strings longer than 16 bytes more complicated
    push 0x306c6c65
    push 0x306c6c65                     # 42 also aligns the string to rsp + a multiple of 8 which is needed later to bring the string
    push 0x306c6c65                     # up in the stack by popping datat off
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax

    movsxd rsi, DWORD PTR [rcx+0x48]    # zero out memory at [rcx+0x48] by xoring with itself
    xor DWORD PTR [rcx+0x48], esi

    push 0x50                           # because you can't pop rdi directly, set rax to 1
    pop rax
    xor al, 0x51
    xor DWORD PTR [rcx+0x48], eax       # then place 1 at [rcx+0x48]
    movsxd rdi, DWORD PTR [rcx+0x48]    # and load it into rdi

    movsxd rsi, DWORD PTR [rcx+0x48]    # then zero out memory at [rcx+0x48] again
    xor DWORD PTR [rcx+0x48], esi
    movsxd rsi, DWORD PTR [rcx+0x4c]    # zero out the remaining 12 of the 16 bytes of continuous memory on the stack
    xor DWORD PTR [rcx+0x4c], esi
    movsxd rsi, DWORD PTR [rcx+0x50]
    xor DWORD PTR [rcx+0x50], esi
    movsxd rsi, DWORD PTR [rcx+0x54]
    xor DWORD PTR [rcx+0x54], esi

    movsxd rsi, DWORD PTR [rcx+0x48]    # use 0ed memory to clear rsi (will later be useful for xoring a non 0 value into rsi)

                                        # xoring two separate printable values to get the parts of the string you want
                                        # you could also simply push "Hell" "o, W" ... directly, but then it will show up in the assembled string
    push 0x39395639                     # 99V9
    pop rax
    xor eax, 0x55553371                 # UU3q
    xor DWORD PTR [rcx+0x48], eax       # 0x39395639 ^ 0x55553371 = 0x6c6c6548 = "Hell" (in reverse)

    push 0x63705858                     # cpXX
    pop rax
    xor eax, 0x34507437                 # 4p7t
    xor DWORD PTR [rcx+0x4c], eax       # 0x63705858 ^ 0x34507437 = 0x57202c6f = "o, W"

    push 0x32384138                     # 28A8
    pop rax
    xor eax, 0x56543357                 # VT3W
    xor DWORD PTR [rcx+0x50], eax       # 0x32384138 ^ 0x56543357 = 0x646c726f = "orld"

    push 0x45454545                     # EEEE
    pop rax
    xor eax, 0x45454f64                 # EEOd
    xor DWORD PTR [rcx+0x54], eax       # 0x45454545 ^ 0x45454f64 = 0x00000a21 = "!\n\0\0"

                                        # now [rcx+0x48] to [rcx+0x54] contain "Hello, World!\n\0\0"
                                        # 0x48 / 8 = 8, so you need to pop 8 times to get to the string

    pop rax                             # align rsp and the string
    pop rcx
    pop rcx
    pop rax
    pop rax
    pop rax
    pop rcx
    pop rcx

    push rsp                            # pointer to string
    push rsp                            # pointer to pointer to string
    pop rcx                             # rcx = pointer to pointer to string
    xor rsi, QWORD PTR [rcx]            # rsi was 0, now it's the pointer to the string

    push 0x59                           # set rdx to 0x10 (16): length of string
    pop rax
    xor al, 0x49
    push rax
    pop rdx

    push 0x50                           # set rax to 0x1 (1): syscall number for write
    pop rax
    xor al, 0x51

    push rax                            # two byte padding doing nothing until syscall because the offset 0x3 * 0x4d is not exact
    pop rax
    
    .byte 0x66, 0x75, 0x63, 0x6b        # gets overwritten by 0x5850050f (syscall and push rax pop rax)

    # exit(0)
    # registers: rax = 60, rdi = 0

    push 0x50                           # again calculate the offset to the next syscall
    push rsp
    pop rcx
    pop rax
    xor al, 0x53
    push rax
    pop rax
    imul edi, DWORD PTR [rcx], 0x4d     # edi = 0x4d * 0x3 = e7 (231) this happens to be the same as last time by coincidence due to the stack shifting?
                                        # not sure since I found it by trial and error, but it does in fact reach the end of the code

    movsxd rsi, DWORD PTR [rcx+rdi]     # zero out memory at [rcx+rdi]
    xor DWORD PTR [rcx+rdi], esi

    push 0x6161474a
    pop rax
    xor eax, 0x61614245
    push rax
    pop rax
    movsxd rsi, DWORD PTR [rcx]
    xor DWORD PTR [rcx+rdi], esi        # write 0x0000050f to [rcx+rdi] (syscall)

    push 0x41                           # clear rdi
    pop rax
    xor al, 0x41
    push rax
    movsxd rdi, DWORD PTR [rcx]         # rdi = 0 exit code

    push 0x64
    pop rax
    xor al, 0x58                        # rax = 0x3c (60) syscall number for exit

    # sycall gets written right here
