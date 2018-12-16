//
//  shim.h
//  tcp-server-select
//
//  Created by sunlubo on 2018/12/15.
//  Copyright © 2018 sunlubo. All rights reserved.
//

#ifndef shim_h
#define shim_h

#include <arpa/inet.h>
#include <errno.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

void swift_FD_ZERO(fd_set *fdset) { FD_ZERO(fdset); }

void swift_FD_COPY(fd_set *fdset_orig, fd_set *fdset_copy) { FD_COPY(fdset_orig, fdset_copy); }

void swift_FD_CLR(int fd, fd_set *fdset) { FD_CLR(fd, fdset); }

void swift_FD_SET(int fd, fd_set *fdset) { FD_SET(fd, fdset); }

int swift_FD_ISSET(int fd, fd_set *fdset) {
    return (fdset->fds_bits[(unsigned long)fd / __DARWIN_NFDBITS] &
            ((__int32_t)(((unsigned long)1) << ((unsigned long)fd % __DARWIN_NFDBITS))));
}

#endif /* shim_h */
