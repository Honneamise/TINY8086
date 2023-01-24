;==============================================================================
; TSTN lbl
; Test for number. 
; If present, place its value onto the AESTK and continue execution 
; at next suggested location. 
; Otherwise continue at lbl.
;==============================================================================
ILM_TSTN:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret