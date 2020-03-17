QEMU=qemu-system-i386
QEMU_ARGS=-L . -m 32 -rtc base=localtime -vga std -drive file=helloos.img,index=0,if=floppy,format=raw

ipl.bin: ipl.nas
	nasm ipl.nas -o ipl.bin -l ipl.lst

helloos.img: ipl.bin
	mformat -f 1440 -C -B ipl.bin -i helloos.img ::

img:
	make -r helloos.img

run :
	make img
	$(QEMU) $(QEMU_ARGS)
