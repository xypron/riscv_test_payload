/* SPDX-License-Identifier: MIT */
/*
 * Assembly startup code for C payload
 */

	.text
	.globl _start

/*
 * Entry point - get PC and jump to C code
 * Input: a0 = hart_id, a1 = dtb
 * Output: a0 = hart_id, a1 = dtb, a2 = load_addr
 */
_start:
	auipc	a2, 0		# Get program counter (load address)
	j	main		# Jump to C main

	.size _start, . - _start
