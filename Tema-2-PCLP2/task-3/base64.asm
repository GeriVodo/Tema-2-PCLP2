%include "../include/io.mac"

extern printf
global base64

section .data
    alphabet db 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

section .text

base64:
    push ebp
    mov ebp, esp
    pusha

    mov esi, [ebp + 8]   ; esi = source byte array
    mov ecx, [ebp + 12]  ; ecx = source length
    mov edi, [ebp + 16]  ; edi = destination buffer
    mov edx, [ebp + 20]  ; edx = pointer to result length

    xor ebx, ebx         ; ebx will hold output length

process_triplets:
    cmp ecx, 0
    jle encoding_done

    ; Load 3 bytes into eax (big-endian)
    xor eax, eax
    cmp ecx, 1
    jl pad_two_bytes     ; Need to pad 2 bytes
    mov al, [esi]
    shl eax, 8
    cmp ecx, 2
    jl pad_one_byte      ; Need to pad 1 byte
    mov al, [esi + 1]
    shl eax, 8
    mov al, [esi + 2]

    ; Process all 4 Base64 characters
    call encode_quad
    add esi, 3
    sub ecx, 3
    jmp process_triplets

pad_one_byte:
    ; Only 2 bytes available, pad with 1 '='
    mov al, [esi + 1]
    shl eax, 8
    call encode_quad
    mov byte [edi - 1], '=' ; Replace last char with padding
    add esi, 2
    sub ecx, 2
    jmp process_triplets

pad_two_bytes:
    ; Only 1 byte available, pad with 2 '='
    call encode_quad
    mov byte [edi - 1], '=' ; Replace last 2 chars with padding
    mov byte [edi - 2], '='
    inc esi
    dec ecx
    jmp process_triplets

encode_quad:

    ; First 6 bits (bits 18-23)
    mov edx, eax
    shr edx, 18
    and edx, 0x3F
    mov dl, [alphabet + edx]
    mov [edi], dl
    inc edi
    inc ebx

    ; Next 6 bits (bits 12-17)
    mov edx, eax
    shr edx, 12
    and edx, 0x3F
    mov dl, [alphabet + edx]
    mov [edi], dl
    inc edi
    inc ebx

    ; Next 6 bits (bits 6-11)
    mov edx, eax
    shr edx, 6
    and edx, 0x3F
    mov dl, [alphabet + edx]
    mov [edi], dl
    inc edi
    inc ebx

    ; Last 6 bits (bits 0-5)
    mov edx, eax
    and edx, 0x3F
    mov dl, [alphabet + edx]
    mov [edi], dl
    inc edi
    inc ebx
    ret

encoding_done:
    ; Store final length
    mov edx, [ebp + 20]
    mov [edx], ebx

    popa
    leave
    ret