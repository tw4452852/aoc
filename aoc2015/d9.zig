const std = @import("std");
const print = std.debug.print;
const fmt = std.fmt;

const count = 8;
test "d9" {
    const input = @embedFile("input/d9");
    var lines = std.mem.tokenize(u8, input, "\r\n");

    var distances = std.AutoHashMap(Ends, usize).init(std.testing.allocator);
    defer distances.deinit();

    var a: usize = 0;
    var b: usize = 0;
    while (a < count - 1) : (a += 1) {
        b = a + 1;
        while (b < count) : (b += 1) {
            const l = lines.next().?;
            const i = std.mem.indexOfScalar(u8, l, '=').?;
            const distance = try fmt.parseInt(usize, l[i + 2 ..], 10);
            try distances.put(.{ .a = a, .b = b }, distance);
            try distances.put(.{ .a = b, .b = a }, distance);
        }
    }

    std.debug.assert(lines.next() == null);

    var min: usize = std.math.maxInt(usize);
    var max: usize = 0;
    var q = try Q.init(0);

    try iterate(&q, &distances, &max, &min);

    print("part1 = {}, part2 = {}\n", .{ min, max });
}

fn iterate(q: *Q, distances: *const std.AutoHashMap(Ends, usize), max: *usize, min: *usize) anyerror!void {
    const cur = q.constSlice();

    if (cur.len == count) {
        var sum: usize = 0;
        for (cur[0 .. count - 1]) |a, i| {
            const b = cur[i + 1];
            sum += distances.get(.{ .a = a, .b = b }).?;
        }
        if (sum > max.*) max.* = sum;
        if (sum < min.*) min.* = sum;
        return;
    }

    var i: usize = 0;
    while (i < count) : (i += 1) {
        if (std.mem.indexOfScalar(usize, cur, i) == null) {
            try q.append(i);
            try iterate(q, distances, max, min);
            _ = q.pop();
        }
    }
}

const Q = std.BoundedArray(usize, count);
const Ends = struct {
    a: usize,
    b: usize,
};
