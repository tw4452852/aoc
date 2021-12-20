const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

const Count = std.meta.Vector(26, usize);
const Key = struct {
    pair: [2]u8,
    step: usize,
};
const Rules = std.AutoHashMap([2]u8, u8);

test "d14" {
    const input = @embedFile("input/d14");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var rules = Rules.init(std.testing.allocator);
    defer rules.deinit();

    const template = it.next().?;
    while (it.next()) |l| {
        var parts = std.mem.tokenize(u8, l, " ->");
        const k = parts.next().?;
        const v = parts.next().?;
        try rules.put(k[0..2].*, v[0]);
    }

    var cached_count = std.AutoHashMap(Key, Count).init(std.testing.allocator);
    defer cached_count.deinit();

    print("part1 = {}, part2 = {}\n", .{ calcUntil(&cached_count, rules, template, 10), calcUntil(&cached_count, rules, template, 40) });
}

fn calcUntil(cached_count: *std.AutoHashMap(Key, Count), rules: Rules, template: []const u8, step: usize) usize {
    const counts: [26]usize = blk: {
        var counts = std.mem.zeroes(Count);
        var i: usize = 0;
        while (i < template.len - 1) : (i += 1) {
            const key = template[i..][0..2].*;
            counts += count(cached_count, rules, key, step);
        }
        counts[template[i] - 'A'] += 1;
        break :blk counts;
    };

    var min: usize = std.math.maxInt(usize);
    var max: usize = 0;
    for (counts) |c| {
        if (c != 0 and c < min) min = c;
        if (c > max) max = c;
    }

    return max - min;
}

fn count(cached_count: *std.AutoHashMap(Key, Count), rules: Rules, key: [2]u8, step: usize) Count {
    if (step == 0) {
        var counts = std.mem.zeroes(Count);
        counts[key[0] - 'A'] = 1;
        return counts;
    }

    if (cached_count.get(.{ .pair = key, .step = step })) |v| return v;

    const insert = rules.get(key).?;
    const result = count(cached_count, rules, .{ key[0], insert }, step - 1) + count(cached_count, rules, .{ insert, key[1] }, step - 1);

    cached_count.put(.{ .pair = key, .step = step }, result) catch unreachable;
    return result;
}
