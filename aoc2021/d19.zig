const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d19" {
    const input = @embedFile("input/d19");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var scanners = std.ArrayList(Scanner).init(std.testing.allocator);
    defer {
        for (scanners.items) |scanner| {
            std.testing.allocator.free(scanner.beancons);
        }
        scanners.deinit();
    }

    var points = std.ArrayList(Point).init(std.testing.allocator);
    defer points.deinit();

    while (it.next()) |l| {
        if (std.mem.startsWith(u8, l, "---")) {
            if (points.items.len > 0) {
                try scanners.append(.{ .beancons = points.toOwnedSlice() });
            }
        } else {
            var parts = std.mem.tokenize(u8, l, ",");
            const x = try fmt.parseInt(isize, parts.next().?, 10);
            const y = try fmt.parseInt(isize, parts.next().?, 10);
            const z = try fmt.parseInt(isize, parts.next().?, 10);

            try points.append(.{ .x = x, .y = y, .z = z });
        }
    }
    if (points.items.len > 0) {
        try scanners.append(.{ .beancons = points.toOwnedSlice() });
    }

    var memo = try Memo.init(std.testing.allocator, scanners.items.len);
    defer memo.deinit();

    var count = std.AutoHashMap(Point, usize).init(std.testing.allocator);
    defer count.deinit();

    memo.add(scanners.items[0], 0, .{ .x = 0, .y = 0, .z = 0 }, 0);

    var timer = try std.time.Timer.start();
    loop: while (memo.pending.count() != 0) {
        var pit = memo.pending.iterator(.{});
        while (pit.next()) |i| {
            const scanner = scanners.items[i];

            var rotation: u32 = 0;
            while (rotation < 24) : (rotation += 1) {
                count.clearRetainingCapacity();
                for (scanner.beancons) |unknown| {
                    for (memo.known_beancons.keys()) |known| {
                        const trans = known.sub(unknown.rotate(rotation));
                        const entry = try count.getOrPut(trans);
                        if (entry.found_existing) {
                            entry.value_ptr.* += 1;
                            if (entry.value_ptr.* >= 12) {
                                memo.add(scanner, rotation, trans, i);
                                continue :loop;
                            }
                        } else {
                            entry.value_ptr.* = 1;
                        }
                    }
                }
            }
        }
    }
    const p1_time = timer.lap();

    const p1 = memo.known_beancons.keys().len;
    var p2: isize = 0;
    for (memo.transforms[0 .. memo.transforms.len - 1]) |a, i| {
        for (memo.transforms[i + 1 ..]) |b| {
            const dist = a.manh_distance(b);
            if (dist > p2) p2 = dist;
        }
    }

    print("part1 = {}, part2 = {}, p1 time = {}\n", .{ p1, p2, p1_time });
}

const Scanner = struct {
    beancons: []const Point,
};

const Memo = struct {
    pending: std.DynamicBitSet,
    rotations: []u32,
    transforms: []Point,
    known_beancons: std.AutoArrayHashMap(Point, void),
    allocator: std.mem.Allocator,

    const Self = @This();

    fn init(allocator: std.mem.Allocator, count: usize) !Self {
        return Self{
            .pending = try std.DynamicBitSet.initFull(allocator, count),
            .rotations = try allocator.alloc(u32, count),
            .transforms = try allocator.alloc(Point, count),
            .known_beancons = std.AutoArrayHashMap(Point, void).init(allocator),
            .allocator = allocator,
        };
    }

    fn deinit(self: *Self) void {
        self.known_beancons.deinit();
        self.allocator.free(self.rotations);
        self.allocator.free(self.transforms);
        self.pending.deinit();
    }

    fn add(self: *Self, scanner: Scanner, rotation: u32, transform: Point, i: usize) void {
        self.pending.unset(i);
        self.rotations[i] = rotation;
        self.transforms[i] = transform;
        for (scanner.beancons) |b| {
            self.known_beancons.put(b.rotate(rotation).add(transform), {}) catch unreachable;
        }
    }
};

const Point = struct {
    x: isize,
    y: isize,
    z: isize,

    const Self = @This();

    fn manh_distance(self: Self, other: Self) isize {
        const delta = self.sub(other);
        return (std.math.absInt(delta.x) catch unreachable) +
            (std.math.absInt(delta.y) catch unreachable) +
            (std.math.absInt(delta.z) catch unreachable);
    }

    fn add(self: Self, other: Self) Self {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    fn sub(self: Self, other: Self) Self {
        return .{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    fn rotate(self: Self, rotation: u32) Self {
        const x = self.x;
        const y = self.y;
        const z = self.z;
        return switch (rotation) {
            0 => Self{ .x = x, .y = y, .z = z },
            1 => Self{ .x = x, .y = z, .z = -y },
            2 => Self{ .x = x, .y = -y, .z = -z },
            3 => Self{ .x = x, .y = -z, .z = y },

            4 => Self{ .x = -x, .y = y, .z = -z },
            5 => Self{ .x = -x, .y = z, .z = y },
            6 => Self{ .x = -x, .y = -y, .z = z },
            7 => Self{ .x = -x, .y = -z, .z = -y },

            8 => Self{ .x = y, .y = -x, .z = z },
            9 => Self{ .x = y, .y = -z, .z = -x },
            10 => Self{ .x = y, .y = x, .z = -z },
            11 => Self{ .x = y, .y = z, .z = x },

            12 => Self{ .x = -y, .y = -x, .z = -z },
            13 => Self{ .x = -y, .y = -z, .z = x },
            14 => Self{ .x = -y, .y = x, .z = z },
            15 => Self{ .x = -y, .y = z, .z = -x },

            16 => Self{ .x = z, .y = x, .z = y },
            17 => Self{ .x = z, .y = y, .z = -x },
            18 => Self{ .x = z, .y = -x, .z = -y },
            19 => Self{ .x = z, .y = -y, .z = x },

            20 => Self{ .x = -z, .y = x, .z = -y },
            21 => Self{ .x = -z, .y = y, .z = x },
            22 => Self{ .x = -z, .y = -x, .z = y },
            23 => Self{ .x = -z, .y = -y, .z = -x },

            else => unreachable,
        };
    }
};
