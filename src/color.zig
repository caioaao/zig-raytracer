const std = @import("std");

const Vec3 = @import("./vec3.zig").Vec3;
const Interval = @import("./interval.zig").Interval;

pub const RGB = packed struct {
    r: u8,
    g: u8,
    b: u8,

    pub fn printPPM(self: RGB, writer: std.io.AnyWriter) !void {
        const r = self.r;
        const g = self.g;
        const b = self.b;
        try writer.print("{d} {d} {d}\n", .{ r, g, b });
    }

    pub fn new(r: u8, g: u8, b: u8) RGB {
        return .{ .r = r, .g = g, .b = b };
    }

    pub fn newFromIntensityVector(v: Vec3) RGB {
        const r = byteFromRatio(linearToGamma(v.x));
        const g = byteFromRatio(linearToGamma(v.y));
        const b = byteFromRatio(linearToGamma(v.z));
        return new(r, g, b);
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

inline fn linearToGamma(linear_component: f64) f64 {
    if (linear_component > 0) return std.math.sqrt(linear_component);
    return 0;
}

inline fn gammaToLinear(gamma_component: f64) f64 {
    return gamma_component * gamma_component;
}
