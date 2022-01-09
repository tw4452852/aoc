const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d20" {
    const input = @embedFile("input/d20");
    var it = std.mem.tokenize(u8, input, "\n\r");

    const first_line = it.next().?;
    std.debug.assert(first_line.len == 512);
    var algr = try std.DynamicBitSet.initEmpty(std.testing.allocator, first_line.len);
    defer algr.deinit();

    const need_toggle = first_line[0] == '#';
    var default = need_toggle;
    for (first_line) |c, i| {
        if (c == '#') algr.set(i);
    }

    var map1 = std.ArrayList(Pos).init(std.testing.allocator);
    defer map1.deinit();
    var map2 = std.ArrayList(Pos).init(std.testing.allocator);
    defer map2.deinit();

    var h: usize = 0;
    var w: usize = 0;
    while (it.next()) |l| {
        for (l) |c, x| {
            if (c == '#') try map1.append(.{ .x = x, .y = h });
        }
        w = l.len;
        h += 1;
    }
    //print("w = {}, h = {}, {}\n", .{ w, h, map1.items.len });

    var src: *std.ArrayList(Pos) = &map1;
    var dst: *std.ArrayList(Pos) = &map2;
    var count: usize = 0;
    while (count < 2) : (count += 1) {
        std.debug.assert(src.items.len > 0);
        std.debug.assert(dst.items.len == 0);

        w += 2;
        h += 2;
        if (need_toggle) default = !default;
        try expand(algr, src, dst, w, h, default);

        const tmp = src;
        src = dst;
        dst = tmp;
    }
    const p1 = src.items.len;

    while (count < 50) : (count += 1) {
        std.debug.assert(src.items.len > 0);
        std.debug.assert(dst.items.len == 0);

        w += 2;
        h += 2;
        if (need_toggle) default = !default;
        try expand(algr, src, dst, w, h, default);

        const tmp = src;
        src = dst;
        dst = tmp;
    }
    const p2 = src.items.len;

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

fn expand(algr: std.DynamicBitSet, src: *std.ArrayList(Pos), dst: *std.ArrayList(Pos), w: usize, h: usize, default: bool) !void {
    var x: usize = 0;
    var y: usize = 0;

    var map = std.AutoArrayHashMap(Pos, void).init(std.testing.allocator);
    defer map.deinit();
    for (src.items) |p| {
        try map.put(.{ .x = p.x + 1, .y = p.y + 1 }, {});
    }
    if (default) {
        while (y < 1) : (y += 1) {
            x = 0;
            while (x < w) : (x += 1) {
                try map.put(.{ .x = x, .y = y }, {});
            }
        }
        y = h - 1;
        while (y < h) : (y += 1) {
            x = 0;
            while (x < w) : (x += 1) {
                try map.put(.{ .x = x, .y = y }, {});
            }
        }
        x = 0;
        while (x < 1) : (x += 1) {
            y = 0;
            while (y < h) : (y += 1) {
                try map.put(.{ .x = x, .y = y }, {});
            }
        }
        x = w - 1;
        while (x < w) : (x += 1) {
            y = 0;
            while (y < h) : (y += 1) {
                try map.put(.{ .x = x, .y = y }, {});
            }
        }
    }

    y = 0;
    while (y < h) : (y += 1) {
        x = 0;
        while (x < w) : (x += 1) {
            var bits = std.StaticBitSet(9).initEmpty();
            bits.setValue(8, contains(&map, .{ .x = x -% 1, .y = y -% 1 }, w, h, default));
            bits.setValue(7, contains(&map, .{ .x = x, .y = y -% 1 }, w, h, default));
            bits.setValue(6, contains(&map, .{ .x = x + 1, .y = y -% 1 }, w, h, default));
            bits.setValue(5, contains(&map, .{ .x = x -% 1, .y = y }, w, h, default));
            bits.setValue(4, contains(&map, .{ .x = x, .y = y }, w, h, default));
            bits.setValue(3, contains(&map, .{ .x = x + 1, .y = y }, w, h, default));
            bits.setValue(2, contains(&map, .{ .x = x -% 1, .y = y + 1 }, w, h, default));
            bits.setValue(1, contains(&map, .{ .x = x, .y = y + 1 }, w, h, default));
            bits.setValue(0, contains(&map, .{ .x = x + 1, .y = y + 1 }, w, h, default));

            if (algr.isSet(bits.mask)) try dst.append(.{ .x = x, .y = y });
        }
    }

    src.clearRetainingCapacity();
}

fn contains(map: *const std.AutoArrayHashMap(Pos, void), p: Pos, w: usize, h: usize, default: bool) bool {
    if (p.x >= w or p.y >= h) return default;

    return map.contains(p);
}

const Pos = struct {
    x: usize,
    y: usize,
};
