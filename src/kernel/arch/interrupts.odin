package arch

import "../vga"

foreign import interrupts "interrupts.s"
@(default_calling_convention = "sysv")
foreign interrupts {
    load_idt :: proc(idtr: ^IDT_Descriptor) ---
    read_cr2 :: proc() -> uintptr ---
    isr0 :: proc() ---
    isr1 :: proc() ---
    isr2 :: proc() ---
    isr3 :: proc() ---
    isr4 :: proc() ---
    isr5 :: proc() ---
    isr6 :: proc() ---
    isr7 :: proc() ---
    isr8 :: proc() ---
    isr9 :: proc() ---
    isr10 :: proc() ---
    isr11 :: proc() ---
    isr12 :: proc() ---
    isr13 :: proc() ---
    isr14 :: proc() ---
    isr15 :: proc() ---
    isr16 :: proc() ---
    isr17 :: proc() ---
    isr18 :: proc() ---
    isr19 :: proc() ---
    isr20 :: proc() ---
}

IDT_ENTRIES :: 256
IDT_ENTRY_PRESENT :: 0x80
IDT_ENTRY_INT_GATE :: 0x0e
IDT_DEFAULT_FLAGS :: IDT_ENTRY_PRESENT | IDT_ENTRY_INT_GATE

IDT_Entry :: struct #packed {
    offset_low: u16,
    selector: u16,
    ist: u8,
    type_attr: u8,
    offset_mid: u16,
    offset_high: u32,
    reserved: u32,
}

IDT_Descriptor :: struct #packed {
    limit: u16,
    base: u64,
}

idt_entries: [IDT_ENTRIES]IDT_Entry
idt_descriptor: IDT_Descriptor

@(export)
interrupt_handler :: proc "sysv" (id: u64, error_code: u64) {
}

// set an entry
set_idt_gate :: proc(n: int, handler: rawptr, selector: u16 = 0x08, flags: u8 = IDT_DEFAULT_FLAGS) {
    addr := uintptr(handler)

    idt_entries[n].offset_low = u16(addr & 0xffff)
    idt_entries[n].selector = selector
    idt_entries[n].ist = 0
    idt_entries[n].type_attr = flags
    idt_entries[n].offset_mid = u16((addr >> 16) & 0xffff)
    idt_entries[n].offset_high = u32(addr >> 32)
    idt_entries[n].reserved = 0
}

init_idt :: proc() {
    idt_descriptor.limit = u16(size_of(IDT_Entry) * IDT_ENTRIES - 1)
    idt_descriptor.base = u64(uintptr(&idt_entries[0]))

    // clear the table
    for i in 0..<IDT_ENTRIES {
        idt_entries[i] = {}
    }

    // install handlers
    set_idt_gate(0, rawptr(isr0))
    set_idt_gate(1, rawptr(isr1))
    set_idt_gate(2, rawptr(isr2))
    set_idt_gate(3, rawptr(isr3))
    set_idt_gate(4, rawptr(isr4))
    set_idt_gate(5, rawptr(isr5))
    set_idt_gate(6, rawptr(isr6))
    set_idt_gate(7, rawptr(isr7))
    set_idt_gate(8, rawptr(isr8))
    set_idt_gate(9, rawptr(isr9))
    set_idt_gate(10, rawptr(isr10))
    set_idt_gate(11, rawptr(isr11))
    set_idt_gate(12, rawptr(isr12))
    set_idt_gate(13, rawptr(isr13))
    set_idt_gate(14, rawptr(isr14)) // page fault
    set_idt_gate(15, rawptr(isr15))
    set_idt_gate(16, rawptr(isr16))
    set_idt_gate(17, rawptr(isr17))
    set_idt_gate(18, rawptr(isr18))
    set_idt_gate(19, rawptr(isr19))
    set_idt_gate(20, rawptr(isr20))

    load_idt(&idt_descriptor)
}
