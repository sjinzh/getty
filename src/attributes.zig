const de = @import("de.zig");
const ser = @import("ser.zig");
const std = @import("std");

pub const Mode = enum {
    ser,
    de,
};

pub fn Attributes(comptime T: type, comptime mode: Mode, attributes: _Attributes(T, mode)) type {
    return struct {
        pub const _attributes = attributes;
    };
}

/// Returns an attribute map type.
///
/// `T` is a type that wants to implement the `Serialize` or `Deserialize`
/// interface.
///
/// The returned type is a struct that contains fields corresponding to each
/// field/variant in `T`, as well as a field named after `T`. These identifier
/// fields are structs containing various attributes. The attributes within an
/// identifier field depend on the identifier field. For identifier fields that
/// correspond to a field or variant in `T`, the attributes consists of field
/// or variant attributes. For the identifier field corresponding to the type
/// name of `T`, the attributes consist of container attributes. All fields in
/// `attributes` may be omitted.
fn _Attributes(comptime T: type, comptime mode: Mode) type {
    const Container = switch (mode) {
        .ser => struct {
            //bound: ,
            //content: ,
            into: []const u8 = "",
            rename: []const u8 = @typeName(T),
            rename_all: []const u8 = "",
            //remote: ,
            //tag: ,
            transparent: bool = false,
            //untagged: ,
        },
        .de => struct {
            //bound: ,
            //content: ,
            //default: ,
            deny_unknown_fields: bool = false,
            //from: ,
            into: []const u8 = "",
            rename: []const u8 = @typeName(T),
            rename_all: []const u8 = "",
            //remote: ,
            //tag: ,
            transparent: bool = false,
            //try_from:,
            //untagged: ,
        },
    };

    const Inner = switch (mode) {
        .ser => switch (@typeInfo(T)) {
            .Struct => struct {
                //bound: ,
                //flatten: ,
                //getter: ,
                rename: []const u8 = @typeName(T),
                skip: bool = false,
                //skip_serializing_if: ,
                with: []const u8 = "",
            },
            .Enum => struct {
                //bound: ,
                rename: []const u8 = "",
                rename_all: []const u8 = "",
                skip: bool = false,
                with: []const u8 = "",
            },
            else => unreachable,
        },
        .de => switch (@typeInfo(T)) {
            .Struct => struct {
                alias: []const u8 = "",
                //bound: ,
                //default: ,
                //flatten: ,
                rename: []const u8 = @typeName(T),
                skip: bool = false,
                with: []const u8 = "",
            },
            .Enum => struct {
                alias: []const u8 = "",
                //bound: ,
                other: bool = false,
                rename: []const u8 = @typeName(T),
                rename_all: []const u8 = "",
                skip: bool = false,
                with: []const u8 = "",
            },
            else => unreachable,
        },
    };

    const container = Container{};
    const inner = Inner{};

    comptime var fields: [std.meta.fields(T).len + 1]std.builtin.TypeInfo.StructField = undefined;

    inline for (std.meta.fields(T)) |field, i| {
        fields[i] = .{
            .name = field.name,
            .field_type = Inner,
            .default_value = inner,
            .is_comptime = true,
            .alignment = 4,
        };
    }

    fields[fields.len - 1] = .{
        .name = @typeName(T),
        .field_type = Container,
        .default_value = container,
        .is_comptime = true,
        .alignment = 4,
    };

    return @Type(std.builtin.TypeInfo{
        .Struct = .{
            .layout = .Auto,
            .fields = &fields,
            .decls = &[_]std.builtin.TypeInfo.Declaration{},
            .is_tuple = false,
        },
    });
}

test "Serialize - basic (struct)" {
    const TestPoint = struct {
        usingnamespace Attributes(@This(), .ser, .{});

        x: i32,
        y: i32,
    };
}

test "Serialize - with container attribute (struct)" {
    const TestPoint = struct {
        usingnamespace Attributes(@This(), .ser, .{ .TestPoint = .{ .rename = "A" } });

        x: i32,
        y: i32,
    };
}

test "Serialize - with field attribute (struct)" {
    const TestPoint = struct {
        usingnamespace Attributes(@This(), .ser, .{ .x = .{ .rename = "a" } });

        x: i32,
        y: i32,
    };
}