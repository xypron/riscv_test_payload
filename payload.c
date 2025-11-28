/* SPDX-License-Identifier: MIT */
/*
 * RISC-V Test Payload
 * ===================
 * Print the load address, hart ID, and device-tree address
 * to the console and power off.
 */

/* Basic type definitions for freestanding environment */
typedef unsigned long size_t;
typedef unsigned long uint64_t;

/* SBI extension IDs */
#define SBI_EXT_DBCN		0x4442434E
#define SBI_EXT_SRST		0x53525354

/* SBI function IDs */
#define SBI_DBCN_WRITE_STRING	0
#define SBI_DBCN_WRITE_BYTE	2
#define SBI_SRST_SYSTEM_RESET	0

/* SBI reset types */
#define SBI_SRST_SHUTDOWN	0
#define SBI_SRST_RESET_REASON_NONE	0

/* String messages */
static const char msg_load_addr[] = "\nTest payload\n============\n\nLoad address: 0x";
static const char msg_hart[] = "\nBoot hart:    0x";
static const char msg_dtb[] = "\nDevice-tree:  0x";
static const char msg_poweroff[] = "\nPowering off\n\n";

/**
 * sbi_call() - Make an SBI call
 * @ext: SBI extension ID
 * @fid: SBI function ID
 * @arg0-arg4: Arguments for the SBI call
 *
 * Return: SBI error code in a0
 */
static inline long sbi_call(unsigned long ext, unsigned long fid,
			    unsigned long arg0, unsigned long arg1,
			    unsigned long arg2, unsigned long arg3,
			    unsigned long arg4)
{
	register unsigned long a0 asm("a0") = arg0;
	register unsigned long a1 asm("a1") = arg1;
	register unsigned long a2 asm("a2") = arg2;
	register unsigned long a3 asm("a3") = arg3;
	register unsigned long a4 asm("a4") = arg4;
	register unsigned long a6 asm("a6") = fid;
	register unsigned long a7 asm("a7") = ext;

	asm volatile("ecall"
		     : "+r"(a0), "+r"(a1)
		     : "r"(a2), "r"(a3), "r"(a4), "r"(a6), "r"(a7)
		     : "memory");
	return a0;
}

/**
 * print_str() - Print null-terminated string via OpenSBI
 * @str: Pointer to null-terminated string
 */
void print_str(const char *str)
{
	size_t len = 0;
	const char *p = str;

	/* Calculate string length */
	while (*p++)
		len++;

	/* SBI call to write string */
	sbi_call(SBI_EXT_DBCN, SBI_DBCN_WRITE_STRING,
		 len, (unsigned long)str, 0, 0, 0);
}

/**
 * print_num() - Print 64-bit value as hexadecimal
 * @value: Value to print
 */
void print_num(unsigned long value)
{
	int shift;

	/* Print each hex digit (16 digits for 64-bit value) */
	for (shift = 60; shift >= 0; shift -= 4) {
		unsigned char digit = (value >> shift) & 0xf;
		char ch;

		if (digit < 10)
			ch = '0' + digit;
		else
			ch = 'a' + (digit - 10);

		/* SBI call to write byte */
		sbi_call(SBI_EXT_DBCN, SBI_DBCN_WRITE_BYTE,
			 ch, 0, 0, 0, 0);
	}
}

/**
 * poweroff() - Power off the system via SBI
 */
__attribute__((noreturn)) void poweroff(void)
{
	/* Power off */
	sbi_call(SBI_EXT_SRST, SBI_SRST_SYSTEM_RESET,
		 SBI_SRST_SHUTDOWN, SBI_SRST_RESET_REASON_NONE,
		 0, 0, 0);

	/* Should never reach here */
	while (1)
		;
}

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
