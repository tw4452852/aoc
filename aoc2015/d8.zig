const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d8" {
    const input = @embedFile("input/d8");

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var p1: usize = 0;
    var p2: usize = 0;
    while (lines.next()) |l| {
        p1 += 2;
        p2 += 4;

        var i: usize = 0;
        while (std.mem.indexOfPos(u8, l, i, "\\")) |idx| {
            i = idx + 2;
            if (l[idx + 1] == 'x') {
                p1 += 3;
                p2 += 1;
            } else {
                p1 += 1;
                p2 += 2;
            }
        }
    }

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}
