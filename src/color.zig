const std = @import("std");

const Vec3 = @import("./vec3.zig").Vec3;

pub const RGB = packed struct {
    r: u8,
    g: u8,
    b: u8,

    // TODO maybe there's a way of not needing the anytype?
    pub fn printPPM(self: RGB, writer: anytype) !void {
        try writer.print("{d} {d} {d}\n", .{ self.r, self.g, self.b });
    }

    pub fn newFromRatios(r: f64, g: f64, b: f64) RGB {
        return .{
            .r = byteFromRatio(r),
            .g = byteFromRatio(g),
            .b = byteFromRatio(b),
        };
    }
};

fn byteFromRatio(ratio: f64) u8 {
    const scaled: u32 = @intFromFloat(255.999 * ratio);
    const truncated: u8 = @truncate(scaled);

    return truncated;
}
