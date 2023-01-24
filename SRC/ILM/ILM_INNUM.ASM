;==============================================================================
; INNUM
; Read a number from the terminal and push its value onto the AESTK.
;==============================================================================
ILM_INNUM:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret