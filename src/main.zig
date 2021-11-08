const std = @import("std");
const fs = std.fs;

pub fn main() anyerror!void {
    const fb = try fs.openFileAbsolute("/dev/fb0", .{ .write = true });
    defer fb.close();

    const blue = [_]u8{ 255, 0, 0, 255 };
    try pixel(blue[0..2], fb, 6);
}

fn pixel(color: []const u8, fb: fs.File, pos: u16) fs.File.PWriteError!void {
   _ = try fb.pwrite(color, pos * 4);
}

test "fb0 exists" {
     try fs.accessAbsolute("/dev/fb0", .{ .write = true });
}