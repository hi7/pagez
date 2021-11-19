const std = @import("std");
const testing = std.testing;
const fs = std.fs;
const File = fs.File;
const Vector = std.meta.Vector;
const print = std.debug.print;

var mouseFile: File = undefined;

pub const Point = struct {
    x: u16, y: u16
};

pub const Mouse = struct {
    dx: i8 = 0,
    dy: i8 = 0,
    lmb: bool = false, // left mouse button
    rmb: bool = false, // right mouse button
};

pub const ParseError = error{
      SeparatorNotFound,
      NoIntegerValue,
};

pub fn resolution() anyerror!Point {
    var res = try fs.openFileAbsolute("/sys/class/graphics/fb0/virtual_size", .{ .read = true });
    defer res.close();

    var buf: [15]u8 = undefined;
    var bytes_read = try res.readAll(&buf);
    // remove line feed at the end
    if (!std.ascii.isDigit(buf[bytes_read])) { bytes_read -= 1; }
    const separator = std.mem.indexOf(u8, buf[0..bytes_read], ",");
    if (separator == null) return ParseError.SeparatorNotFound;
    const width = std.fmt.parseInt(u16, buf[0..separator.?], 10) catch {
        std.debug.print("{s} is no u16 value\n", .{buf[0..separator.?]});
        return ParseError.NoIntegerValue;
    };
    const height = std.fmt.parseInt(u16, buf[(separator.?+1)..bytes_read], 10) catch {
        std.debug.print("{s} is no u16 value\n", .{buf[(separator.?+1)..bytes_read]});
        return ParseError.NoIntegerValue;
    };
    return Point{ .x = width, .y = height };
}

fn calcPos(x: u16, y: u16, res: Point) u32 {
   return (@as(u32, res.x) * @as(u32, y) + @as(u32, x)) *% @as(u32, 4);
}

pub fn pixel(color: Vector(4, u8), x: u16, y: u16, bitmap: []u8, res: Point) void {
    const offset = calcPos(x, y, res);
    bitmap[offset] = color[0];
    bitmap[offset + 1] = color[1];
    bitmap[offset + 2] = color[2];
    bitmap[offset + 3] = color[3];
}

pub fn box(color: Vector(4, u8), pos: Point, size: Point, bitmap: []u8, res: Point) void {
    const offset = calcPos(pos.x, pos.y, res);
    var dx: u16 = 0;
    var dy: u16 = 0;
    while (dy < size.y) : (dy += 1) {
        const yoffset:u32 = dy * res.x * @as(u32, 4);
        while (dx < size.x*4) : (dx += 4) {
            bitmap[offset + yoffset + dx] = color[0];
            bitmap[offset + yoffset + dx + 1] = color[1];
            bitmap[offset + yoffset + dx + 2] = color[2];
            bitmap[offset + yoffset + dx + 3] = color[3];
        }
        dx = 0;
    }
}

pub fn flush(bitmap: []u8, fb: fs.File) fs.File.PWriteError!void {
    try fb.seekTo(0);
    _ = try fb.write(bitmap);
}

pub fn clear(bitmap: []u8) void {
    for (bitmap) |_, index| {
        bitmap[index] = 0;
    }
}

test "files exists" {
    try fs.accessAbsolute("/dev/fb0", .{ .write = true });
    try fs.accessAbsolute("/sys/class/graphics/fb0/virtual_size", .{ .read = true });
}

///`pub fn openMouse() !void` call once before *readMouse()*.
pub fn openMouse() !void {
    // user needs to be in group input:
    // $ sudo adduser username input
    mouseFile = try fs.openFileAbsolute("/dev/input/mouse0", .{ .read = true });
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
