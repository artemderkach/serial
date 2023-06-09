# SERIAL

## Purpose
Need a small program to read serial data from microcontroller via USB. Usually i was using `screen` cli.

## Learned During Implementation
1. to acquire data form USB serial port, syscalls is used. one for opening file descriptor, one for acquiring termios, one for configuring port and one for each character received.
2. termios is a structure that configures port. probably stands for terminal OS.
3. comptime functions/structures can be used as interface in zig
4. zig is good for cross-compiling due to possibility of determining OS during comptime.
5. `[100]u8` is array/slice, `[]u8` is pointer to array/slice.
6. speed for port transferring in zig can not be chosen as cross-platform, only as `os.linux.B115200`
7. `os.open` requires 3 arguments, in case file is only opened without creating one, 3-rd argument `mode` is not required (set to 0)
8. for some reason `{}` need to be added at the end of `std.heap.GeneralPurposeAllocator(.{}){}` statement
9. cli parameters can be transformed to slice of strings
10. `switch` cannot be used with strings

## Links
- Serial Programming HOWTO  
https://tldp.org/HOWTO/Serial-Programming-HOWTO/x115.html
- termios man page  
https://man7.org/linux/man-pages/man3/termios.3.html
- termios structure  
https://www.mkssoftware.com/docs/man5/struct_termios.5.asp
- Linux Serial Ports Using C/C++  
https://blog.mbedded.ninja/programming/operating-systems/linux/linux-serial-ports-using-c-cpp/
- working zig version for serial communication  
https://github.com/MasterQ32/zig-serial

## Build
`$ zig build-exe main.zig --name serial`

## Possible updates
- handle errors properly
- add tests
- add handler for buffer out of bound