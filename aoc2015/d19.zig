const std = @import("std");
const print = std.debug.print;
const fmt = std.fmt;

test "d19" {
    const input = @embedFile("input/d19");
    var lines = std.mem.tokenize(u8, input, "\n\r");

    var rules = std.ArrayList(Replace).init(std.testing.allocator);
    defer rules.deinit();

    var s: []const u8 = undefined;
    while (lines.next()) |l| {
        if (std.mem.indexOfScalar(u8, l, '=')) |i| {
            try rules.append(.{ .from = l[0 .. i - 1], .to = l[i + 3 ..] });
        } else {
            s = l;
        }
    }

    var map = std.StringHashMap(void).init(std.testing.allocator);
    defer {
        var keys = map.keyIterator();
        while (keys.next()) |k| std.testing.allocator.free(k.*);
        map.deinit();
    }
    for (rules.items) |r| {
        var i: usize = 0;
        while (std.mem.indexOfPos(u8, s, i, r.from)) |idx| {
            i = idx + 1;
            const k = try fmt.allocPrint(std.testing.allocator, "{s}{s}{s}", .{ s[0..idx], r.to, s[idx + r.from.len ..] });
            if (!map.contains(k)) {
                try map.put(k, {});
            } else std.testing.allocator.free(k);
        }
    }
    const p1 = map.count();

    std.sort.sort(Replace, rules.items, {}, Replace.lessThan);
    var sl = std.ArrayList(u8).init(std.testing.allocator);
    defer sl.deinit();
    try sl.insertSlice(0, s);
    var p2: usize = 0;
    loop: while (true) {
        for (rules.items) |r| {
            while (std.mem.indexOf(u8, sl.items, r.to)) |i| {
                try sl.replaceRange(i, r.to.len, r.from);
                p2 += 1;
            }
            if (std.mem.eql(u8, sl.items, "e")) break :loop;
        }
    }

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

const Replace = struct {
    from: []const u8,
    to: []const u8,

    fn lessThan(_: void, a: @This(), b: @This()) bool {
        return a.to.len > b.to.len;
    }
};
