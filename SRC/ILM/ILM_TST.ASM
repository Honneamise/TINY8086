;==============================================================================
; TST lbl,'string'
; delete leading blanks 
; If string matches the BASIC line, advance cursor over the 
; matched string and execute the next IL instruction.
; If a match fails, execute the IL instruction at the labled lbl.
;
; Expect :
; DX == the string to compare
;
; Return : 
; AL == 0 no match, 1 == match
;==============================================================================	
ILM_TST:
		xor		al,al					;clear AL

	.skip_blanks:
		cmp		[CURSOR],byte 00h		;is EOL ?
		je		.nomatch				;possible error

		cmp		[CURSOR],byte 20h		;is a blank ?
		jg		.compare				;no, check the string
		
		inc		word [CURSOR]			;increase cursor
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
		mov     si,[CURSOR]      		;SI equal to CURSOR current pos
        mov     di,dx     				;DX is the start of the str to compare
        repe    cmpsb           		;equals ?
        jne     .nomatch        		;nope

	.match: 							;if here strings are equals
		add		[CURSOR],cx				;update the cursor

		mov		al,1					;set AL for mathc found
		ret

	.nomatch:
		ret								;AL already cleared