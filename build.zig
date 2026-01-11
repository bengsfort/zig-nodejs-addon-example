const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("zig_nodejs_addon_test", .{
        .root_source_file = b.path("src/addon.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const lib = b.addLibrary(.{
        .name = "zig_nodejs_addon_test",
        .linkage = .dynamic,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
        .root_module = mod,
    });

    // TODO: This should be dynamic, not hardcoded.
    const home_dir = std.posix.getenv("HOME") orelse ".";
    const node_ver = "23.7.0";
    const node_include_path = b.fmt("{s}/.cache/node-gyp/{s}/include/node", .{ home_dir, node_ver });
    lib.addIncludePath(.{ .cwd_relative = node_include_path });

    const dll = b.addInstallArtifact(lib, .{ .dest_dir = .{ .override = .lib }, .dest_sub_path = "../zig-addon.node" });
    b.default_step.dependOn(&dll.step);
}
