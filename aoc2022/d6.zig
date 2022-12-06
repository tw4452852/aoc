const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;

const Bits = std.StaticBitSet(26);

test "d6" {
    const input = @embedFile("input/d6");

    var p1: usize = 0;
    var p2: usize = 0;
    var i: usize = 4;
    while (i <= input.len) : (i += 1) {
        if (p1 == 0 and is_unique(input[i - 4 .. i])) {
            p1 = i;
        }
        if (p2 == 0 and i > 13 and is_unique(input[i - 14 .. i])) {
            p2 = i;
            break;
        }
    }

    print("part1: {d}, part2: {d}\n", .{ p1, p2 });
}

fn is_unique(s: []const u8) bool {
    var seen = Bits.initEmpty();

    for (s) |c| seen.set(c - 'a');

    return seen.count() == s.len;
}
