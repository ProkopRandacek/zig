//! Optimizer immediate language

// All optimizations are currently isolated per function.
//
// Instruction parts:
// * Reference into the type puddle,
// * Control flow edge
// * First data edge
// * Second data edge

const Inst = packed struct {
    tag: Tag,
    data: Data,

    const Tag = enum(u8) {
        start,

        projfarg,

        sconst, // small const, 40 bits
    };

    const Data = packed union {
        empty: void,
        type: Type.Ref,
        clr: packed struct {
            cfe: Ref,
            lhs: Ref,
            rhs: Ref,
        },
        lr: packed struct {
            lhs: Ref,
            rhs: Ref,
        },
        cst: packed struct {
            value: u40,
        },
    };

    /// Reference to an OIL instruction
    pub const Ref = enum(u16) { _ };
};

insts: MemoryPool(Inst),
start: Inst.Ref,

fn fromAirBody(air: *const Air, oil: *Oil, body: []const Air.Inst.Index) void {
    _ = oil;
    const tags: []const Air.Inst.Tag = air.instructions.items(.tag);
    const data: []const Air.Inst.Data = air.instructions.items(.data);

    for (body) |inst| {
        const tag = tags[@intFromEnum(inst)];
        const dat = data[@intFromEnum(inst)];
        _ = dat;
        switch (tag) {
            .arg => {
                const arg = data[@intFromEnum(inst)].arg;
                _ = arg;
            },
        }
    }
}

pub fn fromAir(air: *const Air, alc: Allocator) !Oil {
    var pool: MemoryPool(Inst) = .init(alc);
    const start_node = try pool.create();

    start_node.* = Inst{
        .tag = .start,
        .data = .{.empty},
    };

    var oil: Oil = .{
        .instructions = pool,
        .start = start_node,
    };

    fromAirBody(air, &oil, air.getMainBody());

    return oil;
}

pub fn print(oil: Oil) void {
    _ = oil;
    std.debug.print("haha hehe", .{});
}

comptime {
    std.debug.assert(@sizeOf(Inst.Tag) == 1);
    std.debug.assert(@sizeOf(Inst.Data) == 8);
}

const Oil = @This();
const std = @import("std");
const Allocator = std.mem.Allocator;
const MemoryPool = std.heap.MemoryPool;
const Air = @import("../Air.zig");
const Type = @import("Type.zig").Type;

// git show c04be63 --ext-diff
