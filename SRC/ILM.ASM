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

		mov		dx,INTP_STR				;print welcome string
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

		push	ax						;save line number on stack

		cmp		al,00h					;compare AL with 0
		jl		CO						;if less we have an error

		call	ILM_INSERT        		;INSERT IT (MAY BE DELETE)

		pop		ax						;was line 0 ?
		cmp		al,00h
		je		XEC
		
		jmp     CO						;return to collect

XEC:    
		call	ILM_XINIT             	;INITIALIZE

STMT:

		
S14:    
		mov		dx,LIST_STR				;LIST COMMAND
		call	ILM_TST

		cmp		al,00h					;no match
		je		S17						;!!! REPLACE WITH S15

		call	ILM_DONE
		call	ILM_LST
		call	ILM_NXT

S17:    call	ILM_ERR	          		;SYNTAX ERROR

END:	cli                             ;disable interrupts
        hlt                             ;halt system



;==============================================================================
; Vars section
;==============================================================================
MODE			db 00h

LBUF 			times COLS db 00h			;the reading buffer

PGM				times 256 * COLS db 00h		;the PGM area (256 lines * 80 byte)
PGP				dw	0000h					;PGP (line pointer)
CURSOR			dw	0000h					;Cursor (byte pointer)

INTP_STR 		db "TINY BASIC 8086",00h	;welcome string
NOT_IMPLEMENTED	db "Not mplemented",00h		;REMOVE ON RELEASE

LIST_STR		db "LIST",00h				;list of language keywords
RUN_STR			db "RUN",00h
CLEAR_STR		db "CLEAR",00h

SYNTAX_ERROR	db "Syntax error",00h		;list of available errors			
LINE_ERROR		db "Invalid line number",00h

DEBUG_1			db "DEBUG_1",00h		;REMOVE ON RELEASE
DEBUG_2			db "DEBUG_2",00h		;REMOVE ON RELEASE
DEBUG_3			db "DEBUG_3",00h		;REMOVE ON RELEASE
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