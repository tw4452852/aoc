const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d19" {
    const input = @embedFile("input/sample");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var scanners = std.ArrayList(Scanner).init(std.testing.allocator);
    defer {
        for (scanners.items) |*scanner| {
            scanner.deinit();
        }
        scanners.deinit();
    }

    while (it.next()) |l| {
        if (std.mem.startsWith(u8, l, "---")) {
            try scanners.append(Scanner.init(std.testing.allocator));
        } else {
            var parts = std.mem.tokenize(u8, l, ",");
            const x = try fmt.parseInt(isize, parts.next().?, 10);
            const y = try fmt.parseInt(isize, parts.next().?, 10);
            const z = try fmt.parseInt(isize, parts.next().?, 10);

            const scanner = &scanners.items[scanners.items.len - 1];
            try scanner.addPoint(.{ .x = x, .y = y, .z = z });
        }
    }

    const s0 = &scanners.items[0];
    var pending = std.ArrayList(usize).init(std.testing.allocator);
    defer pending.deinit();

    var i: usize = 1;
    while (i < scanners.items.len) : (i += 1) {
        try pending.append(i);
    }

    while (pending.items.len > 0) {
        for (pending.items) |p, idx| {
            if (s0.merge(&scanners.items[p])) {
                print("0 overlap with {}\n", .{p});
                _ = pending.swapRemove(idx);
                break;
            }
        } else {
            // at least one possible overlap with scanner0
            std.debug.assert(false);
        }
    }
}

const Point = struct {
    x: isize,
    y: isize,
    z: isize,

    const Self = @This();

    fn distanceX(self: Self, other: Self) isize {
        return other.x - self.x;
    }
    fn distanceY(self: Self, other: Self) isize {
        return other.y - self.y;
    }
    fn distanceZ(self: Self, other: Self) isize {
        return other.z - self.z;
    }
};

const Line = struct {
    ends: [2]Point,

    const Self = @This();

    fn lenX(self: Self) isize {
        return self.ends[0].distanceX(self.ends[1]);
    }
    fn lenY(self: Self) isize {
        return self.ends[0].distanceY(self.ends[1]);
    }
    fn lenZ(self: Self) isize {
        return self.ends[0].distanceZ(self.ends[1]);
    }

    fn parallelWith(self: Self, other: Self) bool {
        return (self.lenX() == other.lenX() or self.lenX() == -other.lenX()) and (self.lenY() == other.lenY() or self.lenY() == -other.lenY()) and (self.lenZ() == other.lenZ() or self.lenZ() == -other.lenZ());
    }
};

const Scanner = struct {
    ps: std.ArrayList(Point),
    ls: std.ArrayList(Line),
    allocator: *std.mem.Allocator,

    const Self = @This();

    fn init(allocator: *std.mem.Allocator) Self {
        return .{
            .ps = std.ArrayList(Point).init(allocator),
            .ls = std.ArrayList(Line).init(allocator),
            .allocator = allocator,
        };
    }

    fn deinit(self: *Self) void {
        self.ps.deinit();
        self.ls.deinit();
    }

    fn addPoint(self: *Self, p: Point) !void {
        for (self.ps.items) |c| {
            std.debug.assert(!std.meta.eql(c, p));
            try self.ls.append(.{ .ends = .{ c, p } });
        }
        try self.ps.append(p);
    }

    fn merge(self: *Self, other: *const Self) bool {
        var count: usize = 0;
        var dx: isize = 0;
        var dy: isize = 0;
        var dz: isize = 0;

        for (self.ls.items) |m| {
            for (other.ls.items) |o| {
                if (m.parallelWith(o)) {
                    print("{} {} {} {}\n{} {} {} {} para\n", .{ m, m.lenX(), m.lenY(), m.lenZ(), o, o.lenX(), o.lenY(), o.lenZ() });
                    count += 1;
                }
                if (count == 66) {
                    // if we have 66 paralelled lines, that's exactly 12 points (because 12 * 11 / 2 == 66)
                    _ = dx;
                    _ = dy;
                    _ = dz;
                }
            }
        }

        return if (count >= 66) true else false;
    }
};
