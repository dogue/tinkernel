package kernel

import "vga"

foreign _ {
    @(link_name = "__$startup_runtime")
    _startup_runtime :: proc "odin" () ---
    @(link_name = "__$cleanup_runtime")
    _cleanup_runtime :: proc "odin" () ---
}

@(export, link_name = "kmain", require)
kmain :: proc "contextless" () -> ! {
    // enable_sse()
    context = {}
    #force_no_inline _startup_runtime()

    vga.clear()
    vga.put_string("hellope!\n\thehe\n")
    vga.put_string("this is a really long string that is intended to wrap around once it reaches the end of the screen on the right hand side so that I can test if that's working correctly with my current VGA text mode handling code")

    for {}
}
