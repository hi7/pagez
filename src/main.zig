const std = @import("std");
const pagez = @import("pagez");
const gui = @import("gui");
const fs = std.fs;
const mem = std.mem;
const max = std.math.max;
const print = std.debug.print;
const Thread = std.Thread;
const Point = pagez.Point;
const Position = pagez.Position;
const Size = pagez.Size;
const expect = std.testing.expect;
const Mouse = pagez.Mouse;
const sleep = std.time.sleep;

//pub const io_mode = .evented;

pub fn main() !void {
    try pagez.init();

    try draw();
    try pagez.flush();

    _ = try Thread.spawn(handleInput, 0);

    var pos = center();
    cursor_color = gui.white();
    updateCursor(pos);
    var time = std.time.milliTimestamp();
    while (!m.rmb) {
        if (!isIdle(m)) {
            drawCursorBackground(pos, true);
            pos = updatePos(pos);
            m.dx = 0;
            m.dy = 0;
            updateCursor(pos);
        }
        var dt = std.time.milliTimestamp() - time;
        if (dt > 850) {
            drawCursorBackground(pos, false);
            cursor_color = if (cursor_color[0] == 0) gui.white() else gui.black();
            updateCursor(pos);
            time = std.time.milliTimestamp();
        }
        std.time.sleep(50000000);
    }
    pagez.exit();
}

fn updateCursor(pos: Position) void {
    drawCursor(pos, true) catch |err| {
        print("drawCursor({s}) error: {s}\n", .{ pos, err });
    };
}

inline fn isIdle(mouse: Mouse) bool {
    return mouse.dx == 0 and mouse.dy == 0;
}

fn center() Position {
    return Position{ .x = pagez.display_size.x / 2, .y = pagez.display_size.y / 2 };
}

const cursor_dots = 8;
const cursor_bytes = cursor_dots * 4;
fn cursorBackground() [cursor_bytes]u8 {
    return @splat(cursor_bytes, @as(u8, 0));
}

const cursor_radius = 3;
var bg = cursorBackground();
const dots = [_]Point{
    Point{ .x = 2, .y = 0 }, Point{ .x = 3, .y = 0 },
    Point{ .x = 4, .y = 0 }, Point{ .x = 5, .y = 0 },
    Point{ .x = 0, .y = 2 }, Point{ .x = 0, .y = 3 },
    Point{ .x = 0, .y = 4 }, Point{ .x = 0, .y = 5 },
};
var cursor_color: [4]u8 = undefined;
fn drawCursor(pos: Position, flush: bool) !void {
    for (dots) |dot, index| {
        const p = Position{
            .x = @intCast(u16, @intCast(i16, pos.x) + dot.x),
            .y = @intCast(u16, @intCast(i16, pos.y) + dot.y),
        };
        saveBgColorAt(p, index * 4);
        gui.pixel(cursor_color, p);
        if (flush) {
            try pagez.flushData(&cursor_color, gui.calcOffset(p));
        }
    }
}
inline fn saveBgColorAt(pos: Position, offset: usize) void {
    const c = gui.colorAt(pos);
    var i: u8 = 0;
    while (i < pagez.bytes_per_pixel) : (i += 1) bg[offset + i] = c[i];
}
inline fn cursorBackgroundColor(offset: usize) [4]u8 {
    var i: u8 = 0;
    var c: [4]u8 = undefined;
    while (i < pagez.bytes_per_pixel) : (i += 1) c[i] = bg[offset + i];
    return c;
}
fn drawCursorBackground(pos: Position, flush: bool) void {
    for (dots) |dot, index| {
        const p = Position{
            .x = @intCast(u16, @intCast(i16, pos.x) + dot.x),
            .y = @intCast(u16, @intCast(i16, pos.y) + dot.y),
        };
        var bgColor: [4]u8 = cursorBackgroundColor(index * pagez.bytes_per_pixel);
        gui.pixel(bgColor, p);
        if (flush) {
            pagez.flushData(bgColor[0..pagez.bytes_per_pixel], gui.calcOffset(p)) catch |err| {
                print("drawCursorBackground() error: {s}\n", .{err});
            };
        }
    }
}

var m: Mouse = undefined;
fn handleInput(num: u8) u8 {
    while (true) {
        m = pagez.readMouse() catch |err| {
            print("readMouse() error: {s}\n", .{err});
            return 1;
        };
    }
    return num;
}

fn updatePos(pos: Position) Position {
    var result = Position{ .x = @intCast(u16, max(0, (@intCast(i16, pos.x) + @intCast(i16, m.dx)))), .y = @intCast(u16, max(0, (@intCast(i16, pos.y) + @intCast(i16, m.dy) * -1))) };
    if (result.x < cursor_radius) {
        result.x = cursor_radius;
    }
    if (result.x + cursor_radius >= pagez.display_size.x) {
        result.x = pagez.display_size.x - cursor_radius;
    }
    if (result.y < cursor_radius) {
        result.y = cursor_radius;
    }
    if (result.y + cursor_radius + 1 >= pagez.display_size.y) {
        result.x = pagez.display_size.y - cursor_radius - 1;
    }
    return result;
}

fn draw() !void {
    pagez.clear(gui.gray(), pagez.bytes_per_pixel);
    gui.box(gui.white(), Position{ .x = pagez.display_size.x / 2 - 50, .y = pagez.display_size.y / 2 - 4 }, Size{ .x = 8, .y = 8 });
    gui.box(gui.white(), Position{ .x = pagez.display_size.x / 2 + 50, .y = pagez.display_size.y / 2 - 4 }, Size{ .x = 8, .y = 8 });
    gui.box(gui.red(), Position{ .x = pagez.display_size.x / 2 - 25, .y = pagez.display_size.y / 2 - 4 }, Size{ .x = 8, .y = 8 });
    gui.box(gui.red(), Position{ .x = pagez.display_size.x / 2 + 25, .y = pagez.display_size.y / 2 - 4 }, Size{ .x = 8, .y = 8 });
}
