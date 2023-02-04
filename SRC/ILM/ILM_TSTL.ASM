;==============================================================================
; TSTL lbl 	
; After editing leading blanks, look for a line number. 
; Report error if invalid.
; Transfer to lbl if not present.
;
; Return :
; AL == line number, -1 on error
; SI == index of first element after the line number
;==============================================================================
ILM_TSTL:
		xor		ax,ax					;clear AX
		mov		ch,10					;set CH as multiplier

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
		mov		[ERROR_CODE],word ERROR_LINE_NUMBER 
		call	ILM_ERR
		mov		al,-1
		ret
