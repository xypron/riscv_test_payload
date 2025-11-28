# SPDX-License-Identifier: MIT

CROSS_COMPILE = riscv64-linux-gnu-
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy

CFLAGS_64 = -march=rv64gc -mabi=lp64d -ffreestanding -nostdlib -Og -Wall -Werror -g
CFLAGS_32 = -march=rv32gc -mabi=ilp32d -ffreestanding -nostdlib -Og -Wall -Werror -g
ASFLAGS = -g
LDFLAGS = -Map

all: payload.bin payload-c.bin payload32.bin payload32-c.bin

# 64-bit targets
payload.o: payload.S
	$(AS) -march=rv64gc $(ASFLAGS) -o payload.o payload.S

payload.bin: payload.o
	$(LD) -T payload-asm.lds $(LDFLAGS)=payload.map -o payload.elf payload.o
	$(OBJCOPY) -O binary payload.elf payload.bin

start.o: start.S
	$(AS) -march=rv64gc $(ASFLAGS) -o start.o start.S

payload-c.o: payload.c
	$(CC) $(CFLAGS_64) -c -o payload-c.o payload.c

payload-c.bin: start.o payload-c.o
	$(LD) -T payload.lds $(LDFLAGS)=payload-c.map -o payload-c.elf start.o payload-c.o
	$(OBJCOPY) -O binary payload-c.elf payload-c.bin

# 32-bit targets
payload32.o: payload.S
	$(AS) -march=rv32gc $(ASFLAGS) -o payload32.o payload.S

payload32.bin: payload32.o
	$(LD) -m elf32lriscv -T payload-asm.lds $(LDFLAGS)=payload32.map -o payload32.elf payload32.o
	$(OBJCOPY) -O binary payload32.elf payload32.bin

start32.o: start.S
	$(AS) -march=rv32gc $(ASFLAGS) -o start32.o start.S

payload32-c.o: payload.c
	$(CC) $(CFLAGS_32) -c -o payload32-c.o payload.c

payload32-c.bin: start32.o payload32-c.o
	$(LD) -m elf32lriscv -T payload.lds $(LDFLAGS)=payload32-c.map -o payload32-c.elf start32.o payload32-c.o
	$(OBJCOPY) -O binary payload32-c.elf payload32-c.bin

clean:
	rm -f payload.o payload.elf payload.bin payload.map
	rm -f start.o payload-c.o payload-c.elf payload-c.bin payload-c.map
	rm -f payload32.o payload32.elf payload32.bin payload32.map
	rm -f start32.o payload32-c.o payload32-c.elf payload32-c.bin payload32-c.map

check: check-asm-64 check-c-64 check-asm-32 check-c-32

check-asm-64:
	@echo "Testing 64-bit assembly version..."
	qemu-system-riscv64 -M virt -nographic -kernel payload.bin

check-c-64:
	@echo "Testing 64-bit C version..."
	qemu-system-riscv64 -M virt -nographic -kernel payload-c.bin

check-asm-32:
	@echo "Testing 32-bit assembly version..."
	qemu-system-riscv32 -M virt -nographic -kernel payload32.bin

check-c-32:
	@echo "Testing 32-bit C version..."
	qemu-system-riscv32 -M virt -nographic -kernel payload32-c.bin
