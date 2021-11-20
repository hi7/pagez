const std = @import("std");
const pagez = @import("pagez");
const gui = @import("gui");
const fs = std.fs;
const mem = std.mem;
const max = std.math.max;
const Point = pagez.Point;
const Position = pagez.Position;
const Size = pagez.Size;
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
        try pagez.flush();
        try waitForMouse();
        drawBackground(pos);
    }
    pagez.exit();
}

fn center() Position {
    return Position{ .x = pagez.display_size.x / 2, .y = pagez.display_size.y / 2 };
}

const cursor_dots = 8;
const cursor_bytes = cursor_dots * 4;
fn cursorBackground() [cursor_bytes]u8 {
   return @splat(cursor_bytes, @as(u8, 0));
}

var bg = cursorBackground();
const dots = [_]Point { 
    Point{ .x = 0, .y = -2}, Point{ .x = 0, .y = -1},
    Point{ .x = -2, .y = 0}, Point{ .x = -1, .y = 0},
    Point{ .x = 2, .y = 0}, Point{ .x = 1, .y = 0},
    Point{ .x = 0, .y = 2}, Point{ .x = 0, .y = 1},
};
fn drawCursor(pos: Position) !void {
    for (dots) |dot, index| {
        const p = Position { 
            .x = @intCast(u16, @intCast(i16, pos.x) + dot.x), 
            .y = @intCast(u16, @intCast(i16, pos.y) + dot.y), 
        };
        saveBgColorAt(p, index * 4);
        gui.pixel(gui.yellow, p);
    }
}
inline fn saveBgColorAt(pos: Position, offset: usize) void {
    const c = gui.colorAt(pos);
    bg[offset] = c[0];
    bg[offset+1] = c[1];
    bg[offset+2] = c[2];
    bg[offset+3] = c[3];
}
inline fn getColor(offset: usize) [4]u8 {
    return [4]u8 {
        bg[offset],
        bg[offset+1],
        bg[offset+2],
        bg[offset+3],
    };
}

fn drawBackground(pos: Position) void {
    for (dots) |dot, index| {
        const p = Position { 
            .x = @intCast(u16, @intCast(i16, pos.x) + dot.x), 
            .y = @intCast(u16, @intCast(i16, pos.y) + dot.y), 
        };
        gui.pixel(getColor(index*4), p);
    }
}

var m: pagez.Mouse = undefined;
inline fn waitForMouse() !void {
    m = try pagez.readMouse();
}

fn updatePos(pos: *Position) void {
    pos.x = @intCast(u16, max(0, (@intCast(i16, pos.x) + @intCast(i16, m.dx))));
    if (pos.x < 2) { pos.x = 2; }
    if (pos.x + 3 >= pagez.display_size.x) { pos.x = pagez.display_size.x - 3; }
    pos.y = @intCast(u16, max(0, (@intCast(i16, pos.y) + @intCast(i16, m.dy) * -1)));
    if (pos.y < 3) { pos.y = 2; }
    if (pos.y + 8 >= pagez.display_size.y) { pos.y = pagez.display_size.y - 3; }
}

fn draw() !void {
    pagez.clear();
    gui.box(gui.white, Position{ .x = pagez.display_size.x / 2 - 50, .y = pagez.display_size.x / 2 - 4}, Size{ .x = 8, .y = 8});
    gui.box(gui.white, Position{ .x = pagez.display_size.x / 2 + 50, .y = pagez.display_size.x / 2 - 4}, Size{ .x = 8, .y = 8});
    gui.box(gui.red, Position{ .x = pagez.display_size.x / 2 - 25, .y = pagez.display_size.x / 2 - 4}, Size{ .x = 8, .y = 8});
    gui.box(gui.red, Position{ .x = pagez.display_size.x / 2 + 25, .y = pagez.display_size.x / 2 - 4}, Size{ .x = 8, .y = 8});
}
