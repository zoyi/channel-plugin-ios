//
//  FilePromise.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/04.
//

import Alamofire
import ObjectMapper
import RxSwift
import SwiftyJSON

struct FilePromise {
  static func uploadFile(
    channelId: String,
    filename: String,
    data: Data) -> Observable<([String:Any]?, Double)> {
    return Observable.create { subscriber in
      let url = CDNService.UploadFile(channelId, filename)
      let req = AF
        .upload(data, to: url, method: url.method, headers: url.authHeaders)
        .uploadProgress(closure: { progress in
          subscriber.onNext((nil, progress.fractionCompleted))
        })
        .validate(statusCode: 200..<300)
        .asyncResponse { response in
          switch response.result {
          case .success(let data):
            let result = SwiftyJSON.JSON(data).dictionaryObject
            subscriber.onNext((result, 1))
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        }
      return Disposables.create {
        req.cancel()
      }
    }
  }
}
