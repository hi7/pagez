const std = @import("std");
const pagez = @import("pagez.zig");
const Vector = std.meta.Vector;
const Point = pagez.Point;

pub const white: Vector(4, u8) = Vector(4, u8){ 255, 255, 255, 255 };
pub const yellow: Vector(4, u8) = Vector(4, u8){ 0, 255, 255, 255 };
pub const blue: Vector(4, u8) = Vector(4, u8){ 255, 0, 0, 255 };
pub const green: Vector(4, u8) = Vector(4, u8){ 0, 255, 0, 255 };
pub const red: Vector(4, u8) = Vector(4, u8){ 0, 0, 255, 255 };
pub const magenta: Vector(4, u8) = Vector(4, u8){ 255, 0, 255, 255 };
pub const cyan: Vector(4, u8) = Vector(4, u8){ 255, 255, 0, 255 };

fn calcPos(x: u16, y: u16) u32 {
   return (@as(u32, pagez.display_size.x) * @as(u32, y) + @as(u32, x)) *% @as(u32, 4);
}

pub fn pixel(color: Vector(4, u8), x: u16, y: u16) void {
    const offset = calcPos(x, y);
    pagez.bitmap[offset] = color[0];
    pagez.bitmap[offset + 1] = color[1];
    pagez.bitmap[offset + 2] = color[2];
    pagez.bitmap[offset + 3] = color[3];
}

pub fn box(color: Vector(4, u8), pos: Point, size: Point) void {
    const offset = calcPos(pos.x, pos.y);
    var dx: u16 = 0;
    var dy: u16 = 0;
    while (dy < size.y) : (dy += 1) {
        const y_offset:u32 = dy * pagez.display_size.x * @as(u32, 4);
        while (dx < size.x*4) : (dx += 4) {
            pagez.bitmap[offset + y_offset + dx] = color[0];
            pagez.bitmap[offset + y_offset + dx + 1] = color[1];
            pagez.bitmap[offset + y_offset + dx + 2] = color[2];
            pagez.bitmap[offset + y_offset + dx + 3] = color[3];
        }
        dx = 0;
    }
}
