;==============================================================================
; SPC
; Insert spaces, to move the print head to next zone.
;==============================================================================
ILM_SPC:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret