const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d23" {
    var p1: usize = 0;
    var pending = Queue.init(std.testing.allocator, {});
    defer pending.deinit();

    const state: State = .{
        .amps = .{
            .{ .cost = 1, .cur = .{ .x = -3, .y = -1 }, .dst_x = -3 },
            .{ .cost = 1, .cur = .{ .x = 3, .y = -1 }, .dst_x = -3 },
            .{ .cost = 10, .cur = .{ .x = 1, .y = -1 }, .dst_x = -1 },
            .{ .cost = 10, .cur = .{ .x = 1, .y = -2 }, .dst_x = -1 },
            .{ .cost = 100, .cur = .{ .x = -1, .y = -1 }, .dst_x = 1 },
            .{ .cost = 100, .cur = .{ .x = 3, .y = -2 }, .dst_x = 1 },
            .{ .cost = 1000, .cur = .{ .x = -1, .y = -2 }, .dst_x = 3 },
            .{ .cost = 1000, .cur = .{ .x = -3, .y = -2 }, .dst_x = 3 },
        },
    };
    try pending.add(.{ .state = state, .cost = 0 });

    var memo = std.AutoHashMap(State, usize).init(std.testing.allocator);
    defer memo.deinit();
    try memo.put(state, 0);

    while (pending.removeMinOrNull()) |entry| {
        if (entry.state.is_solved()) {
            p1 = entry.cost;
            break;
        }
        const min_cost = memo.get(entry.state).?;
        if (entry.cost > min_cost) continue;

        try entry.state.go(&pending, &memo);
    }

    print("part1 = {}\n", .{p1});
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
    amps: [8]Amp,

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

    fn go(self: *Self, pending: *Queue, memo: *std.AutoHashMap(State, usize)) !void {
        var map = std.AutoHashMap(Pos, *const Amp).init(std.testing.allocator);
        defer map.deinit();
        for (self.amps) |*amp| {
            map.put(amp.cur, amp) catch unreachable;
        }

        // find a way to move
        // firstly, check we can move to zoom
        for (self.amps) |*amp, i| {
            if (amp.done or amp.cur.y != 0) continue;

            const dst1: Pos = .{ .x = amp.dst_x, .y = -2 };
            if (map.get(dst1)) |ent1| {
                if (!ent1.done) continue;
                const dst2: Pos = .{ .x = amp.dst_x, .y = -1 };
                if (map.get(dst2) == null) {
                    if (is_way_clear(&map, amp.cur, dst2)) {
                        const copy = amp.moveTo(dst2);
                        var state_copy = self.*;
                        state_copy.amps[i] = copy;
                        const c = state_copy.cost();
                        const gop = try memo.getOrPut(state_copy);
                        if (!gop.found_existing or gop.value_ptr.* > c) {
                            gop.value_ptr.* = c;
                            try pending.add(.{ .state = state_copy, .cost = c });
                        }
                    }
                }
            } else {
                if (is_way_clear(&map, amp.cur, dst1)) {
                    const copy = amp.moveTo(dst1);
                    var state_copy = self.*;
                    state_copy.amps[i] = copy;
                    const c = state_copy.cost();
                    const gop = try memo.getOrPut(state_copy);
                    if (!gop.found_existing or gop.value_ptr.* > c) {
                        gop.value_ptr.* = c;
                        try pending.add(.{ .state = state_copy, .cost = c });
                    }
                }
            }
        }

        // secondly, check we can move to hallway
        for (self.amps) |*amp, i| {
            if (amp.done or amp.cur.y == 0) continue;

            var x: i8 = -5;

            while (x <= 5) : (x += 1) {
                if (x == amp.cur.x) continue;
                const dst: Pos = .{ .x = x, .y = 0 };

                if (is_way_clear(&map, amp.cur, dst)) {
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
