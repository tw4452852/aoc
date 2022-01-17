const std = @import("std");
const print = std.debug.print;
const fmt = std.fmt;

test "d4" {
    var steps: usize = 1;
    var p1: usize = 0;
    var p2: usize = 0;
    const concurrent = 9;
    var handles: [concurrent]std.Thread = undefined;

    for (handles) |*handle| {
        handle.* = try std.Thread.spawn(.{}, check, .{ &steps, &p1, &p2 });
    }
    for (handles) |handle| {
        handle.join();
    }

    print("part1 = {}, part2 = {}\n", .{ p1, p2 });
}

fn check(psteps: *usize, p1: *usize, p2: *usize) !void {
    const key = "iwrupvqb";

    var buf: [128]u8 = undefined;
    var digest: [std.crypto.hash.Md5.digest_length]u8 = undefined;

    while (true) {
        if (@atomicLoad(usize, p1, .SeqCst) != 0 and @atomicLoad(usize, p2, .SeqCst) != 0) return;

        const steps = @atomicRmw(usize, psteps, .Add, 1, .SeqCst);
        const input = try fmt.bufPrint(&buf, "{s}{}", .{ key, steps });
        std.crypto.hash.Md5.hash(input, &digest, .{});
        const output = try fmt.bufPrint(&buf, "{:02}", .{fmt.fmtSliceHexUpper(&digest)});
        if (@atomicLoad(usize, p1, .SeqCst) == 0 and std.mem.startsWith(u8, output, "00000")) {
            @atomicStore(usize, p1, steps, .SeqCst);
        }
        if (@atomicLoad(usize, p2, .SeqCst) == 0 and std.mem.startsWith(u8, output, "000000")) {
            @atomicStore(usize, p2, steps, .SeqCst);
        }
    }
}
