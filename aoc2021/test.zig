const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d1" {
    const input = @embedFile("input/d1");
    var it = std.mem.tokenize(u8, input, "\n");
    var numbers = std.ArrayList(isize).init(std.testing.allocator);
    defer numbers.deinit();
    var prev = try fmt.parseInt(isize, it.next().?, 10);
    try numbers.append(prev);

    var count: usize = 0;
    while (it.next()) |s| {
        const cur = try fmt.parseInt(isize, s, 10);
        if (cur > prev) {
            count += 1;
        }
        prev = cur;
        try numbers.append(prev);
    }
    print("p1 = {}", .{count});

    var i: usize = 0;
    count = 0;
    while (i < numbers.items.len - 3) : (i += 1) {
        if (numbers.items[i + 3] > numbers.items[i]) {
            count += 1;
        }
    }
    print(", p2 = {}", .{count});
}

test "d2" {
    const input = @embedFile("input/d2");
    var it = std.mem.tokenize(u8, input, "\n");

    var depth: isize = 0;
    var horizon: isize = 0;
    var aim: isize = 0;

    while (it.next()) |s| {
        var parts = std.mem.tokenize(u8, s, " ");
        const direction = parts.next().?;
        const count = try fmt.parseInt(isize, parts.next().?, 10);

        switch (direction[0]) {
            'f' => {
                horizon += count;
                depth += aim * count;
            },
            'u' => aim -= count,
            'd' => aim += count,
            else => unreachable,
        }
    }
    print("p1 = {}, p2 = {}", .{ aim * horizon, depth * horizon });
}

test "d3" {
    const input = @embedFile("input/d3");
    var it = std.mem.tokenize(u8, input, "\n");

    const width = 12;
    var stat = std.mem.zeroes([width]isize);
    var numbers = std.ArrayList([]const u8).init(std.testing.allocator);
    var numbers1 = std.ArrayList([]const u8).init(std.testing.allocator);
    defer numbers.deinit();
    defer numbers1.deinit();
    while (it.next()) |s| {
        try numbers.append(s);
        try numbers1.append(s);
        for (s) |c, i| {
            switch (c) {
                '1' => stat[i] += 1,
                '0' => stat[i] -= 1,
                else => unreachable,
            }
        }
    }

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
                const v = try fmt.parseInt(u12, numbers.items[0], 2);
                break :blk v;
            }
        }
        unreachable;
    };
    const co2 = blk: {
        var i: usize = 0;
        while (i < width) : (i += 1) {
            filter(i, &numbers1, false);
            if (numbers1.items.len == 1) {
                const v = try fmt.parseInt(u12, numbers1.items[0], 2);
                break :blk v;
            }
        }
        unreachable;
    };

    print(" oxy: {[0]b:0>12} {[0]}", .{oxy});
    print(" co2: {[0]b:0>12} {[0]}", .{co2});
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
