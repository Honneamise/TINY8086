;==============================================================================
; Nasm directives
;==============================================================================
[CPU 8086]
[BITS 16]
[ORG 0000h]

;==============================================================================
; Const section
;==============================================================================
ROWS            EQU 25
COLS            EQU 80

DIRECT			EQU 0
RUN				EQU 1

MAX_NUMBER		EQU 32767				;(max is signed)
MAX_STACK		EQU 255

;==============================================================================
; MAIN PROGRAM
;==============================================================================

		mov		dx,STR_WELCOME				;print welcome string
		call	PRINT_STR

START:
		call	ILM_INIT				;INITIALIZE
		call	ILM_NLINE				;WRITE CRLF

CO:     
		mov		ax,PGM
		mov		[PGP],ax
		mov		[CURSOR],ax
		mov		[MODE],byte 00h

		call	ILM_GETLINE				;WRITE PROMPT AND GET LINE
		call	ILM_NLINE				;WRITE CRLF

		cmp		[LBUF],byte 00h			;LBUB empty ?
		je		CO

		call	ILM_TSTL                ;TEST FOR LINE NUMBER

		call	ILM_INSERT        		;INSERT IT (MAY BE DELETE)

		cmp		al,00h					;is direct ?
		jne		CO						;no, back to collection

XEC:    
		call	ILM_XINIT             	;INITIALIZE
;---------------------------
; call	ILM_TSTN

; mov	dx,[AESTACK_BASE]
; call PRINT_NUMBER

;---------------------------
STMT:   
		; TST     S1,'LET'      ;IS STATEMENT A LET
        ; TSTV    S17           ;YES, PLACE VAR ADDRESS ON AESTK
        ; TST     S17,'='       ;ASSIGNEMENT
        ; CALL    EXPR          ;PLACE EXPR VALUE ON AESTK
        ; DONE                  ;REPORT ERROR IF NOT NEXT
        ; STORE                 ;STORE RESULT
        ; NXT                   ;AND SEQUENCE TO NEXT
S1:     
		; TST     S2,'GOTO'     ;GOTO OT GOSUB?
        ; CALL    EXPR          ;GET LABEL
        ; DONE                  ;ERROR IF CR NOT NEXT
        ; XPER                  ;SET UP AND JUMP
S2:     
		; TST     S3,'GOSUB'    ;ERROR IF NO MATCH
        ; CALL    EXPR          ;GET DESTINATION
        ; DONE                  ;ERROR IF CR NOT NEXT
        ; SAV                   ;SAVE RETURN LINE
        ; XPER                  ;AND JUMP
S3:     
		mov		dx,STR_PRINT			;"PRINT"
		call	ILM_TST
		cmp		al,00h
		je		S8
S4:     
		mov		dx,STR_QUOTE			;test for quote
		call	ILM_TST
		cmp		al,00h
		je		S7
		call	ILM_PRS         		;PRINT STRING
S5:     
		; TST     S6,','        ;IS THERE MORE?
        ; SPC                   ;SPACE TO NEXT ZONE
        ; JMP     S4            ;YES JUMP BACK
S6:     
		call	ILM_DONE             	;ERROR IF CR NOT NEXT
        call	ILM_NLINE
        call	ILM_NXT
S7:     
		; CALL    EXPR
        ; PRN                   ;PRINT IT
        ; JMP     S5            ;IS THERE MORE?
S8:     
		; TST     S9,'IF'       ;IF STATEMENT
        ; CALL    EXPR          ;GET EXPRESSION
        ; CALL    RELOP         ;DETERMINE OPR AND PUT ON STK
        ; CALL    EXPR          ;GET EXPRESSION
        ; TST     S17,'THEN'    ;THEN BRANCH
        ; CMPR                  ;PERFORM COMPARE -- NXT IF FALSE
        ; JMP     STMT
S9:     
		; TST     S12,'INPUT'   ;INPUT STATEMENT
S10:    
		; TSTV    S17           ;GET VAR ADDRESS
        ; INNUM                 ;MOVE NUMBER FROM TTY TO AESTK
        ; STORE                 ;STORE IT
        ; TST     S11,','       ;IS THERE MORE?
        ; JMP     S10           ;YES
S11:    
		; DONE                  ;MUST BE CR
        ; NXT                   ;SEQUENCE TO NEXT
S12:    
		; TST     S13,'RETURN'  ;RETURN STATEMENT
        ; DONE                  ;MUST BE CR
        ; RSTR                  ;RESTORE LINE NUMBER OF CALL
        ; NXT                   ;SEQUENCE TO NEXT STATEMENT
S13:    
		mov		dx,STR_END				;END PROGRAM
		call	ILM_TST
		cmp		al,00h
		je		S14

		call	ILM_DONE
        call	ILM_FIN
S14:    
		mov		dx,STR_LIST				;LIST COMMAND
		call	ILM_TST
		cmp		al,00h
		je		S15

		call	ILM_DONE
        call	ILM_LST
        call	ILM_NXT
S15:    
		mov		dx,STR_RUN				;RUN COMMAND
		call	ILM_TST
		cmp		al,00h
		je		S16
        call	ILM_DONE
		mov		[MODE],byte 01h			;set RUN mode
        call	ILM_NXT
S16:    
		; TST     S17,'CLEAR'   ;CLEAR COMMAND
        ; DONE
        ; JMP     START
S17:    
		call	ILM_ERR             	;SYNTAX ERROR

EXPR:   
		; TST     E0,'-'
        ; CALL    TERM          ;TEST FOR UNARY -.
        ; NEG                   ;GET VALUE
        ; JMP     E1            ;NEGATE IT
E0:     
		; TST     E1A,'+'       ;LOOK FOR MORE
E1A:    
		; CALL    TERM          ;TEST FOR UNARY +
E1:     
		; TST     E2,'+'        ;LEADING TERM
        ; CALL    TERM
        ; ADD
        ; JMP     E1
E2:     
		; TST     E3,'-'        ;ANY MORE?
        ; CALL    TERM          ;DIFFERENCE TERM
        ; SUB
        ; JMP     E1
E3:
T2:  
		; RTN                   ;ANY MORE?
TERM:   
		; CALL    FACT
T0:     
		; TST     T1,"*"
        ; CALL    FACT          ;PRODUCT FACTOR.
        ; MUL
        ; JMP     T0
T1:     
		; TST     T2,'/'
        ; CALL    FACT          ;QUOTIENT FACTOR.
        ; DIV
        ; JMP     T0

FACT:   
		; TSTV    F0
        ; IND                   ;YES, GET THE VALUE.
        ; RTN
F0:     
		call	ILM_TSTN				 ;NUMBER, GET ITS VALUE.
		cmp		al,00h
		je		F1
		ret
		
F1:     
		; TST     F2,'('        ;PARENTHESIZED EXPR.
        ; CALL    EXPR
        ; TST     F2,')'
        ; RTN
F2:     
		call	ILM_ERR                   ;ERROR.

RELOP:  
		; TST     RO,'='
        ; LIT     0             ;=
        ; RTN
R0:     
		; TST     R4,'<'
        ; TST     R1,'='
        ; LIT     2             ;<=
        ; RTN
R1:     
		; TST     R3,'>'
        ; LIT     3             ;<>
        ; RTN
R3:     
		; LIT     1             ;<
        ; RTN
R4:     
		; TST     S17,'>'
        ; TST     R5,'='
        ; LIT     5             ;>=
        ; RTN
R5:     
		; TST     R6,'<'
        ; LIT     3
        ; RTN                   
R6:     
		; LIT     4
        ; RTN

END:									;this point should never be reached
		cli                             ;disable interrupts
        hlt                             ;halt system

;------------------------------------------------------------------------------
ERROR:									
		call	ILM_NLINE				;new line
		
		cmp		[MODE],byte 00h			;direct mode ?
		je		.str					;dont print line number

		mov		ax,[PGP]				;convert line address to line number
		sub		ax,PGM					
		mov		bl,COLS
		div		bl

	.num:								;print line number
		mov		dx,ax
		call	PRINT_NUMBER

		mov     ah,0Eh                  ;teletype print interupt
        mov 	al,3Ah                 	;column symbol
        mov     bh,00h                  ;page
        int     10h                     ;call interrupt
		
	.str:								;print error string
		mov		dx,[ERROR_STR]				
		call	PRINT_STR
		call	ILM_NLINE
		jmp		CO						;back to collection routine

;==============================================================================
; Vars section
;==============================================================================
MODE			db 00h						;0==direct, 1==run

LBUF 			times COLS db 00h			;the reading buffer

PGM				times 256 * COLS db 00h		;the PGM area (256 lines * 80 byte)
PGP				dw	0000h					;PGP (line pointer)
CURSOR			dw	0000h					;Cursor (byte pointer)

VARIABLES		times 25 dw 0000h			;Variables A,B,C...Z 

AESTACK_BASE	times 256 dw 0000h			;Arithmetic Expression stack
AESTACK_POINTER db 00h

SBRSTACK_BASE	times 256 db 00h			;Subroutines stack
SBRSTACK_POINTER db 00h

STR_WELCOME		db "TINY BASIC 8086",00h	;welcome string
NOT_IMPLEMENTED	db "Not mplemented",00h		;REMOVE ON RELEASE

;list of language keywords
STR_GOTO		db "GOTO",00h	
STR_END			db "END",00h	
STR_PRINT		db "PRINT",00h				
STR_LIST		db "LIST",00h				
STR_RUN			db "RUN",00h
STR_CLEAR		db "CLEAR",00h
STR_QUOTE		db 22h,00h

;error flag and list of available errors
ERROR_STR				dw 0000h

ERROR_SYNTAX			db "Syntax error",00h					
ERROR_LINE				db "Invalid line number",00h
ERROR_PGP 				db "PGP out of range",00h
ERROR_QUOTES			db "Missing quotes",00h
ERROR_NUMBER			db "Number invalid",00h
ERROR_AESTACK_OVERFLOW	db "Arithmetic stack overflow",00h
ERROR_AESTACK_UNDERFLOW	db "Arithmetic stack underflow",00h

;debug remove on release
DEBUG_1			db "Debug 1",00h
DEBUG_2			db "Debug 2",00h
DEBUG_3			db "Debug 3",00h
;==============================================================================
; Include section
;==============================================================================
%INCLUDE "SRC/UTILS.ASM"					;required to use core functions

%INCLUDE "SRC/ILM/ILM_ADD.ASM"				;ILM functions
%INCLUDE "SRC/ILM/ILM_CALL.ASM"
%INCLUDE "SRC/ILM/ILM_CMPR.ASM"
%INCLUDE "SRC/ILM/ILM_DIV.ASM"
%INCLUDE "SRC/ILM/ILM_DONE.ASM"
%INCLUDE "SRC/ILM/ILM_ERR.ASM"
%INCLUDE "SRC/ILM/ILM_FIN.ASM"
%INCLUDE "SRC/ILM/ILM_GETLINE.ASM"
%INCLUDE "SRC/ILM/ILM_IND.ASM"
%INCLUDE "SRC/ILM/ILM_INIT.ASM"
%INCLUDE "SRC/ILM/ILM_INNUM.ASM"
%INCLUDE "SRC/ILM/ILM_INSERT.ASM"
%INCLUDE "SRC/ILM/ILM_JUMP.ASM"
%INCLUDE "SRC/ILM/ILM_LIT.ASM"
%INCLUDE "SRC/ILM/ILM_LST.ASM"
%INCLUDE "SRC/ILM/ILM_MUL.ASM"
%INCLUDE "SRC/ILM/ILM_NEG.ASM"
%INCLUDE "SRC/ILM/ILM_NLINE.ASM"
%INCLUDE "SRC/ILM/ILM_NXT.ASM"
%INCLUDE "SRC/ILM/ILM_PRN.ASM"
%INCLUDE "SRC/ILM/ILM_PRS.ASM"
%INCLUDE "SRC/ILM/ILM_RSTR.ASM"
%INCLUDE "SRC/ILM/ILM_RTN.ASM"
%INCLUDE "SRC/ILM/ILM_SAV.ASM"
%INCLUDE "SRC/ILM/ILM_SPC.ASM"
%INCLUDE "SRC/ILM/ILM_STORE.ASM"
%INCLUDE "SRC/ILM/ILM_SUB.ASM"
%INCLUDE "SRC/ILM/ILM_TST.ASM"
%INCLUDE "SRC/ILM/ILM_TSTL.ASM"
%INCLUDE "SRC/ILM/ILM_TSTN.ASM"
%INCLUDE "SRC/ILM/ILM_TSTV.ASM"
%INCLUDE "SRC/ILM/ILM_XPER.ASM"
%INCLUDE "SRC/ILM/ILM_XINIT.ASM"