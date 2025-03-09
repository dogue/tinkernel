package keyboard

foreign import kb "keyboard.s"

@(default_calling_convention = "sysv")
foreign kb {
    read_scancode :: proc() -> u8 ---
}
