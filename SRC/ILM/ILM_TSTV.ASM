;==============================================================================
; TSTV lbl
; Test for variable (i.e letter) if present.
; Place its index value onto the AESTK and continue execution at next suggested
; location. 
; Otherwise continue at lbl.
;
; Return:
; AL == -1 on error ( should return to CO )
; AL == 0 if no match
; AL == 1 on success 
;
; NOTE: if match, [CURSOR] point to first element after matched string
;==============================================================================
ILM_TSTV:
        mov     si,[CURSOR]

    .skip_blanks:
		cmp		[si],byte 00h			;is EOL ?
		je		.nomatch				;possible error

		cmp		[si],byte 20h			;is a blank ?
		jg		.check					;no, check for var
		
		inc		si						;increase position

		jmp		.skip_blanks			;check next char

	.check:
		cmp		[si],byte 41h			;less than 'A' ?
		jl		.nomatch

		cmp		[si],byte 5Ah			;greater than 'Z' ?
		jg		.nomatch

		mov		dx,[si]					;convert ascii char to index
		sub		dx,41h

	.stack:
		xor		bx,bx					;clear bx

        mov		bl,[AESTACK_POINTER] 	;get current stack pointer
		cmp		bl,MAX_STACK			;greatest of max elements ?
		jae		.stack_err				;if yes error

		shl		bl,1					;multiply pointer by 2

		add		bx,AESTACK_BASE			;add the base of stack

		mov		[bx],dx					;copy the value

		inc		byte [AESTACK_POINTER]	;increase stack pointer
		inc		byte [CURSOR]			;increase cursor

		mov		al,1					;exit success
		ret

	.nomatch:							;match fail
		xor		al,al
		ret

	.stack_err:
		mov		[ERROR_CODE],word ERROR_AESTACK_OVERFLOW
		mov		al,-1
		ret