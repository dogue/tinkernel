bits 64
section .text

global outb
outb:
    mov dx, di
    mov al, sil
    out dx, al
    ret

global inb
inb:
    mov dx, di
    in al, dx
    ret

global read_msr
read_msr:
    mov ecx, edi
    rdmsr
    ret

global write_msr
write_msr:
    mov ecx, edi
    mov eax, esi
    ; xor edx, edx
    wrmsr
    ret

global set_interrupt
set_interrupt:
    sti
    ret

global halt_catch_fire
halt_catch_fire:
    cli

    ; disable apic
    mov ecx, 0x1b
    rdmsr
    and eax, ~(1<<11)
    wrmsr

    hlt
