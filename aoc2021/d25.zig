const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;

test "d25" {
    const input = @embedFile("input/d25");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var w: usize = undefined;
    var h: usize = 0;
    var map = std.AutoHashMap(Pos, Facing).init(std.testing.allocator);
    defer map.deinit();

    while (it.next()) |l| {
        w = l.len;

        for (l) |c, x| {
            switch (c) {
                'v' => try map.put(.{ .x = x, .y = h }, .south),
                '>' => try map.put(.{ .x = x, .y = h }, .east),
                '.' => {},
                else => unreachable,
            }
        }

        h += 1;
    }
    //dump(&map, w, h);

    var steps: usize = 0;
    while (true) : (steps += 1) {
        const east = try moveEast(&map, w, h);
        const south = try moveSouth(&map, w, h);
        //print("after step{}:\n", .{steps + 1});
        //dump(&map, w, h);

        if (!east and !south) break;
    }

    print("part1 = {}\n", .{steps + 1});
}

fn dump(map: *const std.AutoHashMap(Pos, Facing), w: usize, h: usize) void {
    var x: usize = 0;
    var y: usize = 0;

    while (y < h) : (y += 1) {
        x = 0;
        while (x < w) : (x += 1) {
            const pos: Pos = .{ .x = x, .y = y };
            if (map.get(pos)) |f| {
                switch (f) {
                    .east => print(">", .{}),
                    .south => print("v", .{}),
                }
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }
}

fn moveEast(map: *std.AutoHashMap(Pos, Facing), w: usize, h: usize) !bool {
    var x: usize = 0;
    var y: usize = 0;

    var actions = std.ArrayList(Pos).init(std.testing.allocator);
    defer actions.deinit();

    while (x < w) : (x += 1) {
        y = 0;
        while (y < h) : (y += 1) {
            const pos: Pos = .{ .x = x, .y = y };
            if (map.get(pos)) |f| {
                if (f == .east and !map.contains(.{ .x = (x + 1) % w, .y = y })) {
                    try actions.append(pos);
                }
            }
        }
    }

    for (actions.items) |pos| {
        _ = map.remove(pos);
        try map.put(.{ .x = (pos.x + 1) % w, .y = pos.y }, .east);
    }

    return actions.items.len > 0;
}

fn moveSouth(map: *std.AutoHashMap(Pos, Facing), w: usize, h: usize) !bool {
    var x: usize = 0;
    var y: usize = 0;

    var actions = std.ArrayList(Pos).init(std.testing.allocator);
    defer actions.deinit();

    while (y < h) : (y += 1) {
        x = 0;
        while (x < w) : (x += 1) {
            const pos: Pos = .{ .x = x, .y = y };
            if (map.get(pos)) |f| {
                if (f == .south and !map.contains(.{ .x = x, .y = (y + 1) % h })) {
                    try actions.append(pos);
                }
            }
        }
    }

    for (actions.items) |pos| {
        _ = map.remove(pos);
        try map.put(.{ .x = pos.x, .y = (pos.y + 1) % h }, .south);
    }

    return actions.items.len > 0;
}

const Facing = enum {
    east,
    south,
};

const Pos = struct {
    x: usize,
    y: usize,
};
