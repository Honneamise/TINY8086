;==============================================================================
; Nasm directives
;==============================================================================
[CPU 8086]
[BITS 16]
[ORG 00h]

;==============================================================================
; Const section
;==============================================================================
ROWS            EQU 25
COLS            EQU 80

DIRECT			EQU 0
RUN				EQU 1

;==============================================================================
; MAIN PROGRAM
;==============================================================================

		mov		dx,STR_WELCOME				;print welcome string
		call	PRINT_STR

START:

		call	ILM_INIT				;INITIALIZE
		call	ILM_NLINE				;WRITE CRLF

CO:     
		mov		[PGP],word PGM			;reset line
		mov		[CURSOR],word PGM		;reset cursor

		call	ILM_GETLINE				;WRITE PROMPT AND GET LINE

		call	ILM_NLINE				;WRITE CRLF

		call	ILM_TSTL                ;TEST FOR LINE NUMBER

		cmp		al,00h					;if line 0 direct mode
		je		_XEC

		call	ILM_INSERT        		;INSERT IT (MAY BE DELETE)
		jmp     CO						;return to collect

_XEC:
		call	ILM_INSERT				;insert for line 0
		mov		bx,[PGP]
		cmp		[bx],byte 00h				;if empty line skip
		je		CO

XEC:    
		call	ILM_XINIT             	;INITIALIZE

STMT:

S3:     
		mov		dx,STR_PRINT
		call	ILM_TST
		cmp		al,00h
		je		S14						;!!! REPLACE WITH S8
		
S4:     
		mov		dx,STR_QUOTE
		call	ILM_TST
		cmp		al,00h
		je		S17       				;!!! REPLACE WITH S7
        call	ILM_PRS                 ;PRINT STRING
		
		call	ILM_DONE
		call	ILM_NXT

; S5:     
; 		TST     S6,','        			;IS THERE MORE?
;         SPC                   			;SPACE TO NEXT ZONE
;         JMP     S4            			;YES JUMP BACK
; S6:     
; 		DONE                  			;ERROR IF CR NOT NEXT
;         NLINE
;         NXT

S14:    
		mov		dx,STR_LIST				;LIST COMMAND
		call	ILM_TST

		cmp		al,00h					;no match
		je		S15						;!!! REPLACE WITH S15

		call	ILM_DONE
		call	ILM_LST
		call	ILM_NXT

S15:    
		mov		dx,STR_RUN				;RUN COMMAND
		call	ILM_TST
        
		cmp		al,00h
		je		S16

		call	ILM_DONE

		mov		ax,PGM+COLS
		mov		[PGP],ax				;select first line
		mov		[CURSOR],ax

		jmp		XEC
		

S16:
		;to do

S17:    call	ILM_ERR	          		;SYNTAX ERROR

END:	cli                             ;disable interrupts
        hlt                             ;halt system


ERROR:									
		call	ILM_NLINE				;new line
		
		mov		ax,[PGP]				;get line address
		cmp		ax,PGM					;line 0 ?
		je		.str					;dont print line number

		sub		ax,PGM					;calculate line number
		mov		bx,COLS
		div		bx

	.num:								;print line number
		mov		dx,ax
		call	PRINT_NUMBER

		mov     ah,0Eh                  ;teletype print interupt
        mov 	al,3Ah                 	;column
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
LBUF 			times COLS db 00h			;the reading buffer

PGM				times 256 * COLS db 00h		;the PGM area (256 lines * 80 byte)
PGP				dw	0000h					;PGP (line pointer)
CURSOR			dw	0000h					;Cursor (byte pointer)

STR_WELCOME		db "TINY BASIC 8086",00h	;welcome string
NOT_IMPLEMENTED	db "Not mplemented",00h		;REMOVE ON RELEASE

;list of language keywords
STR_PRINT		db "PRINT",00h				
STR_QUOTE		db 22h,00h
STR_LIST		db "LIST",00h				
STR_RUN			db "RUN",00h
STR_CLEAR		db "CLEAR",00h

;error flag and list of available errors
ERROR_STR				dw 0000h

ERROR_SYNTAX	db "Syntax error",00h					
ERROR_LINE		db "Invalid line number",00h
ERROR_PGP 		db "PGP out of range",00h
ERROR_QUOTES	db "Missing quotes",00h

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
%INCLUDE "SRC/ILM/ILM_XFER.ASM"
%INCLUDE "SRC/ILM/ILM_XINIT.ASM"