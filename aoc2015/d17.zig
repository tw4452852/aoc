const std = @import("std");
const print = std.debug.print;
const fmt = std.fmt;

test "d17" {
    const input = @embedFile("input/d17");
    var lines = std.mem.tokenize(u8, input, "\r\n");

    var containers = std.ArrayList(usize).init(std.testing.allocator);
    defer containers.deinit();

    while (lines.next()) |l| {
        const container = try fmt.parseInt(usize, l, 10);
        try containers.append(container);
    }
    std.sort.sort(usize, containers.items, {}, comptime std.sort.desc(usize));

    var results = std.AutoArrayHashMap(usize, usize).init(std.testing.allocator);
    defer results.deinit();
    try count(containers.items, 150, 0, &results);

    const p1 = blk: {
        var sum: usize = 0;
        for (results.values()) |v| {
            sum += v;
        }
        break :blk sum;
    };
    const p2 = blk: {
        const min = std.sort.min(usize, results.keys(), {}, comptime std.sort.asc(usize)).?;
        break :blk results.get(min).?;
    };

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

fn count(candidates: []const usize, sum: usize, step: usize, results: *std.AutoArrayHashMap(usize, usize)) anyerror!void {
    for (candidates) |c, i| {
        if (c > sum) continue;
        if (c == sum) {
            const gop = try results.getOrPut(step);
            if (gop.found_existing) {
                gop.value_ptr.* += 1;
            } else {
                gop.value_ptr.* = 1;
            }
        } else {
            if (i < candidates.len - 1) try count(candidates[i + 1 ..], sum - c, step + 1, results);
        }
    }
}
