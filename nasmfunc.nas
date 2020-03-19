; nasmfunc

; Generate machine lang for 32 bit mode
[BITS 32]

; Info for object file
  GLOBAL io_hlt

; Main part for function
[SECTION .text]
io_hlt:
  HLT
  RET
