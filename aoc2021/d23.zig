const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d23" {
    var p1: usize = 0;
    var p2: usize = 0;
    var pending1 = Queue.init(std.testing.allocator, {});
    defer pending1.deinit();
    var pending2 = Queue.init(std.testing.allocator, {});
    defer pending2.deinit();

    const state1: State = .{
        .amps = .{
            .{ .cost = 1, .cur = .{ .x = -3, .y = -1 }, .dst_x = -3 },
            .{ .cost = 1, .cur = .{ .x = 3, .y = -1 }, .dst_x = -3 },
            .{ .cost = 10, .cur = .{ .x = 1, .y = -1 }, .dst_x = -1 },
            .{ .cost = 10, .cur = .{ .x = 1, .y = -2 }, .dst_x = -1 },
            .{ .cost = 100, .cur = .{ .x = -1, .y = -1 }, .dst_x = 1 },
            .{ .cost = 100, .cur = .{ .x = 3, .y = -2 }, .dst_x = 1 },
            .{ .cost = 1000, .cur = .{ .x = -1, .y = -2 }, .dst_x = 3 },
            .{ .cost = 1000, .cur = .{ .x = -3, .y = -2 }, .dst_x = 3 },

            .{ .cost = 1, .cur = .{ .x = -3, .y = -3 }, .dst_x = -3, .done = true },
            .{ .cost = 1, .cur = .{ .x = -3, .y = -3 }, .dst_x = -3, .done = true },
            .{ .cost = 10, .cur = .{ .x = -1, .y = -3 }, .dst_x = -1, .done = true },
            .{ .cost = 10, .cur = .{ .x = -1, .y = -4 }, .dst_x = -1, .done = true },
            .{ .cost = 100, .cur = .{ .x = 1, .y = -3 }, .dst_x = 1, .done = true },
            .{ .cost = 100, .cur = .{ .x = 1, .y = -4 }, .dst_x = 1, .done = true },
            .{ .cost = 1000, .cur = .{ .x = 3, .y = -4 }, .dst_x = 3, .done = true },
            .{ .cost = 1000, .cur = .{ .x = 3, .y = -4 }, .dst_x = 3, .done = true },
        },
    };
    const state2: State = .{
        .amps = .{
            .{ .cost = 1, .cur = .{ .x = -3, .y = -1 }, .dst_x = -3 },
            .{ .cost = 1, .cur = .{ .x = 3, .y = -1 }, .dst_x = -3 },
            .{ .cost = 1, .cur = .{ .x = 3, .y = -2 }, .dst_x = -3 },
            .{ .cost = 1, .cur = .{ .x = 1, .y = -3 }, .dst_x = -3 },
            .{ .cost = 10, .cur = .{ .x = 1, .y = -1 }, .dst_x = -1 },
            .{ .cost = 10, .cur = .{ .x = 1, .y = -2 }, .dst_x = -1 },
            .{ .cost = 10, .cur = .{ .x = -1, .y = -3 }, .dst_x = -1 },
            .{ .cost = 10, .cur = .{ .x = 1, .y = -4 }, .dst_x = -1 },
            .{ .cost = 100, .cur = .{ .x = -1, .y = -1 }, .dst_x = 1 },
            .{ .cost = 100, .cur = .{ .x = -1, .y = -2 }, .dst_x = 1 },
            .{ .cost = 100, .cur = .{ .x = 3, .y = -3 }, .dst_x = 1 },
            .{ .cost = 100, .cur = .{ .x = 3, .y = -4 }, .dst_x = 1 },
            .{ .cost = 1000, .cur = .{ .x = -3, .y = -2 }, .dst_x = 3 },
            .{ .cost = 1000, .cur = .{ .x = -3, .y = -3 }, .dst_x = 3 },
            .{ .cost = 1000, .cur = .{ .x = -3, .y = -4 }, .dst_x = 3 },
            .{ .cost = 1000, .cur = .{ .x = -1, .y = -4 }, .dst_x = 3 },
        },
    };
    try pending1.add(.{ .state = state1, .cost = 0 });
    try pending2.add(.{ .state = state2, .cost = 0 });

    var memo1 = std.AutoHashMap(State, usize).init(std.testing.allocator);
    defer memo1.deinit();
    var memo2 = std.AutoHashMap(State, usize).init(std.testing.allocator);
    defer memo2.deinit();
    try memo1.put(state1, 0);
    try memo2.put(state2, 0);

    while (pending1.removeMinOrNull()) |*entry| {
        if (entry.state.is_solved()) {
            p1 = entry.cost;
            break;
        }
        const min_cost = memo1.get(entry.state).?;
        if (entry.cost > min_cost) continue;
        try entry.state.go(&pending1, &memo1, -2);
    }

    while (pending2.removeMinOrNull()) |*entry| {
        if (entry.state.is_solved()) {
            p2 = entry.cost;
            break;
        }
        const min_cost = memo2.get(entry.state).?;
        if (entry.cost > min_cost) continue;
        try entry.state.go(&pending2, &memo2, -4);
    }

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

const QE = struct {
    state: State,
    cost: usize,

    fn order(_: void, a: @This(), b: @This()) std.math.Order {
        return std.math.order(a.cost, b.cost);
    }
};
const Queue = std.PriorityDequeue(QE, void, QE.order);

const State = struct {
    amps: [16]Amp,

    const Self = @This();

    fn is_solved(self: *const Self) bool {
        for (self.amps) |*amp| {
            if (!amp.done) return false;
        }
        return true;
    }

    fn cost(self: *const Self) usize {
        var sum: usize = 0;
        for (self.amps) |*amp| {
            sum += amp.sum;
        }
        return sum;
    }

    fn go(self: *Self, pending: *Queue, memo: *std.AutoHashMap(State, usize), depth: i8) !void {
        var map = std.AutoHashMap(Pos, *const Amp).init(std.testing.allocator);
        defer map.deinit();
        for (self.amps) |*amp| {
            map.put(amp.cur, amp) catch unreachable;
        }

        // find a way to move
        // firstly, check we can move to zoom
        for (self.amps) |*amp, i| {
            if (amp.done) continue;

            var y = depth;
            while (y < 0) : (y += 1) {
                const dst: Pos = .{ .x = amp.dst_x, .y = y };
                if (map.get(dst)) |ent| {
                    if (!ent.done) break;
                } else {
                    if (is_way_clear(&map, amp.cur, dst)) {
                        var state_copy = self.*;
                        state_copy.amps[i] = amp.moveTo(dst);
                        const c = state_copy.cost();
                        const gop = try memo.getOrPut(state_copy);
                        if (!gop.found_existing or gop.value_ptr.* > c) {
                            gop.value_ptr.* = c;
                            try pending.add(.{ .state = state_copy, .cost = c });
                        }
                        break;
                    }
                }
            }
        }

        // secondly, check we can move to hallway
        for (self.amps) |*amp, i| {
            if (amp.done or amp.cur.y == 0) continue;

            const base_x = amp.cur.x;
            if (!is_way_clear(&map, amp.cur, .{ .x = base_x, .y = 0 })) continue;
            const min_x = blk: {
                var x = base_x - 1;
                while (x >= -5) : (x -= 1) {
                    if (map.get(.{ .x = x, .y = 0 })) |ent| {
                        std.debug.assert(ent.dst_x != x);
                        if (ent.dst_x < x or ent.dst_x == amp.dst_x or amp.dst_x > x) break :blk x + 1;
                        break :blk ent.dst_x + 1;
                    }
                }
                break :blk -5;
            };
            const max_x = blk: {
                var x = base_x + 1;
                while (x <= 5) : (x += 1) {
                    if (map.get(.{ .x = x, .y = 0 })) |ent| {
                        std.debug.assert(ent.dst_x != x);
                        if (ent.dst_x > x or ent.dst_x == amp.dst_x or amp.dst_x < x) break :blk x - 1;
                        break :blk ent.dst_x - 1;
                    }
                }
                break :blk 5;
            };
            if (min_x > max_x) continue;

            var x = min_x;

            while (x <= max_x) : (x += 1) {
                if (x == amp.cur.x) continue;
                const dst: Pos = .{ .x = x, .y = 0 };

                if ((x != -1 and x != -3 and x != 1 and x != 3)) {
                    var state_copy = self.*;
                    state_copy.amps[i] = amp.moveTo(dst);
                    const c = state_copy.cost();
                    const gop = try memo.getOrPut(state_copy);
                    if (!gop.found_existing or gop.value_ptr.* > c) {
                        gop.value_ptr.* = c;
                        try pending.add(.{ .state = state_copy, .cost = c });
                    }
                }
            }
        }
    }
};

fn is_way_clear(map: *const std.AutoHashMap(Pos, *const Amp), src: Pos, dst: Pos) bool {
    std.debug.assert(!std.meta.eql(src, dst));

    if (src.y < 0 and dst.y < 0) {
        const mid: Pos = .{ .x = src.x, .y = 0 };
        return is_way_clear(map, src, mid) and is_way_clear(map, mid, dst);
    }

    var x: i8 = src.x;
    var y: i8 = src.y;
    if (src.y == 0) {
        std.debug.assert(dst.y < 0);
        // from hallway to room
        if (src.x != dst.x) {
            while (x != dst.x) {
                x = if (x > dst.x) x - 1 else x + 1;
                if (map.contains(.{ .x = x, .y = 0 })) return false;
            }
        }
        while (y != dst.y) {
            y = if (y > dst.y) y - 1 else y + 1;
            if (map.contains(.{ .x = x, .y = y })) return false;
        }
    } else {
        std.debug.assert(dst.y == 0);
        std.debug.assert(src.y < 0);
        // from room to hallway
        while (y != dst.y) {
            y = if (y > dst.y) y - 1 else y + 1;
            if (map.contains(.{ .x = x, .y = y })) return false;
        }
        if (x != dst.x) {
            while (x != dst.x) {
                x = if (x > dst.x) x - 1 else x + 1;
                if (map.contains(.{ .x = x, .y = 0 })) return false;
            }
        }
    }
    return true;
}

const Pos = struct {
    x: i8,
    y: i8,
};

const Amp = struct {
    cost: usize,
    sum: usize = 0,
    cur: Pos,
    dst_x: i8,
    done: bool = false,

    const Self = @This();

    fn moveTo(self: *const Self, p: Pos) Self {
        std.debug.assert(!self.done);
        var copy = self.*;
        if (p.y < 0 and self.cur.y < 0) {
            // move to the dst directly
            std.debug.assert(self.sum == 0);
            std.debug.assert(p.x == self.dst_x);
            const steps = -self.cur.y - p.y + (if (p.x > self.cur.x) p.x - self.cur.x else self.cur.x - p.x);
            copy.sum = @intCast(usize, steps) * self.cost;
            copy.done = true;
        } else {
            // move to/from hallway from/to room
            const steps = (if (p.x > self.cur.x) p.x - self.cur.x else self.cur.x - p.x) +
                (if (p.y > self.cur.y) p.y - self.cur.y else self.cur.y - p.y);
            copy.sum += @intCast(usize, steps) * self.cost;
            if (p.y < 0) {
                std.debug.assert(p.x == self.dst_x);
                copy.done = true;
            }
        }
        copy.cur = p;
        return copy;
    }
};

test "enery" {
    var amp: Amp = .{
        .cost = 1,
        .cur = .{ .x = -1, .y = -2 },
        .dst_x = 1,
    };

    amp = amp.moveTo(.{ .x = 1, .y = -1 });
    std.debug.assert(amp.sum == 5);
    std.debug.assert(amp.done);

    amp = .{
        .cost = 1,
        .cur = .{ .x = -1, .y = -2 },
        .dst_x = 1,
    };
    amp = amp.moveTo(.{ .x = 1, .y = 0 });
    std.debug.assert(amp.sum == 4);
    std.debug.assert(!amp.done);
    amp = amp.moveTo(.{ .x = 1, .y = -2 });
    std.debug.assert(amp.sum == 6);
    std.debug.assert(amp.done);
}
