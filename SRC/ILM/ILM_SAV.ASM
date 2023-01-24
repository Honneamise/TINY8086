;==============================================================================
; SAV
; Push present line number on SBRSTK. Report overflow as error.
;==============================================================================
ILM_SAV:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret