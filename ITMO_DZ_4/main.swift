import Foundation

let group = DispatchGroup()

func performConcurrentTasks(iterations: Int, closure: @escaping (Int) -> Void) {
    DispatchQueue.concurrentPerform(iterations: iterations) { i in
        group.enter()
        usleep(UInt32.random(in: 0...1000))
        closure(i)
        group.leave()
    }
    
    group.wait()
}

func appendTest() {
    let sharedArray = try! ThreadSafeArray<Int>()

    performConcurrentTasks(iterations: 100) { i in
        for j in 1...10000 {
            sharedArray.append(100 * i + j)
        }
    }

    assert(sharedArray.count == 10000 * 100)
    print("appendTest is success")
}

func writeTest() {
    let sharedArray = try! ThreadSafeArray<Int>()

    for i in 0..<10000 {
        sharedArray.append(i)
    }

    performConcurrentTasks(iterations: 10000) { i in
        sharedArray[i] *= 100
    }

    performConcurrentTasks(iterations: 10000) { i in
        assert(sharedArray[i] == i * 100)
    }

    print("writeTest is success")
}

func subscriptSetAndGetTest() {
    let sharedArray = try! ThreadSafeArray<Int>()

    for i in 0..<10000 {
        sharedArray.append(i)
    }

    performConcurrentTasks(iterations: 10000) { i in
        sharedArray[i] = sharedArray[i] * 2
    }

    performConcurrentTasks(iterations: 10000) { i in
        let value = sharedArray[i]
        assert(value % 2 == 0)
    }

    print("subscriptSetAndGetTest is success")
}

func parallelReadAndWrite() {
    let sharedArray = try! ThreadSafeArray<Int>()

    for i in 0..<10000 {
        sharedArray.append(i)
    }

    performConcurrentTasks(iterations: 10000) { i in
        if i % 2 == 0 {
            sharedArray[i] = 0
        } else {
            assert(sharedArray[i] == i)
        }
    }

    performConcurrentTasks(iterations: 10000) { i in
        if i % 2 == 0 {
            assert(sharedArray[i] == 0)
        }
    }

    print("parallelReadAndWrite is success")
}

func removeTest() {
    let sharedArray = try! ThreadSafeArray<Int>()

    for i in 0..<10000 {
        sharedArray.append(i)
    }

    performConcurrentTasks(iterations: 5000) { i in
        sharedArray.remove(at: i)
    }

    assert(sharedArray.count == 5000)
    print("removeTest is success")
}

appendTest()
writeTest()
subscriptSetAndGetTest()
parallelReadAndWrite()
removeTest()
