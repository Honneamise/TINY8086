;==============================================================================
; STORE
; Place the value at the top of the AESTK 
; into the variable designated by the index specified by the value immediately 
; below it. Delete both from the stack.
;
; Return:
; AL = 0 if fail, 1 on success (if fail, main must jump back to collection)
;==============================================================================
ILM_STORE:

        xor     bx,bx                   ;clear bx

        mov     bl,[AESTACK_POINTER]    ;get stack pointer

		cmp     bl,02h					;not enough elements
        jb     	.stack_err

        dec     bl						;get top stack
		shl		bl,1					;mult by 2
		add		bx,AESTACK_BASE			;add stack base address

		mov		ax,[bx]					;get the value in AX

		dec		bx						;decrease address by 2
		dec		bx

		mov		di,[bx]					;get in DI the variable index

		shl		di,1					;mult by 2

		add		di,VARIABLES			;add base address for variables

		mov		[di],ax					;store the value

		dec		byte [AESTACK_POINTER]	;decrease stack pointer
		dec		byte [AESTACK_POINTER]

		mov		al,1					;exit success

		ret

    .stack_err:
		mov		[ERROR_CODE],word ERROR_AESTACK_UNDERFLOW
		call	ILM_ERR					;return 0 on fail
		xor		al,al
		ret