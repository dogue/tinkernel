package kernel

import "vga"
import "core:slice"
import "base:runtime"
import "core:mem"
import "core:fmt"
import "core:math/bits"

BUILD_HASH :: #config(BUILD_HASH, "unknown")

foreign _ {
    @(link_name = "__$startup_runtime")
    _startup_runtime :: proc "odin" () ---
    @(link_name = "__$cleanup_runtime")
    _cleanup_runtime :: proc "odin" () ---
}

Multiboot_Info :: struct #packed {
    total_size: u32,
    reserved: u32
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
    entries: [0]Memory_Map_Entry,
}

Memory_Map_Entry :: struct #packed {
    base_addr: u64,
    len: u64,
    type: u32,
    reserved: u32,
}

@(export, link_name = "kmain", require)
kmain :: proc "contextless" (mb_info: ^Multiboot_Info, mb_magic: u32) -> ! {
    context = {}
    #force_no_inline _startup_runtime()

    vga.clear()

    if mb_magic != 0x36d76289 {
        vga.print("BAD BOOT :(")
        halt_catch_fire()
    }

    mmap := find_mmap(mb_info)
    if mmap == nil {
        vga.print("No memory map found\n:(")
        halt_catch_fire()
    }

    entry_count := (mmap.size - 16) / size_of(Memory_Map_Entry)
    entries := transmute([]Memory_Map_Entry)runtime.Raw_Slice{
        data = &mmap.entries,
        len = int(entry_count),
    }

    kalloc: mem.Buddy_Allocator
    base_ptr := (^u8)(uintptr(entries[3].base_addr))
    size := int(entries[3].len)
    size_aligned := uint(1) << bits.log2(uint(size))
    mem_block := slice.from_ptr(base_ptr, int(size_aligned))
    mem.buddy_allocator_init(&kalloc, mem_block, 8)
    context.allocator = mem.buddy_allocator(&kalloc)

    vga.printfln("Tinkernel - build: %s", BUILD_HASH)
    vga.printf("Total available mem: %d MB", size_aligned / 1024 / 1024)

    halt_catch_fire()
}

halt_catch_fire :: proc() -> ! {
    for {}
}

find_mmap :: proc (mb_info: ^Multiboot_Info) -> ^Multiboot_Memory_Map {
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

align_up :: proc(val: u32, align: u32) -> u32 {
    return (val + (align - 1)) & ~(align - 1)
}

