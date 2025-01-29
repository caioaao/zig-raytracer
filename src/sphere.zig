const std = @import("std");
const Hittable = @import("./hittable.zig").Hittable;
const HitRecord = @import("./hittable.zig").HitRecord;
const Vec3 = @import("./vec3.zig").Vec3;
const Point3 = @import("./vec3.zig").Point3;
const Ray = @import("./ray.zig").Ray;
const Interval = @import("./interval.zig").Interval;

pub const Sphere = struct {
    center: Point3,
    radius: f64,

    pub fn new(center: Point3, radius: f64) Sphere {
        return .{ .center = center, .radius = @max(0, radius) };
    }

    pub fn hittable(self: *Sphere) Hittable {
        return .{
            .ptr = self,
            .vtable = &.{
                .hit = hit,
            },
        };
    }

    fn hit(ctx: *anyopaque, ray: Ray, ray_t: Interval) ?HitRecord {
        const self: *Sphere = @ptrCast(@alignCast(ctx));

        const oc = self.center.sub(ray.origin);
        const a = ray.direction.lengthSquared();
        const h = Vec3.dot(ray.direction, oc);
        const c = oc.lengthSquared() - self.radius * self.radius;
        const discriminant = h * h - a * c;

        if (discriminant < 0) return null;

        const sqrtd = std.math.sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range.
        var root = (h - sqrtd) / a;
        if (!ray_t.surrounds(root)) {
            root = (h + sqrtd) / a;
            if (!ray_t.surrounds(root)) {
                return null;
            }
        }

        const hit_point = ray.at(root);
        const outward_normal = hit_point.sub(self.center).scale(1.0 / self.radius);
        const front_face = ray.direction.dot(outward_normal) < 0;
        return .{
            .t = root,
            .p = hit_point,
            .normal = if (front_face) outward_normal else outward_normal.reverse(),
            .front_face = front_face,
        };
    }
};
