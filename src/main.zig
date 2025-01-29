const std = @import("std");
const Vec3 = @import("./vec3.zig").Vec3;
const RGB = @import("./color.zig").RGB;
const AspectRatio = @import("./camera.zig").AspectRatio;
const Camera = @import("./camera.zig").Camera;
const Point3 = @import("./vec3.zig").Point3;
const Sphere = @import("./sphere.zig").Sphere;
const HittableList = @import("./hittable.zig").HittableList;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer().any();

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    var world = HittableList.init(allocator);
    defer world.deinit();

    var sphere1 = Sphere.new(Point3{ .x = 0, .y = 0, .z = -1 }, 0.5);
    var sphere2 = Sphere.new(Point3{ .x = 0, .y = -100.5, .z = -1 }, 100);

    try world.add(sphere1.hittable());
    try world.add(sphere2.hittable());

    const camera = Camera.init(400, AspectRatio{ .x = 16.0, .y = 9.0 }, rand);

    try camera.renderPPM(world.hittable(), stdout);

    try bw.flush();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
