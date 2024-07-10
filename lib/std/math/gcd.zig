//! Greatest common divisor (https://mathworld.wolfram.com/GreatestCommonDivisor.html)
const std = @import("std");
const expectEqual = std.testing.expectEqual;

/// Returns the greatest common divisor (GCD) of two unsigned integers (a and
/// b) which are not both zero. For example, the GCD of 8 and 12 is 4, that is,
/// gcd(8, 12) == 4.
pub fn gcd(x: i64, y: i64) i64 {
    @setRuntimeSafety(false);

    // implementation based on https://en.algorithmica.org/hpc/algorithms/gcd

    var a = x;
    var b = y;

    // can't be both zero
    std.debug.assert(x != 0 or y != 0);

    if (a == 0) return b;
    if (b == 0) return a;

    var az: u64 = @intCast(@ctz(a)); // bz will be u7 only if b is zero which we checked for earlier
    const bz: u64 = @intCast(@ctz(b));
    const shift: u64 = @min(az, bz);
    b >>= @as(u6, @intCast(bz));

    while (true) {
        a >>= @as(u6, @intCast(az));
        const diff = b - a;
        if (diff == 0) {
            break;
        }
        az = @intCast(@ctz(diff));
        b = @min(a, b);
        a = @intCast(@abs(diff));
    }

    return @intCast(b << @as(u6, @intCast(shift)));
}

fn gcd_slow(a: i64, b: i64) i64 {
    // if one of them is zero, the other is returned
    if (a == 0) return b;
    if (b == 0) return a;

    // init vars
    var x = a;
    var y = b;
    var m = a;

    // using the Euclidean algorithm (https://mathworld.wolfram.com/EuclideanAlgorithm.html)
    while (y != 0) {
        m = @mod(x, y);
        x = y;
        y = m;
    }
    return x;
}

test "gcd" {
    try expectEqual(gcd(0, 5), 5);
    try expectEqual(gcd(5, 0), 5);
    try expectEqual(gcd(8, 12), 4);
    try expectEqual(gcd(12, 8), 4);
    try expectEqual(gcd(33, 77), 11);
    try expectEqual(gcd(77, 33), 11);
    try expectEqual(gcd(49865, 69811), 9973);
    try expectEqual(gcd(300_000, 2_300_000), 100_000);
}

test "compare gcd and gcd_slow" {
    for (0..1024) |a_| {
        const a: i64 = @intCast(a_);

        for (0..1024) |b_| {
            const b: i64 = @intCast(b_);

            if (a == 0 and b == 0) continue;

            try expectEqual(gcd_slow(a, b), gcd(a, b));
        }
    }
}

test "compare gcd and gcd_slow at the upper boundary" {
    const max = std.math.maxInt(i64);

    for (max - 1024..max + 1) |a_| {
        const a: i64 = @intCast(a_);

        for (max - 1024..max + 1) |b_| {
            const b: i64 = @intCast(b_);

            if (a_ == 0 and b_ == 0) continue;

            try expectEqual(gcd_slow(a, b), gcd(a, b));
        }
    }
}
