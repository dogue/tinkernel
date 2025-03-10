package tinkernel

import "kernel"
import "drivers/vga"
import mb "kernel/multiboot"

foreign _ {
    halt_catch_fire :: proc() -> ! ---
}

@(export, link_name = "kmain", require)
kmain :: proc "contextless" (mb_info: ^mb.Multiboot_Info, mb_magic: u32) -> ! {
    vga.clear()
    context = kernel.init(mb_info)

    if mb_magic != 0x36d76289 {
        panic("Multiboot magic number missing or incorrect")
    }

    vga.println("Tinkernel :)")

    // exception handler test
    // bad_addr := (^u8)(uintptr(0xffff_ffff_0000_6969))
    // bad_addr^ = 42

    for {}
}
