const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d2" {
    const input = @embedFile("input/d2");
    var it = std.mem.tokenize(u8, input, "\n");

    var depth: isize = 0;
    var horizon: isize = 0;
    var aim: isize = 0;

    while (it.next()) |s| {
        var parts = std.mem.tokenize(u8, s, " ");
        const direction = parts.next().?;
        const count = try fmt.parseInt(isize, parts.next().?, 10);

        switch (direction[0]) {
            'f' => {
                horizon += count;
                depth += aim * count;
            },
            'u' => aim -= count,
            'd' => aim += count,
            else => unreachable,
        }
    }
    print("p1 = {}, p2 = {}\n", .{ aim * horizon, depth * horizon });
}
