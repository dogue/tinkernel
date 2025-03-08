global start
extern kmain

section .data
multiboot_ptr: dq 0
multiboot_magic: dq 0

;;
section .text
bits 32

; eax -> table being mapped
; ebx -> parent table
; ecx -> entry index
map_table:
    or eax, 0b11    ; present + writable
    mov [ebx + (ecx * 8)], eax
    mov dword [ebx + (ecx * 8) + 4], 0
    ret

; eax -> phys addr
; ebx -> flags
; ecx -> table addr
; edx -> entry index
map_entry:
    or eax, ebx     ; apply flags
    mov [ecx + edx * 8], eax
    mov dword [ecx + edx * 8 + 4], 0
    ret

setup_paging:
    ; PML4[0] -> PDPT
    mov eax, pdpt_table
    mov ebx, 0x3        ; present + writable
    mov ecx, pml4_table
    xor edx, edx        ; index 0
    call map_entry

    ; PDPT[0] -> PD
    mov eax, pd_table
    mov ebx, 0x3        ; present + writable
    mov ecx, pdpt_table
    xor edx, edx        ; index 0
    call map_entry

    xor esi, esi    ; current page number
.map_pages:
    mov eax, esi
    shl eax, 21     ; multiply by 2MiB
    mov ebx, 0x83   ; present + writable + huge page
    mov ecx, pd_table
    mov edx, esi
    call map_entry

    inc esi
    cmp esi, 512
    jne .map_pages

    ; higher half kernel map
    ; PML4[511] -> PDPT for -2GiB virtual addr
    mov eax, pdpt_high
    mov ebx, 0x3
    mov ecx, pml4_table
    mov edx, 511
    call map_entry

    ; PDPT[510] -> PD_high
    mov eax, pd_high
    mov ebx, 0x3
    mov ecx, pdpt_high
    mov edx, 510        ; maps virtual -2GiB
    call map_entry

    ; APIC map
    mov eax, 0xfee00000 ; phys addr
    and eax, ~0x1fffff  ; 2MiB align
    mov ebx, 0x3
    mov ecx, pd_high
    xor edx, edx
    call map_entry

    ret

start:
    mov dword [multiboot_magic], eax
    mov dword [multiboot_ptr], ebx
    call setup_paging

enable_paging:
    ; move P4 table into the page table control reg
    mov eax, pml4_table
    mov cr3, eax

    ; enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; set long mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8 ; set IA32_EFER.LME
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
    jmp gdt64.code:k_setup

halt:
    hlt

;;
section .bss
align 4096

pml4_table:
    resb 4096
pdpt_table:
    resb 4096
pd_table:
    resb 4096
pt_table:
    resb 4096

pdpt_high:
    resb 4096
pd_high:
    resb 4096
pt_high:
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

k_setup:
    ; enable SSE
    mov rax, cr0
    and ax, 0xfffb
    or ax, 0x0002
    mov cr0, rax
    mov rax, cr4
    or ax, 3 << 9
    mov cr4, rax

    ; start kernel
    mov rdi, [multiboot_ptr]
    mov rsi, [multiboot_magic]
    call kmain
    hlt
