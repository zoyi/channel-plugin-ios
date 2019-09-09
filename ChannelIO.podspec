#
# Be sure to run `pod lib lint CHPlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ChannelIO'
  s.version          = '6.1.1'
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
  s.ios.deployment_target = '9.1'
  #s.script_phase = {
  #  :name => 'ChannelIO Emoji Sync',
  #  :script => '${PODS_TARGET_SRCROOT}/Assets/setup.sh',
  #  :execution_position => :before_compile
  #}
  s.source_files = 'ChannelIO/Source/**/*.{swift, h, m}'
  
  s.resource_bundles = {
    'ChannelIO' => [
      'ChannelIO/Assets/*'
    ]
  }
  s.swift_version = '5.0'

  s.frameworks = 'CoreTelephony'
 
  s.dependency 'Reusable', '~> 4.0'
  s.dependency 'SnapKit', '~> 4.0'
  s.dependency 'SwiftyJSON', '~> 4.0'
  s.dependency 'ReSwift', '~> 4.0'
  s.dependency 'RxSwift', '~> 4.0'
  s.dependency 'RxCocoa', '~> 4.0'
  s.dependency 'ObjectMapper', '~> 3.3'
  s.dependency 'NVActivityIndicatorView', '~> 4.4.0'
  s.dependency 'CHDwifft'
  s.dependency 'Alamofire', '~> 4.8'
  s.dependency 'Socket.IO-Client-Swift', '~> 15.0.0' 
  s.dependency 'CHSlackTextViewController'
  s.dependency 'MGSwipeTableCell'
  s.dependency 'M13ProgressSuite'
  s.dependency 'SVProgressHUD'
  s.dependency 'CRToast'
  s.dependency 'PhoneNumberKit', '~> 2.6.0'
  s.dependency 'SDWebImage', '~> 5.0.0'
  s.dependency 'RxSwiftExt'
  s.dependency 'TLPhotoPicker'
end
