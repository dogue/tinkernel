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

global halt_catch_fire
halt_catch_fire:
    cli

    ; disable apic
    mov ecx, 0x1b
    rdmsr
    and eax, ~(1<<11)
    wrmsr

    hlt
