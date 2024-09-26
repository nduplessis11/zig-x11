const std = @import("std");
const posix = std.posix;
const net = std.net;

pub fn main() !void {
    std.log.info("Starting windowing system...", .{});

    const sockfd = try posix.socket(
        posix.AF.UNIX,
        posix.SOCK.STREAM,
        0,
    );
    errdefer net.Stream.close(.{ .handle = sockfd });

    var sock_addr = posix.sockaddr.un{
        .family = posix.AF.UNIX,
        .path = undefined,
    };

    const path: []const u8 = "/tmp/.X11-unix/X1";

    @memset(&sock_addr.path, 0);
    @memcpy(sock_addr.path[0..path.len], path);

    const address: posix.sockaddr = .{ .un = sock_addr };
    const sock_size = @as(posix.socklen_t, @intCast(@sizeOf(posix.sockaddr.un)));
    try posix.connect(sockfd, &address, sock_size);
    // TODO: Lookup type-unions and any on Address
    // try posix.connect(sockfd, &sock_addr.any, sock_addr.getOsSockLen());
}
