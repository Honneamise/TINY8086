;==============================================================================
; LST
; List the contents of the program area.
;==============================================================================
LINE_COUNTER	db 00h					;line counter
PAGE_BREAK		db 00h					;page break
;------------------------------------------------------------------------------
ILM_LST:
		mov		[PAGE_BREAK],byte 00h	;keep track of how many lines printed
		mov		[LINE_COUNTER],byte 01h	;reset counter variable
		mov		di,PGM+COLS				;init DI at the line number 1
		
	.cycle:
		cmp		di,PGM+256*80			;is this the last line ?
		jge		.done					;if yes exit

		cmp		[di],byte 00h			;is an empty line ?
		je		.next					;skip it

		xor		dx,dx					;clear dx
		mov		dl,[LINE_COUNTER]		;get the line counter
		call	PRINT_NUMBER			;print the line number

		mov		dx,di					;copy the start of the line
		call	PRINT_STR				;call print line
		call	ILM_NLINE				;add a new line

		inc		byte [PAGE_BREAK]		;increase line printed
		cmp		byte [PAGE_BREAK],ROWS-1;less than screen row ? (-1 cause CRLF)
		jb		.next					;yep, continue

		call	WAIT_KEY				;wait for key press
		mov		byte [PAGE_BREAK],00h	;reset counter

	.next:

		add		di,COLS					;move to the next line
		inc		byte [LINE_COUNTER]		;increase line counter
		jmp		.cycle					;repeat

	.done:
		ret
