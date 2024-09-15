# SPDX-License-Identifier: MIT

all:
	riscv64-linux-gnu-as payload.S -o payload.elf	
	riscv64-linux-gnu-objcopy -O binary -j .text payload.elf payload.bin

clean:
	rm -f payload.elf payload.bin

check:
	qemu-system-riscv64 -M virt -accel kvm -nographic -kernel payload.bin
