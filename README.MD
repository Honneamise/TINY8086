# TINY 8086 (WORK IN PROGRESS)

TINY 8086 is an interpreter written in assembly 8086 for the Tiny Basic language

The goal is to produce a flat binary that can run without the need of a OS on any x86 machine 

---
## THE INTERPRETER
---
- The interpreter can execute single instructions or an entire program

- It is possible to store a program of a maximum of 255 lines

- There are available 26 numeric variables identified by the letters A,B,C...Z
---
## BASE COMMANDS 
---
- **LIST** : print on screen the content of the stored program

- **RUN** : execute the program currently stored in memory

- **RESET** : entire reset of the interpreter (memory, variables,etc..)

---
## INSTRUCTIONS
---
**PRINT**

- allow to print on screen : numbers,expressions,variables,strings and their combinations

- to concatenate elements use the "," character

```
PRINT 123 → print: 123
PRINT (4*5)+6 → print:  26
PRINT A → print the numeric value stored in A
PRINT "hello" → print: hello
PRINT "2+3 is :",2+3 → print: 2+3 is 5
```
---
**END**

- Terminate the execution of the current running program

```
10 PRINT "hello" 
20 END						
→ Print : hello and terminate

10 PRINT "line1"
20 END
30 PRINT "line2"		
→ Stampa : line1 and terminate
```
---
**LET** _variable_ **=** _expression_

- Change the content of a variable (A,B,C...Z)
- Variables can store integers numbers between -32767 and +32767
```
LET A = 69 
--> store in A the value 69

LET A = 5*2 
--> store in A the value 10

LET A = A+1 
--> increase the value of A by 1

LET A = B+C 
--> store in A the sum B+C

LET A = (B+C) 
--> store in A the sum B+C
```
---
**INPUT** _variable_

- Read a number from the terminal and store in the designated variable
- Multiple reads are possible using the "," character
```
INPUT A
--> read a number and store it in A

INPUT A,B,C
--> read 3 numbers and store them in A,B,C
```
---
**IF** _condition_ **THEN** _instruction_

- If the condition is true then execute the instruction following THEN
- Logical operators supported : ==,!=,<,>,<=,>=
```
IF 2!=1 THEN PRINT "hello"
--> always print "hello"

IF A<(3*4) THEN PRINT "hello""
--> print "hello" only if the content of the variable A is less than 12
```
---
**GOTO** _expression_

- Continue the execution of the program at the line indicated by the expression
```
GOTO 25
--> continue the execution at line 25

10 PRINT "hello"
20 GOTO 10
30 END
--> print "hello" repeatedly (does not terminate)
```
---
**GOSUB** _expression_ and **RETURN**

- Execute the instructions from the line indicated by the expression up to RETURN
- It resumes the execution of the program at the line following the starting GOSUB
```
10 PRINT "line1"
20 GOSUB 100
30 END
100 PRINT "line2"
110 RETURN
--> print "line1", "line2" and terminate
```
---
**REM**

- It is possible to insert line of comment using the "REM" prefix
```
10 REM Test program
20 PRINT "hello"
30 END
 --> print "hello" and terminate
```
---
## EXAMPLES
---
**Sample code for loops**
```
10 LET A=0
20 IF A>=5 THEN GOTO 60
30 PRINT "hello"
40 LET A=A+1
50 GOTO 20
60 END
--> print "hello" 5 times

10 LET A=0
20 PRINT "hello"
30 LET A=A+1
40 IF A<5 THEN GOTO 20
50 END 
--> print "hello" 5 times
```
---
**Sample calculator program**
```
5 PRINT "CALCULATOR"
10 PRINT "Operation:"
20 PRINT "1 : sum"
30 PRINT "2 : subtraction"
40 PRINT "3 : multiplication"
50 PRINT "4 : division"
60 INPUT A
70 IF A<1 THEN END
80 IF A>4 THEN END
90 PRINT "Insert the first number:"
100 INPUT B
110 PRINT "Insert the second number:"
120 INPUT C
130 PRINT "Result:"
140 IF A==1 THEN PRINT B+C
150 IF A==3 THEN PRINT B-C
160 IF A==4 THEN PRINT B*C
170 IF A==3 THEN PRINT B/C 
180 GOTO 10
```
---
# IMPLEMENTATION DETAILS

## Interpreter

- The system consists of a program (the interpreter itself) and a boot loader (whose only job is to load the program into memory).

- The memory it is structured as :

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
---
## SOURCE CODE

- __BOOT.ASM__ : the boot loader

- __UTILS.ASM__ : utilities functions

- __FLOPPY.ASM__ : to create a floppy image of the system

- __ILM.ASM__ : the interpreter

- __ILM/*.ASM__ : folder containing all the functions required by the interpreter

---
## BUILD AND RUN

This repository contains all the tools needed to build and run the system.

- __BUILD.BAT__ will invoke the Nasm assembler to produce in the _BUILD_ folder the following files : _boot.bin_, _program.bin_ and _floppy.img_

- __RUN.BAT__ will invoke the Bochs emulator to run the system from _floppy.img_

---
## FOLDERS

- __SRC__ : source code
- __BUILD__ : output directory
- __DOC__ : Tiny Basic and Assembly 8086 documentation
- __NASM__ : Nasm assembler
- __BOCHS__ : Bochs emulator

---
## REFERENCES

- TINY BASIC : [http://www.ittybittycomputers.com/IttyBitty/TinyBasic/DDJ1/Design.html](http://www.ittybittycomputers.com/IttyBitty/TinyBasic/DDJ1/Design.html)

- ASM 8086 : [http://vitaly_filatov.tripod.com/ng/asm/](http://vitaly_filatov.tripod.com/ng/asm/)

- NASM : [https://www.nasm.us/](https://www.nasm.us/)

- BOCHS : [https://bochs.sourceforge.io/](https://bochs.sourceforge.io/)

---
## NOTES

- The current keymap is set to US
