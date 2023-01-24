;==============================================================================
; Expect in DX the beginning of the string
;==============================================================================
PRINT_STR:                       

        mov     si,dx                   ;copy the start of string in SI
        mov     ah,0Eh                  ;interrupt 10h code (teletype print)
        mov     bh,00h                  ;interrupt 10h page 0

    .next: 
        mov     al,[si]                 ;copy in al the current byte to print
        cmp     al,00h                  ;compare al with 0x00 (string end)
        jz      .done                  	;if zero, go to finish
        int     10h                     ;call interrupt
        inc     si                      ;move forward
        jmp     .next                  	;repeat

    .done:
        ret

;==============================================================================
; Expect in DX the word to print (NOTE : we "consume" DX from the head)
;==============================================================================
PRINT_WORD:                     

        mov     ch,04h                  ;use CH as nibble counter
        mov     cl,04h                  ;use CL for 4 bit shift
        mov     ah,0Eh                  ;write characters in teletype mode
        mov     bh,00h                  ;write at page 0

    .cycle:
        mov     al,dh                   ;copy in al the high byte of DX
        and     al,0F0h                 ;get the left nibble
        shr     al,cl                   ;shift it to right
        
        add     al,30h                  ;add 48 to get the printable char
        cmp     al,39h                  ;is number or letter ?
        jbe     .print                 	;if less is a number, go to print it
        add     al,07h                  ;is a letter, add 7 more

    .print:
        int     10h                     ;call interrupt

        dec     ch                      ;decrease the counter
        jz      .done                  	;if zero we have done
        shl     dx,cl                   ;advance next nibble
        jmp     .cycle                 	;repeat

    .done:
        ret

;==============================================================================
; Print a number in decimal format, expect in DX the number to print
; NOTE : we use the stack to "decompose" the number
;==============================================================================
PRINT_NUMBER:

        mov     ax,dx                   ;copy the number in AX
        cmp     ax,00h                  ;it is zero ?
        je      .zero                   ;jmp to special case

        or 		ax,ax                   ;check if negative
		jns 	.positive               ;no, continue
	
    .negative:                             
                                        
        mov     ah,0EH                  ;print the minus sign          
        mov     al,2Dh                  
        mov     bh,00h    
        int     10h
                                        
        mov     ax,dx                   ;put in AX the absolute value
    	not 	ax                     
		inc 	ax                      

    .positive:
        
        mov     bx,10                   ;we use base 10
        xor     cx,cx                   ;will be counter for stack
        xor     dx,dx                   ;will hold remainder of division

    .pusher:                            ;loop to push numbers on stack
            
        cmp     ax,0                    ;if here finished
        je      .popper                 ;go to loop that print the numbers
            
        div     bx                      ;divide AX by 10
            
        push    dx                      ;push the remainder of division on stack             
            
        inc     cx                      ;increase the stack counter
            
        xor     dx,dx                   ;clear DX for next division
        
        jmp     .pusher                 ;repeat popper cycle
    
    .popper:                            ;cycle to pop elements and print them
            
        cmp     cx,00h                  ;still have elements on stack ?
        je      .done                   ;no, exit
            
        pop     ax                      ;get the number from the stack
            
        mov     ah,0EH                  ;set ah for teletype print
        add     al,30h                  ;make the number an ascii value
        mov     bh,00h                  ;page 00h
        int     10h                     ;call interrupt

        dec     cx                      ;decrease the counter

        jmp     .popper                 ;repeat pop items
    
    .zero:                              ;special case for 0
        mov     ah,0EH
        mov     al,30h
        mov     bh,00h    
        int     10h

    .done:
        ret

;==============================================================================
; Wait for a key press
;==============================================================================
WAIT_KEY:  
        xor     ax,ax                   ;keyboard read function
        int     16h                     ;interrupt for keyboard I/O services
        ret

