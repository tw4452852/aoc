const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d7" {
    const input = @embedFile("input/d7");
    var lines = std.mem.tokenize(u8, input, "\r\n");

    var map = std.StringHashMap([]const u8).init(std.testing.allocator);
    defer map.deinit();
    var cache = std.StringHashMap(u16).init(std.testing.allocator);
    defer cache.deinit();

    while (lines.next()) |l| {
        const idx = std.mem.indexOf(u8, l, "->").?;
        const v = l[0..idx];
        const k = l[idx + 3 ..];
        try map.put(k, v);
    }

    const p1 = emulate(&map, map.get("a").?, &cache);

    cache.clearRetainingCapacity();
    try cache.put("b", p1);
    const p2 = emulate(&map, map.get("a").?, &cache);

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

fn emulate(map: *const std.StringHashMap([]const u8), s: []const u8, cache: *std.StringHashMap(u16)) u16 {
    var parts = std.mem.tokenize(u8, s, " ");
    const p1 = parts.next();
    const op = parts.next();
    const p2 = parts.next();

    if (op == null and p2 == null) {
        return value(map, p1.?, cache);
    }

    if (p2 == null) {
        std.debug.assert(std.mem.eql(u8, p1.?, "NOT"));
        return ~value(map, op.?, cache);
    }

    return switch (op.?[0]) {
        'A' => value(map, p1.?, cache) & value(map, p2.?, cache),
        'O' => value(map, p1.?, cache) | value(map, p2.?, cache),
        'L' => value(map, p1.?, cache) <<| value(map, p2.?, cache),
        'R' => value(map, p1.?, cache) >> @intCast(u4, value(map, p2.?, cache)),
        else => unreachable,
    };
}

fn value(map: *const std.StringHashMap([]const u8), s: []const u8, cache: *std.StringHashMap(u16)) u16 {
    if (cache.get(s)) |n| {
        return n;
    } else {
        if (fmt.parseInt(u16, s, 10)) |n| {
            return n;
        } else |_| {
            const n = emulate(map, map.get(s).?, cache);
            cache.put(s, n) catch unreachable;
            return n;
        }
    }
}
