;==============================================================================
; ERR
; Report syntax error am return to line collect routine.
;==============================================================================
ILM_ERR:
		mov		dx,ERROR_SYNTAX			;select syntax error string
		call	PRINT_STR				;print the string
		call	ILM_NLINE				;print new line
		jmp		CO						;jmp to collection routine
										;NOTE : no return