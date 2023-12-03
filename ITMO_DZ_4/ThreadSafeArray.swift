import Foundation

enum ThreadSafeArrayError: Error {
    case initializationFailed
}

class ThreadSafeArray<T> {
    private var array: [T]
    private let lock: RWLock

    init() throws {
        do {
            array = []
            lock = try RWLock()
        } catch {
            throw ThreadSafeArrayError.initializationFailed
        }
    }

    var description: String {
        return array.description
    }
}

extension ThreadSafeArray: RandomAccessCollection {
    typealias Index = Int
    typealias Element = T

    var startIndex: Index {
        return synchronizedRead {
            array.startIndex
        }
    }

    var endIndex: Index {
        return synchronizedRead {
            array.endIndex
        }
    }

    subscript(index: Index) -> Element {
        get {
            return synchronizedRead {
                array[index]
            }
        }
        set {
            synchronizedWrite {
                array[index] = newValue
            }
        }
    }

    func index(after i: Index) -> Index {
        return synchronizedRead {
            array.index(after: i)
        }
    }

    func append(_ v: T) {
        synchronizedWrite {
            array.append(v)
        }
    }

    @discardableResult
    func remove(at index: Index) -> T {
        return synchronizedWrite {
            array.remove(at: index)
        }
    }

    private func synchronizedRead<R>(_ block: () throws -> R) rethrows -> R {
        let lockLocal = lock
        lockLocal.readLock()
        let result = try block()
        lockLocal.unlock()
        return result
    }

    private func synchronizedWrite<R>(_ block: () throws -> R) rethrows -> R {
        let lockLocal = lock
        lockLocal.writeLock()
        let result = try block()
        lockLocal.unlock()
        return result
    }
}
