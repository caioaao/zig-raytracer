const std = @import("std");
const Vec3 = @import("./vec3.zig").Vec3;
const RGB = @import("./color.zig").RGB;

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const img_width = 256;
    const img_height = 256;

    try stdout.print("P3\n{d} {d}\n255\n", .{ img_width, img_height });

    for (0..img_height) |j| {
        std.debug.print("Scanlines remaining: {d}\n", .{img_height - j});
        for (0..img_width) |i| {
            const v = Vec3{
                .x = @as(f64, @floatFromInt(i)) / (img_width - 1),
                .y = @as(f64, @floatFromInt(j)) / (img_height - 1),
                .z = 0,
            };
            const pixel_color = vecToRGB(v);
            try pixel_color.printPPM(stdout);
        }
    }

    std.debug.print("Done.\n", .{});

    try bw.flush();
}

fn vecToRGB(v: Vec3) RGB {
    return RGB{
        .r = byteFromRatio(v.x),
        .g = byteFromRatio(v.y),
        .b = byteFromRatio(v.z),
    };
}

fn byteFromRatio(ratio: f64) u8 {
    const scaled: u32 = @intFromFloat(255.999 * ratio);
    const truncated: u8 = @truncate(scaled);

    return truncated;
}
test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
