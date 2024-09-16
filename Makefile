# SPDX-License-Identifier: MIT

all:
	riscv64-linux-gnu-as payload.S -o payload.elf	
	riscv64-linux-gnu-objcopy -O binary -j .text payload.elf payload.bin
	riscv64-linux-gnu-as payload_workaround.S -o payload_workaround.elf	
	riscv64-linux-gnu-objcopy -O binary -j .text payload_workaround.elf payload_workaround.bin

clean:
	rm -f *.elf *.bin

check:
	qemu-system-riscv64 -M virt -accel kvm -nographic -kernel payload.bin

check_workaround:
	qemu-system-riscv64 -M virt -accel kvm -nographic -kernel payload_workaround.bin
