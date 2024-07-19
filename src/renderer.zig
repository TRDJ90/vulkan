const std = @import("std");
const vk = @import("vulkan");
const VulkanLoader = @import("vulkanloader.zig").VulkanLoader;
const c = @import("c.zig");

const apis: []const vk.ApiInfo = &.{
    .{
        .base_commands = .{
            .createInstance = true,
        },
        .instance_commands = .{
            .createDevice = true,
            .destroyInstance = true,
        },
    },
    vk.features.version_1_2,
    vk.extensions.khr_portability_enumeration,
};

const BaseDispatch = vk.BaseWrapper(apis);
const InstanceDispatch = vk.InstanceWrapper(apis);

const Instance = vk.InstanceProxy(apis);

pub const Renderer = struct {
    allocator: std.mem.Allocator,
    vkb: BaseDispatch,

    instance: Instance,
    surface: vk.SurfaceKHR,

    pub fn init(allocator: std.mem.Allocator, window: *c.GLFWwindow) !Renderer {
        var renderer: Renderer = undefined;

        var loader = try VulkanLoader.init();
        defer loader.deinit();

        renderer.allocator = allocator;
        renderer.vkb = try BaseDispatch.load(loader.get_instance_proc_addr);

        // Extensions for instance creation
        var extension_list = std.ArrayList([*c]const u8).init(allocator);
        defer extension_list.deinit();

        // Gather and add glfw extensions to the extension list
        var glfw_extensions_count: u32 = 0;
        const glfw_extensions = c.glfwGetRequiredInstanceExtensions(&glfw_extensions_count);

        var i: u8 = 0;
        while (i < glfw_extensions_count) : (i += 1) {
            try extension_list.append(glfw_extensions[i]);
        }

        // Add MacOS specific extension not completely sure if this needed tho, given this is also already defined
        // in apis at the top of the file.
        try extension_list.append(vk.extensions.khr_portability_enumeration.name);

        const app_info = vk.ApplicationInfo{
            .p_application_name = "",
            .application_version = vk.makeApiVersion(0, 0, 0, 0),
            .p_engine_name = "",
            .engine_version = vk.makeApiVersion(0, 0, 0, 0),
            .api_version = vk.API_VERSION_1_2,
        };

        const instance = try renderer.vkb.createInstance(&.{
            .p_application_info = &app_info,
            .enabled_extension_count = @intCast(extension_list.items.len),
            .pp_enabled_extension_names = @ptrCast(extension_list.items.ptr),
            .flags = vk.InstanceCreateFlags{
                .enumerate_portability_bit_khr = true,
            },
        }, null);

        const vki = try allocator.create(InstanceDispatch);
        errdefer allocator.destroy(vki);

        vki.* = try InstanceDispatch.load(instance, loader.get_instance_proc_addr);
        renderer.instance = Instance.init(instance, vki);
        errdefer renderer.instance.destroyInstance(null);

        // Create surface
        var surface: vk.SurfaceKHR = undefined;
        if (c.glfwCreateWindowSurface(renderer.instance.handle, window, null, &surface) != .success) {
            return error.SurfaceInitFailed;
        }
        errdefer surface.destroySurfaceKHR(surface, null);
        renderer.surface = surface;

        // Get device candidate
        //var candidate: vk.DeviceCandidate

        return renderer;
    }

    const DeviceCandidate = struct {
        pdev: vk.PhysicalDevice,
        props: vk.PhysicalDeviceProperties,
        queues: QueueAllocation,
    };

    const QueueAllocation = struct {
        graphics_family: u32,
        present_family: u32,
    };
};
