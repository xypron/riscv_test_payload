/* SPDX-License-Identifier: MIT */
/*
 * Print the load address, hart ID, and device-tree address
 * to the console and power off.
 */

	.text

	auipc t0, 0		# Load the programm counter into t0
	mv s0, a0		# Save hart ID
	mv s1, a1		# Save device-tree address

	li a7, 0x4442434E	# DBCN
	li a6, 0		# Console write string
	li a2, 0		# High address bytes
	jal a1, msg1		# Load message start into a1
	.ascii "\nTest payload\n============\n\nLoad address: 0x"
	.align 1, 0		# Instructions must start on 2-byte boundary
msg1:	auipc a0, 0		# Load message end into a0
	sub a0, a0, a1		# Calculate message length
	ecall			# SBI conserves all registers but a0, a1

	jal ra, print_num

	jal a1, msg2		# Load message start into a1
	.ascii "\nBoot hart:    0x"
	.align 1, 0		# Instructions must start on 2-byte boundary
msg2:	auipc a0, 0		# Load message end into a0
	sub a0, a0, a1		# Calculate message length
	ecall			# SBI conserves all registers but a0, a1

	mv t0, s0
	jal ra, print_num

	jal a1, msg3		# Load message start into a1
	.ascii "\nDevice-tree:  0x"
	.align 1, 0		# Instructions must start on 2-byte boundary
msg3:	auipc a0, 0		# Load message end into a0
	sub a0, a0, a1		# Calculate message length
	ecall			# SBI conserves all registers but a0, a1

	mv t0, s1
	jal ra, print_num

	jal a1, msg4		# Load message start into a1
	.ascii "\nPowering off\n\n"
	.align 1, 0		# Instructions must start on 2-byte boundary
msg4:	auipc a0, 0		# Load message end into a0
	sub a0, a0, a1		# Calculate message length
	ecall

	li a7, 0x53525354	# SRST
	li a6, 0		# Sytem reset
	li a0, 0		# Shutdown
	li a1, 0		# No reason
	ecall

panic:	j panic			# We should never arrive here

# print_num() - print t0 as hexadecimal number
print_num:
	li a6, 2		# Console write byte
	li t1, 64		# Number of bits
	li t2, 0xA		# Start of non-decimal digits
loop:
	addi t1, t1, -4		# Decrement shift register
	srl a0, t0, t1		# Shift current digit to low bits
	and a0, a0, 0xf		# Mask current digit
	blt a0, t2, low		# < 0xa ?
	addi a0, a0, ('a' - 1) - '9'
low:
	addi a0, a0, '0'	# Convert to ASCII
	ecall
	blt x0, t1, loop	# Any digit left?

	li a6, 0		# Console write string
	ret
