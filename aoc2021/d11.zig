const std = @import("std");
const fmt = std.fmt;
const print = std.debug.print;

test "d11" {
    const input = @embedFile("input/d11");
    var it = std.mem.tokenize(u8, input, "\n\r");

    var octopus = std.ArrayList(isize).init(std.testing.allocator);
    defer octopus.deinit();

    var width: usize = 0;
    while (it.next()) |line| {
        if (width == 0) width = line.len;
        for (line) |c| {
            try octopus.append(c - '0');
        }
    }

    var step: usize = 0;
    var part1: usize = 0;
    while (true) : (step += 1) {
        const count = try oneStep(octopus.items, width);
        if (step < 100) part1 += count;
        if (count == octopus.items.len) break;
    }

    print("part1 = {}, part2 = {}\n", .{ part1, step + 1 });
}

fn oneStep(octopus: []isize, width: usize) !usize {
    var count: usize = 0;

    var pending = std.ArrayList(usize).init(std.testing.allocator);
    defer pending.deinit();

    for (octopus) |*level, i| {
        level.* += 1;
        if (level.* > 9) try pending.append(i);
    }

    while (pending.items.len != 0) {
        try propagate(octopus, &pending, width);
    }

    for (octopus) |*level| {
        if (level.* > 9) {
            count += 1;
            level.* = 0;
        }
    }
    return count;
}

fn propagate(octopus: []isize, pending: *std.ArrayList(usize), width: usize) !void {
    const i = pending.pop();
    const x = i % width;
    std.debug.assert(octopus[i] > 9);

    if (i -% width < octopus.len) {
        octopus[i - width] += 1;
        if (octopus[i - width] == 10) try pending.append(i - width);
    }
    if (i -% (width + 1) < octopus.len and x > 0) {
        octopus[i - (width + 1)] += 1;
        if (octopus[i - (width + 1)] == 10) try pending.append(i - (width + 1));
    }
    if (i -% (width - 1) < octopus.len and x < width - 1) {
        octopus[i - (width - 1)] += 1;
        if (octopus[i - (width - 1)] == 10) try pending.append(i - (width - 1));
    }
    if (x > 0) {
        octopus[i - 1] += 1;
        if (octopus[i - 1] == 10) try pending.append(i - 1);
    }
    if (x < width - 1) {
        octopus[i + 1] += 1;
        if (octopus[i + 1] == 10) try pending.append(i + 1);
    }
    if (i + (width - 1) < octopus.len and x > 0) {
        octopus[i + (width - 1)] += 1;
        if (octopus[i + (width - 1)] == 10) try pending.append(i + (width - 1));
    }
    if (i + width < octopus.len) {
        octopus[i + width] += 1;
        if (octopus[i + width] == 10) try pending.append(i + width);
    }
    if (i + width + 1 < octopus.len and x < width - 1) {
        octopus[i + width + 1] += 1;
        if (octopus[i + width + 1] == 10) try pending.append(i + width + 1);
    }
}
