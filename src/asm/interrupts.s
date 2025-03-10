bits 64

global read_cr2
read_cr2:
    mov rax, cr2
    ret

global load_idt
load_idt:
    mov rax, rdi
    lidt [rax]
    ret

global isr_common
isr_common:
    pop r11 ; interrupt num
    pop r10 ; error

    push rax
    push rbx
    push rcx
    push rdx
    push rbp
    push rsi
    push rdi
    push r8
    push r9
    ; push r10
    ; push r11
    push r12
    push r13
    push r14
    push r15

    mov rdi, r11
    mov rsi, r10

    ; kernel code handler
    ; interrupt is cleared by the handler
    extern interrupt_handler
    call interrupt_handler

    pop r15
    pop r14
    pop r13
    pop r12
    ; pop r11
    ; pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rbp
    pop rdx
    pop rcx
    pop rbx
    pop rax

    iretq

; ISR handlers
%macro ISR_STUB 1
global isr%1
isr%1:
    cli
    %if !(%1 == 8 || (%1 >= 10 && %1 <= 14) || %1 == 17 || %1 == 21 || %1 == 29 || %1 == 30)
    push qword 0  ; no error code, push dummy
    %endif
    push qword %1  ; push interrupt number
    jmp isr_common
%endmacro

; generate handlers for all interrupts
%assign i 0
%rep 34
    ISR_STUB i
%assign i i+1
%endrep
