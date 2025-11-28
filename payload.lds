/* SPDX-License-Identifier: MIT */
/*
 * Linker script for RISC-V test payload
 */

OUTPUT_ARCH(riscv)
ENTRY(_start)

SECTIONS
{
	. = 0x82000000;

	.text : {
		start.o(.text)
		*(.text)
		*(.text.*)
	}

	.rodata : {
		*(.rodata)
		*(.rodata.*)
	}

	.data : {
		*(.data)
		*(.data.*)
	}

	.bss : {
		*(.bss)
		*(.bss.*)
		*(COMMON)
	}
}
