;==============================================================================
; XINIT
; Perform initialization for each stated execution. 
; Empties AEXP stack.
;==============================================================================
ILM_XINIT:
		mov     al,00h            		;the value to initialize the buffer
        mov		di,LBUF       			;clear LBUF
        mov     cx,COLS		          	;size of bufffer
		rep		stosb                   ;repeat

		mov		[CURSOR],word PGM
		ret