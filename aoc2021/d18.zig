const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d18" {
    const input = @embedFile("input/d18");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var s = std.ArrayList(u8).init(std.testing.allocator);
    var snails = std.ArrayList([]const u8).init(std.testing.allocator);
    defer snails.deinit();

    const first = it.next().?;
    try snails.append(first);

    try s.appendSlice(first);
    defer s.deinit();

    while (it.next()) |l| {
        try snails.append(l);
        try add(&s, l);
    }

    var sum = std.ArrayList(u8).init(std.testing.allocator);
    defer sum.deinit();
    var largest: usize = 0;
    for (snails.items) |l, i| {
        for (snails.items) |r, j| {
            if (j == i) continue;

            sum.clearRetainingCapacity();
            try sum.appendSlice(l);
            try add(&sum, r);
            const mag = magnitude(sum.items);
            if (mag > largest) largest = mag;
        }
    }

    print("part1 = {}, part2 = {}\n", .{ magnitude(s.items), largest });
}

fn magnitude(l: []const u8) usize {
    var mul: usize = 1;
    var sum: usize = 0;

    for (l) |c| {
        switch (c) {
            '[' => mul *= 3,
            ']' => mul /= 2,
            ',' => {
                mul /= 3;
                mul *= 2;
            },
            else => sum += (c - '0') * mul,
        }
    }

    return sum;
}

fn add(s: *std.ArrayList(u8), l: []const u8) !void {
    try s.insert(0, '[');
    try s.append(',');
    try s.appendSlice(l);
    try s.append(']');

    while (true) {
        var changed = try explode(s);
        if (changed) continue;
        changed = try split(s);
        if (!changed) break;
    }
}

fn split(s: *std.ArrayList(u8)) !bool {
    var i: usize = 0;
    while (i < s.items.len) : (i += 1) {
        const c = s.items[i];
        if (c == '[' or c == ']' or c == ',') continue;
        const n = (c & 0x7f) - '0';
        if (n <= 9) continue;

        const left = n / 2;
        const right = n - left;

        var buf: [16]u8 = undefined;
        const pair = try fmt.bufPrint(&buf, "[{c},{c}]", .{ left + '0', right + '0' });
        try s.replaceRange(i, 1, pair);
        return true;
    }
    return false;
}

fn explode(s: *std.ArrayList(u8)) !bool {
    var level: usize = 0;
    var i: usize = 0;

    while (i < s.items.len) : (i += 1) {
        switch (s.items[i]) {
            '[' => level += 1,
            ']' => level -= 1,
            ',' => {},
            else => if (level > 4) break,
        }
    } else {
        std.debug.assert(level == 0);
        return false;
    }

    std.debug.assert(level > 4);

    const left = (s.items[i] & 0x7f) - '0';
    const right = (s.items[i + 2] & 0x7f) - '0';

    // add to left if any
    var j: usize = i - 2;
    while (j >= 0 and j < s.items.len) : (j -%= 1) {
        const c = s.items[j];
        if (c == ',' or c == '[' or c == ']') continue;
        s.items[j] += left;
        if (s.items[j] == ']' or s.items[j] == '[') {
            s.items[j] |= 1 << 7;
        }
        break;
    }

    // add to right if any
    j = i + 4;
    while (j < s.items.len) : (j += 1) {
        const c = s.items[j];
        if (c == ',' or c == '[' or c == ']') continue;
        s.items[j] += right;
        if (s.items[j] == ']' or s.items[j] == '[') {
            s.items[j] |= 1 << 7;
        }
        break;
    }

    // replace entire pair with 0
    try s.replaceRange(i - 1, 5, "0");

    return true;
}
