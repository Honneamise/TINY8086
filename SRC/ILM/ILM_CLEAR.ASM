;==============================================================================
; CLEAR
; clear the entire scren using ILM values
;==============================================================================
ILM_CLEAR:
        mov     ah,06h                  ;clear screen service
        mov     al,00h                  ;lines to scroll (if 0 all)
        mov     bh,BG_COLOR|FG_COLOR    ;background/foreground colors
        mov     ch,00h                  ;Row number of upper left corner
        mov     cl,00h                  ;Column number of upper left corner
        mov     dh,ROWS-1               ;Row number of lower right corner
        mov     dl,COLS-1               ;Column number of lower right corner
        int     10h                     

        mov     ah,02h                  ;int to reset cursor position
        mov     bh,00h                  ;page number
        mov     dx,000h                 ;row/col
        int     10h

        ret