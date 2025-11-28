# SPDX-License-Identifier: MIT

CROSS_COMPILE = riscv64-linux-gnu-
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy

CFLAGS = -march=rv64gc -mabi=lp64d -ffreestanding -nostdlib -O2 -Wall

all: payload.bin payload-c.bin

# Assembly version
payload.bin: payload.o
	$(LD) -T payload.lds -o payload.elf payload.o
	$(OBJCOPY) -O binary payload.elf payload.bin

payload.o: payload.S
	$(AS) -march=rv64gc -o payload.o payload.S

# C version
payload-c.bin: start.o payload-c.o
	$(LD) -T payload.lds -o payload-c.elf start.o payload-c.o
	$(OBJCOPY) -O binary payload-c.elf payload-c.bin

start.o: start.S
	$(AS) -march=rv64gc -o start.o start.S

payload-c.o: payload.c
	$(CC) $(CFLAGS) -c -o payload-c.o payload.c

clean:
	rm -f payload.o payload.elf payload.bin
	rm -f start.o payload-c.o payload-c.elf payload-c.bin

check:
	qemu-system-riscv64 -M virt -nographic -kernel payload.bin

check-c:
	qemu-system-riscv64 -M virt -nographic -kernel payload-c.bin
