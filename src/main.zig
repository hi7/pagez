const std = @import("std");
const filez = @import("filez");
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

    try filez.openMouse();
    var m = try filez.readMouse();
    var mp = Point{ .x = res.x / 2, .y = res.y / 2 };
    const c: Vector(4, u8) = .{ 0, 255, 255, 255 };
    box(c, mp,  Point{ .x = 4, .y = 4}, bitmap, res);
    while (!m.lmb) {
        mp.x = @intCast(u16, (@intCast(i16, mp.x) + @intCast(i16, m.dx)));
        mp.y = @intCast(u16, (@intCast(i16, mp.y) + @intCast(i16, m.dy) * -1));
        box(c, mp,  Point{ .x = 8, .y = 8}, bitmap, res);
        try flush(bitmap, fb);
        m = try filez.readMouse();
    }
    filez.exit();
}

fn draw(bitmap: []u8, res: Point, fb: fs.File) anyerror!void {
    clear(bitmap);
    // TODO: use u32 for color
    const white: Vector(4, u8) = .{ 255, 255, 255, 255 };
    box(white, Point{ .x = 0, .y = 0},  Point{ .x = 8, .y = 8}, bitmap, res);
    box(white, Point{ .x = res.x-9, .y = 0},  Point{ .x = 8, .y = 8}, bitmap, res);
    const cyan = [4]u8{ 255, 255, 0, 255 };
    box(cyan, Point{ .x = 8, .y = 5},  Point{ .x = 3, .y = 3}, bitmap, res);
    box(cyan, Point{ .x = res.x-12, .y = 5},  Point{ .x = 3, .y = 3}, bitmap, res);

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

fn calcPos(x: u16, y: u16, res: Point) u32 {
   return (@as(u32, res.x) * @as(u32, y) + @as(u32, x)) *% @as(u32, 4);
}

fn pixel(color: Vector(4, u8), x: u16, y: u16, bitmap: []u8, res: Point) void {
    const offset = calcPos(x, y, res);
    bitmap[offset] = color[0];
    bitmap[offset + 1] = color[1];
    bitmap[offset + 2] = color[2];
    bitmap[offset + 3] = color[3];
}

fn box(color: Vector(4, u8), pos: Point, size: Point, bitmap: []u8, res: Point) void {
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

fn flush(bitmap: []u8, fb: fs.File) fs.File.PWriteError!void {
    try fb.seekTo(0);
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