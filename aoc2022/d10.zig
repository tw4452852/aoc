const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;

test "d10" {
    const input = @embedFile("input/d10");
    var it = std.mem.tokenize(u8, input, "\r\n");

    var cycle: isize = 1;
    var x: isize = 1;
    var p1: isize = 0;
    print("\n", .{});
    while (it.next()) |l| : (cycle += 1) {
        sum(cycle, x, &p1);
        if (l[0] == 'n') {
            continue;
        }

        const d = try fmt.parseInt(isize, l[5..], 10);
        cycle += 1;
        sum(cycle, x, &p1);
        x += d;
    }

    print("part1: {d}\n", .{p1});
}

fn sum(cycle: isize, x: isize, total: *isize) void {
    const cur = @mod(cycle - 1, 40);
    const diff = if (cur > x) cur - x else x - cur;

    if (diff <= 1) print("#", .{}) else print(".", .{});
    if (cur == 39) print("\n", .{});

    switch (cycle) {
        20, 60, 100, 140, 180, 220 => {
            total.* += cycle * x;
        },
        else => {},
    }
}
