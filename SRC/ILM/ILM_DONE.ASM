;==============================================================================
; DONE
; Report a syntax error if after deletion leading blanks the cursor is not 
; positioned to road a carriage return.
;
; Return:
; AL = 0 if fail, 1 on success (if fail, main must jump back to collection)
;==============================================================================
ILM_DONE:

		mov		si,[CURSOR]

	.skip_blanks:

		cmp		[si],byte 00h				;is EOL ?
		je		.done						;ok done

		cmp		[si],byte 20h				;is a blank ?
		ja		.err						;no, error
		
		inc		si							;increase cursor
		jmp		.skip_blanks				;check next char

	.err:
		mov		[ERROR_CODE],word ERROR_SYNTAX
		call	ILM_ERR
		xor		al,al
		ret

	.done:
		mov		al,01h
		ret