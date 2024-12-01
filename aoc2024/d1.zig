const std = @import("std");

test {
    const sample_input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;
    const input = if (false) sample_input else @embedFile("d1_input.txt");
    const gpa = std.testing.allocator;
    var left = std.ArrayList(isize).init(gpa);
    var right = std.ArrayList(isize).init(gpa);
    defer {
        left.deinit();
        right.deinit();
    }

    var it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (it.next()) |line| {
        const space = std.mem.indexOfScalar(u8, line, ' ').?;
        try left.append(try std.fmt.parseUnsigned(isize, line[0..space], 10));
        try right.append(try std.fmt.parseUnsigned(isize, line[space + 3 ..], 10));
    }

    std.mem.sort(isize, left.items, {}, std.sort.asc(isize));
    std.mem.sort(isize, right.items, {}, std.sort.asc(isize));

    var sum: usize = 0;
    for (0..left.items.len) |i| {
        sum += @abs(left.items[i] - right.items[i]);
    }
    std.debug.print("part1: {}\n", .{sum});

    var seen = std.AutoHashMap(isize, isize).init(gpa);
    defer seen.deinit();
    var similarity: isize = 0;
    for (left.items) |l| {
        if (seen.get(l)) |count| {
            similarity += l * count;
        } else {
            var count: isize = 0;
            for (right.items) |r| {
                if (r == l) {
                    count += 1;
                } else if (r > l) {
                    break;
                }
            }
            similarity += l * count;
            try seen.putNoClobber(l, count);
        }
    }
    std.debug.print("part2: {}\n", .{similarity});
}
