;==============================================================================
; DONE
; Report a syntax error if after deletion leading blanks the cursor is not 
; positioned to road a carriage return.
;==============================================================================
ILM_DONE:
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
		call	ILM_NLINE
		ret

	.done:
		ret