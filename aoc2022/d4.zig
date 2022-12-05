const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;

test "d4" {
    const input = @embedFile("input/d4");
    var it = std.mem.tokenize(u8, input, "\r\n");

    var p1: usize = 0;
    var p2: usize = 0;
    while (it.next()) |l| {
        var parts = std.mem.tokenize(u8, l, ",-");
        const ab = try fmt.parseInt(isize, parts.next().?, 10);
        const ae = try fmt.parseInt(isize, parts.next().?, 10);
        const bb = try fmt.parseInt(isize, parts.next().?, 10);
        const be = try fmt.parseInt(isize, parts.next().?, 10);

        if (is_contain(ab, ae, bb, be)) {
            p1 += 1;
        }
        if (is_overlap(ab, ae, bb, be)) {
            p2 += 1;
        }
    }

    print("part1: {d}, part2: {d}\n", .{ p1, p2 });
}

fn is_contain(ab: isize, ae: isize, bb: isize, be: isize) bool {
    if (ab <= bb and ae >= be) return true;
    if (bb <= ab and be >= ae) return true;
    return false;
}

fn is_overlap(ab: isize, ae: isize, bb: isize, be: isize) bool {
    if (bb <= ae and ab <= be) return true;
    return false;
}
