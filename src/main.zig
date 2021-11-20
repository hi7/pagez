const std = @import("std");
const pagez = @import("pagez");
const gui = @import("gui");
const fs = std.fs;
const mem = std.mem;
const max = std.math.max;
const Point = pagez.Point;
const expect = std.testing.expect;

pub fn main() !void {
    try pagez.init();
    try draw();
    try pagez.flush();

    try waitForMouse();
    var pos = center();
    while (!m.lmb) {
        updatePos(&pos);
        try drawCursor(pos);
        try waitForMouse();
        drawBackground(pos);
    }
    pagez.exit();
}

fn center() Point {
    return Point{ .x = pagez.display_size.x / 2, .y = pagez.display_size.y / 2 };
}

const cursor_dots = 2;
const cursor_bytes = cursor_dots * 4;
fn cursorBackground() [cursor_bytes]u8 {
   return @splat(cursor_bytes, @as(u8, 0));
}

var bg = cursorBackground();
const dots = []Point {};
fn drawCursor(pos: Point) !void {
    var i: u8 = 0;
    const c = gui.colorAt(pos);
    while (i < 4) : (i += 1) bg[i] = c[i];
    gui.pixel(gui.yellow, pos);
    try pagez.flush();
}

fn drawBackground(pos: Point) void {
    gui.pixel(bg[0..4].*, pos);
}

var m: pagez.Mouse = undefined;
inline fn waitForMouse() !void {
    m = try pagez.readMouse();
}

fn updatePos(pos: *Point) void {
    pos.x = @intCast(u16, max(0, (@intCast(i16, pos.x) + @intCast(i16, m.dx))));
    if (pos.x + 8 >= pagez.display_size.x) { pos.x = pagez.display_size.x - 9; }
    pos.y = @intCast(u16, max(0, (@intCast(i16, pos.y) + @intCast(i16, m.dy) * -1)));
    if (pos.y + 8 >= pagez.display_size.y) { pos.y = pagez.display_size.y - 9; }
}

fn draw() !void {
    pagez.clear();
    gui.box(gui.white, Point{ .x = 0, .y = 0},  Point{ .x = 8, .y = 8});
    gui.box(gui.white, Point{ .x = pagez.display_size.x-9, .y = 0},  Point{ .x = 8, .y = 8});
    gui.box(gui.magenta, Point{ .x = 8, .y = 5},  Point{ .x = 3, .y = 3});
    gui.box(gui.magenta, Point{ .x = pagez.display_size.x-12, .y = 5},  Point{ .x = 3, .y = 3});
}
