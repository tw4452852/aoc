const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d6" {
    const input = @embedFile("input/d6");
    var it = std.mem.tokenize(u8, input, ",\r\n");

    var counts = [_]u64{0} ** 9;

    while (it.next()) |s| {
        const n = try fmt.parseInt(u8, s, 10);
        counts[n] += 1;
    }

    var day: usize = 0;
    while (day < 80) : (day += 1) {
        const age0 = counts[0];
        counts[0] = counts[1];
        counts[1] = counts[2];
        counts[2] = counts[3];
        counts[3] = counts[4];
        counts[4] = counts[5];
        counts[5] = counts[6];
        counts[6] = counts[7] + age0;
        counts[7] = counts[8];
        counts[8] = age0;
    }

    var total: u64 = 0;
    for (counts) |count| {
        total += count;
    }

    print("p1 = {}", .{total});

    while (day < 256) : (day += 1) {
        const age0 = counts[0];
        counts[0] = counts[1];
        counts[1] = counts[2];
        counts[2] = counts[3];
        counts[3] = counts[4];
        counts[4] = counts[5];
        counts[5] = counts[6];
        counts[6] = counts[7] + age0;
        counts[7] = counts[8];
        counts[8] = age0;
    }

    total = 0;
    for (counts) |count| {
        total += count;
    }

    print(", p2 = {}\n", .{total});
}
