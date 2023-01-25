;==============================================================================
; NXT	
; If the present mode is direct (line number zero), 
; then return to line collection. 
; Otherwise, select the next line and begin interpretation.
;==============================================================================
ILM_NXT:
        
        cmp		[MODE],byte DIRECT		;is direct ?
		jge		.collection				;return to collect 

		mov		ax,[PGP]				;caluclate in AX next line
		add		ax,COLS

		mov		[PGP],ax				;next line
		mov		[CURSOR],ax				;set cursor to beginning of the line
		jmp		STMT					;jump to statement executor

	.collection:
		jmp		CO						;jump to collection routine

        