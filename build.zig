const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("tcc-zig", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    addTcc(exe);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

fn addTcc(exe: *std.build.LibExeObjStep) void {
    // for (tcc_files) |tcc_file| {
    //     const c_path = std.fs.path.join(b.allocator, &.{ "tinycc", tcc_file }) catch unreachable;
    //     exe.addCSourceFile(c_path, &.{});
    // }
    // exe.addIncludePath("tinycc");
    var b = exe.builder;
    const src_path = std.fs.path.dirname(@src().file) orelse ".";
    const tcc_path = std.fs.path.join(b.allocator, &.{ src_path, "tinycc" }) catch unreachable;

    const configure_step = b.addSystemCommand(&.{"./configure", "--enable-static", "--config-predefs=yes", "--extra-cflags=-fPIC -g -O2 -static", "--prefix=/usr",
                                                 "--libdir=/usr/lib64"});
    configure_step.cwd = "./tinycc";

    const make_step = b.addSystemCommand(&.{"make"});
    // configure_step.setEnvironmentVariable("CFLAGS", "-DTCC_LIBTCC1=");
    // configure_step.setEnvironmentVariable("CFLAGS", "-DTCC_LIBTCC1='\"\"'");
    make_step.cwd = "./tinycc";

    exe.linkLibC();
    exe.linkSystemLibrary("tcc");
    exe.addLibPath(tcc_path);

    exe.step.dependOn(&configure_step.step);
    exe.step.dependOn(&make_step.step);
}

const tcc_files = [_][]const u8 {
    "arm-asm.c",
    "arm-gen.c",
    "arm-link.c",
    "arm64-asm.c",
    "arm64-gen.c",
    "arm64-link.c",
    "c67-gen.c",
    "c67-link.c",
    "conftest.c",
    "i386-asm.c",
    "i386-gen.c",
    "i386-link.c",
    "il-gen.c",
    "libtcc.c",
    "riscv64-asm.c",
    "riscv64-gen.c",
    "riscv64-link.c",
    "tcc.c",
    "tccasm.c",
    "tcccoff.c",
    "tccdbg.c",
    "tccelf.c",
    "tccgen.c",
    "tccmacho.c",
    "tccpe.c",
    "tccpp.c",
    "tccrun.c",
    "tcctools.c",
    "x86_64-gen.c",
    "x86_64-link.c",
};
