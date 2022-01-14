const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;
const expectEqual = std.testing.expectEqualSlices;

test "d24" {
    const input = @embedFile("input/d24");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var max: [14]u8 = undefined;
    var min: [14]u8 = undefined;

    var stack = try std.BoundedArray(Ent, 7).init(0);
    var pos: usize = 0;
    var pop: bool = undefined;
    while (it.next()) |l| : (pos += 1) {
        try expectEqual(u8, l, "inp w");
        try expectEqual(u8, it.next().?, "mul x 0");
        try expectEqual(u8, it.next().?, "add x z");
        try expectEqual(u8, it.next().?, "mod x 26");

        const popLine = it.next().?;
        if (std.mem.eql(u8, popLine, "div z 1")) {
            pop = false;
        } else {
            try expectEqual(u8, popLine, "div z 26");
            pop = true;
        }

        const off1Line = it.next().?;
        try expectEqual(u8, off1Line[0..6], "add x ");
        const off1 = try fmt.parseInt(isize, off1Line[6..], 10);

        try expectEqual(u8, it.next().?, "eql x w");
        try expectEqual(u8, it.next().?, "eql x 0");
        try expectEqual(u8, it.next().?, "mul y 0");
        try expectEqual(u8, it.next().?, "add y 25");
        try expectEqual(u8, it.next().?, "mul y x");
        try expectEqual(u8, it.next().?, "add y 1");
        try expectEqual(u8, it.next().?, "mul z y");
        try expectEqual(u8, it.next().?, "mul y 0");
        try expectEqual(u8, it.next().?, "add y w");

        const off2Line = it.next().?;
        try expectEqual(u8, off2Line[0..6], "add y ");
        const off2 = try fmt.parseInt(isize, off2Line[6..], 10);

        try expectEqual(u8, it.next().?, "mul y x");
        try expectEqual(u8, it.next().?, "add z y");

        if (!pop) {
            try stack.append(.{
                .pos = pos,
                .off = off2,
            });
        } else {
            const last = stack.pop();
            const diff = last.off + off1;
            if (diff > 0) {
                max[last.pos] = '9' - @intCast(u8, diff);
                max[pos] = '9';
                min[last.pos] = '1';
                min[pos] = '1' + @intCast(u8, diff);
            } else {
                max[last.pos] = '9';
                max[pos] = '9' - @intCast(u8, -diff);
                min[last.pos] = '1' + @intCast(u8, -diff);
                min[pos] = '1';
            }
        }
    }

    print("part1 = {s}, part2 = {s}\n", .{ max, min });
}

const Ent = struct {
    pos: usize,
    off: isize,
};
