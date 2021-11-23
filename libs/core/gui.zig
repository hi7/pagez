const std = @import("std");
const pagez = @import("pagez.zig");
const Point = pagez.Point;
const Position = pagez.Position;
const Size = pagez.Size;

pub const white = [4]u8{ 255, 255, 255, 255 };
pub const yellow = [4]u8{ 0, 255, 255, 255 };
pub const blue = [4]u8{ 255, 0, 0, 255 };
pub const green = [4]u8{ 0, 255, 0, 255 };
pub const red = [4]u8{ 0, 0, 255, 255 };
pub const magenta = [4]u8{ 255, 0, 255, 255 };
pub const cyan = [4]u8{ 255, 255, 0, 255 };

fn calcOffset(x: u16, y: u16) u32 {
    return (@as(u32, pagez.display_size.x) * @as(u32, y) + @as(u32, x)) *% @as(u32, 4);
}

pub fn colorAt(pos: Position) [4]u8 {
    const offset = calcOffset(pos.x, pos.y);
    return [4]u8{
        pagez.bitmap[offset],
        pagez.bitmap[offset + 1],
        pagez.bitmap[offset + 2],
        pagez.bitmap[offset + 3],
    };
}

pub fn pixel(color: [4]u8, pos: Position) void {
    const offset = calcOffset(pos.x, pos.y);
    pagez.bitmap[offset] = color[0];
    pagez.bitmap[offset + 1] = color[1];
    pagez.bitmap[offset + 2] = color[2];
    pagez.bitmap[offset + 3] = color[3];
}

pub fn box(color: [4]u8, pos: Position, size: Size) void {
    const offset = calcOffset(pos.x, pos.y);
    var dx: u16 = 0;
    var dy: u16 = 0;
    while (dy < size.y) : (dy += 1) {
        const y_offset: u32 = dy * pagez.display_size.x * @as(u32, 4);
        while (dx < size.x * 4) : (dx += 4) {
            var i: u8 = 0;
            while (i < std.mem.len(color)) : (i += 1) pagez.bitmap[offset + y_offset + dx + i] = color[i];
        }
        dx = 0;
    }
}
