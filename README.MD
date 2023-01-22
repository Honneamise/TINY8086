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

The code is contains 3 files :

- __boot.asm__ : the boot loader

- __program.asm__ : the interpreter

- __funcs.asm__ : utilities functions

- __system.asm__ : to create a floppy image of the system

## BUILD AND RUN

This repository contains all the tools needed to build and run the system.

- __BUILD.BAT__ will invoke the Nasm assembler to produce in the __BUILD__ folder the following files : _boot.bin_, _program.bin_ and _floppy.img_

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
