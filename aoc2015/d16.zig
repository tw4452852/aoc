const std = @import("std");
const print = std.debug.print;
const fmt = std.fmt;

test "d16" {
    const input = @embedFile("input/d16");
    var lines = std.mem.tokenize(u8, input, "\r\n");

    const map = std.ComptimeStringMap(usize, .{
        .{ "children", 3 },
        .{ "cats", 7 },
        .{ "samoyeds", 2 },
        .{ "pomeranians", 3 },
        .{ "akitas", 0 },
        .{ "vizslas", 0 },
        .{ "goldfish", 5 },
        .{ "trees", 3 },
        .{ "cars", 2 },
        .{ "perfumes", 1 },
    });

    var p1: usize = 0;
    var p2: usize = 0;
    while (lines.next()) |l| {
        var parts = std.mem.tokenize(u8, l, " ,:");
        _ = parts.next();
        const num = try fmt.parseInt(usize, parts.next().?, 10);
        var valid1 = true;
        var valid2 = true;
        for (" " ** 3) |_| {
            const k = parts.next().?;
            const v = try fmt.parseInt(usize, parts.next().?, 10);
            const known = map.get(k).?;
            if (known != v) valid1 = false;
            if (std.mem.eql(u8, k, "trees") or std.mem.eql(u8, k, "cats")) {
                if (v <= known) valid2 = false;
            } else if (std.mem.eql(u8, k, "pomeranians") or std.mem.eql(u8, k, "goldfish")) {
                if (v >= known) valid2 = false;
            } else if (v != known) valid2 = false;
        }
        if (valid1 and p1 == 0) p1 = num;
        if (valid2 and p2 == 0) p2 = num;
    }

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}
