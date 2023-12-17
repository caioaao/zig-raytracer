const std = @import("std");

pub const Vec3 = packed struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3{ .e = .{ self.x + other.x, self.y + other.y, self.z + other.z } };
    }

    pub fn sub(self: Vec3, other: Vec3) Vec3 {
        return Vec3{ .e = .{ self.x - other.x, self.y - other.y, self.z - other.z } };
    }

    pub fn scale(self: Vec3, s: f64) Vec3 {
        return Vec3{ .e = .{ self.x * s, self.y * s, self.z * s } };
    }

    pub fn length(self: Vec3) f64 {
        return std.math.sqrt(self.length_squared);
    }

    pub fn length_squared(self: Vec3) f64 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn dot(self: Vec3, other: Vec3) f64 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn cross(self: Vec3, other: Vec3) Vec3 {
        return Vec3{ .e = .{
            self.y * other.z - self.z * other.y,
            self.z * other.x - self.x * other.z,
            self.x * other.y - self.y * other.x,
        } };
    }

    pub fn unit_vector(self: Vec3) Vec3 {
        return self.scale(1.0 / self.length);
    }
};

pub const Point3 = Vec3;
