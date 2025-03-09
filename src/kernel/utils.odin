package kernel

import "base:runtime"
import "core:fmt"
import "../drivers/vga"

@(default_calling_convention = "sysv")
foreign {
    halt_catch_fire :: proc() -> ! ---
}

Log_Level :: enum {
    Debug,
    Info,
    Warn,
    Error,
    Panic,
}

panic :: proc "contextless" (msg: string) -> ! {
    log(.Panic, msg)
    halt_catch_fire()
}

panicf :: proc(f: string, args: ..any) -> ! {
    logf(.Panic, f, ..args)
    halt_catch_fire()
}

log :: proc "contextless" (level: Log_Level, msg: string) {
    level_str: string
    switch level {
    case .Debug: level_str = "DEBUG"
    case .Info: level_str = "INFO"
    case .Warn: level_str = "WARN"
    case .Error: level_str = "ERROR"
    case .Panic: level_str = "PANIC"
    }

    vga.print("[")
    vga.print(level_str)
    vga.print("] ")
    vga.println(msg)
}

logf :: proc(level: Log_Level, f: string, args: ..any) {
    msg := fmt.tprintf(f, ..args)
    log(level, msg)
}
