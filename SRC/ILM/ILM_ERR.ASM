;==============================================================================
; ERR
; Report syntax error am return to line collect routine.
;
; Expect:
; [ERROR_CODE] == the error line to print
;
; NOTE : insert JMP CO after calling this function
;==============================================================================
ILM_ERR:									
		
		call	ILM_NLINE				;new line

	.mode:
		cmp		[MODE],byte 00h			;direct mode ?
		je		.err_direct				;skip line number

	.err_at_line:
		mov		dx,ERROR_STR_AT_LINE	;
		call	PRINT_STR

	.line:
		mov		ax,[PGP]				;convert line address to line number
		sub		ax,PGM					
		mov		bl,COLS
		div		bl

	.num:								;print line number
		mov		dx,ax
		call	PRINT_NUMBER
		
		jmp		.err_code

	.err_direct:
		mov		dx,ERROR_STR
		call	PRINT_STR

	.err_code:								
		mov		dx,[ERROR_CODE]			;print code error
		call	PRINT_STR

		call	ILM_NLINE

		ret