const std = @import("std");
const Hittable = @import("./hittable.zig").Hittable;
const HitRecord = @import("./hittable.zig").HitRecord;
const Vec3 = @import("./vec3.zig").Vec3;
const Point3 = @import("./vec3.zig").Point3;
const Ray = @import("./ray.zig").Ray;

pub const Sphere = struct {
    center: Point3,
    radius: f64,

    pub fn new(center: Point3, radius: f64) Sphere {
        .{ .center = center, .radius = std.math.fmax(0, radius) };
    }

    pub fn hittable(self: *Sphere) Hittable {
        return .{
            .ptr = self,
            .vtable = &.{
                .hit = hit,
            },
        };
    }

    fn hit(ctx: *anyopaque, ray: Ray, rayTMin: f64, rayTMax: f64) ?HitRecord {
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
        if (root <= rayTMin or rayTMax <= root) {
            root = (h + sqrtd) / a;
            if (root <= rayTMin or rayTMax <= root) {
                return false;
            }
        }

        const hit_point = ray.at(root);
        const outward_normal = hit_point.sub(self.center).scale(1.0 / self.radius);
        const front_face = ray.direction.dot(outward_normal) < 0;
        return .{
            .t = root,
            .p = hit_point,
            .normal = if (front_face) outward_normal else outward_normal.reverse(),
        };
    }
};
