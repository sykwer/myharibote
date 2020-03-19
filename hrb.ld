/* https://vanya.jp.net/os/haribote.html#hrb */

OUTPUT_FORMAT("binary");

SECTIONS
{
  .head 0x0 : {
    LONG(64 * 1024)        /*  0: Size of stack + data + heap (multiple of 4KB)*/
    LONG(0x69726148)       /*  4: Signature "Hari" */
    LONG(0)                /*  8: Size of mmarea (multiple of 4KB) */
    LONG(0x310000)         /* 12: Stack initial value & .data transfer destination */
    LONG(SIZEOF(.data))    /* 16: .data size */
    LONG(LOADADDR(.data))  /* 20: Address where file for .data initial value array is placed */
    LONG(0xE9000000)       /* 24: */
    LONG(HariMain - 0x20)  /* 28: Entry address */
    LONG(0)                /* 32: Start address of heap */
  }

  .text : {
    *(.text)
  }

  .data 0x310000 : AT ( ADDR(.text) + SIZEOF(.text) ) {
    *(.data)
    *(.rodata*)
    *(.bss)
  }

  /DISCARD/ : {
    *(.eh_frame)
  }
}
