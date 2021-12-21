const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d16" {
    const input = @embedFile("input/d16");

    var bytes: [input.len / 2]u8 = undefined;
    _ = try fmt.hexToBytes(&bytes, input);

    var parser: Parser = .{
        .reader = std.io.bitReader(.Big, std.io.fixedBufferStream(@as([]const u8, &bytes)).reader()),
    };

    const part2 = parser.packet();
    print("part1 = {}, part2 = {}\n", .{ parser.part1, part2 });
}

const Parser = struct {
    reader: std.io.BitReader(.Big, std.io.FixedBufferStream([]const u8).Reader),
    pos: usize = 0,
    part1: u64 = 0,

    const Self = @This();

    const Type = enum {
        sum,
        prod,
        min,
        max,
        literal,
        gt,
        lt,
        eq,
    };

    fn nextBits(self: *Self, len: usize) u64 {
        self.pos += len;
        return self.reader.readBitsNoEof(u64, len) catch unreachable;
    }

    pub fn packet(self: *Self) u64 {
        const version = self.nextBits(3);
        const type_id = self.nextBits(3);
        self.part1 += version;

        const typ = @intToEnum(Type, type_id);
        return switch (typ) {
            .literal => self.literal(),
            .gt, .lt, .eq => self.compare(typ),
            else => self.operator(typ),
        };
    }

    fn compare(self: *Self, typ: Type) u64 {
        const len_type_id = self.nextBits(1);
        _ = self.nextBits(if (len_type_id == 0) 15 else 11);
        const l = self.packet();
        const r = self.packet();
        return switch (typ) {
            .lt => @boolToInt(l < r),
            .gt => @boolToInt(l > r),
            .eq => @boolToInt(l == r),
            else => unreachable,
        };
    }

    fn literal(self: *Self) u64 {
        var num: u64 = 0;
        while (true) {
            const chunk = self.nextBits(5);
            const n = chunk & 0xf;
            num <<= 4;
            num |= n;
            if (chunk & 0x10 == 0) break;
        }
        return num;
    }

    fn operator(self: *Self, typ: Type) u64 {
        const len_type_id = self.nextBits(1);
        var num: u64 = switch (typ) {
            .max, .sum => 0,
            .prod => 1,
            .min => std.math.maxInt(u64),
            else => unreachable,
        };
        if (len_type_id == 0) {
            const len = self.nextBits(15);
            const end = self.pos + len;
            while (self.pos != end) {
                const sub = self.packet();
                switch (typ) {
                    .max => num = std.math.max(num, sub),
                    .min => num = std.math.min(num, sub),
                    .sum => num += sub,
                    .prod => num *= sub,
                    else => unreachable,
                }
            }
        } else {
            const n = self.nextBits(11);
            var i: usize = 0;
            while (i < n) : (i += 1) {
                const sub = self.packet();
                switch (typ) {
                    .max => num = std.math.max(num, sub),
                    .min => num = std.math.min(num, sub),
                    .sum => num += sub,
                    .prod => num *= sub,
                    else => unreachable,
                }
            }
        }
        return num;
    }
};
