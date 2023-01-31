;==============================================================================
; NEG
; Replace top of AESTK with its negative.
;==============================================================================
ILM_NEG:

        xor     bx,bx                   ;clear bx

        mov     bl,[AESTACK_POINTER]    ;get stack pointer

		cmp     bl,00h					;if zero stack empty
        jbe     .stack_err

        dec     bl						;go to first element

		shl		bl,1					;mult by 2

		add		bx,AESTACK_BASE			;add stack base

		neg		word [bx]				;negate it

		ret

    .stack_err:
		mov		[ERROR_STR],word ERROR_AESTACK_UNDERFLOW
		jmp		ERROR
    