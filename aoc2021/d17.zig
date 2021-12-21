const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d17" {
    const min_x = 88;
    const max_x = 125;
    const min_y = -157;
    const max_y = -103;

    const max_init_y = -min_y - 1;
    const part1 = (max_init_y) * (max_init_y + 1) / 2; // sum of 1 + 2 + 3 + ... + max_init_y

    var y: isize = min_y;
    var x: isize = undefined;
    var part2: usize = 0;
    while (y <= max_init_y) : (y += 1) {
        x = 1;
        while (x <= max_x) : (x += 1) {
            if (isHit(x, y, min_x, max_x, min_y, max_y)) part2 += 1;
        }
    }
    print("part1 = {}, part2 = {}\n", .{ part1, part2 });
}

fn isHit(x: isize, y: isize, min_x: isize, max_x: isize, min_y: isize, max_y: isize) bool {
    if (x * (x + 1) < min_x * 2) return false;

    var hori: isize = 0;
    var vert: isize = 0;
    var x_step = x;
    var y_step = y;
    while (true) {
        hori += x_step;
        vert += y_step;

        if (min_x <= hori and hori <= max_x and min_y <= vert and vert <= max_y) return true;
        if (hori > max_x or vert < min_y) return false;

        y_step -= 1;
        if (x_step > 0) x_step -= 1;
    }
}
