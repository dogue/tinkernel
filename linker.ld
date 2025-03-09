ENTRY(start)

PHDRS {
    /* 1 = X, 2 = W, 4 = R */
    text    PT_LOAD FLAGS(5); /* RX */
    rodata  PT_LOAD FLAGS(4); /* R */
    data    PT_LOAD FLAGS(6); /* RW */
}

SECTIONS {
    . = 1M;

    kernel_phys_start = .;

    .boot :
    {
        *(.multiboot_header)
    } :text

    .text :
    {
        *(.text)
    } :text

    .rodata :
    {
        *(.rodata)
    } :rodata

    .data :
    {
        *(.data)
    } :data

    .bss :
    {
        *(.bss)
    } :data

    kernel_phys_end = .;
}
