import Foundation

public enum CoreDataChange<T> {
    
    case update(Int, T)
    case delete(Int, T)
    case insert(Int, T)
    
    public func object() -> T {
        switch self {
        case .update(_, let object): return object
        case .delete(_, let object): return object
        case .insert(_, let object): return object
        }
    }
    
    public func index() -> Int {
        switch self {
        case .update(let index, _): return index
        case .delete(let index, _): return index
        case .insert(let index, _): return index
        }
    }
    
    public var isDeletion: Bool {
        switch self {
        case .delete(_): return true
        default: return false
        }
    }
    
    public var isUpdate: Bool {
        switch self {
        case .update(_): return true
        default: return false
        }
    }
    
    public var isInsertion: Bool {
        switch self {
        case .insert(_): return true
        default: return false
        }
    }
    
}
