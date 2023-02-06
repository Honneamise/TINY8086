;==============================================================================
; Nasm directives
;==============================================================================
[CPU 8086]
[BITS 16]
[ORG 7C00h]

;==============================================================================
; Const
;==============================================================================
STACK_SEG       EQU 1000h
STACK_OFF       EQU 0FFFFh

PROG_SEG 	    EQU 2000h
PROG_OFF 	    EQU 0000h

;==============================================================================
; Bootloader, read disk sectors to memory dest ES:BX
; NOTE: at power-on, DL will contain the boot device id
;==============================================================================
BOOT:  
        mov     [DEVICE],dl             ;save boot device id

        cli                             ;disable interrupt
        cld                             ;clear DF flag
        clc                             ;clear carry flag

        mov     ax,0003h                ;set video mode Text 80x25
        int     10h                     ;call video interrupt

        mov     ah,05h                  ;set active page
        mov     al,0000h                ;display page, we always use page 0
        int     10h

    .load:  
        mov     ax,PROG_SEG             ;set program segment
        mov     es,ax
        mov     bx,PROG_OFF          	;set program offset
        
        mov     ah,02h                  ;disk read function
        mov     al,40h                  ;number of sectors to read
        mov     ch,00h                  ;starting from cylinder
        mov     cl,02h 					;starting from sector (1st is boot)
        mov     dh,00h                  ;starting from head
        mov     dl,[DEVICE]             ;device to read from
        int     13h                     ;call interrupt service

        jc    	ERR                     ;CF NOT clear, error

    .load_ok:

		mov     ax,PROG_SEG          	;setup data segment and extra segment
        mov     ds,ax
		mov     es,ax

        mov     ax,STACK_SEG            ;setup stack segment
        mov     ss,ax        

        mov     ax,STACK_OFF            ;setup base pointer and stack pointer
        mov     bp,ax       
        mov     sp,ax

        sti                             ;re-enable interrupts

        jmp     PROG_SEG:PROG_OFF       ;jump to the program location

ERR:
        mov     ah,0Eh                  ;teletype print interupt
        mov     bh,00h                  ;page
        mov     si,ERROR_STR            ;string pointer

    .cycle:
        mov     al,[si]                 ;char to print
        cmp     al,00h                  ;EOL ?
        je      .end
        int     10h                     ;call interrupt
        inc     si
        jmp     .cycle

    .end:
        hlt                             ;halt program (cli already disabled)

;==============================================================================
; Variables section
;==============================================================================
DEVICE          db 00h
ERROR_STR       db "LOADING ERROR",00h	

;==============================================================================
; Bootloader end
;==============================================================================
TIMES 510-($-$$) DB 00h                 ;fill the remaining space with zeroes

DW 0xAA55                               ;fill the remaining 2 bytes with the
                                        ;magic number for boot (0xAA55)