;==============================================================================
; INIT
; Perform global initilization.
; Clears program area, empties GOSUB stack, etc.
;==============================================================================
ILM_INIT:
		mov		[MODE],byte 00h			;mode 0 = direct

		mov     al,00h            		;the byte to initialize the buffer
        mov		di,PGM       			;clear PGM
        mov     cx,256*COLS		        ;size of bufffer
		rep		stosb                   ;repeat

		mov     ax,0000h            	;the word to initialize the buffer
        mov		di,VARIABLES   			;clear VARIABLES
        mov     cx,26		        	;size of bufffer
		rep		stosw                   ;repeat

		mov		[PGP],word PGM			;clear the PGP

		mov		[CURSOR],word PGM		;clear the CURSOR

		mov		[AESTACK_POINTER], byte 00h 	;clear AESTACK pointer
		mov		[SBRSTACK_POINTER], byte 00h 	;clear AESTACK pointer

		ret