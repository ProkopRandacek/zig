//! Optimizer immediate language

// All optimizations are currently isolated per function.
//
// Instruction parts:
// * Reference into the type puddle,
// * Control flow edge
// * First data edge
// * Second data edge

pub const Inst = packed struct {
    tag: Tag,
    data: Data,

    const Tag = enum(u8) {
        startcontrol, // Data: empty
        arg,
    };

    const Data = packed union {
        empty: void,
        ty: packed struct {
            type: Type.Ref,
        },
        ty_bin: packed struct {
            type: Type.Ref,
            lhs: Ref,
            rhs: Ref,
        },
        ty_cf: packed struct {
            type: Type.Ref,
            cfe: Ref,
        },
        ty_cf_bin: packed struct {
            type: Type.Ref,
            cfe: Ref,
            lhs: Ref,
            rhs: Ref,
        },
    };

    pub const Ref = if (false) enum(u16) { _ } else *Inst;

    pub fn startcontrol() Inst {
        return .{
            .tag = .startcontrol,
            .data = .{ .empty = {} },
        };
    }

    pub fn block(parent: Inst.Ref) Inst {
        return .{
            .tag = .block,
            .data = .{ .block = .{ .cfe = parent } },
        };
    }
};

insts: MemoryPool(Inst),
startcontrol: Inst.Ref,

pub fn print(oil: Oil) void {
    _ = oil;
    std.debug.print("haha hehe", .{});
}

comptime {
    if (false) {
        std.debug.assert(@sizeOf(Inst.Tag) == 1);
        std.debug.assert(@sizeOf(Inst.Data) == 8);
    }
}

pub const fromAir = @import("from_air.zig").fromAir;

const Oil = @This();
const std = @import("std");
const Allocator = std.mem.Allocator;
const InstMap = std.AutoArrayHashMapUnmanaged(Air.Inst.Ref, Oil.Inst.Ref);
const MemoryPool = std.heap.MemoryPool;
const Air = @import("../Air.zig");
const Type = @import("Type.zig");

// git show c04be63 --ext-diff

// TODO for later:
// write nice a pool allocator for instructions with 16b indexes instead of current 64b pointers
