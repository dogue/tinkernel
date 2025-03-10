package kernel

import "base:runtime"
import "core:fmt"
import "core:log"

import "../drivers/vga"

@(default_calling_convention = "sysv")
foreign {
    halt_catch_fire :: proc() -> ! ---
}

// panic handler, called by the built-in `panic` proc
@(private)
kpanic :: proc(prefix, message: string, loc := #caller_location) -> ! {
    // klog(.Fatal, message)
    log.fatal(message)
    halt_catch_fire()
}

// This was written before setting up the custom kernel logger.
// Keeping it for now for contextless logging, but may remove it
// later in favor of just calling default_context() where needed.
klog :: proc "contextless" (level: runtime.Logger_Level, msg: string) {
    level_str: string
    switch level {
    case .Debug: level_str = "Debug"
    case .Info: level_str = "Info"
    case .Warning: level_str = "Warn"
    case .Error: level_str = "Error"
    case .Fatal: level_str = "Fatal"
    }

    vga.print("[")
    vga.print(level_str)
    vga.print("] ")
    vga.println(msg)
}

kernel_logger_proc :: proc(
    data: rawptr,
    level: runtime.Logger_Level,
    text: string,
    options: bit_set[runtime.Logger_Option],
    location := #caller_location
) {
    vga.printfln("[%s] %s", level, text)
}

kernel_logger_init :: proc "contextless" (level: runtime.Logger_Level = .Info) -> runtime.Logger {
    return runtime.Logger {
        procedure = kernel_logger_proc,
        data = nil,
        lowest_level = level,
        options = {},
    }
}
