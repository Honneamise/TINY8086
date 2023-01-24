;==============================================================================
; NLINE
; Output CRLF to Printer.
;==============================================================================
ILM_NLINE:
		mov     ah,0Eh                  ;teletype print interupt
        mov 	al,0Dh                 	;CR
        mov     bh,00h                  ;page
        int     10h                     ;call interrupt
		
		mov		al,0Ah					;LF
		int     10h 					;call interrupt

		ret