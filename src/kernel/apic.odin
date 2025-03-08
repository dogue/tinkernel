package kernel

import "vga"

foreign import apic "x86/apic.s"
@(default_calling_convention = "sysv")
foreign apic {
    get_apic_base :: proc() -> u32 ---
}

APIC_BASE :: 0xffff_ffff_fee0_0000

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

write_apic :: proc(reg: APIC_Register, value: u32) {
    addr := APIC_BASE + u64(reg)
    (^u32)(uintptr(addr))^ = value
}

read_apic :: proc(reg: APIC_Register) -> u32 {
    addr := APIC_BASE + u64(reg)
    return (^u32)(uintptr(addr))^
}

init_apic :: proc() {
    // APIC_BASE = (0xffffffff << 32) | u64(get_apic_base())
    // APIC_BASE = 0xfee00000
    // enable APIC by setting spurious interrupt vector
    // bit 8 = enable
    // bits 0-7 = vector
    // write_apic(.SPURIOUS, 0x1ff)

    // disable all local interrupts initially
    // write_apic(.LVT_TIMER, 0x10000)
    // write_apic(.LVT_LINT0, 0x1070F)
    // write_apic(.LVT_LINT1, 0x1040F)
    // write_apic(.LVT_ERROR, 0x10000)

    write_apic(.LVT_LINT0, 0x1070f)
    write_apic(.LVT_LINT1, 0x1040f)
    write_apic(.LVT_TIMER, 0x10000)
    write_apic(.LVT_ERROR, 0x10000)

    write_apic(.SPURIOUS, 0x1ff)
}
