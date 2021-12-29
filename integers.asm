;   ==============================  RGB2ASCII  ================================
;
;   Author:         Craig Opie
;   Date:           2021-10-14
;   Version:        1.0.0
;   UH Username:    opieca
;   Description:    Assembly Program that takes a string of binary values that
;   ===========================================================================

;   =========================  Initial Definitions  ===========================

;******************************************************************************
;   Include Statements
;******************************************************************************
%include "asm_io.inc"

;******************************************************************************
;   Static Variable Initialization
;******************************************************************************
segment .data
        msg1            db              "Enter an integer: ", 0
        char_str        db              "0123456789ABCDEF", 0                   ; this is where the hex chars are pulled from

;******************************************************************************
;   Global and Static Variable Declaration
;******************************************************************************
segment .bss
        hex_            resd            9                                       ; value stores the hex result in char format


;******************************************************************************
;   Define Instructions
;******************************************************************************
segment .text
        global          asm_main

;   ============================  Main   Function  ============================

asm_main:
        ;**********************************************************************
        ;   Perform Program Setup
        ;**********************************************************************
        enter           0,0
        pusha

        ;**********************************************************************
        ;   Main Function
        ;**********************************************************************
        mov             eax, msg1
        call            print_string                                            ; prompts user for integer
        mov             ebx, hex_
        add             ebx, 8                                                  ; go to the end of the hex_ array and
        mov             [ebx], byte 0                                           ; terminate with a null char to make a string
        dec             ebx                                                     ; traverse the hex_ array backwards for populating
        call            read_int                                                ; read the users input
        call            int_to_hex
        mov             eax, hex_
        call            print_string                                            ; print the hex value to the user

        ;**********************************************************************
        ;   Perform Program Cleanup
        ;**********************************************************************
        popa
        mov             eax, 0
        mov             ebx, 0
        mov             ecx, 0
        mov             edx, 0
        leave
        ret
        
;******************************************************************************
;   32-bit Integer to Hex Conversion
;******************************************************************************
int_to_hex:
        mov             ecx, char_str
        mov             edx, 0xF                                                ; create the mask to ensure only the lowest nibble
        and             edx, eax                                                ; is stored in edx
inc_loop:
        cmp             edx, 0                                                  ; iterate through the char_str to find the correct
        jz              exit_inc_loop                                           ; hex symble that corresponds to the int value
        inc             ecx
        dec             edx
        jmp             inc_loop
exit_inc_loop:
        mov             dl, [ecx]
        mov             [ebx], dl                                               ; store the hex char in the hex_ array
        dec             ebx                                                     ; traverse the array in reverse to the next char
        shr             eax, 4                                                  ; divide the users input by 16 to get the next char
        cmp             eax, 0                                                  ; check to see if the users input is at zero
        jg              int_to_hex                                              ; and exit the loop because there isn't anything else
        mov             eax, hex_                                               ; load the starting address for hex_ for the next cmp
fill_zeros:
        cmp             eax, ebx                                                ; check to make ensure we haven't traversed the start
        jg              exit_fill                                               ; of the array in reverse and exit if we did
        mov             [ebx], byte 48                                          ; otherwise, store a 0 char in the hex_ array which
        dec             ebx                                                     ; looks like the prefix 0's when printed
        jmp             fill_zeros
exit_fill:
        ret