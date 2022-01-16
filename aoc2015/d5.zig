const std = @import("std");
const print = std.debug.print;

test "d5" {
    const input = @embedFile("input/d5");
    var lines = std.mem.tokenize(u8, input, "\n\r");

    var p1: usize = 0;
    var p2: usize = 0;
    while (lines.next()) |l| {
        if (is_nice1(l)) p1 += 1;
        if (is_nice2(l)) p2 += 1;
    }

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

fn is_nice1(s: []const u8) bool {
    var vowels: usize = 0;
    var in_row = false;

    for (s) |c, i| {
        if (i > 0) {
            const part = s[i - 1 .. i + 1];
            if (std.mem.eql(u8, part, "ab") or
                std.mem.eql(u8, part, "cd") or
                std.mem.eql(u8, part, "pq") or
                std.mem.eql(u8, part, "xy")) return false;
        }
        if (c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u') vowels += 1;
        if (i > 0 and s[i - 1] == c) in_row = true;
    }

    return in_row and vowels >= 3;
}

fn is_nice2(s: []const u8) bool {
    var cond1 = false;
    var cond2 = false;
    for (s) |c, i| {
        if (cond1 and cond2) return true;
        if (i >= 2 and s[i - 2] == c) cond2 = true;
        if (i >= 3) {
            const pair = s[i - 1 .. i + 1];
            if (std.mem.indexOf(u8, s[0 .. i - 1], pair)) |_| {
                cond1 = true;
            }
        }
    }
    return cond1 and cond2;
}
