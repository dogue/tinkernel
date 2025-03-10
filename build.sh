#!/usr/bin/env bash

declare -a ASM_FILES

# clean up
if [ -d "build" ]; then
    rm -rf ./build
    mkdir build
fi

# build bootloader
nasm -f elf64 src/boot/multiboot_header.s -o build/multiboot_header.o
nasm -f elf64 src/boot/boot.s -o build/boot.o

# build asm wrappers
for asm_file in ./src/asm/*.s; do
    outpath=build/$(basename $asm_file .s).o
    nasm -f elf64 $asm_file -o build/$(basename $asm_file .s).o
    ASM_FILES+=($outpath)
done

# build kernel
odin build src -build-mode:object -no-crt -target:freestanding_amd64_sysv -out:build/kernel.o -no-thread-local -reloc-mode:static -default-to-panic-allocator -debug -no-entry-point -disable-red-zone -use-single-module

# link
ld --nmagic --output=build/kernel.bin --script=linker.ld build/kernel.o build/multiboot_header.o build/boot.o ${ASM_FILES[@]}

# create boot iso
mkdir -p build/isofiles/boot/grub
cp src/boot/grub.cfg build/isofiles/boot/grub
cp build/kernel.bin build/isofiles/boot
grub-mkrescue -o build/kernel.iso build/isofiles

# boot the kernel
if [ "$1" == "run" ] || [ "$1" == "r" ]; then
    qemu-system-x86_64 -cdrom build/kernel.iso -m 500M
fi
