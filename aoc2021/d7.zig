const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d7" {
    const input = @embedFile("input/d7");
    var it = std.mem.tokenize(u8, input, ",\n\r");

    var nums = std.ArrayList(usize).init(std.testing.allocator);
    defer nums.deinit();

    var sum: usize = 0;
    while (it.next()) |s| {
        const num = try fmt.parseInt(usize, s, 10);
        try nums.append(num);
        sum += num;
    }

    std.sort.sort(usize, nums.items, {}, comptime std.sort.asc(usize));
    var avg = @floatToInt(usize, std.math.floor(@intToFloat(f32, sum) / @intToFloat(f32, nums.items.len)));
    //print("{d}, avg = {}\n", .{ nums.items, avg });

    var i: usize = 0;
    sum = 0;
    while (i < nums.items.len / 2) : (i += 1) {
        const start = nums.items[i];
        const end = nums.items[nums.items.len - 1 - i];

        sum += end - start;
    }
    print("p1 = {}", .{sum});

    var sum1: usize = 0;
    for (nums.items) |num| {
        i = 0;
        const d = if (num > avg) num - avg else avg - num;
        while (i < d) : (i += 1) {
            sum1 += i + 1;
        }
    }

    avg += 1;
    var sum2: usize = 0;
    for (nums.items) |num| {
        i = 0;
        const d = if (num > avg) num - avg else avg - num;
        while (i < d) : (i += 1) {
            sum2 += i + 1;
        }
    }
    print(", p2 = {}\n", .{std.math.min(sum1, sum2)});
}
