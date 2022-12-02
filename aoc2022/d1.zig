const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d2" {
    const input = @embedFile("input/d2");
    var it = std.mem.tokenize(u8, input, "\r\n");
    var cals = std.ArrayList(i64).init(std.testing.allocator);
    defer cals.deinit();

    var p1: i64 = 0;
    var p2: i64 = 0;
    while (it.next()) |l| {
        std.debug.assert(l.len == 3);
        p1 += outcome(l[0], l[2], false);
        p2 += outcome(l[0], l[2], true);
    }

    print("part1: {d}, part2: {d}\n", .{ p1, p2 });
}

fn outcome(opponent: u8, you: u8, is_score: bool) i64 {
    const opp: i64 = switch (opponent) {
        'A' => 1,
        'B' => 2,
        'C' => 3,
        else => unreachable,
    };

    const me: i64 = if (!is_score) switch (you) {
        'X' => 1,
        'Y' => 2,
        'Z' => 3,
        else => unreachable,
    } else switch (you) {
        'X' => if (opp - 1 == 0) 3 else opp - 1,
        'Y' => opp,
        'Z' => if (opp + 1 > 3) 1 else opp + 1,
        else => unreachable,
    };

    const score: i64 = blk: {
        const diff = me - opp;
        break :blk switch (diff) {
            -2, 1 => 6,
            2, -1 => 0,
            0 => 3,
            else => unreachable,
        };
    };

    return me + score;
}
