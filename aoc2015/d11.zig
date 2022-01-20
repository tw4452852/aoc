const std = @import("std");
const print = std.debug.print;

test "d11" {
    var input = [_]u8{ 'v', 'z', 'b', 'x', 'k', 'g', 'h', 'b' };
    const n = input.len;

    var count: usize = 0;
    while (count < 2) {
        input[n - 1] += 1;

        var i: usize = n - 1;
        while (i >= 0) : (i -= 1) {
            if (input[i] > 'z') {
                input[i] = 'a';
                if (i > 0) input[i - 1] += 1;
            }
            if (i == 0) break;
        }

        if (meetRequirements(&input)) {
            count += 1;
            if (count == 1) {
                print("part1 = {s}\n", .{input});
            } else {
                print("part2 = {s}\n", .{input});
            }
        }
    }
}

fn meetRequirements(input: []const u8) bool {
    var three = false;
    var pair: ?usize = null;

    for (input) |c, i| {
        if (c == 'i' or c == 'o' or c == 'l') return false;
        if (i >= 2 and input[i - 1] == c - 1 and input[i - 2] == c - 2) three = true;
        if (i >= 1 and input[i - 1] == c) {
            if (pair) |idx| {
                if (idx != i - 1 and idx != input.len and input[idx] != c) pair = input.len;
            } else {
                pair = i;
            }
        }
    }

    return three and pair != null and pair.? == input.len;
}
