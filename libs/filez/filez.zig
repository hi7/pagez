const std = @import("std");
const testing = std.testing;
const fs = std.fs;
const File = fs.File;
const Vector = std.meta.Vector;
const print = std.debug.print;

var arena: std.heap.ArenaAllocator = undefined;
var allocator: *std.mem.Allocator = undefined;
var fb0: File = undefined;
var mouse0: File = undefined;
var bitmap: []u8 = undefined;
pub var display_size: Point = undefined;

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
    try fs.accessAbsolute("/sys/class/graphics/fb0/virtual_size", .{ .read = true });
    try fs.accessAbsolute("/dev/fb0", .{ .write = true });
    try fs.accessAbsolute("/dev/input/mouse0", .{ .read = true });
}

pub fn resolution() anyerror!Point {
    var virtual_size = try fs.openFileAbsolute("/sys/class/graphics/fb0/virtual_size", .{ .read = true });
    defer virtual_size.close();

    var buf: [15]u8 = undefined;
    var bytes_read = try virtual_size.readAll(&buf);
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

fn calcPos(x: u16, y: u16) u32 {
   return (@as(u32, display_size.x) * @as(u32, y) + @as(u32, x)) *% @as(u32, 4);
}

pub fn pixel(color: Vector(4, u8), x: u16, y: u16) void {
    const offset = calcPos(x, y);
    bitmap[offset] = color[0];
    bitmap[offset + 1] = color[1];
    bitmap[offset + 2] = color[2];
    bitmap[offset + 3] = color[3];
}

pub fn box(color: Vector(4, u8), pos: Point, size: Point) void {
    const offset = calcPos(pos.x, pos.y);
    var dx: u16 = 0;
    var dy: u16 = 0;
    while (dy < display_size.y) : (dy += 1) {
        const yoffset:u32 = dy * size.x * @as(u32, 4);
        while (dx < size.x*4) : (dx += 4) {
            bitmap[offset + yoffset + dx] = color[0];
            bitmap[offset + yoffset + dx + 1] = color[1];
            bitmap[offset + yoffset + dx + 2] = color[2];
            bitmap[offset + yoffset + dx + 3] = color[3];
        }
        dx = 0;
    }
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
    try openMouse();
    const m = try readMouse();
    try testing.expect(m.dx == 0);
    try testing.expect(m.dy == 0);
    try testing.expect(m.lmb == true);
    try testing.expect(m.rmb == false);
    exit();
}
