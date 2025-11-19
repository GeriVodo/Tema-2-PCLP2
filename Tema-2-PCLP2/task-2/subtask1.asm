%include "../include/io.mac"

section .text
    global check_events
    extern printf

check_events:
    enter 0, 0
    pusha

    mov esi, [ebp + 8]    ; esi = pointer to first event (36-byte structure)
    mov ecx, [ebp + 12]   ; ecx = total number of events

.check_loop:
    cmp ecx, 0
    je .done

    ; Mark event as invalid by default
    mov byte [esi + 31], 0

    ; Extract day, month, year
    movzx eax, byte [esi + 32] ; day
    movzx ebx, byte [esi + 33] ; month
    movzx edx, word [esi + 34] ; year

    ; Check year range [1990, 2030]
    cmp edx, 1990
    jl .next
    cmp edx, 2030
    jg .next

    ; Check month range [1, 12]
    cmp ebx, 1
    jl .next
    cmp ebx, 12
    jg .next

    ; Determine days in month
    mov edi, 31               ; default 31 days
    cmp ebx, 4
    je .set_30
    cmp ebx, 6
    je .set_30
    cmp ebx, 9
    je .set_30
    cmp ebx, 11
    je .set_30
    cmp ebx, 2
    je .set_28
    jmp .check_day

.set_30:
    mov edi, 30               ; April, June, September, November
    jmp .check_day

.set_28:
    mov edi, 28               ; February

.check_day:
    cmp eax, 1
    jl .next
    cmp eax, edi
    jg .next

    ; All checks passed - mark as valid
    mov byte [esi + 31], 1

.next:
    add esi, 36               ; move to next event
    dec ecx
    jmp .check_loop

.done:
    popa
    leave
    ret