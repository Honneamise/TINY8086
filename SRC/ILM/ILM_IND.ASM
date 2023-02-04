;==============================================================================
; IND
; Replace top of AEstack by variable value it indexes.
;
; Return:
; AL = 0 if fail, 1 on success (if fail, main must jump back to collection)
;==============================================================================
ILM_IND:
        xor     bx,bx                  	;clear bx

        mov     bl,[AESTACK_POINTER]    ;get stack pointer

		cmp     bl,00h					;if zero stack empty
        jbe     .stack_err

        dec     bl						;go to first element

		shl		bl,1					;mult by 2

		add		bx,AESTACK_BASE			;add stack base

		mov 	si,[bx]					;copy the var index from [BX] to SI
		shl		si,1					;mult by2
		add 	si,VARIABLES			;add VARIABLES BASE

		mov		ax,[si] 				;copy the value in ax

		mov		[bx],ax					;store it at top of stack

		mov		al,01h

		ret

    .stack_err:
		mov		[ERROR_CODE],word ERROR_AESTACK_UNDERFLOW
		call	ILM_ERR
		xor		al,al
		ret