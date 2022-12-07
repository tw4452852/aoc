const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;

test "d7" {
    const input = @embedFile("input/d7");
    var it = std.mem.tokenize(u8, input, "\r\n");

    var ds = std.ArrayList(usize).init(std.testing.allocator);
    defer ds.deinit();

    _ = it.next();
    _ = try traverse(&it, &ds);

    var p1: usize = 0;
    var p2: usize = 70000000;
    const total = ds.items[ds.items.len - 1];
    const need = 30000000 - (70000000 - total);
    for (ds.items) |n| {
        if (n <= 100000) p1 += n;
        if (n >= need and n < p2) p2 = n;
    }

    print("part1: {d}, part2: {d}\n", .{ p1, p2 });
}

fn traverse(it: *std.mem.TokenIterator(u8), ds: *std.ArrayList(usize)) !usize {
    var v: usize = 0;
    const ls = it.next().?;
    assert(std.mem.eql(u8, ls, "$ ls"));

    while (it.next()) |l| {
        if (l[0] == '$') {
            if (l[5] == '.') break; // cd ..
            v += try traverse(it, ds); // cd xx
        } else if (l[0] == 'd') {
            // dir xx
            continue;
        } else {
            // size file
            var parts = std.mem.split(u8, l, " ");
            v += try fmt.parseInt(usize, parts.next().?, 10);
        }
    }
    try ds.append(v);
    return v;
}
