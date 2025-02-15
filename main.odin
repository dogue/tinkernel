package kernel

import "vga"

foreign import boot "boot.s"

foreign boot {
    enable_sse :: proc "sysv" () ---
}

foreign _ {
    @(link_name = "__$startup_runtime")
    _startup_runtime :: proc "odin" () ---
    @(link_name = "__$cleanup_runtime")
    _cleanup_runtime :: proc "odin" () ---
}


@(export, link_name = "kmain", require)
kmain :: proc "contextless" () -> ! {
    enable_sse()
    context = {}
    #force_no_inline _startup_runtime()

    vga.clear()
    vga.put_string("hellope!")

    for {}
}
