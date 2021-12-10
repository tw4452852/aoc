const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d10" {
    const input = @embedFile("input/d10");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var part1: isize = 0;
    var corruptScores = std.ArrayList(isize).init(std.testing.allocator);
    defer corruptScores.deinit();

    while (it.next()) |line| {
        const s = try score(line);
        if (s >= 0) {
            part1 += s;
        } else {
            try corruptScores.append(-s);
        }
    }

    std.sort.sort(isize, corruptScores.items, {}, comptime std.sort.asc(isize));

    print("part1 = {}, part2 = {}\n", .{ part1, corruptScores.items[corruptScores.items.len / 2] });
}

// positive number represents corrupted score, otherwise incomplete score.
fn score(line: []const u8) !isize {
    var pending = std.ArrayList(u8).init(std.testing.allocator);
    defer pending.deinit();

    var firstError: ?isize = null;
    for (line) |c| {
        switch (c) {
            '[', '{', '(', '<' => try pending.append(c),
            ']', '}', ')', '>' => {
                const tail = pending.popOrNull();
                if (tail == null) return 0;
                if (c -% tail.? != 1 and c -% tail.? != 2) {
                    if (firstError != null) return 0;
                    firstError = switch (c) {
                        ')' => 3,
                        ']' => 57,
                        '}' => 1197,
                        '>' => 25137,
                        else => unreachable,
                    };
                }
            },
            else => unreachable,
        }
    }

    if (pending.items.len > 0 and firstError == null) return -incompleteScore(pending.items);

    return firstError orelse 0;
}

fn incompleteScore(pending: []const u8) isize {
    var s: isize = 0;
    var i: usize = pending.len;

    while (i > 0) : (i -= 1) {
        s *= 5;
        switch (pending[i - 1]) {
            '(' => s += 1,
            '[' => s += 2,
            '{' => s += 3,
            '<' => s += 4,
            else => unreachable,
        }
    }

    return s;
}
