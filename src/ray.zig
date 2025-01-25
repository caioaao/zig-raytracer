const Vec3 = @import("./vec3.zig").Vec3;
const Point3 = @import("./vec3.zig").Point3;
const RGB = @import("./color.zig").RGB;

const RED = RGB.newFromRatios(1, 0, 0);

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
        if (self.hitSphere(.{ .x = 0, .y = 0, .z = -1 }, 0.5)) {
            return RED;
        }
        const a = self.direction.y * 0.5 + 0.5;
        return RGB.newFromRatios(
            (1.0 - a) + a * 0.5,
            (1.0 - a) + a * 0.7,
            (1.0 - a) + a * 1.0,
        );
    }

    pub fn hitSphere(self: Ray, center: Point3, radius: f64) bool {
        const oc = center.sub(self.origin);
        const a = Vec3.dot(self.direction, self.direction);
        const b = -2.0 * Vec3.dot(self.direction, oc);
        const c = Vec3.dot(oc, oc) - radius * radius;
        const discriminant = b * b - 4 * a * c;
        return discriminant >= 0;
    }
};

fn byteFromRatio(ratio: f64) u8 {
    const scaled: u32 = @intFromFloat(255.999 * ratio);
    const truncated: u8 = @truncate(scaled);

    return truncated;
}
