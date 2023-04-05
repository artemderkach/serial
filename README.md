# SERIAL

## Purpose
Need a small program to read serial data from microcontroller via USB. Usually i was using `screen` cli.

## Learned During Implementation
1. to acquire data form USB serial port, syscalls is used. one for opening file descriptor, one for acquiring termios, one for configuring port and one for each character received.
2. termios is a structure that configures port. probably stands for terminal OS.
3. comptime functions/structures can be used as interface in zig
4. zig is good for cross-compiling due to possibility of determining OS during comptime.
5. `[100]u8` is array/slice, `[]u8` is pointer to array/slice.