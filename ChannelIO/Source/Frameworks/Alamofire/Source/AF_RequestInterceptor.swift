//
//  RequestInterceptor.swift
//
//  Copyright (c) 2019 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// A type that can inspect and optionally adapt a `URLRequest` in some manner if necessary.
protocol AF_RequestAdapter {
    /// Inspects and adapts the specified `URLRequest` in some manner and calls the completion handler with the Result.
    ///
    /// - Parameters:
    ///   - urlRequest: The `URLRequest` to adapt.
    ///   - session:    The `Session` that will execute the `URLRequest`.
    ///   - completion: The completion handler that must be called when adaptation is complete.
    func adapt(_ urlRequest: URLRequest, for session: AF_Session, completion: @escaping (Result<URLRequest, Error>) -> Void)
}

// MARK: -

/// Outcome of determination whether retry is necessary.
enum AF_RetryResult {
    /// Retry should be attempted immediately.
    case retry
    /// Retry should be attempted after the associated `TimeInterval`.
    case retryWithDelay(TimeInterval)
    /// Do not retry.
    case doNotRetry
    /// Do not retry due to the associated `Error`.
    case doNotRetryWithError(Error)
}

extension AF_RetryResult {
    var retryRequired: Bool {
        switch self {
        case .retry, .retryWithDelay: return true
        default: return false
        }
    }

    var delay: TimeInterval? {
        switch self {
        case let .retryWithDelay(delay): return delay
        default: return nil
        }
    }

    var error: Error? {
        guard case let .doNotRetryWithError(error) = self else { return nil }
        return error
    }
}

/// A type that determines whether a request should be retried after being executed by the specified session manager
/// and encountering an error.
protocol AF_RequestRetrier {
    /// Determines whether the `Request` should be retried by calling the `completion` closure.
    ///
    /// This operation is fully asynchronous. Any amount of time can be taken to determine whether the request needs
    /// to be retried. The one requirement is that the completion closure is called to ensure the request is properly
    /// cleaned up after.
    ///
    /// - Parameters:
    ///   - request:    `Request` that failed due to the provided `Error`.
    ///   - session:    `Session` that produced the `Request`.
    ///   - error:      `Error` encountered while executing the `Request`.
    ///   - completion: Completion closure to be executed when a retry decision has been determined.
    func retry(_ request: AF_Request, for session: AF_Session, dueTo error: Error, completion: @escaping (AF_RetryResult) -> Void)
}

// MARK: -

/// Type that provides both `RequestAdapter` and `RequestRetrier` functionality.
protocol AF_RequestInterceptor: AF_RequestAdapter, AF_RequestRetrier {}

extension AF_RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: AF_Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
    }

    func retry(_ request: AF_Request,
                      for session: AF_Session,
                      dueTo error: Error,
                      completion: @escaping (AF_RetryResult) -> Void) {
        completion(.doNotRetry)
    }
}

/// `RequestAdapter` closure definition.
typealias AF_AdaptHandler = (URLRequest, AF_Session, _ completion: @escaping (Result<URLRequest, Error>) -> Void) -> Void
/// `RequestRetrier` closure definition.
typealias AF_RetryHandler = (AF_Request, AF_Session, Error, _ completion: @escaping (AF_RetryResult) -> Void) -> Void

// MARK: -

/// Closure-based `RequestAdapter`.
class AF_Adapter: AF_RequestInterceptor {
    private let adaptHandler: AF_AdaptHandler

    /// Creates an instance using the provided closure.
    ///
    /// - Parameter adaptHandler: `AdaptHandler` closure to be executed when handling request adaptation.
    init(_ adaptHandler: @escaping AF_AdaptHandler) {
        self.adaptHandler = adaptHandler
    }

    func adapt(_ urlRequest: URLRequest, for session: AF_Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adaptHandler(urlRequest, session, completion)
    }
}

// MARK: -

/// Closure-based `RequestRetrier`.
class AF_Retrier: AF_RequestInterceptor {
    private let retryHandler: AF_RetryHandler

    /// Creates an instance using the provided closure.
    ///
    /// - Parameter retryHandler: `RetryHandler` closure to be executed when handling request retry.
    init(_ retryHandler: @escaping AF_RetryHandler) {
        self.retryHandler = retryHandler
    }

    func retry(_ request: AF_Request,
                    for session: AF_Session,
                    dueTo error: Error,
                    completion: @escaping (AF_RetryResult) -> Void) {
        retryHandler(request, session, error, completion)
    }
}

// MARK: -

/// `RequestInterceptor` which can use multiple `RequestAdapter` and `RequestRetrier` values.
class AF_Interceptor: AF_RequestInterceptor {
    /// All `RequestAdapter`s associated with the instance. These adapters will be run until one fails.
    let adapters: [AF_RequestAdapter]
    /// All `RequestRetrier`s associated with the instance. These retriers will be run one at a time until one triggers retry.
    let retriers: [AF_RequestRetrier]

    /// Creates an instance from `AdaptHandler` and `RetryHandler` closures.
    ///
    /// - Parameters:
    ///   - adaptHandler: `AdaptHandler` closure to be used.
    ///   - retryHandler: `RetryHandler` closure to be used.
    init(adaptHandler: @escaping AF_AdaptHandler, retryHandler: @escaping AF_RetryHandler) {
        adapters = [AF_Adapter(adaptHandler)]
        retriers = [AF_Retrier(retryHandler)]
    }

    /// Creates an instance from `RequestAdapter` and `RequestRetrier` values.
    ///
    /// - Parameters:
    ///   - adapter: `RequestAdapter` value to be used.
    ///   - retrier: `RequestRetrier` value to be used.
    init(adapter: AF_RequestAdapter, retrier: AF_RequestRetrier) {
        adapters = [adapter]
        retriers = [retrier]
    }

    /// Creates an instance from the arrays of `RequestAdapter` and `RequestRetrier` values.
    ///
    /// - Parameters:
    ///   - adapters:     `RequestAdapter` values to be used.
    ///   - retriers:     `RequestRetrier` values to be used.
    ///   - interceptors: `RequestInterceptor`s to be used.
    init(adapters: [AF_RequestAdapter] = [], retriers: [AF_RequestRetrier] = [], interceptors: [AF_RequestInterceptor] = []) {
        self.adapters = adapters + interceptors
        self.retriers = retriers + interceptors
    }

    func adapt(_ urlRequest: URLRequest, for session: AF_Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapt(urlRequest, for: session, using: adapters, completion: completion)
    }

    private func adapt(_ urlRequest: URLRequest,
                       for session: AF_Session,
                       using adapters: [AF_RequestAdapter],
                       completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var pendingAdapters = adapters

        guard !pendingAdapters.isEmpty else { completion(.success(urlRequest)); return }

        let adapter = pendingAdapters.removeFirst()

        adapter.adapt(urlRequest, for: session) { result in
            switch result {
            case let .success(urlRequest):
                self.adapt(urlRequest, for: session, using: pendingAdapters, completion: completion)
            case .failure:
                completion(result)
            }
        }
    }

    func retry(_ request: AF_Request,
                    for session: AF_Session,
                    dueTo error: Error,
                    completion: @escaping (AF_RetryResult) -> Void) {
        retry(request, for: session, dueTo: error, using: retriers, completion: completion)
    }

    private func retry(_ request: AF_Request,
                       for session: AF_Session,
                       dueTo error: Error,
                       using retriers: [AF_RequestRetrier],
                       completion: @escaping (AF_RetryResult) -> Void) {
        var pendingRetriers = retriers

        guard !pendingRetriers.isEmpty else { completion(.doNotRetry); return }

        let retrier = pendingRetriers.removeFirst()

        retrier.retry(request, for: session, dueTo: error) { result in
            switch result {
            case .retry, .retryWithDelay, .doNotRetryWithError:
                completion(result)
            case .doNotRetry:
                // Only continue to the next retrier if retry was not triggered and no error was encountered
                self.retry(request, for: session, dueTo: error, using: pendingRetriers, completion: completion)
            }
        }
    }
}
