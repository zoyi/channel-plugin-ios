//
//  Combine.swift
//
//  Copyright (c) 2020 Alamofire Software Foundation (http://alamofire.org/)
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

#if canImport(Combine)

import Combine
import Dispatch
import Foundation

// MARK: - DataRequest / UploadRequest

/// A Combine `Publisher` that publishes the `DataResponse<Value, AFError>` of the provided `DataRequest`.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
struct AF_DataResponsePublisher<Value>: Publisher {
    typealias Output = AF_DataResponse<Value, AFError>
    typealias Failure = Never

    private typealias Handler = (@escaping (_ response: AF_DataResponse<Value, AFError>) -> Void) -> AF_DataRequest

    private let request: AF_DataRequest
    private let responseHandler: Handler

    /// Creates an instance which will serialize responses using the provided `ResponseSerializer`.
    ///
    /// - Parameters:
    ///   - request:    `DataRequest` for which to publish the response.
    ///   - queue:      `DispatchQueue` on which the `DataResponse` value will be published. `.main` by default.
    ///   - serializer: `ResponseSerializer` used to produce the published `DataResponse`.
    init<Serializer: AF_ResponseSerializer>(_ request: AF_DataRequest, queue: DispatchQueue, serializer: Serializer)
        where Value == Serializer.SerializedObject {
        self.request = request
        responseHandler = { request.response(queue: queue, responseSerializer: serializer, completionHandler: $0) }
    }

    /// Creates an instance which will serialize responses using the provided `DataResponseSerializerProtocol`.
    ///
    /// - Parameters:
    ///   - request:    `DataRequest` for which to publish the response.
    ///   - queue:      `DispatchQueue` on which the `DataResponse` value will be published. `.main` by default.
    ///   - serializer: `DataResponseSerializerProtocol` used to produce the published `DataResponse`.
    init<Serializer: AF_DataResponseSerializerProtocol>(_ request: AF_DataRequest,
                                                            queue: DispatchQueue,
                                                            serializer: Serializer)
        where Value == Serializer.SerializedObject {
        self.request = request
        responseHandler = { request.response(queue: queue, responseSerializer: serializer, completionHandler: $0) }
    }

    /// Publishes only the `Result` of the `DataResponse` value.
    ///
    /// - Returns: The `AnyPublisher` publishing the `Result<Value, AFError>` value.
    func result() -> AnyPublisher<Result<Value, AFError>, Never> {
        map { $0.result }.eraseToAnyPublisher()
    }

    /// Publishes the `Result` of the `DataResponse` as a single `Value` or fail with the `AFError` instance.
    ///
    /// - Returns: The `AnyPublisher<Value, AFError>` publishing the stream.
    func value() -> AnyPublisher<Value, AFError> {
        setFailureType(to: AFError.self).flatMap { $0.result.publisher }.eraseToAnyPublisher()
    }

    func receive<S>(subscriber: S) where S: Subscriber, AF_DataResponsePublisher.Failure == S.Failure, AF_DataResponsePublisher.Output == S.Input {
        subscriber.receive(subscription: Inner(request: request,
                                               responseHandler: responseHandler,
                                               downstream: subscriber))
    }

    private final class Inner<Downstream: Subscriber>: Subscription, Cancellable
        where Downstream.Input == Output {
        typealias Failure = Downstream.Failure

        @AF_Protected
        private var downstream: Downstream?
        private let request: AF_DataRequest
        private let responseHandler: Handler

        init(request: AF_DataRequest, responseHandler: @escaping Handler, downstream: Downstream) {
            self.request = request
            self.responseHandler = responseHandler
            self.downstream = downstream
        }

        func request(_ demand: Subscribers.Demand) {
            assert(demand > 0)

            guard let downstream = downstream else { return }

            self.downstream = nil
            responseHandler { response in
                _ = downstream.receive(response)
                downstream.receive(completion: .finished)
            }.resume()
        }

        func cancel() {
            request.cancel()
            downstream = nil
        }
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension AF_DataResponsePublisher where Value == Data? {
    /// Creates an instance which publishes a `DataResponse<Data?, AFError>` value without serialization.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    init(_ request: AF_DataRequest, queue: DispatchQueue) {
        self.request = request
        responseHandler = { request.response(queue: queue, completionHandler: $0) }
    }
}

extension AF_DataRequest {
    /// Creates a `DataResponsePublisher` for this instance using the given `ResponseSerializer` and `DispatchQueue`.
    ///
    /// - Parameters:
    ///   - serializer: `ResponseSerializer` used to serialize response `Data`.
    ///   - queue:      `DispatchQueue` on which the `DataResponse` will be published. `.main` by default.
    ///
    /// - Returns:      The `DataResponsePublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishResponse<Serializer: AF_ResponseSerializer, T>(using serializer: Serializer, on queue: DispatchQueue = .main) -> AF_DataResponsePublisher<T>
        where Serializer.SerializedObject == T {
        AF_DataResponsePublisher(self, queue: queue, serializer: serializer)
    }

    /// Creates a `DataResponsePublisher` for this instance and uses a `DataResponseSerializer` to serialize the
    /// response.
    ///
    /// - Parameters:
    ///   - queue:               `DispatchQueue` on which the `DataResponse` will be published. `.main` by default.
    ///   - preprocessor:        `DataPreprocessor` which filters the `Data` before serialization. `PassthroughPreprocessor()`
    ///                          by default.
    ///   - emptyResponseCodes:  `Set<Int>` of HTTP status codes for which empty responses are allowed. `[204, 205]` by
    ///                          default.
    ///   - emptyRequestMethods: `Set<HTTPMethod>` of `HTTPMethod`s for which empty responses are allowed, regardless of
    ///                          status code. `[.head]` by default.
    /// - Returns:               The `DataResponsePublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishData(queue: DispatchQueue = .main,
                            preprocessor: AF_DataPreprocessor = AF_DataResponseSerializer.defaultDataPreprocessor,
                            emptyResponseCodes: Set<Int> = AF_DataResponseSerializer.defaultEmptyResponseCodes,
                            emptyRequestMethods: Set<AF_HTTPMethod> = AF_DataResponseSerializer.defaultEmptyRequestMethods) -> AF_DataResponsePublisher<Data> {
        publishResponse(using: AF_DataResponseSerializer(dataPreprocessor: preprocessor,
                                                      emptyResponseCodes: emptyResponseCodes,
                                                      emptyRequestMethods: emptyRequestMethods),
                        on: queue)
    }

    /// Creates a `DataResponsePublisher` for this instance and uses a `StringResponseSerializer` to serialize the
    /// response.
    ///
    /// - Parameters:
    ///   - queue:               `DispatchQueue` on which the `DataResponse` will be published. `.main` by default.
    ///   - preprocessor:        `DataPreprocessor` which filters the `Data` before serialization. `PassthroughPreprocessor()`
    ///                          by default.
    ///   - encoding:            `String.Encoding` to parse the response. `nil` by default, in which case the encoding
    ///                          will be determined by the server response, falling back to the default HTTP character
    ///                          set, `ISO-8859-1`.
    ///   - emptyResponseCodes:  `Set<Int>` of HTTP status codes for which empty responses are allowed. `[204, 205]` by
    ///                          default.
    ///   - emptyRequestMethods: `Set<HTTPMethod>` of `HTTPMethod`s for which empty responses are allowed, regardless of
    ///                          status code. `[.head]` by default.
    ///
    /// - Returns:               The `DataResponsePublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishString(queue: DispatchQueue = .main,
                              preprocessor: AF_DataPreprocessor = AF_StringResponseSerializer.defaultDataPreprocessor,
                              encoding: String.Encoding? = nil,
                              emptyResponseCodes: Set<Int> = AF_StringResponseSerializer.defaultEmptyResponseCodes,
                              emptyRequestMethods: Set<AF_HTTPMethod> = AF_StringResponseSerializer.defaultEmptyRequestMethods) -> AF_DataResponsePublisher<String> {
        publishResponse(using: AF_StringResponseSerializer(dataPreprocessor: preprocessor,
                                                        encoding: encoding,
                                                        emptyResponseCodes: emptyResponseCodes,
                                                        emptyRequestMethods: emptyRequestMethods),
                        on: queue)
    }

    /// Creates a `DataResponsePublisher` for this instance and uses a `DecodableResponseSerializer` to serialize the
    /// response.
    ///
    /// - Parameters:
    ///   - type:                `Decodable` type to which to decode response `Data`. Inferred from the context by default.
    ///   - queue:               `DispatchQueue` on which the `DataResponse` will be published. `.main` by default.
    ///   - preprocessor:        `DataPreprocessor` which filters the `Data` before serialization. `PassthroughPreprocessor()`
    ///                          by default.
    ///   - decoder:             `DataDecoder` instance used to decode response `Data`. `JSONDecoder()` by default.
    ///   - emptyResponseCodes:  `Set<Int>` of HTTP status codes for which empty responses are allowed. `[204, 205]` by
    ///                          default.
    ///   - emptyRequestMethods: `Set<HTTPMethod>` of `HTTPMethod`s for which empty responses are allowed, regardless of
    ///                          status code. `[.head]` by default.
    ///
    /// - Returns:               The `DataResponsePublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishDecodable<T: Decodable>(type: T.Type = T.self,
                                               queue: DispatchQueue = .main,
                                               preprocessor: AF_DataPreprocessor = AF_DecodableResponseSerializer<T>.defaultDataPreprocessor,
                                               decoder: AF_DataDecoder = JSONDecoder(),
                                               emptyResponseCodes: Set<Int> = AF_DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
                                               emptyResponseMethods: Set<AF_HTTPMethod> = AF_DecodableResponseSerializer<T>.defaultEmptyRequestMethods) -> AF_DataResponsePublisher<T> {
        publishResponse(using: AF_DecodableResponseSerializer(dataPreprocessor: preprocessor,
                                                           decoder: decoder,
                                                           emptyResponseCodes: emptyResponseCodes,
                                                           emptyRequestMethods: emptyResponseMethods),
                        on: queue)
    }

    /// Creates a `DataResponsePublisher` for this instance which does not serialize the response before publishing.
    ///
    ///   - queue: `DispatchQueue` on which the `DataResponse` will be published. `.main` by default.
    ///
    /// - Returns: The `DataResponsePublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishUnserialized(queue: DispatchQueue = .main) -> AF_DataResponsePublisher<Data?> {
        AF_DataResponsePublisher(self, queue: queue)
    }
}

// A Combine `Publisher` that publishes a sequence of `Stream<Value, AFError>` values received by the provided `DataStreamRequest`.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
struct AF_DataStreamPublisher<Value>: Publisher {
    typealias Output = AF_DataStreamRequest.Stream<Value, AFError>
    typealias Failure = Never

    private typealias Handler = (@escaping AF_DataStreamRequest.Handler<Value, AFError>) -> AF_DataStreamRequest

    private let request: AF_DataStreamRequest
    private let streamHandler: Handler

    /// Creates an instance which will serialize responses using the provided `DataStreamSerializer`.
    ///
    /// - Parameters:
    ///   - request:    `DataStreamRequest` for which to publish the response.
    ///   - queue:      `DispatchQueue` on which the `Stream<Value, AFError>` values will be published. `.main` by
    ///                 default.
    ///   - serializer: `DataStreamSerializer` used to produce the published `Stream<Value, AFError>` values.
    init<Serializer: AF_DataStreamSerializer>(_ request: AF_DataStreamRequest, queue: DispatchQueue, serializer: Serializer)
        where Value == Serializer.SerializedObject {
        self.request = request
        streamHandler = { request.responseStream(using: serializer, on: queue, stream: $0) }
    }

    /// Publishes only the `Result` of the `DataStreamRequest.Stream`'s `Event`s.
    ///
    /// - Returns: The `AnyPublisher` publishing the `Result<Value, AFError>` value.
    func result() -> AnyPublisher<Result<Value, AFError>, Never> {
        compactMap { stream in
            switch stream.event {
            case let .stream(result):
                return result
            // If the stream has completed with an error, send the error value downstream as a `.failure`.
            case let .complete(completion):
                return completion.error.map(Result.failure)
            }
        }
        .eraseToAnyPublisher()
    }

    /// Publishes the streamed values of the `DataStreamRequest.Stream` as a sequence of `Value` or fail with the
    /// `AFError` instance.
    ///
    /// - Returns: The `AnyPublisher<Value, AFError>` publishing the stream.
    func value() -> AnyPublisher<Value, AFError> {
        result().setFailureType(to: AFError.self).flatMap { $0.publisher }.eraseToAnyPublisher()
    }

    func receive<S>(subscriber: S) where S: Subscriber, AF_DataStreamPublisher.Failure == S.Failure, AF_DataStreamPublisher.Output == S.Input {
        subscriber.receive(subscription: Inner(request: request,
                                               streamHandler: streamHandler,
                                               downstream: subscriber))
    }

    private final class Inner<Downstream: Subscriber>: Subscription, Cancellable
        where Downstream.Input == Output {
        typealias Failure = Downstream.Failure

        @AF_Protected
        private var downstream: Downstream?
        private let request: AF_DataStreamRequest
        private let streamHandler: Handler

        init(request: AF_DataStreamRequest, streamHandler: @escaping Handler, downstream: Downstream) {
            self.request = request
            self.streamHandler = streamHandler
            self.downstream = downstream
        }

        func request(_ demand: Subscribers.Demand) {
            assert(demand > 0)

            guard let downstream = downstream else { return }

            self.downstream = nil
            streamHandler { stream in
                _ = downstream.receive(stream)
                if case .complete = stream.event {
                    downstream.receive(completion: .finished)
                }
            }.resume()
        }

        func cancel() {
            request.cancel()
            downstream = nil
        }
    }
}

extension AF_DataStreamRequest {
    /// Creates a `DataStreamPublisher` for this instance using the given `DataStreamSerializer` and `DispatchQueue`.
    ///
    /// - Parameters:
    ///   - serializer: `DataStreamSerializer` used to serialize the streamed `Data`.
    ///   - queue:      `DispatchQueue` on which the `DataRequest.Stream` values will be published. `.main` by default.
    /// - Returns:      The `DataStreamPublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishStream<Serializer: AF_DataStreamSerializer>(using serializer: Serializer,
                                                                on queue: DispatchQueue = .main) -> AF_DataStreamPublisher<Serializer.SerializedObject> {
        AF_DataStreamPublisher(self, queue: queue, serializer: serializer)
    }

    /// Creates a `DataStreamPublisher` for this instance which uses a `PassthroughStreamSerializer` to stream `Data`
    /// unserialized.
    ///
    /// - Parameters:
    ///   - queue:      `DispatchQueue` on which the `DataRequest.Stream` values will be published. `.main` by default.
    /// - Returns:      The `DataStreamPublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishData(queue: DispatchQueue = .main) -> AF_DataStreamPublisher<Data> {
        publishStream(using: AF_PassthroughStreamSerializer(), on: queue)
    }

    /// Creates a `DataStreamPublisher` for this instance which uses a `StringStreamSerializer` to serialize stream
    /// `Data` values into `String` values.
    ///
    /// - Parameters:
    ///   - queue:      `DispatchQueue` on which the `DataRequest.Stream` values will be published. `.main` by default.
    /// - Returns:      The `DataStreamPublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishString(queue: DispatchQueue = .main) -> AF_DataStreamPublisher<String> {
        publishStream(using: AF_StringStreamSerializer(), on: queue)
    }

    /// Creates a `DataStreamPublisher` for this instance which uses a `DecodableStreamSerializer` with the provided
    /// parameters to serialize stream `Data` values into the provided type.
    ///
    /// - Parameters:
    ///   - type:         `Decodable` type to which to decode stream `Data`. Inferred from the context by default.
    ///   - queue:        `DispatchQueue` on which the `DataRequest.Stream` values will be published. `.main` by default.
    ///   - decoder:      `DataDecoder` instance used to decode stream `Data`. `JSONDecoder()` by default.
    ///   - preprocessor: `DataPreprocessor` which filters incoming stream `Data` before serialization.
    ///                   `PassthroughPreprocessor()` by default.
    /// - Returns:        The `DataStreamPublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishDecodable<T: Decodable>(type: T.Type = T.self,
                                               queue: DispatchQueue = .main,
                                               decoder: AF_DataDecoder = JSONDecoder(),
                                               preprocessor: AF_DataPreprocessor = AF_PassthroughPreprocessor()) -> AF_DataStreamPublisher<T> {
        publishStream(using: AF_DecodableStreamSerializer(decoder: decoder,
                                                       dataPreprocessor: preprocessor),
                      on: queue)
    }
}

/// A Combine `Publisher` that publishes the `DownloadResponse<Value, AFError>` of the provided `DownloadRequest`.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
struct AF_DownloadResponsePublisher<Value>: Publisher {
    typealias Output = AF_DownloadResponse<Value, AFError>
    typealias Failure = Never

    private typealias Handler = (@escaping (_ response: AF_DownloadResponse<Value, AFError>) -> Void) -> AF_DownloadRequest

    private let request: AF_DownloadRequest
    private let responseHandler: Handler

    /// Creates an instance which will serialize responses using the provided `ResponseSerializer`.
    ///
    /// - Parameters:
    ///   - request:    `DownloadRequest` for which to publish the response.
    ///   - queue:      `DispatchQueue` on which the `DownloadResponse` value will be published. `.main` by default.
    ///   - serializer: `ResponseSerializer` used to produce the published `DownloadResponse`.
    init<Serializer: AF_ResponseSerializer>(_ request: AF_DownloadRequest, queue: DispatchQueue, serializer: Serializer)
        where Value == Serializer.SerializedObject {
        self.request = request
        responseHandler = { request.response(queue: queue, responseSerializer: serializer, completionHandler: $0) }
    }

    /// Creates an instance which will serialize responses using the provided `DownloadResponseSerializerProtocol` value.
    ///
    /// - Parameters:
    ///   - request:    `DownloadRequest` for which to publish the response.
    ///   - queue:      `DispatchQueue` on which the `DataResponse` value will be published. `.main` by default.
    ///   - serializer: `DownloadResponseSerializerProtocol` used to produce the published `DownloadResponse`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    init<Serializer: AF_DownloadResponseSerializerProtocol>(_ request: AF_DownloadRequest,
                                                                queue: DispatchQueue,
                                                                serializer: Serializer)
        where Value == Serializer.SerializedObject {
        self.request = request
        responseHandler = { request.response(queue: queue, responseSerializer: serializer, completionHandler: $0) }
    }

    /// Publishes only the `Result` of the `DownloadResponse` value.
    ///
    /// - Returns: The `AnyPublisher` publishing the `Result<Value, AFError>` value.
    func result() -> AnyPublisher<Result<Value, AFError>, Never> {
        map { $0.result }.eraseToAnyPublisher()
    }

    /// Publishes the `Result` of the `DownloadResponse` as a single `Value` or fail with the `AFError` instance.
    ///
    /// - Returns: The `AnyPublisher<Value, AFError>` publishing the stream.
    func value() -> AnyPublisher<Value, AFError> {
        setFailureType(to: AFError.self).flatMap { $0.result.publisher }.eraseToAnyPublisher()
    }

    func receive<S>(subscriber: S) where S: Subscriber, AF_DownloadResponsePublisher.Failure == S.Failure, AF_DownloadResponsePublisher.Output == S.Input {
        subscriber.receive(subscription: Inner(request: request,
                                               responseHandler: responseHandler,
                                               downstream: subscriber))
    }

    private final class Inner<Downstream: Subscriber>: Subscription, Cancellable
        where Downstream.Input == Output {
        typealias Failure = Downstream.Failure

        @AF_Protected
        private var downstream: Downstream?
        private let request: AF_DownloadRequest
        private let responseHandler: Handler

        init(request: AF_DownloadRequest, responseHandler: @escaping Handler, downstream: Downstream) {
            self.request = request
            self.responseHandler = responseHandler
            self.downstream = downstream
        }

        func request(_ demand: Subscribers.Demand) {
            assert(demand > 0)

            guard let downstream = downstream else { return }

            self.downstream = nil
            responseHandler { response in
                _ = downstream.receive(response)
                downstream.receive(completion: .finished)
            }.resume()
        }

        func cancel() {
            request.cancel()
            downstream = nil
        }
    }
}

extension AF_DownloadRequest {
    /// Creates a `DownloadResponsePublisher` for this instance using the given `ResponseSerializer` and `DispatchQueue`.
    ///
    /// - Parameters:
    ///   - serializer: `ResponseSerializer` used to serialize the response `Data` from disk.
    ///   - queue:      `DispatchQueue` on which the `DownloadResponse` will be published.`.main` by default.
    ///
    /// - Returns:      The `DownloadResponsePublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishResponse<Serializer: AF_ResponseSerializer, T>(using serializer: Serializer, on queue: DispatchQueue = .main) -> AF_DownloadResponsePublisher<T>
        where Serializer.SerializedObject == T {
        AF_DownloadResponsePublisher(self, queue: queue, serializer: serializer)
    }

    /// Creates a `DownloadResponsePublisher` for this instance using the given `DownloadResponseSerializerProtocol` and
    /// `DispatchQueue`.
    ///
    /// - Parameters:
    ///   - serializer: `DownloadResponseSerializer` used to serialize the response `Data` from disk.
    ///   - queue:      `DispatchQueue` on which the `DownloadResponse` will be published.`.main` by default.
    ///
    /// - Returns:      The `DownloadResponsePublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishResponse<Serializer: AF_DownloadResponseSerializerProtocol, T>(using serializer: Serializer, on queue: DispatchQueue = .main) -> AF_DownloadResponsePublisher<T>
        where Serializer.SerializedObject == T {
        AF_DownloadResponsePublisher(self, queue: queue, serializer: serializer)
    }

    /// Creates a `DataResponsePublisher` for this instance and uses a `DataResponseSerializer` to serialize the
    /// response.
    ///
    /// - Parameters:
    ///   - queue:               `DispatchQueue` on which the `DataResponse` will be published. `.main` by default.
    ///   - preprocessor:        `DataPreprocessor` which filters the `Data` before serialization. `PassthroughPreprocessor()`
    ///                          by default.
    ///   - emptyResponseCodes:  `Set<Int>` of HTTP status codes for which empty responses are allowed. `[204, 205]` by
    ///                          default.
    ///   - emptyRequestMethods: `Set<HTTPMethod>` of `HTTPMethod`s for which empty responses are allowed, regardless of
    ///                          status code. `[.head]` by default.
    /// - Returns:               The `DownloadResponsePublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishData(queue: DispatchQueue = .main,
                            preprocessor: AF_DataPreprocessor = AF_DataResponseSerializer.defaultDataPreprocessor,
                            emptyResponseCodes: Set<Int> = AF_DataResponseSerializer.defaultEmptyResponseCodes,
                            emptyRequestMethods: Set<AF_HTTPMethod> = AF_DataResponseSerializer.defaultEmptyRequestMethods) -> AF_DownloadResponsePublisher<Data> {
        publishResponse(using: AF_DataResponseSerializer(dataPreprocessor: preprocessor,
                                                      emptyResponseCodes: emptyResponseCodes,
                                                      emptyRequestMethods: emptyRequestMethods),
                        on: queue)
    }

    /// Creates a `DataResponsePublisher` for this instance and uses a `StringResponseSerializer` to serialize the
    /// response.
    ///
    /// - Parameters:
    ///   - queue:               `DispatchQueue` on which the `DataResponse` will be published. `.main` by default.
    ///   - preprocessor:        `DataPreprocessor` which filters the `Data` before serialization. `PassthroughPreprocessor()`
    ///                          by default.
    ///   - encoding:            `String.Encoding` to parse the response. `nil` by default, in which case the encoding
    ///                          will be determined by the server response, falling back to the default HTTP character
    ///                          set, `ISO-8859-1`.
    ///   - emptyResponseCodes:  `Set<Int>` of HTTP status codes for which empty responses are allowed. `[204, 205]` by
    ///                          default.
    ///   - emptyRequestMethods: `Set<HTTPMethod>` of `HTTPMethod`s for which empty responses are allowed, regardless of
    ///                          status code. `[.head]` by default.
    ///
    /// - Returns:               The `DownloadResponsePublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishString(queue: DispatchQueue = .main,
                              preprocessor: AF_DataPreprocessor = AF_StringResponseSerializer.defaultDataPreprocessor,
                              encoding: String.Encoding? = nil,
                              emptyResponseCodes: Set<Int> = AF_StringResponseSerializer.defaultEmptyResponseCodes,
                              emptyRequestMethods: Set<AF_HTTPMethod> = AF_StringResponseSerializer.defaultEmptyRequestMethods) -> AF_DownloadResponsePublisher<String> {
        publishResponse(using: AF_StringResponseSerializer(dataPreprocessor: preprocessor,
                                                        encoding: encoding,
                                                        emptyResponseCodes: emptyResponseCodes,
                                                        emptyRequestMethods: emptyRequestMethods),
                        on: queue)
    }

    /// Creates a `DataResponsePublisher` for this instance and uses a `DecodableResponseSerializer` to serialize the
    /// response.
    ///
    /// - Parameters:
    ///   - type:                `Decodable` type to which to decode response `Data`. Inferred from the context by default.
    ///   - queue:               `DispatchQueue` on which the `DataResponse` will be published. `.main` by default.
    ///   - preprocessor:        `DataPreprocessor` which filters the `Data` before serialization. `PassthroughPreprocessor()`
    ///                          by default.
    ///   - decoder:             `DataDecoder` instance used to decode response `Data`. `JSONDecoder()` by default.
    ///   - emptyResponseCodes:  `Set<Int>` of HTTP status codes for which empty responses are allowed. `[204, 205]` by
    ///                          default.
    ///   - emptyRequestMethods: `Set<HTTPMethod>` of `HTTPMethod`s for which empty responses are allowed, regardless of
    ///                          status code. `[.head]` by default.
    ///
    /// - Returns:               The `DownloadResponsePublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishDecodable<T: Decodable>(type: T.Type = T.self,
                                               queue: DispatchQueue = .main,
                                               preprocessor: AF_DataPreprocessor = AF_DecodableResponseSerializer<T>.defaultDataPreprocessor,
                                               decoder: AF_DataDecoder = JSONDecoder(),
                                               emptyResponseCodes: Set<Int> = AF_DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
                                               emptyResponseMethods: Set<AF_HTTPMethod> = AF_DecodableResponseSerializer<T>.defaultEmptyRequestMethods) -> AF_DownloadResponsePublisher<T> {
        publishResponse(using: AF_DecodableResponseSerializer(dataPreprocessor: preprocessor,
                                                           decoder: decoder,
                                                           emptyResponseCodes: emptyResponseCodes,
                                                           emptyRequestMethods: emptyResponseMethods),
                        on: queue)
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension AF_DownloadResponsePublisher where Value == URL? {
    /// Creates an instance which publishes a `DownloadResponse<URL?, AFError>` value without serialization.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    init(_ request: AF_DownloadRequest, queue: DispatchQueue) {
        self.request = request
        responseHandler = { request.response(queue: queue, completionHandler: $0) }
    }
}

extension AF_DownloadRequest {
    /// Creates a `DownloadResponsePublisher` for this instance which does not serialize the response before publishing.
    ///
    /// - Parameter queue: `DispatchQueue` on which the `DownloadResponse` will be published. `.main` by default.
    ///
    /// - Returns:         The `DownloadResponsePublisher`.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func publishUnserialized(on queue: DispatchQueue = .main) -> AF_DownloadResponsePublisher<URL?> {
        AF_DownloadResponsePublisher(self, queue: queue)
    }
}

#endif
