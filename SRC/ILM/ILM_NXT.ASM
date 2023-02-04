;==============================================================================
; NXT	
; If the present mode is direct (line number zero), return to line collection. 
; Otherwise, select the next line and begin interpretation.
;
; Return:
; AL == 0 must jump to CO, 1 must jump to XEC
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
		mov		al,01h					;set return to STMT
		ret

	.err:
		sub		bx,COLS					;get last valid line
		mov		[PGP],bx				;copy it in PGP

		mov		[ERROR_CODE],word ERROR_PGP
		call	ILM_ERR

	.collection:
		xor		al,al					;set for return to collection
		ret
