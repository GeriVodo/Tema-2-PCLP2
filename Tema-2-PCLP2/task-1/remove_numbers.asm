%include "../include/io.mac"

extern printf
global remove_numbers

section .data
    fmt db "%d", 10, 0

section .text

remove_numbers:
    push    ebp
    mov     ebp, esp       
    pusha                   

    mov     esi, [ebp + 8]   ; esi = source array pointer (a)
    mov     ecx, [ebp + 12]  ; ecx = number of elements (n)
    mov     edi, [ebp + 16]  ; edi = target array pointer (target)
    mov     edx, [ebp + 20]  ; edx = pointer to result length (ptr_len)

    xor     ebx, ebx         ; ebx will count valid elements

filter_loop:
    test    ecx, ecx         ; check if there are elements left
    jz      done             

    mov     eax, [esi]       ; load current element
    add     esi, 4           ; move source pointer

    ; Check if number is odd
    test    eax, 1           
    jnz     skip_odd         

    ; Check if number is power of two
    push    eax              
    dec     eax              
    test    eax, [esp]       
    pop     eax              
    jz      skip_power_two   

    ; If even and not power of two, add to target
    mov     [edi], eax       
    add     edi, 4           
    inc     ebx              

skip_odd:
skip_power_two:
    dec     ecx              
    jmp     filter_loop      

done:
    mov     [edx], ebx       ; store number of valid elements

    popa
    leave
    ret