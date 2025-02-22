const std = @import("std");

pub fn boundedFloat(comptime T: type, rand: std.Random, min: f64, max: f64) f64 {
    return min + (max - min) * rand.float(T);
}
