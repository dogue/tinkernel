package vga

import "base:runtime"

@(private)
BUF := cast([^]VGA_Char)uintptr(0xb8000)

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
cursor := [2]int{0, 0}

@(private)
write :: proc(c: VGA_Char) {
    switch c.char {
    case '\n':
        cr()
        return

    case '\t':
        if cursor.x + 4 < 80 {
            cursor.x += 4
        } else {
            cr()
        }
        return
    }

    BUF[(cursor.y * 80) + cursor.x] = c
    cursor.x += 1

    if cursor.x >= 80 {
        cr()
    }

}

@(private)
cr :: #force_inline proc() {
    cursor.x = 0
    cursor.y += 1

    if cursor.y >= 25 {
        scroll()
    }
}

@(private)
scroll :: proc() {
    scr: [^]VGA_Char
    temp := cursor.y - 25 + 1
    // yeah it's ugly, so what?
    runtime.mem_copy(&BUF[0], &BUF[temp * 80], (25 - temp) * 80 * 2)
    runtime.mem_zero(&BUF[(25 - temp) * 80], 80)
    cursor.y = 24
}

clear_line :: proc() {
    pos := cursor.x
    cursor.x = 0
    for i in 0..<80 {
        BUF[(cursor.y * 80) + cursor.x] = BLANK_CHAR
    }
    cursor.x = pos
}

clear :: proc() {
    for i in 0..<80 * 25 {
        BUF[i] = BLANK_CHAR
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
