# [Channel io](https://www.channel.io) - Talk with your online customers and increase conversions.
[Channel](https://www.channel.io) is a conversational customer relationship management solution (CRM) for web businesses. Designed to capture potential customers before they leave your site and increase conversions, the web-based SaaS lets you see who’s on your site, what they’re looking at, how long/frequent they’re visiting and finally, drop in and give a little “hello” to online customers in real time.

[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)](https://cocoapods.org/pods/SendBirdSDK)
[![Languages](https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg)](https://github.com/smilefam/sendbird-ios-framework)
[![CocoaPods](https://img.shields.io/badge/pod-v0.1.1-green.svg)](https://cocoapods.org/pods/SendBirdSDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Commercial License](https://img.shields.io/badge/license-Commercial-brightgreen.svg)](https://github.com/smilefam/sendbird-ios-framework/blob/master/LICENSE.md)

## Documentation
https://medium.com/channel-korea/android-plugin-guide-4e047398e76#.x5it8lmqe

## Install Channel plugin Framework from CocoaPods(iOS 8+)

Add below into your Podfile on Xcode.

```
target YOUR_PROJECT_TARGET do
  pod 'CHPlugin'
end
```

Install Channel plugin Framework through CocoaPods.

```
pod install
```

Now you can see Channel plugin framework by inspecting YOUR_PROJECT.xcworkspace.

## Install Channel plugin Framework from Carthage(iOS 8+)

1. Add `github "zoyi/channel-plugin-ios"` to your `Cartfile`.
2. Run `carthage update --platform iOS --no-use-binaries`.
3. Go to your Xcode project's "General" settings. Open `<YOUR_XCODE_PROJECT_DIRECTORY>/Carthage/Checkouts/channel-plugin-ios` in Finder and drag `CHPlugin.framework` to the "Embedded Binaries" section in Xcode along with other dependencies. Make sure `Copy items if needed` is selected and click `Finish`.


