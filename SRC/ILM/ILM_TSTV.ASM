;==============================================================================
; TSTV lbl
; Test for variable (i.e letter) if present.
; Place its index value onto the AESTK and continue execution at next suggested
; location. 
; Otherwise continue at lbl.
;==============================================================================
ILM_TSTV:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret