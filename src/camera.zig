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
};

pub const Camera = struct {
    image_width: u32,
    image_height: u32,
    aspect_ratio: AspectRatio,
    viewport: Viewport,
    focal_length: f64 = 1.0,
    center: Point3 = Point3{ .x = 0.0, .y = 0.0, .z = 0.0 },

    pub fn init(image_width_: u32, aspect_ratio_: AspectRatio) Camera {
        const image_height_ = deriveImageHeight(image_width_, aspect_ratio_);
        return Camera{
            .image_width = image_width_,
            .image_height = image_height_,
            .aspect_ratio = aspect_ratio_,
            .viewport = Viewport{
                .width = 2.0 * @as(f64, @floatFromInt(image_width_)) / @as(f64, @floatFromInt(image_height_)),
                .height = 2.0,
            },
        };
    }

    pub fn ray_color(_: Camera, ray: Ray, world: Hittable) RGB {
        if (world.hit(ray, Interval{ .min = 0, .max = std.math.inf(f64) })) |hit_record| {
            return RGB.newFromRatios(
                (hit_record.normal.x + 1) * 0.5,
                (hit_record.normal.y + 1) * 0.5,
                (hit_record.normal.z + 1) * 0.5,
            );
        }

        const a = ray.direction.y * 0.5 + 0.5;
        return RGB.newFromRatios(
            (1.0 - a) + a * 0.5,
            (1.0 - a) + a * 0.7,
            (1.0 - a) + a * 1.0,
        );
    }

    pub fn renderPPM(self: Camera, world: Hittable, writer: std.io.AnyWriter) !void {
        const viewport_u = Vec3{ .x = self.viewport.width, .y = 0.0, .z = 0.0 };
        const viewport_v = Vec3{ .x = 0.0, .y = -self.viewport.height, .z = 0.0 };

        const pixel_delta_u = viewport_u.scale(1.0 / @as(f64, @floatFromInt(self.image_width)));
        const pixel_delta_v = viewport_v.scale(1.0 / @as(f64, @floatFromInt(self.image_height)));

        const viewport_upper_left = self.center.sub((Vec3{ .x = 0.0, .y = 0.0, .z = self.focal_length }).add(viewport_u.scale(0.5)).add(viewport_v.scale(0.5)));
        const pixel00_loc = viewport_upper_left.add(pixel_delta_u.scale(0.5)).add(pixel_delta_v.scale(0.5));

        try writer.print("P3\n{d} {d}\n255\n", .{ self.image_width, self.image_height });

        for (0..self.image_height) |j| {
            std.debug.print("Scanlines remaining: {d}\n", .{self.image_height - j});

            for (0..self.image_width) |i| {
                const pixel_center = pixel00_loc.add(pixel_delta_u.scale(@as(f64, @floatFromInt(i)))).add(pixel_delta_v.scale(@as(f64, @floatFromInt(j))));
                const ray = Ray{ .origin = self.center, .direction = pixel_center.sub(self.center) };

                const pixel_color = self.ray_color(ray, world);
                try pixel_color.printPPM(writer);
            }
        }

        std.debug.print("Done.\n", .{});
    }
};

fn deriveImageHeight(width: u32, aspect_ratio_: AspectRatio) u32 {
    const height = width * aspect_ratio_.y / aspect_ratio_.x;
    return @max(height, 1);
}
