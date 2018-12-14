//
//  main.swift
//  tcp-client
//
//  Created by sunlubo on 2018/12/12.
//  Copyright © 2018 sunlubo. All rights reserved.
//

import Foundation
import Darwin

// create -> connect -> close

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
let client_fd = socket(AF_INET, SOCK_STREAM, 0) // int socket(int domain, int type, int protocol)
assert(client_fd != -1, "socket: \(errno)")

// initiate a connection on a socket
var hints = addrinfo()
hints.ai_family = AF_INET
hints.ai_socktype = SOCK_STREAM
var addr: UnsafeMutablePointer<addrinfo>!
getaddrinfo("127.0.0.1", "9090", &hints, &addr)

var ret = connect(client_fd, addr.pointee.ai_addr, addr.pointee.ai_addrlen) // int connect(int socket, const struct sockaddr *address, socklen_t address_len)
freeaddrinfo(addr)
assert(ret != -1, "connect: \(errno)")

// write output
let request = """
GET /hello/world HTTP/1.1\r\n\
Host: 127.0.0.1:9090\r\n\
Connection: keep-alive\r\n\
Upgrade-Insecure-Requests: 1\r\n\
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36\r\n\
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8\r\n\
Accept-Encoding: gzip, deflate, br\r\n\
Accept-Language: zh-CN,zh;q=0.9,en;q=0.8\r\n\r\n
"""
let bytes_sent = write(client_fd, request, request.utf8.count) // ssize_t write(int fildes, const void *buf, size_t nbyte)
assert(bytes_sent != -1, "write: \(errno)")

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

// delete a descriptor
ret = close(client_fd) // int close(int fildes)
assert(ret != -1, "close: \(errno)")
