package multiboot

Multiboot_Info :: struct #packed {
    total_size: u32,
    reserved: u32,
}

Multiboot_Tag :: struct #packed {
    type: u32,
    size: u32,
}

Multiboot_Memory_Map :: struct #packed {
    type: u32,
    size: u32,
    entry_size: u32,
    entry_version: u32,
    entries: [^]Memory_Map_Entry,
}

Memory_Map_Entry :: struct #packed {
    base_addr: u64,
    len: u64,
    type: u32,
    reserved: u32,
}

find_memory_map :: proc (mb_info: ^Multiboot_Info) -> ^Multiboot_Memory_Map {
    align_up :: proc(val: u32, align: u32) -> u32 {
        return (val + (align - 1)) & ~(align - 1)
    }

    curr := uintptr(mb_info) + size_of(Multiboot_Info)
    end := uintptr(mb_info) + uintptr(mb_info.total_size)

    for curr < end {
        tag := (^Multiboot_Tag)(rawptr(curr))
        if tag.type == 6 {
            return (^Multiboot_Memory_Map)(rawptr(curr))
        }
        curr += uintptr(align_up(tag.size, 8))
    }

    return nil
}
