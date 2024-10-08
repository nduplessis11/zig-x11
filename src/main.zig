const std = @import("std");
const posix = std.posix;
const net = std.net;

pub fn main() !void {
    std.log.info("Starting windowing system...", .{});

    const display = posix.getenv("DISPLAY") orelse ":0";
    std.debug.print("{s}\n", .{display});

    const stream = try net.connectUnixSocket("/tmp/.X11-unix/X1");
    errdefer stream.close();

    // Send the setup request
    var setup_request = [_]u8{0} ** 12;
    setup_request[0] = 'l'; // Little-endian byte order
    setup_request[2] = 11; // Protocol version

    _ = try stream.write(&setup_request);

    // Read the header (first 8 bytes) of the reply
    var reply: [8]u8 = undefined;
    _ = try stream.read(&reply);
    std.debug.print("Reply: {x}\n", .{reply});

    // Check for success (first byte should be 1)
    if (reply[0] == 1) {
        std.log.info("Connected to X server", .{});
        handle_error(&reply);
    } else {
        std.log.err("Failed to connect to X server", .{});
    }

    stream.close();
}

fn handle_error(reply: []u8) void {
    std.debug.print("Version {} \n", .{reply[2]});
}
