bits 64
section .text
global read_scancode

read_scancode:
    xor rax, rax
    in al, 0x60
    ret
