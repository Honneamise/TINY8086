;==============================================================================
; CALL lbl	
; Execute the IL subroutine starting at lbl. 
; Save the IL address following the CALL on the control stack.
;==============================================================================
ILM_CALL:
        mov     DX,NOT_IMPLEMENTED
        call    PRINT_STR
        ret