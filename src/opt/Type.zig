// Main Lattice:
//                top
//                 |
//  +-----+-----+--+--+-----+-----+
//  |     |     |     |     |     |
// ctr   flt   int   mem   ptr   sct
//  |     |     |     |     |     |
//  +-----+-----+--+--+-----+-----+
//                 |
//                bot
//
// Control Lattice:
//                top
//                 |
//                bot
//
// Float Lattice:
//                top
//                 |
//               val[N] for N some float constant
//                 |
//                bot
//
// Int Lattice:
//                top[B] B: bitwidth
//                 |
//               val[B][N] B: bitwidth, N: int constant
//                 |
//                bot[B] B: bitwidth
//
// Mem Lattice:
//                top
//                 |
//               val[#N] for N some id of this memory
//                 |
//                bot
//
// Ptr Lattice: XXX
//                top
//                 |
//                bot
//
// Struct Lattice: XXX
//                top
//                 |
//                bot

pub const Type = union(enum) {
    top: void,
    bot: void,

    ctr: Ctr,
    flt: Flt,
    int: Int,
    mem: Mem,
    ptr: Ptr,

    // TODO: struct

    pub fn meet(l: Type, r: Type) Type {
        if (l == .top) return r;
        if (r == .top) return l;
        if (l == .bot) return l;
        if (r == .bot) return r;

        return switch (l) {
            .ctr => |lv| switch (r) {
                .ctr => |rv| .{ .ctr = lv.meet(rv) },
                else => .bot,
            },
            .int => |lv| switch (r) {
                .int => |rv| lv.meet(rv),
                else => .bot,
            },
            .flt => |lv| switch (r) {
                .flt => |rv| lv.meet(rv),
                else => .bot,
            },
            .mem => |lv| switch (r) {
                .mem => |rv| .{ .mem = lv.meet(rv) },
                else => .bot,
            },
            .ptr => |lv| switch (r) {
                .ptr => |rv| .{ .ptr = lv.meet(rv) },
                else => .bot,
            },
            .top, .bot => unreachable,
        };
    }
};

pub const Ctr = union(enum) {
    top: void,
    bot: void,

    pub fn meet(l: Ctr, r: Ctr) Ctr {
        return if (l == .top and r == .top) .top else .bot;
    }
};

pub const Flt = union(enum) {
    top_f16: void,
    val_f16: f16,
    bot_f16: void,

    top_f32: void,
    val_f32: f32,
    bot_f32: void,

    top_f64: void,
    val_f64: f64,
    bot_f64: void,

    top_f80: void,
    val_f80: f80,
    bot_f80: void,

    top_f128: void,
    val_f128: f128,
    bot_f128: void,

    pub fn meet(l: Flt, r: Flt) Type {
        return switch (l) {
            // zig fmt: off
            .val_f16  => |lv| switch (r) { .val_f16  => |rv| .{ .flt = if (lv == rv) l else .bot_f16  }, .top_f16  => .{.flt=l}, .bot_f16  => .{.flt=r}, else => .bot, },
            .val_f32  => |lv| switch (r) { .val_f32  => |rv| .{ .flt = if (lv == rv) l else .bot_f32  }, .top_f32  => .{.flt=l}, .bot_f32  => .{.flt=r}, else => .bot, },
            .val_f64  => |lv| switch (r) { .val_f64  => |rv| .{ .flt = if (lv == rv) l else .bot_f64  }, .top_f64  => .{.flt=l}, .bot_f64  => .{.flt=r}, else => .bot, },
            .val_f80  => |lv| switch (r) { .val_f80  => |rv| .{ .flt = if (lv == rv) l else .bot_f80  }, .top_f80  => .{.flt=l}, .bot_f80  => .{.flt=r}, else => .bot, },
            .val_f128 => |lv| switch (r) { .val_f128 => |rv| .{ .flt = if (lv == rv) l else .bot_f128 }, .top_f128 => .{.flt=l}, .bot_f128 => .{.flt=r}, else => .bot, },

            .top_f16  => switch (r) { .top_f16 , .val_f16 , .bot_f16  => .{ .flt = r }, else => .bot, },
            .top_f32  => switch (r) { .top_f32 , .val_f32 , .bot_f32  => .{ .flt = r }, else => .bot, },
            .top_f64  => switch (r) { .top_f64 , .val_f64 , .bot_f64  => .{ .flt = r }, else => .bot, },
            .top_f80  => switch (r) { .top_f80 , .val_f80 , .bot_f80  => .{ .flt = r }, else => .bot, },
            .top_f128 => switch (r) { .top_f128, .val_f128, .bot_f128 => .{ .flt = r }, else => .bot, },

            .bot_f16  => switch (r) { .top_f16 , .val_f16 , .bot_f16  => .{ .flt = l }, else => .bot, },
            .bot_f32  => switch (r) { .top_f32 , .val_f32 , .bot_f32  => .{ .flt = l }, else => .bot, },
            .bot_f64  => switch (r) { .top_f64 , .val_f64 , .bot_f64  => .{ .flt = l }, else => .bot, },
            .bot_f80  => switch (r) { .top_f80 , .val_f80 , .bot_f80  => .{ .flt = l }, else => .bot, },
            .bot_f128 => switch (r) { .top_f128, .val_f128, .bot_f128 => .{ .flt = l }, else => .bot, },
            // zig fmt: on
        };
    }
};

pub const Int = struct {
    signed: bool,
    width: u6,

    val: union(enum) {
        top: void,
        val: u64,
        bot: void,
    },

    pub fn meet(l: Int, r: Int) Type {
        if (l.signed != r.signed or l.width != r.width) {
            return .bot;
        }

        const bot: Int = .{ .signed = l.signed, .width = l.width, .val = .{ .bot = {} } };

        return .{ .int = switch (l.val) {
            .top => r,
            .bot => bot,
            .val => |lv| switch (r.val) {
                .top => l,
                .bot => bot,
                .val => |rv| if (lv == rv) l else bot,
            },
        } };
    }
};

pub const Mem = union(enum) {
    top: void,
    val: u32,
    bot: void,

    pub fn meet(l: Mem, r: Mem) Mem {
        return switch (l) {
            .top => r,
            .bot => .bot,
            .val => |lv| switch (r) {
                .top => .{ .val = lv },
                .bot => .bot,
                .val => |rv| if (lv == rv) l else .bot,
            },
        };
    }
};

pub const Ptr = union(enum) {
    top: void,
    val: Ref,
    bot: void,

    pub fn meet(l: Ptr, r: Ptr) Ptr {
        return switch (l) {
            .top => r,
            .bot => .bot,
            .val => |lv| switch (r) {
                .top => .{ .val = lv },
                .bot => .bot,
                .val => |rv| if (lv == rv) l else .bot,
            },
        };
    }
};

pub const Ref = enum(u32) { _ };

const values: [48]Type = .{
    .{ .top = {} },
    .{ .bot = {} },

    .{ .ctr = .top },
    .{ .ctr = .bot },

    .{ .flt = .{ .top_f16 = {} } },
    .{ .flt = .{ .val_f16 = 0.1 } },
    .{ .flt = .{ .val_f16 = 0.2 } },
    .{ .flt = .{ .bot_f16 = {} } },

    .{ .flt = .{ .top_f32 = {} } },
    .{ .flt = .{ .val_f32 = 0.1 } },
    .{ .flt = .{ .val_f32 = 0.2 } },
    .{ .flt = .{ .bot_f32 = {} } },

    .{ .flt = .{ .top_f64 = {} } },
    .{ .flt = .{ .val_f64 = 0.1 } },
    .{ .flt = .{ .val_f64 = 0.2 } },
    .{ .flt = .{ .bot_f64 = {} } },

    .{ .flt = .{ .top_f80 = {} } },
    .{ .flt = .{ .val_f80 = 0.1 } },
    .{ .flt = .{ .val_f80 = 0.2 } },
    .{ .flt = .{ .bot_f80 = {} } },

    .{ .flt = .{ .top_f128 = {} } },
    .{ .flt = .{ .val_f128 = 0.1 } },
    .{ .flt = .{ .val_f128 = 0.2 } },
    .{ .flt = .{ .bot_f128 = {} } },

    .{ .int = .{ .signed = true, .width = 12, .val = .{ .top = {} } } },
    .{ .int = .{ .signed = true, .width = 12, .val = .{ .val = 1 } } },
    .{ .int = .{ .signed = true, .width = 12, .val = .{ .val = 2 } } },
    .{ .int = .{ .signed = true, .width = 12, .val = .{ .bot = {} } } },

    .{ .int = .{ .signed = true, .width = 13, .val = .{ .top = {} } } },
    .{ .int = .{ .signed = true, .width = 13, .val = .{ .val = 1 } } },
    .{ .int = .{ .signed = true, .width = 13, .val = .{ .val = 2 } } },
    .{ .int = .{ .signed = true, .width = 13, .val = .{ .bot = {} } } },

    .{ .int = .{ .signed = false, .width = 12, .val = .{ .top = {} } } },
    .{ .int = .{ .signed = false, .width = 12, .val = .{ .val = 1 } } },
    .{ .int = .{ .signed = false, .width = 12, .val = .{ .val = 2 } } },
    .{ .int = .{ .signed = false, .width = 12, .val = .{ .bot = {} } } },

    .{ .int = .{ .signed = false, .width = 13, .val = .{ .top = {} } } },
    .{ .int = .{ .signed = false, .width = 13, .val = .{ .val = 1 } } },
    .{ .int = .{ .signed = false, .width = 13, .val = .{ .val = 2 } } },
    .{ .int = .{ .signed = false, .width = 13, .val = .{ .bot = {} } } },

    .{ .mem = .{ .top = {} } },
    .{ .mem = .{ .val = 0 } },
    .{ .mem = .{ .val = 1 } },
    .{ .mem = .{ .bot = {} } },

    .{ .ptr = .{ .top = {} } },
    .{ .ptr = .{ .val = @enumFromInt(0) } },
    .{ .ptr = .{ .val = @enumFromInt(1) } },
    .{ .ptr = .{ .bot = {} } },
};

test "lattice meet neutral element" {
    for (values) |x| {
        try testing.expectEqual(x, x.meet(.top));
    }
}

test "lattice meet idempotent" {
    for (values) |x| {
        try testing.expectEqual(x, x.meet(x));
    }
}

test "lattice meet commultative" {
    for (values) |x| {
        for (values) |y| {
            const l = x.meet(y);
            const r = y.meet(x);
            try testing.expectEqual(l, r);
        }
    }
}

test "lattice meet associative" {
    for (values) |x| {
        for (values) |y| {
            for (values) |z| {
                const l = x.meet(y).meet(z);
                const r = x.meet(y.meet(z));
                try testing.expectEqual(l, r);
            }
        }
    }
}

const std = @import("std");
const testing = std.testing;
//const InternPool = @import("../InternPool.zig");
//pub fn fromIP(ip: *const InternPool, ty: InternPool.Index) Type { return switch (ty) { .u0_type, .i0_type, .u1_type, .u8_type, .i8_type, .u16_type, .i16_type, .u29_type, .u32_type, .i32_type, .u64_type, .i64_type, .u80_type, .u128_type, .i128_type, .u256_type, .usize_type, .isize_type, .c_char_type, .c_short_type, .c_ushort_type, .c_int_type, .c_uint_type, .c_long_type, .c_ulong_type, .c_longlong_type, .c_ulonglong_type, .c_longdouble_type, .f16_type, .f32_type, .f64_type, .f80_type, .f128_type, .anyopaque_type, .bool_type, .void_type, .type_type, .anyerror_type, .comptime_int_type, .comptime_float_type, .noreturn_type, .anyframe_type, .null_type, .undefined_type, .enum_literal_type, .ptr_usize_type, .ptr_const_comptime_int_type, .manyptr_u8_type, .manyptr_const_u8_type, .manyptr_const_u8_sentinel_0_type, .slice_const_u8_type, .slice_const_u8_sentinel_0_type, .vector_8_i8_type, .vector_16_i8_type, .vector_32_i8_type, .vector_64_i8_type, .vector_1_u8_type, .vector_2_u8_type, .vector_4_u8_type, .vector_8_u8_type, .vector_16_u8_type, .vector_32_u8_type, .vector_64_u8_type, .vector_2_i16_type, .vector_4_i16_type, .vector_8_i16_type, .vector_16_i16_type, .vector_32_i16_type, .vector_4_u16_type, .vector_8_u16_type, .vector_16_u16_type, .vector_32_u16_type, .vector_2_i32_type, .vector_4_i32_type, .vector_8_i32_type, .vector_16_i32_type, .vector_4_u32_type, .vector_8_u32_type, .vector_16_u32_type, .vector_2_i64_type, .vector_4_i64_type, .vector_8_i64_type, .vector_2_u64_type, .vector_4_u64_type, .vector_8_u64_type, .vector_1_u128_type, .vector_2_u128_type, .vector_1_u256_type, .vector_4_f16_type, .vector_8_f16_type, .vector_16_f16_type, .vector_32_f16_type, .vector_2_f32_type, .vector_4_f32_type, .vector_8_f32_type, .vector_16_f32_type, .vector_2_f64_type, .vector_4_f64_type, .vector_8_f64_type, .optional_noreturn_type, .anyerror_void_error_union_type, .adhoc_inferred_error_set_type, .generic_poison_type, .empty_tuple_type, .undef, .undef_bool, .undef_usize, .undef_u1, .zero, .zero_usize, .zero_u1, .zero_u8, .one, .one_usize, .one_u1, .one_u8, .four_u8, .negative_one, .void_value, .unreachable_value, .null_value, .bool_true, .bool_false, .empty_tuple, .none => unreachable, .usize_type, .isize_type, .c_char_type, .c_short_type, .c_ushort_type, .c_int_type, .c_uint_type, .c_long_type, .c_ulong_type, .c_longlong_type, .c_ulonglong_type => .botint, _ => switch (ty.unwrap(ip).getTag(ip)) { .type_int_signed, .type_int_unsigned, => true, else => false, }, }; }
