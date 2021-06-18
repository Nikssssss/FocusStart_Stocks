//
//  ThreadSafeArray.swift
//  ThreadSafeArray
//
//  Created by Никита Гусев on 26.04.2021.
//

import Foundation

class ThreadSafeArray<T> {
    var toArray: [T] {
        return array
    }
    
    private var array = [T]()
    private let queue = DispatchQueue(label: "com.threadsafearray.queue", attributes: .concurrent)
    
    var count: Int {
        self.queue.sync {
            return self.array.count
        }
    }
    
    var isEmpty: Bool {
        self.queue.sync {
            return self.array.isEmpty
        }
    }
    
    func append(_ item: T) {
        self.queue.sync { [weak self] in
            guard let self = self else { return }
            self.array.append(item)
        }
    }
    
    func remove(at index: Int) {
        self.queue.async(flags: .barrier) { [weak self] in
            guard let self = self, index >= 0, index < self.array.count else { return }
            self.array.remove(at: index)
        }
    }
    
    func removeAll() {
        self.queue.async(flags: .barrier) { [weak self] in
            self?.array.removeAll()
        }
    }
    
    subscript(index: Int) -> T? {
        self.queue.sync {
            guard index >= 0, index < self.array.count else { return nil }
            return self.array[index]
        }
    }
}
