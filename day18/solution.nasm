section .bss
    dat:    resb len
    buffer: resb len
    input: resb len
    length: resb 1
    answer: resb 10

section .data
    len     equ 0xA00
    size    dd len
    newl    db 0xA
    p1loops dq 40
    p2loops dq 400000

section .text
    global  _start
_start:
    push    rbp
    mov     rbp, rsp
    ; main flow
    call    readinput
    ; length of input
    push    rax

    call    initialize
    mov     rax, [p1loops]
    mov     rcx, [rbp - 8]
    call    run
    call    printanswer

    mov     rax, [rbp-8]
    call    initialize
    mov     rax, [p2loops]
    mov     rcx, [rbp -8]
    call    run
    call    printanswer

    call    exit

initialize:
    ; Initializes the state with the cleaned input
    push    rbp
    mov     rbp, rsp

    push    rax
    push    0

    _loopinitialize:
    mov     rax, [rbp - 16]
    cmp     rax, [rbp - 8]
    jae     _endinitialize

    mov     bl, [input + rax]
    cmp     bl, '^'
    mov     bl, 0
    mov     al, 1
    cmove   rbx, rax
    mov     rax, [rbp-16]
    mov     [dat + rax], bl

    mov     rax, 1
    add     [rbp - 16], rax
    jmp     _loopinitialize

    _endinitialize:
    pop     rax
    pop     rax
    mov     rsp, rbp
    pop     rbp
    ret

run:
    push    rbp
    mov     rbp, rsp

    ; number of loops (rbp - 8)
    push    rax
    ; input length (rbp - 16)
    push    rcx
    ; index (rbp - 24)
    push    0
    ; number of items (rbp - 32)
    push    0
    _runloop:
    mov     rax, [rbp-24]
    cmp     rax, [rbp-8]
    jae     _endrun

    ; calculate number of items
    mov     rax, 0
    _calculateloop:
    cmp     rax, [rbp-16]
    jae     _endcalculate
    mov     sil, [dat + rax]
    mov     rbx, 0
    mov     rdi, 1
    cmp     sil, 0
    cmove   rbx, rdi
    add     [rbp-32], rbx

    add     rax, 1
    jmp     _calculateloop
    _endcalculate:
    mov     rsi, [rbp-32]
    ; inner index (rbp-40)
    push    0
    _mutateloop:
    mov     rax, [rbp-40]
    cmp     rax, [rbp-16]
    jae     _endmutate

    mov     rbx, 0
    mov     rcx, 0

    mov     rax, [rbp-40]
    cmp     rax, qword 0
    cmovne  rbx, [dat+rax-1]
    mov     rdx, [rbp-16]
    sub     rdx, 1
    cmp     rax, rdx
    cmovne  rcx, [dat+rax+1]
    xor     rbx, rcx
    mov     [buffer+rax], rbx

    mov     rax, [rbp-40]
    add     rax, 1
    mov     [rbp-40], rax
    jmp     _mutateloop

    _endmutate:
    pop     rax
    mov     rax, 0
    _copyloop:
    cmp     rax, [rbp-40]
    jae     _endcopy
    mov     cl, [buffer+rax]
    mov     [dat+rax], cl
    add     rax, 1
    jmp     _copyloop
    _endcopy:
    mov     rax, [rbp-24]
    add     rax, 1
    mov     [rbp-24], rax
    jmp     _runloop
    _endrun:
    pop     rax
    mov     rsp, rbp
    pop     rbp
    ret

readinput:
    push    rbp
    mov     rbp, rsp

    ; reads stdin to dat
    push    0
    _nextchar:
    ; check length, only read max len chars
    ; push len on stack
    mov     rbx, len
    cmp     [rbp-8], rbx
    jae     _endreadinput

    ; destination
    mov     rax, [rbp-8]
    lea     rcx, [input + rax]

    ; length
    mov     rdx, 1
    ; stdin
    mov     rbx, 0
    ; read
    mov     rax, 3
    int     0x80

    mov     rbx, rax

    ; check if eof
    cmp     rbx, 0
    je      _endreadinput

    ; check if end of line
    mov     rax, [rbp-8]
    mov     rbx, [input + rax]
    cmp     rbx, 10
    je      _endreadinput

    mov     rbx, [rbp-8]
    add     rbx, 1
    mov     [rbp-8], rbx
    jmp     _nextchar

    _endreadinput:
    pop     rax
    mov     rsp, rbp
    pop     rbp
    ret

printanswer:
    push    rbp
    mov     rbp, rsp

    ; rax = number to print, rbx = digit index
    mov     rbx, 0
    _nextdigit:
    cmp     rax, 0
    je      _printdigits
    mov     rsi, 10
    mov     edx, 0
    div     rsi
    add     rdx, '0'
    mov     [answer + rbx], rdx
    add     rbx, 1
    jmp     _nextdigit

    _printdigits:
    push    rbx
    mov     rdx, 1
    lea     rcx, [answer + rbx]
    call    print
    pop     rbx
    cmp     rbx, 0
    je      _endprintanswer
    sub     rbx, 1
    jmp     _printdigits

    _endprintanswer:
    call    newline
    mov     rsp, rbp
    pop     rbp
    ret

newline:
    push    rbp
    mov     rbp, rsp

    mov     rcx, newl
    mov     rdx, 1
    call    print

    mov     rsp, rbp
    pop     rbp
    ret

print:
    ; to print, put length in rdx, destination in rcx
    push    rbp
    mov     rbp, rsp

    mov     rbx,1
    mov     rax,4
    int     0x80

    mov     rsp, rbp
    pop     rbp
    ret

exit:
    mov     ebx,0
    mov     eax,1
    int     0x80