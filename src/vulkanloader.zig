const std = @import("std");
const builtin = @import("builtin");
const vk = @import("vulkan");

// Got this from: https://www.youtube.com/watch?v=DPe4SxsUWyo
pub const VulkanLoader = struct {
    const Self = @This();
    const library_names = switch (builtin.os.tag) {
        .windows => &[_][]const u8{"vulkan-1.dll"},
        .ios, .macos, .tvos, .watchos => &[_][]const u8{
            "libvulkan.dylib",
        },
        else => &[_][]const u8{ "libvulkan.so.1", "libvulkan.so" },
    };

    handle: std.DynLib,
    get_instance_proc_addr: vk.PfnGetInstanceProcAddr,
    get_device_proc_addr: vk.PfnGetDeviceProcAddr,

    pub fn init() !Self {
        for (library_names) |library_name| {
            if (std.DynLib.open(library_name)) |library| {
                var handle = library;
                errdefer handle.close();
                return .{
                    .handle = handle,
                    .get_instance_proc_addr = handle.lookup(vk.PfnGetInstanceProcAddr, "vkGetInstanceProcAddr") orelse return error.InitializationFailed,
                    .get_device_proc_addr = handle.lookup(vk.PfnGetDeviceProcAddr, "vkGetDeviceProcAddr") orelse return error.InitializationFailed,
                };
            } else |err| {
                std.debug.print("{any}", .{err});
            }
        }
        return error.InitilizationFailed;
    }

    pub fn deinit(self: *Self) void {
        self.handle.close();
    }
};
