//
//  ObservableType+Extras.swift
//  Papr
//
//  Created by Joan Disho on 07.01.18.
//  Copyright © 2018 Joan Disho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    
    func ignoreAll() -> Observable<Void> {
        return self.map { _ in }
    }
    
    func unwrap<T>() -> Observable<T> where E == Optional<T> {
        return self.filter { $0 != nil }.map { $0! }
    }

    func flatMapIgnore<O: ObservableConvertibleType>(_ selector: @escaping (E) throws -> O) -> Observable<E> {
        return flatMap { result -> Observable<E> in
            let ignoredObservable = try selector(result)

            return ignoredObservable.asObservable()
                .flatMap { _ in Observable.just(result) }
                .take(1)
        }
    }
    
}

extension Observable where E == Data {
    func map<D: Decodable>( _ type: D.Type) -> Observable<D>  {
        return self.map { try! JSONDecoder().decode(type, from: $0) }
    }
}

extension Observable where E == Bool {
    
    var negation: Observable<Bool> {
        return self.map { !$0 }
    }

}

extension Observable where E: Sequence, E.Iterator.Element: Comparable {
    
    /**
     Transforms an observable of sequences into an observable of ordered arrays by using the sequence element's
     natural comparator.
     */
    
    func sorted<T>() -> Observable<[T]> where E.Iterator.Element == T {
        return self.map { $0.sorted() }
    }
    
    func sorted<T>(_ areInIncreasingOrder: @escaping (T, T) -> Bool) -> Observable<[T]> 
        where E.Iterator.Element == T {
            return self.map { $0.sorted(by: areInIncreasingOrder) }
    }
}


extension ObservableType where E: Collection {

    func mapMany<T>(_ transform: @escaping (Self.E.Element) -> T) -> Observable<[T]> {
        return self.map { collection -> [T] in
            collection.map(transform)
        }
    }

}
