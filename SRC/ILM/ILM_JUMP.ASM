;==============================================================================
; JMP lbl
; Continue execution of IL at the line specified.
;==============================================================================
ILM_JMP:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret