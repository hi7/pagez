const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const Vector = std.meta.Vector;
const expect = std.testing.expect;

const Point = struct {
    x: u16, y: u16
};

pub fn main() anyerror!void {
    const res = try resolution();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;
    const size: u32 = @as(u32, res.x) * @as(u32, res.y) * @as(u32, 4);
    var bitmap = try allocator.alloc(u8, size);
    defer allocator.free(bitmap);

    const fb = try fs.openFileAbsolute("/dev/fb0", .{ .write = true });
    defer fb.close();
    try draw(bitmap, res, fb);
}

fn draw(bitmap: []u8, res: Point, fb: fs.File) anyerror!void {
    clear(bitmap);

    const white: Vector(4, u8) = .{ 255, 255, 255, 255 };
    pixel(white, 0, 0, bitmap, res);
    pixel(white, res.x - 1, 0, bitmap, res);
    const blue = [4]u8{ 255, 0, 0, 255 };
    pixel(blue, 1, 1, bitmap, res);
    pixel(blue, res.x - 2, 1, bitmap, res);

    try flush(bitmap, fb);
}

const ParseError = error{
      SeparatorNotFound,
      NoIntegerValue,
};

fn resolution() anyerror!Point {
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

fn pixel(color: Vector(4, u8), x: u16, y: u16, bitmap: []u8, res: Point) void {
    const pos = (res.x * y + x) * 4;
    bitmap[pos] = color[0];
    bitmap[pos + 1] = color[1];
    bitmap[pos + 2] = color[2];
    bitmap[pos + 3] = color[3];
}

fn flush(bitmap: []u8, fb: fs.File) fs.File.PWriteError!void {
    _ = try fb.write(bitmap);
}

fn clear(bitmap: []u8) void {
    for (bitmap) |_, index| {
        bitmap[index] = 0;
    }
}

test "files exists" {
    try fs.accessAbsolute("/dev/fb0", .{ .write = true });
    try fs.accessAbsolute("/sys/class/graphics/fb0/virtual_size", .{ .read = true });
}
