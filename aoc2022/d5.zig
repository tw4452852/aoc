const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;

const List = std.ArrayList(u8);

test "d5" {
    const input = @embedFile("input/d5");
    var it = std.mem.tokenize(u8, input, "\r\n");

    var p1: [9]List = .{
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(u8, "WDGBHRV")),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(u8, "JNGCRF")),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(u8, "LSFHDNJ")),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(u8, "JDSV")),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(u8, "SHDRQWNV")),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(u8, "PGHCM")),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(u8, "FJBGLZHC")),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(u8, "SJR")),
        List.fromOwnedSlice(std.testing.allocator, try std.testing.allocator.dupe(u8, "LGSRBNVM")),
    };
    var p2: [9]List = .{
        try p1[0].clone(),
        try p1[1].clone(),
        try p1[2].clone(),
        try p1[3].clone(),
        try p1[4].clone(),
        try p1[5].clone(),
        try p1[6].clone(),
        try p1[7].clone(),
        try p1[8].clone(),
    };

    defer {
        for (p1) |*stack| {
            stack.deinit();
        }
        for (p2) |*stack| {
            stack.deinit();
        }
    }

    for (" " ** 9) |_| _ = it.next();
    while (it.next()) |l| {
        var parts = std.mem.tokenize(u8, l, "movefromto ");

        const quantity = try fmt.parseInt(usize, parts.next().?, 10);
        const from = try fmt.parseInt(usize, parts.next().?, 10) - 1;
        const to = try fmt.parseInt(usize, parts.next().?, 10) - 1;

        var i: usize = 0;
        while (i < quantity) : (i += 1) try move(&p1[from], &p1[to], 1);
        try move(&p2[from], &p2[to], quantity);
    }

    print("part1: ", .{});
    for (p1) |*stack| {
        print("{c}", .{stack.items[stack.items.len - 1]});
    }
    print(", part2: ", .{});
    for (p2) |*stack| {
        print("{c}", .{stack.items[stack.items.len - 1]});
    }
    print("\n", .{});
}

fn move(from: *List, to: *List, n: usize) !void {
    const part = from.items[from.items.len - n ..];
    from.shrinkRetainingCapacity(from.items.len - n);
    try to.appendSlice(part);
}
