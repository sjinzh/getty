const std = @import("std");

const DefaultSeed = @import("../impls/seed/default.zig").DefaultSeed;

/// Deserialization and access interface for variants of Getty Unions.
pub fn VariantAccess(
    /// A namespace that owns the method implementations passed to the `methods` parameter.
    comptime Context: type,
    /// The error set returned by the interface's methods upon failure.
    comptime E: type,
    /// A namespace containing the methods that implementations of `VariantAccess` can implement.
    comptime methods: struct {
        payloadSeed: ?@TypeOf(struct {
            fn f(_: Context, _: ?std.mem.Allocator, seed: anytype) E!@TypeOf(seed).Value {
                unreachable;
            }
        }.f) = null,

        // Provided method.
        payload: ?@TypeOf(struct {
            fn f(_: Context, _: ?std.mem.Allocator, comptime T: type) E!T {
                unreachable;
            }
        }.f) = null,
    },
) type {
    return struct {
        /// An interface type.
        pub const @"getty.de.VariantAccess" = struct {
            context: Context,

            const Self = @This();

            pub const Error = E;

            pub fn payloadSeed(self: Self, allocator: ?std.mem.Allocator, seed: anytype) Error!@TypeOf(seed).Value {
                if (methods.payloadSeed) |f| {
                    return try f(self.context, allocator, seed);
                }

                @compileError("payloadSeed is not implemented by type: " ++ @typeName(Context));
            }

            pub fn payload(self: Self, allocator: ?std.mem.Allocator, comptime T: type) Error!T {
                if (methods.payload) |f| {
                    return try f(self.context, allocator, T);
                } else {
                    var ds = DefaultSeed(T){};
                    const seed = ds.seed();

                    return try self.payloadSeed(allocator, seed);
                }
            }
        };

        /// Returns an interface value.
        pub fn variantAccess(self: Context) @"getty.de.VariantAccess" {
            return .{ .context = self };
        }
    };
}
