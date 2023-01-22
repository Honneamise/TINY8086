;==============================================================================
; Nasm directives
;==============================================================================
[CPU 8086]
[BITS 16]
[ORG 00h]

		mov		dx,INTP_STR					;print welcome string
		call	PRINT_STR

		jmp		START						;jump to the main program

;==============================================================================
; Const section
;==============================================================================
ROWS            EQU 25
COLS            EQU 80

;==============================================================================
; Vars section
;==============================================================================
INTP_STR 		db "TINY BASIC 8086",00h	;welcome string

SYNTAX_ERROR	db "Syntax error",00h					
LINE_ERROR		db "Invalid line number",00h

LBUF 			times COLS db 00h			;the reading buffer

PGM				times 256 * COLS db 00h		;the PGM area (256 lines * 80 byte)
PGP				db	00h						;PGP (pointer to pgp line)

;==============================================================================
; MAIN PROGRAM
;==============================================================================
START:

;------------------------------------------------------------------------------


;------------------------------------------------------------------------------

		call	INIT					;INITIALIZE

		call	NLINE					;WRITE CRLF

CO:     call	GETLINE					;WRITE PROMPT AND GET LINE

		call	NLINE

		call	TSTL                	;TEST FOR LINE NUMBER

		cmp		al,00h
		je		XEC

		call	INSERT        			;INSERT IT (MAY BE DELETE)

		call	LST
		
        jmp     CO

XEC:    ;call	XINIT                 ;INITIALIZE

END:	cli                             ;disable interrupts
        hlt                             ;halt system


	
;==============================================================================
; Perform global initilization. Clears program area, empties GOSUB stack, etc.
;==============================================================================
INIT:
		
		mov     al,00h            		;the value to initialize the buffer
        mov		di,LBUF       			;clear LBUF
        mov     cx,COLS		          	;size of bufffer
		rep		stosb                   ;repeat

		mov     al,00h            		;the value to initialize the buffer
        mov		di,PGM       			;clear PGM
        mov     cx,256*COLS		        ;size of bufffer
		rep		stosb                   ;repeat

		mov		[PGP],byte 00h			;clear the PGP
		ret

;==============================================================================
; Just print CRLF
;==============================================================================
NLINE:
		mov     ah,0Eh                  ;teletype print interupt
        mov 	al,0Dh                 	;CR
        mov     bh,00h                  ;page
        int     10h                     ;call interrupt
		
		mov		al,0Ah					;LF
		int     10h 					;call interrupt

		ret

;==============================================================================
; Input a line to LBUF
;==============================================================================
GETLINE:

		mov     al,00h            		;the value to initialize the buffer
        mov		di,LBUF       			;clear LBUF
        mov     cx,COLS		          	;size of bufffer
		rep		stosb                   ;repeat

		mov		si,00h					;reset SI (index)

	.cycle:
		xor     ax,ax                   ;keyboard read function
        int     16h						;ah scancode, al ascii code

		cmp		ah,1Ch					;is enter pressed ?
		je		.done					;ok finished

		cmp		ah,0Eh 					;is backspace ?
		je		.backspace

		cmp		si,COLS-1
		jge		.cycle

		mov		bx,LBUF
		mov		[bx+si],al				;store character 
		inc		si

		mov     ah,0Eh                  ;teletype print interupt
        mov     bh,00h                  ;page
        int     10h 

		jmp		.cycle

	.backspace:

		cmp		si,0					;we are at beginning of LBUF
		jle		.cycle					;skip backspace

		dec		si						;dec di and store a blank in LBUF
		mov		bx,LBUF
		mov		[bx+si],byte 00h
		
		mov		bh,00h      			;set page number for all operations

		mov		ah,03h					;get cursor position in DH,DL (row/col)
		int		10h

		dec		dl						;dec the col
		mov		ah,02h					;set cur pos
		int		10h

		mov     ah,0Ah                  ;write character at current cursor pos
		mov		al,20h					;we use empty space
        int     10h

		jmp		.cycle
		
	.done:
		ret

;==============================================================================
;TSTL lbl 	
;After editing leading blanks, look for a line number. 
;Report error if invalid
;Transfer to lbl if not present.
;on exit :
;AL == line number (-1 on error)
;SI == index of first element after the line number
;==============================================================================
TSTL:
		xor		ax,ax					;clear AX
		mov		ch,10					;set ch as multiplier

		mov		bx,LBUF					;get the base address of buffer
		mov		si,00h					;we use SI as index

	.skip_blanks:						;skip leading blanks
		mov		cl,[bx+si]				;get in CL the current char
		cmp		cl,00h					;is EOL ?
		je		.done

		cmp 	cl,byte 20h				;is a BLANK ?
		jg		.get_number				;no go to check if number is present
		inc		si						;next char
		jmp		.skip_blanks			;repeat skip blanks loop

	.get_number:						;check if we have line number

		mov		cl,[bx+si]				;get in cl the current char

		cmp 	cl,30h					;is less than 0 ?
		jl		.done

		cmp 	cl,39h					;is greater than 9 ?
		jg		.done

		sub 	cl,30h					;convert CL ascii to a number 0..9

		mul 	ch						;multiply the content of AL for 10
		add		al,cl					;add the the CL value

		cmp		ax,0FFh					;is line number greater than 255 ?
		jg		.err					;if yes error

		inc 	si						;next char
		jmp		.get_number 			;repeat

	.done:												
		cmp		ax,00h					;do we have a line number ?
		jne		.blank					;if yes verify we are on blank
		ret

	.blank:
		cmp		[bx+si],byte 20h		;we should have a blank after line num
		jg		.err					;if not error
		ret

	.err:
		mov		ax,-1					;line number is invalid
		ret

;==============================================================================
;Insert line after deleting any line with same line number.
;expect in AL == line number, in SI == first element after line number
;==============================================================================
INSERT:
		mov		cx,COLS					;how many to copy
		sub		cx,si

		add		si,LBUF					;prepare source data index

		mov		bl,COLS					;prepare dest data index (PGM+LINE_NUM*COLS)
		mul		bl
		mov		di,ax					
		add		di,PGM

        rep     movsb           		;copy
	
	.done:
		ret

;==============================================================================
;LST 	List the contents of the program area.
;==============================================================================
LST_LINE_COUNTER		db 00h			;line counter
;------------------------------------------------------------------------------
LST:
		mov		di,PGM					;init DI as base pointer to PGM

	.cycle:
		cmp		di,PGM+256*80			;is this the last line ?
		jge		.done					;if yes exit

		cmp		[di],byte 00h			;is an empty line ?
		je		.next					;skip it

		xor		dx,dx					;clear dx
		mov		dl,[LST_LINE_COUNTER]	;get the line counter
		call	PRINT_NUMBER			;print the line number

		mov		dx,di					;copy the start of the line
		call	PRINT_STR				;call print line
		call	NLINE					;add a new line

	.next:
		add		di,COLS					;move to the next line
		inc		byte [LST_LINE_COUNTER]	;increase line counter
		jmp		.cycle					;repeat

	.done:
		ret
		
;==============================================================================
; Program end
;==============================================================================
%INCLUDE "SRC/FUNCS.ASM"				;required to use core functions
