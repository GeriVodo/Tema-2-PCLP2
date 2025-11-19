%include "../include/io.mac"

extern printf
global check_row
global check_column
global check_box

section .data
    digit_counts times 10 db 0  ; Count array for digits 1-9 (indexed from 1)
    debug_fmt db "%d ", 0       ; Debug format string (unused)
    newline db 10, 0            ; Newline character for debug

section .text

; Macro to reset digit_counts to 0
%macro CLEAR_COUNTS 0
    push edi
    push ecx
    push eax
    mov edi, digit_counts
    mov ecx, 10
    xor eax, eax
    rep stosb
    pop eax
    pop ecx
    pop edi
%endmacro

; int check_row(char* sudoku, int row);
check_row:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi

    CLEAR_COUNTS               ; Reset count array

    ; Calculate row offset: row * 9
    mov eax, [ebp + 12]        ; row
    mov ecx, 9
    mul ecx                    ; eax = row * 9
    mov esi, [ebp + 8]         ; sudoku
    add esi, eax               ; esi points to row start

    mov ecx, 9                 ; Process 9 cells
.row_loop:
    movzx eax, byte [esi]      ; Get cell value
    cmp eax, 1
    jl .invalid_digit          ; Skip if < 1
    cmp eax, 9
    jg .invalid_digit          ; Skip if > 9
    inc byte [digit_counts + eax]
.invalid_digit:
    inc esi                    ; Next cell
    loop .row_loop

    ; Verify each digit 1-9 appears exactly once
    mov ecx, 1
.verify_loop:
    cmp byte [digit_counts + ecx], 1
    jne .invalid_row
    inc ecx
    cmp ecx, 10
    jl .verify_loop

    mov eax, 1                 ; Valid row
    jmp .end_check

.invalid_row:
    mov eax, 2                 ; Invalid row

.end_check:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    leave
    ret

; int check_column(char* sudoku, int column);
check_column:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi

    CLEAR_COUNTS               ; Reset count array

    mov esi, [ebp + 8]         ; sudoku
    mov edx, [ebp + 12]        ; column

    mov ecx, 9                 ; Process 9 rows
.column_loop:
    mov eax, ecx
    dec eax                    ; row = ecx - 1
    imul eax, eax, 9           ; row * 9
    add eax, edx               ; column offset
    movzx ebx, byte [esi + eax] ; Get cell value

    cmp ebx, 1
    jl .invalid_digit          ; Skip if < 1
    cmp ebx, 9
    jg .invalid_digit          ; Skip if > 9
    inc byte [digit_counts + ebx]
.invalid_digit:
    loop .column_loop

    ; Verify counts
    mov ecx, 1
.verify_loop:
    cmp byte [digit_counts + ecx], 1
    jne .invalid_column
    inc ecx
    cmp ecx, 10
    jl .verify_loop

    mov eax, 1                 ; Valid column
    jmp .end_check

.invalid_column:
    mov eax, 2                 ; Invalid column

.end_check:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    leave
    ret

; int check_box(char* sudoku, int box);
check_box:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi

    CLEAR_COUNTS               ; Reset count array

    ; Calculate box position: box_row = box / 3, box_col = box % 3
    mov eax, [ebp + 12]        ; box index
    mov ecx, 3
    xor edx, edx
    div ecx                    ; eax = box_row, edx = box_col

    ; Calculate top-left offset: (box_row * 27) + (box_col * 3)
    imul eax, eax, 27          ; 3 rows * 9 columns = 27
    imul edx, edx, 3
    add eax, edx

    mov esi, [ebp + 8]         ; sudoku
    add esi, eax               ; Pointer to top-left of box

    mov ecx, 3                 ; Process 3 rows
.box_row_loop:
    push ecx
    mov ecx, 3                 ; Process 3 columns
    mov edx, 0
.box_col_loop:
    movzx eax, byte [esi + edx] ; Get cell value
    cmp eax, 1
    jl .invalid_digit          ; Skip if < 1
    cmp eax, 9
    jg .invalid_digit          ; Skip if > 9
    inc byte [digit_counts + eax]
.invalid_digit:
    inc edx                    ; Next column
    loop .box_col_loop
    add esi, 9                 ; Next row in sudoku
    pop ecx
    loop .box_row_loop

    ; Verify counts
    mov ecx, 1
.verify_loop:
    cmp byte [digit_counts + ecx], 1
    jne .invalid_box
    inc ecx
    cmp ecx, 10
    jl .verify_loop

    mov eax, 1                 ; Valid box
    jmp .end_check

.invalid_box:
    mov eax, 2                 ; Invalid box

.end_check:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    leave
    ret