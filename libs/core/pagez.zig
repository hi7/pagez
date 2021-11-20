const std = @import("std");
const testing = std.testing;
const fs = std.fs;
const File = fs.File;
const print = std.debug.print;

var arena: std.heap.ArenaAllocator = undefined;
var allocator: *std.mem.Allocator = undefined;
var fb0: File = undefined;
var mouse0: File = undefined;
pub var bitmap: []u8 = undefined;
pub var display_size: Size = undefined;

pub const Point = struct {
    x: i16, y: i16
};
pub const Position = struct {
    x: u16, y: u16
};
pub const Size = struct {
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

///`pub fn init() !void` call once before other functions.
pub fn init() !void {
    fb0 = try fs.openFileAbsolute("/dev/fb0", .{ .write = true });
    // user needs to be in group input: $ sudo adduser username input
    mouse0 = try fs.openFileAbsolute("/dev/input/mouse0", .{ .read = true });
    display_size = try resolution();
    arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    allocator = &arena.allocator;
    const mem_size: u32 = @as(u32, display_size.x) * @as(u32, display_size.y) * @as(u32, 4);
    bitmap = try allocator.alloc(u8, mem_size);
}
///`pub fn exit() void` call after using *readMouse()*.
pub fn exit() void {
    fb0.close();
    mouse0.close();
    allocator.free(bitmap);
    arena.deinit();
}

test "files exists" {
    try fs.accessAbsolute("/sys/class/graphics/fb0/virtual_Size", .{ .read = true });
    try fs.accessAbsolute("/dev/fb0", .{ .write = true });
    try fs.accessAbsolute("/dev/input/mouse0", .{ .read = true });
}

pub fn resolution() !Size {
    var virtual_Size = try fs.openFileAbsolute("/sys/class/graphics/fb0/virtual_Size", .{ .read = true });
    defer virtual_Size.close();

    var buf: [15]u8 = undefined;
    var bytes_read = try virtual_Size.readAll(&buf);
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
    return Size{ .x = width, .y = height };
}

pub fn flush() fs.File.PWriteError!void {
    try fb0.seekTo(0);
    _ = try fb0.write(bitmap);
}

pub fn clear() void {
    for (bitmap) |_, index| {
        bitmap[index] = 0;
    }
}

///`pub fn readMouse() !Mouse` blocking call to read position offset and mouse button status.
pub fn readMouse() !Mouse {
    var buf: [3]u8 = undefined;
    // Following call is blocking!!!
    var bytes_read = try mouse0.readAll(&buf);
    return Mouse {
        .dx = if (buf[1] >= 0x80) @intCast(i8, ~(buf[1] -% 1))*-1 else @intCast(i8, buf[1]),
        .dy = if (buf[2] >= 0x80) @intCast(i8, ~(buf[2] -% 1))*-1 else @intCast(i8, buf[2]),
        .lmb = (buf[0] & 0x01) == 0x01,
        .rmb = (buf[0] & 0x02) == 0x02,
    };
}

test "read mouse" {
    print("please press left move button.\n", .{});
    try init();
    const m = try readMouse();
    try testing.expect(m.dx == 0);
    try testing.expect(m.dy == 0);
    try testing.expect(m.lmb == true);
    try testing.expect(m.rmb == false);
    exit();
}
