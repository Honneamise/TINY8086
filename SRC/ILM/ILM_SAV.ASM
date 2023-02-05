;==============================================================================
; SAV
; Push present line number on SBRSTK. Report overflow as error.
;
; Return:
; AL = 0 if fail, 1 on success (if fail, main must jump back to collection)
;==============================================================================
ILM_SAV:
		
		xor		bx,bx					;clear bx

        mov		bl,[SBRSTACK_POINTER] 	;get current stack pointer
		cmp		bl,MAX_STACK			;greatest of max elements ?
		jae		.stack_err				;if yes error

		add		bx,SBRSTACK_BASE		;add the base of stack

		mov		ax,[PGP]				;get the current line address

		sub		ax,PGM					;subtract the base stack address

		mov		cl,COLS					;we use CL as divider

		div		cl						;divide AX by CL

		xor		ah,ah					;clear remainder

		mov		[bx],ax					;store the line address

		inc		byte [SBRSTACK_POINTER]	;store the new pointer value

		mov		al,01h

		ret

	.stack_err:
		mov		[ERROR_CODE],word ERROR_SBRSTACK_OVERFLOW
		call	ILM_ERR
		xor		al,al
		ret