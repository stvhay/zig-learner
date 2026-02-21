// Zig 0.15.2 std.atomic — API signatures + doc comments

/// This is a thin wrapper around a primitive value to prevent accidental data races.
pub fn Value(comptime T: type) type

pub fn init(value: T) Self

pub inline fn load(self: *const Self, comptime order: AtomicOrder) T

pub inline fn store(self: *Self, value: T, comptime order: AtomicOrder) void

pub inline fn swap(self: *Self, operand: T, comptime order: AtomicOrder) T

pub inline fn cmpxchgWeak(

pub inline fn cmpxchgStrong(

pub inline fn fetchAdd(self: *Self, operand: T, comptime order: AtomicOrder) T

pub inline fn fetchSub(self: *Self, operand: T, comptime order: AtomicOrder) T

pub inline fn fetchMin(self: *Self, operand: T, comptime order: AtomicOrder) T

pub inline fn fetchMax(self: *Self, operand: T, comptime order: AtomicOrder) T

pub inline fn fetchAnd(self: *Self, operand: T, comptime order: AtomicOrder) T

pub inline fn fetchNand(self: *Self, operand: T, comptime order: AtomicOrder) T

pub inline fn fetchXor(self: *Self, operand: T, comptime order: AtomicOrder) T

pub inline fn fetchOr(self: *Self, operand: T, comptime order: AtomicOrder) T

pub inline fn rmw(

        /// Marked `inline` so that if `bit` is comptime-known, the instruction
        /// can be lowered to a more efficient machine code instruction if
        /// possible.
pub inline fn bitSet(self: *Self, bit: Bit, comptime order: AtomicOrder) u1

        /// Marked `inline` so that if `bit` is comptime-known, the instruction
        /// can be lowered to a more efficient machine code instruction if
        /// possible.
pub inline fn bitReset(self: *Self, bit: Bit, comptime order: AtomicOrder) u1

        /// Marked `inline` so that if `bit` is comptime-known, the instruction
        /// can be lowered to a more efficient machine code instruction if
        /// possible.
pub inline fn bitToggle(self: *Self, bit: Bit, comptime order: AtomicOrder) u1

/// Signals to the processor that the caller is inside a busy-wait spin-loop.
pub inline fn spinLoopHint() void

pub fn cacheLineForCpu(cpu: std.Target.Cpu) u16
