;==============================================================================
; SPC
; Insert spaces, to move the print head to next zone.
;==============================================================================
ILM_SPC:
        mov		al,20h					;space
		mov     ah,0Eh                  ;interrupt 10h code (teletype print)
        mov     bh,00h                  ;interrupt 10h page 0
		int		10h
		
        ret