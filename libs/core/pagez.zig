const std = @import("std");
const testing = std.testing;
const fs = std.fs;
const File = fs.File;
const expect = std.testing.expect;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

var arena: std.heap.ArenaAllocator = undefined;
var allocator: *std.mem.Allocator = undefined;
var fb0: File = undefined;
var mouse0: File = undefined;
pub var bitmap: []u8 = undefined;
pub var display_size: Size = undefined;
pub var bits_per_pixel: u8 = undefined;

pub const Point = struct { x: i16, y: i16 };
pub const Position = struct { x: u16, y: u16 };
pub const Size = struct { x: u16, y: u16 };

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
    bits_per_pixel = try bitsPerPixel();
    display_size = try resolution();
    arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    allocator = &arena.allocator;
    const mem_size: u32 = @as(u32, display_size.x) * @as(u32, display_size.y) * @as(u32, 4);
    bitmap = try allocator.alloc(u8, mem_size);
}
///`pub fn exit() void` call after using other functions.
pub fn exit() void {
    fb0.close();
    mouse0.close();
    allocator.free(bitmap);
    arena.deinit();
}

test "files exists" {
    try fs.accessAbsolute("/sys/class/graphics/fb0/virtual_size", .{ .read = true });
    try fs.accessAbsolute("/dev/fb0", .{ .write = true });
    try fs.accessAbsolute("/dev/input/mouse0", .{ .read = true });
}

pub fn bitsPerPixel() !u8 {
    var buf: [4]u8 = undefined;
    var size = try readNumber("/sys/class/graphics/fb0/bits_per_pixel", &buf);
    const bits_perPixel = std.fmt.parseInt(u8, buf[0..size], 10) catch {
        std.debug.print("bits_per_pixel: {s} is no u8 value\n", .{buf[0..size]});
        return ParseError.NoIntegerValue;
    };
    std.debug.print("bitsPerPixel[0..{d}] {s} => {d}\n", .{ size, buf[0..size], bits_per_pixel });
    return bits_per_pixel;
}

pub fn resolution() !Size {
    var buf: [15]u8 = undefined;
    var size = try readNumber("/sys/class/graphics/fb0/virtual_size", &buf);
    const separator = std.mem.indexOf(u8, buf[0..size], ",");
    if (separator == null) return ParseError.SeparatorNotFound;
    const width = std.fmt.parseInt(u16, buf[0..separator.?], 10) catch {
        std.debug.print("width: {s} is no u16 value\n", .{buf[0..separator.?]});
        return ParseError.NoIntegerValue;
    };
    const height = std.fmt.parseInt(u16, buf[(separator.? + 1)..size], 10) catch {
        std.debug.print("height: {s} is no u16 value\n", .{buf[(separator.? + 1)..size]});
        return ParseError.NoIntegerValue;
    };
    return Size{ .x = width, .y = height };
}

pub fn readNumber(path: []const u8, buffer: []u8) !usize {
    var file = try fs.openFileAbsolute(path, .{ .read = true });
    defer file.close();

    var bytes_read = try file.readAll(buffer);
    // remove line feed at the end
    if (!std.ascii.isDigit(buffer[bytes_read])) {
        bytes_read -= 1;
    }
    return bytes_read;
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
    var bytes_read = try mouse0.readAll(&buf);
    return Mouse{
        .dx = if (buf[1] >= 0x80) @intCast(i8, ~(buf[1] -% 1)) * -1 else @intCast(i8, buf[1]),
        .dy = if (buf[2] >= 0x80) @intCast(i8, ~(buf[2] -% 1)) * -1 else @intCast(i8, buf[2]),
        .lmb = (buf[0] & 0x01) == 0x01,
        .rmb = (buf[0] & 0x02) == 0x02,
    };
}
