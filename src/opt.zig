/// Consumes air, returns optimized oil
pub fn optimize(air: *Air, a: Allocator) !Oil {
    const oil: Oil = try .fromAir(air, a);

    // invoke passes from here

    return oil;
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const Air = @import("Air.zig");
const Oil = @import("opt/Oil.zig");
