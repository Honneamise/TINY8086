;==============================================================================
; NXT	
; If the present mode is direct (line number zero), 
; then return to line collection. 
; Otherwise, select the next line and begin interpretation.
;==============================================================================
ILM_NXT:
        
        cmp		[MODE],byte 00h			;is direct ?
		je		.collection				;return to collect 

		mov		bx,[PGP]				;get the PGP
	
	.cycle:
		add		bx,COLS

		cmp		bx,PGM+(256*80)			;is this the last line ?
		jge		.err					;err, we are outside of program

		cmp		[bx],byte 00h			;is empty line ?
		je		.cycle

	.done:	
		mov		[PGP],bx				;next line
		mov		[CURSOR],bx				;set cursor to beginning of the line
		jmp		XEC						;jump to executor

	.collection:
		jmp		CO						;jump to collection routine

    .err:
		sub		bx,COLS					;get last valid line
		mov		[PGP],bx				;copy it in PGP

		mov		[ERROR_STR],word ERROR_PGP
		jmp		ERROR