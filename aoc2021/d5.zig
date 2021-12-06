const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d5" {
    const input = @embedFile("input/d5");
    var it = std.mem.tokenize(u8, input, "\n");

    var map1 = std.AutoHashMap(Point, isize).init(std.testing.allocator);
    defer map1.deinit();
    var map2 = std.AutoHashMap(Point, isize).init(std.testing.allocator);
    defer map2.deinit();

    while (it.next()) |line| {
        var parts = std.mem.tokenize(u8, line, ",-> ");
        const x1 = try fmt.parseInt(isize, parts.next().?, 10);
        const y1 = try fmt.parseInt(isize, parts.next().?, 10);
        const x2 = try fmt.parseInt(isize, parts.next().?, 10);
        const y2 = try fmt.parseInt(isize, parts.next().?, 10);

        const dx = if (x1 > x2) x1 - x2 else x2 - x1;
        const dy = if (y1 > y2) y1 - y2 else y2 - y1;

        var x: isize = x1;
        var y: isize = y1;

        if (x1 != x2 and y1 == y2) {
            while (x != x2) {
                var entry = try map1.getOrPutValue(Point{ .x = x, .y = y }, 0);
                entry.value_ptr.* += 1;

                if (x < x2) x += 1 else x -= 1;
                if (x == x2) {
                    entry = try map1.getOrPutValue(Point{ .x = x, .y = y }, 0);
                    entry.value_ptr.* += 1;
                }
            }
        } else if (x1 == x2 and y1 != y2) {
            while (y != y2) {
                var entry = try map1.getOrPutValue(Point{ .x = x, .y = y }, 0);
                entry.value_ptr.* += 1;

                if (y < y2) y += 1 else y -= 1;
                if (y == y2) {
                    entry = try map1.getOrPutValue(Point{ .x = x, .y = y }, 0);
                    entry.value_ptr.* += 1;
                }
            }
        } else if (dx == dy) {
            while (x != x2) {
                var entry = try map2.getOrPutValue(Point{ .x = x, .y = y }, 0);
                entry.value_ptr.* += 1;

                if (x < x2) {
                    x += 1;
                } else {
                    x -= 1;
                }
                if (y < y2) {
                    y += 1;
                } else {
                    y -= 1;
                }
                if (x == x2) {
                    entry = try map2.getOrPutValue(Point{ .x = x, .y = y }, 0);
                    entry.value_ptr.* += 1;
                }
            }
        }
    }

    var overlaps: usize = 0;
    var mapIt = map1.iterator();
    while (mapIt.next()) |kv| {
        if (kv.value_ptr.* > 1) overlaps += 1;
    }

    print("p1 = {}", .{overlaps});

    mapIt = map2.iterator();
    while (mapIt.next()) |kv| {
        const entry = try map1.getOrPutValue(kv.key_ptr.*, 0);
        entry.value_ptr.* += kv.value_ptr.*;
    }
    overlaps = 0;
    mapIt = map1.iterator();
    while (mapIt.next()) |kv| {
        if (kv.value_ptr.* > 1) overlaps += 1;
    }
    print(", p2 = {}\n", .{overlaps});
}

const Point = struct {
    x: isize,
    y: isize,
};
