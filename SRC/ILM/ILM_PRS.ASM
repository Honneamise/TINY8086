;==============================================================================
; PRS
; Print characters from the BASIC text up to but not including the
; closing quote mark. 
; If a cr is found in the program text, report an error. 
; Move the cursor to the point following the closing quote.
;==============================================================================
ILM_PRS:
        mov		si,[CURSOR]

	.cycle:
		cmp		[si],byte 00h			;EOL ?
		je		.err					;error

		cmp		[si],byte 22h			;double quotes found ?
		je		.done					;done

		mov		al,[si]
		mov     ah,0Eh                  ;interrupt 10h code (teletype print)
        mov     bh,00h                  ;interrupt 10h page 0
		int		10h

		inc 	si						;advance to next char

		jmp		.cycle

	.err:
		jmp		CO						;FIX, print error and return to collect

	.done:
		inc		si						;move one pos after double quotes
		mov		[CURSOR],si				;save cursor
        ret