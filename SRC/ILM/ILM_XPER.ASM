;==============================================================================
; XPER
; Test value at the top of the AE stack to be within range.
; If not,report an error.
; If so, attempt to position cursor at that line. 
; If it exists, begin interpretation there.
; If not report an error.
;==============================================================================
ILM_XPER:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret