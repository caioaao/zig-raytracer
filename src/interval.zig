const std = @import("std");

pub const Interval = packed struct {
    min: f64,
    max: f64,

    pub fn new() Interval {
        return .{
            .min = std.math.inf(f64),
            .max = -std.math.inf(f64),
        };
    }

    pub fn size(self: Interval) f64 {
        return self.max - self.min;
    }

    pub fn contains(self: Interval, x: f64) bool {
        return self.min <= x and self.max >= x;
    }

    pub fn surrounds(self: Interval, x: f64) bool {
        return self.min < x and self.max > x;
    }

    pub const EMPTY = Interval.new();
    pub const UNIVERSE = Interval{ .min = -std.math.inf(f64), .max = std.math.inf(f64) };
};
