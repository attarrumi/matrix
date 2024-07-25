const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
var r = std.Random.DefaultPrng.init(0);
const rand = r.random();

pub fn metrics(comptime T: type) type {
    return struct {
        const this = @This();
        data: []T,
        rows: usize,
        cols: usize,
        allocator: std.mem.Allocator,

        fn init(allocator: std.mem.Allocator, rows: usize, cols: usize) !*this {
            var matrix = try allocator.create(this);
            matrix.data = try allocator.alloc(T, rows * cols);
            matrix.rows = rows;
            matrix.cols = cols;
            matrix.allocator = allocator;
            return matrix;
        }

        pub fn init_data(allocator: std.mem.Allocator, rows: usize, cols: usize, data: []const T) !*this {
            const matrix = try init(allocator, rows, cols);
            @memcpy(matrix.data, data);
            return matrix;
        }

        pub fn init_zero(allocator: std.mem.Allocator, rows: usize, cols: usize) !*this {
            const matrix = try init(allocator, rows, cols);
            @memset(matrix.data, std.mem.zeroes(T));
            return matrix;
        }

        pub fn deinit(self: *this) void {
            self.allocator.free(self.data);
            self.allocator.destroy(self);
        }

        pub fn randomize(self: *this) void {
            for (self.data) |*elem| {
                elem.* = @floatCast(rand.float(f64) * 2 - 1);
            }
        }

        pub fn mul(self: *const this, other: *const this) *this {
            assert(self.cols == other.rows);
            const result = init(self.allocator, self.rows, other.cols) catch unreachable;
            for (result.data, 0..) |*elem, idx| {
                const i = idx / other.cols;
                const j = idx % other.cols;
                elem.* = 0;
                for (self.data[i * self.cols .. (i + 1) * self.cols], 0..) |a, k| {
                    elem.* += a * other.data[k * other.cols + j];
                }
            }
            return result;
        }

        pub fn add(self: *const this, other: *const this) *this {
            assert(self.rows == other.rows and self.cols == other.cols);

            const result = init(self.allocator, self.rows, self.cols) catch unreachable;
            for (result.data, 0..) |*elem, idx| {
                elem.* = self.data[idx] + other.data[idx];
            }
            return result;
        }

        pub fn sub(self: *const this, other: *const this) *this {
            assert(self.rows == other.rows and self.cols == other.cols);
            const result = init(self.allocator, self.rows, self.cols) catch unreachable;
            for (result.data, 0..) |*elem, idx| {
                elem.* = self.data[idx] - other.data[idx];
            }
            return result;
        }

        pub fn transpose(self: *const this) *this {
            const result = init(self.allocator, self.cols, self.rows) catch unreachable;
            for (result.data, 0..) |*elem, idx| {
                const i = idx / self.cols; // Corrected to use self.cols
                const j = idx % self.cols; // Corrected to use self.cols
                elem.* = self.data[j * self.rows + i]; // Corrected to use self.rows
            }
            return result;
        }

        pub fn mulElem(self: *const this, other: *const this) *this {
            assert(self.rows == other.rows and self.cols == other.cols);
            const result = init(self.allocator, self.rows, self.cols) catch unreachable;
            for (result.data, 0..) |*elem, idx| {
                elem.* = self.data[idx] * other.data[idx];
            }
            return result;
        }

        pub fn apply(self: *const this, func: fn (T) T) *this {
            const result = init(self.allocator, self.rows, self.cols) catch unreachable;
            for (result.data, 0..) |*elem, idx| {
                elem.* = func(self.data[idx]);
            }
            return result;
        }

        pub fn addScalar(self: *const this, scalar: T) *this {
            const result = init(self.allocator, self.rows, self.cols) catch unreachable;
            for (result.data, 0..) |*elem, idx| {
                elem.* = self.data[idx] + scalar;
            }
            return result;
        }

        pub fn mulScalar(self: *const this, scalar: T) *this {
            const result = init(self.allocator, self.rows, self.cols) catch unreachable;
            for (result.data, 0..) |*elem, idx| {
                elem.* = self.data[idx] * scalar;
            }
            return result;
        }

        pub fn set(self: *this, i: usize, j: usize, value: T) void {
            self.data[i * self.cols + j] = value;
        }

        pub fn copy(self: *const this, other: *const this) void {
            @memcpy(self.data, other.data);
        }

        pub fn print(self: *const this) void {
            for (self.data, 0..) |elem, idx| {
                std.debug.print("{d} ", .{elem});
                if ((idx + 1) % self.cols == 0) {
                    std.debug.print("\n", .{});
                }
            }
        }

        pub fn sigmoid(x: T) T {
            return 1.0 / (1.0 + std.math.exp(-x));
        }

        pub fn dsigmoid(x: T) T {
            return sigmoid(x) * (1 - sigmoid(x));
        }
    };
}
