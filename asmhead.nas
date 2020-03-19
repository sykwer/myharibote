; Haribote OS

  ORG 0xc200                ; 0x8000(Boot sector top) + 0x4200(Saved file contents' offset)

  BOTPAK EQU 0x00280000     ; Address where bootpack is loaded
  DSKCAC EQU 0x00100000     ; Address where disk cache is saved
  DSKCAC0 EQU 0x00008000    ; Address where disk cache is saved in real mode

  ; Address where boot info is saved
  CYLS EQU 0x0ff0
  LEDS EQU 0x0ff1
  VMODE EQU 0x0ff2          ; The number of bit colors
  SCRNX EQU 0x0ff4          ; Resolution X
  SCRNY EQU 0x0ff6          ; Resolution Y
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

  ; TODO: Add explanation
  MOV AL,0xff
  OUT 0x21,AL
  NOP                       ; Successive OUT instruction fails on some machines
  OUT 0xa1,AL

  CLI                       ; Forbit interruption in CPU level

  ; Configure A20GATE so that CPU can access memory in more than 1MB
  CALL waitkbdout
  MOV AL,0xd1
  OUT 0x64,AL
  CALL waitkbdout
  MOV AL,0xdf               ; Enable A20
  OUT 0x60,AL
  CALL waitkbdout

  ; Protect mode
  LGDT [GDTR0]              ; Configure temporary GDT
  MOV EAX,CR0
  MOV EAX,0x7fffffff        ; Set bit31 0 to forbit paging
  OR EAX,0x00000001         ; Set bit0 1 to become protect mode
  MOV CR0,EAX
  JMP pipelineflush

pipelineflush:
  MOV AX,1*8                ; Readable/Writable segment 32bit
  MOV DS,AX
  MOV ES,AX
  MOV FS,AX
  MOV GS,AX
  MOV SS,AX

  ; Transfer bootpack
  MOV ESI,bootpack
  MOV EDI,BOTPAK
  MOV ECX,512*1024/4        ; Transfer 4 bytes in one MOV instruction
  CALL memcpy

  ; Transfor disk data
  MOV ESI,0x7c00
  MOV EDI,DSKCAC
  MOV ECX,512/4
  CALL memcpy

  MOV ESI,DSKCAC0+512
  MOV EDI,DSKCAC+512
  MOV ECX,0
  MOV CL,BYTE [CYLS]
  IMUL ECX,512*18*2/4
  SUB ECX,512/4
  CALL memcpy

  ; Launch bootpack
  MOV EBX,BOTPAK
  MOV ECX,[EBX+16]
  ADD ECX,3
  SHR ECX,2
  JZ skip                   ; There is nothing to transfer
  MOV ESI,[EBX+20]
  ADD ESI,EBX
  MOV EDI,[EBX+12]
  CALL memcpy

skip:
  MOV ESP,[EBX+12]          ; Stack initial value
  JMP DWORD 2*8:0x0000001b

waitkbdout:
  IN AL,0x64
  AND AL,0x02
  JNZ waitkbdout
  RET

memcpy:
  MOV EAX,[ESI]
  ADD ESI,4
  MOV [EDI],EAX
  ADD EDI,4
  SUB ECX,1
  JNZ memcpy
  RET

  ALIGNB 16, DB 0

GDT0:
  TIMES 8 DB 0
  DW 0xffff,0x0000,0x9200,0x00cf  ; Readable/Writable segment 32bit
  DW 0xffff,0x0000,0x9a28,0x0047  ; Executable 32bit (for bootpack)
  DW 0

GDTR0:
  DW 8*3-1
  DD GDT0

  ALIGNB 16, DB 0

bootpack:
