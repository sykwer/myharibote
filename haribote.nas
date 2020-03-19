; Haribote OS

  ORG 0xc200                ; 0x8000(Boot sector top) + 0x4200(Saved file contents' offset)

  ; Address where boot info is saved
  CYLS EQU 0x0ff0
  LEDS EQU 0x0ff1
  VMODE EQU 0x0ff2          ; The number of bit colors
  SCRNX EQU 0x0ff4          ; Resolution X (screen x)
  SCRNY EQU 0x0ff6          ; Resolution Y (screen y)
  VRAM EQU 0x0ff8           ; Start address of graphic buffer

  ; Change display mode
  MOV AH,0x00               ; Change display mode
  MOV AL,0x13               ; VGA graphics 320x200x8 bit color
  INT 0x10                  ; Call video BIOS

  ; Save boot info
  MOV BYTE [VMODE],8
  MOV WORD [SCRNX],320
  MOV WORD [SCRNY],200
  MOV DWORD [VRAM],0x000a0000

  ; Save LED info
  MOV AH,0x02
  INT 0x16                  ; Keyboard BIOS
  MOV [LEDS],AL

fin:
  HLT
  JMP fin
