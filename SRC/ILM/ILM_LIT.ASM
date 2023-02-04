;==============================================================================
; LIT num
; Push the number num onto the AESTK (Originally omitted)
;
; Expect:
; DX == the number to push on the Aestack
;
; Return:
; AL = 0 if fail, 1 on success (if fail, main must jump back to collection)
;==============================================================================
ILM_LIT:
		xor		bx,bx					;clear bx

        mov		bl,[AESTACK_POINTER] 	;get current stack pointer
		cmp		bl,MAX_STACK			;greatest of max elements ?
		jae		.stack_err				;if yes error

		shl		bl,1					;multiply pointer by 2

		add		bx,AESTACK_BASE			;add the base of stack

		mov		[bx],dx					;store the number

		inc		byte [AESTACK_POINTER]	;store the new pointer value

		mov		al,01h

		ret

	.stack_err:
		mov		[ERROR_CODE],word ERROR_AESTACK_OVERFLOW
		call	ILM_ERR
		xor		al,al
		ret
        