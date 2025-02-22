const std = @import("std");

const Point3 = @import("./vec3.zig").Point3;
const Vec3 = @import("./vec3.zig").Vec3;
const Ray = @import("./ray.zig").Ray;
const RGB = @import("./color.zig").RGB;
const Hittable = @import("./hittable.zig").Hittable;
const Interval = @import("./interval.zig").Interval;

pub const AspectRatio = packed struct {
    x: u32,
    y: u32,
};

pub const Viewport = packed struct {
    width: f64,
    height: f64,
    u: Vec3,
    v: Vec3,

    pub fn new(width: f64, height: f64) Viewport {
        return .{
            .width = width,
            .height = height,
            .u = Vec3{ .x = width, .y = 0.0, .z = 0.0 },
            .v = Vec3{ .x = 0.0, .y = -height, .z = 0.0 },
        };
    }
};

pub const Camera = struct {
    image_width: u32,
    image_height: u32,
    aspect_ratio: AspectRatio,
    viewport: Viewport,
    focal_length: f64,
    center: Point3,
    samples_per_pixel: u8 = 10,
    max_ray_bounces: usize = 50,

    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,
    pixel00_loc: Point3,
    rand: std.Random,

    pub fn init(image_width_: u32, aspect_ratio_: AspectRatio, rand: std.Random) Camera {
        const image_height_ = deriveImageHeight(image_width_, aspect_ratio_);
        const viewport = Viewport.new(
            2.0 * @as(f64, @floatFromInt(image_width_)) / @as(f64, @floatFromInt(image_height_)),
            2.0,
        );
        const center = Point3{ .x = 0.0, .y = 0.0, .z = 0.0 };
        const focal_length: f64 = 1.0;
        const viewport_upper_left = center.sub((Vec3{ .x = 0.0, .y = 0.0, .z = focal_length }).add(viewport.u.scale(0.5)).add(viewport.v.scale(0.5)));

        const pixel_delta_u = viewport.u.scale(1.0 / @as(f64, @floatFromInt(image_width_)));
        const pixel_delta_v = viewport.v.scale(1.0 / @as(f64, @floatFromInt(image_height_)));

        return Camera{
            .image_width = image_width_,
            .image_height = image_height_,
            .aspect_ratio = aspect_ratio_,
            .viewport = viewport,
            .focal_length = focal_length,
            .center = center,
            .pixel_delta_u = pixel_delta_u,
            .pixel_delta_v = pixel_delta_v,
            .pixel00_loc = viewport_upper_left.add(pixel_delta_u.scale(0.5)).add(pixel_delta_v.scale(0.5)),
            .rand = rand,
        };
    }

    pub fn rayColorIntensity(self: Camera, ray: Ray, bouncesLeft: usize, world: Hittable) Vec3 {
        if (bouncesLeft <= 0) return Vec3.new(0, 0, 0);
        if (world.hit(ray, Interval{ .min = 0.001, .max = std.math.inf(f64) })) |hit_record| {
            const direction = Vec3.randomOnHemisphere(self.rand, hit_record.normal);
            return rayColorIntensity(self, Ray.new(hit_record.p, direction), bouncesLeft - 1, world).scale(0.5);
        }

        const a = ray.direction.y * 0.5 + 0.5;
        return Vec3.new(
            (1.0 - a) + a * 0.5,
            (1.0 - a) + a * 0.7,
            (1.0 - a) + a * 1.0,
        );
    }

    pub fn renderPPM(self: Camera, world: Hittable, writer: std.io.AnyWriter) !void {
        try writer.print("P3\n{d} {d}\n255\n", .{ self.image_width, self.image_height });

        for (0..self.image_height) |j| {
            std.debug.print("Scanlines remaining: {d}\n", .{self.image_height - j});

            for (0..self.image_width) |i| {
                var pixel_color_intensity = Vec3.new(0, 0, 0);
                for (0..self.samples_per_pixel) |_| {
                    const ray = self.getRay(i, j);

                    const sample = self.rayColorIntensity(ray, self.max_ray_bounces, world);
                    pixel_color_intensity = pixel_color_intensity.add(sample);
                }
                pixel_color_intensity = pixel_color_intensity.scale(1.0 / @as(f64, @floatFromInt(self.samples_per_pixel)));
                const color = RGB.newFromIntensityVector(pixel_color_intensity);
                try color.printPPM(writer);
            }
        }

        std.debug.print("Done.\n", .{});
    }

    fn getRay(self: Camera, i: usize, j: usize) Ray {
        const jitter_offset = Vec3.new(self.rand.float(f64) - 0.5, self.rand.float(f64) - 0.5, 0.0);
        const pixel_center = self.pixel00_loc
            .add(self.pixel_delta_u.scale(@as(f64, @floatFromInt(i)) + jitter_offset.x))
            .add(self.pixel_delta_v.scale(@as(f64, @floatFromInt(j)) + jitter_offset.y));

        return Ray{ .origin = self.center, .direction = pixel_center.sub(self.center) };
    }
};

fn deriveImageHeight(width: u32, aspect_ratio_: AspectRatio) u32 {
    const height = width * aspect_ratio_.y / aspect_ratio_.x;
    return @max(height, 1);
}
