;==============================================================================
; GETLINE
; Input a line to LBUF.
;==============================================================================
ILM_GETLINE:

		mov     al,00h            		;the value to initialize the buffer
        mov		di,LBUF       			;clear LBUF
        mov     cx,COLS		          	;size of bufffer
		rep		stosb                   ;repeat

		mov		si,00h					;reset SI (index)

	.cycle:
		xor     ax,ax                   ;keyboard read function
        int     16h						;ah scancode, al ascii code

		cmp		ah,1Ch					;is enter pressed ?
		je		.done					;ok finished

		cmp		ah,0Eh 					;is backspace ?
		je		.backspace

		cmp		si,COLS-1               ;do we have any space left ?
		jge		.cycle                  ;if not skip insertion

		mov		bx,LBUF
		mov		[bx+si],al				;store character 
		inc		si

		mov     ah,0Eh                  ;teletype print interupt
        mov     bh,00h                  ;page
        int     10h 

		jmp		.cycle

	.backspace:

		cmp		si,0					;we are at beginning of LBUF
		jle		.cycle					;skip backspace

		dec		si						;dec di and store a blank in LBUF
		mov		bx,LBUF
		mov		[bx+si],byte 00h
		
		mov		bh,00h      			;set page number for all operations

		mov		ah,03h					;get cursor position in DH,DL (row/col)
		int		10h

		dec		dl						;dec the col
		mov		ah,02h					;set cur pos
		int		10h

		mov     ah,0Ah                  ;write character at current cursor pos
		mov		al,20h					;we use empty space
        int     10h

		jmp		.cycle
		
	.done:
		ret