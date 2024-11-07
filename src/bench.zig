const std = @import("std");
const time = std.time;
const Instant = time.Instant;
const Timer = time.Timer;
const print = std.debug.print;
const Uuid = @import("Uuid.zig");

pub fn main() !void {
    const iterations = 10_000_000;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var uuids = try allocator.alloc(Uuid, iterations);

    const start = try Instant.now();

    for (0..iterations) |i| {
        uuids[i] = try Uuid.new();
    }

    const end = try Instant.now();
    const elapsed_ns: f64 = @floatFromInt(end.since(start));

    const ns_per = elapsed_ns / iterations;
    const us_per = ns_per / time.ns_per_us;

    print("{d:.3}us per iteration.\n", .{us_per});

    const file = try std.fs.cwd().createFile("foo.txt", .{});
    defer file.close();
    var bw = std.io.bufferedWriter(file.writer());
    const writer = bw.writer();

    for (uuids) |*uuid| {
        try writer.print("{s}\n", .{uuid.to_string()});
    }

    try bw.flush();
}
