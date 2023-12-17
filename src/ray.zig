const Vec3 = @import("./vec3.zig").Vec3;
const Point3 = @import("./vec3.zig").Point3;
const RGB = @import("./color.zig").RGB;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,

    pub fn new(origin: Point3, direction: Vec3) Ray {
        return Ray{
            .origin = origin,
            .direction = direction.normalize(),
        };
    }

    // Returns a point along the ray at a distance t from the origin.
    pub fn at(self: Ray, t: f64) Point3 {
        return self.origin.add(self.direction.scale(t));
    }

    pub fn color(self: Ray) RGB {
        const a = self.direction.y * 0.5 + 0.5;
        return RGB{
            .r = byteFromRatio((1.0 - a) + a * 0.5),
            .g = byteFromRatio((1.0 - a) + a * 0.7),
            .b = byteFromRatio((1.0 - a) + a * 1.0),
        };
    }
};

fn byteFromRatio(ratio: f64) u8 {
    const scaled: u32 = @intFromFloat(255.999 * ratio);
    const truncated: u8 = @truncate(scaled);

    return truncated;
}
