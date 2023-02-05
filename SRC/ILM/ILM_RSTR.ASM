;==============================================================================
; RSTR
; Replace current line number with value on SBRSTK.
; If stack is empty, report error.
;
; Return:
; AL = 0 if fail, 1 on success (if fail, main must jump back to collection)
;
;NOTE : we push the address of line
;==============================================================================
ILM_RSTR:
        xor     bx,bx                  	;clear bx

        mov     bl,[SBRSTACK_POINTER]   ;get stack pointer

		cmp     bl,00h					;if zero stack empty
        jbe     .stack_err

        dec     bl						;go to first element

		add		bx,SBRSTACK_BASE		;add stack base

		xor		ax,ax					;clear DX

		mov 	al,[bx]					;copy line number in DL

		mov		cl,COLS					;set CL as line multiplier

		mul		cl						;multiply by cols

		add		ax,PGM					;add PGM base

		mov		[PGP],ax				;store it in PGP

		dec		byte [SBRSTACK_POINTER]	;store the new pointer value

		mov		al,01h

		ret

    .stack_err:
		mov		[ERROR_CODE],word ERROR_SBRSTACK_UNDERFLOW
		call	ILM_ERR
		xor		al,al
		ret