;==============================================================================
; ERR
; Report syntax error am return to line collect routine.
;==============================================================================
ILM_ERR:
		mov		[ERROR_STR], word ERROR_SYNTAX				
		jmp		ERROR