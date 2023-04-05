const std = @import("std");
const os = std.os;

const VTIME = 5;
const VMIN = 6;
const VSTART = 8;
const VSTOP = 9;

pub fn main() void {
    // giving that file will be only opened, without creation, mode parameter is omited
    const fd = os.open("/dev/ttyACM0", os.O.RDONLY, 0) catch unreachable;
    defer os.close(fd);

    var termios = os.tcgetattr(fd) catch unreachable;

    termios.cflag &= ~@as(std.os.linux.tcflag_t, 0o000000010017);
    termios.cflag |= os.linux.B115200;
    termios.ispeed = os.linux.B115200;
    termios.ospeed = os.linux.B115200;
    termios.cflag |= std.os.linux.CS8;

    termios.cc[VMIN] = 1;
    termios.cc[VSTOP] = 0x13; // XOFF
    termios.cc[VSTART] = 0x11; // XON
    termios.cc[VTIME] = 0;

    os.tcsetattr(fd, os.TCSA.NOW, termios) catch unreachable;

    _ = std.os.linux.syscall3(.ioctl, @bitCast(usize, @as(isize, fd)), 0x540B, 2);

    var buf: [100]u8 = undefined;
    // const n = try serial.reader().readUntilDelimiterOrEof(&buf, '\n');

    // std.fs

    while (true) {
        var index: usize = 0;
        while (true) {
            var byte: [1]u8 = undefined;
            _ = os.read(fd, &byte) catch unreachable;

            buf[index] = byte[0];

            if (byte[0] == '\n') {
                break;
            }

            index += 1;
        }

        std.debug.print("{s}", .{buf[0 .. index + 1]});
        buf = undefined;
    }
}
