;   ==============================  RGB2ASCII  ================================
;
;   Author:         Craig Opie
;   Date:           2021-11-09
;   Version:        1.0.0
;   UH Username:    opieca
;   Description:    Assembly Program that decodes an image
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

;******************************************************************************
;   Global and Static Variable Declaration
;******************************************************************************
segment .bss
        width_          resd            1
        height_         resd            1
        col_            resd            1
        row_            resd            1
        coded_pixel_    resd            1
        scrambler_      resd            1
        red_            resd            1
        green_          resd            1
        blue_           resd            1

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
        call            init
        call            scan_pixels

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
;   Initialize Variables
;******************************************************************************
init:
        ;**********************************************************************
        ;   Initialize Column and Row to Zero
        ;**********************************************************************
        mov             eax, col_
        mov             [eax], dword 0
        mov             eax, row_
        mov             [eax], dword 0

        ;**********************************************************************
        ;   Initialize Width and Height to Real Values
        ;**********************************************************************
        mov             ebx, width_
        mov             ecx, height_
        call            read_int
        call            print_int
        call            print_nl
        mov             [ebx], eax
        call            read_int
        call            print_int
        call            print_nl
        mov             [ecx], eax
        ret

;******************************************************************************
;   Initialize Variables
;******************************************************************************
scan_pixels:
        call            load_coded_pixel
        call            descramble
        mov             eax, col_
        mov             ebx, dword [width_]
        add             [eax], dword 1
        cmp             [eax], ebx
        jl              scan_pixels
        mov             [eax], dword 0
        mov             ecx, row_
        mov             edx, dword [height_]
        add             [ecx], dword 1
        cmp             [ecx], edx
        jl              scan_pixels
        ret

;******************************************************************************
;   Load Coded Pixel Into Array
;******************************************************************************
load_coded_pixel:
        mov             ebx, coded_pixel_
        mov             ecx, 0
        call            read_int
        mov             cx, ax
        shl             ecx, 8
        call            read_int
        or              cx, ax
        shl             ecx, 8
        call            read_int
        or              cx, ax
        mov             [ebx], ecx
        mov             eax, ecx
        ret

;******************************************************************************
;   Descramble The Pixel
;******************************************************************************
descramble:
        ;**********************************************************************
        ;   Setup the Registers for Multiplication
        ;**********************************************************************
        mov             eax, dword 101231
        mov             ebx, col_
        mov             edx, 0

        ;**********************************************************************
        ;   Perform the First Multiplication of 101231 * col_
        ;**********************************************************************
        mul             dword [ebx]
        mov             edx, 0

        ;**********************************************************************
        ;   Multiply the Previous Result by col_ again
        ;**********************************************************************
        mul             dword [ebx]
        mov             edx, scrambler_
        mov             [edx], eax

        ;**********************************************************************
        ;   Setup the Registers for the Second Multiplication
        ;**********************************************************************
        mov             eax, dword 41231
        mov             ebx, row_
        mov             edx, 0

        ;**********************************************************************
        ;   Perform the First Multiplication of 41231 * row_
        ;**********************************************************************
        mul             dword [ebx]
        mov             edx, 0

        ;**********************************************************************
        ;   Multiply the Previous Result by row_ again
        ;**********************************************************************
        mul             dword [ebx]
        mov             edx, scrambler_
        add             [edx], eax

        ;**********************************************************************
        ;   Exclusive OR the scrambler_ with the coded_pixel_
        ;**********************************************************************
        mov             ebx, coded_pixel_
        mov             ecx, [ebx]
        xor             ecx, [edx]
        mov             [ebx], ecx

        ;**********************************************************************
        ;   Decode the Real Green Values
        ;**********************************************************************
        mov             eax, green_
        mov             [eax], cx
        and             [eax], dword 0xFF

        ;**********************************************************************
        ;   Decode the Real Red Values
        ;**********************************************************************
        shr             ecx, 5
        mov             edx, ecx
        and             edx, dword 0xF8
        mov             eax, ecx
        shr             eax, 16
        and             eax, dword 0x7
        or              edx, eax
        mov             eax, red_
        mov             [eax], dx

        ;**********************************************************************
        ;   Decode the Real Blue Values
        ;**********************************************************************
        shr             ecx, 8
        and             ecx, 0xFF
        mov             eax, blue_
        mov             [eax], cx
        and             [eax], dword 0xFF

        ;**********************************************************************
        ;   Print the Real RGB Values
        ;**********************************************************************
        mov             eax, dword [red_]
        call            print_int
        call            print_nl
        mov             eax, dword [green_]
        call            print_int
        call            print_nl
        mov             eax, dword [blue_]
        call            print_int
        call            print_nl
        ret
