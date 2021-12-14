const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d13" {
    const input = @embedFile("input/d13");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var ps = std.ArrayList(Point).init(std.testing.allocator);
    defer ps.deinit();
    var left = std.ArrayList(Point).init(std.testing.allocator);
    defer left.deinit();

    var folded = false;
    while (it.next()) |l| {
        if (std.mem.startsWith(u8, l, "fold")) {
            var parts = std.mem.tokenize(u8, l, " ");
            _ = parts.next();
            _ = parts.next();
            var part3 = std.mem.tokenize(u8, parts.next().?, "=");
            const is_x = part3.next().?[0] == 'x';
            const fold = try fmt.parseInt(isize, part3.next().?, 10);

            if (is_x) try foldX(&ps, fold, &left) else try foldY(&ps, fold, &left);
            if (!folded) {
                folded = true;
                print("part1: {d}\n", .{left.items.len});
            }

            const tmp = ps;
            ps = left;
            left = tmp;
        } else {
            var parts = std.mem.tokenize(u8, l, ",");
            try ps.append(.{ .x = try fmt.parseInt(isize, parts.next().?, 10), .y = try fmt.parseInt(isize, parts.next().?, 10) });
        }
    }
    print("part2:\n", .{});
    show(ps.items);
}

const Point = struct {
    x: isize,
    y: isize,

    const Self = @This();
    fn foldY(self: Self, y: isize) Self {
        return if (self.y >= y) .{
            .x = self.x,
            .y = y - (self.y - y),
        } else self;
    }

    fn foldX(self: Self, x: isize) Self {
        return if (self.x >= x) .{
            .x = x - (self.x - x),
            .y = self.y,
        } else self;
    }
};

fn foldX(ps: *std.ArrayList(Point), x: isize, left: *std.ArrayList(Point)) !void {
    while (ps.popOrNull()) |p| {
        const fp = p.foldX(x);
        for (left.items) |l| {
            if (l.x == fp.x and l.y == fp.y) break;
        } else {
            try left.append(fp);
        }
    }
}

fn foldY(ps: *std.ArrayList(Point), y: isize, left: *std.ArrayList(Point)) !void {
    while (ps.popOrNull()) |p| {
        const fp = p.foldY(y);
        for (left.items) |l| {
            if (l.x == fp.x and l.y == fp.y) break;
        } else {
            try left.append(fp);
        }
    }
}

fn show(ps: []Point) void {
    var w: isize = 0;
    var h: isize = 0;

    for (ps) |p| {
        if (p.x > w) w = p.x;
        if (p.y > h) h = p.y;
    }

    var i: usize = 0;
    var j: usize = 0;
    while (i < h + 1) : (i += 1) {
        j = 0;
        while (j < w + 1) : (j += 1) {
            for (ps) |p| {
                if (p.x == j and p.y == i) {
                    print("#", .{});
                    break;
                }
            } else {
                print(" ", .{});
            }
        }
        print("\n", .{});
    }
}
