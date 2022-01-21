const std = @import("std");
const print = std.debug.print;

test "d18" {
    const input = @embedFile("input/d18");
    var lines = std.mem.tokenize(u8, input, "\r\n");

    var w: usize = 0;
    var h: usize = 0;
    var map = std.AutoHashMap(Pos, void).init(std.testing.allocator);
    defer map.deinit();
    while (lines.next()) |l| {
        for (l) |c, i| if (c == '#') try map.put(.{ .x = i, .y = h }, {});

        w = l.len;
        h += 1;
    }

    var map2 = try map.clone();
    defer map2.deinit();
    try map2.put(.{ .x = 0, .y = 0 }, {});
    try map2.put(.{ .x = w - 1, .y = 0 }, {});
    try map2.put(.{ .x = 0, .y = h - 1 }, {});
    try map2.put(.{ .x = w - 1, .y = h - 1 }, {});

    var step: usize = 0;
    var actions = std.ArrayList(Pos).init(std.testing.allocator);
    defer actions.deinit();
    var x: usize = undefined;
    var y: usize = undefined;
    while (step < 100) : (step += 1) {
        y = 0;
        while (y < h) : (y += 1) {
            x = 0;
            while (x < w) : (x += 1) {
                const p: Pos = .{ .x = x, .y = y };
                const nei = ons(&map, p);
                const on = map.contains(p);
                if (on and nei != 2 and nei != 3) try actions.append(p);
                if (!on and nei == 3) try actions.append(p);
            }
        }

        while (actions.popOrNull()) |p| {
            if (map.fetchRemove(p) == null) {
                try map.put(p, {});
            }
        }
    }
    const p1 = map.count();

    step = 0;
    while (step < 100) : (step += 1) {
        y = 0;
        while (y < h) : (y += 1) {
            x = 0;
            while (x < w) : (x += 1) {
                if ((x == 0 and (y == 0 or y == h - 1)) or
                    (x == w - 1 and (y == 0 or y == h - 1))) continue;
                const p: Pos = .{ .x = x, .y = y };
                const nei = ons(&map2, p);
                const on = map2.contains(p);
                if (on and nei != 2 and nei != 3) try actions.append(p);
                if (!on and nei == 3) try actions.append(p);
            }
        }

        while (actions.popOrNull()) |p| {
            if (map2.fetchRemove(p) == null) {
                try map2.put(p, {});
            }
        }
    }
    const p2 = map2.count();

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

fn ons(map: *const std.AutoHashMap(Pos, void), p: Pos) usize {
    var sum: usize = 0;
    if (map.contains(.{ .x = p.x -% 1, .y = p.y -% 1 })) sum += 1;
    if (map.contains(.{ .x = p.x, .y = p.y -% 1 })) sum += 1;
    if (map.contains(.{ .x = p.x + 1, .y = p.y -% 1 })) sum += 1;
    if (map.contains(.{ .x = p.x -% 1, .y = p.y })) sum += 1;
    if (map.contains(.{ .x = p.x + 1, .y = p.y })) sum += 1;
    if (map.contains(.{ .x = p.x -% 1, .y = p.y + 1 })) sum += 1;
    if (map.contains(.{ .x = p.x, .y = p.y + 1 })) sum += 1;
    if (map.contains(.{ .x = p.x + 1, .y = p.y + 1 })) sum += 1;
    return sum;
}

const Pos = struct {
    x: usize,
    y: usize,
};
