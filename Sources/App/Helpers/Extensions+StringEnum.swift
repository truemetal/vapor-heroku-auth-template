extension StructuredDataWrapper {
    func get<T, E: RawRepresentable>(_ field: E) throws -> T where E.RawValue == String {
        return try get(field.rawValue)
    }
    
    mutating func set<E: RawRepresentable>(_ field: E, _ any: Any?) throws where E.RawValue == String {
        try set(field.rawValue, any)
    }
}

import Fluent
extension QueryRepresentable where Self: ExecutorRepresentable {
    func filter<E: RawRepresentable>(_ field: E, _ value: NodeRepresentable?) throws -> Query<Self.E>
        where E.RawValue == String
    {
        return try filter(field.rawValue, value)
    }
}

extension Creator {
    func string<E: RawRepresentable>(_ name: E, optional: Bool = true, unique: Bool = false)
        where E.RawValue == String {
        string(name.rawValue, optional: optional, unique: unique)
    }
    
    func int<E: RawRepresentable>(_ name: E, optional: Bool = true, unique: Bool = false)
        where E.RawValue == String {
        int(name.rawValue, optional: optional, unique: unique)
    }
}
