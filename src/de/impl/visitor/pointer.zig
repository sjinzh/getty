const std = @import("std");
const getty = @import("../../../lib.zig");
const visitors = @import("../visitor.zig");

pub fn Visitor(comptime T: type) type {
    if (@typeInfo(T) != .Pointer or @typeInfo(T).Pointer.size != .One) {
        @compileError("expected one pointer, found `" ++ @typeName(T) ++ "`");
    }

    const Value = T;
    const Child = std.meta.Child(T);
    const ChildVisitor = switch (@typeInfo(Child)) {
        .Array => visitors.ArrayVisitor(Child),
        .Bool => visitors.BoolVisitor,
        .Enum => visitors.EnumVisitor(Child),
        .Float, .ComptimeFloat => visitors.FloatVisitor(Child),
        .Int, .ComptimeInt => visitors.IntVisitor(Child),
        .Optional => visitors.OptionalVisitor(Child),
        .Pointer => |info| switch (info.size) {
            .One => visitors.PointerVisitor(Child),
            .Slice => visitors.SliceVisitor(Child),
            else => @compileError("pointer type is not supported"),
        },
        .Struct => |info| switch (info.is_tuple) {
            false => visitors.StructVisitor(Child),
            true => @compileError("tuple deserialization is not supported"),
        },
        .Void => visitors.VoidVisitor,
        else => @compileError("type `" ++ @typeName(Child) ++ "` is not supported"),
    };

    return struct {
        allocator: *std.mem.Allocator,

        const Self = @This();

        /// Implements `getty.de.Visitor`.
        pub usingnamespace getty.de.Visitor(
            *Self,
            Value,
            _V.visitBool,
            _V.visitEnum,
            _V.visitFloat,
            _V.visitInt,
            _V.visitMap,
            _V.visitNull,
            _V.visitSequence,
            _V.visitString,
            _V.visitSome,
            _V.visitVoid,
        );

        const _V = struct {
            fn visitBool(self: *Self, comptime Error: type, input: bool) Error!Value {
                const value = try self.allocator.create(Child);
                errdefer self.allocator.destroy(value);

                var v = childVisitor(self.allocator);
                value.* = try v.visitor().visitBool(Error, input);
                return value;
            }

            fn visitEnum(self: *Self, comptime Error: type, input: anytype) Error!Value {
                const value = try self.allocator.create(Child);
                errdefer self.allocator.destroy(value);

                var v = childVisitor(self.allocator);
                value.* = try v.visitor().visitEnum(Error, input);
                return value;
            }

            fn visitFloat(self: *Self, comptime Error: type, input: anytype) Error!Value {
                const value = try self.allocator.create(Child);
                errdefer self.allocator.destroy(value);

                var v = childVisitor(self.allocator);
                value.* = try v.visitor().visitFloat(Error, input);
                return value;
            }

            fn visitInt(self: *Self, comptime Error: type, input: anytype) Error!Value {
                const value = try self.allocator.create(Child);
                errdefer self.allocator.destroy(value);

                var v = childVisitor(self.allocator);
                value.* = try v.visitor().visitInt(Error, input);
                return value;
            }

            fn visitMap(self: *Self, mapAccess: anytype) @TypeOf(mapAccess).Error!Value {
                const value = try self.allocator.create(Child);
                errdefer self.allocator.destroy(value);

                var v = childVisitor(self.allocator);
                value.* = try v.visitor().visitMap(mapAccess);
                return value;
            }

            fn visitNull(self: *Self, comptime Error: type) Error!Value {
                const value = try self.allocator.create(Child);
                errdefer self.allocator.destroy(value);

                var v = childVisitor(self.allocator);
                value.* = try v.visitor().visitNull(Error);
                return value;
            }

            fn visitSequence(self: *Self, sequenceAccess: anytype) @TypeOf(sequenceAccess).Error!Value {
                const value = try self.allocator.create(Child);
                errdefer self.allocator.destroy(value);

                var v = childVisitor(self.allocator);
                value.* = try v.visitor().visitSequence(sequenceAccess);
                return value;
            }

            fn visitString(self: *Self, comptime Error: type, input: anytype) Error!Value {
                const value = try self.allocator.create(Child);
                errdefer self.allocator.destroy(value);

                var v = childVisitor(self.allocator);
                value.* = try v.visitor().visitString(Error, input);
                return value;
            }

            fn visitSome(self: *Self, deserializer: anytype) @TypeOf(deserializer).Error!Value {
                const value = try self.allocator.create(Child);
                errdefer self.allocator.destroy(value);

                var v = childVisitor(self.allocator);
                value.* = try v.visitor().visitSome(deserializer);
                return value;
            }

            fn visitVoid(self: *Self, comptime Error: type) Error!Value {
                const value = try self.allocator.create(Child);
                errdefer self.allocator.destroy(value);

                var v = childVisitor(self.allocator);
                value.* = try v.visitor().visitVoid(Error);
                return value;
            }
        };

        fn childVisitor(allocator: *std.mem.Allocator) ChildVisitor {
            return switch (@typeInfo(Child)) {
                .Array, .Bool, .ComptimeFloat, .ComptimeInt, .Enum, .Float, .Int, .Void => .{},
                .Optional, .Pointer, .Struct => .{ .allocator = allocator },
                else => unreachable,
            };
        }
    };
}
