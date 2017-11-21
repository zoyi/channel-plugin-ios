#
# Be sure to run `pod lib lint CHPlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CHPlugin'
  s.version          = '2.3.3'
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

  s.source_files = 'CHPlugin/Source/**/*'
  s.resources = 'CHPlugin/Assets/*'
  s.frameworks = 'SystemConfiguration', 'CoreTelephony', 'CoreLocation', 'WebKit'
  s.requires_arc = 'true' 
 
  s.dependency 'Reusable'
  s.dependency 'SnapKit'
  s.dependency 'ManualLayout'
  s.dependency 'UIColor_Hex_Swift'
  s.dependency 'SwiftDate'
  s.dependency 'SwiftyJSON'
  s.dependency 'Then'
  s.dependency 'ReSwift'
  s.dependency 'RxSwift'
  s.dependency 'ObjectMapper'
  s.dependency 'NVActivityIndicatorView'
  s.dependency 'CHDwifft'
  s.dependency 'DKImagePickerController'
  s.dependency 'Alamofire'
  s.dependency 'CGFloatLiteral'
  s.dependency 'Socket.IO-Client-Swift', '~> 12.0.0' 
  s.dependency 'CHSlackTextViewController'
  s.dependency 'MGSwipeTableCell'
  s.dependency 'M13ProgressSuite'
  s.dependency 'CHPhotoBrowser'
  s.dependency 'SVProgressHUD'
  s.dependency 'CRToast'
  s.dependency 'PhoneNumberKit'
  s.dependency "StarscreamSocketIO", "~> 8.0.3"
end

