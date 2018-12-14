
/// This function converts the uint16_t integer hostshort from host byte order to network byte order.
public func htons(_ hostshort: UInt16) -> UInt16 {
    return hostshort.bigEndian
}

/// This function converts the uint16_t integer netshort from network byte order to host byte order.
public func ntohs(_ hostshort: UInt16) -> UInt16 {
    #if _endian(big)
    return hostshort
    #else
    return hostshort.littleEndian
    #endif
}

/// This function converts the uint32_t integer hostlong from host byte order to network byte order.
public func htonl(_ hostshort: UInt32) -> UInt32 {
    return hostshort.bigEndian
}

/// This function converts the uint32_t integer netlong from network byte order to host byte order.
public func ntohl(_ hostshort: UInt32) -> UInt32 {
    #if _endian(big)
    return hostshort
    #else
    return hostshort.littleEndian
    #endif
}
