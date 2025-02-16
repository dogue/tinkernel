package vga

_buf := cast([^]VGA_Char)uintptr(0xb8000)

BLANK_CHAR :: VGA_Char {}
DEFAULT_CHAR := VGA_Char {
    char = 0,
    fg = .LightGray,
    bg = .Black,
    blink = false,
}

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

VGA_Char :: bit_field u16 {
    char:  byte  | 8,
    fg:    Color | 4,
    bg:    Color | 3,
    blink: bool  | 1,
}

@(private)
write :: proc(c: VGA_Char) {
    @(static)
    offset := 0

    switch c.char {
    case '\n':
        offset += 80 - ((offset + 80) % 80)
        return
    }

    _buf[offset] = c
    offset += 1
}

clear :: proc() {
    for i in 0..<80 * 25 {
        _buf[i] = BLANK_CHAR
    }
}

put_char :: proc {
    put_char_default,
}

put_char_default :: proc(c: byte) {
    vc := DEFAULT_CHAR
    vc.char = c
    write(vc)
}

put_char_fg :: proc(c: byte, fg: Color) {
    vc := DEFAULT_CHAR
    vc.char = c
    vc.fg = fg
    write(vc)
}

put_string :: proc(s: string) {
    for c in s {
        put_char(byte(c))
    }
}
