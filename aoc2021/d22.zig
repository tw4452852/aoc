const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d22" {
    const input = @embedFile("input/d22");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var map = Map.init(std.testing.allocator);
    defer map.deinit();

    var p1: isize = 0;
    while (it.next()) |l| {
        var parts = std.mem.tokenize(u8, l, " ,");
        const on = parts.next().?[1] == 'n';

        var xparts = std.mem.tokenize(u8, parts.next().?[2..], ".");
        const x_min = try fmt.parseInt(isize, xparts.next().?, 10);
        const x_max = try fmt.parseInt(isize, xparts.next().?, 10);

        var yparts = std.mem.tokenize(u8, parts.next().?[2..], ".");
        const y_min = try fmt.parseInt(isize, yparts.next().?, 10);
        const y_max = try fmt.parseInt(isize, yparts.next().?, 10);

        var zparts = std.mem.tokenize(u8, parts.next().?[2..], ".");
        const z_min = try fmt.parseInt(isize, zparts.next().?, 10);
        const z_max = try fmt.parseInt(isize, zparts.next().?, 10);

        //print("{} {} {}, {} {}, {} {}\n", .{ on, x_min, x_max, y_min, y_max, z_min, z_max });
        if ((x_min < -50 or x_max > 50 or y_min < -50 or y_max > 50 or z_min < -50 or z_max > 50) and p1 == 0) p1 = map.count();
        if (on) {
            try map.on(.{ .x_min = x_min, .x_max = x_max, .y_min = y_min, .y_max = y_max, .z_min = z_min, .z_max = z_max });
        } else {
            try map.off(.{ .x_min = x_min, .x_max = x_max, .y_min = y_min, .y_max = y_max, .z_min = z_min, .z_max = z_max });
        }
    }

    print("part1 = {}, part2 = {}\n", .{ p1, map.count() });
}

const Space = struct {
    x_min: isize,
    x_max: isize,
    y_min: isize,
    y_max: isize,
    z_min: isize,
    z_max: isize,

    const Self = @This();

    fn count(self: Self) isize {
        return (self.x_max - self.x_min + 1) *
            (self.y_max - self.y_min + 1) *
            (self.z_max - self.z_min + 1);
    }
    fn contains(self: Self, other: Self) bool {
        return (self.x_min <= other.x_min and other.x_max <= self.x_max) and
            (self.y_min <= other.y_min and other.y_max <= self.y_max) and
            (self.z_min <= other.z_min and other.z_max <= self.z_max);
    }

    fn overlap(self: Self, other: Self) bool {
        return (self.x_min <= other.x_max and other.x_min <= self.x_max) and
            (self.y_min <= other.y_max and other.y_min <= self.y_max) and
            (self.z_min <= other.z_max and other.z_min <= self.z_max);
    }
};

const Map = struct {
    spaces: std.ArrayList(Space),
    allocator: std.mem.Allocator,

    const Self = @This();

    fn init(allocator: std.mem.Allocator) Self {
        return .{
            .spaces = std.ArrayList(Space).init(allocator),
            .allocator = allocator,
        };
    }

    fn deinit(self: *Self) void {
        self.spaces.deinit();
    }

    fn count(self: *Self) isize {
        var sum: isize = 0;
        for (self.spaces.items) |s| {
            sum += s.count();
        }
        return sum;
    }

    fn on(self: *Self, s: Space) !void {
        var i: usize = 0;
        while (i < self.spaces.items.len) {
            const item = self.spaces.items[i];
            if (item.overlap(s)) {
                if (item.contains(s)) return;
                if (s.contains(item)) {
                    _ = self.spaces.swapRemove(i);
                    continue;
                }
                var parts = try Spaces.init(0);
                split(&parts, item, s);
                try self.spaces.replaceRange(i, 1, parts.slice());
                i += parts.len;
            } else {
                i += 1;
            }
        }
        try self.spaces.append(s);
    }

    fn off(self: *Self, s: Space) !void {
        var i: usize = 0;
        while (i < self.spaces.items.len) {
            const item = self.spaces.items[i];
            if (item.overlap(s)) {
                if (s.contains(item)) {
                    _ = self.spaces.swapRemove(i);
                    continue;
                }
                var parts = try Spaces.init(0);
                split(&parts, item, s);
                try self.spaces.replaceRange(i, 1, parts.slice());
                i += parts.len;
            } else {
                i += 1;
            }
        }
    }
};

const Spaces = std.BoundedArray(Space, 6);
fn split(result: *Spaces, a: Space, b: Space) void {
    var remain = a;
    if (remain.x_min < b.x_min) {
        var chunk = remain;
        chunk.x_max = b.x_min - 1;
        result.appendAssumeCapacity(chunk);
        remain.x_min = b.x_min;
    }
    if (remain.x_max > b.x_max) {
        var chunk = remain;
        chunk.x_min = b.x_max + 1;
        result.appendAssumeCapacity(chunk);
        remain.x_max = b.x_max;
    }
    if (remain.y_min < b.y_min) {
        var chunk = remain;
        chunk.y_max = b.y_min - 1;
        result.appendAssumeCapacity(chunk);
        remain.y_min = b.y_min;
    }
    if (remain.y_max > b.y_max) {
        var chunk = remain;
        chunk.y_min = b.y_max + 1;
        result.appendAssumeCapacity(chunk);
        remain.y_max = b.y_max;
    }
    if (remain.z_min < b.z_min) {
        var chunk = remain;
        chunk.z_max = b.z_min - 1;
        result.appendAssumeCapacity(chunk);
        remain.z_min = b.z_min;
    }
    if (remain.z_max > b.z_max) {
        var chunk = remain;
        chunk.z_min = b.z_max + 1;
        result.appendAssumeCapacity(chunk);
        remain.z_max = b.z_max;
    }
}
