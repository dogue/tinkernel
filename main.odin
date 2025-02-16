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
    vga.put_string("this\nis\na\nreally\nlong\nstring\nthat\nis\nintended\nto\nwrap\naround\nonce\nit\nreaches\nthe\nend\nof\nthe\nscreen\non\nthe\nright\nhand\nside\nof\nthe")

    for {}
}
