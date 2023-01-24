;==============================================================================
; LST
; List the contents of the program area.
;==============================================================================
LST_COUNTER		db 00h					;line counter
;------------------------------------------------------------------------------
ILM_LST:
		mov		[LST_COUNTER],byte 00h	;reset counter variable
		mov		di,PGM					;init DI as base pointer to PGM

	.cycle:
		cmp		di,PGM+256*80			;is this the last line ?
		jge		.done					;if yes exit

		cmp		[di],byte 00h			;is an empty line ?
		je		.next					;skip it

		xor		dx,dx					;clear dx
		mov		dl,[LST_COUNTER]		;get the line counter
		call	PRINT_NUMBER			;print the line number

		mov		dx,di					;copy the start of the line
		call	PRINT_STR				;call print line
		call	ILM_NLINE					;add a new line

	.next:
		add		di,COLS					;move to the next line
		inc		byte [LST_COUNTER]		;increase line counter
		jmp		.cycle					;repeat

	.done:
		ret
