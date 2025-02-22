const std = @import("std");
const boundedFloat = @import("./random.zig").boundedFloat;

pub const Vec3 = packed struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn new(x: f64, y: f64, z: f64) Vec3 {
        return .{ .x = x, .y = y, .z = z };
    }

    pub fn random(rand: std.Random) Vec3 {
        return new(rand.float(f64), rand.float(f64), rand.float(f64));
    }

    pub fn boundedRandom(rand: std.Random, min: f64, max: f64) Vec3 {
        return new(boundedFloat(f64, rand, min, max), boundedFloat(f64, rand, min, max), boundedFloat(f64, rand, min, max));
    }

    pub fn randomUnit(rand: std.Random) Vec3 {
        for (0..100) |_| {
            const p = boundedRandom(rand, -1, 1);
            const lensq = p.lengthSquared();
            if ((1e-160 < lensq) and (lensq <= 1)) {
                return p.scale(1.0 / std.math.sqrt(lensq));
            }
        }
        unreachable;
    }

    pub fn randomOnHemisphere(rand: std.Random, normal: Vec3) Vec3 {
        const on_unit_sphere = randomUnit(rand);
        if (dot(on_unit_sphere, normal) > 0.0) {
            return on_unit_sphere;
        }
        return reverse(on_unit_sphere);
    }

    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn scale(self: Vec3, s: f64) Vec3 {
        return Vec3{
            .x = self.x * s,
            .y = self.y * s,
            .z = self.z * s,
        };
    }

    pub fn length(self: Vec3) f64 {
        return std.math.sqrt(self.lengthSquared());
    }

    pub fn lengthSquared(self: Vec3) f64 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn dot(self: Vec3, other: Vec3) f64 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn cross(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }

    pub fn normalize(self: Vec3) Vec3 {
        return self.scale(1.0 / self.length());
    }

    pub fn reverse(self: Vec3) Vec3 {
        return self.scale(-1);
    }
};

pub const Point3 = Vec3;
