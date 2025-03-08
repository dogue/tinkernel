global get_apic_base

section .text
bits 64

get_apic_base:
    mov ecx, 0x1b
    rdmsr
    ret

enable_apic_simple:
    mov ecx, 0x1b
    rdmsr
    or eax, (1 << 11)
    wrmsr
    ret

; RDI = reg offset
read_apic_reg:
    mov rax, cr8
    push rax

    ; get APIC base addr from model specific reg
    mov ecx, 0x1b ; IA32_APIC_BASE MSR
    rdmsr
    mov rdx, 0xfffff000
    and rax, rdx

    ; add register offset
    add rdi, rax
    mov eax, [rdi] ; read reg value

    pop rcx
    mov cr8, rcx
    ret

; RDI = reg offset
; RSI = value
write_apic_reg:
    mov rax, cr8
    push rax

    ; get APIC base addr from model specific reg
    mov ecx, 0x1b ; IA32_APIC_BASE MSR
    rdmsr
    mov rdx, 0xfffff000
    and rax, rdx

    ; add offset and write value
    add rdi, rax
    mov [rdi], esi

    pop rcx
    mov cr8, rcx
    ret

enable_apic:
    mov ecx, 0x1b
    rdmsr

    ; set enable bit
    or eax, (1<<11)
    wrmsr

    ; enable APIC by writing to spurious interrupt vector reg
    mov rdi, 0xf0
    mov esi, 0x100
    call write_apic_reg
    ret
