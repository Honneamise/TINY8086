incbin  "BUILD\BOOT.BIN"
incbin  "BUILD\ILM.BIN"

TIMES 1474560-($-$$) DB 0x00		    ;fill the remaing space with 0 up to
										;the size of a 1.44 floppy

										;NOTE : a 1.44 floppy disk is usually 
										; 80 cylinders
										; 2 sides 
										; 18 sectors per track
										;(a single sector is usually 512 bytes)