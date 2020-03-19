QEMU=qemu-system-i386
QEMU_ARGS=-L . -m 32 -rtc base=localtime -vga std -drive file=haribote.img,index=0,if=floppy,format=raw

default:
	make -r img

ipl10.bin: ipl10.nas
	nasm ipl10.nas -o ipl10.bin -l ipl10.lst

asmhead.bin: asmhead.nas
	nasm asmhead.nas -o asmhead.bin -l asmhead.lst

haribote.sys: asmhead.bin
	cat asmhead.bin > haribote.sys

haribote.img: ipl10.bin haribote.sys
	mformat -f 1440 -C -B ipl10.bin -i haribote.img ::
	mcopy -i haribote.img haribote.sys ::

.PHONY: img
img:
	make -r haribote.img

.PHONY: run
run:
	make -r img
	$(QEMU) $(QEMU_ARGS)

.PHONY: clean
clean:
	rm ipl10.bin ipl10.lst asmhead.bin asmhead.lst haribote.sys haribote.img
