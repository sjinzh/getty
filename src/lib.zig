//! A serialization and deserialization framework for the Zig programming
//! language.
//!
//! The main contribution of Getty is its data model, a set of types that
//! establishes a generic baseline from which serializers and deserializers can
//! operate. By working within Getty's data model, the set of possible
//! inputs/outputs for a serializer/deserializer is reduced from all possible
//! types in Zig to a subset of the types within the data model.
//!
//! Any type that is mapped to Getty's data model automatically becomes
//! (de)serializable. Out of the box, Getty maps a number of Zig types,
//! including many standard library types (e.g., std.ArrayList,
//! std.StringHashMap). For types that aren't already supported by Getty,
//! custom "with blocks" can be provided to specify how a type can be
//! serialized or deserialized into.

/// Serialization framework.
pub usingnamespace @import("ser.zig");

/// Deserialization framework.
pub usingnamespace @import("de.zig");

/// Compile-time type restraints for various Getty data types.
pub const concepts = struct {
    pub usingnamespace @import("ser/concept/map.zig");
    pub usingnamespace @import("ser/concept/serializer.zig");
    pub usingnamespace @import("ser/concept/seq.zig");
    pub usingnamespace @import("ser/concept/structure.zig");
    pub usingnamespace @import("ser/concept/with.zig");

    pub usingnamespace @import("de/concept/deserializer.zig");
    pub usingnamespace @import("de/concept/map.zig");
    pub usingnamespace @import("de/concept/seed.zig");
    pub usingnamespace @import("de/concept/seq.zig");
    pub usingnamespace @import("de/concept/visitor.zig");
    pub usingnamespace @import("de/concept/with.zig");
};
