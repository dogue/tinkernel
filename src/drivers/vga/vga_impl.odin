#+private
package vga

import "base:runtime"
import "core:slice"
import "base:intrinsics"

BUF := cast([^]VGA_Char)uintptr(0xb8000)

BLANK_CHAR :: VGA_Char {}
DEFAULT_CHAR := VGA_Char {
    char = 0,
    fg = .LightGray,
    bg = .Black,
    blink = false,
}

VGA_Char :: bit_field u16 {
    char:  byte  | 8,
    fg:    Color | 4,
    bg:    Color | 3,
    blink: bool  | 1,
}

cursor := [2]int{0, 0}

write :: proc "contextless" (c: VGA_Char) {
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

cr :: #force_inline proc "contextless" () {
    cursor.x = 0
    cursor.y += 1

    if cursor.y >= 25 {
        scroll()
    }
}

scroll :: proc "contextless" () {
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

put_char :: proc "contextless" (c: byte) {
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

put_string :: proc "contextless" (s: string) {
    for c in s {
        put_char(byte(c))
    }
}

kprint_int :: proc "contextless" (n: u64) {
    if n == 0 {
        put_char('0')
        return
    }

    tmp: [100]u8
    n := n

    i := 0
    for n != 0 {
        r := n % 10
        tmp[i] = u8(r) + 0x30
        i += 1
        n /= 10
    }

    for j := i - 1; j >= 0; j -= 1 {
        put_char(byte(tmp[j]))
    }
}

kprint_hex :: proc "contextless" (n: $T) where intrinsics.type_is_integer(T) {
    if n == 0 {
        put_char('0')
        return
    }

    tmp: [100]u8
    n := n

    i := 0
    for n != 0 {
        r := n % 16
        if r < 10 {
            tmp[i] = u8(r) + 0x30
        } else {
            tmp[i] = u8(r) + 0x37
        }
        i += 1
        n /= 16
    }

    for j := i - 1; j >= 0; j -= 1 {
        put_char(byte(tmp[j]))
    }
}
