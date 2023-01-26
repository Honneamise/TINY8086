;==============================================================================
; DONE
; Report a syntax error if after deletion leading blanks the cursor is not 
; positioned to road a carriage return.
;==============================================================================
ILM_DONE:

	.skip_blanks:

		mov		si,[CURSOR]

		cmp		[si],byte 00h				;is EOL ?
		je		.done						;ok done

		cmp		[si],byte 20h				;is a blank ?
		jg		.err						;no, error
		
		inc		si							;increase cursor
		jmp		.skip_blanks				;check next char

	.err:
		mov		dx,ERROR_SYNTAX
		call	PRINT_STR
		call	ILM_NLINE
		ret

	.done:
		ret