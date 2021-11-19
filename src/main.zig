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

    var m = try pagez.readMouse();
    var mp = Point{ .x = pagez.display_size.x / 2, .y = pagez.display_size.y / 2 };
    gui.box(gui.white, mp, Point{ .x = 4, .y = 4});
    while (!m.lmb) {
        mp.x = @intCast(u16, max(0, (@intCast(i16, mp.x) + @intCast(i16, m.dx))));
        if (mp.x + 8 >= pagez.display_size.x) { mp.x = pagez.display_size.x - 9; }
        mp.y = @intCast(u16, max(0, (@intCast(i16, mp.y) + @intCast(i16, m.dy) * -1)));
        if (mp.y + 8 >= pagez.display_size.y) { mp.y = pagez.display_size.y - 9; }
        gui.box(gui.yellow, mp, Point{ .x = 8, .y = 8});
        try pagez.flush();
        m = try pagez.readMouse();
    }
    pagez.exit();
}

fn draw() !void {
    pagez.clear();
    gui.box(gui.white, Point{ .x = 0, .y = 0},  Point{ .x = 8, .y = 8});
    gui.box(gui.white, Point{ .x = pagez.display_size.x-9, .y = 0},  Point{ .x = 8, .y = 8});
    gui.box(gui.magenta, Point{ .x = 8, .y = 5},  Point{ .x = 3, .y = 3});
    gui.box(gui.magenta, Point{ .x = pagez.display_size.x-12, .y = 5},  Point{ .x = 3, .y = 3});

    try pagez.flush();
}
