const std = @import("std");
const print = std.debug.print;
const fmt = std.fmt;

test "d15" {
    const input = @embedFile("input/d15");
    var lines = std.mem.tokenize(u8, input, "\r\n");

    var recipes = std.MultiArrayList(Recipe){};
    defer recipes.deinit(std.testing.allocator);

    while (lines.next()) |l| {
        var parts = std.mem.tokenize(u8, l, ", ");
        inline for (" " ** 2) |_| _ = parts.next();
        const cap = try fmt.parseInt(isize, parts.next().?, 10);
        _ = parts.next();
        const dur = try fmt.parseInt(isize, parts.next().?, 10);
        _ = parts.next();
        const fla = try fmt.parseInt(isize, parts.next().?, 10);
        _ = parts.next();
        const tex = try fmt.parseInt(isize, parts.next().?, 10);
        _ = parts.next();
        const cal = try fmt.parseInt(isize, parts.next().?, 10);

        try recipes.append(std.testing.allocator, .{ .cap = cap, .dur = dur, .fla = fla, .tex = tex, .cal = cal });
    }

    std.debug.assert(recipes.items(.cap).len == 4);
    const all = 100;
    var result = [_]isize{1} ** 4;

    var p1: isize = 0;
    var p2: isize = 0;
    while (result[0] < all) : (result[0] += 1) {
        result[1] = 1;
        while (result[1] < all - result[0]) : (result[1] += 1) {
            result[2] = 1;
            while (result[2] < all - result[0] - result[1]) : (result[2] += 1) {
                result[3] = all - result[0] - result[1] - result[2];
                const cap = blk: {
                    var sum: isize = 0;
                    for (recipes.items(.cap)) |v, i| {
                        sum += v * result[i];
                    }
                    break :blk sum;
                };
                if (cap <= 0) continue;
                const dur = blk: {
                    var sum: isize = 0;
                    for (recipes.items(.dur)) |v, i| {
                        sum += v * result[i];
                    }
                    break :blk sum;
                };
                if (dur <= 0) continue;
                const fla = blk: {
                    var sum: isize = 0;
                    for (recipes.items(.fla)) |v, i| {
                        sum += v * result[i];
                    }
                    break :blk sum;
                };
                if (fla <= 0) continue;
                const tex = blk: {
                    var sum: isize = 0;
                    for (recipes.items(.tex)) |v, i| {
                        sum += v * result[i];
                    }
                    break :blk sum;
                };
                if (tex <= 0) continue;

                const r = cap * dur * fla * tex;
                if (r > p1) p1 = r;

                const cal = blk: {
                    var sum: isize = 0;
                    for (recipes.items(.cal)) |v, i| {
                        sum += v * result[i];
                    }
                    break :blk sum;
                };
                if (cal == 500 and r > p2) p2 = r;
            }
        }
    }

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

const Recipe = struct {
    cap: isize,
    dur: isize,
    fla: isize,
    tex: isize,
    cal: isize,
};
