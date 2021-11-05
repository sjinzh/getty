const std = @import("std");
const getty = @import("../../../lib.zig");

pub fn Visitor(comptime Slice: type) type {
    return struct {
        allocator: *std.mem.Allocator,

        const Self = @This();
        const impl = @"impl Visitor"(Slice);

        pub usingnamespace getty.de.Visitor(
            Self,
            impl.visitor.Value,
            undefined,
            undefined,
            undefined,
            undefined,
            undefined,
            undefined,
            impl.visitor.visitSequence,
            impl.visitor.visitString,
            undefined,
            undefined,
        );
    };
}

fn @"impl Visitor"(comptime Slice: type) type {
    const Self = Visitor(Slice);

    return struct {
        pub const visitor = struct {
            pub const Value = Slice;

            pub fn visitSequence(self: Self, seqAccess: anytype) @TypeOf(seqAccess).Error!Value {
                var list = std.ArrayList(Child).init(self.allocator);
                errdefer getty.de.free(self.allocator, list);

                while (try seqAccess.nextElement(Child)) |elem| {
                    try list.append(elem);
                }

                return list.toOwnedSlice();
            }

            pub fn visitString(self: Self, comptime Error: type, input: anytype) Error!Value {
                // TODO: This type check (and InvalidType error) is a temporary
                // workaround for the case where the child type of `Value` isn't a
                // u8. In that situation, the compiler keeps both the .ArrayBegin
                // and the .String branches, which results in a compiler error since
                // `TokenStream.slice` returns a `[]const u8` and we can't `dupe` into,
                // say, a `[]const u32` from that.
                //
                // Maybe what we could do is use `visitSequence` and in the JSON
                // deserializer figure out what to do in the SequenceAccess based
                // on whether the input is an Array or a String. If this works, do we
                // even need a `visitString` method?
                if (Child == u8) {
                    return try self.allocator.dupe(std.meta.Child(Value), input);
                }

                return error.InvalidType;
            }

            const Child = std.meta.Child(Value);
        };
    };
}
