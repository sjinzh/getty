const std = @import("std");

pub fn is(comptime T: type) bool {
    return std.mem.startsWith(u8, @typeName(T), "std.linked_list.TailQueue");
}

pub fn serialize(value: anytype, serializer: anytype) @TypeOf(serializer).Error!@TypeOf(serializer).Ok {
    const seq = (try serializer.serializeSequence(value.len)).seq();
    {
        var iterator = value.first;
        while (iterator) |node| : (iterator = node.next) {
            try seq.serializeElement(node.data);
        }
    }
    return try seq.end();
}
