package meminfo

Memory_Info :: struct {
    region: int,
    base_addr: u64,
    size: u64,
}

meminfo: Memory_Info

init :: proc(region: int, base, size: u64) {
    meminfo = Memory_Info{ region, base, size }
}


