;==============================================================================
; Nasm directives
;==============================================================================
[CPU 8086]
[BITS 16]
[ORG 7C00h]

        jmp     BOOT                    ;jump to boot section

;==============================================================================
; Const
;==============================================================================
STACK_SEG       EQU 1000h
STACK_OFF       EQU 0FFFFh

PROG_SEG 	    EQU 2000h
PROG_OFF 	    EQU 0000h

ROWS            EQU 25
COLS            EQU 80

FG_COLOR        EQU 0Eh
BG_COLOR        EQU 10h

;==============================================================================
; Variables section
;==============================================================================
DEVICE          db 00h

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

        mov     ah,06h                  ;clear screen service
        mov     al,00h                  ;lines to scroll (if 0 all)
        mov     bh,BG_COLOR | FG_COLOR    ;background/foreground colors
        mov     ch,00h                  ;Row number of upper left corner
        mov     cl,00h                  ;Column number of upper left corner
        mov     dh,ROWS-1               ;Row number of lower right corner
        mov     dl,COLS-1               ;Column number of lower right corner
        int     10h                     ;call int to clear the screen
        
        mov     ax,PROG_SEG             ;set program segment
        mov     es,ax
        mov     bx,PROG_OFF          	;set program offset
        
        mov     ah,02h                  ;disk read function
        mov     al,40h                  ;number of sectors to read
        mov     ch,00h                  ;starting from cylinder
        mov     cl,02h 					;starting from sector (1st is boot)
        mov     dh,00h                  ;starting from head
        mov     dl,[DEVICE]
        int     13h                     ;call interrupt service,
                                        ;dl is already set and untouched

        jnc    	.boot_ok                ;CF clear ok, continue

                                        ;if here error,print a sad face '☻'
                                        ;and halt the system

        mov     ah,0Eh                  ;teletype print interupt
        mov     al,02h                  ;char to print
        mov     bh,00h                  ;page
        int     10h                     ;call interrupt

        hlt                             ;halt program (cli already disabled)

    .boot_ok:

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


;==============================================================================
; Loader end
;==============================================================================
TIMES 510-($-$$) DB 00h                 ;fill the remaining space with zeroes

DW 0xAA55                               ;fill the remaining 2 bytes with the m
                                        ;magic for boot (0xAA55)