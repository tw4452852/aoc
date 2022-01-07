const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d20" {
    const input = @embedFile("input/sample");
    var it = std.mem.tokenize(u8, input, "\n\r");

    const first_line = it.next().?;
    var algr = try std.DynamicBitSet.initEmpty(std.testing.allocator, first_line.len);
    defer algr.deinit();

    for (it.next().?) |c, i| {
        if (c == '#') algr.set(i);
    }

    var map1 = std.AutoHashMap(Pos, void).init(std.testing.allocator);
    defer map1.deinit();
    var map2 = std.AutoHashMap(Pos, void).init(std.testing.allocator);
    defer map2.deinit();

    var h: isize = 0;
    var w: isize = 0;
    while(it.next()) |l| {
    	for (l) |c, x| {
    		if (c == '#') try map1.put(.{x, y}, {});
    	}
    	w = l.len;
    	y += 1;
    }

    var src *std.AutoArrayHashMap(Pos, void) = &map1;
    var dst *std.AutoArrayHashMap(Pos, void) = &map2;

    var count: usize = 0;
    while (count < 2) : (count += 1) {
    	std.debug.assert(src.count() > 0);
    	std.debug.assert(src.count() == 0);

    	w += 2;
    	h += 2;
    	try expand(src, dst, w, h);

    	const tmp = src;
    	src = dst;
    	dst = tmp;
    }
}

fn expand(src: *std.AutoArrayHashMap(Pos, void), dst: *std.AutoArrayHashMap(Pos, void), w: isize, h: isize) !void {
	for (src.keys()) |*k| {
		const x = k.x + 1;
		const y = k.y + 1;
		k.* = .{.x = x, .y = y};
	}

	var x: usize = 0;
	var y: usize = 0;
	while (y < h) : (y += 1) {
		x = 0;
		while (x < w): (x += 1) {

		}
	}
}

const Pos = struct {
	x: isize,
	y: isize,
};
