ENTRY(start)

SECTIONS {
    . = 1M;

    kernel_phys_start = .;

    .boot :
    {
        *(.multiboot_header)
    }

    .text :
    {
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(.bss)
    }

    kernel_phys_end = .;
}
