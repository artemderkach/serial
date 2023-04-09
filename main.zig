const std = @import("std");
const builtin = @import("builtin");
const mem = std.mem;
const os = std.os;

const VTIME = 5;
const VMIN = 6;
const VSTART = 8;
const VSTOP = 9;

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // create slice to relocate argv's into
    var args = allocator.alloc([]const u8, os.argv.len) catch unreachable;
    defer allocator.free(args);
    
    for (args) |_, i| {
        args[i] = mem.sliceTo(os.argv[i], 0);
    }

    const ARG_PORT = args[1];
    const ARG_BAUD = baudMap(std.fmt.parseInt(u32, args[2], 10) catch unreachable);

    const PORT = if (args.len > 1) ARG_PORT else "/dev/ttyACM0";
    const BAUD = if (args.len > 2) ARG_BAUD else os.linux.B115200;

    // giving that file will be only opened, without creation, mode parameter is omited
    const fd = os.open(PORT, os.O.RDONLY, 0) catch unreachable;
    defer os.close(fd);

    // termios structure is used for configuring ports
    var termios = os.tcgetattr(fd) catch unreachable;

    termios.cflag &= ~@as(std.os.linux.tcflag_t, 0o000000010017);
    termios.cflag |= BAUD;
    termios.cflag |= std.os.linux.CS8;
    termios.ispeed = BAUD;
    termios.ospeed = BAUD;
    termios.cc[VMIN] = 0;
    termios.cc[VSTOP] = 0x13; // XOFF
    termios.cc[VSTART] = 0x11; // XON
    termios.cc[VTIME] = 0;

    os.tcsetattr(fd, os.TCSA.NOW, termios) catch unreachable;

    // flush port
    _ = std.os.linux.syscall3(.ioctl, @bitCast(usize, @as(isize, fd)), 0x540B, 2);

    // limit for one line in terminal
    var buf: [256]u8 = undefined;

    // start reading incoming data
    var i: u32 = 30;
    while (i != 0) {
        i -= 1;
        var index = readBytes(fd, &buf);

        std.debug.print("{s}", .{buf[0 .. index + 1]});
        buf = undefined;
    }
}

// read bytes until new line delimiter
// bytes read from file descriptor one by one
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

fn baudMap(baud: u32) u32 {
    return switch (baud) {
        115200 => os.linux.B115200,
        else => os.linux.B115200,
    };
}