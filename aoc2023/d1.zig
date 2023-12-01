const std = @import("std");
const print = std.debug.print;

test "d1" {
    const input = @embedFile("input/d1.txt");
    var it = std.mem.tokenize(u8, input, "\r\n");

    var part1: usize = 0;
    while (it.next()) |l| {
        const first = for (l) |c| {
            if ('0' <= c and c <= '9') break c - '0';
        } else unreachable;

        const last = for (0..l.len) |i| {
            const c = l[l.len - 1 - i];
            if ('0' <= c and c <= '9') break c - '0';
        } else unreachable;

        part1 += first * 10 + last;
    }
    print("part1: {}\n", .{part1});

    const m = std.ComptimeStringMap(usize, .{
        .{ "one", 1 },
        .{ "two", 2 },
        .{ "three", 3 },
        .{ "four", 4 },
        .{ "five", 5 },
        .{ "six", 6 },
        .{ "seven", 7 },
        .{ "eight", 8 },
        .{ "nine", 9 },
    });
    it.reset();
    var part2: usize = 0;
    while (it.next()) |l| {
        const first = for (l, 0..l.len) |c, i| {
            if ('0' <= c and c <= '9') break c - '0';
            if (i >= 2) {
                if (m.get(l[i - 2 .. i + 1])) |v| break v;
            }
            if (i >= 3) {
                if (m.get(l[i - 3 .. i + 1])) |v| break v;
            }
            if (i >= 4) {
                if (m.get(l[i - 4 .. i + 1])) |v| break v;
            }
        } else unreachable;

        const last = for (0..l.len) |i| {
            const idx = l.len - 1 - i;
            const c = l[idx];
            if ('0' <= c and c <= '9') break c - '0';
            if (i >= 2) {
                if (m.get(l[idx .. idx + 3])) |v| break v;
            }
            if (i >= 3) {
                if (m.get(l[idx .. idx + 4])) |v| break v;
            }
            if (i >= 4) {
                if (m.get(l[idx .. idx + 5])) |v| break v;
            }
        } else unreachable;

        part2 += first * 10 + last;
    }
    print("part2: {}\n", .{part2});
}
