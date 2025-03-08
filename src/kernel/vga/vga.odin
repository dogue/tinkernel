package vga

import "core:fmt"

Color :: enum u8 {
    Black,
    Blue,
    Green,
    Cyan,
    Red,
    Magenta,
    Brown,
    LightGray,
    DarkGray,
    LightBlue,
    LightGreen,
    LightCyan,
    LightRed,
    LightMagenta,
    Yellow,
    White,
}

print_int :: proc "contextless" (n: u64) {
    kprint_int(n)
}

print_hex :: proc "contextless" (n: u64) {
    kprint_hex(n)
}

print :: proc "contextless" (s: string) {
    put_string(s)
}

println :: proc "contextless" (s: string) {
    print(s)
    print("\n")
}

printf :: proc(f: string, args: ..any) {
    s := fmt.tprintf(f, ..args)
    print(s)
}

printfln :: proc(f: string, args: ..any) {
    printf(f, ..args)
    print("\n")
}

clear :: proc "contextless" () {
    for i in 0..<80 * 25 {
        BUF[i] = BLANK_CHAR
    }
}
