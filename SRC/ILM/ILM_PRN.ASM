;==============================================================================
; PRN
; Print number obtained by popping the top of the expression stack.
;==============================================================================
ILM_PRN:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret