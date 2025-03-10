package kernel

@(default_calling_convention = "sysv")
foreign {
    read_msr :: proc(reg: u32) -> u32 ---
    write_msr :: proc(reg, value: u32) ---
    set_interrupt :: proc() ---
}

APIC_BASE: u64

APIC_Register :: enum u32 {
    ID              = 0x20,
    VERSION         = 0x30,
    TPR             = 0x80,
    EOI             = 0xB0,
    SPURIOUS        = 0xF0,
    ICR_LOW         = 0x300,
    ICR_HIGH        = 0x310,
    LVT_TIMER       = 0x320,
    LVT_LINT0       = 0x350,
    LVT_LINT1       = 0x360,
    LVT_ERROR       = 0x370,
}

@(init)
get_apic_base_addr :: proc() {
    // discard flags in the low 12 bits
    addr := read_msr(0x1b) & 0xffff_f000
    // APIC is mapped into the upper half
    APIC_BASE = (0xffff_ffff << 32) | u64(addr)
}

write_apic :: proc(reg: APIC_Register, value: u32) {
    addr := APIC_BASE + u64(reg)
    (^u32)(uintptr(addr))^ = value
}

read_apic :: proc(reg: APIC_Register) -> u32 {
    addr := APIC_BASE + u64(reg)
    return (^u32)(uintptr(addr))^
}

enable_apic :: proc() {
    val := read_msr(0x1b)
    val |= 1 << 11
    write_msr(0x1b, val)
    set_interrupt()
}

init_apic :: proc() {
    // ICW1 - init master and slave PICs

    enable_apic()
    // enable APIC by setting spurious interrupt vector
    // bit 8 = enable
    // bits 0-7 = vector
    write_apic(.SPURIOUS, 0x1ff)
    write_apic(.LVT_LINT0, 0x700)

    // disable all local interrupts initially
    write_apic(.LVT_TIMER, (1 << 16))
    // write_apic(.LVT_LINT0, (7 << 8))
    write_apic(.LVT_LINT1, (1 << 16))
    write_apic(.LVT_ERROR, (1 << 16))

    init_pic()
}

init_pic :: proc() {
    // ICW1: init master/slave PICs
    outb(0x20, 0x11)
    outb(0xa0, 0x11)

    // ICW2: set base vectors, master 0x20, slave 0x28
    outb(0x21, 0x20)
    outb(0xa1, 0x28)

    // ICW3: slave on IRQ2
    outb(0x21, 0x04)
    outb(0xa1, 0x02)

    // ICW4: 8086 mode
    outb(0x21, 0x01)
    outb(0xa1, 0x01)

    // unmask IRQ1 (kb) on master, mask all on slave
    outb(0x21, 0xfd)
    outb(0xa1, 0xff)
}
