#
# Be sure to run `pod lib lint CHPlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ChannelIO'
  s.version          = '4.1.6'
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
  #s.script_phase = {
  #  :name => 'ChannelIO Emoji Sync',
  #  :script => '${PODS_TARGET_SRCROOT}/Assets/setup.sh',
  #  :execution_position => :before_compile
  #}
  s.source_files = 'ChannelIO/Source/**/*'
  s.resources = 'ChannelIO/Assets/*'
  s.default_subspec = 'Core'
  s.swift_version = '4.2'

  s.frameworks = 'SystemConfiguration', 'CoreTelephony', 'CoreLocation', 'WebKit'

  s.subspec 'Core' do |core|
    core.dependency 'ChannelIO/Model'
    core.dependency 'ChannelIO/Network'
    core.dependency 'ChannelIO/Image'
    core.dependency 'ChannelIO/Reactive'
    core.dependency 'ChannelIO/Utils'
    core.dependency 'ChannelIO/UI'
  end 
  
  s.subspec 'Model' do |model|
    model.dependency 'ReSwift'
  end

  s.subspec 'Network' do |network|
    network.dependency 'Alamofire'
    network.dependency 'Socket.IO-Client-Swift', '~> 13.1.0'
    network.dependency 'SwiftyJSON'
    network.dependency 'ObjectMapper', '~> 3.3'
  end

  s.subspec 'Image' do |image|
    image.dependency 'Lightbox'
    image.dependency 'SDWebImage'
    image.dependency 'SDWebImage/GIF'
    image.dependency 'DKImagePickerController'
  end 

  s.subspec 'Reactive' do |reactive|
    reactive.dependency 'RxSwift', '~> 4.0'
    reactive.dependency 'RxCocoa', '~> 4.0'
  end

  s.subspec 'Utils' do |utils|
    utils.dependency 'Reusable'
    utils.dependency 'Then'
    utils.dependency 'SVProgressHUD'
    utils.dependency 'M13ProgressSuite'
    utils.dependency 'PhoneNumberKit'
    utils.dependency 'NVActivityIndicatorView'
    utils.dependency 'HexColors'
    utils.dependency 'CHDwifft'
    utils.dependency 'CGFloatLiteral'
  end

  s.subspec 'UI' do |ui|
    ui.dependency 'MGSwipeTableCell'
    ui.dependency 'SnapKit'
    ui.dependency 'ManualLayout'
    ui.dependency 'CRToast'
    ui.dependency 'CHSlackTextViewController'
    ui.dependency 'CHNavBar'
  end
>>>>>>> 59df8ba... swift 4.2 migration
end
