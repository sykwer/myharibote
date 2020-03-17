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
  MOV AX,0                ; Initialize register
  MOV SS,AX
  MOV SP,0x7c00
  MOV ES,AX

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
fin:
  HLT
  JMP fin

; Message data
msg:
  DB 0x0a, 0x0a           ; Newline character
  DB "hello, sykwer"
  DB 0x0a
  DB 0
  TIMES 0x1fe-($-$$) DB 0 ; Fill 0x00 until 0x001fe
  DB 0x55, 0xaa

; Description written in other than boot sector
  DB 0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
  TIMES 4600 DB 0
  DB 0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
  TIMES 1469432 DB 0
