//
//  FileCellModel.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/16.
//

protocol FileCellModelType {
  var type: FileType { get set }
  var url: URL? { get set }
  var thumbUrl: URL? { get set }
  var duration: Double { get set }
  var currSeconds: Double? { get set }
  var height: Int { get set }
  var width: Int { get set }
}

struct FileCellModel: FileCellModelType, VideoPlayable, ThumbDisplayable {
  var type: FileType
  var url: URL?
  var thumbUrl: URL?
  var duration: Double
  var currSeconds: Double?
  var height: Int
  var width: Int
  var isPlayable: Bool
  var youtubeId: String?

  init(_ file: CHFile, seconds: Double? = nil) {
    self.type = file.type
    self.url = file.url
    self.thumbUrl = file.thumbUrl
    self.duration = file.duration
    self.currSeconds = seconds
    self.height = file.height
    self.width = file.width
    self.isPlayable = file.isPlayable
    self.youtubeId = file.youtubeId
  }
}
