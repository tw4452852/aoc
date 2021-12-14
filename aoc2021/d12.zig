const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d12" {
    const input = @embedFile("input/d12");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var map = std.AutoHashMap(u16, std.ArrayList(u16)).init(std.testing.allocator);
    defer {
        var vit = map.valueIterator();
        while (vit.next()) |v| {
            v.deinit();
        }
        map.deinit();
    }

    while (it.next()) |line| {
        var parts = std.mem.tokenize(u8, line, "-");
        const p1 = toNumber(parts.next().?);
        const p2 = toNumber(parts.next().?);

        var entry = try map.getOrPut(p1);
        if (entry.found_existing) {
            try entry.value_ptr.append(p2);
        } else {
            var l = std.ArrayList(u16).init(std.testing.allocator);
            try l.append(p2);
            entry.value_ptr.* = l;
        }

        entry = try map.getOrPut(p2);
        if (entry.found_existing) {
            try entry.value_ptr.append(p1);
        } else {
            var l = std.ArrayList(u16).init(std.testing.allocator);
            try l.append(p1);
            entry.value_ptr.* = l;
        }
    }

    var partial = std.ArrayList(u16).init(std.testing.allocator);
    try partial.append(0);
    defer partial.deinit();

    const p1 = part1(&partial, map);

    // we use partial[0] to indicate whether we encountered a double lower point
    // 0: not yet, 1: yes.
    std.debug.assert(partial.items.len == 0);
    try partial.appendSlice(&[_]u16{ 0, 0 });
    const p2 = part2(&partial, map);

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

fn toNumber(s: []const u8) u16 {
    return switch (s.len) {
        3 => 1, // 'end'
        5 => 0, // 'start'
        2 => (@as(u16, s[0]) << 8) + s[1], // anything else
        else => unreachable,
    };
}

fn part1(partial: *std.ArrayList(u16), map: std.AutoHashMap(u16, std.ArrayList(u16))) anyerror!usize {
    var sum: usize = 0;
    const now = partial.items[partial.items.len - 1];
    if (now != 1) {
        for (map.get(now).?.items) |p| {
            if (std.mem.indexOfScalar(u16, partial.items, p) == null or (toNumber("AA") <= p and p <= toNumber("ZZ"))) {
                try partial.append(p);
                sum += try part1(partial, map);
            }
        }
    } else {
        //print("found one {X}\n", .{partial.items});
        sum = 1;
    }

    _ = partial.pop();
    return sum;
}

fn part2(partial: *std.ArrayList(u16), map: std.AutoHashMap(u16, std.ArrayList(u16))) anyerror!usize {
    var sum: usize = 0;
    const now = partial.items[partial.items.len - 1];
    if (now != 1) {
        for (map.get(now).?.items) |p| {
            if (std.mem.indexOfScalar(u16, partial.items, p) == null or (toNumber("AA") <= p and p <= toNumber("ZZ"))) {
                try partial.append(p);
                sum += try part2(partial, map);
            } else if (partial.items[0] == 0 and (toNumber("aa") <= p and p <= toNumber("zz"))) {
                partial.items[0] = p;
                try partial.append(p);
                sum += try part2(partial, map);
            }
        }
    } else {
        //print("found one {X}\n", .{partial.items[1..]});
        sum = 1;
    }

    const p = partial.pop();
    if (p == partial.items[0]) partial.items[0] = 0;
    return sum;
}
