const std = @import("std");
const testing = std.testing;
const fs = std.fs;
const File = fs.File;
const print = std.debug.print;

var mouseFile: File = undefined;

pub const Mouse = struct {
    dx: i8 = 0,
    dy: i8 = 0,
    lmb: bool = false, // left mouse button
    rmb: bool = false, // right mouse button
};

///`pub fn openMouse() !void` call once before *readMouse()*.
pub fn openMouse() !void {
    // user needs to be in group input:
    // $ sudo adduser username input
    mouseFile = try fs.openFileAbsolute("/dev/input/mouse0", .{ .read = true });
}

test "open mouse" {
    try openMouse();
    exit();
}

///`pub fn readMouse() !Mouse` blocking call to read position offset and mouse button status.
pub fn readMouse() !Mouse {
    var buf: [3]u8 = undefined;
    // Following call is blocking!!!
    var bytes_read = try mouseFile.readAll(&buf);
    return Mouse {
        .dx = if (buf[1] >= 0x80) @intCast(i8, ~(buf[1] -% 1))*-1 else @intCast(i8, buf[1]),
        .dy = if (buf[2] >= 0x80) @intCast(i8, ~(buf[2] -% 1))*-1 else @intCast(i8, buf[2]),
        .lmb = (buf[0] & 0x01) == 0x01,
        .rmb = (buf[0] & 0x02) == 0x02,
    };
}

test "read mouse" {
    print("please press left move button.\n", .{});
    try openMouse();
    const m = try readMouse();
    try testing.expect(m.dx == 0);
    try testing.expect(m.dy == 0);
    try testing.expect(m.lmb == true);
    try testing.expect(m.rmb == false);
    exit();
}

///`pub fn exit() void` call after using *readMouse()*.
pub fn exit() void {
    mouseFile.close();
}
