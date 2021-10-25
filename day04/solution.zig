const std = @import("std");
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const allocator = std.heap.page_allocator;

const Entry = struct { chr: u8, count: usize };

const Room = struct {
    parts: ArrayList([]const u8),
    id: usize,
    checksum: []const u8,

    fn from_line(line: []u8) Room {
        var parts = std.mem.split(line, "-");
        var result: Room = Room{ .parts = ArrayList([]const u8).init(allocator), .id = 0, .checksum = "" };

        while (parts.next()) |part| {
            if (parts.rest().len > 0) {
                result.parts.append(part) catch |_| {};
            } else {
                var tail = std.mem.tokenize(part, "[]");
                result.id = std.fmt.parseInt(usize, tail.next() orelse "0", 10) catch |_| 0;
                result.checksum = tail.next() orelse "";
            }
        }

        return result;
    }

    fn get_counts(self: *const Room) AutoHashMap(u8, usize) {
        var result = AutoHashMap(u8, usize).init(allocator);

        for (self.parts.items) |item| {
            for (item) |c| {
                var count = result.get(c) orelse 0;
                if (result.fetchPut(c, count + 1)) |_| {} else |_| {}
            }
        }

        return result;
    }

    fn is_real(self: *const Room) bool {
        var counts = self.get_counts();
        var it = counts.iterator();
        var entries = ArrayList(Entry).init(allocator);

        while (it.next()) |entry| {
            entries.append(Entry{
                .chr = entry.key_ptr.*,
                .count = entry.value_ptr.*,
            }) catch |_| {};
        }

        std.sort.sort(Entry, entries.items, {}, compare_entries);

        var checksum: [5]u8 = undefined;
        for (entries.items[0..5]) |item, idx| {
            checksum[idx] = item.chr;
        }

        return std.mem.eql(u8, checksum[0..], self.checksum);
    }

    fn decrypt(self: *const Room) []u8 {
        var decrypted_parts = ArrayList([]u8).init(allocator);

        for (self.parts.items) |part| {
            var decrypted_part = ArrayList(u8).init(allocator);

            for (part) |chr| {
                decrypted_part.append(shift_char(chr, self.id)) catch |_| {};
            }

            decrypted_parts.append(decrypted_part.items) catch |_| {};
        }

        return std.mem.join(allocator, " ", decrypted_parts.items) catch |_| "";
    }
};

fn read_lines() anyerror!ArrayList([]u8) {
    const stdin = std.io.getStdIn().reader();

    var result = ArrayList([]u8).init(allocator);

    while (true) {
        if (stdin.readUntilDelimiterAlloc(allocator, '\n', 10000)) |line| {
            result.append(line) catch |_| {};
        } else |_| {
            return result;
        }
    }
}

fn compare_entries(ctx: void, e1: Entry, e2: Entry) bool {
    if (e1.count == e2.count)
        return e1.chr < e2.chr;

    return e1.count > e2.count;
}

fn shift_char(chr: u8, shift: usize) u8 {
    return (chr - 'a' + @intCast(u8, shift % 26)) % 26 + 'a';
}

fn solve_a(rooms: ArrayList(Room)) usize {
    var result: usize = 0;

    for (rooms.items) |room| {
        if (room.is_real()) result += room.id;
    }

    return result;
}

fn solve_b(rooms: ArrayList(Room)) usize {
    for (rooms.items) |room| {
        const decrypted = room.decrypt();

        if (std.mem.eql(u8, decrypted, "northpole object storage")) {
            return room.id;
        }
    }

    return 0;
}

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    var rooms = ArrayList(Room).init(allocator);
    for ((try read_lines()).items) |line| {
        try rooms.append(Room.from_line(line));
    }

    try stdout.print("Part 1: {d}\nPart 2: {d}\n", .{
        solve_a(rooms),
        solve_b(rooms),
    });
}
