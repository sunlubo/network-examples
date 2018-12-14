import Darwin

// https://www.gnu.org/software/libc/manual/html_node/Internet-Address-Formats.html#Internet-Address-Formats
// https://www.gnu.org/software/libc/manual/html_node/Byte-Order.html#Byte-Order

// IPV4
var addr_in = sockaddr_in()
addr_in.sin_family = sa_family_t(AF_INET)
addr_in.sin_port = htons(8080)
addr_in.sin_addr.s_addr = inet_addr("127.0.0.1")
addr_in.sin_addr.s_addr = htonl(INADDR_ANY)

// You can use this constant to stand for “the address of this machine,” instead of finding its actual address.
// It is the IPv4 Internet address ‘127.0.0.1’, which is usually called ‘localhost’.
// This special constant saves you the trouble of looking up the address of your own machine.
// Also, the system usually implements INADDR_LOOPBACK specially, avoiding any network traffic for the case of one machine talking to itself.
INADDR_LOOPBACK
// You can use this constant to stand for “any incoming address” when binding to an address.
INADDR_ANY
// This constant is the address you use to send a broadcast message.
INADDR_BROADCAST
// This constant is returned by some functions to indicate an error.
INADDR_NONE

var i_addr = in_addr()
inet_aton("127.0.0.1", &i_addr) // inet_aton returns nonzero if the address is valid, zero if not.
String(cString: inet_ntoa(i_addr))

let n = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
n.initialize(to: 0)
// This function converts an Internet address (either IPv4 or IPv6) from presentation (textual) to network (binary) format.
inet_pton(AF_INET, "127.0.0.1", n)

let p = UnsafeMutablePointer<Int8>.allocate(capacity: Int(INET_ADDRSTRLEN))
p.initialize(to: 0)
// This function converts an Internet address (either IPv4 or IPv6) from network (binary) to presentation (textual) form.
inet_ntop(AF_INET, n, p, socklen_t(INET_ADDRSTRLEN))
String(cString: p)
n.deallocate()
p.deallocate()

// IPV6
var addr_in6 = sockaddr_in6()
addr_in6.sin6_family = sa_family_t(AF_INET6)
addr_in6.sin6_port = htons(8080)
inet_pton(AF_INET6, "::1", &addr_in6.sin6_addr.__u6_addr)
print(addr_in6.sin6_addr.__u6_addr.__u6_addr8)
print(addr_in6.sin6_addr.__u6_addr.__u6_addr16)
print(addr_in6.sin6_addr.__u6_addr.__u6_addr32)

// This constant is the IPv6 address ‘::1’, the loopback address.
in6addr_loopback
// This constant is the IPv6 address ‘::’, the unspecified address.
in6addr_any

// common
let addr = unsafeBitCast(addr_in, to: sockaddr.self)
addr.sa_family
addr.sa_data
addr.sa_len

// new common
let n_addr = sockaddr_storage()
