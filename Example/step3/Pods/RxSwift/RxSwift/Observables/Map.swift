//
//  Map.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    /**
     Projects each element of an observable sequence into a new form.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.

     */
    public func map<R>(_ transform: @escaping (E) throws -> R)
        -> Observable<R> {
        return asObservable().composeMap(transform)
    }
}

private final class MapSink<SourceType, O: ObserverType>: Sink<O>, ObserverType {
    typealias Transform = (SourceType) throws -> ResultType

    typealias ResultType = O.E
    typealias Element = SourceType

    private let _transform: Transform

    init(transform: @escaping Transform, observer: O, cancel: Cancelable) {
        _transform = transform
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<SourceType>) {
        switch event {
        case let .next(element):
            do {
                let mappedElement = try _transform(element)
                forwardOn(.next(mappedElement))
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        case let .error(error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
}

#if TRACE_RESOURCES
    fileprivate let _numberOfMapOperators = AtomicInt(0)
    extension Resources {
        public static var numberOfMapOperators: Int32 {
            return load(_numberOfMapOperators)
        }
    }
#endif

internal func _map<Element, R>(source: Observable<Element>, transform: @escaping (Element) throws -> R) -> Observable<R> {
    return Map(source: source, transform: transform)
}

private final class Map<SourceType, ResultType>: Producer<ResultType> {
    typealias Transform = (SourceType) throws -> ResultType

    private let _source: Observable<SourceType>

    private let _transform: Transform

    init(source: Observable<SourceType>, transform: @escaping Transform) {
        _source = source
        _transform = transform

        #if TRACE_RESOURCES
            _ = increment(_numberOfMapOperators)
        #endif
    }

    override func composeMap<R>(_ selector: @escaping (ResultType) throws -> R) -> Observable<R> {
        let originalSelector = _transform
        return Map<SourceType, R>(source: _source, transform: { (s: SourceType) throws -> R in
            let r: ResultType = try originalSelector(s)
            return try selector(r)
        })
    }

    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == ResultType {
        let sink = MapSink(transform: _transform, observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }

    #if TRACE_RESOURCES
        deinit {
            _ = decrement(_numberOfMapOperators)
        }
    #endif
}
