package arch

foreign import apic "apic.s"

@(default_calling_convention = "sysv")
foreign apic {
    read_apic_reg :: proc(offset: u64) -> u32 ---
    write_apic_reg :: proc(offset: u64, value: u32) ---
    enable_apic :: proc() ---
    read_apic_id :: proc() -> u32 ---
    test_func :: proc() -> u32 ---
    enable_apic_simple :: proc() ---
}
