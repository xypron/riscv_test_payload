# SPDX-License-Identifier: MIT

all:
	riscv64-linux-gnu-as payload.S -march=rv32gc -o payload.elf
	riscv64-linux-gnu-objcopy -O binary -j .text payload.elf payload.bin

clean:
	rm -f payload.elf payload.bin

check:
	qemu-system-riscv32 -M virt -nographic -kernel payload.bin
	qemu-system-riscv64 -M virt -nographic -kernel payload.bin
