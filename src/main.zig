const std = @import("std");
const Vec3 = @import("./vec3.zig").Vec3;
const RGB = @import("./color.zig").RGB;
const AspectRatio = @import("./camera.zig").AspectRatio;
const Camera = @import("./camera.zig").Camera;

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const camera = Camera.init(400, AspectRatio{ .x = 16.0, .y = 9.0 });

    try camera.renderPPM(stdout);

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
