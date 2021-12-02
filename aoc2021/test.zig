const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d1" {
    const input = @embedFile("input/d1");
    var it = std.mem.tokenize(u8, input, "\n");
    var numbers = std.ArrayList(isize).init(std.testing.allocator);
    defer numbers.deinit();
    var prev = try fmt.parseInt(isize, it.next().?, 10);
    try numbers.append(prev);

    var count: usize = 0;
    while (it.next()) |s| {
        const cur = try fmt.parseInt(isize, s, 10);
        if (cur > prev) {
            count += 1;
        }
        prev = cur;
        try numbers.append(prev);
    }
    print("p1 = {}", .{count});

    var i: usize = 0;
    count = 0;
    while (i < numbers.items.len - 3) : (i += 1) {
        if (numbers.items[i + 3] > numbers.items[i]) {
            count += 1;
        }
    }
    print(", p2 = {}", .{count});
}

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
    print("p1 = {}, p2 = {}", .{ aim * horizon, depth * horizon });
}
