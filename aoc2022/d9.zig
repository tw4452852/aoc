const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;

const Pos = struct {
    x: isize,
    y: isize,
};

test "d9" {
    const input = @embedFile("input/d9");
    var it = std.mem.tokenize(u8, input, "\r\n");

    var p1 = std.AutoHashMap(Pos, void).init(std.testing.allocator);
    defer p1.deinit();
    var p2 = std.AutoHashMap(Pos, void).init(std.testing.allocator);
    defer p2.deinit();

    var knots: [10]Pos = [_]Pos{.{ .x = 0, .y = 0 }} ** 10;

    var n: usize = undefined;
    while (it.next()) |l| {
        const step = try fmt.parseInt(usize, l[2..], 10);
        n = 0;
        while (n < step) : (n += 1) {
            switch (l[0]) {
                'R' => knots[0].x += 1,
                'L' => knots[0].x -= 1,
                'U' => knots[0].y += 1,
                'D' => knots[0].y -= 1,
                else => unreachable,
            }

            var i: usize = 0;
            while (i < 9) : (i += 1) {
                const head = &knots[i];
                const tail = &knots[i + 1];
                const dx = head.x - tail.x;
                const dy = head.y - tail.y;

                if (dx >= 2 or dx <= -2 or dy >= 2 or dy <= -2) {
                    tail.x += std.math.clamp(dx, -1, 1);
                    tail.y += std.math.clamp(dy, -1, 1);
                } else break;
            }
            try p1.put(knots[1], {});
            try p2.put(knots[9], {});
        }
    }

    print("part1: {d}, part2: {d}\n", .{ p1.count(), p2.count() });
}
