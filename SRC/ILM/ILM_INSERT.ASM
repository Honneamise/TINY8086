;==============================================================================
; INSRT
; Insert line after deleting any line with same line number.
;
; Expect:
; AL == line number
; SI == first element after line number
;==============================================================================
ILM_INSERT:
		mov		cx,COLS					;how many to copy
		sub		cx,si

		add		si,LBUF					;prepare source data index

		mov		bl,COLS					;prepare dest data index (PGM+LINE_NUM*COLS)
		mul		bl
		mov		di,ax					
		add		di,PGM

        rep     movsb           		;copy
	
	.done:
		ret