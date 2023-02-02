;==============================================================================
; DIV	
; Replace top two elements of AESTK by their quotient.
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

		dec		bx						;decrease address by 2
		dec		bx

		mov		ax,[bx]					;get first element in AX
		cwd								;NOTE: extends sign bit of AX in DX

		idiv	cx						;divide by cx

		mov		[bx],ax					;store result
		
		dec		byte [AESTACK_POINTER]	;decrease stack pointer

		ret

    .stack_err:
		mov		[ERROR_STR],word ERROR_AESTACK_UNDERFLOW
		jmp		ERROR
