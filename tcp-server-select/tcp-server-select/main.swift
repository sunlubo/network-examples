//
//  main.swift
//  tcp-server-select
//
//  Created by sunlubo on 2018/12/15.
//  Copyright © 2018 sunlubo. All rights reserved.
//

import Foundation
import Darwin

enum ParseState {
    case completed(String, Int)
    case needMoreData
}

// \r\n => 13 10
func parse(_ buf: UnsafePointer<UInt8>, size: Int) -> ParseState {
    var index = 0
    while index < size - 1 {
        if buf[index] == 13 && buf[index + 1] == 10 {
            let str = String(bytes: UnsafeBufferPointer(start: buf, count: index), encoding: .utf8)!
            return .completed(str, index + 2)
        }
        index += 1
    }
    return .needMoreData
}

// create an endpoint for communication
let server_fd = socket(PF_INET, SOCK_STREAM, 0) // int socket(int domain, int type, int protocol)
assert(server_fd != -1, "socket: \(errno)")

// bind a name to a socket
var addr_in = sockaddr_in()
addr_in.sin_family = sa_family_t(AF_INET)
addr_in.sin_port = in_port_t(9090).bigEndian
addr_in.sin_addr.s_addr = inet_addr("127.0.0.1")

var addr = unsafeBitCast(addr_in, to: sockaddr.self)
var ret = bind(server_fd, &addr, socklen_t(MemoryLayout<sockaddr_in>.size)) // int bind(int socket, const struct sockaddr *address, socklen_t address_len)
assert(ret != -1, "bind: \(errno)")

// listen for connections on a socket
ret = listen(server_fd, 1) // int listen(int socket, int backlog)
assert(ret != -1, "listen: \(errno)")

print("listen: \(String(cString: inet_ntoa(addr_in.sin_addr))):\(addr_in.sin_port.bigEndian)")

// synchronous I/O multiplexing
let nfds = server_fd + 1
var fset = fd_set()
swift_FD_ZERO(&fset)
swift_FD_SET(server_fd, &fset)
var timeout = timeval(tv_sec: 10, tv_usec: 0)
ret = select(nfds, &fset, nil, nil, &timeout) // int select(int nfds, fd_set *restrict readfds, fd_set *restrict writefds, fd_set *restrict errorfds, struct timeval *restrict timeout)
assert(ret != -1, "select: \(errno)")
assert(ret !=  0, "select: timeout")

print("select: connection ready - \(swift_FD_ISSET(server_fd, &fset))")

// accept a connection on a socket
var client_addr = sockaddr()
var addr_len = socklen_t(MemoryLayout<sockaddr>.size)
let client_fd = accept(server_fd, &client_addr, &addr_len) // int accept(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len)
assert(client_fd != -1, "accept: \(errno)")

// receive a message from a socket
let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
buf.initialize(to: 0)
let bytes_read = recv(client_fd, buf, 1024, 0) // ssize_t recv(int socket, void *buffer, size_t length, int flags)
assert(bytes_read != -1, "recv: \(errno)")

var used = 0
start: while used < bytes_read {
    let state = parse(buf.advanced(by: used), size: bytes_read - used)
    switch state {
    case .completed(let str, let size):
        print((str, size))
        used += size
    case .needMoreData:
        let remaining_data = Data(bytes: buf.advanced(by: used), count: bytes_read - used)
        print("need more data: \(Array(remaining_data))")
        break start
    }
}
buf.deallocate()

// write output
let response = """
HTTP/1.1 200 OK\r\n\r\n\
hello\r\n
"""
let bytes_sent = write(client_fd, response, response.utf8.count) // ssize_t write(int fildes, const void *buf, size_t nbyte)
assert(bytes_sent != -1, "write: \(errno)")

// delete a descriptor
ret = close(server_fd) // int close(int fildes)
assert(ret != -1, "close: \(errno)")
