fn fromAirBody(
    zcu: *const Zcu,
    air: *const Air,
    oil: *Oil,
    inst_map: *Oil.InstMap,
    current_block: Oil.Inst.Ref,
    body: []const Air.Inst.Index,
) !void {
    const tags: []const Air.Inst.Tag = air.instructions.items(.tag);
    const data: []const Air.Inst.Data = air.instructions.items(.data);
    for (body) |inst| {
        const tag = tags[@intFromEnum(inst)];
        const dat = data[@intFromEnum(inst)];
        switch (tag) {
            .arg => {
                const arg = dat.arg;
                const ins: Oil.Inst.Ref = try oil.insts.create();

                const res_ty = arg.ty.toType();

                const t: Type = switch (res_ty.toIntern()) {};

                const ty: Type = if (res_ty.isInt(zcu))
                    .botint
                else
                    @panic("well shit");

                ins.* = .{
                    .tag = .arg,
                    .data = .{ .ty = {} },
                };
            },
            .block => {
                const pl_idx = dat.ty_pl.payload;
                const extra = air.extraData(Air.Block, pl_idx);
                const inner: []const Air.Inst.Index = @ptrCast(air.extra.items[extra.end..][0..extra.data.body_len]);

                fromAirBody(air, oil, inst_map, current_block, inner);
            },
            .br => { // break

            },
        }
    }
}

pub fn fromAir(air: *const Air, alc: Allocator) !Oil {
    var pool: MemoryPool(Oil.Inst) = .init(alc);
    const start_control: *Oil.Inst = try pool.create();
    const current_block: *Oil.Inst = try pool.create();

    start_control.* = .startcontrol();
    current_block.* = .block(start_control);

    var oil: Oil = .{
        .insts = pool,
        .startcontrol = start_control,
    };

    var inst_map: Oil.InstMap = .empty;
    defer inst_map.deinit(alc);

    try fromAirBody(air, &oil, &inst_map, &current_block, air.getMainBody());

    return oil;
}

const std = @import("std");
const Allocator = std.mem.Allocator;

const Oil = @import("Oil.zig");
const MemoryPool = std.heap.MemoryPool;
const Air = @import("../Air.zig");
const Type = @import("Type.zig");
