const std = @import("std");
const print = std.debug.print;
const fmt = std.fmt;

test "d2" {
    const input = @embedFile("input/d2");
    var it = std.mem.tokenize(u8, input, "\r\n");

    var p1: usize = 0;
    var p2: usize = 0;
    while (it.next()) |l| {
        var parts = std.mem.tokenize(u8, l, "x");
        var lines: [3]usize = undefined;
        lines[0] = try fmt.parseInt(usize, parts.next().?, 10);
        lines[1] = try fmt.parseInt(usize, parts.next().?, 10);
        lines[2] = try fmt.parseInt(usize, parts.next().?, 10);

        std.sort.sort(usize, &lines, {}, comptime std.sort.asc(usize));

        var paper: usize = 0;

        for (lines[0..2]) |line, i| {
            if (i + 1 < 3) {
                const area = line * lines[i + 1];
                paper += 2 * area;
                if (i == 0) paper += area;
            }
            if (i + 2 < 3) {
                const area = line * lines[i + 2];
                paper += 2 * area;
            }
        }
        const ribbon = lines[0] * lines[1] * lines[2] + 2 * (lines[0] + lines[1]);

        p1 += paper;
        p2 += ribbon;
    }

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}
