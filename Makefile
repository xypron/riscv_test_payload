# SPDX-License-Identifier: MIT

all:
	riscv64-linux-gnu-as payload.S -march=rv64gc -o payload.o
	riscv64-linux-gnu-ld -T payload.lds -o payload.elf payload.o
	riscv64-linux-gnu-objcopy -O binary payload.elf payload.bin

clean:
	rm -f payload.o payload.elf payload.bin

check:
	qemu-system-riscv64 -M virt -nographic -kernel payload.bin
