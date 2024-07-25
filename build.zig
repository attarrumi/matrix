const std = @import("std");

pub const matrix = @import("src/main.zig"); // mark 1

pub fn build(b: *std.Build) !void {
    _ = b.addModule("matrix", .{ // mark 2
        .root_source_file = b.path("src/main.zig"),
    });
}
