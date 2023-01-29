# TINY 8086 (WORK IN PROGRESS)

TINY 8086 is an interpreter written in assembly 8086 for the Tiny Basic language

The goal is to produce a flat binary that can run without the need of a OS on any x86 machine 

## System
The system consists of a program (the interpreter itself) and a boot loader (whose only job is to load the program into memory).

The memory it is structured as :

```
             ________
0000:0000   |BOOT    |  
            |        |--7C00 boot loader start
            |        |
0000:FFFF   |________|

             ________
1000:0000   |STACK   |  
            |        |
            |        |
1000:FFFF   |________|--FFFF stack base

             ________
2000:0000   |PROGRAM |--0000 program start
            |        |
            |        |
2000:FFFF   |________|
```

## SOURCE CODE

- __boot.asm__ : the boot loader

- __program.asm__ : the interpreter

- __funcs.asm__ : utilities functions

- __system.asm__ : to create a floppy image of the system

## BUILD AND RUN

This repository contains all the tools needed to build and run the system.

- __BUILD.BAT__ will invoke the Nasm assembler to produce in the _BUILD_ folder the following files : _boot.bin_, _program.bin_ and _floppy.img_

- __RUN.BAT__ will invoke the Bochs emulator to run the system from _floppy.img_

## FOLDERS
- __SRC__ : source code
- __BUILD__ : output directory
- __DOC__ : Tiny Basic and Assembly 8086 documentation
- __NASM__ : Nasm assembler
- __BOCHS__ : Bochs emulator

## REFERENCES

- TINY BASIC : [http://www.ittybittycomputers.com/IttyBitty/TinyBasic/DDJ1/Design.html](http://www.ittybittycomputers.com/IttyBitty/TinyBasic/DDJ1/Design.html)

- ASM 8086 : [http://vitaly_filatov.tripod.com/ng/asm/](http://vitaly_filatov.tripod.com/ng/asm/)

- NASM : [https://www.nasm.us/](https://www.nasm.us/)

- BOCHS : [https://bochs.sourceforge.io/](https://bochs.sourceforge.io/)

## NOTES

This is a slighlty modified version of the original statements executor :

```
    ;THE IL CONTROL SECTION

    START:  INIT                  ;INITIALIZE
            NLINE                 ;WRITE CRLF
    CO:     GETLINE               ;WRITE PROMPT AND GET LINE
            TSTL    XEC           ;TEST FOR LINE NUMBER
            INSERT                ;INSERT IT (MAY BE DELETE)
            JMP     CO
    XEC:    XINIT                 ;INITIALIZE

    ;STATEMENT EXECUTOR

    STMT:   TST     S1,'LET'      ;IS STATEMENT A LET
            TSTV    S17           ;YES, PLACE VAR ADDRESS ON AESTK
            TST     S17,'='       ;ASSIGNEMENT
            CALL    EXPR          ;PLACE EXPR VALUE ON AESTK
            DONE                  ;REPORT ERROR IF NOT NEXT
            STORE                 ;STORE RESULT
            NXT                   ;AND SEQUENCE TO NEXT
    S1:     TST     S2,'GOTO'     ;GOTO OT GOSUB?
            CALL    EXPR          ;GET LABEL
            DONE                  ;ERROR IF CR NOT NEXT
            XPER                  ;SET UP AND JUMP
    S2:     TST     S3,'GOSUB'    ;ERROR IF NO MATCH
            CALL    EXPR          ;GET DESTINATION
            DONE                  ;ERROR IF CR NOT NEXT
            SAV                   ;SAVE RETURN LINE
            XPER                  ;AND JUMP
    S3:     TST     S8,'PRINT'    ;PRINT
    S4:     TST     S7,'"'        ;TEST FOR QUOTE
            PRS                   ;PRINT STRING
    S5:     TST     S6,','        ;IS THERE MORE?
            SPC                   ;SPACE TO NEXT ZONE
            JMP     S4            ;YES JUMP BACK
    S6:     DONE                  ;ERROR IF CR NOT NEXT
            NLINE
            NXT
    S7:     CALL    EXPR
            PRN                   ;PRINT IT
            JMP     S5            ;IS THERE MORE?
    S8:     TST     S9,'IF'       ;IF STATEMENT
            CALL    EXPR          ;GET EXPRESSION
            CALL    RELOP         ;DETERMINE OPR AND PUT ON STK
            CALL    EXPR          ;GET EXPRESSION
            TST     S17,'THEN'    ;THEN BRANCH
            CMPR                  ;PERFORM COMPARE -- NXT IF FALSE
            JMP     STMT
    S9:     TST     S12,'INPUT'   ;INPUT STATEMENT
    S10:    TSTV    S17           ;GET VAR ADDRESS
            INNUM                 ;MOVE NUMBER FROM TTY TO AESTK
            STORE                 ;STORE IT
            TST     S11,','       ;IS THERE MORE?
            JMP     S10           ;YES
    S11:    DONE                  ;MUST BE CR
            NXT                   ;SEQUENCE TO NEXT
    S12:    TST     S13,'RETURN'  ;RETURN STATEMENT
            DONE                  ;MUST BE CR
            RSTR                  ;RESTORE LINE NUMBER OF CALL
            NXT                   ;SEQUENCE TO NEXT STATEMENT
    S13:    TST     S14,'END'
            DONE
            FIN
    S14:    TST     S15,'LIST'    ;LIST COMMAND
            DONE
            LST
            NXT
    S15:    TST     S16,'RUN'     ;RUN COMMAND
            DONE
            NXT
    S16:    TST     S17,'CLEAR'   ;CLEAR COMMAND
            DONE
            JMP     START

    S17:    ERR                   ;SYNTAX ERROR

    EXPR:   TST     E0,'-'
            CALL    TERM          ;TEST FOR UNARY -.
            NEG                   ;GET VALUE
            JMP     E1            ;NEGATE IT
    E0:     TST     E1A,'+'       ;LOOK FOR MORE
    E1A:    CALL    TERM          ;TEST FOR UNARY +
    E1:     TST     E2,'+'        ;LEADING TERM
            CALL    TERM
            ADD
            JMP     E1
    E2:     TST     E3,'-'        ;ANY MORE?
            CALL    TERM          ;DIFFERENCE TERM
            SUB
            JMP     E1
    E3:T2:  RTN                   ;ANY MORE?
    TERM:   CALL    FACT
    TO:     TST     T1,"*"
            CALL    FACT          ;PRODUCT FACTOR.
            MUL
            JMP     T0
    T1:     TST     T2,'/'
            CALL    FACT          ;QUOTIENT FACTOR.
            DIV
            JMP     T0

    FACT:   TSTV    F0
            IND                   ;YES, GET THE VALUE.
            RTN
    F0:     TSTN    F1            ;NUMBER, GET ITS VALUE.
            RTN
    F1:     TST     F2,'('        ;PARENTHESIZED EXPR.
            CALL    EXPR
            TST     F2,')'
            RTN
    F2:     ERR                   ;ERROR.

    RELOP:  TST     RO,'='
            LIT     0             ;=
            RTN
    R0:     TST     R4,'<'
            TST     R1,'='
            LIT     2             ;<=
            RTN
    R1:     TST     R3,'>'
            LIT     3             ;<>
            RTN
    R3:     LIT     1             ;<
            RTN
    R4:     TST     S17,'>'
            TST     R5,'='
            LIT     5             ;>=
            RTN
    R5:     TST     R6,'<'
            LIT     3
            RTN                   
    R6:     LIT     4
            RTN
```

# TODO
- handle errors :
  - DONE ✅
  - PRS ✅
  - XFER ❌
  - SAV ❌
  - RSTR ❌
  - ERR ✅
  - TSTL ✅
