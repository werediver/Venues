//
//  Result.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/8/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import Foundation

protocol ResultProtocol {
    associatedtype Value

    var value: Value? { get }
    var error: Error? { get }

    func iif<U>(success: (Value) -> U, failure: (Error) -> U) -> U
}

extension ResultProtocol {
    func map<U>(_ transform: (Value) -> U) -> Result<U> {
        return iif(success: { .success(transform($0)) }, failure: { .failure($0) })
    }

    func flatMap<U>(_ transform: (Value) -> Result<U>) -> Result<U> {
        return iif(success: transform, failure: { .failure($0) })
    }

    static func `try`(_ body: () throws -> Value) -> Result<Value> {
        do {
            return try .success(body())
        } catch {
            return .failure(error)
        }
    }
}

enum Result<T>: ResultProtocol {
    case success(T)
    case failure(Error)

    var value: T? {
        return iif(success: { $0 }, failure: { _ in nil })
    }

    var error: Error? {
        return iif(success: { _ in nil }, failure: { $0 })
    }

    func iif<U>(success: (T) -> U, failure: (Error) -> U) -> U {
        switch self {
        case let .success(value):
            return success(value)
        case let .failure(error):
            return failure(error)
        }
    }
}
