const TypeRef = enum(u16) { _ }; // TODO: probably not enough bits.. Types come and go a lot when integer range analysis

const MeetLUTEntry = union(enum) {
    value: Type,
    lhs: void,
    rhs: void,
    handle_intint: void,
};

pub const Type = struct {
    pub const Tag = enum(u8) {
        top,
        topint,
        ctrl,
        int, // uses data as i64
        botint,
        bot,
    };

    // Only some types use this field (and bitcast it to something useful)
    // Types that don't use this value have to set it to 0.
    pub const Data = u64;

    pub const Ref = enum(u32) { _ };

    tag: Tag,
    data: Data,

    pub const top = Type{ .tag = .top, .data = 0 };
    pub const topint = Type{ .tag = .topint, .data = 0 };
    pub const ctrl = Type{ .tag = .ctrl, .data = 0 };
    pub const botint = Type{ .tag = .botint, .data = 0 };
    pub const bot = Type{ .tag = .bot, .data = 0 };

    // is left subtype of right?
    pub fn isSubType(left: Type, right: Type) bool {
        const equal_value = left.data == right.data;

        return switch (left.tag) {
            .top => switch (right.tag) {
                .top => true,
                .topint => false,
                .ctrl => false,
                .int => false,
                .botint => false,
                .bot => false,
            },
            .topint => switch (right.tag) {
                .top => true,
                .topint => true,
                .ctrl => false,
                .int => false,
                .botint => false,
                .bot => false,
            },
            .ctrl => switch (right.tag) {
                .top => true,
                .topint => false,
                .ctrl => true,
                .int => false,
                .botint => false,
                .bot => false,
            },
            .int => switch (right.tag) {
                .top => true,
                .topint => true,
                .ctrl => false,
                .int => equal_value,
                .botint => false,
                .bot => false,
            },
            .botint => switch (right.tag) {
                .top => true,
                .topint => true,
                .ctrl => false,
                .int => true,
                .botint => true,
                .bot => false,
            },
            .bot => switch (right.tag) {
                .top => true,
                .topint => true,
                .ctrl => true,
                .int => true,
                .botint => true,
                .bot => true,
            },
        };
    }

    pub fn meet(l: Type, r: Type) Type {
        if (l.isSubType(r)) {
            return l;
        }
        if (r.isSubType(l)) {
            return r;
        }

        // types are not comparable.

        // they are either different integer constants,
        if (l.tag == .int and r.tag == .int) {
            return .botint;
        }

        // or they are from different sublattices, in which case the result is bottom

        return .bot;
    }
};

const values: [7]Type = .{
    .top,
    .topint,
    .ctrl,
    .{ .tag = .int, .data = 10 },
    .{ .tag = .int, .data = 20 },
    .botint,
    .bot,
};

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

test "lattice meet commultative" {
    for (values) |x| {
        for (values) |y| {
            const l = x.meet(y);
            const r = y.meet(x);
            try testing.expectEqual(l, r);
        }
    }
}

test "lattice meet idempotent" {
    for (values) |x| {
        try testing.expectEqual(x, x.meet(x));
    }
}

test "lattice meet neutral element" {
    for (values) |x| {
        try testing.expectEqual(x, x.meet(.top));
    }
}

const std = @import("std");
const testing = std.testing;
