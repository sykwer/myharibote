QEMU=qemu-system-i386
QEMU_ARGS=-L . -m 32 -rtc base=localtime -vga std -drive file=haribote.img,index=0,if=floppy,format=raw

default:
	make -r img

ipl.bin: ipl.nas
	nasm ipl.nas -o ipl.bin -l ipl.lst

haribote.sys: haribote.nas
	nasm haribote.nas -o haribote.sys -l haribote.lst

haribote.img: ipl.bin haribote.sys
	mformat -f 1440 -C -B ipl.bin -i haribote.img ::
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
	rm ipl.bin ipl.lst haribote.sys haribote.lst haribote.img
