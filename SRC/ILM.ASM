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

;==============================================================================
; MAIN PROGRAM
;==============================================================================

		mov		dx,INTP_STR				;print welcome string
		call	PRINT_STR

START:

		call	ILM_INIT				;INITIALIZE
		call	ILM_NLINE				;WRITE CRLF

CO:     call	ILM_GETLINE				;WRITE PROMPT AND GET LINE

		call	ILM_NLINE				;WRITE CRLF

		call	ILM_TSTL                ;TEST FOR LINE NUMBER

		cmp		al,00h					;compare with 0
		jl		CO						;if less we have an error
		je		XEC						;if equals execute directly

		call	ILM_INSERT        		;INSERT IT (MAY BE DELETE)

		jmp     CO

XEC:    call	ILM_XINIT             	;INITIALIZE

; S14:    TST     S15,'LIST'    		;LIST COMMAND
;         DONE
;         LST
;         NXT
		
S14:    
		mov		dx,LIST_STR
		call	ILM_TST
		xor		dx,dx
		mov		dl,al
		call	PRINT_NUMBER
		
		jmp		CO

S17:    call	ILM_ERR	          		;SYNTAX ERROR

END:	cli                             ;disable interrupts
        hlt                             ;halt system



;==============================================================================
; Vars section
;==============================================================================
INTP_STR 		db "TINY BASIC 8086",00h	;welcome string
NOT_IMPLEMENTED	db "Not mplemented",00h		;REMOVE ON RELEASE

LBUF 			times COLS db 00h			;the reading buffer

PGM				times 256 * COLS db 00h		;the PGM area (256 lines * 80 byte)
PGP				dw	0000h					;PGP (line pointer)
CURSOR			db	00h						;line cursor

LIST_STR		db "LIST",00h				;list of language keywords
RUN_STR			db "RUN",00h
CLEAR_STR		db "CLEAR",00h

SYNTAX_ERROR	db "Syntax error",00h		;list of available errors			
LINE_ERROR		db "Invalid line number",00h


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