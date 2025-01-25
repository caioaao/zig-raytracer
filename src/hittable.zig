const Vec3 = @import("./vec3.zig").Vec3;
const Point3 = @import("./vec3.zig").Point3;
const Ray = @import("./ray.zig").Ray;

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
        hit: *const fn (ctx: *anyopaque, ray: Ray, rayTMin: f64, rayTMax: f64) ?HitRecord,
    };

    pub fn hit(self: Hittable, ray: Ray, rayTMin: f64, rayTMax: f64) ?HitRecord {
        return self.vtable.hit(self.ptr, ray, rayTMin, rayTMax);
    }
};
