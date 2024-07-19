const std = @import("std");
const window = @import("platform/window_glfw.zig");
const Renderer = @import("renderer.zig").Renderer;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try window.init(1280, 720, "test vulkan");
    defer window.deinit();

    _ = try Renderer.init(allocator, try window.getWindow());

    while (!window.windowClosed()) {
        window.update();
    }
}
