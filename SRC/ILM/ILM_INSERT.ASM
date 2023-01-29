;==============================================================================
; INSRT
; Insert line after deleting any line with same line number.
;
; Expect:
; AL == line number
; SI == first element after line number
;
; Return :
; AL == line number inserted
;==============================================================================
ILM_INSERT:
		mov		dl,al					;bkup the line number

		mov		cx,COLS					;how many to copy
		sub		cx,si

		add		si,LBUF					;prepare source data index

		mov		bl,COLS					;prepare dest data index (PGM+LINE_NUM*COLS)
		mul		bl
		mov		di,ax					
		add		di,PGM

        rep     movsb           		;copy

		mov		al,dl					;restore line number inserted

		ret