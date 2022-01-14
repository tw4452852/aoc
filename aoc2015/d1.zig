const std = @import("std");
const print = std.debug.print;
const fmt = std.fmt;

test "d1" {
    const input = @embedFile("input/d1");
    var it = std.mem.tokenize(u8, input, "\r\n");

    const l = it.next().?;
    var p1: isize = 0;
    var p2: usize = 0;
    for (l) |c, i| {
        switch (c) {
            '(' => p1 += 1,
            ')' => {
                p1 -= 1;
                if (p1 == -1 and p2 == 0) p2 = i + 1;
            },
            else => unreachable,
        }
    }

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}
