//
//  RWLock.swift
//  ITMO_DZ_4
//
//  Created by Kirill Mikhailov on 03.12.2023.
//

import Foundation

enum RWLockError: Error {
    case initializationFailed
}

class RWLock {
    private var lock: pthread_rwlock_t
    
    init() throws {
        lock = pthread_rwlock_t()
        let result = pthread_rwlock_init(&lock, nil)
        guard result == 0 else {
            throw RWLockError.initializationFailed
        }
    }
    
    deinit {
        let result = pthread_rwlock_destroy(&lock)
        assert(result == 0, "Failed to destroy RWLock")
    }

    func writeLock() {
        var result = pthread_rwlock_wrlock(&lock)
        while (result != 0) {
            result = pthread_rwlock_wrlock(&lock)
        }
    }

    func readLock() {
        var result = pthread_rwlock_rdlock(&lock)
        while (result != 0) {
            result = pthread_rwlock_rdlock(&lock)
        }
    }

    func unlock() {
        var result = pthread_rwlock_unlock(&lock)
        while (result != 0) {
            result = pthread_rwlock_unlock(&lock)
        }
    }
}
