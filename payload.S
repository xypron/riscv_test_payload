/* SPDX-License-Identifier: MIT */
/*
 * RISC-V Test Payload
 * ===================
 *
 * Print the load address, hart ID, and device-tree address
 * to the console and power off.
 */

	.text
	.globl _start

/*
 * Entry point - save boot parameters
 */
_start:
	auipc	t0, 0			# Load the program counter into t0
	mv	s0, a0			# Save hart ID (a0)
	mv	s1, a1			# Save device-tree address (a1)

/*
 * Print header and load address
 */
	la	a0, msg_load_addr	# Load message address
	jal	ra, print_str		# Print the message

	mv	a0, t0			# Move load address to a0 for printing
	jal	ra, print_num		# Print the load address in hex

/*
 * Print boot hart ID
 */
	la	a0, msg_hart		# Load message address
	jal	ra, print_str		# Print the message

	mv	a0, s0			# Move saved hart ID to a0 for printing
	jal	ra, print_num		# Print the hart ID in hex

/*
 * Print device-tree address
 */
	la	a0, msg_dtb		# Load message address
	jal	ra, print_str		# Print the message

	mv	a0, s1			# Move saved device-tree address to a0 for printing
	jal	ra, print_num		# Print the device-tree address in hex

/*
 * Print shutdown message
 */
	la	a0, msg_poweroff	# Load message address
	jal	ra, print_str		# Print the message

/*
 * Power off
 */
	li	a7, 0x53525354		# SBI extension: SRST (System Reset)
	li	a6, 0			# Function: system reset
	li	a0, 0			# Reset type: shutdown
	li	a1, 0			# Reset reason: no reason
	ecall				# Perform system shutdown

panic:	j	panic			# Infinite loop (should never reach here)

/*
 * print_str() - Print null-terminated string via OpenSBI
 *
 * Inputs:
 *   a0 = pointer to null-terminated string
 * Clobbers: a0, a1, a2, a6, a7, t3
 */
print_str:
	mv	t3, a0			# Save string pointer
	li	a1, 0			# Initialize length counter

1:	lbu	a2, (a0)		# Load byte from string
	beqz	a2, 2f			# If null terminator, done counting
	addi	a1, a1, 1		# Increment length
	addi	a0, a0, 1		# Move to next character
	j	1b			# Continue loop

2:	mv	a0, a1	
	mv	a1, t3			# Restore string pointer to a0
	li	a7, 0x4442434E		# SBI extension: DBCN (Debug Console)
	li	a6, 0			# Function: console write string
	li	a2, 0			# High address bytes (upper 32-bit)
	ecall				# SBI call (preserves all registers except a0, a1)
	ret				# Return to caller

/*
 * print_num() - Print 64-bit value in a0 as hexadecimal
 *
 * Inputs:
 *   a0 = value to print
 * Clobbers: a0, a6, a7, t1, t2, t3
 */
print_num:
	mv	t3, a0			# Move value to t0 for processing
	li	a7, 0x4442434E		# SBI extension: DBCN (Debug Console)
	li	t1, 64			# Number of bits in register
	li	t2, 0xA			# Threshold for hex digits (a-f vs 0-9)

loop:
	addi	t1, t1, -4		# Shift by 4 bits less (next hex digit)
	srl	a0, t3, t1		# Shift current digit to low 4 bits
	and	a0, a0, 0xf		# Mask to get only current hex digit
	blt	a0, t2, low		# Branch if digit is 0-9
	addi	a0, a0, ('a' - 1) - '9'	# Adjust for hex letters (a-f)
low:
	addi	a0, a0, '0'		# Convert to ASCII character
	li	a7, 0x4442434E		# SBI extension: DBCN (Debug Console)
	li	a6, 2			# Function: console write byte
	ecall				# Print the character
	blt	x0, t1, loop		# Continue if more digits remain
	ret				# Return to caller

/*
 * String data section
 */
	.section .rodata

msg_load_addr:	.asciz "\nTest payload\n============\n\nLoad address: 0x"
msg_hart:	.asciz "\nBoot hart:    0x"
msg_dtb:	.asciz "\nDevice-tree:  0x"
msg_poweroff:	.asciz "\nPowering off\n\n"
