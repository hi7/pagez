const std = @import("std");
const filez = @import("filez");
const gui = @import("gui");
const fs = std.fs;
const mem = std.mem;
const Point = filez.Point;
const expect = std.testing.expect;

pub fn main() anyerror!void {
    try filez.init();
    try draw();

    var m = try filez.readMouse();
    var mp = Point{ .x = filez.display_size.x / 2, .y = filez.display_size.y / 2 };
    gui.box(gui.white, mp, Point{ .x = 4, .y = 4});
    while (!m.lmb) {
        mp.x = @intCast(u16, (@intCast(i16, mp.x) + @intCast(i16, m.dx)));
        mp.y = @intCast(u16, (@intCast(i16, mp.y) + @intCast(i16, m.dy) * -1));
        gui.box(gui.yellow, mp, Point{ .x = 8, .y = 8});
        try filez.flush();
        m = try filez.readMouse();
    }
    filez.exit();
}

fn draw() anyerror!void {
    filez.clear();
    gui.box(gui.white, Point{ .x = 0, .y = 0},  Point{ .x = 8, .y = 8});
    gui.box(gui.white, Point{ .x = filez.display_size.x-9, .y = 0},  Point{ .x = 8, .y = 8});
    gui.box(gui.magenta, Point{ .x = 8, .y = 5},  Point{ .x = 3, .y = 3});
    gui.box(gui.magenta, Point{ .x = filez.display_size.x-12, .y = 5},  Point{ .x = 3, .y = 3});

    try filez.flush();
}
