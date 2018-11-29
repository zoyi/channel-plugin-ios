//
//  Alamofire+Extensions.swift
//  ChannelIO
//
//  Created by Haeun Chung on 18/10/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import Alamofire

extension DataRequest {
  
  /// Adds a handler to be called once the request has finished.
  ///
  /// - parameter options:           The JSON serialization reading options. Defaults to `.allowFragments`.
  /// - parameter completionHandler: A closure to be executed once the request has finished.
  ///
  /// - returns: The request.
  @discardableResult
  public func asyncResponse(
    queue: DispatchQueue? = nil,
    options: JSONSerialization.ReadingOptions = .allowFragments,
    completionHandler: @escaping (DataResponse<Data>) -> Void) -> Self {
    return response(
      queue: queue == nil ? RestRouter.queue : queue,
      responseSerializer: DataRequest.dataResponseSerializer(options: options),
      completionHandler: completionHandler
    )
  }
  
  public static func dataResponseSerializer(
    options: JSONSerialization.ReadingOptions = .allowFragments) -> DataResponseSerializer<Data> {
    return DataResponseSerializer { _, response, data, error in
      let result = Request.serializeResponseData(response: response, data: data, error: error)
      
      switch result {
      case .success(let value):
        return .success(value)
      case .failure(let error):
        return .failure(error)
      }
    }
  }
}



