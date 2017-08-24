Pod::Spec.new do |s|  
  s.name              = 'CHPlugin'
  s.version           = '1.1.0'
  s.summary           = 'Channel plugin for iOS'
  s.homepage          = 'http://www.channel.io'

  s.author            = { 'Zoyi' => 'eng@zoyi.co' }
  s.license           = { :type => 'SDK', :file => 'LICENSE' }

  s.platform          = :ios
  s.source            = { :git => 'https://github.com/zoyi/channel-plugin-ios.git', :tag => s.version }
	
	s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.ios.vendored_frameworks = 'CHPlugin.framework'

  s.dependency 'CHSlackTextViewController'
  s.dependency 'MGSwipeTableCell'
  s.dependency 'M13ProgressSuite'
  s.dependency 'MWPhotoBrowser'
  s.dependency 'SVProgressHUD'
  s.dependency 'CRToast'
  s.dependency 'PhoneNumberKit'
  s.dependency "StarscreamSocketIO", "~> 8.0.3"
end 
