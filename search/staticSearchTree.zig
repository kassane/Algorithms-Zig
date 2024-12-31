const std = @import("std");

/// Implements a basic static search tree algorithm at compile-time.
pub fn StaticSearchTree(comptime T: type, comptime data: []const T) type {
    return struct {
        const Self = @This();

        /// Searches for the given value.
        pub fn search(value: T) ?usize {
            return searchRecursive(0, data.len - 1, value);
        }

        fn searchRecursive(comptime start: usize, comptime end: usize, value: T) ?usize {
            if (start > end) return null;
            const mid = (start + end) / 2;
            if (data[mid] == value) {
                return @as(?usize, mid);
            }
            if (data[mid] < value) return searchRecursive(mid + 1, end, value);
            if (mid > 0) {
                return searchRecursive(start, mid - 1, value);
            } else {
                return null;
            }
        }

        /// Searches for the given value using SIMD.
        pub fn searchSIMD(value: T) ?usize {
            return searchSIMDRecursive(0, data.len - 1, value);
        }

        fn searchSIMDRecursive(comptime start: usize, comptime end: usize, value: T) ?usize {
            if (start > end) return null;
            const mid = (start + end) / 2;

            const value_vec: @Vector(4, T) = @splat(value);
            const mid_value: @Vector(4, T) = @splat(data[mid]);
            const eq_mask = @as(@Vector(4, bool), value_vec == mid_value);
            if (eq_mask[0]) {
                return @as(?usize, mid);
            }
            const gt_mask = @as(@Vector(4, bool), value_vec > mid_value);
            if (gt_mask[0]) {
                return searchSIMDRecursive(mid + 1, end, value);
            }
            if (mid > 0) {
                return searchSIMDRecursive(start, mid - 1, value);
            } else {
                return null;
            }
        }
    };
}

test "static search tree" {
    const data = [_]i32{ 1, 3, 5, 7, 9 };
    const SearchTree = StaticSearchTree(i32, &data);

    for (data, 0..) |v, i| {
        try std.testing.expectEqual(@as(?usize, i), SearchTree.search(@intCast(v)));
    }
    try std.testing.expectEqual(@as(?usize, null), SearchTree.search(2));
}

test "search for non-existent values" {
    const data = [_]i32{0} ** 6;
    const SearchTree = StaticSearchTree(i32, &data);

    try std.testing.expectEqual(@as(?usize, null), SearchTree.search(1));
    try std.testing.expectEqual(@as(?usize, null), SearchTree.search(2));
    try std.testing.expectEqual(@as(?usize, null), SearchTree.search(4));
    try std.testing.expectEqual(@as(?usize, null), SearchTree.search(6));
    try std.testing.expectEqual(@as(?usize, null), SearchTree.search(8));
    try std.testing.expectEqual(@as(?usize, null), SearchTree.search(10));
}

test "search for values at the beginning and end of the array" {
    const data = [_]i32{ 1, 3, 5, 7, 9 };
    const SearchTree = StaticSearchTree(i32, &data);

    try std.testing.expectEqual(@as(?usize, 0), SearchTree.search(1));
    try std.testing.expectEqual(@as(?usize, 4), SearchTree.search(9));
}

test "static search tree with SIMD" {
    const data = [_]i32{
        340, 341, 342, 343, 344, 345, 346, 347,
        348, 349, 350, 351, 352, 353, 354, 355,
        356, 357, 358, 359, 360, 361, 362, 363,
        364, 365, 366, 367, 368, 369, 370, 371,
        372, 373, 374, 375, 376, 377, 378, 379,
        380, 381, 382, 383, 384, 385, 386, 387,
        388, 389, 390, 391, 392, 393, 394, 395,
    };
    const SearchTree = StaticSearchTree(i32, &data);

    for (data, 0..) |v, i| {
        try std.testing.expectEqual(@as(?usize, i), SearchTree.searchSIMD(@intCast(v)));
    }
}
