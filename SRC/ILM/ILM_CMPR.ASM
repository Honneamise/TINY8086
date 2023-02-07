;==============================================================================
; CMPR
; Compare AESTK(SP), the top of the stack, with AESTK(SP-2)
; as per the relations indicated by AESTK(SP-1). 
; Delete all from stack.
; If the condition specified did not match, then perform NXT action.
;
; Return:
; AL = -1 error
; AL = 0 false
; AL = 1 true
;==============================================================================
ILM_CMPR:
		xor		ax,ax					;clear AX
        xor     si,si                   ;clear SI

        add     si,[AESTACK_POINTER]    ;get stack pointer

		cmp     si,03h					;not enough elements
        jb     	.stack_err

        dec     si						;get top stack
		shl		si,1					;mult by 2
		add		si,AESTACK_BASE			;add stack base address

		mov		dx,[si]					;get second operand

		dec		si						;decrease address by 2
		dec		si

		mov		cx,[si]					;get operator index
		
		dec		si						;decrease address by 2
		dec		si

		mov		bx,[si]					;get first operand

		sub		[AESTACK_POINTER],byte 03h   ;remove 3 elements

	.switch:
		cmp		cx,00h
		je		.e
		cmp		cx,01h
		je		.ne
		cmp		cx,02h
		je		.le
		cmp		cx,03h
		je		.ge
		cmp		cx,04h
		je		.l
		cmp		cx,05h
		je		.g

	.e:
		cmp		bx,dx
		je		.done_true
		ret

	.ne:
		cmp		bx,dx
		jne		.done_true
		ret

	.le:
		cmp		bx,dx
		jle		.done_true
		ret

	.ge:
		cmp		bx,dx
		jge		.done_true
		ret

	.l:
		cmp		bx,dx
		jl		.done_true
		ret

	.g:
		cmp		bx,dx
		jg		.done_true
		ret

	.done_true:
		mov		al,1					;exit true
		ret

    .stack_err:
		mov		[ERROR_CODE],word ERROR_AESTACK_UNDERFLOW		
		call	ILM_ERR						
		mov		al,-1					;return -1 on fail
		ret