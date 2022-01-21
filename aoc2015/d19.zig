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

    var dup = std.ArrayList(Dup).init(std.testing.allocator);
    defer dup.deinit();
    for (rules.items) |a, ai| {
        if (a.to.len > a.from.len and std.mem.startsWith(u8, a.to, a.from)) {
            const suffix = a.to[a.from.len..];
            for (rules.items) |b, bi| {
                if (bi != ai and b.to.len > b.from.len and
                    std.mem.endsWith(u8, b.to, b.from))
                {
                    const prefix = b.to[0 .. b.to.len - b.from.len];
                    if (std.mem.eql(u8, suffix, prefix)) {
                        try dup.append(.{ .start = a.from, .middle = suffix, .end = b.from });
                    }
                }
            }
        }
    }

    var memo = std.StringHashMap(usize).init(std.testing.allocator);
    defer memo.deinit();

    var p1: usize = 0;
    for (rules.items) |r| {
        if (memo.get(r.from)) |n| {
            p1 += n;
            continue;
        }
        const n = std.mem.count(u8, s, r.from);
        p1 += n;
        try memo.put(r.from, n);
    }
    for (dup.items) |d| {
        const n = findAllDup(s, d);
        p1 -= n;
    }
    print("part1 = {}\n", .{p1});
}

fn findAllDup(s: []const u8, d: Dup) usize {
    var ret: usize = 0;
    var start_i: usize = 0;
    var end_i: usize = 0;

    while (std.mem.indexOfPos(u8, s, start_i, d.start)) |i| {
        start_i = i + 1;
        end_i = i + 1;
        while (std.mem.indexOfPos(u8, s, end_i, d.end)) |j| {
            end_i = j + d.end.len;
            if (i + d.start.len >= j) {
                ret += 1;
                continue;
            }
            const mid = s[i + d.start.len .. j];
            if (mid.len % d.middle.len != 0) continue;
            const n = mid.len / d.middle.len;
            if (std.mem.containsAtLeast(u8, mid, n, d.middle)) {
                ret += 1;
            }
        }
    }

    return ret;
}

const Replace = struct {
    from: []const u8,
    to: []const u8,
};

const Dup = struct {
    start: []const u8,
    middle: []const u8,
    end: []const u8,
};
