;==============================================================================
; INIT
; Perform global initilization.
; Clears program area, empties GOSUB stack, etc.
;==============================================================================
ILM_INIT:
		mov     al,00h            		;the value to initialize the buffer
        mov		di,LBUF       			;clear LBUF
        mov     cx,COLS		          	;size of bufffer
		rep		stosb                   ;repeat

		mov     al,00h            		;the value to initialize the buffer
        mov		di,PGM       			;clear PGM
        mov     cx,256*COLS		        ;size of bufffer
		rep		stosb                   ;repeat

		mov		[PGP],word PGM			;clear the PGP

		mov		[CURSOR],word PGM		;clear the CURSOR

		ret