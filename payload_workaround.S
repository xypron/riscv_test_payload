/* SPDX-License-Identifier: MIT */
/*
 * Write a message to the debug console and power off.
 */

	.text

	# The FS bits should be set in QEMU/KVM.
	li a1, 0x00006000 # FS subfield mask
	csrr a0, 0x100    # Read CSR sstatus
	or a0, a0, a1     # Set FS bits
	csrw 0x100, a0    # Write CSR sstatus

	li a7, 0x4442434E # DBCN
	li a6, 0	  # Console Write
	li a2, 0	  # High address bytes
	jal a1, msgend	  # Load message start into a1
	.ascii "\nTest payload\n============\n\nfcvt.d.w fa5,a5\n"
	.align 1, 0	  # Instructions must start on 2-byte boundary
msgend: auipc a0, 0	  # Load message end into a0
	sub a0, a0, a1    # Calculate message length
	ecall

	fcvt.d.w fa5,a5

	li a7, 0x4442434E # DBCN
	li a6, 0	  # Console Write
	li a2, 0	  # High address bytes
	jal a1, msgen2	  # Load message start into a1
	.ascii "Powering off\n\n"
	.align 1, 0	  # Instructions must start on 2-byte boundary
msgen2: auipc a0, 0	  # Load message end into a0
	sub a0, a0, a1    # Calculate message length
	ecall
	li a7, 0x53525354 # SRST
	li a6, 0	  # Sytem reset
	li a0, 0	  # Shutdown
	li a1, 0	  # No reason
	ecall

loop:   j loop		  # We should not arrive here
