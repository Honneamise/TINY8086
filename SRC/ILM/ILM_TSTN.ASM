;==============================================================================
; TSTN lbl
; Test for number. 
; If present, place its value onto the AESTK and continue execution 
; at next suggested location. 
; Otherwise continue at lbl.
;
; Return :
; AL == 0 not found, 1 found (and pushed on AESTACK)
;==============================================================================
ILM_TSTN:

		xor		ax,ax					;clear AX
		mov		bx,10					;set BX as multiplyer
		mov		di,0					;set DI for positive sign

		mov		si,[CURSOR]				;init SI with current cursor position

    .skip_blanks:						;skip leading blanks
		cmp		[si],byte 00h			;is EOL ?
		je		.not_found

		cmp 	[si],byte 20h			;is a BLANK ?
		jg		.check_sign				;no go to check if is a sign
		
		inc		si						;next char
		jmp		.skip_blanks			;repeat skip blanks loop
        
	.check_sign:
		cmp 	[si],byte 2Dh			;is minus sign?
		jne		.check_number			;nope

		mov		di,1					;set DL for negative
		inc		si						;skip the sign

	.check_number:						;if not number exit
		cmp 	[si],byte 30h
		jl		.not_found
		cmp 	[si],byte 39h
		jg		.not_found

		xor		ch,ch					;clear high part of CX

	.get_number:
		
		mov		cl,[si]					;get in CL the current char

		cmp 	cl,30h					;is less than 0 ?
		jl		.fix_sign

		cmp 	cl,39h					;is greater than 9 ?
		jg		.fix_sign

		sub 	cl,30h					;convert CL ascii to a number 0..9

		mul 	bx						;multiply the content of AX for 10
		jo		.number_err				;if greatest error

		add		ax,cx					;add the the CX value
		jo		.number_err				;if greatest error
		
		inc 	si						;next char
	
		jmp		.get_number 			;repeat

	.fix_sign:
		cmp		di,00h					;was negative ?
		je		.done					;nope
		neg		ax						;yes, negate it
						
	.done:

		xor		bx,bx					;clear bx

		mov		bl,[AESTACK_POINTER] 	;get current stack pointer
		cmp		bl,MAX_STACK			;greatest of max elements ?
		jae		.stack_err				;if yes error

		shl		bl,1					;multiply pointer by 2

		add		bx,AESTACK_BASE			;add the base of stack

		mov		[bx],ax					;store the number

		inc		byte [AESTACK_POINTER]	;store the new pointer value

		mov		[CURSOR],si				;update cursor
		mov		al,01h					;ok done
		ret

	.number_err:
		mov		[ERROR_STR],word ERROR_NUMBER
		jmp		ERROR

	.stack_err:
		mov		[ERROR_STR],word ERROR_AESTACK_OVERFLOW
		jmp		ERROR

	.not_found:
		mov		al,00h					;not found
		ret
