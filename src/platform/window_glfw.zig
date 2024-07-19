const c = @import("../c.zig");

var window: *c.GLFWwindow = undefined;

pub fn init(width: i32, height: i32, title: [:0]const u8) !void {
    if (c.glfwInit() != c.GLFW_TRUE) return error.glfwWindowFailed;
    c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);

    const glfw_window = c.glfwCreateWindow(width, height, title, null, null) orelse return error.glfwWindowFailed;
    window = glfw_window;
}

pub fn deinit() void {
    c.glfwDestroyWindow(window);
    c.glfwTerminate();
}

pub fn getWindow() !*c.GLFWwindow {
    if (window == undefined) {
        return error.glfwWindowNotInitialised;
    }
    return window;
}

pub fn windowClosed() bool {
    return c.glfwWindowShouldClose(window) == c.GLFW_TRUE;
}

pub fn update() void {
    c.glfwPollEvents();
}
