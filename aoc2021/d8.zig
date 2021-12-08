const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d8" {
    const input = @embedFile("input/d8");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var count: usize = 0;
    var sum: u32 = 0;
    while (it.next()) |line| {
        var parts = std.mem.tokenize(u8, line, " |");

        var four: u7 = undefined;
        var seven: u7 = undefined;
        var i: usize = 0;
        while (i < 10) : (i += 1) {
            const mask = getMask(parts.next().?);
            if (@popCount(u7, mask) == 4) four = mask;
            if (@popCount(u7, mask) == 3) seven = mask;
        }

        var v: u32 = 0;
        while (parts.next()) |num| {
            const mask = getMask(num);

            const digital: u32 = blk: {
                switch (@popCount(u7, mask)) {
                    2 => {
                        count += 1;
                        break :blk 1;
                    },
                    4 => {
                        count += 1;
                        break :blk 4;
                    },
                    3 => {
                        count += 1;
                        break :blk 7;
                    },
                    7 => {
                        count += 1;
                        break :blk 8;
                    },
                    5 => {
                        if (mask & seven == seven) {
                            break :blk 3;
                        } else if (@popCount(u7, mask & four) == 2) {
                            break :blk 2;
                        } else {
                            break :blk 5;
                        }
                    },
                    6 => {
                        if (mask & seven != seven) {
                            break :blk 6;
                        } else if (mask & four == four) {
                            break :blk 9;
                        } else {
                            break :blk 0;
                        }
                    },
                    else => unreachable,
                }
            };

            v *= 10;
            v += digital;
        }
        sum += v;
    }

    print("p1 = {}, p2 = {}\n", .{ count, sum });
}

fn getMask(s: []const u8) u7 {
    var mask = std.StaticBitSet(7).initEmpty();

    for (s) |c| {
        mask.set(c - 'a');
    }

    return mask.mask;
}
