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

LBUF 			times COLS db 00h			;the reading buffer

PGM				times 256 * COLS db 00h		;the PGM area (256 lines * 80 byte)
PGP				db	00h						;PGP (pointer to pgp line)

CURSOR			dw	0000h					;line cursor

;list of language keywords
LIST_STR		db "LIST",00h
RUN_STR			db "RUN",00h
CLEAR_STR		db "CLEAR",00h

;list of available errors
SYNTAX_ERROR	db "Syntax error",00h					
LINE_ERROR		db "Invalid line number",00h

;==============================================================================
; MAIN PROGRAM
;==============================================================================

START:

		call	INIT					;INITIALIZE
		call	NLINE					;WRITE CRLF

;COLLECTION ROUTINE

CO:     call	GETLINE					;WRITE PROMPT AND GET LINE

		call	NLINE					;WRITE CRLF

		call	TSTL                	;TEST FOR LINE NUMBER

		cmp		al,00h					;compare with 0
		jl		CO						;if less we have an error
		je		XEC						;if equals execute directly

		call	INSERT        			;INSERT IT (MAY BE DELETE)

		jmp     CO

XEC:    call	XINIT                 	;INITIALIZE

;STATEMENT EXECUTOR

; S14:    TST     S15,'LIST'    			;LIST COMMAND
;         DONE
;         LST
;         NXT
		
S14:    
		mov		dx,LIST_STR
		call	TST
		xor		dx,dx
		mov		dl,al
		call	PRINT_NUMBER
		
		jmp		CO

S17:    call	ERR	          			;SYNTAX ERROR

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

		mov		[CURSOR],word PGM		;clear the CURSOR

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
		jc		.err					;if carry error

		add		al,cl					;add the the CL value
		jc		.err					;if carry error
		
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
		mov		dx,LINE_ERROR			;select error string
		call	PRINT_STR				;print error string
		call	NLINE					;print new line
		mov		al,-1					;we return -1 in AL for errors
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
LST_COUNTER		db 00h					;line counter
;------------------------------------------------------------------------------
LST:
		mov		[LST_COUNTER],byte 00h	;reset counter variable
		mov		di,PGM					;init DI as base pointer to PGM

	.cycle:
		cmp		di,PGM+256*80			;is this the last line ?
		jge		.done					;if yes exit

		cmp		[di],byte 00h			;is an empty line ?
		je		.next					;skip it

		xor		dx,dx					;clear dx
		mov		dl,[LST_COUNTER]		;get the line counter
		call	PRINT_NUMBER			;print the line number

		mov		dx,di					;copy the start of the line
		call	PRINT_STR				;call print line
		call	NLINE					;add a new line

	.next:
		add		di,COLS					;move to the next line
		inc		byte [LST_COUNTER]		;increase line counter
		jmp		.cycle					;repeat

	.done:
		ret

;==============================================================================	
; XINIT Perform initialization for each stated execution. Empties AEXP stack.
;==============================================================================	
XINIT:
		mov     al,00h            		;the value to initialize the buffer
        mov		di,LBUF       			;clear LBUF
        mov     cx,COLS		          	;size of bufffer
		rep		stosb                   ;repeat

		mov		[CURSOR],word PGM
		ret

;==============================================================================	
; ERR	Report syntax error am return to line collect routine.
;==============================================================================	
ERR:
		mov		dx,SYNTAX_ERROR			;select syntax error string
		call	PRINT_STR				;print the string
		call	NLINE					;print new line
		jmp		CO						;jmp to collection routine
										;NOTE : no return

;==============================================================================	
; TST lbl,'string'  	
; - delete leading blanks
; - If string matches the BASIC line, 
; advance cursor over the matched string and execute the next IL instruction 
; - If a match fails, execute the IL instruction at the labled lbl.
; Expect in DX the string to compare
; Return in AL : 0 == no match, 1 == match
;==============================================================================	
TST:
		xor		al,al					;clear AL

	.skip_blanks:
		cmp		[CURSOR],byte 00h		;is EOL ?
		je		.nomatch				;possible error

		cmp		[CURSOR],byte 20h			;is a blank ?
		jg		.compare					;no, check the string
		
		inc		word [CURSOR]				;increase cursor
		jmp		.skip_blanks			;check next char

	.compare:

		xor		cx,cx					;clear CX (counter of strlen)
		mov		bx,dx					;copy in BX ths start of the string

	.strlen:							;calculate the len of the string
		cmp		[bx],byte 00h
		je		.strcmp
		inc		cx
		jmp		.strlen

	.strcmp:
		mov     si,[CURSOR]      			;SI equal to CURSOR current pos
        mov     di,dx     				;DX is the start of the str to compare
        repe    cmpsb           		;equals ?
        jne     .nomatch        		;nope

	.match: 								;if here strings are equals
		add		[CURSOR],cx				;update the cursor

		mov		al,1					;set AL for mathc found
		ret

	.nomatch:
		ret								;AL already cleared

;==============================================================================
; DONE 	Report a syntax error if after deletion leading blanks the 
; cursor is not positioned to road a carriage return.
;==============================================================================
DONE:
	.skip_blanks:
		cmp		[CURSOR],byte 00h		;is EOL ?
		je		.done				

		cmp		[CURSOR],byte 20h			;is a blank ?
		jg		.err					;no, check the string
		
		inc		word [CURSOR]				;increase cursor
		jmp		.skip_blanks			;check next char

	.err:

		mov		dx,SYNTAX_ERROR
		call	PRINT_STR
		call	NLINE
		ret

	.done:
		ret

;==============================================================================
; Program end
;==============================================================================
%INCLUDE "SRC/FUNCS.ASM"				;required to use core functions
