;==============================================================================
; STORE
; Place the value at the top of the AESTK into the variable
; designated by the index specified by the value immediately 
; below it. 
; Delete both from the stack.
;==============================================================================
ILM_STORE:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret