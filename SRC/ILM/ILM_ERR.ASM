;==============================================================================
; ERR
; Report syntax error am return to line collect routine.
;==============================================================================
ILM_ERR:
		call	ILM_NLINE				;new line
		
		mov		ax,[PGP]				;get line address
		cmp		ax,PGM					;line 0 ?
		je		.str					;dont print line number

		sub		ax,PGM					;calculate line number
		mov		bx,COLS
		div		bx

	.num:								;print line number
		mov		dx,ax
		call	PRINT_NUMBER

		mov     ah,0Eh                  ;teletype print interupt
        mov 	al,3Ah                 	;column
        mov     bh,00h                  ;page
        int     10h                     ;call interrupt
		
	.str:								;print error string
		mov		dx,ERROR_SYNTAX				
		call	PRINT_STR
		call	ILM_NLINE
		jmp		CO						;back to collection routine