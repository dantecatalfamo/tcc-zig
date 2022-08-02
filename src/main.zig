const std = @import("std");
const tcc = @import("tcc.zig");

pub fn main() anyerror!void {
    // Note that info level log messages are by default printed only in Debug
    // and ReleaseSafe build modes.
    std.log.info("All your codebase are belong to us.", .{});
    var t = try tcc.new();

    std.log.info("{d}", .{t});
    t.add_library_path("/usr/lib64");
    t.set_lib_path("tinycc");
    // const src_path = std.fs.path.dirname(@src().file) orelse ".";
    // const tcc_path = std.fs.path.joinZ(std.heap.page_allocator, &.{ src_path, "tinycc" }) catch unreachable;
    // t.set_lib_path(tcc_path);
    try t.compile_string(prog);
    const ret = t.run(&.{});
    std.log.info("Returned {d}", .{ ret });
}

const prog =
    \\ int main() {
    \\    return 4;
    \\ }
;

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
