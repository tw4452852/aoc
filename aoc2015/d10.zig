const std = @import("std");
const print = std.debug.print;

test "d10" {
    var result = std.ArrayList(u8).init(std.testing.allocator);
    defer result.deinit();
    try result.appendSlice("1113222113");

    var i: usize = 0;
    var j: usize = 0;
    var p1: usize = undefined;
    while (i < 50) : (i += 1) {
        const cur = result.items;
        if (i == 40) p1 = cur.len;

        const n = cur.len;
        var count: usize = 1;
        var v = cur[0];
        j = 1;
        while (j < n) : (j += 1) {
            const c = result.items[j];
            if (c == v) {
                count += 1;
            } else {
                try result.writer().print("{}{c}", .{ count, v });
                v = c;
                count = 1;
            }
        }
        try result.writer().print("{}{c}", .{ count, v });

        try result.replaceRange(0, n, "");
    }

    print("part1 = {}, part2 = {}\n", .{ p1, result.items.len });
}
