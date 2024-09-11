RISC-V Test Payload
===================

This project supplies a trivial payload that can be used with OpenSBI
running on QEMU.

It prints a message via the debug console extension

::

    Test payload
    ============

    Powering off

and then powers off via the system reset extension.
