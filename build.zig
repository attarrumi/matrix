const std = @import("std");

pub const zcmd = @import("src/main.zig"); // mark 1

pub fn build(b: *std.Build) !void {
    _ = b.addModule("matrix", .{ // mark 2
        .source_file = .{ .path = "src/main.zig" },
    });
}
