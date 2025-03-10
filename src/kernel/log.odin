

package kernel

import "base:runtime"
import "../drivers/vga"

kernel_logger_proc :: proc(
    data: rawptr,
    level: runtime.Logger_Level,
    text: string,
    options: bit_set[runtime.Logger_Option],
    location := #caller_location
) {
    vga.printfln("[%s] %s", level, text)
}

kernel_logger_init :: proc() -> runtime.Logger {
    return runtime.Logger {
        procedure = kernel_logger_proc,
        data = nil,
        lowest_level = .Debug,
        options = {},
    }
}
