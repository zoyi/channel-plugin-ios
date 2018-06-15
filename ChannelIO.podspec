#
# Be sure to run `pod lib lint CHPlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ChannelIO'
  s.version          = '3.2.0'
  s.summary          = 'Channel plugin for iOS'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Channel Plugin for iOS'
  s.homepage         = 'https://www.channel.io'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'SDK', :file => 'LICENSE' }
  s.author           = { 'ZOYI' => 'eng@zoyi.co' }
  s.source           = { :git => 'https://github.com/zoyi/channel-plugin-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0.0' }

  s.source_files = 'ChannelIO/Source/**/*'
  s.resources = 'ChannelIO/Assets/*'
  s.frameworks = 'SystemConfiguration', 'CoreTelephony', 'CoreLocation', 'WebKit'
  s.requires_arc = 'true' 
 
  s.dependency 'Reusable'
  s.dependency 'SnapKit'
  s.dependency 'ManualLayout'
  s.dependency 'HexColors'
  s.dependency 'SwiftyJSON'
  s.dependency 'Then'
  s.dependency 'ReSwift'
  s.dependency 'RxSwift', '~> 4.0'
  s.dependency 'RxCocoa', '~> 4.0'
  s.dependency 'ObjectMapper'
  s.dependency 'NVActivityIndicatorView'
  s.dependency 'CHDwifft'
  s.dependency 'DKImagePickerController'
  s.dependency 'Alamofire'
  s.dependency 'CGFloatLiteral'
  s.dependency 'Socket.IO-Client-Swift', '~> 13.1.0' 
  s.dependency 'CHSlackTextViewController'
  s.dependency 'MGSwipeTableCell'
  s.dependency 'M13ProgressSuite'
  s.dependency 'CHPhotoBrowser'
  s.dependency 'SVProgressHUD'
  s.dependency 'CRToast'
  s.dependency 'PhoneNumberKit'
  s.dependency 'CHNavBar'
end
