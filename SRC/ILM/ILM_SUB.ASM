;==============================================================================
; SUB
; Replace top two elements of AESTK by their difference.
;
; Return:
; AL = 0 if fail, 1 on success (if fail, main must jump back to collection)
;==============================================================================
ILM_SUB:
        xor     bx,bx                   ;clear bx

        mov     bl,[AESTACK_POINTER]    ;get stack pointer

		cmp     bl,02h					;not enough elements
        jb     	.stack_err

        dec     bl						;get top stack
		shl		bl,1					;mult by 2
		add		bx,AESTACK_BASE			;add stack base address

		mov		ax,[bx]					;get second element in DX

		dec		bx						;decrease address by 2
		dec		bx

		sub		[bx],ax					;store result of sub

		dec		byte [AESTACK_POINTER]	;decrease stack pointer

		mov		al,01h
		ret

    .stack_err:
		mov		[ERROR_CODE],word ERROR_AESTACK_UNDERFLOW
		call	ILM_ERR
		xor		al,al
		ret