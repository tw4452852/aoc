const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;

const Pos = struct {
    row: usize,
    col: usize,
};

test "d8" {
    const input = @embedFile("input/d8");
    var it = std.mem.tokenize(u8, input, "\r\n");

    var grid = std.AutoHashMap(Pos, u8).init(std.testing.allocator);
    defer grid.deinit();

    var row: usize = 0;
    while (it.next()) |l| : (row += 1) {
        for (l) |c, col| try grid.put(.{ .row = row, .col = col }, c);
    }

    var p1: usize = 0;
    var p2: usize = 0;
    var map_it = grid.iterator();
    while (map_it.next()) |kv| {
        try explore(kv.key_ptr.*, &grid, &p1, &p2);
    }
    print("part1: {d}, part2: {d}\n", .{ p1, p2 });
}

fn explore(p: Pos, grid: *const std.AutoHashMap(Pos, u8), p1: *usize, p2: *usize) !void {
    var distance: usize = undefined;
    var visible = false;
    var mul: usize = 1;
    const h = grid.get(p).?;

    // turn left
    var cur: Pos = .{ .row = p.row, .col = p.col -% 1 };
    distance = 0;
    while (grid.get(cur)) |cur_h| : (cur = .{ .row = cur.row, .col = cur.col -% 1 }) {
        distance += 1;
        if (cur_h >= h) break;
    } else visible = true;
    mul *= distance;

    // turn right
    cur = .{ .row = p.row, .col = p.col +% 1 };
    distance = 0;
    while (grid.get(cur)) |cur_h| : (cur = .{ .row = cur.row, .col = cur.col +% 1 }) {
        distance += 1;
        if (cur_h >= h) break;
    } else visible = true;
    mul *= distance;

    // turn up
    cur = .{ .row = p.row -% 1, .col = p.col };
    distance = 0;
    while (grid.get(cur)) |cur_h| : (cur = .{ .row = cur.row -% 1, .col = cur.col }) {
        distance += 1;
        if (cur_h >= h) break;
    } else visible = true;
    mul *= distance;

    // turn down
    cur = .{ .row = p.row +% 1, .col = p.col };
    distance = 0;
    while (grid.get(cur)) |cur_h| : (cur = .{ .row = cur.row +% 1, .col = cur.col }) {
        distance += 1;
        if (cur_h >= h) break;
    } else visible = true;
    mul *= distance;

    if (visible) p1.* += 1;
    if (mul > p2.*) p2.* = mul;
}
