const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d3" {
    const input = @embedFile("input/d3");
    var it = std.mem.tokenize(u8, input, "\r\n");

    const width = 12;
    var stat = std.mem.zeroes([width]isize);
    var numbers = std.ArrayList([]const u8).init(std.testing.allocator);
    defer numbers.deinit();
    while (it.next()) |s| {
        try numbers.append(s);
        for (s) |c, i| {
            switch (c) {
                '1' => stat[i] += 1,
                '0' => stat[i] -= 1,
                else => unreachable,
            }
        }
    }
    const count = numbers.items.len;

    var gramma_s = std.ArrayList(u8).init(std.testing.allocator);
    defer gramma_s.deinit();
    for (stat) |pos| {
        if (pos > 0) {
            try gramma_s.append('1');
        } else {
            try gramma_s.append('0');
        }
    }
    const gramma = try fmt.parseInt(u12, gramma_s.items, 2);
    const epsilon: usize = ~gramma;
    print("p1 = {}", .{@as(usize, gramma * epsilon)});

    const oxy = blk: {
        var i: usize = 0;
        while (i < width) : (i += 1) {
            filter(i, &numbers, true);
            if (numbers.items.len == 1) {
                const v = try fmt.parseInt(usize, numbers.items[0], 2);
                break :blk v;
            }
        }
        unreachable;
    };
    const co2 = blk: {
        numbers.items.len = count;
        var i: usize = 0;
        while (i < width) : (i += 1) {
            filter(i, &numbers, false);
            if (numbers.items.len == 1) {
                const v = try fmt.parseInt(usize, numbers.items[0], 2);
                break :blk v;
            }
        }
        unreachable;
    };

    print(", p2 = {}\n", .{oxy * co2});
}

fn filter(pos: usize, numbers: *std.ArrayList([]const u8), most: bool) void {
    var val: isize = 0;

    for (numbers.items) |number| {
        switch (number[pos]) {
            '1' => val += 1,
            '0' => val -= 1,
            else => unreachable,
        }
    }

    var i: usize = 0;
    while (i < numbers.items.len) {
        switch (numbers.items[i][pos]) {
            '1' => {
                if ((most and val >= 0) or (!most and val < 0)) {
                    i += 1;
                } else {
                    _ = numbers.swapRemove(i);
                }
            },
            '0' => {
                if ((most and val < 0) or (!most and val >= 0)) {
                    i += 1;
                } else {
                    _ = numbers.swapRemove(i);
                }
            },
            else => unreachable,
        }
    }
}
