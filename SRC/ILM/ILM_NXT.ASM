;==============================================================================
; NXT	
; If the present mode is direct (line number zero), 
; then return to line collection. 
; Otherwise, select the next line and begin interpretation.
;==============================================================================
ILM_NXT:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret