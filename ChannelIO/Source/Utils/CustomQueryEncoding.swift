//
//  CustomQueryEncoding.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

struct CustomQueryEncoding: AF_ParameterEncoding {
  func encode(_ urlRequest: AF_URLRequestConvertible, with parameters: AF_Parameters?) throws -> URLRequest {
    let encoding = AF_URLEncoding(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .literal)
    var request = try encoding.encode(urlRequest, with: parameters)
    let urlString = request.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "=")
    request.url = URL(string: urlString!)
    return request
  }
}
