;==============================================================================
; TST lbl,'string'
; Delete leading blanks 
; If string matches the BASIC line, advance cursor over the 
; matched string and execute the next IL instruction.
; If a match fails, execute the IL instruction at the labled lbl.
;
; Expect :
; DX == the string to compare
;
; Return : 
; AL == 0 no match, 1 == match
; [CURSOR] == if mathced first element after matched string
;==============================================================================	
TST_CURBKUP		dw 0000h				;cursor bkup
;------------------------------------------------------------------------------
ILM_TST:
		xor 	al,al					;clear AL

		mov		si,[CURSOR]				;backup the cursor
		mov		[TST_CURBKUP],si	
		
	.skip_blanks:
		cmp		[si],byte 00h			;is EOL ?
		je		.nomatch				;possible error

		cmp		[si],byte 20h			;is a blank ?
		jg		.compare				;no, check the string
		
		inc		si						;increase position

		jmp		.skip_blanks			;check next char

	.compare:
		xor		cx,cx					;clear CX (counter of strlen)
		mov		bx,dx					;copy in BX the start of the string

	.strlen:							;calculate the len of the string
		cmp		[bx],byte 00h
		je		.strcmp
		inc 	bx
		inc		cx
		jmp		.strlen

	.strcmp:
		mov     di,dx     				;DX is the start of the str to compare
        repe    cmpsb           		;equals ?
        jne     .nomatch        		;nope

	.match: 							;if here strings are equals
		mov		[CURSOR],si				;update the cursor position
		mov		al,1					;set AL for match found
		ret

	.nomatch:
		mov 	bx,[TST_CURBKUP]		;restore cursor position
		mov		[CURSOR],bx		
		ret								;AL already clear