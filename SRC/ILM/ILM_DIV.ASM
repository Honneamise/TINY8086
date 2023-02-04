;==============================================================================
; DIV	
; Replace top two elements of AESTK by their quotient.
;
; Return:
; AL = 0 if fail, 1 on success (if fail, main must jump back to collection)
;==============================================================================
ILM_DIV:
        xor     bx,bx                   ;clear BX

        mov     bl,[AESTACK_POINTER]    ;get stack pointer

		cmp     bl,02h					;not enough elements
        jb     	.stack_err

        dec     bl						;get top stack
		shl		bl,1					;mult by 2
		add		bx,AESTACK_BASE			;add stack base address

		mov		cx,[bx]					;get second element in CX

		cmp		cx,0					;divide by 0 error
		je		.div_zero_err

		dec		bx						;decrease address by 2
		dec		bx

		mov		ax,[bx]					;get first element in AX
		cwd								;NOTE: extends sign bit of AX in DX

		idiv	cx						;divide by cx

		mov		[bx],ax					;store result
		
		dec		byte [AESTACK_POINTER]	;decrease stack pointer

		mov		al,01h					;exit success

		ret

    .stack_err:
		mov		[ERROR_CODE],word ERROR_AESTACK_UNDERFLOW
		jmp		.err

	.div_zero_err:
		mov		[ERROR_CODE],word ERROR_DIVIDE_ZERO

	.err:
		call	ILM_ERR
		xor		al,al
		ret

