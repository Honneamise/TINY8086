;==============================================================================
; TSTN lbl
; Test for number. 
; If present, place its value onto the AESTK and continue execution 
; at next suggested location. Otherwise continue at lbl.
;
; Return:
; AL == -1 on error ( should return to CO )
; AL == 0 if no match
; AL == 1 on success 
;
; NOTE: if match, [CURSOR] point to first element after the number
;==============================================================================
ILM_TSTN:
		xor		ch,ch					;clear high part of CX
		xor		ax,ax					;clear AX
		mov		bx,10					;set BX as multiplyer
		mov		di,0					;set DI for positive sign

		mov		si,[CURSOR]				;init SI with current cursor position

    .skip_blanks:						;skip leading blanks
		cmp		[si],byte 00h			;is EOL ?
		je		.not_found

		cmp 	[si],byte 20h			;is a BLANK ?
		ja		.check_sign				;no go to check if is a sign
		
		inc		si						;next char
		jmp		.skip_blanks			;repeat skip blanks loop
        
	.check_sign:
		cmp		[si],byte 2Bh			;check '+'
		je		.skip_sign

		cmp		[si],byte 2Dh			;check '-'
		jne		.get_number
	
		mov		di,1					;set DI for sign change

	.skip_sign:
		inc		si

	.check_number:						;if not number exit
		cmp 	[si],byte 30h
		jl		.not_found
		cmp 	[si],byte 39h
		jg		.not_found

	.get_number:
		
		mov		cl,[si]					;get in CL the current char

		cmp 	cl,30h					;is less than 0 ?
		jl		.fix_sign

		cmp 	cl,39h					;is greater than 9 ?
		jg		.fix_sign

		sub 	cl,30h					;convert CL ascii to a number 0..9

		mul 	bx						;multiply the content of AX for 10
		jo		.number_err				;if overflow error

		add		ax,cx					;add the the CX value
		jo		.number_err				;if overflow error
		
		inc 	si						;next char
	
		jmp		.get_number 			;repeat

	.fix_sign:
		cmp		di,00h					;was negative ?
		je		.done					;nope
		neg		ax						;yes, negate it
						
	.done:
		mov		dx,ax
		call	ILM_LIT
		cmp		al,00h
		jne		.done_ok
		mov		al,-1					;err
		ret								

	.done_ok:
		mov		[CURSOR],si				;update cursor
		mov		al,01h					;exit success
		ret

	.number_err:
		mov		[ERROR_CODE],word ERROR_BIG_NUMBER
		call	ILM_ERR
		mov		al,-1
		ret

	.not_found:
		xor		al,al
		ret
