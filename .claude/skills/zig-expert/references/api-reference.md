# Zig API Reference (0.15.2)

## Zig-Specific Syntax

Patterns that don't exist in C/Go/Rust — include because Zig training data is sparse.

```zig
// for: payload capture + optional index
for (items) |item| { ... }
for (items, 0..) |item, i| { ... }
for (a, b) |x, y| { ... }  // multi-object iteration

// while with optional: idiomatic iterator
while (iter.next()) |item| { ... }

// Tagged union + exhaustive switch with payload
const val: Shape = .{ .circle = 5.0 };
switch (val) { .circle => |r| pi * r * r, .rect => |rc| rc.w * rc.h, .point => 0 }

// Labeled blocks for complex init
const x = blk: { var v: u32 = 1; for (0..5) |_| v *= 2; break :blk v; };

// @This() for self-referencing generic types
fn Stack(comptime T: type) type { return struct { const Self = @This(); ... }; }

// Strings: []const u8 (no dedicated type). Literals: [:0]const u8 (sentinel).
// Multiline: \\ prefixed lines. Comptime concat: "a" ++ "b".
```

## Types

### Pointer/Slice Types
| Type | Description | `.len`? | Bounds-checked? |
|------|-------------|---------|-----------------|
| `*T` / `*const T` | Single pointer | No | N/A |
| `[*]T` | Many-pointer (like C `T*`) | No | **No** |
| `[*:0]T` | Sentinel-terminated many-ptr | No | No |
| `*[N]T` | Pointer to array | Yes (N) | Yes |
| `[]T` / `[]const T` | Slice (ptr + len) | Yes | **Yes** |
| `[:0]T` | Sentinel-terminated slice | Yes | Yes |
| `?*T` | Optional (nullable) pointer | No | N/A |
| `*anyopaque` | Void pointer — `@ptrCast(@alignCast(...))` to use | No | N/A |

### Packed/Extern Structs
```zig
const Flags = packed struct { lo: u4, hi: u4 };
const byte: u8 = @bitCast(Flags{ .lo = 0xA, .hi = 0x5 }); // 0x5A (lo = low bits)
// extern struct = C-compatible layout with C padding rules
```

### Casting Builtins
`@intCast` (narrow int), `@floatCast` (narrow float), `@floatFromInt`, `@intFromFloat` (truncates), `@ptrCast`, `@alignCast` (required from `*anyopaque`), `@bitCast` (reinterpret bits), `@as(T, val)` (type annotation). Implicit widening: u8→u32 automatic.

### Arithmetic Operators
`+%`/`-%`/`*%` (wrapping), `+|`/`-|`/`*|` (saturating), `@addWithOverflow(a,b)` → `{result, overflow_bit}`.

## Collections

```zig
// ArrayList: .empty, allocator per-method
var list: std.ArrayList(i32) = .empty;
defer list.deinit(gpa);
try list.append(gpa, 42);
try list.appendSlice(gpa, &.{1, 2, 3});
try list.ensureTotalCapacity(gpa, 100);
list.clearRetainingCapacity();  // reuse without realloc
_ = list.orderedRemove(0);     // O(n), preserves order
_ = list.swapRemove(0);        // O(1), breaks order
std.sort.pdq(i32, list.items, {}, std.sort.asc(i32));

// HashMap: .init(gpa), allocator stored
var map = std.AutoHashMap(i32, []const u8).init(gpa);
defer map.deinit();
try map.put(1, "one");
if (map.get(1)) |val| { ... }
const gop = try map.getOrPut(key);  // atomic get-or-insert
if (!gop.found_existing) gop.value_ptr.* = compute();

// StringHashMap: keys NOT freed by deinit — free manually
var smap = std.StringHashMap(i32).init(gpa);
defer { var it = smap.keyIterator(); while (it.next()) |k| gpa.free(k.*); smap.deinit(); }
```

### Data Structure Summary
| Structure | Init | Alloc | Ptr Stable? |
|-----------|------|-------|-------------|
| ArrayList | `.empty` | per-method | No |
| AutoHashMap | `.init(gpa)` | stored | No |
| MultiArrayList | `.{}` | per-method | No |
| SegmentedList(T, N) | `.{}` | per-method | **Yes** |
| PriorityQueue | `.init(gpa, ctx)` | stored | No |
| StaticBitSet(N) | `.initEmpty()` | none | N/A |
| DynamicBitSet | `initEmpty(gpa, n)` | stored | No |
| EnumSet(E) | `.initEmpty()` | none | N/A |
| EnumArray(E, V) | `.initFill(val)` | none | N/A |
| EnumMap(E, V) | `.init(.{...})` | none | N/A |
| DoublyLinkedList | `.{}` | none (intrusive) | **Yes** |
| StaticStringMap(V) | `.initComptime(.{...})` | none | N/A |

**PriorityQueue:** compareFn returns `std.math.Order` (NOT bool). Use `std.math.order(a, b)` for min-heap, `std.math.order(b, a)` for max-heap.

**DoublyLinkedList:** Intrusive — embed `Node` in struct, recover parent with `@fieldParentPtr("node", node_ptr)`. `len()` is a method, not a field.

**MultiArrayList:** SoA layout. Access fields: `list.slice().items(.x)` → `[]f32`.

## Strings
```zig
std.mem.eql(u8, a, b)                  // equality
std.mem.startsWith(u8, s, prefix)      // prefix check
std.mem.indexOf(u8, haystack, needle)  // ?usize
std.mem.trim(u8, s, " ")              // strip
std.mem.splitScalar(u8, data, ',')     // iterator (keeps empty parts)
std.mem.tokenizeScalar(u8, data, ' ')  // iterator (skips consecutive)
std.mem.span(c_str)                    // [*:0]const u8 → []const u8
std.mem.sliceTo(&data, 0)             // scan for sentinel, return slice
std.mem.replaceOwned(u8, gpa, s, "old", "new")  // allocating replace
std.mem.concat(gpa, u8, &.{"a", "b"})           // runtime concat
std.ascii.toLower(c)                   // single char
// Unicode: std.unicode.Utf8View.initUnchecked(s).iterator()
```

## I/O
```zig
// stdout/stderr/stdin: see 0.15.2 corrections in SKILL.md

// File operations
const file = try std.fs.cwd().openFile("path", .{});
defer file.close();
const stat = try file.stat();         // stat.size = file size
const all = try std.fs.cwd().readFileAlloc(gpa, "path", max_size);
defer gpa.free(all);

// GOTCHA: file.readAll(buf) returns usize (bytes read), NOT the buffer
const n = try file.readAll(buf);
const content = buf[0..n];

// GOTCHA: file.reader(&buf) → File.Reader — no .read() method!
// Use file.read(&buf) directly for raw byte reading in loops

// In-memory stream
var buf: [1024]u8 = undefined;
var fbs = std.io.fixedBufferStream(&buf);
try fbs.writer().print("hello {d}", .{42});
const written = fbs.getWritten();

// Paths
std.fs.path.extension("file.txt")    // ".txt"
std.fs.path.basename("/a/b/c.txt")   // "c.txt"
std.fs.path.join(gpa, &.{"/a", "b"}) // allocating
```

## JSON
```zig
// Parse dynamic
const parsed = try std.json.parseFromSlice(std.json.Value, gpa, json_str, .{});
defer parsed.deinit();
const name = parsed.value.object.get("name").?.string;

// Parse into struct
const result = try std.json.parseFromSlice(MyStruct, gpa, json_str, .{
    .ignore_unknown_fields = true,
});

// Serialize (NO stringify — use {f} with json.fmt)
const json = try std.fmt.allocPrint(gpa, "{f}", .{std.json.fmt(value, .{})});
```

## Formatting
```zig
try std.fmt.bufPrint(&buf, "{d}: {s}", .{ 42, "hi" });      // stack
const s = try std.fmt.allocPrint(gpa, "{s}_{d}", .{ "k", 1 }); // heap
const label = std.fmt.comptimePrint("field_{d}", .{42});     // comptime
// {d} int, {s} string, {x} hex, {f} custom format, {any} raw struct
```

## Error Handling Patterns
```zig
// errdefer with error capture
errdefer |err| log.err("{s}", .{@errorName(err)});

// errdefer loop cleanup (partial init pattern)
var done: usize = 0;
errdefer for (items[0..done]) |item| alloc.free(item);
for (items) |*slot| { slot.* = try alloc.alloc(u8, 64); done += 1; }

// Rich error context (when flat error sets aren't enough)
const Result = union(enum) { ok: u32, err: struct { code: anyerror, msg: []const u8 } };
```

## Allocator Patterns
```zig
// Custom allocator: ptr + vtable
const vtable: Allocator.VTable = .{
    .alloc = allocFn, .resize = resizeFn, .remap = remapFn, .free = freeFn,
};
// Alignment type: std.mem.Alignment (NOT mem.Allocator.Alignment — not public)

// Arena composition (zero syscalls)
var buf: [4096]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buf);
var arena = std.heap.ArenaAllocator.init(fba.allocator());

// Scoped arena per-request
for (requests) |req| {
    var arena = std.heap.ArenaAllocator.init(backing);
    defer arena.deinit();
    processRequest(arena.allocator(), req);
}
// Arena reset: .free_all, .retain_capacity, .{ .retain_with_limit = N }

// OOM testing
var failing = std.testing.FailingAllocator.init(testing.allocator, .{ .fail_index = 2 });
try std.testing.checkAllAllocationFailures(testing.allocator, testFn, .{});
// ^ exhaustive: fails at alloc 0, 1, 2, ... until function succeeds
```

## Testing
```zig
try testing.expect(cond);
try testing.expectEqual(expected, actual);
try testing.expectEqualStrings("exp", actual);
try testing.expectEqualSlices(u8, exp, actual);
try testing.expectApproxEqAbs(exp, actual, tolerance);
try testing.expectError(error.Foo, fallible_expr);

// Parameterized (inline for)
inline for (.{ u8, u16, u32 }) |T| { try testing.expectEqual(...); }

// Fuzzing
var prng = std.Random.DefaultPrng.init(std.testing.random_seed);
const random = prng.random();
random.bytes(buf); random.uintLessThan(usize, max);

// Force-analyze nested tests
test { testing.refAllDecls(MyModule); }         // shallow
test { testing.refAllDeclsRecursive(MyModule); } // recursive
```

## Build System
```zig
// build.zig.zon
.{ .name = .my_project, .fingerprint = 0xABCD, .version = "0.1.0",
   .paths = .{ "build.zig", "build.zig.zon", "src" } }

// build.zig
const mod = b.addModule("mylib", .{ .root_source_file = b.path("src/root.zig") });
const exe = b.addExecutable(.{ .name = "app",
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target, .optimize = optimize,
        .imports = &.{ .{ .name = "mylib", .module = mod } },
    }),
});
b.installArtifact(exe);

// Config options → source-accessible module
const options = b.addOptions();
options.addOption(bool, "feature", b.option(bool, "feature", "...") orelse false);
exe.root_module.addOptions("config", options);
// Source: const config = @import("config"); config.feature

// Test step
const tests = b.addTest(.{ .root_module = mod });
const test_step = b.step("test", "Run tests");
test_step.dependOn(&b.addRunArtifact(tests).step);

// Platform: @import("builtin").os.tag, .cpu.arch, .mode, .is_test
```

## Idiomatic Patterns
```zig
// Iterator
const Iter = struct {
    data: []const u8, index: usize = 0,
    fn next(self: *Iter) ?u8 {
        if (self.index >= self.data.len) return null;
        defer self.index += 1;
        return self.data[self.index];
    }
};

// Type-erased interface (vtable)
const Drawable = struct {
    ptr: *anyopaque,
    vtable: *const VTable,
    const VTable = struct { drawFn: *const fn (*anyopaque) void };
    fn draw(self: Drawable) void { self.vtable.drawFn(self.ptr); }
};
```

## Math
```zig
@min(a, b), @max(a, b)          // builtins (NOT std.math)
std.math.clamp(val, lo, hi)
std.math.isPowerOfTwo(n)         // asserts n > 0 — panics on 0!
std.math.log2_int(u32, n)       // type FIRST, then value
std.math.divCeil(u32, n, d)     // returns error union
std.math.maxInt(u8)              // 255
```
