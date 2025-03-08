package tinkernel

import "kernel"
import "kernel/vga"
import mb "kernel/multiboot"

@(export, link_name = "kmain", require)
kmain :: proc "contextless" (mb_info: ^mb.Multiboot_Info, mb_magic: u32) -> ! {
    context = kernel.init(mb_info)

    if mb_magic != 0x36d76289 {
        kernel.panic("Multiboot magic number missing or incorrect")
    }

    // vga.clear()
    vga.println("Tinkernel :)")

    // exception handler test
    bad_addr := (^u8)(uintptr(0xffff_ffff_0000_6969))
    bad_addr^ = 42

    for {}
}
