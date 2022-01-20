const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d14" {
    const input = @embedFile("input/d14");
    var lines = std.mem.tokenize(u8, input, "\r\n");
    var deers = std.ArrayList(Deer).init(std.testing.allocator);
    defer deers.deinit();
    while (lines.next()) |l| {
        var parts = std.mem.tokenize(u8, l, " ");
        inline for (" " ** 3) |_| _ = parts.next();
        const speed = try fmt.parseInt(usize, parts.next().?, 10);
        inline for (" " ** 2) |_| _ = parts.next();
        const fly = try fmt.parseInt(usize, parts.next().?, 10);
        inline for (" " ** 6) |_| _ = parts.next();
        const rest = try fmt.parseInt(usize, parts.next().?, 10);

        try deers.append(.{ .speed = speed, .fly = fly, .rest = rest });
    }

    var p1: usize = 0;
    const time = 2503;
    for (deers.items) |*deer| {
        const distance = deer.distanceAt(time);
        if (distance > p1) p1 = distance;
    }

    var sec: usize = 0;
    while (sec < time) : (sec += 1) {
        var max: usize = 0;
        std.debug.assert(deers.items.len < 16);
        var max_i = try std.BoundedArray(usize, 16).init(0);
        for (deers.items) |*deer, i| {
            const distance = deer.distanceAt(sec);
            if (distance > max) {
                max = distance;
                try max_i.resize(0);
                try max_i.append(i);
            } else if (distance == max and max != 0) {
                try max_i.append(i);
            }
        }
        for (max_i.constSlice()) |i| {
            deers.items[i].points += 1;
        }
    }
    var p2: usize = 0;
    for (deers.items) |*deer| {
        if (deer.points > p2) p2 = deer.points;
    }

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

const Deer = struct {
    speed: usize,
    fly: usize,
    rest: usize,
    points: usize = 0,

    const Self = @This();

    fn distanceAt(self: *const Self, time: usize) usize {
        const interval = self.fly + self.rest;
        const div = time / interval;
        const rem = time % interval;

        return (div * self.fly + if (rem > self.fly) self.fly else rem) * self.speed;
    }
};
