const std = @import("std");
const builtin = @import("builtin");
const os = std.os;

const VTIME = 5;
const VMIN = 6;
const VSTART = 8;
const VSTOP = 9;

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var argIter = std.process.argsWithAllocator(allocator) catch unreachable;
    defer argIter.deinit();

    _ = argIter.skip();

    const PORT = argIter.next() orelse "/dev/ttyACM0";

    // giving that file will be only opened, without creation, mode parameter is omited
    const fd = os.open(PORT, os.O.RDONLY, 0) catch unreachable;
    defer os.close(fd);

    // termios structure is used for configuring ports
    var termios = os.tcgetattr(fd) catch unreachable;

    termios.cflag &= ~@as(std.os.linux.tcflag_t, 0o000000010017);
    termios.cflag |= os.linux.B115200;
    termios.cflag |= std.os.linux.CS8;
    termios.ispeed = os.linux.B115200;
    termios.ospeed = os.linux.B115200;
    termios.cc[VMIN] = 1;
    termios.cc[VSTOP] = 0x13; // XOFF
    termios.cc[VSTART] = 0x11; // XON
    termios.cc[VTIME] = 0;

    os.tcsetattr(fd, os.TCSA.NOW, termios) catch unreachable;

    // flush port
    _ = std.os.linux.syscall3(.ioctl, @bitCast(usize, @as(isize, fd)), 0x540B, 2);

    // limit for one line in terminal
    var buf: [256]u8 = undefined;

    while (true) {
        var index = readBytes(fd, &buf);

        std.debug.print("{s}", .{buf[0 .. index + 1]});
        buf = undefined;
    }
}

// read bytes until new line delimiter
fn readBytes(fd: os.fd_t, buf: []u8) usize {
    var index: usize = 0;
    var byte: [1]u8 = undefined;

    while (true) {
        byte = undefined;

        _ = os.read(fd, &byte) catch unreachable;

        buf[index] = byte[0];

        if (byte[0] == '\n') {
            break;
        }

        index += 1;
    }

    return index;
}
