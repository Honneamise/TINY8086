;==============================================================================
; Nasm directives
;==============================================================================
[CPU 8086]
[BITS 16]
[ORG 0000h]

;==============================================================================
; Const section
;==============================================================================
STACK_SEG       EQU 1000h
STACK_OFF       EQU 0FFFFh

ROWS            EQU 25
COLS            EQU 80

FG_COLOR        EQU 0Fh
BG_COLOR        EQU 10h

DIRECT			EQU 0
RUN				EQU 1

MAX_STACK		EQU 128					

;==============================================================================
; MAIN PROGRAM
;==============================================================================
START:
		call	ILM_CLEAR				;clear screen

		mov		dx,STR_WELCOME			;print welcome string
		call	PRINT_STR

		call	ILM_INIT				;init function (clear all)
		call	ILM_NLINE				;new line

CO:     
		mov		sp,STACK_OFF			;clear SP (error could happened)

		mov		ax,PGM					;copy PGM address
		mov		[PGP],ax				;set PGP at beginning of program
		mov		[CURSOR],ax				;set CURSOR at beginning of line
		mov		[MODE],byte 00h			;set mode 0 (direct)

		mov		al,3Eh					;set prompt '>'
		call	ILM_GETLINE				;get line in LBUF
		call	ILM_NLINE				;new line

		cmp		[LBUF],byte 00h			;LBUF empty ?
		je		CO						;skip

		call	ILM_TSTL                ;test for line number
		cmp		al,-1					;number valid ?
		je		CO						;if not back to collection

		call	ILM_INSERT        		;insert line

		cmp		al,00h					;is direct ?
		jne		CO						;no, back to collection

XEC:    
		call	ILM_XINIT             	;clear AESTACK

STMT:   
		mov		dx,STR_REM				;"REM" (comment)
		call	ILM_TST
		cmp		al,00h
		je		S0

		call	ILM_NXT					;next line
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC 
		
S0:
		mov		dx,STR_LET				;"LET"
		call	ILM_TST
		cmp		al,00h
		je		S1

		call	ILM_TSTV				;there is a variable ? ?
		cmp		al,-1
		je		CO
		cmp		al,00h
		je		ERROR

		mov		dx,STR_ASSIGN			;there is "=" assignement symbol ?
		call	ILM_TST
		cmp		al,00h
		je		ERROR

		call	EXPR					;evaluate expression

		call	ILM_DONE				;EOL ?
		cmp		al,00h
		je		CO

		call	ILM_STORE				;store value into variable
		cmp		al,00h
		je		CO

		call	ILM_NXT					;next line
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC

S1:     
		mov		dx,STR_GOTO				;"GOTO"
		call	ILM_TST
		cmp		al,00h
		je		S2

		call	EXPR					;evaluate expression

		call 	ILM_DONE				;EOL ?
		cmp		al,00h
		je		CO

		call	ILM_XPER				;set PGP to new line, reset CURSOR
		cmp		al,0
		je		CO

		jmp		XEC

S2:     
		mov		dx,STR_GOSUB			;"GOSUB"
		call	ILM_TST
		cmp		al,00h
		je		S3

		call 	EXPR					;evaluate expression

		call 	ILM_DONE				;EOL ?
		cmp		al,00h
		je		CO             			

		call	ILM_SAV					;save current line on SBRSTACK
		cmp		al,00h
		je		CO

		call	ILM_XPER				;set PGP to new line, reset CURSOR
		cmp		al,0
		je		CO

S3:     
		mov		dx,STR_PRINT			;"PRINT"
		call	ILM_TST
		cmp		al,00h
		je		S8

S4:     
		mov		dx,STR_QUOTES			;chack for quotes
		call	ILM_TST
		cmp		al,00h
		je		S7

		call	ILM_PRS         		;print the string
		cmp		al,00h
		je		CO

S5:     
		mov		dx,STR_COMMA			;check comma for more
		call	ILM_TST
		cmp		al,00h
		je		S6

		call	ILM_SPC					;add single space

		jmp		S4

S6:     
		call 	ILM_DONE				;EOL ?
		cmp		al,00h
		je		CO             			

        call	ILM_NLINE				;new line

        call	ILM_NXT					;next line
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC

S7:     
		call    EXPR					;evaluate expression

		call	ILM_PRN					;print number
		cmp		al,00h
		je		CO

		jmp		S5

S8:     
		mov		dx,STR_IF				;"IF"
		call	ILM_TST
		cmp		al,00h
		je		S9

		call	EXPR					;evaluate expression

		call	RELOP					;set logical operator on AESTACK
		
		call	EXPR					;evaluate expression

        mov		dx,STR_THEN				;check "THEN"
		call	ILM_TST
		cmp		al,00h
		je		ERROR              

		call	ILM_CMPR				;perform compare
		cmp		al,-1
		je		CO
		cmp		al,00h
		jne		XEC						;match ok, execute "THEN" part

		call	ILM_NXT					;no match, next line
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC

S9:      
		mov		dx,STR_INPUT			;"INPUT"
		call	ILM_TST
		cmp		al,00h
		je		S12

S10:    
		call	ILM_TSTV				;check for Variable letter
		cmp		al,-1
		je		CO
		cmp		al,00h
		je		ERROR

		call	ILM_INNUM				;get number
		cmp		al,00h
		je		CO

        call	ILM_STORE				;store the number in the variable
		cmp		al,00h
		je		CO

        mov		dx,STR_COMMA			;check for more elements
		call	ILM_TST
		cmp		al,00h
		je		S11
		
        jmp		S10			

S11:    
		call 	ILM_DONE				;EOL ?
		cmp		al,00h
		je		CO             	

        call	ILM_NXT					;next line
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC

S12:    
		mov		dx,STR_RETURN			;"RETURN"
		call	ILM_TST
		cmp		al,00h
		je		S13

		call 	ILM_DONE				;EOL ?
		cmp		al,00h
		je		CO             	

		call	ILM_RSTR				;restore previous line
		cmp		al,00h
		je		CO

		call	ILM_NXT					;next line
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC

S13:    
		mov		dx,STR_END				;"END"
		call	ILM_TST
		cmp		al,00h
		je 		S14

		call	ILM_DONE				;no need to test DONE result
        jmp		CO						;always jump to collection routine

S14:    
		mov		dx,STR_LIST				;"LIST"
		call	ILM_TST
		cmp		al,00h
		je		S15

		call 	ILM_DONE				;EOL ?
		cmp		al,00h
		je		CO

		cmp		byte [MODE],DIRECT		;im in DIRECT mode ?
		je		S14A

		mov		[ERROR_CODE],word ERROR_MODE
		call	ILM_ERR					;no, print error and go back to CO
		jmp		CO

S14A:		
        call	ILM_LST					;print program
		jmp		CO

S15:    
		mov		dx,STR_RUN				;"RUN"
		call	ILM_TST
		cmp		al,00h
		je		S16

        call 	ILM_DONE				;EOL ? 
		cmp		al,00h
		je		CO

		cmp		byte [MODE],DIRECT		;im in DIRECT mode ?
		je		S15A

		mov		[ERROR_CODE],word ERROR_MODE
		call	ILM_ERR					;no, print error and go back to CO
		jmp		CO

S15A:
		mov		byte [MODE],RUN			;set RUN mode

        call	ILM_NXT					;next line
		cmp		al,00h
		je		CO
		cmp		al,01h
		je		XEC

S16:    
		mov		dx,STR_RESET			;test "RESET"
		call	ILM_TST
		cmp		al,00h
		je		ERROR

		call 	ILM_DONE				;EOL ?
		cmp		al,00h
		je		CO

		cmp		byte [MODE],DIRECT		;im in DIRECT mode ?
		je		S16A

		mov		[ERROR_CODE],word ERROR_MODE
		call	ILM_ERR					;no, print error and go back to CO
		jmp		CO

S16A:
        jmp		START					;back to beginning

ERROR:    
		mov		[ERROR_CODE],word ERROR_SYNTAX
		call	ILM_ERR             	
		jmp		CO						;back to collection routine

EXPR:   
		mov		dx,STR_MINUS			;"-" (unary)
		call	ILM_TST
		cmp		al,00h
		je		E0

		call	TERM					;evaluate term

		call	ILM_NEG					;negate it
		cmp		al,00h
		je		CO

		jmp		E1

E0:     
		mov		dx,STR_PLUS				;"+"  (unary)
		call	ILM_TST
		cmp		al,00h
		je		E1A

E1A:   
		call	TERM   					;evaluate term

E1:     
		mov		dx,STR_PLUS				;"+"
		call	ILM_TST
		cmp		al,00h
		je		E2

		call	TERM					;evaluate term

		call	ILM_ADD					;addition
		cmp		al,00h
		je		CO

		jmp		E1

E2:     
		mov		dx,STR_MINUS			;test "-"
		call	ILM_TST
		cmp		al,00h
		je		E3

		call	TERM					;evaluate term

		call	ILM_SUB					;subtraction
		cmp		al,00h
		je 		CO

		jmp		E1

E3:
		ret

TERM:   
		call	FACT					;evaluate factorial

T0:     
		mov		dx,STR_MUL				;"*"
		call	ILM_TST
		cmp		al,00h
		je		T1

		call	FACT					;evaluate factorial

		call 	ILM_MUL					;multiply
		cmp		al,00h
		je		CO

		jmp		T0

T1:     
		mov		dx,STR_DIV				;"/"
		call	ILM_TST
		cmp		al,00h
		je		T2

		call    FACT					;evaluate factorial

        call	ILM_DIV					;division
		cmp		al,00h
		je		CO

        jmp   	T0

T2:  
		ret

FACT:  
		call	ILM_TSTV				;is Variable ?
		cmp		al,-1
		je		CO
		cmp		al,00h
		je		F0
		
        call	ILM_IND                 ;swap top AESTACK with value of Variable index
        cmp		al,00h
		je		CO

		ret

F0:     
		call	ILM_TSTN				;is Number ?
		cmp		al,-1					
		je		CO
		cmp		al,00h					
		je		F1
					
		ret

F1:    
		mov		dx,STR_LPAREN			;"("
		call	ILM_TST
		cmp		al,00h
		je		F2

		call	EXPR					;evaluate expression

		mov		dx,STR_RPAREN			;")"
		call	ILM_TST
		cmp		al,00h
		je		F2

        ret

F2:     
		mov		[ERROR_CODE],word ERROR_SYNTAX
		call	ILM_ERR                 
		jmp		CO						;back to collection routine

; RELOP/CODE :
; == 0
; != 1
; <= 2
; >= 3
;  < 4
;  > 5

RELOP:  
		mov		dx,STR_OP_E				;test "=="
		call	ILM_TST
		cmp		al,00h
		je		R0

		mov		dx,0
		jmp		R5

R0:  
		mov		dx,STR_OP_NE			;test "!="
		call	ILM_TST
		cmp		al,00h
		je		R1

		mov		dx,1
		jmp		R5

R1:     
		mov		dx,STR_OP_LE			;test "<="
		call	ILM_TST
		cmp		al,00h
		je		R2

		mov		dx,2
		jmp		R5

R2: 
		mov		dx,STR_OP_GE			;test ">="
		call	ILM_TST
		cmp		al,00h
		je		R3

		mov		dx,3
		jmp		R5

R3:   
		mov		dx,STR_OP_L				;test "<"
		call	ILM_TST
		cmp		al,00h
		je		R4

		mov		dx,4
		jmp		R5        

R4:     
		mov		dx,STR_OP_G				;test ">"
		call	ILM_TST
		cmp		al,00h
		je		R6

		mov		dx,5

R5:	
		call	ILM_LIT					;push DX on Aestack
		cmp		al,00h
		je		CO

		ret								;done success !

R6:     
        mov		[ERROR_CODE],word ERROR_OPERATOR
		call	ILM_ERR
		jmp		CO

END:									;this point should never be reached
		cli                             ;disable interrupts
        hlt                             ;halt system

;==============================================================================
; Include section
;==============================================================================
%INCLUDE "SRC/UTILS.ASM"					;required to use core functions

%INCLUDE "SRC/ILM/ILM_ADD.ASM"				;ILM functions
%INCLUDE "SRC/ILM/ILM_CLEAR.ASM"
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
;welcome string
STR_WELCOME		db "TINY BASIC 8086",0Ah,0Dh,"Vers.2023 by Honny",00h	

;list of language keywords
STR_REM			db "REM",00h
STR_LET			db "LET",00h
STR_GOTO		db "GOTO",00h	
STR_GOSUB		db "GOSUB",00h	
STR_END			db "END",00h	
STR_PRINT		db "PRINT",00h				
STR_LIST		db "LIST",00h				
STR_RUN			db "RUN",00h
STR_RESET		db "RESET",00h
STR_RETURN		db "RETURN",00h
STR_INPUT		db "INPUT",00h
STR_IF			db "IF",00h
STR_THEN		db "THEN",00h

STR_COMMA		db ',',00h
STR_QUOTES		db '"',00h
STR_ASSIGN		db '=',00h
STR_MINUS		db '-',00h
STR_PLUS		db '+',00h
STR_MUL			db '*',00h
STR_DIV			db '/',00h
STR_LPAREN		db '(',00h
STR_RPAREN		db ')',00h

;list of logic operators
STR_OP_E		db "==",00h
STR_OP_NE		db "!=",00h
STR_OP_LE		db "<=",00h
STR_OP_GE		db ">=",00h
STR_OP_L		db "<",00h
STR_OP_G		db ">",00h

;error flag and list of available errors
ERROR_CODE					dw 0000h

ERROR_STR					db "ERROR",00h
ERROR_STR_AT_LINE			db "ERROR at line ",00h
ERROR_SYNTAX				db ":Syntax error",00h					
ERROR_LINE_NUMBER			db ":Invalid line number",00h
ERROR_EMPTY_LINE			db ":Empty line",00h
ERROR_PGP 					db ":PGP out of range",00h
ERROR_QUOTES				db ":Missing quotes",00h
ERROR_INVALID_NUMBER		db ":Number invalid",00h
ERROR_NOT_NUMBER			db ":Not a number",00h
ERROR_NUMBER_OVERFLOW		db ":Number out of range",00h
ERROR_AESTACK_OVERFLOW		db ":Arithmetic stack overflow",00h
ERROR_AESTACK_UNDERFLOW		db ":Arithmetic stack underflow",00h
ERROR_SBRSTACK_OVERFLOW		db ":Subroutines stack overflow",00h
ERROR_SBRSTACK_UNDERFLOW	db ":Subroutines stack underflow",00h
ERROR_DIVIDE_ZERO			db ":Divide by zero",00h
ERROR_OPERATOR				db ":Invalid operator",00h
ERROR_MODE					db ":Unavailable for current mode",00h

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

