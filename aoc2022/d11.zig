const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;

const List = std.ArrayList(usize);

test "d11" {
    const ls = &[_]List{
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 93, 98 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 95, 72, 98, 82, 86 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 85, 62, 82, 86, 70, 65, 83, 76 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 86, 70, 71, 56 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 77, 71, 86, 52, 81, 67 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 89, 87, 60, 78, 54, 77, 98 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 69, 65, 63 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{89})),
    };
    defer for (ls) |l| l.deinit();
    const ls2 = &[_]List{
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 93, 98 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 95, 72, 98, 82, 86 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 85, 62, 82, 86, 70, 65, 83, 76 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 86, 70, 71, 56 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 77, 71, 86, 52, 81, 67 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 89, 87, 60, 78, 54, 77, 98 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{ 69, 65, 63 })),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(usize, &[_]usize{89})),
    };
    defer for (ls2) |l| l.deinit();

    var counts = std.mem.zeroes([ls.len]usize);
    var counts2 = std.mem.zeroes([ls.len]usize);

    for (" " ** 20) |_| {
        inline for (.{ m0, m1, m2, m3, m4, m5, m6, m7 }) |f, i| {
            counts[i] += try f(ls, true);
            counts2[i] += try f(ls2, false);
        }
    }
    for (" " ** (10000 - 20)) |_| {
        inline for (.{ m0, m1, m2, m3, m4, m5, m6, m7 }) |f, i| {
            counts2[i] += try f(ls2, false);
        }
    }

    std.sort.sort(usize, &counts, {}, comptime std.sort.desc(usize));
    std.sort.sort(usize, &counts2, {}, comptime std.sort.desc(usize));
    print("part1: {d}, part2: {d}\n", .{ counts[0] * counts[1], counts2[0] * counts2[1] });
}

fn m0(items: []List, relief: bool) !usize {
    const s = items[0].items;
    for (s) |c| {
        var new = c * 17;
        if (relief) new /= 3 else new %= 19 * 13 * 5 * 7 * 17 * 2 * 3 * 11;
        if (new % 19 == 0) {
            try items[5].append(new);
        } else {
            try items[3].append(new);
        }
    }
    items[0].clearRetainingCapacity();
    return s.len;
}

fn m1(items: []List, relief: bool) !usize {
    const s = items[1].items;
    for (s) |c| {
        var new = c + 5;
        if (relief) new /= 3 else new %= 19 * 13 * 5 * 7 * 17 * 2 * 3 * 11;
        if (new % 13 == 0) {
            try items[7].append(new);
        } else {
            try items[6].append(new);
        }
    }
    items[1].clearRetainingCapacity();
    return s.len;
}

fn m2(items: []List, relief: bool) !usize {
    const s = items[2].items;
    for (s) |c| {
        var new = c + 8;
        if (relief) new /= 3 else new %= 19 * 13 * 5 * 7 * 17 * 2 * 3 * 11;
        if (new % 5 == 0) {
            try items[3].append(new);
        } else {
            try items[0].append(new);
        }
    }
    items[2].clearRetainingCapacity();
    return s.len;
}

fn m3(items: []List, relief: bool) !usize {
    const s = items[3].items;
    for (s) |c| {
        var new = c + 1;
        if (relief) new /= 3 else new %= 19 * 13 * 5 * 7 * 17 * 2 * 3 * 11;
        if (new % 7 == 0) {
            try items[4].append(new);
        } else {
            try items[5].append(new);
        }
    }
    items[3].clearRetainingCapacity();
    return s.len;
}

fn m4(items: []List, relief: bool) !usize {
    const s = items[4].items;
    for (s) |c| {
        var new = c + 4;
        if (relief) new /= 3 else new %= 19 * 13 * 5 * 7 * 17 * 2 * 3 * 11;
        if (new % 17 == 0) {
            try items[1].append(new);
        } else {
            try items[6].append(new);
        }
    }
    items[4].clearRetainingCapacity();
    return s.len;
}

fn m5(items: []List, relief: bool) !usize {
    const s = items[5].items;
    for (s) |c| {
        var new = c * 7;
        if (relief) new /= 3 else new %= 19 * 13 * 5 * 7 * 17 * 2 * 3 * 11;
        if (new % 2 == 0) {
            try items[1].append(new);
        } else {
            try items[4].append(new);
        }
    }
    items[5].clearRetainingCapacity();
    return s.len;
}

fn m6(items: []List, relief: bool) !usize {
    const s = items[6].items;
    for (s) |c| {
        var new = c + 6;
        if (relief) new /= 3 else new %= 19 * 13 * 5 * 7 * 17 * 2 * 3 * 11;
        if (new % 3 == 0) {
            try items[7].append(new);
        } else {
            try items[2].append(new);
        }
    }
    items[6].clearRetainingCapacity();
    return s.len;
}

fn m7(items: []List, relief: bool) !usize {
    const s = items[7].items;
    for (s) |c| {
        var new = c * c;
        if (relief) new /= 3 else new %= 19 * 13 * 5 * 7 * 17 * 2 * 3 * 11;
        if (new % 11 == 0) {
            try items[0].append(new);
        } else {
            try items[2].append(new);
        }
    }
    items[7].clearRetainingCapacity();
    return s.len;
}
