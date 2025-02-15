global start
extern kmain

section .text
bits 32
start:
    mov eax, p3_table
    or eax, 0b11
    mov dword [p4_table], eax
    mov eax, p2_table
    or eax, 0b11
    mov dword [p3_table], eax

    mov ecx, 0
map_p2_table:
    mov eax, 0x200000 ; 2 MiB pages
    mul ecx
    or eax, 0b10000011
    mov [p2_table + ecx * 8], eax
    inc ecx
    cmp ecx, 512
    jne map_p2_table

enable_paging:
    ; move P4 table into the page table control reg
    mov eax, p4_table
    mov cr3, eax

    ; enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; set long mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; enable paging
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax

    lgdt [gdt64.pointer] ; load global descriptor table

jump_to_long:
    ; update selectors
    mov ax, gdt64.data
    mov ss, ax
    mov ds, ax
    mov es, ax
    jmp gdt64.code:kmain

halt:
    hlt

;;
section .bss
align 4096

p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096

section .rodata
gdt64:
    dq 0

.code: equ $ - gdt64
    dq (1 << 44) | (1 << 47) | (1 << 41) | (1 << 43) | (1 << 53)

.data: equ $ - gdt64
    dq (1 << 44) | (1 << 47) | (1 << 41)

.pointer:
    dw .pointer - gdt64 - 1
    dq gdt64

;;
section .text
bits 64
global enable_sse

enable_sse:
    mov rax, cr0
    and ax, 0xfffb
    or ax, 0x0002
    mov cr0, rax

    mov rax, cr4
    or ax, 3 << 9
    mov cr4, rax
    ret
