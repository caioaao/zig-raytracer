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

    pub fn color(_: Ray) RGB {
        return RGB{ .r = 0.0, .g = 0.0, .b = 0.0 };
    }
};
