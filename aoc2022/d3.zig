const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;

const Bits = std.StaticBitSet(52);

test "d3" {
    const input = @embedFile("input/d3");
    var it = std.mem.tokenize(u8, input, "\r\n");

    var p1: usize = 0;
    var p2: usize = 0;
    var previous: [3][]const u8 = undefined;
    var i: usize = 0;
    while (it.next()) |l| : (i += 1) {
        const p1_bits = priority(l[0 .. l.len / 2], l[l.len / 2 ..]);
        assert(p1_bits.count() == 1);
        p1 += p1_bits.findFirstSet().? + 1;

        previous[i % 3] = l;
        if (i % 3 == 2) {
            var ab = priority(previous[0], previous[1]);
            const bc = priority(previous[1], previous[2]);
            const ac = priority(previous[0], previous[2]);

            ab.setIntersection(bc);
            ab.setIntersection(ac);
            assert(ab.count() == 1);
            p2 += ab.findFirstSet().? + 1;
        }
    }

    print("part1: {d}, part2: {d}\n", .{ p1, p2 });
}

fn priority(a: []const u8, b: []const u8) Bits {
    var ab = Bits.initEmpty();
    var bb = Bits.initEmpty();

    for (a) |c| {
        ab.set(if (c >= 'a') c - 'a' else c - 'A' + 26);
    }
    for (b) |c| {
        bb.set(if (c >= 'a') c - 'a' else c - 'A' + 26);
    }

    ab.setIntersection(bb);
    return ab;
}
