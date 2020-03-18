; hello-os

  ORG 0x7c00              ; Boot sector is loaded from this address

; Description for normal AT12 format floppy disk
  JMP SHORT entry
  DB 0x90
  DB "HelloIPL"           ; Boot sector name (must be 8byte)
  DW 512                  ; 1sector size (must be 512)
  DB 1                    ; Cluster size (must be 1sector)
  DW 1                    ; Which sector FAT starts from (normally from first sector)
  DB 2                    ; The number of FATs (must be 2)
  DW 224                  ; Size of root directory area (normaly 224 entries)
  DW 2880                 ; Size of this drive (must be 2880 sectors)
  DB 0xf0                 ; Media type (must be 0xf0)
  DW 9                    ; Length of FAT area (must be 9 sectors)
  DW 18                   ; The number of sectors within one track
  DW 2                    ; The number of heads (must be 2)
  DD 0                    ; Partition is not used (must be 0)
  DD 2880                 ; Size of this drive (written here again)
  DB 0,0,0x29             ; ???
  DD 0xffffffff           ; Volume serial number
  DB "HELLO-OS   "        ; Disk name (must be 11 byte)
  DB "FAT12   "           ; Format name (must be 8 byte)
  TIMES 18 DB 0

; Executed program
entry:
  ; Initialize register
  MOV AX,0
  MOV SS,AX
  MOV SP,0x7c00
  MOV DS,AX

  ; Read disk
  MOV AX,0x0820
  MOV ES,AX               ; Buffer address [ES:BX] (ES * 16 + BX)
  MOV CH,0                ; [Cylinder number] & 0xff
  MOV DH,0                ; Head number
  MOV CL,2                ; [Sector number(bit0-5)] | [Cylinder number & 0x300] >> 2

readloop:
  MOV SI,0                ; Failure counter

retry:
  MOV AH,0x02             ; Read floppy/hard disk in CHS mode (specify BIOS function)
  MOV AL,1                ; The number of sectors to be processed
  MOV BX,0                ; Buffer address [ES:BX] (ES * 16 + BX)
  MOV DL,0x00             ; Drive number (`A` drive)
  INT 0x13                ; Call disk BIOS
  JNC next
  ADD SI,1
  CMP SI,5
  JAE error
  MOV AH,0x00             ; Reset floppy/hard disk
  MOV DL,0x00
  INT 0x13
  JMP retry

next:
  MOV AX,ES
  ADD AX,0x0020           ; 0x0020 = 512 / 16
  MOV ES,AX
  ADD CL,1
  CMP CL,18
  JBE readloop

fin:
  HLT
  JMP fin

error:
  MOV SI,msg

putloop:
  MOV AL,[SI]
  ADD SI,1
  CMP AL,0
  JE fin
  MOV AH,0x0e             ; Display char (specify BIOS function)
  MOV BX,15               ; Color code
  INT 0x10                ; Call video BIOS
  JMP putloop

; Error message
msg:
  DB 0x0a, 0x0a           ; Newline character
  DB "load error"
  DB 0x0a
  DB 0
  TIMES 0x1fe-($-$$) DB 0 ; Fill 0x00 until 0x001fe
  DB 0x55, 0xaa
