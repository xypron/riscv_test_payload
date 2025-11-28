/* SPDX-License-Identifier: MIT */
/*
 * Library functions for RISC-V SBI interaction
 */

#ifndef LIB_H
#define LIB_H

/* Basic type definitions for freestanding environment */
typedef unsigned long size_t;

/**
 * print_str() - Print null-terminated string via OpenSBI
 * @str: Pointer to null-terminated string
 */
void print_str(const char *str);

/**
 * print_num() - Print 64-bit value as hexadecimal
 * @value: Value to print
 */
void print_num(unsigned long value);

/**
 * poweroff() - Power off the system via SBI
 */
__attribute__((noreturn)) void poweroff(void);

#endif /* LIB_H */
