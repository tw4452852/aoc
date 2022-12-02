const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d1" {
    const input = @embedFile("input/d1");
    var it = std.mem.split(u8, input, "\n");
    var cals = std.ArrayList(i64).init(std.testing.allocator);
    defer cals.deinit();

    var cal: i64 = 0;
    var max: [3]i64 = .{ 0, 0, 0 };
    while (it.next()) |l| {
        if (l.len == 0) {
            if (cal > max[0]) {
                max[2] = max[1];
                max[1] = max[0];
                max[0] = cal;
            } else if (cal > max[1]) {
                max[2] = max[1];
                max[1] = cal;
            } else if (cal > max[2]) {
                max[2] = cal;
            }

            try cals.append(cal);
            cal = 0;
            continue;
        }

        cal += try fmt.parseInt(i64, l, 10);
    }

    print("part1: {d}, part2: {d}\n", .{ max[0], max[0] + max[1] + max[2] });
}
