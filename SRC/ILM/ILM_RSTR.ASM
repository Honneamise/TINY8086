;==============================================================================
; RSTR
; Replace current line number with value on SBRSTK.
; If stack is empty, report error.
;==============================================================================
ILM_RSTR:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret