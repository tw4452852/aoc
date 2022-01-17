const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d6" {
    const input = @embedFile("input/d6");
    var lines = std.mem.tokenize(u8, input, "\r\n");

    var map1 = std.AutoHashMap(Pos, void).init(std.testing.allocator);
    defer map1.deinit();
    var map2 = std.AutoArrayHashMap(Pos, usize).init(std.testing.allocator);
    defer map2.deinit();
    var x: usize = undefined;
    var y: usize = 0;

    while (y < 1000) : (y += 1) {
        x = 0;
        while (x < 1000) : (x += 1) {
            try map2.put(.{ .x = x, .y = y }, 0);
        }
    }
    while (lines.next()) |l| {
        var parts = std.mem.tokenize(u8, l[5..], " ,");
        _ = parts.next();
        const x_min = try fmt.parseInt(usize, parts.next().?, 10);
        const y_min = try fmt.parseInt(usize, parts.next().?, 10);
        _ = parts.next();
        const x_max = try fmt.parseInt(usize, parts.next().?, 10);
        const y_max = try fmt.parseInt(usize, parts.next().?, 10);

        switch (l[6]) {
            'n' => {
                // turn on
                y = y_min;
                while (y <= y_max) : (y += 1) {
                    x = x_min;
                    while (x <= x_max) : (x += 1) {
                        try map1.put(.{ .x = x, .y = y }, {});
                        const val_ptr = map2.getPtr(.{ .x = x, .y = y }).?;
                        val_ptr.* += 1;
                    }
                }
            },
            ' ' => {
                // toggle
                y = y_min;
                while (y <= y_max) : (y += 1) {
                    x = x_min;
                    while (x <= x_max) : (x += 1) {
                        if (map1.fetchRemove(.{ .x = x, .y = y }) == null) {
                            try map1.put(.{ .x = x, .y = y }, {});
                        }
                        const val_ptr = map2.getPtr(.{ .x = x, .y = y }).?;
                        val_ptr.* += 2;
                    }
                }
            },
            'f' => {
                // turn off
                y = y_min;
                while (y <= y_max) : (y += 1) {
                    x = x_min;
                    while (x <= x_max) : (x += 1) {
                        _ = map1.remove(.{ .x = x, .y = y });
                        const val_ptr = map2.getPtr(.{ .x = x, .y = y }).?;
                        val_ptr.* -|= 1;
                    }
                }
            },
            else => unreachable,
        }
    }
    const p1 = map1.count();
    const p2 = blk: {
        var sum: usize = 0;
        for (map2.values()) |brightness| {
            sum += brightness;
        }
        break :blk sum;
    };
    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

const Pos = struct {
    x: usize,
    y: usize,
};
