const std = @import("std");
const print = std.debug.print;
const fmt = std.fmt;

test "d3" {
    const input = @embedFile("input/d3");
    var it = std.mem.tokenize(u8, input, "\r\n");

    var map1 = std.AutoHashMap(Pos, void).init(std.testing.allocator);
    defer map1.deinit();
    var map2 = std.AutoHashMap(Pos, void).init(std.testing.allocator);
    defer map2.deinit();

    var pos: Pos = .{ .x = 0, .y = 0 };
    var p1 = pos;
    var p2 = pos;
    try map1.put(pos, {});
    try map2.put(pos, {});

    for (it.next().?) |c, i| {
        var p1_p = &pos;
        var p2_p = &p1;
        if (i % 2 == 1) p2_p = &p2;

        switch (c) {
            '>' => {
                p1_p.x += 1;
                p2_p.x += 1;
            },
            '<' => {
                p1_p.x -= 1;
                p2_p.x -= 1;
            },
            'v' => {
                p1_p.y -= 1;
                p2_p.y -= 1;
            },
            '^' => {
                p1_p.y += 1;
                p2_p.y += 1;
            },
            else => unreachable,
        }
        try map1.put(p1_p.*, {});
        try map2.put(p2_p.*, {});
    }

    print("part1 = {}, part2 = {}\n", .{ map1.count(), map2.count() });
}

const Pos = struct {
    x: isize,
    y: isize,
};
