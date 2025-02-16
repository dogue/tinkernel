#!/usr/bin/env bash

clean() {
    if [ -d "build" ]; then
        rm -rf ./build
    fi
}

build_kernel() {
    odin build . -build-mode:object -no-crt -target:freestanding_amd64_sysv -out:build/kernel.o -no-thread-local -reloc-mode:static -default-to-panic-allocator -debug -no-entry-point -disable-red-zone -use-single-module
}

build_bootloader() {
    nasm -f elf64 boot.s -o build/boot.o

    if [ ! -f "build/multiboot_header.o" ]; then
        nasm -f elf64 multiboot_header.s -o build/multiboot_header.o
    fi
}

link_all() {
    ld --nmagic --output=build/kernel.bin --script=linker.ld build/kernel.o build/multiboot_header.o build/boot.o
}

build_iso() {
    grub-mkrescue -o build/kernel.iso build/isofiles
}

build() {
    clean
    mkdir -p build/isofiles/boot/grub
    cp grub.cfg build/isofiles/boot/grub
    build_kernel
    build_bootloader
    link_all
    cp build/kernel.bin build/isofiles/boot
    build_iso
}

run() {
    qemu-system-x86_64 -cdrom build/kernel.iso -m 500M
}

print_help() {
    cat << 'EOF'
Commands:
    c, clean    clean build artifacts
    b, build    build the kernel, bootloader, and ISO
    r, run      run the kernel in QEMU
EOF
    exit 0
}

case "${1:-}" in
    "c" | "clean")  clean;;
    "b" | "build")  build;;
    "r" | "run")    build && run;;
    *)              print_help;;
esac
