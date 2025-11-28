/* SPDX-License-Identifier: MIT */
/*
 * RISC-V Test Payload
 * ===================
 * Print the load address, hart ID, and device-tree address
 * to the console and power off.
 */

#include "lib.h"

/* String messages */
static const char msg_load_addr[] = "\nTest payload\n============\n\nLoad address: 0x";
static const char msg_hart[] = "\nBoot hart:    0x";
static const char msg_dtb[] = "\nDevice-tree:  0x";
static const char msg_poweroff[] = "\nPowering off\n\n";

/**
 * main() - Main entry point from assembly startup
 * @hart_id: Boot hart ID (passed in a0)
 * @dtb: Device tree blob address (passed in a1)
 * @load_addr: Load address (passed in a2)
 */
__attribute__((noreturn)) void main(unsigned long hart_id, unsigned long dtb, unsigned long load_addr)
{

	/* Print header and load address */
	print_str(msg_load_addr);
	print_num(load_addr);

	/* Print boot hart ID */
	print_str(msg_hart);
	print_num(hart_id);

	/* Print device-tree address */
	print_str(msg_dtb);
	print_num(dtb);

	/* Print shutdown message */
	print_str(msg_poweroff);

	/* Power off the system */
	poweroff();
}
