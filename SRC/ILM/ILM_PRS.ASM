;==============================================================================
; PRS
; Print characters from the BASIC text up to but not including the
; closing quote mark. 
; If a cr is found in the program text, report an error. 
; Move the cursor to the point following the closing quote.
;==============================================================================
ILM_PRS:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret