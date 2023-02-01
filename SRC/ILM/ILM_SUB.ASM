;==============================================================================
; SUB
; Replace top two elements of AESTK by their difference.
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

		ret

    .stack_err:
		mov		[ERROR_STR],word ERROR_AESTACK_UNDERFLOW
		jmp		ERROR