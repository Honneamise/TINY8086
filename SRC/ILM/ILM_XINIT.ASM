;==============================================================================
; XINIT
; Perform initialization for each stated execution. 
; Empties AEXP stack.
;==============================================================================
ILM_XINIT:
		mov		[AESTACK_POINTER],byte 00h
		ret