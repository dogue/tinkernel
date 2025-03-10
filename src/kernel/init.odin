package kernel

import "base:runtime"
import "core:slice"
import "core:math/bits"
import "core:mem"
import "../drivers/vga"
import mb "multiboot"
import "core:log"

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

// This data should only be accessed via the context returned by default_context()
@(private = "file")
KCTX: runtime.Context
@(private = "file")
KALLOC: runtime.Allocator
@(private = "file")
_KALLOC_BUDDY: mem.Buddy_Allocator

default_context :: proc() -> runtime.Context {
    return KCTX
}

init :: proc "contextless" (mb_info: ^mb.Multiboot_Info) -> runtime.Context {
    KCTX.logger = kernel_logger_init(.Info)
    KCTX.assertion_failure_proc = kpanic
    context = KCTX

    klog(.Info, "calling _startup_runtime")
    #force_no_inline _startup_runtime()

    klog(.Info, "parsing multiboot memory map")
    memory_map := mb.find_memory_map(mb_info)
    if memory_map == nil {
        panic("memory map is nil")
    }

    entry_count := (memory_map.size - 16) / size_of(mb.Memory_Map_Entry)
    entries_ptr := (^mb.Memory_Map_Entry)(&memory_map.entries)
    entries := slice.from_ptr(entries_ptr, int(entry_count))

    region_base_addr := (^u8)(uintptr(entries[3].base_addr))
    region_size := uint(1) << bits.log2(uint(entries[3].len))
    region := slice.from_ptr(region_base_addr, int(region_size))

    klog(.Info, "initializing kernel allocator")
    mem.buddy_allocator_init(&_KALLOC_BUDDY, region, 8)
    KALLOC = mem.buddy_allocator(&_KALLOC_BUDDY)
    KCTX.allocator = KALLOC
    context.allocator = KALLOC

    log.infof("memory region base address: 0x%X", region_base_addr)
    log.infof("memory region size: %d bytes", region_size)

    log.info("Initializing interrupt descriptor table")
    init_idt()

    log.info("Initializing local APIC and legacy PIC")
    init_apic()

    return default_context()
}

