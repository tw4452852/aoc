const std = @import("std");
const print = std.debug.print;
const fmt = std.fmt;

const count = 8;
test "d13" {
    const input = @embedFile("input/d13");
    var lines = std.mem.tokenize(u8, input, "\r\n");

    var happniess = std.AutoHashMap(Ends, isize).init(std.testing.allocator);
    defer happniess.deinit();

    var a: usize = 0;
    var b: usize = 0;
    while (a < count) : (a += 1) {
        b = 0;
        while (b < count) : (b += 1) {
            if (a == b) continue;
            const l = lines.next().?;
            var parts = std.mem.tokenize(u8, l, " ");
            _ = parts.next();
            _ = parts.next();
            const gain = if (std.mem.eql(u8, parts.next().?, "gain")) true else false;
            const h = try fmt.parseInt(isize, parts.next().?, 10);

            try happniess.put(.{ .a = a, .b = b }, if (gain) h else -h);
        }
    }

    std.debug.assert(lines.next() == null);

    var max: isize = 0;
    var max2: isize = 0;
    var q = try Q.init(0);

    try iterate(&q, &happniess, &max, &max2);

    print("part1 = {}, part2 = {}\n", .{ max, max2 });
}

fn iterate(q: *Q, happniess: *const std.AutoHashMap(Ends, isize), max: *isize, max2: *isize) anyerror!void {
    const cur = q.constSlice();

    if (cur.len == count) {
        var sum: isize = 0;
        for (cur) |a, i| {
            const l = cur[if (i > 0) i - 1 else count - 1];
            const r = cur[(i + 1) % count];
            sum += happniess.get(.{ .a = a, .b = l }).?;
            sum += happniess.get(.{ .a = a, .b = r }).?;
        }
        if (sum > max.*) max.* = sum;

        for (cur) |a, i| {
            const r = cur[(i + 1) % count];
            const sum2 = sum - (happniess.get(.{ .a = a, .b = r }).? + happniess.get(.{ .a = r, .b = a }).?);
            if (sum2 > max2.*) max2.* = sum2;
        }
        return;
    }

    var i: usize = 0;
    while (i < count) : (i += 1) {
        if (std.mem.indexOfScalar(usize, cur, i) == null) {
            try q.append(i);
            try iterate(q, happniess, max, max2);
            _ = q.pop();
        }
    }
}

const Q = std.BoundedArray(usize, count);
const Ends = struct {
    a: usize,
    b: usize,
};
