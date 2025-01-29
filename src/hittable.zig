const std = @import("std");
const Vec3 = @import("./vec3.zig").Vec3;
const Point3 = @import("./vec3.zig").Point3;
const Ray = @import("./ray.zig").Ray;
const Interval = @import("./interval.zig").Interval;

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    t: f64,
    front_face: bool,
};

// Interface for hittable objects
pub const Hittable = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        hit: *const fn (ctx: *anyopaque, ray: Ray, ray_t: Interval) ?HitRecord,
    };

    pub fn hit(self: Hittable, ray: Ray, ray_t: Interval) ?HitRecord {
        return self.vtable.hit(self.ptr, ray, ray_t);
    }
};

pub const HittableList = struct {
    objects: std.ArrayList(Hittable),

    pub fn init(allocator: std.mem.Allocator) HittableList {
        return .{
            .objects = std.ArrayList(Hittable).init(allocator),
        };
    }

    pub fn deinit(self: HittableList) void {
        self.objects.deinit();
    }

    pub fn hittable(self: *HittableList) Hittable {
        return .{
            .ptr = self,
            .vtable = &.{
                .hit = hit,
            },
        };
    }

    pub fn add(self: *HittableList, object: Hittable) !void {
        try self.objects.append(object);
    }

    pub fn hit(ctx: *anyopaque, ray: Ray, ray_t: Interval) ?HitRecord {
        const self: *HittableList = @ptrCast(@alignCast(ctx));
        var hit_record: ?HitRecord = null;
        var closest_so_far = ray_t.max;

        for (self.objects.items) |object| {
            if (object.hit(ray, Interval{ .min = ray_t.min, .max = closest_so_far })) |new_hit_record| {
                hit_record = new_hit_record;
                closest_so_far = new_hit_record.t;
            }
        }

        return hit_record;
    }
};
