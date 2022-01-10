const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d21" {
    const p1 = blk: {
        var player1: Player = .{
            .pos = 2,
        };
        var player2: Player = .{
            .pos = 8,
        };
        var step: usize = 1;
        while (true) {
            player1.update([_]usize{ step, step + 1, step + 2 });
            step += 3;
            if (player1.score >= 1000) break :blk player2.score * (step - 1);

            player2.update([_]usize{ step, step + 1, step + 2 });
            step += 3;
            if (player2.score >= 1000) break :blk player1.score * (step - 1);
        }
    };

    const p2 = blk: {
        var memo = std.AutoHashMap(Players, Results).init(std.testing.allocator);
        defer memo.deinit();

        var combs: [27][3]usize = undefined;

        var i: usize = 0;
        for ([3]usize{ 1, 2, 3 }) |a| {
            for ([3]usize{ 1, 2, 3 }) |b| {
                for ([3]usize{ 1, 2, 3 }) |c| {
                    combs[i] = .{ a, b, c };
                    i += 1;
                }
            }
        }

        var player1: Player = .{
            .pos = 2,
        };
        var player2: Player = .{
            .pos = 8,
        };

        const ret = count(player1, player2, &combs, &memo);
        //print("{} {}\n", .{ ret.a, ret.b });
        break :blk std.math.max(ret.a, ret.b);
    };

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

const Results = struct {
    a: usize,
    b: usize,
};

const Players = struct {
    a: Player,
    b: Player,
};

fn count(a: Player, b: Player, combs: *const [27][3]usize, memo: *std.AutoHashMap(Players, Results)) Results {
    if (a.score >= 21) return .{ .a = 1, .b = 0 };
    if (b.score >= 21) return .{ .a = 0, .b = 1 };

    if (memo.get(.{ .a = a, .b = b })) |counts| return counts;

    var a_count: usize = 0;
    var b_count: usize = 0;
    for (combs) |comb| {
        var player = a;
        player.update(comb);

        const counts = count(b, player, combs, memo);
        a_count += counts.b;
        b_count += counts.a;
    }

    const result: Results = .{ .a = a_count, .b = b_count };
    memo.put(.{ .a = a, .b = b }, result) catch unreachable;
    return result;
}

const Player = struct {
    score: usize = 0,
    pos: usize,

    const Self = @This();

    fn update(self: *Self, steps: [3]usize) void {
        self.pos = (self.pos + steps[0] + steps[1] + steps[2] - 1) % 10 + 1;
        self.score += self.pos;
    }
};
