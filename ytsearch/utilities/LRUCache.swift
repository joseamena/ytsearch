
import Foundation


class LRUFetcher<Key, Value> {
    func fetch(key: Key, completion: ((Value?, Error?) -> Void)?) {

    }
}

class Node<K,T> : CustomStringConvertible {
    var value: T
    var key: K
    
    var next: Node<K,T>?
    weak var previous: Node<K,T>?
    
    init (key: K, value: T) {
        self.key = key
        self.value = value
        self.next = nil
        self.previous = nil
    }
    
    var description: String {
        return "\(key): \(value)"
    }
}

class List<K,T> {
    var head: Node<K,T>?
    var tail: Node<K,T>?
    
    func isEmpty() -> Bool {
        return head === nil
    }
    
    func addTail(node: Node<K,T>) {
        if isEmpty() {
            head = node
            tail = node
            return
        }

        if let tail = tail {
            tail.next = node
            node.previous = tail
            self.tail = node
        }
    }
    
    func addHead(node: Node<K,T>) {
        
        if isEmpty() {
            head = node
            tail = node
            return
        }

        if let head = head {
            node.next = head
            head.previous = node
            self.head = node
        }
    }
    
    func remove(node: Node<K,T>) {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        
        next?.previous = prev
        
        if next == nil {
            tail = prev
        }
        
        node.previous = nil
        node.next = nil
    }
    
    func clear() {
        head = nil
        tail = nil
    }
    
}

class LRUCache<Key: Hashable, ValueType>: CustomStringConvertible {
    private var dict : Dictionary<Key,Node<Key,ValueType>>
    private var list : List<Key,ValueType>
    private let cacheSize : Int
    private var count = 0
    public var fetcher: LRUFetcher<Key, ValueType>?
    
    init(size: Int) {
        dict = Dictionary<Key,Node<Key,ValueType>>()
        list = List<Key,ValueType>()
        cacheSize = size
    }

    //completion handler is only called if the key does not exist
    func getValue(key: Key, completion: ((ValueType?, Error?) -> Void)?) {

        //if we have it just return it
        if let node = dict[key] {
            list.remove(node: node)
            list.addHead(node: node)
            completion?(node.value, nil)
        }

        //otherwise fetch it return nil, and provide the data in the completion handler
        fetcher?.fetch(key: key, completion: { (data, error) in
            if let error = error {
                completion?(nil, error)
                return
            }
            if let data = data {
                self.set(value: data, forKey: key)
            }
            completion?(data, error)
        })
    }
    
    private func set(value : ValueType, forKey key: Key) {
        
        if let node = dict[key] {
            //key already exists update it and move it to front
            node.value = value
            list.remove(node: node)
            list.addHead(node: node)
            return
        }
        
        
        if (count >= cacheSize) {
            //discard the last element
            if let last = list.tail {
                dict.removeValue(forKey: last.key)
                list.remove(node: last)
            }
        } else {
            count += 1
        }
        
        let node = Node<Key,ValueType>(key: key, value: value)
        dict[key] = node
        list.addHead(node: node)
        
    }
    
    func clear() {
        list.clear()
        dict.removeAll()
    }
    
    var description: String {
        return dict.description
    }
    
}
