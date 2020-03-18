; Haribote OS

  ORG 0xc200                ; 0x8000(Boot sector top) + 0x4200(Saved file contents' offset)

  MOV AH,0x00               ; Change display mode
  MOV AL,0x13               ; VGA graphics 320x200x8 bit color
  INT 0x10

fin:
  HLT
  JMP fin
