package kernel

import "base:runtime"
import "core:slice"
import "core:math/bits"
import "core:mem"
import "vga"
import mb "multiboot"
import "meminfo"
import "arch"

foreign {
    @(link_name = "__$startup_runtime")
    _startup_runtime :: proc "odin" () ---
    @(link_name = "__$cleanup_runtime")
    _cleanup_runtime :: proc "odin" () ---
}

foreign {
    @(link_name="kernel_phys_start")
    kernel_phys_start: uintptr
}

KCTX: runtime.Context
KALLOC: runtime.Allocator
_KALLOC_BUDDY: mem.Buddy_Allocator

panic :: proc "contextless" (msg: string) -> ! {
    vga.print("[PANIC]: ")
    vga.println(msg)
    for {}
}

init :: proc "contextless" (mb_info: ^mb.Multiboot_Info) -> runtime.Context {
    context = KCTX
    #force_no_inline _startup_runtime()

    mb_info := mb_info

    memory_map := mb.find_memory_map(mb_info)
    if memory_map == nil {
        panic("Memory map is nil")
    }

    entry_count := (memory_map.size - 16) / size_of(mb.Memory_Map_Entry)
    entries_ptr := (^mb.Memory_Map_Entry)(&memory_map.entries)
    entries := slice.from_ptr(entries_ptr, int(entry_count))

    region_base_addr := (^u8)(uintptr(entries[3].base_addr))
    region_size := uint(1) << bits.log2(uint(entries[3].len))
    region := slice.from_ptr(region_base_addr, int(region_size))

    meminfo.init(3, entries[3].base_addr, u64(region_size))

    mem.buddy_allocator_init(&_KALLOC_BUDDY, region, 8)
    KALLOC = mem.buddy_allocator(&_KALLOC_BUDDY)
    KCTX.allocator = KALLOC
    context.allocator = KALLOC

    vga.clear()

    vga.println("REGIONS:")
    for entry, i in entries {
        type: string
        switch entry.type {
        case 1: type = "available"
        case 2: type = "reserved"
        case 3: type = "ACPI reclaimbable"
        case 4: type = "ACPI NVS"
        case 5: type = "bad memory"
        case: type = "unknown"
        }

        if type == "reserved" do continue


        vga.printfln("\tREGION %d:", i)
        vga.printfln("\t\tTYPE: %s", type)
        vga.printfln("\t\tBASE: %x", entry.base_addr)
        vga.printfln("\t\t LEN: %d", entry.len)
        vga.println("")
    }

    // arch.enable_apic_simple()
    vga.printfln("APIC BASE: 0x%X", arch.test_func())
    // vga.printfln("APIC ID: %d", arch.read_apic_id())
    vga.printfln("KERNEL LOADED AT 0x%X", kernel_phys_start)

    return default_context()
}

default_context :: proc() -> runtime.Context {
    return KCTX
}
