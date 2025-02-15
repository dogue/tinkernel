package vga

VGA := cast([^]VGA_Char)uintptr(0xb8000)

BLANK :: VGA_Char {}
DEFAULT := VGA_Char {
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

clear :: proc() {
    for i in 0..<80 * 25 {
        VGA[i] = BLANK
    }
}

put_char :: proc {
    put_char_default,
}

put_char_default :: proc(c: byte, offset := 0) {
    vc := DEFAULT
    vc.char = c
    VGA[offset] = vc
}

put_char_fg :: proc(c: byte, fg: Color, offset := 0) {
    vc := DEFAULT
    vc.char = c
    vc.fg = fg
    VGA[offset] = vc
}

put_string :: proc(s: string, offset := 0) {
    offset := offset
    for c in s {
        put_char(byte(c), offset)
        offset += 1
    }
}
