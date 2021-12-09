const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d9" {
    const input = @embedFile("input/d9");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var ps = std.ArrayList(u8).init(std.testing.allocator);
    defer ps.deinit();

    var width: usize = 0;
    while (it.next()) |line| {
        if (width == 0) width = line.len;
        for (line) |n| {
            try ps.append(n - '0');
        }
    }
    const height = ps.items.len / width;

    var part1: usize = 0;
    var stack = std.ArrayList(usize).init(std.testing.allocator);
    defer stack.deinit();
    var seen = std.ArrayList(usize).init(std.testing.allocator);
    defer seen.deinit();
    var max3 = [_]usize{0} ** 3;
    for (ps.items) |p, i| {
        const x = i % width;
        const y = i / width;

        if (x > 0 and p >= ps.items[i - 1]) continue;
        if (x < width - 1 and p >= ps.items[i + 1]) continue;
        if (y > 0 and p >= ps.items[i - width]) continue;
        if (y < height - 1 and p >= ps.items[i + width]) continue;

        part1 += p + 1;

        std.debug.assert(stack.items.len == 0);
        try stack.append(i);
        seen.clearRetainingCapacity();
        const bs = try basinSize(&stack, &seen, ps.items, width, height);

        if (bs > max3[0] and bs <= max3[1]) {
            max3[0] = bs;
        } else if (bs > max3[1] and bs <= max3[2]) {
            max3[0] = max3[1];
            max3[1] = bs;
        } else if (bs > max3[2]) {
            max3[0] = max3[1];
            max3[1] = max3[2];
            max3[2] = bs;
        }
    }

    print("part1 = {}, part2 = {}\n", .{ part1, max3[0] * max3[1] * max3[2] });
}

fn basinSize(stack: *std.ArrayList(usize), seen: *std.ArrayList(usize), ps: []const u8, width: usize, height: usize) anyerror!usize {
    const i = stack.pop();
    try seen.append(i);

    const x = i % width;
    const y = i / width;

    var sum: usize = 1;
    if (x > 0 and std.mem.indexOfScalar(usize, seen.items, i - 1) == null and ps[i - 1] != 9) {
        try stack.append(i - 1);
        sum += try basinSize(stack, seen, ps, width, height);
    }

    if (x < width - 1 and std.mem.indexOfScalar(usize, seen.items, i + 1) == null and ps[i + 1] != 9) {
        try stack.append(i + 1);
        sum += try basinSize(stack, seen, ps, width, height);
    }

    if (y > 0 and std.mem.indexOfScalar(usize, seen.items, i - width) == null and ps[i - width] != 9) {
        try stack.append(i - width);
        sum += try basinSize(stack, seen, ps, width, height);
    }

    if (y < height - 1 and std.mem.indexOfScalar(usize, seen.items, i + width) == null and ps[i + width] != 9) {
        try stack.append(i + width);
        sum += try basinSize(stack, seen, ps, width, height);
    }

    return sum;
}
