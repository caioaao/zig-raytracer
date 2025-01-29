const std = @import("std");

const Vec3 = @import("./vec3.zig").Vec3;
const Interval = @import("./interval.zig").Interval;

pub const RGB = packed struct {
    r: u8,
    g: u8,
    b: u8,

    // TODO maybe there's a way of not needing the anytype?
    pub fn printPPM(self: RGB, writer: std.io.AnyWriter) !void {
        try writer.print("{d} {d} {d}\n", .{ self.r, self.g, self.b });
    }

    pub fn new(r: u8, g: u8, b: u8) RGB {
        return .{ .r = r, .g = g, .b = b };
    }

    pub fn newFromIntensityVector(v: Vec3) RGB {
        return new(byteFromRatio(v.x), byteFromRatio(v.y), byteFromRatio(v.z));
    }

    pub fn intensityVector(self: RGB) Vec3 {
        return Vec3.new(
            ratioFromByte(self.r),
            ratioFromByte(self.g),
            ratioFromByte(self.b),
        );
    }
};

const INTENSITY = Interval{ .min = 0, .max = 0.999 };

fn byteFromRatio(ratio: f64) u8 {
    const scaled: u32 = @intFromFloat(255.999 * INTENSITY.clamp(ratio));
    const truncated: u8 = @truncate(scaled);

    return truncated;
}

fn ratioFromByte(b: u8) f64 {
    return @as(f64, @floatFromInt(b)) / 255.999;
}
