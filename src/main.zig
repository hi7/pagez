const std = @import("std");
const fs = std.fs;

pub fn main() anyerror!void {
    var buffer: [1366*768*4]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var allocator = &fba.allocator;

    var bitmap = try allocator.alloc(u8, 1366*768*4);
    defer allocator.free(bitmap);
    
    const white = [4]u8{ 255, 255, 255, 255 };
    pixel(white, bitmap, 0);
    const blue = [4]u8{ 255, 0, 0, 255 };
    pixel(blue, bitmap, 1);


    const fb = try fs.openFileAbsolute("/dev/fb0", .{ .write = true });
    defer fb.close();

    try flush(bitmap, fb);
}

fn pixel(color: [4]u8, bitmap: []u8, pos: u16) void {
   bitmap[pos] = color[0];
   bitmap[pos+1] = color[1];
   bitmap[pos+2] = color[2];
   bitmap[pos+3] = color[3];
}

fn flush(bitmap: []u8, fb: fs.File) fs.File.PWriteError!void {
   _ = try fb.write(bitmap);
}

test "fb0 exists" {
     try fs.accessAbsolute("/dev/fb0", .{ .write = true });
}