;==============================================================================
; XPER
; Test value at the top of the AE stack to be within range.
; If not,report an error.
; If in range, attempt to position cursor at that line. 
; If it exists, begin interpretation there.
; If not report an error.
;
; Return:
; AL = 0 on error should jump back to CO
; AL = 1 on success should jump to XEC
;==============================================================================
ILM_XPER:

		mov		dl,COLS					;set DL as line multiplier

        xor     bx,bx                   ;clear BX

        mov     bl,[AESTACK_POINTER]    ;get stack pointer

		cmp     bl,00h					;if zero stack empty
        jbe     .stack_err

        dec     bl						;go to first element

		shl		bl,1					;mult by 2

		add		bx,AESTACK_BASE			;add stack base

		mov		ax,[bx]					;in AX line number index

		cmp		ax,00h					;less than 1?
		jle		.pgp_err

		cmp		ax,0FFh					;greater than 255 ?
		jg		.pgp_err

		xor		ah,ah					;clear high part of ax
		mul		dl

		add		ax,PGM					;add PGM base

		mov		si,ax					;check for empty line
		cmp		[si],byte 00h
        je      .empty_err

		mov		[PGP],si				;set line
		mov		[CURSOR],si				;reset cursor

		mov		al,01h

		ret

	.stack_err:
		mov		[ERROR_CODE],word ERROR_AESTACK_UNDERFLOW
		jmp		.err

	.pgp_err:
		mov		[ERROR_CODE],word ERROR_PGP
		jmp		.err

	.empty_err:
		mov		[ERROR_CODE],word ERROR_EMPTY_LINE

	.err:
		call	ILM_ERR
		xor		al,al
		ret