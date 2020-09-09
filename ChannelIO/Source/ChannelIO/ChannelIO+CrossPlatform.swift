//
//  ChannelIO+CrossPlatform.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/09/09.
//

extension ChannelIO {
  @objc
  public final class CrossPlatformUtils: NSObject {
    @objc
    public class func openBrowser(url: URL?) {
      if let url = url {
        url.openWithUniversal()
      }
    }
  }
}
