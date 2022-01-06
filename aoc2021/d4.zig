const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d4" {
    const input = @embedFile("input/d4");
    var it = std.mem.tokenize(u8, input, "\r\n");

    const firstLine = it.next().?;
    var inputNums = std.ArrayList(isize).init(std.testing.allocator);
    defer inputNums.deinit();

    var firstLineIt = std.mem.tokenize(u8, firstLine, ",");
    while (firstLineIt.next()) |s| {
        try inputNums.append(try fmt.parseInt(isize, s, 10));
    }

    var boards = std.ArrayList(Board).init(std.testing.allocator);
    defer boards.deinit();
    while (it.rest().len != 0) {
        var b: Board = undefined;
        try b.init(&it);
        try boards.append(b);
    }

    var notWinned = boards.items.len;
    for (inputNums.items) |num| {
        for (boards.items) |*board| {
            if (board.isWon()) continue;
            const sum = board.mark(num);
            if (sum != null) {
                notWinned -= 1;
                if (notWinned == boards.items.len - 1) {
                    // Winner.
                    print("p1 = {}", .{num * sum.?});
                }
                if (notWinned == 0) {
                    // Loser.
                    print(", p2 = {}\n", .{num * sum.?});
                }
            }
        }
    }
}

const Board = struct {
    numbers: [5][5]isize,
    won: bool = false,
    const Self = @This();

    pub fn init(self: *Self, it: *std.mem.TokenIterator(u8)) !void {
        comptime var i = 0;
        inline while (i < 5) : (i += 1) {
            const line = it.next().?;
            var parts = std.mem.tokenize(u8, line, " ");
            comptime var j = 0;
            inline while (j < 5) : (j += 1) {
                const s = parts.next().?;
                const num = try fmt.parseInt(isize, s, 10);
                self.numbers[i][j] = num;
            }
        }
    }

    pub fn mark(self: *Self, v: isize) ?isize {
        var needCheck = false;

        for (self.numbers) |*row| {
            for (row) |*num| {
                if (num.* != v) continue;

                num.* = -1;
                needCheck = true;
            }
        }

        if (needCheck) {
            if (self.hasRowAllMarked() or self.hasColAllMarked()) {
                self.won = true;
                return self.sumUnmarked();
            }
        }
        return null;
    }

    pub fn isWon(self: *Self) bool {
        return self.won;
    }

    fn sumUnmarked(self: *Self) isize {
        var r: isize = 0;
        for (self.numbers) |row| {
            for (row) |num| {
                if (num > 0) r += num;
            }
        }
        return r;
    }

    fn hasRowAllMarked(self: *Self) bool {
        outer: for (self.numbers) |row| {
            for (row) |num| {
                if (num >= 0) continue :outer;
            }
            return true;
        }
        return false;
    }

    fn hasColAllMarked(self: *Self) bool {
        var col: usize = 0;
        var row: usize = 0;
        outer: while (col < 5) : (col += 1) {
            row = 0;
            while (row < 5) : (row += 1) {
                if (self.numbers[row][col] >= 0) continue :outer;
            }
            return true;
        }
        return false;
    }
};
