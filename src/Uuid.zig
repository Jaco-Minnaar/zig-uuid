const Uuid = @This();

const std = @import("std");

bytes: u128,
str: ?[36]u8 = null,

pub fn new() !Uuid {
    const rand = std.crypto.random;

    const num = rand.int(u128);
    const bytes = num & 0xFFFFFFFFFFFF4FFFBFFFFFFFFFFFFFFF | 0x40008000000000000000;

    return .{ .bytes = bytes };
}

pub fn to_string(s: *Uuid) []const u8 {
    if (s.str) |str| {
        return &str;
    }
    var str: [36]u8 = undefined;
    var bytes = s.bytes;
    for (0..36) |i| {
        const byte = switch (i) {
            12, 17, 22, 27 => '-',
            else => blk: {
                var num: u8 = undefined;
                num = @truncate(bytes & 0xF);
                bytes >>= 4;

                var hex: u8 = undefined;
                if (num < 10) {
                    hex = num + 48;
                } else {
                    hex = num + 87;
                }
                break :blk hex;
            },
        };

        str[35 - i] = byte;
    }

    s.str = str;
    return &(s.str orelse unreachable);
}
