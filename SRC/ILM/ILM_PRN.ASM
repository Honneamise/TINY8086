;==============================================================================
; PRN
; Print number obtained by popping the top of the expression stack.
;
; Return:
; AL = 0 if fail, 1 on success (if fail, main must jump back to collection)
;==============================================================================
ILM_PRN:
        xor     bx,bx                   ;clear bx

        mov     bl,[AESTACK_POINTER]    ;get stack pointer

		cmp     bl,01h					;at least one element
        jl     	.stack_err

        dec     bl						;get top stack
		shl		bl,1					;mult by 2
		add		bx,AESTACK_BASE			;add stack base address

		mov		dx,[bx]					;top of stack

		call	PRINT_NUMBER

		dec		byte [AESTACK_POINTER]	;decrease stack pointer

		mov		al,1					;exit success

		ret

    .stack_err:
		mov		[ERROR_CODE],word ERROR_AESTACK_UNDERFLOW
		call	ILM_ERR
		xor		al,al
		ret
