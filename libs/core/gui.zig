const std = @import("std");
const assert = std.debug.assert;
const pagez = @import("pagez.zig");
const Point = pagez.Point;
const Position = pagez.Position;
const Size = pagez.Size;

pub const white = [_]u8{ 255, 255, 255, 255 };
pub const yellow = [_]u8{ 0, 255, 255, 255 };
pub const blue = [_]u8{ 255, 0, 0, 255 };
pub const green = [_]u8{ 0, 255, 0, 255 };
pub const red = [_]u8{ 0, 0, 255, 255 };
pub const magenta = [_]u8{ 255, 0, 255, 255 };
pub const cyan = [_]u8{ 255, 255, 0, 255 };

fn calcOffset(x: u16, y: u16) u32 {
    return (@as(u32, pagez.display_size.x) * @as(u32, y) + @as(u32, x)) *% @as(u32, pagez.bytes_per_pixel);
}

pub fn colorAt(pos: Position) []u8 {
    const offset = calcOffset(pos.x, pos.y);
    var color: [4]u8 = undefined;
    var i: u8 = 0;
    while (i < pagez.bytes_per_pixel) : (i += 1) color[i] = pagez.bitmap[offset + i];
    return &color;
}

pub fn pixel(color: [4]u8, pos: Position) void {
    const offset = calcOffset(pos.x, pos.y);
    var i: u8 = 0;
    while (i < pagez.bytes_per_pixel) : (i += 1) pagez.bitmap[offset + i] = color[i];
}

pub fn box(color: [4]u8, pos: Position, size: Size) void {
    const bytes: u16 = pagez.bytes_per_pixel;
    const offset = calcOffset(pos.x, pos.y);
    var dx: u16 = 0;
    var dy: u16 = 0;
    while (dy < size.y) : (dy += 1) {
        const y_offset: u32 = dy * pagez.display_size.x * @as(u32, bytes);
        while (dx < size.x * bytes) : (dx += bytes) {
            var i: u8 = 0;
            while (i < bytes) : (i += 1) pagez.bitmap[offset + y_offset + dx + i] = color[i];
        }
        dx = 0;
    }
}
