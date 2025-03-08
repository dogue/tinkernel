#!/usr/bin/env bash

declare -a ASM_FILES

clean() {
    if [ -d "build" ]; then
        rm -rf ./build
    fi
}

build_kernel() {
    odin build src -build-mode:object -no-crt -target:freestanding_amd64_sysv -out:build/kernel.o -no-thread-local -reloc-mode:static -default-to-panic-allocator -debug -no-entry-point -disable-red-zone -use-single-module
}

build_bootloader() {
    nasm -f elf64 util/boot.s -o build/boot.o

    if [ ! -f "build/multiboot_header.o" ]; then
        nasm -f elf64 util/multiboot_header.s -o build/multiboot_header.o
    fi
}

build_asm() {
    for asm_file in ./src/kernel/x86/*.s; do
        outpath=build/$(basename $asm_file .s).o
        nasm -f elf64 $asm_file -o build/$(basename $asm_file .s).o
        ASM_FILES+=($outpath)
    done
}

link_all() {
    ld --nmagic --output=build/kernel.bin --script=util/linker.ld build/kernel.o build/multiboot_header.o build/boot.o ${ASM_FILES[@]}
}

build_iso() {
    grub-mkrescue -o build/kernel.iso build/isofiles
}

build() {
    clean
    mkdir -p build/isofiles/boot/grub
    cp util/grub.cfg build/isofiles/boot/grub
    build_asm
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
