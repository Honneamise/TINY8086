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
; AL == 0 no match, 1 match success
;
; NOTE: if match, [CURSOR] point to first element after matched string
;==============================================================================	
ILM_TST:
		mov		ax,[CURSOR]				;use AX as cursor bkup
		mov		si,ax					;we use SI as byte pointer of string

	.skip_blanks:
		cmp		[si],byte 00h			;is EOL ?
		je		.nomatch				;possible error

		cmp		[si],byte 20h			;is a blank ?
		ja		.compare				;no, check the string
		
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
		mov		al,01h
		ret

	.nomatch:
		mov		[CURSOR],ax				;restore cursor position
		xor		al,al
		ret