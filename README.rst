RISC-V Test Payload
===================

This project supplies a minimal payload that can be used with OpenSBI
running on QEMU. It demonstrates basic SBI (Supervisor Binary Interface)
interaction from both assembly and C code.

Features
--------

The payload prints boot information via the SBI Debug Console extension (DBCN)
and then powers off the system via the SBI System Reset extension (SRST).

Output example::

    Test payload
    ============

    Load address: 0x0000000082000000
    Boot hart:    0x0000000000000000
    Device-tree:  0x0000000087000000
    Powering off

Available Binaries
------------------

The project builds four variants:

- ``payload.bin`` - 64-bit assembly version
- ``payload-c.bin`` - 64-bit C version
- ``payload32.bin`` - 32-bit assembly version
- ``payload32-c.bin`` - 32-bit C version

Building
--------

Requirements:

- RISC-V GNU toolchain (riscv64-linux-gnu-gcc, etc.)
- GNU Make

Build all variants::

    make

Build specific variants::

    make payload.bin        # 64-bit assembly only
    make payload-c.bin      # 64-bit C only
    make payload32.bin      # 32-bit assembly only
    make payload32-c.bin    # 32-bit C only

Clean build artifacts::

    make clean

Testing
-------

Requirements:

- QEMU (qemu-system-riscv32 and qemu-system-riscv64)

Run all tests::

    make check

Run specific tests::

    make check-asm-64    # Test 64-bit assembly version
    make check-c-64      # Test 64-bit C version
    make check-asm-32    # Test 32-bit assembly version
    make check-c-32      # Test 32-bit C version

Project Structure
-----------------

Source Files:

- ``payload.S`` - Assembly implementation
- ``payload.c`` - C main application
- ``lib.c`` / ``lib.h`` - Shared library functions for SBI interaction
- ``start.S`` - Assembly startup code for C version

Build Configuration:

- ``Makefile`` - Build system
- ``payload.lds`` - Linker script for C versions
- ``payload-asm.lds`` - Linker script for assembly-only versions

Debug Support
-------------

All binaries are built with debug symbols (``-g``) and generate map files
showing memory layout and symbol addresses:

- ``payload.map`` / ``payload-c.map`` (64-bit)
- ``payload32.map`` / ``payload32-c.map`` (32-bit)

Compiler flags include ``-Wall -Werror -Og`` for clean builds optimized
for debugging.

License
-------

This project is licensed under the MIT License. See LICENSE.rst for details.
