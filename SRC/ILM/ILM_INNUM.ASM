;==============================================================================
; INNUM
; Read a number from the terminal and push its value onto the AESTK.
;
; Return:
; AL = 0 if fail, 1 on success (if fail, main must jump back to collection)
;
; NOTE : we use LBUF to read the number
;==============================================================================
ILM_INNUM:

		mov		al,23h					;set prompt	'#'
		call	ILM_GETLINE				;read a line in LBUF

	.init:
		mov		si,LBUF					;set SI at LBUF
		xor		ax,ax					;AX will store the result
		mov		bx,10					;BX will be multiplier by 10
		xor		di,di					;set DL for positive sign
		xor		ch,ch					;clear high part of CX
		
	.skip_blanks:
		cmp		[si],byte 00h			;is EOL ?
		je		.empty_line				;possible error

		cmp		[si],byte 20h			;is a blank ?
		jg		.check_sign				;no, check if sign present
		
		inc		si						;increase position

		jmp		.skip_blanks			;check next char

	.check_sign:
		cmp		[si],byte 2Bh			;check '+'
		je		.skip_sign

		cmp		[si],byte 2Dh			;check '-'
		jne		.get_number
	
		mov		di,1					;set DL for sign change

	.skip_sign:
		inc		si
		
	.get_number:						

		mov		cl,[si]					;get in cl the current char

		cmp		cl,00h					;ok done, go to fix sign if needed
		je		.fix_sign

		cmp 	cl,30h					;is less than 0 ?
		jl		.not_number

		cmp 	cl,39h					;is greater than 9 ?
		jg		.not_number

		sub 	cl,30h					;convert CL ascii to a number 0..9

		mul 	bx						;multiply the content of AL for 10
		jo		.big_number				;if overflow error

		add		ax,cx					;add the the CL value
		jo		.big_number				;if overflow error
		
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
		ret								;AL already set to 0 from ILM_LIT

	.done_ok:
		call	ILM_NLINE
		mov		al,01h					;exit success
		ret
	
	.empty_line:
		mov		[ERROR_CODE],word ERROR_EMPTY_LINE
		jmp		.err

	.not_number:
		mov		[ERROR_CODE],word ERROR_NOT_NUMBER
		jmp		.err

	.big_number:
		mov		[ERROR_CODE],word ERROR_NUMBER_OVERFLOW

	.err:
		call	ILM_ERR
		xor		al,al
		ret