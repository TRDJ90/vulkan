const std = @import("std");
const VulkanLoader = @import("vulkanloader.zig").VulkanLoader;
const c = @import("c.zig");
const vk = @import("vulkan");

pub fn main() !void {
    var loader = try VulkanLoader.init();
    defer loader.deinit();

    if (c.glfwInit() != c.GLFW_TRUE) return error.glfwInitFailed;
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);

    const window = c.glfwCreateWindow(800, 600, "Vulkan window", null, null) orelse return error.glfwWindowInitFailed;
    defer c.glfwDestroyWindow(window);

    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE) {
        c.glfwPollEvents();
    }
}
