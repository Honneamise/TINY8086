;==============================================================================
; CMPR
; Compare AESTK(SP), the top of the stack, with AESTK(SP-2)
; as per the relations indicated by AESTK(SP-1). 
; Delete all from stack.
; If the condition specified did not match, then perform NXT action.
;==============================================================================
ILM_CMPR:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret