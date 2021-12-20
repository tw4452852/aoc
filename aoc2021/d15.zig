const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

const Entry = struct {
    x: usize,
    y: usize,
    cost: u64,

    const Self = @This();

    pub fn compare(a: Self, b: Self) std.math.Order {
        return std.math.order(a.cost, b.cost);
    }
};

const Queue = std.PriorityDequeue(Entry, Entry.compare);

const Map = struct {
    base: []const u8,
    w: usize,
    h: usize,
    large: bool = false,

    const Self = @This();

    pub fn isEnd(self: Self, x: usize, y: usize) bool {
        return if (self.large) x + y * self.w * 5 == self.w * self.h * 25 - 1 else x + y * self.w == self.w * self.h - 1;
    }

    pub fn idx(self: Self, x: usize, y: usize) usize {
        return if (self.large) x + y * self.w * 5 else x + y * self.w;
    }

    fn isInRange(self: Self, x: usize, y: usize) bool {
        const w = if (self.large) self.w * 5 else self.w;
        const h = if (self.large) self.h * 5 else self.h;

        return x < w and y < h;
    }

    /// if the position is out of range, return null
    pub fn riskAt(self: Self, x: usize, y: usize) ?u64 {
        if (!self.isInRange(x, y)) return null;

        const x_delta = x / self.w;
        const y_delta = y / self.h;
        const x_mod = x % self.w;
        const y_mod = y % self.h;
        var risk = self.base[x_mod + y_mod * self.w] + x_delta + y_delta;
        if (risk > 9) risk -= 9;
        return risk;
    }
};

test "d15" {
    const input = @embedFile("input/d15");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var w: usize = 0;
    var ps = blk: {
        var ps = std.ArrayList(u8).init(std.testing.allocator);
        while (it.next()) |l| {
            if (w == 0) w = l.len;

            try ps.ensureUnusedCapacity(w);
            for (l) |c| {
                ps.appendAssumeCapacity(c - '0');
            }
        }
        break :blk ps.toOwnedSlice();
    };
    defer std.testing.allocator.free(ps);
    const h = ps.len / w;

    const small_map: Map = .{
        .base = ps,
        .w = w,
        .h = h,
    };
    const large_map: Map = .{
        .base = ps,
        .w = w,
        .h = h,
        .large = true,
    };
    const p1 = try walk(small_map);
    const p2 = try walk(large_map);

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

fn walk(map: Map) !u64 {
    var q = Queue.init(std.testing.allocator);
    defer q.deinit();
    try q.add(.{ .x = 0, .y = 0, .cost = 0 });

    var costs = try std.testing.allocator.alloc(u64, map.w * map.h * 25);
    defer std.testing.allocator.free(costs);
    std.mem.set(u64, costs, std.math.maxInt(u64));
    costs[0] = 0;

    while (true) {
        const shortest = q.removeMin();
        const idx = map.idx(shortest.x, shortest.y);
        if (map.isEnd(shortest.x, shortest.y)) {
            return shortest.cost;
        }

        if (costs[idx] != shortest.cost) continue;

        if (map.riskAt(shortest.x -% 1, shortest.y)) |r| {
            const dst_idx = map.idx(shortest.x - 1, shortest.y);
            if (shortest.cost + r < costs[dst_idx]) {
                costs[dst_idx] = shortest.cost + r;
                try q.add(.{ .x = shortest.x - 1, .y = shortest.y, .cost = costs[dst_idx] });
            }
        }
        if (map.riskAt(shortest.x + 1, shortest.y)) |r| {
            const dst_idx = map.idx(shortest.x + 1, shortest.y);
            if (shortest.cost + r < costs[dst_idx]) {
                costs[dst_idx] = shortest.cost + r;
                try q.add(.{ .x = shortest.x + 1, .y = shortest.y, .cost = costs[dst_idx] });
            }
        }
        if (map.riskAt(shortest.x, shortest.y -% 1)) |r| {
            const dst_idx = map.idx(shortest.x, shortest.y - 1);
            if (shortest.cost + r < costs[dst_idx]) {
                costs[dst_idx] = shortest.cost + r;
                try q.add(.{ .x = shortest.x, .y = shortest.y - 1, .cost = costs[dst_idx] });
            }
        }
        if (map.riskAt(shortest.x, shortest.y + 1)) |r| {
            const dst_idx = map.idx(shortest.x, shortest.y + 1);
            if (shortest.cost + r < costs[dst_idx]) {
                costs[dst_idx] = shortest.cost + r;
                try q.add(.{ .x = shortest.x, .y = shortest.y + 1, .cost = costs[dst_idx] });
            }
        }
    }
}
