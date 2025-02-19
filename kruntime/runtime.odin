package kruntime

import "core:slice"
import "core:math/bits"
import "core:mem"
import "base:runtime"
import "../vga"

foreign {
    @(link_name = "__$startup_runtime")
    _startup_runtime :: proc "odin" () ---
    @(link_name = "__$cleanup_runtime")
    _cleanup_runtime :: proc "odin" () ---
}

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

@(private)
Runtime_State :: struct {
    mb_info: ^Multiboot_Info,
    mmap_entries: []Memory_Map_Entry,
    allocator: mem.Buddy_Allocator,
    ctx: runtime.Context,
    mem_base: u64,
    mem_size: u64,
}

@(private)
kernel_rt := Runtime_State{}

init :: proc "contextless" (mb_info: ^Multiboot_Info) -> runtime.Context {
    context = {}
    #force_no_inline _startup_runtime()

    kernel_rt.mb_info = mb_info
    context = kernel_rt.ctx

    mem_map := find_mmap(mb_info)
    if mem_map == nil {
        panic("Memory map is nil")
    }

    entry_count := (mem_map.size - 16) / size_of(Memory_Map_Entry)
    entries_ptr := (^Memory_Map_Entry)(&mem_map.entries)
    entries := slice.from_ptr(entries_ptr, int(entry_count))

    region_base_addr := (^u8)(uintptr(entries[3].base_addr))
    region_size := uint(1) << bits.log2(uint(entries[3].len))
    region := slice.from_ptr(region_base_addr, int(region_size))

    mem.buddy_allocator_init(&kernel_rt.allocator, region, 8)
    kernel_rt.ctx.allocator = mem.buddy_allocator(&kernel_rt.allocator)
    kernel_rt.mem_base = entries[3].base_addr
    kernel_rt.mem_size = u64(region_size)

    return kernel_rt.ctx
}

ctx :: proc "contextless" () -> runtime.Context {
    return kernel_rt.ctx
}

find_mmap :: proc (mb_info: ^Multiboot_Info) -> ^Multiboot_Memory_Map {
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

meminfo :: proc() -> (base_addr: u64, size: u64) {
    return kernel_rt.mem_base, kernel_rt.mem_size
}

panic :: proc "contextless" (msg: string) -> ! {
    vga.print("[PANIC]: ")
    vga.println(msg)
    for {}
}
