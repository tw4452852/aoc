const std = @import("std");
const print = std.debug.print;
const json = std.json;

test "d12" {
    const input = @embedFile("input/d12");
    var parser = json.Parser.init(std.testing.allocator, false);
    defer parser.deinit();

    var p1: i64 = 0;
    var p2: i64 = 0;
    var tree = try parser.parse(input);
    defer tree.deinit();
    const root = tree.root;
    iterate(&root, &p1, false);
    iterate(&root, &p2, true);

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

fn iterate(v: *const json.Value, sum: *i64, skip_red: bool) void {
    switch (v.*) {
        .Integer => |n| {
            sum.* += n;
        },
        .Array => |a| for (a.items) |*i| {
            iterate(i, sum, skip_red);
        },
        .Object => |m| {
            if (!skip_red) {
                for (m.values()) |*i| {
                    iterate(i, sum, skip_red);
                }
            } else {
                const values = m.values();
                const contain_red = blk: {
                    for (values) |value| switch (value) {
                        .String => |s| if (std.mem.eql(u8, s, "red")) break :blk true,
                        else => {},
                    };
                    break :blk false;
                };
                if (!contain_red) for (values) |*i| {
                    iterate(i, sum, skip_red);
                };
            }
        },
        .Float => unreachable,
        else => {},
    }
}
