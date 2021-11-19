const std = @import("std");
const filez = @import("filez");
const fs = std.fs;
const mem = std.mem;
const Point = filez.Point;
const Vector = std.meta.Vector;
const expect = std.testing.expect;

pub fn main() anyerror!void {
    const res = try filez.resolution();
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
    filez.box(c, mp, Point{ .x = 4, .y = 4}, bitmap, res);
    while (!m.lmb) {
        mp.x = @intCast(u16, (@intCast(i16, mp.x) + @intCast(i16, m.dx)));
        mp.y = @intCast(u16, (@intCast(i16, mp.y) + @intCast(i16, m.dy) * -1));
        filez.box(c, mp, Point{ .x = 8, .y = 8}, bitmap, res);
        try filez.flush(bitmap, fb);
        m = try filez.readMouse();
    }
    filez.exit();
}

fn draw(bitmap: []u8, res: Point, fb: fs.File) anyerror!void {
    filez.clear(bitmap);
    // TODO: use u32 for color
    const white: Vector(4, u8) = .{ 255, 255, 255, 255 };
    filez.box(white, Point{ .x = 0, .y = 0},  Point{ .x = 8, .y = 8}, bitmap, res);
    filez.box(white, Point{ .x = res.x-9, .y = 0},  Point{ .x = 8, .y = 8}, bitmap, res);
    const cyan = [4]u8{ 255, 255, 0, 255 };
    filez.box(cyan, Point{ .x = 8, .y = 5},  Point{ .x = 3, .y = 3}, bitmap, res);
    filez.box(cyan, Point{ .x = res.x-12, .y = 5},  Point{ .x = 3, .y = 3}, bitmap, res);

    try filez.flush(bitmap, fb);
}
