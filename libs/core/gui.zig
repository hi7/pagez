const std = @import("std");
const assert = std.debug.assert;
const pagez = @import("pagez.zig");
const Point = pagez.Point;
const Position = pagez.Position;
const Size = pagez.Size;

fn to16bitColor(r: u8, g: u8, b: u8) [4]u8 {
    assert(r < 32);
    assert(g < 64);
    assert(b < 32);
    var color: [4]u8 = undefined;
    color[0] = b >> 1;
    color[1] = ((b & 0x1) << 7) & ((r & 0xE) << 3);
    color[2] = ((r & 0x2) << 2) & ((g & 0xA) >> 4);
    color[3] = g & 0xF;
    return color;
}

pub fn black() [4]u8 {
    return [4]u8{ 0, 0, 0, 0 };
}
pub fn white() [4]u8 {
    return if (pagez.bytes_per_pixel == 4) [4]u8{ 255, 255, 255, 255 } else [4]u8{ 0xFF, 0xFF, 0, 0 };
}
pub fn gray() [4]u8 {
    return if (pagez.bytes_per_pixel == 4) [4]u8{ 0x7F, 0x7F, 0x7F, 255 } else to16bitColor(16, 32, 16);
}
pub fn blue() [4]u8 {
    return if (pagez.bytes_per_pixel == 4) [4]u8{ 255, 0, 0, 255 } else [4]u8{ 0xF8, 0x00, 0, 0 };
}
pub fn green() [4]u8 {
    return if (pagez.bytes_per_pixel == 4) [4]u8{ 0, 255, 0, 255 } else [4]u8{ 0x00, 0x2F, 0, 0 };
}
pub fn red() [4]u8 {
    return if (pagez.bytes_per_pixel == 4) [4]u8{ 0, 0, 255, 255 } else [4]u8{ 0x02, 0xB0, 0, 0 };
}
pub fn yellow() [4]u8 {
    return if (pagez.bytes_per_pixel == 4) [4]u8{ 0, 255, 255, 255 } else [4]u8{ 0x0F, 0xFF, 0, 0 };
}
pub fn magenta() [4]u8 {
    return if (pagez.bytes_per_pixel == 4) [4]u8{ 255, 0, 255, 255 } else [4]u8{ 0xF0, 0xFF, 0, 0 };
}
pub fn cyan() [4]u8 {
    return if (pagez.bytes_per_pixel == 4) [4]u8{ 255, 255, 0, 255 } else [4]u8{ 0xF8, 0x0F, 0, 0 };
}

fn calcOffset(x: u16, y: u16) u32 {
    return (@as(u32, pagez.display_size.x) * @as(u32, y) + @as(u32, x)) *% @as(u32, pagez.bytes_per_pixel);
}

pub fn colorAt(pos: Position) []u8 {
    const offset = calcOffset(pos.x, pos.y);
    var color: [4]u8 = undefined;
    var i: u8 = 0;
    while (i < pagez.bytes_per_pixel) : (i += 1) color[i] = pagez.bitmap[offset + i];
    return color[0..pagez.bytes_per_pixel];
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
