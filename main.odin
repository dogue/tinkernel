package kernel

import "vga"
import rt "kruntime"


@(export, link_name = "kmain", require)
kmain :: proc "contextless" (mb_info: ^rt.Multiboot_Info, mb_magic: u32) -> ! {
    context = rt.init(mb_info)

    if mb_magic != 0x36d76289 {
        rt.panic("Multiboot magic number missing or incorrect")
    }

    vga.clear()
    vga.println("Tinkernel :)")
    _, mem_size := rt.meminfo()
    vga.printf("Total available mem: %d MB", mem_size / 1024 / 1024)

    for {}
}
