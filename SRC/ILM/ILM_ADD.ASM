;==============================================================================
; ADD	
; Replace top two elements of AESTK by their sum.
;
; Return:
; AL = 0 if fail, 1 on success (if fail, main must jump back to collection)
;==============================================================================
ILM_ADD:
        xor     bx,bx                   ;clear bx

        mov     bl,[AESTACK_POINTER]    ;get stack pointer

		cmp     bl,02h					;not enough elements
        jb     	.stack_err

        dec     bl						;get top stack
		shl		bl,1					;mult by 2
		add		bx,AESTACK_BASE			;add stack base address

		mov		ax,[bx]					;get second element in AX

		dec		bx						;decrease address by 2
		dec		bx

		add		[bx],ax					;store result of sum
		jo		.number_err

		dec		byte [AESTACK_POINTER]	;decrease stack pointer

		mov		al,1					;exit success

		ret

    .stack_err:
		mov		[ERROR_CODE],word ERROR_AESTACK_UNDERFLOW
		call	ILM_ERR
		jmp		.fail

	.number_err:
		mov		[ERROR_CODE],word ERROR_BIG_NUMBER
		call	ILM_ERR

	.fail:								;return 0 on fail
		xor		al,al
		ret