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

MAX_NUMBER		EQU 32767				;signed short
MAX_STACK		EQU 128					;max elements

;==============================================================================
; MAIN PROGRAM
;==============================================================================

		mov		dx,STR_WELCOME			;print welcome string
		call	PRINT_STR

START:
		call	ILM_INIT				;INITIALIZE
		call	ILM_NLINE				;WRITE CRLF

CO:     
; mov dx,sp
; call PRINT_WORD
; call ILM_NLINE

		mov		ax,PGM
		mov		[PGP],ax
		mov		[CURSOR],ax
		mov		[MODE],byte 00h

		call	ILM_GETLINE				;WRITE PROMPT AND GET LINE
		call	ILM_NLINE				;WRITE CRLF

		cmp		[LBUF],byte 00h			;LBUF empty ?
		je		CO

		call	ILM_TSTL                ;TEST FOR LINE NUMBER
		cmp		al,-1
		je		CO

		call	ILM_INSERT        		;INSERT IT (MAY BE DELETE)

		cmp		al,00h					;is direct ?
		jne		CO						;no, back to collection

XEC:    
		call	ILM_XINIT             	;INITIALIZE
;--------------------

DEBUG:

		mov		dx,STR_DEBUG			;DEBUG
		call	ILM_TST
		cmp		al,00h
		je		STMT
		;----------test code here

		mov		dx,[VARIABLES];A
		call	PRINT_NUMBER

		;----------test code here
		jmp		CO
;--------------------

STMT:   
		mov		dx,STR_LET
		call	ILM_TST
		cmp		al,00h
		je		S1

		call	ILM_TSTV
		cmp		al,-1
		je		CO
		cmp		al,00h
		je		S17

		mov		dx,STR_EQUAL
		call	ILM_TST
		cmp		al,00h
		je		S17

		call	EXPR

		call	ILM_DONE
		cmp		al,00h
		je		CO

		; TST     S1,'LET'      ;IS STATEMENT A LET
        ; TSTV    S17           ;YES, PLACE VAR ADDRESS ON AESTK
        ; TST     S17,'='       ;ASSIGNEMENT
        ; CALL    EXPR          ;PLACE EXPR VALUE ON AESTK
        ; DONE                  ;REPORT ERROR IF NOT NEXT
        ; STORE                 ;STORE RESULT
        ; NXT                   ;AND SEQUENCE TO NEXT

		call	ILM_STORE
		cmp		al,00h
		je		CO

		call	ILM_NXT
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC

S1:     
		mov		dx,STR_GOTO
		call	ILM_TST
		cmp		al,00h
		je		S2

		call	EXPR

		call 	ILM_DONE
		cmp		al,00h
		je		CO

		call	ILM_XPER
		cmp		al,0
		je		CO

		jmp		XEC
S2:     
		mov		dx,STR_GOSUB
		call	ILM_TST
		cmp		al,00h
		je		S3

		call 	EXPR

		call 	ILM_DONE
		cmp		al,00h
		je		CO             	;ERROR IF CR NOT NEXT

		call	ILM_SAV
		cmp		al,00h
		je		CO

		call	ILM_XPER
		cmp		al,0
		je		CO

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
		mov		dx,STR_QUOTES			;test for quote
		call	ILM_TST
		cmp		al,00h
		je		S7

		call	ILM_PRS         		;PRINT STRING
		cmp		al,00h
		je		CO

S5:     
		mov		dx,STR_COMMA			;comma for more
		call	ILM_TST
		cmp		al,00h
		je		S6

		call	ILM_SPC

		jmp		S4
S6:     
		call 	ILM_DONE
		cmp		al,00h
		je		CO             	;ERROR IF CR NOT NEXT

        call	ILM_NLINE

        call	ILM_NXT
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC
S7:     
		call    EXPR

		call	ILM_PRN
		cmp		al,00h
		je		CO

		jmp		S5

        ; PRN                   ;PRINT IT
        ; JMP     S5            ;IS THERE MORE?
S8:     
		; TST     S9,'IF'       ;IF STATEMENT
        ; CALL    EXPR          ;GET EXPRESSION
        ; CALL    RELOP         ;DETERMINE OPR AND PUT ON STK
        ; CALL    EXPR          ;GET EXPRESSION
        ; TST     S17,'THEN'    ;THEN BRANCH
        ; CMPR                  ;PERFORM COMPARE -- NXT IF FALSE
        ; JMP     XEC
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
		mov		dx,STR_RETURN
		call	ILM_TST
		cmp		al,00h
		je		S13

		call 	ILM_DONE
		cmp		al,00h
		je		CO             	;ERROR IF CR NOT NEXT

		call	ILM_RSTR
		cmp		al,00h
		je		CO

		call	ILM_NXT
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC

		; TST     S13,'RETURN'  ;RETURN STATEMENT
        ; DONE                  ;MUST BE CR
        ; RSTR                  ;RESTORE LINE NUMBER OF CALL
        ; NXT                   ;SEQUENCE TO NEXT STATEMENT
S13:    
		mov		dx,STR_END				;test "END"
		call	ILM_TST
		cmp		al,00h
		je 		S14

		call	ILM_DONE				;no need to test DONE result
        jmp		CO						;always jump to collection routine
S14:    
		mov		dx,STR_LIST				;test "LIST"
		call	ILM_TST
		cmp		al,00h
		je		S15

		call 	ILM_DONE
		cmp		al,00h
		je		CO

        call	ILM_LST					;print program

        call	ILM_NXT
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC
S15:    
		mov		dx,STR_RUN				;test "RUN"
		call	ILM_TST
		cmp		al,00h
		je		S16

        call 	ILM_DONE
		cmp		al,00h
		je		CO

		mov		[MODE],byte 01h			;set RUN mode

        call	ILM_NXT
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC
S16:    
		; TST     S17,'CLEAR'   ;CLEAR COMMAND
        ; DONE
        ; JMP     START
S17:    
		mov		[ERROR_CODE],word ERROR_SYNTAX
		call	ILM_ERR             	
		jmp		CO						;back to collection routine

EXPR:   
		mov		dx,STR_MINUS			;test "-"
		call	ILM_TST
		cmp		al,00h
		je		E0

		call	TERM					;TEST FOR UNARY

		call	ILM_NEG					;NEGATE IT
		cmp		al,00h
		je		CO

		jmp		E1
E0:     
		mov		dx,STR_PLUS				;test "+"
		call	ILM_TST
		cmp		al,00h
		je		E1A
E1A:   

		call	TERM   

E1:     
		mov		dx,STR_PLUS				;test "+"
		call	ILM_TST
		cmp		al,00h
		je		E2

		call	TERM

		call	ILM_ADD
		cmp		al,00h
		je		CO

		jmp		E1
E2:     
		mov		dx,STR_MINUS			;test "-"
		call	ILM_TST
		cmp		al,00h
		je		E3

		call	TERM

		call	ILM_SUB
		cmp		al,00h
		je 		CO

		jmp		E1
E3:
		ret

TERM:   
		call	FACT
T0:     
		mov		dx,STR_MUL				;test "*"
		call	ILM_TST
		cmp		al,00h
		je		T1

		call	FACT

		call 	ILM_MUL
		cmp		al,00h
		je		CO

		jmp		T0
T1:     
		mov		dx,STR_DIV				;test "/"
		call	ILM_TST
		cmp		al,00h
		je		T2

		call    FACT

        call	ILM_DIV
		cmp		al,00h
		je		CO

        jmp   	T0
T2:  
		ret

FACT:  
		call	ILM_TSTV
		cmp		al,-1
		je		CO
		cmp		al,00h
		je		F0
		
        call	ILM_IND                 ;YES, GET THE VALUE.
        cmp		al,00h
		je		CO

		ret
F0:     
		call	ILM_TSTN				;NUMBER, GET ITS VALUE.
		cmp		al,-1					;error goto CO
		je		CO
		cmp		al,00h					;match fail go to F1
		je		F1
					
		ret
F1:    
		mov		dx,STR_LPAREN
		call	ILM_TST
		cmp		al,00h
		je		F2

		call	EXPR

		mov		dx,STR_RPAREN
		call	ILM_TST
		cmp		al,00h
		je		F2

        ret
F2:     
		mov		[ERROR_CODE],word ERROR_SYNTAX
		call	ILM_ERR                 
		jmp		CO						;back to collection routine

RELOP:  
		; TST     R0,'='
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

;==============================================================================
; Include section
;==============================================================================
%INCLUDE "SRC/UTILS.ASM"					;required to use core functions

%INCLUDE "SRC/ILM/ILM_ADD.ASM"				;ILM functions
%INCLUDE "SRC/ILM/ILM_CMPR.ASM"
%INCLUDE "SRC/ILM/ILM_DIV.ASM"
%INCLUDE "SRC/ILM/ILM_DONE.ASM"
%INCLUDE "SRC/ILM/ILM_ERR.ASM"
%INCLUDE "SRC/ILM/ILM_GETLINE.ASM"
%INCLUDE "SRC/ILM/ILM_IND.ASM"
%INCLUDE "SRC/ILM/ILM_INIT.ASM"
%INCLUDE "SRC/ILM/ILM_INNUM.ASM"
%INCLUDE "SRC/ILM/ILM_INSERT.ASM"
%INCLUDE "SRC/ILM/ILM_LIT.ASM"
%INCLUDE "SRC/ILM/ILM_LST.ASM"
%INCLUDE "SRC/ILM/ILM_MUL.ASM"
%INCLUDE "SRC/ILM/ILM_NEG.ASM"
%INCLUDE "SRC/ILM/ILM_NLINE.ASM"
%INCLUDE "SRC/ILM/ILM_NXT.ASM"
%INCLUDE "SRC/ILM/ILM_PRN.ASM"
%INCLUDE "SRC/ILM/ILM_PRS.ASM"
%INCLUDE "SRC/ILM/ILM_RSTR.ASM"
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

;==============================================================================
; Vars section
;==============================================================================
;REMOVE ON RELEASE
STR_DEBUG				db "DEBUG",00h	
NOT_IMPLEMENTED			db "Not implemented",00h	

STR_DEBUG1				db "DEBUG1",0Ah,0Dh,00h	
STR_DEBUG2				db "DEBUG2",0Ah,0Dh,00h	
STR_DEBUG3				db "DEBUG3",0Ah,0Dh,00h	
STR_DEBUG4				db "DEBUG4",0Ah,0Dh,00h	

;welcome string
STR_WELCOME		db "TINY BASIC 8086",00h	

;list of language keywords
STR_LET			db "LET",00h
STR_GOTO		db "GOTO",00h	
STR_GOSUB		db "GOSUB",00h	
STR_END			db "END",00h	
STR_PRINT		db "PRINT",00h				
STR_LIST		db "LIST",00h				
STR_RUN			db "RUN",00h
STR_CLEAR		db "CLEAR",00h
STR_RETURN		db "RETURN",00h

STR_COMMA		db ',',00h
STR_QUOTES		db '"',00h
STR_EQUAL		db '=',00h
STR_MINUS		db '-',00h
STR_PLUS		db '+',00h
STR_MUL			db '*',00h
STR_DIV			db '/',00h
STR_LPAREN		db '(',00h
STR_RPAREN		db ')',00h

;error flag and list of available errors
ERROR_CODE					dw 0000h

ERROR_STR					db ":ERROR:",00h
ERROR_SYNTAX				db "Syntax error",00h					
ERROR_LINE_NUMBER			db "Invalid line number",00h
ERROR_EMPTY_LINE			db "Empty line",00h
ERROR_PGP 					db "PGP out of range",00h
ERROR_QUOTES				db "Missing quotes",00h
ERROR_INVALID_NUMBER		db "Number invalid",00h
ERROR_NOT_NUMBER			db "Not a number",00h
ERROR_BIG_NUMBER			db "Number too big",00h
ERROR_AESTACK_OVERFLOW		db "Arithmetic stack overflow",00h
ERROR_AESTACK_UNDERFLOW		db "Arithmetic stack underflow",00h
ERROR_SBRSTACK_OVERFLOW		db "Subroutines stack overflow",00h
ERROR_SBRSTACK_UNDERFLOW	db "Subroutines stack underflow",00h
ERROR_DIVIDE_ZERO			db "Divide by zero",00h

;ILM variables
MODE			db 00h						;0==direct, 1==run

VARIABLES		times 26 dw 0000h			;Variables A,B,C...Z 

AESTACK_BASE	times MAX_STACK dw 0000h	;Arithmetic Expression stack
AESTACK_POINTER db 00h

SBRSTACK_BASE	times MAX_STACK db 00h		;Subroutines stack
SBRSTACK_POINTER db 00h

LBUF 			times COLS db 00h			;the reading buffer
CURSOR			dw	0000h					;Cursor (byte pointer)
PGP				dw	0000h					;PGP (line pointer)
PGM				dw	0000h
;PGM				times 256 * COLS db 00h		;the PGM area (256 lines * 80 byte)

