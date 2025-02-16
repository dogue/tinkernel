section .multiboot_header
header_start:
    dd 0xe85250d6   ; multiboot magic
    dd 0            ; protected mode
    dd header_end - header_start

    ; checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; info request tag
    dw 1    ; type 1 (info request)
    dw 0    ; flags
    dd 24   ; size
    dd 6    ; request mmap
    dd 4    ; request BIOS boot device
    dd 1    ; request cmdline
    dd 2    ; request bootloader name
    dd 0    ; terminator

    ; end tag
    dw 0    ; type
    dw 0    ; flags
    dd 8    ; size
header_end:
